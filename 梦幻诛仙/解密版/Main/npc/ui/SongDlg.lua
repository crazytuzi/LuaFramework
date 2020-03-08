local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SongDlg = Lplus.Extend(ECPanelBase, "SongDlg")
local def = SongDlg.define
local instance
def.field("string").songName = ""
def.field("string").singerName = ""
def.field("string").album = ""
def.field("string").lyric = ""
def.static("string", "string", "string", "string").ShowDlg = function(songName, singerName, album, lyric)
  local dlg = SongDlg()
  dlg.songName = songName
  dlg.singerName = singerName
  dlg.album = album
  dlg.lyric = lyric
  dlg:CreatePanel(RESPATH.PREFAB_SONG, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
    self.m_panelName
  })
  self:UpdateLabel()
end
def.method().UpdateLabel = function(self)
  local scorll = self.m_panel:FindDirect("Img_Bg/Img_Lyric/Scrollview")
  local lbl1 = scorll:FindDirect("Label_Name")
  local lbl2 = scorll:FindDirect("Label_Player")
  local lbl3 = scorll:FindDirect("Label_Album")
  local lbl4 = scorll:FindDirect("Drag_Lyric")
  lbl1:GetComponent("UILabel"):set_text(self.songName)
  lbl2:GetComponent("UILabel"):set_text(string.format(textRes.activity[800], self.singerName))
  lbl3:GetComponent("UILabel"):set_text(string.format(textRes.activity[801], self.album))
  lbl4:GetComponent("UILabel"):set_text(self.lyric)
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
return SongDlg.Commit()
