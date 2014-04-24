require "nokogiri"
# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10m', :first_in => 0 do |job|
	#s = IO.read('selenium/rspecreport1.html');
	#puts s
	testresults = Array.new
    #header=Array.new
    #header.push("Test Case")
    #header.push("Result")
    #testresults.push(header)
	@doc = Nokogiri::HTML(File.open("selenium/rspecreport.html"))

	passedtests = @doc.css("span[class=passed_spec_name]")

	passedtests.each do |testname|
		testrow=Array.new
		
		testrow.push(testname.text)
		testrow.push("Passed")
		#testresults.push(testrow)
		testresults.push({label: testname.text, value: "Passed"})
	end

	failedtests = @doc.css("span[class=failed_spec_name]")

	failedtests.each do |testname|
		testrow=Array.new
		
		testrow.push(testname.text)
		testrow.push("Failed")
		#testresults.push(testrow)
		testresults.push({label: testname.text, value: "Failed"})
		
	end
 	puts testresults
 	send_event('rackroom_selenium_results', {items: testresults})
end

