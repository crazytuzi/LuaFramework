function table_is_empty(t)
  return _G.next(t) == nil
end
function getTableLength(tb)
  if type(tb) ~= "table" then
    return 0
  end
  local n = 0
  for k, v in pairs(tb) do
    n = n + 1
  end
  return n
end
function DeepCopyTable(tbData)
  if type(tbData) ~= "table" then
    return tbData
  end
  local copyData = {}
  for k, v in pairs(tbData) do
    if type(v) == "table" then
      v = DeepCopyTable(v)
    end
    copyData[k] = v
  end
  return copyData
end
function ChangeTableKeyToNum(lua_table)
  if type(lua_table) ~= "table" then
    return lua_table
  end
  local newTable = {}
  for k, v in pairs(lua_table) do
    if type(k) == "string" and tonumber(k) ~= nil then
      newTable[tonumber(k)] = ChangeTableKeyToNum(v)
    else
      newTable[k] = ChangeTableKeyToNum(v)
    end
  end
  return newTable
end
function print_lua_table(lua_table, indent)
  if type(lua_table) ~= "table" then
    print("print_lua_table传进来的不是table")
    return
  end
  indent = indent or 0
  for k, v in pairs(lua_table) do
    if type(k) == "string" then
      k = string.format("%q", k)
    end
    local szSuffix = ""
    if type(v) == "table" then
      szSuffix = "{"
    end
    local szPrefix = string.rep("    ", indent)
    formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix
    if type(v) == "table" then
      print(formatting)
      print_lua_table(v, indent + 1)
      print(szPrefix .. "},")
    else
      local szValue = ""
      if type(v) == "string" then
        szValue = string.format("%q", v)
      else
        szValue = tostring(v)
      end
      print(formatting .. szValue .. ",")
    end
  end
end
function getSubNameStr(nameStr, maxSize, excstr, ft, ftSize, ftColor)
  excstr = excstr or ".."
  local exceedSize = false
  while true do
    while true do
      local temp = ui.newTTFLabel({
        text = nameStr,
        fontSize = ftSize,
        font = ft,
        color = ftColor
      })
      local size = temp:getContentSize()
      if maxSize < size.width then
        local temp = string.sub(nameStr, -1, -1)
        if temp:byte() > 128 then
          nameStr = string.sub(nameStr, 1, -4)
        else
          nameStr = string.sub(nameStr, 1, -2)
        end
        exceedSize = true
      else
        break
      end
    end
  end
  while true do
    if exceedSize then
      local temp = ui.newTTFLabel({
        text = nameStr .. excstr,
        fontSize = ftSize,
        font = ft,
        color = ftColor
      })
      local size = temp:getContentSize()
      if maxSize < size.width then
        local temp = string.sub(nameStr, -1, -1)
        if temp:byte() > 128 then
          nameStr = string.sub(nameStr, 1, -4)
        else
          nameStr = string.sub(nameStr, 1, -2)
        end
      else
        nameStr = nameStr .. excstr
        break
      end
    end
  end
  return nameStr
end
function getSubNameStrWithObj(txtObj, nameStr, maxSize, excstr)
  local ft = txtObj:getFontName()
  local ftSize = txtObj:getFontSize()
  local ftColor = txtObj:getColor()
  return getSubNameStr(nameStr, maxSize, excstr, ft, ftSize, ftColor)
end
function getRelativePetPos(pos)
  return pos + DefineRelativePetAddPos
end
local tan_225 = 0.4142135623731
local tan_675 = 2.4142135623731
function getDirectionByDelayPos(dx, dy, noCrossFlag)
  if noCrossFlag == true then
    if dx >= 0 then
      if dy > 0 then
        return DIRECTIOIN_RIGHTUP
      else
        return DIRECTIOIN_RIGHTDOWN
      end
    elseif dy > 0 then
      return DIRECTIOIN_LEFTUP
    else
      return DIRECTIOIN_LEFTDOWN
    end
  end
  if dy == 0 then
    if dx >= 0 then
      return DIRECTIOIN_RIGHT
    else
      return DIRECTIOIN_LEFT
    end
  elseif dx == 0 then
    if dy > 0 then
      return DIRECTIOIN_UP
    else
      return DIRECTIOIN_DOWN
    end
  else
    local div = dx / dy
    local absDiv = math.abs(div)
    if absDiv > tan_675 then
      if dx >= 0 then
        return DIRECTIOIN_RIGHT
      else
        return DIRECTIOIN_LEFT
      end
    elseif absDiv < tan_225 then
      if dy >= 0 then
        return DIRECTIOIN_UP
      else
        return DIRECTIOIN_DOWN
      end
    elseif dx > 0 then
      if dy > 0 then
        return DIRECTIOIN_RIGHTUP
      else
        return DIRECTIOIN_RIGHTDOWN
      end
    elseif dy > 0 then
      return DIRECTIOIN_LEFTUP
    else
      return DIRECTIOIN_LEFTDOWN
    end
  end
