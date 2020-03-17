--[[
活动 阵营战场
wangshaui
]]

_G.ActivityZhanChang = BaseActivity:new(ActivityConsts.ZhanChang);
ActivityModel:RegisterActivity(ActivityZhanChang);

ActivityZhanChang.zcInfoVo = {}; --战场信息
ActivityZhanChang.zcRoleInfo = {}; -- 人物信息
ActivityZhanChang.zcGeneralList = {}; -- ab阵营榜单  1==6,2==7
ActivityZhanChang.zcFlagList = {}; --战场旗子；
ActivityZhanChang.zcSkllList = {}; -- 嗜血榜单;
ActivityZhanChang.zcContrList = {}; -- 贡献榜单；
ActivityZhanChang.IsSignUp = 0; -- 0报名， 1 未报名
ActivityZhanChang.zcGeneral = {};-- 总排行榜
ActivityZhanChang.zcReward  ={};-- 奖励界面数据
ActivityZhanChang.zclianxuMaxNum ={}; -- 连续击杀最大数量
ActivityZhanChang.isHaveFlag = nil; -- 是否有旗子
ActivityZhanChang.timerKey = nil;
ActivityZhanChang.isAtZhanchangAct = false;
ActivityZhanChang.curshowUI = true
function ActivityZhanChang : RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_GetZhanchanginfo,self,self.ZhanchangInfo); -- 返回战场信息  8183
	MsgManager:RegisterCallBack(MsgType.SC_ZhancRoleinfo,self,self.ZhanchangRoleInfo); -- 返回战场人物信息   8184
	MsgManager:RegisterCallBack(MsgType.WC_ZhancSignUp,self,self.ZhanchangSingUp); -- 战场报名  7137
	MsgManager:RegisterCallBack(MsgType.SC_UpdateFlags,self,self.ZhanchangFlag); -- 推送战场内旗子状态
	MsgManager:RegisterCallBack(MsgType.SC_PickFlagResult,self,self.FlagResult); -- 旗子返回结果
	MsgManager:RegisterCallBack(MsgType.SC_ZhancKillRank,self,self.ZhanchangKillRank); -- 返回战场噬血榜
	MsgManager:RegisterCallBack(MsgType.SC_ZhancContriRank,self,self.ZhanchangContrRank); -- 返回战场贡献榜
	MsgManager:RegisterCallBack(MsgType.SC_ZhancUpdate,self,self.ZhanchangInfoUpdata); -- 返回战场信息更新

	MsgManager:RegisterCallBack(MsgType.SC_ZhancResult,self,self.ZhanchangReward); -- 返回战场结果
	MsgManager:RegisterCallBack(MsgType.SC_ZhancZuidjs,self,self.ZhanchangMaxNum); -- 返回战场最大击杀榜
	
end;
function ActivityZhanChang:FinishRightQuit()
	return false
end;

-- 进入活动执行方法
function ActivityZhanChang:OnEnter()
	self.isAtZhanchangAct = true;
	--  注册时间侦听器
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer( function() self:OnTimer() end,1000,0);
end


function ActivityZhanChang:OnShowUI()
	if self.curshowUI == true then 
		self.curshowUI = false;
		UIZhanChang:Show();
		UIActivity:Hide();
		ChatController:OpenCampChat();
	end;
end;

-- 退出活动执行方法
function ActivityZhanChang:OnQuit()
	self.isAtZhanchangAct = false;
	self.curshowUI = true;
	UIZhanChang:Hide();
	ZhChFlagController:EscMap()
	ChatController:CloseCampChat();
	-- 清楚阵营头像
	self.isHaveFlag = nil;
	if UIZhchUpFlag:IsShow() then 
		UIZhchUpFlag:Hide();
	end;
	if UIZhanChErjiView:IsShow() then 
		UIZhanChErjiView:Hide();
	end;
	if UIZhchRewardInsterction:IsShow() then 
		UIZhchRewardInsterction:Hide();
	end;
	if UIZhanChangMap:IsShow() then 
		UIZhanChangMap:Hide();
	end;
	if UIZhchZhaoHuan:IsShow() then 
		UIZhchZhaoHuan:Hide();
	end;
