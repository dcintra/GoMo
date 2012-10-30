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
      :predicates => [
        {:field => 'CriteriaType', :operator => 'EQUALS', :values => ['PLATFORM']}]
      })
  end 

  def hybrid_campaign_filter
    hybrid_campaign = @campaigns
  end


end
