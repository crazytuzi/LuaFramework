--[[
打宝活力值-消耗等级设置
2015年1月22日19:47:26
haohu
]]

_G.UIDropValueSetting = BaseUI:new("UIDropValueSetting");

function UIDropValueSetting:Create()
	self:AddSWF("dropValueSetting.swf", true, "center");
end

function UIDropValueSetting:OnLoaded( objSwf )
	objSwf.btnClose.click         = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click       = function() self:OnBtnConfirmClick(); end
	objSwf.btnCancel.click        = function() self:OnBtnCancelClick(); end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadComplete(); end
	objSwf.si.maximum = DropValueConsts:GetDVCeiling();
	objSwf.tipsButton.rollOver = function() self:OnTipsBtnRollOver(); end
	objSwf.tipsButton.rollOut = function() self:OnTipsBtnRollOut(); end
	self:InitOptions(objSwf);
end

function UIDropValueSetting:OnShow()
	self:UpdateShow();
end

function UIDropValueSetting:InitOptions(objSwf)
	local dvLevel0 = 0;
	local vipLvl0, multiple0 = DropValueConsts:GetDropValueInfo(dvLevel0);
	local rbLevel0 = objSwf.rbLevel0;
	local vipLoader0 = objSwf.vipLoader0;
	rbLevel0.htmlLabel = StrConfig['dropValue202'];
	vipLoader0._visible = vipLvl0 ~= 0;
	vipLoader0.num = vipLvl0;
	rbLevel0.data = dvLevel0;
	--------------------------------
	local dvLevel1 = 1;
	local vipLvl1, multiple1 = DropValueConsts:GetDropValueInfo(dvLevel1);
	local rbLevel1 = objSwf.rbLevel1;
	local vipLoader1 = objSwf.vipLoader1;
	rbLevel1.htmlLabel = string.format( StrConfig['dropValue203'], multiple1 );
	vipLoader1._visible = vipLvl1 ~= 0;
	vipLoader1.num = vipLvl1;
	rbLevel1.data = dvLevel1;
	--------------------------------
	local dvLevel2 = 2;
	local vipLvl2, multiple2 = DropValueConsts:GetDropValueInfo(dvLevel2);
	local rbLevel2 = objSwf.rbLevel2;
	local vipLoader2 = objSwf.vipLoader2;
	rbLevel2.htmlLabel = string.format( StrConfig['dropValue203'], multiple2 );
	vipLoader2._visible = vipLvl2 ~= 0;
	vipLoader2.num = vipLvl2;
	rbLevel2.data = dvLevel2;
	--------------------------------
	local dvLevel3 = 3;
	local vipLvl3, multiple3 = DropValueConsts:GetDropValueInfo(dvLevel3);
	local rbLevel3 =  objSwf.rbLevel3;
	local vipLoader3 = objSwf.vipLoader3;
	rbLevel3.htmlLabel = string.format( StrConfig['dropValue203'], multiple3 );
	vipLoader3._visible = vipLvl3 ~= 0;
	vipLoader3.num = vipLvl3;
	rbLevel3.data = dvLevel3;
end

function UIDropValueSetting:UpdateShow()
	self:ShowDropValue();
	self:ShowOption();
end

-- 活力值
function UIDropValueSetting:ShowDropValue()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dropValue = MainPlayerModel.humanDetailInfo.eaDropVal;
	objSwf.si.value = dropValue;
	objSwf.numLoader:drawStr( dropValue .. "p" .. DropValueConsts:GetDVCeiling() );
end

-- 选项
function UIDropValueSetting:ShowOption()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currLevel = DropValueModel:GetDropValueLevel();
	local radioButton = objSwf["rbLevel"..currLevel];
	if radioButton then
		radioButton.selected = true;
	end
end

function UIDropValueSetting:OnBtnCloseClick()
	self:Hide();
end

function UIDropValueSetting:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local setLevel = objSwf._buttonGroup_option.data;
	local currLevel = DropValueModel:GetDropValueLevel();
	if setLevel ~= currLevel then
		DropValueController:SetDynamicDrop( setLevel );
	end
	self:Hide();
end

function UIDropValueSetting:OnBtnCancelClick()
	self:Hide();
end

function UIDropValueSetting:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numLoader = objSwf.numLoader;
	local bg = objSwf.si;
	numLoader._x = bg._x + ( bg._width - numLoader._width ) * 0.5;
end

function UIDropValueSetting:OnTipsBtnRollOver()
	local dropValue = MainPlayerModel.humanDetailInfo.eaDropVal;
	local dailyGain = DropValueConsts:GetDVDailyGain();
	TipsManager:ShowBtnTips( string.format( StrConfig['dropValue204'], dropValue, dailyGain ) );
end

function UIDropValueSetting:OnTipsBtnRollOut()
	TipsManager:Hide();
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIDropValueSetting:ListNotificationInterests()
	return {
		NotifyConsts.SetDropValueLevel,
		NotifyConsts.PlayerAttrChange
	};
end

--处理消息
function UIDropValueSetting:HandleNotification(name, body)
	if name == NotifyConsts.SetDropValueLevel then
		self:ShowOption();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaDropVal then
			self:ShowDropValue();
		end
	end
end
