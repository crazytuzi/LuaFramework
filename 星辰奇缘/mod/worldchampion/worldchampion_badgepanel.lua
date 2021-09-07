WorldChampionBadgePanel = WorldChampionBadgePanel or BaseClass(BasePanel)

function WorldChampionBadgePanel:__init(parent,model)
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.worldchampionbadgepanel, type = AssetType.Main},
        {file = AssetConfig.no1inworldbadge_textures, type = AssetType.Dep},
        --{file  = AssetConfig.childbirth_textures, type  =  AssetType.Dep},
        --{file = AssetConfig.base_textures, type = AssetType.Dep},
        --{file = AssetConfig.glory_textures, type = AssetType.Dep},
        --{file = AssetConfig.exquisite_shelf_textures, type = AssetType.Dep},
        --{file = AssetConfig.childrentextures, type = AssetType.Dep},
    }


    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.onNumChange = function()  self:SetNum() end -- self:ShowButtonEfc()
    self.setData = function (data) self:SetData(data)  end
end

function WorldChampionBadgePanel:OnShow()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.onNumChange)
    WorldChampionManager.Instance.onStarChange:AddListener(self.setData)

    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end

end

function WorldChampionBadgePanel:OnInitCompleted()
    WorldChampionManager.Instance:Require16431()
    self:SetNum()
end

function WorldChampionBadgePanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.onNumChange)
    WorldChampionManager.Instance.onStarChange:RemoveListener(self.setData)
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function WorldChampionBadgePanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end

    if self.upEffect ~= nil then
        self.upEffect:DeleteMe()
        self.upEffect = nil
    end

    if self.unlockEffect ~= nil then
        self.unlockEffect:DeleteMe()
        self.unlockEffect = nil
    end

    if self.processEffect ~= nil then
        self.processEffect:DeleteMe()
        self.processEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionBadgePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionbadgepanel))
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t
    self.button = t:Find("Button")

    self.numTxt = t:Find("Item/num"):GetComponent(Text)
    self.btnTxt = self.button:Find("Text"):GetComponent(Text)
    self.button.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickBtn() end)
    self.starList = {}
    self.starBtn = {}
    local star = t:Find("Star")
    for i=1,5 do
        self.starList[i] = star:GetChild(i-1)
        self.starBtn[i] = star:GetChild(i-1).gameObject:GetComponent(Button)
    end
    self.badgeBtn = t:Find("Process/Image"):GetComponent(Button)

    self.process = t:Find("Process"):GetComponent(Image)
    self.processEft = t:Find("Process/eft"):GetComponent(RectTransform)
    self.lvlupEft = t:Find("Effect"):GetComponent(RectTransform)
    self.lvlupEft.localPosition = Vector2(-200,-19)
    self.lvlupEft.transform:SetParent(star)
    local itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(t:Find("Item/Slot"), itemSlot.gameObject)
    local itemBaseData = BackpackManager:GetItemBase(22785)
    local itemData = ItemData.New()
    itemData:SetBase(itemBaseData)
    itemSlot:SetAll(itemData, { nobutton = true })

    self.reward1 = t:Find("Bg/Reward1"):GetComponent(RectTransform)
    self.reward2 = t:Find("Bg/Reward2"):GetComponent(RectTransform)
    self.reward1Name = t:Find("Bg/Reward1/name"):GetComponent(Text)
    t:Find("Bg/Reward2/name"):GetComponent(Text).text = TI18N("随机王者徽章")
    self.rewardId = 21168

    self.title = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.reward2.gameObject:GetComponent(Button).onClick:AddListener(function ()
        NoticeManager.Instance:FloatTipsByString(TI18N("马上就能解锁新徽章了，想想还有点小激动呢{face_1,10}"))
    end)



    if self.processEffect == nil then
        self.processEffect = BaseUtils.ShowEffect(20161, self.processEft.transform, Vector3(1,1,1), Vector3(0,0,100))
    end
    self.processEft.gameObject:SetActive(false)
    self.canClick = true
    self:OnShow()
    self.Mgr.showProcessEft = function() self:ShowProcessEft()  end

end

function WorldChampionBadgePanel:SetNum()
    self.numTxt.text = string.format(TI18N("王者之心：<color='#ae38d5'>%s</color>/%s"), BackpackManager.Instance:GetItemCount(22785),1)
