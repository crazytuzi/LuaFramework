--[[
	商业活动  (本日充值)
	2015年10月12日, PM 04:59:58
]]

_G.UIOperactivitesBusiness = BaseUI:new('UIOperactivitesBusiness');
UIOperactivitesBusiness.remainTime = 0
UIOperactivitesBusiness.timerKey = nil;
UIOperactivitesBusiness.lastTime = 0
function UIOperactivitesBusiness:Create()
	self:AddSWF('operactivitesBusiness.swf',true,nil);
end

function UIOperactivitesBusiness:OnLoaded(objSwf)
	-- 充值 vip
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
end

function UIOperactivitesBusiness:OnBtnChargeClick()
	Version:Charge()
end

function UIOperactivitesBusiness:OnShow()
	local group = OperActUIManager.currentGroupId	
	OperactivitiesController:RespPartyInfo(group)
	self.timerCount = 0
end

function UIOperactivitesBusiness:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId	
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetListData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	local mainType, subType = OperactivitiesModel:GetOperActType(group)
	local mainType1, subType1 = OperactivitiesModel:GetOperActType1(group)
	if not mainType1 then
		mainType1 = -1
	end
	if mainType == 1 or mainType == 2 or mainType1 == 10 or mainType == 10 or mainType == 104 then
		objSwf.btnCharge.visible = true
	else
		objSwf.btnCharge.visible = false
	end
	
	objSwf.labTotalGold._visible = false
	objSwf.txtTotalGold._visible = false
	objSwf.labTotalPeople._visible = false
	objSwf.txtTotalPeople._visible = false
	if mainType == 1 then
		objSwf.labTotalGold.htmlText = UIStrConfig["operactivites4"]
		objSwf.labTotalGold._visible = true
		objSwf.txtTotalGold._visible = true
		objSwf.txtTotalGold.text = OperactivitiesModel:GetTotalMoney(group)..'元宝'
	elseif mainType == 11 then
		objSwf.labTotalGold._visible = true
		objSwf.labTotalGold.htmlText = UIStrConfig["operactivites16"]
		objSwf.txtTotalGold._visible = true
		objSwf.txtTotalGold.text = OperactivitiesModel:GetTotalMoney(group)..'元宝'
	elseif mainType == 10 or mainType1 == 10 then
		objSwf.labTotalGold._visible = true
		objSwf.labTotalGold.htmlText = UIStrConfig["operactivites4"]
		objSwf.txtTotalGold._visible = true
		objSwf.txtTotalGold.text = OperactivitiesModel:GetTotalMoney1(group)..'元宝'
	elseif mainType == 104 then
		objSwf.labTotalPeople._visible = true
		objSwf.labTotalPeople.text = UIStrConfig['operactivites10']
		objSwf.txtTotalPeople._visible = true
		objSwf.txtTotalPeople._y = 162
		objSwf.labTotalPeople._y = 162
		local nValue = OperactivitiesModel:GetTotalPeople(group)
		if nValue >= 200 then
			nValue = ">200人"
		else
			nValue = nValue .. "人"
		end
		objSwf.txtTotalPeople.text = nValue
	-- elseif mainType == 105 then
	-- 	if subType == 1 then
	-- 		objSwf.labTotalPeople.text = UIStrConfig['operactivites17']
	-- 	else
	-- 		objSwf.labTotalPeople.text = UIStrConfig['operactivites18']
	-- 	end
	-- 	objSwf.labTotalPeople._visible = true
	-- 	objSwf.txtTotalPeople._visible = true
	-- 	objSwf.txtTotalPeople._y = 162
	-- 	objSwf.labTotalPeople._y = 162
	-- 	local nValue = OperactivitiesModel:GetTotalMoney(group)
	-- 	objSwf.txtTotalPeople.text = nValue .. "天"
	end
	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = ""
	
	
	local imgUrl = OperactivitiesModel:GetGroupImageByGroupId(group)
	if imgUrl and imgUrl ~= "" then
		imgUrl = ResUtil:GetOperActivityIcon(imgUrl)
		if imgUrl ~= objSwf.imgshow.source then
			objSwf.imgshow.source = imgUrl		
		end
	else
		objSwf.imgshow.source = ""
	end
	
	self.remainTime = OperactivitiesModel:GetGroupRemainTimeByGroupId(group)
	if self.remainTime and self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
	
end

function UIOperactivitesBusiness : Ontimer()
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
	if self.remainTime <= -10 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
			
		end;
		UIMainOperActivites:Hide()
		--Notifier:sendNotification(NotifyConsts.UpdateGroupItemList, {isShowFirst=true});
	end
	

	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		
		-- self:UpdateUI()	
		UIMainOperActivites:Hide()
		-- Notifier:sendNotification(NotifyConsts.UpdateGroupItemList, {isShowFirst=true}); 
	end	

	if self.timerCount >=10 and self.timerCount%10 == 0 then
		local group = OperActUIManager.currentGroupId
		local mainType, subType = OperactivitiesModel:GetOperActType(group)
		if mainType == 104 then
			OperactivitiesController:ReqPartyGroupPurchaseFirst(group)
		end
	end

	self.timerCount = self.timerCount + 1
