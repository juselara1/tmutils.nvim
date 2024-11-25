local capture = require("tmutils.capture")
local send = require("tmutils.send")

vim.api.nvim_create_user_command("TmutilsCapture", capture.tmux_capture, {nargs=1})
vim.api.nvim_create_user_command("TmutilsSend", send.tmux_send, {nargs=1, range=true})
