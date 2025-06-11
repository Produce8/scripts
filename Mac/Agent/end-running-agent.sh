process_name="Produce8-Agent"

killall "$process_name"
if [ $? -eq 0 ]; then
  echo "Process(es) $process_name terminated successfully"
else
  echo "Failed to terminate process(es) $process_name"
fi