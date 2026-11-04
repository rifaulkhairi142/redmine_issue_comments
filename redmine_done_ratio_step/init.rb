Redmine::Plugin.register :redmine_done_ratio_step do
  name 'Redmine Done Ratio Step'
  author 'Rifa Ulkhairi'
  description 'Replaces the % Done dropdown with a slider / number input using a configurable step'
  version '1.0.0'
  requires_redmine version_or_higher: '6.0.0'

  settings default: { 'step' => '5', 'mode' => 'slider' },
           partial: 'settings/done_ratio_step_settings'
end

# lib/ is autoloaded by Zeitwerk in Redmine 6; referencing the constant loads it.
RedmineDoneRatioStep::Hooks
