--[[DailyMustDoMsgBoxView
zhangshuhui
2015年3月18日14:50:00
]]

_G.UIDailyMustDoMsgBoxView = BaseUI:new("UIDailyMustDoMsgBoxView")

UIDailyMustDoMsgBoxView.type = 0;
UIDailyMustDoMsgBoxView.consumetype = 0;
UIDailyMustDoMsgBoxView.id = 0;
UIDailyMustDoMsgBoxView.isall = false;

function UIDailyMustDoMsgBoxView:Create()
	self:AddSWF("dailyMustDoMsgBox.swf", true, "top")
end

function UIDailyMustDoMsgBoxView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnclose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.yinliangwancheng.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yinliangwancheng.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.yinliangzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yinliangzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.zhizunwancheng.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.zhizunwancheng.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.zhizunzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.zhizunzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.vipwancheng.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.vipwancheng.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.vipzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.vipzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.yijianwancheng.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yijianwancheng.btncancel.click = function() self:OnBtnCancelClick(); end;
	objSwf.yijianzhuihui.btnok.click = function() self:OnBtnOkClick(); end;
	objSwf.yijianzhuihui.btncancel.click = function() self:OnBtnCancelClick(); end;
end

function UIDailyMustDoMsgBoxView:OnBtnOkClick()
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
function UIDailyMustDoMsgBoxView:OnBtnCancelClick()
	self:Hide();
end

function UIDailyMustDoMsgBoxView:OnShow(name)
	--显示
	self:ShowInfo();
	
	self:Top();
end

--点击关闭按钮
function UIDailyMustDoMsgBoxView:OnBtnCloseClick()
	self:Hide();
end

function UIDailyMustDoMsgBoxView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.JinRiBiZuoListUpdata then
		self:Hide();
	elseif name == NotifyConsts.JinBiBiZuoUpdata then
		self:Hide();
	end
end

function UIDailyMustDoMsgBoxView:ListNotificationInterests()
	return {NotifyConsts.JinRiBiZuoListUpdata,
			NotifyConsts.JinBiBiZuoUpdata};
end

--显示完成信息
function UIDailyMustDoMsgBoxView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.yinliangwancheng._visible = false;
	objSwf.yinliangzhuihui._visible = false;
	objSwf.zhizunwancheng._visible = false;
	objSwf.zhizunzhuihui._visible = false;
	objSwf.vipwancheng._visible = false;
	objSwf.vipzhuihui._visible = false;
	objSwf.yijianwancheng._visible = false;
	objSwf.yijianzhuihui._visible = false;
	
	--标题
	--今日完成
	if self.type == DailyMustDoConsts.typetoday then
		--银两
		if self.consumetype == DailyMustDoConsts.typeyinliang then
			--一键完成
			if self.isall == true then
				objSwf.yijianwancheng._visible = true;
				
				local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
				local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, self.consumetype);
				objSwf.yijianwancheng.txtinfo.htmlText = string.format( StrConfig["dailymustdo5"], string.format( StrConfig["dailymustdo7"], allconstomenum),pecent);
			--银两完成
			else
				objSwf.yinliangwancheng._visible = true;
				
				local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
				local pecent = DailyMustDoUtil:GetRewardPecent(self.id, self.type, self.consumetype);
				objSwf.yinliangwancheng.txtinfo.htmlText = string.format( StrConfig["dailymustdo3"], string.format( StrConfig["dailymustdo7"], consumenum),pecent);
			end
			
		--元宝
		elseif self.consumetype == DailyMustDoConsts.typeyuanbao then
			--一键完成
			if self.isall == true then
				objSwf.zhizunwancheng._visible = true;
				
				local allconstomenum = DailyMustDoUtil:GetAllConstomeNum(self.type, self.consumetype);
				local pecent = DailyMustDoUtil:GetRewardPecent(1, self.type, self.consumetype);
				objSwf.zhizunwancheng.txtinfo.htmlText = string.format( StrConfig["dailymustdo5"], string.format( StrConfig["dailymustdo6"], allconstomenum) ,pecent);
			--元宝完成
			else
				objSwf.vipwancheng._visible = true;
				
				local consumenum = DailyMustDoUtil:GetConsumeNum(self.id, self.type, self.consumetype);
				local pecent = DailyMustDoUtil:GetRewardPecent(self.id, self.type, self.consumetype);
				objSwf.vipwancheng.txtinfo.htmlText = string.format( StrConfig["dailymustdo3"], string.format( StrConfig["dailymustdo6"], consumenum) ,pecent);
			end
		end
	
	--昨日追回
	elseif self.type == DailyMustDoConsts.typeyesterday then
		--银两
		if self.consumetype == DailyMustDoConsts.typeyinliang then
			--一键追回
			if self.isall == true then
				objSwf.yijianzhuihui._visible = true;
				
				local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, self.consumetype);
				objSwf.yijianzhuihui.txtinfo.htmlText = strname;
				
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
				
				local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(self.id, self.type, self.consumetype);
				objSwf.yinliangzhuihui.txtinfo.htmlText = strname;
				
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
				
				local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(0, self.type, self.consumetype);
				objSwf.zhizunzhuihui.txtinfo.htmlText = strname;
				
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
				
				local strname,strnum,isnull = DailyMustDoUtil:GetRewardInfoText(self.id, self.type, self.consumetype);
				objSwf.vipzhuihui.txtinfo.htmlText = strname;
				
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
function UIDailyMustDoMsgBoxView:OpenPanel(id, type, consumetype, isall)
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