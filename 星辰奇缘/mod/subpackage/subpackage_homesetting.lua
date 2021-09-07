-- 分包处理 NPC信息设置
-- @author huangyq
-- @date 20160612
SubpackageHomeSetting = SubpackageHomeSetting or BaseClass()

function SubpackageHomeSetting:__init()
    self.skinId = 76008
    self.modelId = 76008
end

function SubpackageHomeSetting:__delete()
end

function SubpackageHomeSetting:Resources(resData, replaceonly)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return self:DefaultRes(resData, replaceonly)
    else
        local usePack = false
        local requestRes = {resData.skinPath, resData.ctrlPath, resData.modelPath}
        if CSSubpackageManager.GetInstance():HaveSubpackageFile(requestRes) then
            CSSubpackageManager.GetInstance():AddOptimalFile(requestRes)
            usePack = true
        else
            usePack = false
        end
        if not usePack then
            return self:DefaultRes(resData, replaceonly)
        else
            resData.skinId = self.skinId
            resData.modelId = self.modelId
            resData.ctrlPath = nil
            resData.animationData = nil
            resData.skinPath = string.format("prefabs/npc/skin/%s.unity3d", self.skinId)
            resData.modelPath = string.format("prefabs/npc/model/%s.unity3d", self.modelId)
            return self:DefaultRes(resData, replaceonly)
        end
    end
end

function SubpackageHomeSetting:DefaultRes(resData, replaceonly)
    if replaceonly then
        return resData
    else
        local res = {
            {file = resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        }
        if resData.ctrlPath ~= nil then
            table.insert(res, {file = resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end
        return res
    end
end
