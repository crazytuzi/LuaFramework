--[[
跨服:主面板
liyuan
2014年9月24日16:22:09
]]


_G.MainInterServiceUI = BaseUI:new("MainInterServiceUI")

MainInterServiceUI.tabButton = {}

function MainInterServiceUI:Create()
	self:AddSWF("interServerMainView.swf", true, "center")

	self:AddChild(UIInterServicePvpView,	'uiInterServicePvp')
	self:AddChild(UIInterServiceBoss,		'uiInterServiceBoss')
	self:AddChild(UIInterContest, 			'uiInterServiceContest')
	self:AddChild(UIInterServerScene, 		'uiInterServiceScene')
end

function MainInterServiceUI:WithRes()
	return {"interServerPvpPanel.swf"}
end

function MainInterServiceUI:IsTween()
	return true;
end

function MainInterServiceUI:GetPanelType()
	return 1;
end

function MainInterServiceUI:IsShowSound()
	return true;
end

function MainInterServiceUI:OnLoaded(objSwf, name)
	self:GetChild('uiInterServicePvp'):SetContainer(objSwf.childPanel)
	self:GetChild('uiInterServiceBoss'):SetContainer(objSwf.childPanel)
	self:GetChild('uiInterServiceContest'):SetContainer(objSwf.childPanel)
	self:GetChild('uiInterServiceScene'):SetContainer(objSwf.childPanel)
	
	
	--tab button 
	self.tabButton['uiInterServicePvp'] = objSwf.btnpvp
	self.tabButton['uiInterServiceBoss'] = objSwf.btnboss
	self.tabButton['uiInterServiceContest'] = objSwf.btncontest
	self.tabButton['uiInterServiceScene'] = objSwf.btnScene
	
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	--close button
	objSwf.btnClose.click = function()
		MainInterServiceUI.isMax = false
		MainInterServiceUI.isMin = false
		self:Hide()
	end;	
end

function MainInterServiceUI:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function MainInterServiceUI:OnHide()
end

function MainInterServiceUI:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end

	local funcCfg = t_funcOpen[FuncConsts.KuaFuBoss]
	if funcCfg then
		if funcCfg.isHide == 1 or FuncManager:GetFuncIsOpen(FuncConsts.KuaFuBoss) == false then
			--屏蔽
			objSwf.btnboss.visible = false
		else
			objSwf.btnboss.visible = true
		end
	end
	
	local funcCfg = t_funcOpen[FuncConsts.KuaFuContest]
	if funcCfg then
		if funcCfg.isHide == 1 or FuncManager:GetFuncIsOpen(FuncConsts.KuaFuContest) == false then
			--屏蔽
			objSwf.btncontest.visible = false
		else
			objSwf.btncontest.visible = true
		end
	end
	
	local funcCfg = t_funcOpen[FuncConsts.KuaFuScene]
	if funcCfg then
		if funcCfg.isHide == 1 or FuncManager:GetFuncIsOpen(FuncConsts.KuaFuScene) == false then
			--屏蔽
			objSwf.btnScene.visible = false
		else
			objSwf.btnScene.visible = true
		end
	end

	self:UpdateMask()
	self:UpdateCloseButton()
	
	if #self.args > 0 then
		local otherArgs = {};
		if #self.args > 1 then
			for i=2,#self.args do
				table.push(otherArgs,self.args[i]);
			end
		end
		
		local funcCfg = t_funcOpen[FuncConsts.KuaFuBoss]
		local isBossShow = false
		if funcCfg then
			if funcCfg.isHide == 1 or FuncManager:GetFuncIsOpen(FuncConsts.KuaFuBoss) == false then
				--屏蔽
				isBossShow = false
			else
				isBossShow = true
			end
		end
		
		if isBossShow and self.tabButton[self.args[1]] then		
			self:TurnToSubpanel(self.args[1],unpack(otherArgs));
			return;
		end
	end
	self:TurnToSubpanel( self:GetFirstTab() )
