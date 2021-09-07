ZoneMessagePanel = ZoneMessagePanel or BaseClass()

function ZoneMessagePanel:__init(model, Main)
    self.model = model
    self.zoneMgr = self.model.zoneMgr
    self.myzoneData = self.zoneMgr.myzoneData
    self.Main = Main
    self.gameObject = self.Main.gameObject
    self.transform = self.gameObject.transform
    self.assetWrapper = self.Main.assetWrapper
    self.appendTab = {}
    self.headSlotList = {}
    self.iconloader = {}
    self.slotlist = {}

    self.TabSelectPosX = {
        [1] = -15,
        [2] = 65,
        [3] = 144,
        [4] = 224,
    }
    self.TabName = {
        [1] = TI18N("我的空间"),
        [2] = TI18N("好 友"),
        [3] = TI18N("最 热"),
        [4] = TI18N("发 现"),
    }
    self.TabSelectButton = self.transform:Find("MainCon/TabSelectButton")
    self.Sub1Con = self.transform:Find("MainCon/Sub1Con")
    self.Sub2Con = self.transform:Find("MainCon/Sub2Con")
    self.Sub3Con = self.transform:Find("MainCon/Sub3Con")
    self.sub1layoutCon = self.Sub1Con:Find("sub1/ScrollMask/Layout")
    self.sub2layoutCon = self.Sub1Con:Find("sub2/ScrollMask/Layout")
    self.sub3layoutCon = self.Sub1Con:Find("sub3/ScrollMask/Layout")
    self.MyGiftText = self.transform:Find("MainCon/Sub1Con/sub1/MyGiftText"):GetComponent(Text)
    self.LikeText = self.transform:Find("MainCon/Sub1Con/sub1/LikeText"):GetComponent(Text)
    self.RecGiftText = self.transform:Find("MainCon/Sub1Con/sub1/RecGiftText"):GetComponent(Text)
    self.AddGiftButton = self.transform:Find("MainCon/Sub1Con/sub1/AddGiftButton"):GetComponent(Button)
    self.LikeButton = self.transform:Find("MainCon/Sub1Con/sub1/LikeButton"):GetComponent(Button)
    self.HasGiftButton = self.transform:Find("MainCon/Sub1Con/sub1/HasGiftButton"):GetComponent(Button)
    self.HasGiftIcon = self.transform:Find("MainCon/Sub1Con/sub1/GetGift/Icon"):GetComponent(Image)
    local id = self.HasGiftIcon.gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(self.HasGiftIcon.gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, 20031)

    self.trendInputField = self.transform:Find("MainCon/Sub1Con/sub1/InputBar/InputField")
    self.inputfield = self.trendInputField:GetComponent(InputField)
    self.inputfield.characterLimit = 60
    self.Main:SetInputField(self.trendInputField)
    self.inputfield = self.trendInputField:GetComponent(InputField)
    self.inputfield.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)

    self.trendsItem = self.Sub1Con:Find("sub1/ScrollMask/GiftItem").gameObject
    self.VisitItem = self.Sub1Con:Find("sub2/ScrollMask/VisitItem").gameObject
    self.GetGiftItem = self.Sub1Con:Find("sub2/ScrollMask/GetGiftItem").gameObject
    self.LikeItem = self.Sub1Con:Find("sub3/ScrollMask/GiftItem").gameObject

    self.TrendsCon = self.Sub1Con:Find("sub1/ScrollMask/Layout")
    self.VisitCon = self.Sub1Con:Find("sub2/ScrollMask/Layout")
    self.GiftCon = self.Sub1Con:Find("sub3/ScrollMask/Layout")

    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Top = 5
        ,border = 5
    }
    local setting2 = {
        column = 2
        ,cspacing = 0
        ,rspacing = 0
        ,cellSizeX = 254
        ,cellSizeY = 74
        ,bordertop = 5
        ,borderleft = 5
    }
    self.TrendsLayout = LuaBoxLayout.New(self.TrendsCon, setting1)
    self.VisitLayout = LuaGridLayout.New(self.VisitCon, setting2)
    self.GiftLayout = LuaBoxLayout.New(self.GiftCon, setting1)

    self.Sub1Con:Find("sub1/InputBar/SendButton"):GetComponent(Button).onClick:AddListener(function() self:OnButtonSend() end)
    self.Sub1Con:Find("sub1/InputBar/AddButton"):GetComponent(Button).onClick:AddListener(function() self:ClickMore() end)

    self.scrollRect = self.transform:Find("MainCon/Sub1Con/sub1/ScrollMask"):GetComponent(ScrollRect)
    local scrollSize = self.scrollRect.gameObject.transform.sizeDelta
    self.scrollRect.onValueChanged:AddListener(function(value)
        self.TrendsLayout:OnScroll(scrollSize, value)
    end)
    self:InitInfo()
    self:InitTab()
    self:ChangeSubCon(1)