end
function separateUTF8String(s, n)
  local dropping = string.byte(s, n + 1)
  if not dropping then
    return s, ""
  end
  if dropping >= 128 and dropping < 192 then
    return separateUTF8String(s, n - 1)
  end
  local ls = string.sub(s, 1, n) or ""
  local rs = string.sub(s, n + 1) or ""
  return ls, rs
end
function GetMyUTF8Len(s)
  local l = 0
  local len = string.len(s)
  local isChinese = false
  for i = 1, len do
    local char = string.byte(s, i)
    if char < 128 then
      l = l + 1
    elseif char >= 192 then
      l = l + 2
    end
  end
  return l
end
function GetMyUTF8Len_ex(s)
  local l = 0
  local len = string.len(s)
  local isChinese = false
  for i = 1, len do
    local char = string.byte(s, i)
    if char < 128 then
      l = l + 1
    elseif char >= 192 then
      l = l + 1
    end
  end
  return l
end
function GetRichTextUTF8Len(s, fontName)
  local fontDict = getFontConfig(fontName)
  local l = 0
  local len = string.len(s)
  local isChinese = false
  for i = 1, len do
    local char = string.byte(s, i)
    if char < 128 then
      l = l + (fontDict[char] or 1)
    elseif char >= 192 then
      local delL = 2
      if char == 226 then
        local char2 = string.byte(s, i + 1)
        if char2 == 128 then
          local char3 = string.byte(s, i + 2)
          if char3 == 156 then
            delL = 1
          elseif char3 == 157 then
            delL = 1
          end
        end
      end
      l = l + delL
    end
  end
  return l
end
function SeparateRichTextUTF8Len(s, n, fontName)
  local fontDict = getFontConfig(fontName)
  if n == 0 then
    return "", s
  end
  local l = 0
  local len = string.len(s)
  local isChinese = false
  for i = 1, len do
    local char = string.byte(s, i)
    if char < 128 then
      l = l + (fontDict[char] or 1)
    elseif char >= 192 then
      l = l + 2
    end
    if n <= l then
      return separateUTF8String(s, i - 1)
    end
  end
  return s, ""
end
function isListEqual(list1, list2)
  if list1 == nil or list2 == nil or type(list1) ~= "table" or type(list2) ~= "table" then
    return false
  end
  if #list1 ~= #list2 then
    return false
  end
  for i, v in ipairs(list1) do
    if v ~= list2[i] then
      return false
    end
  end
  return true
end
function listContain(list, obj)
  if list == nil or type(list) ~= "table" then
    return false
  end
  for _, temp in pairs(list) do
    if temp == obj then
      return true
    end
  end
  return false
end
function isEqualMode(mode1, mode2)
  if mode1 == 0 then
    mode1 = false
  end
  if mode2 == 0 then
    mode2 = false
  end
  return mode1 == mode2
end
function GetTimeText(time)
  time = time or 0
  return string.format("%02d:%02d:%02d", math.floor(time / 3600), math.floor(time / 60 % 60), math.floor(time % 60))
end
require("lfs")
function os.exists(path)
  return CCFileUtils:sharedFileUtils():isFileExist(path)
end
function os.mkdir(path)
  if not os.exists(path) then
    return lfs.mkdir(path)
  end
  return true
end
function os.rmdir(path)
  print("os.rmdir:", path)
  if os.exists(path) then
    do
      local function _rmdir(path)
        local iter, dir_obj = lfs.dir(path)
        while true do
          local dir = iter(dir_obj)
          if dir == nil then
            break
          end
          if dir ~= "." and dir ~= ".." then
            local curDir = path .. dir
            local mode = lfs.attributes(curDir, "mode")
            if mode == "directory" then
              _rmdir(curDir .. "/")
            elseif mode == "file" then
              os.remove(curDir)
            end
          end
        end
        local succ, des = os.remove(path)
        if des then
          print(des)
        end
        return succ
      end
      _rmdir(path)
    end
  end
  return true
