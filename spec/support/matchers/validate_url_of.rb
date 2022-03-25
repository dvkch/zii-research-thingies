RSpec::Matchers.define :validate_url_of do |attribute|

  def allowing_nil
    @allow_nil = true
    self
  end

  def allowing_blank
    @allow_nil = true
    @allow_blank = true
    self
  end

  def with_hosts(hosts)
    @hosts = hosts
    self
  end

  match do |subject|
    valid = proc {
      # evaluate validity but only check errors for the given attribute
      subject.valid?
      subject.errors[attribute].empty?
    }

    @allow_nil = false if @allow_nil.nil?
    @allow_blank = false if @allow_blank.nil?
    @hosts = [] if @hosts.nil?

    @failed = []

    # nil
    subject.send("#{attribute}=", nil)
    @failed << 'should allow nil' if @allow_nil && !valid.call
    @failed << 'should not allow nil' if !@allow_nil && valid.call

    # blank
    subject.send("#{attribute}=", '')
    if subject.send(attribute) == ''
      # if the attribute is translated, mobility converts blanks to nils
      @failed << 'should allow blank' if @allow_blank && !valid.call
      @failed << 'should not allow blank' if !@allow_blank && valid.call
    end

    # http
    http_value = 'http://google.com'
    http_value = 'http://' + @hosts.first unless @hosts.empty?
    subject.send("#{attribute}=", http_value)
    @failed << "should allow #{http_value}" unless valid.call

    # https
    https_value = 'https://google.com'
    https_value = 'https://' + @hosts.first unless @hosts.empty?
    subject.send("#{attribute}=", https_value)
    @failed << "should allow #{https_value}" unless valid.call

    # invalid
    invalid_value = 'not on internet'
    subject.send("#{attribute}=", invalid_value)
    @failed << "should not allow #{invalid_value}" if valid.call

    # valid hosts only
    unless @hosts.empty?
      @hosts.each do |valid_host|
        subject.send("#{attribute}=", 'https://' + valid_host)
        @failed << "should allow #{valid_host}" unless valid.call
      end

      invalid_host = 'website-that-doesnt-exist.com'
      subject.send("#{attribute}=", invalid_host)
      @failed << "should not allow #{invalid_host}" if valid.call
    end

    @failed.empty?
  end

  failure_message do |subject|
    message = "#{subject.class.name}.#{attribute} doesn't seem to properly check for urls:"
    @failed.each do |failure|
      message << "\n - #{failure}"
    end
    message
  end
end
