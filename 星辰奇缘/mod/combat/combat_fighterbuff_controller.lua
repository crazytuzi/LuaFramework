-- buff信息

FighterBuffController = FighterBuffController or BaseClass()

function FighterBuffController:__init(fighterCtrl)
    self.combatMgr = CombatManager.Instance
    self.mainPanel = self.combatMgr.controller.mainPanel
    self.assetWrapper = self.mainPanel.combatMgr.assetWrapper
    self.minorassetWrapper = nil
    self.mixPanel = self.mainPanel.mixPanel
    self.EffectOffset = self.combatMgr.controller.combatCamera.transform.forward * -1

    self.fighterCtrl = fighterCtrl
    self.fighterData = nil
    self.parentPanel = nil
    self.hpBarPanel = nil
    self.basePosition = nil

    self.baseBuffPanel = nil
    self.buffPosList = {}
    self.buffUiDataList = {}    -- list
    self.buffPanelList = {}     -- list
    self.buffEffectDict = {}    -- dict
end

function FighterBuffController:InitBuffUI()
    self.fighterData = self.fighterCtrl.fighterData
    self.hpBarPanel = self.fighterCtrl.hpBarPanel
    self.basePosition = self.hpBarPanel.transform.localPosition
    -- self.parentPanel = CombatManager.Instance.objPool:Pop("BuffPanel")
    self.parentPanel = nil
    if self.parentPanel == nil then
        self.parentPanel = GameObject.Instantiate(self.mixPanel.buffPanel)
    else
        local num = self.parentPanel.transform.childCount
        if num > 4 then
            for i = 4, num-1 do
                GameObject.DestroyImmediate(self.parentPanel.transform:GetChild(4).gameObject)
            end
        end
    end
    -- table.insert(self.combatMgr.controller.uiResCacheList, {id = "BuffPanel", go = self.parentPanel})
    self.parentPanel.transform:SetParent(self.hpBarPanel.transform)
    self.parentPanel.name = "BuffPanel_" .. self.fighterData.id
    self.parentPanel.transform.localScale = Vector3(1, 1, 1)
    self.parentPanel.transform.localPosition = Vector3(10, -12, 0)
    self.parentPanel:SetActive(true)

    self.baseBuffPanel = self.parentPanel.transform:FindChild("Buff1").gameObject
    self.arrowImage = self.parentPanel.transform:FindChild("Arrow").gameObject
    self.arrowImage:SetActive(false)

    table.insert(self.buffPosList, self.parentPanel.transform:FindChild("Buff1").localPosition)
    table.insert(self.buffPosList, self.parentPanel.transform:FindChild("Buff2").localPosition)
    table.insert(self.buffPosList, self.parentPanel.transform:FindChild("Buff3").localPosition)
end

function FighterBuffController:InsertUpdateBuff(uiData, assetwrapper)
    if self.fighterCtrl.IsDisappear or (uiData.buffId == 90213 and (self.fighterCtrl.fighterData.group ~= self.combatMgr.controller.selfData.group or self.combatMgr.isWatching)) then
        -- 消失的单位不再更新buff
        return
    end
    if uiData.buffId == nil then
        BaseUtils.dump(uiData)
    end

    if uiData.special == 1 then
        local data = self:FindBuffUiData(uiData.buffId)
        if data == nil then
            table.insert(self.buffUiDataList, uiData)
        end
    else
        local data = self:FindBuffUiData(uiData.buffId)
        local buffData = DataSkillBuff.data_skill_buff[uiData.buffId]
        if buffData == nil then
            Log.Error(string.format("DataSkillBuff.data_skill_buff[%s] Not Find", tostring(uiData.buffId)))
        else
            if buffData.shake == 1 then
                self.fighterCtrl:DoShake(true)
            end
        end
        local show = DataSkillBuff.data_skill_buff[uiData.buffId].not_show == 0
        if data == nil and show then
            table.insert(self.buffUiDataList, uiData)
        elseif show then
            data:Clone(uiData)
        end
        self.minorassetWrapper = assetwrapper
    end

    self:ShowBuffPanel()
end

