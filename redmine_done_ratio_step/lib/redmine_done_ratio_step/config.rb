module RedmineDoneRatioStep
  module Config
    DEFAULT_STEP = 5
    MODES = %w[slider number].freeze

    def self.settings
      value = Setting.plugin_redmine_done_ratio_step
      value.is_a?(Hash) ? value : {}
    end

    def self.step
      value = settings['step'].to_i
      value.between?(1, 100) ? value : DEFAULT_STEP
    end

    def self.mode
      MODES.include?(settings['mode']) ? settings['mode'] : MODES.first
    end
  end
end
