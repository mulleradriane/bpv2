Estrutura esperada para method_responses:


methods = [
  {
    http_method = "GET"
    resource_id = "abc123"
    method_responses = {
      "200" = {
        response_models    = {"application/json" = "Empty"}
        response_parameters = {"method.response.header.Content-Type" = true}
      },
      "400" = {
        response_models    = {"application/json" = "Error"}
        response_parameters = {}
      }
    }
  }
]