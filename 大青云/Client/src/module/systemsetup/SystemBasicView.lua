--[[
	2015年1月14日, PM 03:08:02
	系统设置主面板
	wangyanwei
]]

_G.UISystemBasic = BaseUI:new('UISystemBasic');

UISystemBasic.tabButton = {};

UISystemBasic.setState = false;

function UISystemBasic:Create()
	self:AddSWF("mainPageSetPanel.swf", true, "center");
	
	self:AddChild(UISetSystem,"setsys");
	self:AddChild(UISetFunc,"setfunc");
	self:AddChild(UISetSkill,"setskill");
end

UISystemBasic.buttonTabel = {};
function UISystemBasic:OnLoaded(objSwf)
	self:GetChild('setsys'):SetContainer(objSwf.childPanel);
	self:GetChild('setfunc'):SetContainer(objSwf.childPanel);
	self:GetChild('setskill'):SetContainer(objSwf.childPanel);
	--
	objSwf.btn_close.click = function () self:OnCloseClick(); end
	--
	self.tabButton['setsys'] = objSwf.btn_setsys;
	self.tabButton['setfunc'] = objSwf.btn_setfunc;
	self.tabButton['setskill'] = objSwf.btn_setskill;
	
	self.buttonTabel[1] = objSwf.btn_setsys;
	self.buttonTabel[2] = objSwf.btn_setfunc;
	self.buttonTabel[3] = objSwf.btn_setskill;
	for i , v in pairs(self.tabButton) do
		v.click = function () self:OnTabClickHandler(i); end
	end
	
	objSwf.btn_init.click = function () self:OnSetInit(); end
	objSwf.btn_cancel.click = function () self:OnSetCancel(); end
	objSwf.btn_save.click = function () self:onSaveClick() end
	objSwf.btn_until.click = function () self:OnUntilClick(); end
	-- objSwf.bg.hitTestDisable = true;
	objSwf.btn_save._visible = false;
	objSwf.btn_cancel._visible = false;
end

function UISystemBasic:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	for i , v in ipairs(self.buttonTabel) do
		self.buttonTabel[i] = nil;
	end
end

function UISystemBasic:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_until.disabled = true;
	self:OnTabClickHandler('setsys');
end

--点击标签
UISystemBasic.oldTabButton = '';
function UISystemBasic:OnTabClickHandler(name)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if UIConfirm:IsShow() then
		return;
	end
	self.oldTabButton = name;
	if not self.tabButton[name] then
		return ;
	end
	local child = self:GetChild(name);
	if not child then
		return ;
	end
	self.tabButton[name].selected = true;
	for i , v in pairs (self.buttonTabel) do
		v.babel = UIStrConfig['setsys' .. i];
	end
	self:ShowChild(name);
end

--恢复默认按钮
function UISystemBasic:OnSetInit()
	UISetFunc.listIndex = 0;
	UISetSkill.listStr = {};
	UISetSkill.listIndex = 0;
	self.setState = false;       --修改状态清掉
	UISetSystem.selectePlayerNum = 0;
	SetSystemModel:SetFuncInitKey();  --把按键恢复
	local str = SetSystemModel:GetFuncKeyStr();
	if not str then return end
	local val = SetSystemConsts.ININTSHOWMODEL ;   --得到要显示的选项
	SetSystemController:OnSendSetModel(val,str);
	self.objSwf.btn_until.disabled = true;
	UISetSystem:SetSliderAudioTxt(SetSystemModel:LoadDefaultAudioValue());
	UISetSystem:SetSliderSoundEffectTxt(SetSystemModel:LoadDefaultSoundEffectValue());
	SetSystemModel:SaveAudioValue(UISetSystem.audioValue);
	SetSystemModel:SaveSoundEffectValue(UISetSystem.soundEffectValue);
end

--应用点击
function UISystemBasic:OnUntilClick()
	self:OnSetSave();
	self.objSwf.btn_until.disabled = true;
end

--保存点击
function UISystemBasic:onSaveClick()
	self:OnSetSave();
	self:Hide();
end

--保存事件
function UISystemBasic:OnSetSave()
	if not self.setState then 
		return
	end
	local str = SetSystemModel:GetFuncKeyStr();
	if not str then return end
	if UISetSystem.selectePlayerNum == 0 then 
		UISetSystem:OnPlayerChange();
	end
	local val = UISetSystem.selecteNum + UISetSystem.selectePlayerNum + UISetSystem.drawLevelNum ;   --得到要显示的选项
	SetSystemController:OnSendSetModel(val,str);
	self.setState = false;       --修改状态清掉
	UISetSystem.selectePlayerNum = 0;
	--UISetSystem.drawLevelNum = 0;
	UISetFunc.listIndex = 0;
	UISetSkill.listStr = {};
	UISetSkill.listIndex = 0;
	SetSystemModel:SaveAudioValue(UISetSystem.audioValue);
	SetSystemModel:SaveSoundEffectValue(UISetSystem.soundEffectValue);
	----------发送数据----------
end

--取消事件
function UISystemBasic:OnSetCancel()
	UISetFunc.listIndex = 0;
	UISetSkill.listStr = {};
	UISetSkill.listIndex = 0;
	self.setState = false;       --修改状态清掉
	SetSystemModel:SetFuncKeyHandler();  --把按键恢复
	UISetSystem:OnInitSet();     --显示数据清掉
	UISetSystem:SetSliderAudioTxt(SetSystemModel:LoadAudioValue());
	UISetSystem:SetSliderSoundEffectTxt(SetSystemModel:LoadSoundEffectValue());
	self:Hide();
end

--关闭事件
function UISystemBasic:OnBeforeHide()
	if self.setState then
		self:OnCloseClick();
	else
		return true;
	end
end

--关闭按钮
function UISystemBasic:OnCloseClick()
	if self.setState then
		local func = function () 
			UISetFunc.listIndex = 0;
			UISetSkill.listIndex = 0;
			self.setState = false;       --修改状态清掉
			SetSystemModel:SetFuncKeyHandler();  --把按键恢复
			UISetSystem:OnInitSet();     --显示数据清掉
			UISetSystem:SetSliderAudioTxt(SetSystemModel:LoadAudioValue());
			UISetSystem:SetSliderSoundEffectTxt(SetSystemModel:LoadSoundEffectValue());
			self:Hide();
		end
		UIConfirm:Open(StrConfig['setsys0105'],func);
	else
		self:Hide();
	end
end

function UISystemBasic:OnHide()
	
end


--父面板处理↓↓↓↓↓↓↓↓↓↓↓

function UISystemBasic:GetWidth()
	return 464;
end
function UISystemBasic:GetHeight()
	return 688;
end

function UISystemBasic:IsTween()
	return true;
end

function UISystemBasic:WithRes()
	return {"setSystemPanel.swf"};
end

function UISystemBasic:IsShowSound()
	return true;
end

function UISystemBasic:GetPanelType()
	return 1;
end

function UISystemBasic:IsShowLoading()
	return true;
end

function UISystemBasic:HandleNotification(name,body)
	if name == NotifyConsts.SetSystemDisabled then
		self.objSwf.btn_until.disabled = false;
	end
end

function UISystemBasic:ListNotificationInterests()
	return {
		NotifyConsts.SetSystemDisabled,
	}
end