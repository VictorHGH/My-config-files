#!/bin/bash

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
	link1="localhost:8000"
	link2="https://www.youtube.com/watch?v=3HmFLO29RPU&list=PLZ2ovOgdI-kUSqWuyoGJMZL6xldXw6hIg&index=12"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
	link1="localhost/youtube_course"
	link2="https://www.youtube.com/watch?v=3HmFLO29RPU&list=PLZ2ovOgdI-kUSqWuyoGJMZL6xldXw6hIg&index=12"
else
    echo "Unsupported operating system"
    exit 1
fi

exoprt link1, link2

