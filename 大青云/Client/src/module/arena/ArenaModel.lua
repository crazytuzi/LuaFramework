--[[
	竞技场Model
	wangshuai
]]

_G.ArenaModel = Module:new();

ArenaModel.myRoleInfo = {}; --  我的信息
ArenaModel.fristList = {}; -- 123名
ArenaModel.beRoleList = {}; -- 被挑战人物
ArenaModel.skillInfovo = {}; -- 竞技战报
ArenaModel.skinfoTextlist = {};

ArenaModel.resultsVo = {};


ArenaModel.myWardItemVo = {};
ArenaModel.Allrawardlist = {};
ArenaModel.curbeRoleRank = 0;

ArenaModel.timerKey = nil;  -- 计时器
function ArenaModel:GetBeroleName(rank)
	for i,info in ipairs(self.fristList) do
		if info.rank == rank then
			return info.roleName;
		end;
	end;
	for c,cao in ipairs(self.beRoleList) do
		if cao.rank == rank then
			return cao.roleName;
		end;
	end;
end;
function ArenaModel : InitFun()
	-- 注册TimerEvent
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,0);
end;

function ArenaModel : Ontimer()
	local lastTime = ArenaModel : GetMyroleInfo().lastTime
	if not lastTime then return end;
	ArenaModel : GetMyroleInfo().lastTime = ArenaModel : GetMyroleInfo().lastTime - 1;
	local t,s,m = ArenaModel:GetCurtime()

	if ArenaModel : GetMyroleInfo().lastTime < 0 then
		ArenaModel : GetMyroleInfo().lastTime = 0;
		return;
	end;
	if UIArena:IsShow() then
		UIArena:timerText(t,s,m)
	end;
end;
-- 获取当前冷却时间
function ArenaModel : GetCurtime(bo,time)
	if bo == true then
		local ti = self.myRoleInfo.lastTime;
		return ti
	end;
	local tim = self.myRoleInfo.lastTime;
	if time then
		tim = time;
	end
	if tim < 0 then tim = 0; end
	local t,s,m = CTimeFormat:sec2format(tim)
	if t < 10 then
		t= "0"..t;
	end;
	if s < 10 then
		s = "0"..s;
	end;
	if m < 10 then
		m = "0"..m;
	end;
	return t,s,m
end;
function ArenaModel:GetMyRank()
	return self.myRoleInfo.rank;
end;
---我的属性
function ArenaModel : SetMyroleInfo(rank,chal,lastTime,isResults,ranks,field,admoney,adhonor,maxchallTime)
	self.myRoleInfo.rank = rank; -- 当前排名
	self.myRoleInfo.honor = MainPlayerModel.humanDetailInfo.eaHonor--honor; -- 荣誉值
	self.myRoleInfo.chal = chal; -- 挑战次数
	self.myRoleInfo.lastTime = lastTime ; -- 冷却时间
	self.myRoleInfo.isResults = isResults; -- 是否领取奖励
	self.myRoleInfo.ranks = ranks; -- 人物0点排行
	self.myRoleInfo.field = field; -- 连胜常数
	self.myRoleInfo.admoney = admoney;  --累计金钱
	self.myRoleInfo.adhonor = adhonor; -- 累计荣誉
	self.myRoleInfo.maxchall = maxchallTime;
	Notifier:sendNotification(NotifyConsts.ArenaUpMyInfo);
	--计算我自己的奖励
	self:setWradInfo();
	self:UpdateToQuest();
end;
function ArenaModel:GetCurRank()
	return self.myRoleInfo.rank;
end;
function ArenaModel : GetMyroleInfo()
	return self.myRoleInfo;
