-- ----------------------------------------------------------
-- UI - 宠物窗口 主窗口
-- ----------------------------------------------------------
PetSkillView = PetSkillView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetSkillView:__init(model)
    self.model = model
    self.name = "PetSkillView"
    self.windowId = WindowConfig.WinID.pet_learnskill
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.pet_skill_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.noitemtips = nil
    self.itemSlot = nil
    self.assetImage = nil
    self.assetText = nil
    self.itemList = {}
    self.itemSlotList = {}
    self.select_itemdata = nil
    self.select_item = nil
    self.skillSlotList = {}

    self.tabGroupObj = nil
    self.tabGroup = nil
    self.container = nil
    self.item = nil
    self.view_index = 0

    self.skillTips = {TI18N("1、宠物技能数不足<color='#ffff00'>4个</color>时，战斗和升级有几率领悟技能")
                , TI18N("2、打书可为宠物<color='#ffff00'>增加</color>技能，也有几率<color='#ffff00'>覆盖</color>当前已有技能")
                , TI18N("3、当前技能（符石技能除外）达到<color='#ffff00'>天生可拥有技能数量</color>时，打书不再增加技能数量")
                , TI18N("4、使用<color='#ffff00'>天赋异禀</color>可以随机习得一个<color='#ffff00'>天生技能</color>(已拥有的天生技能除外)，其中特殊技能概率较大")
                , TI18N("5、突破技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在")
                , TI18N("6、点击<color='#00ff00'>天赋技能</color>可对其进行<color='#ffff00'>锁定</color>，被锁定的技能在<color='#ffff00'>学习技能</color>时<color='#00ff00'>不会被覆盖</color>，拥有<color='#ffff00'>8个</color>以上（含）技能时，锁定将消耗<color='#ffff00'>2本技能认证书</color>，突破技能与护符技能不计算在内")
            }

    self.skillTips2 = {TI18N("1、学习技能时有几率<color='#ff0000'>覆盖</color>原技能")
                , TI18N("2、宠物可对<color='#ffff00'>专属天赋</color>技能进行锁定，锁定后在学习技能时<color='#ffff00'>不会被替换</color>")
                , TI18N("3、当有被锁定的技能时，每次学习技能需要消耗一本<color='#ffff00'>技能认证书</color>")
            }
    ------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._update_market = function(catalg_1, catalg_2) self:update_market(catalg_1, catalg_2) end
    self._sureUse = function() self:sureUse() end
    self._skill_update = function() self:skill_update() end

    self.guideOkBtn = nil

    self.lockSkillItemId = 21132
end

