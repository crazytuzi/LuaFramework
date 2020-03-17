--[[
	活动，帮派王城战
	wangshuai
]]
_G.UnionDiGongController = setmetatable({},{__index = IController})
UnionDiGongController.name = "UnionDiGongController"

UnionDiGongController.isChangeLine = 0;
UnionDiGongController.curlineId = 0;
UnionDiGongController.curId = 0;
UnionDiGongController.isIn = false;
UnionDiGongController.isRet = false;
UnionDiGongController.timerKey = nil;
UnionDiGongController.isFirstShow = true;
UnionDiGongController.oldstate = 0;
function UnionDiGongController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_EnterDiGongResult, self, self.OnUnionEnterDiGongWarMsg );
	MsgManager:RegisterCallBack( MsgType.WC_DiGongBoss, self, self.OnUnionDiGongInfoMsg );
	MsgManager:RegisterCallBack( MsgType.WC_UnionDiGongBidInfo, self, self.OnUnionDiGongBidInfoMsg );
	MsgManager:RegisterCallBack( MsgType.WC_UnionDiGongBid, self, self.OnUnionDiGongBidMsg );
	MsgManager:RegisterCallBack( MsgType.SC_UnionDiGongScoreNotify, self, self.OnUnionDiGongScoreNotify );
	MsgManager:RegisterCallBack( MsgType.SC_UnionDiGongBuState, self, self.OnUnionDiGongBuState );
	MsgManager:RegisterCallBack( MsgType.SC_UnionDiGongRet, self, self.OnUnionDiGongRet );
	MsgManager:RegisterCallBack( MsgType.SC_UnionDiGongFlagNotify, self, self.OnUnionDiGongFlagNotify );
	MsgManager:RegisterCallBack( MsgType.SC_DGWar_MapFlag, self, self.OnUnionDGWarMapFlagMsg );
	MsgManager:RegisterCallBack( MsgType.SC_DiGongBossHp, self, self.OnCaveBossInfo)
	MsgManager:RegisterCallBack( MsgType.SC_DiGongMosterUpdate, self, self.OnCaveXXMonsterInfo)
end;
	
--- 地宫BOSS血量信息
function UnionDiGongController:OnCaveBossInfo(msg)
	UICaveBossInfo:SetBossHp(msg)
end

function UnionDiGongController:OnChangeSceneMap()
	UICaveBossInfo:OnChangeSceneMap()
	--print("切换场景成功")
	if self.isChangeLine ~= true then return end;
	self.isChangeLine = false;
	if UIUnionAcitvity:IsShow() then 
			UIUnionAcitvity:Hide() ---  尝试关闭提醒
	end;
	-- UnionCityWarModel:EnterScene()
end;

--- 地宫精英怪信息
function UnionDiGongController:OnCaveXXMonsterInfo(msg)
	UICaveBossInfo:SetMonsterNum(msg.number)
end
-- 退出地宫争夺战战
function UnionDiGongController:OutDiGong()
	--local msg = ReqQuitGuildCityWarMsg:new();
	--MsgManager:Send(msg);
	-- 退出场景执行方法
	--UnionCityWarModel:OutScene()
end;
-- 进入地宫争夺战战
function UnionDiGongController:EnterWar()
	-- local msg = ReqEnterGuildCityWarMsg:new();
	-- msg.MapId = 0;
	-- MsgManager:Send(msg)
	-- 进入场景执行方法
end; 

-- 进入场景
function UnionDiGongController:EnterScene(msg)
	-- if msg.isopen ~= 0 then 
		-- FloatManager:AddNormal(StrConfig["unioncitywar823"]);
		-- return
	-- end; 
	-- if msg.isPass ~= 0 then 
		-- --帮派没有进入权限
		-- FloatManager:AddNormal(StrConfig['unioncitywar803']);
		-- return 
	-- end;
	-- self.curlineId = msg.lineID;
	-- local curline = CPlayerMap:GetCurLineID();
	-- if curline == self.curlineId then
		-- self:EnterWar();
	-- else
		-- MainPlayerController:ReqChangeLine(self.curlineId);
	-- end;
end;

-- 换线成功
function UnionDiGongController:OnLineChange()
	if self.isChangeLine ~= true then return end;
	if self.curlineId == 0 then return end;
	-- 进入活动
	self:EnterWar()
	self.isChangeLine = false;
end;
--换线失败
function UnionDiGongController:OnLineChangeFail()
	self.isChangeLine = false;
end

-- 信息总览
function UnionDiGongController:OnDiGongInfo(msg)
	--UnionDiGongModel:SetCityWarAllinfo(msg.SuperMaxHp,msg.time,msg.mytype,msg.atkUnionName,msg.defUnionName)
	-- TimerManager:RegisterTimer(function()
	-- 	UnionDiGongModel:EnterScene()
	-- end,1000,1);
	--UnionDiGongModel:EnterScene()
