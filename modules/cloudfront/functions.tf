resource "aws_cloudfront_function" "return_404" {
  name    = "return_404"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOF
    function handler(event) {
        var response = {
            statusCode: 404,
            statusDescription: 'Not found',
        };
        return response;
    }
  EOF
}

resource "aws_cloudfront_function" "normalize_webp" {
  name    = "normalize_webp"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOF
    function handler(event) {
      var req = event.request;
      var h = req.headers;

      var accept = (h.accept && h.accept.value) ? h.accept.value : "";
      var webp = accept.indexOf("image/webp") !== -1;

      h["x-image-format"] = { value: webp ? "webp" : "orig" };
      return req;
    }
  EOF
}
