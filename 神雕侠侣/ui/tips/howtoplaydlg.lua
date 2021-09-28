local SingletonDialog = require "ui.singletondialog"
local Dialog = require "ui.dialog"

local HowToPlayDlg = {}
setmetatable(HowToPlayDlg, SingletonDialog)
HowToPlayDlg.__index = HowToPlayDlg

function HowToPlayDlg.GetLayoutFileName()
	return "xiaganyidanadd.layout"
end

function HowToPlayDlg.new()
	local inst = {}
	setmetatable(inst, HowToPlayDlg)
	inst:OnCreate()
	return inst
end

function HowToPlayDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wTxt = CEGUI.Window.toRichEditbox(winMgr:getWindow("xiaganyidanadd/main/wenben"))
end

function HowToPlayDlg:Init(id)
	local Table = BeanConfigManager.getInstance():GetTableByName("knight.gsp.message.chowtoplay")
	local record = Table:getRecorder(id)
	if record then
		local data = {}
		data.parseText = record.text
		self:RefreshData(data)
	end
end

function HowToPlayDlg:RefreshData(data)
	self.m_wTxt:Clear()
	self.m_wTxt:AppendParseText(CEGUI.String(data.parseText))
	self.m_wTxt:Refresh()
	self.m_wTxt:HandleTop()
end

return HowToPlayDlg
