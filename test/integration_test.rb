require 'test_helper'

Sidekiq::Testing.disable!

class IntegrationTest < SidekiqIchniteTestCase
  class MyWorker
    include Sidekiq::Worker

    def perform(var)
      if var == 'fail'
        raise ArgumentError, 'oh no'
      else
        Ichnite.log('job_run', var: var)
      end
    end
  end

  def test_client_log
    MyWorker.perform_async('some data')

    assert_equal 1, ichnite_events.size
    enqueue = ichnite_events.first
    job_id = enqueue.last.delete(:job_id)
    assert_equal(["job_enqueue", { queue: 'default', job_class: 'IntegrationTest::MyWorker', args: ['some data']}], enqueue)
    assert_match(/[a-f0-9]+/, job_id)
  end

  def test_server_log_success
    stub_current_time 1477465809.473578 do
      worker = MyWorker.new
      Sidekiq::Ichnite::ServerMiddleware.new.call(worker, SIDEKIQ_WORKER_MSG, 'default')  do
        worker.perform('some data')
      end

      assert_ichnite_events(
        ['job_run', { job_id: '0b59872d5a115e833b4232d6', job_class: 'SampleWorker', var: 'some data' }],
        ['job_stop', { job_id: '0b59872d5a115e833b4232d6', job_class: 'SampleWorker', queue: 'default', queued_for: 7, duration: 0 }])
    end
  end

  def test_server_log_error
    worker = MyWorker.new
    begin
      stub_current_time 1477465807.473578 do
        Sidekiq::Ichnite::ServerMiddleware.new.call(worker, SIDEKIQ_WORKER_MSG, 'default')  do
          worker.perform('fail')
        end
      end
    rescue ArgumentError
    end

    assert_ichnite_events(
      ['job_error', { job_id: '0b59872d5a115e833b4232d6', job_class: 'SampleWorker', queue: 'default', at: :error, queued_for: 5, duration: 0, error: "ArgumentError", message: '"oh no"'}])
  end
end
