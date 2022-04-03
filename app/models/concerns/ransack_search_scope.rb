# frozen_string_literal: true

module RansackSearchScope
  as_trait do |scope_name, scope_proc|
    # allows filtering arrays in admin
    # https://stackoverflow.com/a/45728004/1439489
    # for instance: include RansackSearchScope[:parameters_includes, ->(value) { where("array_to_string(parameters,',') ILIKE ?", "%#{value}%") }]

    @cached_ransack_scopes_configs ||= {}
    @cached_ransack_scopes_configs[scope_name] = scope_proc
    all_configs = @cached_ransack_scopes_configs

    define_singleton_method(:ransack_scopes_configs) do
      all_configs # returning @cached_ransack_scopes_configs from here doesn't work
    end

    scope scope_name, scope_proc

    def self.ransackable_scopes(auth_object = nil)
      super + ransack_scopes_configs.keys.map(&:to_sym)
    end
  end
end
