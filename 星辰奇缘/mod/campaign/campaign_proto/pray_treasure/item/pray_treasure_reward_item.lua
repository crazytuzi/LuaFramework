-- @author hze
-- @date #2019/09/19#
-- 祈愿宝阁rewardItem

PrayTreasureRewardItem = PrayTreasureRewardItem or BaseClass()

function PrayTreasureRewardItem:__init(model, gameObject, poolId, parent)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self._active = self.gameObject.activeSelf
    self.poolId = poolId
    self.parent = parent

    self.pool_cfg = DataCampPray.data_pool[self.poolId]
    self.items_cfg = self:GetItemsCfg()

    self.itemList = {}
    self.count = 0

    self:InitPanel()
end

function PrayTreasureRewardItem:__delete()
    if self.itemList then 
        for _, v in ipairs(self.itemList) do
            if v.slot then
                v.slot:DeleteMe()
            end
        end
    end
end

function PrayTreasureRewardItem:InitPanel()
    self.nameImg = self.transform:Find("Name"):GetComponent(Image)
    self.descTxt = self.transform:Find("Text"):GetComponent(Text)

    self.nameImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.praytreasuretextures, "name" .. self.pool_cfg.icon)

    self.container = self.transform:Find("Container")
    for i = 1, 6 do
        local tab = self.itemList[i] or {}
        if self.itemList[i] == nil then
            tab.transform = self.container:GetChild(i - 1)
            tab.gameObject = tab.transform
            tab.gameObject.name = BaseUtils.Key(self.poolId, i)
            tab.slotTrans = tab.transform:Find("Slot")
            tab.selectObj = tab.transform:Find("Mask").gameObject
            tab.cfg = self.items_cfg[i]
            if tab.cfg then
                if tab.slot == nil then
                    tab.slot = ItemSlot.New()
                    NumberpadPanel.AddUIChild(tab.slotTrans.gameObject, tab.slot.gameObject)
                end
                tab.data = ItemData.New()
                tab.data:SetBase(DataItem.data_get[tab.cfg.item_id])
                tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
                tab.slot:SetNum(tab.cfg.count)
                tab.slot:ShowEffect(tab.cfg.is_eff == 1, 20223)
                tab.slot:SetNotips()
            end
            tab.btn = tab.transform:GetComponent(Button)
            tab.btn.onClick:AddListener(function() self:OnItemClick(tab) end)
            self.itemList[i] = tab
        end
    end
end


function PrayTreasureRewardItem:SetData()
    self.data = self.model:GetSelectListByPoolId(self.poolId)
    -- BaseUtils.dump(self.data, "分类别选中列表")
    -- BaseUtils.dump(self.itemList, "itemList")
    
    local count = 0
    for i , v in ipairs(self.itemList) do
        if #self.data > 0 then
            for _, id in ipairs(self.data) do
                if v.cfg and v.cfg.id == id then
                    count = count + 1
                    v.selectObj:SetActive(true)
                    v.selectFlag = true
                    break
                else
                    v.selectObj:SetActive(false)
                    v.selectFlag = false
                end
            end
        else
            v.selectFlag = false
            v.selectObj:SetActive(false)
        end
        
    end
    self.count = count
    self.descTxt.text = string.format(TI18N("从以下道具中选择：<color='#248813'>%s</color>/%s"), self.pool_cfg.count - self.count, self.pool_cfg.count)    
end

function PrayTreasureRewardItem:OnItemClick(tab)
    if self.showTips then
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[tab.cfg.item_id])
        TipsManager.Instance:ShowItem({gameObject = tab.gameObject, itemData = itemData, extra = {nobutton = true}})
    else
        if not tab.selectFlag and self.count == self.pool_cfg.count then
            NoticeManager.Instance:FloatTipsByString("已达该组别可选择道具数量上限")
            return
        end
        tab.selectFlag = not tab.selectFlag
        tab.selectObj:SetActive(tab.selectFlag)
        if tab.selectFlag then
            self.model.prayTreasureCliSelectTab[tab.cfg.id] = tab.selectFlag
        else
            self.model.prayTreasureCliSelectTab[tab.cfg.id] = nil
        end

        if tab.selectFlag then
            self.count = self.count + 1
        else
            if self.count < 1 then
                self.count = 1
            end
            self.count = self.count - 1
        end
        self.descTxt.text = string.format(TI18N("从以下道具中选择：<color='#248813'>%s</color>/%s"), self.pool_cfg.count - self.count, self.pool_cfg.count)
    end
end

function PrayTreasureRewardItem:GetItemsCfg()
    local cfg = DataCampPray.data_items[self.poolId]
    local list = {}

    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex

    for i, v in ipairs(cfg) do
        if (lev >= v.min_lev and lev <= v.max_lev) or  (v.min_lev == 0 and v.max_lev == 0) then
            if sex == v.sex or v.sex == 2 then
                if classes == v.classes or v.classes == 0 then
                    table.insert(list, v)
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

function PrayTreasureRewardItem:SetEnabledTips(bool)
    self.showTips = bool
    -- for i , v in ipairs(self.itemList) do
    --     if v.slot and v.slot.button then
    --         v.slot.button.enabled = bool
    --         v.btn.enabled = not bool
    --     end
    -- end
end
