defmodule NavHelper do
  def toggle_nav(hider) do
    if hider == "" do
      hider = "hidden"
      hider
    else
      hider = ""
      hider
    end
  end
end
