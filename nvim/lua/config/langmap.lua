local escape = function(str)
  local escape_chars = [[;,.|"\|\]]
  return vim.fn.escape(str, escape_chars)
end

local qwerty       = [[qwertyuiop[]asdfghjkl;'zxcvbnm,./]]
local norman       = [[qwdfkjurl;[]asetgynioh'zxcvbpm,./]]
local ru           = [[йцукенгшщзхъфывапролджэячсмитьбю/]]

local qwerty_shift = [[QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?]]
local norman_shift = [[QWDFKJURL:{}ASETGYNIOH"ZXCVBPM<>?]]
local ru_shift     = [[ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ?]]

vim.opt.langmap = vim.fn.join({
  escape(norman) .. ';' .. escape(qwerty),
  escape(norman_shift) .. ';' .. escape(qwerty_shift),
  escape(ru) .. ';' .. escape(qwerty),
  escape(ru_shift) .. ';' .. escape(qwerty_shift),
}, ',')
