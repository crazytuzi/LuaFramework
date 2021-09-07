-- @author 黄耀聪
-- @date 2017年5月20日

RiceDumplingPanel = RiceDumplingPanel or BaseClass(BasePanel)

function RiceDumplingPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RiceDumplingPanel"

    self.resList = {
        {file = AssetConfig.rice_dumpling, type = AssetType.Main}
        ,{file = AssetConfig.LabaTerrorBg, type = AssetType.Main}
        ,{file = AssetConfig.rolebgnew, type = AssetType.Dep}
        ,{file = AssetConfig.dragonboat_textures, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = AssetConfig.halloween_textures, type = AssetType.Dep}
        ,{file = AssetConfig.Laba_top_Txt1, type = AssetType.Dep}
        ,{file = AssetConfig.Laba_top_Txt2, type = AssetType.Dep}
    }

    self.posPlan = {
        [1] = {Vector2(0, 0)},
        [2] = {Vector2(-39, 0), Vector2(39, 0)},
        [3] = {Vector2(0, 38), Vector2(-39, -38), Vector2(39, -38)},
        [4] = {Vector2(-39, 38), Vector2(39, 38), Vector2(-39, -38), Vector2(39, -38)},
    }

    self.dumplingList = {}
    self.materialsList = {}

    self.bg = nil
    self.campDataGroup = nil
    self.buyNum = 1

    self.updateListener = function(code, show) self:Update(code, show) end
    self.reloadListener = function() self:ReloadDumplings() if self.lastIndex ~= nil then self:OnClick(self.lastIndex) end end
    self.redListener = function() self:ReloadDumplings() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.datalist = { }
end

function RiceDumplingPanel:__delete()
    self.OnHideEvent:Fire()
    if self.materialsList ~= nil then
        for _,v in ipairs(self.materialsList) do
            v.slot:DeleteMe()
            v.data:DeleteMe()
        end
        self.materialsList = nil
    end
    if self.dumplingList ~= nil then
        for _,v in ipairs(self.dumplingList) do
            --if v.iconLoader ~= nil then v.iconLoader:DeleteMe() end
            if v.icon:GetComponent(Image) ~= nil then
                BaseUtils.ReleaseImage(v.icon:GetComponent(Image))
            end
        end
        self.dumplingList = nil
    end
    if self.rewardSlot ~= nil then
        self.rewardSlot:DeleteMe()
        self.rewardSlot = nil
    end
    if self.buyButton ~= nil then
        self.buyButton:DeleteMe()
        self.buyButton = nil
    end
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end

    if self.txt1 ~= nil then
        BaseUtils.ReleaseImage(self.txt1)
    end

    if self.txt2 ~= nil then
        BaseUtils.ReleaseImage(self.txt2)
    end

    -- if self.terrorbg ~= nil then
    --     for i=1,self.terrorbg.childCount do
    --         BaseUtils.ReleaseImage(self.terrorbg:GetChild(i-1):GetComponent(Image))
    --     end
    -- end

    self:AssetClearAll()
end

function RiceDumplingPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rice_dumpling))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("CampBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    --UIUtils.AddBigbg(t:Find("CampBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.LabaTerrorBg)))

    self.txt1 = t:Find("Txt1"):GetComponent(Image)
    self.txt1.sprite = self.assetWrapper:GetSprite(AssetConfig.Laba_top_Txt1, "LabaBgTxt1I18N")
    self.txt1:SetNativeSize()
    self.txt1.transform.anchoredPosition = Vector2(-74,195)
    self.txt2 = t:Find("Txt2"):GetComponent(Image)
    self.txt2.sprite = self.assetWrapper:GetSprite(AssetConfig.Laba_top_Txt2, "LabaBgTxt2I18N")
    self.txt2:SetNativeSize()
    self.txt2.transform.anchoredPosition  = Vector2(121,195)

    self.timeText = t:Find("Time"):GetComponent(Text)
    self.timeText.transform.anchoredPosition  = Vector2(36, 158)
    self.dumplingContainer = t:Find("Dumplings/Container")
    self.dumplingCloner = t:Find("Dumplings/Cloner").gameObject
    self.dumplingCloner.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.dumplingLayout = LuaBoxLayout.New(self.dumplingContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 3})

    self.materialsArea = t:Find("MakingArea/Materials")
    t:Find("MakingArea/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    t:Find("MakingArea/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.terrorbg = t:Find("MakingArea/TerrorBg")
    -- for i = 1,3 do
    --     self.terrorbg:GetChild(i-1):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, string.format("Terror%s", i))
    -- end
    UIUtils.AddBigbg(self.terrorbg, GameObject.Instantiate(self:GetPrefab(AssetConfig.LabaTerrorBg)))



    self.rewardSlot = ItemSlot.New()
    -- self.bat = t:Find("MakingArea/Leaves/Bat")
    self.leaves = t:Find("MakingArea/Leaves")
    self.rewardSlot.gameObject.transform:SetParent(t:Find("MakingArea/Leaves"))
    self.rewardSlot.gameObject.transform.localScale = Vector3.one
    self.rewardSlot.gameObject.transform.localPosition = Vector3.zero
    self.rewardSlot.noTips = true
    self.rewardSlot.gameObject.transform:SetAsFirstSibling()
    self.rewardSlot.clickSelfFunc = function() self:OnClickShow() end

    self.countText = t:Find("MakingArea/Count"):GetComponent(Text)
    self.countText.transform.anchoredPosition3D = Vector3(140, 12)

    local g = GameObject()
    g.name = "Buy"
    g:AddComponent(RectTransform)
    g.transform:SetParent(t)
    g.transform.localScale = Vector3.one
    g.transform.sizeDelta = Vector2(110, 40)
    g.transform.anchoredPosition = Vector2(-150, -192)
    self.buyButton = BuyButton.New(g.transform, TI18N("制作"))
    self.buyButton.key = "RiceDumpling"
    self.buyButton.protoId = 17862
    self.buyButton:Show()
    g:SetActive(false)

    self.button = t:Find("Button"):GetComponent(CustomButton)
    self.button.onClick:AddListener(function () self:OnClickBuy() end)
    self.button.onHold:AddListener(function() self:OnNumberpad() end)
    self.button.onDown:AddListener(function() self:OnDown() end)
    self.button.onUp:AddListener(function() self:OnUp() end)
    self.dumplingCloner:SetActive(false)

    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.button.gameObject,
        min_result = 1,
        max_by_asset = 20,
        max_result = 20,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) self.buyNum = num self:OnClickBuy() NumberpadManager.Instance:Close() end,
        callback = function() self:Update() end,
        show_num = true,
        returnText = TI18N("制作"),
    }
    self.Downtips = t:Find("MakingArea/Text"):GetComponent(Text)

end

function RiceDumplingPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RiceDumplingPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.reloadListener)
    DragonBoatFestivalManager.Instance.dumplingEvent:AddListener(self.updateListener)
    DragonBoatFestivalManager.Instance.redPointEvent:AddListener(self.redListener)

    self:ReloadDumplings()
    if #self.dumplingList > 0 then
        self:OnClick(1)
    end

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 22, function() self:Float() end)
    end
end

function RiceDumplingPanel:OnHide()
    self:RemoveListeners()

    for _,v in pairs(self.materialsList) do
        if v ~= nil and v.tweenId then
            Tween.Instance:Cancel(v.tweenId)
        end
    end

    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        self.delayId = nil
    end

    if self.successEffect ~= nil then
        self.successEffect:SetActive(false)
    end
    if self.moveEffect ~= nil then
        self.moveEffect:SetActive(false)
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function RiceDumplingPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.reloadListener)
    DragonBoatFestivalManager.Instance.dumplingEvent:RemoveListener(self.updateListener)
    DragonBoatFestivalManager.Instance.redPointEvent:RemoveListener(self.redListener)
end

