require File.dirname(__FILE__) + "/help"

describe 'Page' do
  before do
    @page = Page.new(:title => "About", :body => "About this article")
  end

  it "should have a proper slug" do
    @page.slug.should == "about"
  end

  it "should url" do
    @page.url.should == "about"
  end

  it "should body_html" do
    @page.body_html.strip.should == "<p>About this article</p>"
  end
end
