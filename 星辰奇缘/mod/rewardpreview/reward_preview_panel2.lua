-- @author hze
-- @date #19/08/31#
-- @奖励预览面板--可上下滑动(展示单个礼包)
-- @parent一定要有rewardPreviewPanel2属性
RewardPreviewPanel2 = RewardPreviewPanel2 or BaseClass(BasePanel)

function RewardPreviewPanel2:__init(parent)
    self.name = "RewardPreviewPanel2"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.reward_preview_panel2, type = AssetType.Main},
        {file = AssetConfig.reward_preview_textures, type = AssetType.Dep},
    }

    self.titleString = TI18N("980 可获得该礼包全部奖励")

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardPreviewPanel2:__delete()
    self.OnHideEvent:Fire()

    for _, v in ipairs(self.itemList) do
        v:DeleteMe()
    end

    if self.grid ~= nil then 
        self.grid:DeleteMe()
    end

    if self.titleTxt then 
        self.titleTxt:DeleteMe()
    end

    if self.parent.rewardPreviewPanel2 ~= nil then 
        self.parent.rewardPreviewPanel2 = nil
    end
end

function RewardPreviewPanel2:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reward_preview_panel2))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform 
    local txt = self.transform:Find("TitleTxt")
    txt:SetParent(self.transform:Find("TitleBg"))
    txt.anchoredPosition = Vector2(15, -71)

    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.gameObject.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(
        function() self:DeleteMe() end
    )

    self.titleTxt = MsgItemExt.New(self.transform:Find("TitleBg/TitleTxt"):GetComponent(Text), 240, 18, 22)

    self.scroll = self.transform:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function()
        self:DealExtraEffect(self.scroll, self.itemList)
    end)
    self.container = self.scroll.transform:Find("Container")

    self.grid = LuaGridLayout.New(self.container, {column = 4, cspacing = 10, cellSizeX = 64, cellSizeY = 64, bordertop = 10, borderleft = 20})
end

function RewardPreviewPanel2:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardPreviewPanel2:OnOpen()
    if not self.openArgs then 
        Log.Error("RewardPreviewPanel2未传参")
        return 
    end
    local data = self.openArgs[1] or {}
    local titleString = self.openArgs[2]
    self.titleTxt:SetData(titleString)
    self:ReloadData(data)
end

function RewardPreviewPanel2:OnHide()

end

function RewardPreviewPanel2:ReloadData(data)
    -- BaseUtils.dump(data,"ssss")
    self.grid:ReSet()
    for i, v in ipairs(data) do
        local slot = ItemSlot.New()
        local itemVo = ItemData.New()
        itemVo:SetBase(DataItem.data_get[v.item_id])
        slot:SetAll(itemVo)
        slot:SetNum(v.item_num)
        slot:ShowEffect(v.effect ~= 0, v.effect) 
        self.grid:AddCell(slot.gameObject)
        self.itemList[i] = slot
    end
end


function RewardPreviewPanel2:DealData(data)
    local tabData = {}
    for _,v in ipairs(data) do
        local tab = {}
        tab.lev = v.bring_lev
        tab.desc = self.descString
        local gift_data
        if v.gift_type == 1 or v.gift_type == 2 then 
            gift_data = DataItemGift.data_show_gift_list[v.gift_id]
        elseif v.gift_type == 6 then 
            gift_data =DataItemGift.data_select_gift_list[v.gift_id]
        end
        tab.slotData = CampaignManager.ItemFilterForItemGift(gift_data)
        table.insert(tabData, tab)
    end
    return tabData
end

function RewardPreviewPanel2:DealExtraEffect(scrollRect,item_list)
    local delta1 =  0
    local delta2 =  0  

    local container = scrollRect.content

    local a_side = -container.anchoredPosition.y            
    local b_side = a_side - scrollRect.transform.sizeDelta.y  

    local a_xy,s_xy = 0,0
    for k,v in pairs(item_list) do
        a_xy = v.transform.anchoredPosition.y + delta1
        s_xy = v.transform.sizeDelta.y + delta1 - delta2
        if v.effect ~= nil then 
            v.effect:SetActive(a_xy < a_side and a_xy - s_xy > b_side)
        end
    end
end