end

function ActivityZhanChang:GetMyCamp()
	return self.zcInfoVo.type
end;
ActivityZhanChang.haveFlagRemindNum = 0;
--计时器
function ActivityZhanChang:OnTimer()
	--print("竟来了么")
	if not self.isAtZhanchangAct then return end;
	if not ActivityZhanChang.zcInfoVo.sourceTime then return end;
	ActivityZhanChang.zcInfoVo.sourceTime = ActivityZhanChang.zcInfoVo.sourceTime -1;
	local t, s, m = CTimeFormat:sec2format(ActivityZhanChang.zcInfoVo.sourceTime);
	if s < 10 then 
		s = "0"..s 
	end;
	if m < 10 then 
		m = "0"..m;
	end;
	ActivityZhanChang.zcInfoVo.lasttimer = ActivityZhanChang.zcInfoVo.lasttimer - 1;
	local at,as,am  = CTimeFormat:sec2format(ActivityZhanChang.zcInfoVo.lasttimer);
	if as < 10 then 
		as = "0"..as;
	end;
	if am < 10 then 
		am = "0"..am;
	end;

	if UIZhanChang:IsShow() then 
		if ActivityZhanChang.zcInfoVo.sourceTime >= 0 then 
			UIZhanChang:updataSourceTime(s,m)
		end;
		if ActivityZhanChang.zcInfoVo.lasttimer >= 0 then
			UIZhanChang:ShowTimerFun(at,as,am)
		end;
		
	end;


	----- ----- -- ------ ---- 判断是否有旗子，是否需要提醒尽快交付 
	if self.isAtZhanchangAct then 
		if self.isHaveFlag then 
			if not UIZhchUpFlag:Show() then 
				UIZhchUpFlag:Show();
			end;
		else
			if UIZhchUpFlag:IsShow() then 
				UIZhchUpFlag:Hide();
			end;
		end;
		if self.isHaveFlag then 
			self.haveFlagRemindNum = self.haveFlagRemindNum + 1;
		else
			self.haveFlagRemindNum = 0;
		end;
		if self.haveFlagRemindNum >= 10 then 
			FloatManager:AddActivity(StrConfig['zhanchang119']);
			self.haveFlagRemindNum = 0;
		end;
	end;
end;
ActivityZhanChang.PopNum = 0;
function ActivityZhanChang:OnStateChange()
	local activity = ActivityModel:GetActivity(ActivityConsts.ZhanChang);
	local opentime = activity:GetOpenLastTime()
	if tonumber(opentime) <= 0 then 
		if self.IsSignUp == 1 then
			if self.isAtZhanchangAct == true then 
				return 
			end;
			if self.PopNum == 1 then 
				return 
			end;
			self.PopNum = 1;

			local okfun = function () 
				ActivityController:EnterActivity(ActivityConsts.ZhanChang);
			end;
			local state = false;
			local nofun = function () state = true; end;--StrConfig["zhanchang118"],
			UIZhchZhaoHuan:Open(okfun,nofun);
			TimerManager:RegisterTimer(function()
				if self.isAtZhanchangAct then 
					return 
				end;
				if state == false then 
					ActivityController:EnterActivity(ActivityConsts.ZhanChang);
					UIZhchZhaoHuan:Hide();
				end;
			end, 10000, 1)
		end;
	end;
end;

--------------------------------------s To c -- 

-- 战场结束奖励结果
function ActivityZhanChang:ZhanchangReward(msg)
	local victory = msg.result;
	self.zcReward["victory"] = victory;
	local list = msg.rewardList;

	for i,info in ipairs(list) do 
		local vo = {};
		vo.roleName = info.roleName;
		vo.icon = info.icon;
		vo.num = info.num;
		self.zcReward[i] = vo;
	end;
	-- 显示奖励界面数据
	UIZhanChangReward:Show()	
