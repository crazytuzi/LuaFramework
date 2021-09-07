-- @author 黄耀聪
-- @date 2017年3月2日

LoveWishBackWindow = LoveWishBackWindow or BaseClass(BaseWindow)

--情谊礼盒物品Id
LoveWishBackWindow.CONFIG_ITEM_ID = 24027
function LoveWishBackWindow:__init(model)
    self.model = model
    self.name = "LoveWishBackWindow"

    self.windowId = WindowConfig.WinID.love_wish_back

    self.resList = {
        {file = AssetConfig.love_wish_back, type = AssetType.Main},
        {file = AssetConfig.valentine_textures, type = AssetType.Dep},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.open_server_luckymoney2,type = AssetType.Dep},
    }

    self.timeString2 = TI18N("倒计时：<color='#FFFF00'>%s时%s分</color>")
    self.timeString3 = TI18N("倒计时：<color='#FFFF00'>%s分%s秒</color>")
    self.timeString4 = TI18N("倒计时：<color='#FFFF00'>%s秒</color>")

    self.updateListener = function() self:Refresh() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.chooseNum = 2
    self.nowChooseNum = self.chooseNum

    self.loveWishBackReplyListener = function() self:ReplyBackWish() end

    self.tipsPanel = nil

    self.wishExt = nil
    self.noticeExt = nil
end

function LoveWishBackWindow:__delete()
    self.OnHideEvent:Fire()
    self:ReleaseField("headSlot")
    self:ReleaseField("wishExt")
    --self:ReleaseField("itemSlot")
    self:ReleaseField("imgLoader")
    local transform = self.transform
    transform:Find("Main/Reward"):GetComponent(Image).sprite = nil
    transform:Find("Main/Bg"):GetComponent(Image).sprite = nil
    transform:Find("Main/Bottom"):GetComponent(Image).sprite = nil

    if self.wishExt ~= nil then
        self.wishExt:DeleteMe()
    end

    if self.noticeExt ~= nil then
        self.noticeExt:DeleteMe()
    end

    if self.floatTimerId ~= nil then
        LuaTimer.Delete(self.floatTimerId)
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function LoveWishBackWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_wish_back))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self:InitPlayer()
    self:InitReward()
    self:InitButton()
    self.timeText = self.transform:Find("Main/Clock/Text"):GetComponent(Text)
    self.timeText.text = ""
    self.leftText = self.transform:Find("Main/Text3"):GetComponent(Text)
    self.leftText.gameObject:SetActive(false)
    self.rightText = self.transform:Find("Main/Text2"):GetComponent(Text)
    self.rightText.gameObject:SetActive(false)
    self.middleText = self.transform:Find("Main/Text1"):GetComponent(Text)


    if self.noticeExt == nil then
        self.noticeExt = MsgItemExt.New(self.middleText,240, 19, 22)
        local text = TI18N("1、帮Ta还愿可获得<color='#13fc60'>2</color>{assets_2,20002}\n2、选择诚挚还愿可获得5{assets_2,90048}，同时获得价值<color='#ffff00'>500钻</color>的诚挚大礼盒")
        self.noticeExt:SetData(text)
    end

    self.rewardNameText = self.transform:Find("Main/RewardName"):GetComponent(Text)
    self.rewardNameText.text = TI18N("<color='#ffff00'>诚挚大礼盒</color>")
    self.rewardNameText.gameObject:SetActive(true)
    self.wishText = self.transform:Find("Main/WishBg/WishText"):GetComponent(Text)
    self.wishBackText = self.transform:Find("Main/WishBg/WishBackText"):GetComponent(Text)

    -- self.middleText.text = TI18N("点击还愿即可获奖，挚诚还愿奖励更丰厚哦")
    -- self.transform:Find("Main/Text2"):GetComponent(Text).text = TI18N("可获<color='#00ff00'>双倍奖励</color>")
    self:Refresh()
    self:OnOpen()
end