function FighterBuffController:DeleteBuff(buffId)
    -- print("清除buff，ID: "..tostring(buffId))
        local index = 0
        local alphanum = 0
        local scalenum = 0
        local shakenum = 0
        for key, data in ipairs(self.buffUiDataList) do
            if data.special == nil then
                local skillBuffdata = self.combatMgr:GetCombatBuffData(data.buffId)
                if skillBuffdata.alpha_val < 100 then
                    alphanum = alphanum + 1
                end
                if skillBuffdata.scale_val ~= 100 then
                    scalenum = scalenum + 1
                end
                if skillBuffdata.shake == 1 then
                    shakenum = shakenum + 1
                end
            end
        end
        for key, data in ipairs(self.buffUiDataList) do
            if data.special == nil and data.buffId == buffId then
                index = key
                local skillBuffdata = self.combatMgr:GetCombatBuffData(buffId)
                if skillBuffdata.alpha_val < 100 and alphanum == 1 then
                    self.fighterCtrl:SetAlpha(1)
                end
                if skillBuffdata.scale_val ~= 100 and scalenum == 1 then
                    self.fighterCtrl:SetScale(1)
                end
                if skillBuffdata.shake == 1 and shakenum == 1 then
                    self.fighterCtrl:DoShake(false)
                end
            end
        end
        if index ~= 0 then
            table.remove(self.buffUiDataList, index)
        end

    self:ShowBuffPanel()
end

function FighterBuffController:ShowBuffPanel()
    if BaseUtils.isnull(self.arrowImage) then
        return
    end
    local oldList = {}
    -- BaseUtils.dump(self.buffPanelList,"BUFF小图标23333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333")
    for _, buffPanel in ipairs(self.buffPanelList) do
        table.insert(oldList, buffPanel)
    end

    self.buffPanelList = {}


    local myIndex = 1
    local count = #self.buffUiDataList
    if count > 0 then
        for i = 1, count do
            local skillBuffdata = self.combatMgr:GetCombatBuffData(self.buffUiDataList[i].buffId)
            if (myIndex <= 3 and skillBuffdata == nil) or (myIndex <= 3 and skillBuffdata ~= nil and skillBuffdata.isActive == 0) then
                local buffPanel = self:CreateBuffPanel(self.buffUiDataList[i])
                if buffPanel ~= nil then
                    buffPanel.transform:SetParent(self.parentPanel.transform)
                    buffPanel.transform.localScale = Vector3(1, 1, 1)
                    buffPanel.transform.localPosition = self.buffPosList[myIndex]
                    table.insert(self.buffPanelList, buffPanel)
                end
                myIndex = myIndex + 1
            end
        end
    end
    if count > 3 then
        self.arrowImage:SetActive(true)
    else
        self.arrowImage:SetActive(false)
    end

    for _, old in ipairs(oldList) do
        GameObject.DestroyImmediate(old)
    end

    if #self.buffUiDataList > 0 then
        -- local bp = self.basePosition
        -- self.hpBarPanel.transform.localPosition = Vector3(bp.x, bp.y + 30, bp.z)
        self.fighterCtrl.hpBarPanelBuffOffset = 20
    else
        self.fighterCtrl.hpBarPanelBuffOffset = 0
        -- self.hpBarPanel.transform.localPosition = self.basePosition
    end
    self.fighterCtrl:SetHpBarPanelPosition()
    self:RefreshEffect()
end

