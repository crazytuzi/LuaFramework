-- @author 黄耀聪
-- @date 2017年4月27日

TribleGiftPanel = TribleGiftPanel or BaseClass(BasePanel)

function TribleGiftPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "TribleGiftPanel"

    self.dateTimeFormatString = TI18N("%s年%s月%s日%s时")
    self.freeBtnString = TI18N("免费领取")
    self.buyBtnString = TI18N("我要购买")
    self.hasFreeBtnString = TI18N("已领取")
    self.hasBuyBtnString = TI18N("已购买")
    self.hasFinishedString = TI18N("已结束")
    self.sureNoticeString = TI18N("限时礼包只能选择其中一个购买，<color='#ffff00'>仅有一次选择机会</color>，请考虑清楚哦！")
    self.checkForRewardString = TI18N("查看奖励")
    self.giftString = TI18N("使用获得以下所有道具：")

    self.lastFormatString = TI18N("原价:<color=#C7F9FF>%s</color>")
    self.nowFormatString = TI18N("现价:<color=#C7F9FF>%s</color>")

    self.freePriceString = TI18N("免费")

    self.path = "prefabs/ui/springfestival/buybuybuy.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
        {file = AssetConfig.shop_textures, type = AssetType.Dep},
    }

    self.itemList = {nil, nil, nil}
    self.giftPreview = nil

    self.updateUIListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TribleGiftPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v.nowIconLoader:DeleteMe()
            v.lastIconLoader:DeleteMe()
        end
    end
    if self.confirmData ~= nil then
        self.confirmData:DeleteMe()
        self.confirmData = nil
    end
    if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
    self:AssetClearAll()
end

function TribleGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "BuyThreePanel"
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.talkText = t:Find("TalkBg/Text"):GetComponent(Text)
    self.infoBtn = t:Find("InfoBtn"):GetComponent(Button)

    for i=1,3 do
        local item = t:Find("Container/Item"..i)
        self.itemList[i] = {
            lastText = item:Find("Last/Text"):GetComponent(Text),
            nowText = item:Find("Now/Text"):GetComponent(Text),
            buyBtn = item:Find("Button"):GetComponent(Button),
            buyImage = item:Find("Button"):GetComponent(Image),
            buyText = item:Find("Button/Text"):GetComponent(Text),
            bgBtn = item:Find("Bg"):GetComponent(Button),
            lastIconLoader = SingleIconLoader.New(item:Find("Last/Text/Icon").gameObject),
            nowIconLoader = SingleIconLoader.New(item:Find("Now/Text/Icon").gameObject),
            data = nil,
        }

        local j = i

        self.itemList[i].buyBtn.onClick:AddListener(function() self:OnClick(self.itemList[j].data) end)
        self.itemList[i].bgBtn.onClick:AddListener(function() self:OnShowItem(self.itemList[j].data) end)
    end
    self.itemList[2].buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    self.itemList[3].buyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")

    self.infoBtn.onClick:AddListener(function() self:ClickInfo() end)
end

function TribleGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TribleGiftPanel:OnOpen()
    self:RemoveListeners()
    BibleManager.Instance.onUpdateTrible:AddListener(self.updateUIListener)

    self.tribleData = self.model.currentTribleData

    self:InitUI()
end

function TribleGiftPanel:OnHide()
    self:RemoveListeners()
end

function TribleGiftPanel:RemoveListeners()
    BibleManager.Instance.onUpdateTrible:RemoveListener(self.updateUIListener)
end

function TribleGiftPanel:Update()
    if self.tribleData ~= nil then
        if self.model.currentTribleData == nil then
            for _,group in pairs(self.tribleData.group) do
                if group ~= nil then
                    group.status = 2
                end
            end
            self:InitUI()
        elseif self.model.currentTribleData.id ~= self.tribleData.id then
            self.confirmData = self.confirmData or NoticeConfirmData.New()
            self.confirmData.type = ConfirmData.Style.Sure
            self.confirmData.content = TI18N("活动已更新，点击确认刷新")
            self.confirmData.sureLabel = TI18N("确 认")
            self.confirmData.sureCallback = function() self.tribleData = self.model.currentTribleData self:InitUI() end
            NoticeManager.Instance:ConfirmTips(self.confirmData)
        else
            self:InitUI()
        end
    else
        self:InitUI()
    end
end

