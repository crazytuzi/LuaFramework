--[[封妖界面：奖励面板
]]
_G.UIFengyaoReward = BaseUI:new("UIFengyaoReward");
function UIFengyaoReward:Create()
	self:AddSWF("fengyaoRewardPanel.swf", true, "center")
end

function UIFengyaoReward:OnLoaded(objSwf, name)
	objSwf.btnConfirm.click = function() self:OnBtnConfirm1Click(); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	RewardManager:RegisterListTips(objSwf.list);
end
function UIFengyaoReward:OnShow(name)
	self:UpdateShow();
	self:StartTimer();
end
function UIFengyaoReward:OnBtnConfirm1Click()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 0)
	end
end
function UIFengyaoReward:OnBtnCloseClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 0)
	end
end
function UIFengyaoReward:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	-- 文本显示
	objSwf.txtPrompt.htmlText = string.format( StrConfig['quest111'], FengYaoModel.fengyaoinfo.finishCount+1 )
	-- WriteLog(LogType.Normal,true,'---------------------UILoadingScene:OnShow()',FengYaoModel.fengyaoinfo.finishCount)
	-- objSwf.txtZhenqi.text = _G.getNumShow( rewardZhenqi )
	-- 图标
	if FengYaoModel.fengyaoinfo.fengyaoId ~= 0 then
		local fengyaovo = FengYaoUtil:GetFengYaoListVO(FengYaoModel.fengyaoinfo.fengyaoId);
		if fengyaovo then
			local reward = nil;
			if FengYaoModel.fengyaoinfo.finishCount	> t_consts[19].val3-1 then
				reward = fengyaovo.itemReward_1
			else
				reward = fengyaovo.itemReward
			end
			local rewardList = RewardManager:Parse(enAttrType.eaExtremityVal..","..fengyaovo.finish_score,reward);
			
			local uiList = objSwf.list
			uiList.dataProvider:cleanUp()
			uiList.dataProvider:push( unpack(rewardList) )
			uiList:invalidateData()
			local itemList = {};
			itemList[1] = objSwf.item1;
			itemList[2] = objSwf.item2;
			itemList[3] = objSwf.item3;
			itemList[4] = objSwf.item4;
			itemList[5] = objSwf.item5;
			UIDisplayUtil:HCenterLayout(#rewardList, itemList, 64, 278, 166);
			itemList = nil;	
		end
	end

end
---------------------------------倒计时处理--------------------------------
local time;
local timerKey;
function UIFengyaoReward:StartTimer()
	time = 15;
	local func = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIFengyaoReward:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
	self:UpdateCountDown();
end

function UIFengyaoReward:OnTimeUp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	--是否可领奖
	if FengYaoModel.fengyaoinfo.curState == FengYaoConsts.ShowType_NoAward then
		FengYaoController:ReqGetFengYaoReward(FengYaoModel.fengyaoinfo.fengyaoId, 0)
	end
end

function UIFengyaoReward:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:HideCountDown();
	end
end

function UIFengyaoReward:HideCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime._visible = false;
end

function UIFengyaoReward:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local txtTime = objSwf.txtTime;
	if not txtTime._visible then
		txtTime._visible = true;
	end
	-- WriteLog(LogType.Normal,true,'---------------------UIFengyaoReward:UpdateCountDown()',time)
	objSwf.txtTime.htmlText = string.format( StrConfig['quest112'], time );
end

function UIFengyaoReward:OnHide()
	self:StopTimer();
end
--监听消息
function UIFengyaoReward:ListNotificationInterests()
	return {
		NotifyConsts.FengYaoBaoScoreAdd,
	};
end

--消息处理
function UIFengyaoReward:HandleNotification( name, body )
	if name == NotifyConsts.FengYaoBaoScoreAdd then
		self:Hide()
	end
end