end;
--计算我自己的奖励
function ArenaModel : setWradInfo()
	local grade = 7;
	local txt = "";
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
	for i,info in ipairs(t_jjc) do
		local lvl = split(info.rank_range,",")
		local curmyLvl = self.myRoleInfo.ranks
		if curmyLvl == 0 then curmyLvl = self.myRoleInfo.rank; end;
		if curmyLvl >= tonumber(lvl[1]) and curmyLvl <= tonumber(lvl[2]) then
			grade = i;
			txt = lvl[1].."-"..lvl[2]
			break;
		end;
	end;
	if grade == 0 or grade == nil then
		print(debug.traceback("grade is "..grade.."  serverRanks: "..self.myRoleInfo.ranks.."  serverRank: "..self.myRoleInfo.rank));
	end;

	local itemvo = {};
	local cfg = t_jjcPrize[mylvl];
	if not cfg then return;end
	itemvo.honor = cfg.honor[grade];
	itemvo.gold = cfg.gold[grade];
	itemvo.zhenqi = cfg.zhenqi[grade];
	itemvo.exp = cfg.exp[grade];
	itemvo.txt = txt;
	self.myWardItemVo = itemvo;
	--奖励更新完成。	
	self:SetAllWardItem();
end;
function ArenaModel : SetAllWardItem()
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel;
	self.Allrawardlist = {};
	local cfg = t_jjcPrize[mylvl];
	for i,info in ipairs(t_jjc) do
		local de = split(info.rank_range,",");
		local vo = {};
		vo.miniRank = de[1];
		vo.maxRank = de[2];
		vo.honor = cfg.honor[i];
		vo.gold = cfg.gold[i];
		vo.zhenqi = cfg.zhenqi[i];
		vo.exp = cfg.exp[i];
		table.push(self.Allrawardlist,vo)
	end;
end;
--得到奖励list
function ArenaModel : GetAllReward()
	return self.Allrawardlist;
end;
-- 得到我的奖励
function ArenaModel : GetMyReward()
	return self.myWardItemVo;
end;

--挑战对象
function ArenaModel : SetChallenge(list)
	self.beRoleList = {};
	for i,info in ipairs(list) do
		local vo = {};
		vo.id = info.roleId;
		vo.roleName = info.roleName;
		vo.fight = info.fight;
		vo.rank = info.rank;
		vo.prof = info.prof;
		vo.arms = info.arms;
		vo.dress = info.dress;
		vo.shoulder = info.shoulder;
		vo.fashionshead = info.fashionshead
		vo.fashionsarms = info.fashionsarms
		vo.fashionsdress = info.fashionsdress
		vo.wuhunId = 0;--info.wuhunId;
		vo.wing = info.wing
		vo.suitflag = info.suitflag
		table.push(self.beRoleList,vo)
	end;

	local vo = self.beRoleList;
	for i=1,#vo-1 do
		for i=1,#vo-1 do
			if vo[i].rank > vo[i+1].rank then
				vo[i] ,vo[i+1] = vo[i+1],vo[i];
			end;
		end;
	end;
	--trace(self.beRoleList)
	--UIArena:ShowBeRoleInfo();
	Notifier:sendNotification(NotifyConsts.ArenaUpChaObjectlist);
end;
function ArenaModel : GetBerolelist()
	return self.beRoleList;
end;
--123名
function ArenaModel : SetFrist(list)
	self.fristList = {};

	for i,info in  ipairs(list) do
		local vo = {};
		vo.id = info.roleId;
		vo.roleName = info.roleName;
		vo.fight = info.fight;
		vo.rank = info.rank;
		vo.prof = info.prof;
		vo.arms = info.arms;
		vo.dress = info.dress;
		vo.fashionshead = info.fashionshead
		vo.fashionsarms = info.fashionsarms
		vo.fashionsdress = info.fashionsdress
		vo.wing = info.wing
		vo.suitflag = info.suitflag
		vo.wuhunId = 0;--info.wuhunId;
		table.push(self.fristList,vo)
	end;
	--发送消息 返回fristrank
	Notifier:sendNotification(NotifyConsts.ArenaUpFirstRank);
end;
function ArenaModel : GetFristList()
	return self.fristList;
