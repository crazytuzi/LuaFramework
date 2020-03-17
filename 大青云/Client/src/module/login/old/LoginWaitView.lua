--[[
登陆等待界面
lizhuangzhuang
2014年9月3日11:32:24
]]

_G.UILoginWait = BaseUI:new("UILoginWait");

UILoginWait.roleInfo = nil;--登录玩家信息
UILoginWait.hasSend = false;--是否已发送请求登录协议

function UILoginWait:Create()
	self:AddSWF("loginWaitPanelOld.swf",true,"center");
end

function UILoginWait:OnLoaded(objSwf)
	objSwf.bottom.btnEnter.click = function() self:OnBtnEnterClick(); end
	
	objSwf.bottom.btnLeft.stateChange = function(e) CLoginScene:OnBtnRoleRightStateChange(e.state); end;
	objSwf.bottom.btnRight.stateChange = function(e) CLoginScene:OnBtnRoleLeftStateChange(e.state); end;
	objSwf.mcLeft.labelTitleLoginTime.text = ''--UIStrConfig['login6']
	-- objSwf.mcRight.labelTitleTotalTime.text = UIStrConfig['login8']
	objSwf.mcRight.mcHead:stop();
	objSwf.mcLeft.fightNum.loadComplete = function() 
		local width = objSwf.mcLeft.fightNum.width;
		objSwf.mcLeft.labelTitleLoginTime._x = (123 + width - 280)/2 
		-- objSwf.mcLeft.fightNum._x =(objSwf.mcLeft._width-width)/2 + 10;
	end
	objSwf.mcRight.vipNum.visible = false
	
	objSwf.mcRight._visible = false;
	objSwf.bottom._visible = false;
	objSwf.mcLeft._visible = false;
	objSwf.warningLabel._visible = true;
	
end

function UILoginWait:DeleteWhenHide()
	return true;
end

function UILoginWait:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottom._x = (wWidth - 297)/2
	objSwf.bottom._y = wHeight - 136 - 100
	-- if wHeight <= 750 then
		-- objSwf.bottom._y = wHeight - objSwf.bottom._height + 100
	-- else
	-- end
	
	objSwf.strengthTip._x = (wWidth - objSwf.strengthTip._width)/2;
	objSwf.strengthTip._y = wHeight - 25;
	
	objSwf.blackPanel._x = 0;
	objSwf.blackPanel._y = 0;
	objSwf.blackPanel._width = wWidth;
	objSwf.blackPanel._height = wHeight;
	
	objSwf.warningLabel._x = (wWidth - objSwf.warningLabel._width)/2;
	objSwf.warningLabel._y = (wHeight - objSwf.warningLabel._height)/2;
	
	objSwf.mcRight._x = wWidth - objSwf.mcRight._width;
	objSwf.mcRight._y = 410
	objSwf.mcLeft._x = 0;
	objSwf.mcLeft._y = wHeight - objSwf.mcLeft._height
	-- objSwf.bottom._y = wHeight - 190
	-- objSwf.bottom._x = (wWidth-623)/2;
	
end

function UILoginWait:OnHide()
end

function UILoginWait:OnShow()
	local wWidth,wHeight = UIManager:GetWinSize();
	self:OnResize(wWidth,wHeight);
	
	self.objSwf.warningLabel.htmlText = UIStrConfig['login9'];
	self.objSwf.warningLabel._visible = false;
	self.objSwf.blackPanel._visible = false;
	local onCompleteHandler = function()
		self:ShowRoleInfo();
		self.objSwf.mcRight._visible = true;
		self.objSwf.bottom._visible = true;
		self.objSwf.mcLeft._visible = true;
		self.objSwf.warningLabel._visible = false;
	end
	--[[
	Tween:To(self.objSwf.blackPanel,4,{_alpha=100},{onComplete=function()
			Tween:To(self.objSwf.blackPanel,2,{_alpha=0});
			Tween:To(self.objSwf.warningLabel,2,{_alpha=0},
					{onComplete=function()
						onCompleteHandler();
					end},true);
			end},true);
	]]
	onCompleteHandler();

end

--显示玩家信息
function UILoginWait:ShowRoleInfo()
	if not self.roleInfo then return; end
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
 	objSwf.bottom.labelName.text = self.roleInfo.roleName;
 	objSwf.bottom.levelNum.num = self.roleInfo.level
	--objSwf.mcRight.labelLevel.text = string.format(StrConfig['login10'],);
	--objSwf.mcRight.labelProf.text = PlayerConsts:GetProfName(self.roleInfo.prof);
	-- if t_map[self.roleInfo.mapId] then
		-- objSwf.bottom.labelMap.text = t_map[self.roleInfo.mapId].name;
	-- else
		objSwf.bottom.labelMap.text = "";
	-- end
	objSwf.mcLeft.labelLoginTime.text = '上次登录时间:'..CTimeFormat:todate(self.roleInfo.lastLoginTime);
	if self.roleInfo.fight < 0 then
		objSwf.mcLeft.fightNum.num = 0;
	else
		objSwf.mcLeft.fightNum.num = self.roleInfo.fight;
	end
	-- objSwf.mcRight.vipNum.num = self.roleInfo.vipLevel;
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