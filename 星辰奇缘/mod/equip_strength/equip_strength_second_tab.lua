EquipStrengthSecondTab = EquipStrengthSecondTab or BaseClass(BasePanel)

function EquipStrengthSecondTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_tab2, type = AssetType.Main}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
        ,{file = AssetConfig.equip_strength_res, type = AssetType.Dep}
        ,{file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20047), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20177), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()} --没升级的 情况，提升播20177
        ,{file = string.format(AssetConfig.effect, 20178), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()} --升的话，播20178
    }
    self.item_list = nil
    self.cur_selected_kong_id = nil
    self.green_con_X = {64, 55, 48.7, 42, 35, 28, 22, 14.5, 6.5, 0}
    self.last_left_stone_state = false
    self.last_right_stone_state = false
    self.last_hero_stone_state = false
    self.restoreFrozen_stone = nil

    self.firstKongId = 110
    self.secondKongId = 111
    self.thirdKongId = 112
    self.curHeroLev = nil
    self.isHide = false
    self.onHide = function()
        self.isHide = true
        self:OnResetHeroStone()
    end
    self.onShow = function()
        self.isHide = false
        self:update_left_list()

    end
    self.OnOpenEvent:AddListener(self.onShow)
    self.OnHideEvent:AddListener(self.onHide)
    self.has_init = false

    self.guideOver = function() self:OnGuideOver() end

    return self
end

function EquipStrengthSecondTab:OnResetHeroStone()
    self.last_data_base_id = nil
end

function EquipStrengthSecondTab:__delete()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end

    if self.Bottom3Slot ~= nil then
        self.Bottom3Slot:DeleteMe()
        self.Bottom3Slot = nil
    end

    self.curHeroLev = nil
    self:OnResetHeroStone()
    self.top_stone1.mySlot:DeleteMe()
    self.top_stone2.mySlot:DeleteMe()
    self.bottom_stone1.mySlot:DeleteMe()
    self.bottom_stone2.mySlot:DeleteMe()
    self.bottom_stone3.mySlot:DeleteMe()
    self.bottom2_stone1.mySlot:DeleteMe()
    self.bottom2_stone2.mySlot:DeleteMe()

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
            v:DeleteMe()
        end
        self.item_list = nil
    end

    self.bigbg1.sprite = nil
    self.bigbg2.sprite = nil
    self.bigbg3.sprite = nil

    self.has_init = false
    if self.restoreFrozen_stone ~= nil then
        self.restoreFrozen_stone:DeleteMe()
    end

    if self.progConBarRectTween1 ~= nil then
        Tween.Instance:Cancel(self.progConBarRectTween1)
        self.progConBarRectTween1 = nil 
    end
    if self.progConBarRectTween2 ~= nil then
        Tween.Instance:Cancel(self.progConBarRectTween2)
        self.progConBarRectTween2 = nil 
    end
    
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.item_list = nil
    self.has_init = false
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    self:AssetClearAll()
end

function EquipStrengthSecondTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_tab2))
    self.gameObject.name = "EquipStrengthSecondTab"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.EquipList = self.transform:FindChild("EquipList")
    self.ItemMaskCon = self.EquipList:FindChild("ItemMaskCon")
    self.ScrollLayer = self.ItemMaskCon:FindChild("ScrollLayer")
    self.ItemCon = self.ScrollLayer:FindChild("ItemCon")
    self.EquipItem = self.ItemCon:FindChild("EquipItem").gameObject

    self.EquipStone = self.transform:FindChild("EquipStone")
    self.TopCon = self.EquipStone:FindChild("TopCon")
    self.Stone1 = self.TopCon:FindChild("Stone1")
    self.Stone2 = self.TopCon:FindChild("Stone2")
    self.Stone3 = self.TopCon:FindChild("Stone3")
    self.Stone3LockIcon = self.TopCon:FindChild("Stone3"):FindChild("ImgHeroLock").gameObject
    self.TopCon:FindChild("Stone3"):FindChild("ImgHeroLock"):GetComponent(Button).onClick:AddListener(function()
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>英雄宝石</color>在装备达到<color='#ffff00'>70级</color>后开放"))
    end)
    self.TopCon:FindChild("Stone3"):FindChild("ImgHeroLockBg"):GetComponent(Button).onClick:AddListener(function()
        if self.cur_selected_item.data.lev < 70 then
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>英雄宝石</color>在装备达到<color='#ffff00'>70级</color>后开放"))
        else
            for i=1,#self.cur_selected_item.data.attr do
                local ed = self.cur_selected_item.data.attr[i]
                if ed.type == GlobalEumn.ItemAttrType.gem then
                    if ed.name == self.thirdKongId then
                        self:OnSelectedKong(self.thirdKongId, 1, ed.val)
                        return
                    end
                end
            end
            self:OnSelectedKong(self.thirdKongId, 0)
        end
    end)
    self.top_stone1 = self:read_stone_con(self.Stone1, 1)
    self.top_stone2 = self:read_stone_con(self.Stone2, 1)
    self.top_stone3 = self:read_stone_con(self.Stone3, 5)

    -- 大图 hosr
    self.bigbg1 = self.Stone1:GetComponent(Image)
    self.bigbg1.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    self.bigbg2 = self.Stone2:GetComponent(Image)
    self.bigbg2.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    self.bigbg3 = self.Stone3:GetComponent(Image)
    self.bigbg3.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.effect_left = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20047)))
    self.effect_left.transform:SetParent(self.Stone1)
    self.effect_left.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_left.transform, "UI")
    self.effect_left.transform.localScale = Vector3(1, 1, 1)
    self.effect_left.transform.localPosition = Vector3(0, 0, -400)
    self.effect_left:SetActive(false)

    self.effect_right = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20047)))
    self.effect_right.transform:SetParent(self.Stone2)
    self.effect_right.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_right.transform, "UI")
    self.effect_right.transform.localScale = Vector3(1, 1, 1)
    self.effect_right.transform.localPosition = Vector3(0, 0, -400)
    self.effect_right:SetActive(false)

    self.hero_effect_upgrade = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20177)))
    self.hero_effect_upgrade.transform:SetParent(self.Stone3)
    self.hero_effect_upgrade.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.hero_effect_upgrade.transform, "UI")
    self.hero_effect_upgrade.transform.localScale = Vector3(1, 1, 1)
    self.hero_effect_upgrade.transform.localPosition = Vector3(0, 0, -400)
    self.hero_effect_upgrade:SetActive(false)

    self.hero_effect_uplev = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20178)))
    self.hero_effect_uplev.transform:SetParent(self.Stone3)
    self.hero_effect_uplev.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.hero_effect_uplev.transform, "UI")
    self.hero_effect_uplev.transform.localScale = Vector3(1, 1, 1)
    self.hero_effect_uplev.transform.localPosition = Vector3(0, 0, -400)
    self.hero_effect_uplev:SetActive(false)

    --底部状态1
    self.Bottom1 = self.EquipStone:FindChild("Bottom1")
    self.Bottom1TiitleTxt = self.Bottom1:FindChild("Tiitle"):FindChild("Text"):GetComponent(Text)
    self.B_Stone1 = self.Bottom1:FindChild("Stone1")
    self.B_Stone3 = self.Bottom1:FindChild("Stone3")
    self.B_Stone2 = self.Bottom1:FindChild("Stone2")
    self.bottom_stone1 = self:read_stone_con(self.B_Stone1, 2)
    self.bottom_stone2 = self:read_stone_con(self.B_Stone2, 2)
    self.bottom_stone3 = self:read_stone_con(self.B_Stone3, 2)
    self.bottom_stone1.Button.onClick:AddListener(function() self:OnClickBottom1Stone(1) end)
    self.bottom_stone2.Button.onClick:AddListener(function() self:OnClickBottom1Stone(2) end)
    self.bottom_stone3.Button.onClick:AddListener(function() self:OnClickBottom1Stone(3) end)

    --底部状态2
    self.Bottom2 = self.EquipStone:FindChild("Bottom2")
    self.B2_Stone1 = self.Bottom2:FindChild("Stone1")
    self.B2_Stone2 = self.Bottom2:FindChild("Stone2")
    self.bottom2_stone1 = self:read_stone_con(self.B2_Stone1, 3)
    self.bottom2_stone2 = self:read_stone_con(self.B2_Stone2, 4)
    self.bottom2_stone1.Button.onClick:AddListener(function() self:On_Click_remove() end)
    self.bottom2_stone1.ButtonLook.onClick:AddListener(function() self:On_Click_look() end)
    self.bottom2_stone2.Button.onClick:AddListener(function() self:On_Click_up() end)
    self.restoreFrozen_stone = FrozenButton.New(self.bottom2_stone2.Button)

    --底部状态3
    self.Bottom3 = self.EquipStone:FindChild("Bottom3")
    self.Bottom3TitleTxt = self.Bottom3:FindChild("ImgTitle"):FindChild("Text"):GetComponent(Text)
    self.ProgConTxt = self.Bottom3:FindChild("ProgCon"):FindChild("ImgProgBg"):FindChild("TxtProg"):GetComponent(Text)
    self.ProgConBarRect = self.Bottom3:FindChild("ProgCon"):FindChild("ImgProgBg"):FindChild("ImgProg"):GetComponent(RectTransform)
    self.Bottom3DescTxt1 = self.Bottom3:FindChild("TxtDesc1"):GetComponent("Text")
    self.Bottom3DescTxt2 = self.Bottom3:FindChild("TxtDesc2"):GetComponent("Text")
    self.Bottom3BreakBtn = self.Bottom3:FindChild("ImgBreakBtn"):GetComponent("Button")
    self.Bottom3CostCon = self.Bottom3:FindChild("ImgCostCon")
    self.Bottom3LookBtn = self.Bottom3CostCon:FindChild("ButtonLook"):GetComponent(Button)
    self.Bottom3SlotCon = self.Bottom3CostCon:FindChild("SlotCon").gameObject
    self.Bottom3Slot = self:create_slot(self.Bottom3SlotCon)
    self.Bottom3SlotTxt = self.Bottom3CostCon:FindChild("SlotNameTxt"):GetComponent(Text)
    self.Bottom3UpGradeBtn = self.Bottom3CostCon:FindChild("ImgUpGradeBtn"):GetComponent(Button)
    self.Bottom3LookBtn.onClick:AddListener(function()
        self:On_Click_look()
    end)
    self.Bottom3UpGradeBtn.onClick:AddListener(function()
        -- local stone_id = self.bottom_stone3.myData.id
        for i=1,#self.cur_selected_item.data.attr do
            local ed = self.cur_selected_item.data.attr[i]
            if ed.type == GlobalEumn.ItemAttrType.gem then
                if ed.name == self.thirdKongId then
                    self.upgrade_heor_stone = true
                    local cfgMaterialData = DataBacksmith.data_hero_stone_material[ed.val]
                    local cfgData = DataBacksmith.data_hero_stone_base[ed.val] --self.parent.model:get_first_lev_hero_stone_by_id(base_id)
                    local curExp = 0
                    local maxExp = cfgData.max_exp
                    for k, v in pairs(self.cur_selected_item.data.attr) do
                        if v.name == self.thirdKongId then
                            curExp = v.flag
                            break
                        end
                    end
                    maxExp = maxExp/5
                    curExp = curExp/5
                    local needExp = maxExp - curExp
                    local hasNum = BackpackManager.Instance:GetItemCount(cfgMaterialData.loss[1][1])
                    local needUpdateNum = math.ceil(needExp/(cfgMaterialData.exp/5))
                    local canUpdateNum = math.floor(hasNum/cfgMaterialData.loss[1][2])
                    if canUpdateNum > needUpdateNum then
                        --道具的个数满足提升到升级，够
                        if self.curHeroLev == 5 then
                            local data = NoticeConfirmData.New()
                            data.type = ConfirmData.Style.Normal
                            data.content = TI18N("<color='#ffff00'>6级及以上</color>的英雄宝石在装备进阶时会损失<color='#ffff00'>一部分</color>经验，请注意哟~{face_1, 7}")
                            data.sureLabel = TI18N("确认升级")
                            data.cancelLabel = TI18N("取消")
                            data.cancelSecond = 180
                            data.sureCallback = function()
                                EquipStrengthManager.Instance:request10624(self.cur_selected_item.data.id, self.cur_selected_kong_id, needUpdateNum*cfgMaterialData.loss[1][2]/cfgMaterialData.loss[1][2])
                            end
                            NoticeManager.Instance:ConfirmTips(data)
                        else
                            EquipStrengthManager.Instance:request10624(self.cur_selected_item.data.id, self.cur_selected_kong_id, needUpdateNum*cfgMaterialData.loss[1][2]/cfgMaterialData.loss[1][2])
                        end
                    else
                        --道具个数不满足提升到升级，不够
                        EquipStrengthManager.Instance:request10624(self.cur_selected_item.data.id, self.cur_selected_kong_id, canUpdateNum*cfgMaterialData.loss[1][2]/cfgMaterialData.loss[1][2])
                    end
                    break
                end
            end
        end
    end)

    self.Bottom3BreakBtn.onClick:AddListener(function()
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            EquipStrengthManager.Instance:request10606(self.cur_selected_item.data.id, self.cur_selected_kong_id)
        end
        local gainList = nil
        for i=1,#self.cur_selected_item.data.attr do
            local ed = self.cur_selected_item.data.attr[i]
            if ed.type == GlobalEumn.ItemAttrType.gem then
                if ed.name == self.thirdKongId then
                    gainList = DataBacksmith.data_hero_stone_break[ed.val].gain
                    break
                end
            end
        end
        local str = ""
        if gainList ~= nil then
            for i=1, #gainList do
                local gainData = gainList[i]
                local baseData = DataItem.data_get[gainData[1]]
                local num = gainData[2]
                if str == "" then
                    str = string.format("%s:%sx%s", TI18N("拆除该宝石可返还"), ColorHelper.color_item_name(baseData.quality , baseData.name), num)
                else
                    str = string.format("%s、%sx%s", str, ColorHelper.color_item_name(baseData.quality , baseData.name), num)
                end
            end
        end
        confirmData.content = str
        NoticeManager.Instance:ConfirmTips(confirmData)
    end)

    self.on_equip_update = function(equips)
        self:update_left_list()
    end
    self.on_item_update = function()
        if self.cur_selected_item ~= nil then
            --设置为不选中
            self:update_left_list()
        end
    end
    self.isHide = false
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
    self:update_left_list()
    self.has_init = true
