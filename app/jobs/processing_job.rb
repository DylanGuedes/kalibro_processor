require 'metric_collector'
require 'processor'

class ProcessingJob < ActiveJob::Base
  queue_as :default

  before_perform do |job|
    @context = Processor::Context.new
  end

#FIXME This should work for periodic_processing
=begin
  after_perform do |job|
    period = @context.repository.period
    if period > 0
      new_processing = Processing.create(repository: @repository, state: "PREPARING")
      ProcessingJob.set(wait: period.day).perform_later(@context.repository,new_processing)
    end
  end
=end

  rescue_from(Errors::ProcessingCanceledError) do
    @context.processing.destroy
  end

  rescue_from(Errors::ProcessingError) do |exception|
    @context.processing.update(state: 'ERROR', error_message: exception.message)
  end

  rescue_from(Errors::EmptyModuleResultsError) do
    @context.processing.update(state: "READY")
  end

  def perform(repository, processing)
    @context.repository = repository
    @context.processing = processing

    Processor::Preparer.perform(@context)
    Processor::Downloader.perform(@context)
    Processor::Collector.perform(@context)
    Processor::TreeBuilder.perform(@context)
    Processor::Aggregator.perform(@context)
    Processor::CompoundResultCalculator.perform(@context)
    Processor::Interpreter.perform(@context)

    @context.processing.update(state: "READY")
  end
end
