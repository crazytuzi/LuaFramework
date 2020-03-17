--[[ 
v计划，年费展示
wangshuai
]]
_G.UIVplanYear = BaseUI:new("UIVplanYear")

function UIVplanYear:Create()
	self:AddSWF("vplanYearVipPanel.swf",true,nil)
end;

function UIVplanYear:OnLoaded(objSwf)
	objSwf.giveMeReward.click = function() self:OnGiveReward() end;
	objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
end;

function UIVplanYear:OnShow()
	self:SetShowState();
end;

function UIVplanYear:OnGiveReward()
	if VplanModel:GetIsVplan() then -- 已开通，一件领取 
		VplanController:ReqVplanYearGift()
	else
		VplanController:ToYRecharge()
	end;
end

function UIVplanYear:SetShowState()
	local objSwf = self.objSwf;
	local isYaerVip = VplanModel:GetYearVplan()
	local isgetYaerGift = VplanModel:GetYearGiftState();
	if isYaerVip then 
		if isgetYaerGift then -- 未领取
			objSwf.giveMeReward.disabled = false
		else -- 以领取
			objSwf.giveMeReward.disabled = true
		end;
		objSwf.giveMeReward.textField.text = StrConfig['vplan902']
	else
		objSwf.giveMeReward.textField.text = StrConfig['vplan903']
	end;
end;

function UIVplanYear:OnHide()

end;

function UIVplanYear:HandleNotification(name,body)
	if name==NotifyConsts.VFlagChange then
		self:SetShowState();
	end
end

function UIVplanYear:ListNotificationInterests()
	return {NotifyConsts.VFlagChange};
end