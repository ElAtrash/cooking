# Create admin and regular user accounts
puts "Creating sample users..."

# Create admin user
admin = User.create!(
  email_address: "admin@example.com",
  password: "password123",
  password_confirmation: "password123"
)

# Create regular user
user = User.create!(
  email_address: "user@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created admin user: #{admin.email_address}"
puts "Created regular user: #{user.email_address}"
puts "Default password for both: password123"