end
local DelFrequency = 20
function RollingNumberEffect(txtObj, sNumber, eNumber, dt, prefix, suffix)
  prefix = prefix or ""
  suffix = suffix or ""
  local times = checkint(dt * DelFrequency)
  if times <= 0 then
    txtObj:setText(string.format("%s%d%s", prefix, eNumber, suffix))
    return
  end
  txtObj:setText(string.format("%s%d%s", prefix, sNumber, suffix))
  local delNum = (eNumber - sNumber) / times
  local actList = {}
  local t = 1 / DelFrequency
  for i = 1, times do
    if i == times then
      actList[#actList + 1] = CCDelayTime:create(t)
      actList[#actList + 1] = CCCallFunc:create(function()
        txtObj:setText(string.format("%s%d%s", prefix, eNumber, suffix))
      end)
    else
      sNumber = sNumber + delNum
      do
        local temp = checkint(sNumber)
        actList[#actList + 1] = CCDelayTime:create(t)
        actList[#actList + 1] = CCCallFunc:create(function()
          txtObj:setText(string.format("%s%d%s", prefix, temp, suffix))
        end)
      end
    end
  end
  txtObj:runAction(transition.sequence(actList))
end
function getHMSWithSeconds(seconds)
  local h = math.floor(seconds / 3600)
  seconds = seconds - h * 3600
  local m = math.floor(seconds / 60)
  return h, m, seconds - m * 60
end
local DaysNormalMonth = {
  [1] = 31,
  [2] = nil,
  [3] = 31,
  [4] = 30,
  [5] = 31,
  [6] = 30,
  [7] = 31,
  [8] = 31,
  [9] = 30,
  [10] = 31,
  [11] = 30,
  [12] = 31
}
function getDaysWithMonth(month, year)
  if month == 2 then
    if year % 4 == 0 and year % 100 ~= 0 or year % 100 == 0 and year % 400 == 0 then
      return 29
    else
      return 28
    end
  else
    return DaysNormalMonth[month]
  end
end
LAYOUT_CLIPPING_STENCIL = 0
LAYOUT_CLIPPING_SCISSOR = 1
function setAllNodesClippingType(clipType)
  local p = display.getRunningScene()
  recursiveSetAllNodesClippingType(p, clipType)
  recursiveSetAllNodesClippingType(g_MostTopLayer, clipType)
end
function recursiveSetAllNodesClippingType(parentNode, clipType)
  if parentNode.m_UINode then
    parentNode = parentNode.m_UINode
  end
  if parentNode.setClippingType ~= nil then
    parentNode:setClippingType(clipType)
  end
  local children = parentNode:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      recursiveSetAllNodesClippingType(node, clipType)
    end
  end
end
function Value2Str(value, setNum)
  value = value or 0
  setNum = setNum or 0
  local temp10Num = 10 ^ setNum
  local fStr = "%." .. tostring(setNum) .. "f"
  return string.format(fStr, math.floor(value * temp10Num + 1.0E-8) / temp10Num)
end
function isNeedMapLoading()
  print("==>>isNeedMapLoading:")
  if device.platform == "ios" then
    local deviceName = SyNative.getDeviceName()
    print("deviceName:", deviceName)
    if deviceName == "x86_64" then
      return false
    end
    local model, v1, v2 = string.match(deviceName, "(%a+)(%d+),(%d+)")
    print("model, v1, v2-->:", model, v1, v2)
    if model ~= nil and v1 ~= nil and v2 ~= nil then
      v1 = tonumber(v1)
      v2 = tonumber(v2)
      if model == "iPod" then
        if v1 >= 5 then
          print("iPod5以上..")
          return false
        else
          return true
        end
      elseif model == "iPhone" then
        if v1 >= 5 then
          print("iPhone4S以上..")
          return false
        else
          return true
        end
      elseif model == "iPad" then
        if v1 >= 2 then
          print("iPad2以上..")
          return false
        else
          return true
        end
      end
    end
    local totalMem, _, _ = SyNative.getMemoryInfo()
    print("没有匹配到使用内存判断-->totalMem:", totalMem)
    if totalMem == nil or totalMem == 0 or totalMem > 300 then
      return false
    end
  elseif device.platform == "android" then
    local totalMem, _, _ = SyNative.getMemoryInfo()
    print("使用内存判断-->totalMem:", totalMem)
    if totalMem == nil or totalMem == 0 or totalMem > 300 then
      return false
    else
      return true
    end
  end
  return false
end
local __oldPixelFormat
function setDefaultAlphaPixelFormat(pixelFormat)
  if pixelFormat ~= nil then
    __oldPixelFormat = CCTexture2D:defaultAlphaPixelFormat()
    CCTexture2D:setDefaultAlphaPixelFormat(pixelFormat)
  end
end
function resetDefaultAlphaPixelFormat()
  if __oldPixelFormat ~= nil then
    CCTexture2D:setDefaultAlphaPixelFormat(__oldPixelFormat)
    __oldPixelFormat = nil
  end
end
function getSubNumberFromString(strIn)
  if type(strIn) ~= "string" then
    return strIn
  end
  local r = ""
  for i = 1, string.len(strIn) do
    local d = string.sub(strIn, i, i)
    if d >= "0" and d <= "9" then
      r = r .. d
    end
  end
  return tonumber(r)
end
function printLogTEST(...)
  printLog(...)
end
function printLogDebug(...)
  printLog(...)
end
function CheckStringIsLegal(text, enableChinese, replaceChar)
  if text == nil or type(text) ~= "string" then
    return text, true
  end
  if enableChinese == nil then
    enableChinese = true
  end
  local newLen = string.len(text)
  local i = 1
  local invalidList = {}
  replaceChar = replaceChar or ""
  while newLen >= i do
    local addStr = string.sub(text, i, i)
    local bt = addStr:byte()
    if bt < 128 then
      i = i + 1
    elseif bt >= 192 then
      local k = 1
      for j = i + 1, newLen do
        local tempStr = string.sub(text, j, j)
        local bt_temp = tempStr:byte()
        if bt_temp < 128 or bt_temp >= 192 then
          break
        else
          k = k + 1
        end
      end
      if not IsValideCharacter(text, i, k) then
        local invalidChar = string.sub(text, i, i + k - 1)
        invalidList[#invalidList + 1] = invalidChar
        print("过滤非法键盘字符:", invalidChar)
      elseif not enableChinese then
        local invalidChar = string.sub(text, i, i + k - 1)
        invalidList[#invalidList + 1] = invalidChar
        print("过滤中文字符:", invalidChar)
      end
      i = i + k
    end
  end
  local validFlag = true
  if #invalidList > 0 then
    for j = #invalidList, 1, -1 do
      local invalidChar = invalidList[j]
      text = string.gsub(text, invalidChar, replaceChar)
    end
    validFlag = false
  end
  return text, validFlag
end
function IsValideCharacter(txt, sIndex, cntBits)
  uniC = 0
  firstByte = string.sub(txt, sIndex, sIndex)
  firstByte = firstByte:byte()
  ptr = 0
  firstByte = ZZMathBit.andOp(firstByte, ZZMathBit.lShiftOp(1, 7 - cntBits) - 1)
  for i = sIndex + cntBits - 1, sIndex + 1, -1 do
    utfb = string.sub(txt, i, i)
    utfb = utfb:byte()
    local temp = ZZMathBit.andOp(utfb, 63)
    local temp2 = ZZMathBit.lShiftOp(temp, ptr)
    uniC = ZZMathBit.orOp(uniC, temp2)
    ptr = ptr + 6
  end
  uniC = ZZMathBit.orOp(uniC, ZZMathBit.lShiftOp(firstByte, ptr))
  print("=====>>>unicode:", uniC)
  if uniC >= 0 and uniC <= 255 and uniC ~= 169 then
    return true
  elseif uniC >= 19968 and uniC <= 40895 then
    return true
  elseif uniC >= 8192 and uniC <= 8303 and uniC ~= 8205 then
    return true
  elseif uniC >= 8352 and uniC <= 8399 then
    return true
  elseif uniC >= 12288 and uniC <= 12351 and uniC ~= 12336 and uniC ~= 12349 then
    return true
  elseif uniC >= 12352 and uniC <= 12447 or uniC >= 12448 and uniC <= 12543 then
    return true
  elseif uniC >= 65280 and uniC <= 65519 then
    return true
  elseif uniC == 9733 then
    return true
  else
    print("=======>>>不在范围内的unicode", uniC)
    return false
  end
end
function checkStringIsLegalForSafetylock(text)
  local textLen = string.len(text)
  if textLen < 6 or textLen > 8 then
    return false
  end
  for i = 1, textLen do
    local c = string.sub(text, i, i)
    local asciiValue = string.byte(c)
    if asciiValue < 48 or asciiValue > 57 then
      return false
    end
  end
  return true
end
