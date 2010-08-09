class RenderIt
  # Default regular expressions to define browser and its version
  DEFAULT_BROWSERS_CONFIG = {
    'ie' => 'msie (\d+\.\d).*\)(?!\s*opera)', 
    'firefox' => 'gecko.*?firefox\/(\d+\.\d)', 
    'chrome' => 'applewebkit.*?chrome\/(\d+\.\d)', 
    'safari' => 'applewebkit.*?version\/(\d+.\d)\.\d(?!\s*mobile).*?safari', 
    'safarimobile' => 'applewebkit.*?version\/(\d+.\d)\.\d\smobile.*?safari', 
    'opera' => 'opera.*?version\/(\d+\.\d)' 
  }
  VERSION_MATCH_REGEXP = Regexp.new("([a-z]+)(.*)", "i")
  NON_EXPRESSION_REGEXP = Regexp.new("^[^><=]")

  Browser = Struct.new(:name, :version)

  # Returns template name depending on request. 
  # Template name depends on configuration defined in conf/renderit.yml  
  # For example, if renderit.yml will contain following:
  #
  # templates:
  #      new: chrome>5, firefox>3.5, opera>10.5
  #
  # And request will be made from Chrome6.0 then if 'new' string should be returned.
  def self.get_template_name(request)
    user_agent = request.env["HTTP_USER_AGENT"]
    browser = self.get_browser(user_agent)
    return self.template_name(browser)
  end


  # Returns browser name and its version 
  def self.get_browser(user_agent)
    browsers_config = read_inheritable_attribute(:browsers_config)    
    browsers_config.keys.each do |browser_name|
      if version = browsers_config[browser_name].match(user_agent)
        return Browser.new(browser_name, version[1])
      end
    end
  end


  # Returns template name based on browser and configuration
  def self.template_name(browser)
    templates_config = read_inheritable_attribute(:templates_config)
    return '' unless templates_config
    if (browser)
      templates_config.keys.each do |name|
        if comparator = templates_config[name][browser.name]
          return name if eval(browser.version+comparator)
        end
      end
    end
    return ''
  end

  # Loads initial configuration from config/renderit.yml file
  # This is made once on rails application start
  def self.load_config
    if File.exist?(File.join(Rails.root, 'config/renderit.yml'))
      renderit_config = YAML::load_file(File.join(Rails.root, 'config/renderit.yml'))
      
      #Loading browsers config
      browsers_config = renderit_config['browsers']||{}
      browsers_config.merge!(DEFAULT_BROWSERS_CONFIG)
      #Turning strings into RegExp
      browsers_config.keys.each do |browser|
        browsers_config[browser] = Regexp.new(browsers_config[browser], 'i')
      end
      write_inheritable_attribute(:browsers_config, browsers_config)

      #Loading templates config
      templates_config = renderit_config['templates']
      templates_config.keys.each do |template_name|
        matching_browser_versions = templates_config[template_name]
        templates_config[template_name] = {}
        matching_browser_versions.split(',').each do |value|
          match = VERSION_MATCH_REGEXP.match(value)
          if (browser = match[1]) && (expression = match[2])
            expression = expression.strip
            expression = '=='+expression if NON_EXPRESSION_REGEXP.match(expression)
            templates_config[template_name][browser.strip.downcase] = expression
          end
        end
      end

      write_inheritable_attribute(:templates_config, templates_config)
    end

  end

end


RAILS_THREE_REGEXP = /^3/

if RAILS_THREE_REGEXP =~ Rails.version # If rails version is 3

  module AbstractController
    module Rendering

      def _normalize_options(options)
        if options[:partial] == true
          options[:partial] = action_name
        end
        if (options.keys & [:partial, :file, :template]).empty?
          options[:prefix] ||= _prefix
        end

        options[:template] ||= (options[:action] || action_name).to_s
        if (@renderit_template ||= RenderIt.get_template_name(request))
          begin
            template_name = options[:template]+'_'+@renderit_template
            if lookup_context.find_template(template_name, options[:prefix])
              options[:template] = template_name
            end
          rescue ActionView::MissingTemplate => e          
          end
        end
        options
      end

    end

  end

  module AbstractController
    module Layouts

      def _normalize_options(options)
        super
        if _include_layout?(options)
          layout = options.key?(:layout) ? options.delete(:layout) : :default
          value = _layout_for_option(layout)
          if (value && (@renderit_template ||= RenderIt.get_template_name(request)) )
            begin
              template_name = value+'_'+@renderit_template
              if lookup_context.find_template(template_name, 'layouts')
                value = template_name
              end
            rescue ActionView::MissingTemplate => e
            end
          end
          options[:layout] = (value =~ /\blayouts/ ? value : "layouts/#{value}") if value
        end
      end

    end
  end


else # If rails version is 2.3.*

  class ActionController::Base
    private

    # default_render method for ActionController::Base is redefined
    # in order to render views for specific browsers (depending on user_agent)
    def default_render
      @renderit_template ||= RenderIt.get_template_name(request)
      template_path = default_template_name + '_' + @renderit_template
      if view_paths.find_template(template_path, default_template_format)
        render template_path
      end
    rescue ActionView::MissingTemplate => e
      render default_template_name
    end

    # default_layout method for ActionController::Base is redefined
    # in order to render layouts for specific browsers (depending on user_agent)
    def default_layout
      @renderit_template = RenderIt.get_template_name(request)
      layout = self.class.read_inheritable_attribute(:layout)
      return layout unless self.class.read_inheritable_attribute(:auto_layout)
      begin
        rendered_layout = find_layout(layout+ '_' + @renderit_template, default_template_format)
      rescue ActionView::MissingTemplate
      end
      return rendered_layout if rendered_layout
      find_layout(layout, default_template_format)
    rescue ActionView::MissingTemplate
      nil
    end

  end

  RenderIt.load_config

end
