local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local SetXueTuLevelNode = Lplus.Extend(TabNode, "SetXueTuLevelNode")
local GangData = require("Main.Gang.data.GangData")
local GangUtility = require("Main.Gang.GangUtility")
local def = SetXueTuLevelNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:FillDefaultXuetuLevel()
end
def.method().FillDefaultXuetuLevel = function(self)
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local Img_Num = self.m_node:FindDirect("Img_Num")
  local input = Img_Num:FindDirect("Label_Num"):GetComponent("UILabel")
  input:set_text(gangInfo.xueTuMaxLevel)
end
def.override().OnHide = function(self)
end
def.method("userdata").FocusOnInput = function(self, clickobj)
  local input = clickobj:GetComponent("UIInput")
  input:set_isSelected(true)
end
def.method().OnSetXuetuLevelClick = function(self)
  local Img_Num = self.m_node:FindDirect("Img_Num")
  local input = Img_Num:FindDirect("Label_Num"):GetComponent("UIInput")
  local val = input:get_value()
  local default = Img_Num:FindDirect("Label_Num"):GetComponent("UILabel"):get_text()
  if val == "" and default == "" then
    Toast(textRes.Gang[77])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if memberInfo == nil then
    return
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  if tbl.isCanMgeApplyList then
    local curServerLv = require("Main.Server.Interface").GetServerLevelInfo().level
    local settingMax = GangUtility.GetGangConsts("SETTING_XUETU_MAX_OFFSET_LV")
    local settingMin = GangUtility.GetGangConsts("SETTING_XUETU_MIN_OFFSET_LV")
    local xueTuMax = GangUtility.GetGangConsts("XUETU_MAX_LV")
    local maxLevel = curServerLv - settingMax
    local minLevel = xueTuMax - settingMin
    local inputLv = 0
    if val ~= "" then
      inputLv = tonumber(val)
    else
      inputLv = tonumber(default)
    end
    if maxLevel < inputLv then
      Toast(textRes.Gang[104])
    elseif minLevel > inputLv then
      Toast(textRes.Gang[105])
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSetXueTuMaxLevel").new(inputLv))
    end
  else
    Toast(textRes.Gang[78])
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Label_Num" == id then
    self:FocusOnInput(clickobj)
  elseif "Btn_Set" == id then
    self:OnSetXuetuLevelClick()
  end
end
SetXueTuLevelNode.Commit()
return SetXueTuLevelNode
