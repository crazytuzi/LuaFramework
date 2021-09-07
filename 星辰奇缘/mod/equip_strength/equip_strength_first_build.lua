EquipStrengthFirstBuild = EquipStrengthFirstBuild or BaseClass(BasePanel)

-- 锻造和重铸
function EquipStrengthFirstBuild:__init(parent)
    self.parent = parent
    self.resList = {
        { file = AssetConfig.equip_strength_build, type = AssetType.Main }
        ,{ file = AssetConfig.pet_textures, type = AssetType.Dep }
        ,{ file = string.format(AssetConfig.effect, 20049), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
        ,{ file = string.format(AssetConfig.effect, 20071), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
        ,{ file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
    }
    self.has_init = false
    self.is_playing_effect = false
    self.isNeedHeroStore = false    -- 是否需要使用英雄卷轴

    self.on_equip_update = function(equips) self:update_single_info(equips, true) end
    self.on_equip_build_attr_back = function() self:update_top_right() end
    self.update_reset_val = function() self:on_update_reset_val() end

    self.on_equip_last_lev = function(data) self:update_swtich_last_lev(data) end

    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.build_reset_id = EquipStrengthManager.Instance.model.build_reset_id

    self.buy_listener = function(val) self:OnBuyResult(val) end
    self.isBuy = false
    self.guildeEffect = nil
end

function EquipStrengthFirstBuild:OnShow()
    self:AddListener()
    self.isBuy = false
    if self.PerfectCon_Toggle2 ~= nil then
        if BackpackManager.Instance:GetItemCount(20406) == 0 then
            self.PerfectCon_Toggle2.isOn = false
        else
            self.PerfectCon_Toggle2.isOn = true
        end
    end
end

function EquipStrengthFirstBuild:OnHide()
    self:RemoveListener()

    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
end

function EquipStrengthFirstBuild:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.equip_strength_attr_back, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.equip_build_attr_back, self.on_equip_build_attr_back)
    EventMgr.Instance:RemoveListener(event_name.equip_build_resetval_update, self.update_reset_val)
    EventMgr.Instance:RemoveListener(event_name.equip_last_lev_attr_back, self.on_equip_last_lev)
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.buy_listener)
end

function EquipStrengthFirstBuild:AddListener()
    EventMgr.Instance:AddListener(event_name.equip_strength_attr_back, self.on_equip_update)
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:AddListener(event_name.equip_build_resetval_update, self.update_reset_val)
    EventMgr.Instance:AddListener(event_name.equip_last_lev_attr_back, self.on_equip_last_lev)
end

function EquipStrengthFirstBuild:__delete()
    self:RemoveListener()
    self.Rebuild_ImgTip_Slot:DeleteMe()
    self.top_left_slot:DeleteMe()
    self.top_right_slot:DeleteMe()
    self.bottom_slot_1:DeleteMe()
    self.bottom_slot_2:DeleteMe()
    self.bottom_slot_3:DeleteMe()
    self.perfect_slot:DeleteMe()
    self.hero_slot:DeleteMe()

    self.has_init = false
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    if self.BuildCon_BtnBuild_buy_btn ~= nil then
        self.BuildCon_BtnBuild_buy_btn:DeleteMe()
        self.BuildCon_BtnBuild_buy_btn = nil
    end

    if self.PerfectCon_BtnBuil_buy_btn ~= nil then
        self.PerfectCon_BtnBuil_buy_btn:DeleteMe()
        self.PerfectCon_BtnBuil_buy_btn = nil
    end
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end

function EquipStrengthFirstBuild:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_build))
    self.gameObject.name = "EquipStrengthFirstBuild"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(154, -9, 0)

    self.Rebuild_ImgTip = self.transform:FindChild("ImgTips")
    self.Rebuild_ImgTip_Btn = self.Rebuild_ImgTip:GetComponent(Button)
    self.Rebuild_ImgTip_Con = self.Rebuild_ImgTip:FindChild("Con")
    self.Rebuild_ImgTip_Slot_Con = self.Rebuild_ImgTip_Con:FindChild("Slot").gameObject
    self.Rebuild_ImgTip_TxtName = self.Rebuild_ImgTip_Con:FindChild("TxtName"):GetComponent(Text)
    self.Rebuild_ImgTip.gameObject:SetActive(false)

    self.Rebuild_ImgTip_Btn.onClick:AddListener( function()
        self.Rebuild_ImgTip.gameObject:SetActive(false)
    end )

    self.Rebuild_ImgTip_Slot = self:create_equip_slot(self.Rebuild_ImgTip_Slot_Con)
    local basedata = DataItem.data_get[22589]
    self:set_stone_slot_data(self.Rebuild_ImgTip_Slot, basedata)
    self.Rebuild_ImgTip_TxtName.text = ColorHelper.color_item_name(basedata.quality, basedata.name)



    self.TopCon = self.transform:FindChild("TopCon")

    self.ToggleCon = self.TopCon:FindChild("ToggleCon")
    self.ToggleBtnTanHao = self.ToggleCon:FindChild("BtnTanHao"):GetComponent(Button)

    self.ToggleConLastLev = self.ToggleCon:FindChild("ToggleConLastLev")
    self.ToggleConLastLevBtn = self.ToggleConLastLev:GetComponent(Button)
    self.LastToggle = self.ToggleConLastLev:FindChild("Toggle")
    self.LastBackground = self.LastToggle:FindChild("Background")
    self.LastCheckmark = self.LastBackground:FindChild("Checkmark").gameObject
    self.LastToggleTxt = self.ToggleConLastLev:FindChild("ToggleTxt"):GetComponent(Text)


    self.ToggleConCurLev = self.ToggleCon:FindChild("ToggleConCurLev")
    self.ToggleConCurLevBtn = self.ToggleConCurLev:GetComponent(Button)
    self.CurToggle = self.ToggleConCurLev:FindChild("Toggle")
    self.CurBackground = self.CurToggle:FindChild("Background")
    self.CurCheckmark = self.CurBackground:FindChild("Checkmark").gameObject
    self.CurToggleTxt = self.ToggleConCurLev:FindChild("ToggleTxt"):GetComponent(Text)

    self.LeftCon = self.TopCon:FindChild("LeftCon")
    self.ButtonLook = self.LeftCon:FindChild("ImgTitle"):FindChild("ButtonLook"):GetComponent(Button)
    self.left_selected_bg = self.LeftCon:FindChild("ImgSelectedBg").gameObject
    self.top_left_SlotCon = self.LeftCon:FindChild("SlotCon"):FindChild("SlotCon").gameObject
    self.top_left_TxtName = self.LeftCon:FindChild("TxtName"):GetComponent(Text)
    self.top_left_TxtLev = self.LeftCon:FindChild("TxtLev"):GetComponent(Text)
    self.top_left_TxtVal_1 = self.LeftCon:FindChild("TxtVal_1"):GetComponent(Text)
    self.top_left_TxtVal_2 = self.LeftCon:FindChild("TxtVal_2"):GetComponent(Text)
    self.top_left_TxtVal_3 = self.LeftCon:FindChild("TxtVal_3"):GetComponent(Text)
    self.top_left_TxtVal_4 = self.LeftCon:FindChild("TxtVal_4"):GetComponent(Text)
    self.top_left_TxtVal_5 = self.LeftCon:FindChild("TxtVal_5"):GetComponent(Text)

    self.top_left_txtVal_list = { }
    for i = 1, 6 do
        local txtVal = self.LeftCon:FindChild(string.format("TxtVal_%s", i)):GetComponent(Text)
        table.insert(self.top_left_txtVal_list, txtVal)
    end

    self.top_left_txtstrength_list = { }
    for i = 1, 5 do
        local txtVal = self.LeftCon:FindChild(string.format("TxtStrength_%s", i)):GetComponent(Text)
        table.insert(self.top_left_txtstrength_list, txtVal)
    end

    self.RightCon = self.TopCon:FindChild("RightCon")
    self.right_selected_bg = self.RightCon:FindChild("ImgSelectedBg").gameObject
    self.top_right_title_txt = self.RightCon:FindChild("ImgTitle"):FindChild("Txt"):GetComponent(Text)
    self.top_right_SlotCon = self.RightCon:FindChild("SlotCon"):FindChild("SlotCon").gameObject
    self.top_right_TxtName = self.RightCon:FindChild("TxtName"):GetComponent(Text)
    self.top_right_TxtLev = self.RightCon:FindChild("TxtLev"):GetComponent(Text)

    self.top_right_txt_strength_list = { }
    for i = 1, 5 do
        local txtVal = self.RightCon:FindChild(string.format("TxtStrength_%s", i)):GetComponent(Text)
        table.insert(self.top_right_txt_strength_list, txtVal)
    end


    self.top_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20049)))
    self.top_right_effect.transform:SetParent(self.RightCon:FindChild("SlotCon"))
    self.top_right_effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.top_right_effect.transform, "UI")
    self.top_right_effect.transform.localScale = Vector3(1, 1, 1)
    self.top_right_effect.transform.localPosition = Vector3(30, -30, -400)
    self.top_right_effect:SetActive(false)

    self.top_left_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20049)))
    self.top_left_effect.transform:SetParent(self.LeftCon:FindChild("SlotCon"))
    self.top_left_effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.top_left_effect.transform, "UI")
    self.top_left_effect.transform.localScale = Vector3(1, 1, 1)
    self.top_left_effect.transform.localPosition = Vector3(30, -30, -400)
    self.top_left_effect:SetActive(false)


