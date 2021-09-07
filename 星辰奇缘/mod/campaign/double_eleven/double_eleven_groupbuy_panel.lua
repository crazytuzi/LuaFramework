--2016/11/4
--xjlong
--双十一全民团购活动
DoubleElevenGroupBuyPanel = DoubleElevenGroupBuyPanel or BaseClass(BasePanel)

function DoubleElevenGroupBuyPanel:__init(model, parent, mainWindow)
    self.model = model
    self.parent = parent
    self.mainWindow = mainWindow
    self.name = "DoubleElevenGroupBuyPanel"

    self.resList = {
        {file = AssetConfig.double_eleven_groupbuy_panel, type = AssetType.Main}
        ,{file = AssetConfig.groupbuytxtti18n, type = AssetType.Main}
        ,{file = AssetConfig.doubleeleven_res, type = AssetType.Dep}
        -- ,{file = AssetConfig.christmasgroupbuyi18n, type = AssetType.Main}
    }
    -- self.resList[#self.resList + 1] = {file = self.model.bg,type = AssetType.Main}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.hasInit = false

    self.updateItemData = function() self:OnUpdateItemData() end
end

function DoubleElevenGroupBuyPanel:__delete()
    self.OnHideEvent:Fire()
    self.hasInit = false
    if self.buyItemList ~= nil then
        for _,v in pairs(self.buyItemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.buyItemList = nil
    end
    if self.extraSlot ~= nil then
        self.extraSlot:DeleteMe()
        self.extraSlot = nil
    end

    if self.effectObj ~= nil then
        self.effectObj:DeleteMe()
        self.effectObj = nil
    end

    self:AssetClearAll()
end

function DoubleElevenGroupBuyPanel:OnHide()
    self:RemoveListeners()
end

function DoubleElevenGroupBuyPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.double_eleven_groupbuy_update, self.updateItemData)
end

function DoubleElevenGroupBuyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.double_eleven_groupbuy_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.ImgTop = self.transform:Find("ImgTop")
    self.ImgTop.transform:GetComponent(Image).enabled = false

    if self.bg ~= nil then 
        local obj = GameObject.Instantiate(self:GetPrefab(self.bg))
        -- local objTxt = GameObject.Instantiate(self:GetPrefab(AssetConfig.groupbuytxtti18n))
        -- UIUtils.AddBigbg(self.ImgTop.transform, objTxt)
        UIUtils.AddBigbg(self.ImgTop.transform, obj)
        obj.transform:SetAsFirstSibling()
        -- objTxt.transform.anchoredPosition = Vector2(10, 0)
    end
    self.ImgTop.gameObject:SetActive(true)

    self.TimeTxt = self.ImgTop:Find("TimeTxt"):GetComponent(Text)
    local cfgData = DataCampaign.data_list[self.campId]
    local msgTxt = string.format(TI18N("活动时间:<color='#00ff00'>%s年%s月%s日~%s月%s日</color>"), cfgData.cli_start_time[1][1], cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])
    msgTxt = string.format(TI18N("%s\n活动内容:%s"), msgTxt, cfgData.cond_desc)
    self.TimeTxt.text = msgTxt

    self.extraReward = self.transform:Find("ExtraReward")
    self.extraReward.anchoredPosition = Vector2(473, 183.69)
    self.extraRewarded = self.extraReward:Find("RewardedImage").gameObject

    self.extraSlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(self.transform:Find("ExtraReward"), self.extraSlot.gameObject)
    self.extraSlot.transform:SetSiblingIndex(1)

    self.extraRewarded:SetActive(false)

    local funTemp = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.extraSlot.gameObject.transform)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effectObj = BaseEffectView.New({effectId = 20209, time = nil, callback = funTemp})

    self.infoBtn = self.transform:Find("InfoBtn"):GetComponent(Button)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1、<color='#00ff00'>每日首购礼</color>：活动期间每日推出一款赠礼，当日<color='#ffff00'>首次购买</color>任一<color='#ffff00'>钻石团购礼包</color>即可领取（<color='#ffff00'>赠礼每天不同，喜欢的就不要错过哦</color>）"),
            TI18N("2、<color='#00ff00'>价格低更低</color>：团购礼包达到<color='#ffff00'>相应购买人数</color>后将获得<color='#ffff00'>更低折扣</color>！价格只会越来越低！"),
            TI18N("3、<color='#00ff00'>折扣超额返</color>：购买团购礼包后，每逢参团人数达到<color='#ffff00'>新折扣</color>，自动返还<color='#ffff00'>全额差价</color>，更附赠<color='#ffff00'>额外奖励</color>！越早下手，赠礼越多，先买不吃亏！{face_1,7}"),
            }})
        end)

    self.MaskCon = self.transform:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.buyItem = self.Container:Find("BuyItem")
    local buyItemRt = self.buyItem:GetComponent(RectTransform)
    buyItemRt.pivot = Vector2(0, 1)
    self.buyItem.gameObject:SetActive(false)

    self.buyItemList = {}
    for i = 1, 6 do
        local item = self:CreateBuyItem()
        table.insert(self.buyItemList, item)
    end

    self.single_item_height = buyItemRt.sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.buyItemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self.hasInit = true
    self:OnOpen()
end

function DoubleElevenGroupBuyPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.double_eleven_groupbuy_update, self.updateItemData)

    DoubleElevenManager.Instance:Send14045()
    if self.hasInit == false then
        return
    end

    self:UpdateWindow()
    self.vScroll.onValueChanged:Invoke({0, 1})
end

function DoubleElevenGroupBuyPanel:UpdateWindow()
    if self.model.reward_base_id == 0 then
        self.extraReward.gameObject:SetActive(false)
    else
        self.extraReward.gameObject:SetActive(true)
        self.itemData = DataItem.data_get[self.model.reward_base_id]
        self.extraSlot:SetAll(self.itemData, {inbag = false, nobutton = true})
        self.extraSlot:SetNum(self.model.reward_num or 0)
    end

    if self.model.has_reward and self.model.has_reward == 1 then
        self.extraRewarded:SetActive(true)
    else
        self.extraRewarded:SetActive(false)
    end

    local pos = self.Container.anchoredPosition.y
    local height = self.Container.sizeDelta.y

    self.setting.data_list = self.model.groupBuyData
    BaseUtils.refresh_circular_list(self.setting)

    self.vScroll.onValueChanged:Invoke({0, 1})
    self.Container.anchoredPosition = Vector2(0, pos)
    self.vScroll.onValueChanged:Invoke({0, 1 - pos / height})
end

function DoubleElevenGroupBuyPanel:CreateBuyItem()
    local itemObj = GameObject.Instantiate(self.buyItem)
    itemObj.transform:SetParent(self.Container.transform)
    itemObj.gameObject:SetActive(false)
    itemObj.transform.localScale = Vector3.one
    itemObj.transform.localPosition = Vector3.zero
    itemObj.transform.localRotation = Quaternion.identity

    local item = DoubleElevenGroupBuyItem.New(itemObj.gameObject, self.mainWindow)
    return item
end

function DoubleElevenGroupBuyPanel:OnUpdateItemData()
    self:UpdateWindow()
    -- self.setting.data_list = self.model.groupBuyData
    -- if self.model.has_reward and self.model.has_reward == 1 then
    --     self.extraRewarded:SetActive(true)
    -- else
    --     self.extraRewarded:SetActive(false)
    -- end

    -- local item = nil
    -- for i = 1, 6 do
    --     item = self.buyItemList[i]
    --     item:update_my_self(self.setting.data_list[item.index], item.index)
    -- end

end