end;

function UIOperactivitesBusiness:OnHide()
	self.timerCount = 0
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

--所有数据
function UIOperactivitesBusiness:GetListData()
	--将可领奖的放在上面  拆分，排序，重组
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]	
	FPrint('UIOperactivitesBusiness:GetListData所有数据'..group)
	-- FTrace(actList)

	local list = {}
	local vo;
	for i , v in ipairs(actList) do		
		vo = {};
		vo.id = v.id	
		vo.eachTxt = v.eachTxt or '没有配:id'..v.id
		if not v.reward then v.reward = '' end
		vo.reward = v.reward or ''
		local getcount = v.count or 0
		local rtime = v.receiveTime or 0
		local num = rtime - getcount
		if not num or num < 0 then num = 0 end
		vo.receiveTime = num
		vo.mainType = mainType
		vo.isAward = v:GetIsArawdState() or 0
		
		if vo.isAward ~= 2 and (v.mainType == 5 or v.mainType == 10) then
			if v.mainType == 5 then
				vo.peopletxt = v.progress
				vo.peopleLabel = "当前阶数："
			else
				vo.peopletxt = v.progress
				vo.peopleLabel = "当前人数："
			end
		else
			vo.peopletxt = ""
			vo.peopleLabel = ""
		end
		vo.isDacheng = v:GetFirstChargePeopleIsDacheng()
		
		-- vo.progress = OperactivitiesModel:GetActPrecess(v.id)
		local majorStr = UIData.encode(vo);
		FPrint(v.id)
		FPrint(v.reward)
		local rewardList = RewardManager:Parse( v.reward);
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list
end
function UIOperactivitesBusiness:PlayYilingqu(actId)
	local objSwf = self.objSwf
	if not objSwf then return end
	local group = OperActUIManager.currentGroupId
	local actList = OperactivitiesModel.groupList[group]	

	for i , v in ipairs(actList) do	
		if v.id == actId then
			local vo = {};
			vo.id = v.id	
			vo.eachTxt = v.eachTxt or '没有配:id'..v.id
			if not v.reward then v.reward = '' end
			vo.reward = v.reward or ''
			local getcount = v.count or 0
			local rtime = v.receiveTime or 0
			local num = rtime - getcount
			if not num or num < 0 then num = 0 end
			vo.receiveTime = num
			vo.isAward = v.isAward or 0--是否已领取
			vo.mainType = mainType
			if vo.isAward ~= 2 and (v.mainType == 5 or v.mainType == 10) then
				if v.mainType == 5 then
					vo.peopletxt = v.progress
					vo.peopleLabel = "当前阶数："
				else
					vo.peopletxt = v.progress
					vo.peopleLabel = "当前人数："
				end
			else
				vo.peopletxt = ""
				vo.peopleLabel = ""
			end

			local majorStr = UIData.encode(vo);
			FPrint(v.id)
			FPrint(v.reward)
			local rewardList = RewardManager:Parse( v.reward);
			local rewardStr = table.concat(rewardList, "*");
			local finalStr = majorStr .. "*" .. rewardStr;
			
			self.objSwf.list.dataProvider[i - 1] = finalStr
			local uiSlot = self.objSwf.list:getRendererAt(i - 1)
			if uiSlot then
				uiSlot:setData(finalStr);
				if  v.isAward == 2 then
					uiSlot:PlayYilingqu()
					OperactivitiesModel:GoRewardfun(uiSlot, v.reward)
				end
			end
		end
	end
end

--领奖点击
function UIOperactivitesBusiness:GetRewardClick(e)
	if GetCurTime() - self.lastTime > 300 then
		if e.item.isAward ~= 1 and e.item.mainType == 1 then
			local chargefunc = function ()
				Version:Charge()
			end
			UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
			return
		end
		OperactivitiesController:ReqGetPartyAward(e.item.id, 1)	
		self.lastTime = GetCurTime()
	end
end

function UIOperactivitesBusiness:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
		NotifyConsts.UpdateTeamBuyFirstInfo
	}
end

function UIOperactivitesBusiness:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:PlayYilingqu(body.actId)
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateTeamBuyFirstInfo then
		self:UpdateUI()
		Notifier:sendNotification(NotifyConsts.UpdateGroupItemList)
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			local mainType, subType = OperactivitiesModel:GetOperActType(group)
			if mainType == 104 then
				OperactivitiesController:ReqPartyGroupPurchaseFirst(group)	
			else
				self:UpdateUI()
			end
		end
	end	
end