end

--------------------------时间监听器
function EquipStrengthSecondTab:on_equip_item_change(equips)
    if self.has_init == true then
        self:update_sigle_item(equips)
    end
end

-------------------------各种更新逻辑
--更新单个
function EquipStrengthSecondTab:update_sigle_item(equips)

    local new_data = BackpackManager.Instance.equipDic[equips[1].id]
    if self.cur_selected_item ~= nil then
        new_data = BackpackManager.Instance.equipDic[self.cur_selected_item.data.id]
    end
     if self.item_list ~= nil then
        for i=1, #self.item_list do
            local item =self.item_list[i]
            if item ~= nil and item.data.id == new_data.id then
                item:SetData(new_data)
                if self.cur_selected_item == item then
                     self:update_right(item)
                end
                break
            end
        end
    end
end

--更新左边列表
function EquipStrengthSecondTab:update_left_list()
    if self.isHide then
        return
    end
    if self.item_list ~= nil then
        for i=1, #self.item_list do
            if self.item_list[i] ~= nil then
                self.item_list[i].ImgSelected.gameObject:SetActive(false)
                self.item_list[i].gameObject:SetActive(false)
            end
        end
    else
        self.item_list = {}
    end

    local data_list = {}
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        table.insert(data_list, v)
    end

    for i=1,#data_list do
        local data = data_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = EquipStrengthSecondItem.New(self, self.EquipItem)
            table.insert(self.item_list, item)
        end
        item:SetData(data)
    end
    if self.cur_selected_item ==nil and #self.item_list > 0 then
        self:update_right(self.item_list[1])
    else
        self:update_right(self.cur_selected_item)
    end
end

--item调用更新右边逻辑
function EquipStrengthSecondTab:update_right_for_item(item)
    if self.cur_selected_item == item then
        return
    end
    self:update_right(item)
end


