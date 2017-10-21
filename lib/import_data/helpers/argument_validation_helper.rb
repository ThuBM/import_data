module ImportData
  module ArgumentValidationHelper
    def class_name_valid? class_name
      if class_name.blank?
        puts "class_name is required!"
        return false
      end

      model = Kernel.const_get(class_name) rescue nil

      if model.nil?
        puts "#{class_name} is not existed."
        return false
      end

      unless model.new.is_a?(ActiveRecord::Base)
        puts "#{class_name} is not an ActiveRecord::Base."
        return false
      end

      true
    end

    def async_tool_valid? async_tool
      return true if async_tool.nil? || [:worker, :active_job].include?(async_tool)

      puts "#{async_tool} must be worker or active_job."
    end

    def boolean_valid? attr_name, attr_value
      return true if [nil, "true", "false"].include? attr_value
      puts "#{attr_name} must be true or false."
    end

    def number_valid? attr_name, attr_value
      return true if attr_value.nil? || attr_value.to_i.to_s == attr_value

      puts "#{attr_name} must be a number."
    end
  end
end
