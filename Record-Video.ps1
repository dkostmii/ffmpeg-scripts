param(
  [string] $WindowTitle,
  [switch] $Audio = $false,
  [switch] $DrawMouse = $false,
  [string] $VideoSize = "1600x900",
  [int] $FPS = 30
)

$outputDir = (Join-Path $env:userprofile "Videos" "Captures");

if (-not (Test-Path -Path $outputDir -PathType Container)) {
  New-Item -Path $outputDir -ItemType Directory -Force
}

$timestamp = (Get-Date -Format "yyyyMMddHHmmss");
$filename = "Capture-$timestamp.mp4"

$file = (Join-Path $outputDir $filename)

function Get-AudioDevices {
  ffmpeg -list_devices true -f dshow -i dummy 2> audioDevices.txt
  $devices = (Get-Content audioDevices.txt) -match "`".*`"(?=\s\(audio\))"

  $devices = $devices.Split('`n') | ForEach-Object { $_ -replace "\[.*\] | \(audio\)|`"","" }

  Remove-Item audioDevices.txt

  return $devices
}

$audioDevices = Get-AudioDevices
$selectedAudioDevice = $audioDevices[0]

$cropScript = "crop=trunc(iw/2)*2:trunc(ih/2)*2"

$mouse = if ($DrawMouse) { 1 } else { 0 }

$pixFmt = "yuv420p";
$codec = "libx264";

$dshowBuffer = "1500M"
$gdiBuffer = "100M"
$threadQueueSize = 512

if (-not $WindowTitle) {
  if ($Audio) {
    ffmpeg -rtbufsize $dshowBuffer -f dshow -thread_queue_size $threadQueueSize -i audio=$selectedAudioDevice -f gdigrab -framerate $FPS -show_region 1 -draw_mouse $mouse -offset_x 0 -offset_y 0 -video_size $VideoSize -thread_queue_size $threadQueueSize -i desktop -pix_fmt $pixFmt -c:v $codec $file
  }
  else {
    ffmpeg -rtbufsize $gdiBuffer -rtbufsize $gdiBuffer -f gdigrab -framerate $FPS -show_region 1 -draw_mouse $mouse -offset_x 0 -offset_y 0 -video_size $VideoSize -thread_queue_size $threadQueueSize -i desktop -pix_fmt $pixFmt -c:v $codec $file
  }
}
else {
  if ($Audio) {
    ffmpeg -rtbufsize $dshowBuffer -f dshow -thread_queue_size $threadQueueSize -i audio=$selectedAudioDevice -rtbufsize $gdiBuffer -f gdigrab -framerate $FPS -show_region 1 -draw_mouse $mouse -thread_queue_size $threadQueueSize -i title=$WindowTitle -vf $cropScript -pix_fmt $pixFmt -c:v $codec $file
  }
  else {
    ffmpeg -rtbufsize $gdiBuffer -f gdigrab -framerate $FPS -show_region 1 -draw_mouse $mouse -thread_queue_size $threadQueueSize -i title=$WindowTitle -vf $cropScript -pix_fmt $pixFmt -c:v $codec $file
  }
}

Write-Host "Writing to " -NoNewline
Write-Host "$file ..." -ForegroundColor Yellow

Write-Host "Done." -ForegroundColor Green