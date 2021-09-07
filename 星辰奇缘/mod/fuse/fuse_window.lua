FuseWindow = FuseWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function FuseWindow:__init(model)
    self.model = model
    self.name = "FuseWindow"
    self.fuseMgr = self.model.fuseMgr
    self.resList = {
        {file = AssetConfig.fusewindow, type = AssetType.Main},
        {file = "prefabs/effect/20049.unity3d", type = AssetType.Main},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
    }
    self.index = 1
    self.indexItem = nil
    self.sub_index = 1
    self.sub_indexItem = nil
    self.last_id = 0
    self.iconloader = {}
end

function FuseWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    self:ClearDepAsset()
end

function FuseWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fusewindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWin() end)

    self.tabCon = self.transform:Find("Main/FusePanel/Bar/mask/Container")
    self.tabItem = self.transform:Find("Main/FusePanel/Bar/Button").gameObject
    self.subItem = self.transform:Find("Main/FusePanel/Bar/SubButton").gameObject

    self.fusePanel = self.transform:Find("Main/FusePanel/Panel/FusePanel")
    self.effect = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20049.unity3d"))
    self.effect.transform:SetParent(self.fusePanel)
    self.effect.transform.localPosition = Vector3(0.009719849, 120.9993, -400)
    self.effect.transform.localScale = Vector3.one
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    self.selectCon = self.fusePanel:Find("ChildCon")
    self.resultSlot = self.fusePanel:Find("ResultSlot")
    self.resultText = self.fusePanel:Find("ResultText"):GetComponent(Text)
    self.MergeText = self.fusePanel:Find("MergeText"):GetComponent(Text)
    self.rateText = self.fusePanel:Find("RateText"):GetComponent(Text)
    self.needSliverNum = self.fusePanel:Find("needslivernum"):GetComponent(Text)
    self.fuseBtn = self.fusePanel:Find("fusebtn"):GetComponent(Button)
    self.quickfuseBtn = self.fusePanel:Find("quickfusebtn"):GetComponent(Button)

    self.itemSlot1 = self.fusePanel:Find("ItemSlot1").gameObject
    self.itemSlot1_resultSlot = self.fusePanel:Find("ItemSlot1/ResultSlot")
    self.itemSlot1_resultText = self.fusePanel:Find("ItemSlot1/ResultText"):GetComponent(Text)
    self.itemSlot1_rateText = self.fusePanel:Find("ItemSlot1/RateText"):GetComponent(Text)

    self.itemSlot2 = self.fusePanel:Find("ItemSlot2").gameObject
    self.itemSlot2_resultSlot = self.fusePanel:Find("ItemSlot2/ResultSlot")
    self.itemSlot2_resultText = self.fusePanel:Find("ItemSlot2/ResultText"):GetComponent(Text)
    self.itemSlot2_rateText = self.fusePanel:Find("ItemSlot2/RateText"):GetComponent(Text)

    self.transform:Find("Main/FusePanel/Panel/FusePanel/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.fuseBtn.onClick:RemoveAllListeners()
    self.fuseBtn.onClick:AddListener(function() self.fuseMgr:Commit() end)
    self.quickfuseBtn.onClick:RemoveAllListeners()
    self.quickfuseBtn.onClick:AddListener(function() self.fuseMgr:Commit(true) end)
    if self.model.index ~= nil then
        self.index = tonumber(self.model.index)
        self.sub_index = tonumber(self.model.sub_index)
    end
    self:InitTabBar()
    self:InitSelectPanel()
    self.fuseMgr:SetTarget(self.index, self.sub_index)
    self:UpdatePanel()


end

function FuseWindow:InitTabBar()
    -- local setting = {
    --     axis = BoxLayoutAxis.Y
    --     ,spacing = 0
    --     ,Top = 0
    --     ,border = 0
    -- }
    -- self.TabLayout = LuaBoxLayout.New(self.TrendsCon, setting1)
    local currselectItem = nil
    local currselectSubItem = nil
    local List = self.fuseMgr.fuseTable
    for i,sub_List in ipairs(List) do
        local pItem = GameObject.Instantiate(self.tabItem)
        if self.index == i then
            currselectItem = pItem
        end
        pItem.gameObject.name = tostring(i)

        local id = pItem.transform:Find("MainButton/Image").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(pItem.transform:Find("MainButton/Image").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, sub_List[1].type_icon)
        pItem.transform:Find("MainButton/Enable/Text"):GetComponent(Text).text = sub_List[1].type
        pItem.transform:Find("MainButton/Disable/Text"):GetComponent(Text).text = sub_List[1].type
        pItem.transform:GetComponent(Button).onClick:AddListener(function() self:SelectTab(pItem.transform, i) end)
        for ii,v in ipairs(sub_List) do
            local sub_item = GameObject.Instantiate(self.subItem)
            if self.index == i and self.sub_index == ii then
                currselectSubItem = sub_item
            end
            sub_item.gameObject.name = tostring(ii)
            sub_item.transform:SetParent(pItem.transform)
            sub_item.transform:Find("Text"):GetComponent(Text).text = v.sub_type
            sub_item.transform:GetComponent(Button).onClick:AddListener(function() self:SelectSub(sub_item.transform, ii) end)
        end
        UIUtils.AddUIChild(self.tabCon.gameObject, pItem.gameObject)
        -- pItem.gameObject:SetActive(true)
    end
    if currselectItem ~= nil then
        self:SelectTab(currselectItem.transform, self.index)
    end
    -- if currselectSubItem ~= nil then
    --     self:SelectSub(currselectSubItem.transform, self.sub_index)
    -- end
end

function FuseWindow:SwitchSub(index, show)
    local parent = self.tabCon:Find(tostring(index))
    if parent ~= nil then
        local childnum = parent.childCount
        for i = 2, childnum-1 do
            local childbtn = parent:GetChild(i).gameObject
            childbtn:SetActive(show)
        end
    end
end

function FuseWindow:SelectTab(item, index)
    if self.index == index and self.indexItem == item then
        self.indexItem = item
        self:SwitchSub(index, false)
        self.index = 0
        self.indexItem:Find("MainButton/Enable").gameObject:SetActive(false)
        self.indexItem:Find("MainButton/Disable").gameObject:SetActive(true)
    else
        if self.index ~= index then
            self.sub_index = 1
        end
        if self.indexItem ~= nil then
            self:SwitchSub(self.index, false)
            self.indexItem:Find("MainButton/Enable").gameObject:SetActive(false)
            self.indexItem:Find("MainButton/Disable").gameObject:SetActive(true)
        end
        self.indexItem = item
        self.indexItem:Find("MainButton/Enable").gameObject:SetActive(true)
        self.indexItem:Find("MainButton/Disable").gameObject:SetActive(false)
        self:SwitchSub(index, true)
        self.index = index
        self:SelectSub(item:Find(tostring(self.sub_index)), self.sub_index)
    end
end

function FuseWindow:SelectSub(item, sub_index)
    if self.sub_index == sub_index and self.sub_item == item then

    else
        if self.sub_indexItem ~= nil then
            self.sub_indexItem:Find("Select").gameObject:SetActive(false)
            -- self.sub_indexItem:Find("Text"):GetComponent(Text).color = Color(0.5, 0.6, 0.8)
        end
        self.sub_indexItem = item
        self.sub_indexItem:Find("Select").gameObject:SetActive(true)
        -- self.sub_indexItem:Find("Text"):GetComponent(Text).color = Color(1,1,1)
        self.sub_index = sub_index
        self.fuseMgr:SetTarget(self.index, self.sub_index)
        self:UpdatePanel()
    end
end

function FuseWindow:ClearSlot(id)
    for i=1,4 do
        local slot = self.selectCon:Find(string.format("childitem%s/Slot/ItemSlot", tostring(i)))
        if slot ~= nil then
            GameObject.DestroyImmediate(slot.gameObject)
        end
    end
    local resultSlot = self.resultSlot:Find("ItemSlot")
    if resultSlot ~= nil then
        GameObject.DestroyImmediate(resultSlot.gameObject)
    end
    if id ~= nil then
        self:ShowFuseResultItem(id)
    end
end

function FuseWindow:UpdatePanel(id)
    self:UpdateRedPoint()
    local targetData = self.fuseMgr.targetData
    if self.last_id ~= targetData.next_base_id then
        self:ClearSlot(id)
    end
    -- BaseUtils.dump(targetData)
    if targetData ~= nil then
        if DoubleFuseType[targetData.type_index] then

            local nextdata = DataItem.data_get[targetData.next_base_id]

            if id == nil and RoleManager.Instance.RoleData.lev >= 10 and targetData.next_base_id == 20617 then
                local data_get = DataItem.data_get[20638]
                self:CreatSlot(20638, self.itemSlot1_resultSlot)
                self.itemSlot1_resultText.text = data_get.name
                self.itemSlot1_rateText.text = TI18N("25%")

                self:CreatSlot(targetData.next_base_id, self.itemSlot2_resultSlot)
                self.itemSlot2_resultText.text = nextdata.name
                self.itemSlot2_rateText.text = TI18N("75%")

                self.itemSlot1:SetActive(true)
                self.itemSlot2:SetActive(true)

                self.resultText.gameObject:SetActive(false)
                self.resultSlot.gameObject:SetActive(false)
                self.rateText.gameObject:SetActive(false)
            else
                self.resultText.text = nextdata.name
                if id == nil then
                    self:CreatSlot(targetData.next_base_id, self.resultSlot)
                end
                self.rateText.text = string.format(TI18N("成功率%s%%"), tostring(targetData.odds))

                self.itemSlot1:SetActive(false)
                self.itemSlot2:SetActive(false)

                self.resultText.gameObject:SetActive(true)
                self.resultSlot.gameObject:SetActive(true)
                self.rateText.gameObject:SetActive(true)
            end

            for i=1,4 do
                local citem = self.selectCon:Find(string.format("childitem%s", tostring(i)))
                citem.gameObject:SetActive(i<=targetData.need_num)
                citem:Find("Button").gameObject:SetActive(i<=targetData.need_num)
            end
            local baseData = BackpackManager.Instance:GetItemBase(targetData.base_id)
            local hasnum = BackpackManager.Instance:GetItemCount(targetData.base_id)
            for i=1,targetData.need_num do
                local child = self.selectCon:Find(string.format("childitem%s", tostring(i)))
                child:Find("Image2").gameObject:SetActive(false)
                child:Find("name"):GetComponent(Text).text = baseData.name
                if self.fuseMgr.needItem[i] == nil then
                    child:Find("need"):GetComponent(Text).text = TI18N("未选择")
                else
                    self:CreatSlot(targetData.base_id, child:Find("Slot"))
                    local backData = BackpackManager.Instance:GetItemById(self.fuseMgr.needItem[i])
                    local num = 1
                    child:Find("need"):GetComponent(Text).text, num = self:GetAttr(backData)
                    child:Find("Image2").gameObject:SetActive(num>1)
                end
                child:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
                child:Find("Button"):GetComponent(Button).onClick:AddListener(function() self.selectPanelObj:OpenSelectPanel(i) end)
            end

            self.needSliverNum.text = tostring(targetData.cost_assets[1][2] )
            if RoleManager.Instance.RoleData.coin >= targetData.cost_assets[1][2] then
                self.needSliverNum.color = Color(199/255,249/255,1)
            else
                self.needSliverNum.color = Color(1, 0, 0)
            end
            local canCreat = math.floor(hasnum/targetData.need_num)
            self.fuseBtn.transform:Find("redcon").gameObject:SetActive(canCreat>0)
            self.fuseBtn.transform:Find("redcon/redpoint/num"):GetComponent(Text).text = tostring(canCreat)
            -- self.fusePanel:Find("MergeText").gameObject:SetActive(true)
            if targetData.type_index == 3 then
                self.MergeText.gameObject:SetActive(true)
                self.MergeText.text = TI18N("合成后的护符拥有的技能和技能个数将被重置")
            elseif targetData.type_index == 10 then
                self.MergeText.gameObject:SetActive(false)
                self.MergeText.text = TI18N("合成后的项链拥有的技能和技能个数将被重置")
            end
            self.quickfuseBtn.gameObject:SetActive(false)
            self.fuseBtn.gameObject.transform.anchoredPosition3D = Vector3(130.74, -174, 0)
        else
            -- print("进来了")
            -- BaseUtils.dump(targetData)

            self.itemSlot1:SetActive(false)
            self.itemSlot2:SetActive(false)

            self.resultText.gameObject:SetActive(true)
            self.resultSlot.gameObject:SetActive(true)
            self.rateText.gameObject:SetActive(true)

            local baseData = BackpackManager.Instance:GetItemBase(targetData.base_id)
            local hasnum = BackpackManager.Instance:GetItemCount(targetData.base_id)
            local child = self.selectCon:Find("childitem1")
            -- self.resultText.text = targetData.sub_type
            local nextdata = DataItem.data_get[targetData.next_base_id]
            self.resultText.text = nextdata.name
            if self.last_baseid ~= targetData.base_id or self.last_id ~= targetData.next_base_id then
                self:CreatSlot(targetData.next_base_id, self.resultSlot, true)
                self.rateText.text = string.format(TI18N("成功率%s%%"), tostring(targetData.odds))
                for i=1,4 do
                    local citem = self.selectCon:Find(string.format("childitem%s", tostring(i)))
                    citem.gameObject:SetActive(i==1)
                    citem:Find("Image2").gameObject:SetActive(false)
                    citem:Find("Button").gameObject:SetActive(false)
                end
                child:Find("name"):GetComponent(Text).text = baseData.name
                child:Find("Image2").gameObject:SetActive(false)
                self:CreatSlot(targetData.base_id, child:Find("Slot"), false)
            end
            child:Find("need"):GetComponent(Text).text = string.format("%s/%s", tostring(hasnum), tostring(targetData.need_num))
            local canCreat = math.floor(hasnum/targetData.need_num)
            if hasnum/targetData.need_num >= 2 then
                self.quickfuseBtn.gameObject:SetActive(true)
                self.quickfuseBtn.transform:Find("redcon").gameObject:SetActive(canCreat>0)
                self.fuseBtn.transform:Find("redcon").gameObject:SetActive(false)
                self.quickfuseBtn.transform:Find("redcon/redpoint/num"):GetComponent(Text).text = tostring(canCreat)
                self.fuseBtn.gameObject.transform.anchoredPosition3D = Vector3(64.53, -174, 0)
            else
                self.quickfuseBtn.gameObject:SetActive(false)
                self.fuseBtn.transform:Find("redcon").gameObject:SetActive(false)
                self.fuseBtn.gameObject.transform.anchoredPosition3D = Vector3(130.74, -174, 0)
            end
            self.needSliverNum.text = tostring(targetData.cost_assets[1][2] )
            if RoleManager.Instance.RoleData.coin >= targetData.cost_assets[1][2] then
                self.needSliverNum.color = Color(199/255,249/255,1)
            else
                self.needSliverNum.color = Color(1, 0, 0)
            end
            -- self.fuseBtn.transform:Find("redcon").gameObject:SetActive(canCreat>0)
            -- self.fuseBtn.transform:Find("redcon/redpoint/num"):GetComponent(Text).text = tostring(canCreat)
            self.fusePanel:Find("MergeText").gameObject:SetActive(false)
            self.last_id = targetData.next_base_id
            self.last_baseid = targetData.base_id
        end
    end
end

function FuseWindow:CreatSlot(baseid, parent, nobtn)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[baseid]
    info:SetBase(base)
    local extra = {inbag = false, nobutton ~= (btn == false)}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end

function FuseWindow:CreatSlotInBag(bag_id, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = BackpackManager.Instance:GetItemById(bag_id)
    info:SetBase(base)
    local extra = {inbag = true ,nobutton = true}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    slot:ClickSelf()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

function FuseWindow:InitSelectPanel()
    self.selectPanel = self.transform:Find("SelectMain")
    -- self.selectPanel:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.selectPanel.gameObject:SetActive(false) end)
    self.selectPanel:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.selectPanel.gameObject:SetActive(false) end)
    self.originSelectItem = self.selectPanel:Find("mask/Item")
    self.petselectCon = self.selectPanel:Find("mask/ItemContainer")
    self.nonitem = self.selectPanel:Find("mask/NoItemTips").gameObject
    local buycallback = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1,3,9})
    end
    self.noitembutton = self.selectPanel:Find("mask/NoItemTips/Button"):GetComponent(Button).onClick:AddListener(buycallback)
    self.selectOkButton = self.selectPanel:Find("OkButton"):GetComponent(Button)
    self.selectOkButton.onClick:AddListener(function() self.selectPanel.gameObject:SetActive(false) end)
    self.selectDescText = self.selectPanel:Find("DescText"):GetComponent(Text)
    self.selectPanelObj = FuseItemSelect.New(self)
    self.nonitem.transform:Find("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "I18NMarketButtonIcon")
end



function FuseWindow:GetAttr(backpackData)
    local attr = backpackData.attr
    local attr_str = ""
    local skill_str = ""
    local num = 0
    for k,v in pairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s: +%s", KvData.attr_name[v.name], v.val)
                num = num + 1
            else
                if skill_str ~= "" then
                    skill_str = skill_str..string.format("\n[%s]", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
                else
                    skill_str = skill_str..string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
                end
                num = num + 1
            end
        end
    end
    if attr_str == "" then
        return skill_str, num
    else
        return attr_str, num
    end
end


function FuseWindow:UpdateRedPoint()
    local List = self.fuseMgr.fuseTable
    for i,sub_List in ipairs(List) do
        local subhas = 0
        for ii,v in ipairs(sub_List) do
            local hasnum = BackpackManager.Instance:GetItemCount(v.base_id)
            self.tabCon:Find(string.format("%s/%s/Red", tostring(v.type_index), tostring(v.sub_type_index))).gameObject:SetActive(hasnum>=v.need_num)
            if hasnum>=v.need_num then
                subhas = 1
            end
        end
        self.tabCon:Find(string.format("%s/Red", tostring(sub_List[1].type_index))).gameObject:SetActive(subhas>0)
    end
end

function FuseWindow:ShowEffect()
    self.effect:SetActive(true)
    LuaTimer.Add(1000, function() if not BaseUtils.is_null(self.effect) then self.effect:SetActive(false) end end)
end

function FuseWindow:ShowFuseResultItem(id)
    if self.gameObject == nil then
        return
    end
    local resultSlot = self.resultSlot:Find("ItemSlot")
    if resultSlot ~= nil then
        GameObject.DestroyImmediate(resultSlot.gameObject)
    end
    self:CreatSlotInBag(id, self.resultSlot)
end