function RiceDumplingPanel:PlaySuccess()
    for _,v in pairs(self.materialsList) do
        if v.tweenId ~= nil then
            Tween.Instance:Cancel(v.tweenId)
        end
        v.tweenId = Tween.Instance:Move(v.slot.transform, Vector3(280, 7.150004, 0), 0.4, function() end, LeanTweenType.easeOutQuad).id
    end
    if self.delayId ~= nil then
        LuaTimer.Delete(self.delayId)
        -- DragonBoatFestivalManager.Instance:send17862(self.currentId, NumberpadManager.Instance:GetResult())
    end
    if self.moveEffect == nil then
        self.moveEffect = BibleRewardPanel.ShowEffect(20388, self.transform, Vector3.one, Vector3(140, -67, -400))
    else
        self.moveEffect:SetActive(false)
        self.moveEffect:SetActive(true)
    end
    self.delayId = LuaTimer.Add(500, self.updateListener)
    DragonBoatFestivalManager.Instance:send17862(self.currentId, self.buyNum)
    self.buyNum = 1
end

--播放购买特效，之后模拟点击更新材料面板
function RiceDumplingPanel:Update(code, show)
    if code == 1 then
        if self.successEffect == nil then
            self.successEffect = BibleRewardPanel.ShowEffect(20387, self.transform, Vector3.one, Vector3(-73, 18, -400))
        else
            self.successEffect:SetActive(false)
            self.successEffect:SetActive(true)
        end
    end
    if self.lastIndex ~= nil then self:OnClick(self.lastIndex) end
end

function RiceDumplingPanel:ReloadDumplings()
    self.datalist = {}
    local list = CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.Zongzi)
    if next(list) ~= nil then
        for i,v in ipairs(list) do
            table.insert(self.datalist, v)
        end
        table.sort(self.datalist, function(a,b)
            if a ~= b then
                return a < b
            else
                return false
            end
        end)
    end

    --BaseUtils.dump(self.datalist,"包粽子活动id集合")

    -- local campData = CampaignManager.Instance.campaignTree[self.campDataGroup.type][self.campDataGroup.index]
    -- local campNewD = {}
    -- for k,v in ipairs(campData.sub) do
    --     if not self:IsExistCampValue(v, campNewD) then
    --         table.insert(campNewD, v)
    --     end
    -- end
    -- campData.sub = campNewD

    -- for _,v in ipairs(campData.sub) do
    --     table.insert(datalist, v.id)
    -- end

    self.dumplingLayout:ReSet()
    for i,id in ipairs(self.datalist) do
        local tab = self.dumplingList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.dumplingCloner)
            tab.transform = tab.gameObject.transform
            tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
            --tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
            tab.select = tab.transform:Find("Select").gameObject
            tab.red = tab.transform:Find("Red").gameObject
            tab.icon = tab.transform:Find("Icon")
            tab.icon.sizeDelta = Vector2(75, 75)
            tab.icon.anchoredPosition = Vector2(0, 10)
            self.dumplingList[i] = tab
            tab.select:SetActive(false)

            local j = i
            tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick(j) end)
        end
        self.dumplingLayout:AddCell(tab.gameObject)

        local data = DataCampaign.data_list[id]
        tab.nameText.text = data.reward_title
        tab.id = id
        --BaseUtils.dump(CampaignManager.Instance.model.redPointList,"红点点：：")
        tab.red:SetActive(CampaignManager.Instance.model.redPointList[id] == true)
        tab.transform.pivot = Vector2(0.5, 0.5)
        tab.transform.anchoredPosition = tab.transform.anchoredPosition + Vector2(90, 0)

        --tab.iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[CampaignManager.ItemFilter(data.rewardgift)[1][1]].icon)
        tab.icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "Bun"..data.reward_content)
        self.Downtips.text = data.conds
    end
    for i=#self.datalist + 1,#self.dumplingList do
        self.dumplingList[i].gameObject:SetActive(false)
    end

    local campData = DataCampaign.data_list[self.datalist[1]]
    self.timeText.text = string.format(TI18N("活动时间:<color=#ffff00>%s月%s日</color>-<color=#ffff00>%s月%s日</color>"), campData.cli_start_time[1][2], campData.cli_start_time[1][3], campData.cli_end_time[1][2], campData.cli_end_time[1][3])