end;

function UnionDiGongController:OnDiGongRank(msg)
	--UnionDiGongModel:SetResult(msg)
end;


----------------------C  To  S 
-- 请求进入
function UnionDiGongController:EnterUnionCityWar()
	-- self.isChangeLine = true;
	-- local msg = ReqUnionEnterCityWarMsg:new();
	
	-- local fun = function() 
		-- MsgManager:Send(msg);
	-- end;
	-- if TeamUtils:RegisterNotice(UIUnionDungeonMain,fun) then 
		-- return
	-- end;

	-- MsgManager:Send(msg);
end;

------------------------进入活动
function UnionDiGongController:ReqGoInDiGong()
	-- local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	-- if not mapCfg then return end;
	-- if mapCfg.can_teleport == false then 
		-- FloatManager:AddSysNotice(2005014);--已达上限
		-- -- FloatManager:AddNormal(StrConfig["unioncitywar824"]);
		-- return 
	-- end;

	-- local unionlvl = UnionModel:GetMyUnionLevel();
	-- local cfglvl = t_guildActivity[3].guildlv;
	-- if unionlvl < cfglvl then 
		-- FloatManager:AddNormal(StrConfig["unionwar225"]);
		-- return 
	-- end;
	-- UnionDiGongController:EnterUnionCityWar()
end;




--请求加入帮派地宫争夺战
function UnionDiGongController:ReqUnionEnterDiGongWar(id)
	self.curId = id;
	local msg = ReqUnionEnterDiGongWarMsg:new();
	msg.id = id;
	MsgManager:Send(msg)
	-- print('============请求加入帮派地宫争夺战')
	-- trace(msg)
	
	self.isRet = false;
end

--请求帮派野外地宫信息
function UnionDiGongController:ReqUnionDiGongInfo()
	local msg = ReqDiGongBossMsg:new();
	MsgManager:Send(msg)
	-- print('============请求帮派野外地宫信息')
	-- trace(msg)
end

--请求帮派野外地宫竞标列表信息
function UnionDiGongController:ReqUnionDiGongBidList(id)
	local msg = ReqUnionDiGongBidInfoMsg:new();
	msg.id = id;
	MsgManager:Send(msg)
	-- print('============请求帮派野外地宫竞标列表信息')
	-- trace(msg)
end

--请求帮派野外地宫竞标
function UnionDiGongController:ReqUnionDiGongBid(id,bidmoney)
	local msg = ReqUnionDiGongBidMsg:new();
	msg.id = id;
	msg.bidmoney = bidmoney;
	MsgManager:Send(msg)
	-- print('============请求帮派野外地宫竞标')
	-- trace(msg)
end

--请求进入地宫BOSS
function UnionDiGongController:ReqEnterGuildDiGong()
	local msg = ReqEnterDiGongMsg:new();
	msg.floor = 1;
	MsgManager:Send(msg)
end

--请求退出帮派地宫争夺战
function UnionDiGongController:ReqQuitGuildDiGong(id)
	local msg = ReqQuitGuildDiGongMsg:new();
	msg.id = id;
	MsgManager:Send(msg)
	-- print('============请求退出帮派地宫争夺战')
	-- trace(msg)
	
	self.isIn = false;
	self.isRet = true;
	UnionDiGongModel:SetIsAtUnionActivity(self.isIn)
	
	DiGongFlagController:EscMap();
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	UIUnionDiGongZhuiZongView:Hide();
	MapController:CleanUpCurrMap();  -- 清楚无用点
	MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图
end

--请求帮派地宫争夺战旗帜操作
function UnionDiGongController:ReqUnionDiGongPickFlag()
	local msg = ReqUnionDiGongPickFlagMsg:new();
	MsgManager:Send(msg)
	-- print('============请求帮派地宫争夺战旗帜操作')
	-- trace(msg)
end

-------------------------服务器返回----------------------------------------

--返回进入地宫
function UnionDiGongController:OnUnionEnterDiGongWarMsg(msg)
	if msg.result == 0 then
		self.isIn = true;
		UnionDiGongModel:SetIsAtUnionActivity(self.isIn);
		return;
	end
	if msg.result == -1 then
		FloatManager:AddNormal("进入地宫失败");
		return
	end; 
	if msg.result == -2 then 
		--帮派没有进入权限
		FloatManager:AddNormal("玩家等级不足");
		return 
	end;
	if msg.result == -3 then
		FloatManager:AddNormal("参与人数已满，稍后再试");
		return 
	end
	if msg.result == -4 then
		FloatManager:AddNormal("当前活动关闭");
		return 
	end
	if msg.result == -5 then
		FloatManager:AddNormal("不允许组队");
		return 
	end
	if msg.result == -7 then
		FloatManager:AddNormal("跨服无法参加");
		return 
	end
	if msg.result == -8 then
		FloatManager:AddNormal("道具不足")
		return;
	end
	if msg.result == -6 then
		self.curlineId = 1;
		local curline = CPlayerMap:GetCurLineID();
		if curline == self.curlineId then
			self:ReqEnterGuildDiGong();
		else
			MainPlayerController:ReqChangeLine(self.curlineId);
			self:ReqEnterGuildDiGong();
		end;
	end
