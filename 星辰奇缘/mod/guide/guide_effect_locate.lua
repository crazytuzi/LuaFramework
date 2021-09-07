-- ------------------------------
-- 引导-特效显示
-- hosr
-- ------------------------------
GuideEffect = GuideEffect or BaseClass()

function GuideEffect:__init()
    self.effectObj = nil
    self.gameObject = nil
    self.offestV2 = nil
    self.pathFight = "prefabs/effect/20103.unity3d"
    self.pathQuest = "prefabs/effect/20107.unity3d"
    self.pathSkill = "prefabs/effect/20104.unity3d"
    self.pathGuard = "prefabs/effect/20105.unity3d"
    self.pathAuto = "prefabs/effect/20106.unity3d"
    self.showEffect = "prefabs/effect/20102.unity3d"

    self.effectFight = nil
    self.effectQuest = nil
    self.effectSkill = nil
    self.effectGuard = nil
    self.effectAuto = nil
    self.effectShow = nil

    self.isHide = false
end

function GuideEffect:LoadRes()
    self.assetWrapper = AssetBatchWrapper.New()
    local func = function()
        self.effectFight = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathFight))
        self.effectFight.name = "GuideFightEffect"
        self.effectFight.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectFight.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectFight.transform, "UI")
        self.effectFight:SetActive(false)

        self.effectQuest = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathQuest))
        self.effectQuest.name = "GuideQuestEffect"
        self.effectQuest.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectQuest.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectQuest.transform, "UI")
        self.effectQuest:SetActive(false)

        self.effectSkill = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathSkill))
        self.effectSkill.name = "GuideSkillEffect"
        self.effectSkill.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectSkill.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectSkill.transform, "UI")
        self.effectSkill:SetActive(false)

        self.effectGuard = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathGuard))
        self.effectGuard.name = "GuideGuardEffect"
        self.effectGuard.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectGuard.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectGuard.transform, "UI")
        self.effectGuard:SetActive(false)

        self.effectAuto = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathAuto))
        self.effectAuto.name = "GuideAutoEffect"
        self.effectAuto.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectAuto.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectAuto.transform, "UI")
        self.effectAuto:SetActive(false)

        self.effectShow = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.showEffect))
        self.effectShow.name = "GuideShowEffect"
        self.effectShow.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectShow.transform.localScale = Vector3.one
        Utils.ChangeLayersRecursively(self.effectShow.transform, "UI")
        self.effectShow:SetActive(false)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil

        self:Show(self.gameObject, self.offestV2, self.id, self.tab)
    end

    self.resList = {
        {file = self.pathFight, type = AssetType.Main},
        {file = self.pathQuest, type = AssetType.Main},
        {file = self.pathSkill, type = AssetType.Main},
        {file = self.pathGuard, type = AssetType.Main},
        {file = self.pathAuto, type = AssetType.Main},
        {file = self.showEffect, type = AssetType.Main},
    }
    self.assetWrapper:LoadAssetBundle(self.resList, func)
end

function GuideEffect:Show(gameObject, vec2, id, tab)
    if gameObject == nil or gameObject:Equals(NULL) then
        return
    end

    self.isHide = false

    self.gameObject = gameObject
    self.offestV2 = vec2
    self.id = id
    self.tab = tab
    self.scale = 1

    if self.id == 1 then
        -- 功能按钮
        self.effectObj = self.effectFight
    elseif self.id == 2 then
        -- 关闭按钮
        self.effectObj = self.effectFight
    elseif self.id == 3 then
        -- 任务
        self.effectObj = self.effectQuest
    elseif self.id == 4 then
        self.effectObj = self.effectGuard
    elseif self.id == WindowConfig.WinID.guardian then
        self.effectObj = self.effectGuard
    elseif self.id == WindowConfig.WinID.skill 
        or self.id == WindowConfig.WinID.pet 
        or self.id == WindowConfig.WinID.biblemain 
        or self.id == WindowConfig.WinID.backpack then
        self.effectObj = self.effectSkill
    else
        self.effectObj = self.effectFight
    end

    if self.effectObj == nil or self.effectObj:Equals(NULL) then
        self:LoadRes()
        return
    end

    if self.offestV2 == nil then
        self.offestV2 = Vector2.zero
    end
    self.effectObj.transform:SetParent(gameObject.transform)
    self.effectObj.transform.localScale = Vector3.one * self.scale
    self.effectObj.transform.localPosition = Vector3(self.offestV2.x, self.offestV2.y, -400)
    Utils.ChangeLayersRecursively(self.effectObj.transform, "UI")
    self.effectObj.transform:SetAsLastSibling()

    if self.id == 1 then
        if MainUIManager.Instance.isMainUIShow then
            self:FlyToTarget(gameObject)
        else
            self:FlyEnd()
        end
    else
        self.effectObj:SetActive(true)
        if self.tab ~= nil then
            if MainUIManager.Instance.isMainUIShow then
                TipsManager.Instance:ShowGuide(self.tab)
            end
        end
    end
end

function GuideEffect:Hide()
    self.isHide = true
    if self.effectObj ~= nil and self.effectObj:Equals(NULL) == false then
        self.effectObj:SetActive(false)
        self.effectObj.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
        self.effectObj.transform.localScale = Vector3.one
    end
    if self.effectShow ~= nil then
        self.effectShow:SetActive(false)
    end
    TipsManager.Instance:HideGuide()
end

function GuideEffect:FlyToTarget(gameObject)
    self.effectShow.transform.localPosition = Vector3.zero
    self.effectShow:SetActive(true)
    local pos = ctx.UICamera.camera:WorldToScreenPoint(gameObject.transform.position)
    local func = function()
        local scaleWidth = ctx.ScreenWidth
        local scaleHeight = ctx.ScreenHeight
        local origin = 960 / 540
        local currentScale = scaleWidth / scaleHeight
        local ch = 0
        local cw = 0
        local newx = 0
        local newy = 0
        local off_x = 0
        local off_y = 0
        if currentScale > origin then
            -- 以宽为准
            ch = 540
            cw = 960 * currentScale / origin

            newx = pos.x * cw / scaleWidth
            newy = pos.y * ch / scaleHeight

            off_x = self.offestV2.x * cw / scaleWidth
            off_y = self.offestV2.y * ch / scaleHeight
        else
            -- 以高为准
            ch = 540 * origin / currentScale
            cw = 960

            newx = pos.x * cw / scaleWidth
            newy = pos.y * ch / scaleHeight

            off_x = self.offestV2.x * cw / scaleWidth
            off_y = self.offestV2.y * ch / scaleHeight
        end
        pos = Vector3(newx + off_x - cw / 2, newy + off_y - ch / 2, 0)
        Tween.Instance:MoveLocal(self.effectShow, pos, 0.6, function() self:FlyEnd() end)
    end
    LuaTimer.Add(1000, func)
end

function GuideEffect:FlyEnd()
    if self.isHide then
        if not BaseUtils.is_null(self.effectShow) then
            self.effectShow:SetActive(false)
        end
        if not BaseUtils.is_null(self.effectObj) then
            self.effectObj:SetActive(false)
        end
        return
    end

    if self.effectShow ~= nil then
        self.effectShow:SetActive(false)
    end
    if self.effectObj ~= nil then
        self.effectObj:SetActive(true)
    end
    if self.tab ~= nil then
        if MainUIManager.Instance.isMainUIShow then
            TipsManager.Instance:ShowGuide(self.tab)
        end
    end
end
