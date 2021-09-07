-- ----------------------------------
-- 打开礼包展示界面
-- hosr
-- ----------------------------------

BackpackGiftShow = BackpackGiftShow or BaseClass(BasePanel)

function BackpackGiftShow:__init(model,deleteCallBack,isFlower)
    self.deleteCallBack = deleteCallBack
  	self.model = model
    self.isFlower = isFlower or false
    self.bg1 = "textures/ui/bigbg/gettitle.unity3d"
  	self.resList = {
        {file = AssetConfig.opengiftshowpanel, type = AssetType.Main},
        {file = AssetConfig.guildleaguebig, type = AssetType.Dep},
        {file = self.bg1, type = AssetType.Dep},
        {file = string.format(AssetConfig.effect, 20417), type = AssetType.Main },
    }
    self.itemList = {}
    self.currIndex = 0
    self.showing = true
    self.time = 4
end

function BackpackGiftShow:__delete()
    if self.deleteCallBack ~= nil then
        self.deleteCallBack()
    end
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

function BackpackGiftShow:OnShow()


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

function BackpackGiftShow:OnHide()
end

function BackpackGiftShow:Close()
    if self.showing then
        return
    end

    if self.base_id == 22510 then
        GuideManager.Instance:GuideImprove(true)
    end
    if self.model ~= nil then
  	     self.model:CloseGiftShow()
    else
        self:DeleteMe()
    end
end

function BackpackGiftShow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.opengiftshowpanel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
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

    self.secondText = self.transform:Find("Main/SecondText"):GetComponent(Text)
    if self.isFlower == true then
        self.secondText.gameObject:SetActive(true)
    else
        self.secondText.gameObject:SetActive(false)
    end

    self.container = self.transform:Find("Main/Mask/Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.scrollCon = self.transform:Find("Main/Mask/Scroll")
    self.scroll = self.scrollCon:GetComponent(ScrollRect)
    self.scroll.enabled = false
    self.scroll.onValueChanged:AddListener(function() self:OnChange() end)
    local len = self.container.childCount


    for i = 1, len do
        if self.baseObj == nil then
            self.baseObj = GameObject.Instantiate(self.container:GetChild(i - 1).gameObject)
        end
        local item = BackpackGiftShowItem.New(self.container:GetChild(i - 1).gameObject, self)
        table.insert(self.itemList, item)
    end

    if self.baseObj ~= nil then
        self.baseObj.transform:SetParent(self.container)
    end

    if self.openEffect == nil then
        self.openEffect = BaseUtils.ShowEffect(20417, self.transform, Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.openEffect:SetActive(false)
    self.openEffect:SetActive(true)


    self:OnShow()

end

function BackpackGiftShow:GetItem(index)
    local item = self.itemList[index]
    if item == nil then
        local obj = GameObject.Instantiate(self.baseObj)
        local trans = obj.transform
        trans:SetParent(self.container)
        trans.localScale = Vector3.one
        trans.localPosition = Vector3((index - 1) * 100, 0, 0)
        item = BackpackGiftShowItem.New(obj, self)
        table.insert(self.itemList, item)
    end


    self.containerRect.sizeDelta = Vector2(index * 100, 100)
    return item
end

function BackpackGiftShow:Update()
    SoundManager.Instance:Play(269)
    local gift = DataItem.data_get[self.base_id]
    if gift ~= nil then
        self.desc.text = string.format(TI18N("%s奖励"), ColorHelper.color_item_name(gift.quality, gift.name))
    end
    if self.base_id == 1 then
        self.desc.text = TI18N("翅膀收藏奖励")
    end
    for i,v in ipairs(self.data) do
      local item = self:GetItem(i)
      item:SetData(v)

      if self.isFlower == true then
        self.secondText.text = DataCampaignCollection.data_get_all_flowers[v.id]
      end
    end



    self:EndShow()
    self:BeginShow()
end

function BackpackGiftShow:EndShow()
    if self.timeId ~= nil then
      LuaTimer.Delete(self.timeId)
      self.timeId = nil
    end
end

function BackpackGiftShow:BeginShow()
    if #self.data > 5 then
        self.containerRect.anchoredPosition = Vector3.zero
    else
        self.containerRect.anchoredPosition = Vector3.zero + Vector3(50,0,0)*(5-#self.data)
    end
    self.timeId = LuaTimer.Add(0, 100, function() self:Loop() end)
end

function BackpackGiftShow:Loop()
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
        item:Show()
    end
end

function BackpackGiftShow:Reset()
    -- self.tweenId = Tween.Instance:MoveLocalX(self.container.gameObject, 0, 0.2).id
    if #self.data > 5 then
        self.scroll.enabled = true
    end
    self.tipsObj:SetActive(true)
    self.showing = false
    self:BeginTime()
end

function BackpackGiftShow:OnChange()
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

function BackpackGiftShow:BeginTime()
    self.tips.text = TI18N("点击任意地方关闭 <color='#00ff00'>3秒</color>")
    self:EndTime()
    self.timeid3 = LuaTimer.Add(0, 1000, function() self:LoopTime() end)
end

function BackpackGiftShow:LoopTime()
    self.time = self.time - 1
    if self.time == 0 then
        self:EndTime()
        self:Close()
        return
    end

    self.tips.text = string.format(TI18N("点击任意地方关闭 <color='#00ff00'>%s秒</color>"), self.time)
end

function BackpackGiftShow:EndTime()
    if self.timeid3 ~= nil then
        LuaTimer.Delete(self.timeid3)
        self.timeid3 = nil
    end
end