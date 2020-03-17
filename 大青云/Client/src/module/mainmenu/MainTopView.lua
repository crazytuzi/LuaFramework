--[[
    Created by IntelliJ IDEA.
    UI顶部条
    User: Hongbin Yang
    Date: 2016/10/12
    Time: 22:34
   ]]


_G.UIMainTop = BaseUI:new("UIMainTop");

function UIMainTop:Create()
	self:AddSWF("mainPageTop.swf", false, "interserver");
end

function UIMainTop:OnLoaded(objSwf)
	self:Init(objSwf);
	self:RegisterOtherEvents(objSwf);
	-- 元宝 绑元 灵力
	for _, btn in pairs( { objSwf.btnMoney, objSwf.btnGold, objSwf.btnBindGold } ) do
		btn.textField.autoSize = "left";
		btn.rollOver = function(e) self:OnAttrOver(e); end
		btn.rollOut  = function() self:OnAttrOut(); end
	end
	self:LayoutRight();
end

function UIMainTop:NeverDeleteWhenHide()
	return true;
end
function UIMainTop:OnShow()
	self:SetAttrShow();
	self:UpdateOther();
end


--显示元宝 /绑元 /灵力
function UIMainTop:SetAttrShow(attrName, attrValue)
	if attrName then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local attrTxt = _G.getNumShow(attrValue);
		if attrName == enAttrType.eaUnBindMoney then
			if toint(attrValue) > 100000 then
				attrValue = getNumShow(attrValue);
			end
			objSwf.btnMoney.label = attrValue;
			objSwf.btnMoney.data = string.format( StrConfig["mainmenuHead001"], attrValue );
			-- elseif attrName == enAttrType.eaBindMoney then
			-- objSwf.btnBindMoney.label = attrValue--attrTxt;
			-- objSwf.btnBindMoney.data = string.format( StrConfig["mainmenuHead002"], attrValue );
		elseif attrName == enAttrType.eaBindGold then
			if toint(attrValue) > 100000 then
				attrValue = getNumShow(attrValue);
			end
			objSwf.btnBindGold.label = attrValue;
			objSwf.btnBindGold.data = string.format( StrConfig["mainmenuHead003"], attrValue );
		elseif attrName == enAttrType.eaBindMoney then
			if toint(attrValue) > 100000 then
				attrValue = getNumShow(attrValue);
			end
			objSwf.btnGold.label = attrValue;
			objSwf.btnGold.data = string.format( StrConfig["mainmenuHead101"], attrValue );
		end
	else
		local info = MainPlayerModel.humanDetailInfo;
		self:SetAttrShow( enAttrType.eaUnBindMoney, info.eaUnBindMoney );
		self:SetAttrShow( enAttrType.eaBindMoney, info.eaBindMoney );
		self:SetAttrShow( enAttrType.eaBindGold, info.eaBindGold );
		self:SetAttrShow( enAttrType.eaUnBindGold, info.eaUnBindGold );
	end
end


function UIMainTop:OnAttrOver(e)
	local tipsStr = e.target.data;
	if tipsStr then
		TipsManager:ShowBtnTips( tipsStr );
	end
end

function UIMainTop:OnAttrOut()
	TipsManager:Hide();
end

--监听消息列表
function UIMainTop:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
	}
end

--处理消息
function UIMainTop:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaUnBindMoney or body.type == enAttrType.eaBindMoney or
				body.type == enAttrType.eaBindGold or body.type == enAttrType.eaUnBindGold then
			self:SetAttrShow(body.type, toint(body.val,0.5));
		end
	end
end

function UIMainTop:GetGoldIconGlobalPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	return UIManager:PosLtoG(objSwf, objSwf.goldIcon._x, objSwf.goldIcon._y);
end

function UIMainTop:GetBindMoneyIconGlobalPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	return UIManager:PosLtoG(objSwf, objSwf.bindMoneyIcon._x, objSwf.bindMoneyIcon._y);
end


function UIMainTop:OnResize(dwWidth,dwHeight)
	self:LayoutRight();
end

function UIMainTop:LayoutRight()
	local wWidth, wHeight = UIManager:GetWinSize();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.right._x = wWidth - objSwf.right._width - 5;
end

---------------------------以下为与地图无关，或次要地图信息的处理-----------------------------
UIMainTop.BtnSet   = "BtnSet";
UIMainTop.BtnMail  = "BtnMail";
UIMainTop.BtnMusic  = "BtnMusic";
UIMainTop.BtnPingbi  = "BtnPingbi";
UIMainTop.BtnGuaji = "BtnGuaji";
UIMainTop.BtnNotice  = "BtnNotice";
UIMainTop.BtnTeam  = "BtnTeam";
UIMainTop.BtnFriend = "BtnFriend";
UIMainTop.BtnEye = "BtnEye";

function UIMainTop:Init(objSwf)
	objSwf.right.btnSet.data         = UIMainTop.BtnSet;
	objSwf.right.btnMail.data        = UIMainTop.BtnMail;
	objSwf.right.btnMusic.data        = UIMainTop.BtnMusic;
	objSwf.right.btnNotice.data        = UIMainTop.BtnNotice;
	--	objSwf.btnPingbi.data       = UIMainTop.BtnPingbi;
	objSwf.right.btnGuaji.data       = UIMainTop.BtnGuaji;
	objSwf.right.btnFriend.data	   = UIMainTop.BtnFriend;
	-- objSwf.btnTeam.data 	   = UIMainTop.BtnTeam;
	objSwf.right.btnEye.data 		= UIMainTop.BtnEye;
	self:InitMusicState();
	SmallEyeView:UpdateSmallEyeButton();
end