function LoveWishBackWindow:InitPlayer()
    local transform = self.transform
    local headSlot = HeadSlot.New()
    self.headSlot = headSlot
    NumberpadPanel.AddUIChild(transform:Find("Main/Head"), headSlot.gameObject)
    self.nameText = transform:Find("Main/Name"):GetComponent(Text)
    self.wishItemText = transform:Find("Main/I18N"):GetComponent(Text)
    -- self.underLine = transform:Find("Main/Underline"):GetComponent(RectTransform)
    self.wishExt = MsgItemExt.New(transform:Find("Main/WishBg/Scroll/Text"):GetComponent(Text), 223, 19, 22)

    self.leftEnableTr = transform:Find("Main/LeftChoose/Enable")
    self.leftEnableTr.gameObject:SetActive(false)
    self.leftDisableTr = transform:Find("Main/LeftChoose/Diaable")
    self.leftDisableTr.gameObject:SetActive(false)

    self.rightEnableTr = transform:Find("Main/RightChoose/Enable")
    self.rightEnableTr.gameObject:SetActive(false)
    self.rightDisableTr = transform:Find("Main/RightChoose/Diaable")
    self.rightDisableTr.gameObject:SetActive(false)

end

function LoveWishBackWindow:InitReward()
    local transform = self.transform

    self.rewardIcon = transform:Find("Main/Reward").gameObject
    transform:Find("Main/Reward"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_luckymoney2,"I18NLuckyMoney2")
    transform:Find("Main/RewardName"):GetComponent(Text).text = DataItem.data_get[LoveWishBackWindow.CONFIG_ITEM_ID].name
    transform:Find("Main/RewardName").gameObject:SetActive(false)
    self:SetImg(DataItem.data_get[LoveWishBackWindow.CONFIG_ITEM_ID].icon)
    transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    transform:Find("Main/Bottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")


    self.buttonReward = self.rewardIcon:GetComponent(Button)
    self.buttonReward.onClick:AddListener(function() self:ShowPossibleReward() end)
end

function LoveWishBackWindow:SetImg(iconId)
    -- if self.imgLoader == nil then
    --     self.imgLoader = SingleIconLoader.New(self.rewardIcon)
    -- end
    -- self.imgLoader:SetSprite(SingleIconType.Item, iconId)
end

function LoveWishBackWindow:InitButton()
    local transform = self.transform

    self.button1 = transform:Find("Main/Button1"):GetComponent(Button)
    self.button1.onClick:AddListener(function() self:OnClickButton1() end)
    transform:Find("Main/Button1/Text"):GetComponent(Text).text = TI18N("还  愿")

    self.button2 = transform:Find("Main/Button2"):GetComponent(Button)
    self.button2.onClick:AddListener(function() self:OnClickButton2() end)
    transform:Find("Main/Button2/Text"):GetComponent(Text).text = TI18N("诚挚还愿")

    -- self.buttonTips = transform:Find("Main/Underline"):GetComponent(Button)
    -- self.buttonTips.gameObject:SetActive(false)
    -- self.buttonTips.onClick:AddListener(function() self:OnShowTips() end)

    -- self.underlineText = transform:Find("Main/Underline"):GetComponent(Text)
    -- self.leftChooseBtn = transform:Find("Main/LeftChoose"):GetComponent(Button)
    -- self.leftChooseBtn.onClick:AddListener(function() self:ApplyLeftChooseBtn() end)

    -- self.rightChooseBtn = transform:Find("Main/RightChoose"):GetComponent(Button)
    -- self.rightChooseBtn.onClick:AddListener(function() self:ApplyRightChooseBtn() end)

    transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function LoveWishBackWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LoveWishBackWindow:OnOpen()
    self:SetBaseData()
    self:RemoveListeners()
    -- self:InitChooseStatus()
    ValentineManager.Instance.onUpdateWish:AddListener(self.updateListener)
    ValentineManager.Instance.loveBackWishReply:AddListener(self.loveWishBackReplyListener)
end

function LoveWishBackWindow:SetBaseData()
    local data = DataWedding.data_get_whiteday_votive
    self:SetImg(DataItem.data_get[data[1].reward[1][1]].icon)


    self.leftText.text = string.format("可获<color='#00ff00'>%s*%s</color>",DataItem.data_get[data[1].reward[1][1]].name,data[1].reward[1][3])
    self.rightText.text = string.format("可获<color='#00ff00'>%s*%s</color>",DataItem.data_get[data[2].reward[1][1]].name,data[2].reward[1][3])
end
function LoveWishBackWindow:OnHide()
    self:RemoveListeners()

    if self.floatTimerId ~= nil then
         LuaTimer.Delete(self.floatTimerId)
     end
    self:DeleteTimer("timerId")
    self:DeleteTimer("floatTimerId")
end

function LoveWishBackWindow:RemoveListeners()
    ValentineManager.Instance.onUpdateWish:RemoveListener(self.updateListener)
    ValentineManager.Instance.loveBackWishReply:RemoveListener(self.loveWishBackReplyListener)
