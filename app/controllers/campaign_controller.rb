class CampaignController < ApplicationController

  def adwords_access #this method accesses the api with all appropriate credentials
    config_filename = File.join(Rails.root, 'config', 'adwords_api.yml') #retrieve all of the appropriate login credentials from the adwords_api.yml file
    adwords = AdwordsApi::Api.new(config_filename) #create a new instance with all the credentials
  end
  
  def index
    @adwords = adwords_access #creates instance 
    response = call_campaign_criterion() #response has all the information from the API
    if response
        @campaign_criterion = CampaignCriterion.get_criterion_list(response) #create a new object (get criterion list) with the data retrieved from API (response) 
        @campaign_criterion_count = response[:total_num_entries]
    end
    campaign_response = call_campaign()
    if campaign_response
        @campaign_details = Campaign.get_campaign_info(campaign_response)
        @campaign_details_count = response[:total_num_entries]
    end
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
      :predicates => [
        {:field => 'CriteriaType', :operator => 'EQUALS', :values => ['PLATFORM']}]
      })
  end 

  def call_campaign() #retrieve all the campaign info for specific hybrid campaign
    campaign_srv = @adwords.service(:CampaignService, :v201209) 
      campaign_service = campaign_srv.get({
      :fields => ['Id', 'Name', 'Status', 'StartDate', 'EndDate', 'Settings'],
      :predicates => [
        {:field => 'Id', :operator => 'EQUALS', :values => ['90823468']}]
      })
  end 

  def copy_campaign #copy campaign info and set to mobile only
  end

  def update_remove_mobile #update campaign => remove mobile
  end

  def shared_budget #initiate shared budget
  end
   
  
  
  


end
