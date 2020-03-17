--[[
离线奖励面板：离线奖励
zhangshuhui
2015年2月2日11:15:00
]]

_G.UIRegisterOutLineView = BaseUI:new("UIRegisterOutLineView");

UIRegisterOutLineView.maxtime = 60*12; --60分钟*12个小时

function UIRegisterOutLineView:Create()
	self:AddSWF("registerOutLine.swf",true,nil);
end

function UIRegisterOutLineView:OnLoaded(objSwf)
	--充值vip
	--objSwf.btnchongzhivip.click = function() self:OnBtnChongZhiVIPClick() end
	objSwf.btnchongzhivip.visible = false;
	--领取奖励
	objSwf.btnget.click = function() self:OnBtnGetClick() end
	--领取双倍收益
	objSwf.btngettwo.click = function() self:OnBtnGetTwoClick() end
	--领取三倍收益
	objSwf.btngetthree.click = function() self:OnBtnGetThreeClick() end
	
	objSwf.btngettwo.rollOver = function() self:OnbtnTip2RollOver(); end
	objSwf.btngettwo.rollOut  = function() TipsManager:Hide();  end
	objSwf.btngetthree.rollOver = function() self:OnbtnTip3RollOver(); end
	objSwf.btngetthree.rollOut  = function() TipsManager:Hide();  end
	objSwf.btntip2.rollOver = function() self:OnbtnTip2RollOver(); end
	objSwf.btntip2.rollOut  = function() TipsManager:Hide();  end
	objSwf.btntip3.rollOver = function() self:OnbtnTip3RollOver(); end
	objSwf.btntip3.rollOut  = function() TipsManager:Hide();  end
	
	--离线收益居中
	self.numexpbasex = objSwf.numexpbase._x
	objSwf.numexpbase.loadComplete = function()
									objSwf.numexpbase._x = self.numexpbasex - objSwf.numexpbase.width / 2
								end
	self.numexptwox = objSwf.numexptwo._x
	objSwf.numexptwo.loadComplete = function()
									objSwf.numexptwo._x = self.numexptwox - objSwf.numexptwo.width / 2
								end
	self.numzhenqitwox = objSwf.numzhenqitwo._x
	objSwf.numzhenqitwo.loadComplete = function()
									objSwf.numzhenqitwo._x = self.numzhenqitwox - objSwf.numzhenqitwo.width / 2
								end
	self.numexpthreex = objSwf.numexpthree._x
	objSwf.numexpthree.loadComplete = function()
									objSwf.numexpthree._x = self.numexpthreex - objSwf.numexpthree.width / 2
								end
	self.numzhenqithreex = objSwf.numzhenqithree._x
	objSwf.numzhenqithree.loadComplete = function()
									objSwf.numzhenqithree._x = self.numzhenqithreex - objSwf.numzhenqithree.width / 2
								end
								
	for i=1,3 do
		objSwf["effectyilingqu"..i].complete = function() self:ShowImgState(i); end
	end
	objSwf.numzhenqitwo._visible = false
	objSwf.numzhenqithree._visible = false
end

function UIRegisterOutLineView:OnShow(name)
	--显示
	self:ShowOutLineInfo();
end

function UIRegisterOutLineView:OnHide()
	UIConfirm:Close(self.confirmID);
end

function UIRegisterOutLineView:OnBtnChongZhiVIPClick()
	
end

function UIRegisterOutLineView:OnBtnGetClick()
	if RegisterAwardModel.outlinetime == 0 then
		return;
	end
	
	RegisterAwardController:ReqGetOutLineAward(1);
end

function UIRegisterOutLineView:OnBtnGetTwoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if RegisterAwardModel.outlinetime == 0 then
		return;
	end
	
	--vip等级不足1
	local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )--黄金
	if GoldTime == -1 or GoldTime == 0 then
		FloatManager:AddNormal( StrConfig["registerReward11"], objSwf.btngettwo);
		return;
	end
	
	--元宝
	local constomnum = 0;
	local t = split(t_consts[113].param,"#");
	if t[1] then
		local constomvo = split(t[1],",");
		constomnum = tonumber(constomvo[2]);
	end
	local content = string.format(StrConfig["registerReward16"],constomnum);
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local confirmFunc = function()
		if playerinfo.eaUnBindMoney < constomnum then
			FloatManager:AddNormal( StrConfig["registerReward15"] );
			return;
		end
		RegisterAwardController:ReqGetOutLineAward(2);
	end
	self.confirmID = UIConfirm:Open( content, confirmFunc );
end

