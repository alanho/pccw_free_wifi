require "mechanize"

class PccwWifi
  LANDING_URL = "http://hotspot.pccwwifi.com/index.jsp"

  def login
    landing_page do |page|
      page.form_with(:name => "OnlineSubscriptionForm") do |form|
        form.so_agree = "on"
        form.so_planid = 58
        form.so_secure = "NA"
      end.submit
    end unless connected?
  end

  def logout
    disconnect_button.click if connected?
  end

  def expires_at
    matches = /date:"(?<datestr>[0-9\/]+ [0-9:]+ (?:AM|PM))/.match(landing_page.content)

    Time.strptime(matches[:datestr], "%m/%d/%Y %I:%M:%S %p") if matches
  end

  def connected?
    !disconnect_button.nil?
  end

  private
  def landing_page
    agent.get(LANDING_URL)
  end

  def disconnect_button
    landing_page.link_with(:href => /\/disconnect/)
  end

  def agent
    @agent ||= Mechanize.new { |agent|
      agent.user_agent_alias = "Mac Safari"
      agent.follow_meta_refresh = true
    }
  end
end