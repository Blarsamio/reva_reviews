# Reva Reviews Dashboard

A Rails application for managing and analyzing customer reviews with Net Promoter Score (NPS) tracking. Built with Rails 7.1, PostgreSQL, Turbo, and Tailwind CSS.

## Features

- **NPS Dashboard** - Real-time Net Promoter Score calculation and visualization
- **Advanced Filtering** - Filter reviews by rating, channel, company, date range, and text search
- **Responsive Design** - Mobile-first design with optimized layouts for all screen sizes
- **Turbo Frames** - Fast, partial page updates without full page reloads
- **CSV Import** - Idempotent review imports with fingerprint-based deduplication
- **Modern UI** - Clean interface built with Tailwind CSS
- **Background Jobs** - Automated NPS calculation using Sidekiq

## Tech Stack

- **Ruby** 3.3.5
- **Rails** 7.1.6
- **PostgreSQL** with pg_trgm extension for full-text search
- **Turbo** for reactive updates
- **Tailwind CSS** for styling
- **Pagy** for pagination
- **Sidekiq** for background jobs
- **pg_search** for PostgreSQL full-text search

## Prerequisites

- Ruby 3.3.5
- PostgreSQL 12+
- Redis (for Sidekiq background jobs)
- Node.js (for asset compilation)

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd reva_reviews_app
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Database setup

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate
```

The migrations will automatically:
- Enable the `pg_trgm` PostgreSQL extension
- Create the `reviews` table with fingerprint indexing
- Create the `nps_scores` table for materialized NPS data
- Add trigram indexes for fast text search

### 4. Import review data

Import reviews from a CSV file using the custom rake task:

```bash
rake reviews:import[path/to/reviews.csv]
```

**What the task does:**
- Validates the file exists before attempting import
- Displays progress information (duration, counts)
- Shows detailed statistics:
  - Number of reviews processed
  - Number of new reviews created
  - Total reviews in database
- Handles errors gracefully with informative messages
- Confirms idempotency when no new records are added

**Example output:**
```
Starting import from: /path/to/reviews.csv
============================================================
============================================================
Import completed successfully!
Duration: 2.45 seconds
Reviews processed: 1000
New reviews created: 1000
Total reviews in database: 1000
============================================================
```

**Running the same import again:**
```
============================================================
Import completed successfully!
Duration: 2.12 seconds
Reviews processed: 1000
New reviews created: 0
Total reviews in database: 1000
============================================================
Note: No new reviews were added (all reviews already exist)
This is expected behavior due to fingerprint-based idempotency
```

**CSV Format:**
The CSV file should have the following columns:
```
company_name,channel,rating,date,title,description
```

**Example CSV line:**
```
"Acme Corp",iOS App,5,2024-01-15,"Great Service","Excellent experience with the app"
```

**Field mapping:**
- `company_name` → Company name (string)
- `channel` → Review channel (e.g., "iOS App", "Website", "Google")
- `rating` → Star rating (1-5)
- `date` → Review date (will be stored as `review_date`)
- `title` → Review title (optional)
- `description` → Review text content

The import is **idempotent** - running it multiple times with the same data will not create duplicates thanks to SHA256 fingerprinting based on company_name, review_date, rating, channel, and description.

### 5. Calculate NPS scores

Generate NPS scores for a specific date:

```bash
# Calculate for yesterday
rails runner "Nps::DailyCalculationJob.perform_now(Date.yesterday)"

# Or for a specific date
rails runner "Nps::DailyCalculationJob.perform_now(Date.new(2024, 1, 15))"
```

### 6. Start the application

Using Foreman (recommended for development):

```bash
bin/dev
```

This starts both the Rails server and Tailwind CSS watcher.

Or manually:

```bash
# Terminal 1: Rails server
rails server

# Terminal 2: Tailwind watcher
rails tailwindcss:watch

