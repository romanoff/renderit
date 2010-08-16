require File.dirname(__FILE__) + '/spec_helper.rb'

describe RenderIt do
  
  it "should load config file" do
    RenderIt.load_config.should == true
  end  

  it "should parse Chrome browser user_agent" do
    browser = RenderIt.get_browser("Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/533.9 (KHTML, like Gecko) Chrome/6.0.401.1 Safari/533.9")
    browser.name.should == 'chrome'
    browser.version.should == '6.0'
  end

  it "should parse Firefox browser user_agent" do 
    browser = RenderIt.get_browser("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100416 Mandriva Linux/1.9.2.3-0.2mdv2010.0 (2010.0) Firefox/3.6.3")
    browser.name.should == 'firefox'
    browser.version.should == '3.6'
  end

  it "should parse IE browser user_agent" do
    browser = RenderIt.get_browser("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)")
    browser.name.should == 'ie'
    browser.version.should == '8.0'
  end

  it "should parse Opera browser user_agent" do
    browser = RenderIt.get_browser("Opera/9.80 (Windows NT 5.1; U; ru) Presto/2.5.24 Version/10.53")
    browser.name.should == 'opera'
    browser.version.should == '10.5'    
  end

  it "should parse Safari browser user_agent" do
    browser = RenderIt.get_browser("Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-us) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16")
    browser.name.should == 'safari'
    browser.version.should == '5.0'    
  end

  it "should parse SafariMobile browser user_agent" do
    browser = RenderIt.get_browser("Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2_1 like Mac OS X; ru-ru) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20")
    browser.name.should == 'safarimobile'
    browser.version.should == '3.1'    
  end

  it "should parse SafariMobile browser user_agent" do
    browser = RenderIt.get_browser("UNDEFINED USER_AGENT")
    browser.should be_nil
  end

  it "should return 'new' template name" do
    request = create_request("Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/533.9 (KHTML, like Gecko) Chrome/6.0.401.1 Safari/533.9")
    RenderIt.get_template_name(request).should == 'new'     
  end

  it "should return blank template name if browser is old" do
    request = create_request("Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)")
    RenderIt.get_template_name(request).should == ''     
  end

  it "should return blank template name if unknown browser" do
    request = create_request("UNDEFINED USER_AGENT")
    RenderIt.get_template_name(request).should == ''     
  end

end

def create_request(user_agent)
  request = Object.new
  request.stub!(:env).and_return({'HTTP_USER_AGENT' => user_agent})
  return request
end
