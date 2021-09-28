require "ui.dialog"

FactionMessage = {}
setmetatable(FactionMessage, Dialog)
FactionMessage.__index = FactionMessage

local function createdlg()
	local self = {}
	setmetatable(self, FactionMessage)
	function self.GetLayoutFileName()
		return "gangnomination.layout"
	end
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pTextbox = CEGUI.toRichEditbox(winMgr:getWindow("GangNomination/Back/editbox"))
	self.m_pOkBtn = CEGUI.toPushButton(winMgr:getWindow("GangNomination/jingying"))
	self.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("GangNomination/Pmin"))
	self.m_pOkBtn:subscribeEvent("Clicked", self.HandleOkBtnClicked, self)
	self.m_pCancelBtn:subscribeEvent("Clicked", self.HandleCancelBtnClicked, self)
	self.m_pTextbox:subscribeEvent("TextChanged", self.HandleMsgChanged, self)
	return self
end

function FactionMessage:HandleMsgChanged(e)
--[[
	local txt = self.m_pTextbox:GetPureText()
	txt = require "utils.mhsdutils".ShiedText(txt)
	self.m_pTextbox:Clear()
	self.m_pTextbox:AppendText(CEGUI.String(txt))
	self.m_pTextbox:Refresh()
	self.m_pTextbox:SetCaratEnd()
	--]]
end

function FactionMessage:HandleOkBtnClicked(e)
	local txt = self.m_pTextbox:GetPureText()
	if txt then
		local shied, txt = require "utils.mhsdutils".ShiedText(txt)
		self.m_pTextbox:Clear()
		self.m_pTextbox:AppendText(CEGUI.String(txt))
		self.m_pTextbox:Refresh()
		self.m_pTextbox:SetCaratEnd()
		if shied then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(142261)
            end
			return
		else
			local p = require "protocoldef.knight.gsp.faction.cfactionmessage":new()
			p.message = txt
			require "manager.luaprotocolmanager":send(p)
			self.DestroyDialog()
		end
	end
end

function FactionMessage:HandleCancelBtnClicked(e)
	self.DestroyDialog()
end

local _instance
function FactionMessage.GetSingletonDialogAndShowIt()
	if not _instance then
		_instance = createdlg()
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionMessage.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function FactionMessage.getInstanceOrNot()
	return _instance
end

return FactionMessage