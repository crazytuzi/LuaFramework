--[[
	展示
	2015年10月12日, PM 08:15:41
]]

_G.UIOperactivitesShow = BaseUI:new('UIOperactivitesShow');
UIOperactivitesShow.showCount = 3
UIOperactivitesShow.actList = {}
UIOperactivitesShow.currentIndex = 1
UIOperactivitesShow.remainTime = 0
UIOperactivitesShow.timerKey = nil;
UIOperactivitesShow.showModel = {}
UIOperactivitesShow.lastTime = 0

function UIOperactivitesShow:Create()
	self:AddSWF('operactivitesShow.swf',true,nil);
end

function UIOperactivitesShow:OnLoaded(objSwf)
	objSwf.btnPre.click = function() 
		self.currentIndex = self.currentIndex - 1
		if self.currentIndex <= 1 then self.currentIndex = 1 end
		self:UpdateUI()
	end
	objSwf.btnNext.click = function()
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex >= #self.actList - self.showCount + 1 then self.currentIndex = #self.actList - self.showCount + 1 end
		self:UpdateUI()
	end
	
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
end

function UIOperactivitesShow:OnShow()
	local group = OperActUIManager.currentGroupId	
	
		OperactivitiesController:RespPartyInfo(group)
	
end

function UIOperactivitesShow:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	local group = OperActUIManager.currentGroupId	
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetListData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtRemindTime.text = ""
	objSwf.txtTotalGold.text = ""
	
	self:UpdateBtnState()
	
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
	if self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
	
	self:Show3DWeapon()
end

function UIOperactivitesShow : Ontimer()
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
			-- Notifier:sendNotification(NotifyConsts.UpdateGroupItemList, {isShowFirst=true});
		end
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
end;

function UIOperactivitesShow:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	
	local name = 'UIOperactivitesShow1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw1 then
		self.objUIDraw1:SetDraw(false);
	end
	
	name = 'UIOperactivitesShow2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw2 then
		self.objUIDraw2:SetDraw(false);
	end
	
	name = 'UIOperactivitesShow3'
	local objUIDraw3 = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw3 then
		self.objUIDraw3:SetDraw(false);
	end
end

function UIOperactivitesShow:OnDelete()
	local name = 'UIOperactivitesShow1'
	local objUIDraw1 = UIDrawManager:GetUIDraw(name);
	if objUIDraw1 then
		objUIDraw1:SetUILoader(nil);
	end
	
	name = 'UIOperactivitesShow2'
	local objUIDraw2 = UIDrawManager:GetUIDraw(name);
	if objUIDraw2 then
		objUIDraw2:SetUILoader(nil);
	end
	
	name = 'UIOperactivitesShow3'
	local objUIDraw3 = UIDrawManager:GetUIDraw(name);
	if objUIDraw3 then
		objUIDraw3:SetUILoader(nil);
	end
end

function UIOperactivitesShow:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnNext.disabled = false
	objSwf.btnPre.disabled = false
	if self.currentIndex <= 1 then
		objSwf.btnPre.disabled = true
	end
	
	if self.currentIndex >= #self.actList - self.showCount + 1 then
		objSwf.btnNext.disabled = true
	end
end

