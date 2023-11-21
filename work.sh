#! /bin/zsh
session=ollero

# kill session
if [ "$1" = "k" ]; then
  echo "Kill session"
  tmux kill-session -t $session
  exit 0
fi

echo "Opening workspace..."

# setup windows
tmux new -s $session -n modmon -c ~/w/marco-souza/ollero.nvim/ -d nvim && \

# select first window
tmux select-window -t "$session:0"

# attach
echo "attach ? [Y/n]"
read confirm
if [ "${confirm:-y}" = "y" ]; then
  tmux a -t $session
fi

