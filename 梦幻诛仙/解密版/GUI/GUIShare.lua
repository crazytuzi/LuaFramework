local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIShare = Lplus.Extend(ECPanelBase, "GUIShare")
local def = GUIShare.define
def.field("table").m_content = nil
local instance
def.static("=>", GUIShare).Instance = function()
  if not instance then
    instance = GUIShare()
  end
  return instance
end
def.method("table").ShowPanel = function(self, content)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_content = content
  self:CreatePanel(RESPATH.PREFAB_SHARE_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if self.m_content == nil then
    return
  end
  instance.m_panel:FindDirect("Img_Bg/Label_1"):GetComponent("UILabel").text = self.m_content.title
  instance.m_panel:FindDirect("Img_Bg/Label_2"):GetComponent("UILabel").text = self.m_content.msg
  if self.m_content.cancelBtnStr then
    instance.m_panel:FindDirect("Img_Bg/Btn_Left/Label"):GetComponent("UILabel").cancelStr = self.m_content.cancelBtnStr
  end
  if self.m_content.confirmBtnStr then
    instance.m_panel:FindDirect("Img_Bg/Btn_Right/Label"):GetComponent("UILabel").confirmStr = self.m_content.confirmBtnStr
  end
end
def.override().OnDestroy = function(self)
  self.m_content = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Left" then
    self:DestroyPanel()
  elseif id == "Btn_Right" then
    if self.m_content.callback then
      self.m_content.callback()
    end
    self:DestroyPanel()
  end
end
return GUIShare.Commit()
