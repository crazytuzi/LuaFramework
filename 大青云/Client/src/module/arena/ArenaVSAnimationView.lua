--[[
	vs动画
wangshuai
]]
_G.UIArenaVsAn = BaseUI:new("UIArenaVsAn");

UIArenaVsAn.curtime = 0;
UIArenaVsAn.fun = nil;
UIArenaVsAn.curWidth = 0;
UIArenaVsAn.curheight = 0;
function UIArenaVsAn : Create()
	self:AddSWF("arenaVSAnimation.swf",true,"story");
end;

function UIArenaVsAn : OnLoaded(objSwf)
end;
function UIArenaVsAn : PlayAnimation(Onfun)
	self.fun = Onfun;
	self:Show();
end;

function UIArenaVsAn : OnShow()
	local objSwf = self.objSwf;
	--objSwf.vspanel._visible = false;
	local x,y = UIManager:GetWinSize();


	objSwf.panelread._y = -620;
	objSwf.panelread._x = 250.65;

	objSwf.panelbule._y = y + 100;
	objSwf.panelbule._x = -422.55;
	local myvo = ArenaBattle.playerList[1]--.playerInfo
	local othervo = ArenaBattle.playerList[2]--.playerInfo
	if not myvo then return end;
	if not othervo then return end;
	--if myvo or othervo then 
	-- 玩家形象
	objSwf.panelread.loadicon.source = ResUtil:GetArenaRoleImageImg(myvo.prof)
	objSwf.panelbule.loadicon.source = ResUtil:GetArenaRoleImageImg(othervo.prof)
	-- 玩家名字
	objSwf.panelread.txtname.text = myvo.playerInfo[enAttrType.eaName];
	objSwf.panelbule.txtname.text = othervo.playerInfo[enAttrType.eaName]

	-- 玩家攻击力
	objSwf.panelread.ChalNum.num = myvo.power;
	objSwf.panelbule.ChalNum.num = othervo.power;
	objSwf.vspanel:gotoAndPlay(0)
	--动面板  r 97 b - 66
	Tween:To(objSwf.panelread,0.5,{_x=0,_y=0,ease=Quart.easeIn})
	Tween:To(objSwf.panelbule,0.5,{_x=0,_y=0,ease=Quart.easeIn},{onComplete = function()
			objSwf.vspanel._visible = true;
				self:Compleyefun();
		end})

	-- Tween:To(objSwf.panelread,0.3,{_x = 0,_y = 0,ease=Cubic.easeIn});
	-- Tween:To(objSwf.panelbule,0.3,{_x = 0,_y = 0,ease=Cubic.easeIn},{ onComplete = function()
	-- 		objSwf.vspanel._visible = true;
	-- 				self:Compleyefun();
	-- 	end});
end;

function UIArenaVsAn : Compleyefun()
	local objSwf =self.objSwf;
	if not objSwf then return end;
	objSwf.vspanel:gotoAndPlay(11)
	_rd.camera:shake(1, 3, 500)
	TimerManager:RegisterTimer(function()
		objSwf.vspanel:gotoAndPlay(60)
		Tween:To(objSwf.panelread,0.2,{_x = 250.65,_y = -503,ease=Cubic.easeIn});
		Tween:To(objSwf.panelbule,0.2,{_x = -322.55,_y = 551.50,ease=Cubic.easeIn},{ onComplete = function()
			UIArenaVsAn:Hide();
		end});
	end,2000,1);
end;
function UIArenaVsAn : Update()
	self:SetCurMyXY();
end;

function UIArenaVsAn : SetCurMyXY()
	if not self.objSwf then return end;
	self.curWidth,self.curheight = UIManager:GetWinSize();

	local objSwf = self.objSwf
	local vx = self.curWidth/2;
	local vy = self.curheight/2 + 100;

	objSwf._x = vx;
	objSwf._y = vy;
end;

function UIArenaVsAn : OnHide()
	if not self.fun then return end;
	self.fun();
end;