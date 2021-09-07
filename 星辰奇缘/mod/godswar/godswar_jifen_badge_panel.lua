-- ----------------------------
-- 诸神之战  积分徽章主界面
-- zyh
-- ----------------------------

GodsWarJiFenBadgePanel = GodsWarJiFenBadgePanel or BaseClass(BasePanel)

function GodsWarJiFenBadgePanel:__init(parent)
    self.model = GodsWarManager.Instance.model
    self.parent = parent
    self.effectPath = "prefabs/effect/20009.unity3d"
    self.effect = nil

    self.resList = {
        {file = AssetConfig.godswarjifenbadgepanel, type = AssetType.Main},
         {file = AssetConfig.godswarjifenbg, type = AssetType.Main},
         {file = AssetConfig.godswartexture, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenlight, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenCircleBg, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1001, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1002, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1003, type = AssetType.Dep},
          {file = AssetConfig.godswarjifenBadge1004, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1005, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1006, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenBadge1000, type = AssetType.Dep},

    }



    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.roleListener = function() self:UpdateRoleStatus() end

    self.startObjList = {}
    self.startObjList2 = {}
    self.itemList = {}

    self.rotateId = nil
    self.timerId = nil
    self.extra = {inbag = false, nobutton = true}
    self.isInit = false
end

function GodsWarJiFenBadgePanel:__delete()
    self:OnHide()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.timerId ~= nil then
      LuaTimer.Delete(self.timerId)
      self.timerId = nil
  end

    if self.itemList ~= nil then
        for k,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end

    if self.leftCircleBg ~= nil and self.leftCircleBg.sprite ~= nil then
        self.leftCircleBg.sprite = nil
    end

    if self.leftLightBg ~= nil and self.leftLightBg.sprite ~= nil then
        self.leftLightBg.sprite = nil
    end

    if self.rightCircleBg ~= nil and self.rightCircleBg.sprite ~= nil then
        self.rightCircleBg.sprite = nil
    end

    if self.rightLightBg ~= nil and self.rightLightBg.sprite ~= nil then
        self.rightLightBg.sprite = nil
    end

    if self.rightBadgeImage ~= nil and self.rightBadgeImage.sprite ~= nil then
        self.rightBadgeImage.sprite = nil
    end

    if self.leftBadgeImage ~= nil and self.leftBadgeImage.sprite ~= nil then
        self.leftBadgeImage.sprite = nil
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
end

function GodsWarJiFenBadgePanel:AddAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarData:AddListener(self.roleListener)
end

function GodsWarJiFenBadgePanel:RemoveAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarData:RemoveListener(self.roleListener)
end

function GodsWarJiFenBadgePanel:OnHide()
    self:RemoveAllListeners()

    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    --     self.timerId = nil
    -- end

     if self.rotateId ~= nil then
        Tween.Instance:Cancel(self.rotateId)
       self.rotateId = nil
    end
end

function GodsWarJiFenBadgePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarjifenbadgepanel))
    self.gameObject.name = "GodsWarJiFenBadgePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(-2,-7)

    self.bigBg = self.transform:Find("BadgeBg/BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarjifenbg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    bigObj.transform.localScale = Vector3(0.97,0.97,1)

    self.leftCircleBg = self.transform:Find("BadgeBg/LeftBadge"):GetComponent(Image)
    self.leftLightBg = self.transform:Find("BadgeBg/LeftBadge/Light"):GetComponent(Image)

    self.leftCircleBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenCircleBg,"GodsWarCircleBg")
    self.leftLightBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenlight,"GodsWarLightBg")

    self.rightCircleBg = self.transform:Find("BadgeBg/RightBadge"):GetComponent(Image)
    self.rightLightBg = self.transform:Find("BadgeBg/RightBadge/Light"):GetComponent(Image)

    self.rightCircleBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenCircleBg,"GodsWarCircleBg")
    self.rightLightBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenlight,"GodsWarLightBg")

    self.leftLightBg.gameObject:SetActive(true)
    self.rightLightBg.gameObject:SetActive(true)

    self.leftCircleBg.gameObject:SetActive(true)
    self.rightCircleBg.gameObject:SetActive(true)

    self.leftBadgeImage = self.transform:Find("BadgeBg/LeftBadge/Badge"):GetComponent(Image)


    self.rightBadgeImage = self.transform:Find("BadgeBg/RightBadge/Badge"):GetComponent(Image)
    self.rightBadgeButton = self.transform:Find("BadgeBg/RightBadge/Badge"):GetComponent(Button)

    self.rightBadgeButton.onClick:AddListener(function() if self.nextData ~= nil and self.myData ~= nil then
        local tt = self.nextData.need_score - GodsWarManager.Instance.godsWarJiFenData.gods_duel_score
        NoticeManager.Instance:FloatTipsByString(string.format("再获得{assets_1,90056,%s}可晋升{face_1,3}",tt))
        end
    end)

    BaseUtils.SetGrey(self.rightBadgeImage, true, false)

    self.itemContainer = self.transform:Find("BadgeBg/RightBadge/Container")
    self.tabLayout = LuaBoxLayout.New(self.itemContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 0})

    self.startContaner = self.transform:Find("BadgeBg/LeftBadge/Levels")
    self.startContaner2 = self.transform:Find("BadgeBg/RightBadge/Levels")
     self.jifenText = self.transform:Find("BadgeBg/LeftBadge/JifenText"):GetComponent(Text)
    self.slider = self.transform.transform:FindChild("BadgeBg/LeftBadge/ExpSlider"):GetComponent(Slider)
    self.shareChat = self.transform:Find("BadgeBg/LeftBadge/ShareButton"):GetComponent(Button)
    self.shareChat.onClick:AddListener(function()
        WorldChampionManager.Instance.model:OnShareGodsWar()
    end)

    self.noticeBtn = self.transform:Find("BadgeBg/LeftBadge/NoticeButton"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
     TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
       TI18N("1.诸神战斗获胜时可获得<color='#ffff00'>荣誉积分</color>"),
            TI18N("2.历史累计的荣誉积分可提升<color='#ffff00'>神祇</color>"),
            TI18N("3.消耗积分可兑换稀有道具，不影响神祇等级")
            }})
    end)
    for i = 1,3 do
        local go = self.startContaner:GetChild(i - 1).gameObject
        table.insert(self.startObjList,go)
    end


    for i = 1,3 do
        local go = self.startContaner2:GetChild(i - 1).gameObject
        BaseUtils.SetGrey(go.transform:GetComponent(Image), true, false)
        table.insert(self.startObjList2,go)
    end

    self.imgLoader = SingleIconLoader.New(self.transform:Find("BadgeBg/LeftBadge/Jifen").gameObject)
    self.imgLoader:SetSprite(SingleIconType.Item, 90056)

    self.leftTitle = self.transform:Find("BadgeBg/LeftBadge/TitleBg/Text"):GetComponent(Text)
    self.rightTitle = self.transform:Find("BadgeBg/RightBadge/TitleBg/Text"):GetComponent(Text)


    self.startContaner.transform.anchoredPosition = Vector2(0,171)
    self.startContaner2.transform.anchoredPosition = Vector2(0,171)

    if self.timerId == nil then
        self.floatCounter = 0
        self.timerId = LuaTimer.Add(0, 16, function() self:OnFloatItem() end)
    end


    self.OnOpenEvent:Fire()
end

function GodsWarJiFenBadgePanel:OnShow()
    self:RemoveAllListeners()
    self:AddAllListeners()



    if self.rotateId ~= nil then
        Tween.Instance:Cancel(self.rotateId)
       self.rotateId = nil
    end
    self.rotateId = Tween.Instance:RotateZ(self.leftLightBg.gameObject, -720, 30, function() end):setLoopClamp().id




    GodsWarManager.Instance:Send17936()
end

function GodsWarJiFenBadgePanel:OnFloatItem()
    self.floatCounter = self.floatCounter + 1
    local position = self.leftBadgeImage.transform.localPosition
    self.leftBadgeImage.transform.localPosition = Vector2(position.x, position.y + 0.3 * math.sin(self.floatCounter * math.pi / 90 * 1.2))

    for i,v in ipairs(self.startObjList) do
        position = v.transform.localPosition
        v.transform.localPosition = Vector2(position.x, position.y + 0.3 * math.sin(self.floatCounter * math.pi / 90 * 1.2))
    end
end

