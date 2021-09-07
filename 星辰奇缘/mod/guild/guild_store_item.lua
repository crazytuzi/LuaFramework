GuildStoreItem = GuildStoreItem or BaseClass()

function GuildStoreItem:__init(parent, originItem, data, index)
    self.data = data
    self.index = index
    self.parent = parent

    self.gameObject = GameObject.Instantiate(originItem)
    self.transform = self.gameObject.transform
    self.transform:SetParent(originItem.transform.parent)
    self.transform.localScale = Vector3.one
    self.gameObject:SetActive(true)

    self.ImgSelectBg=self.transform:FindChild("ImgSelectBg"):GetComponent(Image)
    self.ImgSelectBg.gameObject:SetActive(false)
    self.ImgFinishSell = self.transform:FindChild("ImgFinishSell"):GetComponent(Image)
    self.ImgFinishSell.gameObject:SetActive(false)

    self.ImgShare = self.transform:FindChild("ImgShare"):GetComponent(Image)
    self.ImgShare.gameObject:SetActive(false)

    self.SlotCon= self.transform:FindChild("SlotCon").gameObject
    self.TxtName= self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtName.color = ColorHelper.DefaultButton10
    self.TxtExchangeNum= self.transform:FindChild("TxtExchangeNum"):GetComponent(Text)
    self.CostCon =  self.transform:FindChild("CostCon").gameObject
    self.TxtCost=  self.CostCon.transform:FindChild("TxtCost"):GetComponent(Text)
    self.ImgGx=  self.CostCon.transform:FindChild("ImgGx"):GetComponent(Image)
    self.TxtGx=  self.CostCon.transform:FindChild("TxtGx"):GetComponent(Text)
    self.ImgCoin=  self.CostCon.transform:FindChild("ImgCoin"):GetComponent(Image)


    -- event_manager:GetUIEvent(self.gameObject).OnDownCall:AddListener(GuildStoreItem:drag_begin)
    -- event_manager:GetUIEvent(self.gameObject).OnDragCall:AddListener(GuildStoreItem:draging)
    -- event_manager:GetUIEvent(self.gameObject).OnDragEndCall:AddListener(GuildStoreItem:drag_end)


    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:on_click_item() end)

    self:set_store_data()

    if self.parent.selected_data ~= nil and self.parent.selected_data.Id == self.data.Id then
        self:on_click_item()
    elseif index == 1 then
        self:on_click_item()
    end

    local newY = -45 + (math.ceil(index/2)-1)*-95
    local newX = 117
    if (index%2) == 0 then
        newX = 337
    end
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, newY)
end

function GuildStoreItem:Release()
    self.ImgCoin.sprite = nil
    self.ImgGx.sprite = nil
    self.slot:DeleteMe()
end

function GuildStoreItem:InitPanel(_data)

end

function GuildStoreItem:reset_data(data, index)
    self.data = data
    self.index = index
    self:set_store_data()
end

function GuildStoreItem:set_store_data()
    ---道具图标
    self.ImgFinishSell.gameObject:SetActive(false)
    self.ImgShare.gameObject:SetActive(false)
    self.TxtExchangeNum.text = ""

    if self.slot == nil then
        self.slot = ItemSlot.New()
        self.slot.gameObject.transform:SetParent(self.SlotCon.transform)
        self.slot.gameObject.transform.localScale = Vector3.one
        self.slot.gameObject.transform.localPosition = Vector3.zero
        self.slot.gameObject.transform.localRotation = Quaternion.identity
        local rect = self.slot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one
    end
    local cell = ItemData.New()
    cell:SetBase(DataItem.data_get[self.data.BaseId])
    self.slot:SetAll(cell, {inbag = false, nobutton = true})

    self.myItemData = DataItem.data_get[self.data.BaseId]

    self.TxtName.text = self.myItemData.name
