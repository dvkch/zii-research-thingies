module ActiveAdmin
  module Views
    module Pages
      class Index < Base
        def build_collection
          if items_in_collection? || config.options[:as] == ActiveAdmin::Views::IndexAsTableWithHeader
            render_index
          else
            if params[:q] || params[:scope]
              render_empty_results
            else
              render_blank_slate
            end
          end
        end
      end
    end
  end
end
