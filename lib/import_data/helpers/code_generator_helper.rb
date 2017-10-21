module ImportData
  module CodeGeneratorHelper
    def generate_model_code model_name, async: true, validation: true
      tabs_str = ""
      base_code = ""
      (model_name.split("::").size + 1).times{tabs_str += "  "}

      # abstract_path = model_name.split("::").map(&:underscore).join("/")
      # file_path = "#{Rails.root}/app/models/#{abstract_path}.rb"

      <<-EOS
#{tabs_str}private
#{generate_validation_code validation: validation, tabs_str: tabs_str}
#{generate_async_code async: async, tabs_str: tabs_str}
      EOS
    end

    def generate_job_code model_name, async_tool: :active_job
      if async_tool == :active_job
        generate_active_job_code model_name
      else
        generate_worker_code model_name
      end
    end

    private
    def generate_active_job_code model_name
      active_job_name = model_name.split("::").last.capitalize

      <<-EOS
class #{active_job_name}Job < ActiveJob::Base
  queue_as :default

  def perform file_path
    #{model_name}.import_data file_path
  end
end
      EOS
    end

    def generate_worker_code model_name
      worker_name = model_name.split("::").last.capitalize

      <<-EOS
class #{worker_name}Worker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform file_path
    #{model_name}.import_data file_path
  end
end
      EOS
    end

    def generate_validation_code validation: true, tabs_str: ""
      return "" if validation

      <<-EOS
#{tabs_str}def validation?
#{tabs_str}  false
#{tabs_str}end
      EOS
    end

    def generate_async_code async: true, tabs_str: ""
      return "" if async

      <<-EOS
#{tabs_str}def async?
#{tabs_str}  false
#{tabs_str}end
      EOS
    end
  end
end
