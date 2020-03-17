--[[
其他角色界面主面板
zhangshuhui
2015年2月10日11:32:06
]]

_G.UIOtherRole = BaseUI:new("UIOtherRole");

UIOtherRole.tabButton = {};

function UIOtherRole:Create()
	self:AddSWF("otherroleMainPanel.swf", true, "center");
	
	self:AddChild(UIOtherRoleBasic, "basic");
	self:AddChild(UIOtherRoleInfo, "info");
end

function UIOtherRole:OnLoaded(objSwf, name)
	self:GetChild("basic"):SetContainer(objSwf.childPanel);
	self:GetChild("info"):SetContainer(objSwf.childPanel);
	--
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--
	self.tabButton["basic"]     = objSwf.btnBasic;
	self.tabButton["info"]      = objSwf.btnInfo;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end;
	end
end

function UIOtherRole:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIOtherRole:OnShow(name)
	self:OnTabButtonClick("basic");
end

--人物面板中详细信息为隐藏面板，不计算到总宽度内
function UIOtherRole:GetWidth()
	return 840;
end

function UIOtherRole:GetHeight()
	return 670;
end

function UIOtherRole:IsTween()
	return true;
end

function UIOtherRole:GetPanelType()
	return 1;
end

function UIOtherRole:IsShowLoading()
	return true;
end

function UIOtherRole:IsShowSound()
	return true;
end

function UIOtherRole:WithRes()
	return {"otherroleBasicPanel.swf"};
end

--点击标签
function UIOtherRole:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end

--点击关闭按钮
function UIOtherRole:OnBtnCloseClick()
	self:Hide();
end