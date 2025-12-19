# ZappyNotes ⚡📝

A modern, lightning-fast note-taking application built with Rails 8. ZappyNotes provides a clean, intuitive interface for organizing your thoughts with Markdown support, auto-save, and tiered subscription plans.

![ZappyNotes Logo](app/assets/images/zappynoteslogo.png)

## ✨ Features

### Core Functionality
- **WYSIWYG Markdown Editor** - Write with Toast UI Editor featuring real-time formatting
- **Auto-Save** - Notes save automatically on blur and every 60 seconds
- **Image Upload** - Paste or upload images directly into your notes
- **Notebook Organization** - Color-coded notebooks (6 colors) for easy visual organization
- **Responsive Design** - Works seamlessly on desktop and mobile devices

### User Management
- **Secure Authentication** - Built with Rails 8 authentication
- **User Profiles** - Customize your account with first and last name
- **Account Settings** - Manage your profile and subscription in one place

### Subscription Tiers
- **Free Plan** - 3 notebooks, 10 notes per notebook, 100MB storage
- **Plus Plan** ($1.99/mo) - 10 notebooks, 30 notes per notebook, 500MB storage
- **Pro Plan** ($4.99/mo) - Unlimited notebooks, notes, and storage

### Admin Features
- **Motor Admin Panel** - Full database management interface
- **Admin Users** - Unlimited resources for administrators
- **Usage Tracking** - Monitor storage and resource usage

## 🛠️ Tech Stack

- **Framework:** Ruby on Rails 8.1.1
- **Ruby Version:** 3.3.8
- **Database:** PostgreSQL 18
- **CSS:** Tailwind CSS v4
- **JavaScript:** Importmap with Stimulus
- **Rich Text Editor:** Toast UI Editor
- **UI Components:** Flowbite
- **Payment Processing:** Stripe
- **Markdown Rendering:** Kramdown (GitHub Flavored Markdown)
- **Monitoring:** AppSignal (APM & Error Tracking)
- **Admin Dashboard:** Motor Admin

## 📋 Prerequisites

- Ruby 3.3.8
- Rails 8.1.1
- PostgreSQL 18
- Node.js (for JavaScript dependencies)
- Stripe account (for subscription features)

## 🚀 Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/zappynotes.git
cd zappynotes
```

### 2. Install dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies (if needed)
# Rails 8 uses importmap, so no npm install required
```

### 3. Set up environment variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Update `.env` with your configuration:

```env
# Database
DATABASE_URL=postgresql://localhost/zappynotes_development

# Stripe Keys (get from https://dashboard.stripe.com/apikeys)
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Stripe Price IDs (create products in Stripe Dashboard)
STRIPE_PLUS_PRICE_ID=price_your_plus_price_id
STRIPE_PRO_PRICE_ID=price_your_pro_price_id

# AppSignal (Optional - for monitoring)
APPSIGNAL_PUSH_API_KEY=your_appsignal_key
```

### 4. Set up the database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Create an admin user
rails console
> user = User.create!(email_address: "admin@example.com", password: "password123", password_confirmation: "password123", admin: true)
> exit
```

### 5. Start the development server

Open two terminal windows:

**Terminal 1 - Rails Server:**
```bash
rails server
```

**Terminal 2 - Tailwind CSS Watcher:**
```bash
rails tailwindcss:watch
```

Visit [http://localhost:3000](http://localhost:3000)

## ⚙️ Configuration

### Stripe Setup

1. Create a Stripe account at [stripe.com](https://stripe.com)
2. Get your API keys from the [Stripe Dashboard](https://dashboard.stripe.com/apikeys)
3. Create two products in Stripe:
   - **Plus Plan**: $1.99/month recurring
   - **Pro Plan**: $4.99/month recurring
4. Copy the Price IDs to your `.env` file
5. Set up webhook endpoint at `/webhooks/stripe` in Stripe Dashboard

### Admin Access

To give a user admin privileges:

```bash
rails console
> user = User.find_by(email_address: "user@example.com")
> user.update(admin: true)
> exit
```

Access the admin panel at: [http://localhost:3000/motor_admin](http://localhost:3000/motor_admin)

## 📱 Usage

### Creating Your First Note

1. **Sign Up** - Create a free account
2. **Default Notebooks** - You'll start with "My Notebook" and "Getting Started"
3. **Create a Note** - Click "+ Create Note" under any notebook
4. **Start Writing** - Use the WYSIWYG editor with Markdown support
5. **Auto-Save** - Your notes save automatically

### Keyboard Shortcuts (in editor)

- `Ctrl/Cmd + B` - Bold
- `Ctrl/Cmd + I` - Italic
- `Ctrl/Cmd + K` - Insert link
- `Ctrl/Cmd + Shift + C` - Code block

### Managing Notebooks

- **Create** - Click "+ Create Notebook" (respects plan limits)
- **Rename** - Click ellipsis (⋮) next to notebook → Rename
- **Change Color** - Click ellipsis → Change Color (6 colors available)
- **Delete** - Click ellipsis → Delete (deletes all notes in notebook)

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 📦 Deployment

### Heroku Deployment

```bash
# Install Heroku CLI and login
heroku login

# Create Heroku app
heroku create your-app-name

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set STRIPE_PUBLISHABLE_KEY=pk_live_xxx
heroku config:set STRIPE_SECRET_KEY=sk_live_xxx
heroku config:set STRIPE_WEBHOOK_SECRET=whsec_xxx
heroku config:set STRIPE_PLUS_PRICE_ID=price_xxx
heroku config:set STRIPE_PRO_PRICE_ID=price_xxx

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Create admin user
heroku run rails console
> User.create!(email_address: "admin@yourdomain.com", password: "secure_password", admin: true)
```

### Railway / Render Deployment

See [deployment guide](docs/deployment.md) for detailed instructions.

## 🗂️ Project Structure

```
zappynotes/
├── app/
│   ├── assets/
│   │   ├── images/          # Logo and static images
│   │   └── tailwind/        # Tailwind CSS configuration
│   ├── controllers/         # Application controllers
│   ├── models/             # ActiveRecord models
│   ├── views/              # ERB templates
│   └── javascript/         # Stimulus controllers
├── config/
│   ├── initializers/       # Rails initializers
│   ├── routes.rb          # Application routes
│   └── appsignal.rb       # APM configuration
├── db/
│   ├── migrate/           # Database migrations
│   └── schema.rb          # Current database schema
├── spec/                  # RSpec tests
└── docs/                  # Project documentation
```

## 🤝 Contributing

This is a private project, but contributions from team members are welcome!

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

### Coding Standards

- Follow Ruby Style Guide
- Write tests for new features
- Update documentation as needed
- Use conventional commits

## 📄 License

This project is proprietary and confidential.

## 🙏 Acknowledgments

- Built with [Ruby on Rails](https://rubyonrails.org/)
- UI Components from [Flowbite](https://flowbite.com/)
- Editor powered by [Toast UI Editor](https://ui.toast.com/tui-editor)
- Monitoring by [AppSignal](https://appsignal.com/)
- Payments by [Stripe](https://stripe.com/)

## 📧 Support

For questions or support, contact: your-email@example.com

---

Made with ⚡ and ❤️