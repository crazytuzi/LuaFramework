--[[
帮派:创建面板
liyuan
2014年9月24日16:22:09
]]


_G.UIUnionCreate = BaseUI:new("UIUnionCreate")

function UIUnionCreate:Create()
	self:AddSWF("unionCreatePanel.swf", true, "center")
	self:AddChild(UIUnionCreateList, UnionConsts.TabUnionCreateList)
end

function UIUnionCreate:OnLoaded(objSwf, name)
	-- set child panel
	self:GetChild(UnionConsts.TabUnionCreateList):SetContainer(objSwf.childPanel)
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function UIUnionCreate:OnShow(name)
	self:TurnToSubpanel( UnionConsts.TabUnionCreateList)
end

function UIUnionCreate:OnHide()
end

function UIUnionCreate:GetWidth(name)
	return 910
end

function UIUnionCreate:GetHeight(name)
	return 580
end

function UIUnionCreate:TurnToSubpanel(panelName)
	local child = self:GetChild(panelName)
	if child and not child:IsShow() then
		self:ShowChild(panelName)
	end
end

function UIUnionCreate:OnBtnCloseClick()
	self:Hide()
end
function UIUnionCreate:IsShowSound()
	return true;
end

function UIUnionCreate:IsShowLoading()
	return true;
end