function PetSkillView:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end
    if self.itemSlot2 ~= nil then
        self.itemSlot2:DeleteMe()
        self.itemSlot2 = nil
    end
    for k,v in pairs(self.itemSlotList) do
        v:DeleteMe()
        v = nil
    end

    for i,v in ipairs(self.skillSlotList) do
        v:DeleteMe()
    end
    self.skillSlotList = nil

    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetSkillView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_skill_window))
    self.gameObject.name = "PetSkillView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.skillPanel = self.mainTransform:FindChild("SkillPanel")

    -- 单个物品
    self.singlePanel = self.skillPanel:FindChild("Single").gameObject

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.skillPanel:FindChild("Single/ItemIcon").gameObject, self.itemSlot.gameObject)

    self.assetImage = self.skillPanel:FindChild("Single/AssetsImage").gameObject
    self.assetText = self.skillPanel:FindChild("Single/NumText"):GetComponent(Text)
    self.nameText = self.skillPanel:FindChild("Single/NameText"):GetComponent(Text)
    self.addImage = self.skillPanel:FindChild("Single/AddImage").gameObject

    -- 两个个物品
    self.doublePanel = self.skillPanel:FindChild("Double").gameObject

    self.itemSlot1 = ItemSlot.New()
    UIUtils.AddUIChild(self.skillPanel:FindChild("Double/Item1/ItemIcon").gameObject, self.itemSlot1.gameObject)

    self.assetImage1 = self.skillPanel:FindChild("Double/Item1/AssetsImage").gameObject
    self.assetText1 = self.skillPanel:FindChild("Double/Item1/NumText"):GetComponent(Text)
    self.nameText1 = self.skillPanel:FindChild("Double/Item1/NameText"):GetComponent(Text)
    self.addImage1 = self.skillPanel:FindChild("Double/Item1/AddImage").gameObject

    self.itemSlot2 = ItemSlot.New()
    UIUtils.AddUIChild(self.skillPanel:FindChild("Double/Item2/ItemIcon").gameObject, self.itemSlot2.gameObject)

    self.assetImage2 = self.skillPanel:FindChild("Double/Item2/AssetsImage").gameObject
    self.assetText2 = self.skillPanel:FindChild("Double/Item2/NumText"):GetComponent(Text)
    self.nameText2 = self.skillPanel:FindChild("Double/Item2/NameText"):GetComponent(Text)
    self.addImage2 = self.skillPanel:FindChild("Double/Item2/AddImage").gameObject

    self.lock1 = self.skillPanel:FindChild("Lock1").gameObject
    self.lock2 = self.skillPanel:FindChild("Lock2").gameObject
    --------------------------------
    local btn = self.skillPanel:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onOkButtonClick() end)
    self.guideOkBtn = btn

    btn = self.skillPanel:FindChild("DescButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showtips() end)

    btn = self.skillPanel:FindChild("DescButton2"):GetComponent(Button)
    btn.onClick:AddListener(function() self:showtips2() end)

    btn = self.skillPanel:FindChild("RrecommendSkillButton").gameObject
    btn:GetComponent(Button).onClick:AddListener(function() self:openfeed_recommendskill() end)

    btn = self.transform:FindChild("Panel"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnClickClose() end)

    -- 初始化技能图标
    local soltPanel = self.skillPanel:FindChild("NowSkillPanel/ScrollView/ItemPanel").gameObject
    for i=1, 12 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(soltPanel, slot.gameObject)
        table.insert(self.skillSlotList, slot)
    end

    self.itemPanel = self.mainTransform:FindChild("ItemPanel")

    self.container = self.itemPanel.transform:FindChild("mask/Container")
    self.item = self.container:FindChild("Item").gameObject

    self.item:SetActive(false)
    self.item.transform:FindChild("Select").gameObject:SetActive(false)
    self.noitemtips = self.itemPanel:FindChild("NoItemTips").gameObject
    self.noitemtips:GetComponent(Button).onClick:AddListener(function() self:open_gold_market() end)

    self.tabGroupObj = self.itemPanel.transform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, { notAutoSelect = true })

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetSkillView:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:ClosePetSkillWindow()
end

function PetSkillView:OnShow()
    self.cur_petdata = self.model.cur_petdata

    MarketManager.Instance:send12400(3, 7)
    MarketManager.Instance:send12400(3, 8)
    MarketManager.Instance:send12400(3, 9)
    EventMgr.Instance:AddListener(event_name.market_gold_update, self._update_market)
    EventMgr.Instance:AddListener(event_name.pet_sure_useskillbook, self._sureUse)
    PetManager.Instance.OnPetUpdate:Add(self._skill_update)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.tabGroup:ChangeTab(self.openArgs[1])
    else
        local list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petskillbook)
        if #list > 0 then
            self.tabGroup:ChangeTab(1)
        else
            self.tabGroup:ChangeTab(4)
        end
    end

    self.select_itemdata = nil
    self:update_selectitem()
end

function PetSkillView:OnHide()
    EventMgr.Instance:RemoveListener(event_name.market_gold_update, self._update_market)
    EventMgr.Instance:RemoveListener(event_name.pet_sure_useskillbook, self._sureUse)
    PetManager.Instance.OnPetUpdate:Remove(self._skill_update)

    self.view_index = 0
end

function PetSkillView:ChangeTab(index)
    if self.view_index == index then return end
    self.view_index = index

    self.select_itemdata = nil
    -- self.container.localPosition = Vector3(-148, 180, 0)
    self:update()
end

function PetSkillView:skill_update()
    self:update()
end

