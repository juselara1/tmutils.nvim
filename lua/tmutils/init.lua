local capture = require("tmutils.capture")

vim.api.nvim_create_user_command("TmutilsCapture", capture.tmux_capture, {nargs=1})
