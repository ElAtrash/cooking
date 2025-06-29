# frozen_string_literal: true

RSpec.describe FavoriteRecipe, type: :model do
  describe "associations" do
    it { should belong_to(:recipe) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:recipe) { create(:recipe) }

    it "prevents user from favoriting same recipe twice" do
      create(:favorite_recipe, user: user, recipe: recipe)
      duplicate = build(:favorite_recipe, user: user, recipe: recipe)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows different users to favorite same recipe" do
      other_user = create(:user)
      create(:favorite_recipe, user: user, recipe: recipe)
      other_favorite = build(:favorite_recipe, user: other_user, recipe: recipe)

      expect(other_favorite).to be_valid
    end

    it "allows same user to favorite different recipes" do
      other_recipe = create(:recipe)
      create(:favorite_recipe, user: user, recipe: recipe)
      other_favorite = build(:favorite_recipe, user: user, recipe: other_recipe)

      expect(other_favorite).to be_valid
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let!(:recent_favorite) { create(:favorite_recipe, user: user, created_at: 1.day.ago) }
    let!(:old_favorite) { create(:favorite_recipe, user: user, created_at: 1.week.ago) }

    it "orders by newest first" do
      expect(FavoriteRecipe.recent.first).to eq(recent_favorite)
      expect(FavoriteRecipe.recent.last).to eq(old_favorite)
    end

    it "finds favorites for a specific user" do
      other_user = create(:user)
      other_favorite = create(:favorite_recipe, user: other_user)

      user_favorites = FavoriteRecipe.for_user(user)
      expect(user_favorites).to include(recent_favorite, old_favorite)
      expect(user_favorites).not_to include(other_favorite)
    end
  end

  describe "class methods" do
    let(:user) { create(:user) }
    let(:recipe) { create(:recipe) }

    describe ".toggle_for" do
      context "when favorite does not exist" do
        it "creates a new favorite" do
          expect {
            FavoriteRecipe.toggle_for(user, recipe)
          }.to change(FavoriteRecipe, :count).by(1)
        end

        it "returns the created favorite" do
          favorite = FavoriteRecipe.toggle_for(user, recipe)
          expect(favorite).to be_persisted
          expect(favorite.user).to eq(user)
          expect(favorite.recipe).to eq(recipe)
        end
      end

      context "when favorite already exists" do
        let!(:existing_favorite) { create(:favorite_recipe, user: user, recipe: recipe) }

        it "destroys the existing favorite" do
          expect {
            FavoriteRecipe.toggle_for(user, recipe)
          }.to change(FavoriteRecipe, :count).by(-1)
        end

        it "returns nil" do
          result = FavoriteRecipe.toggle_for(user, recipe)
          expect(result).to be_nil
        end
      end
    end
  end
end
