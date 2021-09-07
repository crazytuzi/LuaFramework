TipsModel = TipsModel or BaseClass(BaseModel)

function TipsModel:__init()
    self.ui_camera = ctx.UICamera
    self.tipsCanvas = nil

    self.xregion = {["min"] = 0, ["max"] = 0}
    self.yregion = {["min"] = 0, ["max"] = 0}
    self.offset = 0

    --创建加载wrapper
    self.assetWrapper = AssetBatchWrapper.New()

    local func = function()
        if self.assetWrapper == nil then return end
        self.tipsCanvas = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.tips_canvas))
        self.tipsCanvas.name = "TipsCanvas"
        UIUtils.AddUIChild(ctx.CanvasContainer, self.tipsCanvas)
        self.tipsCanvas.transform.localPosition = Vector3(0, 0, -500)

        self.panel = self.tipsCanvas.transform:Find("Panel").gameObject
        self.panel:GetComponent(Image).color = Color(0,0,0,0)
        self.panel:GetComponent(Button).onClick:AddListener(function() EventMgr.Instance:Fire(event_name.tips_cancel_close) self:Closetips() end)
        self.panel:SetActive(false)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    self.assetWrapper:LoadAssetBundle({{file = AssetConfig.tips_canvas, type = AssetType.Main}}, func)

    self.itemTips = ItemTips.New(self)
    self.equipTips = EquipTips.New(self)
    self.petEquipTips = PetEquipTips.New(self)
    self.skillTips = SkillTips.New(self)
    self.playerTips = PlayerTips.New(self)
    self.textTips = GeneralTips.New(self)
    self.buttonTips = ButtonTips.New(self)
    self.guideTips = GuideTips.New(self)
    self.guideTipsNew = GuideTipsNew.New(self)
    self.dropTips = DropTips.New(self)
    self.previewTips = PreviewTips.New(self)
    self.wingTips = WingTips.New(self)
    self.fruitTips = FruitTips.New(self)
    self.randomFruitTips = RandomFruitTips.New(self)
    self.teamupTips = TeamUpTips.New(self)
    self.titleTips = TitleTips.New(self)
    self.rideSkillTips = RideSkillTips.New(self)
    self.rideEquipTips = RideEquipTips.New(self)
    self.fruitTipsNew = FruitTipsNew.New(self)
    self.textBtnTips = GeneralBtnTips.New(self)
    self.childTelnetTips = ChildTelnetTips.New(self)
    self.talismanTips = TalismanTips.New(self)
    self.talismanTipsAttr = TalismanAfter.New(self)
    self.rulesTips = RulesTips.New(self)
    self.chanceshowTips = ChanceShowTips.New(self)
    self.runeTips = RuneTips.New(self)

    self.currentItem = nil
    self.isShowTailsManTips = false

    -- 记录已经提示过的卖出行为
    self.hasNoticeTab = {}
end

function TipsModel:__delete()
end

function TipsModel:Clear()
    self:Closetips()
end

function TipsModel:Closetips()
    --不要挪动事件位置

    if self.panel ~= nil then
        self.panel:SetActive(false)
    end
    if self.itemTips ~= nil then
        self.itemTips:Hiden()
    end
    if self.equipTips ~= nil then
        self.equipTips:Hiden()
    end
    if self.petEquipTips ~= nil then
        self.petEquipTips:Hiden()
    end
    if self.skillTips ~= nil then
        self.skillTips:Hiden()
    end
    if self.playerTips ~= nil then

        self.playerTips:Hiden()
    end
    if self.textTips ~= nil then
        self.textTips:Hiden()
    end
    if self.buttonTips ~= nil then
        self.buttonTips:Hiden()
    end
    if self.guideTips ~= nil then
        self.guideTips:Hiden()
        if self.isShowGuideTips == true then
        end
    end
    if self.guideTipsNew ~= nil then
        self.guideTipsNew:Hiden()
    end
    if self.dropTips ~= nil then
        self.dropTips:Hiden()
    end
    if self.wingTips ~= nil then
        self.wingTips:Hiden()
    end
    if self.fruitTips ~= nil then
        self.fruitTips:Hiden()
    end
    if self.titleTips ~= nil then
        self.titleTips:Hiden()
    end
    if self.randomFruitTips ~= nil then
        self.randomFruitTips:Hiden()
    end
    if self.rideSkillTips ~= nil then
        self.rideSkillTips:Hiden()
    end
    if self.rideEquipTips ~= nil then
        self.rideEquipTips:Hiden()
    end
    if self.fruitTipsNew ~= nil then
        self.fruitTipsNew:Hiden()
    end
    if self.textBtnTips ~= nil then
        self.textBtnTips:Hiden()
    end
    if self.childTelnetTips ~= nil then
        self.childTelnetTips:Hiden()
    end
    if self.talismanTips ~= nil then
        self.talismanTips:Hiden()
    end
    if self.previewTips ~= nil then
        self.previewTips:Hiden()
    end
    if self.talismanTipsAttr ~= nil then
        self.talismanTipsAttr:Hiden()
    end

    if self.chanceshowTips ~= nil then
        self.chanceshowTips:Hiden()
    end

    if self.rulesTips ~= nil then
        self.rulesTips:Hiden()
    end
    
    if self.runeTips ~= nil then
        self.runeTips:Hiden()
    end

    -- if self.chanceshowPanel ~= nil then
    --     self:CloseChancePanel()
    -- end

    if self.currentItem ~= nil then
        if self.currentItem.isItemSlot then
            self.currentItem:ShowSelect(false)
        end
        self.currentItem = nil
    end

    EventMgr.Instance:Fire(event_name.tips_close)

    if self.isShowTailsManTips == true then
        self.isShowTailsManTips = false
    end


end

