--[[
神兵:主面板
zhangshuhui
]]


_G.MainMagicWeaponUI = BaseUI:new("MainMagicWeaponUI")

MainMagicWeaponUI.tabButton = {}

function MainMagicWeaponUI:Create()
	self:AddSWF("magicWeaponMainPanel.swf", true, "center")

	self:AddChild(UIMagicWeapon, "magicweapon")
--	self:AddChild(UIBingLing, "bingling")
--	self:AddChild(UIHun, "hun")
end

function MainMagicWeaponUI:WithRes()
	return {"magicWeaponPanel.swf"}
end

function MainMagicWeaponUI:IsTween()
	return true;
end

function MainMagicWeaponUI:GetPanelType()
	return 1;
end

function MainMagicWeaponUI:IsShowSound()
	return true;
end

function MainMagicWeaponUI:OnLoaded(objSwf, name)
	self:GetChild("magicweapon"):SetContainer(objSwf.childPanel)
--	self:GetChild("bingling"):SetContainer(objSwf.childPanel)
--	self:GetChild("hun"):SetContainer(objSwf.childPanel)
	
	--tab button 
	self.tabButton["magicweapon"] = objSwf.btnZhanshou
	self.tabButton["bingling"] = objSwf.btnLingshou
	self.tabButton["hun"] = objSwf.btnHun
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function MainMagicWeaponUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--关闭事件
function MainMagicWeaponUI:OnBeforeHide()
	if UIBlessingWarning:IsShow() then
		return false
	end
	if self.warningState == nil then
		self.warningState = true;
		if ChargesUtil:OnWarningPass(ChargesConsts.MagicWeapon) then
			if not UIBlessingWarning:Open(function () self:Hide() end) then
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

function MainMagicWeaponUI:OnHide()
end

function MainMagicWeaponUI:OnShow(name)
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
	self:TurnToSubpanel( self:GetFirstTab() )
	
	self:SetFuncOpen();
end

--是否显示兵灵
function MainMagicWeaponUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
--	self.tabButton["bingling"].visible = FuncManager:GetFuncIsOpen(FuncConsts.BingLing);
--	self.tabButton["hun"].visible = FuncManager:GetFuncIsOpen(FuncConsts.ShenBingHun);
	self.tabButton["bingling"].visible = false;
	self.tabButton["hun"].visible = false;
end

function MainMagicWeaponUI:SetSwf()

end

function MainMagicWeaponUI:GetWidth(szName)
	return 1489 
end

function MainMagicWeaponUI:GetHeight(szName)
	return 744
end

function MainMagicWeaponUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainMagicWeaponUI:TurnToSubpanel(panelName,...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName,nil,...)
		end
	end
end

function MainMagicWeaponUI:OnBtnCloseClick()
	self:Hide()
end

function MainMagicWeaponUI:GetFirstTab()
	return "magicweapon";
end

--[[
function MainMagicWeaponUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end
]]
--[[

function MainMagicWeaponUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end
]]
--[[

function MainMagicWeaponUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end
]]
