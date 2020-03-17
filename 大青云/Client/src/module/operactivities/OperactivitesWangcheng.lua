--[[
	展示
	2015年10月12日, PM 08:15:41
]]

_G.UIOperactivitesWangcheng = BaseUI:new('UIOperactivitesWangcheng');
UIOperactivitesWangcheng.actMasterVO = {}
UIOperactivitesWangcheng.actMemVO = {}
UIOperactivitesWangcheng.actMasterVO1 = {}
UIOperactivitesWangcheng.actMemVO1 = {}
UIOperactivitesWangcheng.remainTime = 0
UIOperactivitesWangcheng.timerKey = nil;
UIOperactivitesWangcheng.showModel = ''
UIOperactivitesWangcheng.lastTime = 0
function UIOperactivitesWangcheng:Create()
	self:AddSWF('operactivitesWangcheng.swf',true,nil);
end

function UIOperactivitesWangcheng:OnLoaded(objSwf)

	-- objSwf.busiess1.btn_getReward.click = function (e) 
	-- 	if not self.actMasterVO then FloatManager:AddCenter(StrConfig['operactivites26']) return end
	-- 	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
	-- 		self.isPlayMaster = true
	-- 		OperactivitiesController:ReqGetPartyAward(self.actMasterVO.id, 1)
	-- 		self.lastTime = GetCurTime()
	-- 	end
	-- end	
	-- objSwf.busiess2.btn_getReward.click = function (e) 
	-- 	if not self.actMemVO then FloatManager:AddCenter(StrConfig['operactivites27']) return end
	-- 	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
	-- 		self.isPlayMem = true
	-- 		OperactivitiesController:ReqGetPartyAward(self.actMemVO.id, 1)
	-- 		self.lastTime = GetCurTime()
	-- 	end
	-- end
	-- objSwf.busiess3.btn_getReward.click = function (e) 
	-- 	if not self.actMasterVO1 then FloatManager:AddCenter(StrConfig['operactivites26']) return end
	-- 	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
	-- 		self.isPlayMaster1 = true
	-- 		OperactivitiesController:ReqGetPartyAward(self.actMasterVO1.id, 1)
	-- 		self.lastTime = GetCurTime()
	-- 	end
	-- end	
	-- objSwf.busiess4.btn_getReward.click = function (e) 
	-- 	if not self.actMemVO1 then FloatManager:AddCenter(StrConfig['operactivites27']) return end
	-- 	if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
	-- 		self.isPlayMem1 = true
	-- 		OperactivitiesController:ReqGetPartyAward(self.actMemVO1.id, 1)
	-- 		self.lastTime = GetCurTime()
	-- 	end
	-- end
	
	
	RewardManager:RegisterListTips( objSwf.busiess1.rewardList )
	RewardManager:RegisterListTips( objSwf.busiess2.rewardList )
	RewardManager:RegisterListTips( objSwf.busiess3.rewardList )
	RewardManager:RegisterListTips( objSwf.busiess4.rewardList )
end

function UIOperactivitesWangcheng:OnShow()
	local group = OperActUIManager.currentGroupId	
	
		OperactivitiesController:RespPartyInfo(group)
	