function GodsWarJiFenBadgePanel:UpdateRoleStatus()
     if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.nextData = nil
    for k,v in pairs(GodsWarManager.Instance.godsWarJiFenAllData.rank_info) do
        if v.rank == GodsWarManager.Instance.godsWarJiFenData.rank_lev then
            self.myData = v
        elseif v.rank == GodsWarManager.Instance.godsWarJiFenData.rank_lev + 1 then
            self.nextData = v
        end
    end
    if self.nextData == nil then
        self.nextData = self.myData
    end

    for i=1,self.myData.star do
        self.startObjList[i].gameObject:SetActive(true)
    end
    if #self.startObjList > self.myData.star then
        for i2=self.myData.star + 1,#self.startObjList do
            self.startObjList[i2].gameObject:SetActive(false)
        end
    end

    if self.myData.star == 1 then
        self.startObjList[1].transform.anchoredPosition = Vector2(-4.2,-66.7)
    end

    if self.myData.star == 2 then
        self.startObjList[1].transform.anchoredPosition = Vector2(-27,-74)
        self.startObjList[2].transform.anchoredPosition = Vector2(27,-74)
    end

    if self.myData.star == 3 then
        self.startObjList[1].transform.anchoredPosition = Vector2(-50,-81.2)
        self.startObjList[2].transform.anchoredPosition = Vector2(-4.2,-66.7)
        self.startObjList[3].transform.anchoredPosition = Vector2(42.3,-79.5)
    end



    for i=1,self.nextData.star do
        self.startObjList2[i].gameObject:SetActive(true)
    end
    if #self.startObjList2 > self.nextData.star then
        for i2=self.nextData.star + 1,#self.startObjList2 do
            self.startObjList2[i2].gameObject:SetActive(false)
        end
    end

    if self.nextData.star == 1 then
        self.startObjList2[1].transform.anchoredPosition = Vector2(-4.2,-66.7)
    end

    if self.nextData.star == 2 then
        self.startObjList2[1].transform.anchoredPosition = Vector2(-27,-74)
        self.startObjList2[2].transform.anchoredPosition = Vector2(27,-74)
    end

    if self.nextData.star == 3 then
        self.startObjList2[1].transform.anchoredPosition = Vector2(-50,-81.2)
        self.startObjList2[2].transform.anchoredPosition = Vector2(-4.2,-66.7)
        self.startObjList2[3].transform.anchoredPosition = Vector2(42.3,-79.5)
    end

    self.leftBadgeImage.transform.localPosition = Vector2(0,0)


    if self.timerId == nil then
        self.floatCounter = 0
        self.timerId = LuaTimer.Add(0, 16, function() self:OnFloatItem() end)
    end

    for i=1,#self.nextData.reward do
        if self.itemList[i] == nil then
            local slot = ItemSlot.New()
            self.tabLayout:AddCell(slot.gameObject)
            self.itemList[i] = slot
        end
        local itemData = ItemData.New()

        itemData:SetBase(DataItem.data_get[self.nextData.reward[i].id])

        self.itemList[i]:SetAll(itemData,self.extra)
        self.itemList[i]:SetNum(self.nextData.reward[i].value)
    end

    if self.myData ~= self.nextData then
        self.slider.value = (GodsWarManager.Instance.godsWarJiFenData.gods_duel_score - self.myData.need_score)/(self.nextData.need_score - self.myData.need_score)
    else
        self.slider.value = 1
    end


    self.leftTitle.text = string.format("%s",self.myData.name)
    self.rightTitle.text = "晋升奖励"

    self.jifenText.text = GodsWarManager.Instance.godsWarJiFenData.gods_duel_score .. "/" .. self.nextData.need_score
    print("徽章id:" .. self.myData.badge_id)
    self.leftBadgeImage.sprite = self.assetWrapper:GetSprite(AssetConfig[string.format("godswarjifenBadge%s",self.myData.badge_id)],"GodsWarBadge" .. self.myData.badge_id)
    self.leftBadgeImage:SetNativeSize()
    self.rightBadgeImage.sprite = self.assetWrapper:GetSprite(AssetConfig[string.format("godswarjifenBadge%s",self.nextData.badge_id)],"GodsWarBadge" .. self.nextData.badge_id)

    self.leftBadgeImage.gameObject:SetActive(true)
    self.rightBadgeImage.gameObject:SetActive(true)
    self.rightBadgeImage:SetNativeSize()

end