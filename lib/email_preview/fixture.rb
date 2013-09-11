module EmailPreview
  class Fixture
    DEFAULT_CATEGORY = 'General'
    attr_accessor :category, :description, :callback

    def initialize(description, options = {}, &block)
      self.category = options[:category] || DEFAULT_CATEGORY
      self.description = options[:description] || description.to_s
      self.callback = block
    end
    
    def preview(params)
      case self.callback.arity
      when 0
        self.callback.call
      else
        self.callback.call(parse_params(params))
      end
    end

    def preview_with_transaction(params)
      return preview_without_transaction(params) unless EmailPreview.transactional?
      mail = nil
      ActiveRecord::Base.transaction do
        mail = preview_without_transaction(params)
        raise ActiveRecord::Rollback, "EmailPreview rollback"
      end
      mail
    end
    alias_method_chain :preview, :transaction

    protected

    def parse_params(params)
      Rack::Utils.parse_nested_query(params).symbolize_keys
    end
  end

end