-- 显示前判断是否有获取途径信息
function TipsModel:BeforeShow(tips, info)
    local dropstr = self:CheckIsDrop(info)
    local itemObj = info.gameObject
    if dropstr ~= "" then
        self.panel:SetActive(true)
        tips:RemoveTime()
        tips.rect.anchorMax = Vector2.one * 0.5
        tips.rect.anchorMin = Vector2.one * 0.5
        tips.rect.pivot = Vector2(1, 0.5)
        tips.rect.anchoredPosition = Vector2.zero
        self.dropTips:Show({info = info, dropstr = dropstr, height = tips.height})
    elseif self:CheckShowModel(info) ~= nil then
        self.panel:SetActive(true)
        tips:RemoveTime()
        tips.rect.anchorMax = Vector2.one * 0.5
        tips.rect.anchorMin = Vector2.one * 0.5
        tips.rect.pivot = Vector2(1, 0.5)
        tips.rect.anchoredPosition = Vector2.zero
        self.previewTips:Show({args = self:CheckShowModel(info), height = tips.height})
    else
        self.panel:SetActive(false)
        tips.rect.anchorMax = Vector2.zero
        tips.rect.anchorMin = Vector2.zero
        tips.rect.pivot = Vector2.zero

        if itemObj ~= nil then
            --可能这里这样处理会有问题
            local tipsOffsetX = nil
            local tipsOffsetY = nil
            if info.extra ~= nil then
                tipsOffsetX = info.extra.tipsOffsetX
                if tipsOffsetX ~= nil then
                    tipsOffsetX = tipsOffsetX + tips.width
                end
                tipsOffsetY = info.extra.tipsOffsetY
                if tipsOffsetY ~= nil then
                    tipsOffsetY = tipsOffsetY + tips.height
                end
            end
            self:Locate(itemObj.transform, tips.gameObject, {w = tips.width, h = tips.height}, nil, tipsOffsetX, tipsOffsetY)
        end
    end
end

function TipsModel:ShowItem(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.itemTips:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.itemTips, info)
    end
    self.itemTips:Show(func)
end

function TipsModel:ShowEquip(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.equipTips:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.equipTips, info)
    end
    self.equipTips:Show(func)
end

function TipsModel:ShowText(info)
    if not info.special then
        self:Closetips()
    end
    -- BaseUtils.dump(info,"info")
    local itemObj = info.gameObject
    local isChance = info.isChance
    local func = function()
        self.textTips:UpdateInfo(info.itemData)
        if isChance == nil then
            if BaseUtils.is_null(itemObj) then return end
            self:Locate(itemObj.transform, self.textTips.gameObject, {w = self.textTips.width, h = self.textTips.height}, info.special, info.tipsOffsetX, info.tipsOffsetY, info.forward)
        elseif isChance ~= nil and isChance == true then
            local currheight = 540
            local currWidth = 960
            if ctx.ScreenWidth/ctx.ScreenHeight > 16/9 then
                currheight = 540
                currWidth = 960 * (ctx.ScreenWidth/ctx.ScreenHeight) / (16/9)
            else
                currheight = 540 * (16/9) / (ctx.ScreenWidth/ctx.ScreenHeight)
                currWidth = 960
            end
            self.textTips.gameObject:GetComponent(RectTransform).anchoredPosition =Vector2((currWidth/2) - self.textTips.width, (currheight-self.textTips.height)/2)
        end
    end
    self.textTips:Show(func)
end

function TipsModel:ShowTextBtn(info)
    if not info.special then
        self:Closetips()
    end
    local itemObj = info.gameObject
    local func = function()
        self.textBtnTips:UpdateInfo(info.itemData)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.textBtnTips.gameObject, {w = self.textBtnTips.width, h = self.textBtnTips.height}, info.special)
    end
    self.textBtnTips:Show(func)
end

function TipsModel:ShowPetEquip(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.petEquipTips:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.petEquipTips, info)
    end
    self.petEquipTips:Show(func)
end

function TipsModel:ShowSkill(info, special)
    if not special then
        self:Closetips()
    end
    local itemObj = info.gameObject
    local func = function()
        if BaseUtils.is_null(itemObj) then
            return
        end
        self.skillTips:UpdateInfo(info.type, info.skillData, info.extra)
        self:Locate(itemObj.transform, self.skillTips.gameObject, {w = self.skillTips.width, h = self.skillTips.height}, special)

        if special then
            self.skillTips.transform:SetAsLastSibling()
        end
    end
    self.skillTips:Show(func)
end

function TipsModel:ShowPlayer(info)
        self.playerTips:UpdateInfo(info)
end

function TipsModel:SetPlayerTipsInfo(info)
    self:Closetips()
    local func = function()
        self.playerTips:ReceiveData(info)
    end
    self.playerTips:Show(func)
end

function TipsModel:ShowButton(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.buttonTips:UpdateInfo(info.data)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.buttonTips.gameObject, {w = self.buttonTips.width, h = self.buttonTips.height})
    end
    self.buttonTips:Show(func)
end

function TipsModel:ShowRideSkill(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.rideSkillTips:UpdateInfo(info.data)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.rideSkillTips.gameObject, {w = self.rideSkillTips.width, h = self.rideSkillTips.height})
    end
    self.rideSkillTips:Show(func)
end

function TipsModel:ShowRideEquip(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.rideEquipTips:UpdateInfo(info.itemData, info.extra)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.rideEquipTips.gameObject, {w = self.rideEquipTips.width, h = self.rideEquipTips.height})
    end
    self.rideEquipTips:Show(func)
end

function TipsModel:ShowChildTelnet(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.childTelnetTips:UpdateInfo(info.data)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.childTelnetTips.gameObject, {w = self.childTelnetTips.width, h = self.childTelnetTips.height})
    end
    self.childTelnetTips:Show(func)
end

function TipsModel:ShowGuide(info)
    if BaseUtils.IsVerify then
        return
    end
    if info == nil then
        return
    end
    if BaseUtils.is_null(info.gameObject) then
        return
    end
    if info.forward ~= nil then
        self:ShowGuideNew(info)
    else
        local itemObj = info.gameObject
        local func = function()
            self.guideTips:UpdateInfo(info.data)
            if BaseUtils.is_null(itemObj) then return end
            local h = (itemObj:GetComponent(RectTransform).rect.height - self.guideTips.height) / 2 + self.guideTips.height
            self:Locate(itemObj.transform, self.guideTips.gameObject, {w = self.guideTips.width, h = h})
        end
        self.guideTips:Show(func)
    end
end

function TipsModel:HideGuide()
    self.guideTips:Hiden()
    self.guideTipsNew:Hiden()
end