function PetSkillView:update()
    self.cur_petdata = self.model:getpet_byid(self.cur_petdata.id)

    if MarketManager.Instance.model.goldItemList[3] == nil or
        MarketManager.Instance.model.goldItemList[3][7] == nil or MarketManager.Instance.model.goldItemList[3][8] == nil then
        return
    end

    local list = {}
    if self.view_index == 1 then
        list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petskillbook)
    elseif self.view_index == 2 then
        local goldItemList = MarketManager.Instance.model.goldItemList[3][7]
        for _, value in ipairs(goldItemList) do
            local itembase = BackpackManager.Instance:GetItemBase(value.base_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = BackpackManager.Instance:GetItemCount(value.base_id)
            table.insert(list, itemData)
        end
    elseif self.view_index == 3 then
        local goldItemList = MarketManager.Instance.model.goldItemList[3][8]
        for _, value in ipairs(goldItemList) do
            local itembase = BackpackManager.Instance:GetItemBase(value.base_id)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = BackpackManager.Instance:GetItemCount(value.base_id)
            table.insert(list, itemData)
        end
    elseif self.view_index == 4 then
        local recommend_skill_list = DataPet.data_pet_recommend_skill[self.cur_petdata.base_id]
        if recommend_skill_list ~= nil then
            for _, value in ipairs(recommend_skill_list.skill_list) do
                local skill_data = DataPet.data_recommend_skill[value]
                if skill_data ~= nil then
                    local item_id = skill_data.item_id
                    if item_id == 20171 and DataPet.data_pet_special_skill_low_lev[self.cur_petdata.base_id] then
                        item_id = 20182
                    end
                    local itembase = BackpackManager.Instance:GetItemBase(item_id)
                    local itemData = ItemData.New()
                    itemData:SetBase(itembase)
                    itemData.quantity = BackpackManager.Instance:GetItemCount(item_id)
                    table.insert(list, itemData)
                end
            end
        end
    end
    self:update_item(list)

    self:update_skill()
end

function PetSkillView:update_item(list)
    local list = list
    if #list > 0 then
        self.noitemtips:SetActive(false)
        local select_item = nil
        for i, data in ipairs(list) do
            local item = self.itemList[i]
            local slot = self.itemSlotList[i]
            if item == nil then
                local newItem = GameObject.Instantiate(self.item)
                newItem.transform:SetParent(self.container)
                newItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                self.itemList[i] = newItem
                item = newItem

                local newSlot = ItemSlot.New()
                UIUtils.AddUIChild(newItem.transform:FindChild("Solt"), newSlot.gameObject)
                self.itemSlotList[i] = newSlot
                slot = newSlot
            end

            self.itemList[i]:SetActive(true)

            item.name = data.base_id

            item.transform:FindChild("NameText"):GetComponent(Text).text = data.name
            slot:SetAll(data, { nobutton = true })

            local inbagback = false
            if self.view_index == 1 then
                item.transform:FindChild("Using").gameObject:SetActive(false)
            else
                local num = BackpackManager.Instance:GetItemCount(data.base_id)
                if num == 0 then
                    item.transform:FindChild("Using").gameObject:SetActive(false)
                else
                    item.transform:FindChild("Using").gameObject:SetActive(true)
                    item.transform:FindChild("Using/Text"):GetComponent(Text).text = TI18N("已拥有")
                    inbagback = true
                end
            end

            local haslearn = false
            for _,effect_client in ipairs(data.effect_client) do
                if effect_client.effect_type_client == 3 then
                    local skill_id = effect_client.val_client[1]
                    local mark = false
                    for __, pet_skill in ipairs(self.cur_petdata.skills) do
                        if pet_skill.id == skill_id then
                            mark = true
                            break
                        end
                    end
                    if mark then
                        item.transform:FindChild("Using").gameObject:SetActive(true)
                        item.transform:FindChild("Using/Text"):GetComponent(Text).text = TI18N("已学会")
                        haslearn = true
                    end
                end
            end

            item.transform:FindChild("DecommendText").gameObject:SetActive(self.view_index == 4)

            local button = item:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onselectitem(item, data, inbagback, haslearn) end)

            -- if select_item == nil then -- 默认选中一个
            --     select_item = { item, data, inbagback, haslearn }
            -- end
            if self.select_itemdata ~= nil and self.select_itemdata.base_id == data.base_id then
                select_item = { item, data, inbagback, haslearn }
            end
        end

        if select_item ~= nil then
            self:onselectitem(select_item[1], select_item[2], select_item[3], select_item[4])
        -- else
        --     self.select_itemdata = nil
        --     self:update_selectitem()
        end
    else
        if self.noitemtips ~= nil then
            self.noitemtips:SetActive(true)
        end
        -- self.select_itemdata = nil
        -- self:update_selectitem()
    end

    if #self.itemList > #list then
        for i = #list+1, #self.itemList do
            self.itemList[i]:SetActive(false)
        end
    end
end

function PetSkillView:update_market(catalg_1, catalg_2)
    self:update()
end

