--[[
圣器:主面板
zhangshuhui
]]


_G.BingHunMainUI = BaseUI:new("BingHunMainUI")

BingHunMainUI.tabButton = {}

function BingHunMainUI:Create()
	self:AddSWF("shengqiMainPanel.swf", true, "center")

	self:AddChild(UIBingHunView,              "binghun")
	self:AddChild(UIHallows,             	  "shengling")
	--self:AddChild(UILingZhenZhenYan,               "zhenyan")
end

function BingHunMainUI:WithRes()
	return {"binghunMainPanel.swf"}
end

function BingHunMainUI:IsTween()
	return true;
end

function BingHunMainUI:GetPanelType()
	return 1;
end

function BingHunMainUI:IsShowSound()
	return true;
end

function BingHunMainUI:OnLoaded(objSwf, name)
	self:GetChild("binghun"):SetContainer(objSwf.childPanel)
	self:GetChild("shengling"):SetContainer(objSwf.childPanel)
	
	--tab button 
	self.tabButton["binghun"] = objSwf.btnZhanshou
	self.tabButton["shengling"] = objSwf.btnLingshou
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function BingHunMainUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function BingHunMainUI:OnHide()
end

BingHunMainUI.firsOpenName = nil
function BingHunMainUI:Open(name)
	if self:IsShow() then
		self:OnTabButtonClick(name)
	else
		self.firsOpenName = name;
		self:Show();
	end
end

function BingHunMainUI:OnShow(name)
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
	if self.firsOpenName then
		self:TurnToSubpanel( self.firsOpenName );
		self.firsOpenName = nil;
	else
		self:TurnToSubpanel( self:GetFirstTab() )
	end
	
	self:SetFuncOpen();
end

--是否显示强化翅膀
function BingHunMainUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if FuncManager:GetFuncIsOpen(FuncConsts.Hallows) == true then
		self.tabButton["shengling"].visible = true;
	else
		self.tabButton["shengling"].visible = false;
	end
end

function BingHunMainUI:SetSwf()

end

function BingHunMainUI:GetWidth(szName)
	return 1489 
end

function BingHunMainUI:GetHeight(szName)
	return 744
end

function BingHunMainUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function BingHunMainUI:TurnToSubpanel(panelName,...)
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

function BingHunMainUI:OnBtnCloseClick()
	self:Hide()
end

function BingHunMainUI:GetFirstTab()
	return "binghun";
end

function BingHunMainUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function BingHunMainUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function BingHunMainUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
end