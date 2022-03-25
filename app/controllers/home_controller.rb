# frozen_string_literal: true

class HomeController < ApplicationController
  def index
  end

  def test_route
    render json: {}, status: :ok
  end
end
