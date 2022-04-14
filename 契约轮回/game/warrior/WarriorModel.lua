---
--- Created by  Administrator
--- DateTime: 2019/8/13 11:38
---
WarriorModel = WarriorModel or class("WarriorModel", BaseModel)
local WarriorModel = WarriorModel

function WarriorModel:ctor()
    WarriorModel.Instance = self
	self:Reset()
end

--- 初始化或重置
function WarriorModel:Reset()
	self.floor = 0 --当期层数
	self.score = 0 --当前积分
	self.kill = 0  --击杀人数
    self.actId = 10231
    self.creepState = 0
    if self.meleeCenter then
        self.meleeCenter:destroy();
    end
    self.meleeCenter = nil;
end

function WarriorModel:GetInstance()
    if WarriorModel.Instance == nil then
        WarriorModel()
    end
    return WarriorModel.Instance
end

function WarriorModel:IsWarriorScene(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_WARRIOR then
        return true
    end

    return false
end

function WarriorModel:EnterWarriorDungeon()
    local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel();
    local actId = self.actId
    if  ActivityModel:GetInstance():GetActivity(10232) then
        actId = 10232
    end

    local actTab = Config.db_activity[actId];
    if actTab then
        local sceneConfig = Config.db_scene[actTab.scene];
        if sceneConfig then
            local reqs = String2Table(sceneConfig.reqs);
            if reqs[1] == "level" then
                if roleLevel < reqs[2] then
                    Notify.ShowText("Level too low" .. reqs[2] .. ", unable to enter");
                    return ;
                end
            end
        else
            Notify.ShowText("Failed to find scene configuration, please check");
        end
        SceneControler:GetInstance():RequestSceneChange(actTab.scene, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, actId);
      --  SceneControler:GetInstance():RequestSceneChange(30391, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.actId);
    else
        Notify.ShowText("Failed to find this event, please check your configuration");
    end
end

function WarriorModel:GetRewardCfg(rank)
    local rewardCfg = Config.db_warrior_reward
    for i, v in pairs(rewardCfg) do
        if rank == v.rank_min and rank == v.rank_max then
            return v
        end
        if rank >= v.rank_min and rank<=v.rank_max then
            return v
        end
    end
    return nil
end