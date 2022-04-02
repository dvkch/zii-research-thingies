# frozen_string_literal: true

ActiveAdmin.register_page 'Twitter Keywords' do
  menu parent: 'twitter', priority: 4, label: proc { I18n.t('admin.pages.twitter_keywords') }

  content do
    h2 I18n.t('admin.labels.stats')

    # Filters
    show_filters([:twitter_search, :limit, :min_character_count, :from, :to])

    # Results
    para do
      span do
        'Most common words are: '
      end
      scope = (selected_twitter_search&.twitter_tweets || TwitterTweet)
      scope = scope.where('date >= ?', selected_from) if selected_from.present?
      scope = scope.where('date <= ?', selected_to) if selected_to.present?
      words = scope.common_words(min_word_length: selected_min_character_count, limit: selected_limit).map(&:first)
      ul class: 'word_tags' do
        words.each do |w|
          li do
            w
          end
        end
      end
    end
  end
end
