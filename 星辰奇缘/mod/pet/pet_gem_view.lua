-- ----------------------------------------------------------
-- UI - 宠物符石窗口
-- ----------------------------------------------------------
PetGemView = PetGemView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetGemView:__init(model)
    self.model = model
    self.name = "PetGemView"
    self.windowId = WindowConfig.WinID.petgemwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.pet_gen_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.selectitem = nil
    self.selectitem2 = nil
    self.geniconlist = {}
    self.itemList = {}

    self.itemcontainer =  nil
    self.noitemtips =  nil
    self.okButton =  nil
    self.descText  = nil
    self.rrecommendSkillButton = nil
    self.buyButton = nil
    self.sumNum = 0
    self.curNum = 0
    self.canFuse = false

    self.itemSlotlist = {}

    self.showPrice = function() self:ShowPrice() end
    self.calculateNum = function()
        if self.selectitemdata2 ~= nil then
            self:CalculateNum(self.selectitemdata2)
        end
    end
    ------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

end

function PetGemView:__delete()
    self:OnHide()
    if self.itemSlotlist ~= nil then
        for k,v in pairs(self.itemSlotlist) do
            v:DeleteMe()
        end
        self.itemSlotlist = nil
    end

    if self.geniconlist ~= nil then
        for k,v in pairs(self.geniconlist) do
            v.slot:DeleteMe()
        end
        self.geniconlist = nil
    end

    if self.curSlot ~= nil then
        self.curSlot:DeleteMe()
        self.curSlot = nil
    end

    if self.buyConfirm ~= nil then
        self.buyConfirm:DeleteMe()
        self.buyConfirm = nil
    end

end

function PetGemView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_gen_window))
    self.gameObject.name = "PetGemView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.itemcontainer = self.transform:FindChild("Main/mask/ItemContainer").gameObject

    self.noitemtips = self.transform:FindChild("Main/mask/NoItemTips").gameObject
    self.noitemtips.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:open_gold_market() end)
    self.selectTips = self.noitemtips.transform:Find("selectTips").gameObject
    self.selectTips2 = self.noitemtips.transform:Find("selectTips2").gameObject
    self.marketButton = self.noitemtips.transform:Find("Button").gameObject
    self.marketImg = self.noitemtips.transform:Find("Image").gameObject

    self.wear = self.noitemtips.transform:Find("Wear").gameObject
    self.curGen = self.wear.transform:Find("Icon").gameObject

    self.genType = self.wear.transform:Find("GenType").gameObject:GetComponent(Text)
    self.genDesc = self.wear.transform:Find("Des").gameObject:GetComponent(Text)
    self.genPrice = self.wear.transform:Find("Price").gameObject:GetComponent(Text)
    self.fuseTips = self.wear.transform:Find("FuseTips").gameObject




    if self.curSlot == nil then
        self.curSlot = ItemSlot.New()
    end
    UIUtils.AddUIChild(self.curGen, self.curSlot.gameObject)
    self.price = self.wear.transform:Find("Price").gameObject:GetComponent(Text)

    self.numTxt = self.curSlot.transform:Find("Num").gameObject:GetComponent(Text)
    self.numRect = self.numTxt.gameObject:GetComponent(RectTransform)

    local nbg = self.curSlot.transform:Find("NumBg")
    if nbg ~= nil then
        self.numBg = nbg.gameObject
        self.numBgRect = self.numBg:GetComponent(RectTransform)
    end

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.okButton:SetActive(false)
    self.wearButton = self.transform:FindChild("Main/WearButton").gameObject
    self.wearButton:GetComponent(Button).onClick:AddListener(function() self:OnClickWear() end)
    self.wearButton:SetActive(false)

    self.descText = self.transform:FindChild("Main/DescText"):GetComponent(Text)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetGemView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetGemView:OnShow()
    self.descText.text = ""
    self.okButton:SetActive(false)
    self:update()
    PetManager.Instance.onGetPrice:AddListener(self.showPrice)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.calculateNum)
end

