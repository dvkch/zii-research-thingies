# frozen_string_literal: true

module ActiveAdminFixResourcesPaths
  extend ActiveSupport::Concern

  # we need at least one method or the module won't exist in rails eyes
  def are_path_fixed
    true
  end

  included do
    # In Admin::Users#show we had an issue causing id_column for resource.artists and resource.playlists to
    # fail because resource_path would return /admin/users/:playlist_id instead of /admin/playlists/:playlist_id
    # for instance. The problem also manifests itself when using `actions`. Curiously this is not an issue in
    # Admin::Albums#show or any other admin controllers. Just Users. And disabling Devise didn't change a thing.
    # This fix is inspired from `auto_link` and https://github.com/activeadmin/activeadmin/issues/279#issuecomment-37366570
    # It works even if its pretty damn weird

    def resource_path(*given_args)
      resource = given_args.first
      config = active_admin_namespace.resource_for(resource.class)
      return unless config

      url_for config.route_instance_path resource, url_options
    end

    def edit_resource_path(*given_args)
      resource = given_args.first
      config = active_admin_namespace.resource_for(resource.class)
      return unless config

      url_for config.route_edit_instance_path resource, url_options
    end
  end
end