end

function MainInterServiceUI:SetSwf()

end

function MainInterServiceUI:GetWidth(szName)
	return 1255 
end

function MainInterServiceUI:GetHeight(szName)
	return 828
end

function MainInterServiceUI:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
end

function MainInterServiceUI:TurnToSubpanel(panelName,...)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName,nil,...)
		end
	end
end

function MainInterServiceUI:OnBtnCloseClick()
	self:Hide()
end

function MainInterServiceUI:GetFirstTab()
	return 'uiInterServicePvp';
end

function MainInterServiceUI:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function MainInterServiceUI:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
	self:UpdateCloseButton()
end

function MainInterServiceUI:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 100, 1175 ), 1201 )
end

--执行打开缓动
function MainInterServiceUI:DoTweenHide()
	if MainInterServiceUI.isMin then
		self:DoTweenMin()
	else
		self:PvpTweenHide()
	end
end

--执行缓动
function MainInterServiceUI:DoTweenShow()
	if MainInterServiceUI.isMax then
		self:DoTweenMax()	
	else
		self:PvpTweenShow()
	end
end

function MainInterServiceUI:DoTweenMin()
	local endX,endY;
	local winW,winH = UIManager:GetWinSize();
	endX = _G.PanelPosConfig["UIInterServiceMinPanel"].left	
	endY = winH - _G.PanelPosConfig["UIInterServiceMinPanel"].bottom
	
	if not self.swfCfg.objSwf then 
		self:DoHide();
		return
	end
	
	local mc = self.swfCfg.objSwf.content;			
	Tween:To(mc,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					mc._xscale = 100;
					mc._yscale = 100;
					mc._alpha = 100;
				end},true);
end

function MainInterServiceUI:DoTweenMax()	
	local startPos = UIManager:GetMousePos();	
	local startX,startY = startPos.x,startPos.y;
	local endX,endY = self:GetCfgPos();
	--
	if not self.swfCfg.objSwf then 
		self:DoShow();
		return
	end
	
	local mc = self.swfCfg.objSwf.content;
	mc._xscale = 0;
	mc._yscale = 0;
	mc._alpha = 50;
	mc._x = startX;
	mc._y = startY;			
	Tween:To(mc,0.5,{_alpha=100,_xscale=100,_yscale=100,_x=endX,_y=endY},
				{onComplete=function()
					self:DoShow();
				end},true);
end

--执行打开缓动
function MainInterServiceUI:PvpTweenShow()
	if not self.tweenStartPos then
		self.tweenStartPos = UIManager:GetMousePos();
	end
	local startX,startY = self.tweenStartPos.x,self.tweenStartPos.y;
	local endX,endY = self:GetCfgPos();
	--
	if not self.swfCfg.objSwf then 
		self:DoShow();
		return
	end
	
	local mc = self.swfCfg.objSwf.content;
	mc._xscale = 0;
	mc._yscale = 0;
	mc._alpha = 50;
	mc._x = startX;
	mc._y = startY;			
	Tween:To(mc,0.5,{_alpha=100,_xscale=100,_yscale=100,_x=endX,_y=endY},
				{onComplete=function()
					self:DoShow();
				end},true);
end

--执行缓动
function MainInterServiceUI:PvpTweenHide()
	
	local endX,endY;
	if self.tweenStartPos then
		endX = self.tweenStartPos.x;
		endY = self.tweenStartPos.y;
	else
		local winW,winH = UIManager:GetWinSize();
		endX = winW/2;
		endY = winH;
	end
	--
	if not self.swfCfg.objSwf then 
		self:DoHide();		
		return
	end
	
	local mc = self.swfCfg.objSwf.content;			
	Tween:To(mc,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					mc._xscale = 100;
					mc._yscale = 100;
					mc._alpha = 100;
				end},true);
end