MailPanel = MailPanel or BaseClass()

MainType = {
    player = 0,
    system = 1,
    announce = 3,
    }

function MailPanel:__init(Mainwin)
    self.Mainwin = Mainwin
    self.friendMgr = self.Mainwin.friendMgr
    self.model = self.Mainwin.model
    self.layout = self.Mainwin.Layout4
    self.BaseItem = self.Mainwin.MailItem
    self.itemSlot_list = {}

    self.mailListCon = self.Mainwin.LeftConGroup[4]:Find("Layout")
    self.mailinfoCon = self.Mainwin.RightConGroup[3]:Find("Con")

    self.hasguildmail = self.Mainwin.transform:Find("MainCon/LeftCon/GuildMailHas")
    self.guildmailItem = self.Mainwin.RightConGroup[3]:Find("Con2/Guildmail")
    self.guildmailItem:Find("ReportButton").gameObject:SetActive(false)    --//暂时屏蔽公会邮件举报
    self.guildmailCon = self.Mainwin.RightConGroup[3]:Find("Con2")
    local setting11 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.guildmailCon:Find("Mask")
    }
    self.guildmailLayout = LuaBoxLayout.New(self.guildmailCon:Find("Mask/Layout"), setting11)

    self.itemList = {}
    self.itemGuildList = {}

    self.selectItem = nil
    self.selectData = nil
    self.textcontent = self.mailinfoCon:Find("TextCount/MsgText"):GetComponent(Text)
    self.TextEXT = MsgItemExt.New(self.textcontent, 377, 18, 29)
    self.TitleTextEXT = MsgItemExt.New(self.mailinfoCon:Find("TitleText"):GetComponent(Text), 250, 17, 22)

    self.slotContainer = self.mailinfoCon:Find("ItemCon/ItemConScroll/SlotContainer")
    self.slot = self.mailinfoCon:Find("ItemCon/Slot1").gameObject
    self.slot:SetActive(false)

    self.mailList = {}
    self.slotlist = {}
end

function MailPanel:__delete()
    if self.slotlayout ~= nil then
        self.slotlayout:DeleteMe()
        self.slotlayout = nil
    end

    if self.slotlist ~= nil then
        for k,v in pairs(self.slotlist) do
            v:DeleteMe()
        end
        self.slotlist = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v.titleExt ~= nil then
                v.titleExt:DeleteMe()
            end
        end
        self.itemList = nmil
    end
    if self.itemGuildList ~= nil then
        for _,v in pairs(self.itemGuildList) do
            if v.textExt ~= nil then
                v.textExt:DeleteMe()
            end
        end
        self.itemGuildList = nil
    end
    if self.guildmailLayout ~= nil then
        self.guildmailLayout:DeleteMe()
        self.guildmailLayout = nil
    end
    if self.TextEXT ~= nil then
        self.TextEXT:DeleteMe()
        self.TextEXT =  nil
    end
    if self.TitleTextEXT ~= nil then
        self.TitleTextEXT:DeleteMe()
        self.TitleTextEXT =  nil
    end
end

function MailPanel:UpdateMailList()
    local list = self.friendMgr.mail_List
    local locallist = {}
    local parent = self.mailListCon.gameObject
    self.layout:ReSet()

    if self.friendMgr.guildmail_List ~= nil and next(self.friendMgr.guildmail_List) ~= nil then
        local item = parent.transform:Find("GuildMailHas")
        if item == nil then
            item = GameObject.Instantiate(self.hasguildmail.gameObject)
        end
        item.gameObject.name = "GuildMailHas"
        local num = self.friendMgr:GetUnReadGuildMailNum()
        item.transform:Find("num"):GetComponent(Text).text = tostring(num)
        item.transform:Find("num").gameObject:SetActive(num>0)
        item.transform:Find("Red").gameObject:SetActive(num>0)
        item.transform:Find("Head"):GetComponent(Image).sprite = self.Mainwin.assetWrapper:GetSprite(AssetConfig.chat_window_res, "Guild")
        item:GetComponent(Button).onClick:RemoveAllListeners()
        item:GetComponent(Button).onClick:AddListener(
            function()
                self:SwitchCon("Guild")
                if self.selectItem ~= nil then
                    self.selectItem.transform:Find("Select").gameObject:SetActive(false)
                end
                item.transform:Find("Red").gameObject:SetActive(false)
                item.transform:Find("num").gameObject:SetActive(false)
                self.selectItem = item
                self.selectData = data
                self.selectItem.transform:Find("Select").gameObject:SetActive(true)
            end
        )
        self.layout:AddCell(item.gameObject)
    end

    for k,v in pairs(list) do
        table.insert(locallist, {key = k, value = v})
    end
    for k,v in pairs(self.friendMgr.announce_list) do
        table.insert(locallist, {key = k, value = v})
    end
    table.sort( locallist, function(a,b) return a.value.rev_ts>b.value.rev_ts end )
    self.mailList = locallist
    for k,v in ipairs(locallist) do
        local item = self.itemList[v.key] or self:CreateItem()
        self.itemList[v.key] = item
        self:SetMailItem(item, v.value)
        self.layout:AddCell(item.gameObject)
    end
    self:CheckGuildMail()
