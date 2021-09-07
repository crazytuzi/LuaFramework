-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaEquip = EncyclopediaEquip or BaseClass(BasePanel)


function EncyclopediaEquip:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.Mgr = self.model.Mgr
    self.parent = parent
    self.name = "EncyclopediaEquip"

    self.resList = {
        {file = AssetConfig.equip_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }
    self.currclass = math.floor(RoleManager.Instance.RoleData.lev/10)
    if self.currclass == 0 then
        self.currclass = 1
    elseif self.currclass > 9 then
        self.currclass = 9
    end
    self.slotlist = {}
    self.currType = RoleManager.Instance.RoleData.classes
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaEquip:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.extra ~= nil then
        self.extra:DeleteMe()
    end
    if self.Layout1 ~= nil then
        self.extra:DeleteMe()
    end
    self:AssetClearAll()
end

function EncyclopediaEquip:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.ToggleList = t:Find("ToggleList")
    self.Background = t:Find("ToggleList/Background").gameObject
    self.Label = t:Find("ToggleList/Label"):GetComponent(Text)
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.ClassList:SetActive(open == false)
    end)

    self.ClassList = t:Find("ClassList").gameObject
    self.ClassListBtn = t:Find("ClassList/Button"):GetComponent(Button)
    self.ClassListBtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.ClassList:SetActive(false)
    end)
    self.ClassListCon = t:Find("ClassList/Mask/Scroll")
    self.ClassListItem = t:Find("ClassList/Mask/Scroll"):GetChild(0).gameObject
    self.ClassListItem:SetActive(false)

    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemListItem = t:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject
    -- self.ItemListItem:SetActive(false)
    -- self.top_right_TxtVal_list = {}
    -- for i=1,5 do
    --     local txtVal = self.transform:Find(string.format("Right/TxtVal_%s", i)):GetComponent(Text)
    --     table.insert(self.top_right_TxtVal_list, txtVal)
    -- end
    -- self.TxtName = self.transform:Find("Right/TxtName"):GetComponent(Text)
    -- self.TxtLev = self.transform:Find("Right/TxtLev"):GetComponent(Text)
    -- self.RightSlot = self.transform:Find("Right/SlotCon")
    self.extra = EquipTipsExt.New(self.transform:Find("Right").gameObject, self)
    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
    }
    self.Layout1 = LuaBoxLayout.New(self.ClassListCon, setting1)
    -- self.Layout2 = LuaBoxLayout.New(self.ItemListCon, setting2)
    self:RefreshItemList()
    for i=1,9 do
        local item = GameObject.Instantiate(self.ClassListItem)
        item.transform:Find("I18NText"):GetComponent(Text).text = TI18N(string.format(TI18N("%s级装备"), i*10))
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self.Label.text = item.transform:Find("I18NText"):GetComponent(Text).text
            self.currclass = i
            self.Background:SetActive(false)
            self.ClassList:SetActive(false)
            self:RefreshItemList()
        end)
        self.Layout1:AddCell(item)
    end
    self.Label.text = TI18N(string.format(TI18N("%s级装备"), self.currclass*10))
end

function EncyclopediaEquip:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaEquip:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaEquip:OnHide()
    self:RemoveListeners()
end

function EncyclopediaEquip:RemoveListeners()
end

function EncyclopediaEquip:OnClickClassItem(index)
    self.Background:SetActive(false)
    self.ClassList:SetActive(false)
    self.currclass = index
end

function EncyclopediaEquip:RefreshItemList()
    local equipdata = self.Mgr.EquipData[self.currclass*10]
    if equipdata == nil then
        return
    end
    self.ItemListCon.sizeDelta = Vector2(208, 72*#equipdata)
    -- BaseUtils.dump(self.Mgr.EquipData)
    for i=1,15 do

        local Item = self.ItemListCon:GetChild(i-1)
        if equipdata[i] == nil then
            Item.gameObject:SetActive(false)
        else
            Item.gameObject:SetActive(true)
            local lastItemSlot = Item:Find("ItemSlot")
            if lastItemSlot ~= nil then
                GameObject.Destroy(lastItemSlot.gameObject)
            end
            local SlotItemCon = Item:Find("ItemCon")
            local equipSlot = ItemSlot.New()
            UIUtils.AddUIChild(SlotItemCon, equipSlot.gameObject)
            equipSlot:SetAll(equipdata[i])
            equipSlot:SetNotips(true)
            table.insert(self.slotlist, equipSlot)
            Item:Find("ItemName"):GetComponent(Text).text = equipdata[i].name
            Item:Find("ItemLev"):GetComponent(Text).text = string.format(TI18N("%s 级装备"), equipdata[i].lev)
            Item:Find("Select").gameObject:SetActive(false)
            Item:GetComponent(Button).onClick:RemoveAllListeners()
            Item:GetComponent(Button).onClick:AddListener(function()
                if self.selectgo ~= nil then
                    self.selectgo:SetActive(false)
                end
                self.selectgo = Item:Find("Select").gameObject
                self.selectgo:SetActive(true)
                self.currType = equipdata[i].type
                self:ShowItem(equipdata[i])
            end)
            if self.currType == equipdata[i].type then
                if self.selectgo ~= nil then
                    self.selectgo:SetActive(false)
                end
                self.selectgo = Item:Find("Select").gameObject
                self.selectgo:SetActive(true)
                self:ShowItem(equipdata[i])
            end
        end
    end

end

function EncyclopediaEquip:ShowItem(equipdata)
    self.extra:Show(equipdata, true)
end