end;
-- zhanchang info updata 
function ActivityZhanChang:ZhanchangInfoUpdata(msg)
	local info = self.zcInfoVo;
	if msg.type == 0 then 
		-- A阵营得分
		info.scoreA = msg.value;
		if UIZhanChang:IsShow() == true then
			UIZhanChang:SetMyInfoPanel()
		end;
		if UIZhanChErjiView:IsShow() == true then
			UIZhanChErjiView:SetMyInfoPanel()
		end;
		return
	end;
	if msg.type == 1 then 
		-- B阵营得分
		info.scoreB = msg.value;
		if UIZhanChang:IsShow() == true then
			UIZhanChang:SetMyInfoPanel()
		end;
		if UIZhanChErjiView:IsShow() == true then
			UIZhanChErjiView:SetMyInfoPanel()
		end;
		return 
	end;
	if msg.type == 2 then 
		-- A阵营击杀信使数
		if info.type == 6 then 
			info.num = msg.value;
			if UIZhanChang:IsShow() == true then
				UIZhanChang:SetMyInfoPanel()
			end;
			if UIZhanChErjiView:IsShow() == true then
				UIZhanChErjiView:SetMyInfoPanel()
			end;
		end;
	end;
	if msg.type == 3 then 
		-- B阵营击杀信使数
		if info.type == 7 then 
			info.num = msg.value;
			if UIZhanChang:IsShow() == true then
				UIZhanChang:SetMyInfoPanel()
			end;
			if UIZhanChErjiView:IsShow() == true then
				UIZhanChErjiView:SetMyInfoPanel()
			end;
		end;
	end;
	if msg.type == 4 then 
		-- 资源刷新
		info.sourceTime = msg.value;
		if UIZhanChang:IsShow() == true then
			UIZhanChang:SetMyInfoPanel()
		end;
		if UIZhanChErjiView:IsShow() == true then
			UIZhanChErjiView:SetMyInfoPanel()
		end;
	end;
	if msg.type == 5 then  
		-- 我的击杀 
		info.addnum = msg.value;
		if UIZhanChang:IsShow() == true then 
			UIZhanChang:ShowMySkInfo()
		end;
	end;
	if msg.type == 6 then 
		-- 我的连续击杀
		info.contnum = msg.value;
		if UIZhanChang:IsShow() == true then 
			UIZhanChang:ShowMySkInfo()
		end;
	end;
	if msg.type == 7 then 
		-- 我的贡献度
		info.contr = msg.value;
		if UIZhanChang:IsShow() == true then 
			UIZhanChang:ShowMySkInfo()
		end;
	end;
	if msg.type == 8 then 
		-- 我的最大击杀
		info.maxcontnum = msg.value;
		if UIZhanChang:IsShow() == true then
			--UIZhanChang:SetMyInfoPanel()
		end;
	end;
	-- 更新信息
end;
-- zhanchang Contr Rank 
function ActivityZhanChang : ZhanchangContrRank(msg)
	--print("贡献榜")
	--trace(msg)
	self.zcContrList = {};
	for i,info in pairs(msg.rankList) do
		if info.camp ~= 0 then 
		local vo = {};
		vo.camp = info.camp;
		vo.roleName = info.roleName;
		vo.contr = info.contr;
		table.push(self.zcContrList,vo)
		end;
	end;

	if UIZhanChang:IsShow() == true then 
		UIZhanChang:GongxianRankShow()
	end;
end;
-- zhanchang Kill Rank
function ActivityZhanChang : ZhanchangKillRank(msg)
	--print("嗜血帮")
	--trace(msg)
	self.zcSkllList = {};
	for i,info in pairs(msg.rankList) do 
		if info.camp ~= 0 then 
		local vo = {};
		vo.camp = info.camp;
		vo.roleName = info.roleName;
		vo.addnum = info.Addnum;
		vo.contnum = info.contnum;
		table.push(self.zcSkllList,vo)
		end;
	end;
	if UIZhanChang:IsShow() == true then 
		UIZhanChang:ShiXueRnakShow()
	end;
end;
-- 连续击杀最大排行榜
function ActivityZhanChang:ZhanchangMaxNum(msg) 
	self.zclianxuMaxNum = {};	
	for i,info in ipairs(msg.rankList) do 
		if info.camp ~= 0 then 
		local vo = {};
		vo.roleName = info.roleName;
		vo.camp = info.camp;
		vo.Addnum = info.Addnum;
		table.push(self.zclianxuMaxNum,vo)
		end;
	end;

	--刷新ui
	if UIZhanChang:IsShow() == true then 
		UIZhanChang:setlianxuJishaList();
	end;