--
    local leftNum = self.data.Limit-self.data.RoleNum

    if self.data.type == 3 then
        self.TxtExchangeNum.gameObject:SetActive(true)
        self.TxtExchangeNum.text= string.format("<color='#3166ad'>%s<color='#248813'>%s</color>%s</color>", TI18N("商店"), self.parent.model.my_guild_data.store_lev+1, TI18N("级可购买"))
    end

    -- if self.data.Limit ~= 0 then--有限购
    --     self.TxtExchangeNum.gameObject:SetActive(true)
    --     leftNum = self.data.Limit-self.data.RoleNum
    --     if leftNum == 0 then
    --         self.TxtExchangeNum.text= self.parent.model.guild_lang.GUILD_STORE_ITEM_LIMIT_1
    --     else
    --         if self.data.type == 3 then
    --             self.TxtExchangeNum.text= string.format("<color='#cc3333'>%s%s%s</color>", TI18N("商店"), self.parent.model.my_guild_data.store_lev+1, TI18N("级可购买"))
    --         else
    --             -- self.TxtExchangeNum.text= string.format(self.parent.model.guild_lang.GUILD_STORE_ITEM_LIMIT,leftNum)
    --             -- self.slot:SetNum(leftNum)
    --         end
    --     end
    -- else
    --     self.TxtExchangeNum.gameObject:SetActive(false)
    -- end

    local l = self.data.prices
    local myNum = 0
    if l[1].name >= 90000 then--资产
        if l[1].name == 90000 then
            myNum = RoleManager.Instance.RoleData.coin
        elseif l[1].name == 90002 then
            myNum = RoleManager.Instance.RoleData.gold
        elseif l[1].name == 90003 then
            myNum = RoleManager.Instance.RoleData.gold_bind
        elseif l[1].name == 90011 then
            myNum = RoleManager.Instance.RoleData.guild
        end
    else --道具
        myNum =mod_item.item_count(l[1].name)
    end

    if #self.data.prices==2 then
        if myNum < l[1].val then
            local temp = string.format("<color='#ff0000'>%d</color>",tostring(l[1].val))
            self.TxtCost.text = tostring(temp)
        else
            local temp = string.format("<color='#248813'>%d</color>",tostring(l[1].val))
            self.TxtCost.text = tostring(temp)
        end

        self.TxtGx.text = tostring(l[2].val)

        self.ImgCoin.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s",l[1].name))
        self.ImgCoin.gameObject:SetActive(true)
        self.ImgGx.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s",l[2].name))
        self.ImgGx.gameObject:SetActive(true)
    elseif #self.data.prices == 1 then
        if myNum < l[1].val then
            local temp = string.format("<color='#ff0000'>%d</color>",tostring(l[1].val))
            self.TxtCost.text = tostring(temp)
        else
            local temp = string.format("<color='#248813'>%d</color>",tostring(l[1].val))
            self.TxtCost.text = tostring(temp)
        end

        self.TxtGx.gameObject:SetActive(false)
        self.ImgCoin.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s",l[1].name))
        self.ImgCoin.gameObject:SetActive(true)
        self.ImgGx.gameObject:SetActive(false)
    end

    if self.data.type == 1 then
        --共享
        if self.data.Num == 0 then
            self.ImgFinishSell.gameObject:SetActive(true)
        elseif self.data.Num > 0 then
            self.ImgShare.gameObject:SetActive(true)
        end
    elseif self.data.type == 2 then
        if leftNum == 0 then
            self.ImgFinishSell.gameObject:SetActive(true)
        end
    end

    --非共享
    if leftNum ==0 and  self.data.Num ~= 0 then
        self.slot:SetNum(self.data.Num)
    elseif leftNum ~=0 and  self.data.Num == 0 then
        self.slot:SetNum(leftNum)
    elseif leftNum ~=0 and  self.data.Num ~= 0 then
        local show_num = leftNum >= self.data.Num and self.data.Num or leftNum
        self.slot:SetNum(show_num)
    else
        self.slot:SetNum(0)
    end


end


function GuildStoreItem:on_click_item()
    if self.parent.last_selected_item ~= nil then
        self:set_select(self.parent.last_selected_item,false)
    end

    self:set_select(self,true)
    self.parent:update_right_inner(self.data, self.myItemData)
    self.parent.last_selected_item = self
end


--设置选中状态
function GuildStoreItem:set_select(item,state)
    item.ImgSelectBg.gameObject:SetActive(state)
end