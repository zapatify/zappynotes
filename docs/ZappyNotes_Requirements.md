# ZappyNotes - Requirements Document

## Project Overview
ZappyNotes is a web-based note-taking application similar to Evernote, built as a cost-effective alternative. The application will support free and paid tiers with different usage limits.

**Project Name**: ZappyNotes  
**Version**: 1.0  
**Deployment Target**: Heroku

---

## Technical Stack

### Backend
- **Ruby**: 3.3.8
- **Rails**: 8.1.1
- **Database**: PostgreSQL 18

### Frontend
- **CSS Framework**: Tailwind CSS
- **UI Components**: Flowbite (integrated via Importmaps)
- **JavaScript**: Hotwire/Stimulus (Rails default)

### Testing
- **Framework**: RSpec
- **Test Data**: FactoryBot
- **CI/CD**: GitHub Actions with PostgreSQL
- **Scope**: Unit and integration tests only (no system tests in v1)
- **Stripe Testing**: Mock webhooks in tests

### Payment Processing
- **Provider**: Stripe
- **Mode**: Test mode initially
- **Integration**: Stripe Checkout modal for subscriptions

### Markdown Processing
- **Parser**: kramdown gem (or Rails-compatible alternative)
- **Flavor**: GitHub Flavored Markdown (GFM)

---

## Authentication & User Management

### Authentication Method
- Rails built-in authentication (`rails g authentication`)
- Users must authenticate to access the application
- Users can only view their own notebooks and notes

### User Isolation
- Complete data isolation between users
- No shared notebooks or notes in v1

---

## Subscription Plans & Limits

### Plan Tiers

#### Free Plan
- **Cost**: $0/month
- **Notebooks**: 3 maximum
- **Notes per Notebook**: 10 maximum
- **Storage Limit**: 100MB total (sum of all note content in bytes)

#### Plus Plan
- **Cost**: $1.99/month
- **Notebooks**: 10 maximum
- **Notes per Notebook**: 30 maximum
- **Storage Limit**: 500MB total (sum of all note content in bytes)

#### Pro Plan
- **Cost**: $4.99/month
- **Notebooks**: Unlimited
- **Notes per Notebook**: Unlimited
- **Storage Limit**: Unlimited

### Storage Calculation
- Storage is calculated as the byte size of Markdown content
- Limits apply to the **total sum of all notes** across all notebooks
- This aligns with expected Heroku storage costs

### Subscription Management
- Users can subscribe to paid plans via Stripe Checkout modal
- Track subscription status: Free, Plus (active), Pro (active)
- Users can upgrade or downgrade plans
- **Downgrade handling**: Deferred to v2 (will require notebook/note selection)

### Limit Enforcement
- When limits are reached (e.g., Free user tries to create 4th notebook)
- Display prompt asking user to upgrade to a paid plan
- Prevent creation of additional resources until upgrade

---

## Landing Page

### Hero Section
- Marketing text placeholders
- Clear value proposition
- Call-to-action buttons

### Pricing Section
Display three plan cards with:
- Plan name (Free, Plus, Pro)
- Monthly price
- Feature list with limits clearly stated
- Subscribe/Get Started button

### Subscription Flow
- Free plan: Direct signup (no payment)
- Plus/Pro plans: Display Stripe Checkout modal
- After successful payment: Redirect to main application

---

## Main Application UI

### Layout
- **Left Sidebar**: Vertical navigation (notebooks and notes)
- **Right Panel**: Note editor (selected note)
- **Responsive**: Mobile optimization deferred to v2

### Sidebar Structure

```
┌─────────────────────────────────┐
│  [+ Create Notebook]            │
├─────────────────────────────────┤
│  📔 My Notebook            [⋮]  │
│    - First Note            [⋮]  │
│    - Meeting Notes         [⋮]  │
│                                  │
│  📔 Getting Started        [⋮]  │
│    - Welcome Note          [⋮]  │
│                                  │
│  📔 Work Notes             [⋮]  │
│    [+ Create Note]              │
└─────────────────────────────────┘
```

