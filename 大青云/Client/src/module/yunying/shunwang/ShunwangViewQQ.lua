--[[
顺网qq开通钻石
wangshuai
2015年11月12日17:28:13
]]

_G.UIShunWangQQ = BaseUI:new("UIShunWangQQ")

function UIShunWangQQ:Create()
	self:AddSWF("shunwangPanel.swf",true,'center')
end;

function UIShunWangQQ:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goChongzhi.click = function() self:GoChongzhiClick()end;
end;

function UIShunWangQQ:OnShow()
	self:SetShunwangQQ();
end;

function UIShunWangQQ:OnHide()

end;

function UIShunWangQQ:SetShunwangQQ()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local state = YunYingController.platIconState
	if state then 
		objSwf.qqNumber.htmlText = "专属客服QQ：3167726040"
	else
		objSwf.qqNumber.htmlText = "专属客服QQ：**********"
	end;
end;

function UIShunWangQQ:GoChongzhiClick()
	--充值界面
	Version:Charge()
end;

-- 是否缓动
function UIShunWangQQ:IsTween()
	return true;
end

--面板类型
function UIShunWangQQ:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIShunWangQQ:IsShowSound()
	return true;
end

function UIShunWangQQ:IsShowLoading()
	return true;
end

function UIShunWangQQ:HandleNotification(name,body)
	if name == NotifyConsts.AddExpenseMoney then
		self:SetShunwangQQ();
	end
end

function UIShunWangQQ:ListNotificationInterests()
	return {
		NotifyConsts.AddExpenseMoney,
	}
end