---
--- Created by  Administrator
--- DateTime: 2019/9/24 11:06
---
StigmasModel = StigmasModel or class("StigmasModel", BaseModel)
local StigmasModel = StigmasModel

function StigmasModel:ctor()
    StigmasModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function StigmasModel:Reset()
    self.slots = {}  --部署的神灵
    self.options = {} --可以布置的神灵
    self.dungenInfo = {}
    self.dungenStype = 0
    self.dungenId = 0
    self.curSlot = 0
    self.redGodTab = {}
    self.rTimes = 0
end

function StigmasModel:GetInstance()
    if StigmasModel.Instance == nil then
        StigmasModel()
    end
    return StigmasModel.Instance
end

--获取当前位置布置的神灵
function StigmasModel:GetSlotByIndex(index)
    for i, v in pairs(self.slots) do
        if index == i then
            return v
        end
    end
    return 0
end

function StigmasModel:IsOption(godId)
    for i, id in pairs(self.options) do
        if godId == id then
            return true
        end
    end
    return false
end

function StigmasModel:GetGodtimes(godId)
    local nus = 0
    for i, v in pairs(self.slots) do
        if v == godId then
            nus = nus + 1
        end
    end
    return nus
end

function StigmasModel:CheckHaveBetterGodByPos(pos)
    local isBatter = false
   -- local godTab = {}
    self.redGodTab[pos] = {}
    local curGodId = self.slots[pos] or 0  --当前位置的神灵ID
        for i, id in pairs(self.options) do  --可以布置的神灵列表
            self.redGodTab[pos][id] = false
            local cfg = Config.db_dunge_soul_morph[id]
            local rTime = cfg.num - self:GetGodtimes(id)
            if rTime > 0 then --剩余次数大于0
                if curGodId == 0 then
                    --return true
                    isBatter = true
                    self.redGodTab[pos][id] = true
                else
                    local curColor = Config.db_god_morph[curGodId].color
                    local color = Config.db_god_morph[id].color
                    if color > curColor then
                      --  return true
                        isBatter = true
                        --table.insert(godTab,id)
                        self.redGodTab[pos][id] = true
                    end
                end
            end
        end
    GlobalEvent:Brocast(StigmasEvent.UpdateRedPoint,isBatter)
    return isBatter
end

--是否有未上阵红点
function StigmasModel:IsStartRed()
    for i, tab in pairs(self.redGodTab) do
        for j, isRed in pairs(tab) do
            if isRed == true then
                return true
            end
        end
    end
    return false
end


----检查是否有更好的神灵未上阵
--function StigmasModel:CheckHaveBetterGod()
--   -- local  isBatter = false
--    local cfg = Config.db_dunge_soul_morph
--    for i, id in pairs(self.options) do  --可布置的神灵
--        local itemCfg = cfg[id]
--        local times = itemCfg.num
--        local rTime =  times - self:GetGodtimes()
--        if rTime > 0 then  --剩余次数>0
--            if self:CheckHaveBetterGodById() then
--                return true
--            end
--        end
--    end
--    return false
--
--end
----godId 神灵id
function StigmasModel:CheckHaveBetterGodById(godId)
    local paramCfg  = Config.db_god_morph[godId]
    for i, id in pairs(self.slots) do --已经布置的神灵
        local cfg = Config.db_god_morph[id]
        if paramCfg.color > cfg.color then
            return true
        end
    end
    return false
end
function StigmasModel:SetTimes(num)
    self.rTimes = num
   -- GlobalEvent:Brocast(MainEvent.ChangeRedDot, "role_info", num > 0)
end

--是否在圣痕秘境地图
function StigmasModel:IsStigmasMap(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        --   print2("不存在场景配置" .. tostring(sceneId));
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL then
        return true
    end

    return false
end

