--[[
飞火Vip
wangshuai
2015年11月12日17:28:13
]]

_G.UIFeihuoVIp = BaseUI:new("UIFeihuoVIp")

function UIFeihuoVIp:Create()
	self:AddSWF("yunyingFeihuopanel.swf",true,'center')
end;

function UIFeihuoVIp:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goChongzhi.click = function() self:GoChongzhiClick()end;
	objSwf.fuzhiBtn.click = function() self:FuZhiqqclick() end;
end;

function UIFeihuoVIp:OnShow()
	self:SetQQNumber();
end;

function UIFeihuoVIp:OnHide()

end;

function UIFeihuoVIp:GoChongzhiClick()
	--充值界面
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Charge()
end;

function UIFeihuoVIp:FuZhiqqclick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	_sys.clipboard = 800022132
end;

function UIFeihuoVIp:SetQQNumber()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local state = YunYingController.platIconState
	if state then 
		objSwf.qqNumber.htmlText = "专属客服QQ：800022132"
		objSwf.fuzhiBtn.disabled = false;
	else
		objSwf.qqNumber.htmlText = "专属客服QQ：**********"
		objSwf.fuzhiBtn.disabled = true;
	end;
end;

function UIFeihuoVIp:HandleNotification(name,body)
	if name == NotifyConsts.AddExpenseMoney then
		self:SetQQNumber();
	end
end

function UIFeihuoVIp:ListNotificationInterests()
	return {
		NotifyConsts.AddExpenseMoney,
	}
end

-- 是否缓动
function UIFeihuoVIp:IsTween()
	return true;
end

--面板类型
function UIFeihuoVIp:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIFeihuoVIp:IsShowSound()
	return true;
end

function UIFeihuoVIp:IsShowLoading()
	return true;
end