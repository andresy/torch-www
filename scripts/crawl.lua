require 'paths'

local remote = arg[1]

function file2id(dir)
   local remote = remote:gsub('%-', '%%%-')
   dir = dir:gsub('^' .. remote .. '/torch7/dok', 'manual')
   dir = dir:gsub('^' .. remote .. '/torch7/', '')
   dir = dir:gsub('%.txt', '')
--   dir = dir:gsub('/', ':')
   return dir
end

function addfilesfromdir(files, dir)
   for file in paths.files(dir) do
      if file ~= '.' and file ~= '..' then
	 if paths.filep(paths.concat(dir, file, 'index.txt')) then
--	    print('DIR', paths.concat(dir, file))
	    addfilesfromdir(files, paths.concat(dir, file))
	 elseif file:match('%.txt$') then
--	    print('FIL', paths.concat(dir, file))
	    table.insert(files, paths.concat(dir, file))
	 end
      end
   end
end

local files = {}
addfilesfromdir(files, remote .. '/torch7')

for _,file in pairs(files) do
   local cmd = 'wget -qO- ' .. '"http://www.torch.ch/' .. file2id(file) .. '"'
   print(cmd)
   local f = io.popen(cmd)
   local txt = f:read('*all')
   f:close()
--   print(txt)
   local imgbug = txt:match('img src%="(/lib/exe/indexer%.php.-)"')
   if imgbug then
      local cmd = 'wget -qO- ' .. '"http://www.torch.ch' .. imgbug .. '"'
      print(cmd)
      local f = io.popen(cmd)
      local txt = f:read('*all')
      f:close()
   end
end