function TipsModel:ShowGuideNew(info)
    if BaseUtils.IsVerify then
        return
    end
    if info == nil then
        return
    end
    if BaseUtils.is_null(info.gameObject) then
        return
    end
    local itemObj = info.gameObject
    local func = function()
        self.guideTipsNew:UpdateInfo(info.data)
        if info.forward == 1 then
            self.guideTipsNew:ShowLeft()
        elseif info.forward == 2 then
            self.guideTipsNew:ShowRight()
        elseif info.forward == 3 then
            self.guideTipsNew:ShowUp()
        elseif info.forward == 4 then
            self.guideTipsNew:ShowDown()
        end
        if BaseUtils.is_null(itemObj) then return end
        local h = (itemObj:GetComponent(RectTransform).rect.height - self.guideTipsNew.height) / 2 + self.guideTipsNew.height
        self:Locate(itemObj.transform, self.guideTipsNew.gameObject, {w = self.guideTipsNew.width, h = self.guideTipsNew.height}, false, 0, 0, info.forward)
    end
    self.guideTipsNew:Show(func)
end

function TipsModel:ShowEquipExt()
    self.panel:SetActive(true)
    self.equipTips:RemoveTime()
    self.equipTips.rect.anchorMax = Vector2.one * 0.5
    self.equipTips.rect.anchorMin = Vector2.one * 0.5
    self.equipTips.rect.pivot = Vector2(1, 0.5)
    self.equipTips.rect.anchoredPosition = Vector2.zero
end

function TipsModel:ShowWing(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.wingTips:UpdateInfo(info.itemData)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.wingTips.gameObject, {w = self.wingTips.width, h = self.wingTips.height})
    end
    self.wingTips:Show(func)
end

function TipsModel:ShowFruit(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.fruitTips:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.fruitTips, info)
    end
    self.fruitTips:Show(func)
end

function TipsModel:ShowRandomFruit(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.randomFruitTips:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.randomFruitTips, info)
    end
    self.randomFruitTips:Show(func)
end

