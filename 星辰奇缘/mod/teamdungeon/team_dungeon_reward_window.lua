-- ----------------------------------------------------------
-- UI - 组队副本窗口
-- ljh 20170205
-- ----------------------------------------------------------
TeamDungeonRewardWindow = TeamDungeonRewardWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TeamDungeonRewardWindow:__init(model)
    self.model = model
    self.name = "TeamDungeonRewardWindow"
    self.windowId = WindowConfig.WinID.TeamDungeonRewardWindow
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.teamdungeoncardwindow, type = AssetType.Main}
        , {file = AssetConfig.teamdungeon_textures, type = AssetType.Dep}
        , {file = AssetConfig.unlimited_texture, type = AssetType.Dep}
        ,{file = "prefabs/effect/20274.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20275.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20276.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20118.unity3d", type = AssetType.Main}
        ,{file = AssetConfig.bigatlas_titlebg, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
    self.cardGoupButton = nil
    self.slotList = {}
    self.stateText = nil

    self.cardList = {}
    self.cardEffect = nil
    self.select = nil

    self.timerId = nil
    self.duangTimerId = nil
    self.moveTweenId = nil
	------------------------------------------------
	self.hasOpenCard = false

    self.step = 0
    self.autoTimerId = nil

    self.cardEffectList = {}

    self.donotSend12147 = false
    ------------------------------------------------
    self._OnUpdate = function(args) self:OnUpdate(args) end
    self.OnUpdateReward = function(num) self:ClickCloseCard(num) end
    self.OnUpdateRewardText = function() self:SetText() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isImproveOpen = false
end

function TeamDungeonRewardWindow:__delete()
    self:OnHide()

    for i,v in ipairs(self.slotList) do
        if v ~= nil and v.itemSlot ~= nil then
            v.itemSlot:DeleteMe()
        end
    end
    self.slotList = nil

    for i,v in ipairs(self.cardList) do
        if v ~= nil and v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    self.cardList = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function TeamDungeonRewardWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamdungeoncardwindow))
    self.gameObject.name = "TeamDungeonRewardWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    local titleBg = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_titlebg))
    UIUtils.AddBigbg(self.mainTransform:FindChild("Title"), titleBg)
    titleBg.transform.localScale = Vector3(1.7, 1.2, 1)
    -- self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    -- self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.exitButtonObj = self.mainTransform:FindChild("ExitButton").gameObject
    self.exitButtonObj:SetActive(false)
    self.getAllButtonObj = self.mainTransform:FindChild("GetAllButton").gameObject
    self.getAllButtonObj:SetActive(false)
    self.getAllButtonObj:GetComponent(Button).onClick:AddListener(function() self:GetAll() end)

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.exitButtonObj:GetComponent(Button).onClick:AddListener(function()
            local ismap = false
            for k,v in pairs(DataDungeon.data_dungeon_map) do
                if SceneManager.Instance:CurrentMapId() == v.map_id then
                    ismap = true
                    break
                end
            end

            if TeamDungeonManager.Instance.dungeon_status == true and ismap == true then
                DungeonManager.Instance:Require12101()
                self:Exit()
            end

        end)
    else
        self.mainTransform:FindChild("ExitButton/Text"):GetComponent(Text).text = TI18N("关闭界面")
        self.exitButtonObj:GetComponent(Button).onClick:AddListener(function() self:Exit() end)
    end

    self.title1 = self.mainTransform:FindChild("Title1").gameObject
    local containerItem = self.mainTransform:FindChild("Container/Item").gameObject
    containerItem:SetActive(false)
    self.container = self.mainTransform:FindChild("Container").gameObject
    for i = 1, 4 do
        local item = GameObject.Instantiate(containerItem)
        item:SetActive(true)
        item.transform:SetParent(self.container.transform)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

        local itemSlot = ItemSlot.New()
        UIUtils.AddUIChild(item, itemSlot.gameObject)

        local text = item.transform:FindChild("Text"):GetComponent(Text)

        table.insert(self.slotList, { itemSlot = itemSlot, text = text })
    end

    self.buttonExt = MsgItemExt.New(self.mainTransform:FindChild("GetAllButton/Text"):GetComponent(Text), 140, 18, 30)

    self.titleText = self.mainTransform:FindChild("TitleText"):GetComponent(Text)
    self.stateText = self.mainTransform:FindChild("StateText"):GetComponent(Text)

    self.cardGoupButton = self.mainTransform:FindChild("CardGoup"):GetComponent(Button)
    self.cardGoupButton.onClick:AddListener(function() self:OnCardGoupButtonClick() end)

    self.cards = self.mainTransform:FindChild("Cards").gameObject

    self.cardList = {}
    for i=1,3 do
        local card = self.cards.transform:FindChild(string.format("Card%s/Card", i))

        local close = card:Find("Close").gameObject
        close:GetComponent(Button).onClick:AddListener(function() TeamDungeonManager.Instance:Send12152(false,i) end)
        close:SetActive(true)

        local slot = ItemSlot.New()
        UIUtils.AddUIChild(card:Find("result/Slot").gameObject, slot.gameObject)

        self.cardList[i] = {}
        self.cardList[i].transform = card
        self.cardList[i].animation = card:GetComponent(Animation)
        self.cardList[i].closeCard = close
        self.cardList[i].result = card:Find("result").gameObject
        self.cardList[i].nameText = card:Find("result/Slot/NameText"):GetComponent(Text)
        self.cardList[i].slot = slot

        self.cardList[i].closeCard:SetActive(true)
        self.cardList[i].result:SetActive(false)
    end
    self.select = self.cards.transform:FindChild("Select")

    self.cardGoupButton.gameObject:SetActive(true)
    self.cards:SetActive(false)

    self.cardEffect = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20275.unity3d"))
    self.cardEffect.transform:SetParent(self.cardGoupButton.transform)
    self.cardEffect.transform.localScale = Vector3.one
    self.cardEffect.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.cardEffect.transform, "UI")

    -- local effect = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20118.unity3d"))
    -- effect.transform:SetParent(self.getAllButtonObj.transform)
    -- effect.transform.localScale = Vector3(1.15, 0.88, 0)
    -- effect.transform.localPosition = Vector3(-57, 25, 0)
    -- Utils.ChangeLayersRecursively(effect.transform, "UI")

    self.bangEffect = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20276.unity3d"))
    self.bangEffect.transform:SetParent(self.cardGoupButton.transform.parent)
    self.bangEffect.transform.localScale = Vector3.one
    local p = self.cardGoupButton.transform.localPosition
    self.bangEffect.transform.localPosition = Vector3(p.x + 10, p.y - 1, 0)
    Utils.ChangeLayersRecursively(self.bangEffect.transform, "UI")
    self.bangEffect:SetActive(false)

    for index=1, 3 do
        self.cardEffectList[index] = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20274.unity3d"))
        self.cardEffectList[index].transform:SetParent(self.cardList[index].transform)
        self.cardEffectList[index].transform.localScale = Vector3.one
        self.cardEffectList[index].transform.localPosition = Vector3(-3, 6, 0)
        Utils.ChangeLayersRecursively(self.cardEffectList[index].transform, "UI")
        self.cardEffectList[index]:SetActive(false)
    end
    ----------------------------

    self:OnShow()