--左边列表选中item更新右边面板内容
function EquipStrengthSecondTab:update_right(item)
    if self.cur_selected_item ~= nil then
        --设置为不选中
        self.cur_selected_item.ImgSelected:SetActive(false)
    end
    self.cur_selected_item = item
    self.cur_selected_item.ImgSelected:SetActive(true)
    local data = item.data
    self.left_stone_state = false --true则改孔位不可以放入宝石
    self.right_stone_state = false --true 则该孔位不可以放入宝石
    self.hero_stone_state = false --true 则该空位不可以放入宝石
    if RoleManager.Instance.RoleData.lev < 65 then
        --只显示两个孔
        self.Stone1.gameObject:SetActive(true)
        self.Stone2.gameObject:SetActive(true)
        self.Stone3.gameObject:SetActive(false)
        self.Stone1:GetComponent(RectTransform).anchoredPosition = Vector2(-80, 10)
        self.Stone2:GetComponent(RectTransform).anchoredPosition = Vector2(80, 10)
    elseif RoleManager.Instance.RoleData.lev >= 65 then
        --显示三个孔
        self.Stone1.gameObject:SetActive(true)
        self.Stone2.gameObject:SetActive(true)
        self.Stone3.gameObject:SetActive(true)
        self.Stone1:GetComponent(RectTransform).anchoredPosition = Vector2(-135, 10)
        self.Stone2:GetComponent(RectTransform).anchoredPosition = Vector2(0, 10)
        self.Stone3:GetComponent(RectTransform).anchoredPosition = Vector2(135, 10)
    end

    --更新顶部两个孔位
    self.top_stone1.GreenBlockCon.gameObject:SetActive(false)
    self.top_stone1.TxtName.gameObject:SetActive(true)
    self.top_stone2.GreenBlockCon.gameObject:SetActive(false)
    self.top_stone2.TxtName.gameObject:SetActive(true)
    self.top_stone3.GreenBlockCon.gameObject:SetActive(false)
    self.top_stone3.TxtName.gameObject:SetActive(true)
    self.top_stone1.mySlot:SetAll(nil, nil)
    self.top_stone2.mySlot:SetAll(nil, nil)
    self.top_stone3.mySlot:SetAll(nil, nil)
    if data.lev < 30 then
        self.left_stone_state = true
        --未开启
        self.top_stone1.mySlot:SetAddCallback(nil)
        self.top_stone1.mySlot:SetLockCallback(nil)
        self.top_stone1.mySlot:SetAll(nil, nil)
        self.top_stone1.mySlot:ShowAddBtn(false)
        self.top_stone1.mySlot:ShowLock(true)
        self.top_stone1.TxtName.text = TI18N("30级开启")
    else
        self.left_stone_state = false
        --已开启
        self.top_stone1.mySlot:ShowAddBtn(true)
        self.top_stone1.mySlot:ShowLock(false)
        self.top_stone1.mySlot:SetAddCallback(function()
            self:OnSelectedKong(self.firstKongId, 0)
        end)
        self.top_stone1.mySlot:SetLockCallback(nil)
        self.top_stone1.TxtName.text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("可镶嵌宝石"))
    end

    if data.lev < 60 then
        self.right_stone_state = true
        --未开启
        self.top_stone2.mySlot:SetAddCallback(nil)
        self.top_stone2.mySlot:SetLockCallback(nil)
        self.top_stone2.mySlot:SetAll(nil, nil)
        self.top_stone2.mySlot:ShowAddBtn(false)
        self.top_stone2.mySlot:ShowLock(true)
        self.top_stone2.TxtName.text = TI18N("装备60级开启")
    else
        self.right_stone_state = false
        --已开启
        self.top_stone2.mySlot:ShowAddBtn(true)
        self.top_stone2.mySlot:ShowLock(false)
        self.top_stone2.mySlot:SetAddCallback(function()
            self:OnSelectedKong(self.secondKongId, 0)
        end)
        self.top_stone2.mySlot:SetLockCallback(nil)
        self.top_stone2.TxtName.text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("可镶嵌宝石"))
    end

    if data.lev < 70 then
        self.hero_stone_state = true
        --未开启
        self.Stone3LockIcon:SetActive(true)
        self.top_stone3.mySlot:SetAddCallback(nil)
        self.top_stone3.mySlot:SetLockCallback(nil)
        self.top_stone3.mySlot:SetAll(nil, nil)
        self.top_stone3.mySlot:ShowAddBtn(false)
        self.top_stone3.mySlot:ShowLock(true)
        self.top_stone3.TxtName.text = string.format("%s\n<color='#b031d5'>%s</color>", TI18N("装备70级开启"), TI18N("英雄宝石"))
    else
        self.hero_stone_state = false
        self.Stone3LockIcon:SetActive(false)
        --已开启
        self.top_stone3.mySlot:ShowAddBtn(true)
        self.top_stone3.mySlot:ShowLock(false)
        self.top_stone3.mySlot:SetAddCallback(function()
            self:OnSelectedKong(self.thirdKongId, 0)
        end)
        self.top_stone3.mySlot:SetLockCallback(nil)
        self.top_stone3.TxtName.text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("可镶嵌英雄宝石"))
    end

    --检查下是否各个孔位已经有宝石镶嵌
    for i=1,#data.attr do
        local ed = data.attr[i]
        if ed.type == GlobalEumn.ItemAttrType.gem then
            if ed.name == self.firstKongId then
                --第一个孔位有宝石
                self.left_stone_state = true
                self.top_stone1.mySlot:ShowAddBtn(false)
                self.top_stone1.mySlot:ShowLock(false)
                self:set_stone_slot_data(self.top_stone1.mySlot, ed.val)
                self.top_stone1.mySlot:SetNotips(true)
                self.top_stone1.mySlot:SetSelectSelfCallback(function()
                    --选中第一个孔位
                    self:OnSelectedKong(self.firstKongId, 1, ed.val)
                end)

                self:set_bind_stone_green(self.top_stone1.TxtName, self.top_stone1.GreenBlockCon, data.lev, DataBacksmith.data_gem_base[ed.val].lev, self.top_stone1.GreenBlockCon, self.top_stone1.block_list, self.top_stone1.block_con_list, 1)
            elseif ed.name == self.secondKongId then
                --第二个孔位有宝石
                self.right_stone_state = true
                self.top_stone2.mySlot:ShowAddBtn(false)
                self.top_stone2.mySlot:ShowLock(false)
                self:set_stone_slot_data(self.top_stone2.mySlot, ed.val)
                self.top_stone2.mySlot:SetNotips(true)
                self.top_stone2.mySlot:SetSelectSelfCallback(function()
                    --选中第一个孔位
                    self:OnSelectedKong(self.secondKongId, 1, ed.val)
                end)

                self:set_bind_stone_green(self.top_stone2.TxtName, self.top_stone2.GreenBlockCon, data.lev, DataBacksmith.data_gem_base[ed.val].lev, self.top_stone2.GreenBlockCon, self.top_stone2.block_list, self.top_stone2.block_con_list, 1)
            elseif ed.name == self.thirdKongId then
                --第三个空位有宝石
                self.Stone3LockIcon:SetActive(false)
                self.hero_stone_state = true
                self.top_stone3.mySlot:ShowAddBtn(false)
                self.top_stone3.mySlot:ShowLock(false)
                self:set_stone_slot_data(self.top_stone3.mySlot, ed.val)
                self.top_stone3.mySlot:SetNotips(true)
                self.top_stone3.mySlot:SetSelectSelfCallback(function()
                    --选中第一个孔位
                    self:OnSelectedKong(self.thirdKongId, 1, ed.val)
                end)
                self:set_bind_stone_green(self.top_stone3.TxtName, self.top_stone3.GreenBlockCon, data.lev, DataBacksmith.data_hero_stone_base[ed.val].lev, self.top_stone3.GreenBlockCon, self.top_stone3.block_list, self.top_stone3.block_con_list, 2)

                self.top_stone3.mySlot:DefaultQuality()
                self.top_stone3.mySlot.qualityBg.gameObject:SetActive(false)
            end
        end
    end

    if self.left_stone_state == false and self.right_stone_state == true then
        self:OnSelectedKong(self.firstKongId, 0)
    elseif self.left_stone_state == false and self.right_stone_state == false then
        self:OnSelectedKong(self.firstKongId, 0)
    elseif self.left_stone_state == true and self.right_stone_state == false then
        --如果第一个孔位有宝石，第二个没有，择选中第二个
        self:OnSelectedKong(self.secondKongId, 0)
    elseif self.cur_selected_kong_id == self.firstKongId or self.cur_selected_kong_id ==nil then
        for i=1,#data.attr do
            local ed = data.attr[i]
            if ed.type == GlobalEumn.ItemAttrType.gem then
                if ed.name == self.firstKongId then
                    self:OnSelectedKong(self.firstKongId, 1, ed.val) --默认选中第一个孔位
                    break
                end
            end
        end
    elseif self.cur_selected_kong_id == self.secondKongId then
        for i=1,#data.attr do
            local ed = data.attr[i]
            if ed.type == GlobalEumn.ItemAttrType.gem then
                if ed.name == self.secondKongId then
                    self:OnSelectedKong(self.secondKongId, 1, ed.val) --默认选中第一个孔位
                    break
                end
            end
        end
    elseif self.cur_selected_kong_id == self.thirdKongId then
        local unStone = true
        for i=1,#data.attr do
            local ed = data.attr[i]
            if ed.type == GlobalEumn.ItemAttrType.gem then
                if ed.name == self.thirdKongId then
                    self.cur_hero_stone_id = ed.name
                    self:OnSelectedKong(self.thirdKongId, 1, ed.val)
                    unStone = false
                    break
                end
            end
        end
        if unStone then
            self:OnSelectedKong(self.thirdKongId, 0)
        end
    elseif self.left_stone_state == true and self.right_stone_state == true and self.hero_stone_state == false then
        self:OnSelectedKong(self.thirdKongId, 0)
    end

    --记录下当前选中的装备对应的两个孔位是否已经镶嵌

    self.effect_right:SetActive(false)
    self.effect_left:SetActive(false)
    self.hero_effect_uplev:SetActive(false)
    self.hero_effect_upgrade:SetActive(false)

    if self.last_data_base_id ~= nil then
        if self.last_data_base_id == item.data.base_id then
            --是同一个装备
            if self.last_left_stone_state == false and self.left_stone_state == true then
                self.effect_left:SetActive(false)
                self.effect_left:SetActive(true)
            end
            if self.last_right_stone_state == false and self.right_stone_state == true then
                self.effect_right:SetActive(false)
                self.effect_right:SetActive(true)
            end
            if self.thirdKongId == self.cur_selected_kong_id then
                --当前是英雄宝石的孔
                if self.mark_hero_stone or self.upgrade_heor_stone then
                    if self.hero_stone_state == true then
                        if self.last_hero_stone_id == nil and self.cur_hero_stone_id ~= nil then
                            --新镶嵌
                            self.hero_effect_uplev:SetActive(true)
                        elseif self.cur_hero_stone_id ~= nil and self.cur_hero_stone_id ~= self.last_hero_stone_id then
                            --看下是否升级，两个英雄宝石的id不一样就是升级了
                            self.hero_effect_uplev:SetActive(true)
                        elseif self.cur_hero_stone_id ~= nil and self.cur_hero_stone_id == self.last_hero_stone_id then
                            --经验提升
                            self.hero_effect_upgrade:SetActive(true)
                        end
                    end
                end
            end

        end
    end
    self.last_data_base_id = item.data.base_id
    self.last_left_stone_state = self.left_stone_state
    self.last_right_stone_state = self.right_stone_state
    self.last_hero_stone_state = self.hero_stone_state
    self.last_hero_stone_id = self.cur_hero_stone_id
    LuaTimer.Add(1000, function()
        if self.has_init == false then
            return
        end
        if self.effect_left ~= nil then
           self.effect_left:SetActive(false)
        end
        if self.effect_right ~= nil then
           self.effect_right:SetActive(false)
        end
        if self.hero_effect_uplev ~= nil then
            self.hero_effect_uplev:SetActive(false)
        end
        if self.hero_effect_upgrade ~= nil then
            self.hero_effect_upgrade:SetActive(false)
        end
        self.mark_hero_stone = false
        self.upgrade_heor_stone = false
    end )

    LuaTimer.Add(300, function() self:CheckGuide() end)