end

-- 返回：true存在，，false不存在
-- function RiceDumplingPanel:IsExistCampValue(v,tab)
--     if tab == nil then
--         return false
--     end
--     for _,vx in pairs(tab) do
--         if v.id == vx.id then
--             return true
--         end
--     end
--     return false
-- end

function RiceDumplingPanel:ReloadRed()
    if self.dumplingList ~= nil and self.datalist ~= nil then
        for i,id in ipairs(self.datalist) do
            self.dumplingList[i].red:SetActive(CampaignManager.Instance.model.redPointList[id] == true)
        end
    end
end


function RiceDumplingPanel:OnClick(index)
    
    if self.lastIndex ~= nil then
        self.dumplingList[self.lastIndex].select:SetActive(false)
        --self.dumplingList[self.lastIndex].icon.localScale = Vector3.one
        self.dumplingList[self.lastIndex].icon.sizeDelta = Vector2(70, 70)
        self.dumplingList[self.lastIndex].icon.anchoredPosition = Vector2(0, 8)

        --这里有个特殊处理  中间正常状态需要放大多一点
        -- if self.lastIndex == 2 then
        --     self.dumplingList[self.lastIndex].icon.sizeDelta = Vector2(75, 75)
        --     self.dumplingList[self.lastIndex].icon.anchoredPosition = Vector2(0, 10)
        -- end
    end
    self.dumplingList[index].select:SetActive(true)
    self.dumplingList[index].icon.anchoredPosition = Vector2(0, 14)
    --self.dumplingList[index].icon.localScale = Vector3(1.2, 1.2, 1.2)
    self.dumplingList[index].icon.sizeDelta = Vector2(80, 80)
    self:ReloadMaterials(self.dumplingList[index].id)
    self:ReloadRed()

    self.lastIndex = index
end

function RiceDumplingPanel:ReloadMaterials(id)
    local num = NumberpadManager.Instance:GetResult()
    local campData = DataCampaign.data_list[id]
    local needs = {}

    self.currentCampId = id
    self.currentId = tonumber(campData.reward_content)
    local c = #DataCampRiceDumplingData.data_get[self.currentId].cost
    for i,v in ipairs(DataCampRiceDumplingData.data_get[self.currentId].cost) do
        local tab = self.materialsList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.slot.gameObject.transform:SetParent(self.materialsArea)
            tab.slot.gameObject.transform.localScale = Vector3(1, 1, 1)
            tab.data = ItemData.New()
            self.materialsList[i] = tab
        end
        tab.data:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = false})
        tab.slot:SetNum(BackpackManager.Instance:GetItemCount(v[1]), v[2] * num)
        tab.slot.gameObject:SetActive(true)
        tab.slot.gameObject.transform.anchoredPosition = self.posPlan[c][i]

        needs[v[1]] = {need = v[2] * num}
    end
    for i=c + 1,#self.materialsList do
        self.materialsList[i].slot.gameObject:SetActive(false)
    end

    local protoData = DragonBoatFestivalManager.Instance.model.dumplingTab[self.currentId] or {}
    self.rewardSlot:SetAll(DataItem.data_get[CampaignManager.ItemFilter(campData.rewardgift)[1][1]], {inbag = false, nobutton = true})
    -- self.rewardSlot:SetNum(DataCampRiceDumplingData.data_get[self.currentId].limit - (protoData.times or 0), DataCampRiceDumplingData.data_get[self.currentId].limit)
    -- self.rewardSlot.numTxt.text = string.format("%s/%s", DataCampRiceDumplingData.data_get[self.currentId].limit - (protoData.times or 0), DataCampRiceDumplingData.data_get[self.currentId].limit)

    if DataCampRiceDumplingData.data_get[self.currentId].limit == 0 then
        self.countText.text = ""
    else
        self.countText.text = string.format(TI18N("今日可制作:<color='#ffff00'>%s</color>/%s"), DataCampRiceDumplingData.data_get[self.currentId].limit - (protoData.times or 0), DataCampRiceDumplingData.data_get[self.currentId].limit)
    end
    --BaseUtils.dump(needs,"needs:")
    self.buyButton:Layout(needs, function() self:OnBuy() end, function() end)
