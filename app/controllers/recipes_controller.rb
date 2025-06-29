# frozen_string_literal: true

class RecipesController < ApplicationController
  include Pagy::Backend

  allow_unauthenticated_access only: [ :index, :show ]
  before_action :resume_session
  before_action :set_recipe, only: [ :show, :edit, :update, :destroy, :favorite ]
  before_action :authorize_recipe_owner!, only: [ :edit, :update, :destroy ]
  before_action :increment_view_count, only: [ :show ]

  def index
    @pagy, @recipes = pagy(filtered_recipes.includes(:user, image_attachment: :blob), limit: 12)

    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("recipes_list", partial: "recipes_list", locals: { recipes: @recipes, pagy: @pagy }) }
    end
  end

  def show
    @ingredients = @recipe.recipe_ingredients.includes(:ingredient)
    @steps = @recipe.recipe_steps.ordered
    @ratings = @recipe.recipe_ratings.recent.includes(:user).limit(10)
    @user_rating = Current.user&.recipe_ratings&.find_by(recipe: @recipe)
    @new_rating = Current.user ? RecipeRating.new : nil
  end

  def new
    @recipe = Current.user.recipes.build
    build_default_steps
  end

  def edit
    build_missing_steps if @recipe.recipe_steps.empty?
  end

  def create
    @recipe = Current.user.recipes.build(recipe_params)

    if @recipe.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  def update
    if @recipe.update(recipe_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  def destroy
    @recipe.destroy!

    respond_to do |format|
      format.html { redirect_to recipes_path, notice: success_message(:deleted) }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@recipe) }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    handle_deletion_error(e)
  end

  def favorite
    favorite = FavoriteRecipe.toggle_for(Current.user, @recipe)

    respond_to do |format|
      format.html { redirect_to @recipe }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "favorite_button_#{@recipe.id}",
          partial: "shared/favorite_button",
          locals: { recipe: @recipe, favorited: favorite.present? }
        )
      end
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to recipes_path, alert: "Recipe not found."
  end

  def authorize_recipe_owner!
    unless Current.user == @recipe.user
      redirect_to recipe_path(@recipe), alert: "You are not authorized to perform this action."
    end
  end

  def increment_view_count
    return unless Current.user && Current.user != @recipe.user

    @recipe.increment(:views_count)
    @recipe.save if @recipe.changed?
  end

  def filtered_recipes
    recipes = Recipe.includes(:user, image_attachment: :blob)
    recipes = apply_search_filter(recipes)
    recipes = apply_difficulty_filter(recipes)
    recipes = apply_user_filter(recipes)
    recipes = apply_sorting(recipes)
    recipes
  end

  def apply_search_filter(recipes)
    return recipes unless params[:search].present?

    recipes.search(params[:search])
  end

  def apply_difficulty_filter(recipes)
    return recipes unless params[:difficulty].present?

    recipes.by_difficulty(params[:difficulty])
  end

  def apply_user_filter(recipes)
    return recipes unless params[:user] == "mine" && Current.user

    Current.user.recipes
  end

  def apply_sorting(recipes)
    case params[:sort]
    when "rating"
      recipes.left_joins(:recipe_ratings)
             .group("recipes.id")
             .order("avg(recipe_ratings.rating) desc nulls last")
    when "popularity"
      recipes.order(favorite_recipes_count: :desc)
    when "total_time"
      recipes.order(Arel.sql("prep_time + cook_time asc"))
    when "difficulty"
      recipes.order(
        Arel.sql("case difficulty_level when 'easy' then 1 when 'medium' then 2 when 'hard' then 3 end")
      )
    else
      recipes.recent
    end
  end

  def build_default_steps
    return if @recipe.recipe_steps.any?

    3.times { |i| @recipe.recipe_steps.build(step_number: i + 1) }
  end

  def build_missing_steps
    return if @recipe.recipe_steps.present?

    build_default_steps
  end

  def handle_successful_creation
    respond_to do |format|
      format.html { redirect_to @recipe, notice: success_message(:created) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("recipes", partial: "recipe_card", locals: { recipe: @recipe }),
          turbo_stream.replace("recipe_form", partial: "shared/flash_messages", locals: {
            type: :notice, message: success_message(:created)
          })
        ]
      end
    end
  end

  def handle_failed_creation
    build_missing_steps
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "recipe_form",
          partial: "form",
          locals: { recipe: @recipe }
        )
      end
    end
  end

  def handle_successful_update
    respond_to do |format|
      format.html { redirect_to @recipe, notice: success_message(:updated) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(@recipe, partial: "recipe_card", locals: { recipe: @recipe }),
          turbo_stream.replace("flash_messages", partial: "shared/flash", locals: {
            type: :notice, message: success_message(:updated)
          })
        ]
      end
    end
  end

  def handle_failed_update
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "recipe_form",
          partial: "form",
          locals: { recipe: @recipe }
        )
      end
    end
  end

  def handle_deletion_error(error)
    respond_to do |format|
      format.html { redirect_to @recipe, alert: "Error deleting recipe: #{error.message}" }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "flash_messages",
          partial: "shared/flash",
          locals: { type: :alert, message: "Error deleting recipe: #{error.message}" }
        )
      end
    end
  end

  def success_message(action)
    "Recipe was successfully #{action}."
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :prep_time, :cook_time, :servings, :difficulty_level, :image,
      recipe_steps_attributes: [ :id, :instruction, :step_number, :image, :_destroy ],
      recipe_ingredients_attributes: [ :id, :ingredient_id, :quantity, :unit, :notes, :_destroy ]
    )
  end
end