end

-------------------------辅助逻辑
--设置已镶嵌宝石的绿块
function EquipStrengthSecondTab:set_bind_stone_green(txtName, blockCon, eq_lev, stone_lev, greenCon, block_list, block_con_list, kongType)
    -- self.top_stone2.block_list
    blockCon.gameObject:SetActive(true)
    txtName.gameObject:SetActive(false)
    local num = 0
    if kongType == 1 then
        local numBase = DataBacksmith.data_stone_bind_num[eq_lev]
        if numBase == nil then
            num = 10
        else
            num = numBase.num
        end
    elseif kongType == 2 then
        local numBase = DataBacksmith.data_hero_stone_bind_num[eq_lev]
        if numBase == nil then
            num = 12
        else
            num = numBase.num
        end
    end

    for i=1,#block_con_list do
        if i <= num then
            block_con_list[i].gameObject:SetActive(true)
        else
            block_con_list[i].gameObject:SetActive(false)
        end
    end

    -- greenCon:GetComponent(RectTransform).anchoredPosition = Vector2(self.green_con_X[num] , -51)

    for i=1,#block_list do
        if i <= stone_lev then
            block_list[i].gameObject:SetActive(true)
        else
            block_list[i].gameObject:SetActive(false)
        end
    end
end

--读取宝石图标里面的一些组件，返回一个表
function EquipStrengthSecondTab:read_stone_con(con, _type)
    local item = {}
    item.SlotCon = con:FindChild("SlotCon").gameObject
    item.TxtName = con:FindChild("TxtName"):GetComponent(Text)
    item.mySlot = self:create_slot(item.SlotCon)
    item.mySlot:SetAll(nil, nil)
    if _type == 1 or _type == 5 then
        item.GreenBlockCon = con:FindChild("GreenBlockCon")
        item.block_list = {}
        item.block_con_list = {}
        local blockLen = 10
        if _type == 5 then
            blockLen = 12
        end
        for i=1,blockLen do
            local block_con = item.GreenBlockCon:FindChild(string.format("ImgBlockCon%s",i))
            table.insert(item.block_con_list, block_con)
            table.insert(item.block_list, block_con:FindChild("ImgBlock").gameObject)
        end
    elseif _type == 2 or _type == 3 or _type == 4 then
        item.TxtProp = con:FindChild("TxtProp"):GetComponent(Text)
        item.Button = con:FindChild("Button"):GetComponent(Button)
    end
    if _type == 3 then
        item.ButtonLook = con:FindChild("ButtonLook"):GetComponent(Button)
    end
    return item
