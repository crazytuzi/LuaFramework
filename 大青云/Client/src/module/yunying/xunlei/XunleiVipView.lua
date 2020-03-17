--[[
迅雷
wangshuai
2015年11月12日17:28:13
]]

_G.XunleiVip = BaseUI:new("XunleiVip")

function XunleiVip:Create()
	self:AddSWF("xunleiVipPanel.swf",true,'center')
end;

function XunleiVip:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goChongzhi.click = function() self:GoChongzhiClick()end;
	objSwf.fuzhiBtn.click = function() self:Openqqclick() end;
end;

function XunleiVip:OnShow()
	self:SetQQNumber();
end;

function XunleiVip:OnHide()

end;

function XunleiVip:GoChongzhiClick()
	--充值界面
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Charge()
end;

function XunleiVip:Openqqclick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:OpenXunleiQQWeb()
end;

function XunleiVip:SetQQNumber()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local addMoney = YunYingController.addExoenseMoney;
	local maxMoney = YunYingController.maxExoenseMoney;
	local state = YunYingController.platIconState
	if state then 
		objSwf.qqNumber.htmlText = "专属客服QQ：800051551"
		objSwf.fuzhiBtn.disabled = false;
	else
		objSwf.qqNumber.htmlText = "专属客服QQ：**********"
		objSwf.fuzhiBtn.disabled = true;
	end;
end;


function XunleiVip:HandleNotification(name,body)
	if name == NotifyConsts.AddExpenseMoney then
		self:SetQQNumber();
	end
end

function XunleiVip:ListNotificationInterests()
	return {
		NotifyConsts.AddExpenseMoney,
	}
end

-- 是否缓动
function XunleiVip:IsTween()
	return true;
end

--面板类型
function XunleiVip:GetPanelType()
	return 1;
end
--是否播放开启音效
function XunleiVip:IsShowSound()
	return true;
end

function XunleiVip:IsShowLoading()
	return true;
end