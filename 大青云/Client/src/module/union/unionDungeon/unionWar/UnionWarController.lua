--[[
活动 帮派战
wangshaui
]]

_G.UnionWarController = setmetatable({},{__index = IController});
UnionWarController.name = "UnionWarController";

UnionWarController.isChangeLine = false;

UnionWarController.curLineid = 0;
UnionWarController.sceneType = 0;
UnionWarController.isShowUI = true;
UnionWarController.opentime = {};
UnionWarController.actRemind = {};

UnionWarController.timerKey = nil;  -- 计时器
function UnionWarController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_UnionWarAct, self, self.SetScene ) -- 7115
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarNpcHungUp, self, self.GetEnterSceneNpcState ) -- 8227
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarInfo, self, self.SetUnionWarInfo ) -- 8228
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarScore, self, self.SetWarRankList ) -- 8229
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarBuState, self, self.SerSceneBuildingState ) -- 8230
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarReward, self, self.SetUnionWarReawrd ) -- 8256
	MsgManager:RegisterCallBack( MsgType.SC_UnionWarState , self, self.CloseUnionWar)
	MsgManager:RegisterCallBack( MsgType.WC_UnionActivityRemind , self, self.ActRemind)
end;

function UnionWarController:CloseUnionWar(msg)
	if msg.result == 0 then 
		local okfun = function () self:Outwar(); end;
		local nofun = function () self:Outwar(); end;
		local str = UIConfirm:Open(StrConfig['unionwar228'],okfun,nofun);
		TimerManager:RegisterTimer(function()
			UIConfirm:Close(str)
			self:Outwar()
		end,28000,1);
	end; 
end;

UnionWarController.sceneChangeCallBack = nil
function UnionWarController:OnChangeSceneMap()
	if self.sceneChangeCallBack then
		self.sceneChangeCallBack()
		self.sceneChangeCallBack = nil
	end
end

function UnionWarController:ActRemind(msg)
	for i,info in pairs(msg.NoticeList) do 
		local vo = {};
		vo.result = info.result;
		vo.lastTime = info.lastTime;
		self.actRemind[info.type] = vo;
	end;
	self:OnSetActivityTime(2)
	self:OnSetActivityTime(3)
	self:OnSetActivityTime(5)
end;

function UnionWarController:OnEnterGame()
	--启动定时器,每秒检测一次活动提醒
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	-- self.timerKey = TimerManager:RegisterTimer(function()
		-- self:ShowNotice();
	-- end,1000,0);
end

function UnionWarController:OnSetActivityTime(guiAct)
	self.opentime[guiAct] = {};
	local actState = self.actRemind[guiAct];
	if actState then 
		self.opentime[guiAct].result = actState.result;
		if actState.result == 0 or actState.result == 1 then 
			self.opentime[guiAct] = nil
			if guiAct == 2 then
				RemindController:ClearRemind(RemindConsts.Type_UnionWar);
			elseif guiAct == 3 then
				RemindController:ClearRemind(RemindConsts.Type_UnionCityWar);
			elseif guiAct == 5 then
				RemindController:ClearRemind(RemindConsts.Type_UnionDGWar);
			end
			return 
		end;
		self.opentime[guiAct].lasttime = actState.lastTime;
		self:ShowNotice();
	end;
end;
function UnionWarController:ShowNotice()
	-- 帮派是否开启
	local unionIsOpen = FuncManager:GetFuncIsOpen(FuncConsts.Guild)
	if not unionIsOpen then 
		return 
	end;
	for i,info  in pairs(self.opentime) do
		if info.result == 2 then 
			local last = info.lasttime;
			if last then 
				info.lasttime =  info.lasttime - 1;
				if last > 0 then -- 活动开启
				--	print("可以显示ui",remain)
					local data = {};
					data.id = i;
					data.num = info.lasttime;
					if i == 2 then
						RemindController:AddRemind(RemindConsts.Type_UnionWar,data);
					elseif i == 3 then
						RemindController:AddRemind(RemindConsts.Type_UnionCityWar,data);
					elseif i == 5 then
						RemindController:AddRemind(RemindConsts.Type_UnionDGWar,data);
					end
					break;
				else
					--print("不可以显示ui")
					if i == 2 then
						RemindController:ClearRemind(RemindConsts.Type_UnionWar);
					elseif i == 3 then
						RemindController:ClearRemind(RemindConsts.Type_UnionCityWar);
					elseif i == 5 then
						RemindController:ClearRemind(RemindConsts.Type_UnionDGWar);
					end
					break;
				end;
			end;
		else
			if i == 2 then
				RemindController:ClearRemind(RemindConsts.Type_UnionWar);
			elseif i == 3 then
				RemindController:ClearRemind(RemindConsts.Type_UnionCityWar);
			elseif i == 5 then
				RemindController:ClearRemind(RemindConsts.Type_UnionDGWar);
			end
		end;
	end;
