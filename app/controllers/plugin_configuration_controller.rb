class PluginConfigurationController < ApplicationController

  before_filter :block_demo_access

  filter_access_to :all

  def configure
    @config = PluginConfiguration.where(:typeclass => params[:typeclass]).first || PluginConfiguration.new(:configuration => {})
    @requested_fields = get_requested_fields(params[:plugin_type], params[:typeclass]) || Hash.new
  end

  def store
  	config = PluginConfiguration.where(:typeclass => params[:typeclass]).first || PluginConfiguration.new

  	config.typeclass = params[:typeclass]
  	config.configuration = params[:config]

  	if config.save
  	  flash[:notice] = "Plugin configuration updated."
  	else
  	  flash[:error] = "Could not update plugin configuration!"
  	end

  	redirect_to :action => :configure
  end

  private
  def get_requested_fields(plugin_type, typeclass)
  	case plugin_type
  		when "alarm_callback"
  			return AlarmCallback.where(:typeclass => typeclass).first.requested_config
      when "message_output"
        return MessageOutput.where(:typeclass => typeclass).first.requested_config
      when "message_input"
        return MessageInput.where(:typeclass => typeclass).first.requested_config
      when "initializer"
        return Initializer.where(:typeclass => typeclass).first.requested_config
      when "transport"
        return Transport.where(:typeclass => typeclass).first.requested_config
  	end
  rescue
  	{}
  end

  def block_demo_access
    if ::Configuration.is_demo_system?
      flash[:notice] = "Sorry, plugin configurations are blocked in demo mode."
      redirect_to :controller => :systemsettings
    end
  end

end