--    self.fly_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20071)))
--    self.fly_effect.transform:SetParent(self.transform)
--    self.fly_effect.transform.localRotation = Quaternion.identity
--    Utils.ChangeLayersRecursively(self.fly_effect.transform, "UI")
--    self.fly_effect.transform.localScale = Vector3(1, 1, 1)
--    self.fly_effect.transform.localPosition = Vector3(0, 0, -400)
--    self.fly_effect:SetActive(false)

    self.top_right_TxtVal_list = { }
    for i = 1, 5 do
        local txtVal = self.RightCon:FindChild(string.format("TxtVal_%s", i)):GetComponent(Text)
        table.insert(self.top_right_TxtVal_list, txtVal)
    end

    self.top_right_arrow_list = { }
    for i = 1, 5 do
        local arrowup = self.RightCon:FindChild(string.format("ImgArrow%s", i)).gameObject
        table.insert(self.top_right_arrow_list, arrowup)
    end
    self.top_right_BtnSave = self.RightCon:FindChild("BtnSave"):GetComponent(Button)

    self.top_right_txtMaxLev = self.RightCon:FindChild("TxtMaxLev").gameObject
    self.RightCon:FindChild("TxtMaxLev"):GetComponent(Text).text = TI18N("<color='#ffff00'>该装备等级已达到当前最高等级</color>")


    self.top_right_TxtDescLev = self.RightCon:FindChild("TxtDescLev").gameObject
    self.RightCon:FindChild("TxtDescLev"):GetComponent(Text).text = TI18N("40级以下的装备不能重铸，请先提升装备等级")
    self.top_right_TxtDesc = self.RightCon:FindChild("TxtDesc").gameObject

    self.top_right_TxtBottomDesc = self.RightCon:FindChild("TxtBottomDesc").gameObject
    self.RightCon:FindChild("TxtBottomDesc"):GetComponent(Text).text = TI18N("<color='#ffff00'>重铸可获得更高属性哦</color>")
    self.top_right_TxtRecommand = self.RightCon:FindChild("TxtRecommand"):GetComponent(Text)

    self.BottomCon = self.transform:FindChild("BottomCon")
    self.bottom_left_tanhao_btn = self.BottomCon:FindChild("ImgTitle"):FindChild("BtnTanHao"):GetComponent(Button)
    self.bottom_LeftCon = self.BottomCon:FindChild("LeftCon")
    self.bottom_left_Slot1 = self.bottom_LeftCon:FindChild("Slot1")
    self.bottom_left_Slot2 = self.bottom_LeftCon:FindChild("Slot2")
    self.bottom_left_Slot3 = self.bottom_LeftCon:FindChild("Slot3")

    self.bottom_left_txtMaxLev = self.bottom_LeftCon:FindChild("TxtMaxLev").gameObject
    self.bottom_LeftCon:FindChild("TxtMaxLev"):GetComponent(Text).text = TI18N("<color='#ffff00'>该装备等级已达到当前最高等级</color>")

    self.bottom_left_SlotCon1 = self.bottom_left_Slot1:FindChild("SlotCon").gameObject
    self.bottom_left_SlotCon2 = self.bottom_left_Slot2:FindChild("SlotCon").gameObject
    self.bottom_left_SlotCon3 = self.bottom_left_Slot3:FindChild("SlotCon").gameObject

    self.bottom_left_TxtName1 = self.bottom_left_Slot1:FindChild("TxtName"):GetComponent(Text)
    self.bottom_left_TxtName2 = self.bottom_left_Slot2:FindChild("TxtName"):GetComponent(Text)
    self.bottom_left_TxtName3 = self.bottom_left_Slot3:FindChild("TxtName"):GetComponent(Text)

    self.bottom_left_icon1 = self.bottom_left_Slot1:FindChild("ImgIcon"):GetComponent(Image)
    self.bottom_left_icon2 = self.bottom_left_Slot2:FindChild("ImgIcon"):GetComponent(Image)
    self.bottom_left_icon3 = self.bottom_left_Slot3:FindChild("ImgIcon"):GetComponent(Image)

    self.bottom_left_TxtVal1 = self.bottom_left_Slot1:FindChild("TxtVal"):GetComponent(Text)
    self.bottom_left_TxtVal2 = self.bottom_left_Slot2:FindChild("TxtVal"):GetComponent(Text)
    self.bottom_left_TxtVal3 = self.bottom_left_Slot3:FindChild("TxtVal"):GetComponent(Text)

    self.PerfectCon = self.BottomCon:FindChild("PerfectCon")
    self.PerfectCon_RightCon = self.PerfectCon:FindChild("RightCon")
    self.PerfectCon_RightCon.gameObject:SetActive(true)
    self.PerfectCon_RightConRect = self.PerfectCon_RightCon:GetComponent(RectTransform)

    self.PerfectCon_Slot1 = self.PerfectCon_RightCon:FindChild("Slot1")
    self.PerfectCon_Slot1Obj = self.PerfectCon_Slot1.gameObject
    self.PerfectCon_SlotCon = self.PerfectCon_Slot1:FindChild("SlotCon").gameObject
    self.PerfectCon_TxtName = self.PerfectCon_Slot1:FindChild("TxtName"):GetComponent(Text)
    self.PerfectCon_TxtName.text = TI18N("完美打造")
    self.PerfectCon_Toggle = self.PerfectCon_Slot1:FindChild("Toggle"):GetComponent(Toggle)
    self.PerfectCon_Toggle.onValueChanged:AddListener( function() self:on_click_toggle() end)

    self.PerfectCon_Slot2 = self.PerfectCon_RightCon:FindChild("Slot2")
    self.PerfectCon_Slot2Obj = self.PerfectCon_Slot2.gameObject
    self.PerfectCon_Slot2Con = self.PerfectCon_Slot2:FindChild("SlotCon").gameObject
    self.PerfectCon_TxtName2 = self.PerfectCon_Slot2:FindChild("TxtName"):GetComponent(Text)
    self.PerfectCon_TxtName2.text = DataItem.data_get[20406].name
    self.PerfectCon_Toggle2 = self.PerfectCon_Slot2:FindChild("Toggle"):GetComponent(Toggle)
    self.PerfectCon_Toggle2.isOn = false
    self.PerfectCon_Slot2:Find("Btn"):GetComponent(Button).onClick:AddListener( function() self:on_click_toggle2() end)

    self.right_selected_bg:SetActive(false)
    self.left_selected_bg:SetActive(false)


    self.PerfectCon_BtnBuild = self.PerfectCon:FindChild("BtnBuild").gameObject
    self.PerfectCon_BtnBuil_buy_btn = BuyButton.New(self.PerfectCon_BtnBuild, TI18N("锻造"))
    self.PerfectCon_BtnBuil_buy_btn.key = "EquipStrengthPerfect"
    self.PerfectCon_BtnBuil_buy_btn.protoId = 10600
    self.PerfectCon_BtnBuil_buy_btn:Set_btn_img("DefaultButton3")
    self.PerfectCon_BtnBuil_buy_btn:Show()

    self.BuildCon = self.BottomCon:FindChild("BuildCon")
    self.BuildCon_BtnBuild = self.BuildCon:FindChild("BtnBuild").gameObject
    self.BuildCon_BtnBuild_buy_btn = BuyButton.New(self.BuildCon_BtnBuild, TI18N("锻造"))
    self.BuildCon_BtnBuild_buy_btn.key = "EquipStrengthPerfect2"
    self.BuildCon_BtnBuild_buy_btn.protoId = 10603
    self.BuildCon_BtnBuild_buy_btn:Set_btn_img("DefaultButton3")
    self.BuildCon_BtnBuild_buy_btn:Show()

    self.RebuildRewardCon = self.BuildCon:FindChild("RebuildRewardCon")
    self.RebuildRewardCon_btn = self.RebuildRewardCon:GetComponent(Button)

--    self.RebuildRewardCon_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
--    self.RebuildRewardCon_effect.transform:SetParent(self.RebuildRewardCon)
--    self.RebuildRewardCon_effect.transform.localRotation = Quaternion.identity
--    Utils.ChangeLayersRecursively(self.RebuildRewardCon_effect.transform, "UI")
--    self.RebuildRewardCon_effect.transform.localScale = Vector3(2.2, 0.7, 1)
--    self.RebuildRewardCon_effect.transform.localPosition = Vector3(-60, -19, -400)
--    self.RebuildRewardCon_effect:SetActive(false)



    self.RebuildRewardCon_ImgProp = self.RebuildRewardCon:FindChild("ImgProp")
    self.RebuildRewardCon_ImgPropBar = self.RebuildRewardCon_ImgProp:FindChild("ImgPropBar")

    self.RebuildRewardCon_TxtProg = self.RebuildRewardCon_ImgProp:FindChild("TxtProg"):GetComponent(Text)

    self.imggo = self.RebuildRewardCon:FindChild("ImgReward").gameObject

    self.TxtDeadLine = self.BuildCon:FindChild("TxtDeadline"):GetComponent(Text)
    self.BtnTips = self.BuildCon:FindChild("BtnLook"):GetComponent(Button)
    self.BtnTips.onClick:AddListener(
    function ()
        self:ShowTips();
        --TipsManager.Instance.model:OpenChancePanel(205)
    end)
    if self.imgLoader == nil then
        self.imggo = self.RebuildRewardCon:FindChild("ImgReward").gameObject
        self.imgLoader = SingleIconLoader.New(self.imggo)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 22530)


    self.RebuildRewardCon.gameObject:SetActive(false)

    self.RebuildRewardCon_btn.onClick:AddListener( function()
        self:on_click_reward()
    end )

    self.bottom_left_tanhao_btn.gameObject:SetActive(false)
    self.bottom_left_tanhao_btn.onClick:AddListener( function()
        local tips = { }
        table.insert(tips, TI18N("由于当前装备提升后<color='#ffff00'>小于世界等级</color>，打造所需<color='#ffff00'>星月石</color>个数降低了"))
        TipsManager.Instance:ShowText( { gameObject = self.bottom_left_tanhao_btn.gameObject, itemData = tips })
    end )

    -- 为所有的slot_con创建slot
    self.top_left_slot = self:create_equip_slot(self.top_left_SlotCon)
    self.top_right_slot = self:create_equip_slot(self.top_right_SlotCon)
    self.bottom_slot_1 = self:create_equip_slot(self.bottom_left_SlotCon1)
    self.bottom_slot_2 = self:create_equip_slot(self.bottom_left_SlotCon2)
    self.bottom_slot_3 = self:create_equip_slot(self.bottom_left_SlotCon3)
    self.perfect_slot = self:create_equip_slot(self.PerfectCon_SlotCon)
    self.hero_slot = self:create_equip_slot(self.PerfectCon_Slot2Con)

    -- 为所有按钮添加监听器逻辑
    self.on_click_perfect_build = function()
        self:on_click_perfect_build_btn()
    end
    self.on_click_build = function()
        self:on_click_build_btn()
    end
    self.on_bottom_prices_back = function(prices)

        self:on_price_back(prices)
    end

    self.top_right_BtnSave.onClick:AddListener( function() self:on_click_save_btn() end)


    self:OnShow()

    self.ButtonLook.onClick:AddListener( function()
        if self.parent.cur_tab_index == 1 then
            -- 锻造
            self.top_right_slot.itemData.show_extra = true
            self.top_right_slot:ClickSelf()
        elseif self.parent.cur_tab_index == 2 then
            -- 重铸
            self.top_left_slot.itemData.show_extra = true
            self.top_left_slot:ClickSelf()
        end
    end )

    self.has_init = true

    if self.parent.cur_left_selected_data ~= nil then
        self:update_info(self.parent.cur_left_selected_data)
    end


    -----------------------装备等级切换逻辑
    self.ToggleBtnTanHao.onClick:AddListener( function()
        local tips = { }
        table.insert(tips, string.format("1.%s<color='#ffff00'>%s%s</color>%s", TI18N("装备锻造至"), EquipStrengthManager.Instance.model.equip_can_switch_lev, TI18N("级"), TI18N("后，可选择切换到上一级属性")))
        table.insert(tips, string.format("2.%s<color='#ffff00'>%s</color>", TI18N("锻造、重铸、转换、洗炼操作需"), TI18N("切换至高级装备")))
        table.insert(tips, TI18N("3.宝石、强化、精炼不受切换装备影响"))
        TipsManager.Instance:ShowText( { gameObject = self.ToggleBtnTanHao.gameObject, itemData = tips })

    end )

    self.cur_switch_index = 2
    self.ToggleConLastLevBtn.onClick:AddListener( function()
        self:on_switch_equip(1)
    end )
    self.ToggleConCurLevBtn.onClick:AddListener( function()
        self:on_switch_equip(2)
    end )
    self.LastToggleTxt.text = ""
    self.CurToggleTxt.text = ""

    self.LastCheckmark.gameObject:SetActive(false)
    self.CurCheckmark.gameObject:SetActive(true)

    -- 未开启
    self.ToggleCon.gameObject:SetActive(false)
    -- 调整左右框的高度
    self:switch_top_left_right_height(2)

    self.PerfectCon_BtnBuil_buy_btn.clickListener = function() self:OnClickBuild() end
