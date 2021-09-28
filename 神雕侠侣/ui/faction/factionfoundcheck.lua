require "ui.dialog"

FactionFoundCheck = {}
setmetatable(FactionFoundCheck, Dialog)
FactionFoundCheck.__index = FactionFoundCheck

local function createdlg()
	local dlg = {}
	setmetatable(dlg, FactionFoundCheck)
	function dlg.GetLayoutFileName()
		return "familyfoundcheck.layout"
	end
	Dialog.OnCreate(dlg)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local pCloseBtn = CEGUI.toPushButton(winMgr:getWindow("familyfoundcheck/close"))
    dlg.m_pNameEdit = CEGUI.toEditbox(winMgr:getWindow("familyfoundcheck/familyname"))
    dlg.m_pBroadcast = CEGUI.toRichEditbox(winMgr:getWindow("familyfoundcheck/Info"))
    dlg.m_pOkBtn = CEGUI.toPushButton(winMgr:getWindow("familyfoundcheck/OK"))
    dlg.m_pCancelBtn = CEGUI.toPushButton(winMgr:getWindow("familyfoundcheck/cansel"))
	dlg.m_pNameEdit:setMaxTextLength(10)
	dlg.m_pBroadcast:setMaxTextLength(32)

    dlg.m_pOkBtn:subscribeEvent("Clicked", FactionFoundCheck.HandleOkBtnClicked, dlg)
    dlg.m_pCancelBtn:subscribeEvent("Clicked", FactionFoundCheck.HandleCancelBtnClicked, dlg)
    pCloseBtn:subscribeEvent("Clicked", FactionFoundCheck.HandleCloseBtnClick, dlg)
    return dlg
end

local _instance
function FactionFoundCheck.getInstance()
	if not _instance then
		_instance = createdlg()
	end
	return _instance
end
function FactionFoundCheck.getInstanceOrNot()
	return _instance
end
function FactionFoundCheck.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FactionFoundCheck:HandleOkBtnClicked(e)
	self.create_co = coroutine.create(function() 
		local send = require "protocoldef.knight.gsp.faction.ccreatefaction2":new()
		send.factionaim = self.m_pBroadcast:GetPureText()
		send.factionname = self.m_pNameEdit:getText()
		LuaProtocolManager.getInstance():send(send)
		local succ = coroutine.yield()
		if succ then
			self.DestroyDialog()
			local dlg = require "ui.faction.familyfound".getInstanceOrNot()
			if dlg then
				dlg.DestroyDialog()
			end
		end
	end)
	coroutine.resume(self.create_co)
end

function FactionFoundCheck:HandleCancelBtnClicked(e)
	self.DestroyDialog()
end

function FactionFoundCheck:HandleCloseBtnClick(e)
    self.DestroyDialog()
end

return FactionFoundCheck