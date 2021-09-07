-- 分包处理 NPC信息设置
-- @author huangyq
-- @date 20160612
SubpackageNpcSetting = SubpackageNpcSetting or BaseClass()

function SubpackageNpcSetting:__init()
    self.skinId = 30001
    self.modelId = 30001
    self.animationId = 3000101

    self.shouhu_skinid = 11002
    self.shouhu_modelId = 11002
    self.shouhu_animationId = 1100201
end

function SubpackageNpcSetting:__delete()
end

function SubpackageNpcSetting:Resources(resData, replaceonly)
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
            if resData.modelId > 11000 and resData.modelId < 11999 then
                resData.skinId = self.shouhu_skinid
                resData.modelId = self.shouhu_modelId
                resData.animationId = self.shouhu_animationId
            else
                resData.skinId = self.skinId
                resData.modelId = self.modelId
                resData.animationId = self.animationId
            end
            resData.animationData = BaseUtils.copytab(DataAnimation.data_npc_data[resData.animationId])
            resData.skinPath = string.format("prefabs/npc/skin/%s.unity3d", resData.skinId)
            resData.modelPath = string.format("prefabs/npc/model/%s.unity3d", resData.modelId)
            resData.ctrlPath = string.format("prefabs/npc/animation/%s.unity3d", resData.animationData.controller_id)
            if resData.animationData.controller_id == 99999 then
                resData.ctrlPath = SceneConstData.looksdefiner_playerctrlpath
            end
            resData.usePack = usePack
            return self:DefaultRes(resData, replaceonly)
        end
    end
end

function SubpackageNpcSetting:DefaultRes(resData, replaceonly)
    if replaceonly then
        return resData
    else
        local res = {
            {file = resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        }
        return res
    end
end