end
function UIOperactivitesWangcheng:UpdateUI()
	local objSwf = self.objSwf
	if not objSwf then return end
	self:GetListData();
	local group = OperActUIManager.currentGroupId		
	
	objSwf.txtGroupTxt.text = OperactivitiesModel:GetGroupTxtByGroupId(group)
	objSwf.txtMaster.text = self.actMasterVO.eachTxt
	
	local getcount = self.actMasterVO.count or 0
	local rtime = self.actMasterVO.receiveTime or 0
	local num = rtime - getcount
	if not num or num < 0 then num = 0 end
	objSwf.busiess1.txt_num.text = "" --num or 0
	
	if self.actMasterVO.isAward == 1 then
		objSwf.getBtn1.disabled = false	
		objSwf.getBtn1.click = function()
			if not self.actMasterVO then FloatManager:AddCenter(StrConfig['operactivites26']) return end
			if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
				self.isPlayMaster = true
				OperactivitiesController:ReqGetPartyAward(self.actMasterVO.id, 1)
				self.lastTime = GetCurTime()
			end
		end
		objSwf.getBtn1:showEffect(ResUtil:GetButtonEffect7())
	elseif self.actMemVO.isAward == 1 then
		objSwf.getBtn1.disabled = false	
		objSwf.getBtn1.click = function()
			if not self.actMemVO then FloatManager:AddCenter(StrConfig['operactivites26']) return end
			if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
				self.isPlayMem = true
				OperactivitiesController:ReqGetPartyAward(self.actMemVO.id, 1)
				self.lastTime = GetCurTime()
			end
		end
		objSwf.getBtn1:showEffect(ResUtil:GetButtonEffect7())
	else
		objSwf.getBtn1.disabled = true
		objSwf.getBtn1:clearEffect()
	end
	if not self.actMasterVO.reward then self.actMasterVO.reward = '' end
	
	objSwf.busiess1.rewardList.dataProvider:cleanUp()
	objSwf.busiess1.rewardList.dataProvider:push( unpack( RewardManager:Parse( self.actMasterVO.reward ) ) )
	objSwf.busiess1.rewardList:invalidateData()
	
	objSwf.txtMem.text = self.actMemVO.eachTxt or ''
	local getcount = self.actMemVO.count or 0
	
	local rtime = self.actMemVO.receiveTime or 0
	local num = rtime - getcount
	if not num or num < 0 then num = 0 end
	objSwf.busiess2.txt_num.text = "" --num or 0

	if not self.actMemVO.reward then self.actMemVO.reward = '' end
	objSwf.busiess2.rewardList.dataProvider:cleanUp()
	objSwf.busiess2.rewardList.dataProvider:push( unpack( RewardManager:Parse( self.actMemVO.reward ) ) )
	objSwf.busiess2.rewardList:invalidateData()

	objSwf.txtMaster1.text = self.actMasterVO1.eachTxt
	
	local getcount = self.actMasterVO1.count or 0
	local rtime = self.actMasterVO1.receiveTime or 0
	local num = rtime - getcount
	if not num or num < 0 then num = 0 end
	objSwf.busiess3.txt_num.text = "" --num or 0
	
	if not self.actMasterVO1.reward then self.actMasterVO1.reward = '' end
	
	objSwf.busiess3.rewardList.dataProvider:cleanUp()
	objSwf.busiess3.rewardList.dataProvider:push( unpack( RewardManager:Parse( self.actMasterVO1.reward ) ) )
	objSwf.busiess3.rewardList:invalidateData()
	
	objSwf.txtMem1.text = self.actMemVO1.eachTxt or ''
	local getcount = self.actMemVO1.count or 0
	
	local rtime = self.actMemVO1.receiveTime or 0
	local num = rtime - getcount
	if not num or num < 0 then num = 0 end
	objSwf.busiess4.txt_num.text = "" --num or 0
	
	if self.actMasterVO1.isAward == 1 then
		objSwf.getBtn2.disabled = false	
		objSwf.getBtn2.click = function()
			if not self.actMasterVO1 then FloatManager:AddCenter(StrConfig['operactivites26']) return end
			if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
				self.isPlayMaster1 = true
				OperactivitiesController:ReqGetPartyAward(self.actMasterVO1.id, 1)
				self.lastTime = GetCurTime()
			end
		end
		objSwf.getBtn2:showEffect(ResUtil:GetButtonEffect7())
	elseif self.actMemVO1.isAward == 1 then
		objSwf.getBtn2.disabled = false	
		objSwf.getBtn2.click = function()
			if not self.actMemVO1 then FloatManager:AddCenter(StrConfig['operactivites26']) return end
			if GetCurTime() - self.lastTime > OperactivitiesConsts.delayReawrd then
				self.isPlayMem1 = true
				OperactivitiesController:ReqGetPartyAward(self.actMemVO1.id, 1)
				self.lastTime = GetCurTime()
			end
		end
		objSwf.getBtn2:showEffect(ResUtil:GetButtonEffect7())
	else
		objSwf.getBtn2.disabled = true	
		objSwf.getBtn2:clearEffect()
	end

	if not self.actMemVO1.reward then self.actMemVO1.reward = '' end
	objSwf.busiess4.rewardList.dataProvider:cleanUp()
	objSwf.busiess4.rewardList.dataProvider:push( unpack( RewardManager:Parse( self.actMemVO1.reward ) ) )
	objSwf.busiess4.rewardList:invalidateData()
	
	self.remainTime = OperactivitiesModel:GetGroupRemainTimeByGroupId(group)
	if self.remainTime > 0 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		self.timerKey = TimerManager:RegisterTimer(function() self:Ontimer() end,1000,0);
		self:Ontimer();
	end
	
	FTrace(self.actMasterVO)
	self.showModel = OperactivitiesModel:GetModelScene(self.actMasterVO.showModel)	
	self:Show3DWeapon()
