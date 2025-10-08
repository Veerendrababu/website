param(
  [int]$Port = 8080
)

Add-Type -AssemblyName System.Net.HttpListener

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")

try {
  $listener.Start()
  Write-Host "Server started on port $Port" -ForegroundColor Green
  Write-Host "Local access: http://localhost:$Port" -ForegroundColor Yellow
    
  # Get local IP address
  $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq "Dhcp" }).IPAddress
  if ($localIP) {
    Write-Host "Network access: http://${localIP}:$Port" -ForegroundColor Cyan
    Write-Host "Use the network access URL on mobile devices connected to the same WiFi" -ForegroundColor Magenta
  }
    
  Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Red
    
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
        
    $localPath = $request.Url.LocalPath
    if ($localPath -eq "/") {
      $localPath = "/index.html"
    }
        
    $filePath = Join-Path (Get-Location) $localPath.TrimStart('/')
        
    if (Test-Path $filePath -PathType Leaf) {
      $content = [System.IO.File]::ReadAllBytes($filePath)
      $response.ContentLength64 = $content.Length
            
      # Set content type based on file extension
      $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
      switch ($extension) {
        ".html" { $response.ContentType = "text/html" }
        ".css" { $response.ContentType = "text/css" }
        ".js" { $response.ContentType = "application/javascript" }
        ".png" { $response.ContentType = "image/png" }
        ".jpg" { $response.ContentType = "image/jpeg" }
        ".jpeg" { $response.ContentType = "image/jpeg" }
        ".gif" { $response.ContentType = "image/gif" }
        ".ico" { $response.ContentType = "image/x-icon" }
        default { $response.ContentType = "application/octet-stream" }
      }
            
      $response.OutputStream.Write($content, 0, $content.Length)
      Write-Host "$(Get-Date -Format 'HH:mm:ss') - Served: $localPath" -ForegroundColor Green
    }
    else {
      $response.StatusCode = 404
      $errorContent = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
      $response.OutputStream.Write($errorContent, 0, $errorContent.Length)
      Write-Host "$(Get-Date -Format 'HH:mm:ss') - 404: $localPath" -ForegroundColor Red
    }
        
    $response.Close()
  }
}
catch {
  Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
  if ($listener.IsListening) {
    $listener.Stop()
  }
  Write-Host "Server stopped" -ForegroundColor Yellow
}