end

-- 点击礼包
function EquipStrengthFirstBuild:on_click_reward()
    if EquipStrengthManager.Instance.model.equip_reset_val >= EquipStrengthManager.Instance.model.max_equip_reset_val then
        EquipStrengthManager.Instance:request10613()
    else
        self.Rebuild_ImgTip.gameObject:SetActive(true)
    end
end

-- 切换装备状态
function EquipStrengthFirstBuild:on_switch_equip(_index)
    if self.cur_switch_index == 2 and _index == 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已切换至当前状态，无需再切换"))
        return
    end

    if self.cur_switch_index == 1 and _index == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已切换至上一级状态，无需再切换"))
        return
    end

    local confirm_func = function()
        self.cur_switch_index = _index

        if _index == 2 then
            self.LastCheckmark.gameObject:SetActive(false)
            self.CurCheckmark.gameObject:SetActive(true)
        elseif _index == 1 then
            self.LastCheckmark.gameObject:SetActive(true)
            self.CurCheckmark.gameObject:SetActive(false)
        end

        EquipStrengthManager.Instance:request10621(self.cur_selected_data.id)
    end


    if _index == 1 then
        local str1 = string.format("%s<color='#ffff00'>%s%s</color>%s<color='#2fc823'>%s</color>%s", TI18N("是否"), TI18N("切换至"), self.cur_selected_data.lev - 10, TI18N("级装备？（注意：锻造、重铸、转换、洗炼操作需"), TI18N("  切换至高级装备"), TI18N("，宝石、强化、精炼不受切换影响）"))

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str1
        data.sureLabel = TI18N("切换装备")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = confirm_func
        NoticeManager.Instance:ConfirmTips(data)
    else
        confirm_func()
    end
end


--------------------------------初始化逻辑
-- 为每个武器创建slot
function EquipStrengthFirstBuild:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
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

-- 对slot设置数据
function EquipStrengthFirstBuild:set_stone_slot_data(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, { _nobutton = true })
    else
        slot:SetAll(cell, { nobutton = _nobutton })
    end
end


---------------------------------所有监听器逻辑
-- 完美打造按钮点击
function EquipStrengthFirstBuild:on_click_perfect_build_btn()
    if self.PerfectCon_Toggle.isOn then
        local use_hero_paper = 0
        if self.PerfectCon_Toggle2.isOn then
            use_hero_paper = 1
        end
        EquipStrengthManager.Instance:request10600(self.cur_selected_data.id, 1, use_hero_paper)
    else
        -- 弹出确认框
        EquipStrengthManager.Instance:request10600(self.cur_selected_data.id, 0)
    end
end

-- 普通打造按钮点击
function EquipStrengthFirstBuild:on_click_build_btn()
    if self.parent.cur_tab_index == 1 then
        -- 锻造
        local use_hero_paper = 0
        if self.PerfectCon_Toggle2.isOn then
            use_hero_paper = 1
        end
        EquipStrengthManager.Instance:request10600(self.cur_selected_data.id, 0, use_hero_paper)
    elseif self.parent.cur_tab_index == 2 then
        -- 重铸
        EquipStrengthManager.Instance:request10603(self.cur_selected_data.id, self.cur_selected_data.reset_attr)
    end
end

-- 保存按钮点击
function EquipStrengthFirstBuild:on_click_save_btn()
    if self.parent.cur_tab_index == 1 then
        EquipStrengthManager.Instance:request10601(self.cur_selected_data.id)
    elseif self.parent.cur_tab_index == 2 then
        EquipStrengthManager.Instance:request10608(self.cur_selected_data.id)
    end
end

-- 点击toggle
function EquipStrengthFirstBuild:on_click_toggle()
    if self.PerfectCon_Toggle.isOn then
        self.top_right_slot:SetEnchant(self.cur_selected_data.enchant)
    else
        self.top_right_slot:SetEnchant(self.cur_selected_data.enchant - 1)
    end
    self:update_bottom_con()
end

-- 点击锻造
function EquipStrengthFirstBuild:OnClickBuild()
    local enough = nil
    local list = nil
    enough, list = self:JudgeForItem()

    local isAutoBuy = BuyManager.Instance:IsAutoBuy(self.PerfectCon_BtnBuil_buy_btn.key, list)

    if enough or isAutoBuy then
        self:JudgeForPerfect()
    else
        self.PerfectCon_BtnBuil_buy_btn:OnClickTrue()
    end
end

function EquipStrengthFirstBuild:JudgeForItem()
    local list = {}
    local enough = true
    for base_id,tab in pairs(self.PerfectCon_BtnBuil_buy_btn.baseidToNeed or {}) do
        if tab ~= nil then
            enough = enough and (BackpackManager.Instance:GetItemCount(base_id) >= tab.need)
            table.insert(list, base_id)
        end
    end
    return enough, list
end

function EquipStrengthFirstBuild:JudgeForPerfect()
    if self.PerfectCon_Toggle.isOn then
        self:JudgeForHeroStore()
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("该装备已经达到<color='#ffff00'>强化+7</color>以上，选择普通强化锻造将有几率使强化等级下降，是否继续？")
        data.sureLabel = TI18N("确 认")
        data.cancelLabel = TI18N("完美打造")
        data.cancelCallback = function() self.PerfectCon_Toggle.isOn = true self:update_bottom_con() NoticeManager.Instance:FloatTipsByString(TI18N("已勾选完美打造，锻造后强化等级不变{face_1,25}")) end
        data.sureCallback = function() LuaTimer.Add(300, function() self:JudgeForHeroStore() end) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function EquipStrengthFirstBuild:JudgeForHeroStore()
    if (not self.isNeedHeroStore) or self.PerfectCon_Toggle2.isOn then
        self.PerfectCon_BtnBuil_buy_btn:OnClickTrue()
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("该装备的英雄宝石等级较高，锻造时若不使用<color='#ffff00'>%s</color>，英雄宝石将<color='#ffff00'>损失一部分经验</color>，是否继续？"), DataItem.data_get[20406].name)
        data.sureLabel = TI18N("确 认")
        data.cancelLabel = TI18N("使用卷轴")
        data.cancelCallback = function() LuaTimer.Add(300, function() self:SureUseHero() end) end
        data.sureCallback = function() LuaTimer.Add(300, function() self.PerfectCon_BtnBuil_buy_btn:OnClickTrue() end) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

-- 英雄卷轴 20406
function EquipStrengthFirstBuild:on_click_toggle2()
    if not self.PerfectCon_Toggle2.isOn then
        -- local data = NoticeConfirmData.New()
        -- data.type = ConfirmData.Style.Normal
        -- data.content = string.format(TI18N("锻造时使用1张<color='#ffff00'>%s</color>可保持装备中的<color='#ffff00'>英雄宝石等级</color>不掉落，是否继续？"), DataItem.data_get[20406].name)
        -- data.sureLabel = TI18N("确定")
        -- data.cancelLabel = TI18N("取消")
        -- -- data.sureCallback = function() LuaTimer.Add(10, function() self:SureUseHero() end) end
        -- data.sureCallback = function() self:SureUseHero() end
        -- data.cancelCallback = function() self:CancelHero() end
        -- NoticeManager.Instance:ConfirmTips(data)
        self:SureUseHero()
    else
        self:CancelHero()
    end
end

