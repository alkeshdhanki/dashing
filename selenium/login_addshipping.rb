require "json"
require "selenium-webdriver"
require "rspec"
if ENV['headless'] == "true" then
	require "headless"
end
include RSpec::Expectations

describe "LoginAddshipping" do

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
  
  it "test_login_addshipping" do
    @driver.get(@base_url + "/welcome.html")
    @driver.find_element(:css, "a.top_right_btn3").click
    @driver.find_element(:name, "login").clear
    @driver.find_element(:name, "login").send_keys "rrssel1@gmail.com"
    @driver.find_element(:name, "password").clear
    @driver.find_element(:name, "password").send_keys "Pa88w0rd"
    @driver.find_element(:css, "input[type=\"submit\"]").click
    @driver.find_element(:link, "MY SHIPPING ADDRESS").click
    @driver.find_element(:link, "ADD A NEW SHIPPING ADDRESS").click
    @driver.find_element(:id, "registration-shipping-streetname").clear
    @driver.find_element(:id, "registration-shipping-streetname").send_keys "1700 Broadway"
    @driver.find_element(:id, "registration-city").clear
    @driver.find_element(:id, "registration-city").send_keys "New York"
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "registration-state")).select_by(:index, 33)
    @driver.find_element(:id, "registration-postal-code").clear
    @driver.find_element(:id, "registration-postal-code").send_keys "10019"
    @driver.find_element(:id, "registration-mobile").clear
    @driver.find_element(:id, "registration-mobile").send_keys "2125962000"
    @driver.find_element(:css, "input.my_shipping_address_form_btn").click
    @driver.find_element(:link, "Sign out").click
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
