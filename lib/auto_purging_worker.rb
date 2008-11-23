module AutoPurgingWorker
  def self.included kls
    kls.send :alias_method_chain, :perform, :auto_purging
  end

  def perform_with_auto_purging data
    begin
      perform_without_auto_purging(data)
    ensure
      @request.destroy
    end
  end

end