end

function TeamDungeonRewardWindow:OnClickClose()
	WindowManager.Instance:CloseWindow(self)
end

function TeamDungeonRewardWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.rewardData = self.openArgs[1]
        -- 是否从提升按钮打开
        self.isImproveOpen = self.openArgs[2] or false
    end

    self.exitButtonObj:SetActive(false)
    self.getAllButtonObj:SetActive(false)
    self:GetAllButtonEffect(false)

    self:Update()

    TeamDungeonManager.Instance.OnUpdateReward:Add(self.OnUpdateReward)
    TeamDungeonManager.Instance.OnUpdateRewardText:Add(self.OnUpdateRewardText)
    TeamDungeonManager.Instance.OnUpdate:Add(self._OnUpdate)
end

function TeamDungeonRewardWindow:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.duangTimerId ~= nil then
        LuaTimer.Delete(self.duangTimerId)
        self.duangTimerId = nil
    end

    if self.autoTimerId ~= nil then
        LuaTimer.Delete(self.autoTimerId)
        self.autoTimerId = nil
    end

    if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end

    self:GetAllButtonEffect(false)

    TeamDungeonManager.Instance.OnUpdate:Remove(self._OnUpdate)
    TeamDungeonManager.Instance.OnUpdateRewardText:Remove(self.OnUpdateRewardText)
    TeamDungeonManager.Instance.OnUpdateReward:Remove(self.OnUpdateReward)
