# frozen_string_literal: true

RSpec.describe RecipesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }
  let(:other_user_recipe) { create(:recipe, user: other_user) }

  describe 'GET #index' do
    let!(:recipes) { create_list(:recipe, 3, user: user) }
    let!(:other_recipes) { create_list(:recipe, 2, user: other_user) }

    context 'when not authenticated' do
      it 'returns all recipes' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(assigns(:recipes).count).to eq(5)
      end
    end

    context 'when authenticated' do
      before { sign_in user }

      it 'returns all recipes' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(assigns(:recipes).count).to eq(5)
      end

      it 'filters by search term' do
        recipe.update(title: 'Delicious Pasta')
        get :index, params: { search: 'pasta' }
        expect(assigns(:recipes)).to include(recipe)
      end

      it 'filters by difficulty' do
        easy_recipe = create(:recipe, difficulty_level: 'easy')
        get :index, params: { difficulty: 'easy' }
        expect(assigns(:recipes)).to include(easy_recipe)
      end

      it 'filters by user (my recipes)' do
        get :index, params: { user: 'mine' }
        expect(assigns(:recipes).count).to eq(3)
        expect(assigns(:recipes)).to all(have_attributes(user: user))
      end

      it 'paginates results' do
        create_list(:recipe, 20)
        get :index
        expect(assigns(:pagy)).to be_present
      end
    end

    context 'with Turbo request' do
      before { sign_in user }

      it 'renders partial for infinite scroll' do
        request.headers['Accept'] = 'text/vnd.turbo-stream.html'
        get :index
        expect(response).to render_template('recipes/_recipes')
      end
    end
  end

  describe 'GET #show' do
    context 'when recipe exists' do
      it 'shows the recipe' do
        get :show, params: { id: recipe.id }
        expect(response).to have_http_status(:ok)
        expect(assigns(:recipe)).to eq(recipe)
      end

      it 'increments view count for authenticated users' do
        sign_in other_user
        expect {
          get :show, params: { id: recipe.id }
        }.to change { recipe.reload.views_count }.by(1)
      end

      it 'loads recipe components' do
        recipe = create(:recipe, :complete)
        get :show, params: { id: recipe.id }

        expect(assigns(:ingredients)).to eq(recipe.recipe_ingredients.includes(:ingredient))
        expect(assigns(:steps)).to eq(recipe.recipe_steps.ordered)
        expect(assigns(:ratings)).to eq(recipe.recipe_ratings.recent.includes(:user))
      end
    end

    context 'when recipe does not exist' do
      it 'redirects to index with error' do
        get :show, params: { id: 'nonexistent' }
        expect(response).to redirect_to(recipes_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #new' do
    context 'when authenticated' do
      before { sign_in user }

      it 'builds a new recipe' do
        get :new
        expect(response).to have_http_status(:ok)
        expect(assigns(:recipe)).to be_a_new(Recipe)
        expect(assigns(:recipe).user).to eq(user)
      end

      it 'builds associated recipe steps' do
        get :new
        expect(assigns(:recipe).recipe_steps.size).to eq(3) # Default steps
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user owns the recipe' do
      before { sign_in user }

      it 'allows editing' do
        get :edit, params: { id: recipe.id }
        expect(response).to have_http_status(:ok)
        expect(assigns(:recipe)).to eq(recipe)
      end
    end

    context 'when user does not own the recipe' do
      before { sign_in other_user }

      it 'redirects with authorization error' do
        get :edit, params: { id: recipe.id }
        expect(response).to redirect_to(recipe_path(recipe))
        expect(flash[:alert]).to match(/not authorized/i)
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        get :edit, params: { id: recipe.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        title: 'Test Recipe',
        description: 'A test recipe',
        prep_time: 15,
        cook_time: 30,
        servings: 4,
        difficulty_level: 'easy'
      }
    end

    let(:invalid_attributes) do
      {
        title: '',
        description: 'A test recipe'
      }
    end

    context 'when authenticated' do
      before { sign_in user }

      context 'with valid parameters' do
        it 'creates a new recipe' do
          expect {
            post :create, params: { recipe: valid_attributes }
          }.to change(Recipe, :count).by(1)
        end

        it 'assigns recipe to current user' do
          post :create, params: { recipe: valid_attributes }
          expect(assigns(:recipe).user).to eq(user)
        end

        it 'redirects to the recipe' do
          post :create, params: { recipe: valid_attributes }
          expect(response).to redirect_to(recipe_path(assigns(:recipe)))
          expect(flash[:notice]).to match(/successfully created/i)
        end

        context 'with Turbo request' do
          it 'responds with turbo stream' do
            request.headers['Accept'] = 'text/vnd.turbo-stream.html'
            post :create, params: { recipe: valid_attributes }
            expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          end
        end
      end

      context 'with invalid parameters' do
        it 'does not create a recipe' do
          expect {
            post :create, params: { recipe: invalid_attributes }
          }.not_to change(Recipe, :count)
        end

        it 'renders new template with errors' do
          post :create, params: { recipe: invalid_attributes }
          expect(response).to render_template(:new)
          expect(assigns(:recipe).errors).to be_present
        end

        context 'with Turbo request' do
          it 'responds with turbo stream containing errors' do
            request.headers['Accept'] = 'text/vnd.turbo-stream.html'
            post :create, params: { recipe: invalid_attributes }
            expect(response.media_type).to eq('text/vnd.turbo-stream.html')
          end
        end
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        post :create, params: { recipe: valid_attributes }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) do
      {
        title: 'Updated Recipe',
        description: 'Updated description'
      }
    end

    context 'when user owns the recipe' do
      before { sign_in user }

      context 'with valid parameters' do
        it 'updates the recipe' do
          patch :update, params: { id: recipe.id, recipe: new_attributes }
          recipe.reload
          expect(recipe.title).to eq('Updated Recipe')
          expect(recipe.description).to eq('Updated description')
        end

        it 'redirects to the recipe' do
          patch :update, params: { id: recipe.id, recipe: new_attributes }
          expect(response).to redirect_to(recipe_path(recipe))
          expect(flash[:notice]).to match(/successfully updated/i)
        end
      end

      context 'with invalid parameters' do
        it 'renders edit template with errors' do
          patch :update, params: { id: recipe.id, recipe: { title: '' } }
          expect(response).to render_template(:edit)
          expect(assigns(:recipe).errors).to be_present
        end
      end
    end

    context 'when user does not own the recipe' do
      before { sign_in other_user }

      it 'redirects with authorization error' do
        patch :update, params: { id: recipe.id, recipe: new_attributes }
        expect(response).to redirect_to(recipe_path(recipe))
        expect(flash[:alert]).to match(/not authorized/i)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:recipe_to_delete) { create(:recipe, user: user) }

    context 'when user owns the recipe' do
      before { sign_in user }

      it 'destroys the recipe' do
        expect {
          delete :destroy, params: { id: recipe_to_delete.id }
        }.to change(Recipe, :count).by(-1)
      end

      it 'redirects to recipes index' do
        delete :destroy, params: { id: recipe_to_delete.id }
        expect(response).to redirect_to(recipes_path)
        expect(flash[:notice]).to match(/successfully deleted/i)
      end

      context 'with Turbo request' do
        it 'responds with turbo stream' do
          request.headers['Accept'] = 'text/vnd.turbo-stream.html'
          delete :destroy, params: { id: recipe_to_delete.id }
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end
    end

    context 'when user does not own the recipe' do
      before { sign_in other_user }

      it 'does not destroy the recipe' do
        expect {
          delete :destroy, params: { id: recipe_to_delete.id }
        }.not_to change(Recipe, :count)
      end

      it 'redirects with authorization error' do
        delete :destroy, params: { id: recipe_to_delete.id }
        expect(response).to redirect_to(recipe_path(recipe_to_delete))
        expect(flash[:alert]).to match(/not authorized/i)
      end
    end
  end

  describe 'POST #favorite' do
    context 'when authenticated' do
      before { sign_in user }

      context 'when recipe is not favorited' do
        it 'creates a favorite' do
          expect {
            post :favorite, params: { id: recipe.id }
          }.to change(user.favorite_recipes, :count).by(1)
        end

        it 'responds with success turbo stream' do
          request.headers['Accept'] = 'text/vnd.turbo-stream.html'
          post :favorite, params: { id: recipe.id }
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end

      context 'when recipe is already favorited' do
        before { create(:favorite_recipe, user: user, recipe: recipe) }

        it 'removes the favorite' do
          expect {
            post :favorite, params: { id: recipe.id }
          }.to change(user.favorite_recipes, :count).by(-1)
        end
      end
    end

    context 'when not authenticated' do
      it 'redirects to sign in' do
        post :favorite, params: { id: recipe.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'private methods' do
    let(:controller_instance) { described_class.new }

    describe '#recipe_params' do
      let(:params) do
        ActionController::Parameters.new({
          recipe: {
            title: 'Test Recipe',
            description: 'Test description',
            prep_time: 15,
            cook_time: 30,
            servings: 4,
            difficulty_level: 'easy',
            image: fixture_file_upload('recipe_image.jpg', 'image/jpeg'),
            recipe_steps_attributes: {
              '0' => { instruction: 'Step 1', step_number: 1 },
              '1' => { instruction: 'Step 2', step_number: 2 }
            }
          }
        })
      end

      before do
        controller_instance.params = params
      end

      it 'permits the correct attributes' do
        allowed_params = controller_instance.send(:recipe_params)
        expect(allowed_params).to be_permitted
        expect(allowed_params[:title]).to eq('Test Recipe')
        expect(allowed_params[:recipe_steps_attributes]).to be_present
      end
    end
  end
end
