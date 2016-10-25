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

    assert_equal 1, ichnite_log_lines.size
    line = ichnite_log_lines.first
    assert_match(/event=job_enqueue queue=default job_id=[a-f0-9]+ job_class=IntegrationTest::MyWorker args=\["some data"\]/, line)
  end

  def test_server_log_success
    worker = MyWorker.new
    Sidekiq::Ichnite::ServerMiddleware.new.call(worker, SIDEKIQ_WORKER_MSG, 'default')  do
      worker.perform('some data')
    end

    assert_ichnite_logs(
      "event=job_run job_id=0b59872d5a115e833b4232d6 job_class=SampleWorker var=some data",
      "event=job_stop job_id=0b59872d5a115e833b4232d6 job_class=SampleWorker queue=default duration=0")
  end

  def test_server_log_error
    worker = MyWorker.new
    begin
      Sidekiq::Ichnite::ServerMiddleware.new.call(worker, SIDEKIQ_WORKER_MSG, 'default')  do
        worker.perform('fail')
      end
    rescue ArgumentError
    end

    assert_ichnite_logs(
      'event=job_error job_id=0b59872d5a115e833b4232d6 job_class=SampleWorker queue=default at=error duration=0 error=\'ArgumentError\' message="oh no"')
  end
end