function EquipStrengthFirstBuild:SureUseHero()
    self.PerfectCon_Toggle2.isOn = true
    self:update_bottom_con()
    -- if BackpackManager.Instance:GetItemCount(20406) == 0 then
    --     local data = NoticeConfirmData.New()
    --     data.type = ConfirmData.Style.Normal
    --     data.content = string.format(TI18N("<color='#ffff00'>英雄卷轴</color>不足，可消耗{assets_1,%s,%s}购买，是否继续？"), 90002, shop.price)
    --     data.sureLabel = string.format(TI18N("%s{assets_2,90002}购买"), shop.price)
    --     data.cancelLabel = TI18N("取消")
    --     data.sureCallback = function() self:SureBuyHero(shop) end
    --     data.cancelCallback = function() self:CancelHero() end
    --     NoticeManager.Instance:ConfirmTips(data)
    -- else
    --     self.PerfectCon_Toggle2.isOn = true
    -- end
end

function EquipStrengthFirstBuild:CancelHero()
    self.PerfectCon_Toggle2.isOn = false
    self:update_bottom_con()
end

function EquipStrengthFirstBuild:SureBuyHero(shop)
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.buy_listener)
    EventMgr.Instance:AddListener(event_name.shop_buy_result, self.buy_listener)
    self.isBuy = true
    ShopManager.Instance:send11303(shop.id, 1)
end

function EquipStrengthFirstBuild:OnBuyResult(result)
    EventMgr.Instance:RemoveListener(event_name.shop_buy_result, self.buy_listener)
    if result == 1 then
        self.PerfectCon_Toggle2.isOn = true
    else
        self.PerfectCon_Toggle2.isOn = false
    end
end

function EquipStrengthFirstBuild:ShowNotice()
    self.idToNumPrice = {
        [self.quickBuyId] =
        {
            asset = 90002,
            num = 1,
            money = ShopManager.Instance.itemPriceTab[28].price,
            assets = 90002,
            assets_num = ShopManager.Instance.itemPriceTab[28].price,
            source = MarketEumn.SourceType.Shop
        }
    }
    self.baseidToNeed = {
        [self.quickBuyId] = { need = 1 }
    }

    if self.notify == nil then
        self.notify = BuyNotify.New(self.idToNumPrice, self.baseidToNeed)
    else
        self.notify.content = ""
        if self.notify.loading ~= true then
            self.notify:ResetData(self.idToNumPrice, self.baseidToNeed)
        end
    end
    self.notify:Show()
end

---------------------------------各种更新逻辑
-- 总更新接口，父容器调用或协议事件调用
function EquipStrengthFirstBuild:update_info(data, is_item_update)
    if self.has_init == false then
        return
    end
    self.cur_selected_data = data
    self:update_top_left(false, is_item_update)

    -- self:update_bottom_con()
    self:update_normal_perfect(is_item_update)

    -- self.parent.cur_tab_index == 1 --锻造
    -- self.parent.cur_tab_index == 2 --重铸
    EquipStrengthManager.Instance:request10609(self.cur_selected_data.id, self.parent.cur_tab_index)
end

-- 更新单个装备
function EquipStrengthFirstBuild:update_single_info(equips, _is_socket)
    if self.has_init == true and self.cur_selected_data ~= nil then
        local new_data = BackpackManager.Instance.equipDic[self.cur_selected_data.id]
        if new_data ~= nil then
            self.cur_selected_data = new_data
            self:update_top_left(_is_socket)
            self:update_bottom_con()
            self:update_top_right()
            self:update_normal_perfect(_is_socket)
        end
    end
end

-- 更新是否显示装备上一级切换的逻辑
function EquipStrengthFirstBuild:update_swtich_last_lev(data)
    if self.cur_selected_data.id == data.id then
        -- 开启
        self.ToggleCon.gameObject:SetActive(true)
        self.LastToggleTxt.text = string.format("%s%s%s", TI18N("切换到"), self.cur_selected_data.lev - 10, TI18N("级装备"))
        self.CurToggleTxt.text = string.format("%s%s%s", TI18N("切换到"), self.cur_selected_data.lev, TI18N("级装备"))

        if data.back_lev == 0 then
            -- 没数据
            self.ToggleCon.gameObject:SetActive(false)
            -- 调整左右框的高度
            self:switch_top_left_right_height(2)
        elseif data.back_lev == data.now_lev then
            -- 还没有切
            self.cur_switch_index = 2
            self.LastCheckmark.gameObject:SetActive(false)
            self.CurCheckmark.gameObject:SetActive(true)
            -- 调整左右框的高度
            self:switch_top_left_right_height(1)
        else
            -- 已经切
            self.cur_switch_index = 1
            self.LastCheckmark.gameObject:SetActive(true)
            self.CurCheckmark.gameObject:SetActive(false)
            -- 调整左右框的高度
            self:switch_top_left_right_height(1)
        end
    end
end


