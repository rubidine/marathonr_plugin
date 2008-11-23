module RecurringWorker
  def self.included kls
    kls.send :alias_method_chain, :perform, :recurring_worker
  end

  def perform_with_recurring_worker data
    begin
      perform_without_recurring_worker(data)
    rescue Exception => ex
      @request.complete = true
      @request.success = false
      @request.error = true
      @request.status_message = "Exception: #{ex.message}"
      if $DEBUG
        puts "----- EXCEPTION DURING PROCESSING"
        puts ex.message
        puts ex.backtrace.join("\n")
      end
    ensure
      reschedule
      @request.save
    end
  end

  def reschedule
    kls = @request.class
    kls.create! :worker_name => @request.worker_name,
                :job_key => @request.job_key,
                :data => @request.data
  end
end