function FighterBuffController:CreateBuffPanel(uiData)
    if BaseUtils.isnull(self.baseBuffPanel) then
        return nil
    end
    local buffPanel = GameObject.Instantiate(self.baseBuffPanel)
    if uiData.special == 1 then
        -- if not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark then
            local buffData = DataBuff.data_list[uiData.buffId]
            if buffData == nil then
                if uiData.buffId ~= 0 then
                    Log.Error("[变身buff] 缺少buff配置信息:[buffId:" .. uiData.buffId .. "]")
                end
            else
                buffPanel.name = "Buff_" .. uiData.buffId
                local sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffData.icon))
                if sprite == nil then
                    Log.Error("[变身buff]缺少buff图标资源:[buffId:" .. uiData.buffId .. "][IconResId:" .. buffData.icon .. "]")
                    sprite = self.assetWrapper:GetSprite(AssetConfig.bufficon, "10001")
                end
                if sprite ~= nil then
                    buffPanel.transform:FindChild("Icon"):GetComponent(Image).sprite = sprite
                end
            end
        -- end
    else
            local skillBuffdata = self.combatMgr:GetCombatBuffData(uiData.buffId)
            if skillBuffdata.alpha_val < 100 then
                self.fighterCtrl:SetAlpha(skillBuffdata.alpha_val/100)
            end
            if skillBuffdata.scale_val ~= 100 then
                self.fighterCtrl:SetScale(skillBuffdata.scale_val/100)
            end
            if skillBuffdata == nil then
                Log.Error("缺少buff配置信息:[buffId:" .. uiData.buffId .. "]")
            end
            buffPanel.name = "Buff_" .. uiData.buffId
            local sprite = self.assetWrapper:GetSprite(AssetConfig.bufficon, tostring(skillBuffdata.iconResId))
            if sprite == nil then
                Log.Error("缺少buff图标资源:[buffId:" .. uiData.buffId .. "][IconResId:" .. skillBuffdata.iconResId .. "]")
                sprite = self.assetWrapper:GetSprite(AssetConfig.bufficon, "10001")
            end
            if sprite ~= nil then
                buffPanel.transform:FindChild("Icon"):GetComponent(Image).sprite = sprite
            end
            -- for i = 1, uiData.layer do
            --     buffPanel.transform:FindChild("Layer" .. i).gameObject:SetActive(true)
            -- endddd
    end
    buffPanel:SetActive(true)
    return buffPanel
end

function FighterBuffController:RefreshEffect()
    local delList = {}  -- GameObject
    local addList = {}  -- uiData
    local containList = {}  -- key
    for _, data in ipairs(self.buffUiDataList) do
        local buffId = data.buffId
        local layer = data.layer
        local key = CombatUtil.Key(buffId, layer)
        if not table.containKey(self.buffEffectDict, key) then
            table.insert(addList, data)
        else
            table.insert(containList, key)
        end
    end
    for key, _ in pairs(self.buffEffectDict) do
        if not table.containValue(containList, key) then
            table.insert(delList, key)
        end
    end

    for _, key in ipairs(delList) do
        local effectlist = self.buffEffectDict[key].list
        for _, effect in ipairs(effectlist) do
            self:DoTransparentEffect(effect, false)
            GameObject.DestroyImmediate(effect)
        end
        self.buffEffectDict[key] = nil
    end

    for _, uiData in ipairs(addList) do
        local key = CombatUtil.Key(uiData.buffId, uiData.layer)
        if uiData.buffId == 90213 and self.fighterCtrl.fighterData.group ~= self.combatMgr.controller.selfData.group then
            print("对面鬼魂术跳过")
        elseif uiData.special == nil then
            self:CreateEffect(uiData.buffId, uiData.layer)
        end
    end
end

function FighterBuffController:CreateEffect(buffId, layer)
    local localasswrapper = nil
    local buffData = self.combatMgr:GetCombatBuffData(buffId)
    local effectIds = {}
    if layer == 1 then
        effectIds = buffData.effect_ids_layer1
    elseif layer == 2 then
        effectIds = buffData.effect_ids_layer2
    elseif layer == 3 then
        effectIds = buffData.effect_ids_layer3
    end
    if #effectIds > 0 then
        local paths = {}
        for _, effectId in ipairs(effectIds) do
            local  effectData = self.combatMgr:GetEffectObject(effectId)
            if effectData ~= nil then
                local effectPath = "prefabs/effect/" .. effectData.res_id .. ".unity3d"
                table.insert(paths, {file = effectPath, type = AssetType.Main, callback = nil, effectId = effectData.id, data = effectData})
            else
                Log.Error("[战斗buff]缺少特效配置信息effectId:" .. effectId)
            end
        end
        -- local majorassetwrapper = self.mainPanel.controller.brocastCtx.majorCtx.assetwrapper
        local callback = function()
            for _, pathInfo in ipairs(paths) do
                local effectPrefab = nil
                if self.minorassetWrapper ~= nil then
                    effectPrefab = self.minorassetWrapper:GetMainAsset(pathInfo.file)
                else
                    effectPrefab = localasswrapper:GetMainAsset(pathInfo.file)
                end
                if effectPrefab ~= nil then
                    local effect = GameObject.Instantiate(effectPrefab)
                    effect.name = "BuffEffect_" .. pathInfo.effectId

                    local key = CombatUtil.Key(buffId, layer)
                    local effectlist = nil
                    if self.buffEffectDict[key] == nil then
                        effectlist = {}
                        self.buffEffectDict[key] = {list = effectlist, buffId = buffId, layer = layer, data = pathInfo.data}
                    else
                        effectlist = self.buffEffectDict[key].list
                    end
                    -- self:DoTransparentEffect(effect, true)
                    -- table.insert(effectlist, effect)
                    -- self:BindEffect(pathInfo.data, self.fighterCtrl.tpose, effect, effectlist)
                    local find = false
                    for _, effectData in ipairs(effectlist) do
                        if effectData.name == effect.name then
                            find = true
                        end
                    end
                    if not find then
                        self:DoTransparentEffect(effect, true)
                        table.insert(effectlist, effect)
                        self:BindEffect(pathInfo.data, self.fighterCtrl.tpose, effect, effectlist)
                    else
                        GameObject.DestroyImmediate(effect)
                    end
                    localasswrapper:DeleteMe()
                end
            end
        end
        if localasswrapper == nil then
            localasswrapper = AssetBatchWrapper.New()
        else
            localasswrapper:DeleteMe()
            localasswrapper = nil
            localasswrapper = AssetBatchWrapper.New()
            -- Log.Error("[Error]assetWrapper不可以重复使用")
        end
        localasswrapper:LoadAssetBundle(paths, callback)
        -- batch_asset_loader.New(ctx, paths, callback)
    end