function PetGemView:OnHide()
    self.selectitem = nil
    self.selectitemdata = nil
    self.selectitemdata2 = nil
    PetManager.Instance.onGetPrice:RemoveListener(self.showPrice)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.calculateNum)

end

function PetGemView:update()
    if self.model.cur_petdata == nil then return end

    for k,v in pairs(self.itemList) do
        GameObject.Destroy(v)
    end
    self.itemList = {}
    local data_pet_gem = DataPet.data_pet_gem[string.format("%s_%s_%s", self.model.cur_petdata.base_id, self.model.cur_petdata.grade, self.model.select_gem)].allow_stone
    local attrgem_list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petattrgem)
    local skillgem_list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petskillgem)
    local itemlist = {}
    local itemlist2 = {}
    if self.model.select_gem == 1 then
        for k,v in pairs(skillgem_list) do
            if table.containValue(data_pet_gem, v.base_id) then
                table.insert(itemlist, v)
            end
        end
    else
        for k,v in pairs(attrgem_list) do
            if table.containValue(data_pet_gem, v.base_id) then
                table.insert(itemlist2, v)
            end
        end
    end

    local itempanel = self.itemcontainer
    local itemobject =  itempanel.transform:FindChild("Item").gameObject

    if #itemlist > 0 then
        itempanel:SetActive(true)
        self.noitemtips:SetActive(false)

        for i=1,#itemlist do
            local itemdata = itemlist[i]
            local item = GameObject.Instantiate(itemobject)
            UIUtils.AddUIChild(itempanel, item)
            table.insert(self.itemList, item)
            local fun = function()
                self:item_click(item, itemdata)
            end
            item:GetComponent(Button).onClick:AddListener(fun)

            local slot = ItemSlot.New()
            UIUtils.AddUIChild(item.transform:FindChild("Item").gameObject, slot.gameObject)
            slot:SetAll(itemdata)
            table.insert(self.itemSlotlist, slot)

            item.transform:FindChild("Name"):GetComponent(Text).text = itemdata.name
            self:setitemattr(item, itemdata.attr)
        end
    else
        itempanel:SetActive(false)
        self.noitemtips:SetActive(true)

        local iconpanel = self.transform:FindChild("Main/mask/NoItemTips/IconPanel").gameObject
        local iconobject =  iconpanel.transform:FindChild("Icon").gameObject
        for i=1,#data_pet_gem do
            local genicon = self.geniconlist[i]

            local base_id = data_pet_gem[i]
            local base_data = ItemData.New()
            base_data:SetBase(BackpackManager.Instance:GetItemBase(base_id))

            if genicon == nil then
                local object = GameObject.Instantiate(iconobject)
                -- UIUtils.AddUIChild(iconpanel, object)
                object.transform:SetParent(iconpanel.transform)
                object.transform.localScale = Vector3.one

                local slot = ItemSlot.New()
                UIUtils.AddUIChild(object, slot.gameObject)
                slot.name = "Slot"

                if self.model.select_gem ~= 1 then
                    local btn = slot.gameObject:GetComponent(Button)
                    btn.onClick:RemoveAllListeners()
                    if base_data ~= nil then
                        btn.onClick:AddListener(function() self:gen_click(slot,base_data) end)
                        --self.selectitemdata2 = base_data
                    end
                end
                genicon = {object = object, slot = slot}
                table.insert(self.geniconlist, genicon)
            end

            if base_data ~= nil then
                genicon.slot:SetAll(base_data)
                genicon.object.transform:FindChild("Text"):GetComponent(Text).text = ColorHelper.color_item_name(base_data.quality, BaseUtils.string_cut(base_data.name, 15, 12))

                local numTxt = genicon.slot.transform:Find("Num").gameObject:GetComponent(Text)
                local numRect = numTxt.gameObject:GetComponent(RectTransform)
                local nbg = genicon.slot.transform:Find("NumBg")
                local numBg = nbg.gameObject
                local numBgRect = numBg:GetComponent(RectTransform)
                local num =  BackpackManager.Instance:GetItemCount(base_id)

                if num == 0 then
                    numTxt.gameObject:SetActive(false)
                    numBg:SetActive(false)
                else
                    numTxt.gameObject:SetActive(true)
                    numBg:SetActive(true)
                    numTxt.text = num
                    local w = math.max(math.ceil(numTxt.preferredWidth) + 1, 18)
                    numRect.sizeDelta = Vector2(w, 24)
                    numBgRect.sizeDelta = Vector2(w + 2, 18)
                    local xprefix = -4.37
                    if w >= 56 then
                        xprefix = 0
                    end
                    numBgRect.anchoredPosition = Vector2(xprefix, numBgRect.anchoredPosition.y)
                    numTxt.transform.anchoredPosition = Vector2(xprefix, numBgRect.anchoredPosition.y + 0.5)
                    numTxt.transform.sizeDelta = numBgRect.sizeDelta
                end
            end

            genicon.object:SetActive(true)
        end

        for i=#data_pet_gem+1, #self.geniconlist do
            self.geniconlist[i].object:SetActive(false)
        end

        if self.model.select_gem == 1 then
            self.selectTips:SetActive(false)
            self.selectTips2:SetActive(true)
            self.marketButton:SetActive(true)
            self.marketImg:SetActive(true)
        else
            self.selectTips:SetActive(true)
            self.selectTips2:SetActive(false)
            self.marketButton:SetActive(false)
            self.marketImg:SetActive(false)
        end
    end
