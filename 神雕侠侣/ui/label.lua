require "ui.dialog"
require "ui.workshop.workshopcxnew"
local LabelDlgs = {}
LabelDlg = {}
setmetatable(LabelDlg, Dialog)
LabelDlg.__index = LabelDlg
function LabelDlg.new(prefix)
	local newLabel = {}
	print(prefix)
	setmetatable(newLabel, LabelDlg)
	newLabel.__index = newLabel
	newLabel:OnCreate(prefix)
	return newLabel
end

function LabelDlg.getLabelById(index)
	return LabelDlgs[index]
end

function LabelDlg:OnCreate(prefix)
	self.prefix = prefix
	local name_prefix = tostring(prefix)
	Dialog.OnCreate(self, nil, name_prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_labels = {}
	for i = 1, 5 do
		local wndname = i == 1 and name_prefix.."Lable/button" or name_prefix.."Lable/button"..i-1
		local btn = CEGUI.Window.toPushButton(winMgr:getWindow(wndname))
		table.insert(self.m_labels, btn)
	end
	self.m_dlgs = {}
	LabelDlgs[prefix] = self
end

function LabelDlg:GetLayoutFileName()
	--print("Get LabelDlg layout name")
	return "lable.layout"
end

function HideDialogs(tab)
  for k,v in pairs(tab) do
    if v:IsVisible() then
      v:SetVisible(false)
    end
  end
end

function LabelDlg.InitJianghu()
	local prefix = "jianghu"
	local dlg = LabelDlg.new(prefix)
	dlg:InitButtons(MHSD_UTILS.get_resstring(2801), MHSD_UTILS.get_resstring(3144), MHSD_UTILS.get_resstring(3147), MHSD_UTILS.get_resstring(2802))
	
  dlg.m_dlgs[1] = require "ui.friendsdialog".getInstanceAndShow()
  dlg.m_dlgs[2] = require "ui.jieyi.jieyiinfodlg".getInstanceAndShow()
  dlg.m_dlgs[2]:SetVisible(false)
  dlg.m_dlgs[3] = require "ui.shitu.shitulianxindlg".getInstanceAndShow()
  dlg.m_dlgs[3]:SetVisible(false)
  dlg.m_dlgs[4] = require "ui.faction.factionentrance"()
  dlg.m_dlgs[4]:SetVisible(false)
	
	dlg.m_labels[1]:subscribeEvent("Clicked", 
	function(e)
    HideDialogs(dlg.m_dlgs)
    require "ui.friendsdialog"
    dlg.m_dlgs[1]:SetVisible(true)
	end)

  dlg.m_labels[2]:subscribeEvent("Clicked",
	function(e)
	  HideDialogs(dlg.m_dlgs)
    dlg.m_dlgs[2]:SetVisible(true)
    
    --request jieyi info
    local req = require "protocoldef.knight.gsp.sworn.csworninfo".Create()
    LuaProtocolManager.getInstance():send(req)
	end)

  dlg.m_labels[3]:subscribeEvent("Clicked",
  function(e)
    HideDialogs(dlg.m_dlgs)
    dlg.m_dlgs[3]:SetVisible(true)
    
    --request shitu lianxin
    local req = require "protocoldef.knight.gsp.master.creqapprences".Create()
    LuaProtocolManager.getInstance():send(req)
  end)
  
	dlg.m_labels[4]:subscribeEvent("Clicked",
	function(e)
      HideDialogs(dlg.m_dlgs)
      dlg.m_dlgs[4]:SetVisible(true)
	end)

	return dlg
end

--[[function LabelDlg.ShowEquipChongxing()
	local myLabel = LabelDlg.new()
	WorkshopCxNew.Show()
end]]--
function LabelDlg:InitButtons(arg1, arg2, arg3, arg4)
	local maxbuttonnum = #(self.m_labels)
	for i=1,maxbuttonnum do
		self.m_labels[i]:setVisible(false)
	end

	if arg1 then
		self.m_labels[1]:setVisible(true)
		self.m_labels[1]:setText(arg1)
	end
	if arg2 then
		self.m_labels[2]:setVisible(true)
		self.m_labels[2]:setText(arg2)
	end
	if arg3 then
		self.m_labels[3]:setVisible(true)
		self.m_labels[3]:setText(arg3)
	end
	if arg4 then
		self.m_labels[4]:setVisible(true)
		self.m_labels[4]:setText(arg4)
	end

end

function LabelDlg.RemoveLabel(prefix)
	LabelDlgs[prefix] = nil
end

function LabelDlg:OnClose()
	Dialog.OnClose(self)
	if self.prefix then
		LabelDlgs[self.prefix] = nil
	end

	for k,v in pairs(self.m_dlgs) do
	 v:OnClose()
	end
end

return LabelDlg
