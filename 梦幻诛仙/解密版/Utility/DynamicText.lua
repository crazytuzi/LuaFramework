local Lplus = require("Lplus")
local lpeg = require("lpeg")
local GameInfo = require("Utility.GameInfo")
local TableProxy = require("Utility.TableProxy")
local print = print
local warn = warn or print
local error = error
local loadstring = loadstring
local setfenv = setfenv
local pcall = pcall
local tableconcat = table.concat
local tostring = tostring
local pairs = pairs
local debug = debug
local type = type
local select = select
local _G = _G
local function warnFail(reason, errLevel)
  warn(debug.traceback(reason, errLevel + 1))
end
local DynamicText = Lplus.Class("DynamicText")
do
  local def = DynamicText.define
  local emptyTextFunc = function()
    return ""
  end
  def.static("string", "=>", "function").compileWithGameInfo = function(dynText)
    return DynamicText.compile(dynText, GameInfo.getRawInfo())
  end
  def.static("string", "table", "=>", "function").compile = function(dynText, env)
    local compiledText = DynamicText.parseText(dynText)
    if compiledText == nil then
      return emptyTextFunc
    end
    return DynamicText.compile_parsedText(compiledText, env)
  end
  local dynPatt
  do
    local scriptOpen = lpeg.P("<%")
    local scriptClose = lpeg.P("%>")
    local normalText = (1 - scriptOpen) ^ 1
    local normalPatt = normalText / function(str)
      return ("write %q\n"):format(str)
    end
    local innerText = (1 - scriptClose) ^ 0
    local express = innerText / function(str)
      return ("write(%s)\n"):format(str)
    end
    local scriptExpression = lpeg.P("=") / "" * express
    local fragment = innerText / function(str)
      return ("%s\n"):format(str)
    end
    local scriptFragment = fragment
    local scriptInner = scriptExpression + scriptFragment
    local scriptCloseChecker = lpeg.Cmt("", function(s, pos)
      error({
        err = "'%>' expected at end of string"
      })
    end)
    local scriptPatt = scriptOpen / "" * scriptInner * (scriptClose / "" + scriptCloseChecker)
    dynPatt = lpeg.Cs((normalPatt + scriptPatt) ^ 0)
  end
  def.static("string", "=>", "varlist").parseText = function(dynText)
    local bRet, ret = pcall(lpeg.match, dynPatt, dynText)
    if not bRet then
      if type(ret) == "table" then
        warnFail("Failed to parse dynamic text: " .. ret.err .. [[

original text:
]] .. dynText, 1)
      end
      return ""
    end
    local parsedText = ret
    if parsedText == nil then
      warn([[
Failed to parse dynamic text
original text:
]] .. dynText)
      return ""
    end
    return parsedText
  end
  def.static("string", "table", "=>", "function").compile_parsedText = function(parsedText, env)
    local f, err = loadstring("local write = ...\n" .. parsedText)
    if f == nil then
      warnFail("Failed to compile dynamic text: " .. tostring(err) .. [[

parsed text:
]] .. parsedText, 1)
      return emptyTextFunc
    end
    local textSink
    local function write(...)
      for i = 1, select("#", ...) do
        textSink[#textSink + 1] = tostring(select(i, ...))
      end
    end
    local finalEnv = TableProxy.createReadonlyTable(setmetatable({write = write}, {__index = env}))
    local workerFunc = setfenv(f, finalEnv)
    return function()
      textSink = {}
      local bRet, err = pcall(workerFunc, write)
      if not bRet then
        warnFail("Failed to generate dynamic text: " .. tostring(err) .. [[

parsed text:
]] .. parsedText, 1)
        return ""
      end
      local result = tableconcat(textSink)
      textSink = nil
      return result
    end
  end
end
return DynamicText.Commit()
