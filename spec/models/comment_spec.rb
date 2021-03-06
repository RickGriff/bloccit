require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    # disable creation of favorite by, and initial email to, user who creates post - for ease of testing with a new post
    Post.any_instance.stub(:create_favorite)
    Post.any_instance.stub(:send_email_notification)
  end
  
  # create test objects using FactoryGirl
  let(:topic) { create(:topic) }
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:comment) { create(:comment) }
  
  it { is_expected.to belong_to(:commentable) }
  
  it {is_expected.to validate_presence_of(:body) }
  it {is_expected.to validate_length_of(:body).is_at_least(5) }
  
  describe "attributes" do
    it "has a body attribute" do
      expect(comment).to have_attributes(body: comment.body)
    end
  end
  
   describe "after_create" do
    before do
      @another_comment = Comment.new(body: 'Comment Body', commentable: post, user: user)
    end
 
    it "sends an email to users who have favorited the post" do
      favorite = user.favorites.create(post: post)
      expect(FavoriteMailer).to receive(:new_comment).with(user, post, @another_comment).and_return(double(deliver_now: true))
 
      @another_comment.save!
    end

    it "does not send emails to users who haven't favorited the post" do
      #new_comment shouldn't be called when a comment is added to a post a user hasn't favorited
      expect(FavoriteMailer).not_to receive(:new_comment)
 
      @another_comment.save!
    end
  end
end
