--[[
登陆等待界面
lizhuangzhuang
2014年9月3日11:32:24
]]

_G.UILoginWait = BaseUI:new("UILoginWait");

UILoginWait.roleInfo = nil;--登录玩家信息
UILoginWait.hasSend = false;--是否已发送请求登录协议

function UILoginWait:Create()
	self:AddSWF("loginWaitPanel.swf",true,"center");
end

function UILoginWait:OnLoaded(objSwf)
	objSwf.bottom.btnEnter.click = function() self:OnBtnEnterClick(); end
	
	objSwf.bottomBtn.btnLeft.stateChange = function(e) CLoginScene:OnBtnRoleRightStateChange(e.state); end;
	objSwf.bottomBtn.btnRight.stateChange = function(e) CLoginScene:OnBtnRoleLeftStateChange(e.state); end;
	objSwf.mcLeft.labelTitleLoginTime.text = UIStrConfig['login6']
	-- objSwf.mcRight.labelTitleTotalTime.text = UIStrConfig['login8']
	objSwf.mcRight.mcHead:stop();
	objSwf.mcLeft.fightNum.loadComplete = function() 
		local width = objSwf.mcLeft.fightNum.width;
		objSwf.mcLeft.fightNum._x = (228 - width)/2;
	end
end

function UILoginWait:DeleteWhenHide()
	return true;
end

function UILoginWait:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- objSwf.labelInfo._y = 56;
	-- objSwf.labelInfo._x = (wWidth - objSwf.labelInfo._width)/2;
	-- objSwf.bottom._y = wHeight - objSwf.bottom._height
	objSwf.bottom._x = wWidth - objSwf.bottom._width
	if wHeight <= 750 then
		objSwf.bottom._y = wHeight - objSwf.bottom._height + 100
	else
		objSwf.bottom._y = wHeight - objSwf.bottom._height
	end
	
	objSwf.strengthTip._x = (wWidth - objSwf.strengthTip._width)/2;
	objSwf.strengthTip._y = wHeight - 190;
	
	objSwf.mcRight._x = wWidth - objSwf.mcRight._width;
	objSwf.mcRight._y = 0
	objSwf.mcLeft._x = 0;
	objSwf.mcLeft._y = wHeight - objSwf.mcLeft._height
	objSwf.bottomBtn._y = wHeight - 190
	objSwf.bottomBtn._x = (wWidth-objSwf.bottomBtn._width)/2;
	-- objSwf.bg._x = (wWidth-objSwf.bg._width)/2;
	-- objSwf.bg._y = (wHeight-objSwf.bg._height)/2;
end

function UILoginWait:OnHide()
end

function UILoginWait:OnShow()
	local wWidth,wHeight = UIManager:GetWinSize();
	self:OnResize(wWidth,wHeight);
	self:ShowRoleInfo();
	print(debug.traceback())
end

--显示玩家信息
function UILoginWait:ShowRoleInfo()
	if not self.roleInfo then return; end
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottom.labelName.text = self.roleInfo.roleName;
	objSwf.bottom.levelNum.num = self.roleInfo.level;
	if t_map[self.roleInfo.mapId] then
		objSwf.bottom.labelMap.text = t_map[self.roleInfo.mapId].name;
	else
		objSwf.bottom.labelMap.text = "";
	end
	objSwf.mcLeft.labelLoginTime.text = CTimeFormat:todate(self.roleInfo.lastLoginTime);
	if self.roleInfo.fight < 0 then
		objSwf.mcLeft.fightNum.num = 0;
	else
		objSwf.mcLeft.fightNum.num = self.roleInfo.fight;
	end
	objSwf.mcRight.vipNum.num = self.roleInfo.vipLevel;
	objSwf.mcRight.mcHead:gotoAndStop(self.roleInfo.prof);
end

--设置玩家登陆信息
function UILoginWait:SetRoleInfo(msg)
	self.roleInfo = msg;
	self:ShowRoleInfo();
end

--点击进入游戏 
function UILoginWait:OnBtnEnterClick()
	if not self.hasSend then
		self.hasSend = true;
		LogManager:Send(130);
		LoginController:EnterGame();
	end
end