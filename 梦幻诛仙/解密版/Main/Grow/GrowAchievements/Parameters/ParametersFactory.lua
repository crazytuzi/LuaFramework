local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ParametersFactory = Lplus.Class(CUR_CLASS_NAME)
local Parameter = import(".Parameter")
local ParameterType = require("consts.mzm.gsp.grow.confbean.ParameterType")
local def = ParametersFactory.define
local CreateAndInit = function(class, type)
  local obj = class()
  obj:Init(type)
  return obj
end
def.static("number", "=>", Parameter).CreateParameter = function(parameterType)
  if parameterType == ParameterType.ALABOSHUZI then
    local ArabianDigital = import(".ArabianDigital", CUR_CLASS_NAME)
    return CreateAndInit(ArabianDigital, parameterType)
  elseif parameterType == ParameterType.HANZI then
    local ChineseNumber = import(".ChineseNumber", CUR_CLASS_NAME)
    return CreateAndInit(ChineseNumber, parameterType)
  elseif parameterType == ParameterType.TASK_NAME then
    local TaskName = import(".TaskName", CUR_CLASS_NAME)
    return CreateAndInit(TaskName, parameterType)
  elseif parameterType == ParameterType.NULL then
    local Empty = import(".Empty", CUR_CLASS_NAME)
    return CreateAndInit(Empty, parameterType)
  else
    return CreateAndInit(Parameter, parameterType)
  end
end
return ParametersFactory.Commit()