end

function MailPanel:CreateItem()
    local tab = {}
    tab.gameObject = GameObject.Instantiate(self.BaseItem)
    tab.transform = tab.gameObject.transform
    tab.titleExt = MsgItemExt.New(tab.transform:Find("Title"):GetComponent(Text), 201)
    tab.headImage = tab.transform:Find("Head"):GetComponent(Image)
    tab.senderText = tab.transform:Find("Sender"):GetComponent(Text)
    tab.timeText = tab.transform:Find("Time"):GetComponent(Text)
    tab.red = tab.transform:Find("Red").gameObject
    tab.button = tab.gameObject:GetComponent(Button)
    tab.hasIcon = tab.transform:Find("Hasicon")
    return tab
end

function MailPanel:SetMailItem(item, data)
    local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
    item.gameObject:SetActive(true)
    item.titleExt:SetData(data.title)
    if data.type == MainType.system or data.type == MainType.announce then
        item.senderText.text = TI18N("发件人：系统")
    else
        item.senderText.text = TI18N("发件人：玩家")
    end
    local starTime = string.format(TI18N("%s月%s日"), os.date("%m", data.rev_ts), os.date("%d", data.rev_ts))
    local endTime = string.format(TI18N("%s月%s日"), os.date("%m", data.rev_ts+86400), os.date("%d", data.rev_ts+86400))

    item.timeText.text = string.format(TI18N("有效期：%s-%s"), starTime, endTime)
    item.red:SetActive(data.status == 0)
    item.button.onClick:RemoveAllListeners()
    item.hasIcon.gameObject:SetActive(data.item_list ~= nil and next(data.item_list) ~= nil and data.item_list.get ~= true)
    if data.type == 2 then
        item.headImage.sprite = self.Mainwin.assetWrapper:GetSprite(AssetConfig.chat_window_res, "Guild")
    elseif data.type == 1 or data.type == 3 then
        item.headImage.sprite = self.Mainwin.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NSystem")
    elseif data.type == 0 then
        item.headImage.sprite = self.Mainwin.assetWrapper:GetSprite(AssetConfig.chat_window_res, "Personal")
    end

    item.button.onClick:AddListener(function() self:OnClickItem(item, data) end)
    if self.selectItemId == item.gameObject then
        self:OnClickItem(item, data)
    end
end

function MailPanel:OnClickItem(item, data)
    self:SwitchCon("Normal")
    if self.selectItem ~= nil then
        self.selectItem.transform:Find("Select").gameObject:SetActive(false)
    end
    item.red:SetActive(false)
    self.selectItem = item.gameObject
    self.selectData = data
    self.selectItem.transform:Find("Select").gameObject:SetActive(true)
    self:ShowMail(self.selectData)
    self.Mainwin:CheckoutRedPoint()
end