end

function LoveWishBackWindow:OnTick()
    local checkWishData = self.model.checkWishData
    if checkWishData ~= nil then
        self.d,self.h,self.m,self.s = BaseUtils.time_gap_to_timer(checkWishData.time - BaseUtils.BASE_TIME)

        if self.h ~= 0 then
            self.timeText.text = string.format(self.timeString2, self.h, self.m)
        elseif self.m ~= 0 then
            self.timeText.text = string.format(self.timeString3, self.m, self.s)
        else
            self.timeText.text = string.format(self.timeString4, self.s)
        end
    end
end

function LoveWishBackWindow:OnClickButton1()
    local confirmData = NoticeConfirmData.New()
    local cost = DataWedding.data_get_whiteday_votive[1].cost[1]
    confirmData.content = string.format(
        TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, 90000}进行<color='#ffff00'>心意还愿</color>，同时获得<color='#ffff00'>2</color>{assets_2, 20002}？"),
            cost[2],DataItem.data_get[LoveWishBackWindow.CONFIG_ITEM_ID].name
    )

    confirmData.sureCallback = function() ValentineManager.Instance:send17831(1) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function LoveWishBackWindow:OnClickButton2()
    local confirmData = NoticeConfirmData.New()
    local cost = DataWedding.data_get_whiteday_votive[2].cost[1]
    confirmData.content = string.format(
        TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, %s}进行<color='#ffff00'>诚挚还愿</color>，同时获得<color='#ffff00'>5</color>{assets_2, 90048}以及<color='#ffff00'>诚挚大礼盒</color>奖励？？"),
            cost[2], cost[1], DataItem.data_get[LoveWishBackWindow.CONFIG_ITEM_ID].name
    )
    confirmData.sureCallback = function() ValentineManager.Instance:send17831(2) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function LoveWishBackWindow:OnShowTips()
    -- local checkWishData = self.model.checkWishData
    -- local itemBaseId = checkWishData.reward[1].base_id
    -- local reward = ItemData.New()
    -- local base = DataItem.data_get[itemBaseId]
    -- reward:SetBase(base)
    -- TipsManager.Instance:ShowItem({gameObject = self.buttonTips.gameObject, itemData = reward,
    --     extra = {nobutton = true, inbag = false}})
end

function LoveWishBackWindow:ShowPossibleReward()
    local reward = DataWedding.data_get_whiteday_possible_reward[1].reward
    self.model:OpenPossibleReward(TI18N("打开可获得以下道具中的一种："), reward)
end

function LoveWishBackWindow:Refresh()
    if self.model.checkWishData == nil then
        return
    end
    local checkWishData = self.model.checkWishData
    local name = ""
    for k,v in ipairs(DataWedding.data_whiteday) do
        if checkWishData.type == v.type then
            name = v.title
        end
    end
    self.headSlot:SetAll({id = checkWishData.role_id, platform = checkWishData.platform, zone_id = checkWishData.zone_id, classes = checkWishData.classes, sex = checkWishData.sex})
    self.wishItemText.text = TI18N(string.format("许愿了<color='#00ff00'>%s</color>", name))
    local width = self.wishItemText.preferredWidth - 51;
    -- local uSizeDelta = self.underLine.sizeDelta
    -- self.underLine.sizeDelta = Vector2(width + 10, uSizeDelta.y)
    self.nameText.text = checkWishData.name
    self.wishExt:SetData(string.format("  %s",checkWishData.wish))
    self.wishText.text = TI18N("亲爱的" .. "<color='#ffff00'>" .. RoleManager.Instance.RoleData.name .. "</color>" .. "\n　　星语星愿一线牵,真情可贵愿望成,我想对你说:")
    self.wishBackText.text = TI18N("<color='#ffff00'>" .. self.model.checkWishData.name .. "</color>" .. "诚挚许愿")

    --if checkWishData.reward ~= nil then
    --    self.itemData:SetBase(DataItem.data_get[itemBaseId])
    --    self.itemSlot:SetAll(self.itemData, {inbag = false, nobutton = true})
    --end

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 500, function() self:OnTick() end)
    end
    if self.floatTimerId == nil then
        self.floatCounter = 0
        self.floatTimerId = LuaTimer.Add(0, 16, function() self:OnFloatItem() end)
    end
end