end

function FighterBuffController:BindEffect(effectData, tpose, effect, effectlist)
    -- local key = CombatUtil.Key(buffId, layer)
    -- local effectlist = nil
    -- if self.buffEffectDict[key] == nil then
    --     effectlist = {}
    --     self.buffEffectDict[key] = {list = effectlist, buffId = buffId, layer = layer, data = effectData}
    -- else
    --     effectlist = self.buffEffectDict[key].list
    -- end
    -- table.insert(effectlist, effect)
    if BaseUtils.isnull(effect) then
        return
    end
    if effectData.mounter == EffectDataMounter.Origin then
        if BaseUtils.isnull(effect) or BaseUtils.isnull(tpose) then
            -- 可能切换战斗时特效或模型已经被干掉
            return
        end
        effect.transform:SetParent(tpose.transform)
        self:EffectSetting(effect, effectData)
    elseif effectData.mounter == EffectDataMounter.TopOrigin then
        effect.transform:SetParent(tpose.transform.parent)
        self:EffectSetting(effect, effectData)
        effect.transform.localPosition = Vector3(0, 0.75, 0)
    elseif effectData.mounter == EffectDataMounter.Weapon then
        local lmounter = BaseUtils.GetChildPath(tpose, "Bip_L_Weapon")
        local rmounter = BaseUtils.GetChildPath(tpose, "Bip_R_Weapon")
        if lmounter ~= "" or rmounter ~= "" then
            local clone = false
            if lmounter ~= "" then
                local lm = tpose.transform:Find(lmounter)
                if lm ~= nil then
                    effect.transform:SetParent(lm)
                    self:EffectSetting(effect, effectData)
                    clone = true
                end
            end
            if rmounter ~= "" then
                local rm = tpose.transform:Find(rmounter)
                if rm ~= nil then
                    if clone  then
                        local reffect = nil
                        if #effectlist > 1 then
                            reffect = effectlist[2]
                        else
                            reffect = GameObject.Instantiate(effect)
                            table.insert(effectlist, reffect)
                        end
                        reffect.transform:SetParent(rm)
                        self:EffectSetting(reffect, effectData)
                    else
                        effect.transform:SetParent(rm)
                        self:EffectSetting(effect, effectData)
                    end
                end
            end
        else
            effect.transform:SetParent(tpose.transform)
            self:EffectSetting(effect, effectData)
        end
    else
        local mounterPath = nil
        if effectData.mounter_str ~= "" then
            mounterPath = BaseUtils.GetChildPath(tpose, effectData.mounter_str)
        elseif effectData.mounter == EffectDataMounter.Wing then
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        elseif effectData.mounter == EffectDataMounter.WingL1 then
            -- 看以后需求改
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        else
            mounterPath = BaseUtils.GetChildPath(tpose, "bp_wing")
        end
        if mounterPath ~= nil then
            local mounter = tpose.transform:Find(mounterPath)
            if mounter ~= nil then
                effect.transform:SetParent(mounter)
                self:EffectSetting(effect, effectData)
            end
        end
    end
