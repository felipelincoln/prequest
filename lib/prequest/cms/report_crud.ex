defmodule Prequest.CMS.ReportCRUD do
  @moduledoc """
  CRUD implementation for reports
  """

  alias Prequest.CMS.{CRUD, Report}
  use CRUD, schema: Report
end