function TipsModel:ShowFruitNew(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.fruitTipsNew:UpdateInfo(info.itemData, info.extra)
        self:BeforeShow(self.fruitTipsNew, info)
    end
    self.fruitTipsNew:Show(func)
end

function TipsModel:ShowTeamUp(info)
    self:Closetips()
    local func = function()
        self.teamupTips:SetData(info)
    end
    self.teamupTips:Show(func)
end

function TipsModel:ShowTitle(info)
    if not info.special then
        self:Closetips()
    end
    local itemObj = info.gameObject
    local func = function()
        self.titleTips:UpdateInfo(info.itemData, info.title)
        if BaseUtils.is_null(itemObj) then return end
        self:Locate(itemObj.transform, self.titleTips.gameObject, {w = self.titleTips.width, h = self.titleTips.height}, info.special)
    end
    self.titleTips:Show(func)
end

function TipsModel:ShowRuneTips(info)
    self:Closetips()
    local itemObj = info.gameObject
    local func = function()
        self.runeTips:UpdateInfo(info.itemData, info.extra)
        self:Locate(itemObj.transform, self.runeTips.gameObject, {w = self.runeTips.width, h = self.runeTips.height})
    end
    self.runeTips:Show(func)
end

--检查点击点的合法性
function TipsModel:Checkvalidregion(x, y)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight

    local newx = 0
    local newy = 0
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960
    end
    x = x * cw / scaleWidth
    y = y * ch / scaleHeight

    local xok = false
    local yok = false
    if x >= self.xregion["min"] and x <= self.xregion["max"] then
        xok = true
    end
    if y >= self.yregion["min"] and y <= self.yregion["max"] then
        yok = true
    end
    return xok and yok
end

function TipsModel:Dolocate(x, off_x, y, off_y, ohwidth, ohheight, tips, width, height, special)
    local rect = tips:GetComponent(RectTransform)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight

    local newx = 0
    local newy = 0
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960
    end
    newx = x * cw / scaleWidth
    newy = y * ch / scaleHeight

    local v2 = Vector2(newx + off_x, newy + off_y)
    local right = true
    local guidemark = false --指引旋转标记
    if (v2.x - width - ohwidth) < self.offset then--在图标右边
        if tips.gameObject.name == "GuideTips" then
            guidemark = true
        end
        if (v2.y - height + ohheight) < self.offset then--贴底边
            v2 = Vector2(v2.x + ohwidth, 0)
        else
            v2 = v2 + Vector2(ohwidth, ohheight - height)
        end
    else--在图标左边
        right = false
        if (v2.y - height + ohheight) < self.offset then--贴底边
            v2 = Vector2(v2.x - width - ohwidth, 0)
        else
            v2 = v2 + Vector2(-width - ohwidth, ohheight - height)
        end
    end

    rect.anchoredPosition = Vector2(v2.x, v2.y)

    if not special then
        --计算有效区域
        self.xregion = {}
        self.yregion = {}
        local max = v2 + Vector2(width, height)
        local min = v2
        self.xregion["min"] = min.x
        self.xregion["max"] = max.x
        self.yregion["min"] = min.y
        self.yregion["max"] = max.y
        if tips.gameObject.name == "GuideTips" then
            if guidemark == true then
                rect:Find("Text").localScale = Vector3(-1, 1, 1)
                rect.localScale = Vector3(-1, 1, 1)
                rect.anchoredPosition = Vector2(v2.x + width, v2.y)
            else
                rect:Find("Text").localScale = Vector3.one
                rect.localScale = Vector3.one
            end
        end
    end
end

-- 新增一个靠上下的tips
function TipsModel:DolocateUpDown(x, off_x, y, off_y, ohwidth, ohheight, tips, width, height, special, forward)
    -- print(string.format("x=%s;y=%s;ohw=%s,ohh=%s,w=%s,h=%s", x, y, ohwidth, ohheight, width, height))

    local rect = tips:GetComponent(RectTransform)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight

    local newx = 0
    local newy = 0
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960
    end
    newx = x * cw / scaleWidth
    newy = y * ch / scaleHeight

    local v2 = Vector2(newx + off_x, newy + off_y)

    if forward == 1 then
        -- 左
        v2 = v2 + Vector2(-ohwidth - width - 25, -height/2)
    elseif forward == 2 then
        -- 右
        v2 = v2 + Vector2(ohwidth + 25, -height/2)
    elseif forward == 3 then
        -- 上
        v2 = v2 + Vector2(-width/2, ohheight + 25)
    elseif forward == 4 then
        -- 下
        v2 = v2 + Vector2(-width/2, -ohheight - height - 25)
    end

    rect.anchoredPosition = Vector2(v2.x, v2.y)

    if not special then
        --计算有效区域
        self.xregion = {}
        self.yregion = {}
        local max = v2 + Vector2(width, height)
        local min = v2
        self.xregion["min"] = min.x
        self.xregion["max"] = max.x
        self.yregion["min"] = min.y
        self.yregion["max"] = max.y
        if tips.gameObject.name == "GuideTips" then
            rect:Find("Text").localScale = Vector3.one
            rect.localScale = Vector3.one
        end
    end
end

--特殊用于装备tips，重设右边有效区域
function TipsModel:LocateEquipTipsRightArea()
    self.has_locate_equip_tips_right = true
    local offsetY = self.equipTips.extra.height - self.equipTips.height
    self.xregion["max"] = self.xregion["max"] + self.equipTips.extra.width
    self.yregion["min"] = self.yregion["min"] - offsetY
end

--特殊用于装备tips，取消右边有效区域
function TipsModel:CancelEquipTipsRightArea()
    if self.has_locate_equip_tips_right then
        local offsetY = self.equipTips.extra.height - self.equipTips.height
        self.xregion["max"] = self.xregion["max"] - self.equipTips.extra.width
        self.yregion["min"] = self.yregion["min"] + offsetY
        self.has_locate_equip_tips_right = false
    end
end

--获取对象对应镜头的位置
function TipsModel:CameraPosition(trans)
    local v3 = nil
    if trans == nil then
        v3 = Vector2(ctx.ScreenWidth/2, ctx.ScreenHeight/2)
    else
        v3 = self.ui_camera.camera:WorldToScreenPoint(trans.position)
    end
    return Vector2(v3.x, v3.y)
end

--获取对象长宽--已经渲染的方可
function TipsModel:ObjSize(trans)
    local half = nil
    if trans == nil then
        half = {w = 0, h = 0}
    else
        half = {w = trans.gameObject:GetComponent(RectTransform).rect.width/2, h = trans.gameObject:GetComponent(RectTransform).rect.height/2}
    end
    return half
end

--传人参考对象transform，tips对象transform，tips size{w:0,h:0}，进行重定位
-- 自定义放向
function TipsModel:Locate(trans, tips, size, special, tipsOffsetX, tipsOffsetY, forward)
    if tipsOffsetX == nil then tipsOffsetX = 0 end
    if tipsOffsetY == nil then tipsOffsetY = 0 end
    local v2 = self:CameraPosition(trans)
    local half = self:ObjSize(trans)
    local pivot = trans.gameObject:GetComponent(RectTransform).pivot
    local off_x = (0.5 - pivot.x)/0.5 * half.w + tipsOffsetX
    local off_y = (0.5 - pivot.y)/0.5 * half.h + tipsOffsetY
    if forward ~= nil then
        self:DolocateUpDown(v2.x, off_x, v2.y, off_y, half.w, half.h, tips, size.w, size.h, special, forward)
    else
        self:Dolocate(v2.x, off_x, v2.y, off_y, half.w, half.h, tips, size.w, size.h, special)
    end
end

-- -----------------------
-- 按钮操作
-- ----------------------
function TipsModel:Use(item, extra)
    if item ~= nil then
        if extra ~= nil and extra.inbag and
            (item.type == BackpackEumn.ItemType.childTelent
            or item.type == BackpackEumn.ItemType.childGrowth
            or item.type == BackpackEumn.ItemType.childFood
            or item.type == BackpackEumn.ItemType.childPoint) then
            NoticeManager.Instance:FloatTipsByString(TI18N("请在子女喂养界面使用该道具"))
            self:Closetips()
        elseif DataItem.data_change_item[item.base_id] ~= nil and item.classes ~= RoleManager.Instance.RoleData.classes then
            self:Change(item, extra)
            self:Closetips()
        else
            local isClose = BackpackManager.Instance:Use(item.id, 1, item.base_id)
            if isClose then
                self:Closetips()
            end
        end
    end
end

function TipsModel:UseAll(item)
    if item ~= nil then
        BackpackManager.Instance:Use(item.id, item.quantity, item.base_id)
        self:Closetips()
    end
end

function TipsModel:Pet_gem_off(item, extra)
    if item ~= nil then
        if item.type == BackpackEumn.ItemType.childattreqm or item.type == BackpackEumn.ItemType.childskilleqm then
            local cdata = extra.child
            if BaseUtils.get_unique_roleid(cdata.b_id, cdata.b_zone_id, cdata.b_platform) ~= BaseUtils.get_self_id() then
                -- 不是自己上的装备，提示会归还给所属者
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                if RoleManager.Instance.RoleData.sex == 0 then
                    data.content = string.format(TI18N("<color='#ffff9a'>%s</color>是<color='#ffff9a'>%s</color>的<color='#ffff9a'>%s</color>佩戴的，卸下后将邮件返回"), item.name, cdata.child_name, cdata.father_name)
                else
                    data.content = string.format(TI18N("<color='#ffff9a'>%s</color>是<color='#ffff9a'>%s</color>的<color='#ffff9a'>%s</color>佩戴的，卸下后将邮件返回"), item.name, cdata.child_name, cdata.mother_name)
                end
                data.sureLabel = TI18N("确认卸下")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function() ChildrenManager.Instance:Require18616(cdata.child_id, cdata.platform, cdata.zone_id, 0, extra.hole) end
                NoticeManager.Instance:ConfirmTips(data)
            else
                ChildrenManager.Instance:Require18616(cdata.child_id, cdata.platform, cdata.zone_id, 0, extra.hole)
            end
        else
            EventMgr.Instance:Fire(event_name.petgemoff, item.id)
        end
        self:Closetips()
    end
end

function TipsModel:Pet_gem_replace(item, extra)
    if item ~= nil then
        if item.type == BackpackEumn.ItemType.childattreqm or item.type == BackpackEumn.ItemType.childskilleqm then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petchildgemwindow, {hold_id = extra.hole, replace = true})
            -- ChildrenManager.Instance:Require18616(extra.child_id, extra.platform, extra.zone_id, item.id, extra.hole)
        else
            EventMgr.Instance:Fire(event_name.petgemreplace, item.id)
        end
        self:Closetips()
    end
end

