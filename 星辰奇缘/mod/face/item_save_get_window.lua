-- ----------------------------------
-- 通用礼包转换界面
-- zyh
-- ----------------------------------

ItemsaveGetWindow = ItemsaveGetWindow or BaseClass(BasePanel)

function ItemsaveGetWindow:__init(model)
    self.model = model
    self.bg1 = "textures/ui/bigbg/gettitle.unity3d"
    self.windowId = WindowConfig.WinID.itemsavegetwindow
    self.resList = {
        {file = AssetConfig.opengiftshowwindow, type = AssetType.Main},

        {file = AssetConfig.guildleaguebig, type = AssetType.Dep},
        {file = self.bg1, type = AssetType.Dep},
        {file = AssetConfig.face_textures, type = AssetType.Dep},
        {file = string.format(AssetConfig.effect, 20417), type = AssetType.Main },
    }
    self.itemList = {}
    self.luaTimeList = {}
    self.currIndex = 0
    self.showing = true
    self.time = 10
    self.isChange = false
    self.OnOpenEvent:Add(function() self:OnOpen() end)
end

function ItemsaveGetWindow:__delete()
    for k,v in pairs(self.itemList) do
        v:DeleteMe()
    end
    self.itemList = {}
    self:EndShow()
    self:EndTime()
    for i,v in ipairs(self.itemList) do
      v:DeleteMe()
    end
    self.itemList = nil

    for k,v in pairs(self.luaTimeList) do
        LuaTimer.Delete(v)
        v = nil
    end

    if self.openEffect ~= nil then
        self.openEffect:DeleteMe()
        self.openEffect = nil
    end

    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end

    if self.timeId1 ~= nil then
        LuaTimer.Delete(self.timeId1)
        self.timeId1 = nil
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

function ItemsaveGetWindow:OnOpen()


    -- self.openArgs ={
    -- item_list = {
    --     [1] = {
    --         type = 1,
    --         val = 100,
    --         number = 1,
    --         own = 1,
    --     }
    --  }
    -- }

    self:InitMyData()

    self.base_id = self.openArgs.id
    local reward = self.openArgs.item_list
    self.data = {}

    for i,item in pairs(reward) do
      table.insert(self.data, item)
    end
    if #self.data <= 5 then
        self.leftBtn.gameObject:SetActive(false)
        self.rightBtn.gameObject:SetActive(false)
    end
    self:Update()

end


--self.openArgs 1:data,
function ItemsaveGetWindow:InitMyData()
    self.isChange = self.openArgs.isChange


    self.myType = self.openArgs.item_list[1].type or 1
    self.num = #self.openArgs.item_list

    if self.isChange == true then
        self.openArgs.item_list[1].type = self.openArgs.item_list[1].type or 1

        if self.num == 2 then

            self.openArgs.item_list[3] = self.openArgs.item_list[2]
            self.openArgs.item_list[3].type = self.openArgs.item_list[2].type or 1
            self.openArgs.item_list[2] = {}
            self.openArgs.item_list[2].type = 3
        else
            -- Log.Error("转换的物品数据个数不对")
        end

        -- BaseUtils.dump(self.openArgs,"转换物品的数据=====================================================================================")

    end
end

function ItemsaveGetWindow:OnHide()
end

function ItemsaveGetWindow:Close()
    if self.showing then
        return
    end

    if self.base_id == 22510 then
        GuideManager.Instance:GuideImprove(true)
    end
    self.model:CloseGetWin()
end

-- function ItemsaveGetWindow:OnClickClose()

-- end

function ItemsaveGetWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.opengiftshowwindow))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform:GetComponent(RectTransform).localPosition = Vector3(0,0,-600)
    local canvas = self.gameObject:GetComponent(Canvas)
    canvas.overrideSorting = true
    canvas.sortingOrder = 40
    canvas.overrideSorting = false


    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Main"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig, "GuildLeague2")
    self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.bg1 , "GetTitle")

    self.desc = self.transform:Find("Main/Desc"):GetComponent(Text)
    self.desc2 = self.transform:Find("Main/Desc2"):GetComponent(Text)
    self.desc2.gameObject:SetActive(true)
    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("点击任意地方关闭")
    self.tipsObj = self.tips.gameObject
    self.tipsObj:SetActive(false)
    self.rightBtn = self.transform:Find("Main/RightBtn"):GetComponent(Button)
    self.leftBtn = self.transform:Find("Main/LeftBtn"):GetComponent(Button)
    self.rightImg = self.rightBtn.gameObject:GetComponent(Image)
    self.leftImg = self.leftBtn.gameObject:GetComponent(Image)
    self.leftTrans = self.leftBtn.gameObject.transform
    self.rightTrans = self.rightBtn.gameObject.transform


    self.container = self.transform:Find("Main/Mask/Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.containerRect.anchoredPosition = Vector2(300,100)
    self.scrollCon = self.transform:Find("Main/Mask/Scroll")
    self.scroll = self.scrollCon:GetComponent(ScrollRect)
    self.scroll.enabled = false
    self.scroll.onValueChanged:AddListener(function() self:OnChange() end)
    local len = self.container.childCount
    self.itemList = {}
    for i = 1, len do
        if self.baseObj == nil then
            self.baseObj = GameObject.Instantiate(self.container:GetChild(i - 1).gameObject)
        end
        local item = nil
        if type == 3 then
            item = NormalGetItem.New(self.container:GetChild(i - 1).gameObject, self)
        else
            item = NormalGetItem.New(self.container:GetChild(i - 1).gameObject, self)
        end
        table.insert(self.itemList, item)
    end

    self.transform:Find("Main/SecondText").gameObject:SetActive(false)

    if self.baseObj ~= nil then
        self.baseObj.transform:SetParent(self.container)
    end

    if self.openEffect == nil then
        self.openEffect = BaseUtils.ShowEffect(20417, self.transform, Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.openEffect:SetActive(false)
    self.openEffect:SetActive(true)


    self:OnOpen()

end

function ItemsaveGetWindow:GetItem(index)
    local item = self.itemList[index]
    if item == nil then
        local obj = GameObject.Instantiate(self.baseObj)
        local trans = obj.transform
        trans:SetParent(self.container)
        trans.localScale = Vector3.one
        trans.localPosition = Vector3((index - 1) * 100, 0, 0)
        item = NormalGetItem.New(obj, self)
        table.insert(self.itemList, item)
    end
    item.gameObject.transform.localPosition = Vector3((index - 1) * 85, 0, 0)
    self.containerRect.sizeDelta = Vector2(index * 100, 100)
    return item
end

function ItemsaveGetWindow:Update()
    SoundManager.Instance:Play(269)
    BaseUtils.dump(self.openArgs,"转换参数===============" )
     self.desc2.text = self.openArgs.desc

     self.desc.gameObject:SetActive(true)
     self.desc.text = self.openArgs.descExtra or ""
    -- if self.faceType == 1 then
    --     self.desc.text = string.format(TI18N("<color='#ffa500'>小表情合成</color>奖励"))
    --     if self.myType == 1 then
    --
    --     else
    --         self.desc2.text = ""
    --     end
    -- else
    --     if self.openArgs.isAngel == true then
    --         self.desc.text = string.format(TI18N("<color='#ffa500'>开启天使飞包</color>奖励"))
    --     else
    --         self.desc.text = string.format(TI18N("<color='#ffa500'>大表情合成</color>奖励"))
    --     end
    --     if self.num == 0 then
    --         if self.myType == 1 then
    --             self.desc2.text = string.format(TI18N("获得<color='#ffa500'>已有</color>大表情,自动转换为<color='#ffa500'>包子币</color>"))
    --         else
    --             self.desc2.text = ""
    --         end
    --     else
    --         self.desc2.text = ""
    --     end
    -- end

    for i,v in ipairs(self.data) do
      local item = self:GetItem(i)
      item:SetData(v)
    end

    self:EndShow()
    self:BeginShow()
end

function ItemsaveGetWindow:EndShow()
    if self.timeId ~= nil then
      LuaTimer.Delete(self.timeId)
      self.timeId = nil
    end
end

function ItemsaveGetWindow:BeginShow()
    if #self.data > 5 then
        self.containerRect.anchoredPosition = Vector3.zero
    else
        self.containerRect.anchoredPosition = Vector2(185,0)
    end
    self.timeId = LuaTimer.Add(0, 100, function() self:Loop() end)
end

function ItemsaveGetWindow:Loop()
    self.currIndex = self.currIndex + 1
    if self.currIndex > #self.data then
        self:EndShow()
        self.timeId1 = LuaTimer.Add(1000, function() self:Reset() end)
    else
        if self.currIndex > 5 then
            local t = self.container.localPosition + Vector3(-110, 0, 0)
            self.tweenId = Tween.Instance:MoveLocal(self.container.gameObject, t, 0.1).id
        end

        local item = self.itemList[self.currIndex]
        if self.isChange == true then
            self.luaTimeList[#self.luaTimeList + 1] = LuaTimer.Add(500, function() self:ApplyMove() end)
        else
            local t = self.container.localPosition + Vector3(-13*(#self.openArgs.item_list - 1), 0, 0)
            self.container.localPosition = t
        end


        if self.isChange == true then
            self.luaTimeList[#self.luaTimeList + 1] = LuaTimer.Add(500, function() item:Show() end)
        else
            self.luaTimeList[#self.luaTimeList + 1] = LuaTimer.Add(500, function() item:Show() end)
        end
    end
end

function ItemsaveGetWindow:ApplyMove()
    if self.container ~= nil then
        local t = self.container.localPosition + Vector3(-25, 0, 0)
        self.moveTweenId = Tween.Instance:MoveLocal(self.container.gameObject,t, 0.1).id
    end
end

function ItemsaveGetWindow:Reset()
    -- self.tweenId = Tween.Instance:MoveLocalX(self.container.gameObject, 0, 0.2).id
    if #self.data > 5 then
        self.scroll.enabled = true
    end
    self.tipsObj:SetActive(true)
    self.showing = false
    self:BeginTime()
end

function ItemsaveGetWindow:OnChange()
    if self.containerRect.anchoredPosition.x < -50 then
        self.leftImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.leftTrans.localScale = Vector3(-1, 1, 1)
    else
        self.leftImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.leftTrans.localScale = Vector3.one
    end

    local m = self.containerRect.rect.width
    if self.containerRect.anchoredPosition.x < - m / 2 then
        self.rightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.rightTrans.localScale = Vector3(-1, 1, 1)
    else
        self.rightImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.rightTrans.localScale = Vector3.one
    end
end

function ItemsaveGetWindow:BeginTime()
    self.tips.text = TI18N("点击任意地方关闭 <color='#00ff00'>3秒</color>")
    self:EndTime()
    self.timeid3 = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function ItemsaveGetWindow:LoopTime()
    self.time = self.time - 1
    if self.time == 0 then
        self:EndTime()
        self:Close()
        return
    end

    self.tips.text = string.format(TI18N("点击任意地方关闭 <color='#00ff00'>%s秒</color>"), self.time)
end

function ItemsaveGetWindow:EndTime()
    if self.timeid3 ~= nil then
        LuaTimer.Delete(self.timeid3)
        self.timeid3 = nil
    end
end