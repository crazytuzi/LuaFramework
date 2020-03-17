--[[
	activity unionBoss
	wangshuai
]]
_G.UnionBossController = setmetatable({},{__index = IController})
UnionBossController.name = "UnionBossController"

function UnionBossController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_UnionBossActivityOpen, self, self.SetBossOpenResult ) -- 2167  8484
	MsgManager:RegisterCallBack( MsgType.WC_UnionBossActivityRemind, self, self.SetBossRemind ) -- -- 提醒
	MsgManager:RegisterCallBack( MsgType.SC_UnionBossActivityInfo, self, self.SetBossInfo ) -- -- 总信息、
	MsgManager:RegisterCallBack( MsgType.WC_UnionBossActivityEnterResult, self, self.SetEnterResult ) -- -- 进入结果
	MsgManager:RegisterCallBack( MsgType.SC_UnionBossActivityResult, self, self.SetBossRewardResult ) -- -- 结果、
	MsgManager:RegisterCallBack( MsgType.SC_UnionBossActivityOut, self, self.SetBossOutResult ) -- -- 退出结果、
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer() end,1000,0);

end;

-- 计时器！
function UnionBossController:Ontimer() 
	if not  MainPlayerController.isEnter then return end;
	if UnionbossModel.lastTime >= 0 then 
		UnionbossModel.lastTime = UnionbossModel.lastTime - 1;
		if UnionbossModel:GetOpenState() == 2 then 
			if UnionbossModel:GetActState() == false then 
				if UnionbossModel.lastTime > 0 then 
					-- UIUnionAcitvity:SetShowInfo(4,UnionbossModel.lastTime)
				else
					-- if UIUnionAcitvity:IsShow() then 
					-- 	UIUnionAcitvity:Hide();
					-- end;
				end;
			end;
		else
			-- if UIUnionAcitvity:IsShow() then 
			-- 	UIUnionAcitvity:Hide();
			-- end;
		end;
	end;
	if UIUnionBossWindow:IsShow() then 
		UIUnionBossWindow:TimeUpdata()
	end;
end;

function UnionBossController:SetBossOpenResult(msg)
	--trace(msg)
	--print("帮主开启结果")
	if msg.result == 1 then 
		-- 成功开启

	elseif msg.result == 2 then 
		-- 资金不足

	elseif msg.result == 3 then 
		-- 等级不足

	end;
	
end;

UnionBossController.isremind = false;

function UnionBossController:SetBossRemind(msg)
	if msg.result == 0 then 
		-- no open;
		local vo = {};
		vo.result = msg.result;
		vo.lastTime = 0
		UnionWarController.actRemind[4] = vo;
		UnionWarController:OnSetActivityTime(4)
	elseif msg.result == 1 then 
		-- open  
		if UIUnionAcitvity:IsShow() then 
			if UIUnionAcitvity.curid == 4 then 
				UIUnionAcitvity:Hide();
			end;
		end;

		local vo = {};
		vo.result = msg.result;
		vo.lastTime = 0
		UnionWarController.actRemind[4] = vo;
		UnionWarController:OnSetActivityTime(4)
	elseif msg.result == 2 then 
		-- open ing
		local vo = {};
		vo.result = msg.result;
		vo.lastTime = msg.lastTime;
		UnionWarController.actRemind[4] = vo;
		UnionWarController:OnSetActivityTime(4)

		UnionbossModel:SetlastTime(msg.lastTime)
		UnionbossModel:SetIngActId(msg.id)
		if MainPlayerController:IsEnterGame() then 
			local okfun = function () self:EnterUnionBoss() end;
			UIConfirm:Open(StrConfig["unionBoss013"],okfun);
			self.isremind = false;
		else
			self.isremind = true;
		end;
	end;
	UnionbossModel:SetOpenState(msg.result);
	--活动状态。刷新界面
	if UIUnionBoss:IsShow() then 
		UIUnionBoss:SetEnterBtnState()
	end;
end;

