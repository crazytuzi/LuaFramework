--[[
帮派战
wangshuai
]]

_G.UnionWarModel = Module:new();

UnionWarModel.curMapId = 0;
UnionWarModel.curLienId = 0;

UnionWarModel.WarAllInfo = {};
UnionWarModel.Intergrallist = {};
UnionWarModel.KillList = {};
UnionWarModel.buildingState = {};
UnionWarModel.buildingNum = {};

UnionWarModel.timerKey = nil -- 计时器

UnionWarModel.isAtWarActivity = false;

UnionWarModel.IsFirst = 1;
UnionWarModel.unionRank ={};


function UnionWarModel:GetIsAtUnionActivity()
	return self.isAtWarActivity
end;

function UnionWarModel:init()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,0);
end;

--计时器
function UnionWarModel:Ontimer()
	if not UnionWarModel.WarAllInfo.UnionTime then return end;
	local time = UnionWarModel.WarAllInfo.UnionTime;
	if time < 0 then
		if UnionWarModel.timerKey then 
			TimerManager:UnRegisterTimer(UnionWarModel.timerKey);
			UnionWarModel.timerKey = nil;
		end;
	end;
	time = time - 1;
	UnionWarModel.WarAllInfo.UnionTime = time;
	UIUnionRight:UpTime()
	if UIUnionWarNpcWin:IsShow() then 
		 UIUnionWarNpcWin:UpTime()
	end
end;
-- get 
function UnionWarModel:GetIntergrallist()
	return self.Intergrallist;
end;
function UnionWarModel:GetKillList()
	return self.KillList;
end;
function UnionWarModel:GetWarAllInfo()
	return self.WarAllInfo;
end
function UnionWarModel:GetWarBuilding()
	return self.buildingState;
end;
function UnionWarModel:GetPresonScore()
	return self.PersonScoreList;
end;

function UnionWarModel:GetWarBuildingIndex(id)
	if not self.buildingState[id] then 
		return 1
	end;
	return self.buildingState[id].state;
end;

function UnionWarModel:GetBuildIngNum()
	return self.buildingNum
end;

-- 得到我当前的排名
function UnionWarModel:GetMyRankData(id)
	for i,info in ipairs(self.Intergrallist) do
		if info.Unionid == id then 
			return info
		end;
	end;
	return 0;
end;

---set 
function UnionWarModel:SetScene(mapid,lienid) 
	self.curMapId = mapid;
	self.curLienId = lienid;
end;

function UnionWarModel:SetWatAllInfo(msg)
	local vo = {};
	vo.myUnionNum = msg.myUnionNum;
	vo.myUnionRank = msg.myUnionRank;
	vo.UnionTime = msg.UnionTime;
	vo.skill = msg.skill;
	vo.luakRank = msg.luckyRank;
	self.WarAllInfo = {};
	self.WarAllInfo = vo;
	self:sendNotification(NotifyConsts.UnionWarAllinfo);
end;

function UnionWarModel:SetActLastTime(time)
	if not self.WarAllInfo then 
		self.WarAllInfo = {};
	end;
	self.WarAllInfo.UnionTime = time
end;

function UnionWarModel:SetWarMyScore(val,rank)
	self.WarAllInfo.myScore = val or 0;
	self.WarAllInfo.Myrank = rank or 1;
end;

function UnionWarModel:SetIntergralRanklist(list)
	self.Intergrallist = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.Score = info.Score;
		vo.UnionName = info.UnionName;
		vo.Unionid = info.Unionid;
		vo.rank = i;
		table.push(self.Intergrallist,vo)
	end;
	self:sendNotification(NotifyConsts.UnionWarUpdataList);
end;

function UnionWarModel:SetKillRanklist(list) 
	self.KillList = {};
	for i,info in ipairs(list) do 
		local vo ={} ;
		vo.Score = info.Score;
		vo.UnionName = info.UnionName;
		table.push(self.KillList,vo)
	end;
	self:sendNotification(NotifyConsts.UnionWarUpdataList);
end;

function UnionWarModel:SetPersonScorelist(list) 
	self.PersonScoreList = {};
	for i,info in ipairs(list) do 
		local vo ={} ;
		vo.Score = info.Score;
		vo.UnionName = info.UnionName;
		table.push(self.PersonScoreList,vo)
	end;
	self:sendNotification(NotifyConsts.UnionWarUpdataList);
end;


function UnionWarModel:SetBuildingState(msg)
	self.buildingState = {};
	for i,info in ipairs(msg.listStatus) do 
		local vo = {};
		vo.state = info.status;
		table.push(self.buildingState,vo)
	end;
	self.buildingState.wangzuoname = msg.throneBelong;
	 self:sendNotification(NotifyConsts.UnionWarAllinfo);
	 --trace(self.buildingState)
end;

function UnionWarModel:GetOccUnionName()
	if not self.buildingState.wangzuoname then return end;
	return self.buildingState.wangzuoname;
end;


-- 进入活动的方法
function UnionWarModel:EnterScene()
	--TimerManager:RegisterTimer(function()
		if UIUnionAcitvity:IsShow() then 
			UIUnionAcitvity:Hide() ---  尝试关闭提醒
		end;
		UIUnionManager:Hide();
		if UnionWarController.sceneType == 1 then 
			UIUnionRight:Show();
			UIUnionWarNpcWin:Hide();
		end;
		--UIUnionRight:Show();
		MainMenuController:HideRightTop();
	self.isAtWarActivity = true;
	--end,1000,1);
end;

-- 退出活动的方法
function UnionWarModel:OutScene()
	self.isAtWarActivity = false;
	TimerManager:RegisterTimer(function()
			UIUnionWarNpc:Hide();
			UIUnionWarNpcWin:Hide();
			UIUnionRight:Hide();
			MainMenuController:UnhideRightTop();
	end,500,1);
end;

function UnionWarModel:GetTimer(time)
	if not time then return end;
	if time <= 0 then return "00","00","00" end;
	local ti = time / 60 -- 分
	local tim = (ti % 1)*60 + 0.1
	local m = toint(tim)
	if m < 10 then 
		m = "0"..m
	end;
	local s = toint(ti)
	local t = 0;
	if s >= 60 then 
		t = toint(s/60);
		s = s%60;
	end;

	if s < 10 then 
		s = "0"..s
	end;

	if t < 10 then 
		t = "0"..t;
	end;
	return t,s,m
end;

---帮派战，结束数据
function UnionWarModel:SetReawrdInfo(msg)
	self.unionRank = {};
	self.IsFirst = msg.isfirst;
	local luakrank = msg.luaRank;
	for i,info in ipairs(msg.ranklist) do 
		local vo ={};
		vo.rank = i;
		vo.id = info.Id;
		vo.score = info.Score;
		vo.name = info.UnionName;
		vo.isque = info.isqua;
		table.push(self.unionRank,vo)
	end;
	UIUnionReward:Show();
	UIUnionRight:Hide();
end;

function UnionWarModel:GetReawrdList()
	return self.unionRank;
end;

function UnionWarModel:GetReawrdListItem(id)
	for i,info in ipairs(self.unionRank) do 
		if info.id == id then  
			return info;
		end;
	end;
end;


