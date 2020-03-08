local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgJoinMenpai = Lplus.Extend(ECPanelBase, "DlgJoinMenpai")
local GUIUtils = require("GUI.GUIUtils")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = DlgJoinMenpai.define
local instance
def.field("number").selectedMenpai = 0
def.field("userdata").childId = nil
def.field("table").menpaiMap = nil
def.field("table").menpaiList = nil
def.static("=>", DlgJoinMenpai).Instance = function()
  if instance == nil then
    instance = DlgJoinMenpai()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, childId)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_JOIN_MENPAI, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:ShowAllMenpai()
  self:OnSelectMenpai(1)
end
def.override().OnDestroy = function(self)
  self.selectedMenpai = 0
  self.menpaiMap = nil
  self.menpaiList = nil
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Camp_") then
    local idx = tonumber(string.sub(id, #"Btn_Camp_" + 1, -1))
    self:OnSelectMenpai(idx)
  elseif string.find(id, "Img_ItemSkill") then
    local idx = tonumber(string.sub(id, #"Img_ItemSkill" + 1, -1))
    self:ShowMenpaiSkillTip(idx)
  elseif id == "Btn_Confirm" then
    if self.selectedMenpai > 0 then
      local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
      if 0 >= child_data:GetMenpai() then
        self:JoinMenpai()
        self:DestroyPanel()
        return
      end
      if child_data:GetMenpai() == self.selectedMenpai then
        Toast(textRes.Children[3071])
        return
      end
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Children[3072], constant.CChildrenConsts.child_change_occcupation_cost), function(id, tag)
        if id == 1 then
          self:JoinMenpai()
          self:DestroyPanel()
        end
      end, nil)
    else
      Toast(textRes.Children[3002])
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method().ShowAllMenpai = function(self)
  local panel = self.m_panel:FindDirect("Img_Bg0/ScrollView_Camp/Group_list")
  local uilist = panel:GetComponent("UIList")
  if self.menpaiMap == nil then
    self.menpaiMap = require("Main.Children.ChildrenUtils").GetAllOpenedOccupationSkill()
    self.menpaiList = {}
    self.menpaiList.needInit = true
  end
  local count = table.nums(self.menpaiMap)
  uilist.itemCount = count
  uilist:Resize()
  local menpai
  for i = 1, count do
    local btn = panel:FindDirect("Btn_Camp_" .. i)
    if btn then
      local sp = btn:GetComponent("UISprite")
      menpai = next(self.menpaiMap, menpai)
      if self.menpaiList.needInit then
        table.insert(self.menpaiList, menpai)
      end
      if menpai == self.selectedMenpai then
        sp.spriteName = string.format("%d-3", menpai)
      else
        sp.spriteName = string.format("%d-4", menpai)
      end
    end
  end
  self.menpaiList.needInit = nil
end
def.method("number").OnSelectMenpai = function(self, idx)
  local menpai = self.menpaiList and self.menpaiList[idx]
  if menpai == self.selectedMenpai then
    return
  end
  self.selectedMenpai = menpai
  self:ShowAllMenpai()
  local grid = self.m_panel:FindDirect("Img_Bg0/Group_Skill/Scroll View_FS_Skill/Grid_Skill")
  local uigrid = grid:GetComponent("UIGrid")
  local count = uigrid:GetChildListCount()
  local SkillUtility = require("Main.Skill.SkillUtility")
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  local childEquipLv = child_data:GetEquipsMinLevel()
  local menpaiSkillMap = require("Main.Children.ChildrenUtils").GetMenpaiSkillMap(menpai)
  for i = 1, count do
    local skillPanel = grid:FindDirect("Img_ItemSkill0" .. i)
    local skillIds = self.menpaiMap[menpai]
    local skillId = skillIds and skillIds[i]
    local ui_Texture = skillPanel:FindDirect("Icon_ItemSkillIcon"):GetComponent("UITexture")
    if skillId then
      local skillInfo = SkillUtility.GetSkillCfg(skillId)
      GUIUtils.FillIcon(ui_Texture, skillInfo.iconId)
      local skillCfgInfo = menpaiSkillMap[skillId]
      if skillCfgInfo then
        if childEquipLv >= skillCfgInfo.needEquipmentLevel then
          GUIUtils.SetTextureEffect(ui_Texture, GUIUtils.Effect.Normal)
        else
          GUIUtils.SetTextureEffect(ui_Texture, GUIUtils.Effect.Gray)
        end
      end
    else
      GUIUtils.FillIcon(ui_Texture, 0)
    end
  end
end
def.method("number").ShowMenpaiSkillTip = function(self, index)
  if self.menpaiMap == nil then
    return
  end
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local grid = self.m_panel:FindDirect("Img_Bg0/Group_Skill/Scroll View_FS_Skill/Grid_Skill")
  local sourceObj = grid:FindDirect(string.format("Img_ItemSkill%02d", index))
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  local skillIds = self.menpaiMap[self.selectedMenpai]
  local skillId = skillIds and skillIds[index]
  if skillId then
    require("Main.Skill.SkillTipMgr").Instance():ShowChildSkillTip(skillId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, self.selectedMenpai, self.childId)
  end
end
def.method().JoinMenpai = function(self)
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(self.childId)
  if child_data and child_data:GetMenpai() > 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CChildrenChangeOccupationReq").new(self.childId, self.selectedMenpai))
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Children.CChildrenSelectOccupationReq").new(self.childId, self.selectedMenpai))
  end
end
DlgJoinMenpai.Commit()
return DlgJoinMenpai
