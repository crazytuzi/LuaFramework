local AsyncBase   = luanet.import_type("AsyncBaseNP.AsyncBase")
Ui.tbTaskListener = Ui.tbTaskListener or {}
local tbListener  = Ui.tbTaskListener
tbListener.nTime  = Env.GAME_FPS * 5
tbListener.nHideCount    = 300
tbListener.nRestoreCount = 20
function tbListener:OnLogin()
	if self.nTimer then
		return
	end
	self.nTimer = Timer:Register(self.nTime, self.CheckFrame, self)
end

function tbListener:CheckFrame()
	local nTaskCount = self:GetTaskCount()
	if self.bHideOtherPlayer then
		if nTaskCount < self.nRestoreCount then
			self.bHideOtherPlayer = false
			Ui:UpdateDrawLevel();
			Log("Ui.tbTaskListener Restore", nTaskCount)
		end
	else
		if nTaskCount >= self.nHideCount then
			self.bHideOtherPlayer = true
			Ui:UpdateDrawLevel();
			Log("Ui.tbTaskListener HideOtherPlayer", nTaskCount)
		end
	end
	return true
end

function tbListener:GetTaskCount()
	local nCount = 0
	if AsyncBase.s_lstNormalTask then
		nCount = AsyncBase.s_lstNormalTask.Count
	end
	return nCount
end

function tbListener:IsWorking()
	return self.bHideOtherPlayer
end

AsyncBase.s_nProcessCount = 50