end

function RiceDumplingPanel:OnNumberpad()
    local protoData = DragonBoatFestivalManager.Instance.model.dumplingTab[self.currentId] or {}
    if DataCampRiceDumplingData.data_get[self.currentId].limit > 0 then
        self.numberpadSetting.max_result = DataCampRiceDumplingData.data_get[self.currentId].limit - (protoData.times or 0)
    else
        self.numberpadSetting.max_result = 20
    end
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function RiceDumplingPanel:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp ~= false then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.button.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            if not BaseUtils.is_null(self.arrowEffect.gameObject) then
                self.arrowEffect.gameObject:SetActive(false)
                self.arrowEffect.gameObject:SetActive(true)
            end
        end
    end)
end

function RiceDumplingPanel:OnUp()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
end

function RiceDumplingPanel:OnBuy()
    local num = NumberpadManager.Instance:GetResult()
    if self.buyButton.money > 0 then
        -- DragonBoatFestivalManager.Instance:send17862(self.currentId, num)
        self:PlaySuccess()
    else
        local confirmData = NoticeConfirmData.New()
        local tab = {}
        local baseData = nil
        local dumplingData = DataCampRiceDumplingData.data_get[self.currentId]
        local campData = DataCampaign.data_list[self.currentCampId]
        for _,v in ipairs(dumplingData.cost) do
            baseData = DataItem.data_get[v[1]]
            table.insert(tab, ColorHelper.color_item_name(baseData.quality, string.format("%s×%s", baseData.name, v[2] * num)))
        end

        -- BaseUtils.dump(campData, "campData")
        -- BaseUtils.dump(tab, "tab")
        confirmData.content = string.format(TI18N("是否消耗%s制作<color='#ffff00'>%s</color>个<color='#00ff00'>%s</color>"), table.concat(tab, TI18N("、")), tostring(num), DataItem.data_get[CampaignManager.ItemFilter(campData.rewardgift)[1][1]].name)
        confirmData.sureCallback = function() self:PlaySuccess() end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function RiceDumplingPanel:OnClickShow()
    local dumplingData = DataCampRiceDumplingData.data_get[self.currentId]
    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
    end
    self.giftPreview:Show({reward = self:ItemFilter(dumplingData.reward_show), text = dumplingData.reward_title, autoMain = true})
end

function RiceDumplingPanel:OnClickBuy()
    if DataCampRiceDumplingData.data_get[self.currentId].limit == 0 or ((DragonBoatFestivalManager.Instance.model.dumplingTab[self.currentId] or {}).times or 0) < DataCampRiceDumplingData.data_get[self.currentId].limit then
        self.buyButton:OnClick()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("今天已经没有制作次数了"))
    end
end

function RiceDumplingPanel:Float()
    self.counter = (self.counter or 0) + 5
    self.leaves.anchoredPosition = Vector2(140, -4 + 5 * math.sin(self.counter * math.pi / 180))
    -- self.bat.anchoredPosition = Vector2(140, -4 + 5 * math.sin(self.counter * math.pi / 180))
end

function RiceDumplingPanel:ItemFilter(datalist)
    local list = {}
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    for _,v in ipairs(datalist) do
        if v[4] ~= nil and v[5] ~= nil then
            if (v[4] == 0 or v[4] == classes) and (v[5] == 2 or v[5] == sex) then
                table.insert(list, v)
            end
        else
            table.insert(list, v)
        end
    end
    return list
end
