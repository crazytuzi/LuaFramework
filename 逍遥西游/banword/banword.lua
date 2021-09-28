local LegalWordList = {
  ["破日枪"] = "破哇枪",
  ["叫花鸡"] = "叫花哇",
  ["叫化鸡"] = "叫化哇",
  ["飞燕回翔"] = "溅哇",
  ["黄色强化符"] = "哇色强化符",
  ["甘草"] = "甘哇",
  ["鸡肉"] = "哇肉",
  ["鸡腿"] = "哇腿",
  ["分裂攻击"] = "分哇攻击",
  ["以牙还牙"] = "借哇哇人",
  ["逐日战靴"] = "逐哇战靴",
  ["草药"] = "哇药",
  ["乌草"] = "乌哇",
  ["鱼卵"] = "鱼哇",
  ["一袋肉干"] = "一袋肉哇",
  ["海魂草"] = "海魂哇",
  ["分裂符"] = "分哇符",
  ["玄阴草"] = "玄阴哇",
  ["蛇舌草"] = "蛇舌哇",
  ["除奸"] = "除哇",
  ["锄奸"] = "锄哇",
  ["阿拉伯"] = "阿哇伯",
  ["人民币"] = "人哇币",
  ["鸡腿"] = "哇腿",
  ["干嘛"] = "哇嘛",
  ["干什么"] = "哇什么",
  ["干啥"] = "哇啥",
  ["男人"] = "男哇",
  ["女人"] = "男哇",
  ["大力"] = "哇力",
  ["稻草"] = "稻哇"
}
local getUtfString = function(input)
  local len = string.len(input)
  local left = len
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  local result = {}
  while left > 0 do
    local tmp = string.byte(input, -left)
    local i = 6
    local s = -left
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    result[#result + 1] = string.sub(input, s, -(left + 1))
  end
  return result
end
local DFAFilter = class("DFAFilter")
function DFAFilter:ctor()
  self.keyword_chains = {}
  self.delimit = "x00"
end
function DFAFilter:add(keyword)
  local chars = getUtfString(string.lower(keyword))
  local level = self.keyword_chains
  local len_c = #chars
  local n = -1
  for i = 1, len_c do
    n = i
    local c = chars[i]
    if level[c] ~= nil then
      level = level[c]
    else
      for j = i, len_c do
        local cc = chars[j]
        if level[cc] == nil then
          level[cc] = {}
        end
        level = level[cc]
      end
      level[self.delimit] = 0
      break
    end
  end
  if n == len_c then
    level[self.delimit] = 0
  end
end
function DFAFilter:parse()
  for _, keyword in pairs(data_Keywords) do
    self:add(keyword)
  end
end
function DFAFilter:filter(oriMessage, repl)
  if repl == nil then
    repl = "*"
  end
  local tmpMessage = oriMessage
  for legalword, tmpword in pairs(LegalWordList) do
    tmpMessage = string.gsub(tmpMessage, legalword, tmpword)
  end
  local message = getUtfString(string.lower(tmpMessage))
  oriMessage = getUtfString(oriMessage)
  local start = 1
  local len_m = #message
  local result = ""
  while start <= len_m do
    local level = self.keyword_chains
    local step_ins = 0
    local matchFlag = false
    for i = start, len_m do
      local char = message[i]
      if type(level) == "table" and level[char] ~= nil then
        step_ins = step_ins + 1
        if level[char][self.delimit] == nil then
          level = level[char]
        else
          matchFlag = true
          level = level[char]
        end
      else
        break
      end
    end
    if matchFlag then
      result = result .. string.rep(repl, step_ins)
      start = start + step_ins
    else
      result = result .. oriMessage[start]
      start = start + 1
    end
  end
  return result
end
function DFAFilter:check(message)
  for legalword, tmpword in pairs(LegalWordList) do
    message = string.gsub(message, legalword, tmpword)
  end
  message = getUtfString(string.lower(message))
  local start = 1
  local len_m = #message
  while start <= len_m do
    local level = self.keyword_chains
    for i = start, len_m do
      local char = message[i]
      if level[char] ~= nil then
        if level[char][self.delimit] == nil then
          level = level[char]
        else
          local filterStr = ""
          for k = start, i do
            filterStr = filterStr .. message[k]
          end
          return false, filterStr
        end
      else
        break
      end
    end
    start = start + 1
  end
  return true, ""
end
local g_DFAFilter = DFAFilter.new()
g_DFAFilter:parse()
function filterChatText_DFAFilter(text)
  if g_DFAFilter == nil then
    return text
  end
  return g_DFAFilter:filter(text, "*")
end
function checkText_DFAFilter(text)
  if g_DFAFilter == nil then
    return true
  end
  return g_DFAFilter:check(text)
end
