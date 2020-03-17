--[[
酷狗vip
2015年12月18日12:19:56
]]

_G.UIKugouVip = BaseUI:new("UIKugouVip")

UIKugouVip.QQ = 2850136456

function UIKugouVip:Create()
	self:AddSWF("yunyingKugouVip.swf",true,'center')
end;

function UIKugouVip:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goChongzhi.click = function() self:GoChongzhiClick()end;
	objSwf.fuzhiBtn.click = function() self:FuZhiqqclick() end;
end;

function UIKugouVip:OnShow()
	self:SetQQNumber();
end;

function UIKugouVip:OnHide()

end;

function UIKugouVip:GoChongzhiClick()
	--充值界面
	local objSwf = self.objSwf;
	if not objSwf then return end;
	Version:Charge()
end;

function UIKugouVip:FuZhiqqclick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	_sys.clipboard = UIKugouVip.QQ
end;

function UIKugouVip:SetQQNumber()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local state = YunYingController.platIconState
	if state then 
		objSwf.qqNumber.htmlText = string.format( StrConfig["yunying024"], UIKugouVip.QQ )
		objSwf.fuzhiBtn.disabled = false;
	else
		objSwf.qqNumber.htmlText = string.format( StrConfig["yunying024"], "**********" )
		objSwf.fuzhiBtn.disabled = true;
	end;
end;

function UIKugouVip:HandleNotification(name,body)
	if name == NotifyConsts.AddExpenseMoney then
		self:SetQQNumber();
	end
end

function UIKugouVip:ListNotificationInterests()
	return {
		NotifyConsts.AddExpenseMoney,
	}
end

-- 是否缓动
function UIKugouVip:IsTween()
	return true;
end

--面板类型
function UIKugouVip:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIKugouVip:IsShowSound()
	return true;
end

function UIKugouVip:IsShowLoading()
	return true;
end