end

function ZoneMessagePanel:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.headSlotList ~= nil then
        for _,v in pairs(self.headSlotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.headSlotList = nil
    end
end

function ZoneMessagePanel:InitInfo()
    self.MyGiftText.text = tostring(self.myzoneData.prize_num)
    self.LikeText.text = tostring(self.myzoneData.liked)
    self.RecGiftText.text = tostring(self.myzoneData.present_num)
end


function ZoneMessagePanel:InitTab()
    if self.zoneMgr.openself then
        --local go = self.transform:Find("MainCon/TabButtonGroup").gameObject
        --self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end)
        self.transform:Find("MainCon/Sub1Con/sub1/AddGiftButton"):GetComponent(Button).onClick:AddListener(function() self.Main.giftsetpanel:Show() end)
    else
        self.transform:Find("MainCon/Sub1Con").anchoredPosition = Vector2(113, -2)
        self:UpdateOtherBtn()
        self.transform:Find("MainCon/Sub1Con/sub1/AddGiftButton").gameObject:SetActive(false)
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton").gameObject:SetActive(true)
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CaiButton"):GetComponent(Button).onClick:AddListener(function() self:OnCaiButton() end)
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/AddFriendButton"):GetComponent(Button).onClick:AddListener(function() self:OnAddFriendButton() end)
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CareButton"):GetComponent(Button).onClick:AddListener(function() self.zoneMgr:OpenSelfZone() end)
    end
    self.Sub1Con:Find("sub2/BackButton"):GetComponent(Button).onClick:AddListener(function() self:ChangeSubCon(1) end)
    self.Sub1Con:Find("sub3/BackButton"):GetComponent(Button).onClick:AddListener(function() self:ChangeSubCon(1) end)
    self.LikeButton.onClick:AddListener(function() self:ChangeSubCon(2) end)
    self.HasGiftButton.onClick:AddListener(function() self:ChangeSubCon(3) end)

end


-- function ZoneMessagePanel:OnTabChange(index)
--     if index == 4 then
--         NoticeManager.Instance:FloatTipsByString(TI18N("敬请期待"))
--     elseif index == 2 then
--         self.transform:Find("MainCon/Info").gameObject:SetActive(false)
--         self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
--         self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(true)
--         self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(false)
--         --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(false)
--         self.Main.momentspanel:Hiden()
--         self.Main.CommonTitle.gameObject:SetActive(false)
--     elseif index == 1 then
--         if self.Main.RightTab ~= nil then
--             self.transform:Find("MainCon/Info").gameObject:SetActive(true)
--             self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(false)
--             self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(false)
--             if self.Main.RightTab == 1 then
--                 self.Main.momentspanel:Show(self.Main.openArgs)
--                 self.Main.CommonTitle.gameObject:SetActive(true)
--                 self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
--                 --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(true)
--             elseif self.Main.RightTab == 2 then
--                 self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(true)
--                 --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(false)
--                 self.Main.momentspanel:Hiden()
--                 self.Main.CommonTitle.gameObject:SetActive(false)
--             end
--         end

