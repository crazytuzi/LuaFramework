-- 分包处理 战斗特效
-- 只处理了战斗特效，其中战斗特效中的一些特殊特效不可以用替代资源
-- 逃跑特殊、反射特殊、击飞特效不可以用替代资源
-- @author huangyq
-- @date 2016-10-11
SubpackageEffectSetting = SubpackageEffectSetting or BaseClass()

function SubpackageEffectSetting:__init()
    self.staticEffectId = 11021
    self.staticEffectPath = "prefabs/effect/" .. self.staticEffectId .. ".unity3d"
    self.flyEffectId = 12000
    self.flyEffectPath = "prefabs/effect/" .. self.flyEffectId .. ".unity3d"
end

function SubpackageEffectSetting:__delete()
end

function SubpackageEffectSetting:Resources(peffectId)
    local filePath = "prefabs/effect/" .. peffectId .. ".unity3d"
    if not SubpackageManager.Instance.IsSubPackage then
        return filePath
    end
    local effectId = self.staticEffectId
    local effectPath = self.staticEffectPath
    -- if effectType == EffectType.FlyEffect then
    --     effectId = self.flyEffectId
    --     effectPath = self.flyEffectPath
    -- end
    local requestList = {filePath}
    if CSSubpackageManager.GetInstance():HaveSubpackageFile(requestList) then
        CSSubpackageManager.GetInstance():AddOptimalFile(requestList)
        return effectPath
    else
        return filePath
    end
end

