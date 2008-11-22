##
#
# BackgroundWorker does a bit of automatic work for rendering templates
# from within a MarathonR process.
#
# class MyWorker < BackgroundWorker
#   def perform data
#     tell_begin_work steps=20
#     20.times do |i|
#       tell_step i
#     end
#
#     tell_begin_rendering steps=5
#     5.times do |i|
#       tell_step i
#     end
#
#     tell_complete
#   end
# end
#
class BackgroundWorker

  include ApplicationHelper

  def initialize request, config={}
    @request = request
    @config = config
    @request.status_message = 'Initializing...'
    @request.save

    # perform is defined by the subclass
    perform @request.data
  end

  def tell_begin_work max_steps
    @request.status_message = ''
    @request.current_stage_name = 'Collecting Data'
    @request.current_stage_number = 1
    @request.max_stage_number = 2
    @request.current_stage_max_step = max_steps
    @request.save
  end

  def tell_begin_rendering max_steps
    @request.current_stage_name = 'Preparing Output'
    @request.current_stage_number = 2
    @request.current_stage_max_step = max_steps
    @request.save
  end

  def tell_step num
    @request.current_stage_step = num
    @request.save
  end

  def tell_complete success=true, filetype=nil, filename=nil
    @request.complete = true
    @request.success = success
    @request.error = !success
    @request.filetype = filetype
    @request.filename = filename
    @request.save
  end

  ##
  #
  # Store the template so the front-end can get at it.
  # dir, filename = controller, action in most cases
  #
  def template_output dir, filename
    
    tfile = File.join(RAILS_ROOT, 'app', 'views', dir, filename)
    if !File.file?(tfile)
      body = "Unable to open #{tfile} to prepare output"
    else
      template = ERB.new(File.read(tfile), nil, '-')
      body = template.result(binding)
    end
    
    body
  end
end
