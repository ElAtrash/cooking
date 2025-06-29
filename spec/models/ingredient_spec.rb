# frozen_string_literal: true

RSpec.describe Ingredient, type: :model do
  describe "associations" do
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:recipes).through(:recipe_ingredients) }
  end

  describe "validations" do
    let!(:existing_ingredient) { create(:ingredient, name: "Salt", category: "spices") }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(50) }
    it { should validate_inclusion_of(:category).in_array(%w[produce dairy meat seafood grains spices pantry other]) }
  end

  describe "scopes" do
    let!(:tomato) { create(:ingredient, name: "Tomato", category: "produce") }
    let!(:milk) { create(:ingredient, name: "Milk", category: "dairy") }
    let!(:chicken) { create(:ingredient, name: "Chicken", category: "meat") }

    it "filters by category" do
      expect(Ingredient.by_category("produce")).to include(tomato)
      expect(Ingredient.by_category("produce")).not_to include(milk)
    end

    it "searches by name" do
      expect(Ingredient.search("tom")).to include(tomato)
      expect(Ingredient.search("tom")).not_to include(milk)
    end

    it "orders alphabetically" do
      expect(Ingredient.alphabetical).to eq([ chicken, milk, tomato ])
    end
  end

  describe "instance methods" do
    let(:ingredient) { create(:ingredient, name: "tomato") }

    describe "#display_name" do
      it "capitalizes the name" do
        expect(ingredient.display_name).to eq("Tomato")
      end
    end

    describe "#category_color" do
      it "returns appropriate color for category" do
        produce_ingredient = create(:ingredient, category: "produce")
        expect(produce_ingredient.category_color).to eq("green")

        dairy_ingredient = create(:ingredient, category: "dairy")
        expect(dairy_ingredient.category_color).to eq("blue")
      end
    end
  end

  describe "callbacks" do
    it "downcases name before saving" do
      ingredient = create(:ingredient, name: "GARLIC")
      expect(ingredient.name).to eq("garlic")
    end
  end
end
