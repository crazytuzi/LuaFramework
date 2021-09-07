SkillLifeProduceWindow  =  SkillLifeProduceWindow or BaseClass(BasePanel)

function SkillLifeProduceWindow:__init(model)
    self.name  =  "SkillLifeProduceWindow"
    self.model  =  model
    self.resList  =  {
        {file  =  AssetConfig.skill_life_produce, type  =  AssetType.Main}
    }


    self.windowId = WindowConfig.WinID.skill_life_produce
    self.current_data = self.model.life_produce_data
    self.slot_items = nil
    self.slot_list = nil
    self.selected_index = 1

    self.role_asset_change = function ()
        self:update_produce_cost()
        -- local need = self.current_data.producing_cost[1][2]
        -- local has = RoleManager.Instance.RoleData.energy

        -- if has < need then
        --     self.TxtVal.text = string.format("<color='#E7582B'>%s</color>", need)
        -- else
        --     self.TxtVal.text = string.format("<color='#8DE92A'>%s</color>", need)
        -- end
        -- self.TxtVal2.text = tostring(has)
    end

    return self
end


function SkillLifeProduceWindow:__delete()
    if self.mid_slot ~= nil then
        self.mid_slot:DeleteMe()
    end
    if self.slot_list ~= nil then
        for k, v in pairs(self.slot_list) do
            v:DeleteMe()
        end
    end

    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.role_asset_change)
    self.is_open = false
    self.current_data = nil
    self.is_open = false
    self.slot_items = nil
    self.slot_list = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function SkillLifeProduceWindow:InitPanel()
     if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_life_produce))
    self.gameObject:SetActive(false)
    self.gameObject.name = "SkillLifeProduceWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseSkillLifeProduceWindow() end)

    self.Main = self.transform:FindChild("Main").gameObject
    self.TxtTtile = self.Main.transform:FindChild("Title"):FindChild("Text"):GetComponent(Text)

    self.ConMid =  self.Main.transform:FindChild("ConMid").gameObject
    self.ImgSec = self.ConMid.transform:FindChild("ImgSec"):GetComponent(Image)
    self.TopTxtDesc = self.ImgSec.transform:FindChild("Text"):GetComponent(Text)
    self.ConItems = self.ConMid.transform:FindChild("ConItems")
    self.ScorllCon = self.ConItems.transform:FindChild("ScorllCon")
    self.Container = self.ScorllCon.transform:FindChild("Container")
    self.Item = self.Container.transform:FindChild("Item").gameObject
    self.Item:SetActive(false)

    self.MidItems = self.ConMid.transform:FindChild("MidItems").gameObject
    self.leftArrowBtn = self.MidItems.transform:FindChild("ImgArrowLeft"):GetComponent(Button)
    self.rightArrowBtn = self.MidItems.transform:FindChild("ImgArrowRight"):GetComponent(Button)
    self.MidItem = self.MidItems.transform:FindChild("Item").gameObject
    self.leftArrowBtn.onClick:AddListener(function() self:on_left_right_page(1)  end)
    self.rightArrowBtn.onClick:AddListener(function() self:on_left_right_page(2) end)
    self.MidItem_TxtName = self.MidItems.transform:FindChild("TxtName"):GetComponent(Text)
    self.ProBg = self.ConMid.transform:FindChild("ProBg").gameObject
    self.ImgProBar = self.ProBg.transform:FindChild("ImgProBar").gameObject
    self.ImgProBar:SetActive(false)
    self.TxtProBar = self.ConMid.transform:FindChild("TxtProBar"):GetComponent(Text)
    self.ImgProBar_rectTrans = self.ImgProBar.gameObject.transform:GetComponent(RectTransform)
    self.ImgProBar_rectTrans.sizeDelta = Vector2(0, self.ImgProBar_rectTrans.rect.height)
    self.ProBg:SetActive(false)
    self.TxtProBar.gameObject:SetActive(false)

    self.Item1 =  self.ConMid.transform:FindChild("Item1").gameObject
    self.ImgTxtVal = self.Item1.transform:FindChild("ImgTxtVal").gameObject
    self.TxtVal = self.ImgTxtVal.transform:FindChild("TxtVal"):GetComponent(Text)
    self.Item2 = self.ConMid.transform:FindChild("Item2").gameObject
    self.ImgTxtVal2 = self.Item2.transform:FindChild("ImgTxtVal").gameObject
    self.TxtVal2 = self.ImgTxtVal2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.ImgTanHao = self.Item2.transform:FindChild("ImgTanHao"):GetComponent(Button)

    self.BtnProduce = self.Main.transform:FindChild("BtnProduce"):GetComponent(Button)
    self.BtnProduce_txt = self.BtnProduce.transform:FindChild("Text"):GetComponent(Text)
    self.CloseButton = self.Main.transform:FindChild("CloseButton"):GetComponent(Button)

    self.CloseButton.onClick:AddListener(function() self.model:CloseSkillLifeProduceWindow() end)
    self.BtnProduce.onClick:AddListener(function() self:on_click_produce() end)
    self.ImgTanHao.onClick:AddListener(function() self:on_click_tanhao() end)
    self.is_open = true
    self:update_view()

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.role_asset_change)
end

