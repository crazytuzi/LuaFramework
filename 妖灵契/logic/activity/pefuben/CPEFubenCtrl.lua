local CPEFubenCtrl = class("CPEFubenCtrl", CCtrlBase)

define.PEFuben = {
	Event = 
	{
		UpdateLock = 1,
		UpdateTurn = 2,
	},
}

function CPEFubenCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_FubenInfoList = {}
end

function CPEFubenCtrl.ResetCtrl(self)
	-- body
end

function CPEFubenCtrl.ShowMainView(self, data)
	CPEFbView:ShowView(function (oView)
		oView:RefreshData(data)
		end)
end

function CPEFubenCtrl.UpdateLockResult(self, fb_id, lock)
	local eventdata = {fb_id = fb_id, lock = lock}
	self:OnEvent(define.PEFuben.Event.UpdateLock, eventdata)
end

function CPEFubenCtrl.UpdateTurnResult(self, data)
	self:OnEvent(define.PEFuben.Event.UpdateTurn, data)
end

function CPEFubenCtrl.OpenEquipFBMain(self)
	nethuodong.C2GSOpenPEMain()
end

function CPEFubenCtrl.StartTurn(self, fb_id)
	nethuodong.C2GSPEStartTurn(fb_id)
end

function CPEFubenCtrl.PELock(self, fb_id, lock)
	nethuodong.C2GSPELock(fb_id, lock)	
end

function CPEFubenCtrl.EnterFuben(self, fb_id, floor, itype)
	itype = itype or 0
	nethuodong.C2GSEnterPEFuBen(fb_id, floor, itype)
end

function CPEFubenCtrl.ChooseFuben(self, fb_id)
	nethuodong.C2GSOpenPEMain(fb_id)
end

function CPEFubenCtrl.SetEndCallback(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		self:OpenEquipFBMain()
	end)
end

function CPEFubenCtrl.ShowWarResult(self, oCmd)
	CPEWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
	end)
end

return CPEFubenCtrl
