module Webmachine
  # Represents an HTTP response from Webmachine.
  class Response
    # Pattern for quoted headers
    QUOTED = /^"(.*)"$/

    # @return [Hash] Response headers that will be sent to the client
    attr_reader :headers

    # @return [Fixnum] The HTTP status code of the response
    attr_accessor :code

    # @return [String, #each] The response body
    attr_accessor :body

    # @return [true,false] Whether the response is a redirect
    attr_accessor :redirect

    # @return [Array] the list of states that were traversed
    attr_reader :trace
    
    # @return [Symbol] When an error has occurred, the last state the
    #   FSM was in
    attr_accessor :end_state

    # @return [String] The error message when responding with an error
    #   code
    attr_accessor :error
    
    # Creates a new Response object with the appropriate defaults.
    def initialize
      @headers = {}
      @trace = []
      self.code = 200
      self.redirect = false      
    end

    # Indicate that the response should be a redirect. This is only
    # used when processing a POST request in
    # {Resource::Callbacks#process_post} to indicate that the client
    # should request another resource using GET. Either pass the URI
    # of the target resource, or manually set the Location header
    # using {#headers}.
    # @param [String, URI] location the target of the redirection
    def do_redirect(location=nil)
      headers['Location'] = location.to_s if location
      self.redirect = true
    end

    alias :is_redirect? :redirect
    alias :redirect_to :do_redirect

    # Set the ETag header for this response if a value is given
    # @param [#to_s] etag
    #   the value to which the ETag header is to be set
    def etag=(etag)
      headers['ETag'] = ensure_quoted_header(etag) if etag
    end

    # Set the Expires header for this response if a value is given
    # @param [#httpdate] expires
    #   the value to which the Expires header is to be set
    def expires=(expires)
      headers['Expires'] = expires.httpdate if expires
    end

    # Set the Last-Modified header for this response if a value is given
    # @param [#httpdate] last_modified
    #   the value to which the Last-Modified header is to be set
    def last_modified=(last_modified)
      headers['Last-Modified'] = last_modified.httpdate if last_modified
    end

  private

    # Ensures that a header is quoted (like ETag)
    def ensure_quoted_header(value)
      if value =~ QUOTED
        value
      else
        '"' << value << '"'
      end
    end

  end # class Response
end # module Webmachine
