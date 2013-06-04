class IndexController < ApplicationController
  def mockups
    @methods = MockupController.public_instance_methods(false).map { |med| med.to_s }
  end
end
