$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidekiq'
require 'ichnite'
require 'ichnite/testing'
require 'sidekiq-ichnite'
require 'sidekiq/testing'

require 'minitest/autorun'

class SidekiqIchniteTestCase < Minitest::Test
  include Ichnite::TestHelper

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
end
