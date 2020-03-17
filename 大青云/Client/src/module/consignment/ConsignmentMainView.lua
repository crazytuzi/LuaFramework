--[[
 寄售行 main UI
 wangshuai
]]
_G.UIConsigmentMain = BaseUI:new("UIConsigmentMain")

UIConsigmentMain.tabButton = {};

function UIConsigmentMain:Create()
	self:AddSWF("consignmentMainPanel.swf",true,"center")

	self:AddChild(UIConsignmentBuy,		ConsignmentConsts.ConsignmentBuy);
	self:AddChild(UIConsignmentSell,	ConsignmentConsts.ConsignmentSell);
	self:AddChild(UIConsignmentEarn,    ConsignmentConsts.ConsignmentEarn)
end;

function UIConsigmentMain:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:Hide()end;

	self:GetChild(ConsignmentConsts.ConsignmentBuy)		:SetContainer(objSwf.childPanel);
	self:GetChild(ConsignmentConsts.ConsignmentSell)	:SetContainer(objSwf.childPanel);
	self:GetChild(ConsignmentConsts.ConsignmentEarn)	:SetContainer(objSwf.childPanel);

	self.tabButton[ConsignmentConsts.ConsignmentBuy] = objSwf.btnbuy;
	self.tabButton[ConsignmentConsts.ConsignmentSell] = objSwf.btnsell;
	self.tabButton[ConsignmentConsts.ConsignmentEarn] = objSwf.btnearn;
	
	-- wqn在主界面上增加规则说明
	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["consignmentRule1"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end

	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end;

function UIConsigmentMain:OnShow()
	self:OnTabButtonClick(ConsignmentConsts.ConsignmentBuy);
end;

function UIConsigmentMain:OnHide()
	if UIConsignmentUpItem:IsShow() then 
		UIConsignmentUpItem:Hide();
	end;
	if UIConsignmentSureBuy:IsShow() then 
		UIConsignmentSureBuy:Hide();
	end;
end;

function UIConsigmentMain:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end;

-- 面板缓动
function UIConsigmentMain:IsTween()
	return true;
end;

--面板加载的附带资源
function UIConsigmentMain:WithRes()
	 return {"consignmentBuyPanel.swf"}
end

--面板类型
function UIConsigmentMain:GetPanelType()
	return 1;
end

-- 打开音效
function UIConsigmentMain:IsShowSound()
	return true;
end;

-- 
function UIConsigmentMain:GetHeight()
	return 687
end;
-- 
function UIConsigmentMain:GetWidth()
	return 1146
end;

