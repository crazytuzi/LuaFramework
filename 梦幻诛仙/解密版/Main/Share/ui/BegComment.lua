local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BegComment = Lplus.Extend(ECPanelBase, "BegComment")
local def = BegComment.define
def.field("function").callback = nil
def.static("function").ShowBeg = function(cb)
  local dlg = BegComment()
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_BEG_COMMENT, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  local begText = self.m_panel:FindDirect("Img_Bg/Label_Content")
  begText:GetComponent("UILabel"):set_text(textRes.Share[3])
end
def.method("string").onClick = function(self, id)
  if id == "Btn_No" or id == "Btn_Close" then
    self:DestroyPanel()
    self.callback(0)
  elseif id == "Btn_Yes" then
    self:DestroyPanel()
    self.callback(1)
  end
end
BegComment.Commit()
return BegComment
