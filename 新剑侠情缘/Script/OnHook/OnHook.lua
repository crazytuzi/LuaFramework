OnHook.nCurMaxLevel = 1000;

function OnHook:OnGetExpFinish(nAddExp,nUseExpTime,nGetType)
	if nAddExp > 0 then
		me.CenterMsg(string.format("你获得了%d经验", me.TrueChangeExp(nAddExp)));
	end
	self:RefreshRedPoint()
	UiNotify.OnNotify(UiNotify.emNOTIFY_ONHOOK_GET_EXP_FINISH);
end

function OnHook:CheckRedPoint(pPlayer)
	if self:IsOpen(me) and self:IsHaveExpTime(pPlayer) then
		return true
	end
end

function OnHook:RefreshClientMaxLevel()
	self.nCurMaxLevel = TimeFrame:GetMaxLevel();
end

function OnHook:OnFirstMapLoaded()
	if self:IsOpen(me) and self:IsHaveExpTime(me) then
		self:RefreshRedPoint()
		if Pandora.bOpenPL then
			--当前拍脸窗口打开状态
			Pandora.bWelfareActivity = true;
		else
			Timer:Register(1, 
						function ()
							if not Player:IsInCrossServer() then
								Ui:OpenWindow("WelfareActivity","OnHook");
							end
						end)
		end
	end
end

function OnHook:OnLogin(bIsReconnect)
	if not bIsReconnect then
		-- 处理在线托管中直接关掉客户端或被别的客户端用同一个号顶掉的情况
		if OnHook:IsOnLineOnHook(me) then
			self:StartOnlineOnHookState()
		end	
	else
		-- 如果每次登陆都跑这段的话，每次登陆都有可能EnableWalking，可能会有问题
		-- 比如别的功能DisableWalking了，Login的时候可能就会在这里被释放掉
		if OnHook:IsOnLineOnHook(me) then
			self:StartOnlineOnHookState()
		else
			self:EndOnlineOnHookState()
		end
	end
end

function OnHook:StartOnlineOnHookState()
	if OnHook:IsOnLineOnHookForce(me) then
		return
	end
	local nDoing = me.GetDoing();
    if nDoing == Npc.Doing.sit then
        local _, nX, nY = me.GetWorldPos();
        me.GotoPosition(nX + 1, nY);
    end

    Operation:DisableWalking()

	Ui:CloseWindow("RoleInformationPanel");
	Ui:OpenWindow("OnlineOnHookPanel")

	UiNotify.OnNotify(UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE)
end

function OnHook:StartOnlineOnHookForceState()
	UiNotify.OnNotify(UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE)
end

function OnHook:EndOnlineOnHookState()
	Operation:EnableWalking()

	Ui:CloseWindow("RoleInformationPanel");
	Ui:CloseWindow("OnlineOnHookPanel");

	UiNotify.OnNotify(UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE)
end

function OnHook:ChangeOnLineOnHook()
	local bRet,szMsg = false,"请稍后再试..."

	if OnHook:IsOnLineOnHook(me) then
		bRet,szMsg = OnHook:CheckEndOnlineHook(me)
	else
		bRet,szMsg = OnHook:CheckRequestOnlineOH(me)
		if bRet then
			bRet,szMsg = OnHook:CheckStartOnlineHook(me)
			if bRet then
				me.nRequestStartOnlineOHTime = GetTime() + OnHook.nRequestOnlineOHInterval
			end
		end
	end

	if not bRet then
		me.CenterMsg(szMsg)
		UiNotify.OnNotify(UiNotify.emNOTIFY_ONLINE_ONHOOK_STATE)
		return
	end

	RemoteServer.ChangeOnLineOnHook()
end

function OnHook:OnCalcOnHookFinish()
	self:RefreshRedPoint()
end

function OnHook:RefreshRedPoint()
	 OnHook:RefreshClientMaxLevel()
	 local bRedPoint = OnHook:CheckRedPoint(me)
	 if bRedPoint then
	 	Ui:SetRedPointNotify("OnHook_GetExp");
	 else
	 	Ui:ClearRedPointNotify("OnHook_GetExp");
	 end
end