require_relative '../test_helper'

class NeedTest < ActiveSupport::TestCase

  context "saving need data to the Need API" do
    setup do
      @atts = {
        "role" => "user",
        "goal" => "do stuff",
        "benefit" => "get stuff",
        "organisation_ids" => ["ministry-of-justice"],
        "impact" => "Endangers the health of individuals",
        "justifications" => ["it's something only government does", "the government is legally obliged to provide it"],
        "met_when" => ["Winning"],
        "currently_met" => true,
        "other_evidence" => "Ministerial priority",
        "legislation" => "Vehicle Excise and Registration Act 1994, schedule 4",
        "monthly_user_contacts" => 500,
        "monthly_site_views" => 70000,
        "monthly_need_views" => 15000,
        "monthly_searches" => 2000,
      }
    end

    context "given valid attributes" do
      should "make a request to the need API with an author" do
        need = Need.new(@atts)
        author = User.new(name: "O'Brien", email: "obrien@alphagov.co.uk", uid: "user-1234")

        request = @atts.merge(
          "author" => {
            "name" => "O'Brien",
            "email" => "obrien@alphagov.co.uk",
            "uid" => "user-1234"
          })
        response = @atts.merge(
          "_response_info" => {
            "status" => "created"
          })

        GdsApi::NeedApi.any_instance.expects(:create_need).with(request).returns(status: 201, body: response.to_json)

        assert need.save_as(author)
      end

      context "preparing a need as json" do
        should "present attributes as json" do
          json = Need.new(@atts).as_json

          assert_equal @atts.keys.sort, json.keys.sort
          assert_equal "user", json["role"]
          assert_equal "do stuff", json["goal"]
          assert_equal "get stuff", json["benefit"]
          assert_equal ["ministry-of-justice"], json["organisation_ids"]
          assert_equal "Endangers the health of individuals", json["impact"]
          assert_equal ["it's something only government does", "the government is legally obliged to provide it"], json["justifications"]
          assert_equal ["Winning"], json["met_when"]
        end

        should "ignore the errors attribute" do
          need = Need.new(@atts)
          need.valid? # invoking this sets the errors attribute

          json = need.as_json

          assert json.has_key?("role")
          refute json.has_key?("errors")
        end

        should "set the correct boolean value for currently_met" do
          need = Need.new("currently_met" => true)
          assert_equal true, need.as_json["currently_met"]

          need = Need.new("currently_met" => "true")
          assert_equal true, need.as_json["currently_met"]

          need = Need.new("currently_met" => false)
          assert_equal false, need.as_json["currently_met"]

          need = Need.new("currently_met" => "false")
          assert_equal false, need.as_json["currently_met"]

          need = Need.new("currently_met" => nil)
          assert_nil need.as_json["currently_met"]
        end
      end
    end

    should "raise an exception when non-whitelisted fields are present" do
      assert_raises(ArgumentError) do
        Need.new(@atts.merge("foo" => "bar", "bar" => "baz"))
      end
    end

    should "be invalid when role is blank" do
      need = Need.new(@atts.merge("role" => ""))

      refute need.valid?
      assert need.errors.has_key?(:role)
    end

    should "be invalid when goal is blank" do
      need = Need.new(@atts.merge("goal" => ""))

      refute need.valid?
      assert need.errors.has_key?(:goal)
    end

    should "be invalid when benefit is blank" do
      need = Need.new(@atts.merge("benefit" => ""))

      refute need.valid?
      assert need.errors.has_key?(:benefit)
    end

    should "be invalid when justifications are not in the list" do
      need = Need.new(@atts.merge("justifications" => ["something else"]))

      refute need.valid?
      assert need.errors.has_key?(:justifications)
    end

    should "be invalid when impact is not in the list" do
      need = Need.new(@atts.merge("impact" => "something else"))

      refute need.valid?
      assert need.errors.has_key?(:impact)
    end

    should "be invalid with a non-numeric value for monthly_user_contacts" do
      need = Need.new(@atts.merge("monthly_user_contacts" => "foo"))

      refute need.valid?
      assert need.errors.has_key?(:monthly_user_contacts)
    end

    should "be invalid with a non-numeric value for monthly_site_views" do
      need = Need.new(@atts.merge("monthly_site_views" => "foo"))

      refute need.valid?
      assert need.errors.has_key?(:monthly_site_views)
    end

    should "be invalid with a non-numeric value for monthly_need_views" do
      need = Need.new(@atts.merge("monthly_need_views" => "foo"))

      refute need.valid?
      assert need.errors.has_key?(:monthly_need_views)
    end

    should "be invalid with a non-numeric value for monthly_searches" do
      need = Need.new(@atts.merge("monthly_searches" => "foo"))

      refute need.valid?
      assert need.errors.has_key?(:monthly_searches)
    end

    should "be valid with a blank value for monthly_user_contacts" do
      need = Need.new(@atts.merge("monthly_user_contacts" => ""))

      assert need.valid?
    end

    should "be valid with a blank value for monthly_site_views" do
      need = Need.new(@atts.merge("monthly_site_views" => ""))

      assert need.valid?
    end

    should "be valid with a blank value for monthly_need_views" do
      need = Need.new(@atts.merge("monthly_need_views" => ""))

      assert need.valid?
    end

    should "be valid with a blank value for monthly_searches" do
      need = Need.new(@atts.merge("monthly_searches" => ""))

      assert need.valid?
    end
  end
end
