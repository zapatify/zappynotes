# ZappyNotes ⚡📝

> **Note:** This project is currently on hiatus as I focus on other priorities. This was intended to give me an alternative to Evernote. ZappyNotes serves as an open source learning resource and starting point for note-taking applications.

A modern, self-hosted note-taking application built with Rails 8. ZappyNotes provides a clean, intuitive interface for organizing your thoughts with Markdown support, auto-save, and tiered subscription plans.

[![Ruby](https://img.shields.io/badge/Ruby-3.3.8-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.1-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Features

### Core Functionality
- 🎨 **WYSIWYG Markdown Editor** - Toast UI Editor with real-time formatting
- 💾 **Auto-Save** - Notes save automatically on blur and every 60 seconds
- 🖼️ **Image Upload** - Paste or upload images directly into notes
- 📚 **Notebook Organization** - Color-coded notebooks (6 colors)
- 📱 **Responsive Design** - Works on desktop and mobile
- 🔐 **Email Confirmation** - Verify email addresses to prevent abuse
- 🛡️ **Rate Limiting** - Rack::Attack for DDoS protection

### Subscription Tiers
- **Free Plan** - 3 notebooks, 10 notes per notebook, 100MB storage
- **Plus Plan** ($1.99/mo) - 10 notebooks, 30 notes per notebook, 500MB storage
- **Pro Plan** ($4.99/mo) - Unlimited notebooks, notes, and storage

### Admin Features
- 🎛️ **Motor Admin Panel** - Full database management
- 👤 **Admin Users** - Unlimited resources for administrators
- 📊 **Usage Tracking** - Monitor storage and resource usage

## 🛠️ Tech Stack

- **Framework:** Ruby on Rails 8.1.1
- **Ruby:** 3.3.8
- **Database:** PostgreSQL 18
- **CSS:** Tailwind CSS v4
- **JavaScript:** Importmap, Stimulus, Turbo
- **Editor:** Toast UI Editor
- **UI Components:** Flowbite
- **Payments:** Stripe
- **Email:** ActionMailer with letter_opener (dev)
- **Testing:** RSpec, FactoryBot
- **Monitoring:** AppSignal (optional)
- **Security:** Rack::Attack

## 📋 Prerequisites

- Ruby 3.3.8
- Rails 8.1.1
- PostgreSQL 18
- Node.js (for JavaScript tooling)

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/zappynotes.git
cd zappynotes
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Set Up Environment Variables

Create a `.env` file:
```bash
cp .env.example .env
```

Update `.env` with your configuration:
```env
# Database
DATABASE_URL=postgresql://localhost/zappynotes_development

# Stripe Keys (optional - get from https://dashboard.stripe.com/apikeys)
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret

# Stripe Price IDs (optional - create in Stripe Dashboard)
STRIPE_PLUS_PRICE_ID=price_your_plus_id
STRIPE_PRO_PRICE_ID=price_your_pro_id

# AppSignal (optional - for monitoring)
APPSIGNAL_PUSH_API_KEY=your_key

# IP Blocking (optional)
BLOCKED_IPS=192.168.1.100,10.0.0.50
```

### 4. Set Up Database
```bash
rails db:create
rails db:migrate
```

### 5. Create Admin User (Optional)
```bash
rails console
> User.create!(
    email_address: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    admin: true,
    confirmed_at: Time.current
  )
> exit
```

### 6. Start Development Servers

**Terminal 1 - Rails:**
```bash
rails server
```

**Terminal 2 - Tailwind CSS:**
```bash
rails tailwindcss:watch
```

Visit [http://localhost:3000](http://localhost:3000)

## 🧪 Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

## 📧 Email Configuration

### Development
Uses `letter_opener` gem - emails open in browser automatically.

### Production
Configure ActionMailer with your email service (SendGrid, Mailgun, etc.):
```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  # ... other settings
}
```

## 🚢 Deployment

### Heroku
```bash
# Create app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set STRIPE_PUBLISHABLE_KEY=pk_live_xxx
heroku config:set STRIPE_SECRET_KEY=sk_live_xxx
# ... set other env vars

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Create admin user
heroku run rails console
```

### Other Platforms
See deployment guides for [Railway](https://railway.app/), [Render](https://render.com/), or [Fly.io](https://fly.io/).

## ⚙️ Configuration

### Rate Limiting

Edit `config/initializers/rack_attack.rb`:
```ruby
# Sign-in attempts per IP
throttle('sign-in/ip', limit: 5, period: 20.seconds)

# Sign-up attempts per IP  
throttle('sign-up/ip', limit: 3, period: 1.hour)

# General API requests
throttle('req/ip', limit: 300, period: 5.minutes)
```

### IP Blocking

Add malicious IPs to `.env`:
```env
BLOCKED_IPS=192.168.1.100,10.0.0.50,203.0.113.1
```

### Subscription Plans

Edit plan limits in `app/models/user.rb`:
```ruby
def plan_limits
  case plan
  when :free
    { notebooks: 3, notes_per_notebook: 10, storage_mb: 100 }
  when :plus
    { notebooks: 10, notes_per_notebook: 30, storage_mb: 500 }
  when :pro
    { notebooks: Float::INFINITY, notes_per_notebook: Float::INFINITY, storage_mb: Float::INFINITY }
  end
end
```

## 🤝 Contributing

Contributions are welcome! This project is on hiatus but PRs will be reviewed.

### Getting Started

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Run RuboCop (`bundle exec rubocop -A`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Follow Ruby Style Guide
- Write tests for new features (RSpec)
- Keep test coverage high
- Run RuboCop before committing

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built with [Ruby on Rails](https://rubyonrails.org/)
- UI components from [Flowbite](https://flowbite.com/)
- Editor powered by [Toast UI Editor](https://ui.toast.com/tui-editor)
- Monitoring by [AppSignal](https://appsignal.com/) (optional)
- Payments by [Stripe](https://stripe.com/)

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

## ⚠️ Disclaimer

This is a learning project and personal tool. While functional, it's not actively maintained. Use at your own risk. For a polished, supported note-taking solution, consider [Evernote](https://evernote.com/), [Notion](https://www.notion.so/), or [Obsidian](https://obsidian.md/).

---

**Star ⭐ this repo, and shoot me a ✉️ message  if you find it useful!**