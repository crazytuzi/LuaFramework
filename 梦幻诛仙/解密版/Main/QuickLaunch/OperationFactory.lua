local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationsFactory = Lplus.Class(CUR_CLASS_NAME)
local Operation = import("Main.Grow.Operations.Operation")
local def = OperationsFactory.define
local ShortcutMenuKeys = _G.ShortcutMenuKeys
local operationNames = {
  [ShortcutMenuKeys.message] = "Main.Grow.Operations.OpenFriendList",
  [ShortcutMenuKeys.jiangli] = "Main.Grow.Operations.OpenAwardPanel",
  [ShortcutMenuKeys.zhouli] = "Main.Grow.Operations.OpenActivityWeeklyPanel",
  [ShortcutMenuKeys.radio] = "Main.Grow.Operations.EnterApolloRoom"
}
local CreateAndInit = function(class, id)
  local obj = class()
  return obj
end
local function GetOperationClass(shortcutMenuKey)
  local operationName = operationNames[shortcutMenuKey]
  if operationName then
    return import(operationName, CUR_CLASS_NAME)
  else
    return Operation
  end
end
def.static("string", "=>", Operation).CreateOperation = function(shortcutMenuKey)
  local OperationClass = GetOperationClass(shortcutMenuKey)
  return CreateAndInit(OperationClass)
end
return OperationsFactory.Commit()
