local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local TmpTipsPanel = Lplus.Extend(ECPanelBase, "TmpTipsPanel")
local MathHelper = require("Common.MathHelper")
local Vector = require("Types.Vector")
local def = TmpTipsPanel.define
local dlg
def.static("=>", TmpTipsPanel).Instance = function(self)
  if nil == dlg then
    dlg = TmpTipsPanel()
  end
  return dlg
end
def.field("table").position = nil
def.field("number").iconId = 0
def.field("string").desc = ""
def.field("string").title = ""
def.field("string").typeName = ""
def.static("table", "number", "string", "string", "string", "=>", TmpTipsPanel).ShowTip = function(pos, iconId, desc, title, typeName)
  local tip = TmpTipsPanel.Instance()
  tip.position = pos
  tip.iconId = iconId
  tip.desc = desc
  tip.title = title
  tip.typeName = typeName
  tip:CreatePanel(RESPATH.ITEMTIPS, 2)
  tip:SetOutTouchDisappear()
  return tip
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateContent()
  self:UpdateButton()
  self:SetLayer(ClientDef_Layer.Invisible)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel == nil then
      return
    end
    local tipFrame = self.m_panel:FindDirect("Table_Tips")
    if tipFrame == nil then
      return
    end
    local uiTable = tipFrame:GetComponent("UITableResizeBackground")
    uiTable:Reposition()
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      if tipFrame == nil then
        return
      end
      if self.position.auto then
        local bg = tipFrame:GetComponent("UISprite")
        local x, y = MathHelper.ComputeTipsAutoPosition(self.position.sourceX, self.position.sourceY, self.position.sourceW, self.position.sourceH, bg:get_width(), bg:get_height(), self.position.prefer)
        tipFrame:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
      else
        tipFrame:set_localPosition(Vector.Vector3.new(self.position.x, self.position.y, 0))
      end
      self:SetLayer(ClientDef_Layer.UI)
    end)
    self:TouchGameObject(self.m_panel, self.m_parent)
  end)
end
def.method().UpdateTitle = function(self)
  local uiTexture = self.m_panel:FindDirect("Table_Tips/Title/Img_Item/Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, self.iconId)
  local title = self.m_panel:FindDirect("Table_Tips/Title")
  local titleLabel = title:FindDirect("Label_Name"):GetComponent("UILabel")
  titleLabel:set_text(self.title)
  title:FindDirect("Img_Zhuan"):SetActive(false)
  title:FindDirect("Img_Bang"):SetActive(false)
  local levelLabel = title:FindDirect("Label_Lv"):GetComponent("UILabel")
  local levelLabelTitle = title:FindDirect("Label_LvTitle"):GetComponent("UILabel")
  levelLabelTitle:set_text("")
  levelLabel:set_text("")
  if self.typeName ~= "" then
    title:FindDirect("Label_Type"):SetActive(true)
    title:FindDirect("Label_TypeTitle"):SetActive(true)
    local typeLabel = title:FindDirect("Label_Type"):GetComponent("UILabel")
    typeLabel:set_text(self.typeName)
  else
    title:FindDirect("Label_Type"):SetActive(false)
    title:FindDirect("Label_TypeTitle"):SetActive(false)
  end
  local equipImg = title:FindDirect("Img_Present")
  equipImg:SetActive(false)
  local infoBtn = self.m_panel:FindDirect("Table_Tips/Title/Btn_Info")
  infoBtn:SetActive(false)
end
def.method().UpdateContent = function(self)
  local HTML = self.m_panel:FindDirect("Table_Tips/Label_Describe"):GetComponent("NGUIHTML")
  HTML:ForceHtmlText(self.desc)
end
def.method().UpdateButton = function(self)
  self.m_panel:FindDirect("Table_Tips/Container_Btn"):SetActive(false)
end
TmpTipsPanel.Commit()
return TmpTipsPanel