--     elseif index == 3 then
--         self.transform:Find("MainCon/Info").gameObject:SetActive(false)
--         self.transform:Find("MainCon/Sub1Con").gameObject:SetActive(false)
--         self.transform:Find("MainCon/Sub2Con").gameObject:SetActive(false)
--         self.transform:Find("MainCon/Sub3Con").gameObject:SetActive(true)
--         --self.transform:Find("MainCon/SubPanelCon").gameObject:SetActive(false)
--         self.Main.momentspanel:Hiden()
--         self.Main.CommonTitle.gameObject:SetActive(false)
--     end
--     local pos = Vector2(self.TabSelectPosX[index], 218)
--     self.TabSelectButton:Find("Text"):GetComponent(Text).text = self.TabName[index]
--     Tween.Instance:MoveX(self.TabSelectButton, self.TabSelectPosX[index], 0.6, function() end, LeanTweenType.easeOutQuint)
-- end
function ZoneMessagePanel:UpdateOtherBtn()
    if self.myzoneData.likable == 1 then
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CaiButton/Text"):GetComponent(Text).text = TI18N("点赞一下")
    else
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CaiButton/Text"):GetComponent(Text).text = TI18N("已经赞过")
    end
    self.LikeText.text = tostring(self.myzoneData.liked)

    if FriendManager.Instance:IsFriend(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id) then
    self.transform:Find("MainCon/Sub1Con/sub1/otherButton/AddFriendButton/Text"):GetComponent(Text).text = TI18N("删除好友")
    else
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/AddFriendButton/Text"):GetComponent(Text).text = TI18N("添加好友")
    end

    if self.myzoneData.is_subscribed == 0 then
        -- self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CareButton/Text"):GetComponent(Text).text = "特别关心"
    else
        -- self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CareButton/Text"):GetComponent(Text).text = "取消关心"
    end
end

function ZoneMessagePanel:ChangeSubCon(index)
    for i = 1, 3 do
        self.Sub1Con:Find(string.format("sub%s", tostring(i))).gameObject:SetActive(i==index)
    end
    if index == 1 then
        self:UpdataTrends()
    elseif index == 2 then
        self:UpdataVisits()
    elseif index == 3 then
        self:UpdataGiftInfo()
    end
end


function ZoneMessagePanel:UpdataTrends()
    if self.lockTrends == true then
        return
    end
    self.lockTrends = true
    local data_list = {}
    if self.zoneMgr.openself then
        data_list = self.zoneMgr.mytrends_list
    else
        data_list = self.zoneMgr.othertrends_list
    end
    local parent = self.TrendsCon.gameObject
    self.TrendsLayout:ReSet()
    -- BaseUtils.dump(data_list, "阿登省撒旦撒打死打伤")
    for k,v in pairs(data_list) do
        local item = parent.transform:Find(string.format("%s_%s_%s_%s", v.name, tostring(v.id), tostring(v.type), tostring(v.ctime)))
        -- print(string.format("%s_%s_%s_%s", v.name, tostring(v.id), tostring(v.type), tostring(v.ctime)))
        if item == nil then
            item = GameObject.Instantiate(self.trendsItem)
            item.transform:SetParent(self.transform)
        else
            item.gameObject:SetActive(true)
        end
        if self.headSlotList[k] == nil then
            self.headSlotList[k] = HeadSlot.New()
        end
        self.headSlotList[k]:SetRectParent(item.transform:Find("Head"))
        self:SetTrendItem(item, v, self.headSlotList[k])
        self.TrendsLayout:AddCell(item.gameObject)
    end
    self.lockTrends = false
end


