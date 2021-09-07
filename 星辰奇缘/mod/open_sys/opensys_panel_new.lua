-- ----------------------------
-- 新功能开启
-- 不支持同时开启多个 , 只取第一个，多的策划自己搞定
-- hosr
-- 20161203
-- ----------------------------
OpensysPanelNew = OpensysPanelNew or BaseClass(BasePanel)

function OpensysPanelNew:__init(model, callback)
    self.model = model
    self.endCallback = callback
    self.dialyIcon = AssetConfig.dailyicon
    self.mainuiIcon = AssetConfig.mainui_textures
    self.path = "prefabs/ui/drama/dramaopensys1.unity3d"
    self.effectPath = "prefabs/effect/20233.unity3d"
    self.bg = "textures/ui/bigbg/opensysbg.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.dialyIcon, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Main},
        {file = self.bg, type = AssetType.Dep},
        -- {file = AssetConfig.chat_window_res, type = AssetType.Dep},
        -- {file = AssetConfig.guidetaskicon, type = AssetType.Dep},
    }
    self.dataList = {}
    self.countTime = 3
    self.vec3 = Vector3(0, 0, 0.5)
    self.guide10005 = false
    self.guide10008 = false
    self.hasInit = false
end

function OpensysPanelNew:__delete()
    self.hasInit = false
    self.icon.sprite = nil
    self.icon = nil
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function OpensysPanelNew:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "OpensysPanelNew"
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    else
        UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
    end
    self.transform = self.gameObject.transform

    self.main = self.transform:Find("Main").gameObject
    self.main.transform.localScale = Vector3.one * 0.6
    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)
    self.main:GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.bg, "OpenSysBg")

    self.item = self.transform:Find("Main/Icon").gameObject
    -- self.itemRect = self.item:GetComponent(RectTransform)
    -- self.itemRect.anchorMax = Vector2(1, 0)
    -- self.itemRect.anchorMin = Vector2(1, 0)
    -- self.itemRect.pivot = Vector2(0.5, 0)
    self.name = self.transform:Find("Main/Icon/Name"):GetComponent(Text)
    self.icon = self.transform:Find("Main/Icon/Icon"):GetComponent(Image)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -105, -400)
    self.effect:SetActive(false)

    self.hasInit = true
    self:OnShow()
end

function OpensysPanelNew:OnShow()
    --BaseUtils.dump(self.openArgs,"&&&&&&&&&&&&&&&&&&&&&&&&")
    self.dataList = self.openArgs.gain
    self.desc = self.openArgs.msg

    self.data = self.dataList[1]
    --if self.data.id == 28 then self.data.value = 14 end
    if self.data.id < 1000 then
        -- 主UI
        self.name.gameObject:SetActive(false)
        self.name.text = ""
        self.icon.sprite = PreloadManager.Instance:GetSprite(self.mainuiIcon, OpenSysEumn.MainuiIconName[self.data.id])
        self.icon:SetNativeSize()
        self.icon.transform.localScale = Vector3.one * 0.8
        self.targetVal = Vector3.one
        if self.data.id == 22 then
            self.guide10005 = true
        elseif self.data.id == 14 then
            self.guide10008 = true
        end
    else
        -- 日程里面
        self.name.gameObject:SetActive(false)
        self.name.text = DataAgenda.data_list[self.data.id].name
        self.icon.sprite = self.assetWrapper:GetSprite(self.dialyIcon, tostring(self.data.id))
        self.icon:SetNativeSize()
        self.icon.transform.localScale = Vector3.one
        self.targetVal = Vector3.one * 0.8
    end

    Tween.Instance:Scale(self.main, Vector3.one, 0.3, nil, LeanTweenType.easeOutElastic)
    self.effect:SetActive(true)

    self.targetObj = MainUIManager.Instance.MainUIIconView:getbuttonbyid(self.data.value)

    if self.data.id == 15 then -- 飞行按钮特殊处理
        -- self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NFly")
        -- self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, 41520)
        -- self.icon:SetNativeSize()
        if self.imgLoader == nil then
            self.imgLoader = SingleIconLoader.New(self.icon.gameObject)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, 21110)
        self.icon:GetComponent(RectTransform).sizeDelta = Vector2(80, 80)
    end


    if self.data.value == 15 then -- 飞行按钮特殊处理
        -- self.targetObj = ChatManager.Instance.model.chatMini.buttonTab[5].gameObject

    end

    if self.data.value ~= 1 then -- 背包按钮特殊处理
        self:HideTargetIcon()
    end
    LuaTimer.Add(1500, function() self:FlyIcons() end)