function UnionBossController:SetBossInfo(msg)
	-- trace(msg)
	-- print("总信息")
	UnionbossModel:SetSkillList(msg.rolelist);
	UnionbossModel:SetBossInfo(msg.bossCurHp,msg.bossAllHp,msg.curid,msg.allnum,msg.damage)
	if UIUnionBossWindow:IsShow() then 
		UIUnionBossWindow:UpdataInfo();
	else
		self:EnterAct();
	end;
end;


function UnionBossController:SetBossRewardResult(msg)
	--trace(msg)
	--print("奖励结果")
	UnionbossModel:SetActivityResult(msg.result)
	if not UIUnionBossReward:IsShow() then 
		 UIUnionBossReward:Show();
	end
end;

function UnionBossController:SetBossOutResult(msg)
	trace(msg)
	print("退出结果")
	self:OutAct();
end;



function UnionBossController:SetEnterResult(msg)
	--trace(msg)
	--print("换线")
	--UnionbossModel:SetOpenState(msg.result)
	if msg.result == 0 then 
		-- succeed;
		self:SetScene(msg.lineID)

	elseif msg.result == 1 then 
		-- fail

	elseif msg.result == 2 then 
		-- no Open

	end;
end;

function UnionBossController:OnEnterGame()
	if self.isremind then 
		local okfun = function () self:EnterUnionBoss() end;
		UIConfirm:Open(StrConfig["unionBoss013"],okfun);
		self.isremind = false;
	end;
end;

---------------换线
UnionBossController.curLineid = 0;
UnionBossController.isChangeLine = false;
function UnionBossController:SetScene(lineID)
	self.curLineid = lineID;
	local curline = CPlayerMap:GetCurLineID();
	if curline == lineID then 
		-- 可进入场景
		self:SureEnterUnionBoss();
	else 
		self.isChangeLine = true;
		MainPlayerController:ReqChangeLine(self.curLineid);
	end;
end;
-- 换线成功
function UnionBossController:OnLineChange()
	if self.isChangeLine ~= true then return end;
	if self.curLineid == 0 then return end;
	-- 进入活动
	self:SureEnterUnionBoss();
	self.isChangeLine = false;
end;
--换线失败
function UnionBossController:OnLineChangeFail()
	self.isChangeLine = false;
end


---------------------c to s 

-- 帮主请求开启
function UnionBossController:OpenUnionBoss(id)
	local msg = ReqUnionBossActivityOpenMsg:new();
	msg.Id = id;
	MsgManager:Send(msg)
	--trace(msg)
	--print("帮主请求开启")
end;

-- 进入活动
function UnionBossController:EnterUnionBoss()
	local msg = ReqUnionBossActivityEnterMsg:new()

	local fun = function() 
		MsgManager:Send(msg);
	end;
	if TeamUtils:RegisterNotice(UIUnionBoss,fun) then 
		return
	end;
	
	MsgManager:Send(msg)
	--trace(msg)
	--print("请求进入活动")
end;

--换线成功
function UnionBossController:SureEnterUnionBoss()
	local msg = ReqUnionBossActivitySureEnterMsg:new()
	MsgManager:Send(msg)
	--trace(msg)
	--print("确认进入活动")
end;

-- 退出活动
function UnionBossController:OutUnionBoss()
	local msg = ReqUnionBossActivityOutMsg:new()
	MsgManager:Send(msg)
	--trace(msg)
	--print("退出活动")
end;


UnionBossController.IsActIng = false;
---------活动进入
function UnionBossController:EnterAct()
	UnionbossModel:SetActState(true);
	UIUnionManager:Hide();
	MainMenuController:HideRightTop();
	UIUnionBossWindow:Show();
	if UIUnionAcitvity:IsShow() then 
		if UIUnionAcitvity.curid == 4 then 
			UIUnionAcitvity:Hide();
		end;
	end;
end;

function UnionBossController:OutAct()
	UnionbossModel:SetActState(false);
	UIUnionBossWindow:Hide();
	MainMenuController:UnhideRightTop();
end;