# Terminal 3: Sidekiq (for background jobs)
bundle exec sidekiq
```

Visit http://localhost:3000

## Application Structure

### Models

#### Review
The core model representing customer reviews.

**Concerns:**
- `Review::Searchable` - PostgreSQL full-text search with pg_trgm
- `Review::Filterable` - Scopes for filtering by rating, channel, company, date range
- `Review::Importable` - CSV import functionality

**Key Features:**
- Automatic fingerprint generation for idempotent imports
- NPS categorization (promoter, passive, detractor)
- Full-text search on description field

#### NpsScore
Materialized NPS scores for specific dates and companies.

**Concerns:**
- `NpsScore::Calculatable` - NPS calculation logic

**Key Features:**
- Cache-with-fallback pattern via `Nps::ScoreLoader`
- Stores both global and per-company scores
- Automatic score calculation on save

### Services

#### Review::CsvImporter
Handles CSV file imports with fingerprint-based deduplication.

```ruby
Review::CsvImporter.new('path/to/file.csv').import
```

#### Nps::Calculator
Calculates and stores NPS scores for a specific date and optional company.

```ruby
calculator = Nps::Calculator.new(Date.today, company_name: "Acme Corp")
nps_score = calculator.calculate_and_store
```

#### Nps::DailyCalculator
Batch calculates NPS scores for all companies on a given date.

```ruby
Nps::DailyCalculator.new(Date.yesterday).calculate
```

#### Nps::ScoreLoader
Implements cache-with-fallback pattern for NPS scores.

```ruby
loader = Nps::ScoreLoader.new(Date.yesterday)
global_nps = loader.global_score
company_scores = loader.company_scores
```

### Background Jobs

#### Nps::DailyCalculationJob
Automatically calculates NPS scores for a given date.

```ruby
Nps::DailyCalculationJob.perform_later(Date.yesterday)
```

### Rake Tasks

#### reviews:import
Custom rake task for importing reviews from CSV files with built-in validation and progress reporting.

**Location:** `lib/tasks/reviews.rake`

**Usage:**
```bash
rake reviews:import[/path/to/reviews.csv]
```

**Features:**
- File existence validation
- Progress tracking with timestamps
- Detailed statistics output
- Error handling with stack traces
- Idempotency confirmation messages
- Exit codes for scripting (0 = success, 1 = failure)

**Implementation:**
- Uses `Review.import_from_csv` (from `Review::Importable` concern)
- Delegates to `Review::CsvImporter` service object
- Tracks initial and final counts
- Calculates import duration
- Provides user-friendly output

### Controllers

#### ReviewsController
Main controller for the reviews dashboard.

**Actions:**
- `index` - Lists reviews with filtering, pagination, and NPS dashboard

**Features:**
- Turbo Frame support for fast partial updates
- Advanced filtering with multiple criteria
- Pagination with Pagy

## Key Features Explained

### Fingerprint-Based Idempotency

Reviews are deduplicated using SHA256 fingerprints generated from:
- Company name
- Review date
- Rating
- Channel
- Description

This ensures that importing the same CSV multiple times won't create duplicate reviews.

### NPS Calculation

Net Promoter Score is calculated using the standard formula:

```
NPS = ((Promoters - Detractors) / Total Reviews) × 100
```

Where:
- **Promoters**: 5-star ratings
- **Passives**: 4-star ratings (not counted in NPS)
- **Detractors**: 1-3 star ratings

### Search Functionality

Full-text search uses PostgreSQL's trigram similarity with the `pg_trgm` extension, enabling:
- Fuzzy matching
- Typo tolerance
- Fast searches even on large datasets

### Responsive Design

The application uses a mobile-first approach:
- **Mobile (< 640px)**: Single column, stacked layout
- **Tablet (640px - 1279px)**: Single column with optimized spacing
- **Desktop (≥ 1280px)**: Two-column layout with sticky sidebar


## Configuration

### Pagy Pagination

Configured in `config/initializers/pagy.rb`:
- 20 items per page
- Overflow handling (shows last page if page number too high)

### Sidekiq

Configured in `config/application.rb`:
- ActiveJob adapter set to Sidekiq
- Requires Redis to be running

## Development

### Running Tests

```bash
rails test
```

### Code Quality

The codebase follows 37signals conventions:
- Service objects for business logic
- Concerns for model organization
- Meaningful commit messages
- Comments explaining "why" not "what"

### Sources
- https://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/

- https://world.hey.com/jorge/code-i-like-iii-good-concerns-5a1b391c

- https://dev.37signals.com/vanilla-rails-is-plenty/

- https://github.com/keithschacht/37signals-rails-code

### Database Console

```bash
rails dbconsole
```

### Rails Console

```bash
rails console
```

Useful console commands:

```ruby
# Check review count
Review.count

# Calculate NPS for yesterday
Nps::DailyCalculator.new(Date.yesterday).calculate

# Search reviews
Review.search_by_description("excellent service")

# Filter reviews
Review.filtered(ratings: ["5"], company_name: "Acme")

```

## Troubleshooting

### PostgreSQL Extension Error

If you get an error about `pg_trgm`:

```sql
-- Connect to your database and run:
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

### Sidekiq Not Running

Make sure Redis is running:

```bash
# On macOS with Homebrew
brew services start redis

# On Linux
sudo systemctl start redis
```

### CSS Not Updating

Rebuild Tailwind CSS:

```bash
rails tailwindcss:build
```
