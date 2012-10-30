class CampaignCriterion < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_reader :campaign_id
  attr_reader :criterion

  def initialize(api_criterion)
    @campaign_id = api_criterion[:campaign_id]
    @criterion = api_criterion[:criterion]
  end

  def self.get_criterion_list(response)
    result = {}
    if response[:entries] #once we get the data from the API loop through the data, create a new Criterion object & initialize it with the values
      response[:entries].each do |api_criterion|
        campaign_criterion = CampaignCriterion.new(api_criterion)
        if result[campaign_criterion.campaign_id] == nil #once you've found the campaign_id and it's empty create an array for that campaign
        	result[campaign_criterion.campaign_id] = Array.new()
        end
        result[campaign_criterion.campaign_id] << campaign_criterion.criterion #take the criteria type hash for each campaign and place it into an array 
      end
    end
    return result #we're done with creating the campaigncriterion object
  end
end
