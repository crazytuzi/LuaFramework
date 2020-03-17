--[[
	登陆奖励主面板
	2014年12月15日, PM 04:41:41
	wangyanwei
]]

_G.UIRegisterAward = BaseUI:new("UIRegisterAward");

UIRegisterAward.tabButton = {};
UIRegisterAward.curpanelname = "";

function UIRegisterAward:Create()
	self:AddSWF("registerAwardMainPanel.swf", true, "center");
	
	self:AddChild(UISignPanel, "sign");
	self:AddChild(UIRegisterTimePanel, "registerTime");
	self:AddChild(UILevelAward, "level");
	self:AddChild(UIRegisterOutLineView, "outline");
	self:AddChild(UIRegisterCodeView, "code");
	self:AddChild(UIQQReward, "qq");
	-- self:AddChild(UIPhoneBindingView,"phone")
end

function UIRegisterAward:OnLoaded(objSwf, name)
	self:GetChild("sign"):SetContainer(objSwf.childPanel);
	self:GetChild("registerTime"):SetContainer(objSwf.childPanel);
	self:GetChild("level"):SetContainer(objSwf.childPanel);
	self:GetChild("outline"):SetContainer(objSwf.childPanel);
	self:GetChild("code"):SetContainer(objSwf.childPanel);
	self:GetChild("qq"):SetContainer(objSwf.childPanel);
	-- self:GetChild("phone"):SetContainer(objSwf.childPanel);
	--
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--
	self.tabButton["sign"] = objSwf.btnSign;
	self.tabButton["registerTime"] = objSwf.btnTime;
	self.tabButton["level"] = objSwf.btnLevel;
	self.tabButton["outline"] = objSwf.btnoutline;
	self.tabButton["code"] = objSwf.btncode;
	self.tabButton["qq"] = objSwf.btnQQ;
	-- self.tabButton["phone"] = objSwf.btnPhone;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
end

function UIRegisterAward:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end


function UIRegisterAward:OnShow(name)
	if self.curpanelname == "" then
		self:OnTabButtonClick("sign");
	else
		self:OnTabButtonClick(self.curpanelname);
	end
	self:ShowHaveEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnQQ.visible = false ;--Version:IsQQReward();  --暂时屏蔽qq礼包 2016/12/16
	-- objSwf.btnPhone.visible = PhoneBindingModel:ShowPhone();
	self.btnLevelWidth = objSwf.btnLevel._width;
	self.btnOnLineWidth = objSwf.btnTime._width;
	self.levelLineWidth = objSwf.btnoutline._width;
	self:InintRedPoint();
	self:RegisterTimes();
end

UIRegisterAward.timekey = nil;
function UIRegisterAward:RegisterTimes( )
	self.timekey = TimerManager:RegisterTimer(function()
		self:InintRedPoint()
	end,1000,0); 
end

function UIRegisterAward:InintRedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--等级礼包
	local value = RegisterAwardUtil:GetlvRewardNum ()
	if value > 0 then
		PublicUtil:SetRedPoint(objSwf.btnLevel, RedPointConst.showNum, value)
	else
		PublicUtil:SetRedPoint(objSwf.btnLevel,RedPointConst.showNum,0)
	end

	--在线奖励
	local notGetOnLineRewardNum = RegisterAwardUtil:GetOnilneRewardNum ()
	if notGetOnLineRewardNum > 0 then
		PublicUtil:SetRedPoint(objSwf.btnTime, RedPointConst.showNum, notGetOnLineRewardNum)
	else
		PublicUtil:SetRedPoint(objSwf.btnTime,RedPointConst.showNum,0)
	end

	--离线奖励
	local notGetOutLineRewardNum = RegisterAwardUtil:GetoutilneRewardNum ()
	if notGetOutLineRewardNum > 0 then
		PublicUtil:SetRedPoint(objSwf.btnoutline, RedPointConst.showNum, notGetOutLineRewardNum)
	else
		PublicUtil:SetRedPoint(objSwf.btnoutline, RedPointConst.showNum,0)
	end