-- 更新左上内容
function EquipStrengthFirstBuild:update_top_left(_is_socket, is_item_update)
    -- 根据当前选中的装备确定是否可以切换
    if self.parent.cur_tab_index == 1 then
        if self.cur_selected_data.lev >= EquipStrengthManager.Instance.model.equip_can_switch_lev then
            -- 开启
            if (_is_socket == nil or _is_socket == false) and(is_item_update == false or is_item_update == nil) then
                -- 不是协议触发改变
                EquipStrengthManager.Instance:request10620(self.cur_selected_data.id)
            end
        else
            -- 未开启
            self.ToggleCon.gameObject:SetActive(false)
            -- 调整左右框的高度
            self:switch_top_left_right_height(2)
        end
    elseif self.parent.cur_tab_index == 2 then
        -- 重铸不显示
        self.ToggleCon.gameObject:SetActive(false)
        self:switch_top_left_right_height(2)
        if (_is_socket == nil or _is_socket == false) and(is_item_update == false or is_item_update == nil) then
            if EquipStrengthManager.Instance.model.equip_spare_attr_list[self.cur_selected_data.id] == nil then
                -- 没有这个装备的切换数据则请求一下
                EquipStrengthManager.Instance:request10620(self.cur_selected_data.id)
            end
        end
    end




    local base_data = DataItem.data_get[self.cur_selected_data.base_id]

    local temp_lev = EquipStrengthManager.Instance.model:check_equip_is_last_lev(self.cur_selected_data)
    if self.top_left_slot ~= nil then
        local copy_equip_data = nil
        for k, v in pairs(BackpackManager.Instance.equipDic) do
            if v.id == self.cur_selected_data.id then
                copy_equip_data = BaseUtils.copytab(v)
                break
            end
        end
        if copy_equip_data ~= nil then
            copy_equip_data.lev = temp_lev
            self.top_left_slot:ShowEnchant(true)
            self.top_left_slot:SetAll(copy_equip_data, { nobutton = true })
        end
    end
    if base_data == nil then
        return
    end

    local temp_name_str = ColorHelper.color_item_name(base_data.quality, base_data.name)
    for i = 1, #self.cur_selected_data.extra do
        if self.cur_selected_data.extra[i].name == 9 then
            local temp_id = self.cur_selected_data.extra[i].value
            temp_name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
            break
        end
    end

    self.top_left_TxtName.text = temp_name_str

    self.top_left_TxtLev.text = string.format(TI18N("%s级%s\n<color='#ffffff'>评分:%s</color>"), temp_lev, BackpackEumn.ItemTypeName[self.cur_selected_data.type], BaseUtils.EquipPoint(self.cur_selected_data.attr))

    for i = 1, #self.top_left_txtVal_list do
        self.top_left_txtVal_list[i].text = ""
    end

    for i = 1, #self.top_left_txtstrength_list do
        self.top_left_txtstrength_list[i].text = ""
    end

    for i = 1, #self.top_right_txt_strength_list do
        self.top_right_txt_strength_list[i].text = ""
    end


    self.left_base_attr = { }
    self.strength_base_attr = { }
    local extr_attr = { }
    local effect_attr = { }
    local wing_attr = { }
    local zero_speed = false
    for i = 1, #self.cur_selected_data.attr do
        local attr_v = self.cur_selected_data.attr[i]
        if attr_v.type == GlobalEumn.ItemAttrType.base then
            table.insert(self.left_base_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.enchant then
            self.strength_base_attr[attr_v.name] = attr_v
        elseif attr_v.type == GlobalEumn.ItemAttrType.extra then
            table.insert(extr_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.effect then
            table.insert(effect_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.wing_skill then
            table.insert(wing_attr, attr_v)
        elseif attr_v.type == GlobalEumn.ItemAttrType.zero_speed then
            zero_speed = true
        end
    end

    table.sort(self.left_base_attr, function(a, b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
    table.sort(effect_attr, function(a, b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

    -- 基础属性
    local extr_index = 1
    for i = 1, #self.left_base_attr do
        local attr_v = self.left_base_attr[i]
        local color = "#0c52b0"
        local strength_str = ""
        if self.strength_base_attr[attr_v.name] ~= nil then
            strength_str = string.format("(+%s)", self.strength_base_attr[attr_v.name].val)
        end
        local val = attr_v.val > 0 and string.format("+%s", attr_v.val) or tostring(attr_v.val)
        self.top_left_txtVal_list[i].text = string.format("<color='%s'>%s</color><color='#ACE92A'>%s</color><color='#b031d5'>%s</color>", color, KvData.attr_name[attr_v.name], val, strength_str)
        extr_index = i + 1
    end

    -- 额外属性
    local extr_val = ""
    for i = 1, #extr_attr do
        local attr_v = extr_attr[i]
        local color = "#23F0F7"
        local val = attr_v.val > 0 and string.format("+%s", attr_v.val) or tostring(attr_v.val)
        extr_val = string.format("%s<color='%s'>%s%s </color>", extr_val, color, KvData.attr_name[attr_v.name], val)
    end

    if extr_val ~= "" then
        self.top_left_txtVal_list[extr_index].text = extr_val
        extr_index = extr_index + 1
    end

    -- 特效属性
    for i, v in ipairs(effect_attr) do
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_skill_effect[v.val]
            if skillData == nil then
                skillData = DataSkill.data_skill_role[string.format("%s_%s", v.val, RoleManager.Instance.RoleData.lev)]
                str = string.format("真·%s", skillData.name)
            else
                str = skillData.name
            end
        else
            str = KvData.attr_name[v.name]
        end
        self.top_left_txtVal_list[extr_index].text = string.format(TI18N("<color='#b031d5'>特效 %s</color>"), str)
        extr_index = extr_index + 1
    end

    -- 翅膀特技属性
    for i, v in ipairs(wing_attr) do
        local str = ""
        if v.name == 100 then
            -- 技能
            local skillData = DataSkill.data_wing_skill[string.format("%s_1", v.val)]
            str = skillData.name
        else
            str = KvData.attr_name[v.name]
        end
        self.top_left_txtVal_list[extr_index].text = string.format(TI18N("<color='#b031d5'>特技 %s</color>"), str)
        extr_index = extr_index + 1
    end

    if zero_speed then
        if self.top_left_txtVal_list[extr_index] then
            self.top_left_txtVal_list[extr_index].text = TI18N("<color='#ffff00'>万年玄冰</color>：攻速已降为0")
        end
        extr_index = extr_index + 1
        if self.top_left_txtVal_list[extr_index] then
            self.top_left_txtVal_list[extr_index].text = TI18N("重铸或升级装备可恢复")
        end
        extr_index = extr_index + 1
    end
end

-- 播放特效逻辑
function EquipStrengthFirstBuild:do_play_effect()
    self.curr_effect_go = nil
    if self.parent.cur_tab_index == 1 then
        -- 锻造
        self.curr_effect_go = self.top_left_effect

        if self.cur_selected_data.enchant < 7 then
            self.top_right_slot:SetEnchant(self.cur_selected_data.enchant)
        else
            if self.PerfectCon_Toggle.isOn then
                self.top_right_slot:SetEnchant(self.cur_selected_data.enchant)
            else
                self.top_right_slot:SetEnchant(self.cur_selected_data.enchant - 1)
            end
        end
    else
        -- 重铸
        self.curr_effect_go = self.top_right_effect
    end
    if self.is_playing_effect == false then
        if self.build_reset_id ~= EquipStrengthManager.Instance.model.build_reset_id then
            self.is_playing_effect = true
            self.top_right_effect:SetActive(false)
            self.top_left_effect:SetActive(false)
            self.curr_effect_go:SetActive(true)

            LuaTimer.Add(1200, function()
                self.is_playing_effect = false
                if not BaseUtils.is_null(self.curr_effect_go) then
                    self.curr_effect_go:SetActive(false)
                end
            end )


            if self.parent.cur_tab_index ~= 1 then
                -- 重铸
                if EquipStrengthManager.Instance.model:check_show_rebuild_reward() and self.cur_selected_data.lev >= 70 then
                    -- 飞特效
--                    self.fly_effect.transform.localPosition = Vector3(43.2, 147, -100)
--                    self.fly_effect:SetActive(true)
--                    Tween.Instance:MoveLocal(self.fly_effect, Vector3(122.5, -119.6, -100), 1, function() end, LeanTweenType.linear)
--                    self.fly_effect_time = LuaTimer.Add(1500, function() self.fly_effect:SetActive(false) end)
                end
            end
        end
        self.build_reset_id = EquipStrengthManager.Instance.model.build_reset_id
    else
        self.is_playing_effect = false
        if not BaseUtils.is_null(self.curr_effect_go) then
            self.curr_effect_go:SetActive(false)
        end
    end
end

-- 更新右上内容
function EquipStrengthFirstBuild:update_top_right()
    local attrs = nil

    self.top_right_TxtBottomDesc:SetActive(true)
    self.top_right_TxtDescLev:SetActive(false)
    self.top_right_txtMaxLev:SetActive(false)

    self.top_right_TxtDesc:SetActive(true)

    self.bottom_left_tanhao_btn.gameObject:SetActive(false)

    local recommand_cfg_data = DataEqm.data_recommand_attr[RoleManager.Instance.RoleData.classes]
    local str = string.format("%s<color='#23F0F7'>%s", TI18N("推荐："), recommand_cfg_data.attr[1].attr_name)
    for i = 2, #recommand_cfg_data.attr do
        str = string.format("%s、%s", str, recommand_cfg_data.attr[i].attr_name)
    end
    self.top_right_TxtRecommand.text = string.format("%s</color>", str)

    if self.parent.cur_tab_index == 1 then
        -- 锻造
        self.top_right_title_txt.text = TI18N("打造预览")
        attrs = self.cur_selected_data.backup_attr
    elseif self.parent.cur_tab_index == 2 then
        -- 重铸
        self.top_right_title_txt.text = TI18N("重铸预览")
        attrs = self.cur_selected_data.reset_attr
    end

    self.top_right_TxtName.text = ""
    self.top_right_TxtLev.text = ""
    for i = 1, #self.top_right_TxtVal_list do
        self.top_right_TxtVal_list[i].text = ""
    end

    -- 隐藏所有箭头
    for i = 1, #self.top_right_arrow_list do
        self.top_right_arrow_list[i]:SetActive(false)
    end

    if self.parent.cur_tab_index == 2 then
        -- 重铸
        if self.cur_selected_data.lev < 40 then
            self.top_right_TxtDescLev:SetActive(true)
            self.top_right_TxtDesc:SetActive(false)
            return
        end
    end

    self:do_play_effect()

    self.BuildCon.gameObject:SetActive(false)
    local enchantAddList = { }

    if attrs == nil or #attrs == 0 then
        self.top_right_TxtRecommand.gameObject:SetActive(true)
        self.top_right_BtnSave.gameObject:SetActive(false)

        -- 没有数据，预览
        local base_attr = { }
        local extr_attr = { }

        local cfg_data = nil
        local next_cfg_base_data = nil
        local next_lev = 0
        if self.parent.cur_tab_index == 1 then
            -- 锻造
            cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
            if cfg_data == nil then
                -- 没有数据，已经到最高等级
                self.top_right_txtMaxLev:SetActive(true)
                local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
                local cfg_base_data = BaseUtils.copytab(DataItem.data_get[self.cur_selected_data.base_id])
                local lev_str = string.format(TI18N("%s级%s\n<color='#ffffff'>评分:%s</color>"), self.cur_selected_data.lev, BackpackEumn.ItemTypeName[self.cur_selected_data.type], BaseUtils.EquipPoint(self.cur_selected_data.attr))
                if self.cur_selected_data.extra ~= nil then
                    cfg_base_data.extra = self.cur_selected_data.extra
                end
                self:set_stone_slot_data(self.top_right_slot, cfg_base_data)

                local temp_name_str = ColorHelper.color_item_name(cfg_base_data.quality, cfg_base_data.name)
                for i = 1, #self.cur_selected_data.extra do
                    if self.cur_selected_data.extra[i].name == 9 then
                        local temp_id = self.cur_selected_data.extra[i].value
                        temp_name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
                        break
                    end
                end

                self.top_right_TxtName.text = temp_name_str
                self.top_right_TxtLev.text = lev_str
                return
            end
            next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
            next_lev = cfg_data.next_lev
        else
            -- 重铸
            next_cfg_base_data = DataItem.data_get[self.cur_selected_data.base_id]
            next_lev = math.floor(self.cur_selected_data.lev / 10) * 10
        end

        local temp_attr_list = EquipStrengthManager.Instance.model:get_eqm_prop_by_type_lev(string.format("%s_%s", next_cfg_base_data.type, next_lev))
        table.sort(temp_attr_list, function(a, b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

        local extr_index = 1
        for i = 1, #temp_attr_list do
            local v = temp_attr_list[i]
            if v.val > 0 then
                local color = "#0c52b0"
                local val_1 = tostring(math.floor(v.val * 0.8))
                local val_2 = tostring(math.floor(v.val * 1.05))
                self.top_right_TxtVal_list[extr_index].text = string.format("<color='%s'>%s</color><color='#ACE92A'>+%s~</color><color='#ACE92A'>%s</color>", color, KvData.attr_name[v.name], val_1, val_2)
                extr_index = extr_index + 1
            end
        end

        self.top_right_TxtVal_list[extr_index].text = string.format("<color='#23F0F7'>%s+??</color>", TI18N("附加属性"))

        if self.parent.cur_tab_index == 2 then
            if self.top_right_TxtVal_list[extr_index + 1] ~= nil then
                self.top_right_TxtVal_list[extr_index + 1].text = string.format("<color='#b031d5'>%s+??</color>", TI18N("特效"))
            end
        end
        self.top_right_title_txt.text = TI18N("打造预览")
        self.right_selected_bg:SetActive(false)
        self.BuildCon.gameObject:SetActive(true)
    else
        -- 有数据不是预览
        self.PerfectCon.gameObject:SetActive(false)
        self.BuildCon.gameObject:SetActive(true)

        table.sort(attrs, function(a, b)
            return a.name < b.name
        end )

        self.right_base_attr = { }
        local extr_attr = { }
        local effect_attr = { }
        self.strength_base_attr = { }
        local enchant_props = { }
        local wing_attr = { }
        for i = 1, #attrs do
            local attr_v = attrs[i]
            if attr_v.type == GlobalEumn.ItemAttrType.base then
                table.insert(self.right_base_attr, attr_v)
            elseif attr_v.type == GlobalEumn.ItemAttrType.enchant then
                self.strength_base_attr[attr_v.name] = attr_v
            elseif attr_v.type == GlobalEumn.ItemAttrType.extra then
                table.insert(extr_attr, attr_v)
            elseif attr_v.type == GlobalEumn.ItemAttrType.effect then
                table.insert(effect_attr, attr_v)
            elseif attr_v.type == GlobalEumn.ItemAttrType.wing_skill then
                table.insert(wing_attr, attr_v)
            end
        end

        table.sort(self.right_base_attr, function(a, b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)
        table.sort(effect_attr, function(a, b) return GlobalEumn.AttrSort[a.name] < GlobalEumn.AttrSort[b.name] end)

        -- 强化加成
        local cur_percent_key = string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.enchant)
        local cur_percents = { }
        if DataEqm.data_enchant[cur_percent_key] ~= nil then
            cur_percents = DataEqm.data_enchant[cur_percent_key].target
        end
        for i = 1, #cur_percents do
            local cur_percent_data = cur_percents[i]
            if cur_percent_data ~= nil then
                -- 避免下一等级有，当前等级没有
                enchant_props[cur_percent_data.effect_type] = { name = cur_percent_data.effect_type, val = cur_percent_data.val }
            end
        end

        -- 基础属性
        local extr_index = 1
        for i = 1, #self.right_base_attr do
            local attr_v = self.right_base_attr[i]
            local temp_val = attr_v.val
            local strength_str = ""
            if enchant_props[attr_v.name] ~= nil then
                if enchant_props[attr_v.name].val ~= 0 then
                    local add_val = 0
                    if BackpackEumn.IsEnchantBreak(self.cur_selected_data) then
                        add_val = Mathf.Round((0.02 + enchant_props[attr_v.name].val / 1000) * temp_val)
                    else
                        add_val = Mathf.Round((enchant_props[attr_v.name].val / 1000) * temp_val)
                    end
                    strength_str = string.format("(+%s)", add_val)
                    local t = { }
                    t.type = GlobalEumn.ItemAttrType.enchant
                    t.flag = 0
                    t.name = attr_v.name
                    t.val = add_val
                    table.insert(enchantAddList, t)
                end
            end

            local color = "#0c52b0"
            local val = temp_val > 0 and string.format("+%s", temp_val) or tostring(temp_val)

            self.top_right_TxtVal_list[i].text = string.format("<color='%s'>%s</color><color='#ACE92A'>%s</color><color='#b031d5'>%s</color>", color, KvData.attr_name[attr_v.name], val, strength_str)

            extr_index = i + 1
        end

        if self.parent.cur_tab_index == 2 then
            -- 重铸就要显示箭头
            for i = 1, #self.right_base_attr do
                local attr_v = self.right_base_attr[i]
                local left_attr_v = self.left_base_attr[i]
                if attr_v ~= nil and left_attr_v ~= nil then
                    if attr_v.val > left_attr_v.val then
                        self.top_right_arrow_list[i]:SetActive(true)
                        local arrow_x = self.top_right_TxtVal_list[i].preferredWidth
                        local ap = self.top_right_arrow_list[i].transform:GetComponent(RectTransform).anchoredPosition
                        self.top_right_arrow_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2(arrow_x + 20, ap.y)
                    end
                end
            end
        end

        -- 额外属性
        local extr_val = ""
        for i = 1, #extr_attr do
            local attr_v = extr_attr[i]
            local color = "#23F0F7"
            local val = attr_v.val > 0 and string.format("+%s", attr_v.val) or tostring(attr_v.val)
            extr_val = string.format("%s<color='%s'>%s%s </color>", extr_val, color, KvData.attr_name[attr_v.name], val)
        end

        if extr_val ~= "" then
            self.top_right_TxtVal_list[extr_index].text = extr_val
            extr_index = extr_index + 1
        end

        -- 特效属性
        for i, v in ipairs(effect_attr) do
            local str = ""
            if v.name == 100 then
                -- 技能
                local skillData = DataSkill.data_skill_effect[v.val]
                if skillData == nil then
                    skillData = DataSkill.data_skill_role[string.format("%s_%s", v.val, RoleManager.Instance.RoleData.lev)]
                    str = string.format("真·%s", skillData.name)
                else
                    str = skillData.name
                end
            else
                str = KvData.attr_name[v.name]
            end
            self.top_right_TxtVal_list[extr_index].text = string.format(TI18N("<color='#b031d5'>特效 %s</color>"), str)
            extr_index = extr_index + 1
        end

        -- 翅膀特技属性
        for i, v in ipairs(wing_attr) do
            local str = ""
            if v.name == 100 then
                -- 技能
                local skillData = DataSkill.data_wing_skill[string.format("%s_1", v.val)]
                str = skillData.name
            else
                str = KvData.attr_name[v.name]
            end
            self.top_right_TxtVal_list[extr_index].text = string.format(TI18N("<color='#b031d5'>特技 %s</color>"), str)
            extr_index = extr_index + 1
        end

        self.top_right_TxtBottomDesc:SetActive(false)
        self.top_right_TxtRecommand.gameObject:SetActive(false)
        self.top_right_BtnSave.gameObject:SetActive(true)
        self.top_right_title_txt.text = TI18N("打造属性")
        self.left_selected_bg:SetActive(false)
        self.right_selected_bg:SetActive(true)
    end


    --------------------设置右上部分的slot
    if attrs ~= nil and #attrs ~= 0 then
        attrs = self:GetEquipAttr(self.cur_selected_data.attr, attrs, enchantAddList)
    end

    local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
    local next_cfg_base_data = BaseUtils.copytab(DataItem.data_get[self.cur_selected_data.base_id])
    local val = BaseUtils.EquipPoint(attrs)
    local lev_str = string.format(TI18N("%s级%s\n<color='#ffffff'>评分:%s</color>"), self.cur_selected_data.lev, BackpackEumn.ItemTypeName[self.cur_selected_data.type], val == 0 and "???" or val)
    if cfg_data ~= nil and self.parent.cur_tab_index == 1 then
        -- 不为空且是锻造
        next_cfg_base_data = BaseUtils.copytab(DataItem.data_get[cfg_data.next_id])
        lev_str = string.format(TI18N("%s级%s\n<color='#ffffff'>评分:%s</color>"), cfg_data.next_lev, BackpackEumn.ItemTypeName[self.cur_selected_data.type], BaseUtils.EquipPoint(self.cur_selected_data.attr))
    end
    if self.cur_selected_data.extra ~= nil then
        next_cfg_base_data.extra = BaseUtils.copytab(self.cur_selected_data.extra)
    end
    next_cfg_base_data.attr = attrs
    self:set_stone_slot_data(self.top_right_slot, next_cfg_base_data)

    local temp_name_str = ColorHelper.color_item_name(next_cfg_base_data.quality, next_cfg_base_data.name)
    for i = 1, #self.cur_selected_data.extra do
        if self.cur_selected_data.extra[i].name == 9 then
            local temp_id = self.cur_selected_data.extra[i].value
            temp_name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
            break
        end
    end
    self.top_right_TxtName.text = temp_name_str
    self.top_right_TxtLev.text = lev_str
end

-- 更新底部内容
function EquipStrengthFirstBuild:update_bottom_con()

    self.bottom_left_Slot1.gameObject:SetActive(false)
    self.bottom_left_Slot2.gameObject:SetActive(false)
    self.bottom_left_Slot3.gameObject:SetActive(false)
    self.bottom_left_txtMaxLev:SetActive(false)


    self.RebuildRewardCon.gameObject:SetActive(false)
    local py = nil;
    if self.parent.cur_tab_index == 2 then
        py = -20;
    else
        py = 0
    end
    self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, py)
    -- self.BuildCon_BtnBuild:SetActive(false)
    if self.parent.cur_tab_index == 1 then
        -- 锻造

        local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
        -- 40级的装备才会取得到数据
        if cfg_data == nil then
            -- 没有数据，已经到最高等级
            self.bottom_left_txtMaxLev:SetActive(true)
            return
        end

        local need_items = BaseUtils.copytab(cfg_data.need_item)

        local next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
        -- 判断世界等级
        if next_cfg_base_data.lev < RoleManager.Instance.world_lev then
            need_items = BaseUtils.copytab(cfg_data.low_lev_cost)
            -- for i=1,#need_items do
            --     local temp_data = need_items[i]
            --     local temp_low_data = cfg_data.low_lev_cost[i]
            --     if temp_data[1] == temp_low_data[1] then
            --         temp_data[2] = temp_low_data[2]
            --     end
            -- end
        end


        self.bottom_base_data_1 = DataItem.data_get[need_items[1][1]]
        self.bottom_base_data_2 = DataItem.data_get[need_items[2][1]]
        self.bottom_base_data_3 = DataItem.data_get[need_items[3][1]]

        self.bottom_left_Slot1.gameObject:SetActive(true)
        self.bottom_left_Slot2.gameObject:SetActive(true)
        if need_items[3][2] > 0 then
            self.bottom_left_Slot3.gameObject:SetActive(true)
        end

        self:set_stone_slot_data(self.bottom_slot_1, self.bottom_base_data_1, true)
        self:set_stone_slot_data(self.bottom_slot_2, self.bottom_base_data_2, true)
        self:set_stone_slot_data(self.bottom_slot_3, self.bottom_base_data_3, true)

        self.bottom_left_TxtName1.text = self.bottom_base_data_1.name
        self.bottom_left_TxtName2.text = self.bottom_base_data_2.name
        self.bottom_left_TxtName3.text = self.bottom_base_data_3.name

        self.has_num_1 = BackpackManager.Instance:GetItemCount(self.bottom_base_data_1.id)
        self.has_num_2 = BackpackManager.Instance:GetItemCount(self.bottom_base_data_2.id)
        self.has_num_3 = BackpackManager.Instance:GetItemCount(self.bottom_base_data_3.id)

        self.need_num_1 = need_items[1][2]
        self.need_num_2 = need_items[2][2]
        self.need_num_3 = need_items[3][2]

        self.bottom_slot_1:SetNum(self.has_num_1, self.need_num_1)
        self.bottom_slot_2:SetNum(self.has_num_2, self.need_num_2)
        self.bottom_slot_3:SetNum(self.has_num_3, self.need_num_3)

        local buy_list = { }
        if self.need_num_1 > self.has_num_1 then
            buy_list[self.bottom_base_data_1.id] = { need = self.need_num_1 }
        else
            -- 背包里面有足够的
            self.bottom_left_TxtVal1.text = string.format("<color='#13fc60'>%s</color>", "0")
        end

        if self.need_num_2 > self.has_num_2 then
            buy_list[self.bottom_base_data_2.id] = { need = self.need_num_2 }
        else
            -- 背包里面有足够的
            self.bottom_left_TxtVal2.text = string.format("<color='#13fc60'>%s</color>", "0")
        end

        if self.need_num_3 > self.has_num_3 then
            buy_list[self.bottom_base_data_3.id] = { need = self.need_num_3 }
        else
            -- 背包里面有足够的
            self.bottom_left_TxtVal3.text = string.format("<color='#13fc60'>%s</color>", "0")
        end

        if self.PerfectCon_Toggle2.isOn then
            self.PerfectCon_BtnBuil_buy_btn.noGold = true
            self.BuildCon_BtnBuild_buy_btn.noGold = true
            buy_list[20406] = { need = 1 }
        else
            self.PerfectCon_BtnBuil_buy_btn.noGold = false
            self.BuildCon_BtnBuild_buy_btn.noGold = false
        end

        local perfect_buy_list = BaseUtils.copytab(buy_list)
        local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]

        local perfect_data = nil
        if cfg_data ~= nil then
            self:set_build_btn_sate(cfg_data)
            perfect_data = cfg_data.perfect_item[1]
            if perfect_data ~= nil then
                -- 有完美锻造数据，可以进行完美
                if self.PerfectCon_Toggle.isOn then
                    -- 有勾选完美锻造的才把完美锻造的算进去
                    perfect_buy_list[perfect_data[1]] = { need = perfect_data[2] }
                end
            end
        end

        if self.cur_selected_data.enchant < 7 then
            self.BuildCon_BtnBuild_buy_btn:Layout(buy_list, self.on_click_build, self.on_bottom_prices_back)
        elseif perfect_data ~= nil then
            -- 可以进行完美锻造
            self.PerfectCon_BtnBuil_buy_btn:Layout(perfect_buy_list, self.on_click_perfect_build, self.on_bottom_prices_back)
        end
        self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        self.BuildCon:FindChild("BtnLook").gameObject:SetActive(false)
        self.BuildCon:FindChild("TxtDeadline").gameObject:SetActive(false)
    elseif self.parent.cur_tab_index == 2 then
        -- 重铸
        local lev = self.cur_selected_data.lev
        lev = math.floor(lev / 10) * 10
        local key = string.format("%s_%s_%s_%s", RoleManager.Instance.RoleData.classes, self.cur_selected_data.type, lev, RoleManager.Instance.RoleData.sex % 2)

        local cfg_data = DataBacksmith.data_rebuild_forge[key]
        -- 40级的装备才会取得到数据
        if cfg_data == nil then
            return
        end

        self.bottom_base_data_1 = DataItem.data_get[cfg_data.loss_item[1][1]]
        self.bottom_base_data_2 = DataItem.data_get[cfg_data.loss_item[2][1]]

        self:set_stone_slot_data(self.bottom_slot_1, self.bottom_base_data_1, true)
        self:set_stone_slot_data(self.bottom_slot_2, self.bottom_base_data_2, true)

        self.bottom_left_TxtName1.text = self.bottom_base_data_1.name
        self.bottom_left_TxtName2.text = self.bottom_base_data_2.name

        self.has_num_1 = BackpackManager.Instance:GetItemCount(self.bottom_base_data_1.id)
        self.has_num_2 = BackpackManager.Instance:GetItemCount(self.bottom_base_data_2.id)
        self.need_num_1 = cfg_data.loss_item[1][2]
        self.need_num_2 = cfg_data.loss_item[2][2]

        self.bottom_slot_1:SetNum(self.has_num_1, self.need_num_1)
        self.bottom_slot_2:SetNum(self.has_num_2, self.need_num_2)

        local buy_list = { }
        if self.need_num_1 > self.has_num_1 then
            buy_list[self.bottom_base_data_1.id] = { need = self.need_num_1 }
        else
            -- 背包里面有足够的
            self.bottom_left_TxtVal1.text = string.format("<color='#13fc60'>%s</color>", "0")
        end

        if self.need_num_2 > self.has_num_2 then
            buy_list[self.bottom_base_data_2.id] = { need = self.need_num_2 }
        else
            -- 背包里面有足够的
            self.bottom_left_TxtVal2.text = string.format("<color='#13fc60'>%s</color>", "0")
        end

        self.BuildCon_BtnBuild_buy_btn:Layout(buy_list, self.on_click_build, self.on_bottom_prices_back)

        self.bottom_left_Slot1.gameObject:SetActive(true)
        self.bottom_left_Slot2.gameObject:SetActive(true)
        self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -20)
        self.BuildCon_BtnBuild_buy_btn:EnableBtn(true)
        self.BuildCon:FindChild("BtnLook").gameObject:SetActive(true)
        self.BuildCon:FindChild("TxtDeadline").gameObject:SetActive(true)

        -- 屏蔽重铸能量礼包
--        -- 挪位置,人物等级70级开启
--        if EquipStrengthManager.Instance.model:check_show_rebuild_reward() then
--            self.RebuildRewardCon.gameObject:SetActive(true)
--            self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -27)
--        else
--            self.RebuildRewardCon.gameObject:SetActive(false)
--            self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
--        end

        local times = math.floor((cfg_data.lucky_val - (self.cur_selected_data.lucky_val or 0)) / 10) or 0;
        local desc = nil;
        if times > 3 or times <= 0 then
            desc = TI18N("重铸祝福说明");
        else
            desc = string.format(TI18N("重铸<color='#ffff00'>%s</color>次必出特效"), times)
        end
        self.TxtDeadLine.text = desc;

        EquipStrengthManager.Instance:request10612()
    end
end
-------------------------------------监听器
-- 更新重铸值
function EquipStrengthFirstBuild:on_update_reset_val()
    if self.has_init == false then
        return
    end

    -- 取消重铸能量显示
    --    local prog_str = TI18N("<color='#ffff00'>可领取</color>")
    --    if EquipStrengthManager.Instance.model.equip_reset_val == EquipStrengthManager.Instance.model.max_equip_reset_val then
    --        self.RebuildRewardCon_effect:SetActive(true)
    --    else
    --        self.RebuildRewardCon_effect:SetActive(false)
    --        prog_str = ""--string.format("%s/%s", EquipStrengthManager.Instance.model.equip_reset_val, EquipStrengthManager.Instance.model.max_equip_reset_val)
    --    end

    --    local percent = EquipStrengthManager.Instance.model.equip_reset_val/EquipStrengthManager.Instance.model.max_equip_reset_val
    --    local oldW = self.RebuildRewardCon_ImgPropBar:GetComponent(RectTransform).rect.width
    --    local newW = percent*109.5

    --    -- self.RebuildRewardCon_ImgPropBar:GetComponent(RectTransform).sizeDelta = Vector2(newW, 17)


    --    local fun = function(value)
    --        if self.has_init then
    --            self.RebuildRewardCon_ImgPropBar:GetComponent(RectTransform).sizeDelta = Vector2(value, 17)
    --        end
    --    end
    --    if oldW >= 109.5 then oldW = 0 end
    --    Tween.Instance:ValueChange(oldW, newW, 0.5, nil, LeanTweenType.linear, fun)

    --    self.RebuildRewardCon_TxtProg.text = prog_str
end

function EquipStrengthFirstBuild:ShowTips()
    -- local TipsData =
    -- {
    --     TI18N("1.<color='#ffff00'>装备重铸</color>一定次数，必定出现装备<color='#ffff00'>特效</color>")
    --     ,TI18N("2.重铸<color='#ffff00'>70</color>级以上装备时，可获得<color='#ffff00'>重铸能量</color>")
    --     ,string.format(TI18N("3.装备等级越高，重铸能量越多，达到%s时可获得{item_2,22589,1,1}"),EquipStrengthManager.Instance.model.max_equip_reset_val)
    --     ,""
    --     ,""
    --     ,string.format(TI18N("<color='#01F504'>当前重铸能量：</color><color='#ffff00'>%s</color>/%s"),EquipStrengthManager.Instance.model.equip_reset_val,EquipStrengthManager.Instance.model.max_equip_reset_val)
    -- }

    local TipsData =
    {
        TI18N("1.<color='#ffff00'>装备重铸</color>一定次数，必定出现装备<color='#ffff00'>特效</color>:")
        ,TI18N(" 40级装备  15次   90级装备  13次")
        ,TI18N(" 50级装备  15次   100级装备 13次")
        ,TI18N(" 60级装备  15次   110级装备 14次")
        ,TI18N(" 70级装备  15次   120级装备 15次")
        ,TI18N(" 80级装备  13次")
        ,TI18N("2.重铸<color='#ffff00'>70</color>级以上装备时，可获得<color='#ffff00'>重铸能量</color>")
        ,string.format(TI18N("3.装备等级越高，重铸能量越多，达到%s时可获得{item_2,22589,1,1}"),EquipStrengthManager.Instance.model.max_equip_reset_val)
        ,TI18N("4.<color='#ffff00'>装备重铸</color>获得<color='#ffff00'>特效</color>概率:")
        ,TI18N(" 40级装备  10%   90级装备  13%")
        ,TI18N(" 50级装备  10%   100级装备 13%")
        ,TI18N(" 60级装备  12%   110级装备 10%")
        ,TI18N(" 70级装备  12%   120级装备 10%")
        ,TI18N(" 80级装备  12%")
        ,""
        ,""
        ,string.format(TI18N("<color='#01F504'>当前重铸能量：</color><color='#ffff00'>%s</color>/%s"),EquipStrengthManager.Instance.model.equip_reset_val,EquipStrengthManager.Instance.model.max_equip_reset_val)
    }

    TipsManager.Instance:ShowText( { gameObject = self.BtnTips.gameObject, itemData = TipsData})
end

-- 请求底部个数价格回调
function EquipStrengthFirstBuild:on_price_back(prices)
    if self.bottom_base_data_1 ~= nil then
        self:on_price_back_help(prices[self.bottom_base_data_1.id], self.bottom_left_TxtVal1, self.bottom_left_icon1)
    end
    if self.bottom_base_data_2 ~= nil then
        self:on_price_back_help(prices[self.bottom_base_data_2.id], self.bottom_left_TxtVal2, self.bottom_left_icon2)
    end
    if self.bottom_base_data_3 ~= nil then
        self:on_price_back_help(prices[self.bottom_base_data_3.id], self.bottom_left_TxtVal3, self.bottom_left_icon3)
    end
end

function EquipStrengthFirstBuild:on_price_back_help(data, bottom_left_TxtVal, bottom_left_icon, _num)
    if data == nil then
        return
    end
    local allprice = data.allprice
    local price_str = ""
    if allprice >= 0 then
        price_str = string.format("<color='%s'>%s</color>", "#ffffff", allprice)
    else
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], - allprice)
    end
    bottom_left_TxtVal.text = price_str
    bottom_left_icon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets])
end

-- 更新底部是显示普通打造还是显示完美打造
function EquipStrengthFirstBuild:update_normal_perfect(_is_socket)
    if self.parent.cur_tab_index == 1 then
        -- 锻造

        self.PerfectCon.gameObject:SetActive(false)
        self.BuildCon.gameObject:SetActive(false)

        local cfg_data = DataBacksmith.data_forge[string.format("%s_%s_%s", self.cur_selected_data.base_id, RoleManager.Instance.RoleData.sex, RoleManager.Instance.RoleData.classes)]
        -- 40级的装备才会取得到数据
        if cfg_data == nil then
            return
        end

        self:set_build_btn_sate(cfg_data)

        -- 强化等级低于7 ro 右边属性没有保存  or 配置里面读不到完美打造的数据   则不能进行完美打造
        local perfect_data = cfg_data.perfect_item[1]
        if self.cur_selected_data.enchant < 7 then
            self.BuildCon.gameObject:SetActive(true)
        elseif perfect_data ~= nil then
            -- 可以进行完美锻造
            local temp_base_data = DataItem.data_get[perfect_data[1]]

            local cost_num = perfect_data[2]
            self:set_stone_slot_data(self.perfect_slot, temp_base_data)
            local has_num = BackpackManager.Instance:GetItemCount(temp_base_data.id)
            self.perfect_slot:SetNum(has_num, perfect_data[2])
            self.PerfectCon.gameObject:SetActive(true)
        end
    elseif self.parent.cur_tab_index == 2 then
        -- 重铸
        self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(TI18N("重铸"))

        self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -20)
        self.BuildCon_BtnBuild_buy_btn:EnableBtn(true)

        self.PerfectCon.gameObject:SetActive(false)
        self.BuildCon.gameObject:SetActive(true)
    end

    -- self.PerfectCon_TxtNum.text
    -- self.BuildCon_TxtNum

    self:update_use_hero(_is_socket)
