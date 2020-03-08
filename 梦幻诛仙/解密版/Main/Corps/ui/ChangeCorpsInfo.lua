local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChangeCorpsInfo = Lplus.Extend(ECPanelBase, "ChangeCorpsInfo")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = ChangeCorpsInfo.define
def.field("string").name = ""
def.field("string").declare = ""
def.field("number").badgeId = 0
def.field("boolean").isLeader = false
def.static("string", "string", "number", "boolean").ShowChange = function(name, declare, bagde, isLeader)
  warn("ShowChange", isLeader)
  local dlg = ChangeCorpsInfo()
  dlg.name = name
  dlg.declare = declare
  dlg.badgeId = bagde
  dlg.isLeader = isLeader
  dlg:CreatePanel(RESPATH.PREFAB_CHANGE_CORPS, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsInfoChange, ChangeCorpsInfo.OnInfoChange, self)
  self:UpdateName()
  self:UpdateDeclare()
  self:UpdateBadge()
  if not self.isLeader then
    self:HideButton()
  end
end
def.method("table").OnInfoChange = function(self, param)
  local data = require("Main.Corps.CorpsModule").Instance():GetData()
  if data then
    if self.name ~= data:GetName() then
      self.name = data:GetName()
      self:UpdateName()
    end
    if self.declare ~= data:GetDeclaration() then
      self.declare = data:GetDeclaration()
      self:UpdateDeclare()
    end
    if self.badgeId ~= data:GetBadgeId() then
      self.badgeId = data:GetBadgeId()
      self:UpdateBadge()
    end
  end
end
def.method().HideButton = function(self)
  local btn1 = self.m_panel:FindDirect("Img_Bg/Group_Change/Btn_Change_01")
  local btn2 = self.m_panel:FindDirect("Img_Bg/Group_Change/Btn_Change_02")
  local btn3 = self.m_panel:FindDirect("Img_Bg/Group_Change/Btn_Change_03")
  btn1:SetActive(false)
  btn2:SetActive(false)
  btn3:SetActive(false)
end
def.method().UpdateName = function(self)
  local nameLbl = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameContent")
  nameLbl:GetComponent("UILabel"):set_text(self.name)
end
def.method().UpdateDeclare = function(self)
  local declareLbl = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent/Label_TargetContent")
  declareLbl:GetComponent("UILabel"):set_text(self.declare)
end
def.method().UpdateBadge = function(self)
  local cfg = CorpsUtils.GetCorpsBadgeCfg(self.badgeId)
  local uiTexture = self.m_panel:FindDirect("Img_Bg/Group_Sign/Img_Sign/Icon_Sign"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, cfg.iconId)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CORPS, gmodule.notifyId.Corps.CorpsInfoChange, ChangeCorpsInfo.OnInfoChange)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Change_01" then
    local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
    CommonRenamePanel:ShowPanel2(textRes.Corps[55], false, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH, function(name, tag)
      if CorpsUtils.IsNameValid(name) then
        require("Main.Corps.CorpsModule").Instance():ChangeCorpsName(name)
        return false
      else
        return true
      end
    end, self)
  elseif id == "Btn_Change_02" then
    local ChangeTextDlg = require("Main.Corps.ui.ChangeTextDlg")
    ChangeTextDlg.ShowChangeTextDlg(textRes.Corps[56], "", textRes.Corps[73], constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH, function(content)
      if CorpsUtils.IsDeclareValid(content) then
        require("Main.Corps.CorpsModule").Instance():ChangeCorpsDeclare(content)
        return true
      else
        return false
      end
    end)
  elseif id == "Btn_Change_03" then
    do
      local allBadge = require("Main.Corps.CorpsModule").Instance():GetAllCorpsBadge()
      local icons = {}
      local grays = {}
      for k, v in ipairs(allBadge) do
        table.insert(icons, v.iconId)
      end
      local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(self.badgeId)
      grays[badgeCfg.iconId] = true
      require("Main.Corps.ui.SelectIconDlg").ShowSelectIcon(icons, grays, function(index)
        if allBadge[index] then
          local badgeId = allBadge[index].id
          if badgeId ~= self.badgeId then
            require("Main.Corps.CorpsModule").Instance():ChangeCorpsBadge(badgeId)
          else
            Toast(textRes.Corps[74])
          end
        end
      end)
    end
  end
end
return ChangeCorpsInfo.Commit()
