
class CrawlWorker < SidekiqWorkerBase
  def perform(crawl_job_id)
    crawl_job = CrawlJob.find_by(id: crawl_job_id)
    crawl_job.start_crawl!
  end
end