### Create Notebook Button
- Located at the top of sidebar
- Opens modal/form to enter notebook name
- Creates notebook with default color (user-selected or default)

### Create Note Button
- Displayed only when a notebook is selected
- Located at top of the selected notebook's note list
- Opens modal/form to enter note title
- Immediately opens new note in editor after creation

### Notebook Display
- Icon: Standard notebook SVG icon (provided)
- Icon Color: User-selectable (Red, Green, Blue, Yellow, Orange)
- Name: User-defined
- Ellipsis menu (⋮) for actions

### Note Display
- Listed under parent notebook
- Indented for visual hierarchy
- Note title displayed
- Ellipsis menu (⋮) for actions

### Ellipsis Dropdown Menus

#### Notebook Menu
- **Rename**: Opens Flowbite modal for new name
- **Change Color**: Opens color picker (Red, Green, Blue, Yellow, Orange)
- **Delete**: Opens Flowbite confirmation modal, then deletes notebook and all contained notes

#### Note Menu
- **Rename**: Opens Flowbite modal for new name
- **Delete**: Opens Flowbite confirmation modal, then deletes note

### Deletion Confirmation
- Always show Flowbite modal before deleting notebooks or notes
- Clear warning about permanent deletion
- Confirm/Cancel buttons

---

## Note Editor

### Editor Type
- **Style**: Live WYSIWYG editor
- **Format**: Markdown (GitHub Flavored Markdown)
- **Display**: Formatted text as you type (like Notion)

### Auto-Save Behavior
- **On Blur**: Save when user clicks away from editor
- **Periodic**: Auto-save every 1 minute (or standard interval)
- **Visual Feedback**: Indicate save status ("Saving...", "Saved at [time]")

### Note Selection Behavior
- **First Login**: Display last edited note
- **Create New Note**: Immediately open in editor
- **Delete Current Note**: Show empty state (no note selected)

### Implementation
- Server-side rendering (Rails)
- Use Hotwire/Stimulus for interactivity
- kramdown gem for Markdown parsing
- Single view that saves and re-renders server-side

### Content Restrictions
- **Text Only**: No image uploads or attachments in v1
- **Simple Formatting**: Standard Markdown features only

---

## Notebook Management

### Default Notebooks (First-Time Users)

#### 1. My Notebook
- Created automatically on signup
- Contains default note "First Note"
- User can rename both notebook and note

#### 2. Getting Started
- Created automatically on signup
- Contains a "Welcome Note" with onboarding content
- Helps users understand the application
- User can delete or modify

### Notebook Icons
- **SVG Icon** (provided):
```svg
<svg class="w-6 h-6 text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 16 20">
    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 17V2a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H3a2 2 0 0 0-2 2Zm0 0a2 2 0 0 0 2 2h12M5 15V1m8 18v-4"></path>
</svg>
```

