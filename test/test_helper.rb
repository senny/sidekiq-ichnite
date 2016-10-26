$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidekiq'
require 'sidekiq-ichnite'
require 'ichnite/testing'
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
    "created_at" => 1477465802.469281,
    "enqueued_at" => 1477465802.473578
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
    "created_at" => 1477297111.089411,
    "enqueued_at"=>1477465802.473578
  }

  def stub_current_time(epoch)
    real_time_class = Time
    faked_now = Time.at(epoch)
    fake_time = Class.new do
      define_singleton_method :now do
        faked_now
      end
    end
    Object.send(:remove_const, "Time")
    Object.const_set("Time", fake_time)
    yield
  ensure
    Object.send(:remove_const, "Time")
    Object.const_set("Time", real_time_class)
  end
end
