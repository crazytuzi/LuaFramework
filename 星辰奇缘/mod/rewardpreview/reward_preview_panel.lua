-- @author hze
-- @date #19/05/11#
-- @奖励预览面板--分层可上下滑动（左右滑动）
-- @parent一定要有rewardPreviewPanel属性
RewardPreviewPanel = RewardPreviewPanel or BaseClass(BasePanel)

function RewardPreviewPanel:__init(parent)
    self.name = "RewardPreviewPanel"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.reward_preview_panel, type = AssetType.Main},
        {file = AssetConfig.reward_preview_textures, type = AssetType.Dep},
    }

    self.titleString = TI18N("萌猫亲密%s级宝箱")
    self.descString = TI18N("可随机获得以下奖励中的一个：")

    self.itemList = {}
    self.slotList = {}

    --真的有毒
    self.otherList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RewardPreviewPanel:__delete()
    self.OnHideEvent:Fire()

    for _, v in ipairs(self.itemList) do
        BaseUtils.ReleaseImage(v.titleBgImg)
        if v.twoLayout ~= nil then 
            v.twoLayout:DeleteMe()
        end
        if v.slotList ~= nil then
            for _, vv in ipairs(v.slotList) do
                if v.itemslot ~= nil then 
                    v.itemslot:DeleteMe()
                end
        
                if v.itemData ~= nil then 
                    v.itemData:DeleteMe()
                end
            end
        end
    end


    if self.layout ~= nil then 
        self.layout:DeleteMe()
    end


    if self.parent.rewardPreviewPanel ~= nil then 
        self.parent.rewardPreviewPanel = nil
    end

    self:AssetClearAll()
end

function RewardPreviewPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reward_preview_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.gameObject.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(
        function() self:DeleteMe() end
    )

    self.scroll = self.transform:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function()
        -- self:DealExtraEffect2(self.scroll, self.itemList)
    end)
    self.container = self.scroll.transform:Find("Container")
    self.tempItem = self.scroll.transform:Find("Item").gameObject
    self.tempItem:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 22})

end

function RewardPreviewPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RewardPreviewPanel:OnOpen()
    if not self.openArgs then 
        Log.Error("RewardPreviewPanel未传参")
        return 
    end
    local data = self.openArgs or {}
    self:ReloadOneLevelData(self:DealData(data))
end

function RewardPreviewPanel:OnHide()

end

