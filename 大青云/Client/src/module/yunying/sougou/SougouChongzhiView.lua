--[[
搜狗vip
wangshuai
2015年12月7日15:30:39
]]

_G.UISougouVip = BaseUI:new("UISougouVip")

function UISougouVip:Create()
	self:AddSWF("yunyingSougouPanel.swf",true,'center')
end;

function UISougouVip:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goChongzhi.click = function() self:GoChongzhiClick()end;
	objSwf.fuzhiBtn.click = function() self:FuZhiqqclick() end;
end;

function UISougouVip:OnShow()
	self:SetQQNumber();
end;

function UISougouVip:OnHide()

end;

function UISougouVip:GoChongzhiClick()
	--充值界面
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Charge()
end;

function UISougouVip:FuZhiqqclick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	_sys.clipboard = 2851050939
end;

function UISougouVip:SetQQNumber()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local state = YunYingController.platIconState
	if state then 
		objSwf.qqNumber.htmlText = "2851050939"
		objSwf.fuzhiBtn.disabled = false;
	else
		objSwf.qqNumber.htmlText = "**********"
		objSwf.fuzhiBtn.disabled = true;
	end;
end;

function UISougouVip:HandleNotification(name,body)
	if name == NotifyConsts.AddExpenseMoney then
		self:SetQQNumber();
	end
end

function UISougouVip:ListNotificationInterests()
	return {
		NotifyConsts.AddExpenseMoney,
	}
end

-- 是否缓动
function UISougouVip:IsTween()
	return true;
end

--面板类型
function UISougouVip:GetPanelType()
	return 1;
end
--是否播放开启音效
function UISougouVip:IsShowSound()
	return true;
end

function UISougouVip:IsShowLoading()
	return true;
end