--[[DailyMustDoMsgBoxView
zhangshuhui
2015年3月18日14:50:00
]]

_G.UIDailyMustDoZhuiHuiBoxView = BaseUI:new("UIDailyMustDoZhuiHuiBoxView")

UIDailyMustDoZhuiHuiBoxView.type = 0;
UIDailyMustDoZhuiHuiBoxView.consumetype = 0;
UIDailyMustDoZhuiHuiBoxView.id = 0;
UIDailyMustDoZhuiHuiBoxView.isall = false;

function UIDailyMustDoZhuiHuiBoxView:Create()
	self:AddSWF("dailyMustDoZhuiHuiBox.swf", true, "top")
end

function UIDailyMustDoZhuiHuiBoxView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnclose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.yinliangzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yinliangzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.zhizunzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.zhizunzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.vipzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.vipzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.yijianzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yijianzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	--TIP
	RewardManager:RegisterListTips(objSwf.yinliangzhuihui.itempanel.rewardList);
	RewardManager:RegisterListTips(objSwf.zhizunzhuihui.itempanel.rewardList);
	RewardManager:RegisterListTips(objSwf.vipzhuihui.itempanel.rewardList);
	RewardManager:RegisterListTips(objSwf.yijianzhuihui.itempanel.rewardList);
end

function UIDailyMustDoZhuiHuiBoxView:OnBtnOkClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if self.isall == true then
		if self.consumetype == DailyMustDoConsts.typeyinliang then
			local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
			if playerinfo.eaBindGold + playerinfo.eaUnBindGold < allconstomenum then
				FloatManager:AddNormal( StrConfig['dailymustdo20'], objSwf.btnok );
				return;
			end
		elseif self.consumetype == DailyMustDoConsts.typeyuanbao then
			local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
			if vipLevel <= 0 then
				FloatManager:AddNormal( StrConfig['dailymustdo27'], objSwf.btnok );
				return;
			end
			local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
			if playerinfo.eaUnBindMoney < allconstomenum then
				FloatManager:AddNormal( StrConfig['dailymustdo21'], objSwf.btnok );
				return;
			end
		end
		DailyMustDoController:ReqFinishAllDailyMustDo(self.type, self.consumetype);
	else
		if self.consumetype == DailyMustDoConsts.typeyinliang then
			local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
			if playerinfo.eaBindGold + playerinfo.eaUnBindGold < consumenum then
				FloatManager:AddNormal( StrConfig['dailymustdo20'], objSwf.btnok );
				return;
			end
		elseif self.consumetype == DailyMustDoConsts.typeyuanbao then
			local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
			if vipLevel <= 0 then
				FloatManager:AddNormal( StrConfig['dailymustdo27'], objSwf.btnok );
				return;
			end
			
			local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
			if playerinfo.eaUnBindMoney < consumenum then
				FloatManager:AddNormal( StrConfig['dailymustdo21'], objSwf.btnok );
				return;
			end
		end
		
		DailyMustDoController:ReqFinishDailyMustDo(self.id, self.type, self.consumetype);
	end
end
function UIDailyMustDoZhuiHuiBoxView:OnBtnCancelClick()
	self:Hide();
end

function UIDailyMustDoZhuiHuiBoxView:OnShow(name)
	--显示
	self:ShowInfo();
	
	self:Top();
end

--点击关闭按钮
function UIDailyMustDoZhuiHuiBoxView:OnBtnCloseClick()
	self:Hide();
end

function UIDailyMustDoZhuiHuiBoxView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.JinRiBiZuoListUpdata then
		self:Hide();
	elseif name == NotifyConsts.JinBiBiZuoUpdata then
		self:Hide();
	end
end

function UIDailyMustDoZhuiHuiBoxView:ListNotificationInterests()
	return {NotifyConsts.JinRiBiZuoListUpdata,
			NotifyConsts.JinBiBiZuoUpdata};
end