end

function TeamDungeonRewardWindow:OnUpdate(args)
    if args == nil then
        self:Update()
    elseif args == "" then

    end
end

function TeamDungeonRewardWindow:Update()
    -- BaseUtils.dump(self.rewardData.gain)
    -- BaseUtils.dump(self.rewardData.buy_loss)
    if self.isImproveOpen == false then
        for i,value in ipairs(self.rewardData.gain) do
            local itembase = BackpackManager.Instance:GetItemBase(value.g_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = value.value
            self.slotList[i].itemSlot:SetAll(itemData, { nobutton = true })
            self.slotList[i].text.text = itemData.name

            self.slotList[i].itemSlot.gameObject:SetActive(true)
        end

        if #self.rewardData.gain < #self.slotList then
            for i=#self.rewardData.gain+1, #self.slotList do
                self.slotList[i].itemSlot.gameObject:SetActive(false)
                self.slotList[i].text.text = ""
            end
        end

    else
        self.title1:SetActive(false)
        for i=1, #self.slotList do
            self.slotList[i].itemSlot.gameObject:SetActive(false)
            self.slotList[i].text.text = ""
        end
    end


    local assetsString = ""
    for _,value in ipairs(self.rewardData.buy_loss) do
        assetsString = string.format("%s%s{assets_2,%s}", assetsString, value.l_value, value.l_id)
    end
    -- self.buttonExt:SetData(string.format(TI18N("%s全带走"), assetsString))
    self.buttonExt:SetData(TI18N("全部带走"))

    if self.isImproveOpen == false then
        self.titleText.text = string.format(TI18N("通关%s！"), DataDungeon.data_get[self.rewardData.dun_id].name)
    else
        self.titleText.text = TI18N("副本通关奖励")
    end


    self:Duang(self.cardGoupButton.transform)


    if self.isImproveOpen == true then
        self.autoTimerId = LuaTimer.Add(0.2, function()
                if self.step == 0 then
                     self:OnCardGoupButtonClick()

                end
            end)
    else
        -- self.autoTimerId = LuaTimer.Add(30000, function()
        --         if self.step == 0 then
        --                 if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        --                     if TeamDungeonManager.Instance.dungeon_status == true then
        --                         DungeonManager.Instance:Require12101()
        --                     end
        --                 end
        --         end
        --     end)
    end


end




function TeamDungeonRewardWindow:UpdateCards(index)
    local list = {}
    local selectData = nil
    for _,value in ipairs(self.rewardData.cards) do
        if value.selected == 1 then
            selectData = value
        else
            table.insert(list, value)
        end
    end
    if selectData ~= nil then
        table.insert(list, index, selectData)
    end

    for i=1, #self.cardList do
        local itembase = BackpackManager.Instance:GetItemBase(list[i].item_id)
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = list[i].item_num
        local extra = {inbag = false, nobutton = true}
        self.cardList[i].slot:SetAll(itemData, extra)

        self.cardList[i].nameText.text = string.format("%sx%s", ColorHelper.color_item_name(itembase.quality, itembase.name), itemData.quantity)
    end
end

function TeamDungeonRewardWindow:Exit()
    -- WindowManager.Instance:CloseWindow(self)

    TeamDungeonManager.Instance:Send12152()
    self.model:CloseTeamDungeonRewardWindow()
end

function TeamDungeonRewardWindow:GetAll()
    local assetsString = ""
    for _,value in ipairs(self.rewardData.buy_loss) do
        assetsString = string.format("%s%s{assets_2,%s}", assetsString, value.l_value, value.l_id)
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("花费%s带走其他两个奖励，是否继续？"), assetsString)
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        -- WindowManager.Instance:CloseWindow(self)
        if self.isImproveOpen == true then
           if TeamDungeonManager.Instance.hasRewardData == 1 then
                TeamDungeonManager.Instance:Send12148(true)
            else
                TeamDungeonManager.Instance:Send12148()
            end
        else
            TeamDungeonManager.Instance:Send12148()
        end
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            local ismap = false
            for k,v in pairs(DataDungeon.data_dungeon_map) do
                if SceneManager.Instance:CurrentMapId() == v.map_id then
                    ismap = true
                    break
                end
            end

            if TeamDungeonManager.Instance.dungeon_status == true and ismap == true then
                DungeonManager.Instance:Require12101()
            end
        end
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function TeamDungeonRewardWindow:OnCardGoupButtonClick()
    if self.step ~= 0 then
        return
    end
    self.step = 1
    if self.autoTimerId ~= nil then
        LuaTimer.Delete(self.autoTimerId)
        self.autoTimerId = nil
    end

    local fun = function()
        self.title1:SetActive(false)
        self.container:SetActive(false)
        self.cardEffect:SetActive(false)
        self.cardGoupButton.gameObject:SetActive(false)

        self.bangEffect:SetActive(true)
        SoundManager.Instance:Play(233)

        LuaTimer.Add(1000, function()
                if self.gameObject == nil then
                    return
                end
                self.step = 2
                self.cards:SetActive(true)
                self.bangEffect:SetActive(false)

                self:StopDuang()
                self.stateText.text = TI18N("点击卡牌领取奖励")

                self.autoTimerId = LuaTimer.Add(30000, function()
                        if self.step == 2 then
                            TeamDungeonManager.Instance:Send12152(false,2)
                            -- self:ClickCloseCard(2)
                        end
                    end)
            end)
    end

    self.moveTweenId = Tween.Instance:MoveLocalY(self.cardGoupButton.gameObject, 0, 0.2, fun).id