end;
-- zhanchang info 
function ActivityZhanChang : ZhanchangInfo(msg)
	-- trace(msg)
	-- print("战场数据")
	local vo = {};
	vo.type = msg.type;
	vo.scoreA = msg.scoreA;
	vo.scoreB = msg.scoreB;
	vo.sourceTime = msg.sourceTime;
	vo.num = msg.num;
	vo.contr = msg.contr;
	vo.addnum = msg.Addnum;
	vo.contnum = msg.contnum;
	vo.maxcontnum = msg.Maxcontnum;
	vo.lasttimer = msg.time;
	self.zcInfoVo = vo;
	if UIZhanChang:IsShow() == true then
		UIZhanChang:SetMyInfoPanel()
	end;
	if UIZhanChErjiView:IsShow() == true then
		UIZhanChErjiView:SetMyInfoPanel()
	end;
	-- my info updata 
	self:OnShowUI();
end;

-- zhanchang role info 
function ActivityZhanChang : ZhanchangRoleInfo(msg)
	-- print("战场人物信息")
	-- trace(msg)
	local vo = nil;
	if msg.camp == 6 then 
		-- zy A
		self.zcGeneral = {};	-- 清空总list
		self.zcGeneralList[1] = {};
		vo = self.zcGeneralList[1];
	end;
	if msg.camp == 7 then 
		-- zy B
		self.zcGeneralList[2] = {};
		vo = self.zcGeneralList[2]
	end;
	if not vo then return end;
	for i,info in pairs(msg.infolist) do 
		local xvo = {};
		xvo.roleName = info.roleName;
		xvo.camp = msg.camp
		xvo.contr = info.contr;
		xvo.addnum = info.Addnum;
		xvo.contnum = info.contnum;
		table.push(vo,xvo)
		table.push(self.zcGeneral,xvo)
	end;

	-- 排序
	self:Sortlist(self.zcGeneral);
	self:Sortlist(self.zcGeneralList[1]);
	self:Sortlist(self.zcGeneralList[2]);

	if UIZhanChang:IsShow() == true then
		if UIZhanChang.curpaneindex == 1 then 
			UIZhanChang:ShowZonglanlist();
		end;
		if UIZhanChang.curpaneindex == 2 then 
			UIZhanChang:ShowAzonglanList();
		end;
		if UIZhanChang.curpaneindex == 3 then 
			UIZhanChang:ShowBzonglanList()
		end;
	end;
end;


-- zhanchang IsSignUp 
function ActivityZhanChang : ZhanchangSingUp(msg)
	self.IsSignUp = msg.type;
end;

-- zhanchang falg 
function ActivityZhanChang : ZhanchangFlag(msg)
	-- trace(msg)
	-- print("旗子状态")
	for i,info in pairs(msg.flagList) do 
		local vo = {};
		vo.idx = info.idx;
		vo.camp = info.camp;
		vo.canPick = info.canPick;
		local cfg = ZhChFlagConfig[info.idx];
		cfg.camp = info.camp;

		self.zcFlagList[vo.idx] = vo
		if vo.canPick == 1 then
			ZhChFlagController:DeleteFlag(vo.idx)
			ZhChFlagController:AddFlag(vo.idx,vo.camp)
			UIZhanChangMap:OnShowTexiao(vo.idx)  -- 特效提醒，
		elseif vo.canPick == 0 or vo.canPick == 2 then 
			ZhChFlagController:DeleteFlag(vo.idx)
		end
	end
	MapController:CleanUpCurrMap();  -- 清楚无用点
	MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图
end

-- zhanchang  falg state get
function ActivityZhanChang:GetFlagEnemyState()
	local flag = {}
	local myCamp =  self:GetMyCamp()
	for i,info in pairs(self.zcFlagList) do 
		if info.camp == myCamp then 
			table.push(flag,info)
		end;
	end;
	return flag
