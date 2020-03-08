local Lplus = require("Lplus")
local SensitiveWordsFilterMgr = Lplus.Class("SensitiveWordsFilterMgr")
local def = SensitiveWordsFilterMgr.define
local extendWords = {
  {key = " ", len = 1},
  {key = "_", len = 1},
  {key = "-", len = 1},
  {key = "|", len = 1}
}
def.static().Init = function()
  local dictList = {
    {
      dictName = "Default",
      dictFileList = {
        "data/sensitive_words/sensitive_words.txt"
      }
    },
    {
      dictName = "Name",
      dictFileList = {
        "data/sensitive_words/disabled_names.txt"
      }
    }
  }
  for i, dictInfo in ipairs(dictList) do
    for i, path in ipairs(dictInfo.dictFileList) do
      SensitiveWordsFilter.LoadDictionayFile(path, dictInfo.dictName)
      print(string.format("Load sensitive words dict: [%s](\"%s\")", dictInfo.dictName, path))
    end
  end
  SensitiveWordsFilterMgr.SensitiveWordFilterExtend()
end
def.static().SensitiveWordFilterExtend = function()
  _G.SensitiveWordsTool = _G.SensitiveWordsFilter
  _G.SensitiveWordsFilter = {}
  SensitiveWordsFilter.LoadDictionayFile = SensitiveWordsTool.LoadDictionayFile
  SensitiveWordsFilter.AddDictionaryWord = SensitiveWordsTool.AddDictionaryWord
  function SensitiveWordsFilter.ContainsSensitiveWord(...)
    if _G.not_filter_sensitive_words then
      return false
    end
    local arg = {}
    local i = 1
    while true do
      local param = select(i, ...)
      if param then
        table.insert(arg, param)
        i = i + 1
      else
        break
      end
    end
    if #arg < 1 then
      warn("args is too little............", #arg)
      return false
    end
    if #arg > 2 then
      warn("ContainsSensitiveWord function arg number is too many..... ", #arg)
      return true
    end
    local content = arg[1]
    local dicName = arg[2]
    if content == nil then
      return false
    end
    local isContain = SensitiveWordsTool.ContainsSensitiveWord(content, dicName)
    if isContain then
      return true
    end
    for k, v in pairs(extendWords) do
      local i = 0
      local j = 0
      local filter = {}
      if string.find(content, v.key) then
        local preIndex = j + 1
        while string.find(content, v.key, j + 1) do
          i, j = string.find(content, v.key, j + 1)
          if preIndex == i then
            table.insert(filter, "")
          else
            table.insert(filter, content.sub(content, preIndex, i - 1))
          end
          preIndex = j + 1
        end
        local lastStr = string.sub(content, j + 1, -1)
        if lastStr then
          table.insert(filter, lastStr)
        end
        local newWord = ""
        for _, filterContent in pairs(filter) do
          newWord = newWord .. filterContent
        end
        isContain = SensitiveWordsTool.ContainsSensitiveWord(newWord, dicName)
        if isContain then
          break
        end
      end
    end
    return isContain
  end
  function SensitiveWordsFilter.FilterContent(content, replace)
    if _G.not_filter_sensitive_words then
      return content
    end
    if content == nil or replace == nil then
      return content
    end
    content = SensitiveWordsTool.FilterContent(content, replace)
    if not SensitiveWordsFilter.ContainsSensitiveWord(content) then
      return content
    end
    local originContent = string.sub(content, 1, -1)
    for k, v in pairs(extendWords) do
      local i = 0
      local j = 0
      local filter = {}
      if string.find(content, v.key) then
        local preIndex = j + 1
        while string.find(content, v.key, j + 1) do
          i, j = string.find(content, v.key, j + 1)
          if preIndex == i then
            table.insert(filter, "")
          else
            table.insert(filter, string.sub(content, preIndex, i - 1))
          end
          preIndex = j + 1
        end
        local lastStr = string.sub(content, j + 1, -1)
        if lastStr then
          table.insert(filter, lastStr)
        end
        local newWord = ""
        for _, filterContet in pairs(filter) do
          newWord = newWord .. filterContet
        end
        content = SensitiveWordsTool.FilterContent(newWord, replace)
      end
    end
    return content == nil and originContent or content
  end
end
return SensitiveWordsFilterMgr.Commit()
