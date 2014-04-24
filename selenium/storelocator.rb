require "json"
require "selenium-webdriver"
require "rspec"
if ENV['headless'] == "true" then
	require "headless"
end
include RSpec::Expectations

describe "StoreLocator" do

  before(:each) do
    if ENV['headless'] == "true" then
    	@headless = Headless.new
		@headless.start
	end
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://www.offbroadwayshoes.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  
  it "test_store_locator" do
    @driver.get(@base_url + "/welcome.html")
    @driver.find_element(:link, "STORE LOCATOR").click
    @driver.find_element(:id, "byZip").click
    @driver.find_element(:name, "zipCode").clear
    @driver.find_element(:name, "zipCode").send_keys "07095"
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "distance")).select_by(:value, "5")
    # ERROR: Caught exception [Error: unknown strategy [class] for locator [class=map_info_btn btn_black store_btn_search_locations]]
    # ERROR: Caught exception [Error: unknown strategy [class] for locator [class=storeLocatorError]]
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "distance")).select_by(:value, "100")
    # ERROR: Caught exception [Error: unknown strategy [class] for locator [class=map_info_btn btn_black store_btn_search_locations]]
    # ERROR: Caught exception [Error: unknown strategy [class] for locator [class=storeLocatorError]]
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
