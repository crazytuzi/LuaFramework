--[[
灵兽战印主 --已经废弃由UILianQiMainPanel.lua替代
wangshuai
]]
_G.UIWarPrintMain = BaseUI:new("UIWarPrintMain")

UIWarPrintMain.panelone = {"panelequip","panelshop"};
UIWarPrintMain.paneltow = {"bag"}
function UIWarPrintMain:Create()
	self:AddSWF("SpiritWarPrintMain.swf",true,"center")

	self:AddChild(UIWarPrintEquip,"panelequip")
	self:AddChild(UIWarPrintShop, "panelshop")

	self:AddChild(UIWarPrintBag, "bag")
end;

function UIWarPrintMain:OnLoaded(objSwf)
	self:GetChild("panelequip"):SetContainer(objSwf.childPanel);
	self:GetChild("panelshop") :SetContainer(objSwf.childPanel);



	self:GetChild("bag") :SetContainer(objSwf.childPanel2);
	WarPrintModel:OnTextInfo();
end;

function UIWarPrintMain:OnShow()
	self:OnShowChildPanel("panelequip")
end;
-- 显示装备界面
function UIWarPrintMain:OnShowPanel(type)
	if type == 1 then 
		-- 装备
		self:OnShowChildPanel("panelequip")
	elseif type == 2 then 
		-- 获取
		self:OnShowChildPanel("panelshop")
	elseif type == 3 then 
		-- bag
		self:OnShowChildPanelTwo("bag")
	end;
end;
function UIWarPrintMain:OnShowChildPanel(name)
	local child = self:GetChild(name)
	if not child then return end
	child:Show();
	for i,info in ipairs(self.panelone) do 
		if info ~= name then 
			local childc = self:GetChild(info)
			childc:Hide();
		end;
	end;
end;

function UIWarPrintMain:OnShowChildPanelTwo(name)
	local child = self:GetChild(name)
	if not child then return end
	child:Show();
	for i,info in ipairs(self.paneltow) do 
		if info ~= name then 
			local childc = self:GetChild(info)
			childc:Hide();
		end;
	end;

end;

function UIWarPrintMain:OnHide() 

end;

-- 面板 附带资源
function UIWarPrintMain:WithRes()
	return { "SpiritWarPrint.swf" };
end;
