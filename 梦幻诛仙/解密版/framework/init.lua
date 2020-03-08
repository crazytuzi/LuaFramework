if type(DEBUG) ~= "number" then
  DEBUG = 0
end
if type(DEBUG_FPS) ~= "boolean" then
  DEBUG_FPS = false
end
if type(DEBUG_MEM) ~= "boolean" then
  DEBUG_MEM = false
end
if type(LOAD_SHORTCODES_API) ~= "boolean" then
  LOAD_SHORTCODES_API = true
end
if type(LOAD_DEPRECATED_API) ~= "boolean" then
  LOAD_DEPRECATED_API = false
end
if type(DISABLE_DEPRECATED_WARNING) ~= "boolean" then
  DISABLE_DEPRECATED_WARNING = false
end
if type(USE_DEPRECATED_EVENT_ARGUMENTS) ~= "boolean" then
  USE_DEPRECATED_EVENT_ARGUMENTS = false
end
local CURRENT_MODULE_NAME = (...)
cc = cc or {}
cc.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)
io.stdout:setvbuf("no")
require(cc.PACKAGE_NAME .. ".functions")
require(cc.PACKAGE_NAME .. ".debug")
require(cc.PACKAGE_NAME .. ".cc.init")
