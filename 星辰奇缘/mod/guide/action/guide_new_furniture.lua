-- -----------------------------
-- 引导领取新宠物
-- hosr
-- -----------------------------
GuideNewFurniture = GuideNewFurniture or BaseClass()

function GuideNewFurniture:__init()
    self.gameObject = nil
    self.showEffect = "prefabs/effect/20102.unity3d"
    self.pathFight = "prefabs/effect/20103.unity3d"

    self.resList = {
        {file = self.showEffect, type = AssetType.Main},
        {file = self.pathFight, type = AssetType.Main},
    }

    self.offestV2 = Vector2(0, 0)

    self.tween = nil
    self.timeId = 0
end

function GuideNewFurniture:__delete()
    self.gameObject = nil

    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId =0
    end

    if self.tween ~= nil then
        Tween.Instance:Cancel(self.tweenid)
        self.tween = nil
    end

    if self.effectFight ~= nil then
        GameObject.DestroyImmediate(self.effectFight)
        self.effectFight = nil
    end

    if self.effectShow ~= nil then
        GameObject.DestroyImmediate(self.effectShow)
        self.effectShow = nil
    end
end

function GuideNewFurniture:Show(gameObject)
    self.gameObject = gameObject
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
    end
    self.assetWrapper:LoadAssetBundle(self.resList, function() self:InitPanel() end)
end

function GuideNewFurniture:ReShow(gameObject)
    self.gameObject = gameObject
    if not BaseUtils.is_null(self.effectFight) then
        self.effectFight.transform:SetParent(self.gameObject.transform)
        self.effectFight.transform.localScale = Vector3.one
        self.effectFight.transform.localPosition = Vector3(self.offestV2.x, self.offestV2.y, -400)
        Utils.ChangeLayersRecursively(self.effectFight.transform, "UI")
        self.effectFight.transform:SetAsLastSibling()
        self.effectFight:SetActive(false)
    end

    self:FlyEnd()
end

function GuideNewFurniture:InitPanel()
    self.effectFight = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.pathFight))
    self.effectFight.name = "GuideFightEffect"
    self.effectFight.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effectFight.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effectFight.transform, "UI")
    self.effectFight:SetActive(false)

    self.effectShow = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.showEffect))
    self.effectShow.name = "GuideShowEffect"
    self.effectShow.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.effectShow.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effectShow.transform, "UI")
    self.effectShow:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    self.effectFight.transform:SetParent(self.gameObject.transform)
    self.effectFight.transform.localScale = Vector3.one
    self.effectFight.transform.localPosition = Vector3(self.offestV2.x, self.offestV2.y, -400)
    Utils.ChangeLayersRecursively(self.effectFight.transform, "UI")
    self.effectFight.transform:SetAsLastSibling()
    self.effectFight:SetActive(false)

    if MainUIManager.Instance.isMainUIShow then
        -- 在主UI显示下才飞
        LuaTimer.Add(100, function() self:FlyToTarget() end)
    else
        self:FlyEnd()
    end
end

function GuideNewFurniture:FlyEnd()
    if not BaseUtils.is_null(self.effectShow) then
        self.effectShow:SetActive(false)
    end
    if not BaseUtils.is_null(self.effectFight) then
        self.effectFight:SetActive(true)
    end

    if MainUIManager.Instance.isMainUIShow then
        -- 主UI显示才显示
        TipsManager.Instance:ShowGuide({gameObject = self.gameObject, data = TI18N("点击进入建筑建造界面")})
    end
end

function GuideNewFurniture:FlyToTarget()
    self.effectShow.transform.localPosition = Vector3.zero
    self.effectShow:SetActive(true)

    local pos = ctx.UICamera.camera:WorldToScreenPoint(self.gameObject.transform.position)
    local func = function()
        if self.effectShow == nil or self.effectFight == nil then
            return
        end

        local scaleWidth = ctx.ScreenWidth
        local scaleHeight = ctx.ScreenHeight
        local origin = 960 / 540
        local currentScale = scaleWidth / scaleHeight
        local newx = 0
        local newy = 0
        local ch = 0
        local cw = 0
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

        local yy = newy + off_y - ch / 2
        local xx = newx + off_x - cw / 2
        pos = Vector3(xx, yy, 0)
        self.tween = Tween.Instance:MoveLocal(self.effectShow, pos, 0.6, function() self:FlyEnd() end)
        self.tweenid = self.tween.id
    end
    self.timeId = LuaTimer.Add(1000, func)
end
