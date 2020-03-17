--[[
	商业活动  (本日充值)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesTeamBuy = BaseUI:new('UIOperactivitesTeamBuy');
UIOperactivitesTeamBuy.remainTime = 0
UIOperactivitesTeamBuy.timerKey = nil;
UIOperactivitesTeamBuy.timerCount = 0;
UIOperactivitesTeamBuy.isShowEffect = 0
UIOperactivitesTeamBuy.lastTime = 0
function UIOperactivitesTeamBuy:Create()
	self:AddSWF('operactivitesTeamBuy.swf',true,nil);
end

function UIOperactivitesTeamBuy:OnLoaded(objSwf)
	objSwf.list.handlerBuyClick = function (e) 
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		local moneyNum = e.item.gold
		
		local item1List = actVO.groupbuyItem or {}
		local itemId = toint(item1List[1].ID)
		local itemNum = toint(item1List[2].ID)
		
		local num = toint(e.item.num)
		if num <= 0 then
			self.confirmID = UIConfirm:Open(StrConfig['operactivites18']);
			return
		end
		
		local okfun = function() 
			
			OperactivitiesModel:GoRewardfun(e.renderer, itemId..','..itemNum)
			OperactivitiesController:ReqPartyBuy(actVO.id)	
		end;
		local nofun = function() end;
		
		local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
		if myYuanbao < moneyNum then
			local chargefunc = function ()
				Version:Charge()
			end
			if self.confirmID then
				UIConfirm:Close(self.confirmID);
			end
				self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
			return
		end
		
		UIConfirm:Open(string.format(StrConfig["operactivites10"], moneyNum),okfun,nofun)
		
	end
	objSwf.list.handleBuyItemRollOver = function(e) 
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		
		local item1List = actVO.groupbuyItem or {}
		local itemId = toint(item1List[1].ID)
		local itemNum = toint(item1List[2].ID)
		if itemId and itemId > 0 then
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.list.handleRewardItemRollOut = function(e) TipsManager:Hide(); end
	
	objSwf.list.handleRewardItemRollOver1 = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local rewardlist = split(actVO.reward, '#')
		if rewardlist[1] then
			local itemList = split(rewardlist[1], ',')
			local itemId = toint(itemList[1])
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.list.handleRewardItemRollOver2 = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local rewardlist = split(actVO.reward, '#')
		if rewardlist[2] then
			local itemList = split(rewardlist[2], ',')
			local itemId = toint(itemList[1])
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.list.handleRewardItemRollOver3 = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local rewardlist = split(actVO.reward, '#')
		if rewardlist[3] then
			local itemList = split(rewardlist[3], ',')
			local itemId = toint(itemList[1])
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.list.handleRewardItemRollOver4 = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local rewardlist = split(actVO.reward, '#')
		if rewardlist[4] then
			local itemList = split(rewardlist[4], ',')
			local itemId = toint(itemList[1])
			TipsManager:ShowItemTips(itemId);
		end
	end
	objSwf.list.handlerReward1Click = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local tipState, tipStr = OperactivitiesModel:GetTeamBuyIsAward(actVO, 1)
		if tipState == 2 then				
			UIConfirm:Open(tipStr)
			return
		elseif tipState <= 0 then	
			UIConfirm:Open(StrConfig['operactivites14']..tipStr)
			return
		end
		
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
			local rewardList = split(actVO.reward,'#')	
			OperactivitiesModel:GoRewardfun(e.renderer.reward1, rewardList[1])
			OperactivitiesController:ReqGetPartyAward(actVO.id, 1)
			self.lastTime = GetCurTime()
		end
	end
	objSwf.list.handlerReward2Click = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local tipState, tipStr = OperactivitiesModel:GetTeamBuyIsAward(actVO, 2)
		if tipState == 2 then				
			UIConfirm:Open(tipStr)
			return
		elseif tipState <= 0 then	
			UIConfirm:Open(StrConfig['operactivites14']..tipStr)
			return
		end
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then		
			local rewardList = split(actVO.reward,'#')
			OperactivitiesModel:GoRewardfun(e.renderer.reward2, rewardList[2])
			OperactivitiesController:ReqGetPartyAward(actVO.id, 2)
			self.lastTime = GetCurTime()
		end
	end
	objSwf.list.handlerReward3Click = function(e) 
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local tipState, tipStr = OperactivitiesModel:GetTeamBuyIsAward(actVO, 3)
		if tipState == 2 then				
			UIConfirm:Open(tipStr)
			return
		elseif tipState <= 0 then	
			UIConfirm:Open(StrConfig['operactivites14']..tipStr)
			return
		end
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then	
			local rewardList = split(actVO.reward,'#')
			OperactivitiesModel:GoRewardfun(e.renderer.reward3, rewardList[3])
			OperactivitiesController:ReqGetPartyAward(actVO.id, 3)
			self.lastTime = GetCurTime()
		end
	end
	objSwf.list.handlerReward4Click = function(e)
		local actVO = OperactivitiesModel:GetActVOById(e.item.id)
		if not actVO then return end
		if not actVO.reward then actVO.reward = '' end
		
		local tipState, tipStr = OperactivitiesModel:GetTeamBuyIsAward(actVO, 4)
		if tipState == 2 then				
			UIConfirm:Open(tipStr)
			return
		elseif tipState <= 0 then	
			UIConfirm:Open(StrConfig['operactivites14']..tipStr)
			return
		end
		if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
			local rewardList = split(actVO.reward,'#')
			OperactivitiesModel:GoRewardfun(e.renderer.reward4, rewardList[4])
			OperactivitiesController:ReqGetPartyAward(actVO.id, 4)
			self.lastTime = GetCurTime()
		end
	end
end

function UIOperactivitesTeamBuy:OnShow()	
	-- self:UpdateUI()
	self.isShowEffect = 0
	self.timerCount = 0
	local group = OperActUIManager.currentGroupId	
	
	OperactivitiesController:RespPartyInfo(group)
	
	
end

function UIOperactivitesTeamBuy:UpdateUI()
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

function UIOperactivitesTeamBuy : Ontimer()
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
		OperactivitiesController:ReqPartyGroupPurchase(group)	
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

function UIOperactivitesTeamBuy:OnHide()
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
function UIOperactivitesTeamBuy:GetListData()
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]
	-- FTrace(actList, 'UIOperactivitesTeamBuy:GetListData所有数据')
	local list = {}
	for i , v in ipairs(actList) do				
		-- 团购的东西
		local item1List = v.groupbuyItem
		local vo1 = {}
		local itemId = toint(item1List[1].ID)
		local itemNum = toint(item1List[2].ID)
		local itemCfg = t_item[itemId]
		vo1.id = v.id
		vo1.eachTxt = v.eachTxt or ''
		if not v.mypurchase then v.mypurchase = 0 end
		if not v.groupbuyPrice then v.groupbuyPrice = 0 end
		if not v.param then v.param = '' end
		if not v.totalpurchase then v.totalpurchase = 0 end
		if not v.groupbuyRequire then v.groupbuyRequire = '' end
		if not v.reward then v.reward = '' end
		
		local rtime = v.receiveTime or 0
		local num = rtime- v.mypurchase
		if not num or num < 0 then num = 0 end
		vo1.num = num--剩余购买次数
		vo1.gold = v.groupbuyPrice
		local paramList = split(v.param,',')
		local maxNum = 0
		for k,v in pairs (paramList) do
			v = toint(v) 
			maxNum = math.max(maxNum, v)
		end
		if v.totalpurchase > maxNum then
			vo1.totalNum = '>'.. maxNum ..StrConfig['operactivites22']--本服累计售出
		else
			vo1.totalNum = v.totalpurchase ..StrConfig['operactivites22']--本服累计售出
		end
		
		local rewardSlotVO = RewardSlotVO:new();
		rewardSlotVO.id = itemId or 0
		rewardSlotVO.count = itemNum or 0
		-- rewardSlotVO.bind = itemCfg.bind ;
		local item1Str = UIData.encode(vo1) .. '*' .. rewardSlotVO:GetUIData()
		-- 奖励列表
		local rewardList = split(v.reward,'#')
		
		local groupbuyRequireList = split(v.groupbuyRequire,'#')		
		
		local index = 1
		for rewardKey, rewardStr in pairs (rewardList) do
			local rewardVO = {}
			local rewardList = split(rewardStr,',')
			local itemId = toint(rewardList[1])
			local itemNum = toint(rewardList[2])
			local itemCfg = t_item[itemId]
			rewardVO.totalNum = paramList[rewardKey]..StrConfig['operactivites23']
			local requireList = split(groupbuyRequireList[rewardKey], ',')
			if toint(requireList[1]) == 1 then
				rewardVO.requireStr = groupbuyRequireStr[1]
			elseif toint(requireList[1]) == 2 then
				rewardVO.requireStr = string.format(groupbuyRequireStr[2], requireList[2])
			elseif toint(requireList[1]) == 0 then
				rewardVO.requireStr = StrConfig['operactivites24']
			else
				rewardVO.requireStr = ''
			end			
			rewardVO.isAward = OperactivitiesModel:GetTeamBuyIsAward(v, index)
			rewardVO.isShowEffect = self.isShowEffect
			local rewardSlotVO = RewardSlotVO:new();
			rewardSlotVO.id = itemId
			rewardSlotVO.count = itemNum
			-- rewardSlotVO.bind = itemCfg.bind ;
			item1Str = item1Str..'*' .. UIData.encode(rewardVO) .. '*' .. rewardSlotVO:GetUIData()
			index = index + 1
		end		
		table.push(list, item1Str);		
	end
	self.isShowEffect = 0
	return list
end

--领奖点击
-- function UIOperactivitesTeamBuy:GetRewardClick(id)
	-- FPrint('领奖点击'..id)
	
	-- OperactivitiesController:ReqGetPartyAward(id, 1)
-- end

function UIOperactivitesTeamBuy:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateTeamBuyInfo,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesTeamBuy:HandleNotification( name, body )
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
	elseif name == NotifyConsts.UpdateTeamBuyInfo then
		self:UpdateUI()
		Notifier:sendNotification(NotifyConsts.UpdateGroupItemList); 
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			OperactivitiesController:ReqPartyGroupPurchase(group)	
		end
	end	
end