function TipsModel:Sell(item, isHolding)
    if item ~= nil then
        local isClose = false
        if DataMarketSilver.data_market_silver_item[item.base_id] ~= nil then
            isClose = true
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {4, item.id})
        elseif DataMarketGold.data_market_gold_item[item.base_id] ~= nil or DataMarketGold.data_market_gold_hide[item.base_id] ~= nil or DataMarketGold.data_market_gold_exchange[item.base_id] ~= nil then
            local data = BackpackManager.Instance:GetItemById(item.id)
            if data == nil then
                isClose = true
            else
                local sureSell = function()
                    self.hasNoticeTab[item.base_id] = 1
                    if data.quantity > 1 then
                        isClose = false
                    else
                        isClose = true
                    end
                    if isHolding == true then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sell_gold, {item.id})
                    else
                        local func = function() MarketManager.Instance:send12402(item.id, 1) end
                        local confirm_dat = {
                            titleTop = TI18N("贵重物品")
                            , title = string.format( "%s%s", ColorHelper.color_item_name(data.quality ,string.format("[%s]", data.name)), TI18N("十分珍贵，<color='#df3435'>出售后无法找回</color>"))
                            , password = TI18N(tostring(math.random(100, 999)))
                            , confirm_str = TI18N("出 售")
                            , cancel_str = TI18N("取 消")
                            , confirm_callback = func
                        }
                        if BackpackManager.Instance:GetPreciousItem(item.base_id) then 
                            isClose = true
                            TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
                        else
                            func()
                        end
                    end
                end
                sureSell()
            end
        elseif item.type == BackpackEumn.ItemType.decorate then
            isClose = true
            EventMgr.Instance:Fire(event_name.home_item_sell)
        else
            Log.Error(string.format("缺失配置, DataMarketSilver or DataMarkedGold; id:%s, name:%s", item.base_id, item.name))
        end

        if isClose then
            self:Closetips()
        end
    end
end

function TipsModel:Consignment(item)
    if item ~= nil then
        MarketManager.Instance:Sell(item)
        self:Closetips()
    end
end

function TipsModel:Smith(item)
    if RoleManager.Instance.RoleData.lev < 38 then
        NoticeManager.Instance:FloatTipsByString(TI18N("锻造功能38级开放"))
        return
    end
    if item ~= nil then
        local args = nil
        if item.tips_type ~= nil then
            for i=1,#item.tips_type do
                if item.tips_type[i].tips == TipsEumn.ButtonType.Smith then
                    if item.tips_type[i].val == "[1]" then
                        args = {1}
                    elseif item.tips_type[i].val == "[2]" then
                        args = {2}
                    elseif item.tips_type[i].val == "[3]" then
                        args = {3}
                    elseif item.tips_type[i].val == "[4]" then
                        args = {4}
                    end
                    break
                end
            end
        end
        if args ~= nil and args[1] == 4 then
            if RoleManager.Instance.RoleData.lev < 45 then
                NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>45</color>级才可以强化，努力提升等级吧{face_1,25}"))
                return
            end
        end
        EquipStrengthManager.Instance.model.strength_data = item
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmadvance, args)
        self:Closetips()
    end
end

--装备转换
function TipsModel:Trans(item, _type)
    if RoleManager.Instance.RoleData.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("转换功能40级开放"))
        return
    end
    EquipStrengthManager.Instance.model.trans_data = item
    EquipStrengthManager.Instance.model.trans_type = _type
    EquipStrengthManager.Instance.model:OpenEquipTransUI()
end

--装备转换
function TipsModel:TransForBackPackItem()
    if RoleManager.Instance.RoleData.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("转换功能40级开放"))
        return
    end
    EquipStrengthManager.Instance.model.trans_data = nil
    EquipStrengthManager.Instance.model.trans_type = 2
    EquipStrengthManager.Instance.model:OpenEquipTransUI()
end

--装备精炼
function TipsModel:Dianhua(item)
    EquipStrengthManager.Instance.model.dianhua_data = item
    EquipStrengthManager.Instance.model:OpenEquipStrengthMainUI({5})
end

--宝石摘除
function TipsModel:Remove(item)
    local id = 0
    local hole = 0
    local base_id = item.base.id
    for _id,stones in pairs(mod_eqm.hole_to_stone) do
        for k,v in pairs(stones) do
            if k == item.hole and v.stone == base_id then
                id = _id
                hole = k
            end
        end
    end
    local name = item.base.name
    local num = 1
    local dd = DataBacksmith.data_gem_remove[base_id]
    if dd ~= nil then
        num = dd.val
        local ii = DataItem.data_get[dd.base_id]
        if ii ~= nil then
            name = ii.name
        end
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("拆除后将得到<color='#ffff00'>%s</color>个<color='#00ff00'>[%s]</color>，是否继续？"), num, name)
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()  end --  自己加上宝石摘除的处理
    NoticeManager.Instance:ConfirmTips(data)
end

function TipsModel:Merge(item)
    if item ~= nil then
        self:Closetips()
        FuseManager.Instance:OpenByBaseID(item.base_id)
    end
end

function TipsModel:Openwindow(openwindowid, args)
    self:Closetips()
    WindowManager.Instance:OpenWindowById(tonumber(openwindowid), args)
end

function TipsModel:OpenChancewindow(args)
    self:Closetips()
    if self.chanWin == nil then
        self.chanWin = ChangeTipsWindow.New()
    end
    self.chanWin:Open(args)
end

function TipsModel:CloseChancewindow(args)
    if self.chanWin ~= nil then
        self.chanWin:DeleteMe()
        self.chanWin = nil
    end
end

function TipsModel:Backpack_change()
    if temp_data ~= nil then
        if mod_item.item_data(temp_data.id) == nil then
            mod_tips.closetips()
        end
    end
end

function TipsModel:Discard(item)
    self:Closetips()
    local func = function()
        BackpackManager.Instance:Send10320({id = item.id, storage = BackpackEumn.StorageType.Backpack})
    end
    local str = string.format(TI18N("是否丢弃所有的%s<color='#ffff00'>(注意：丢弃后无法找回)</color>"), ColorHelper.color_item_name(item.quality, "["..item.name.."]"))
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = func
    NoticeManager.Instance:ConfirmTips(data)
end

function TipsModel:Drop(item)
end