end

--返回野外地宫信息
function UnionDiGongController:OnUnionDiGongInfoMsg(msg)
	-- print('============返回帮派野外地宫信息')
	-- trace(msg)
	-- local list = {};
	-- for i,vo in ipairs(msg.list) do
	-- 	local dgVO = {};
	-- 	dgVO.id = vo.id;
	-- 	dgVO.UnionName = vo.UnionName;
	-- 	dgVO.Unionid = vo.Unionid;
	-- 	dgVO.unionid1 = vo.Unionid1;
	-- 	dgVO.UnionName1 = vo.UnionName1;
	-- 	dgVO.bidmoney1 = vo.bidmoney1;
	-- 	dgVO.unionid2 = vo.Unionid2;
	-- 	dgVO.UnionName2 = vo.UnionName2;
	-- 	dgVO.bidmoney2 = vo.bidmoney2;
	-- 	list[vo.id] = dgVO;
		
	-- 	local unVO1 = {};
	-- 	unVO1.id = vo.Unionid1;
	-- 	unVO1.unionName = vo.UnionName1;
	-- 	if vo.Unionid1 then
	-- 		UnionDiGongModel:SetUnionNameById(unVO1);
	-- 	end
	-- 	local unVO2 = {};
	-- 	unVO2.id = vo.Unionid2;
	-- 	unVO2.unionName = vo.UnionName2;
	-- 	if vo.Unionid2 then
	-- 		UnionDiGongModel:SetUnionNameById(unVO2);
	-- 	end
	-- end
	-- UnionDiGongModel:SetDiGongUnionList(list);
	for k, v in pairs(msg.list) do
		UnionDiGongModel:SetBossInfo(v)
	end
	self:sendNotification(NotifyConsts.UnionDiGongInfoUpdate);
	
	--- 下边不知道是什么玩意 暂时不管
	if not self.timerKey then
		self.timerKey = TimerManager:RegisterTimer( self.OnTimer, 1000, 0 );
	end

	RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_CaveBossOpen);
end

--倒计时自动
function UnionDiGongController.OnTimer()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		local curtime = GetDayTime();
		local hour,min,sec = CTimeFormat:sec2format(curtime);
		if hour == 0 and min == 0 then
			UnionDiGongController.isFirstShow = true;
		end
		local nState,havetime = UnionDiGongUtils:GetCurState();
		if nState == UnionDiGongConsts.State_Bid then
			if havetime and havetime > 0 then
				if UnionDiGongController.isFirstShow then
					--帮主
					if UnionModel:IsLeader() then
						RemindController:AddRemind(RemindConsts.Type_GuildDGBid,1);
					end
					UnionDiGongController.isFirstShow = false;
				end
			end
		end
		
		if UnionDiGongController.oldstate ~= nState then
			UnionDiGongController.oldstate = nState;
			UnionDiGongController:sendNotification(NotifyConsts.UnionDiGongInfoUpdate);
			
			if nState == UnionDiGongConsts.State_Fight then
				local data = {};
				data.id = 5;
				data.num = 1800;
				if UnionDiGongUtils:GetIsDiGongWarUniont() then
					RemindController:AddRemind(RemindConsts.Type_UnionDGWar,data);
				end
			end
		end	
	end
end

--返回帮派野外地宫竞标列表信息
function UnionDiGongController:OnUnionDiGongBidInfoMsg(msg)
	-- print('============返回帮派野外地宫竞标列表信息')
	-- trace(msg)
	
	local list = {};
	for i,vo in ipairs(msg.list) do
		local listvo = {};
		listvo.unionName = vo.UnionName;
		listvo.bidmoney = vo.bidmoney;
		table.push(list,listvo);
	end
	UnionDiGongModel:SetUnionBidList(list);	

end

--返回帮派野外地宫竞标结果
function UnionDiGongController:OnUnionDiGongBidMsg(msg)
	-- print('============返回帮派野外地宫竞标结果')
	-- trace(msg)
	
	if msg.result == 0 then
		UnionDiGongController:ReqUnionDiGongBidList(msg.id);
		UnionDiGongController:ReqUnionDiGongInfo();
	elseif msg.result == 1 then 
		print("ERROR：1，")
	elseif msg.result == -2 then 
		FloatManager:AddNormal(StrConfig["unionDiGong006"]);
	elseif msg.result == -4 then 
		FloatManager:AddNormal(StrConfig["unionDiGong012"]);
	end