function PetSkillView:update_selectitem()
    if self.select_itemdata ~= nil then
        if self.model:HasLockSkill(self.cur_petdata) then
            self:update_selectitem_double()
        else
            self:update_selectitem_single()
        end
    else
        self.singlePanel:SetActive(true)
        self.doublePanel:SetActive(false)
        self.addImage:SetActive(true)
        self.itemSlot:SetAll(nil)
        self.nameText.text = TI18N("请选择技能书")
        self.assetImage:SetActive(false)
        self.assetText.text = ""
    end
end

function PetSkillView:update_selectitem_single()
    self.singlePanel:SetActive(true)
    self.doublePanel:SetActive(false)
    if self.select_itemdata.quantity > 0 then
        self.itemSlot:SetAll(self.select_itemdata, { nobutton = true })
        self.itemSlot:ShowNum(true)
        self.itemSlot:SetNum(self.select_itemdata.quantity, 1)
        self.nameText.text = string.format("%s", self.select_itemdata.name)
        self.assetImage:SetActive(false)
        self.assetText.text = ""
    else
        self.itemSlot:SetAll(self.select_itemdata, { nobutton = true })
        self.itemSlot:ShowNum(true)
        self.itemSlot:SetNum(self.select_itemdata.quantity, 1)
        self.nameText.text = self.select_itemdata.name

        local marketData = self:getItemFromGoldMarket(self.select_itemdata.base_id)
        if marketData ~= nil then
            self.assetImage:SetActive(true)
            if marketData.cur_price > RoleManager.Instance.RoleData.gold_bind then
                self.assetText.text = string.format("<color='#ff0000'>%s</color>", marketData.cur_price)
            else
                self.assetText.text = string.format("<color='#00ff00'>%s</color>", marketData.cur_price)
            end
        end
    end
end

function PetSkillView:update_selectitem_double()
    self.singlePanel:SetActive(false)
    self.doublePanel:SetActive(true)
    if self.select_itemdata.quantity > 0 then
        self.itemSlot1:SetAll(self.select_itemdata, { nobutton = true })
        self.itemSlot1:ShowNum(true)
        self.itemSlot1:SetNum(self.select_itemdata.quantity, 1)
        self.nameText1.text = string.format("%s", self.select_itemdata.name)
        self.assetImage1:SetActive(false)
        self.assetText1.text = ""
    else
        self.itemSlot1:SetAll(self.select_itemdata, { nobutton = true })
        self.itemSlot1:ShowNum(true)
        self.itemSlot1:SetNum(self.select_itemdata.quantity, 1)
        self.nameText1.text = self.select_itemdata.name

        local marketData = self:getItemFromGoldMarket(self.select_itemdata.base_id)
        if marketData ~= nil then
            self.assetImage1:SetActive(true)
            if marketData.cur_price > RoleManager.Instance.RoleData.gold_bind then
                self.assetText1.text = string.format("<color='#ff0000'>%s</color>", marketData.cur_price)
            else
                self.assetText1.text = string.format("<color='#00ff00'>%s</color>", marketData.cur_price)
            end
        end
    end

    local itembase = BackpackManager.Instance:GetItemBase(self.lockSkillItemId)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    local num = BackpackManager.Instance:GetItemCount(self.lockSkillItemId)
    itemData.quantity = num
    itemData.need = 1
    if self.model:GetNormalSkill(self.cur_petdata) >= 8 then
        itemData.need = 2
    end
    if num >= itemData.need then
        self.itemSlot2:SetAll(itemData, { nobutton = true })
        self.nameText2.text = string.format("%s", itemData.name)
        self.assetImage2:SetActive(false)
        self.assetText2.text = ""
    else
        self.itemSlot2:SetAll(itemData, { nobutton = true })
        self.nameText2.text = itemData.name

        local marketData = self:getItemFromGoldMarket(itemData.base_id)
        if marketData ~= nil then
            self.assetImage2:SetActive(true)
            if marketData.cur_price > RoleManager.Instance.RoleData.gold_bind then
                self.assetText2.text = string.format("<color='#ff0000'>%s</color>", marketData.cur_price * itemData.need)
            else
                self.assetText2.text = string.format("<color='#00ff00'>%s</color>", marketData.cur_price * itemData.need)
            end
        end
    end
end

