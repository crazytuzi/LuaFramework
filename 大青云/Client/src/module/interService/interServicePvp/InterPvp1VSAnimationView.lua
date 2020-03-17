--[[
	vs动画
wangshuai
]]
_G.UIInterPvp1VsAn = BaseUI:new("UIInterPvp1VsAn");

UIInterPvp1VsAn.curtime = 0;
UIInterPvp1VsAn.fun = nil;
UIInterPvp1VsAn.curWidth = 0;
UIInterPvp1VsAn.curheight = 0;
function UIInterPvp1VsAn : Create()
	self:AddSWF("interPvp1VSAnimation.swf",true,"story");
end;

function UIInterPvp1VsAn : OnLoaded(objSwf)
	objSwf.btnEnter.click = function() 
		InterServicePvpController:ReqExitMatchPvp()
	end	
	objSwf.btnMin.click = function() 
		UIInterServiceMinPanel:Show()
		self:Hide()
		MainInterServiceUI.isMin = true
		MainInterServiceUI:Hide()
	end
end;
function UIInterPvp1VsAn : PlayAnimation(Onfun)
	self.fun = Onfun;
	self:Show();
end;

function UIInterPvp1VsAn : OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	--objSwf.vspanel._visible = false;
	local x,y = UIManager:GetWinSize();


	objSwf.panelread._y = -620;
	objSwf.panelread._x = 250.65;

	objSwf.panelbule._y = y --+ 100;
	objSwf.panelbule._x = -422.55;
	local myvo = MainPlayerModel.humanDetailInfo	
	
	-- 玩家形象
	if myvo then
		objSwf.panelread.loadicon.source = ResUtil:GetArenaRoleImageImg(myvo.eaProf)
		-- 玩家名字
		objSwf.panelread.txtname.text = myvo.eaName
		-- 玩家攻击力
		objSwf.panelread.ChalNum.num = myvo.eaFight;
	end	
	objSwf.vspanel:gotoAndPlay(0)
	--动面板  r 97 b - 66
	Tween:To(objSwf.panelread,0.5,{_x=0,_y=0,ease=Quart.easeIn})
	Tween:To(objSwf.panelbule,0.5,{_x=0,_y=0,ease=Quart.easeIn},{onComplete = function()
			objSwf.vspanel._visible = true;
				self:Compleyefun();
		end})	
end;

function UIInterPvp1VsAn : Compleyefun()
	local objSwf =self.objSwf;
	if not objSwf then return end;
	objSwf.vspanel:gotoAndPlay(11)
	_rd.camera:shake(1, 3, 500)
	TimerManager:RegisterTimer(function()
		-- objSwf.vspanel:gotoAndPlay(60)
		-- Tween:To(objSwf.panelread,0.2,{_x = 250.65,_y = -503,ease=Cubic.easeIn});
		-- Tween:To(objSwf.panelbule,0.2,{_x = -322.55,_y = 551.50,ease=Cubic.easeIn},{ onComplete = function()
		-- UIInterPvp1VsAn:Hide();
		--end});
	end,2000,1);
end;
function UIInterPvp1VsAn : Update()
	self:SetCurMyXY();
end;

function UIInterPvp1VsAn : SetCurMyXY()
	if not self.objSwf then return end;
	self.curWidth,self.curheight = UIManager:GetWinSize();

	local objSwf = self.objSwf
	local vx = self.curWidth/2;
	local vy = self.curheight/2 --+ 100;

	objSwf._x = vx + 30;
	objSwf._y = vy;
end;

function UIInterPvp1VsAn : OnHide()
	if not self.fun then return end;
	self.fun();
end;

------ 消息处理 ---- 
function UIInterPvp1VsAn:ListNotificationInterests()
	return {
		NotifyConsts.KuafuPvpExitCatching,
		}
end;
function UIInterPvp1VsAn:HandleNotification(name,body)
	if not self.bShowState then return; end  
	if name == NotifyConsts.KuafuPvpExitCatching then 
		self:Hide();
	end;
end;