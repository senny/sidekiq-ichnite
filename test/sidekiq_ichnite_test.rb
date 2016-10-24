require 'test_helper'

class SidekiqIchniteTest < Minitest::Test
  SIDEKIQ_WORKER_MSG = {
    "class" => "SampleWorker",
    "args" => [1, "string"],
    "retry" => false,
    "queue" => "aqueue",
    "jid" => "0b59872d5a115e833b4232d6",
    "created_at" => 1477297056.5620632
  }

  ACTIVE_JOB_MSG = {
    "class" => "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper",
    "wrapped" => "SampleJob",
    "queue" => "bqueue",
    "args" => [{
      "job_class" => "SampleJob",
      "job_id" => "206a7e0c-d8a5-4c35-a0a4-7d2c821533aa",
      "queue_name" => "bqueue",
      "arguments" => [{
        "_aj_globalid" => "gid://app/Article/1"
      }],
      "locale" => :en
    }],
    "at" => 1477297112.088673,
    "retry" => true,
    "jid" => "ab0c6c719c4c8b88788a028c",
    "created_at" => 1477297111.089411
  }

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