end


function WorldChampionBadgePanel:SetData(data)
    self.data = data
    local sumCount = DataTournament.data_get_kingbadge[self.data.num].costnum
    if sumCount ~= 0 then
        self.process.fillAmount = data.starlev/sumCount
        for i=1,5 do
            self.starList[i].gameObject:SetActive(false)
        end
        self.showStar = {}
        if sumCount == 1 then
            table.insert(self.showStar,3)
        elseif sumCount == 2 then
            table.insert(self.showStar,2)
            table.insert(self.showStar,4)
        elseif sumCount == 3 then
            table.insert(self.showStar,1)
            table.insert(self.showStar,3)
            table.insert(self.showStar,5)
        elseif sumCount == 5 then
            table.insert(self.showStar,1)
            table.insert(self.showStar,2)
            table.insert(self.showStar,3)
            table.insert(self.showStar,4)
            table.insert(self.showStar,5)
        end
        BaseUtils.dump(self.showStar,"显示的星")
        for k,v in pairs(self.showStar) do
            self.starList[v].gameObject:SetActive(true)
            self.starBtn[v].onClick:RemoveAllListeners()
            self.starBtn[v].onClick:AddListener(function ()
                NoticeManager.Instance:FloatTipsByString(string.format("%s%s%s", TI18N("再点亮"),sumCount-data.starlev,TI18N("个王者之心可获得新徽章{face_1,18}")))
            end)
        end
        self.badgeBtn.onClick:RemoveAllListeners()
        self.badgeBtn.onClick:AddListener(function ()
                NoticeManager.Instance:FloatTipsByString(string.format("%s%s%s", TI18N("再点亮"),sumCount-data.starlev,TI18N("个王者之心可获得新徽章{face_1,18}")))
            end)
        for i=1,sumCount do
            if i > self.data.starlev  then
                self.starList[self.showStar[i]].gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "star2")
            else
                self.starList[self.showStar[i]].gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "star1")
            end
        end


        for k,v in pairs(DataTournament.data_get_rewards) do
            if v.bg_num == data.num and v.star_lev == data.starlev then
                self.rewardId = v.gift_id
            end
        end

        if data.starlev == sumCount -1 then
            self.btnTxt.text = TI18N("解锁")
            self.reward2.gameObject:SetActive(true)
            self.reward1.localPosition = Vector2(-66,9)
            self.title.text = TI18N("徽章解锁 可获得奖励")


            if self.itemSlot == nil then
                self.itemSlot = ItemSlot.New()
                UIUtils.AddUIChild(self.transform:Find("Bg/Reward1"), self.itemSlot.gameObject)
            end
            local itemBaseData = BackpackManager:GetItemBase(self.rewardId)
            local itemData = ItemData.New()
            itemData:SetBase(itemBaseData)
            self.itemSlot:SetAll(itemData, { nobutton = true })
            self.reward1Name.text = itemData.name


        else
            self.btnTxt.text = TI18N("升星")
            self.reward2.gameObject:SetActive(false)
            self.reward1.localPosition = Vector2(0,9)
            self.title.text = TI18N("升星可获得奖励")

            if self.itemSlot == nil then
                self.itemSlot = ItemSlot.New()
                UIUtils.AddUIChild(self.transform:Find("Bg/Reward1"), self.itemSlot.gameObject)
            end
            local itemBaseData = BackpackManager:GetItemBase(self.rewardId)
            local itemData = ItemData.New()
            itemData:SetBase(itemBaseData)
            self.itemSlot:SetAll(itemData, { nobutton = true })
            self.reward1Name.text = itemData.name

        end
        self.processEft.localRotation = Quaternion.Euler(0,0,self.process.fillAmount*360)
        self.processEft.localPosition = Vector3(-math.sin(self.process.fillAmount*2*math.pi ),-math.cos(self.process.fillAmount*2* math.pi),-20)*54

    else
        self.reward2.gameObject:SetActive(true)
        self.reward1.localPosition = Vector2(-66,9)
        self.title.text = TI18N("恭喜解锁完毕，敬请期待新徽章")
        self.button.gameObject:GetComponent(Button).interactable = false
        self.button.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.btnTxt.color = Color(198/255, 247/255, 253/255, 1)
        for i=1,5 do
            self.starList[i].gameObject:SetActive(true)
            self.starList[i].gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "star1")
        end

        if self.itemSlot == nil then
            self.itemSlot = ItemSlot.New()
            UIUtils.AddUIChild(self.transform:Find("Bg/Reward1"), self.itemSlot.gameObject)
        end
        local itemBaseData = BackpackManager:GetItemBase(self.rewardId)
        local itemData = ItemData.New()
        itemData:SetBase(itemBaseData)
        self.itemSlot:SetAll(itemData, { nobutton = true })
        self.reward1Name.text = itemData.name

    end

