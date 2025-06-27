# frozen_string_literal: true

RSpec.describe Recipe, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
    it { should have_many(:recipe_steps).dependent(:destroy) }
    it { should have_many(:recipe_ratings).dependent(:destroy) }
    it { should have_many(:favorite_recipes).dependent(:destroy) }
    it { should have_one_attached(:image) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:prep_time) }
    it { should validate_presence_of(:cook_time) }
    it { should validate_presence_of(:servings) }
    it { should validate_presence_of(:difficulty_level) }

    it { should validate_numericality_of(:prep_time).is_greater_than(0) }
    it { should validate_numericality_of(:cook_time).is_greater_than(0) }
    it { should validate_numericality_of(:servings).is_greater_than(0) }

    it { should validate_inclusion_of(:difficulty_level).in_array(%w[easy medium hard]) }

    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(500) }
  end

  describe 'scopes' do
    let!(:easy_recipe) { create(:recipe, difficulty_level: 'easy') }
    let!(:hard_recipe) { create(:recipe, difficulty_level: 'hard') }
    let!(:quick_recipe) { create(:recipe, prep_time: 10, cook_time: 15) }
    let!(:slow_recipe) { create(:recipe, prep_time: 30, cook_time: 60) }

    it 'filters by difficulty level' do
      expect(Recipe.by_difficulty('easy')).to include(easy_recipe)
      expect(Recipe.by_difficulty('easy')).not_to include(hard_recipe)
    end

    it 'finds quick recipes (total time <= 30 minutes)' do
      expect(Recipe.quick).to include(quick_recipe)
      expect(Recipe.quick).not_to include(slow_recipe)
    end

    it 'orders by newest first' do
      expect(Recipe.recent.first).to eq(slow_recipe) # created last
    end
  end

  describe 'instance methods' do
    let(:recipe) { create(:recipe, prep_time: 15, cook_time: 30) }

    describe '#total_time' do
      it 'returns sum of prep and cook time' do
        expect(recipe.total_time).to eq(45)
      end
    end

    describe '#average_rating' do
      context 'with ratings' do
        before do
          create(:recipe_rating, recipe: recipe, rating: 4)
          create(:recipe_rating, recipe: recipe, rating: 5)
          create(:recipe_rating, recipe: recipe, rating: 3)
        end

        it 'returns average rating rounded to 1 decimal' do
          expect(recipe.average_rating).to eq(4.0)
        end
      end

      context 'without ratings' do
        it 'returns 0' do
          expect(recipe.average_rating).to eq(0)
        end
      end
    end

    describe '#favorited_by?' do
      let(:user) { create(:user) }

      context 'when user has favorited the recipe' do
        before { create(:favorite_recipe, user: user, recipe: recipe) }

        it 'returns true' do
          expect(recipe.favorited_by?(user)).to be true
        end
      end

      context 'when user has not favorited the recipe' do
        it 'returns false' do
          expect(recipe.favorited_by?(user)).to be false
        end
      end
    end
  end

  describe 'search functionality' do
    let!(:pasta_recipe) { create(:recipe, title: 'Spaghetti Carbonara', description: 'Creamy pasta dish') }
    let!(:pizza_recipe) { create(:recipe, title: 'Margherita Pizza', description: 'Classic Italian pizza') }
    let!(:salad_recipe) { create(:recipe, title: 'Caesar Salad', description: 'Fresh green salad') }

    it 'searches by title' do
      results = Recipe.search('spaghetti')
      expect(results).to include(pasta_recipe)
      expect(results).not_to include(pizza_recipe)
    end

    it 'searches by description' do
      results = Recipe.search('italian')
      expect(results).to include(pizza_recipe)
      expect(results).not_to include(salad_recipe)
    end

    it 'is case insensitive' do
      results = Recipe.search('PIZZA')
      expect(results).to include(pizza_recipe)
    end
  end
end
