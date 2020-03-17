--[[
神灵:主面板
zhangshuhui
]]


_G.MainWingUI = BaseUI:new("MainWingUI")

MainWingUI.tabButton = {}

function MainWingUI:Create()
	self:AddSWF("wingMainPanel.swf", true, "center")

	self:AddChild(UIWingHeCheng,              "winghecheng")
	self:AddChild(UIWingStarUp,               "wingstarup")
end

function MainWingUI:WithRes()
	return {"hechengWingPanel.swf"}
end

function MainWingUI:IsTween()
	return true;
end

function MainWingUI:GetPanelType()
	return 1;
end

function MainWingUI:IsShowSound()
	return true;
end

function MainWingUI:OnLoaded(objSwf, name)
	self:GetChild("winghecheng"):SetContainer(objSwf.childPanel)
	self:GetChild("wingstarup"):SetContainer(objSwf.childPanel)
	
	--tab button 
	self.tabButton["winghecheng"] = objSwf.btnZhanshou
	self.tabButton["wingstarup"] = objSwf.btnLingshou
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function MainWingUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--神翼合成&强化红点提示
MainWingUI.timerKey = nil;
function MainWingUI:InitWingRedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		if HeChengUtil:WingCanHeChen( ) then   
			PublicUtil:SetRedPoint(objSwf.btnZhanshou, nil, 1)
		else
			PublicUtil:SetRedPoint(objSwf.btnZhanshou, nil, 0)
		end
		--强化
		if HeChengUtil:WingCanQianghua( ) then   
			PublicUtil:SetRedPoint(objSwf.btnLingshou, nil, 1)
		else
			PublicUtil:SetRedPoint(objSwf.btnLingshou, nil, 0)
		end
	end,1000,0); 
end

function MainWingUI:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
end

function MainWingUI:OnShow(name)
	self:UpdateMask()
	-- self:UpdateCloseButton()
	
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
	self:InitWidth()
	self:SetFuncOpen();
	self:InitWingRedPoint( )
end

function MainWingUI:InitWidth( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.width = objSwf.btnLingshou._width;
end

--是否显示强化翅膀
function MainWingUI:SetFuncOpen()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local funcID = FuncConsts.WingStarUp;
	local cfg = t_funcOpen[funcID];
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level >= cfg.open_level then
		self.tabButton["wingstarup"].visible = true;
	else
		self.tabButton["wingstarup"].visible = false;
	end
end

function MainWingUI:SetSwf()

end

function MainWingUI:GetWidth(szName)
	return 1397 
end

function MainWingUI:GetHeight(szName)
	return 823
end

function MainWingUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainWingUI:TurnToSubpanel(panelName,...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName,nil,...)
		end
	end
end

function MainWingUI:OnBtnCloseClick()
	self:Hide()
end

function MainWingUI:GetFirstTab()
	return "winghecheng";
end

function MainWingUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.mcMask._width = wWidth + 100
	-- objSwf.mcMask._height = wHeight + 100
end

function MainWingUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	-- self:UpdateCloseButton()
end

function MainWingUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1420 )
end