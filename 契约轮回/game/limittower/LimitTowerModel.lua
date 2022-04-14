---
--- Created by  Administrator
--- DateTime: 2019/10/31 14:26
---
LimitTowerModel = LimitTowerModel or class("LimitTowerModel", BaseModel)
local LimitTowerModel = LimitTowerModel

function LimitTowerModel:ctor()
    LimitTowerModel.Instance = self
end

--- 初始化或重置
function LimitTowerModel:Reset()
    self.curFloor = 1
	self.actID = 170100
	self.is_first = true
end

function LimitTowerModel:GetInstance()
    if LimitTowerModel.Instance == nil then
        LimitTowerModel()
    end
    return LimitTowerModel.Instance
end

--0已通关  1 当前层数  2 未通关
function LimitTowerModel:GetCrossState(floor)
    local info =  DungeonModel:GetInstance().dungeon_info_list[enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER].info
    local curFloor = info.cur_floor
    if floor > curFloor then
        return 2
    end
    if floor < curFloor then
        return 0
    end
    return 1
end

function LimitTowerModel:IsLimitTower(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER then
        return true
    end

    return false
end

function LimitTowerModel:UpdateMainRed()
	local floor = self.curFloor
	local nedpower
	local roleInfo = RoleInfoModel.GetInstance():GetMainRoleData()
	local cfg = Config.db_yunying_dunge_limit_tower
	if self.actID then
		for i = 1, #cfg do
			if cfg[i].floor == floor and cfg[i].act_id == self.actID then
				nedpower = cfg[i].power
				break
			end 
		end
		if (#cfg / 2) < floor then
			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "limitTower", false)
		else
			local is_show = roleInfo.power >= nedpower
			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "limitTower", is_show)
		end

	end
end