function UIRegisterOutLineView:OnBtnGetThreeClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if RegisterAwardModel.outlinetime == 0 then
		return;
	end
	
	--vip等级不足5
	local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )--黄金
	if GoldTime == -1 or GoldTime == 0 then
		FloatManager:AddNormal( StrConfig["registerReward111"], objSwf.btngetthree);
		return;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	--元宝
	local constomnum = 0;
	local t = split(t_consts[113].param,"#");
	if t[2] then
		local constomvo = split(t[2],",");
		constomnum = tonumber(constomvo[2]);
	end
	local content = string.format(StrConfig["registerReward16"],constomnum);
	local confirmFunc = function()
		if playerinfo.eaUnBindMoney < constomnum then
			FloatManager:AddNormal( StrConfig["registerReward15"] );
			return;
		end
		RegisterAwardController:ReqGetOutLineAward(3);
	end
	self.confirmID = UIConfirm:Open( content, confirmFunc );
end

function UIRegisterOutLineView:OnbtnTip2RollOver()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )--黄金
	if GoldTime == -1 or GoldTime == 0 then--未激活
		TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig["registerReward7"], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	else
		TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig["registerReward6"], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
end
function UIRegisterOutLineView:OnbtnTip3RollOver()
	local DiamondTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )
	if DiamondTime == -1 or DiamondTime == 0 then
		TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig["registerReward9"], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	else
		TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig["registerReward8"], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	end
end
	
function UIRegisterOutLineView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.OutLineExpUpdata then
		self:UpdateOutLineInfo();
		TipsManager:Hide();
		SoundManager:PlaySfx(2041);
	end
end

function UIRegisterOutLineView:ListNotificationInterests()
	return {NotifyConsts.OutLineExpUpdata};
end

--显示列表
function UIRegisterOutLineView:ShowOutLineInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--显示离线时间
	self:ShowTime();
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local expnum = 0;
	local zhenqinum = 0;
	if t_lvup[playerinfo.eaLevel] then
		expnum = RegisterAwardModel.outlinetime * t_lvup[playerinfo.eaLevel].offline_exp;
		zhenqinum = RegisterAwardModel.outlinetime * t_lvup[playerinfo.eaLevel].offline_zhenqi;
	end
	
	--基本收益
	objSwf.numexpbase.num = "0";
	
	--双倍收益
	objSwf.numexptwo.num = "0";
	objSwf.numzhenqitwo.num = "0";
	
	--三倍收益
	objSwf.numexpthree.num = "0";
	objSwf.numzhenqithree.num = "0";
	
	objSwf.btnget.disabled = true;
	objSwf.btngettwo.disabled = true;
	objSwf.btngetthree.disabled = true;
	objSwf.imggetted1._visible = false;
	objSwf.imggetted2._visible = false;
	objSwf.imggetted3._visible = false;
	objSwf.btntip2.visible = false;
	objSwf.btntip3.visible = false;
	
	objSwf.btnget:clearEffect();
	objSwf.btngettwo:clearEffect();
	objSwf.btngetthree:clearEffect();
	for i=1,3 do
		objSwf["effectsaoguang"..i].visible = false;
		objSwf["effectsaoguang"..i]:stopEffect();
		
		objSwf["effectyilingqu"..i].visible = false;
		objSwf["effectyilingqu"..i]:stopEffect();
	end
	
	if RegisterAwardModel.outlinetime > 0 then
		--基本收益
		objSwf.numexpbase.num = expnum;
		
		--双倍收益
		objSwf.numexptwo.num = expnum * 2;
		objSwf.numzhenqitwo.num = zhenqinum * 2;
		
		--三倍收益
		objSwf.numexpthree.num = expnum * 3;
		objSwf.numzhenqithree.num = zhenqinum * 3;
		
		objSwf.btnget.disabled = false;
		objSwf.btngettwo.disabled = false;
		objSwf.btngetthree.disabled = false;
		
		-- objSwf.effectsaoguang1.visible = true;
		-- objSwf.effectsaoguang1:playEffect(0);
		objSwf.btnget:showEffect(ResUtil:GetButtonEffect10());
		local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )--黄金
		local DiamondTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )--钻石
		
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if GoldTime > 0 then
			-- objSwf.effectsaoguang2.visible = true;
			-- objSwf.effectsaoguang2:playEffect(0);
			objSwf.btngettwo:showEffect(ResUtil:GetButtonEffect10());
		end
		
		if DiamondTime > 0 then
			-- objSwf.effectsaoguang3.visible = true;
			-- objSwf.effectsaoguang3:playEffect(0);
			objSwf.btngetthree:showEffect(ResUtil:GetButtonEffect10());
		end
	else
		objSwf.btntip2.visible = true;
		objSwf.btntip3.visible = true;
		if RegisterAwardModel.outlineawardtype == 1 then
			objSwf.btnget.visible = false;
			objSwf.imggetted1._visible = true;
		elseif RegisterAwardModel.outlineawardtype == 2 then
			objSwf.btngettwo.visible = false;
			objSwf.imggetted2._visible = true;
			objSwf.btntip2.visible = false;
		elseif RegisterAwardModel.outlineawardtype == 3 then
			objSwf.btngetthree.visible = false;
			objSwf.imggetted3._visible = true;
			objSwf.btntip3.visible = false;
		end
	end
	objSwf.textInfo.text = StrConfig['registerReward6002'];
