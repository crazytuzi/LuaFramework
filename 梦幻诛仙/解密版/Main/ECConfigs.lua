local EntryPointConfig = require("EntryPointConfig")
local LuaCheckingLevel = EntryPointConfig.LuaCheckingLevel
package.loaded.Lplus_config = {
  reflection = false,
  declare_checking = LuaCheckingLevel >= 1,
  accessing_checking = LuaCheckingLevel >= 2,
  calling_checking = LuaCheckingLevel >= 2,
  reload = false
}