end

--服务器通知：帮派地宫争夺战战场积分
function UnionDiGongController:OnUnionDiGongScoreNotify(msg)
	-- print('============服务器通知：帮派地宫争夺战战场积分')
	-- trace(msg)
	--如果已经退出
	if self.isRet then
		return;
	end
	if not self.isIn then
		self.isIn = true;
		UnionDiGongModel:ClearData();
		UnionDiGongModel:SetDiGongTime(msg.UnionTime);
		FuncManager:OpenFunc(FuncConsts.Guild,false);
		MainMenuController:HideRight();
		MainMenuController:HideRightTop();
		UIUnionDiGongZhuiZongView:Show();
		UIUnionManager:Hide();
		UnionDiGongModel:SetIsAtUnionActivity(self.isIn)
		
		MapController:CleanUpCurrMap();  -- 清楚无用点
		MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图
	end
	UnionDiGongModel:SetCurFlagInfo(msg.UnionName, msg.RoleName);
	local unionVO1 = {};
	unionVO1.id = msg.Unionid1;
	unionVO1.score = msg.Score1;
	local unionVO2 = {};
	unionVO2.id = msg.Unionid2;
	unionVO2.score = msg.Score2;
	UnionDiGongModel:UpdateUnionInfo(unionVO1,unionVO2);
	--旗帜掉了
	if msg.RoleName ~= "" then
		if UnionDiGongModel:GetIsShowFlag() then
			UnionDiGongModel:SetIsShowFlag(false);
			DiGongFlagController:DeleteFlag();
		end
	end
end


UnionDiGongController.curBuildState = {};
--服务器通知：帮派地宫争夺战建筑物状态
function UnionDiGongController:OnUnionDiGongBuState(msg)
	-- print('============服务器通知：帮派地宫争夺战建筑物状态')
	-- trace(msg)
	self.curBuildState = {};
	for i,info in ipairs(msg.zhuziList) do 
		local vo = {};
		vo.id = info.id;
		vo.Unionid = info.Unionid
		vo.unionName = UnionDiGongModel:GetUnionNameById(info.Unionid);
		table.push(self.curBuildState , vo)
	end;	
	self:sendNotification(NotifyConsts.UnionDiGongWarUpdate);
	MapController:CleanUpCurrMap();  -- 清楚无用点
	MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图

end

--服务器通知：帮派地宫争夺战结算结果
function UnionDiGongController:OnUnionDiGongRet(msg)
	-- print('============服务器通知：帮派地宫争夺战结算结果')
	-- trace(msg)
	
	self.isIn = false;
	self.isRet = true;
	
	local unionid = msg.Unionid;
	UnionDiGongModel:SetWinUnionId(unionid);
	UIUnionDiGongRetView:OpenPanel();
end

--服务器通知：旗帜显示位置
function UnionDiGongController:OnUnionDiGongFlagNotify(msg)
	-- print('============服务器通知：旗帜显示位置')
	-- trace(msg)
	
	UnionDiGongModel:SetFlagPos(msg.posX, msg.posY);
	local cfg= {};
	cfg.x = msg.posX;
	cfg.y = msg.posY;
	
	DiGongFlagController:AddFlag(cfg);
	UnionDiGongModel:SetIsShowFlag(true);
end

local clearTimer
--服务器通知：地图旗帜显示位置
function UnionDiGongController:OnUnionDGWarMapFlagMsg(msg)
	-- print('============服务器通知：地图旗帜显示位置')
	-- trace(msg)

	local playerList = {};
	local vo = {};
	vo.roleId = 1;
	vo.posX = msg.posX;
	vo.posY = msg.posY;
	vo.roleName = "";
	vo.level = 0;
	vo.roleId = 1;
	vo.flag = MapRelationConsts.DG_Flag
	table.push(playerList,vo);
	MapRelationModel:UpdateRelationalPlayer( playerList )
	UnionDiGongModel:SetFlagPos(msg.posX, msg.posY);
	UIUnionDiGongZhuiZongView:DoAutoRun();

	-- 如果超过3s没有收到服务器新的玩家列表，说明当前没有需要显示
	-- 地图图标的玩家，这时清除玩家图标(有需要显示图标的玩家时，服务器每1s推送一次玩家列表)。
	local delTimer = function()
		if clearTimer then
			TimerManager:UnRegisterTimer(clearTimer)
			clearTimer = nil
		end
	end
	delTimer()
	clearTimer = TimerManager:RegisterTimer( function()
		delTimer()
		MapRelationModel:UpdateRelationalPlayer( {} )
	end, 3000, 1)
end