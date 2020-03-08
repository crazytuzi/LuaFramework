function Toy:UseReq(nId)
	RemoteServer.ToyReq("Use", nId)
end

local tbLeaveClasses = {
	ToyWindmill = true,
	ToyChild = true,
	ToyFreeze = true,
	ToyMask = true,
	ToyMecha = true,
	ToySnowman = true,
	ToyDragonHead = true,
	ToyDragonBody = true,
	ToyDragonTail = true,
	ToyPigTarget = true,
	ToyFire = true,
	ToyWater = true,
}

local tbReadyClasses = {
	ToyDragonHead = true,
	ToyDragonBody = true,
	ToyDragonTail = true,
}

function Toy:OnUseSuccess(nId)
	self.tbLastUse = self.tbLastUse or {}
	self.tbLastUse[nId] = GetTime()

	me.CenterMsg("使用成功")

	local nActMode = me.GetActionMode();
    if nActMode ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none, true);
    end

	local szClass = self:GetClass(nId)
	if tbLeaveClasses[szClass] then
		Ui:OpenWindow("QYHLeavePanel", "Toy")
		self.szUsing = szClass
	end

	if tbReadyClasses[szClass] then
		Ui:OpenWindow("ToyReadyPanel", szClass)
	end
end

function Toy:Ready(szClass)
	RemoteServer.ToyReq("Ready")
end

function Toy:CancelReady(szClass)
	RemoteServer.ToyReq("CancelReady")
end

function Toy:OnQuitSuccess(nId)
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("ToyReadyPanel")
	self.szUsing = nil
end

function Toy:OnReadySuccess(nId)
	me.CenterMsg("准备成功，请等待其他玩家接入")

	if Ui:WindowVisible("ToyReadyPanel") == 1 then
		Ui("ToyReadyPanel"):OnReadyChange(true)
	end
end

function Toy:OnCancelReadySuccess(nId)
	me.CenterMsg("取消准备成功")

	if Ui:WindowVisible("ToyReadyPanel") == 1 then
		Ui("ToyReadyPanel"):OnReadyChange(false)
	end
end

function Toy:IsFree()
	return not tbLeaveClasses[self.szUsing or ""]
end

function Toy:GetUsing()
	return self.szUsing
end

function Toy:OnUnlock(nId)
	me.CenterMsg("已解锁天工秘宝，可点击聊天框上方天工匣按钮使用")
	Guide:StartGuideById(self.Def.nGuideId, false, false, true)
end

function Toy:OnForceDance(szName)
	me.CenterMsg(string.format("%s使用了天魔笛使周围的人舞蹈起来", szName), true)
	RemoteServer.SendChatBQ(7, 0)
end

function Toy:OnForceStick(szName)
	me.CenterMsg(string.format("%s塞给你一根糖葫芦，甜甜的，很贴心", szName), true)
end

function Toy:OnForceLaugh(szName)
	me.CenterMsg(string.format("%s对你使用了笑春风，你哈哈大笑不能自已", szName), true)
	RemoteServer.SendChatBQ(2, 0)
end

function Toy:OnForceWineDance()
	RemoteServer.SendChatBQ(self.Def.nWineJarDanceBQ, 0)
end

function Toy:OnClickCancel()
	RemoteServer.ToyReq("Quit")
end

function Toy:BeginUse(nId)
	self.nUsing = nId
	me.SendBlackBoardMsg("大侠可点击其他玩家使用天工秘宝，移动则取消使用")
end

function Toy:CancelUse()
	self.nUsing = nil
end

function Toy:ForceCancelUse()
	if self.nUsing and self.nUsing > 0 then
		local tbSetting = self:GetSetting(self.nUsing)
		if tbSetting then
			me.CenterMsg(string.format("已经取消「%s」", tbSetting.szName), true)
		end
	end
	self:CancelUse()
end

local tbConfirmClass = {
	ToyHat = "确定要把青风赠送给%s吗？",
	ToyStick = "确定要对%s使用糖葫芦吗？",
}
function Toy:OnSelectTarget(nTargetId, szTargetName)
	if not self.nUsing or self.nUsing <= 0 then
		return
	end

	local nUsing = self.nUsing
	self:CancelUse()
	local function fnConfirm()
		RemoteServer.ToyReq("Use", nUsing, nTargetId)
	end

	local szClass = self:GetClass(nUsing)
	if not tbConfirmClass[szClass] then
		fnConfirm()
		return
	end

	local szMsg = string.format(tbConfirmClass[szClass], szTargetName)
	me.MsgBox(szMsg, {{"确定", function()
		fnConfirm()
	end}, {"取消"}})
end

function Toy:OnLeaveMap(nMapTemplateId)
	--RemoteServer.ToyReq("Quit")
	--self:OnQuitSuccess(nId)
	self:CancelUse()
end

function Toy:OnLogout()
	RemoteServer.ToyReq("Quit")
end

function Toy:GetCD(nId)
	self.tbLastUse = self.tbLastUse or {}
	return math.max(0, self.Def.nInterval - (GetTime() - (self.tbLastUse[nId] or 0)))
end

function Toy:Use(nId)
	if self:GetCD(nId) > 0 then
		me.CenterMsg("操作太频繁了")
		return
	end

	local szClass = self:GetClass(nId)
	if self.Def.tbNeedTarget[szClass] then
		self:BeginUse(nId)
		return
	end
	self:UseReq(nId)
end

function Toy:OnUsePig(szFrom)

	me.CenterMsg(string.format("%s对你使用了玩具猪", szFrom))
	Ui:OpenWindow("QYHLeavePanel", "Toy")
	self.szUsing = "ToyPigTarget"
end

function Toy:OnLogin(bReconnect)
	if self:IsMapValid(me) then
		Ui:CloseWindow("QYHLeavePanel")
		Ui:CloseWindow("ToyReadyPanel")
		self.szUsing = nil
	end
end

function Toy:GetShowRightPopup(pPlayer)
    local tbPopup = {}
	for nId, tb in ipairs(self.tbSetting) do
		if self.Def.tbNeedTarget[tb.szClass] then
			table.insert(tbPopup, {
				fnName = function()
	                return tb.szName
	            end,
	            fnOnClick = function(self)
	             	if not Toy:IsUnlocked(pPlayer, nId) then
	             		me.CenterMsg("尚未解锁此玩具")
	             		return
	             	end
	            	Toy.nUsing = nId
	            	Toy:OnSelectTarget(self.tbData.dwRoleId, self.tbData.szName)
	            end,
	            fnAvaliable = function(tbData)
	                return true
	            end,
			})
		end
	end
    return tbPopup
end