end


function UIRegisterAward:OnHide()
	self.curpanelname = "";
	RemindController:AddRemind(RemindConsts.Type_LevelReward, 0);
	if self.timekey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function UIRegisterAward:SetPanelName(panelname)
	self.curpanelname = panelname;
end

--点击标签
function UIRegisterAward:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end

--点击关闭按钮
function UIRegisterAward:OnBtnCloseClick()
	self:Hide();
end

function UIRegisterAward:IsTween()
	return true;
end

function UIRegisterAward:GetPanelType()
	return 1;
end

function UIRegisterAward:IsShowSound()
	return true;
end

function UIRegisterAward:IsShowLoading()
	return true;
end

--返回资源，加载的第一个子面板(字符串SWF)
function UIRegisterAward:WithRes()
	return {"registerSignPanel.swf","levelawardPanel.swf","registerOutLine.swf","registerTime.swf"}
end

function UIRegisterAward:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowLevelRewardEffect();
		end
	elseif name == NotifyConsts.UpDataEffect then
		self:UpdateHaveEffect(body);
	end
end

function UIRegisterAward:ListNotificationInterests()
	return {NotifyConsts.UpDataEffect,NotifyConsts.PlayerAttrChange};
end

--可签到或者可领取显示特效
function UIRegisterAward:ShowHaveEffect()
	self:ShowSignEffect();
	self:ShowTimeEffect();
	self:ShowOutLineEffect();
	self:ShowLevelRewardEffect();
	self:ShowJiHuoMaEffect();
end

--更新特效
function UIRegisterAward:UpdateHaveEffect(body)
		--签到
	if body.state == 1 then
		self:ShowSignEffect();
		--在线抽奖
	elseif body.state == 2 then
		self:ShowTimeEffect();
		--离线奖励
	elseif body.state == 3 then
		self:ShowOutLineEffect();
		--等级奖励
	elseif body.state == 4 then
		self:ShowLevelRewardEffect();
	end
end

function UIRegisterAward:ShowSignEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否有可签到操作
	if RegisterAwardUtil:GetIsHaveSige() == true then
		objSwf.effectsign.visible = true;
		objSwf.effectsign:playEffect(0);
	else
		objSwf.effectsign.visible = false;
		objSwf.effectsign:stopEffect();
	end
end
function UIRegisterAward:ShowTimeEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否在线奖励可领取
	if RegisterAwardUtil:GetIsHaveOnTimeAward() == true then
		objSwf.effecttime.visible = true;
		objSwf.effecttime:playEffect(0);
	else
		objSwf.effecttime.visible = false;
		objSwf.effecttime:stopEffect();
	end
end
function UIRegisterAward:ShowOutLineEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否有离线奖励
	if RegisterAwardUtil:GetIsHaveOutlineReward() == true then
		objSwf.effectoutline.visible = true;
		objSwf.effectoutline:playEffect(0);
	else
		objSwf.effectoutline.visible = false;
		objSwf.effectoutline:stopEffect();
	end
end
function UIRegisterAward:ShowLevelRewardEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否有未领取等级奖励
	if RegisterAwardUtil:GetIsHaveLevelReward() == true then
		objSwf.effectlevelaward.visible = true;
		objSwf.effectlevelaward:playEffect(0);
	else
		objSwf.effectlevelaward.visible = false;
		objSwf.effectlevelaward:stopEffect();
	end
end
function UIRegisterAward:ShowJiHuoMaEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--是否有可用激活码
	if RegisterAwardUtil:GetIsHaveJiHuoMa() == true then
		objSwf.effectjihuoma.visible = true;
		objSwf.effectjihuoma:playEffect(0);
	else
		objSwf.effectjihuoma.visible = false;
		objSwf.effectjihuoma:stopEffect();
	end
end

--面板中详细信息为隐藏面板，不计算到总宽度内
function UIRegisterAward:GetWidth()
	return 1146;
end

function UIRegisterAward:GetHeight()
	return 687;
end