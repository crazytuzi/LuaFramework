--[[
 activity unionBoss
 wangshuai
]]

_G.UnionbossModel = Module:new()

UnionbossModel.ActivityState = 0;-- 0=未开启，1，已开启过，2=开启ing
UnionbossModel.lastTime = 0;
UnionbossModel.skillList = {};
UnionbossModel.activityInfo = {};
UnionbossModel.isActIng = false;
UnionbossModel.IngActId = 1;


-- 活动开启state
function UnionbossModel:SetOpenState(state)
	self.ActivityState = state;
end;

function UnionbossModel:GetOpenState()
	return self.ActivityState or 0;
end;

-- 活动开启后计时
function UnionbossModel:SetlastTime(time)
	self.lastTime = time;
end;

function UnionbossModel:GetLastTime()
	return self.lastTime;
end;

function UnionbossModel:SetIngActId(id)
	self.IngActId = id;
end;

function UnionbossModel:GetIngActId()
	return self.IngActId;
end;


--活动信息
function UnionbossModel:SetBossInfo(bossCurHp,bossAllHp,curid,allnum,myDamage)
	self.activityInfo.bossCurHp = bossCurHp;
	self.activityInfo.curid = curid;
	self.activityInfo.bossAllHp = bossAllHp;
	self.activityInfo.allnum = allnum;
	self.activityInfo.myDamage = myDamage;
end;

function UnionbossModel:GetBossInfo()
	return self.activityInfo
end;

--getMyDamage
function UnionbossModel:GetMyDamage()
	return self.activityInfo.myDamage or 0;
end;

-- getMyInfo 
function UnionbossModel:GetMyRankInfo()
	local myName = MainPlayerModel.humanDetailInfo.eaName;
	for i,info in ipairs(self.skillList) do
		if info.roleName == myName then 
			return info;
		end;
	end;
	return {}
end;

--getAllroleNum
function UnionbossModel:GetCurRoleNum()
	local num = 0;
	for i,info in ipairs(self.skillList) do 
		num = num + 1;
	end;
	return num;
end;

-- 排行信息
function UnionbossModel:SetSkillList(list)
	self.skillList = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo = info;
		vo.rank = i;
		table.push(self.skillList,vo)
	end;
end;

function UnionbossModel:GetSkilllist()
	return self.skillList
end;

--结果
function UnionbossModel:SetActivityResult(state)
	self.activityResult = state;
end;

function UnionbossModel:GetActivityResult()
	--return false
	if self.activityResult == 0 then 
		return true
	else
		return false;
	end;
end;

--活动ing
function UnionbossModel:SetActState(bo)
	self.isActIng = bo;
end;

function UnionbossModel:GetActState()
	return self.isActIng
end;