- **Color Options**: Red, Green, Blue, Yellow, Orange
- **Default Color**: Blue (or user's first selection)
- All notebooks use same icon shape, only color changes

---

## Data Models

### User
- Email (unique)
- Password (encrypted)
- Subscription tier (free, plus, pro)
- Stripe customer ID
- Last edited note ID (for "last viewed" feature)
- Timestamps

### Notebook
- User ID (foreign key)
- Name
- Color (enum: red, green, blue, yellow, orange)
- Position/Order (for sorting)
- Timestamps

### Note
- Notebook ID (foreign key)
- Title
- Content (text, Markdown)
- Content size (integer, bytes)
- Position/Order (for sorting within notebook)
- Timestamps

### Subscription
- User ID (foreign key)
- Stripe subscription ID
- Plan (enum: free, plus, pro)
- Status (enum: active, canceled, past_due, etc.)
- Current period end
- Timestamps

---

## Stripe Integration

### Setup
- Test mode keys stored in `.env` file
- `.env.example` file with placeholder keys provided

### Stripe Checkout
- Triggered when user selects Plus or Pro plan
- Modal overlay (Stripe hosted checkout)
- Success redirect to main application
- Cancel redirect back to pricing page

### Webhook Events

Handle these Stripe webhook events:

1. **checkout.session.completed**
   - New subscription created
   - Create/update user subscription record
   - Set user's plan tier

2. **customer.subscription.updated**
   - Plan changes (upgrade/downgrade)
   - Update subscription record
   - Update user's plan tier

3. **customer.subscription.deleted**
   - Subscription cancellation
   - Update subscription status
   - Revert user to Free plan

4. **invoice.payment_failed**
   - Failed payment
   - Update subscription status
   - Optionally notify user

### Webhook Security
- Verify webhook signatures using Stripe webhook secret
- Return appropriate HTTP status codes

---

## Testing Requirements

### Test Framework
- **RSpec** with Rails integration
- **FactoryBot** for test data generation
- Mock Stripe webhooks (no live API calls in tests)

### Test Coverage (Version 1 Scope)
- **Unit Tests**: Models, services, helpers
- **Integration Tests**: Controllers, request specs
- **No System Tests**: Deferred to v2

### GitHub Actions CI
- Run tests on push/pull request
- PostgreSQL service container configured
- RSpec test suite execution
- Code coverage reporting (optional)

### Test Philosophy
- Basic coverage for v1
- Focus on critical paths (auth, CRUD, limits)
- Expand comprehensively in v2

---

## Deployment

### Platform
- **Heroku**
- PostgreSQL addon
- Environment variables for Stripe keys

### Configuration
- Production-ready Rails configuration
- Asset compilation (Tailwind CSS)
- Database migrations

### Monitoring
- Heroku logs
- Error tracking (optional: Sentry/Rollbar)

---

## Version 2 Features (Out of Scope for v1)

### Deferred Features
1. **System Tests**: Full browser-based testing with Capybara
2. **Downgrade Flow**: UI for selecting notebooks/notes to keep when downgrading
3. **Mobile Responsiveness**: Optimize for tablets and phones
4. **Image Support**: Upload and embed images in notes
5. **Note Sharing**: Share notes with other users
6. **Export/Import**: Export notes to Markdown files, import from other apps
7. **Search**: Full-text search across all notes
8. **Tags**: Tag-based organization
9. **Keyboard Shortcuts**: Power user features
10. **Dark Mode**: Theme switching

---

## Environment Variables

```env
# .env.example (provided)
DATABASE_URL=postgresql://localhost/zappynotes_development
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
STRIPE_PLUS_PRICE_ID=price_your_plus_price_id_here
STRIPE_PRO_PRICE_ID=price_your_pro_price_id_here
```

---

## Success Criteria

### Version 1 Complete When:
- [ ] User can sign up and authenticate
- [ ] Default notebooks/notes created on signup
- [ ] User can create/rename/delete notebooks and notes
- [ ] Notebook colors are customizable (5 colors)
- [ ] Live Markdown editor works with auto-save
- [ ] Subscription limits enforced (notebooks, notes, storage)
- [ ] Stripe integration functional (test mode)
- [ ] Webhooks handle subscription events
- [ ] Landing page displays pricing tiers
- [ ] RSpec tests pass in GitHub Actions
- [ ] Deployable to Heroku

---

## Open Questions / Decisions Needed

1. **Welcome Note Content**: What should the "Getting Started" welcome note contain?
2. **Error Messages**: Specific wording for limit-reached prompts?
3. **Stripe Price IDs**: Need to create products in Stripe dashboard
4. **Domain Name**: For production deployment
5. **Email Service**: For transactional emails (password resets, receipts)?

---

## Document Version
- **Version**: 1.0
- **Date**: December 5, 2025
- **Status**: Ready for Review
