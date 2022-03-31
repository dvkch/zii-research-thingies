module ActiveAdmin
  module Views
    class IndexAsTableWithHeader < IndexAsTable
      def build(page_presenter, collection)
        table_options = {
          id: "index_table_#{active_admin_config.resource_name.plural}",
          sortable: true,
          class: "index_table index",
          i18n: active_admin_config.resource_class,
          paginator: page_presenter[:paginator] != false,
          row_class: page_presenter[:row_class]
        }

        if page_presenter.block
          instance_exec(self, :header, &page_presenter.block)
        end

        unless collection.empty?
          table_for collection, table_options do |t|
            if page_presenter.block
              instance_exec(t, :table, &page_presenter.block)
            else
              instance_exec(t, &default_table)
            end
          end
        end
      end

      def attributes_table(*args, &block)
        opts = args.extract_options!
        table_title = if opts.has_key?(:title)
                        render_or_call_method_or_proc_on(resource, opts[:title])
                      else
                        ActiveAdmin::Localizers.resource(active_admin_config).t(:details)
                      end
        panel(table_title) do
          attributes_table_for resource, *args, &block
        end
      end
    end
  end
end
