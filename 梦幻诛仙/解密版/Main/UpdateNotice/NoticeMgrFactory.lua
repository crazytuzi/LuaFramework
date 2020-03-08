local MODULE_NAME = (...)
local Lplus = require("Lplus")
local NoticeMgrFactory = Lplus.Class(MODULE_NAME)
local UpdateNoticeMgr = require("Main.UpdateNotice.UpdateNoticeMgr")
local def = NoticeMgrFactory.define
def.static("=>", UpdateNoticeMgr).GetCurNoticeMgr = function()
  if _G.use_idip_notice then
    return require("Main.UpdateNotice.IDIPNoticeMgr").Instance()
  elseif ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    return require("Main.UpdateNotice.ECMSDKNoticeMgr").Instance()
  else
    return require("Main.UpdateNotice.ECDefaultNoticeMgr").Instance()
  end
end
return NoticeMgrFactory.Commit()
