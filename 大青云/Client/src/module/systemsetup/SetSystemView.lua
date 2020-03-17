--[[
	2015年1月14日, PM 03:18:22
	设置系统子面板
	wangyanwei
]]

_G.UISetSystem = BaseUI:new('UISetSystem');

function UISetSystem:Create()
	self:AddSWF("setSystemPanel.swf", true, nil);
end

function UISetSystem:OnLoaded(objSwf)

	objSwf.txt_2.text = StrConfig['setsys72'];
	objSwf.txt_3.text = StrConfig['setsys73'];
	objSwf.txt_4.text = StrConfig['setsys74'];
	objSwf.txt_2._visible = false;
	objSwf.txt_4._visible = false;	
	
	objSwf.tf1.text = UIStrConfig['setsys100'];
	objSwf.tf2.text = UIStrConfig['setsys101'];
	objSwf.tf3.text = UIStrConfig['setsys102'];
	objSwf.tf2._visible = false;

	objSwf.sliderAudio.value = SetSystemModel:LoadAudioValue() / 100;
	objSwf.sliderSoundEffect.value = SetSystemModel:LoadSoundEffectValue() / 100;
	self:SetSliderAudioTxt(SetSystemModel:LoadAudioValue());
	self:SetSliderSoundEffectTxt(SetSystemModel:LoadSoundEffectValue());

	objSwf.sliderAudio.change = function() self:OnSliderAudioChange(e) end
	objSwf.sliderSoundEffect.change = function() self:OnSliderSoundEffectChange(e) end

	--画面配置
	objSwf.sliderDrawLevel.change = function() self:OnChangeDrawLevelSlider(e) end


	objSwf.musicBG.click = function () self:OnPlayerChangeNum(SetSystemConsts.MUSICOPEN); end
	objSwf.musicGame.click = function () self:OnPlayerChangeNum(SetSystemConsts.MUSICBGOPEN); end
	objSwf.checkMutual_1.click = function () self:OnPlayerChangeNum(SetSystemConsts.TEAMISOPEN); end
	objSwf.checkMutual_2.click = function () self:OnPlayerChangeNum(SetSystemConsts.DEALISOPEN); end
	objSwf.checkMutual_3.click = function () self:OnPlayerChangeNum(SetSystemConsts.FRIENDISOPEN); end
	objSwf.checkMutual_4.click = function () self:OnPlayerChangeNum(SetSystemConsts.UNIONISOPEN); end
	objSwf.btnRadioPlayer_6.click = function () self:OnPlayerChangeNum(SetSystemConsts.UNSHOWNUMNAME); end
	objSwf.btnRadioPlayer_1.click = function () self:OnPlayerChange(SetSystemConsts.UNSHOWNUMZERO); end
	objSwf.btnRadioPlayer_2.click = function () self:OnPlayerChange(SetSystemConsts.UNSHOWNUMTEN); end
	objSwf.btnRadioPlayer_3.click = function () self:OnPlayerChange(SetSystemConsts.UNSHOWNUMTWENTY); end
	objSwf.btnRadioPlayer_4.click = function () self:OnPlayerChange(SetSystemConsts.UNSHOWNUMTHIRTY); end
	objSwf.btnRadioPlayer_5.click = function () self:OnPlayerChange(SetSystemConsts.UNSHOWNUMALL); end
	objSwf.checkShield_1.click = function () self:OnPlayerChangeNum(SetSystemConsts.ISSHOWSKILL); end
	objSwf.checkShield_2.click = function () self:OnPlayerChangeNum(SetSystemConsts.ISOPENFLASH); end
	objSwf.checkShield_3.click = function () self:OnPlayerChangeNum(SetSystemConsts.ISSHOWCOMMONMONSTER); end
	objSwf.checkShield_4.click = function () self:OnPlayerChangeNum(SetSystemConsts.ISSHOWTITLE); end
	objSwf.btnRadioPlayer_1._visible = false;
	objSwf.btnRadioPlayer_2._visible = false;
	objSwf.btnRadioPlayer_3._visible = false;
	objSwf.btnRadioPlayer_4._visible = false;
	objSwf.btnRadioPlayer_5._visible = false;
	objSwf.checkMutual_2._visible = false;
	objSwf.checkShield_4._visible = false;

	--高光  泛光
	objSwf.highDefinition._visible = false;
	objSwf.flowRight._visible = false;
	objSwf.highDefinition.click = function () self:OnPlayerChangeNum(SetSystemConsts.HIGHDEFINITION); end
	objSwf.flowRight.click = function () self:OnPlayerChangeNum(SetSystemConsts.FLOWRIGHT); end

	--多倍视角
	objSwf.overlooks._visible = false;	
	objSwf.overlooks.click = function () self:OnPlayerChangeNum(SetSystemConsts.DOUBLEOVERLOOKS); end
	objSwf.tf4._visible = false;
	objSwf.overlooks.visible = false;
