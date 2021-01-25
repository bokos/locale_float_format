require 'locale_float_format'

Redmine::Plugin.register :locale_float_format do
  name 'Locale Float Format plugin'
  author 'bokos'
  description 'Enables input and display of float custom fields with decimal separator set in locale.'
  version '0.0.1'
  url 'https://github.com/bokos/locale_float_format'
  author_url 'https://github.com/bokos/locale_float_format'

  RedmineApp::Application.config.after_initialize do
    Issue.send(:include, LocaleFloatFormat::IssuePatch)
    ApplicationHelper.send(:include, LocaleFloatFormat::ApplicationHelperPatch)
    Redmine::FieldFormat::FloatFormat.send(:include, LocaleFloatFormat::FloatFormatPatch)
  end
end
