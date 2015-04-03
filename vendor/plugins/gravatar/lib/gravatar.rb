require 'digest/md5'
require 'cgi'


module GravatarHelper

  # These are the options that control the default behavior of the public
  # methods. They can be overridden during the actual call to the helper,
  # or you can set them in your environment.rb as such:
  #
  #   # Allow racier gravatars
  #   GravatarHelper::DEFAULT_OPTIONS[:rating] = 'R'
  #
  DEFAULT_OPTIONS = {
    # The URL of a default image to display if the given email address does
    # not have a gravatar. Instead of a url we can also use
    # "identicon" "monsterid" and "wavatar".
    :default => nil,
    
    # The default size in pixels for the gravatar image (they're square).
    :size => 50,
    
    # The maximum allowed MPAA rating for gravatars. This allows you to 
    # exclude gravatars that may be out of character for your site.
    :rating => 'PG',
    
    # The alt text to use in the img tag for the gravatar.  Since it's a
    # decorational picture, the alt text should be empty according to the
    # XHTML specs.
    :alt => '',

    # The title text to use for the img tag for the gravatar.
    :title => '',
    
    # The class to assign to the img tag for the gravatar.
    :class => 'gravatar',
    
    # Whether or not to display the gravatars using HTTPS instead of HTTP
    :ssl => false,
    
    # Whether avatar should load as background element for faster page loading
    :fast => true,
  }
  
  # The methods that will be made available to your views.
  module PublicMethods
  
    # Return the HTML img tag for the given user's gravatar. Presumes that 
    # the given user object will respond_to "email", and return the user's
    # email address.
    def gravatar_for(user, options={})
     
      gravatar(user.email, options)
    end

    # Return the HTML img tag for the given email address's gravatar.
    def gravatar(email, options={})
      src = h(gravatar_url(email, options))
      options.reverse_merge!(DEFAULT_OPTIONS)
      size = options.delete(:size)
      size = "#{size}px" if size.is_a?(Integer)
      if options.delete(:fast)
        options[:style] = "width:#{size};height:#{size};background:url(#{src}) no-repeat;"
        content_tag :div, options
      else
         image_tag src, options.merge(:width => size, :height => size)
      end
    end
    
    # Returns the base Gravatar URL for the given email hash. If ssl evaluates to true,
    # a secure URL will be used instead. This is required when the gravatar is to be 
    # displayed on a HTTPS site.
    def gravatar_api_url(hash, ssl=false)
      if ssl
        "https://secure.gravatar.com/avatar/#{hash}"
      else
        "http://www.gravatar.com/avatar/#{hash}"
      end
    end

    # Return the gravatar URL for the given email address.
    def gravatar_url(email, options={})
      email_hash = Digest::MD5.hexdigest(email)
      options = DEFAULT_OPTIONS.merge(options)
      options[:default] = CGI::escape(options[:default]) unless options[:default].nil?
      gravatar_api_url(email_hash, options.delete(:ssl)).tap do |url|
        opts = []
        [:rating, :size, :default].each do |opt|
          unless options[opt].nil?
            value = h(options[opt])
            opts << [opt, value].join('=')
          end
        end
        url << "?#{opts.join('&')}" unless opts.empty?
      end
    end

  end
  
end
