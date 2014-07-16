class BaseToolsController < ApplicationController
  def all_names
    names = {base_tool_names: available_base_tools.keys }

    respond_to do |format|
      format.json { render json: names }
    end
  end

  def find
    collector = available_base_tools.values_at(params[:name]).first
    if collector.nil?
      base_tool = {error: Errors::NotFoundError.new("Base tool #{params[:name]} not found.")}
    else
      base_tool = {base_tool: BaseTool.new(params[:name], collector.description, collector.to_s, collector.supported_metrics)}
    end

    respond_to do |format|
      if base_tool[:error].nil?
        format.json { render json: base_tool}
      else
        format.json { render json: base_tool, status: :unprocessable_entity }
      end
    end
  end

  private

  def available_base_tools
    Runner::BASE_TOOLS.select {|name, collector| collector.available?}
  end

end