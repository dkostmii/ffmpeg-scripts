$seekTimeSeconds = 2
$streamLengthSeconds = 32
$filterScript = "[0:v] fps=12,crop=512:512,...other filters...,split [a][b]; [a] palettegen [p]; [b][p] paletteuse"

ffmpeg -y -ss $seekTimeSeconds -t $streamLengthSeconds -i my-video.mp4 -filter_complex $filterScript my-gif.gif