end

function UISetSystem:OnShow()
	--SetSystemModel:UpDataSetModel(1024);
	self:OnShowSelecteBtn();
	self:OnPlayerChange();
	self:OnDrawClickChange();
	if not UISystemBasic.setState then
		self.selecteNum = SetSystemModel.oldSetVal;
	end
end

--音乐滑动条
function UISetSystem:OnSliderAudioChange(e)
	UISystemBasic.setState = true;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local value = objSwf.sliderAudio.value;
	self:SetSliderAudioTxt(value * 100);
	Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
end
UISetSystem.audioValue = 0;
function UISetSystem:SetSliderAudioTxt(value)
	value = toint(value)
	self.objSwf.txtAudio.text = value .. "%";
	self.audioValue = value;
	self.objSwf.sliderAudio.value = value / 100;
	SetSystemModel:SetAllVolume(self.audioValue, self.soundEffectValue)
end

--音效滑动条
function UISetSystem:OnSliderSoundEffectChange(e)
	UISystemBasic.setState = true;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local value = objSwf.sliderSoundEffect.value;
	self:SetSliderSoundEffectTxt(value * 100);
	Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
end

UISetSystem.soundEffectValue = 0;
function UISetSystem:SetSliderSoundEffectTxt(value)
	value = toint(value)
	self.objSwf.txtSoundEffect.text = value .. "%";
	self.soundEffectValue = value;
	self.objSwf.sliderSoundEffect.value = value / 100;
	SetSystemModel:SetAllVolume(self.audioValue, self.soundEffectValue)
end