end

-- 是否使用英雄卷轴
function EquipStrengthFirstBuild:update_use_hero(_is_socket)
    local show = false
    for k, v in pairs(self.cur_selected_data.attr) do
        if v.type == GlobalEumn.ItemAttrType.gem and v.name == 112 then
            local data = DataBacksmith.data_hero_stone_base[v.val]
            if data ~= nil and data.lev >= 6 then
                show = true
                break
            end
        end
    end

    -- if not self.isBuy then
    --     self.PerfectCon_Toggle2.isOn = false
    -- end

    self.isNeedHeroStore = (show == true)
    if show then
        self.PerfectCon_Slot2Obj:SetActive(true)
        self.PerfectCon_RightConRect.sizeDelta = Vector2(152, 130)
        local temp_base_data = DataItem.data_get[20406]
        self.PerfectCon_TxtName2.text = temp_base_data.name
        self:set_stone_slot_data(self.hero_slot, temp_base_data)
        local has_num = BackpackManager.Instance:GetItemCount(20406)
        self.hero_slot:SetNum(has_num, 1)
    else
        self.isBuy = false
        self.PerfectCon_Toggle2.isOn = false
        self.PerfectCon_Slot2Obj:SetActive(false)
        self.PerfectCon_RightConRect.sizeDelta = Vector2(76, 130)
    end
