

Guide.tbBase = Guide.tbBase or {}
local tbBase = Guide.tbBase;

function tbBase:Init(nGuideId, tbStepsSetting)
	self.tbSteps = {};
	self.nGuideId = nGuideId
	for nIdx, tbStepInfo in ipairs(tbStepsSetting) do
		local tbPointer
		if tbStepInfo.PointerOffset ~= "" then
			local tbSplitStr = Lib:SplitStr(tbStepInfo.PointerOffset, "|");
			local nX = tonumber(tbSplitStr[1]);
			local nY = tonumber(tbSplitStr[2]);
			if nX and nY then
				tbPointer = {nX, nY};
			end
		end
		
		if tbStepInfo.LoginStart == 1 then
			self.nLoginBeginStep = nIdx;
		end
		
		self.tbSteps[nIdx] = 
		{
			szAction = tbStepInfo.ActionType,
			szParam = tbStepInfo.Param,
			szFinishCheck = tbStepInfo.FinishCheck,
			szCheckParam = tbStepInfo.CheckParam,
			szDescType = tbStepInfo.DescType,
			szDesc = tbStepInfo.DescInfo,
			bSave = tbStepInfo.SaveFinish,
			tbPointer = tbPointer,
		}
	end
end

function tbBase:Start(bLoginStart)
	local nBeginStep = 0;
	if bLoginStart and self.nLoginBeginStep then
		nBeginStep = self.nLoginBeginStep - 1
	end
	self.nCurStep = nBeginStep or 0;
	return self:NextStep()
end

function tbBase:NextStep()
	if self.tbCurStep and self.tbCurStep.bSave == 1 then
		RemoteServer.FinishGuide(self.nGuideId)
	end
	
	self.nCurStep = self.nCurStep + 1
	RemoteServer.GuideStep(self.nGuideId, self.nCurStep)
	if not self.tbSteps[self.nCurStep] then
		return false;		-- 结束 没有下一步则认为该引导已经完成
	end
	
	self.tbCurStep = self.tbSteps[self.nCurStep];
	local fnAction = self[self.tbCurStep.szAction]
	if not fnAction then
		Log("Guide Step ActionType Error!!!", self.tbCurStep.szAction)
		return false;
	end
	
	local bRet = fnAction(self, self.tbCurStep.szParam)
	if not bRet then
		Log("Guide Step Action Excute false!!!", self.tbCurStep.szAction, self.tbCurStep.szParam)
		return false;
	end
	
	if self.tbCurStep.szFinishCheck and self.tbFinishCheckInit[self.tbCurStep.szFinishCheck] then
		self.tbFinishCheckInit[self.tbCurStep.szFinishCheck](self, self.tbCurStep, self.tbCurStep.szCheckParam)
	end
	
	return true;
end

tbBase.tbFinishCheckInit = 
{
	CheckOpenUi = function (self, tbStep, szParam)
		tbStep.szCheckOpenUi = szParam;
	end,
	CheckClickWnd = function (self, tbStep, szParam)
		local tbWndCom, szWnd = self:GetUiWndByParam(szParam)
		if not tbWndCom or not szWnd then
			Log("CheckClickWnd Error CheckParam", szParam)
			return;
		end
		tbStep.nClickKey = Guide:SetCheckClickWnd(tbWndCom.pPanel, szWnd)
	end,
	CheckClickScreen = function (self, tbStep, szParam)
		tbStep.bCheckClickScreen = true
	end,
	CheckAniFinish = function (self, tbStep, szParam)
		tbStep.szCheckAniFinish = szParam
	end,
	CheckTaskFinish = function (self, tbStep, szParam)
		tbStep.nTaskId = tonumber(szParam)
	end,
}

function tbBase:CheckOpenUi(szUi)
	if self.tbCurStep and self.tbCurStep.szCheckOpenUi == szUi then
		return true;
	end
	return false;
end

function tbBase:CheckClickScreen()
	if self.tbCurStep then
		return self.tbCurStep.bCheckClickScreen;
	end
	return false;
end

function tbBase:CheckClickWnd(tbWndCom, nClickKey)
	if self.tbCurStep and self.tbCurStep.nClickKey == nClickKey then
		return true;
	end	
	return false;
end

function tbBase:CheckUiAnimation(szUi, szAniName)
	if self.tbCurStep and self.tbCurStep.szCheckAniFinish == (szUi.."|"..szAniName) then
		return true;
	end	
	return false;
end

function tbBase:CheckTaskFinish(nTaskId)
	if self.tbCurStep and self.tbCurStep.nTaskId == nTaskId then
		return true;
	end	
	return false;
end

function tbBase:GetUiWndByParam(szParam)
	if szParam == "" then
		return;
	end
	local tbParam = Lib:SplitStr(szParam, "|")
	if not tbParam[1] then
		return;
	end
	local tbWnd = Ui(tbParam[1])
	if not tbWnd then
		Log("Guide LockWnd unexist wnd:", unpack(tbParam));
		return;
	end
	for i = 2, #tbParam - 1 do
		tbWnd = tbWnd[tbParam[i]]
		if not tbWnd then
			Log("Guide LockWnd unexist wnd:", unpack(tbParam));
			return;
		end
	end
	
	local szWnd = tbParam[#tbParam]
	
	return tbWnd, szWnd
end

function tbBase:__LockWnd(szParam, bDisableClick, bBlackBg)
	if szParam and szParam ~= "" then
		local tbWndCom, szWnd = self:GetUiWndByParam(szParam);
		if tbWndCom and szWnd then
			self:ShowGuide(bDisableClick, bBlackBg, tbWndCom.pPanel, szWnd)
		else
			return false;
		end
	else
		self:ShowGuide(bDisableClick, bBlackBg)
	end
	return true
end

function tbBase:LockWnd(szParam)
	return self:__LockWnd(szParam, true, true)
end

function tbBase:LockWndNoBg(szParam)
	return self:__LockWnd(szParam, true, false)
end

function tbBase:LockWndFree(szParam)
	return self:__LockWnd(szParam, false, false)
end

function tbBase:UnLockWnd()
	Ui:CloseWindow("Guide")
	return true;
end

function tbBase:Commander(szParam)
	local szLoadString = szParam
	local fnExc = loadstring(szLoadString);
	if fnExc then
		xpcall(fnExc, Lib.ShowStack);
	end
	Ui:CloseWindow("Guide");
	return true;
end

function tbBase:ShowGuide(bDisableClick, bBlackBg, pPanel, szWnd)
--	if Ui:WindowVisible("Guide") == 1 then
--		Ui("Guide"):BeginStep(self.tbCurStep.szDescType, self.tbCurStep.szDesc, pPanel, szWnd)
--	else
		Ui:OpenWindow("Guide", self.tbCurStep.szDescType, self.tbCurStep.szDesc, pPanel, szWnd, self.tbCurStep.tbPointer, bDisableClick, bBlackBg)
--	end
end

