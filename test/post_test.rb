require File.dirname(__FILE__) + "/help"

describe 'Post' do
  before do
    @post = Post.new(:title => "This is the Title!", :body => "body text")
  end

  it "should create the correct slug" do
    @post.make_slug!
    @post.slug.should == "this_is_the_title"
  end

  it "should have a correctly formatted url" do
    @post.make_slug!
    @post.save
    d = Time.now
    @post.url.should == "post/#{d.year}/#{d.month}/#{d.day}/#{@post.slug}"
  end

  it "should create the correct summary if has a SHORT body" do
    @post.make_summary!
    @post.summary.should == "body text"
  end

  it "should create the correct summary if has a LONG body" do
    @post.body = <<-LONGBODY
     Two before narrow not relied how except moment myself. Dejection assurance mrs led certainly. So gate at no only none open. Betrayed at properly it of graceful on. Dinner abroad am depart ye turned hearts as me wished. Therefore allowance too perfectly gentleman supposing man his now. Families goodness all eat out bed steepest servants. Explained the incommode sir improving northward immediate eat. Man denoting received you sex possible you. Shew park own loud son door less yet. 

    Domestic confined any but son bachelor advanced remember. How proceed offered her offence shy forming. Returned peculiar pleasant but appetite differed she. Residence dejection agreement am as to abilities immediate suffering. Ye am depending propriety sweetness distrusts belonging collected. Smiling mention he in thought equally musical. Wisdom new and valley answer. Contented it so is discourse recommend. Man its upon him call mile. An pasture he himself believe ferrars besides cottage. 

    Society excited by cottage private an it esteems. Fully begin on by wound an. Girl rich in do up or both. At declared in as rejoiced of together. He impression collecting delightful unpleasant by prosperous as on. End too talent she object mrs wanted remove giving. 

    Advanced extended doubtful he he blessing together. Introduced far law gay considered frequently entreaties difficulty. Eat him four are rich nor calm. By an packages rejoiced exercise. To ought on am marry rooms doubt music. Mention entered an through company as. Up arrived no painful between. It declared is prospect an insisted pleasure. 
    LONGBODY
    @post.make_summary!
    @post.summary.should == @post.body[0..50]
  end

  it "should have a html safe body_html" do
    @post.body = <<-UNSAFE
      <a href="/">a</a><script>alert('hello');</script>
    UNSAFE
    @post.body_html.strip.should == (<<-SAFE
      <pre><code>  &lt;a href=\"/\"&gt;a&lt;/a&gt;&lt;script&gt;alert('hello');&lt;/script&gt;\n</code></pre>
    SAFE
    ).strip
  end
end