end

function PetGemView:setitemattr(item, attr)
    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s+%s", KvData.attr_name[v.name], v.val)
            else
                skill_str = skill_str..string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
            end
        end
    end
    if attr_str == "" then
        item.transform:FindChild("Desc"):GetComponent(Text).text = TI18N("技能:")
        item.transform:FindChild("Skill"):GetComponent(Text).text = skill_str
    else
        item.transform:FindChild("Desc"):GetComponent(Text).text = attr_str
    end
end

function PetGemView:open_gold_market()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 3, 9})
end

function PetGemView:item_click(item, itemdata)
    if self.selectitem ~= nil then
        self.selectitem.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.selectitem = item
    self.selectitemdata = itemdata
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self.okButton:SetActive(true)
    if self.model.cur_petdata ~= nil and self.model.cur_petdata.lev < 30 then
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("30级可用")
    else
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("穿戴")
    end


    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(itemdata.attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s: <color='#00ff00'>+%s</color>", KvData.attr_name[v.name], v.val)
            else
                -- print(v.val)
                skill_str = skill_str..string.format("<color='#00ff00'>[%s]</color>", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
            end
        end
    end
    if attr_str == "" then
        self.descText.text = string.format(TI18N("附带技能: %s"), skill_str)
    else
        self.descText.text = string.format(TI18N("增加宠物%s"), attr_str)
    end
end

function PetGemView:button_click()
    if self.selectitemdata ~= nil then
        if 30 > self.model.cur_petdata.lev then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("宠物等级不足，需要<color='#00ff00'>%s级</color>才能装备"), 30))
        else
            if self.model.gem_type == 0 then
                PetManager.Instance:Send10507(self.model.cur_petdata.id, self.selectitemdata.id, self.model.select_gem)
                self:OnClickClose()
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                        PetManager.Instance:Send10507(self.model.cur_petdata.id, self.selectitemdata.id, self.model.select_gem)
                        self:OnClickClose()
                    end
                if self.model.gem_type == 1 then
                    data.content = TI18N("您的宠物已进到最高阶，此阶段装备护符或符石将<color='#ffff00'>无法再卸下</color>（但可被其他符石覆盖），是否确定穿戴？")
                    data.sureLabel = TI18N("穿戴")
                elseif self.model.gem_type == 2 then
                    data.content = TI18N("您的宠物已进到最高阶，穿戴新护符或符石将<color='#ffff00'>覆盖原有护符</color>，是否确定穿戴？")
                    data.sureLabel = TI18N("覆盖")
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

