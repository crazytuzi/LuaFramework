_G.UISmithing = BaseUI:new("UISmithing");
UISmithing.tabButton = {};
UISmithing.currSelect = nil;
UISmithing.selectPage = 0;

local s_index = {
	[FuncConsts.EquipStren] = FuncConsts.SmithingStar,
	[FuncConsts.EquipGem] = FuncConsts.SmithingInlay,
	[FuncConsts.EquipDecomp] = FuncConsts.EquipDecomp,
	[FuncConsts.EquipRonghe] = FuncConsts.SmithingFusion,
	[FuncConsts.SmithingWash] = FuncConsts.SmithingWash,
	[FuncConsts.SmithingResp] = FuncConsts.SmithingResp,
	[FuncConsts.GroupYangc] = FuncConsts.GroupYangc,
	[FuncConsts.SmithingRing] = FuncConsts.SmithingRing,
}

local s_btn = {FuncConsts.SmithingStar, FuncConsts.SmithingResp, FuncConsts.SmithingWash, FuncConsts.SmithingInlay,
			   FuncConsts.GroupYangc, FuncConsts.SmithingFusion, 
			   FuncConsts.EquipDecomp, FuncConsts.SmithingRing}

function UISmithing:Create()
	self:AddSWF("smithingMainPanel.swf", true, "center");

	self:AddChild(UISmithingStar, FuncConsts.SmithingStar); --装备升星
	self:AddChild(UISmithingInlay, FuncConsts.SmithingInlay); --宝石镶嵌
	self:AddChild(UIEquipDecomp, FuncConsts.EquipDecomp); --分解
	self:AddChild(UISmithingFusion, FuncConsts.SmithingFusion); --装备融合
	self:AddChild(UISmithingWash, FuncConsts.SmithingWash) --装备洗练
	self:AddChild(UISmithingResp, FuncConsts.SmithingResp) --装备传承
	self:AddChild(UISmithingGroup, FuncConsts.GroupYangc) --套装
	self:AddChild(UISmithingRing, FuncConsts.SmithingRing) --左戒
end

function UISmithing:OnLoaded(objSwf)
	for k, v in pairs(s_btn) do
		self:GetChild(v):SetContainer(objSwf.childPanel)
	end

	--- 设置分页按钮----
	self.tabButton[FuncConsts.SmithingStar] = objSwf.btnShengxing;
	self.tabButton[FuncConsts.SmithingInlay] = objSwf.btnGem;
	self.tabButton[FuncConsts.SmithingFusion] = objSwf.btnRonghe;
	self.tabButton[FuncConsts.SmithingWash] = objSwf.btnWash;
	self.tabButton[FuncConsts.SmithingResp] = objSwf.btnResp;
	self.tabButton[FuncConsts.EquipDecomp] = objSwf.btnFenjie;
	self.tabButton[FuncConsts.GroupYangc] = objSwf.btnGroup
	self.tabButton[FuncConsts.SmithingRing] = objSwf.btnRing

	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	for name, btn in pairs(self.tabButton) do
		btn.click = function() if name ~= self.selectPage then self:OnTabButtonClick(name); end end
	end
end

function UISmithing:HandleNotification(name, body)
end

function UISmithing:ListNotificationInterests()
end

function UISmithing:OnShow()
	self:SetPageBtn()
	self:UnRegisterTimes()
	self:RegisterTimes()
	self:InitSmithingRedPoint()
	if UIBag.isOpenSmith then
		self:OnTabButtonClick(FuncConsts.EquipDecomp);
		UIBag.isOpenSmith = false
	else
		self:OnTabButtonClick(self.args and s_index[self.args[1]] or self:GetOpenId(), self.args[2], self.args[3]);
	end

	self:RefreshBtnInfo()
end

function UISmithing:GetOpenId()
	if FuncManager:GetFuncIsOpen(FuncConsts.EquipStren) then
		return s_index[FuncConsts.EquipStren]
	end
	for k, v in pairs(s_index) do
		if FuncManager:GetFuncIsOpen(k) then
			return v
		end
	end
end

