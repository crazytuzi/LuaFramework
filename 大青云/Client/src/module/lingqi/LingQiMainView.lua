--[[
法宝:主面板
zhangshuhui
]]


_G.MainLingQiUI = BaseUI:new("MainLingQiUI")

MainLingQiUI.tabButton = {}

function MainLingQiUI:Create()
	self:AddSWF("lingQiMainPanel.swf", true, "center")

	self:AddChild(UILingQi, "lingqi")
	--self:AddChild(UIBingLing, "bingling")
	--self:AddChild(UIHun, "hun")
end

function MainLingQiUI:WithRes()
	return { "lingQiPanel.swf" }
end

function MainLingQiUI:IsTween()
	return true;
end

function MainLingQiUI:GetPanelType()
	return 1;
end

function MainLingQiUI:IsShowSound()
	return true;
end

function MainLingQiUI:OnLoaded(objSwf, name)
	self:GetChild("lingqi"):SetContainer(objSwf.childPanel)
	--self:GetChild("bingling"):SetContainer(objSwf.childPanel)
	--self:GetChild("hun"):SetContainer(objSwf.childPanel)

	--tab button 
	self.tabButton["lingqi"] = objSwf.btnZhanshou
	self.tabButton["bingling"] = objSwf.btnLingshou
	self.tabButton["hun"] = objSwf.btnHun

	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function MainLingQiUI:OnDelete()
	for k, _ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--关闭事件
function MainLingQiUI:OnBeforeHide()
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

function MainLingQiUI:OnHide()
end

function MainLingQiUI:OnShow(name)
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
function MainLingQiUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tabButton["bingling"]._visible = false;
	self.tabButton["hun"]._visible = false;
	--self.tabButton["bingling"].visible = FuncManager:GetFuncIsOpen(FuncConsts.BingLing);
	--self.tabButton["hun"].visible = FuncManager:GetFuncIsOpen(FuncConsts.ShenBingHun);
end

function MainLingQiUI:SetSwf()
end

--[[
function MainLingQiUI:GetWidth(szName)
	return 1489
end

function MainLingQiUI:GetHeight(szName)
	return 744
end
]]

function MainLingQiUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainLingQiUI:TurnToSubpanel(panelName, ...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName, nil, ...)
		end
	end
end

function MainLingQiUI:OnBtnCloseClick()
	self:Hide()
end

function MainLingQiUI:GetFirstTab()
	return "lingqi";
end

function MainLingQiUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function MainLingQiUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
--	self:UpdateMask()
--	self:UpdateCloseButton()
end

function MainLingQiUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min(math.max(wWidth - 50, 1280), 1380)
end