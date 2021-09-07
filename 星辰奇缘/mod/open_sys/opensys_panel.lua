-- ----------------------------
-- 新功能开启
-- 支持同时开启多个
-- hosr
-- ----------------------------
OpensysPanel = OpensysPanel or BaseClass(BasePanel)

function OpensysPanel:__init(model, callback)
    self.model = model
    self.endCallback = callback
    self.dialyIcon = AssetConfig.dailyicon
    self.mainuiIcon = AssetConfig.mainui_textures
    self.path = "prefabs/ui/drama/dramaopensys.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.dialyIcon, type = AssetType.Dep},
    }
    self.dataList = {}
    self.countTime = 3
    self.rotateList = {}
    self.vec3 = Vector3(0, 0, 0.5)
    self.itemTab = {}
    self.guide10005 = false
    self.guide10008 = false
end

function OpensysPanel:__delete()
    for i,v in ipairs(self.rotateList) do
        LuaTimer.Delete(v)
    end
    self.rotateList = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function OpensysPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "OpensysPanel"
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    else
        UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
    end
    self.transform = self.gameObject.transform

    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)

    self.countDown = self.transform:Find("Main/Count"):GetComponent(Text)
    self.countDown.text = ""

    self.container = self.transform:Find("Main/Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)

    self.baseIcon = self.transform:Find("Main/Icon").gameObject
    self.baseIcon:SetActive(false)

    self.descText = self.transform:Find("Main/Desc/Text"):GetComponent(Text)
    self.descRect = self.transform:Find("Main/Desc"):GetComponent(RectTransform)
    self.descTextRect = self.transform:Find("Main/Desc/Text"):GetComponent(RectTransform)

    self:OnShow()
end

function OpensysPanel:OnShow()
    self.dataList = self.openArgs.gain
    self.desc = self.openArgs.msg

    for i,v in ipairs(self.dataList) do
        local item = {}
        item.gameObject = GameObject.Instantiate(self.baseIcon)
        item.transform = item.gameObject.transform
        item.transform:SetParent(self.container.transform)
        item.transform.localScale = Vector3.one
        item.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(100 * (i - 1), 0)
        item.txtObj = item.transform:Find("Text").gameObject
        item.light = item.transform:Find("Light").gameObject.transform
        item.img = item.transform:Find("Icon"):GetComponent(Image)
        item.data = v

        if v.id < 1000 then
            -- 主UI
            item.txtObj:SetActive(false)
            item.txtObj:GetComponent(Text).text = ""
            item.img.sprite = PreloadManager.Instance:GetSprite(self.mainuiIcon, OpenSysEumn.MainuiIconName[v.id])
            item.img:SetNativeSize()
            item.img.transform.localScale = Vector3.one * 0.8
            item.targetVal = Vector3.one
            if v.id == 22 then
                self.guide10005 = true
            elseif v.id == 14 then
                self.guide10008 = true
            end
        else
            -- 日程里面
            item.txtObj:SetActive(true)
            item.txtObj:GetComponent(Text).text = DataAgenda.data_list[v.id].name
            item.img.sprite = self.assetWrapper:GetSprite(self.dialyIcon, tostring(v.id))
            item.img:SetNativeSize()
            item.img.transform.localScale = Vector3.one
            item.targetVal = Vector3.one * 0.8
        end
        item.gameObject:SetActive(true)
        table.insert(self.itemTab, item)
        local index = i
        local rotateId = LuaTimer.Add(0, 10, function() self:Loop(index) end)
        table.insert(self.rotateList, rotateId)
    end

    local len = #self.dataList
    local cwidth = len * 90, (len - 1) * 10
    local cheight = 120
    self.containerRect.sizeDelta = Vector2(cwidth, cheight)
    self.containerRect.anchoredPosition = Vector2(0, -40)

    local mwidth = math.max(340, cwidth)
    local mheight = 255

    self.mainRect.sizeDelta = Vector2(mwidth, mheight)

    self:HideTargetIcon()

    self.descText.text = self.desc
    local line = math.ceil(self.descText.preferredWidth / (mwidth - 70))

    local h = 20 + 20 * line
    self.descRect.sizeDelta = Vector2(mwidth - 50, h)

    local add = 20 * (line - 1)
    if add > 0 then
        self.mainRect.sizeDelta = Vector2(mwidth, mheight + add)
    end
    self.mainRect.anchoredPosition = Vector2.zero

    LuaTimer.Add(1500, function() self:FlyIcons() end)
end

function OpensysPanel:HideTargetIcon()
    for i,v in ipairs(self.dataList) do
        local index = i
        local item = self.itemTab[index]
        local tarTrans = MainUIManager.Instance.MainUIIconView:getbuttonbyid(v.value).transform
        item.targetObj = tarTrans.gameObject
        if v.id < 1000 then
            MainUIManager.Instance.MainUIIconView:IconSwitcherById(v.id)
            tarTrans.gameObject:SetActive(false)
        else
            tarTrans.gameObject:SetActive(true)
        end
    end
end

function OpensysPanel:Loop(index)
    self.itemTab[index].light:Rotate(self.vec3)
end

function OpensysPanel:FlyIcons()
    if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        -- 战斗中不飞，因为隐藏了取不到具体位置
        self.countTime = 3
    elseif not MainUIManager.Instance.isMainUIShow then
        -- 隐藏主UI不飞，因为隐藏了取不到具体位置
        self.countTime = 3
    else
        self.countTime = 2
        self.countDown.text = ""
        for i,v in ipairs(self.dataList) do
            local index = i
            local item = self.itemTab[index]
            item.txtObj:SetActive(false)
            local pos = self:GetTargetPosition(item.targetObj.transform)
            Tween.Instance:Scale(item.gameObject, Vector3.one * 0.5, 1)
            Tween.Instance:MoveLocal(item.gameObject, pos, 1, function() self:FlyEnd(index) end)
        end
    end
    self:BeginCount()
end

function OpensysPanel:FlyEnd(index)
    local item = self.itemTab[index]
    item.gameObject:SetActive(false)
    item.targetObj:SetActive(true)
    self:EndEffect(item)
end

function OpensysPanel:EndEffect(item)
    local targetVal = item.targetVal
    local gameObject = item.targetObj
    gameObject.transform.localScale = gameObject.transform.localScale * 0.8
    Tween.Instance:Scale(gameObject, targetVal, 0.1, function() self:EffectEnd(item) end, LeanTweenType.easeInElastic)
end

function OpensysPanel:EffectEnd(item)
    item.targetObj.transform.localScale = Vector3.one
    self.gameObject:SetActive(false)
end

function OpensysPanel:BeginCount()
    self.loopId = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function OpensysPanel:LoopTime()
    self.countDown.text = string.format(TI18N("%s秒后自动关闭窗口"), self.countTime)
    self.countTime = self.countTime - 1
    if self.countTime < 0 then
        LuaTimer.Delete(self.loopId)
        self:End()
    end
end

function OpensysPanel:End()
    if self.guide10005 then
        GuideManager.Instance:Start(10005)
    elseif self.guide10008 then
        -- GuideManager.Instance:Start(10008)
    end
    if self.endCallback ~= nil then
        self.endCallback()
    end
end

function OpensysPanel:GetTargetPosition(transform)
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