function RewardPreviewPanel:ReloadOneLevelData(data)
    local oneData = BaseUtils.copytab(data)
    self.layout:ReSet()
    for i, v in ipairs(oneData) do
        local tmp = self.itemList[i] or {}
        if self.itemList[i] == nil then 
            tmp.gameObject = GameObject.Instantiate(self.tempItem)
            tmp.transform = tmp.gameObject.transform
            tmp.titleBgImg = tmp.transform:Find("TitleBg"):GetComponent(Image)
            tmp.titleTxt = tmp.transform:Find("TitleBg/TitleTxt"):GetComponent(Text)
            tmp.descTxt = tmp.transform:Find("DescTxt"):GetComponent(Text)
            tmp.gameObject:SetActive(true)

            tmp.twoScroll = tmp.transform:Find("TwoLevelScrollRect"):GetComponent(ScrollRect)
            tmp.twoScroll.onValueChanged:RemoveAllListeners()
            tmp.twoScroll.onValueChanged:AddListener(function()
                -- self:DealExtraEffect(tmp.twoScroll, self.otherList[i])
            end)
        
            tmp.twoContainer = tmp.twoScroll.transform:Find("TwolevelContainer")
            tmp.tempSlot = tmp.twoScroll.transform:Find("Slot").gameObject
            tmp.tempSlot:SetActive(false)
        
            tmp.twoLayout = LuaBoxLayout.New(tmp.twoContainer,{axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
            tmp.slotList = {}
            
            self.itemList[i] = tmp
        end
        tmp.titleTxt.text = string.format(self.titleString, v.lev)
        tmp.descTxt.text = v.desc
        self.layout:AddCell(tmp.gameObject)
        self:ReloadTwoLevelData(i, v.slotData)
    end
    
end

function RewardPreviewPanel:ReloadTwoLevelData(i,data)
    local twoData = BaseUtils.copytab(data)
    self.itemList[i].twoLayout:ReSet()
     
    for j, v in ipairs(twoData) do
        local tmp = self.itemList[i].slotList or {}
        if self.itemList[i].slotList[j] == nil then 
            tmp.gameObject = GameObject.Instantiate(self.itemList[i].tempSlot)
            tmp.transform = tmp.gameObject.transform

            tmp.specail = tmp.transform:Find("Specail").gameObject
            tmp.slot = tmp.transform:Find("Slot")
            
            tmp.itemslot = ItemSlot.New()
            tmp.itemData = ItemData.New()
            UIUtils.AddUIChild(tmp.slot.gameObject, tmp.itemslot.gameObject)

            tmp.gameObject:SetActive(true)
            -- self.itemList[i].slotList[j] = tmp
        end

        tmp.itemData:SetBase(DataItem.data_get[v.item_id])
        tmp.itemslot:SetAll(tmp.itemData, {inbag = false, nobutton = true})
        tmp.itemslot:SetNum(v.num)
        tmp.specail:SetActive(v.is_effect == 1)
        -- tmp.itemslot:ShowEffect(v.is_effect == 1,20223)
        tmp.effect = tmp.itemslot.effect
        self.itemList[i].twoLayout:AddCell(tmp.gameObject)

        self.itemList[i].slotList[j] = tmp

        local other = {}
        other.trans = tmp.transform
        other.effect = tmp.itemslot.effect

        self.otherList[i] = self.otherList[i] or {}
        self.otherList[i][j] = other
    end
end


function RewardPreviewPanel:DealData(data)
    local tmpData = {}
    for _,v in ipairs(data) do
        local tmp = {}
        tmp.lev = v.bring_lev
        tmp.desc = self.descString
        local gift_data
        if v.gift_type == 1 or v.gift_type == 2 then 
            gift_data = DataItemGift.data_show_gift_list[v.gift_id]
        elseif v.gift_type == 6 then 
            gift_data =DataItemGift.data_select_gift_list[v.gift_id]
        end
        tmp.slotData = CampaignManager.ItemFilterForItemGift(gift_data)
        table.insert(tmpData, tmp)
    end
    return tmpData
end

function RewardPreviewPanel:DealExtraEffect(scrollRect,item_list)
    local delta1 =  2
    local delta2 =  0  

    local container = scrollRect.content

    local a_side = -container.anchoredPosition.x            
    local b_side = a_side + scrollRect.transform.sizeDelta.x  

    local a_xy,s_xy = 0,0
    for k,v in pairs(item_list) do
        a_xy = v.trans.anchoredPosition.x + delta1
        s_xy = v.trans.sizeDelta.x - delta1 - delta2
        if v.effect ~= nil then 
            v.effect:SetActive(a_xy > a_side and a_xy + s_xy < b_side)
        end
    end
end

function RewardPreviewPanel:DealExtraEffect2(scrollRect,item_list)
    -- local delta1 =  68  
    -- local delta2 =  10
    local delta1 =  0
    local delta2 =  0

    local container = scrollRect.content

    local a_side = container.anchoredPosition.y            
    local b_side = a_side + scrollRect.transform.sizeDelta.y

    local a_xy,s_xy = 0,0
    for k,v in pairs(item_list) do
        a_xy = v.transform.anchoredPosition.y + delta1
        s_xy = v.transform.sizeDelta.y - delta1 - delta2

        for _,other in pairs(self.otherList[k]) do
            if other.effect ~= nil then 
                other.effect:SetActive(a_xy > a_side and a_xy + s_xy < b_side)
            end
        end
    end
end