end

function FighterBuffController:EffectSetting(effect, effectData)
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, 0)
    -- effect.transform.position = effect.transform.position + self.EffectOffset/15
    effect.transform.localRotation = Quaternion.identity
    if effectData.overlay ~= 1 then
        Utils.ChangeLayersRecursively(effect.transform, "CombatModel")
    else
        Utils.ChangeLayersRecursively(effect.transform, "Ignore Raycast")
    end
    effect:SetActive(true)
end

function FighterBuffController:FindBuffUiData(buffId)
    for _, data in ipairs(self.buffUiDataList) do
        if data.buffId == buffId then
            return data
        end
    end
    return nil
end

-- 变身 buff特效转移
function FighterBuffController:TransformerForEffect(tpose)
    for _, buffData in pairs(self.buffEffectDict) do
        local effectlist = buffData.list
        local buffId = buffData.buffId
        local layer = buffData.layer
        local effectData = buffData.data
        for _, effect in ipairs(effectlist) do
            local parent_name = effect.transform.parent.gameObject.name
            local mounter = BaseUtils.GetChildPath(tpose, parent_name)
            if mounter ~= "" then
                effect.transform:SetParent(tpose.transform:Find(mounter))
            else
                effect.transform:SetParent(tpose.transform)
            end
            -- self:BindEffect(effectData, tpose, effect, effectlist)
        end
    end
end

function FighterBuffController:HideBuffPanel()
    for _, buffPanel in ipairs(self.buffPanelList) do
        if not BaseUtils.is_null(buffPanel) then
            buffPanel:SetActive(false)
        end
    end
    self.arrowImage:SetActive(false)
end

function FighterBuffController:DoTransparentEffect(effect, isHide)
    if BaseUtils.isnull(effect) then
        return
    end
    local effectName = "BuffEfffect_100300"
    if effectName == effect.name then
        if isHide then
            self.fighterCtrl:SetAlpha(0.5)
        else
            self.fighterCtrl:SetAlpha(1)
        end
    end
end

-- 对所以buff进行同步更新，不存在的清除
function FighterBuffController:BuffDataSync(bufflist)
    for _, data in ipairs(self.buffUiDataList) do
        local has = false
        for _, newdata in ipairs(bufflist) do
            if newdata.id == data.buffId then
                has = true
                break
            end
        end
        if not has then
            self:DeleteBuff(data.buffId)
        end
    end
    -- BaseUtils.dump(self.buffUiDataList, "当前的")
    -- BaseUtils.dump(bufflist, "最新的")
end

function FighterBuffController:CheckShake()
    for _, data in ipairs(self.buffUiDataList) do
        if data.special == 1 then

        elseif DataSkillBuff.data_skill_buff[data.buffId].shake == 1 then
            self.fighterCtrl:DoShake(true)
            return
        end
    end
end
---------------------------------------------------
-- BuffUiData
---------------------------------------------------
BuffUiData = BuffUiData or BaseClass()
function BuffUiData:__init()
    self.buffId = 0
    self.layer = 0
    self.duration = 0
    self.durationLeft = 0
    self.tipsArgeList = {}
    self.special = nil
end
function BuffUiData:ConvertByPlayData(playData)
    self.buffId = playData.buff_id
    self.layer = playData.layer
    self.duration = playData.duration
    self.durationLeft = playData.duration_left
    self.tipsArgeList = playData.tips_args
    self.special = playData.special
end
function BuffUiData:ConvertByPlaySpData(playData)
    self.buffId = playData.id
    if playData.id == nil then
        self.buffId = playData.buff_id
    end
    self.layer = playData.layer
    self.duration = playData.duration
    self.durationLeft = playData.duration_left
    self.special = playData.special
end
function BuffUiData:Clone(uiData)
    self.buffId = uiData.buffId
    self.layer = uiData.layer
    self.duration = uiData.duration
    self.durationLeft = uiData.durationLeft
    self.tipsArgeList = uiData.tipsArgeList
    self.special = uiData.special
end
