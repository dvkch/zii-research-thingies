RSpec::Matchers.define :prevent_deletion_if_children do |attribute|

  chain :through do |through|
    @through = through
  end

  match do |subject|
    @failed = []
    add_item = lambda do
      if @through
        intermediate = FactoryBot.create(@through.to_s.singularize)
        subject.send(@through) << intermediate
        intermediate.send(attribute) << FactoryBot.create(attribute.to_s.singularize)
      else
        subject.send(attribute) << FactoryBot.create(attribute.to_s.singularize)
      end
    end

    clear_items = lambda do
      if @through
        subject.send(@through).each { |intermediate| intermediate.send(attribute).delete_all }
      else
        subject.send(attribute).delete_all
      end
    end

    subject.save!

    add_item.call
    subject.save!
    subject.reload
    @failed << 'Cannot add a new children' if subject.send(attribute).empty?

    raised = raise_exception(ActiveRecord::RecordNotDestroyed).matches? -> { subject.destroy! }
    @failed << 'Should have prevented deletion while it has children' unless raised

    clear_items.call
    raised = raise_exception(ActiveRecord::RecordNotDestroyed).matches? -> { subject.destroy! }
    @failed << 'Should have allowed deletion without children' if raised

    @failed.empty?
  end

  failure_message do |subject|
    message = "#{subject.class.name}.#{attribute} doesn't seem to be properly configured:"
    @failed.each do |failure|
      message << "\n - #{failure}"
    end
    message
  end
end
