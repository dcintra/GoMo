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
  end

  def call_campaign_criterion() #retrieve all the necessary fields from the api
    campaign_srv = @adwords.service(:CampaignCriterionService, :v201209) 
      criterion_service = campaign_srv.get({
      :fields => ['Id', 'CriteriaType', 'KeywordText'],
      })
  end 

  def hybrid_campaign_filter
    hybrid_campaign = @campaigns
  end



 # PAGE_SIZE = 50

  # def index()
  #   @selected_account = selected_account

  #   if @selected_account
  #     response = request_campaigns_list()
  #     if response
  #       @campaigns = Campaign.get_campaigns_list(response)
  #       @campaign_count = response[:total_num_entries]
  #     end
  #   end
  #   response_a = [] << response
  
  # end

  private

 def request_campaigns_list()
    api = get_adwords_api()
    service = api.service(:CampaignService, get_api_version())
    selector = {
      :fields => ['Id', 'Name', 'Status'],
      :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
      :paging => {:start_index => 0, :number_results => PAGE_SIZE}
    }
    result = service.get(selector)
  end

  def get_campaign_targeting_criteria(campaign_id) #debug statement, logs
    api = get_adwords_api()
    service = api.service(:CampaignCriterionService, get_api_version())
    selector = {
      :fields => ['Id', 'CriteriaType', 'KeywordText'],
      :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
      :paging => {:start_index => 0, :number_results => PAGE_SIZE}
    }
    result = service.get(selector)
  end
end
