--[[
GM主UI
lizuangzhuang
2015年10月9日14:56:33
]]

_G.UIGMMain = BaseUI:new("UIGMMain");

UIGMMain.tabButton = {};

function UIGMMain:Create()
	self:AddSWF("gmPanel.swf",true,"center");

	self:AddChild(UIGMChat,"chat");
	self:AddChild(UIGMUnChat,"unchat");
	self:AddChild(UIGMUnLogin,"unlogin");
	self:AddChild(UIGMUnMac,"unmac");
end

function UIGMMain:OnLoaded(objSwf)
	self:GetChild("chat"):SetContainer(objSwf.childPanel);
	self:GetChild("unchat"):SetContainer(objSwf.childPanel);
	self:GetChild("unlogin"):SetContainer(objSwf.childPanel);
	self:GetChild("unmac"):SetContainer(objSwf.childPanel);
	
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	self.tabButton["chat"] = objSwf.btnChat;
	self.tabButton["unchat"] = objSwf.btnUnChat;
	self.tabButton["unlogin"] = objSwf.btnUnLogin;
	self.tabButton["unmac"] = objSwf.btnUnMac;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end
	end
	--
	objSwf.btnGuild.click = function() UIUnionCreate:Show(); end
end

function UIGMMain:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIGMMain:WithRes()
	return {};
end

function UIGMMain:GetPanelType()
	return 0;
end

function UIGMMain:IsShowSound()
	return true;
end

function UIGMMain:IsShowLoading()
	return true;
end

function UIGMMain:OnShow()
	self:OnTabButtonClick("chat");
end

function UIGMMain:OnTabButtonClick(name)
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

function UIGMMain:OnBtnCloseClick()
	self:Hide();
end