end

-- 设置锻造按钮状态
function EquipStrengthFirstBuild:set_build_btn_sate(cfg_data)
    local next_cfg_base_data = DataItem.data_get[cfg_data.next_id]
    local curEquipType = self.cur_selected_data.type
    if (curEquipType == BackpackEumn.ItemType.cloth or curEquipType == BackpackEumn.ItemType.waistband or curEquipType == BackpackEumn.ItemType.trousers or curEquipType == BackpackEumn.ItemType.shoe) then
        -- 衣服、腰带、裤子、鞋子 特殊处理
        if cfg_data.need_lev <= RoleManager.Instance.RoleData.lev and((cfg_data.need_break_times <= RoleManager.Instance.RoleData.lev_break_times and cfg_data.need_break_times ~= 0) or cfg_data.need_break_times == 0) then
            -- 可以锻造
            self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(TI18N("锻造"))
            self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(TI18N("锻造"))
            self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
            self.BuildCon_BtnBuild_buy_btn:EnableBtn(true)
            self.PerfectCon_BtnBuil_buy_btn:EnableBtn(true)
        elseif cfg_data.need_break_times > RoleManager.Instance.RoleData.lev_break_times and cfg_data.need_break_times ~= 0 then
            -- 突破条件不符合
            self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(TI18N("突破后可打造"))
            self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(TI18N("突破后可打造"))
            self.BuildCon_BtnBuild_buy_btn:EnableBtn(false)
            self.PerfectCon_BtnBuil_buy_btn:EnableBtn(false)
        elseif cfg_data.need_lev > RoleManager.Instance.RoleData.lev then
            -- 等级条件不符合
            self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(string.format("%s%s", cfg_data.need_lev, TI18N("级可打造")))
            self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(string.format("%s%s", cfg_data.need_lev, TI18N("级可打造")))
            self.BuildCon_BtnBuild_buy_btn:EnableBtn(false)
            self.PerfectCon_BtnBuil_buy_btn:EnableBtn(false)
        end
    elseif cfg_data.need_lev > RoleManager.Instance.RoleData.lev then
        self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(string.format("%s%s", cfg_data.need_lev, TI18N("级可打造")))
        self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(string.format("%s%s", cfg_data.need_lev, TI18N("级可打造")))
        self.BuildCon_BtnBuild_buy_btn:EnableBtn(false)
        self.PerfectCon_BtnBuil_buy_btn:EnableBtn(false)
    elseif cfg_data.need_break_times > RoleManager.Instance.RoleData.lev_break_times and cfg_data.need_break_times ~= 0 then
        self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(TI18N("突破后可打造"))
        self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(TI18N("突破后可打造"))
        self.BuildCon_BtnBuild_buy_btn:EnableBtn(false)
        self.PerfectCon_BtnBuil_buy_btn:EnableBtn(false)
    else
        self.BuildCon_BtnBuild_buy_btn:Set_btn_txt(TI18N("锻造"))
        self.PerfectCon_BtnBuil_buy_btn:Set_btn_txt(TI18N("锻造"))
        self.BuildCon_BtnBuild.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        self.BuildCon_BtnBuild_buy_btn:EnableBtn(true)
        self.PerfectCon_BtnBuil_buy_btn:EnableBtn(true)
    end