function SkillLifeProduceWindow:on_click_tanhao()
    -- windows.open_window(windows.panel.skill_life_activity)
    local tipsText = {TI18N("<color='#00ff00'>活力</color>可通过完成日程活动获得")}
    TipsManager.Instance:ShowText({gameObject = self.ImgTanHao.gameObject, itemData = tipsText})
end

--更新消耗显示
function SkillLifeProduceWindow:update_produce_cost()
    local need = self.current_data.producing_cost[self.selected_index][2]
    local has = RoleManager.Instance.RoleData.energy

    if has < need then
        self.TxtVal.text = string.format("<color='#E7582B'>%s</color>", need)
    else
        self.TxtVal.text = string.format("<color='#8DE92A'>%s</color>", need)
    end
    self.TxtVal2.text = tostring(has)
end

function SkillLifeProduceWindow:update_view()
    if self.current_data == nil then
        return
    end
    self.TxtTtile.text = string.format("%s Lv.%s", self.current_data.name, self.current_data.lev)
    -- local need = self.current_data.producing_cost[1][2]
    -- local has = RoleManager.Instance.RoleData.energy

    -- if has < need then
    --     self.TxtVal.text = string.format("<color='#E7582B'>%s</color>", need)
    -- else
    --     self.TxtVal.text = string.format("<color='#8DE92A'>%s</color>", need)
    -- end
    -- self.TxtVal2.text = tostring(has)

    local work_str = ""
    if self.current_data.id == 10000 then
        self.BtnProduce_txt.text = TI18N("栽 培")
        work_str = string.format("%s%s%s", TI18N("当前可以"), TI18N("栽培"), TI18N("以下物品"))
    elseif self.current_data.id == 10007 then
        self.BtnProduce_txt.text = TI18N("制 作")
        work_str = string.format("%s%s%s", TI18N("当前可以"), TI18N("制作"), TI18N("以下物品"))
    elseif self.current_data.id == 10001 then
        self.BtnProduce_txt.text = TI18N("研 制")
        work_str = string.format("%s%s%s", TI18N("当前可以"), TI18N("研制"), TI18N("以下物品"))
    elseif self.current_data.id == 10005 then
        self.BtnProduce_txt.text = TI18N("打 造")
        work_str = string.format("%s%s%s", TI18N("当前可以"), TI18N("打造"), TI18N("以下物品"))
    elseif self.current_data.id == 10006 then
        self.BtnProduce_txt.text = TI18N("裁 缝")
        work_str = string.format("%s%s%s", TI18N("当前可以"), TI18N("裁缝"), TI18N("以下物品"))
    end

    self.TopTxtDesc.text = work_str


    if self.slot_items ~= nil then
        for i=1,#self.slot_items do
            local it = self.slot_items[i]
            it:SetActive(false)
        end
    else
        self.slot_items = {}
    end

    self.product = nil
    if self.current_data.id == 10007 then
        self.product = {}
        for i=1,#self.current_data.product do
            local temp_data = self.current_data.product[i]
            if temp_data.classes == RoleManager.Instance.RoleData.classes then
                table.insert(self.product, temp_data)
            end
        end
    else
        self.product = self.current_data.product
    end

    self.ConItems.gameObject:SetActive(false)
    self.MidItems:SetActive(false)
    if self.current_data.id == 10007 or self.current_data.id == 10005 or self.current_data.id == 10006  then
        --有左右翻页
        self.MidItems:SetActive(true)
        if #self.product == 1 then
            self.leftArrowBtn.gameObject:SetActive(false)
            self.rightArrowBtn.gameObject:SetActive(false)
        else
            self.leftArrowBtn.gameObject:SetActive(true)
        end
        if self.mid_slot == nil then
            self.mid_slot = ItemSlot.New()
            self.mid_slot.gameObject.transform:SetParent(self.MidItem.transform)
            self.mid_slot.gameObject.transform.localScale = Vector3.one
            self.mid_slot.gameObject.transform.localPosition = Vector3.zero
            self.mid_slot.gameObject.transform.localRotation = Quaternion.identity
            self.mid_slot.gameObject.transform:SetAsFirstSibling()
            local rect = self.mid_slot.gameObject:GetComponent(RectTransform)
            rect.anchorMax = Vector2(1, 1)
            rect.anchorMin = Vector2(0, 0)
            rect.localPosition = Vector3(0, 0, 1)
            rect.offsetMin = Vector2(0, 0)
            rect.offsetMax = Vector2(0, 2)
            rect.localScale = Vector3.one
        end

        local cell = ItemData.New()
        self.selected_index = #self.product
        local data = self.product[self.selected_index] --默认定位到第一个，
        local itemData = DataItem.data_get[data.key] --设置数据
        cell:SetBase(itemData)
        self.mid_slot:SetAll(cell, nil)

        --self.MidItem_TxtName.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        self.MidItem_TxtName.text = itemData.name
        self.MidItem_TxtName.color = Color(35/255, 89/255, 152/255, 1)

    else
        self.ConItems.gameObject:SetActive(true)
        self.slot_list = {}

        local lineNum = math.floor(#self.product/5)
        local nextNum = #self.product%5
        lineNum = nextNum > 0 and (lineNum+1) or lineNum
        local newH = 84*lineNum
        local rect = self.Container:GetComponent(RectTransform)
        rect.sizeDelta = Vector2(347, newH)
        for i=1,#self.product do
            local data = self.product[i]
            local slot = self.slot_list[i]
            local slot_con = self.slot_items[i]
            if slot_con == nil then
                slot_con = GameObject.Instantiate(self.Item)
                UIUtils.AddUIChild(self.Item.transform.parent.gameObject, slot_con)
                self.slot_items[i] = slot_con
            end
            slot_con:SetActive(true)

            if slot == nil then
                slot = ItemSlot.New()
                slot.gameObject.transform:SetParent(slot_con.transform)
                slot.gameObject.transform.localScale = Vector3.one
                slot.gameObject.transform.localPosition = Vector3.zero
                slot.gameObject.transform.localRotation = Quaternion.identity
                slot.gameObject.transform:SetAsFirstSibling()
                local rect = slot.gameObject:GetComponent(RectTransform)
                rect.anchorMax = Vector2(1, 1)
                rect.anchorMin = Vector2(0, 0)
                rect.localPosition = Vector3(0, 0, 1)
                rect.offsetMin = Vector2(0, 0)
                rect.offsetMax = Vector2(0, 2)
                rect.localScale = Vector3.one
                self.slot_list[i] = slot
            end

            local cell = ItemData.New()
            local itemData = DataItem.data_get[data.key] --设置数据
            cell:SetBase(itemData)
            slot:SetAll(cell, nil)
        end
    end
    self:update_produce_cost()
end

--左右翻页
function SkillLifeProduceWindow:on_left_right_page(_type)
    local data = nil
    if _type == 1 then
        --点左
        if self.selected_index > 1 then
            self.selected_index = self.selected_index - 1
        end

        if self.selected_index < #self.product and self.selected_index > 1 then
            self.leftArrowBtn.gameObject:SetActive(true)
            self.rightArrowBtn.gameObject:SetActive(true)
        elseif self.selected_index == #self.product then
            self.leftArrowBtn.gameObject:SetActive(true)
            self.rightArrowBtn.gameObject:SetActive(false)
        elseif self.selected_index == 1 then
            self.leftArrowBtn.gameObject:SetActive(false)
            self.rightArrowBtn.gameObject:SetActive(true)
        end

        local cell = ItemData.New()
        data = self.product[self.selected_index]
        local itemData = DataItem.data_get[data.key] --设置数据
        cell:SetBase(itemData)
        self.mid_slot:SetAll(cell, nil)
        --self.MidItem_TxtName.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        self.MidItem_TxtName.text = itemData.name
        self.MidItem_TxtName.color = Color(35/255, 89/255, 152/255, 1)
    elseif _type == 2 then
        --点右
        if self.selected_index < #self.product then
            self.selected_index = self.selected_index + 1
        end

        if self.selected_index < #self.product and self.selected_index > 1 then
            self.leftArrowBtn.gameObject:SetActive(true)
            self.rightArrowBtn.gameObject:SetActive(true)
        elseif self.selected_index == #self.product then
            self.leftArrowBtn.gameObject:SetActive(true)
            self.rightArrowBtn.gameObject:SetActive(false)
        elseif self.selected_index == 1 then
            self.leftArrowBtn.gameObject:SetActive(false)
            self.rightArrowBtn.gameObject:SetActive(true)
        end

        local cell = ItemData.New()
        data = self.product[self.selected_index]
        local itemData = DataItem.data_get[data.key] --设置数据
        cell:SetBase(itemData)
        self.mid_slot:SetAll(cell, nil)
        --self.MidItem_TxtName.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        self.MidItem_TxtName.text = itemData.name
        self.MidItem_TxtName.color = Color(35/255, 89/255, 152/255, 1)
    end

    self:update_produce_cost()
end

function SkillLifeProduceWindow:on_click_produce(g)
    local need = self.current_data.producing_cost[self.selected_index][2]
    local has = RoleManager.Instance.RoleData.energy
    if need <= has then

        if self.current_data.id == 10005 or self.current_data.id == 10006  then
            local data = self.product[self.selected_index]
            SkillManager.Instance:Send10816(self.current_data.id, data.key)
        else
            SkillManager.Instance:Send10810(self.current_data.id)
        end
    else
        print("活力值不足, 无法操作")
        NoticeManager.Instance:FloatTipsByString(TI18N("活力值不足, 无法操作"))
    end
end

function SkillLifeProduceWindow:socket_back_update()
    self.ProBg:SetActive(false)
    self.TxtProBar.gameObject:SetActive(false)
    self.BtnProduce.enabled = true
    local has = RoleManager.Instance.RoleData.energy
    self.TxtVal2.text = tostring(has)
    if self.current_data.id == 10000 then
        self.BtnProduce_txt.text = TI18N("栽 培")
    elseif self.current_data.id == 10007 then
        self.BtnProduce_txt.text = TI18N("制 作")
    elseif self.current_data.id == 10001 then
        self.BtnProduce_txt.text = TI18N("研 制")
    elseif self.current_data.id == 10005 then
        self.BtnProduce_txt.text = TI18N("打 造")
    elseif self.current_data.id == 10006 then
        self.BtnProduce_txt.text = TI18N("裁 缝")
    end
end

