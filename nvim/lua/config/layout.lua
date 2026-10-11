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

local function map_ctrl_key(qwerty_key)
  local pos = qwerty:find(qwerty_key)
  if pos then
    local norman_key = norman:sub(pos, pos)
    vim.keymap.set('n', '<C-' .. norman_key .. '>', '<C-' .. qwerty_key .. '>', { remap = false })
  end
end

map_ctrl_key('r')
map_ctrl_key('i')
map_ctrl_key('f')
map_ctrl_key('t')
map_ctrl_key('o')
map_ctrl_key('l')
map_ctrl_key('n')
map_ctrl_key('p')
map_ctrl_key(';')
map_ctrl_key('h')
map_ctrl_key('y')
map_ctrl_key('j')
map_ctrl_key('k')
map_ctrl_key('d')
map_ctrl_key('e')
