$: << File.join(File.dirname(__FILE__), "../lib")

require 'rubygems'
require 'test/unit'
require 'models'

class PostTest < Test::Unit::TestCase
  def test_make_slug_works
    post = Post.new(:title => "This is the Title!", :body => "body text")
    post.make_slug!
    assert_respond_to post, :make_slug!
    assert_equal post.slug, "this_is_the_title"
  end
end
