--[[
帮派UI入口管理
liyuan
2014年9月24日16:22:09
]]


_G.UIUnionManager = BaseUI:new("UIUnionManager")

UIUnionManager.UIList = {}

function UIUnionManager:Create()
	self:SetUnionUI(UnionConsts.UINoUnion, UIUnionUnCreate)
	self:SetUnionUI(UnionConsts.UIHasUnion, UIUnion)
	self:RegisterNotification();
end

function UIUnionManager:Show()
	self:ShowChildView()
end

function UIUnionManager:ShowChildView()
	local unionUI = self:GetUnionUI(UnionConsts.UIHasUnion)
	local unionCreateUI = self:GetUnionUI(UnionConsts.UINoUnion)
	
	if UnionUtils:CheckMyUnion() then
		-- 有帮派
		self:HideUnionUI(unionCreateUI)
		self:ShowUnionUI(unionUI)
	else
		-- 无帮派
		self:HideUnionUI(unionUI)
		self:ShowUnionUI(unionCreateUI)
	end
end

function UIUnionManager:Hide()
	-- FPrint('点击关闭')
	local unionUI = self:GetUnionUI(UnionConsts.UIHasUnion)
	local unionCreateUI = self:GetUnionUI(UnionConsts.UINoUnion)
	self:HideUnionUI(unionCreateUI)
	self:HideUnionUI(unionUI)
end

function UIUnionManager:ShowUnionUI(upanel)
	if upanel then
		if not upanel.bShowState then
			upanel.tweenStartPos = self.tweenStartPos;
			upanel:Show()
		end
	else
		FPrint('没有找到upanel')
	end
end

function UIUnionManager:HideUnionUI(upanel)
	if upanel then
		if upanel.bShowState then
			upanel:Hide() 
		end
	else
		FPrint('没有找到upanel')
	end
end

function UIUnionManager:ListNotificationInterests()
	return {NotifyConsts.MyUnionInfoUpdate,--请求自己的帮派信息
			NotifyConsts.CreateGuildSucc}--创建帮派成功
end

function UIUnionManager:HandleNotification(name,body)
	local unionUI = self:GetUnionUI(UnionConsts.UIHasUnion)
	local unionCreateUI = self:GetUnionUI(UnionConsts.UINoUnion)
	
	if not unionUI or not unionCreateUI then return end
	if not self:IsShow() then return end

	if name == NotifyConsts.MyUnionInfoUpdate then
		self:ShowChildView()
	elseif name == NotifyConsts.CreateGuildSucc then
		UnionController:ReqMyGuildInfo()
	end
end

function UIUnionManager:IsShow()
	local unionUI = self:GetUnionUI(UnionConsts.UIHasUnion)
	local unionCreateUI = self:GetUnionUI(UnionConsts.UINoUnion)
	
	if not unionUI or not unionCreateUI then return false end
	if not unionUI.bShowState and not unionCreateUI.bShowState then return false end
	
	return true
end

function UIUnionManager:SetUnionUI(UIName, UnionUI)
	self.UIList[UIName] = UnionUI
end

function UIUnionManager:GetUnionUI(UIName)
	return self.UIList[UIName]
end