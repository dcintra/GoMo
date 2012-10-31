class Campaign

  attr_reader :id
  attr_reader :name
  attr_reader :status
  attr_reader :startdate
  attr_reader :enddate
  attr_reader :settings

  def initialize(api_campaign)
    @id = api_campaign[:id]
    @name = api_campaign[:name]
    @status = api_campaign[:status]
    @startdate = api_campaign[:startdate]
    @enddate = api_campaign[:enddate]
    @settings = api_campaign[:settings]
  end

  def self.get_campaign_info(campaign_response)
    result = {}
    if campaign_response[:entries]
      campaign_response[:entries].each do |api_campaign|
        campaign = Campaign.new(api_campaign)
        result[campaign.id] = campaign
      end
    end
    return result
  end
end