end

--为每一个slotcon创建slot
function EquipStrengthSecondTab:create_slot(slotCon)
    local stone_slot = ItemSlot.New()

    stone_slot.gameObject.transform:SetParent(slotCon.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--设置宝石道具各自数据
function EquipStrengthSecondTab:set_stone_slot_data(slot, base_id)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
end

----------------时间监听
--点击镶嵌按钮
function EquipStrengthSecondTab:OnClickBottom1Stone(index)
    -- self.cur_selected_kong_id
    local stone_id = 0
    local need_num = 1
    if index == 1 then
        stone_id = self.bottom_stone1.myData.id
    elseif index == 2 then
        stone_id = self.bottom_stone2.myData.id
    elseif index == 3 then
        stone_id = self.bottom_stone3.myData.id
    end

    if self.thirdKongId == self.cur_selected_kong_id then
        local costData = DataBacksmith.data_hero_stone_cost[stone_id].loss[1]
        EquipStrengthManager.Instance.model.hero_stone_quick_buy_data = {self.cur_selected_item.data.id, self.cur_selected_kong_id, stone_id, costData}
        EquipStrengthManager.Instance.model.hero_stone_quick_buy_data.btn_txt = TI18N("镶嵌")
        EquipStrengthManager.Instance.model.hero_stone_quick_buy_data.need_num = costData[2]
        EquipStrengthManager.Instance.model.hero_stone_quick_buy_data.total_num = costData[2]
        EquipStrengthManager.Instance.model.hero_stone_quick_buy_data.callback = function()
            --镶嵌英雄宝石
            self.mark_hero_stone = true
            EquipStrengthManager.Instance:request10604(self.cur_selected_item.data.id, self.cur_selected_kong_id, stone_id)
            self.parent:CloseHeroStoneQuickBuy()
        end
        self.parent:ShowHeroStoneQuickBuy()
    else
        local has_num = BackpackManager.Instance:GetItemCount(stone_id)
        if has_num < need_num then
            --打开快捷按钮
            EquipStrengthManager.Instance.model.stone_quick_buy_data = {self.cur_selected_item.data.id, self.cur_selected_kong_id, stone_id}
            EquipStrengthManager.Instance.model.stone_quick_buy_data.btn_txt = TI18N("镶嵌")
            EquipStrengthManager.Instance.model.stone_quick_buy_data.need_num = 1
            EquipStrengthManager.Instance.model.stone_quick_buy_data.total_num = 1
            EquipStrengthManager.Instance.model.stone_quick_buy_data.callback = function()
                EquipStrengthManager.Instance:request10604(self.cur_selected_item.data.id, self.cur_selected_kong_id,    stone_id)
                self.parent:CloseStoneQuickBuy()
            end

            self.parent:ShowStoneQuickBuy({[stone_id] = {need = 1}})
            return
        end
        EquipStrengthManager.Instance:request10604(self.cur_selected_item.data.id, self.cur_selected_kong_id, stone_id)
    end
end

--点击摘除宝石按钮
function EquipStrengthSecondTab:On_Click_remove()

    local back_lev = 1
    for i=1,#self.cur_selected_item.data.attr do
        local ed = self.cur_selected_item.data.attr[i]
        if ed.type == GlobalEumn.ItemAttrType.gem then
            if ed.name == self.cur_selected_kong_id then
                back_lev = DataBacksmith.data_gem_base[ed.val].lev
                break
            end
        end
    end

    back_lev = back_lev == 1 and back_lev or back_lev - 1
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format("%s%s%s", TI18N("拆除宝石将只退还"), back_lev, TI18N("级的宝石材料，确认是否要拆除宝石"))
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        EquipStrengthManager.Instance:request10606(self.cur_selected_item.data.id, self.cur_selected_kong_id)
    end
    NoticeManager.Instance:ConfirmTips(data)
    -- EquipStrengthManager.Instance:request10606(self.cur_selected_item.data.id, self.cur_selected_kong_id)
end

--点击查看宝石按钮
function EquipStrengthSecondTab:On_Click_look()
    local kongType = 0
    if self.cur_selected_kong_id == self.thirdKongId then
        kongType = 1
        EquipStrengthManager.Instance.model.cur_stone_look_dic = DataBacksmith.data_hero_stone_limit[self.cur_selected_item.data.type].allow
    else
        kongType = 2
        EquipStrengthManager.Instance.model.cur_stone_look_dic = self.cur_selected_item.base_id_dic
    end
    EquipStrengthManager.Instance.model:OpenEquipStoneLookUI(kongType)
end

--点击宝石提升按钮
function EquipStrengthSecondTab:On_Click_up()

    for i=1,#self.cur_selected_item.data.attr do
        local ed = self.cur_selected_item.data.attr[i]
        if ed.type == GlobalEumn.ItemAttrType.gem then
            if ed.name == self.cur_selected_kong_id then
                local eq_lev = self.cur_selected_item.data.lev
                local stone_lev = DataBacksmith.data_gem_base[ed.val].lev
                local max_lev = DataBacksmith.data_stone_bind_num[self.cur_selected_item.data.lev].num
                if stone_lev >= max_lev then
                    NoticeManager.Instance:FloatTipsByString(string.format("%s%s", eq_lev+10, TI18N("级装备可提升")))
                    return
                end
            end
        end
    end

    local cur_cfg_data = DataBacksmith.data_gem_base[self.bottom2_stone2.myData.id]
    local has_num = BackpackManager.Instance:GetItemCount(self.bottom2_stone2.myData.id)

    if self.bottom2_stone2_need_num > has_num then
        EquipStrengthManager.Instance.model.stone_quick_buy_data = {self.cur_selected_item.data.id, self.cur_selected_kong_id, self.bottom2_stone2.myData.id}
        EquipStrengthManager.Instance.model.stone_quick_buy_data.btn_txt = TI18N("提升")

        EquipStrengthManager.Instance.model.stone_quick_buy_data.need_num = self.bottom2_stone2_need_num - has_num
        EquipStrengthManager.Instance.model.stone_quick_buy_data.total_num = self.bottom2_stone2_need_num
        EquipStrengthManager.Instance.model.stone_quick_buy_data.callback = function()
            EquipStrengthManager.Instance:request10605(self.cur_selected_item.data.id, self.cur_selected_kong_id, self.bottom2_stone2.myData.id)
            self.parent:CloseStoneQuickBuy()
        end
        self.parent:ShowStoneQuickBuy({[self.bottom2_stone2.myData.id] = {need = self.bottom2_stone2_need_num - has_num}})
        return
    end
    EquipStrengthManager.Instance:request10605(self.cur_selected_item.data.id, self.cur_selected_kong_id, self.bottom2_stone2.myData.id)
end

--选中孔位
function EquipStrengthSecondTab:OnSelectedKong(kong_id, kong_state, base_id)
    self.cur_selected_kong_id = kong_id
    self.Bottom1.gameObject:SetActive(false)
    self.Bottom2.gameObject:SetActive(false)
    self.Bottom3.gameObject:SetActive(false)

    self.top_stone1.mySlot:ShowSelect(false)
    self.top_stone2.mySlot:ShowSelect(false)
    self.top_stone3.mySlot:ShowSelect(false)
    if kong_id == self.firstKongId then
        self.top_stone1.mySlot:ShowSelect(true)
    elseif kong_id == self.secondKongId then
        self.top_stone2.mySlot:ShowSelect(true)
    elseif kong_id == self.thirdKongId then
        self.top_stone3.mySlot:ShowSelect(true)
    end

    if kong_state == 0 then
        --孔已开启但没有镶嵌过
        --更新未镶嵌的bottom
        self.B_Stone1.gameObject:SetActive(false)
        self.B_Stone2.gameObject:SetActive(false)
        self.B_Stone3.gameObject:SetActive(false)
        local key = string.format("%s_%s", self.cur_selected_item.data.type, RoleManager.Instance.RoleData.classes)
        if self.thirdKongId == self.cur_selected_kong_id then
            --英雄宝石
            local allowList = DataBacksmith.data_hero_stone_limit[self.cur_selected_item.data.type].allow
            local recommend_id = DataBacksmith.data_hero_stone_recommend[key].stone_id
            local index = 1
             for k,v in pairs(allowList) do
                if v[1] == recommend_id then
                    --放第一个
                    self.B_Stone1.gameObject:SetActive(true)
                    self:update_stone_data(self.bottom_stone1, v[1])
                else
                    if index == 1 then
                        self.B_Stone2.gameObject:SetActive(true)
                        self:update_stone_data(self.bottom_stone2, v[1])
                    elseif index == 2 then
                        self.B_Stone3.gameObject:SetActive(true)
                        self:update_stone_data(self.bottom_stone3, v[1])
                    end
                    index = index + 1
                end
            end
            self.Bottom1TiitleTxt.text = TI18N("此装备可镶英雄宝石")
            self.Bottom1.gameObject:SetActive(true)
        else
            --普通宝石
            local recommend_id = DataBacksmith.data_stone_recommend[key].stone_id
            local cur_has_list = {}
            local index = 1
            for k,v in pairs(self.cur_selected_item.base_id_dic) do
                if k == recommend_id then
                    --放第一个
                    self.B_Stone1.gameObject:SetActive(true)
                    self:update_stone_data(self.bottom_stone1, k)
                else
                    if index == 1 then
                        self.B_Stone2.gameObject:SetActive(true)
                        self:update_stone_data(self.bottom_stone2, k)
                    elseif index == 2 then
                        self.B_Stone3.gameObject:SetActive(true)
                        self:update_stone_data(self.bottom_stone3, k)
                    end
                    index = index + 1
                end
            end
            self.Bottom1TiitleTxt.text = TI18N("此装备可镶宝石")
            self.Bottom1.gameObject:SetActive(true)
        end
    elseif kong_state == 1 then
        --孔已开启，有镶嵌
        --更新有镶嵌的bottom
        local cur_first_lev_cfg_data = nil
        if self.thirdKongId == self.cur_selected_kong_id then
            cur_first_lev_cfg_data = DataBacksmith.data_hero_stone_base[base_id] --self.parent.model:get_first_lev_hero_stone_by_id(base_id)
            local baseData = DataItem.data_get[cur_first_lev_cfg_data.id]
            local curExp = 0
            local maxExp = cur_first_lev_cfg_data.max_exp
            for k, v in pairs(self.cur_selected_item.data.attr) do
                if v.name == self.thirdKongId then
                    curExp = v.flag
                    break
                end
            end
            maxExp = maxExp/5
            curExp = curExp/5
            local curLev = DataBacksmith.data_hero_stone_base[base_id].lev
            self.curHeroLev = curLev

            self.Bottom3TitleTxt.text = baseData.name
            self.ProgConTxt.text = string.format("%s/%s", curExp, maxExp)

            if self.progConBarRectTween1 ~= nil then
                Tween.Instance:Cancel(self.progConBarRectTween1)
                self.progConBarRectTween1 = nil 
            end
            if self.progConBarRectTween2 ~= nil then
                Tween.Instance:Cancel(self.progConBarRectTween2)
                self.progConBarRectTween2 = nil 
            end

            if self.last_data_base_id ~= self.cur_selected_item.data.base_id then
                self.ProgConBarRect.sizeDelta = Vector2(293*curExp/maxExp, self.ProgConBarRect.rect.height)
            else
                if curExp > 0 then
                    if self.last_hero_stone_lev == nil or self.last_hero_stone_lev == curLev then
                        --不是升级
                        self.progConBarRectTween1 = Tween.Instance:ValueChange(self.ProgConBarRect.rect.width, 293*curExp/maxExp, 1, nil, LeanTweenType.linear, function(v)
                            self.ProgConBarRect.sizeDelta = Vector2(v, self.ProgConBarRect.rect.height)
                        end).id
                    else
                        --升级了
                        self.progConBarRectTween1 = Tween.Instance:ValueChange(self.ProgConBarRect.rect.width, 293, 1,
                            function()
                                self.progConBarRectTween2 = Tween.Instance:ValueChange(0, 293*curExp/maxExp, 1, nil, LeanTweenType.linear, function(v)
                                    self.ProgConBarRect.sizeDelta = Vector2(v, self.ProgConBarRect.rect.height)
                                end).id
                            end
                            , LeanTweenType.linear,
                            function(v)
                                self.ProgConBarRect.sizeDelta = Vector2(v, self.ProgConBarRect.rect.height)
                            end
                        ).id
                    end
                else
                    if self.last_hero_stone_lev ~= nil and self.last_hero_stone_lev ~= curLev then
                        --是升级
                        self.progConBarRectTween1 = Tween.Instance:ValueChange(self.ProgConBarRect.rect.width, 293, 1,
                            function()
                                self.ProgConBarRect.sizeDelta = Vector2(0, self.ProgConBarRect.rect.height)
                            end
                            , LeanTweenType.linear,
                            function(v)
                                self.ProgConBarRect.sizeDelta = Vector2(v, self.ProgConBarRect.rect.height)
                            end
                        ).id
                    else
                        self.ProgConBarRect.sizeDelta = Vector2(0, self.ProgConBarRect.rect.height)
                    end
                end
            end

            local cfgMaterialCost = DataBacksmith.data_hero_stone_material[base_id].loss[1]
            local cfgAttrData = cur_first_lev_cfg_data.attr[1]
            if cur_first_lev_cfg_data.next_id == 0 or DataBacksmith.data_hero_stone_base[cur_first_lev_cfg_data.next_id] == nil then
                --满级了
                self.ProgConTxt.text = TI18N("已满级")
                self.ProgConBarRect.sizeDelta = Vector2(293, self.ProgConBarRect.rect.height)
                self.Bottom3DescTxt1.text = string.format("%s:<color='#248813'>%s</color>", TI18N("效果"), KvData.GetAttrStringNoColor(cfgAttrData.attr_name, cfgAttrData.val1))
                self.Bottom3DescTxt2.text =string.format("%s:<color='#b031d5'>%s</color>", TI18N("下级效果"), TI18N("已满级"))
                self.Bottom3CostCon.gameObject:SetActive(false)
            else
                self.Bottom3CostCon.gameObject:SetActive(true)
                local nextCfgAttrData = DataBacksmith.data_hero_stone_base[cur_first_lev_cfg_data.next_id].attr[1]
                self.Bottom3DescTxt1.text = string.format("%s:<color='#248813'>%s</color>", TI18N("效果"), KvData.GetAttrStringNoColor(cfgAttrData.attr_name, cfgAttrData.val1))
                self.Bottom3DescTxt2.text =string.format("%s:<color='#b031d5'>%s</color>", TI18N("下级效果"), KvData.GetAttrStringNoColor(nextCfgAttrData.attr_name, nextCfgAttrData.val1))

                self:set_stone_slot_data(self.Bottom3Slot, cfgMaterialCost[1])
                local has_num = BackpackManager.Instance:GetItemCount(cfgMaterialCost[1])
                self.Bottom3Slot:SetNum(has_num, cfgMaterialCost[2])
                self.Bottom3SlotTxt.text = DataItem.data_get[cfgMaterialCost[1]].name-- ColorHelper.color_item_name(DataItem.data_get[base_id].quality, DataItem.data_get[base_id].name)
                self.last_hero_stone_lev = curLev
            end
            self.Bottom3.gameObject:SetActive(true)
        else
            cur_first_lev_cfg_data = self.parent.model:get_first_lev_stone_by_id(base_id)
            self.bottom2_stone2_need_num = cur_first_lev_cfg_data.max_exp
            self:update_stone_data(self.bottom2_stone1, base_id)
            self.bottom2_stone1.mySlot:ShowNum(false)
            self:update_stone_data(self.bottom2_stone2, cur_first_lev_cfg_data.id)
            local has_num = BackpackManager.Instance:GetItemCount(cur_first_lev_cfg_data.id)
            self.bottom2_stone2.mySlot:SetNum(has_num, cur_first_lev_cfg_data.max_exp)
            self.bottom2_stone2.TxtName.text = self.bottom2_stone2.myData.name
            self.Bottom2.gameObject:SetActive(true)
        end
    end
end

--更新底部宝石位的数据
function EquipStrengthSecondTab:update_stone_data(item, base_id)
    self:set_stone_slot_data(item.mySlot, base_id)
    local data = DataItem.data_get[base_id]
    local cfg_data = DataBacksmith.data_gem_base[base_id]
    if self.thirdKongId == self.cur_selected_kong_id then
        cfg_data = DataBacksmith.data_hero_stone_base[base_id]
    end
    item.TxtName.text = data.name
    item.TxtProp.text = KvData.GetAttrStringNoColor(cfg_data.attr[1].attr_name, cfg_data.attr[1].val1)
    -- item.TxtProp.text = string.format("%s+%s", KvData.attr_name_show[cfg_data.attr[1].attr_name], cfg_data.attr[1].val1)
    item.myData = data

    local has_num = BackpackManager.Instance:GetItemCount(base_id)
    local need_num = 1
    item.mySlot:SetNum(has_num, 1)
end

function EquipStrengthSecondTab:CheckGuide()
    local questData = QuestManager.Instance.questTab[41261]
    if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Doing and MainUIManager.Instance.priority == 2 then
        -- 只引导武器
        local weapon = BackpackManager.Instance.equipDic[1]
        if weapon.lev < 30 then
            -- 装备未到30级不播引导
            return
        end

        local hasStone = false
        for i,v in ipairs(weapon.attr) do
            if v.type == GlobalEumn.ItemAttrType.gem then
                hasStone = true
            end
        end

        if hasStone then
            -- 已经有镶嵌过宝石不播引导
            return
        end

        if self.guideScript ~= nil then
            self.guideScript:DeleteMe()
            self.guideScript = nil
        end

        EventMgr.Instance:RemoveListener(event_name.guide_equip_stone_end, self.guideOver)
        EventMgr.Instance:AddListener(event_name.guide_equip_stone_end, self.guideOver)

        self.guideScript = GuideEquipStone.New(self)
        self.guideScript:Show()
    end
end

function EquipStrengthSecondTab:OnGuideOver()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end
