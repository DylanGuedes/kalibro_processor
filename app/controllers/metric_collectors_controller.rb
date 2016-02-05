require 'metric_collector'

class MetricCollectorsController < ApplicationController
  def all_names
    names = { metric_collector_names: MetricCollector::Native.available.keys.concat(
      MetricCollector::KolektiAdapter.available.map(&:name)) }

    respond_to do |format|
      format.json { render json: names }
    end
  end

  def index
    respond_to do |format|
      format.json { render json: MetricCollector::Native.details.concat(MetricCollector::KolektiAdapter.details) }
    end
  end

  def find
    details = MetricCollector::Native.details.
                concat(MetricCollector::KolektiAdapter.details).
                find { |d| d.name == params[:name] }

    if details.nil?
      return_value = { error: Errors::NotFoundError.new("Metric Collector #{params[:name]} not found.") }
    else
      return_value = { metric_collector_details: details }
    end

    respond_to do |format|
      if return_value[:error].nil?
        format.json { render json: return_value }
      else
        format.json { render json: return_value, status: :not_found }
      end
    end
  end
end