function ZoneMessagePanel:SetTrendItem(item, data, headSlot)
    if BaseUtils.isnull(item) then
        return
    end
    local its = item.transform
    local sizeFit = its:Find("InfoText"):GetComponent(Text)
    local tipsdata = BaseUtils.copytab(data)
    tipsdata.id = data.role_id
    its.gameObject.name = string.format("%s_%s_%s_%s", data.name, tostring(data.id), tostring(data.type), tostring(data.ctime))
    -- its:Find("Head"):GetComponent(Image).sprite = self.Main:GetHead(data.classes, data.sex)
    its:Find("Head"):GetComponent(Image).enabled = false
    its:Find("NameText"):GetComponent(Text).text = data.name

    -- headSlot.image.enabled = false
    headSlot:HideSlotBg(true)
    local dat = {id = data.role_id, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
    headSlot:SetAll(dat, {isSmall = true, clickCallback = function() TipsManager.Instance:ShowPlayer(tipsdata) end})

    local contentTxt = its:Find("InfoText"):GetComponent(Text)
    local titleExt =  MsgItemExt.New(contentTxt, 340, 15, 18.5)
    titleExt:SetData(data.content)
    if string.find(data.content, "{role_") ~= nil then
        local toContent = string.gsub(contentTxt.text, "23f0f7", "2555d0", 1)
        contentTxt.text = toContent
    end


    -- its:Find("InfoText"):GetComponent(Text).text = data.content

    local ph = its:Find("InfoText"):GetComponent(Text).preferredHeight
    -- preferredHeight
    its:Find("TimeText"):GetComponent(Text).text = os.date("%Y-%m-%d",tonumber(data.ctime))
    its:Find("GoodButton"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("ReportButton").anchoredPosition = Vector2(177.8,-15)

    if self.zoneMgr.openself then
        its:Find("GoodButton"):GetComponent(Button).onClick:AddListener(function() self:DeleteTrends(item.gameObject, data.id) end)
        --BaseUtils.dump(data,"dsjfskljfklsdjfklsdjkl==========================================")
        if RoleManager.Instance.RoleData.id == data.role_id and RoleManager.Instance.RoleData.platform == data.platform and RoleManager.Instance.RoleData.zone_id == data.zone_id then

            its:Find("ReportButton").gameObject:SetActive(false)
        else
            its:Find("ReportButton").gameObject:SetActive(true)
            its:Find("ReportButton"):GetComponent(Button).onClick:RemoveAllListeners()
            its:Find("ReportButton"):GetComponent(Button).onClick:AddListener(function() self:ApplyReportButton(data) end)
        end
    else
        its:Find("ReportButton").gameObject:SetActive(false)
        its:Find("GoodButton").gameObject:SetActive(false)
    end
    if data.type == 3 then
        local icon = DataItem.data_get[data.presents[1].base_id].icon
        local id = its:Find("GiftImage/GiftIcon").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(its:Find("GiftImage/GiftIcon").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, icon)
        its:Find("GiftNumText"):GetComponent(Text).text = tostring(data.presents[1].num)
    end
    its:Find("GiftImage").gameObject:SetActive(data.type == 3)
    its:Find("GiftNumText").gameObject:SetActive(data.type == 3)
    item.gameObject:SetActive(true)
    local addh = (ph>20 and ph-20 or 0)
    its.sizeDelta = Vector2(its.sizeDelta.x, 78+(ph>20 and ph-20 or 0))
    local headbtn = its:Find("Head").gameObject:GetComponent(Button) or its:Find("Head").gameObject:AddComponent(Button)
    headbtn.onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function()
        if data.role_id ~= RoleManager.Instance.RoleData.id or data.platform ~= RoleManager.Instance.RoleData.platform or data.zone_id ~= RoleManager.Instance.RoleData.zone_id then
            self.reCallTarget = {id = data.id, name = data.name}
            self.inputfield.text = ""
            self.trendInputField:Find("Placeholder"):GetComponent(Text).text = string.format(TI18N("对 %s 说:"), data.name)
            self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("返 回")
        else
            self.reCallTarget = nil
            self.inputfield.text = ""
            self.trendInputField:Find("Placeholder"):GetComponent(Text).text = TI18N("输入内容")
            self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("发 送")
        end
    end)
    headbtn.onClick:AddListener(function() TipsManager.Instance:ShowPlayer(tipsdata) end)
end

function ZoneMessagePanel:ApplyReportButton(data)
    -- ReportManager.Instance.model:OpenZoneWindow(data)
    ReportManager.Instance.model:ReportChat(data, 2)
end

function ZoneMessagePanel:DeleteTrends(item, id)
    local callback = function ()
        self.zoneMgr:Require11825(tonumber(id))
        item:SetActive(false)
        GameObject.DestroyImmediate(item)
        self.TrendsLayout:ReSize()
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("是否删除该条留言？")
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = callback
    NoticeManager.Instance:ConfirmTips(data)
end


function ZoneMessagePanel:UpdataVisits()
    local data_list = self.zoneMgr.myvisit_list
    if self.zoneMgr.openself == false then
        data_list = self.zoneMgr.othervisit_list
    end
    local parent = self.VisitCon.gameObject
    self.VisitLayout:ReSet()
    self:UpdataGetGift()
    for k,v in pairs(data_list) do
        local item = parent.transform:Find(v.name)
        if item == nil then
            item = GameObject.Instantiate(self.VisitItem)
        else
            -- print("找到不创")
            item.gameObject:SetActive(false)
            item = item.gameObject
        end
        self:SetVisitItem(item, v)
        self:AddCellToVisit(item.gameObject)
    end
end

function ZoneMessagePanel:SetVisitItem(item, data)
    local its = item.transform
    local sizeFit = its:Find("InfoText"):GetComponent(Text)
    its.gameObject.name = data.name
    its:Find("Head"):GetComponent(Image).sprite = self.Main:GetHead(data.classes, data.sex)
    its:Find("NameText"):GetComponent(Text).text = data.name
    if data.got_prize == 1 then
        sizeFit.text = TI18N("获得礼物")
        its:Find("getIcon").gameObject:SetActive(true)
    end
    its:Find("Text"):GetComponent(Text).text = tostring(data.lev)
    its:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("Button"):GetComponent(Button).onClick:AddListener(function() self.zoneMgr:OpenOtherZone(data.id, data.platform, data.zone_id) end)
    item.gameObject:SetActive(true)
    local headbtn = its:Find("Head").gameObject:GetComponent(Button) or its:Find("Head").gameObject:AddComponent(Button)
    headbtn.onClick:RemoveAllListeners()
    headbtn.onClick:AddListener(function() FriendManager.Instance:Require11808(data.name, true) end)
end

function ZoneMessagePanel:AddCellToVisit(item)
    LuaTimer.Add(100, function() if not BaseUtils.isnull(item) then self.VisitLayout:AddCell(item) end end)
end

function ZoneMessagePanel:UpdataGetGift()
    local data_list = DataFriend.data_get_popularity_reward
    -- BaseUtils.dump(data_list)
    if self.zoneMgr.openself == false then
        return
        -- data_list = self.zoneMgr.othervisit_list
    end
    local parent = self.VisitCon.gameObject
    local has = false
    if data_list ~= nil and next(data_list) ~= nil then
        for k,v in ipairs(data_list) do
            if self.zoneMgr.reward_list[v.id] == nil then
                local item = parent.transform:Find(tostring(v.id))
                if item == nil then
                    item = GameObject.Instantiate(self.GetGiftItem)
                else
                    item.gameObject:SetActive(false)
                    item = item.gameObject
                end
                self:SetGetGiftItem(item, v)
                self:AddCellToVisit(item.gameObject)
                has = true
            else
                local item = parent.transform:Find(tostring(v.id))
                if item == nil then
                    -- item = GameObject.Instantiate(self.GetGiftItem)
                else
                    item.gameObject:SetActive(false)
                end
            end
        end
    end
    self.LikeButton.gameObject.transform:Find("Red").gameObject:SetActive(has)
end



function ZoneMessagePanel:SetGetGiftItem(item, data)
    local its = item.transform
    local baseData = DataItem.data_get[data.item_id]
    if BaseUtils.isnull(its:Find("Head/ItemSlot")) then
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[data.item_id]
        info:SetBase(base)
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        table.insert(self.slotlist, slot)
        UIUtils.AddUIChild(its:Find("Head").gameObject,slot.gameObject)
    end
    its.gameObject.name = tostring(data.id)
    its:Find("NameText"):GetComponent(Text).text = baseData.name
    its:Find("NeedText"):GetComponent(Text).text = string.format(TI18N("需要:%s"), tostring(data.popularity))
    if self.myzoneData.liked >= data.popularity then
        its:Find("Button/Text"):GetComponent(Text).text = TI18N("可领取")
    else
        its:Find("Button/Text"):GetComponent(Text).text = TI18N("未满足")
    end
    its:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("Button"):GetComponent(Button).onClick:AddListener(function() self.zoneMgr:Require11848(data.id) end)
    its:Find("Button/No").gameObject:SetActive(self.myzoneData.liked < data.popularity)
    item.gameObject:SetActive(true)
end

-- 礼物详情
function ZoneMessagePanel:UpdataGiftInfo()
    local data_list = self.zoneMgr.mygift_list
    if self.zoneMgr.openself == false then
        data_list = self.zoneMgr.othergift_list
    end
    self.GiftLayout:ReSet()
    local parent = self.GiftCon.gameObject
    if data_list ~= nil and next(data_list) ~= nil then
        for k,v in ipairs(data_list) do
            local item = parent.transform:Find(BaseUtils.Key(v.role_id, v.platform, v.zone_id, v.id))
            if item == nil then
                item = GameObject.Instantiate(self.LikeItem)
            else
                item = item.gameObject
                item.gameObject:SetActive(false)
            end
            self:SetGiftItem(item, v)
        end
    end
end


function ZoneMessagePanel:SetGiftItem(item, data)
    -- BaseUtils.dump(data,"啊啊啊")
    local its = item.transform
    local sizeFit = its:Find("InfoText"):GetComponent(Text)
    its.gameObject.name = BaseUtils.Key(data.role_id, data.platform, data.zone_id, data.id)
    its:Find("Head"):GetComponent(Image).sprite = self.Main:GetHead(data.classes, data.sex)
    its:Find("NameText"):GetComponent(Text).text = data.name
    sizeFit.text = data.content
    local baseData = DataItem.data_get[data.presents[1].base_id]
    local id = its:Find("Image/GiftIcon").gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(its:Find("Image/GiftIcon").gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, baseData.icon)
    its:Find("NumText"):GetComponent(Text).text = tostring(data.presents[1].num)
    -- its:Find("TimeText").gameObject:SetActive(false)
    local day = math.floor((BaseUtils.BASE_TIME - data.ctime)/(3600*24))
    local hour = math.floor((BaseUtils.BASE_TIME - data.ctime)/3600)
    local min = math.floor((BaseUtils.BASE_TIME - data.ctime)/60)
    if min < 1 then
        min = 1
    end
    if day > 0 then
        its:Find("TimeText"):GetComponent(Text).text = string.format(TI18N("%s天前"), tostring(day))
    elseif hour > 0 then
        its:Find("TimeText"):GetComponent(Text).text = string.format(TI18N("%s小时前"), tostring(hour))
    else
        its:Find("TimeText"):GetComponent(Text).text = string.format(TI18N("%s分钟前"), tostring(min))
    end
    -- local headbtn = its:Find("Head").gameObject:GetComponent(Button) or its:Find("Head").gameObject:AddComponent(Button)
    -- headbtn.onClick:RemoveAllListeners()
    -- headbtn.onClick:AddListener(function() TipsManager.Instance:ShowPlayer(data) end)
    item.gameObject:SetActive(true)
    LuaTimer.Add(100, function() self.GiftLayout:AddCell(item) end)
end



function ZoneMessagePanel:OnCaiButton()
    if self.myzoneData.likable == 1 then
        self.zoneMgr:Require11836(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
        self.myzoneData.likable = 0
    else
        self.transform:Find("MainCon/Sub1Con/sub1/otherButton/CaiButton/Text"):GetComponent(Text).text = TI18N("已经赞过")
    end
end

function ZoneMessagePanel:OnAddFriendButton()
    if FriendManager.Instance:IsFriend(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id) then
        FriendManager.Instance:DeleteFriend(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)

    else
        FriendManager.Instance:AddFriend(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
    end
end

function ZoneMessagePanel:OnCareButton()
    if self.myzoneData.is_subscribed == 0 then
        self.zoneMgr:Require11827(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
        self.myzoneData.is_subscribed = 1
    else
        self.zoneMgr:Require11828(self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
    end
end


--------------------------空间聊天功能-----------------------------
function ZoneMessagePanel:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Zone,nil,nil,false)
    end
    self.chatExtPanel:Show()
end


function ZoneMessagePanel:AppendInputElement(element)
    -- 其他：同类只有一个，如果是自己，则过滤掉
    local delIndex = 0
    local srcStr = ""
    if element.type ~= nil then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type and element.type ~= MsgEumn.AppendElementType.Face then
                delIndex = i
                srcStr = has.matchString
            end
        end
    end

    local nowStr = self.inputfield.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        local repStr = element.matchString
        nowStr = string.gsub(nowStr, srcStr, repStr, 1)
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.inputfield.text = nowStr
end


function ZoneMessagePanel:CheckElement()
    if #self.appendTab == 0 then
        return false
    end
    local role = RoleManager.Instance.RoleData
    local str = self.inputfield.text
    for i,v in ipairs(self.appendTab) do
        local newSendStr = v.sendString
        if v.cacheType == MsgEumn.CacheType.Item then
            local cacheId = ChatManager.Instance.itemCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, v.num)
            end
        elseif v.cacheType == MsgEumn.CacheType.Pet then
            local cacheId = ChatManager.Instance.petCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{pet_1,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id)
            end
        elseif v.cacheType == MsgEumn.CacheType.Equip then
            local cacheId = ChatManager.Instance.equipCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, 1)
            end
        elseif v.cacheType == MsgEumn.CacheType.Guard then
            local cacheId = ChatManager.Instance.guardCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{guard_1,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id)
            end
        elseif v.cacheType == MsgEumn.CacheType.Wing then
            local cacheId = ChatManager.Instance.wingCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{wing_1,%s,%s,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, role.classes, v.grade, v.growth, cacheId, v.base_id, role.name)
            end
        elseif v.cacheType == MsgEumn.CacheType.Child then
            local name = string.sub(v.showString, 2, -2)
            local cacheId = ChatManager.Instance.childCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{child_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, name)
            end
        end
        str = string.gsub(str, v.matchString, newSendStr, 1)
    end
    -- self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, str)
    ChatManager.Instance:AppendHistory(self.inputfield.text)
    if self.reCallTarget == nil then
        ZoneManager.Instance:Require11823(0, str, self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
    else
        self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("发 送")
        self.trendInputField:Find("Placeholder"):GetComponent(Text).text = TI18N("输入内容")
        ZoneManager.Instance:Require11849(self.reCallTarget.id, str, self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
        self.reCallTarget = nil
    end
    self.appendTab = {}
    return true
end


function ZoneMessagePanel:OnMsgChange(val)
    if self.reCallTarget == nil then
    elseif self.reCallTarget ~= nil then
        local len = string.utf8len(val)
        if len > 0 then
            self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("回 复")
        else
            self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("返 回")
        end
    end
end


function ZoneMessagePanel:OnButtonSend()
    local msg = self.inputfield.text
    local len = string.len(msg)
    if len>0 and self.reCallTarget ~= nil then
        -- self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = "留 言"
        -- self.reCallTarget = nil
        -- self.trendInputField:Find("Placeholder"):GetComponent(Text).text = "输入内容"
    elseif len <= 0 and self.reCallTarget ~= nil then
        self.Sub1Con:Find("sub1/InputBar/SendButton/Text"):GetComponent(Text).text = TI18N("发 送")
        self.reCallTarget = nil
        self.trendInputField:Find("Placeholder"):GetComponent(Text).text = TI18N("输入内容")
    end

    if not self:CheckElement() and len>0 then
        if self.reCallTarget ~= nil then
            self.Main.inputMsg = msg
            self.Main.replyId = 1
            self.Main.mainId = self.reCallTarget.id
            self.Main:CheckWord()
        else
            if self.zoneMgr.targetInfo.id == RoleManager.Instance.RoleData.id and self.zoneMgr.targetInfo.platform == RoleManager.Instance.RoleData.platform and self.zoneMgr.targetInfo.zone_id == RoleManager.Instance.RoleData.zone_id then
                ZoneManager.Instance:Require11823(0,msg,self.zoneMgr.targetInfo.id, self.zoneMgr.targetInfo.platform, self.zoneMgr.targetInfo.zone_id)
                self.inputfield.text = ""
            else
                self.Main.inputMsg = msg
                self.Main.replyId = 2
                self.Main:CheckWord()

            end
        end
    end

end

function ZoneMessagePanel:Hiden()
    self.Sub1Con.gameObject:SetActive(false)
    self.Sub2Con.gameObject:SetActive(false)
    self.Sub3Con.gameObject:SetActive(false)
end

function ZoneMessagePanel:Show()
    local isSelect = false
    for i,v in pairs(self.Main.topbtn) do
        if v.activeSelf == true then
            isSelect = true
            break
        end
    end
    if isSelect == false then return end
    if self.Main.tabgroup ~= nil then
        self.Main.tabgroup:ChangeTab(1)
    end
    self.Main:OnTabChange(1)
end