function TribleGiftPanel:InitUI()
    if self.tribleData == nil then return end
    self.talkText.text = self.tribleData.desc1

    BaseUtils.dump(self.tribleData.group, "self.tribleData.group")

    local i = 0
    for _,group in ipairs(self.tribleData.group) do
        local idList = {}
        for id,gift in pairs(group.gift_list) do
            if gift ~= nil then
                table.insert(idList, id)
            end
        end
        for _,id in ipairs(idList) do
            local gift = group.gift_list[id]
            i = i + 1
            local item = self.itemList[i]
            item.data = {id = self.tribleData.id, gift_id = gift.gift_id, reward = gift.reward, price = gift.price}
            item.lastText.text = string.format(self.lastFormatString, gift.origin_price[1].num)
            if GlobalEumn.CostTypeIconName[gift.origin_price[1].item_id] == nil then
                item.lastIconLoader:SetSprite(SingleIconType.Item, gift.origin_price[1].item_id)
            else
                item.lastIconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[gift.origin_price[1].item_id]))
            end

            if #gift.price > 0 then
                item.nowText.text = string.format(self.nowFormatString, gift.price[1].num)
                item.nowIconLoader.image.gameObject:SetActive(true)
                if GlobalEumn.CostTypeIconName[gift.price[1].item_id] == nil then
                    item.nowIconLoader:SetSprite(SingleIconType.Item, gift.price[1].item_id)
                else
                    item.nowIconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[gift.price[1].item_id]))
                end

                if group.status == 1 then
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    item.buyText.color = ColorHelper.DefaultButton4
                    item.buyText.text = self.hasBuyBtnString
                    item.buyBtn.enabled = false
                elseif group.status == 2 then
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    item.buyText.color = ColorHelper.DefaultButton4
                    item.buyText.text = self.hasFinishedString
                    item.buyBtn.enabled = false
                else
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    item.buyText.color = ColorHelper.DefaultButton3
                    item.buyText.text = self.buyBtnString
                    item.buyBtn.enabled = true
                end
            else
                item.nowIconLoader.image.gameObject:SetActive(true)
                item.nowText.text = string.format(self.nowFormatString, self.freePriceString)
                item.nowIconLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[90002]))

                if group.status == 1 then
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    item.buyText.color = ColorHelper.DefaultButton4
                    item.buyText.text = self.hasFreeBtnString
                    item.buyBtn.enabled = false
                elseif group.status == 2 then
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    item.buyText.color = ColorHelper.DefaultButton4
                    item.buyText.text = self.hasFinishedString
                    item.buyBtn.enabled = false
                else
                    item.buyImage.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    item.buyText.color = ColorHelper.DefaultButton3
                    item.buyText.text = self.freeBtnString
                    item.buyBtn.enabled = true
                end
            end
        end
    end
end

function TribleGiftPanel:ClickInfo()
    if self.tribleData ~= nil then
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {self.tribleData.desc2}})
    end
end

function TribleGiftPanel:ItemFilter(datalist)
    local list = {}
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    local lev = RoleManager.Instance.RoleData.lev
    local lev_break_times = RoleManager.Instance.RoleData.lev_break_times

    for _,v in ipairs(datalist) do
        if (v.classes == 0 or v.classes == classes) and
            (v.sex == 2 or v.sex == sex) and
            ((v.min_lev == 0 and v.max_lev == 0) or (v.min_lev <= lev and lev <= v.max_lev)) and
            ((v.min_lev_break == 0 and v.max_lev_break == 0) or (v.min_lev_break <= lev_break_times and lev_break_times <= v.max_lev_break)) then
            table.insert(list, {v.item_id, v.num})
        end
    end

    return list
end

function TribleGiftPanel:OnClick(data)
    if #data.price > 0 then
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        self.confirmData.sureCallback = function() BibleManager.Instance:send9948(data.id, data.gift_id) end
        self.confirmData.type = ConfirmData.Style.Normal
        self.confirmData.sureLabel = TI18N("取 消")
        self.confirmData.cancelLabel = TI18N("购 买")
        self.confirmData.content = self.sureNoticeString
        self.confirmData.blueSure = true
        self.confirmData.greenCancel = true
        self.confirmData.sureCallback = nil
        self.confirmData.cancelCallback = function() BibleManager.Instance:send9948(data.id, data.gift_id) end
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    else
        BibleManager.Instance:send9948(data.id, data.gift_id)
    end
end

function TribleGiftPanel:OnShowItem(data)
    if self.giftPreview == nil then
        self.giftPreview = GiftPreview.New(self.model.bibleWin.gameObject)
    end
    self.giftPreview:Show({reward = self:ItemFilter(data.reward), autoMain = true, text = self.giftString})
end