function UIMainTop:RegisterOtherEvents(objSwf)
	self:RegisterBtn( objSwf.right.btnSet );
	self:RegisterBtn( objSwf.right.btnMail );
	--	self:RegisterBtn( objSwf.btnPingbi );
	self:RegisterBtn( objSwf.right.btnMusic );
	self:RegisterBtn( objSwf.right.btnNotice );
	self:RegisterBtn( objSwf.right.btnGuaji );
	self:RegisterBtn( objSwf.right.btnFriend);
	-- self:RegisterBtn( objSwf.btnTeam);
	self:RegisterBtn( objSwf.right.btnEye);
end

function UIMainTop:RegisterBtn(btn)
	if btn then
		local param = btn.data;
		btn.click    = function() self:OnBtnClick( param ); end
		btn.rollOver = function() self:OnBtnRollOver( param ); end
		btn.rollOut  = function() self:OnBtnRollOut( param ); end
	end
end

-- @param: btn.data.
function UIMainTop:OnBtnClick(param)
	if not param then
		Debug("need to init btn to fill it's 'data' property")
		return
	end
	if not FuncOpenController.keyEnable then
		return;
	end
	if param == UIMainTop.BtnSet then
		self:SwitchPanel( UISystemBasic );
	elseif param == UIMainTop.BtnMail then
		self:SwitchPanel( UIMail );
	elseif param == UIMainTop.BtnGuaji then
		self:SwitchPanel( UIAutoBattle );
	elseif param == UIMainTop.BtnMusic then
		--	self:SwitchPanel( UIAutoBattle );
		if self.objSwf.right.btnMusic.selected then
			SetSystemController:CloseBackSoundVolume();
			SetSystemController:CloseMusicVolume();
			SetSystemModel:SaveAudioMute(0);
			TipsManager:ShowBtnTips( StrConfig["mainmenuMap11"] );
		else
			SetSystemController:OpenBackSoundVolume();
			SetSystemController:OpenMusicVolume();
			SetSystemModel:SaveAudioMute(1);
			TipsManager:ShowBtnTips( StrConfig["mainmenuMap14"] );
		end
	elseif param == UIMainTop.BtnNotice then
		self:SwitchPanel( UIUpdateNoticeView );
	elseif param == UIMainTop.BtnPingbi then
		--	self:SwitchPanel( UIAutoBattle );
	elseif param == UIMainTop.BtnFriend then
		FuncManager:OpenFunc(FuncConsts.Friend,true);
	elseif param == UIMainTop.BtnTeam then
		FuncManager:OpenFunc(FuncConsts.Team,true);
	elseif param == UIMainTop.BtnEye then
		if SmallEyeView:IsShow() then
			SmallEyeView:Hide();
		else
			SmallEyeView:Show(self.objSwf.right.btnEye._target);
		end
	end
end

function UIMainTop:OnBtnRollOver(param)
	if not param then
		Debug("need to init btn to fill it's 'data' property")
		return
	end
	if param == UIMainTop.BtnSet then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap03"] );
	elseif param == UIMainTop.BtnMail then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap02"] );
	elseif param == UIMainTop.BtnGuaji then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap04"] );
	elseif param == UIMainTop.BtnFriend then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap08"] );
	elseif param == UIMainTop.BtnTeam then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap09"] );
	elseif param == UIMainTop.BtnMusic then
		if self.objSwf.right.btnMusic.selected then
			TipsManager:ShowBtnTips( StrConfig["mainmenuMap11"] );
		else
			TipsManager:ShowBtnTips( StrConfig["mainmenuMap14"] );
		end
	elseif param == UIMainTop.BtnPingbi then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap12"] );
	elseif param == UIMainTop.BtnNotice then
		TipsManager:ShowBtnTips( StrConfig["mainmenuMap13"] );
	end
end

function UIMainTop:OnBtnRollOut(param)
	TipsManager:Hide();
end

function UIMainTop:SwitchPanel(panel)
	if panel:IsShow() then
		panel:Hide();
		return;
	end
	panel:Show();
end

function UIMainTop:UpdateOther()
end

function UIMainTop:InitMusicState()
	if SetSystemModel:LoadAudioMute() == 0 then
		self.objSwf.right.btnMusic.selected = true;
		SetSystemController:CloseBackSoundVolume();
		SetSystemController:CloseMusicVolume();
	else
		self.objSwf.right.btnMusic.selected = false;
		SetSystemController:OpenBackSoundVolume();
		SetSystemController:OpenMusicVolume();
	end
end

--监听消息列表(不包含地图消息，地图的在父类处理)
function UIMainTop:ListOtherNotiInterests()
	return {
		NotifyConsts.MailNumChanged,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.InterServerState
	};
end

--处理消息(不包含地图消息，地图的在父类处理)
function UIMainTop:HandleOtherNotification(name, body)
	if name == NotifyConsts.InterServerState then
		self:CheckInterServer();
	end
end

function UIMainTop:GetMailBtnPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local btn = objSwf.right.btnMail;
	return UIManager:PosLtoG( btn, 0, 0 );
end

function UIMainTop:GetEyeBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	return objSwf.right.btnEye;
end

--------------------------跨服时要做的处理--------------------------
function UIMainTop:CheckInterServer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.right.btnSet.visible = not MainPlayerController.isInterServer;
	objSwf.right.btnMail.visible = not MainPlayerController.isInterServer;
	objSwf.right.btnGuaji.visible = not MainPlayerController.isInterServer;
	objSwf.right.btnFriend.visible = not MainPlayerController.isInterServer;
	-- objSwf.btnTeam.visible = not MainPlayerController.isInterServer;
	--objSwf.effcontainer._visible = not MainPlayerController.isInterServer;
end
--------------------------------------------------------------------