end;
-- 竞技战报
function ArenaModel : SkillInfo(list)
	self.skillInfovo = {};
	for i=1,#list-1 do
		for i=1,#list-1 do
			if list[i].time < list[i+1].time then
				list[i] ,list[i+1] = list[i+1],list[i];
			end;
		end;
	end;

	for i,info in ipairs(list) do
		local vo = {};
		local param = split(info.param,",")
		local tim = self:GetSkinfoText(info)
		local cfg = t_jjcEvent[info.id]
		local str = cfg.desc;
		str = self:GetStringSkInfo(param,str)
		local tit = string.format(StrConfig["arena115"])
		if cfg.win == 0 then
			--失败
			str = "<font color='#cc0000'>"..tit..tim..str.."</font>"
		elseif cfg.win == 1 then
			--成功
			str = "<font color='#29cc00'>"..tit..tim..str.."</font>"
		end;
		table.push(self.skillInfovo,str)
	end;
	Notifier:sendNotification(NotifyConsts.ArenaSkInfoUpdata);
end;
function ArenaModel : GetStringSkInfo(param,str)
	str =  string.gsub(str,"{[^{}]+}",function(pattern)
			local paramStr = string.sub(pattern,2,#pattern-1);--去大括号
			if tonumber(paramStr) == 1 then
				return "<font color='#00fffc'><u>"..param[tonumber(paramStr)].."</u></font>"
			end;
			return param[tonumber(paramStr)]
		end)
	return str;
end;
function ArenaModel : GetSkInfo()
	return self.skillInfovo
end;
-- 得到时间
function ArenaModel : GetSkinfoText(vo)
	local now = GetServerTime();
	local times = now - vo.time
	-- 得到年月日时分秒时间
	--local year, month, day, hour, minute, second = CTimeFormat:todate(vo.time,true);
	--return string.format('%02d:%02d:%02d',hour, minute, second);
	local time = 0;
	local timetxt = ""
	if times > 60 then
		time = toint(times / 60)
		timetxt = string.format(StrConfig["arena117"],time); -- 分
		if time > 60 then
			time = time/60
			timetxt = string.format(StrConfig["arena118"],toint(time)); -- 时
			if time > 24 then
				time = time/24;
				if time >= 3 then
					time = 3;
				end;
				timetxt = string.format(StrConfig["arena135"],toint(time)); -- 时
			end;
		end;
	else
		timetxt = string.format(StrConfig["arena116"],times); -- 秒
	end;
	return timetxt;
end;

function ArenaModel : GetSkInfotextList()
	return self.skinfoTextlist;
end;
--保存战斗结果；
function ArenaModel : SaveFigInfo(msg)
	--trace(msg)
	local vo = self.resultsVo;
	vo.result = msg.result;
	vo.exp = msg.exp;
	vo.honor = msg.honor;
	vo.rank = msg.rank;

	--print(msg.result,"这是我的。。。")

	--local fun = function() ArenaBattle:StarFig() end
	--print("返回战斗结果，并且调用动画")
	--UIArenaVsAn:PlayAnimation(fun);
	--Notifier:sendNotification(NotifyConsts.ArenaChallRe);
end;
function ArenaModel : GetFigInfo()
	return self.resultsVo;
end;


-- 得到当前挑战人物排行
function ArenaModel:GetCurBeRole()
	return self.curbeRoleRank;
end;
function ArenaModel:SetCurBeRole(rank)
	self.curbeRoleRank = rank
end;
--得到整点在线奖励
function ArenaModel:GetHoursReward()
	local gold =  t_consts[29].val3;
	local honor = t_consts[29].val2;
	return honor,gold
end;

function ArenaModel:GetLeftTimes()
	return self:GetMyroleInfo().maxchall - self:GetMyroleInfo().chal;
end

function ArenaModel:UpdateToQuest()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Arena, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local timeAvailable = ArenaModel:GetLeftTimes()
	if QuestModel:GetQuest(questId) then
		if timeAvailable <= 0 then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if timeAvailable <= 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end