function PetSkillView:update_skill()
    local petData = self.cur_petdata
    local skills = self.model:makeBreakSkill(petData.base.id, petData.skills)

    local lock_index = 1
    local special_skill = nil
    local data_pet_special_skill = DataPet.data_pet_special_skill[self.cur_petdata.base.id]
    if data_pet_special_skill ~= nil then
        special_skill = data_pet_special_skill.skills
    end
    -- data_pet_special_skill = DataPet.data_pet_special_skill_low_lev[self.cur_petdata.base.id]
    -- if data_pet_special_skill ~= nil then
    --     special_skill = data_pet_special_skill.skills
    -- end
    for i=1,#skills do
        local skilldata = skills[i]
        local icon = self.skillSlotList[i]
        icon.gameObject.name = skilldata.id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skilldata.id)]
        local extra = {}
        local skillLock = (skilldata.is_lock == 1)

        if special_skill ~= nil then
            local special_mark = false
            for _,data in ipairs(special_skill) do
                if data[1] == skilldata.id then
                    special_mark = true
                    break
                end
            end

            if special_mark then
                if skilldata.source ~= 2 then
                    if skillLock then
                        extra.white_list = { {id = 27, show = true} }
                    else
                        extra.white_list = { {id = 26, show = true} }
                        if lock_index == 1 then
                            self.lock1:SetActive(true)
                            self.lock1.transform:SetParent(icon.transform)
                            self.lock1.transform.localPosition = Vector2(15, -15)
                        end
                        if lock_index == 2 then
                            self.lock2:SetActive(true)
                            self.lock2.transform:SetParent(icon.transform)
                            self.lock2.transform.localPosition = Vector2(15, -15)
                        end
                        lock_index = lock_index + 1
                    end
                end
                extra.skillLock = not skillLock
            end
        end

        extra.petId = petData.id
        icon:SetAll(Skilltype.petskill, skill_data, extra)
        icon:ShowState(skilldata.source == 2)
        icon:ShowLabel(skilldata.source == 4 or skilldata.isBreak, TI18N("<color='#ffff00'>突破</color>"))
        icon:ShowBreak(skilldata.isBreak, TI18N("<color='#FF0000'>未激活</color>"))
        if skilldata.is_lock == 1 then
            icon:ShowLabel(true, TI18N("锁定"), "Tipslabel3")
        end
    end

    for i=#skills+1,#self.skillSlotList do
        local icon = self.skillSlotList[i]
        icon.gameObject.name = ""
        icon:Default()
        icon:ShowState(false)
        icon.skillData = nil
    end

    if lock_index < 2 then
        self.lock1:SetActive(false)
    end

    if lock_index < 3 then
        self.lock2:SetActive(false)
    end
end

function PetSkillView:onselectitem(item, itemData, inbagback, haslearn)
    self.select_itemdata = itemData

    if self.select_item ~= nil then
        self.select_item.transform:FindChild("Select").gameObject:SetActive(false)
        self.select_item = nil
    end

    self.select_item = item
    self.select_item.transform:FindChild("Select").gameObject:SetActive(true)

    self.addImage:SetActive(false)

    self:update_selectitem()
end

function PetSkillView:showtips()
    TipsManager.Instance:ShowText({gameObject = self.skillPanel:FindChild("DescButton").gameObject
            , itemData = self.skillTips})
end

function PetSkillView:showtips2()
    TipsManager.Instance:ShowText({gameObject = self.skillPanel:FindChild("DescButton2").gameObject
            , itemData = self.skillTips2 })
end

function PetSkillView:onOkButtonClick()
    if self.select_itemdata == nil then
        return
    end

    self:useskillbook()
end

