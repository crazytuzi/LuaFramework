-- 分包处理 翅膀信息设置
-- @author huangyq
-- @date 20160612
SubpackageWingSetting = SubpackageWingSetting or BaseClass()

function SubpackageWingSetting:__init()
    self.wingId = 20000
end

function SubpackageWingSetting:__delete()
end

function SubpackageWingSetting:Resources(resData)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return self:DefaultRes(resData)
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
            return self:DefaultRes(resData)
        else
            resData.wingData = DataWing.data_base[self.wingId]
	        resData.animationData = DataAnimation.data_wing_data[resData.wingData.act_id]
            resData.skinPath = string.format("prefabs/wing/skin/%s.unity3d", resData.wingData.map_id)
            resData.modelPath = string.format("prefabs/wing/model/%s.unity3d", resData.wingData.model_id)
            resData.ctrlPath = string.format("prefabs/wing/animation/%s.unity3d", resData.animationData.controller_id)
            return self:DefaultRes(resData)
        end
    end
end

function SubpackageWingSetting:DefaultRes(resData)
    local res = {
        {file = resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = resData.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    return res
end

