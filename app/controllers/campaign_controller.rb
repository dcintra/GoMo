class CampaignController < ApplicationController

  def adwords_access #this method accesses the api with all appropriate credentials
    config_filename = File.join(Rails.root, 'config', 'adwords_api.yml') #retrieve all of the appropriate login credentials from the adwords_api.yml file
    adwords = AdwordsApi::Api.new(config_filename) #create a new instance with all the credentials
  end
  
  def index
    @adwords = adwords_access #creates instance of api
    response = call_campaign_criterion() #response has all the information from the API
    if response
        @campaign_criterion = CampaignCriterion.get_criterion_list(response) #create a new object (get criterion list) with the data retrieved from API (response) 
        @campaign_criterion_count = response[:total_num_entries]
    end
    campaign_response = call_campaign() #response has all the information from the API
    if campaign_response
        @campaign_details = Campaign.get_campaign_info(campaign_response) #create a new object (get campaign info) with the data retrieved from API (response) 
        @campaign_details_count = response[:total_num_entries]
    end
    
    copy_campaign 
    add_campaigns
  end

  def check_for_hybrid
    @campaign_criterion.each_key do |campaignId| #find the campaign_ids for the CID
      @campaignId = campaignId
      @campaign_criterion[campaignId.to_i].any? do |hybrid| #loop through them and check whether they are targeting both Mobile (id=30001) and Desktop (id=3000)
        @is_hybrid = hybrid[:id] == 30000 & 30001 #if they are tell me if it's true or false
          if @is_hybrid = true #if it's true, split out the campaign into desktop & mobile
            "HYBRID CAMPAIN" #insert splitting campaign details here
        end
      end
    end  
  end

  def call_campaign_criterion() #retrieve all the necessary fields from the api
    campaign_srv = @adwords.service(:CampaignCriterionService, :v201209) 
      criterion_service = campaign_srv.get({
      :fields => ['Id', 'CriteriaType', 'KeywordText'],
      # :predicates => [
      #   {:field => 'CriteriaType', :operator => 'EQUALS', :values => ['PLATFORM']}]
      })
  end 

  def call_campaign() #retrieve all the campaign info for specific hybrid campaign 
    campaign_srv = @adwords.service(:CampaignService, :v201209) 
      campaign_service = campaign_srv.get({
      :fields => ['Id', 'Name', 'Status', 'StartDate', 'EndDate', 'Settings'],
      :predicates => [
        {:field => 'Id', :operator => 'EQUALS', :values => ['90823468']}] #INSERT campaign ID here
      })
  end 
  
  def add_campaign_targeting_criteria(campaign_id)
    campaign_criterion_srv = adwords.service(:CampaignCriterionService, :v201209) # Create campaign criteria.
    campaign_criteria = [
    # Location criteria. The IDs can be found in the documentation or retrieved
    # with the LocationCriterionService.
    {:xsi_type => 'Location', :id => 21137}, # California, USA
    {:xsi_type => 'Location', :id => 2484},  # Mexico
    # Language criteria. The IDs can be found in the documentation or retrieved
    # with the ConstantDataService.
    {:xsi_type => 'Language', :id => 1000},  # English
    {:xsi_type => 'Language', :id => 1003},  # Spanish
    # Platform criteria. The IDs can be found in the documentation.
    {:xsi_type => 'Platform', :id => 30001}, # Mobile
   ]   

    # Create operations.
    operations = campaign_criteria.map do |criterion|
      {:operator => 'ADD',
       :operand => {
         :campaign_id => @newcampaign_id, 
         :criterion => criterion}
      }
    end

   # Add negative campaign criterion.
   operations << {
     :operator => 'ADD',
     :operand => {
      # The 'xsi_type' field allows you to specify the xsi:type of the object
      # being created. It's only necessary when you must provide an explicit
      # type that the client library can't infer.
      :xsi_type => 'NegativeCampaignCriterion',
      :campaign_id => campaign_id,
      :criterion => {
        :xsi_type => 'Keyword',
        :text => 'jupiter cruise',
        :match_type => 'BROAD'
      }
     }
    }

    response = campaign_criterion_srv.mutate(operations)

    if response and response[:value]
    criteria = response[:value]
    criteria.each do |campaign_criterion|
      criterion = campaign_criterion[:criterion]
      puts ("Campaign criterion with campaign ID %d, criterion ID %d and " +
          "type '%s' was added.") % [campaign_criterion[:campaign_id],
          criterion[:id], criterion[:criterion_type]]
    end
   else
    puts 'No criteria were returned.'
   end
  end

  

  def add_campaigns()

   budget_srv = @adwords.service(:BudgetService, :v201209)
   campaign_srv = @adwords.service(:CampaignService, :v201209)
   budget = {
    :name => 'Sup Budget3',
    :amount => {:micro_amount => 5000000},
    :delivery_method => 'STANDARD',
    :period => 'DAILY'
   }
   budget_operation = {:operator => 'ADD', :operand => budget}

   # Add budget.
   return_budget = budget_srv.mutate([budget_operation])
   budget_id = return_budget[:value].first[:budget_id]

   # Create campaigns.
   campaigns = [{
      :name => @campaigncopy_name +"_MobileOnly",
      :status => 'PAUSED',
      :bidding_strategy => { :xsi_type => 'ManualCPC'},
      :budget => {:budget_id => budget_id},
      :network_setting => {
        :target_google_search => true,
        :target_search_network => true,
        :target_content_network => false
      },
      :start_date => DateTime.parse((Date.today + 1).to_s).strftime('%Y%m%d'),
      :ad_serving_optimization_status => 'ROTATE',
      :settings => [
         {
          :xsi_type => 'GeoTargetTypeSetting',
          :positive_geo_target_type => 'DONT_CARE',
          :negative_geo_target_type => 'DONT_CARE'
        },
        {
          :xsi_type => 'KeywordMatchSetting',
          :opt_in => true
        },
      ]
    }]

    # Prepare for adding campaign.
    operations = campaigns.map do |campaign|
    {:operator => 'ADD', :operand => campaign}
    end
    # Add campaign.
    addcampaign_response = campaign_srv.mutate(operations)
    addcampaign_response[:value].each do |newcampaign|
      @newcampaign_id = newcampaign[:id]
    end #add campaign with copied attributes
  end


  def copy_campaign_attr #copy important campaign attributes: name, status, id, start/enddate, settings, geo-target
    @campaign_details.each do |id, campaign|
      @campaigncopy_name = campaign.name
      @campaigncopy_status = campaign.status
      @campaigncopy_startdate = campaign.startdate
      @campaigncopy_enddate = campaign.enddate
      @campaigncopy_settings = campaign.settings
      @campaigncopy_posgeo = campaign.settings.find {|n| n[:positive_geo_target_type]}[:positive_geo_target_type]
      @campaigncopy_neggeo = campaign.settings.find {|n| n[:positive_geo_target_type]}[:positive_geo_target_type]
    end
  end

  def update_remove_mobile #update campaign => remove mobile from old campaign
  end

  def shared_budget #initiate shared budget
  end
end