function PetSkillView:useskillbook()
    if self.select_itemdata ~= nil then
        -- if self:isskilllearned() then
        --     NoticeManager.Instance:FloatTipsByString("你已学会该技能")
        -- else
            -- PetManager.Instance:Send10508(self.cur_petdata.id, self.select_itemdata.id)
        --     self:OnClickClose()
        -- end
        local hasLockSkill = self.model:HasLockSkill(self.cur_petdata)
        if self.model.sure_useskillbook then
            self:sureUse()
        else
            local skill_data = nil
            local skill_text = ""

            if self.select_itemdata.base_id == 20182 then -- 如果是天赋领悟
                local pet_special_skill = DataPet.data_pet_special_skill_low_lev[self.cur_petdata.base_id]
                if pet_special_skill ~= nil then
                    local skill_list = {}
                    for _, value in ipairs(pet_special_skill.skills) do
                        table.insert(skill_list, DataSkill.data_petSkill[string.format("%s_1", value[1])])
                    end


                    if #skill_list > 0 then
                        local skill_name_text = ""
                        for i=1,#skill_list do
                            if i == 1 then
                                skill_name_text = string.format("%s[%s]", skill_name_text, skill_list[i].name)
                            else
                                skill_name_text = string.format("%s、[%s]", skill_name_text, skill_list[i].name)
                            end
                        end
                        skill_text = string.format(TI18N("确定让<color='#00ff00'>%s</color>学习<color='#ffff00'>%s</color>吗？\n天赋领悟：有较大几率使携带等级≤65级的宠物习得专属技能<color='#ffff00'>%s</color>\n<color='#00ff00'>小提示：有一定几率顶掉一个原有技能</color>")
                            , self.cur_petdata.name, self.select_itemdata.name, skill_name_text)
                    end
                end
            end

            if self.select_itemdata.base_id == 20171 then -- 如果是天赋异秉
                local pet_special_skill = DataPet.data_pet_special_skill[self.cur_petdata.base_id]
                if pet_special_skill ~= nil then
                    local skill_list = {}
                    for _, value in ipairs(pet_special_skill.skills) do
                        table.insert(skill_list, DataSkill.data_petSkill[string.format("%s_1", value[1])])
                    end


                    if #skill_list > 0 then
                        local skill_name_text = ""
                        for i=1,#skill_list do
                            if i == 1 then
                                skill_name_text = string.format("%s[%s]", skill_name_text, skill_list[i].name)
                            else
                                skill_name_text = string.format("%s、[%s]", skill_name_text, skill_list[i].name)
                            end
                        end
                        skill_text = string.format(TI18N("确定让<color='#00ff00'>%s</color>学习<color='#ffff00'>%s</color>吗？\n天赋异禀：有较大几率习得该宠物的专属技能<color='#ffff00'>%s</color>\n<color='#00ff00'>小提示：有一定几率顶掉一个原有技能</color>")
                            , self.cur_petdata.name, self.select_itemdata.name, skill_name_text)
                    end
                end
            end

            -- 如果不是天赋异秉，或者是天赋异秉但宠物没有天赋技能
            if skill_text == "" then
                for _,effect_client in ipairs(self.select_itemdata.effect_client) do
                    if effect_client.effect_type_client == 3 then
                        local skill_id = effect_client.val_client[1]
                        skill_data = DataSkill.data_petSkill[string.format("%s_1", skill_id)]

                        skill_text = string.format(TI18N("确定让<color='#00ff00'>%s</color>学习<color='#ffff00'>%s</color>吗？\n%s：%s\n<color='#00ff00'>小提示：有一定几率顶掉一个原有技能</color>")
                            , self.cur_petdata.name, skill_data.name, skill_data.name, skill_data.desc)
                    end
                end
            end

            if skill_text ~= "" then
                local button_text = TI18N("确定学习")
                if self.select_itemdata.quantity == 0 or (hasLockSkill and BackpackManager.Instance:GetItemCount(self.lockSkillItemId) == 0) then
                    local totalPrice = 0
                    if self.select_itemdata.quantity == 0 then
                        local marketData = self:getItemFromGoldMarket(self.select_itemdata.base_id)
                        if marketData ~= nil then
                            if marketData.margin >= 1100 then
                                totalPrice = totalPrice + BaseUtils.Round(marketData.cur_price * 1.3)
                            else
                                totalPrice = totalPrice + marketData.cur_price
                            end
                        end
                    end
                    local needNum = 1
                    if self.model:GetNormalSkill(self.cur_petdata) >= 8 then
                        needNum = 2
                    end
                    if hasLockSkill and BackpackManager.Instance:GetItemCount(self.lockSkillItemId) < needNum then
                        local data = self:getItemFromGoldMarket(self.lockSkillItemId)
                        if data ~= nil then
                            totalPrice = totalPrice + data.cur_price * needNum
                        end
                    end
                    if totalPrice > RoleManager.Instance.RoleData.gold_bind then
                        local market_gold_ratio = DataMarketGold.data_market_gold_ratio[RoleManager.Instance.world_lev]
                        if market_gold_ratio ~= nil then
                            local num_gold = math.ceil(totalPrice / market_gold_ratio.rate)
                            if RoleManager.Instance.RoleData.star_gold == 0 then
                                if num_gold > RoleManager.Instance.RoleData.gold then
                                    button_text = string.format(TI18N("<color='#ff0000'>%s</color>{assets_2,90002}学习"), math.ceil(totalPrice / market_gold_ratio.rate))
                                else
                                    button_text = string.format(TI18N("<color='#00ff00'>%s</color>{assets_2,90002}学习"), math.ceil(totalPrice / market_gold_ratio.rate))
                                end
                            elseif num_gold > RoleManager.Instance.RoleData.star_gold then
                                if num_gold > RoleManager.Instance.RoleData.star_gold + RoleManager.Instance.RoleData.gold then
                                    button_text = string.format(TI18N("<color='#ff0000'>%s</color>{assets_2,29255}学习"), math.ceil(totalPrice / market_gold_ratio.rate))
                                else
                                    button_text = string.format(TI18N("<color='#00ff00'>%s</color>{assets_2,29255}学习"), math.ceil(totalPrice / market_gold_ratio.rate))
                                end
                            else
                                button_text = string.format(TI18N("<color='#00ff00'>%s</color>{assets_2,90026}学习"), math.ceil(totalPrice / market_gold_ratio.rate))
                            end
                        end
                    else
                        button_text = string.format(TI18N("<color='#00ff00'>%s</color>{assets_2,90003}学习"), totalPrice)
                    end
                end
                if hasLockSkill then
                    skill_text = string.format(TI18N("%s\n<color='#00ff00'>当前宠物已进行技能认证，学习技能时消耗一个宠物认证书</color>"), skill_text)
                end
                local unitData = {baseid = 20084}
                local base = BaseUtils.copytab(DataUnit.data_unit[20084])
                base.buttons = {
                        {button_id = 70, button_args = {1}, button_desc = button_text, button_show = ""}
                        ,{button_id = 70, button_args = {2}, button_desc = TI18N("取消操作"), button_show = ""}
                        ,{button_id = 70, button_args = {3}, button_desc = TI18N("不再提醒"), button_show = ""}
                    }
                base.plot_talk = skill_text
                local extra = {base = base}
                MainUIManager.Instance:OpenDialog(unitData, extra)
            end
        end
    end
