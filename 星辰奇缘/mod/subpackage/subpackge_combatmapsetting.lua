-- 分包处理 战斗背景图设置
-- @author hzf
-- @date 2016-10-09
SubpackageCombatMapSetting = SubpackageCombatMapSetting or BaseClass()

function SubpackageCombatMapSetting:__init()
    self.map_path = "textures/combat/combatmap/1.unity3d"
end

function SubpackageCombatMapSetting:__delete()
end

function SubpackageCombatMapSetting:Resources(resData)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return resData
    else
        local usePack = false
        local requestRes = {}
        if CSSubpackageManager.GetInstance():HaveSubpackageFileSingle(resData) then
            table.insert(requestRes, resData)
            usePack = true
        -- else
        --     table.insert(newResData, value)
        end

        if not usePack then
            return resData
        else
            CSSubpackageManager.GetInstance():AddOptimalFile(requestRes)
            return self.map_path
        end
    end
end
