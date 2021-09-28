local sshenmishopinfo = require "protocoldef.knight.gsp.shenmishop.sshenmishopinfo"
function sshenmishopinfo:process()
  LogInfo("enter sanswerroleteamstate process")
  local dlg = require "ui.shop.shopsecretdlg"
  if dlg.getInstanceNotCreate() then
    dlg.getInstanceNotCreate():process(self.freetimes,self.maxfreetimes,self.leftfreetime,self.leftduihuanquan,self.leftshopupdatetime,self.items)
  end
end
