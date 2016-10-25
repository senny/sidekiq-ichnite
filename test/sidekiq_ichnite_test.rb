require 'test_helper'

class SidekiqIchniteTest < SidekiqIchniteTestCase
  def test_extract_sidekiq_job_id
    assert_equal "0b59872d5a115e833b4232d6", Sidekiq::Ichnite.job_id(SIDEKIQ_WORKER_MSG)
    assert_equal "ab0c6c719c4c8b88788a028c", Sidekiq::Ichnite.job_id(ACTIVE_JOB_MSG)
  end

  def test_extract_sidekiq_worker_class
    assert_equal "SampleWorker", Sidekiq::Ichnite.job_class(SIDEKIQ_WORKER_MSG)
  end

  def test_wrapped_active_job_class
    assert_equal "SampleJob", Sidekiq::Ichnite.job_class(ACTIVE_JOB_MSG)
  end

  def test_extract_sidekiq_worker_args
    assert_equal [1, "string"], Sidekiq::Ichnite.job_args(SIDEKIQ_WORKER_MSG)
  end

  def test_wrapped_active_job_args
    assert_equal ["gid://app/Article/1"], Sidekiq::Ichnite.job_args(ACTIVE_JOB_MSG)
  end
end