--所有数据
function UIOperactivitesShow:GetListData()
	--将可领奖的放在上面  拆分，排序，重组
	local group = OperActUIManager.currentGroupId	
	self.actList = OperactivitiesModel.groupList[group]	
	FPrint('UIOperactivitesShow:GetListData所有数据'..group)
	-- FTrace(self.actList)
	
	local list = {}
	local vo;
	local index = 1
	self.showModel[1] = ""
	self.showModel[2] = ""
	self.showModel[3] = ""
	for i , v in ipairs(self.actList) do
		if i >= self.currentIndex and i <= self.currentIndex + self.showCount then
			vo = {};
			vo.id = v.id	
			vo.txtName = v.eachTxt or 'cannotfindid'..v.id
			
			local itemCfg = nil
			local itemNum = 0
			if v.consume then
				local itemList = split(v.consume, ',')
				-- FPrint('消耗的id'..v.consume[1].ID)
				itemCfg = t_item[toint(itemList[1])]
				itemNum = toint(itemList[2])
			end
			
			-- local awardState = v:GetIsArawdState()
			-- if awardState then
				-- vo.isAward = 1			
			-- else
				-- vo.isAward = 0
			-- end
			vo.isAward = v:GetIsArawdState() or 0
			vo.txtMoney = ""
			if itemCfg then
				vo.txtMoney = itemNum..itemCfg.name
			end
			local getcount = v.count or 0
			local rtime = v.receiveTime or 0
			local num = rtime - getcount
			if not num or num < 0 then num = 0 end
			vo.txtBuynum = num
			local majorStr = UIData.encode(vo);
			if not v.reward then v.reward = '' end
			local rewardList = RewardManager:Parse( v.reward );
			local rewardStr = table.concat(rewardList, "*");
			local finalStr = majorStr .. "*" .. rewardStr;
			table.push(list, finalStr);	
			
			self.showModel[index] = OperactivitiesModel:GetModelScene(v.showModel)			
			index = index + 1
		end	
	end
	return list
end

function UIOperactivitesShow:PlayYilingqu(actId)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local group = OperActUIManager.currentGroupId
	local actList = OperactivitiesModel.groupList[group]	
	
	local list = {}
	local vo;
	for i , v in ipairs(actList) do	
		if v.id == actId then	
			if v.reward and v.reward ~= '' then
				local uiSlot = self.objSwf.list:getRendererAt(i - 1)
				if uiSlot then
					OperactivitiesModel:GoRewardfun(uiSlot, v.reward)
				end
			end
		end
	end	
end

--领奖点击
function UIOperactivitesShow:GetRewardClick(e)
	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
		FPrint('领奖点击'..e.item.id)	
		OperactivitiesModel:GoRewardfun(e.renderer, e.item.reward)
		OperactivitiesController:ReqGetPartyAward(e.item.id, 1)
		self.lastTime = GetCurTime()
	end
end

function UIOperactivitesShow:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesShow:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.OperActivityInitInfo then
		-- self:UpdateUI()
	elseif name == NotifyConsts.OperActivityInitState then
		self:UpdateUI()
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:UpdateUI()
		self:PlayYilingqu(body.actId)
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			self:UpdateUI()
		end
	end	
end

function UIOperactivitesShow:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	if self.showModel and self.showModel and self.showModel[1] and self.showModel[1] ~= "" then
		local loader = objSwf.roleLoader1
		local name      = 'UIOperactivitesShow1'
		if not self.objUIDraw1 then
			self.objUIDraw1 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
		end	
		self.objUIDraw1:SetUILoader( loader )	
		local src = self.showModel[1]
		if not src then return end
		self.objUIDraw1:SetScene(src);	
		self.objUIDraw1:SetDraw(true);
	end
	
	if self.showModel and self.showModel and self.showModel[2] and self.showModel[2] ~= "" then
		local loader = objSwf.roleLoader2
		local name      = 'UIOperactivitesShow2'
		if not self.objUIDraw2 then
			self.objUIDraw2 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
		end	
		self.objUIDraw2:SetUILoader( loader )	
		local src = self.showModel[2]
		if not src then return end
		self.objUIDraw2:SetScene(src);	
		self.objUIDraw2:SetDraw(true);
	end
	
	if self.showModel and self.showModel and self.showModel[3] and self.showModel[3] ~= "" then
		local loader = objSwf.roleLoader3
		local name      = 'UIOperactivitesShow3'
		if not self.objUIDraw3 then
			self.objUIDraw3 = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
		end	
		self.objUIDraw3:SetUILoader( loader )	
		local src = self.showModel[3]
		if not src then return end
		self.objUIDraw3:SetScene(src);	
		self.objUIDraw3:SetDraw(true);
	end
end