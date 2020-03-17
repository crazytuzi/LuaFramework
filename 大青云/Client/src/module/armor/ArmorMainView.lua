--[[
宝甲:主面板
zhangshuhui
]]


_G.MainArmorUI = BaseUI:new("MainArmorUI")

MainArmorUI.tabButton = {}

function MainArmorUI:Create()
	self:AddSWF("armorMainPanel.swf", true, "center")

	self:AddChild(UIArmor, "armor")
	--	self:AddChild(UIBingLing, "bingling")
	--	self:AddChild(UIHun, "hun")
end

function MainArmorUI:WithRes()
	return { "armorPanel.swf" }
end

function MainArmorUI:IsTween()
	return true;
end

function MainArmorUI:GetPanelType()
	return 1;
end

function MainArmorUI:IsShowSound()
	return true;
end

function MainArmorUI:OnLoaded(objSwf, name)
	self:GetChild("armor"):SetContainer(objSwf.childPanel)
	--	self:GetChild("bingling"):SetContainer(objSwf.childPanel)
	--	self:GetChild("hun"):SetContainer(objSwf.childPanel)

	--tab button 
	self.tabButton["armor"] = objSwf.btnZhanshou
	self.tabButton["bingling"] = objSwf.btnLingshou
	self.tabButton["hun"] = objSwf.btnHun

	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function MainArmorUI:OnDelete()
	for k, _ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--关闭事件
function MainArmorUI:OnBeforeHide()
	if UIBlessingWarning:IsShow() then
		return false
	end
	if self.warningState == nil then
		self.warningState = true;
		if ChargesUtil:OnWarningPass(ChargesConsts.MagicWeapon) then
			if not UIBlessingWarning:Open(function() self:Hide() end) then
				self.warningState = nil;
				return true
			end
		else
			self.warningState = nil;
			return true
		end
	else
		self.warningState = nil;
		return true
	end
end

function MainArmorUI:OnHide()
end

function MainArmorUI:OnShow(name)
--	self:UpdateMask()
--	self:UpdateCloseButton()

	-- if #self.args > 0 then
	-- local otherArgs = {};
	-- if #self.args > 1 then
	-- for i=2,#self.args do
	-- table.push(otherArgs,self.args[i]);
	-- end
	-- end
	-- if self.tabButton[self.args[1]] then

	-- self:TurnToSubpanel(self.args[1],unpack(otherArgs));
	-- return;
	-- end
	-- end
	self:TurnToSubpanel(self:GetFirstTab())

	self:SetFuncOpen();
end

--是否显示兵灵
function MainArmorUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tabButton["bingling"].visible = false;
	self.tabButton["hun"].visible = false;
	--	self.tabButton["bingling"].visible = FuncManager:GetFuncIsOpen(FuncConsts.BingLing);
	--	self.tabButton["hun"].visible = FuncManager:GetFuncIsOpen(FuncConsts.ShenBingHun);
end

function MainArmorUI:SetSwf()
end

--[[
function MainArmorUI:GetWidth(szName)
	return 1489
end

function MainArmorUI:GetHeight(szName)
	return 744
end
]]

function MainArmorUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainArmorUI:TurnToSubpanel(panelName, ...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName, nil, ...)
		end
	end
end

function MainArmorUI:OnBtnCloseClick()
	self:Hide()
end

function MainArmorUI:GetFirstTab()
	return "armor";
end

function MainArmorUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function MainArmorUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	--	self:UpdateMask()
	--	self:UpdateCloseButton()
end

function MainArmorUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min(math.max(wWidth - 50, 1280), 1380)
end