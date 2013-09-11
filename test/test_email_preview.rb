require 'helper'

class TestEmailPreview < Test::Unit::TestCase
  context "with fixtures defined in test/dummy/config/initializers/email_preview.rb" do
    should "have entries in registry" do
      assert_equal 3, EmailPreview.registry.length
    end
  end

  context "with additional params" do
    setup do
      EmailPreview.transactional = false
    end

    should "not affect fixtures that don't take params" do
      assert_nothing_raised(ArgumentError) { EmailPreview.preview(0) }
    end

    should "pass hash to email fixture" do
      mail = EmailPreview.preview 2, "email=test@test.com"
      assert_equal ["test@test.com"], mail.to
    end
  end
end

class EmailPreviewControllerTest < ActionController::TestCase
  context "passing params to preview" do
    should "accept attributes from form" do
      get :preview, :id => 2, :extra => "email=test@test.com&name=John+Appleseed"
      mail = assigns(:mail)
      assert_match(/John\sAppleseed/, mail.body.to_s)
    end
  end
end