class Object
  private macro initializer(*args)
    def initialize({{*args.map { |a| "@#{a}".id }}})
    end
  end

  private macro getter_initializer(*args)
    initializer {{*args}}
    getter {{*args}}
  end

  private macro setter_initializer(*args)
    initializer {{*args}}
    setter {{*args}}
  end

  private macro property_initializer(*args)
    initializer {{*args}}
    property {{*args}}
  end
end
