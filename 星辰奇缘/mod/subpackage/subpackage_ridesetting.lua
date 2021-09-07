-- 分包处理 NPC信息设置
-- @author huangyq
-- @date 20160612
SubpackageRideSetting = SubpackageRideSetting or BaseClass()

function SubpackageRideSetting:__init()
    self.modelId = 80006
    self.skin_id = 80006
    self.animation_id = 80006
end

function SubpackageRideSetting:__delete()
end

function SubpackageRideSetting:Resources(resData, replaceonly)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return self:DefaultRes(resData, replaceonly)
    else
        local usePack = false
        local requestRes = {resData.skinPath, resData.ctrlPath, resData.ridePath}
        if CSSubpackageManager.GetInstance():HaveSubpackageFile(requestRes) then
            CSSubpackageManager.GetInstance():AddOptimalFile(requestRes)
            usePack = true
        else
            usePack = false
        end
        if not usePack then
            return self:DefaultRes(resData, replaceonly)
        else
            resData.modelId = self.modelId

            resData.ridePath = string.format(SceneConstData.looksdefiner_ridepath, self.modelId)
            resData.skinPath = string.format(SceneConstData.looksdefiner_rideSkinpath, self.skin_id)
            resData.ctrlPath = string.format(SceneConstData.looksdefiner_rideCtrpath, self.animation_id)
            resData.rideAnimationData = BaseUtils.copytab(DataAnimation.data_ride_data[self.animation_id])

            resData.effectData = nil
            resData.effect_id = nil

            return self:DefaultRes(resData, replaceonly)
        end
    end
end

function SubpackageRideSetting:DefaultRes(resData, replaceonly)
    if replaceonly then
        return resData
    else
        local res = {
            {file = resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.ridePath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        }
        if resData.rideEffectPath ~= nil then
             table.insert(res,{file = resData.rideEffectPath,type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        end
        return res
    end
end