--显示完成信息
function UIDailyMustDoZhuiHuiBoxView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.yinliangzhuihui._visible = false;
	objSwf.zhizunzhuihui._visible = false;
	objSwf.vipzhuihui._visible = false;
	objSwf.yijianzhuihui._visible = false;
	
	--标题
	--今日完成
	if self.type == DailyMustDoConsts.typetoday then
	
	--昨日追回
	elseif self.type == DailyMustDoConsts.typeyesterday then
		--银两
		if self.consumetype == DailyMustDoConsts.typeyinliang then
			--一键追回
			if self.isall == true then
				objSwf.yijianzhuihui._visible = true;
				
				local rewardlist,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, self.consumetype);
				objSwf.yijianzhuihui.itempanel.rewardList.dataProvider:cleanUp();
				objSwf.yijianzhuihui.itempanel.rewardList.dataProvider:push(unpack(rewardlist));
				objSwf.yijianzhuihui.itempanel.rewardList:invalidateData();
				
				if isnull == true then
					objSwf.yijianzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo24"], string.format( StrConfig["dailymustdo7"], 0));
				else
					local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
					local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, self.consumetype);
					objSwf.yijianzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo9"], string.format( StrConfig["dailymustdo7"], allconstomenum),pecent);
				end
			--银两追回
			else
				objSwf.yinliangzhuihui._visible = true;
				
				local rewardlist,isnull = DailyMustDoUtil:GetRewardInfoText(self.id, self.type, self.consumetype);
				objSwf.yinliangzhuihui.itempanel.rewardList.dataProvider:cleanUp();
				objSwf.yinliangzhuihui.itempanel.rewardList.dataProvider:push(unpack(rewardlist));
				objSwf.yinliangzhuihui.itempanel.rewardList:invalidateData();
				
				if isnull ==  true then
					objSwf.yinliangzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo24"], string.format( StrConfig["dailymustdo7"], 0));
				else
					local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
					local pecent = DailyMustDoUtil:GetRewardPecent(self.id, self.type, self.consumetype);
					objSwf.yinliangzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo9"], string.format( StrConfig["dailymustdo7"], consumenum),pecent);
				end
			end
		--元宝
		elseif self.consumetype == DailyMustDoConsts.typeyuanbao then
			--完美追回
			if self.isall == true then
				objSwf.zhizunzhuihui._visible = true;
				
				local rewardlist,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, self.consumetype);
				objSwf.zhizunzhuihui.itempanel.rewardList.dataProvider:cleanUp();
				objSwf.zhizunzhuihui.itempanel.rewardList.dataProvider:push(unpack(rewardlist));
				objSwf.zhizunzhuihui.itempanel.rewardList:invalidateData();
				
				if isnull == true then
					objSwf.zhizunzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo24"], string.format( StrConfig["dailymustdo6"], 0));
				else
					local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
					local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, self.consumetype);
					objSwf.zhizunzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo9"], string.format( StrConfig["dailymustdo6"], allconstomenum),pecent);
				end
			--元宝追回
			else
				objSwf.vipzhuihui._visible = true;
				
				local rewardlist,isnull = DailyMustDoUtil:GetRewardInfoText(self.id, self.type, self.consumetype);
				objSwf.vipzhuihui.itempanel.rewardList.dataProvider:cleanUp();
				objSwf.vipzhuihui.itempanel.rewardList.dataProvider:push(unpack(rewardlist));
				objSwf.vipzhuihui.itempanel.rewardList:invalidateData();
				
				if isnull == true then
					objSwf.vipzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo24"], string.format( StrConfig["dailymustdo6"], 0));
				else
					local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
					local pecent = DailyMustDoUtil:GetRewardPecent(self.id, self.type, self.consumetype);
					objSwf.vipzhuihui.txttishi.htmlText = string.format( StrConfig["dailymustdo9"], string.format( StrConfig["dailymustdo6"], consumenum) ,pecent);
				end
			end
		end
	end
end

--打开面板
function UIDailyMustDoZhuiHuiBoxView:OpenPanel(id, type, consumetype, isall)
	self.id = id;
	self.type = type;
	self.consumetype = consumetype;
	self.isall = isall;
	
	if self:IsShow() then
		self:ShowInfo();
		self:Top();
	else
		self:Show();
	end
end