function LoveWishBackWindow:OnFloatItem()
        self.floatCounter = self.floatCounter + 1
        local position = self.rewardIcon.transform.localPosition
        self.rewardIcon.transform.localPosition = Vector2(position.x, position.y + 0.5 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
end

function LoveWishBackWindow:DeleteTimer(timerName)
    if self[timerName] ~= nil then
        LuaTimer.Delete(self[timerName])
        self[timerName] = nil
    end
end

function LoveWishBackWindow:ReleaseTable(tableName)
    for _, v in pairs(self[tableName]) do
        v:DeleteMe()
    end
    self[tableName] = {}
end

function LoveWishBackWindow:ReleaseField(fieldName)
    if self[fieldName] ~= nil then
        self[fieldName]:DeleteMe()
        self[fieldName] = nil
    end
end

-- function LoveWishBackWindow:InitChooseStatus()
--     local count = #DataWedding.data_get_whiteday_votive
--     local data = DataWedding.data_get_whiteday_votive
--     self:SetImg(DataItem.data_get[data[self.chooseNum].reward[1][1]].icon)

--     if self.chooseNum < count then
--         self.rightEnableTr.gameObject:SetActive(true)
--         self.rightDisableTr.gameObject:SetActive(false)
--     else
--         self.rightEnableTr.gameObject:SetActive(false)
--         self.rightDisableTr.gameObject:SetActive(true)
--     end

--     if self.chooseNum > 1 then
--         self.leftEnableTr.gameObject:SetActive(true)
--         self.leftDisableTr.gameObject:SetActive(false)
--     else
--         self.leftEnableTr.gameObject:SetActive(false)
--         self.leftDisableTr.gameObject:SetActive(true)
--     end

--     self.nowChooseNum = self.chooseNum
--     local name = DataItem.data_get[data[self.chooseNum].reward[1][1]].name
--     local num = data[self.chooseNum].reward[1][3]
-- end

-- function LoveWishBackWindow:ApplyLeftChooseBtn()
--     local data = DataWedding.data_get_whiteday_votive
--     local count = #DataWedding.data_get_whiteday_votive
--     if self.nowChooseNum >1 then
--         self.nowChooseNum = self.nowChooseNum - 1
--         self:SetImg(DataItem.data_get[data[self.nowChooseNum].reward[1][1]].icon)

--         if self.nowChooseNum < count then
--             self.rightEnableTr.gameObject:SetActive(true)
--             self.rightDisableTr.gameObject:SetActive(false)
--         else
--             self.rightEnableTr.gameObject:SetActive(false)
--             self.rightDisableTr.gameObject:SetActive(true)
--         end

--         if self.nowChooseNum > 1 then
--             self.leftEnableTr.gameObject:SetActive(true)
--             self.leftDisableTr.gameObject:SetActive(false)
--         else
--             self.leftEnableTr.gameObject:SetActive(false)
--             self.leftDisableTr.gameObject:SetActive(true)
--         end
--     end

--     local name = DataItem.data_get[data[self.nowChooseNum].reward[1][1]].name
--     local num = data[self.nowChooseNum].reward[1][3]
-- end

-- function LoveWishBackWindow:ApplyRightChooseBtn()
--     local data = DataWedding.data_get_whiteday_votive
--     local count = #DataWedding.data_get_whiteday_votive
--     if self.nowChooseNum < count then
--         self.nowChooseNum = self.nowChooseNum + 1
--         self:SetImg(DataItem.data_get[data[self.nowChooseNum].reward[1][1]].icon)

--         if self.nowChooseNum < count then
--             self.rightEnableTr.gameObject:SetActive(true)
--             self.rightDisableTr.gameObject:SetActive(false)
--         else
--             self.rightEnableTr.gameObject:SetActive(false)
--             self.rightDisableTr.gameObject:SetActive(true)
--         end

--         if self.nowChooseNum > 1 then
--             self.leftEnableTr.gameObject:SetActive(true)
--             self.leftDisableTr.gameObject:SetActive(false)
--         else
--             self.leftEnableTr.gameObject:SetActive(false)
--             self.leftDisableTr.gameObject:SetActive(true)
--         end
--     end
--     local name = DataItem.data_get[data[self.nowChooseNum].reward[1][1]].name
--     local num = data[self.nowChooseNum].reward[1][3]
-- end


function LoveWishBackWindow:ReplyBackWish()
   if self.tipsPanel == nil then
        self.tipsPanel = LoveWishTips.New(self)
    end

    self.tipsPanel:Show({false})
end