end;
-- zhanchang  falg Result 
function ActivityZhanChang : FlagResult(msg)
	--trace(msg)
		if msg.type == 0 then 
			-- 夺取
			if msg.result == 1 then 
				-- 夺旗成功
				self.isHaveFlag = msg.idx;
				ZhChFlagController:DeleteFlag(msg.idx)
				local player = MainPlayerController:GetPlayer();
				if not player then return; end
				player:AddPosMonitor(tostring(ActivityZhanChang), ActivityZhanChang);
				--FloatManager:AddNormal(StrConfig['zhanchang109']);
			end;
			if msg.result == 3 then 
				-- 采集距离不足
				--FloatManager:AddNormal(StrConfig['zhanchang105']);
			end;
	elseif msg.type == 1 then 
		-- 交付
		if msg.result == 1 then 
			-- 成果
			--消除旗子的操作
			ActivityZhanChang.isHaveFlag = nil;
			local player = MainPlayerController:GetPlayer();
			if not player then return; end
			player:DelPosMonitor(tostring(self));
			--FloatManager:AddNormal(StrConfig['zhanchang108']);
		elseif msg.result == 3 then 
			-- 不可交付 位置不够
			ActivityZhanChang.isHaveFlag = msg.idx;
			--FloatManager:AddNormal(StrConfig['zhanchang106']);
		elseif msg.result == 2 then 
			-- 不可交付
			ActivityZhanChang.isHaveFlag = msg.idx;
			--FloatManager:AddNormal(StrConfig['zhanchang107']);
		end;
	end;
end;
function ActivityZhanChang:PlayerOverFalgNil()
	ActivityZhanChang.isHaveFlag = nil;
end;

--玩家坐标改变
function ActivityZhanChang:OnPosChange(objPlayer, newPos)
	if not ActivityZhanChang.isHaveFlag then return end;
	local vx,vy = newPos.x,newPos.y -- 玩家新坐标
	local myCamp = ActivityZhanChang.zcInfoVo.type;
	if not myCamp then return end;
	local cfg = ZhChFlagUpPoint[myCamp];

	local dx = vx - cfg.x;
	local dy = vy - cfg.y;
	local dist = math.sqrt(dx*dx+dy*dy);
	-- print(dist,cfg.r,"判断旗子是否可交付")
	if dist < cfg.r then 
		--交付旗子
		-- print(dist,"交付旗子")
		ActivityZhanChang:ReqZhanchangFalg(1,ActivityZhanChang.isHaveFlag)
		-- -- 消除旗子的操作
		-- ActivityZhanChang.isHaveFlag = nil;
	end;
end
-------------------------------------c To s -- 
-- req falg 
function ActivityZhanChang : ReqZhanchangFalg(oper,idx)
	--print(oper,idx)
	local msg = ReqPickFlagMsg:new();
	msg.oper = oper;
	msg.idx = idx;
	MsgManager:Send(msg);
end;
-- req Zhanchang Rank  -- camp 
function ActivityZhanChang : ReqZhancRank()
	local  msg = ReqZhancRankMsg:new();
	msg.camp = 0;
	MsgManager:Send(msg)
end;

-- req Zhanchang SingUp
function ActivityZhanChang : ReqZhancSingUp()
	local msg = ReqZhancSignUpMsg:new();
	if self.IsSignUp == 0 then 
		-- 未报名
		msg.type = 1;
	end;
	if self.IsSignUp == 1 then 
		-- 以报名
		msg.type = 0;
	end;
	MsgManager:Send(msg);
end;
--- 请求获取奖励
function ActivityZhanChang : ReqZhancGetReward()
	local msg = ReqZhancRewardMsg:new();
	MsgManager:Send(msg);
end;

function ActivityZhanChang:Sortlist(list)
	if not list then return end;
	-- if #list <= 0 then return end;
	-- for i=1,#list-1 do 
		-- for i=1,#list-1 do 
			-- if list[i].addnum < list[i+1].addnum then  
				-- list[i] ,list[i+1] = list[i+1],list[i];
			-- end;
		-- end;
	-- end;
	table.sort(list,function(A,B)
		return A.addnum > B.addnum
	end)
	-- return list;
end;

