# app/jobs/veteran_directory_scraping_job.rb
class VeteranDirectoryScrapingJob < ApplicationJob
  queue_as :low_priority
  
  def perform(options = {})
    scraper = VeteranDirectoryScraper.new
    scraper.scrape_veteran_businesses(options)
    
    # Store results in cache for admin dashboard
    Rails.cache.write('last_scraping_results', {
      stats: scraper.stats,
      errors: scraper.errors,
      completed_at: Time.current
    }, expires_in: 7.days)
  end
end