--炼化逻辑
function TipsModel:Alchemy(itemData)

    if RoleManager.Instance.RoleData.lev < 35 then
        NoticeManager.Instance:FloatTipsByString(TI18N("魔法炼化35级开放，请努力升级吧 {face_1,18}"))
        return
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.showClose = 1

    local alchemy_num = 0
    if itemData.type == BackpackEumn.ItemType.limit_fruit then
        local currTime = 0
        local maxTime = DataItem.data_fruit[tonumber(itemData.base_id)].num
        -- 限量果实显示使用次数
        for k,v in pairs(itemData.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_time then
                currTime = v.value
            end
        end
        if currTime == 0 then
            currTime = maxTime
        end
        currTime = math.max(currTime, 1)
        alchemy_num = math.ceil(itemData.quantity*itemData.alchemy*(currTime/maxTime))
    else
        alchemy_num = itemData.quantity*itemData.alchemy
    end

    data.content = string.format("%s<color='#ffff00'>%s</color>%s%s%s<color='#ffff00'>%s</color>{assets_2, 90017}", TI18N("炼化"), itemData.quantity, TI18N("个"), ColorHelper.color_item_name(itemData.quality, string.format("[%s]",itemData.name)) , TI18N("可获得"), alchemy_num)
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("前往炼化")
    data.sureCallback = function()
        AlchemyManager.Instance:request14908(itemData.id)
    end
    data.cancelCallback = function()
        AlchemyManager.Instance.model:InitLianhuUI()
    end

    local str = string.format("%s<color='#ffff00'>%s</color>%s<color='#ffff00'>%s</color>{assets_2, 90017}", TI18N("炼化"), itemData.quantity, TI18N("个可获得"), itemData.alchemy)
    local confirm_dat = {
        titleTop = TI18N("贵重物品")
        , title = string.format( "%s%s,<color='#df3435'>%s</color>,%s", ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name)), TI18N("十分珍贵"), TI18N("炼化后无法找回"), str)
        , password = TI18N(tostring(math.random(100, 999)))
        , confirm_str = TI18N("炼 化")
        , cancel_str = TI18N("取 消")
        , confirm_callback = function() AlchemyManager.Instance:request14908(itemData.id) end
    }
    if BackpackManager.Instance:GetPreciousItem(itemData.base_id) then 
        TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
    else
        NoticeManager.Instance:ConfirmTips(data)
    end
    self:Closetips()
end

function TipsModel:LoveCheck(itemData)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_check)
end

--溶炼逻辑
function TipsModel:Smelting(itemData)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.showClose = 1

    local smeltingList = {}
    local data_smelting_item = DataItem.data_smelting_item[itemData.base_id]
    if data_smelting_item ~= nil then
        for index, value in ipairs(data_smelting_item.gain) do
            table.insert(smeltingList, value)
        end
    end

    local smeltingString = ""
    for index, value in ipairs(smeltingList) do
        if index == 1 then
            smeltingString = string.format("{assets_1,%s,%s}", value[1], value[2]*itemData.quantity)
        else
            smeltingString = string.format("%s, {assets_1,%s,%s}", smeltingString, value[1], value[2]*itemData.quantity)
        end
    end

    data.content = string.format("熔炼<color='#ffff00'>%s</color>个%s可获得%s", itemData.quantity, ColorHelper.color_item_name(itemData.quality, string.format("[%s]",itemData.name)), smeltingString)
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        AlchemyManager.Instance:request14910(itemData.id)
    end
    NoticeManager.Instance:ConfirmTips(data)
    self:Closetips()
end

-- 道具拆分
function TipsModel:Split(itemData)
    if itemData.type == BackpackEumn.ItemType.handbook_piece then
        local split = DataHandbook.data_split[itemData.base_id]
        if split == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该道具无法拆分"))
            return
        end
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("拆分后可获得{assets_1,90024,%s}，可在<color='#ffff00'>收藏-商店</color>兑换其它图鉴碎片，是否拆分?"), split.val)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function ()
            HandbookManager.Instance:Send17108(itemData.id)
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        local split = DataBacksmith.data_split[itemData.base_id]
        if split == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该道具无法拆分"))
            return
        end

        local baseid = split.gain[1][1]
        local num = split.gain[1][2]
        local item = DataItem.data_get[baseid]
        local name = ColorHelper.color_item_name(item.quality, item.name)

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("拆分后可获得<color='#00ff00'>%s个</color>绑定的%s，是否拆分?"), num, name)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function ()
            EquipStrengthManager.Instance:request10623(itemData.id)
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
    self:Closetips()
end

-- 收藏
function TipsModel:Collect(handbookId)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.handbook_main, {1, handbookId})
    self:Closetips()
end

-- 转换
function TipsModel:Convert(itemData)
    local confirmData = NoticeConfirmData.New()
    if DataItem.data_get[itemData.base_id].sex == 2 then
        confirmData.content = string.format(TI18N("是否确认将<color='#ffff00'>%s</color>转换为<color='#ffff00'>%s</color>？"), DataItem.data_get[itemData.base_id].name, DataItem.data_get[DataItem.data_change[itemData.base_id].new_base_id].name)
    else
        confirmData.content = string.format(TI18N("是否确认将<color='#ffff00'>%s(%s)</color>转换为<color='#ffff00'>%s(%s)</color>？"), DataItem.data_get[itemData.base_id].name, KvData.sex[DataItem.data_get[itemData.base_id].sex+1], DataItem.data_get[DataItem.data_change[itemData.base_id].new_base_id].name, KvData.sex[DataItem.data_get[DataItem.data_change[itemData.base_id].new_base_id].sex+1])
    end
    confirmData.sureCallback = function() BackpackManager.Instance:Send10336(itemData.id) end
    NoticeManager.Instance:ConfirmTips(confirmData)
    self:Closetips()
end

-- ---------------------------------------- -----------------------------------------
-- 获取途径处理
-- 有获取途径的，整体布局在中间，同时不显示获取途径按钮，把获取信息自动展示
-- ------------------------------------------ ----------------------------------------
function TipsModel:CheckIsDrop(info)
    -- BaseUtils.dump(info,"fdsfsd")
    local dropstr = ""
    local itemData = info.itemData
    if info.extra == nil or (not info.extra.inbag and not info.extra.nobutton) then
        -- print("3")
        for i, data in ipairs(itemData.tips_type) do
            if data.tips == 2 then
                dropstr = data.val
                return dropstr
            end
        end
    end
    return dropstr
end

-- --------------------------------------------------------------------------------
-- 显示模型
-- 整体布局居中
-- --------------------------------------------------------------------------------

function TipsModel:CheckShowModel(info)
    local itemData = info.itemData
    for _,v in pairs(itemData.effect_client) do
        if v.effect_type_client == 19 then
            return v.val_client
        end
    end
    return nil
end