function PetGemView:gen_click(slot,data)
    if self.curSelect ~= nil then
        self.curSelect:SetActive(false)
    end
    self.curSelect = slot.transform:Find("SelectImg").gameObject
    self.curSelect:SetActive(true)
    self.selectTips:SetActive(false)

    -- BaseUtils.dump(data,"数据")
    self.selectitemdata2 = BaseUtils.copytab(data)
    -- BaseUtils.dump(self.selectitemdata2,"222数据")

    self.wear:SetActive(true)
    self.wearButton:SetActive(true)
    if self.model.cur_petdata.lev < 30 then
        self.wearButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("30级可用")
    else
        self.wearButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("穿戴")
    end
    self.genType.text = ColorHelper.color_item_name(data.quality, data.name)
    self.genDesc.text = BaseUtils.split(data.desc, "，")[1]
    self.curSlot:SetAll(data)
    self:CalculateNum(data)
end

function PetGemView:CalculateNum(data)
    --BaseUtils.dump(data,"符石数据")
    self.numBg:SetActive(true)
    self.numTxt.gameObject:SetActive(true)

    self.curNum = 0
    self.sumNum = 0
    self.baseGenId = nil
    if data.quality == 1 then
        self.sumNum = 1
        self.curNum = BackpackManager.Instance:GetItemCount(data.base_id)
        self.baseGenId = data.base_id
    elseif data.quality == 2 then
        for i,v in pairs(DataFuse.data_list) do
            if (v.next_base_id == data.base_id) then
                self.sumNum = v.need_num
                self.curNum = self.curNum + BackpackManager.Instance:GetItemCount(v.next_base_id)*v.need_num
                self.curNum = self.curNum + BackpackManager.Instance:GetItemCount(v.base_id)
                self.baseGenId = v.base_id
            end
        end
    elseif data.quality == 3 then
        for i,v in pairs(DataFuse.data_list) do
            if (v.next_base_id == data.base_id) then
                self.sumNum = v.need_num
                self.curNum = self.curNum + BackpackManager.Instance:GetItemCount(v.next_base_id)*v.need_num
                self.curNum = self.curNum + BackpackManager.Instance:GetItemCount(v.base_id)
                local id = v.base_id
                for i,v in pairs(DataFuse.data_list) do
                    if (v.next_base_id == id) then
                        self.sumNum = self.sumNum*v.need_num
                        self.curNum = self.curNum*v.need_num
                        self.curNum = self.curNum + BackpackManager.Instance:GetItemCount(v.base_id)
                        self.baseGenId = v.base_id
                    end
                end
            end
        end
    end
    if BackpackManager.Instance:GetItemCount(data.base_id) == 0 then
        self.numTxt.text = string.format("<color='#df3435'>%s</color>/%s", 0,1)
    else
        self.numTxt.text = string.format("<color='#00ff00'>%s</color>/%s", BackpackManager.Instance:GetItemCount(data.base_id),1)
    end

    self.fuseTips:SetActive(false)
    if self.sumNum > self.curNum then
        if DataMarketGold.data_market_gold_item[self.baseGenId].init_price ~= nil then
            self.price.gameObject:SetActive(true)
            PetManager.Instance:Send12416({{base_id = self.baseGenId}})
        end
        self.canFuse = false
    else
        self.price.gameObject:SetActive(false)
        self.canFuse = true
        if BackpackManager.Instance:GetItemCount(data.base_id) == 0 then
            self.fuseTips:SetActive(true)
        end
    end

    local w = math.max(math.ceil(self.numTxt.preferredWidth) + 1, 18)
    self.numRect.sizeDelta = Vector2(w, 24)
    self.numBgRect.sizeDelta = Vector2(w + 2, 18)
    local xprefix = -4.37
    if w >= 56 then
        xprefix = 0
    end
    self.numBgRect.anchoredPosition = Vector2(xprefix, self.numBgRect.anchoredPosition.y)
    self.numTxt.transform.anchoredPosition = Vector2(xprefix, self.numBgRect.anchoredPosition.y + 0.5)
    self.numTxt.transform.sizeDelta = self.numBgRect.sizeDelta