end


-- 根据是否可以切换状态调整顶部左右框显示的高度和内容
function EquipStrengthFirstBuild:switch_top_left_right_height(_type)
    if _type == 1 then
        -- 显示
        self.LeftCon:GetComponent(RectTransform).sizeDelta = Vector2(206, 247)
        self.RightCon:GetComponent(RectTransform).sizeDelta = Vector2(206, 247)
        self.LeftCon:GetComponent(RectTransform).anchoredPosition = Vector2(19, -33.5)
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(226, -33.5)
        self.top_right_TxtBottomDesc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(3, -215.5)
        self.top_right_TxtRecommand.transform:GetComponent(RectTransform).anchoredPosition = Vector2(3, -197.1)
        self.left_selected_bg.transform:GetComponent(RectTransform).sizeDelta = Vector2(202, 242.3)
        self.right_selected_bg.transform:GetComponent(RectTransform).sizeDelta = Vector2(202, 242.3)

    elseif _type == 2 then
        -- 不显示
        self.LeftCon:GetComponent(RectTransform).sizeDelta = Vector2(206, 272)
        self.RightCon:GetComponent(RectTransform).sizeDelta = Vector2(206, 272)
        self.LeftCon:GetComponent(RectTransform).anchoredPosition = Vector2(19, -7)
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(226, -7)

        self.top_right_TxtRecommand.transform:GetComponent(RectTransform).anchoredPosition = Vector2(3, -218)
        self.top_right_TxtBottomDesc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(3, -239)
        self.left_selected_bg.transform:GetComponent(RectTransform).sizeDelta = Vector2(202, 268)
        self.right_selected_bg.transform:GetComponent(RectTransform).sizeDelta = Vector2(202, 268)

    end
end

-- 获取装备的非基础属性属性
function EquipStrengthFirstBuild:GetEquipAttr(attr, back, enchantadd)
    for i, v in ipairs(attr) do
        if v.type ~= GlobalEumn.ItemAttrType.base and v.type ~= GlobalEumn.ItemAttrType.extra and v.type ~= GlobalEumn.ItemAttrType.effect and v.type ~= GlobalEumn.ItemAttrType.wing_skill then
            if v.type == GlobalEumn.ItemAttrType.enchant then
                if v.flag ~= 0 then
                    table.insert(back, v)
                end
            else
                table.insert(back, v)
            end
        end
    end
    for i, v in ipairs(enchantadd) do
        v.type = GlobalEumn.ItemAttrType.enchant
        v.flag = 0
        table.insert(back, v)
    end
    return back
end

function EquipStrengthFirstBuild:CheckGuidePoint()
    TipsManager.Instance:ShowGuide({gameObject = self.BuildCon.gameObject, data = TI18N("点击锻造武器"), forward = TipsEumn.Forward.Up})

    if self.guideEffect == nil then
        self.guideEffect = BaseUtils.ShowEffect(20104,self.BuildCon.transform,Vector3(1,1,1), Vector3(0,0,-400))
    end
    self.guideEffect:SetActive(true)
end

function EquipStrengthFirstBuild:HideGuideEffect()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
end
