module BaseIndexer
  class ApplicationController < ActionController::Base
    respond_to :json, :xml, :html

    def remove_prefix(druid)
      druid.gsub('druid:', '') # lop off druid prefix if sent
    end

    def report_failure(method_symbol, params, e)
      "#{method_symbol} #{params}\n\n#{e.inspect}\n#{e.message}\n#{e.backtrace}"
    end

    def report_success
      'success'
    end
  end
end