end

function PetGemView:OnClickWear()
    BaseUtils.dump(self.selectitemdata2,"选择的数据")
    self:CalculateNum(self.selectitemdata2)
    if self.selectitemdata2 ~= nil then
        if 30 > self.model.cur_petdata.lev then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("宠物等级不足，需要<color='#00ff00'>%s级</color>才能装备"), 30))
        else
            if self.model.gem_type == 0 then
                if BackpackManager.Instance:GetItemCount(self.selectitemdata2.base_id) > 0 then
                    print(self.selectitemdata2.base_id.."-------------")
                    local id = BackpackManager.Instance:GetItemByBaseid(self.selectitemdata2.base_id)[1].id
                    PetManager.Instance:Send10507(self.model.cur_petdata.id, id, self.model.select_gem)
                    self:OnClickClose()
                else
                    if self.canFuse == true then
                        PetManager.Instance:Send10568(self.model.cur_petdata.id, self.selectitemdata2.base_id, self.model.select_gem)
                        self:OnClickClose()
                    else
                        print("-----------------打开快捷购买-----------")
                        self:ShowGemQuickBuy(self.baseGenId)
                    end
                end

            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.cancelLabel = TI18N("取消")
                if BackpackManager.Instance:GetItemCount(self.selectitemdata2.base_id) > 0 then
                    local id = BackpackManager.Instance:GetItemByBaseid(self.selectitemdata2.base_id)[1].id
                    data.sureCallback = function()
                        PetManager.Instance:Send10507(self.model.cur_petdata.id, id, self.model.select_gem)
                        self:OnClickClose()
                    end
                    if self.model.gem_type == 1 then
                        data.content = TI18N("您的宠物已进到最高阶，此阶段装备护符或符石将<color='#ffff00'>无法再卸下</color>（但可被其他符石覆盖），是否确定穿戴？")
                        data.sureLabel = TI18N("穿戴")
                    elseif self.model.gem_type == 2 then
                        data.content = TI18N("您的宠物已进到最高阶，穿戴新护符或符石将<color='#ffff00'>覆盖原有护符</color>，是否确定穿戴？")
                        data.sureLabel = TI18N("覆盖")
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                else
                    if self.canFuse == true then
                        data.sureCallback = function()
                            PetManager.Instance:Send10568(self.model.cur_petdata.id, self.selectitemdata2.base_id, self.model.select_gem)
                            self:OnClickClose()
                        end
                        if self.model.gem_type == 1 then
                            data.content = TI18N("您的宠物已进到最高阶，此阶段装备护符或符石将<color='#ffff00'>无法再卸下</color>（但可被其他符石覆盖），是否确定穿戴？")
                            data.sureLabel = TI18N("穿戴")
                        elseif self.model.gem_type == 2 then
                            data.content = TI18N("您的宠物已进到最高阶，穿戴新护符或符石将<color='#ffff00'>覆盖原有护符</color>，是否确定穿戴？")
                            data.sureLabel = TI18N("覆盖")
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        print("-----------------打开快捷购买-----------")
                        self:ShowGemQuickBuy(self.baseGenId)
                    end
                end
            end
        end
    end
end


function PetGemView:ShowGemQuickBuy(baseGenId)
    PetManager.Instance:Send12416({{base_id = baseGenId}})
    -- LuaTimer.Add(100, function()
    if PetManager.Instance.market_price[1] ~= nil then
        local baseidToPrice = {}
        baseidToPrice[baseGenId] = PetManager.Instance.market_price[1]
        local baseidToNeed = {}
        baseidToNeed[baseGenId] = {need = self.sumNum - self.curNum}
        if self.buyConfirm == nil then
            self.buyConfirm = BuyConfirm.New()
        end
        self.buyConfirm:Show({baseidToPrice = baseidToPrice, baseidToNeed = baseidToNeed})
    end
    -- end)
end


function PetGemView:ShowPrice()
    if self.price ~= nil then
        self.price.text = (self.sumNum - self.curNum)*PetManager.Instance.curGemPrice
    end
end
