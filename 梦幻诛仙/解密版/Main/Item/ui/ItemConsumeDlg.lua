local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemConsumeDlg = Lplus.Extend(ECPanelBase, "ItemConsumeDlg")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = ItemConsumeDlg.define
def.static("number", "string", "string", "string", "string", "number", "number", "function").ShowItemConsume = function(itemId, title, name, numStr, desc, iconId, yuanbao, cb)
  local ItemConsumeDlg = ItemConsumeDlg()
  ItemConsumeDlg.itemId = itemId
  ItemConsumeDlg.title = title
  ItemConsumeDlg.name = name
  ItemConsumeDlg.numStr = numStr
  ItemConsumeDlg.desc = desc
  ItemConsumeDlg.iconId = iconId
  ItemConsumeDlg.yuanbao = yuanbao
  ItemConsumeDlg.callback = cb
  ItemConsumeDlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRMICON, 2)
  ItemConsumeDlg:SetModal(true)
end
def.field("number").itemId = 0
def.field("string").title = ""
def.field("string").name = ""
def.field("string").numStr = ""
def.field("string").desc = ""
def.field("number").iconId = 0
def.field("number").yuanbao = 0
def.field("function").callback = nil
def.override().OnCreate = function(self)
  local titleLabel = self.m_panel:FindDirect("Img_0/Label_Title"):GetComponent("UILabel")
  titleLabel:set_text(self.title)
  local nameLabel = self.m_panel:FindDirect("Img_0/Label_ItemName"):GetComponent("UILabel")
  nameLabel:set_text(self.name)
  local numLabel = self.m_panel:FindDirect("Img_0/Label_ItemNum"):GetComponent("UILabel")
  numLabel:set_text(self.numStr)
  local descLabel = self.m_panel:FindDirect("Img_0/Img_BgWords/Label"):GetComponent("UILabel")
  descLabel:set_text(self.desc)
  local icon = self.m_panel:FindDirect("Img_0/Img_BgItem/Img_IconItem"):GetComponent("UITexture")
  GUIUtils.FillIcon(icon, self.iconId)
  local btn = self.m_panel:FindDirect("Img_0/Btn_Confirm")
  local confirmBtn = btn:FindDirect("Label_Confirm")
  local yuanbaoBtn = btn:FindDirect("Group_Icon")
  if self.yuanbao > 0 then
    confirmBtn:SetActive(false)
    yuanbaoBtn:SetActive(true)
    yuanbaoBtn:FindDirect("Label_Confirm"):GetComponent("UILabel"):set_text(self.yuanbao)
  else
    confirmBtn:SetActive(true)
    yuanbaoBtn:SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self.callback(self.yuanbao)
    self:DestroyPanel()
  elseif id == "Btn_Cancel" then
    self.callback(-1)
    self:DestroyPanel()
  elseif id == "Img_BgItem" and self.itemId > 0 then
    local source = self.m_panel:FindDirect("Img_0/Img_BgItem")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.itemId, source, 0, true)
  end
end
ItemConsumeDlg.Commit()
return ItemConsumeDlg