--存入仓库
function TipsModel:InStore(item)
    BackpackManager.Instance.storeModel:InStore(item)
    self:Closetips()
end

--仓库取出
function TipsModel:OutStore(item)
    BackpackManager.Instance.storeModel:OutStore(item)
    self:Closetips()
end

--放置
function TipsModel:Place(item)
    EventMgr.Instance:Fire(event_name.home_warehouse_out, item)
    self:Closetips()
end

--宠物刻印
function TipsModel:Mark(item)
    PetManager.Instance.model:OpenPetStoneMarkWindow(item)
    self:Closetips()
end

-- 护符熔炼
function TipsModel:Melt(item)
    if item == nil then
        self:Closetips()
        return
    end

    local petBase = DataPet.data_pet_gem_reset[item.base_id]
    if petBase == nil then
        self:Closetips()
        return
    end

    local skillname = ""
    for i,v in ipairs(item.attr) do
        if v.val ~= 0 then
            if v.name == 100 then
                local skill = DataSkill.data_petSkill[string.format("%s_1", v.val)]
                if skill ~= nil then
                    if skillname == "" then
                        skillname = string.format("  <color='#00ffff'>[%s]</color>", skill.name)
                    else
                        skillname = skillname .. "\n" .. string.format("  <color='#00ffff'>[%s]</color>", skill.name)
                    end
                end
            end
        end
    end

    local name = ColorHelper.color_item_name(item.quality, string.format("[%s]", item.name))

    local min = 0
    local max = 0
    for i,v in ipairs(petBase.tournament) do
        if min == 0 then
            min = v[1]
        else
            min = math.min(min, v[1])
        end

        if max == 0 then
            max = v[1]
        else
            max = math.max(max, v[1])
        end
    end
    local val = string.format("%s~%s", min, max)

    local t = 0
    if item.base_id == 20616 then
        -- 月亮
        t = PetManager.Instance.moonTimes
    elseif item.base_id == 20617 then
        -- 太阳
        t = PetManager.Instance.sunTimes
    end

    local percent = 0
    local tt = 0
    for i,v in ipairs(petBase.percent) do
        local times = v[1]
        local val = v[2]

        if t < times then
            percent = math.max(percent, val)
        else
            if tt == 0 then
                tt = times
            else
                tt = math.max(tt, times)
            end
        end
    end

    percent = 100 - percent

    local str = ""
    if percent == 0 then
        str = string.format(TI18N("本周已熔炼:{string_2,#ffff00,%s次}"), t)
    else
        str = string.format(TI18N("本周已熔炼:{string_2,#ffff00,%s次}(超过{string_2,#ffff00,%s}次衰减{string_2,#00ff00,%s%%})"), t, tt, percent)
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("是否熔炼%s，熔炼可随机获得{string_2,#00ff00,%s}{assets_2,90020}\n{string_2,#ffff00,(熔炼后护符将消失)}\n\n%s\n\n附带技能:\n%s"), name, val, str, skillname)
    -- data.content = string.format("%s%s%s{assets_1,90020,%s}{string_2,#ffff00,%s}\n\n%s\n%s", TI18N("是否熔炼"), name, TI18N("，熔炼可获得"), val, TI18N("(熔炼后护符将消失)"), TI18N("附带技能:"), skillname)
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function () PetManager.Instance:Send10549(item.id) end
    NoticeManager.Instance:ConfirmTips(data)
    self:Closetips()
end

-- 宠物技能锁定
function TipsModel:PetSkilllLock(item, extra)
    for __, break_skill in ipairs(PetManager.Instance.model.cur_petdata.base.lev_break_skills) do
        if break_skill == item.id then
            NoticeManager.Instance:FloatTipsByString(TI18N("突破技能永久存在，不可锁定"))
            self:Closetips()
            return
        end
    end
    if PetManager.Instance.model:HasLockSkill(PetManager.Instance.model.cur_petdata) then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前宠物锁定技能已达到最大数量"))
    else
        if item ~= nil and extra ~= nil then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("确定要<color='#ffff00'>锁定</color>宠物技能<color='#00ff00'>[%s]</color>吗？被锁定的技能在<color='#ffff00'>学习技能时</color>不会被覆盖\n<color='#00ff00'>锁定后每次学习技能消耗一个技能认证书</color>"), item.name)
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = function () PetManager.Instance:Send10553(extra.petId, item.id) end
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
    self:Closetips()
end

-- 宠物技能解锁
function TipsModel:PetSkilllUnLock(item, extra)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("确定要<color='#ffff00'>解锁</color>宠物技能<color='#00ff00'>[%s]</color>吗？解除锁定后学习技能将有几率覆盖该技能"), item.name)
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.cancelSecond = 180
    data.sureCallback = function ()  PetManager.Instance:Send10553(extra.petId, item.id) end
    NoticeManager.Instance:ConfirmTips(data)
    self:Closetips()
end

