--[[
装备熔炼主面板
lizhuangzhuang
2014年11月13日12:08:51
]]

_G.UIEquip = BaseUI:new("UIEquip");

UIEquip.tabButton = {};

function UIEquip:Create()
	self:AddSWF("equipMainPanel.swf",true,"center");

	self:AddChild(UIEquipStren,FuncConsts.EquipStren); -- 升星
	-- self:AddChild(UIEquipSuper,FuncConsts.EquipSuper);
	self:AddChild(UIEquipInherit,FuncConsts.EquipInherit) ;-- 传承
	self:AddChild(UIEquipGem,FuncConsts.EquipGem);-- 宝石
	self:AddChild(UIRefinView,FuncConsts.EquipRefin);-- 强化
	-- self:AddChild(UIShenWu,FuncConsts.ShenWu);-- 神武
end

function UIEquip:OnLoaded(objSwf)
	self:GetChild(FuncConsts.EquipStren):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipInherit):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipGem):SetContainer(objSwf.childPanel); 
	-- self:GetChild(FuncConsts.EquipSuper):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.EquipRefin):SetContainer(objSwf.childPanel);
	-- self:GetChild(FuncConsts.ShenWu):SetContainer(objSwf.childPanel);

	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	self.tabButton[FuncConsts.EquipStren] = objSwf.btnStren;
	-- self.tabButton[FuncConsts.EquipSuper] = objSwf.btnSuper;
	self.tabButton[FuncConsts.EquipInherit] = objSwf.btnInherit;
	self.tabButton[FuncConsts.EquipGem] = objSwf.btnGem;
	self.tabButton[FuncConsts.EquipRefin] = objSwf.btnRefin;
	-- self.tabButton[FuncConsts.ShenWu] = objSwf.btnShenwu;
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end
	end
end

function UIEquip:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIEquip:WithRes()
	return {"equipRefinPanel.swf"};
end

function UIEquip:IsTween()
	return true;
end

function UIEquip:GetPanelType()
	return 1;
end

function UIEquip:IsShowSound()
	return true;
end

function UIEquip:GetWidth()
	return 1058;
end

function UIEquip:GetHeight()
	return 680;
end

function UIEquip:GetShopContainer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	return objSwf.shopContainer;
end

function UIEquip:OnShow()
	EquipNewTipsManager:CloseAll();
	for funcId,btn in pairs(self.tabButton) do
		if FuncManager:GetFuncIsOpen(funcId) then
			btn.visible = true;
		else
			btn.visible = false;
		end
	end
	if #self.args > 0 then
		if self.tabButton[self.args[1]] then
			self:OnTabButtonClick(self.args[1]);
			return;
		end
	end
	self:OnTabButtonClick(FuncConsts.EquipRefin);
end

function UIEquip:OnTabButtonClick(name)
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

function UIEquip:OnBtnCloseClick()
	self:Hide();
end

function UIEquip:GetSuperInBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnSupeInherit;
end

function UIEquip:GetProductBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnProduct;
end

function UIEquip:GetCloseBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnClose;
end

--任务脚本测试
function UIEquip:GetStrenBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnStren;
end