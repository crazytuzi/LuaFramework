--[[
	商业活动  (首冲团购)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesTeamBuyFirst = BaseUI:new('UIOperactivitesTeamBuyFirst');
UIOperactivitesTeamBuyFirst.remainTime = 0
UIOperactivitesTeamBuyFirst.timerKey = nil;
UIOperactivitesTeamBuyFirst.timerCount = 0;
UIOperactivitesTeamBuyFirst.isShowEffect = 0
UIOperactivitesTeamBuyFirst.lastTime = 0
UIOperactivitesTeamBuyFirst.buyItemId = 0
function UIOperactivitesTeamBuyFirst:Create()
	self:AddSWF('operactivitesFirstChargeTeamBuy.swf',true,nil);
end

function UIOperactivitesTeamBuyFirst:OnLoaded(objSwf)
	objSwf.btn_getReward.click = function (e) 		
		if OperActivity1Btn:IsShow() then
			OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconShouchong)
		end	
	end
	objSwf.buyItem.rollOver = function(e) 
		-- if self.buyItemId and self.buyItemId > 0 then
				
		local itemConstCfg = t_consts[124]
		local itemId = toint(itemConstCfg.val1)
		local itemNum = toint(itemConstCfg.val2)	
		if itemId and itemId > 0 then
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.buyItem.rollOut = function(e) TipsManager:Hide(); end 
	
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
end

--领奖点击
function UIOperactivitesTeamBuyFirst:GetRewardClick(e)
	local actVO = OperactivitiesModel:GetActVOById(e.item.id)
	if not actVO then return end
	if not actVO.reward then actVO.reward = '' end
	
	local tipState, tipStr = OperactivitiesModel:GetTeamBuyFirstIsAward(actVO, 1)
	if tipState == 2 then				
		UIConfirm:Open(tipStr)
		return
	elseif tipState <= 0 then	
		UIConfirm:Open(StrConfig['operactivites14']..tipStr)
		return
	end
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		local rewardList = split(actVO.reward,'#')			
		OperactivitiesModel:GoRewardfun(e.renderer.item1, rewardList[1])
		OperactivitiesController:ReqGetPartyAward(actVO.id, 1)
		self.lastTime = GetCurTime()
	end
end

function UIOperactivitesTeamBuyFirst:OnShow()	
	-- self:UpdateUI()
	self.isShowEffect = 0
	self.timerCount = 0
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
	
	
end

function UIOperactivitesTeamBuyFirst:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetListData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	local group = OperActUIManager.currentGroupId	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = 0
	
	self.remainTime = OperactivitiesModel:GetGroupRemainTimeByGroupId(group)
	if self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
end

function UIOperactivitesTeamBuyFirst : Ontimer()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.remainTime or self.remainTime < 0 then self.remainTime = 0 end
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(self.remainTime)
	if day > 0 then
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites6"],day,hour,mint);
	else
		objSwf.txtRemindTime.text = string.format(StrConfig["operactivites7"],hour,mint);
	end
	
	self.remainTime = self.remainTime - 1
	if not self.isSendDaoqi then
		if self.remainTime <= -10 then
			self.isSendDaoqi = true
			if self.timerKey then 
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
				
			end;
			UIMainOperActivites:Hide()
			-- UIMainOperActivites:Show()
			--Notifier:sendNotification(NotifyConsts.UpdateGroupItemList, {isShowFirst=true});
		end
	end
	
	if self.timerCount >=10 and self.timerCount%10 == 0 then
		local group = OperActUIManager.currentGroupId
		FPrint('团购的自动请求:'..group)
		OperactivitiesController:ReqPartyGroupPurchaseFirst(group)	
	end
	
	if not self.isSendKuatian then		
		local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
		FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
		if hour == 0 and mint == 0 and sec == 10 then
			self.isSendKuatian = true
			if self.timerKey then 
				TimerManager:UnRegisterTimer(self.timerKey);
				self.timerKey = nil;
			end;
			UIMainOperActivites:Hide()
			-- UIMainOperActivites:Show()
			-- self:UpdateUI()			
			--Notifier:sendNotification(NotifyConsts.UpdateGroupItemList, {isShowFirst=true}); 
		end
	end
	self.timerCount = self.timerCount + 1
end;

function UIOperactivitesTeamBuyFirst:OnHide()
	self.timerCount = 0
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

--所有数据
--1达成首充2需已购买%s次 
local groupbuyRequireStr = {StrConfig['operactivites16'],StrConfig['operactivites17']}
function UIOperactivitesTeamBuyFirst:GetListData()
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]
	-- FTrace(actList, 'UIOperactivitesTeamBuyFirst:GetListData所有数据')
	local list = {}
	for i , v in ipairs(actList) do				
		if i == 1 then
			self:UpdateTeamItem(v)
		end		
		local vo = {};
		vo.id = v.id	
		vo.eachTxt = v.eachTxt or '没有配:id'..v.id		
		if not v.reward then v.reward = '' end
		
		vo.isAward = OperactivitiesModel:GetTeamBuyFirstIsAward(v, 1)
		--if vo.isAward == 0 then vo.isAward = 1 end
		vo.isShowEffect = self.isShowEffect
		vo.reward = v.reward
		
		local majorStr = UIData.encode(vo);
		
		local rewardList = RewardManager:Parse( v.reward );
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	self.isShowEffect = 0
	return list
end

function UIOperactivitesTeamBuyFirst:UpdateTeamItem(v)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 团购的东西
	local itemConstCfg = t_consts[124]
	local itemId = toint(itemConstCfg.val1)
	self.buyItemId = itemId
	local itemNum = toint(itemConstCfg.val2)		
	
	if not v.param then v.param = '' end
	if not v.chargenum then v.chargenum = 0 end
	if not v.groupbuyRequire then v.groupbuyRequire = '' end
	if not v.reward then v.reward = '' end
			
	local paramList = split(v.param,',')
	local maxNum = 0
	if t_consts[184] then maxNum = t_consts[184].val1 end
	-- for k,v in pairs (paramList) do
		-- v = toint(v) 
		-- maxNum = math.max(maxNum, v)
	-- end
	if v.chargenum > maxNum then
		objSwf.txtTotalNum.text = '>'.. maxNum ..StrConfig['operactivites22']--本服累计售出
	else
		objSwf.txtTotalNum.text = v.chargenum ..StrConfig['operactivites22']--本服累计售出
	end
	
	if OperActivity1Btn:IsShow() then
		objSwf.mcYilingqi._visible = false
		objSwf.btn_getReward._visible = true
	else
		objSwf.mcYilingqi._visible = true
		objSwf.btn_getReward._visible = false
	end
		
	local rewardSlotVO = RewardSlotVO:new();
	rewardSlotVO.id = itemId
	rewardSlotVO.count = itemNum
	objSwf.buyItem:setData(rewardSlotVO:GetUIData());
end

--领奖点击
-- function UIOperactivitesTeamBuyFirst:GetRewardClick(id)
	-- FPrint('领奖点击'..id)
	
	-- OperactivitiesController:ReqGetPartyAward(id, 1)
-- end

function UIOperactivitesTeamBuyFirst:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateTeamBuyFirstInfo,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesTeamBuyFirst:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self.isShowEffect = 1
		self:UpdateUI()	
	elseif name == NotifyConsts.UpdateTeamBuyFirstInfo then
		self:UpdateUI()
		Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			OperactivitiesController:ReqPartyGroupPurchaseFirst(group)	
		end
	end	
end