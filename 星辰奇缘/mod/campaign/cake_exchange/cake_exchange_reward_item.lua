-- region *.lua
-- Date 2017-5-4 jia
-- 此文件由[BabeLua]插件自动生成
-- 周年庆兑换活动兑换item
-- endregion
CakeExchangeRewardItem = CakeExchangeRewardItem or BaseClass()
function CakeExchangeRewardItem:__init(origin_item, _index)
    self.rewardData = nil
    self.index = _index
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.BtnExchange = self.transform:Find("BtnExchange"):GetComponent(Button)
    self.BtnExchange.onClick:AddListener(
    function()
        self:Exchange()
    end )
    self.BtnSelf = self.transform:GetComponent(Button)
    self.BtnSelf.onClick:AddListener(
    function()
        self:SelfBtnClick()
    end )
    self.TxtNeedPoint = self.transform:Find("ImgPoint/TxtNeedPoint"):GetComponent(Text)

    self.transform:Find("ImgPoint/TxtNeedPoint"):GetComponent(RectTransform).sizeDelta = Vector2(50,30)
    self.transform:Find("ImgPoint/TxtNeedPoint"):GetComponent(RectTransform).localPosition = Vector2(-15,0)
    self.TxtItemName = self.transform:Find("TxtItemName"):GetComponent(Text)
    self.TxtExchangeNum = self.transform:Find("TxtExchangeNum"):GetComponent(Text)
    self.ImgItem = self.transform:Find("ImgItemBg")
    self.ImgUnopen = self.transform:Find("ImgItemBg/ImgUnopen")
    self.ImgUnopen.gameObject:SetActive(false)
    local newX =(_index - 1) * 215
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)

    self.ImgPointIcon = self.transform:Find("ImgPoint/ImgPoint"):GetComponent(Image)
    self.imgLoader = SingleIconLoader.New(self.ImgPointIcon.gameObject)
    self.imgLoader:SetSprite(SingleIconType.Item, KvData.assets.cake_exchange)

    self.slot = nil
    self.tmpData = nil
end

function CakeExchangeRewardItem:SetData(data)
    local tmpData = data
    self.tmpData = tmpData
    self.TxtNeedPoint.text = tmpData.cost[1][2]
    if CakeExchangeManager.Instance:CheckExchangeIsOpen(tmpData) then
        self.ImgUnopen.gameObject:SetActive(false)
        if self.slot == nil then
            self.slot = ItemSlot.New()
            self.slot:ShowBg(false)
            self.slot.gameObject:SetActive(true)
            self.slot:SetGrey(false)
            UIUtils.AddUIChild(self.ImgItem.gameObject, self.slot.gameObject)
        end
        -- local itemtmp = tmpData.item_list[1]
        -- if itemtmp == nil then
        --     return
        -- end
        local baseid = tmpData.item_gift_id  --itemtmp[1]
        local item = BackpackManager.Instance:GetItemBase(baseid)
        item.bind = 0--itemtmp[2]
        item.quantity = 1--itemtmp[3]
        item.show_num = true
        local extra = { inbag = false, nobutton = true }
        self.slot:SetAll(item, extra)
        if self.effect ~= nil then
            self.effect:SetActive(true)
        else
            self.effect = BibleRewardPanel.ShowEffect(20223, self.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
        end
        self.TxtItemName.text = string.format(TI18N("<color='#c3692c'>%s</color>"), item.name)
    else
        self.ImgUnopen.gameObject:SetActive(true)
        self.TxtItemName.text = TI18N("<color='#c3692c'>神秘道具</color>")
    end
    local todayData = CakeExchangeManager.Instance.TodayList[tmpData.id]
    self.todayNum = tmpData.max
    if todayData ~= nil then
        self.todayNum = self.todayNum - todayData.num
    end
    if not CakeExchangeManager.Instance:CheckExchangeIsOpen(tmpData) then
        self.TxtExchangeNum.text = TI18N("兑换上一道具后开启")
        self.TxtNeedPoint.text = "？？"
    else
        if tmpData.max >= 999 then
            self.TxtExchangeNum.text = TI18N("兑换次数不限")
        else
            if self.todayNum <= 0 then
                self.TxtExchangeNum.text = string.format(TI18N("剩余兑换次数:<color='#df3435'>0</color>"))
            else
                self.TxtExchangeNum.text = string.format(TI18N("剩余兑换次数:%s"), self.todayNum)
            end
        end
    end
end

function CakeExchangeRewardItem:Exchange()
    if self.todayNum <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("奖励已经兑完"))
        return
    end
    if not CakeExchangeManager.Instance:CheckExchangeIsOpen(self.tmpData) then
        local preid = self.tmpData.pre_id;
        local prenum = self.tmpData.pre_num;
        local preTmp = DataCampExchange.data_camp_exchange_reward[preid];
        local preItemid = preTmp.item_list[1][1];
        local preItemData = BackpackManager.Instance:GetItemBase(preItemid);
        local tipStr = string.format(TI18N("兑换<color='#ffff00'>上个一道具</color>后可开启<color='#ffff00'>神秘道具</color>{face_1,7}"))
        NoticeManager.Instance:FloatTipsByString(tipStr)
        return
    end
    local pointNum = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.cake_exchange)
    if pointNum < self.tmpData.cost[1][2] then
        NoticeManager.Instance:FloatTipsByString(TI18N("积分不足，无法兑换"))
        local base_data = DataItem.data_get[KvData.assets.cake_exchange]
        local info = { itemData = base_data, gameObject = self.BtnExchange.gameObject }
        TipsManager.Instance:ShowItem(info)
        return
    end
    CakeExchangeManager.Instance:send17846(1, self.tmpData.id)
end

function CakeExchangeRewardItem:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function CakeExchangeRewardItem:SelfBtnClick()
    if not CakeExchangeManager.Instance:CheckExchangeIsOpen(self.tmpData) then
        local preid = self.tmpData.pre_id;
        local prenum = self.tmpData.pre_num;
        local preTmp = DataCampExchange.data_camp_exchange_reward[preid];
        local preItemid = preTmp.item_list[1][1];
        local preItemData = BackpackManager.Instance:GetItemBase(preItemid);
        local tipStr = string.format(TI18N("兑换<color='#ffff00'>上个一道具</color>后可开启<color='#ffff00'>神秘道具</color>{face_1,7}"))
        NoticeManager.Instance:FloatTipsByString(tipStr)
        return
    end
end

function CakeExchangeRewardItem:ShowEffect(bool)
    if self.effect ~= nil then
        self.effect:SetActive(bool)
    end
end