--显示档位
function UISetSystem:OnChangeDrawLevelSlider(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local value = objSwf.sliderDrawLevel.value;
	if value <= 0.25 and value >=0 then
		objSwf.sliderDrawLevel.value = 0;
		self:OnDrawClickChange(SetSystemConsts.DRAWLOW);
		self:OnPlayerChange(SetSystemConsts.UNSHOWNUMTEN)
		if bit.band(self.selecteNum,SetSystemConsts.FLOWRIGHT) == SetSystemConsts.FLOWRIGHT then
			self.selecteNum = self.selecteNum - SetSystemConsts.FLOWRIGHT ;
		end
	end
	if value > 0.25 and value < 0.75 then
		objSwf.sliderDrawLevel.value = 0.5;
		self:OnDrawClickChange(SetSystemConsts.DRAWMID);
		self:OnPlayerChange(SetSystemConsts.UNSHOWNUMTWENTY)
		if bit.band(self.selecteNum,SetSystemConsts.FLOWRIGHT) == SetSystemConsts.FLOWRIGHT then
			self.selecteNum = self.selecteNum - SetSystemConsts.FLOWRIGHT ;
		end
	end
	if value >= 0.75 and value <= 1 then
		objSwf.sliderDrawLevel.value = 1;
		self:OnDrawClickChange(SetSystemConsts.DRAWHIGH);
		self:OnPlayerChange(SetSystemConsts.UNSHOWNUMALL)
		if bit.band(self.selecteNum,SetSystemConsts.FLOWRIGHT) ~= SetSystemConsts.FLOWRIGHT then
			self.selecteNum = self.selecteNum + SetSystemConsts.FLOWRIGHT ;
		end
	end
end

--显示设置点击
UISetSystem.selecteNum = 0;
function UISetSystem:OnPlayerChangeNum(num)
	UISystemBasic.setState = true;
	if bit.band(self.selecteNum,num) == num then
		self.selecteNum = self.selecteNum - num ;
	else
		self.selecteNum = self.selecteNum + num ;
	end
	self:OnPlayerChange();
	self:OnDrawClickChange();
	Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
end

--画面配置点击
UISetSystem.drawLevelNum = 0;
function UISetSystem:OnDrawClickChange(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not num then
		if objSwf.sliderDrawLevel.value == 0 then
			self.drawLevelNum = SetSystemConsts.DRAWLOW
		elseif objSwf.sliderDrawLevel.value == 0.5 then
			self.drawLevelNum = SetSystemConsts.DRAWMID
		elseif objSwf.sliderDrawLevel.value == 1 then
			self.drawLevelNum = SetSystemConsts.DRAWHIGH
		end
		return
	end
	UISystemBasic.setState = true;
	self.drawLevelNum = num;
	Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
end

UISetSystem.selectePlayerNum = 0;
function UISetSystem:OnPlayerChange(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not num then
		--[[if objSwf.btnRadioPlayer_1.selected then
			self.selectePlayerNum = SetSystemConsts.UNSHOWNUMZERO;
		elseif objSwf.btnRadioPlayer_2.selected then
			self.selectePlayerNum = SetSystemConsts.UNSHOWNUMTEN;
		elseif objSwf.btnRadioPlayer_3.selected then
			self.selectePlayerNum = SetSystemConsts.UNSHOWNUMTWENTY;
		elseif objSwf.btnRadioPlayer_4.selected then
			self.selectePlayerNum = SetSystemConsts.UNSHOWNUMTHIRTY;
		elseif objSwf.btnRadioPlayer_5.selected then
			self.selectePlayerNum = SetSystemConsts.UNSHOWNUMALL;
		end]]
		return;
	end
	UISystemBasic.setState = true;
	self.selectePlayerNum = num;
	Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
end

function UISetSystem:OnInitSet()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self.selecteNum = SetSystemModel.oldSetVal;
	self.selectePlayerNum = 0;
	self.drawLevelNum = 0;
	self:OnShowSelecteBtn();
end	

--给选项赋值
function UISetSystem:OnShowSelecteBtn()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if UISystemBasic.setState then
		return 
	end
	objSwf.checkMutual_1.visible = false;
	local cfg = SetSystemModel.SetModel;
	objSwf.highDefinition.selected = cfg:GetHighDefinition();
	objSwf.flowRight.selected = cfg:GetFlowRight();
	objSwf.musicBG.visible = false;		
	objSwf.musicBG.selected = cfg:GetMusicIsOpen();
	objSwf.musicGame.visible = false;		
	objSwf.musicGame.selected = cfg:GetBGMusicIsOpen();
	objSwf.checkMutual_1.selected = cfg:GetTeamIsOpen();
	objSwf.checkMutual_2.selected = cfg:GetDealIsOpen();
	objSwf.checkMutual_3.selected = cfg:GetFriendIsOpen();
	objSwf.checkMutual_4.selected = cfg:GetUnionIsOpen();
	objSwf.btnRadioPlayer_6.selected = cfg:GetUnAllPlayerShowName();
	--[[local playerNum = cfg:GetUnShowNum();
	if playerNum == 0 then
		objSwf.btnRadioPlayer_1.selected = true;
	elseif playerNum == 1 then
		objSwf.btnRadioPlayer_2.selected = true;
	elseif playerNum == 2 then 
		objSwf.btnRadioPlayer_3.selected = true;
	elseif playerNum == 3 then
		objSwf.btnRadioPlayer_4.selected = true;
	elseif not playerNum or playerNum == 4 then
		objSwf.btnRadioPlayer_5.selected = true;
	end]]
	objSwf.checkShield_1.selected = cfg:GetIsShowSkill();
	objSwf.checkShield_2.selected = cfg:GetIsOpenFlash();
	objSwf.checkShield_3.selected = cfg:GetIsShowCommonMonster();
	objSwf.checkShield_4.selected = cfg:GerIsShowTitle();
	
	local drawLevel = SetSystemVO:GetDrawLevel();
	if drawLevel == DisplayQuality.lowQuality then
		objSwf.sliderDrawLevel.value = 0;
	elseif drawLevel == DisplayQuality.midQuality then
		objSwf.sliderDrawLevel.value = 0.5;
	elseif drawLevel == DisplayQuality.highQuality then
		objSwf.sliderDrawLevel.value = 1;
	end
	--self:OpenFunc();
	objSwf.overlooks.selected = cfg:GetIsDoubleLooks();
end

function UISetSystem:OnHide()
	
end

-----------------------------------------------------------------------------------
function UISetSystem:HandleNotification(name,body)
	if name == NotifyConsts.SetSystemShowChange then
		self:OnShowSelecteBtn();
		self.selecteNum = SetSystemModel.oldSetVal;
	end
	
end
function UISetSystem:ListNotificationInterests()
	return {
		NotifyConsts.SetSystemShowChange
	}
end

