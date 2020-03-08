local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CreateCorpsDlg = Lplus.Extend(ECPanelBase, "CreateCorpsDlg")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = CreateCorpsDlg.define
local instance
def.static("=>", CreateCorpsDlg).Instance = function()
  if instance == nil then
    instance = CreateCorpsDlg()
  end
  return instance
end
def.field("number").badgeId = 0
def.field("userdata").nameInput = nil
def.field("userdata").declareInput = nil
def.field("userdata").nameCountLabel = nil
def.field("userdata").declareCountLabel = nil
def.static().ShowCreate = function()
  local dlg = CreateCorpsDlg.Instance()
  dlg:CreatePanel(RESPATH.PREFAB_CREATE_CORPS, 1)
  dlg:SetModal(true)
end
def.static().CloseCreate = function()
  local dlg = CreateCorpsDlg.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  self.nameInput = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameContent"):GetComponent("UIInput")
  self.nameCountLabel = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent/Label_NameCount"):GetComponent("UILabel")
  self.declareInput = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent/Label_TargetContent"):GetComponent("UIInput")
  self.declareCountLabel = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent/Label_TargetCount"):GetComponent("UILabel")
  self:UpdateNameCount()
  self:UpdateDeclareCount()
end
def.method().UpdateNameCount = function(self)
  local content = self.nameInput:get_value()
  local len, clen, hlen = Strlen(content)
  local showLen = math.ceil(clen / 2 + hlen)
  if showLen <= constant.CorpsConsts.CORPS_NAME_MAX_LENGTH then
    self.nameCountLabel:set_text(string.format("%d/%d", showLen, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH))
  else
    self.nameCountLabel:set_text(string.format("[ff0000]%d/%d[-]", showLen, constant.CorpsConsts.CORPS_NAME_MAX_LENGTH))
  end
end
def.method().UpdateDeclareCount = function(self)
  local content = self.declareInput:get_value()
  local len, clen, hlen = Strlen(content)
  local showLen = math.ceil(clen / 2 + hlen)
  if showLen <= constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH then
    self.declareCountLabel:set_text(string.format("%d/%d", showLen, constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH))
  else
    self.declareCountLabel:set_text(string.format("[ff0000]%d/%d[-]", showLen, constant.CorpsConsts.CORPS_DECLARATION_MAX_LENGTH))
  end
end
def.method().UpdateBadge = function(self)
  local cfg = CorpsUtils.GetCorpsBadgeCfg(self.badgeId)
  local uiTexture = self.m_panel:FindDirect("Img_Bg/Group_Sign/Img_Sign/Icon_Sign"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, cfg.iconId)
end
def.override().OnDestroy = function(self)
  self.nameInput = nil
  self.declareInput = nil
  self.nameCountLabel = nil
  self.declareCountLabel = nil
  self.badgeId = 0
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Label_NameContent" then
    self:UpdateNameCount()
  elseif id == "Label_TargetContent" then
    self:UpdateDeclareCount()
  end
end
def.method("=>", "string", "string", "number").GetCreateInfo = function(self)
  local name = self.nameInput:get_value()
  local declare = self.declareInput:get_value()
  local badgeId = self.badgeId
  return name, declare, badgeId
end
def.method("string", "string", "number", "=>", "boolean").ValidCreateInfo = function(self, name, declare, badgeId)
  if not CorpsUtils.IsNameValid(name) then
    return false
  end
  if not CorpsUtils.IsDeclareValid(declare) then
    return false
  end
  if self.badgeId <= 0 then
    Toast(textRes.Corps[13])
    return false
  end
  return true
end
def.method("string").onClick = function(self, id)
  if id == "Img_Sign" then
    do
      local allBadge = require("Main.Corps.CorpsModule").Instance():GetAllCorpsBadge()
      local icons = {}
      for k, v in ipairs(allBadge) do
        table.insert(icons, v.iconId)
      end
      require("Main.Corps.ui.SelectIconDlg").ShowSelectIcon(icons, {}, function(index)
        if allBadge[index] then
          self.badgeId = allBadge[index].id
          self:UpdateBadge()
        end
      end)
    end
  elseif id == "Btn_Create" then
    do
      local name, declare, badgeId = self:GetCreateInfo()
      if self:ValidCreateInfo(name, declare, badgeId) then
        local CommonConfirm = require("GUI.CommonConfirmDlg")
        local str = string.format(textRes.Corps[17], constant.CorpsConsts.CREATE_CORPS_COST_GOLD_NUM, name)
        CommonConfirm.ShowConfirm(textRes.Corps[16], str, function(selection, tag)
          if selection == 1 then
            local ItemModule = require("Main.Item.ItemModule")
            local goldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
            if goldNum < Int64.new(constant.CorpsConsts.CREATE_CORPS_COST_GOLD_NUM) then
              GoToBuyGold(true)
            else
              require("Main.Corps.CorpsModule").Instance():CreateCorps(name, declare, badgeId)
            end
          end
        end, nil)
      end
    end
  elseif id == "Btn_Cancel" then
    self:DestroyPanel()
  end
end
return CreateCorpsDlg.Commit()
