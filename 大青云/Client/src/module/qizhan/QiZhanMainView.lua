--[[
骑战:主面板
ly
]]


_G.QiZhanMainUI = BaseUI:new("QiZhanMainUI")

QiZhanMainUI.tabButton = {}

function QiZhanMainUI:Create()
	self:AddSWF("qizhanMainPanel.swf", true, "center")

	self:AddChild(UIQiZhan,              "qizhanbingqi")
	self:AddChild(UIQiZhanZhenYan,     	 "qizhanzhenyan")
end

function QiZhanMainUI:WithRes()
	return {"qizhanPanel.swf"}
end

function QiZhanMainUI:IsTween()
	return true;
end

function QiZhanMainUI:GetPanelType()
	return 1;
end

function QiZhanMainUI:IsShowSound()
	return true;
end

function QiZhanMainUI:OnLoaded(objSwf, name)
	self:GetChild("qizhanbingqi"):SetContainer(objSwf.childPanel)
	self:GetChild("qizhanzhenyan"):SetContainer(objSwf.childPanel)
	
	--tab button 
	self.tabButton["qizhanbingqi"] = objSwf.btnZhanshou
	self.tabButton["qizhanzhenyan"] = objSwf.btnLingshou
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:Hide() end
end

function QiZhanMainUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function QiZhanMainUI:OnHide()
end

function QiZhanMainUI:OnShow(name)
	self:UpdateMask()
	self:UpdateCloseButton()
	
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
function QiZhanMainUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local funcID = FuncConsts.QiYin;
	local cfg = t_funcOpen[funcID];
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local openLv = 0
	if cfg then 
		openLv=cfg.open_level or 0
	end
	if level >= openLv then
		self.tabButton["qizhanzhenyan"].visible = true;
	else
		self.tabButton["qizhanzhenyan"].visible = false;
	end
end

function QiZhanMainUI:GetWidth(szName)
	return 1489 
end

function QiZhanMainUI:GetHeight(szName)
	return 744
end

function QiZhanMainUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function QiZhanMainUI:TurnToSubpanel(panelName,...)
	for uiname, btn in pairs(self.tabButton) do
		local childPanel = self:GetChild(uiname);
		if childPanel then
			childPanel:Hide();
		end
	end
	
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName,nil,...)
		end
	end
end

function QiZhanMainUI:GetFirstTab()
	return "qizhanbingqi";
end

function QiZhanMainUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function QiZhanMainUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function QiZhanMainUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end