end;
------- c to s
-- 退出帮派战
function UnionWarController:Outwar()
	local msg = ReqQuitGuildWarMsg:new();
	MsgManager:Send(msg);
	self.isShowUI = true;
	-- 退出场景执行方法
	UnionWarModel:OutScene()
end;
function UnionWarController:EnterWar()
	local msg = ReqEnterGuildWarMsg:new();
	msg.MapId = 0;
	MsgManager:Send(msg);
	TimerManager:RegisterTimer(function()
		if UnionWarController.sceneType == 0 then 
			UIUnionWarNpcWin:Show();
			
		end;
	end,1000,1);
	UIUnionManager:Hide();
	MainMenuController:HideRightTop();
	UnionWarModel:init()
	self.sceneChangeCallBack = function()
		UIUnionAcitvity:SetShowState(false) 
		UIUnionAcitvity:Hide();		
	end
end; 
------- w To c 
function UnionWarController:SetScene(msg)
	if msg.isopen == 0 then 
		--FloatManager:AddNormal(StrConfig["unionwar223"]);
		return
	end; 
	self.curLineid = msg.lineID;
	self.sceneType  = msg.type;
	local curline = CPlayerMap:GetCurLineID();
	if curline == msg.lineID then 
		-- 可进入场景
		self:EnterWar();
	else 
		MainPlayerController:ReqChangeLine(self.curLineid);
	end;
	if msg.type == 0 then 
		UnionWarModel:SetActLastTime(msg.lasttime)
	end;
end;
-- 换线成功
function UnionWarController:OnLineChange()
	if self.isChangeLine ~= true then return end;
	if self.curLineid == 0 then return end;
	-- 进入活动
	self:EnterWar()
	self.isChangeLine = false;
end;
--换线失败
function UnionWarController:OnLineChangeFail()
	self.isChangeLine = false;
end

--请求领取奖励
function UnionWarController:OnReqGetReward()
	local msg = ReqGetUnionWarRewardMsg:new()
	MsgManager:Send(msg);
	self.isShowUI = true;
end;

-------  c  To w 
-- 请求加入帮派战
function UnionWarController:ReqAddUnionWar()
	self.isChangeLine = true;
	local msg = ReqUnionWarActMsg:new()
	
	local fun = function() 
		MsgManager:Send(msg);
	end;
	if TeamUtils:RegisterNotice(UIUnion,fun) then 
		return
	end;
	
	MsgManager:Send(msg);
end;

----------  s To c 
function UnionWarController:GetEnterSceneNpcState(msg)
	-- npc 挂了
	-- 需要显示倒计时文本
	UIUnionWarNpc:Show();
	if UIUnionWarNpcWin:IsShow() then 
		UIUnionWarNpcWin:Hide();
	end;
	TimerManager:RegisterTimer(function()
		UnionWarController.sceneType = 1;
	end,5000,1);
end;

function UnionWarController:SetUnionWarInfo(msg)
	--   总信息
	UnionWarModel:SetWatAllInfo(msg)
	if self.isShowUI == true then 
		self.isShowUI = false;
		UnionWarModel:EnterScene()
	else
		return ;
	end;
end;

function UnionWarController:SetWarRankList(msg)
	--  排行信息 前五吧
	if  msg.type == 1 then 
		-- jiFen
		UnionWarModel:SetIntergralRanklist(msg.list)
	elseif msg.type == 2 then 
		-- jiSha`	
		UnionWarModel:SetKillRanklist(msg.list)
	elseif msg.type ==  3 then 
		--个人积分
		UnionWarModel:SetPersonScorelist(msg.list) 
		UnionWarModel:SetWarMyScore(msg.mySocre,msg.mySocreRank)
	end;
end;

function UnionWarController:SerSceneBuildingState(msg) 
	-- 建筑物状态，
	UnionWarModel:SetBuildingState(msg)
	--trace(msg)
	MapController:CleanUpCurrMap();  -- 清楚无用点
	MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图
end


function UnionWarController:SetUnionWarReawrd(msg)
	UnionWarModel:SetReawrdInfo(msg);
end;


---------------提供调用的进入方法
function UnionWarController:GOGOGOEnterWar()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end;
	if mapCfg.can_teleport == false then 
		FloatManager:AddSysNotice(2005014);--已达上限
		-- FloatManager:AddNormal(StrConfig["unioncitywar824"]);
		return 
	end;
	local unionlvl = UnionModel:GetMyUnionLevel();
	local cfglvl = t_guildActivity[2].guildlv;
	if unionlvl < cfglvl then 

		FloatManager:AddNormal(StrConfig["unionwar225"]);
		return 
	end;
	UnionWarController:ReqAddUnionWar()
end;