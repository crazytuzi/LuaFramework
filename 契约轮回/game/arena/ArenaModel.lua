---
--- Created by  Administrator
--- DateTime: 2019/4/29 22:43
---
ArenaModel = ArenaModel or class("ArenaModel", BaseBagModel)
local ArenaModel = ArenaModel

function ArenaModel:ctor()
    ArenaModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function ArenaModel:Reset()
    self.isOpenBattlePanle = false
    self.isOpenArenaBagPanel = false
    self.isOpenArenaPanel = false --是开启了JJC界面
    self.maxPage = 10
    self.curRank = 0 --当前的排名
    self.sti_times = 0 --激励次数
    self.highestRank = 0
    self.highestRankFetch = {} --已领取最高排名奖励Id列表
    self.isRankReward = false --是否有每日奖励
    self.isBigGodReward = false  --是可以领大神奖励
    self.isHightReward = false -- 突破奖励
    self.isChallenge = false -- 是否有挑战次数
    self.isTopChallenge = false --是否有大神挑战次数
    self.curChallenger = nil
    self.red_dot_list = {}
    self.isShowWing = false
    self.isFirstOpenBigPanel = true
    self.bigRedPoint = false
	self.isTimes = false
    self.dayFirst = false
end

function ArenaModel:GetInstance()
    if ArenaModel.Instance == nil then
        ArenaModel()
    end
    return ArenaModel.Instance
end



function ArenaModel:GetVipTimes()
    --local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    --print2(roleData.viplv,"------1-----")
    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    local times = 0
    local cfg = Config.db_vip_rights[30]   --
    for i, v in pairs(cfg) do
        if i ==  "vip"..vipLv then
            times = v
            break
        end
    end
    return times
end

function ArenaModel:GetNextVipTimes()
  --  local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    local times = 0
    local cfg = Config.db_vip_rights[30]   --
        for i, v in pairs(cfg) do
            if i ==  "vip"..vipLv + 1 then
                times = v
                break
            end
        end
    return times
end

function ArenaModel:StartResult(data)
    lua_panelMgr:GetPanelOrCreate(ArenaEndPanel):Open(data)
end

--通过Id判断最高排名奖励是否已领取
function ArenaModel:isHighestById(id)
    for i, v in pairs(self.highestRankFetch) do
        if v == id then
            return true
        end
    end
    return false
end

---是否JJC战斗
function ArenaModel:IsArenaFight(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
     --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ARENA then
        return true
    end

    return false
end

function ArenaModel:GetPower(times,power)
    local cfg = Config.db_arena_stimulate[times]
    if not cfg then
        return
    end
    local num = cfg.stimulate / 10000
    return math.floor(power + power* num)
end



--0已领取 1 未上榜 2可领取
function ArenaModel:GetRewardState(data)
	if self.highestRank == 0 then --未上榜
		return 1
	end
	if self:isHighestById(data.id) then  --已领取
		return 0
	else
		if self.highestRank <= data.max then  --历史最高排名
			return 2
		else
			return  1	
		end
	end
end

function ArenaModel:GetRankCfg(rank)
    local cfg = Config.db_arena_rank
    for i, v in pairs(cfg) do
        if rank == v.max and rank == v.min then
           return v
        end
        if rank >= v.min and rank <= v.max then
            return v
        end
    end
    return nil
end

function ArenaModel:GetRankHonerReward(rank)
    local cfg  = self:GetRankCfg(rank)
    local reward = String2Table(cfg.reward)
    for i = 1, #reward do
        if reward[i][1] == enum.ITEM.ITEM_HONOR then
            return reward[i][2]
        end
    end
    return 0

end

