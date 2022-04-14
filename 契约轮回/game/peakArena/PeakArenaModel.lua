---
--- Created by  Administrator
--- DateTime: 2019/7/31 16:19
---
PeakArenaModel = PeakArenaModel or class("PeakArenaModel", BaseModel)
local PeakArenaModel = PeakArenaModel

function PeakArenaModel:ctor()
    PeakArenaModel.Instance = self
	self:Reset()
end

--- 初始化或重置
function PeakArenaModel:Reset()
	self.join_reward = {}
	self.merit_reward = {} --功勋奖励
	self.isOpenBattlePanel = false
	self.daily_reward = -1   -- 0:没有，1：可领取，2：已领取
	self.merit = 0
	self.score = 0
	self.grade = 0
	self.lastgrade = 0
	self.mode = ""
	self.today_join = 0
	self.remain_buy = 0
	self.remain_join = 0
	self.isRedPoint = false
	self.isReqRedPoint = false --是否请求红点
end

function PeakArenaModel:GetInstance()
    if PeakArenaModel.Instance == nil then
        PeakArenaModel()
    end
    return PeakArenaModel.Instance
end

--判断是否是跨服
function PeakArenaModel:GetIsLocal()
	if self.mode == "local" then
		return true
	end
	
	return false
end

function PeakArenaModel:GetRedPoint()
	return self.isRedPoint
end

function PeakArenaModel:GetGrade()
	return self.grade
end

function PeakArenaModel:GetGradeTab(group)
	local tab = {}
	--local cfg = Config.db_combat1v1_grade
	local cfg = self:GetGradeCfg()
	for k, v in pairs(cfg) do
		local grade = v.grade
		if math.floor(grade/10)  == group then
			table.insert(tab,v)
		end
	end
	table.sort(tab,function(a,b)
		return a.grade < b.grade
	end)
	return tab
end

--获取最大可领取场数
function PeakArenaModel:GetMaxWin()
	--local cfg = Config.db_combat1v1_join_reward
	local cfg = self:GetJoinCfg()
	return cfg[#cfg].num
end


function PeakArenaModel:GetScoreForGrade()
	local curGrade = self:GetGrade()
	--local cfg = Config.db_combat1v1_grade[curGrade]
	local cfg = self:GetGradeCfg()
	return  cfg[curGrade].score
	
	
end



---是否JJC战斗
function PeakArenaModel:Is1v1Fight(sceneId)
	sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
	local config = Config.db_scene[sceneId]
	if not config then
		--   print2("不存在场景配置" .. tostring(sceneId));
		return false
	end
	if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_COMBAT1V1 then
		return true
	end
	
	return false
end


function PeakArenaModel:IsWinReward(num)
	for k, v in pairs(self.join_reward) do
		if k == num then
			return v
		end
	end
	return  0
end

function PeakArenaModel:GetMeritTab()
	local tab = {}
	--local cfg =	Config.db_combat1v1_merit_reward
	local cfg = self:GetMeritCfg()
	for k, v in pairs(self.merit_reward) do
		table.insert(tab,v)
	end
end

--0可以领取 2已经领取 1未达到
function PeakArenaModel:IsMeritReward(num)
	--self.merit_reward 
	--if self.merit >= num then
		--return 1 
	--else
		--return 0
	--end
	for k, v in pairs(self.merit_reward) do
		if v == num then
			return 2 
		end
	end
	if self.merit >= num then
		return 0 
	else
		return 1
	end
end

--阶数表
function PeakArenaModel:GetGradeCfg()
	local cfg = Config.db_combat1v1_cross_grade
	if self.mode == "local" then --本服
		cfg = Config.db_combat1v1_local_grade
	end
	return cfg
end

--购买次数表
function PeakArenaModel:GetLimitCfg()
	local cfg = Config.db_combat1v1_cross_limit
	if self.mode == "local" then --本服
		cfg = Config.db_combat1v1_local_limit
	end
	return cfg
end

function PeakArenaModel:GetMeritCfg()
	local cfg = Config.db_combat1v1_cross_merit_reward
	if self.mode == "local" then --本服
		cfg = Config.db_combat1v1_local_merit_reward
	end
	return cfg
end

function PeakArenaModel:GetJoinCfg()
	local cfg = Config.db_combat1v1_cross_join_reward
	if self.mode == "local" then --本服
		cfg = Config.db_combat1v1_local_join_reward
	end
	return cfg
end
function PeakArenaModel:GetGoalCfg()
	local cfg = Config.db_combat1v1_cross_goal_reward
	if self.mode == "local" then --本服
		cfg = Config.db_combat1v1_local_goal_reward
	end
	return cfg
end