end

function OpensysPanelNew:HideTargetIcon()
    if self.data.id < 1000 and self.data.id ~= 28 then
        MainUIManager.Instance.MainUIIconView:IconSwitcherById(self.data.id)
        self.targetObj:SetActive(false)
    else
        self.targetObj:SetActive(true)
    end
end

function OpensysPanelNew:FlyIcons()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        -- 战斗中不飞，因为隐藏了取不到具体位置
        self.countTime = 3
        self:End()
    elseif not MainUIManager.Instance.isMainUIShow then
        -- 隐藏主UI不飞，因为隐藏了取不到具体位置
        self.countTime = 3
        self:End()
    elseif self.data.id == 27 then
        -- 爵位闯关特殊处理
        self.countTime = 3
        self:End()
    else
        self.countTime = 2
        self.name.gameObject:SetActive(false)
        local pos = self.targetObj.transform.position
        Tween.Instance:Scale(self.icon.gameObject, Vector3.one * 0.5, 1)
        Tween.Instance:Move(self.icon.gameObject, pos, 1, function() self:FlyEnd(index) end)
    end
    -- self:BeginCount()
end

function OpensysPanelNew:FlyEnd(index)
    self.item:SetActive(false)
    self.targetObj:SetActive(true)
    self:EndEffect()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end

function OpensysPanelNew:EndEffect()
    local gameObject = self.targetObj
    gameObject.transform.localScale = gameObject.transform.localScale * 0.8
    Tween.Instance:Scale(gameObject, self.targetVal, 0.1, function() self:EffectEnd(item) end, LeanTweenType.easeInElastic)
end

function OpensysPanelNew:EffectEnd(item)
    self.targetObj.transform.localScale = Vector3.one
    self.gameObject:SetActive(false)
    self:End()
end

function OpensysPanelNew:BeginCount()
    self.loopId = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function OpensysPanelNew:LoopTime()
    self.countTime = self.countTime - 1
    if self.countTime < 0 then
        LuaTimer.Delete(self.loopId)
        self:End()
    end
end

function OpensysPanelNew:End()
    if self.guide10005 then
        GuideManager.Instance:Start(10005)
    elseif self.guide10008 then
        -- GuideManager.Instance:Start(10008)
    end
    if self.endCallback ~= nil then
        self.endCallback()
    end
end

function OpensysPanelNew:GetTargetPosition(transform)
    local pos = ctx.UICamera.camera:WorldToScreenPoint(transform.position)

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
    local half = {w = transform.gameObject:GetComponent(RectTransform).rect.width / 2, h = transform.gameObject:GetComponent(RectTransform).rect.height / 2}
    local pivot = transform.gameObject:GetComponent(RectTransform).pivot
    local off_x = (0.5 - pivot.x) / 0.5 * half.w - 45
    local off_y = (0.5 - pivot.y) / 0.5 * half.h / 2
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight
        off_x = off_x * cw / scaleWidth
        off_y = off_y * ch / scaleHeight
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight
        off_x = off_x * cw / scaleWidth
        off_y = off_y * ch / scaleHeight
    end
    pos = Vector3(newx + off_x - cw / 2, newy + off_y - ch / 2, 0)
    return pos
end