end

function TeamDungeonRewardWindow:ClickCloseCard(index)
    if self.hasOpenCard then
        return
    end
    if self.step ~= 2 then
        return
    end
    self.step = 3
    if self.autoTimerId ~= nil then
        LuaTimer.Delete(self.autoTimerId)
        self.autoTimerId = nil
    end

    self:UpdateCards(index)

    self.hasOpenCard = true
    for i = 1, #self.cardList do
        self.cardList[i].closeCard:GetComponent(Button).enabled = false
        self.cardList[i].closeCard:GetComponent(TransitionButton).enabled = false
    end

    -- local selectEffect = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20226.unity3d"))
    -- selectEffect.transform:SetParent(self.cardList[index].transform)
    -- selectEffect.transform.localScale = Vector3(1.03, 1.06, 0)
    -- selectEffect.transform.localPosition = Vector3(0, -5, 0)
    -- Utils.ChangeLayersRecursively(selectEffect.transform, "UI")

    self.cardList[index].closeCard:SetActive(false)

    self.cardEffectList[index]:SetActive(true)
    SoundManager.Instance:Play(245)


    local fun = function()
        if self.gameObject == nil then
            return
        end
        self.cardList[index].result:SetActive(true)
        -- self.cardList[index].transform.localPosition = Vector3.zero
        self.cardList[index].animation.enabled = false
        -- self.select.localPosition = self.cardList[index].result.transform.parent.localPosition
        self.select:SetParent(self.cardList[index].result.transform)
        self.select.localPosition = Vector3.zero
        self.select.gameObject:SetActive(true)

        self.stateText.text = ""
        self.exitButtonObj:GetComponent(Button).onClick:RemoveAllListeners()
        if self.isImproveOpen == false then
             self.mainTransform:FindChild("ExitButton/Text"):GetComponent(Text).text = TI18N("关闭界面")
             self.exitButtonObj:GetComponent(Button).onClick:AddListener(function()
                if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
                    local ismap = false
                    for k,v in pairs(DataDungeon.data_dungeon_map) do
                        if SceneManager.Instance:CurrentMapId() == v.map_id then
                            ismap = true
                            break
                        end
                    end

                    if TeamDungeonManager.Instance.dungeon_status == true and ismap == true then
                        DungeonManager.Instance:Require12101()
                    end
                end

                self:Exit() end)

            self.exitButtonObj:SetActive(true)
            self.getAllButtonObj:SetActive(true)
            self:GetAllButtonEffect(true)
            local fun2 = function()
                if self.gameObject == nil then
                    return
                end
                for i=1, #self.cardList do
                    self.cardList[i].result:SetActive(true)
                    self.cardList[i].closeCard:SetActive(false)

                    -- self.cardList[i].transform.localPosition = Vector3.zero
                    self.cardList[i].animation.enabled = false
                end
                if not self.donotSend12147 then
                    TeamDungeonManager.Instance:Send12147()
                end
           end
           LuaTimer.Add(1000, fun2)
        else
                local fun2 = function()
                    if self.gameObject == nil then
                        return
                    end
                    for i=1, #self.cardList do
                        self.cardList[i].result:SetActive(true)
                        self.cardList[i].closeCard:SetActive(false)

                    -- self.cardList[i].transform.localPosition = Vector3.zero
                        self.cardList[i].animation.enabled = false
                    end
                    if not self.donotSend12147 then
                        TeamDungeonManager.Instance:Send12147(true)
                    end
                end
                LuaTimer.Add(1000, fun2)
        end
    end

    LuaTimer.Add(1000, fun)