function MailPanel:ShowMail(data)
    local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
    if data.status == 0 then
        if data.type < 3 then
            self.friendMgr:Require13401(data.sess_id, data.platform, data.zone_id)
        elseif data.type == 3 then
            AnnounceManager.Instance:send9923(data.sess_id)
        end
    end
    if data.del_type == 0 and #data.item_list == 0 and self.friendMgr.mail_List[uid] ~= nil then --阅读后无附件删除
        self.friendMgr:Require13403(data.sess_id, data.platform, data.zone_id, data.type)
    end
    -- self.mailinfoCon:Find("TitleText"):GetComponent(Text).text = data.title
    self.TitleTextEXT:SetData(data.title)
    -- self.mailinfoCon:Find("TextCount/MsgText"):GetComponent(Text).text = data.content
    self.TextEXT:SetData(data.content)
    local itemcon = self.mailinfoCon:Find("ItemCon")
    itemcon:Find("GetButton"):GetComponent(Button).onClick:RemoveAllListeners()
    if next(data.item_list) ~= nil then
        self.mailinfoCon:Find("TextCount").sizeDelta = Vector2(387, 213)
        itemcon.gameObject:SetActive(true)
        local num = #data.item_list
        if next(self.itemSlot_list) ~= nil then
            -- for _, slot in pairs(self.itemSlot_list) do
            --     GameObject.DestroyImmediate(slot.transform:Find("ItemSlot").gameObject)
            -- end
            for i, slot in pairs(self.itemSlot_list) do
                slot.gameObject:SetActive(i<=num)
            end

            for _,v in pairs(self.slotlist) do
                v:DeleteMe()
            end
            self.slotlist = {}
            -- self.itemSlot_list = {}
        end

        if self.slotlayout ~= nil then
            self.slotlayout:DeleteMe()
            self.slotlayout = nil
        end

        self.slotlayout = LuaBoxLayout.New(self.slotContainer.gameObject,{axis = BoxLayoutAxis.x, cspacing = 10, border = 5})

        for i,v in ipairs(data.item_list) do
            local slot = self.itemSlot_list[i]
            if slot == nil then
                slot = GameObject.Instantiate(self.slot)
                slot.name = tostring(i)
                self.itemSlot_list[i] = slot
            end
            self.slotlayout:AddCell(slot)
            self:CreatSlot(v, slot)
            -- if i<6 then
            --     local slot = itemcon:Find(string.format("Slot%s", tostring(i))).gameObject
            --     self:CreatSlot(v, slot)
            --     table.insert(self.itemSlot_list, slot)
            -- end
        end
        local getBtn = itemcon:Find("GetButton")
        local getAllBtn = itemcon:Find("GetAllButton")
        getBtn:GetComponent(Image).enabled = true
        itemcon:Find("GetButton/Text"):GetComponent(Text).color = Color(0.5647, 0.37647, 0.0784)
        itemcon:Find("GetButton/Text"):GetComponent(Text).text = TI18N("领取")
        getBtn:GetComponent(Button).onClick:RemoveAllListeners()
        getBtn:GetComponent(Button).onClick:AddListener(function() self.friendMgr:Require13402(data.sess_id, data.platform, data.zone_id, data.type) end)
        getBtn.anchoredPosition = Vector2(0, -83)
        getAllBtn:GetComponent(Button).onClick:RemoveAllListeners()
        getAllBtn:GetComponent(Button).onClick:AddListener(function() self:GetAllItem() end)
        local nogetnum = 0
        for k,v in pairs(self.mailList) do
            if v.value.item_list ~= nil and next(v.value.item_list) ~= nil and v.value.item_list.get ~= true then
                nogetnum = nogetnum + 1
            end
        end
        if nogetnum > 1 then
            getAllBtn.gameObject:SetActive(true)
            getAllBtn.anchoredPosition = Vector2(96, -83)
            getBtn.anchoredPosition = Vector2(-96, -83)
        else
            getAllBtn.gameObject:SetActive(false)
            getBtn.anchoredPosition = Vector2(0, -83)
        end
        -- getAllBtn.gameObject:SetActive(false)
        if data.item_list.get == true then
            self:AlreadyGet(self.selectData)
        end
    else
        self.mailinfoCon:Find("TextCount").sizeDelta = Vector2(387, 373)
        itemcon.gameObject:SetActive(false)
    end

    if data.type == 3 then
        data.status = 1
    end
end

function MailPanel:AlreadyGet(targetdata)
    if targetdata ~= nil then
        local uid = BaseUtils.Key(targetdata.sess_id, targetdata.platform, targetdata.zone_id)
        local item = self.mailListCon:Find(uid)
        if item ~= nil then
            item:Find("Red").gameObject:SetActive(false)
            item:Find("Hasicon").gameObject:SetActive(false)
        end
    end
    local nogetnum = 0
    for k,v in pairs(self.mailList) do
        if v.value.item_list ~= nil and next(v.value.item_list) ~= nil and v.value.item_list.get ~= true then
            nogetnum = nogetnum + 1
        end
    end
    -- self.mailinfoCon:Find("ItemCon/GetAllButton").gameObject:SetActive(nogetnum > 1)
    self.mailinfoCon:Find("ItemCon/GetAllButton").gameObject:SetActive(false)
    local itemcon = self.mailinfoCon:Find("ItemCon")
    itemcon:Find("GetButton"):GetComponent(Image).enabled = false
    itemcon:Find("GetButton/Text"):GetComponent(Text).color = Color(0.56, 0.91, 0.16)
    itemcon:Find("GetButton/Text"):GetComponent(Text).text = TI18N("已领取")
    itemcon:Find("GetButton").anchoredPosition = Vector2(0, -83)
    itemcon:Find("GetButton"):GetComponent(Button).onClick:RemoveAllListeners()
end

