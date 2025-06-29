# frozen_string_literal: true

RSpec.describe RecipeStep, type: :model do
  describe "associations" do
    it { should belong_to(:recipe) }

    it "has an attached image" do
      expect(RecipeStep.new.image).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end

  describe "validations" do
    it { should validate_presence_of(:step_number) }
    it { should validate_presence_of(:instruction) }
    it { should validate_numericality_of(:step_number).is_greater_than(0) }
    it { should validate_length_of(:instruction).is_at_most(1000) }
  end

  describe "scopes" do
    let(:recipe) { create(:recipe) }
    let!(:step_3) { create(:recipe_step, recipe: recipe, step_number: 3) }
    let!(:step_1) { create(:recipe_step, recipe: recipe, step_number: 1) }
    let!(:step_2) { create(:recipe_step, recipe: recipe, step_number: 2) }

    it "orders by step number" do
      expect(recipe.recipe_steps.ordered).to eq([ step_1, step_2, step_3 ])
    end
  end

  describe "callbacks" do
    let(:recipe) { create(:recipe) }

    context "when creating steps without step_number" do
      it "auto-assigns next step number" do
        create(:recipe_step, recipe: recipe, step_number: 1)
        create(:recipe_step, recipe: recipe, step_number: 2)

        new_step = build(:recipe_step, recipe: recipe, step_number: nil)
        new_step.save!

        expect(new_step.step_number).to eq(3)
      end
    end

    context "when recipe has no existing steps" do
      it "assigns step number 1" do
        step = build(:recipe_step, recipe: recipe, step_number: nil)
        step.save!

        expect(step.step_number).to eq(1)
      end
    end
  end

  describe "instance methods" do
    let(:step) { create(:recipe_step, instruction: "Heat oil in a large pan over medium heat.") }

    describe "#short_instruction" do
      context "with long instruction" do
        let(:long_instruction) { "This is a very long instruction that goes on and on and should be truncated when displayed in summary views because it contains too much detail for a quick overview." }
        let(:step) { create(:recipe_step, instruction: long_instruction) }

        it "truncates instruction to 100 characters" do
          expect(step.short_instruction).to eq("This is a very long instruction that goes on and on and should be truncated when displayed in sum......")
        end
      end

      context "with short instruction" do
        it "returns full instruction" do
          expect(step.short_instruction).to eq("Heat oil in a large pan over medium heat.")
        end
      end
    end

    describe "#has_image?" do
      context "with attached image" do
        let(:step) { create(:recipe_step, :with_image) }

        it "returns true" do
          expect(step.has_image?).to be true
        end
      end

      context "without attached image" do
        it "returns false" do
          expect(step.has_image?).to be false
        end
      end
    end
  end

  describe "uniqueness validation" do
    let(:recipe) { create(:recipe) }

    it "prevents duplicate step numbers per recipe" do
      create(:recipe_step, recipe: recipe, step_number: 1)
      duplicate = build(:recipe_step, recipe: recipe, step_number: 1)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:step_number]).to include("has already been taken")
    end

    it "allows same step number for different recipes" do
      other_recipe = create(:recipe)
      create(:recipe_step, recipe: recipe, step_number: 1)
      other_step = build(:recipe_step, recipe: other_recipe, step_number: 1)

      expect(other_step).to be_valid
    end
  end
end
