--[[
老拉新
2015年12月21日15:27:48
haohu
]]

_G.UILaXin = BaseUI:new("UILaXin")

function UILaXin:Create()
	self:AddSWF("youXiLaXin.swf", true, "center")
end

function UILaXin:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.btnGo.click = function() self:OpenZhaomuPage() end
end
function UILaXin:OnShow()
	-- body
end

function UILaXin:OnHide()
	-- body
end

function UILaXin:OpenZhaomuPage()
	Version:LaXinBrowse();
end

-- 是否缓动
function UILaXin:IsTween()
	return true;
end

--面板类型
function UILaXin:GetPanelType()
	return 1;
end
--是否播放开启音效
function UILaXin:IsShowSound()
	return true;
end

function UILaXin:IsShowLoading()
	return true;
end