end

function TeamDungeonRewardWindow:SetText()
     if TeamDungeonManager.Instance.hasRewardData == 1 then
        self.mainTransform:FindChild("ExitButton/Text"):GetComponent(Text).text = TI18N("下一关奖励")
        self.exitButtonObj:GetComponent(Button).onClick:AddListener(function() self:ApplyNextReward() end)
     else
        self.mainTransform:FindChild("ExitButton/Text"):GetComponent(Text).text = TI18N("关闭界面")
        self.exitButtonObj:GetComponent(Button).onClick:AddListener(function() self:Exit() end)
     end
     self.exitButtonObj:SetActive(true)
     self.getAllButtonObj:SetActive(true)
     self:GetAllButtonEffect(true)
end

function TeamDungeonRewardWindow:Duang(trans)
    local fun = function()
        -- Duang
        -- local halfT = 120   -- 半周期
        -- local n = 2         -- 周期数
        -- local t = 0
        -- local scale = 0.02   -- 增量放缩
        -- if self.duangTimerId == nil then
        --     trans:SetAsLastSibling()
        --     self.duangTimerId = LuaTimer.Add(0, 30, function()
        --         t = t + 30
        --         local c = 1 + scale - scale * math.cos(math.pi * t / halfT)
        --         trans.localScale = Vector3(c, c, 1)
        --         if t > halfT * n * 2 then
        --             trans.localScale = Vector3.one
        --             LuaTimer.Delete(self.duangTimerId)
        --             self.duangTimerId = nil
        --         end
        --     end)
        -- end

        -- Shake
        local counter = 0
        local shakeCounter = 0
        if self.duangTimerId == nil then
            self.duangTimerId = LuaTimer.Add(0, 20, function()
                local maxTime = 6280
                counter = (counter + 40) % maxTime
                shakeCounter = (shakeCounter + 2) % 100
                if shakeCounter >= 15 then
                    if self.shakeTimerId ~= nil then
                        LuaTimer.Delete(self.shakeTimerId)
                        self.shakeTimerId = nil
                    end
                    trans.rotation = Quaternion.Euler(0, 0, 0)
                    return
                end
                local status = 2
                if shakeCounter > 15 then status = 0 end
                local diff = math.sin(counter / 20)
                trans.rotation = Quaternion.Euler(0, 0, diff * status)
            end)
        end
    end
    self.timerId = LuaTimer.Add(500, 500, fun)
end

function TeamDungeonRewardWindow:StopDuang()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.duangTimerId ~= nil then
        LuaTimer.Delete(self.duangTimerId)
        self.duangTimerId = nil
    end
end

function TeamDungeonRewardWindow:GetAllButtonEffect(show)
    if self.getAllButtonEffTimerId ~= nil then
        LuaTimer.Delete(self.getAllButtonEffTimerId)
        self.getAllButtonEffTimerId = nil
    end

    if self.getAllButtonObj == nil then return end 
    if show then
        self.getAllButtonEffTimerId = LuaTimer.Add(1000, 3000, function()
            self.getAllButtonObj.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.getAllButtonObj, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    else
        self.getAllButtonObj.transform.localScale = Vector3.one
    end
end

function TeamDungeonRewardWindow:ApplyNextReward()
    TeamDungeonManager.Instance.setText = false
    TeamDungeonManager.Instance:Send12152(true)
end