end

function UIOperactivitesWangcheng : Ontimer()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.remainTime < 0 then self.remainTime = 0 end
	if self.remainTime < 0 then self.remainTime = 0 end
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
	end
	
	local day,hour,mint,sec = CTimeFormat:sec2formatEx(GetLocalTime())
	FPrint('当前的小时和分'..hour..':'..mint..':'..sec)
	if hour == 0 and mint == 0 and sec >= 2 and sec <= 3 then
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end;
		UIMainOperActivites:Hide()
	end
end;

function UIOperactivitesWangcheng:OnDelete()
	local name = 'UIOperactivitesWangcheng'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if objUIDraw then
		objUIDraw:SetUILoader(nil);
	end
end

function UIOperactivitesWangcheng:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	
	local name = 'UIOperactivitesWangcheng'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

--所有数据
function UIOperactivitesWangcheng:GetListData()
	--将可领奖的放在上面  拆分，排序，重组
	local group = OperActUIManager.currentGroupId	
	local actList = OperactivitiesModel.groupList[group]	
	-- FPrint('UIOperactivitesWangcheng:GetListData所有数据'..group)
	-- FTrace(actList)	
	
	for i , v in ipairs(actList) do		
		if toint(v.param) == 1 then
			self.actMasterVO = v			
		end
		
		if toint(v.param) == 2 then
			self.actMemVO = v
		end
		if toint(v.param) == 3 then
			self.actMasterVO1 = v			
		end
		
		if toint(v.param) == 4 then
			self.actMemVO1 = v
		end
	end	
end

function UIOperactivitesWangcheng:PlayYilingqu(actId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isPlayMaster then
		OperactivitiesModel:GoRewardfun(objSwf.getBtn1, self.actMasterVO.reward)
	elseif self.isPlayMem then
		OperactivitiesModel:GoRewardfun(objSwf.getBtn1, self.actMemVO.reward)
	elseif self.isPlayMaster1 then
		OperactivitiesModel:GoRewardfun(objSwf.getBtn2, self.actMasterVO1.reward)
	elseif self.isPlayMem1 then
		OperactivitiesModel:GoRewardfun(objSwf.getBtn2, self.actMemVO1.reward)
	end
	
end

--领奖点击
-- function UIOperactivitesWangcheng:GetRewardClick(id)
	-- FPrint('领奖点击'..id)
	
	-- OperactivitiesController:ReqGetPartyAward(id, 1)
-- end

function UIOperactivitesWangcheng:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.UpdateGroupInfo,
		NotifyConsts.OperActivityInitState,
	}
end

function UIOperactivitesWangcheng:HandleNotification( name, body )
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
		self.isPlayMaster = false
		self.isPlayMem = false
		self.isPlayMem1 = false
		self.isPlayMaster1 = false
	elseif name == NotifyConsts.UpdateGroupInfo then
		local group = OperActUIManager.currentGroupId	
		if group == body.groupId then
			self:UpdateUI()
		end
	end	
end

function UIOperactivitesWangcheng:Show3DWeapon()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	if not self.showModel or self.showModel == "" then
		local name = 'UIOperactivitesWangcheng'
		local objUIDraw = UIDrawManager:GetUIDraw(name);
		if self.objUIDraw then
			self.objUIDraw:SetDraw(false);
		end
		return
	end
	
	local loader = objSwf.roleLoader
	local name      = 'UIOperactivitesWangcheng'
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end	
	self.objUIDraw:SetUILoader( loader )	
	local src = self.showModel
	if not src then return end
	self.objUIDraw:SetScene(src);	
	self.objUIDraw:SetDraw(true);	
end