function UISmithing:SetPageBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
	local x = 70
	local y = 71
	local index = 1
	for i, v in ipairs(s_btn) do
		for k, v1 in pairs(s_index) do
			if v == v1 then
				if (k == FuncConsts.SmithingRing and SmithingModel:GetRingCid()) or (k ~= FuncConsts.SmithingRing and FuncManager:GetFuncIsOpen(k)) then
					self.tabButton[v]._x = x
					self.tabButton[v]._y = y
					x = x + 98
				end
			end
		end
	end
end

--升星，宝石，洗练等红星提示
--adder:houxudong
--date:2016/7/29 16:32:00
UISmithing.timerKey = nil;

function UISmithing:InitSmithingRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return end
	--升星
	if EquipUtil:IsHaveEquipCanStarUp() then
		PublicUtil:SetRedPoint(objSwf.btnShengxing, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnShengxing, nil, 0)
	end

	--宝石
	if EquipUtil:IsHaveGemCanLvUp() or EquipUtil:IsHaveGemCanIn() then
		PublicUtil:SetRedPoint(objSwf.btnGem, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnGem, nil, 0)
	end

	--洗练
	if EquipUtil:IsHaveEquipCanWash() then
		PublicUtil:SetRedPoint(objSwf.btnWash, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnWash, nil, 0)
	end

	--左戒
	if EquipUtil:IsCanLvUpRing() then
		PublicUtil:SetRedPoint(objSwf.btnRing, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnRing, nil, 0)
	end
end

function UISmithing:RegisterTimes(  )
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitSmithingRedPoint()
	end,1000,0); 
end

function UISmithing:UnRegisterTimes(  )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

function UISmithing:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if self.washLoader then  
		self:RemoveRedPoint(self.washLoader)
		self.washLoader = nil;
	end
	if self.gemLoader then  
		self:RemoveRedPoint(self.gemLoader)
		self.gemLoader = nil;
	end
	if self.starLoader then  
		self:RemoveRedPoint(self.starLoader)
		self.starLoader = nil;
	end
	if self.ringLoader then  
		self:RemoveRedPoint(self.ringLoader)
		self.ringLoader = nil;
	end
end

function UISmithing:OnDelete()
	for k, v in pairs(self.tabButton) do
		self.tabButton[k] = nil
	end
	self.tabButton = {}
end

function UISmithing:RefreshBtnInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	for k, v in pairs(self.tabButton) do
		for k1, v1 in pairs(s_index) do
			if v1 == k then
				if k ~= FuncConsts.SmithingRing then
					v.visible = FuncManager:GetFuncIsOpen(k1)
				else
					v.visible = FuncManager:GetFuncIsOpen(k1) and SmithingModel:GetRingCid()
				end
			end
		end
	end
end

function UISmithing:OnTabButtonClick(name, ...)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end

	self.tabButton[name].selected = true;
	self:ShowChild(name, nil, ...);
	self.selectPage = name;

	if name == FuncConsts.SmithingStar then
		RemindController:AddRemind(RemindConsts.Type_SmithingStar, 0);
	elseif name == FuncConsts.SmithingInlay then
		RemindController:AddRemind(RemindConsts.Type_SmithingInlay, 0);
	elseif name == FuncConsts.SmithingWash then
		RemindController:AddRemind(RemindConsts.Type_SmithingWash, 0);
	elseif name == 	FuncConsts.GroupYangc then
		RemindController:AddRemind(RemindConsts.Type_SmithingGroup, 0);
	end

end

function UISmithing:OnBtnCloseClick()
	-- UIBag.isOpenSmith = false
	self:Hide();
end

function UISmithing:WithRes()
	return {"smithingGemPanel.swf", "smithingRespPanel.swf", "smithingRespPanel.swf", "smithingStarPanelV.swf", "smithingWashPanel.swf"};
end

function UISmithing:IsTween()
	return true;
end

function UISmithing:GetPanelType()
	return 1;
end

function UISmithing:IsShowSound()
	return true;
end

function UISmithing:GetWidth()
	return 1146;
end

function UISmithing:GetHeight()
	return 687;
end

function UISmithing:ListNotificationInterests()
end