end

--刷新列表
function UIRegisterOutLineView:UpdateOutLineInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--显示离线时间
	self:ShowTime();
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local expnum = 0;
	local zhenqinum = 0;
	if t_lvup[playerinfo.eaLevel] then
		expnum = RegisterAwardModel.outlinetime * t_lvup[playerinfo.eaLevel].offline_exp;
		zhenqinum = RegisterAwardModel.outlinetime * t_lvup[playerinfo.eaLevel].offline_zhenqi;
	end
	
	--基本收益
	objSwf.numexpbase.num = "0";
	
	--双倍收益
	objSwf.numexptwo.num = "0";
	objSwf.numzhenqitwo.num = "0";
	
	--三倍收益
	objSwf.numexpthree.num = "0";
	objSwf.numzhenqithree.num = "0";
	
	objSwf.btnget.disabled = true;
	objSwf.btngettwo.disabled = true;
	objSwf.btngetthree.disabled = true;
	objSwf.imggetted1._visible = false;
	objSwf.imggetted2._visible = false;
	objSwf.imggetted3._visible = false;
	objSwf.btntip2.visible = false;
	objSwf.btntip3.visible = false;
	-- objSwf.effectsaoguang1.visible = false;
	-- objSwf.effectsaoguang1:stopEffect();
	-- objSwf.effectsaoguang2.visible = false;
	-- objSwf.effectsaoguang2:stopEffect();
	-- objSwf.effectsaoguang3.visible = false;
	-- objSwf.effectsaoguang3:stopEffect();
	objSwf.btnget:clearEffect();
	objSwf.btngettwo:clearEffect();
	objSwf.btngetthree:clearEffect();

	
	for i=1,3 do
		objSwf["effectsaoguang"..i].visible = false;
		objSwf["effectsaoguang"..i]:stopEffect();
		
		objSwf["effectyilingqu"..i].visible = false;
		objSwf["effectyilingqu"..i]:stopEffect();
	end
	
	if RegisterAwardModel.outlinetime > 0 then
		--基本收益
		objSwf.numexpbase.num = expnum;
		
		--双倍收益
		objSwf.numexptwo.num = expnum * 2;
		objSwf.numzhenqitwo.num = zhenqinum * 2;
		
		--三倍收益
		objSwf.numexpthree.num = expnum * 3;
		objSwf.numzhenqithree.num = zhenqinum * 3;
		
		objSwf.btnget.disabled = false;
		objSwf.btngettwo.disabled = false;
		objSwf.btngetthree.disabled = false;
		
		-- objSwf.effectsaoguang1.visible = true;
		-- objSwf.effectsaoguang1:playEffect(0);
		objSwf.btnget:showEffect(ResUtil:GetButtonEffect10());
		
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaVIPLevel >= 1 then
			objSwf.btngettwo:showEffect(ResUtil:GetButtonEffect10());
			-- objSwf.effectsaoguang2.visible = true;
			-- objSwf.effectsaoguang2:playEffect(0);
		end
		
		if playerinfo.eaVIPLevel >= 5 then
			-- objSwf.effectsaoguang3.visible = true;
			-- objSwf.effectsaoguang3:playEffect(0);
			objSwf.btngetthree:showEffect(ResUtil:GetButtonEffect10());
		end
	else
		objSwf.btntip2.visible = true;
		objSwf.btntip3.visible = true;
		if RegisterAwardModel.outlineawardtype == 1 then
			objSwf.btnget.visible = false;
		elseif RegisterAwardModel.outlineawardtype == 2 then
			objSwf.btngettwo.visible = false;
			objSwf.btntip2.visible = false;
		elseif RegisterAwardModel.outlineawardtype == 3 then
			objSwf.btngetthree.visible = false;
			objSwf.btntip3.visible = false;
		end
		
		objSwf["effectyilingqu"..RegisterAwardModel.outlineawardtype].visible = true;
		objSwf["effectyilingqu"..RegisterAwardModel.outlineawardtype]:playEffect(1);
	end
end

--显示时间
function UIRegisterOutLineView:ShowTime()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local hour = RegisterAwardModel.outlinetime / 60
	if hour % 1 > 0 then
		hour = hour - hour % 1;
	end
	local min = RegisterAwardModel.outlinetime % 60
	
	if hour < 10 then
		hour = "0"..hour;
	end
	if min < 10 then
		min = "0"..min;
	end
	-- if sec < 10 then
		-- sec = sec.." ";
	-- end
	local sec = "00";
	
	-- objSwf.numtime.num = hour.."m"..min.."m"..sec;
	objSwf.numtime.text = hour..":"..min..":"..sec;
end

--刷新已完成图标
function UIRegisterOutLineView:ShowImgState(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf["imggetted"..i]._visible = true;
end