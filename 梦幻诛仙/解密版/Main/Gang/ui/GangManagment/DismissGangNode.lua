local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local DismissGangNode = Lplus.Extend(TabNode, "DismissGangNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local def = DismissGangNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
end
def.override().OnHide = function(self)
end
def.static("number", "table").QuitGangCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGangDismissReq").new())
  end
end
def.method().OnDismissGangClick = function(self)
  local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  local memberList = GangData.Instance():GetMemberList()
  if memberInfo == nil then
    return
  end
  if memberInfo.duty ~= bangzhuId then
    Toast(textRes.Gang[145])
  elseif #memberList > 1 then
    Toast(textRes.Gang[143])
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[141], DismissGangNode.QuitGangCallback, tag)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Dismiss" == id then
    self:OnDismissGangClick()
  end
end
DismissGangNode.Commit()
return DismissGangNode
