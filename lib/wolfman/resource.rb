module Wolfman
  class Resource
    attr_reader :response_json

    def initialize(response)
      @response_json = response
      @struct = RecursiveOpenStruct.new(@response_json, {recurse_over_arrays: true})
    end

    def as_json(options = {})
      @response_json
    end

    def method_missing(name, *args)
      @struct.send(name, *args)
    end
  end
end
