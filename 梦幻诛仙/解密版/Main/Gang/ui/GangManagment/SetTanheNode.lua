local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local SetTanheNode = Lplus.Extend(TabNode, "SetTanheNode")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local def = SetTanheNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:FillTips()
end
def.method().FillTips = function(self)
  local Label_Tips = self.m_node:FindDirect("Label_Tips"):GetComponent("UILabel")
  local offline = GangUtility.GetGangConsts("TANHE_OFFLINE_D")
  local wait = GangUtility.GetGangConsts("TANHE_WAIT_TIME_D")
  Label_Tips:set_text(string.format(textRes.Gang[80], offline, wait, wait, wait))
  local Group_Delate = self.m_node:FindDirect("Group_Delate")
  local Group_Cancel = self.m_node:FindDirect("Group_Cancel")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if gangInfo.tanHeEndTime > 0 then
    Group_Delate:SetActive(false)
    Group_Cancel:SetActive(true)
    self:FillTanheInfo(gangInfo.tanHeRoleId, gangInfo.tanHeEndTime)
  else
    Group_Delate:SetActive(true)
    Group_Cancel:SetActive(false)
    self:FillNotTanheInfo()
  end
end
def.method("userdata", "number").FillTanheInfo = function(self, tanHeRoleId, tanHeEndTime)
  local Group_Cancel = self.m_node:FindDirect("Group_Cancel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local name = ""
  local time = GangUtility.GetGangConsts("TANHE_WAIT_TIME_D") * 24 * 60 * 60
  local remain = tanHeEndTime - GetServerTime()
  local rate = remain / time
  local timeStr = GangUtility.GetTimeStr(remain)
  Group_Cancel:FindDirect("Img_BgSlider"):GetComponent("UISlider"):set_sliderValue(rate)
  Group_Cancel:FindDirect("Img_BgSlider/Label_TimeNum"):GetComponent("UILabel"):set_text(timeStr)
  local Btn_Cancel = Group_Cancel:FindDirect("Btn_Cancel"):GetComponent("UIButton")
  if heroProp.id ~= tanHeRoleId then
    Btn_Cancel:set_isEnabled(false)
  else
    Btn_Cancel:set_isEnabled(true)
  end
  if tanHeRoleId ~= nil then
    local memberInfo = GangData.Instance():GetMemberInfoByRoleId(tanHeRoleId)
    if memberInfo ~= nil then
      name = memberInfo.name
    end
  end
  Group_Cancel:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(name)
end
def.method().FillNotTanheInfo = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local Group_Delate = self.m_node:FindDirect("Group_Delate")
  local Btn_Delate = Group_Delate:FindDirect("Btn_Delate"):GetComponent("UIButton")
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if memberInfo == nil then
    return
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  if tbl.isCanTanHe then
    Btn_Delate:set_isEnabled(true)
  else
    Btn_Delate:set_isEnabled(false)
  end
end
def.method().UpdateInfo = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  if gangInfo.tanHeEndTime > 0 then
    self:FillTanheInfo(gangInfo.tanHeRoleId, gangInfo.tanHeEndTime)
  end
end
def.override().OnHide = function(self)
end
def.method().OnTanheClick = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CTanHeReq").new())
end
def.method().OnCanelTanheClick = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCancelTanHeReq").new())
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Delate" == id then
    self:OnTanheClick()
  elseif "Btn_Cancel" == id then
    self:OnCanelTanheClick()
  end
end
SetTanheNode.Commit()
return SetTanheNode
