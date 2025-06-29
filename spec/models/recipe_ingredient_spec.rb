# frozen_string_literal: true

RSpec.describe RecipeIngredient, type: :model do
  describe 'associations' do
    it { should belong_to(:recipe) }
    it { should belong_to(:ingredient) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:unit) }
    it { should validate_length_of(:unit).is_at_most(20) }
    it { should validate_length_of(:notes).is_at_most(100) }
  end

  describe "scopes" do
    let(:recipe) { create(:recipe) }
    let!(:main_ingredient) { create(:recipe_ingredient, recipe: recipe, quantity: 2, unit: "cups") }
    let!(:seasoning) { create(:recipe_ingredient, recipe: recipe, quantity: 0.5, unit: "tsp") }

    it "orders by qiantity descending" do
      expect(RecipeIngredient.by_quantity.first).to eq(main_ingredient)
    end
  end

  describe "instance methods" do
    let(:recipe_ingredient) { create(:recipe_ingredient, quantity: 1.5, unit: "cups", notes: "diced") }

    describe "#display_quantity" do
      it "formats quantity" do
        expect(recipe_ingredient.display_quantity).to eq(1.5)
      end

      context "with whole number" do
        let(:recipe_ingredient) { create(:recipe_ingredient, quantity: 2.0) }

        it "displays without decimal" do
          expect(recipe_ingredient.display_quantity).to eq(2)
        end
      end
    end

    describe "#full_description" do
      it "combines quantity, unit, ingredient name and notes" do
        expected = "1.5 cups #{recipe_ingredient.ingredient.name} (diced)"
        expect(recipe_ingredient.full_description).to eq(expected)
      end
    end
  end

  describe "uniqueness" do
    let(:recipe) { create(:recipe) }
    let(:ingredient) { create(:ingredient) }

    it "prevents duplicate ingredients per recipe" do
      create(:recipe_ingredient, recipe: recipe, ingredient: ingredient)
      duplicate = build(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:ingredient_id]).to include("has already been taken")
    end
  end
end
