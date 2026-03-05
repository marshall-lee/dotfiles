local Path = require("plenary.path")
local python_venv_path = Path:new(vim.fn.stdpath("data")):joinpath("venv")

local function ensure_venv()
  if vim.fn.isdirectory(python_venv_path:absolute()) == 0 then
    vim.notify("Creating Neovim python venv: " .. python_venv, vim.log.levels.INFO)
    local cmd = string.format("python3 -m venv %s", vim.fn.shellescape(python_venv))
    os.execute(cmd)
  end

  local python_bin = python_venv_path:joinpath("bin", "python3"):absolute()
  if vim.fn.filereadable(python_bin) == 0 then
    vim.notify("Python binary not found in venv: " .. python_bin, vim.log.levels.ERROR)
    return
  end

  vim.g.python3_host_prog = python_bin

  local lib_path = python_venv_path:joinpath("lib")
  local lib_dir = lib_path:absolute()
  if vim.fn.isdirectory(lib_dir) == 0 then
    vim.notify("Python lib directory not found in venv: " .. lib_dir, vim.log.levels.ERROR)
    return
  end

  local names = vim.fn.readdir(lib_dir)
  local mmaj, mmin, libstr = 0, 0, ""
  for _, name in ipairs(names) do
    local maj, min = string.match(name, "^python(%d+).(%d+)$")
    if maj then
      maj, min = tonumber(maj), tonumber(min)
      if maj > mmaj or (maj == mmaj and min > mmin) then
        mmaj, mmin = maj, min
        libstr = name
      end
    end
  end
  local pynvim_dir = lib_path:joinpath(libstr, "site-packages", "pynvim"):absolute()
  if vim.fn.isdirectory(pynvim_dir) == 1 then
    return
  end

  local install_cmd = string.format("%s -m pip install --upgrade pip pynvim", vim.fn.shellescape(python_bin))
  local ok = os.execute(install_cmd)
  if ok ~= 0 then
    vim.notify("Failed to install pynvim in venv: " .. python_bin, vim.log.levels.WARN)
  end
end

pcall(ensure_venv)
