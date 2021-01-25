module LocaleFloatFormat
  module ApplicationHelperPatch
    def self.included(base)
      def format_object_with_locale_decimal_separator(object, html=true, &block)
        case object.class.name
        when 'Float'
          number_with_delimiter(sprintf('%.2f', object))
        else
          format_object_without_locale_decimal_separator(object, html, &block)
        end
      end

      base.class_eval do
        alias_method :format_object_without_locale_decimal_separator, :format_object
        alias_method :format_object, :format_object_with_locale_decimal_separator
      end
    end
  end

  module FloatFormatPatch
    def self.included(base)
      base.class_eval do
        def set_custom_field_value(custom_field, custom_field_value, value)
          delimiter = I18n.t('number.format.delimiter', default: ',')
          separator = I18n.t('number.format.separator', default: '.')
          value&.tr(delimiter, '')&.tr(separator, '.')
        end

        def edit_tag(view, tag_id, tag_name, custom_value, options={})
          view.text_field_tag(tag_name, ApplicationController.helpers.number_with_delimiter(custom_value.value), options.merge(:id => tag_id))
        end
      end
    end
  end

  module IssuePatch
    def self.included(base)
      base.class_eval do
        def copy_from(arg, options={})
          issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)
          self.attributes = issue.attributes.dup.except("id", "root_id", "parent_id", "lft", "rgt", "created_on", "updated_on", "status_id", "closed_on")
          self.custom_field_values = issue.custom_field_values.inject({}) { |h,v|
            h[v.custom_field_id] = v.custom_field.field_format == 'float' ?
              ApplicationController.helpers.number_with_delimiter(v.value) : v.value; h
          }
          if options[:keep_status]
            self.status = issue.status
          end
          self.author = User.current
          unless options[:attachments] == false
            self.attachments = issue.attachments.map do |attachement|
              attachement.copy(:container => self)
            end
          end
          unless options[:watchers] == false
            self.watcher_user_ids =
              issue.watcher_users.select{|u| u.status == User::STATUS_ACTIVE}.map(&:id)
          end
          @copied_from = issue
          @copy_options = options
          self
        end
      end
    end
  end
end
