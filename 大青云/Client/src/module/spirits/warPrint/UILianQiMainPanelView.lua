--[[
炼器主面板，只是两个TAB按钮和面板边框，内容分别在WarPrintMainView中
yanghongbin

]]
_G.UILianQiMainPanelView = BaseUI:new("UILianQiMainPanelView")


UILianQiMainPanelView.tabButton = {}
UILianQiMainPanelView.CHILD_BAG_NAME = "UILianQiBag";
function UILianQiMainPanelView:Create()
	self:AddSWF("LianQiMainPanel.swf", true, "center")
	self:AddChild(UIWarPrintEquip, FuncConsts.LianQi); --炼器
	self:AddChild(UIWarPrintShop, FuncConsts.LingBao); --灵宝
	self:AddChild(UIWarPrintBag, self.CHILD_BAG_NAME) --炼器背包
end

function UILianQiMainPanelView:OnLoaded(objSwf, name)
	self:GetChild(FuncConsts.LianQi):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.LingBao):SetContainer(objSwf.childPanel);
	self:GetChild(self.CHILD_BAG_NAME):SetContainer(objSwf.bagPanel);

	self.tabButton[FuncConsts.LianQi] = objSwf.btnLianQi;
	self.tabButton[FuncConsts.LingBao] = objSwf.btnLingBao;

	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
end

function UILianQiMainPanelView:OnDelete()
	for k, _ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UILianQiMainPanelView:OnShow(name)
	self:GetChild(self.CHILD_BAG_NAME):Show();

	-- 查看args中第一位的参数有没有，如果有的话，说明是要直接跳转到某一个tab
	if #self.args > 0 then
		local args1 = toint(self.args[1]);
		if self.tabButton[args1] then
			self:OnTabButtonClick(args1);
			return;
	end
	end
	-- 默认打开第一个tab
	self:OnTabButtonClick(FuncConsts.LianQi);
end

function UILianQiMainPanelView:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function UILianQiMainPanelView:TurnToSubpanel(panelName)
	local tabBtn = self.tabButton[panelName];
	if not tabBtn then return; end
	tabBtn.selected = true;
	for k, v in pairs(self.tabButton) do
		if k == panelName then
			self:GetChild(k):Show();
		else
			self:GetChild(k):Hide();
		end
	end
end

function UILianQiMainPanelView:WithRes()
	return { "SpiritWarPrint.swf", "SpiritWarPrintBuy.swf", "spiritWarPrintBag.swf" }
end

function UILianQiMainPanelView:IsTween()
	return true;
end

function UILianQiMainPanelView:GetPanelType()
	return 1;
end

function UILianQiMainPanelView:ESCHide()
	return true;
end

function UILianQiMainPanelView:IsShowSound()
	return true;
end

function UILianQiMainPanelView:GetWidth(szName)
	return 1397;
end

function UILianQiMainPanelView:GetHeight(szName)
	return 823;
end

function UILianQiMainPanelView:OnBtnCloseClick()
	self:Hide()
end

function UILianQiMainPanelView:OnHide()
end