end

function WorldChampionBadgePanel:OnClickBtn()
    if self.canClick == false then
        return
    end
    if BackpackManager.Instance:GetItemCount(22785) == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("武道会到达<color='#ffff00'>最强王者</color>可获得王者之心{face_1,22}"))
        return
    end
    self.canClick = false
    local sumCount = DataTournament.data_get_kingbadge[self.data.num].costnum

    self.lvlupEft.localPosition =  self.starList[self.showStar[self.data.starlev + 1]].gameObject:GetComponent(RectTransform).localPosition

    if self.upEffect == nil then
        self.upEffect = BaseUtils.ShowEffect(20426, self.lvlupEft.transform, Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.upEffect:SetActive(true)
    SoundManager.Instance:Play(268)
    self.starList[self.showStar[self.data.starlev + 1]].gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldbadge_textures, "star1")

    if self.data.starlev == sumCount -1 then
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 10, function() self:UpStar(true) end)
            self.processEft.gameObject:SetActive(true)
        end
    else
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 10, function() self:UpStar(false) end)
            self.processEft.gameObject:SetActive(true)
        end
    end
end


function WorldChampionBadgePanel:UpStar(isUnlock)

    local sumCount = DataTournament.data_get_kingbadge[self.data.num].costnum
    if self.process.fillAmount < (self.data.starlev + 1 )/sumCount then
        self.process.fillAmount = self.process.fillAmount + 0.005 * 5/sumCount
        self.processEft.localRotation = Quaternion.Euler(0,0,self.process.fillAmount*360)
        self.processEft.localPosition = Vector3(-math.sin(self.process.fillAmount*2*math.pi ),-math.cos(self.process.fillAmount*2* math.pi),-20)*54
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end

        -- self.lvlupEft.localPosition =  self.starList[self.showStar[self.data.starlev + 1]].gameObject:GetComponent(RectTransform).localPosition

        -- if self.upEffect == nil then
        --     self.upEffect = BaseUtils.ShowEffect(20426, self.lvlupEft.transform, Vector3(1,1,1), Vector3(0,0,-1000))
        -- end
        -- self.upEffect:SetActive(true)
        -- SoundManager.Instance:Play(268)
        -- self.starList[self.showStar[self.data.starlev + 1]].gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "star1")
        self.processEft.gameObject:SetActive(false)
        if isUnlock == true then
            -- LuaTimer.Add(1000,function ()
                if self.unlockEffect == nil then
                    self.unlockEffect = BaseUtils.ShowEffect(20427, self.process.transform, Vector3(1,1,1), Vector3(0,0,-1000))
                end
                self.unlockEffect:SetActive(true)
                SoundManager.Instance:Play(262)
            -- end)
        end
        if isUnlock == true then
            LuaTimer.Add(1000, function()
                WorldChampionManager.Instance:Require16432(1)
                if self.upEffect ~= nil then
                    self.upEffect:DeleteMe()
                    self.upEffect = nil
                end
                if self.unlockEffect ~= nil then
                    self.unlockEffect:DeleteMe()
                    self.unlockEffect = nil
                end
                LuaTimer.Add(200,function () self.processEft.gameObject:SetActive(false) end)
            end)
        else
            -- LuaTimer.Add(1000, function()
                WorldChampionManager.Instance:Require16432(0)
                if self.upEffect ~= nil then
                    self.upEffect:DeleteMe()
                    self.upEffect = nil
                end
                LuaTimer.Add(200,function () self.processEft.gameObject:SetActive(false) end)
            -- end)
        end
    end
end

function WorldChampionBadgePanel:ShowProcessEft()
    --self.processEft.gameObject:SetActive(true)
    self.canClick = true
end




