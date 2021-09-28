require "Core.Module.Common.Panel"

require "Core.Module.ProductTip.View.EquipComparisonLeftPanel"
require "Core.Module.ProductTip.View.EquipComparisonRightPanel"

EquipComparisonTipPanel = class("EquipComparisonTipPanel", Panel);

EquipComparisonTipPanel.can_sq_q = 5;
EquipComparisonTipPanel.sq_q = 6;

function EquipComparisonTipPanel:New()
	self = {};
	setmetatable(self, {__index = EquipComparisonTipPanel});
	return self
end


function EquipComparisonTipPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function EquipComparisonTipPanel:_InitReference()
	
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	
	self.centerPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "centerPanel");
	self.rightPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "rightPanel");
	self.leftPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "leftPanel");
	
	self.bg = UIUtil.GetChildByName(self.rightPanel, "Transform", "wbg");
	
	self.comparisonLeftPanel = EquipComparisonLeftPanel:New();
	self.comparisonLeftPanel:Init(self.leftPanel, self.centerPanel)
	
	self.comparisonRightPanel = EquipComparisonRightPanel:New();
	self.comparisonRightPanel:Init(self.rightPanel, self.centerPanel)
	
end

-- function EquipComparisonTipPanel:IsFixDepth()
-- 	return true;
-- end

function EquipComparisonTipPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	
end

function EquipComparisonTipPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL);
end

function EquipComparisonTipPanel:GetMenuBt(funName)
	return self.comparisonRightPanel:GetMenuBt(funName);
end


function EquipComparisonTipPanel:SetData(pro_in_eqBag, pro_in_bag,hideBtn)
	
	local ep_bag_quality = pro_in_eqBag:GetQuality();
	local pro_in_bag_quality = pro_in_bag:GetQuality();
	
	local needShowSqTip = true;
	local maxStar = 0;
	
	local sq_q = EquipComparisonTipPanel.sq_q;
	
	if ep_bag_quality < sq_q and pro_in_bag_quality < sq_q then
		needShowSqTip = false;
	else
		local star1 = pro_in_eqBag:GetStar();
		local star2 = pro_in_bag:GetStar();
		
		if star1 > star2 then
			maxStar = star1;
		else
			maxStar = star2;
		end
	end
	
	if maxStar == 0 then
		maxStar = 1;
	end

	self.comparisonLeftPanel:SetProduct(pro_in_eqBag, needShowSqTip, maxStar);
	self.comparisonRightPanel:SetProduct(pro_in_bag, self.comparisonLeftPanel.fightcp, needShowSqTip, maxStar,hideBtn);
	
    --[[
	if not self.comparisonLeftPanel.hassqSkill and not self.comparisonRightPanel.hassqSkill then
		
		self.comparisonLeftPanel.sqskill.gameObject:SetActive(false);
	end
    ]]
	
end

function EquipComparisonTipPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function EquipComparisonTipPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
end

function EquipComparisonTipPanel:_DisposeReference()
	self._btn_close = nil;
	
	self.comparisonLeftPanel:Dispose();
	self.comparisonRightPanel:Dispose();
	
	
	self.centerPanel = nil;
	self.rightPanel = nil;
	self.leftPanel = nil;
	
	
	self.comparisonLeftPanel = nil;
	
	self.comparisonRightPanel = nil;
	
end
