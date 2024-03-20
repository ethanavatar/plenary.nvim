local system = { }

function system.is_windows()
  return package.config:sub(1,1) == '\\'
end

function system.uses_shellslash()
  return vim.o.shellslash == true
end

return system
