-- 分包处理 角色信息设置
-- @author huangyq
-- @date 20160517
SubpackageRoleSetting = SubpackageRoleSetting or BaseClass()

function SubpackageRoleSetting:__init()
    -- 默认值
    self.defSkinData = {
        ["1_1"] = 5100101
        ,["1_0"] = 5100201
        ,["2_1"] = 5100301
        ,["2_0"] = 5100401
        ,["3_1"] = 5100501
        ,["3_0"] = 5100601
        ,["4_1"] = 5100701
        ,["4_0"] = 5100801
        ,["5_1"] = 5100901
        ,["5_0"] = 5101001
        ,["6_1"] = 5107101
        ,["6_0"] = 5107001
        ,["7_1"] = 5101301
        ,["7_0"] = 5101201
    }
    self.defModelData = {
        ["1_1"] = 51001
        ,["1_0"] = 51002
        ,["2_1"] = 51003
        ,["2_0"] = 51004
        ,["3_1"] = 51005
        ,["3_0"] = 51006
        ,["4_1"] = 51007
        ,["4_0"] = 51008
        ,["5_1"] = 51009
        ,["5_0"] = 51010
        ,["6_1"] = 51071
        ,["6_0"] = 51070
        ,["7_1"] = 51013
        ,["7_0"] = 51012
    }
    self.defHeadSkinData = {
        ["1_1"] = 5000101
        ,["1_0"] = 5000201
        ,["2_1"] = 5000301
        ,["2_0"] = 5000401
        ,["3_1"] = 5000501
        ,["3_0"] = 5000601
        ,["4_1"] = 5000701
        ,["4_0"] = 5000801
        ,["5_1"] = 5000901
        ,["5_0"] = 5001001
        ,["6_1"] = 5007101
        ,["6_0"] = 5007001
        ,["7_1"] = 5001301
        ,["7_0"] = 5001201
    }
    self.defHeadModelData = {
        ["1_1"] = 50001
        ,["1_0"] = 50002
        ,["2_1"] = 50003
        ,["2_0"] = 50004
        ,["3_1"] = 50005
        ,["3_0"] = 50006
        ,["4_1"] = 50007
        ,["4_0"] = 50008
        ,["5_1"] = 50009
        ,["5_0"] = 50010
        ,["6_1"] = 50071 
        ,["6_0"] = 50070 
        ,["7_1"] = 50013
        ,["7_0"] = 50012
    }
end

function SubpackageRoleSetting:__delete()
end

function SubpackageRoleSetting:Resources(resData, replaceonly)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return self:DefaultRes(resData, replaceonly)
    else
        local usePack = false
        local requestRes = {resData.bodyModelPath, resData.bodySkinPath, resData.headModelPath, resData.headSkinPath}
        if CSSubpackageManager.GetInstance():HaveSubpackageFile(requestRes) then
            CSSubpackageManager.GetInstance():AddOptimalFile(requestRes)
            usePack = true
        else
            usePack = false
        end
        if not usePack then
            return self:DefaultRes(resData, replaceonly)
        else
            local key = "" .. resData.classes .. "_" .. resData.sex
            local bodyModelId = self.defModelData[key]
            local bodySkinId = self.defSkinData[key]
            local headModelId = self.defHeadModelData[key]
            local headSkinId = self.defHeadSkinData[key]
            resData.bodyModelId = bodyModelId
            resData.headModelId = headModelId
            resData.bodyModelPath = string.format(SceneConstData.looksdefiner_playerbodypath, bodyModelId)
            resData.bodySkinPath = string.format(SceneConstData.looksdefiner_playerbody_skinpath, bodySkinId)
            resData.headModelPath = string.format(SceneConstData.looksdefiner_playerheadpath, headModelId)
            resData.headSkinPath = string.format(SceneConstData.looksdefiner_playerhead_skinpath, headSkinId)
            -- 不要头部动作了，只分男女
            -- local headData = DataFashion.data_base[resData.headModelId]
            -- resData.headAnimationData = DataAnimation.data_role_head_data[headData.animation_id]
            resData.headAnimationData = DataAnimation.data_role_head_data[resData.sex]
            resData.usePack = usePack
            return self:DefaultRes(resData, replaceonly)
        end
    end
end

function SubpackageRoleSetting:DefaultRes(resData, replaceonly)
    if replaceonly then
        return resData
    else
        local res = {
            {file = resData.bodyModelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.bodySkinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.headModelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
            ,{file = resData.headSkinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        }
        return res
    end
end



