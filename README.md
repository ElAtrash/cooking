# $APP_NAME

A Ruby on Rails 8 application with the complete starter pack.

## Tech Stack

- **Ruby on Rails 8** - Web framework with built-in authentication
- **PostgreSQL** - Database
- **Turbo & Stimulus** - JavaScript framework (Rails 8 default)
- **Tailwind CSS** - Styling framework
- **RSpec** - Testing framework with request tests
- **FactoryBot** - Test data generation
- **Faker** - Fake data generation
- **Pagy** - Pagination (configured, ready to use)
- **Capybara** - System testing

## Getting Started

The application is ready to go with a clean slate! Here's what's configured:

### Database
- PostgreSQL database created and migrated
- Two test users: admin and regular user

### Authentication
- Rails 8 built-in authentication system
- User model with email/password authentication
- Login/logout functionality
- Comprehensive authentication tests

### Testing
- RSpec configured with FactoryBot
- User factory with admin and regular user traits
- Authentication test suite (unit and request tests)
- Ready to run: `rspec`

### Frontend
- Tailwind CSS for styling
- Turbo and Stimulus for JavaScript
- Clean, responsive landing page
- Authentication UI included

## Available Commands

\`\`\`bash
# Run the server
rails server

# Run tests
rspec

# Run tests with coverage
rspec --format documentation

# Access Rails console
rails console

# Generate new components
rails generate controller ControllerName
rails generate model ModelName

# Database operations
rails db:migrate
rails db:seed
rails db:reset
\`\`\`

## Default Test Accounts

- **Admin:** `admin@example.com` / `password123`
- **User:** `user@example.com` / `password123`

## Testing

Run the complete test suite:
```bash
# Run all tests
rspec

# Run specific test types
rspec spec/models/          # Model tests
rspec spec/requests/        # Request tests

# Run with documentation format
rspec --format documentation
```

## Project Structure

- **Models**: \`app/models/\` (User model with authentication)
- **Controllers**: \`app/controllers/\` (Home, Sessions, Passwords)
- **Views**: \`app/views/\` (Landing page, authentication forms)
- **Tests**: \`spec/\` (Complete test suite)
- **Factories**: \`spec/factories/\` (User factory with traits)
- **Styling**: Tailwind CSS classes in views

## What's Included

✅ **Clean Starting Point**: No sample logic to remove
✅ **Authentication**: Complete Rails 8 auth system with tests
✅ **Responsive UI**: Tailwind-styled landing page
✅ **Test Coverage**: User model and request tests
✅ **Ready for Development**: All tools configured, just start building

## Next Steps

1. Start building your application features
2. Add your models, controllers, and views
3. Use the User factory and authentication tests as examples
4. Configure production environment variables
5. Set up deployment

The app is intentionally minimal - a clean foundation for you to build upon! 🚀
