function split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, delimiter, pos, true)
  end, nil, nil do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end
cmd = "dir /b"
thisFileName = "allfile.lua"
outFileName = "fileList.txt"
print("========")
local retFile = io.popen(cmd)
local fileList = {}
local fileDesc = {}
for line in retFile:lines() do
  if line ~= thisFileName and line ~= outFileName then
    local opeFile = io.open(line, "r")
    local cnt = opeFile:read("*a")
    if string.find(cnt, "self:CannotUseInFight()") then
      fileList[line] = "FALSE"
    else
      fileList[line] = "TRUE"
    end
    fileDesc[line] = ""
  end
end
retFile:close()
local outFile = io.open(outFileName, "r")
if outFile then
  for line in outFile:lines() do
    local strs = split(line, "\t")
    local tof = fileList[strs[2]]
    fileList[strs[2]] = tof
    fileDesc[strs[2]] = strs[3]
  end
  outFile:close()
end
outFile = io.open(outFileName, "w")
for k, v in pairs(fileList) do
  local line = string.format("%s\t%s\t%s\n", v, k, fileDesc[k])
  outFile:write(line)
  print(line)
end
outFile:close()
print("========")