-- 合并变身果
function TipsModel:CombineFruit(item)
    local base_id = item.base_id
    local list = BackpackManager.Instance:GetItemByBaseid(base_id)
    local fruit_lev = 0 
    local fruit_extra = item.extra
    if item.type == BackpackEumn.ItemType.limit_fruit then
        for i,v in pairs(item.extra) do
            for k,extra in pairs(item.extra) do
                if extra.name == BackpackEumn.ExtraName.fruit_lev then
                    fruit_lev = extra.value
                end
            end
        end
    end
    -- fruit_lev  当前选中幻化果等级
    -- if fruit_lev ~= 0 then
    --     NoticeManager.Instance:FloatTipsByString("当前幻化果不能合并哦")
    --     return
    -- end
    local counter_currlev = 0  --属性等级相同幻化果数量
    local counter_itemlev = {} --和选中幻化果等级相同的幻化果列表（高等级）
    local counter = 0   --非等级幻化果数量
    local times = 0
    if #list > 1 then
        for i,v in ipairs(list) do
            if v.type == BackpackEumn.ItemType.limit_fruit then
                -- 限量果实显示使用次数
                local fruit_time = 0    
                local fruit_lev_ext = 0  --当前索引果实等级
                if v.extra ~= nil then
                    for k,extra in pairs(v.extra) do
                        if extra.name == BackpackEumn.ExtraName.fruit_time then
                            fruit_time = extra.value
                        end
                        if extra.name == BackpackEumn.ExtraName.fruit_lev then
                            fruit_lev_ext = extra.value
                            if fruit_lev == fruit_lev_ext and fruit_lev ~= 0 then
                                table.insert(counter_itemlev, v)
                            end
                        end
                    end
                    if fruit_lev_ext == 0 and fruit_time ~= 0 then
                        --找到一个非等级幻化果
                        times = times + fruit_time
                        counter = counter + 1
                    end
                end
            end
        end
        if next(counter_itemlev) ~= nil then
            local curr_attrList = self:GetFruitAttrType(fruit_extra)
            for i,v in pairs(counter_itemlev) do
                if v ~= nil then
                    local attrList = self:GetFruitAttrType(v.extra)
                    if next(curr_attrList) ~= nil and next(attrList) ~= nil and BaseUtils.sametab(curr_attrList, attrList) then
                        counter_currlev = counter_currlev + 1
                    end
                end
            end
        end
        
        local maxTime = DataItem.data_fruit[tonumber(base_id)].num
        if times == 0 then
            times = maxTime
        end
    end
    if counter_currlev > 1 then
        --选中的是高等级，且有相同属性
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("是否确认合并所有的同属性<color='#ffff00'>[%sLv%s]</color>？"), item.name, fruit_lev)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function ()
            BackpackManager.Instance:Send10340(item.id)
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif counter_currlev <= 1 and fruit_lev > 0 then
        --选中的是高等级，但没相同属性
        NoticeManager.Instance:FloatTipsByString(TI18N("拥有多个幻化果时才能合并喔{face_1,2}"))
    elseif counter > 1 then
        times = math.max(times, 1)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("将合并背包中所有<color='#ffff9a'>[%s]</color>的使用次数，合并之后可有<color='#ffff00'>%s次</color>使用次数，同时变为<color='#ffff00'>绑定道具</color>，是否继续？"), item.name, times)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function () BackpackManager.Instance:Send10334(base_id) end
        NoticeManager.Instance:ConfirmTips(data)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("拥有多个幻化果时才能合并喔{face_1,2}"))
    end

    self:Closetips()
end

function TipsModel:GetFruitAttrType(extra)
    local tempAttr = {}
    for j,k in pairs(extra) do
        if k.name == BackpackEumn.ExtraName.fruit_lev1_type then
            tempAttr[k.value] = 1
        elseif k.name == BackpackEumn.ExtraName.fruit_lev2_type then
            if tempAttr[k.value] ~= nil then
                tempAttr[k.value] = tempAttr[k.value] + 1
            else
                tempAttr[k.value] = 1
            end
        elseif k.name == BackpackEumn.ExtraName.fruit_lev3_type then
            if tempAttr[k.value] ~= nil then
                tempAttr[k.value] = tempAttr[k.value] + 1
            else
                tempAttr[k.value] = 1
            end
        end
    end
    return tempAttr
end

-- 目前仅支持查看自身法宝
-- function TipsModel:ShowTalisman(info)
function TipsModel:ShowTalisman(info)
    self:Closetips()
    local itemObj =  info.gameObject
    self.currentItem = info
    local func = function()
        self.talismanTips:UpdateInfo(info.itemData, info.extra)
        -- self:BeforeShow(self.talismanTips, info)
    end
    self.talismanTips:Show(func)
    self.isShowTailsManTips = true
end

function TipsModel:ShowTalismanAttr(info)
    self:Closetips()
    self.currentItem = info
    local func = function()
        self.talismanTipsAttr:UpdateInfo(info.attrNow, info.attrOrigin, info.extra)
    end
    self.talismanTipsAttr:Show(func)
end

function TipsModel:ShowRules(info)
    self:Closetips()
    self.currentItem = info
    local itemObj = info.gameObject
    local func = function()
        self.rulesTips:UpdateInfo(info)
        self:Locate(itemObj.transform, self.rulesTips.gameObject, {w = self.rulesTips.width, h = self.rulesTips.height})
    end
    self.rulesTips:Show(func)
end

-- 职业转换
function TipsModel:Change(item, extra)
    local noticeData = NoticeConfirmData.New()
    noticeData.content = string.format(TI18N("<color='#ffff00'>%s</color>（%s）与本职业不符，是否<color='#ffff00'>转换？</color>"), item.name, KvData.classes_name[item.classes])
    noticeData.sureCallback = function() BackpackManager.Instance:Send10338(item.id) end
    NoticeManager.Instance:ConfirmTips(noticeData)
end

--打开选择时装礼包界面
function TipsModel:OpenSelectSuitPanel(args)
    if self.selectsuitPanel == nil then
        self.selectsuitPanel = BackPackSelectSuitPanel.New(self)
    end
    self.selectsuitPanel:Show(args)
end
function TipsModel:CloseSelectSuitPanel()
    if self.selectsuitPanel ~= nil then
        self.selectsuitPanel:DeleteMe()
        self.selectsuitPanel = nil
    end
end

function TipsModel:ShowChance(info)
    --isMutil 控制位置
    --chanceId /chanceData 控制 哪种文字表现
    if not info.special then
        self:Closetips()
    end
    self.currentItem = info
    local itemObj = info.gameObject
    local func = function()
        self.chanceshowTips:UpdateInfo(info)
        local rect = self.chanceshowTips.transform
        --:GetComponent(RectTransform)
        if not info.isMutil then
            rect.anchorMax = Vector2(0, 0)
            rect.anchorMin = Vector2(0, 0)
            rect.pivot = Vector2(0, 0)
            self:Locate(itemObj.transform, self.chanceshowTips.gameObject, {w = self.chanceshowTips.transform.sizeDelta.x, h = self.chanceshowTips.transform.sizeDelta.y})
        else
            rect.anchorMax = Vector2(0.5, 0.5)
            rect.anchorMin = Vector2(0.5, 0.5)
            rect.pivot = Vector2(0, 0.5)
            rect.anchoredPosition = Vector2(0,0)
        end
    end
    self.chanceshowTips:Show(func)
end
--打开二次确认panel
function TipsModel:OpentwiceConfirmPanel(args)
    if self.twiceconfirmPanel == nil then
        self.twiceconfirmPanel = TwiceConfirmPanel.New(self,args)
    end
    self.twiceconfirmPanel:Show()
end
function TipsModel:ClosetwiceConfirmPanel()
    if self.twiceconfirmPanel ~= nil then
        self.twiceconfirmPanel:DeleteMe()
        self.twiceconfirmPanel = nil
    end
end