function MailPanel:CreatSlot(data, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    info:SetBase(data)
    local base = DataItem.data_get[data.base_id]
    info:SetBase(base)
    info.quantity = data.quantity
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotlist, slot)


    local trans = slot.gameObject.transform
    trans:SetParent(parent.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    local rect = trans:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    rect.localScale = Vector3.one
    -- rect.localPosition = Vector3.zero
    slot.gameObject:SetActive(true)

    -- UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end

function MailPanel:CheckGuildMail()
    local list = self.friendMgr.guildmail_List
    local locallist = {}
    local parent = self.guildmailCon:Find("Mask/Layout").gameObject
    self.guildmailLayout:ReSet()
    for k,v in pairs(list) do
        table.insert(locallist, {key = k, value = v})
    end
    table.sort( locallist, function(a,b) return (a.value.status < b.value.status) or (a.value.status == b.value.status and a.value.rev_ts > b.value.rev_ts) end )
    for k,v in ipairs(locallist) do
        local item = self.itemGuildList[v.key] or self:CreateGuildItem()
        self.itemGuildList[v.key] = item
        self:SetGuildMailItem(item, v.value)
        self.guildmailLayout:AddCell(item.gameObject)
    end
end

function MailPanel:CreateGuildItem()
    local tab = {}
    tab.gameObject = GameObject.Instantiate(self.guildmailItem.gameObject)
    tab.transform = tab.gameObject.transform
    tab.textExt = MsgItemExt.New(tab.transform:Find("Msg"):GetComponent(Text), 377, 16, 1)
    tab.timeText = tab.transform:Find("Time"):GetComponent(Text)
    tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
    tab.reportBtn = tab.transform:Find("ReportButton"):GetComponent(Button)
    return tab
end

function MailPanel:SetGuildMailItem(tab, data)
    tab.textExt:SetData(data.content)
    -- its:Find("Msg"):GetComponent(Text).text = data.content
    tab.transform.sizeDelta = Vector2(405, 76+tab.textExt.contentTrans.sizeDelta.y)
    tab.timeText.text = tostring(os.date("%c", data.rev_ts))
    tab.nameText.text = data.from_name
    tab.reportBtn.onClick:AddListener(function()  ReportManager.Instance:Send14704()   end)
end

function MailPanel:SwitchCon(type)
    self.Mainwin:SwitchRightGroup(3)
    if type == "Normal" then
        self.mailinfoCon.gameObject:SetActive(true)
        self.guildmailCon.gameObject:SetActive(false)
    elseif type == "Guild" then
        self.mailinfoCon.gameObject:SetActive(false)
        self.guildmailCon.gameObject:SetActive(true)
        for k,v in pairs(self.friendMgr.guildmail_List) do
            if v.status == 0 then
                self.friendMgr:Require13405(v.sess_id, v.platform, v.zone_id)
            end
        end
    end
end

function MailPanel:GetAllItem()
    for k,mail in pairs(self.friendMgr.mail_List) do
        if mail.item_list ~= nil and #mail.item_list>0 then
            if mail.status == 0 then
                self.friendMgr:Require13401(mail.sess_id, mail.platform, mail.zone_id)
            end
            self.friendMgr:Require13402(mail.sess_id, mail.platform, mail.zone_id, mail.type)
        end
    end

    LuaTimer.Add(1000, function() 
        if not BaseUtils.isnull(self.Mainwin) then 
            self:UpdateMailList() 
        end
    end)
end
-- [2] = {
--             from_name = "",
--             to_face = 0,
--             rev_ts = 1449046094,
--             from_face = 0,
--             from_zone_id = 1,
--             from_id = 0,
--             platform = "dev",
--             zone_id = 1,
--             del_type = 2,
--             item_list = {
--                 [1] = {
--                     step = 0,
--                     id = 0,
--                     base_id = 90002,
--                     enchant = -1,
--                     extra = {
--                     },
--                     expire_type = 0,
--                     pos = 0,
--                     attr = {
--                     },
--                     expire_time = 0,
--                     quantity = 100,
--                     look_id = 0,
--                     bind = 1,
--                     craft = 0,
--                 },
--             },
--             status = 0,
--             content = " 《星辰奇缘》精英玩家交流群：<color='#FFFF00'>484362455</color>\
-- \
-- 各位亲爱的《星辰奇缘》玩家，我们诚挚地希望与您交流，期待您为我们游戏提出宝贵的意见与建议，我们精心准备了丰厚的游戏礼包等您加群来领取哦，首测期间，我们还将在Q群和微信公众号中每日抽取一名幸运玩家赠送一张30元的充值卡。静候您的加入！\
-- \
-- 注：加群后别忘了找 <color='#FFFF00'>客服-小羽</color> 领取礼包哦\
--             ",
--             title = "玩星辰奇缘，加群领好礼",
--             from_platform = "dev",
--             to_name = "",
--             sess_id = 21,
--             type = 1,
--             ts = 1448970925,
--         },
