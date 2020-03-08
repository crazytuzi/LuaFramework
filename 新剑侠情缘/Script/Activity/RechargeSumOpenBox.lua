
local tbAct = Activity.RechargeSumOpenBox;

function tbAct:UpdatePlayerData( tbData )
	local tbOldPlayerData = self.tbPlayerData
	if tbOldPlayerData and not tbOldPlayerData.bFinish and tbData and tbData.bFinish then
		self.bShowThisTime = true
	else
		self.bShowThisTime = nil
	end
	self.tbPlayerData = tbData;
	self:CheckRedPoint( )
	UiNotify.OnNotify(UiNotify.emNOTIFY_WELFARE_UPDATE, "PresentBoxPanel")
end

function tbAct:GetPlayerData(  )
	--开活动时是没同步下来的，在玩家登陆或数据变化时有同步
	return self.tbPlayerData or {}
end

function tbAct:IsShowUi( )
	if not self.nAwardKey then
		return
	end
	if self.bShowThisTime then
		return true
	end
	local tbPlayerData = self:GetPlayerData()
	if not tbPlayerData then
		return 
	end
	if tbPlayerData.bFinish then
		return
	end
	return true
end

function tbAct:TryTakeAward( nIndex )
	local tbPlayerData = self:GetPlayerData()
	local bRet, szMsg = self:CanTakeAward(tbPlayerData, nIndex)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.RechargeSumOpenBoxTakeAward(nIndex)
end

function tbAct:CheckRedPoint(  )
	local bShowRed = fasle;
	if self:IsShowUi() then
		local tbPlayerData = self:GetPlayerData()
		for i,v in ipairs(tbPlayerData) do
			if v == 0 then
				bShowRed = true
				break;
			end
		end
	end
	if bShowRed then
        Ui:SetRedPointNotify("Activity_PresentBoxPanel")
    else
        Ui:ClearRedPointNotify("Activity_PresentBoxPanel")
    end
end