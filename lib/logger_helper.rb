module LoggerHelper
  def log msg
    if defined? Rails
      Rails.logger.info msg
    end
  end
end
