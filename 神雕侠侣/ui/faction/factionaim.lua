require "ui.dialog"
FactionAim = {}
setmetatable(FactionAim, Dialog)
FactionAim.__index = FactionAim

local function createdlg()
	local self = {}
	setmetatable(self, FactionAim)
	function self.GetLayoutFileName()
		return "gangmsg.layout"
	end
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pEditbox = CEGUI.toRichEditbox(winMgr:getWindow("gangmsg/Back/editbox"))
	self.m_pOkBtn = CEGUI.toPushButton(winMgr:getWindow("gangmsg/jingying"))
	self.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("gangmsg/Pmin"))
	self.m_pEditbox:setMaxTextLength(100)
	self.m_pOkBtn:subscribeEvent("Clicked", self.HandleOkBtnClicked, self)
	self.m_pCancelBtn:subscribeEvent("Clicked", self.HandleCancelBtnClicked, self)
	return self
end

function FactionAim:HandleOkBtnClicked(e)
	local p = require "protocoldef.knight.gsp.faction.cchangefactionaim":new()
	p.newaim = self.m_pEditbox:GetPureText()
	local net = require "manager.luaprotocolmanager".getInstance()
	net:send(p)
	self.DestroyDialog()
end

function FactionAim:HandleCancelBtnClicked(e)
	self.DestroyDialog()
end

local _instance
function FactionAim.getInstance()
	if not _instance then
		_instance = createdlg()
	end
	return _instance
end

function FactionAim.getInstanceAndShowIt()
	if not _instance then
		_instance = createdlg()
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionAim.getInstanceOrNot()
	return _instance
end

function FactionAim:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end
function FactionAim.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

return FactionAim