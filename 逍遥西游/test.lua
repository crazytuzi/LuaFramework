local currentFolder = "/Users/user/work/xiyou/Proj/xiyou/res"
local hex = function(s)
  s = string.gsub(s, "(.)", function(x)
    return string.format("%02X", string.byte(x))
  end)
  return s
end
local readFile = function(path)
  local file = io.open(path, "rb")
  if file then
    local content = file:read("*all")
    io.close(file)
    return content
  end
  return nil
end
require("lfs")
local function findindir(path, wefind, dir_table, r_table, intofolder)
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." and file ~= ".DS_Store" and file ~= "flist" and file ~= "launcher.zip" then
      local f = path .. "/" .. file
      local attr = lfs.attributes(f)
      assert(type(attr) == "table")
      if attr.mode == "directory" and intofolder then
        table.insert(dir_table, f)
        findindir(f, wefind, dir_table, r_table, intofolder)
      else
        table.insert(r_table, {
          name = f,
          size = attr.size
        })
      end
    end
  end
end
MakeFileList = {}
function MakeFileList:run(path)
  local dir_table = {}
  local input_table = {}
  findindir(currentFolder, ".", dir_table, input_table, true)
  local pthlen = string.len(currentFolder) + 2
  local buf = "local flist = {\n"
  buf = buf .. "\tappVersion = 1,\n"
  buf = buf .. "\tversion = \"1.0.2\",\n"
  buf = buf .. "\tdirPaths = {\n"
  for i, v in ipairs(dir_table) do
    print("1  MakeFileList:run:", i, v)
    local fn = string.sub(v, pthlen)
    buf = buf .. "\t\t{name = \"" .. fn .. "\"},\n"
  end
  buf = buf .. "\t},\n"
  buf = buf .. "\tfileInfoList = {\n"
  for i, v in ipairs(input_table) do
    print("2  MakeFileList:run:", i, v)
    local fn = string.sub(v.name, pthlen)
    buf = buf .. "\t\t{name = \"" .. fn .. "\", code = \""
    local data = readFile(v.name)
    local ms = crypto.md5(hex(data or "")) or ""
    buf = buf .. ms .. "\", size = " .. v.size .. "},\n"
  end
  buf = buf .. "\t},\n"
  buf = buf .. [[
}

]]
  buf = buf .. "return flist"
  io.writefile(currentFolder .. "/flist", buf)
end
function MakeFileList:CheckMd5(srcPath, dstPath)
  if srcPath:sub(-1) ~= "/" then
    srcPath = srcPath .. "/"
  end
  if dstPath:sub(-1) ~= "/" then
    dstPath = dstPath .. "/"
  end
  for file in lfs.dir(srcPath) do
    if file ~= "." and file ~= ".." and file ~= ".DS_Store" and file ~= "flist" and file ~= "launcher.zip" then
      local f = srcPath .. file
      local attr = lfs.attributes(f)
      assert(type(attr) == "table")
      if attr.mode == "directory" then
      else
        local data1 = readFile(f)
        local ms1 = crypto.md5(hex(data1 or "")) or ""
        local data2 = readFile(dstPath .. file)
        local ms2 = crypto.md5(hex(data2 or "")) or ""
        print(file, ms1 == ms2, ms1, ms2)
      end
    end
  end
end
function MakeFileList:test()
  print("===== TEST =====")
  local result = SYCommon:CompressFolderToZip("/Users/user/work/xiyou/Proj/xiyou/res/script_zip_t.zip", "/Users/user/work/xiyou/Proj/xiyou/res/script_zip")
  SYCommon:UnCompressZip("/Users/user/work/xiyou/Proj/xiyou/res/script_zip_t.zip", "/Users/user/work/xiyou/Proj/xiyou/res/script_zip_t/")
  require("test")
  MakeFileList:CheckMd5("/Users/user/work/xiyou/Proj/xiyou/res/script_zip/", "/Users/user/work/xiyou/Proj/xiyou/res/script_zip_t/")
  print("=== test:", result)
end
return MakeFileList