end

function PetSkillView:sureUse()
    if self.select_itemdata ~= nil then
        if self.view_index == 1 then
            PetManager.Instance:Send10508(self.cur_petdata.id, self.select_itemdata.id)
        else
            PetManager.Instance:Send10546(self.cur_petdata.id, self.select_itemdata.base_id)
        end
    end
end

function PetSkillView:isskilllearned()
    local effect_clientss = self.select_itemdata.effect_client
    for i,effect_client in ipairs(effect_clientss) do
        if effect_client.effect_type_client == 3 then
            local skilldata = DataSkill.data_petSkill[string.format("%s_1", effect_client.val_client[1])]
            for k,v in pairs(self.cur_petdata.skills) do
                if v.id == skilldata.id then
                    return true
                end
            end
        end
    end
    return false
end

function PetSkillView:open_gold_market()
    -- windows.open_window(windows.panel.market, {panel_id = ui_market.windows.gold_market, gold_market_tab = 3})
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 3})
    -- self:OnClickClose()
end

function PetSkillView:CheckGuide()
    if RoleManager.Instance.RoleData.lev >= 15 and PetManager.Instance.model:getpetid_bybaseid(10003) ~= nil then
        if QuestManager.Instance.questTab[41560] ~= nil then
            -- 宠物打书
            local list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.petskillbook)
            local questData = QuestManager.Instance.questTab[41560]
            if #list > 0 and questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
                if self.guideScript == nil then
                    self.guideScript = GuidePetBookSec.New(self)
                    self.guideScript:Show()
                end
            end
        end
    end
end

function PetSkillView:openfeed_recommendskill()
    if self.cur_petdata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有宠物，快去获得一只宠物吧！"))
    else
        self.model:OpenRecommendSkillWindow()
    end
end

function PetSkillView:getItemFromGoldMarket(id)
    if MarketManager.Instance.model.goldItemList == nil or MarketManager.Instance.model.goldItemList[3] == nil then return end
    local list = MarketManager.Instance.model.goldItemList[3][7]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end
    list = MarketManager.Instance.model.goldItemList[3][8]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end
    list = MarketManager.Instance.model.goldItemList[3][9]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end

    return nil
end
