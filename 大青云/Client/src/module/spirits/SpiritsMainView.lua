--[[
帮派:主面板
liyuan
2014年9月24日16:22:09
]]


_G.MainSpiritsUI = BaseUI:new("MainSpiritsUI")

MainSpiritsUI.tabButton = {}

function MainSpiritsUI:Create()
	self:AddSWF("spiritsMainPanel.swf", true, "center")

	--self:AddChild(UIzhanshou,         SpiritsConsts.ZhanshouView) -- 灵兽
	--self:AddChild(UISpirits,       SpiritsConsts.LinshouView) -- 神兽
	self:AddChild(UIWarPrintMain,  SpiritsConsts.Zhanying) -- 站印
	--self:AddChild(UIShouHun,  FuncConsts.ShouHun) -- 血脉
end

function MainSpiritsUI:WithRes()
	return {"zhanshouPanel.swf"}
end

function MainSpiritsUI:IsTween()
	return true;
end

function MainSpiritsUI:GetPanelType()
	return 1;
end

function MainSpiritsUI:IsShowSound()
	return true;
end

function MainSpiritsUI:OnLoaded(objSwf, name)
	--self:GetChild(SpiritsConsts.ZhanshouView):SetContainer(objSwf.childPanel)
	--self:GetChild(SpiritsConsts.LinshouView):SetContainer(objSwf.childPanel)
	self:GetChild(SpiritsConsts.Zhanying):SetContainer(objSwf.childPanel)
	--self:GetChild(FuncConsts.ShouHun):SetContainer(objSwf.childPanel)
	
	--tab button 
	--self.tabButton[SpiritsConsts.ZhanshouView] = objSwf.btnZhanshou
	--self.tabButton[SpiritsConsts.LinshouView] = objSwf.btnLingshou
	self.tabButton[SpiritsConsts.Zhanying] = objSwf.shouying_btn
	--self.tabButton[FuncConsts.ShouHun] = objSwf.shouhun_btn
	--objSwf.btnLingshou._visible = false
	--objSwf.btnZhanshou._visible = false
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end

	--objSwf.shouying_btn.click = function()self:OnShowShouying()end;
end

-- function MainSpiritsUI:OnShowShouying()
-- 	if not UIWarPrintMain:IsShow() then 
-- 		UIWarPrintMain:Show();
-- 	end;
-- end;

function MainSpiritsUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--关闭事件
function MainSpiritsUI:OnBeforeHide()
	if UIBlessingWarning:IsShow() then
		return false
	end
	if self.warningState == nil then
		self.warningState = true;
		if ChargesUtil:OnWarningPass(ChargesConsts.Spirits) then
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


function MainSpiritsUI:OnHide()
end

function MainSpiritsUI:OnShow(name)
	self:UpdateMask()
	self:UpdateCloseButton()
	self:ShowTabButton()
	
	if #self.args > 0 then
		local otherArgs = {};
		if #self.args > 1 then
			for i=2,#self.args do
				table.push(otherArgs,self.args[i]);
			end
		end
		if self.tabButton[self.args[1]] then
		
			self:TurnToSubpanel(self.args[1],unpack(otherArgs));
			return;
		end
	end
	self:TurnToSubpanel( self:GetFirstTab() )
end

function MainSpiritsUI:ShowTabButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.shouhun_btn.visible = FuncManager:GetFuncIsOpen( FuncConsts.ShouHun )
end

function MainSpiritsUI:SetSwf()

end

function MainSpiritsUI:GetWidth(szName)
	return 1489 
end

function MainSpiritsUI:GetHeight(szName)
	return 744
end

function MainSpiritsUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainSpiritsUI:TurnToSubpanel(panelName,...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName,nil,...)
		end
	end
end

function MainSpiritsUI:OnBtnCloseClick()
	self:Hide()
end

function MainSpiritsUI:GetFirstTab()
	return SpiritsConsts.Zhanying;
end

function MainSpiritsUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function MainSpiritsUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function MainSpiritsUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end