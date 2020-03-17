--[[
玉佩:主面板
zhangshuhui
]]


_G.MainMingYuUI = BaseUI:new("MainMingYuUI")

MainMingYuUI.tabButton = {}

function MainMingYuUI:Create()
	self:AddSWF("mingYuMainPanel.swf", true, "center")

	self:AddChild(UIMingYu, "mingyu")
	--	self:AddChild(UIBingLing, "bingling")
	--	self:AddChild(UIHun, "hun")
end

function MainMingYuUI:WithRes()
	return { "mingYuPanel.swf" }
end

function MainMingYuUI:IsTween()
	return true;
end

function MainMingYuUI:GetPanelType()
	return 1;
end

function MainMingYuUI:IsShowSound()
	return true;
end

function MainMingYuUI:OnLoaded(objSwf, name)
	self:GetChild("mingyu"):SetContainer(objSwf.childPanel)
	--	self:GetChild("bingling"):SetContainer(objSwf.childPanel)
	--	self:GetChild("hun"):SetContainer(objSwf.childPanel)

	--tab button 
	self.tabButton["mingyu"] = objSwf.btnZhanshou
	self.tabButton["bingling"] = objSwf.btnLingshou
	self.tabButton["hun"] = objSwf.btnHun

	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function MainMingYuUI:OnDelete()
	for k, _ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--关闭事件
function MainMingYuUI:OnBeforeHide()
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

function MainMingYuUI:OnHide()
end

function MainMingYuUI:OnShow(name)
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
function MainMingYuUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tabButton["bingling"].visible = false;
	self.tabButton["hun"].visible = false;
	--	self.tabButton["bingling"].visible = FuncManager:GetFuncIsOpen(FuncConsts.BingLing);
	--	self.tabButton["hun"].visible = FuncManager:GetFuncIsOpen(FuncConsts.ShenBingHun);
end

function MainMingYuUI:SetSwf()
end

--[[
function MainMingYuUI:GetWidth(szName)
	return 1489
end

function MainMingYuUI:GetHeight(szName)
	return 744
end
]]

function MainMingYuUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainMingYuUI:TurnToSubpanel(panelName, ...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName, nil, ...)
		end
	end
end

function MainMingYuUI:OnBtnCloseClick()
	self:Hide()
end

function MainMingYuUI:GetFirstTab()
	return "mingyu";
end

function MainMingYuUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function MainMingYuUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	--	self:UpdateMask()
	--	self:UpdateCloseButton()
end

function MainMingYuUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min(math.max(wWidth - 50, 1280), 1380)
end