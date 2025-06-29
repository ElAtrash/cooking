# frozen_string_literal: true

RSpec.describe RecipeRating, type: :model do
  describe "associations" do
    it { should belong_to(:recipe) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).is_in(1..5) }
    it { should validate_length_of(:comment).is_at_most(500) }
  end

  describe "scopes" do
    let(:recipe) { create(:recipe) }
    let!(:high_rating) { create(:recipe_rating, recipe: recipe, rating: 5) }
    let!(:low_rating) { create(:recipe_rating, recipe: recipe, rating: 2) }
    let!(:recent_rating) { create(:recipe_rating, recipe: recipe, rating: 4, created_at: 1.day.ago) }
    let!(:old_rating) { create(:recipe_rating, recipe: recipe, rating: 3, created_at: 1.week.ago) }

    it "filters by minimum rating" do
      expect(RecipeRating.with_min_rating(4)).to include(high_rating, recent_rating)
      expect(RecipeRating.with_min_rating(4)).to_not include(low_rating)
    end

    it "orders by oldest last" do
      expect(RecipeRating.recent.last).to eq(old_rating)
    end

    it "orders by highest rating first" do
      expect(RecipeRating.by_rating.first).to eq(high_rating)
      expect(RecipeRating.by_rating.last).to eq(low_rating)
    end
  end

  describe "instance methods" do
    let(:rating) { create(:recipe_rating, rating: 4, comment: "Great recipe!") }

    describe "#stars_display" do
      it "returns filled and empty stars" do
        expect(rating.stars_display).to eq("★★★★☆")
      end

      context "with 5 stars" do
        let(:rating) { create(:recipe_rating, rating: 5) }
        it "returns all filled stars" do
          expect(rating.stars_display).to eq("★★★★★")
        end
      end

      context "with 1 star" do
        let(:rating) { create(:recipe_rating, rating: 1) }

        it "returns mostly empty stars" do
          expect(rating.stars_display).to eq("★☆☆☆☆")
        end
      end
    end

    describe "#has_comment?" do
      context "with comment" do
        it "returns true" do
          expect(rating.has_comment?).to be true
        end
      end

      context "without comment" do
        let(:rating) { create(:recipe_rating, comment: "") }

        it "returns false" do
          expect(rating.has_comment?).to be false
        end
      end
    end

    describe "#short_comment" do
      context "with long comment" do
        let(:long_comment) { "This is a really long comment that goes on and on about how amazing this recipe is and should be truncated." }
        let(:rating) { create(:recipe_rating, comment: long_comment) }

        it "truncates comment to 100 characters" do
          expect(rating.short_comment).to eq("This is a really long comment that goes on and on about how amazing this recipe is and should be ......")
        end
      end

      context "with short comment" do
        it "returns full comment" do
          expect(rating.short_comment).to eq("Great recipe!")
        end
      end
    end
  end

  describe "callbacks" do
    let(:recipe) { create(:recipe) }

    it "updates recipe average rating after create" do
      expect(recipe).to receive(:update_average_rating)
      create(:recipe_rating, recipe: recipe)
    end

    it "updates recipe average rating after update" do
      rating = create(:recipe_rating, recipe: recipe)
      expect(recipe).to receive(:update_average_rating)
      rating.update(rating: 5)
    end

    it "updates recipe average rating after destroy" do
      rating = create(:recipe_rating, recipe: recipe)
      expect(recipe).to receive(:update_average_rating)
      rating.destroy
    end
  end

  describe "uniqueness validation" do
    let(:user) { create(:user) }
    let(:recipe) { create(:recipe) }

    it "prevents user from rating same recipe twice" do
      create(:recipe_rating, user: user, recipe: recipe)
      duplicate = build(:recipe_rating, user: user, recipe: recipe)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows different users to rate same recipe" do
      other_user = create(:user)
      create(:recipe_rating, user: user, recipe: recipe)
      other_rating = build(:recipe_rating, user: other_user, recipe: recipe)

      expect(other_rating).to be_valid
    end
  end
end
