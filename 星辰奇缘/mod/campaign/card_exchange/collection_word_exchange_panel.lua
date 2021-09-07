-- @author hze
-- @date #2019/01/14#
-- 集字兑换活动

CollectionWordExchangePanel = CollectionWordExchangePanel or BaseClass(BasePanel)

function CollectionWordExchangePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "CollectionWordExchangePanel"

    self.resList = {
        {file = AssetConfig.collection_word_exchange_panel, type = AssetType.Main}
        ,{file = AssetConfig.card_exchange_bg4, type = AssetType.Main}
        ,{file = AssetConfig.cardexchangetexture, type = AssetType.Dep}
    }

    self.itemList = {}
    self.itembottomlist = {}
    self.itembottomlist_loader = {}
    self.itembottomlist_num = {}

    self.reloadItemListListener = function(data) self:ReLoadItemList(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CollectionWordExchangePanel:__delete()
    self.OnHideEvent:Fire()

    if self.layout ~= nil then 
        self.layout:DeleteMe()
    end

    if self.itemList ~= nil then 
        for k,v in ipairs(self.itemList) do
            v.resulticonloader:DeleteMe()
            if v.itemloader ~= nil then 
                for key,val in ipairs(v.itemloader) do
                    val:DeleteMe()
                end
            end
            if v.effect ~= nil then 
                v.effect:DeleteMe()
            end
        end
    end

    if self.itembottomlist_loader ~= nil then 
        for k,v in ipairs(self.itembottomlist_loader) do
            v:DeleteMe()
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CollectionWordExchangePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.collection_word_exchange_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local main = self.transform:Find("Main")
    local bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg4))
    UIUtils.AddBigbg(self.transform:Find("Main/Bg1"),bg)
    -- bg.transform.anchoredPosition = Vector2(-20,35)

    self.timeTxt = main:Find("TimeTxt"):GetComponent(Text)

    self.scrollRect = main:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function()
        self:OnRectScroll()
    end)
    self.itemContainer = main:Find("ScrollRect/Container")
    self.itemCloner = main:Find("ScrollRect/ItemCloner").gameObject
    self.itemCloner:SetActive(false)

    self.layout = LuaBoxLayout.New(self.itemContainer, {axis = BoxLayoutAxis.Y, cspacing = 4, Left = 7})

    for i = 1 ,6 do
        local m_slot = main:Find(string.format( "Bottom/Slot/ItemSlot%s", i))
        self.itembottomlist[i] = m_slot.gameObject
        self.itembottomlist_loader[i] = SingleIconLoader.New(m_slot:Find("Icon").gameObject)
        self.itembottomlist_num[i] = m_slot:Find("sign"):GetComponent(Text)
    end

    self.handselBtn = main:Find("Bottom/BuyBtn"):GetComponent(Button)
    self.handselBtn.onClick:AddListener(function() 
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.giftwindow,{index = 1})
    end)
end

function CollectionWordExchangePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CollectionWordExchangePanel:OnOpen()
    self:RemoveListeners()
    CardExchangeManager.Instance.OnUpdateItemListEvent:AddListener(self.reloadItemListListener)
    local campData = DataCampaign.data_list[self.campId]
    local s_m = campData.cli_start_time[1][2]
    local s_d = campData.cli_start_time[1][3]
    local e_m = campData.cli_end_time[1][2]
    local e_d = campData.cli_end_time[1][3]
    self.timeTxt.text = string.format("%s:%s%s%s%s-%s%s%s%s",TI18N("开业时间"),s_m,TI18N("月"),s_d,TI18N("日"),e_m,TI18N("月"),e_d,TI18N("日"))

    CardExchangeManager.Instance:Send20467()
end

function CollectionWordExchangePanel:OnHide()
    self:RemoveListeners()
end

function CollectionWordExchangePanel:RemoveListeners()
    CardExchangeManager.Instance.OnUpdateItemListEvent:RemoveListener(self.reloadItemListListener)
end

function CollectionWordExchangePanel:ReLoadItemList(data)
    self.layout:ReSet()
    for i,v in ipairs (data.plans) do
        local tab = self.itemList[i]
        if not tab then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.itemCloner)
            tab.transform = tab.gameObject.transform
            tab.resultObj = tab.transform:Find("ResultSlot").gameObject
            tab.resulticonloader = SingleIconLoader.New(tab.resultObj.transform:Find("Icon").gameObject)
            tab.itemObj = {}
            tab.itemloader = {}
            for i = 1, 6 do
                tab.itemObj[i] = tab.transform:Find(string.format("ItemSlot%s",i)).gameObject
                tab.itemloader[i] = SingleIconLoader.New(tab.itemObj[i].transform:Find("Icon").gameObject)
            end
            tab.limitTxt = tab.transform:Find("LimitTxt"):GetComponent(Text)
            tab.btn = tab.transform:Find("BuyBtn"):GetComponent(Button)
        end
        tab.limitTxt.text = string.format(TI18N("限兑:%s/%s"), v.all_times - v.times, v.all_times)
        tab.btn.onClick:RemoveAllListeners()
        tab.btn.onClick:AddListener(function() 
            self.model.lastitemContainerPosy = self.itemContainer.anchoredPosition.y
            CardExchangeManager.Instance:Send20468(v.plan_id) 
        end)
        tab.resultObj.transform:GetComponent(Button).onClick:RemoveAllListeners()
        tab.resultObj.transform:GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowItem({gameObject = tab.resultObj, itemData = DataItem.data_get[v.item_id], extra = { nobutton = true, inbag = false}
                })
        end)
        tab.resulticonloader:SetSprite(SingleIconType.Item, DataItem.data_get[v.item_id].icon)

        if tab.effect == nil then 
            if v.is_effect == 1 then 
                tab.effect = BaseUtils.ShowEffect(20138, tab.resultObj.transform ,Vector3(0.95,0.95,0.95),Vector3(0,0,-50))
            end   
        else
            tab.effect:SetActive(v.is_effect == 1)
        end 

        local items_count = #v.items
        for i =1 ,6 do
            if i > (6-items_count) then 
                tab.itemObj[i]:SetActive(true)  
                tab.itemloader[i]:SetSprite(SingleIconType.Item, DataItem.data_get[v.items[i+items_count-6].item_base_id].icon)
            else
                tab.itemObj[i]:SetActive(false)
            end
        end
        self.layout:AddCell(tab.gameObject)
        self.itemList[i] = tab
    end

    local count = #data.collect_items
    for i = 1 ,6 do
        if i > count then 
            self.itembottomlist[i]:SetActive(false)
        else
            local id = data.collect_items[i].collect_base_id
            self.itembottomlist_loader[i]:SetSprite(SingleIconType.Item, DataItem.data_get[id].icon)
            self.itembottomlist_num[i].text = BackpackManager.Instance:GetItemCount(id)
            self.itembottomlist[i]:SetActive(true)
        end
    end
    
    self:OnRectScroll()
    self.itemContainer.anchoredPosition = Vector2(self.itemContainer.anchoredPosition.x, self.model.lastitemContainerPosy + 0.1)
end


function CollectionWordExchangePanel:OnRectScroll()
    local container = self.scrollRect.content
    local top = -container.anchoredPosition.y
    local bottom = top - self.scrollRect.transform.sizeDelta.y

    for k,v in pairs(self.itemList) do
        local ay = v.gameObject.transform.anchoredPosition.y -10
        local sy = v.gameObject.transform.sizeDelta.y -20
        local state = nil
        if ay > top or ay - sy < bottom then
            state = false
        else
            state = true
        end
        if v.effect ~= nil then 
            v.effect:SetActive(state)
        end
    end
  end