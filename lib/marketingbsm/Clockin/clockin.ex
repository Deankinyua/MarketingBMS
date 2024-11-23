defmodule Marketingbsm.Clockin do
  use Ash.Domain

  domain do
    description """
    This Domain holds Resources related to Ambassadors check-ins and check-outs
    """
  end

  resources do
    resource Marketingbsm.Clockin.Checkin do
      define :add_data, action: :create
      define :update_data, action: :update
      define :read_data, action: :read
    end
  end

  resources do
    resource Marketingbsm.Clockin.Checkout do
      define :add_data_checkout, action: :create
      define :update_data_checkout, action: :update
      define :read_data_checkout, action: :read
      define :get_user_by_id, args: [:ambassador_id, :create_date], action: :by_id
    end
  end
end
