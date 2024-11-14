defmodule Marketingbsm.File do
  use Ash.Resource,
    data_layer: :embedded

  resource do
    description """
    Represents a file object
    """
  end

  attributes do
    attribute :filename, :string,
      description: "The system issued filename when upload is complete"

    attribute :original_filename, :string, description: "The filename from client device"
  end
end
