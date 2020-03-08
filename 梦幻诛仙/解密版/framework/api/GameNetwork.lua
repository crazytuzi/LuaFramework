local GameNetwork = {}
PRINT_DEPRECATED("module api.GameNetwork is deprecated, please use cc.sdk.social")
local provider = __FRAMEWORK_GLOBALS__["api.GameNetwork"]
function GameNetwork.init(providerName, params)
  if provider then
    printError("[framework.api.GameNetwork] ERR, init() GameNetwork already init")
    return false
  end
  if type(params) ~= "table" then
    printError("[framework.api.GameNetwork] ERR, init() invalid params")
    return false
  end
  providerName = string.upper(providerName)
  if providerName == "GAMECENTER" then
    provider = require("framework.api.gamenetwork.GameCenter")
  elseif providerName == "OPENFEINT" then
    provider = require("framework.api.gamenetwork.OpenFeint")
  elseif providerName == "CHINAMOBILE" then
    provider = require("framework.api.gamenetwork.ChinaMobile")
  else
    printError("[framework.api.GameNetwork] ERR, init() invalid providerName: %s", providerName)
    return false
  end
  provider.init(params)
  __FRAMEWORK_GLOBALS__["api.GameNetwork"] = provider
end
function GameNetwork.request(command, ...)
  if not provider then
    printError("[framework.api.GameNetwork] ERR, request() GameNetwork not init")
    return
  end
  return provider.request(command, {
    ...
  })
end
function GameNetwork.show(command, ...)
  if not provider then
    printError("[framework.api.GameNetwork] ERR, request() GameNetwork not init")
    return
  end
  provider.show(command, {
    ...
  })
end
function GameNetwork.exit()
  if not provider then
    printError("[framework.api.GameNetwork] ERR, request() GameNetwork not init")
    return
  end
  provider.exit()
end
return GameNetwork
