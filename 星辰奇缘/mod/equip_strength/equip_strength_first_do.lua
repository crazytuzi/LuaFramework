EquipStrengthFirstDo = EquipStrengthFirstDo or BaseClass(BasePanel)

--强化面板
function EquipStrengthFirstDo:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_con, type = AssetType.Main}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
        ,{file = AssetConfig.equip_strength_res, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20048), type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20049), type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20300), type = AssetType.Main}
    }
    self.model = EquipStrengthManager.Instance.model

    self.last_enchant = 0
    self.last_data_base_id = 0
    self.last_break_state = false --false表示未突破

    self.on_equip_update = function()
        local new_data = BackpackManager.Instance.equipDic[self.parent.cur_left_selected_data.id]
        self:update_info(new_data)
    end

    self.on_material_pub = function()
        self:update_material()
    end

    self.restoreFrozen_strength = nil
    self.restoreFrozen_break = nil

    self.has_init = false

    -- 所需材料是否足够
    self.enough = false

    self.is_play_effect = 0
    self.effect_delay_timer_id = 0
    return self
end

function EquipStrengthFirstDo:__delete()
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    if self.effect_delay_timer_id ~= nil then
        LuaTimer.Delete(self.effect_delay_timer_id)
        self.effect_delay_timer_id = 0
    end
    self.LuckCon_slot:DeleteMe()
    self.TopMidCon_slot:DeleteMe()
    self.StrengthCon_slot:DeleteMe()
    self.BreakCon_slot:DeleteMe()
    self.ProtectedCon_slot:DeleteMe()
    self.BestPreviewCon_slot:DeleteMe()


    self.bigbg.sprite = nil

    self.has_init = false
    if self.restoreFrozen_strength ~= nil then
        self.restoreFrozen_strength:DeleteMe()
    end
    if self.restoreFrozen_break ~= nil then
        self.restoreFrozen_break:DeleteMe()
    end

    GameObject.DestroyImmediate(self.gameObject)

    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)

    EventMgr.Instance:RemoveListener(event_name.equip_strength_materail_put, self.on_material_pub)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthFirstDo:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_con))
    self.gameObject.name = "EquipStrengthFirstDo"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(154, -9, 0)

    self.BestPreviewCon = self.transform:FindChild("BestPreviewCon")
    self.BestPreviewCon_SlotCon = self.BestPreviewCon:FindChild("SlotCon").gameObject

    self.ImgTanHaoBtn = self.transform:FindChild("ImgTanHao"):GetComponent(Button)
    self.ImgBreakTanHaoBtn = self.transform:FindChild("ImgBreakTanHao"):GetComponent(Button)
    self.TopMidCon = self.transform:FindChild("TopMidCon")

    -- 大图 hosr
    self.bigbg = self.TopMidCon:Find("ImgSlotBg"):GetComponent(Image)
    self.bigbg.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.effect_fail = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20048)))
    self.effect_fail.transform:SetParent(self.TopMidCon)
    self.effect_fail.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_fail.transform, "UI")
    self.effect_fail.transform.localScale = Vector3(1, 1, 1)
    self.effect_fail.transform.localPosition = Vector3(0, 0, -400)
    self.effect_fail:SetActive(false)

    self.effect_success = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20049)))
    self.effect_success.transform:SetParent(self.TopMidCon)
    self.effect_success.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_success.transform, "UI")
    self.effect_success.transform.localScale = Vector3(1, 1, 1)
    self.effect_success.transform.localPosition = Vector3(0, 0, -400)
    self.effect_success:SetActive(false)

    self.effect_success_go = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20300)))
    self.effect_success_go.transform:SetParent(self.TopMidCon)
    self.effect_success_go.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect_success_go.transform, "UI")
    self.effect_success_go.transform.localScale = Vector3(1, 1, 1)
    self.effect_success_go.transform.localPosition = Vector3(-150,-133, -400)
    self.effect_success_go:SetActive(false)

    self.TopMidCon_ImgTxt = self.TopMidCon:FindChild("ImgTitle"):FindChild("TxtTitle"):GetComponent(Text)
    self.TopMidCon_SlotCon = self.TopMidCon:FindChild("SlotCon").gameObject
    self.num_con = self.TopMidCon:FindChild("NumCon").gameObject
    self.num_con.transform:Find("ImgPlus"):GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_12 , "Num12_+")
    self.num_1 = self.num_con.transform:FindChild("ImgNum1"):GetComponent(Image)
    self.num_2 = self.num_con.transform:FindChild("ImgNum2"):GetComponent(Image)
    self.num_con:SetActive(true)

    self.BreakPropCon = self.transform:FindChild("BreakPropCon")
    self.BreakSlot = self.BreakPropCon:FindChild("BreakSlot")
    self.BreakSlot_SlotCon = self.BreakSlot:FindChild("SlotCon").gameObject
    self.BreakCostCon = self.BreakPropCon:FindChild("BreakCostCon")
    self.BreakCostCon_ImgTxtBg = self.BreakCostCon:FindChild("ImgTxtBg")
    self.BreakCostCon_TxtCostVal = self.BreakCostCon_ImgTxtBg:FindChild("TxtCostVal"):GetComponent(Text)
    self.BreakCostCon_BtnBreak = self.BreakPropCon:FindChild("BtnBreak"):GetComponent(Button)
    self.restoreFrozen_break = FrozenButton.New(self.BreakCostCon_BtnBreak)

    self.BottomPropCon = self.transform:FindChild("BottomPropCon")

    self.StrengthCon = self.BottomPropCon:FindChild("StrengthCon")
    self.StrengthCon_SlotCon = self.StrengthCon:FindChild("SlotCon").gameObject

    self.LuckCon = self.BottomPropCon:FindChild("LuckCon")
    self.LuckCon_SlotCon = self.LuckCon:FindChild("SlotCon").gameObject

    self.ProtectedCon = self.BottomPropCon:FindChild("ProtectedCon")
    self.ProtectedCon_SlotCon = self.ProtectedCon:FindChild("SlotCon").gameObject

    self.MidProgCon = self.BottomPropCon:FindChild("MidProgCon")
    self.MidProgCon_ImgProg = self.MidProgCon:FindChild("ImgProg")
    self.MidProgCon_TxtProg = self.MidProgCon_ImgProg:FindChild("TxtProg"):GetComponent(Text)

    self.TxtAttr_list = {}
    self.ImgArrow_list = {}
    self.TxtUp_list = {}
    self.TxtStrength_list = {}
    for i=1,5 do
        local txtAttr = self.BottomPropCon:FindChild(string.format("TxtAttr%s", i)):GetComponent(Text)
        local imgArrow = self.BottomPropCon:FindChild(string.format("ImgArrow%s", i)).gameObject
        local txtUp = self.BottomPropCon:FindChild(string.format("TxtUp%s", i)):GetComponent(Text)
        local txtStrength = self.BottomPropCon:FindChild(string.format("TxtStrength%s", i)):GetComponent(Text)
        txtAttr.text = ""
        imgArrow:SetActive(false)
        txtUp.text = ""
        txtStrength.text = ""
        table.insert(self.TxtAttr_list, txtAttr)
        table.insert(self.ImgArrow_list, imgArrow)
        table.insert(self.TxtUp_list, txtUp)
        table.insert(self.TxtStrength_list, txtStrength)
    end

    self.GrowupProgCon = self.BottomPropCon:FindChild("GrowupProgCon")
    self.GrowupProgCon_txt_desc = self.GrowupProgCon:FindChild("TxtDesc"):GetComponent(Text)
    self.GrowupProgCon_ImgProg = self.GrowupProgCon:FindChild("ImgProg")
    self.GrowupProgCon_ImgProgBar = self.GrowupProgCon_ImgProg:FindChild("ImgProgBar").gameObject
    self.GrowupProgConImgProgBar_rect = self.GrowupProgCon_ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    self.GrowupProgCon_TxtProg = self.GrowupProgCon_ImgProg:FindChild("TxtProg"):GetComponent(Text)

    self.GrowupProgCon:GetComponent(Button).onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1、<color='#ffff00'>+9以上</color>强化失败可开启相应的成长值"))
        table.insert(tips, TI18N("2、成长值开启后，每次<color='#ffff00'>强化失败</color>都能增加成长值"))
        table.insert(tips, TI18N("3、成长值满了后，该装备将<color='#ffff00'>直接提升</color>到对应的强化等级"))

        TipsManager.Instance:ShowText({gameObject = self.GrowupProgCon.gameObject, itemData = tips})
    end)

    self.CostCon = self.BottomPropCon:FindChild("CostCon")
    self.CostCon_ImgTxtBg = self.CostCon:FindChild("ImgTxtBg")
    self.CostCon_ImgCoin = self.CostCon_ImgTxtBg:FindChild("ImgCoin"):GetComponent(Image)
    self.CostCon_TxtCostVal = self.CostCon_ImgTxtBg:FindChild("TxtCostVal"):GetComponent(Text)
    self.CostCon_BtnStrength = self.BottomPropCon:FindChild("BtnStrength"):GetComponent(Button)
    self.CostCon_BtnStrength_txt = self.CostCon_BtnStrength.transform:FindChild("Text"):GetComponent(Text)
    self.CostCon_BtnStrength_txt.supportRichText = true
    self.restoreFrozen_strength = FrozenButton.New(self.CostCon_BtnStrength)

    self.LuckCon_slot = self:create_equip_slot(self.LuckCon_SlotCon)
    self.TopMidCon_slot = self:create_equip_slot(self.TopMidCon_SlotCon)
    self.StrengthCon_slot = self:create_equip_slot(self.StrengthCon_SlotCon)
    self.BreakCon_slot = self:create_equip_slot(self.BreakSlot_SlotCon)
    self.ProtectedCon_slot = self:create_equip_slot(self.ProtectedCon_SlotCon)
    self.BestPreviewCon_slot = self:create_equip_slot(self.BestPreviewCon_SlotCon)
    self.has_init = true

    self.toggle = self.CostCon:Find("Toggle"):GetComponent(Toggle)
    self.has_tips = false
    self.toggle.isOn = false
    self.toggle.onValueChanged:AddListener(function(status)
        if self.has_tips then
            return
        end
        self.has_tips = true
        if status then
            --没提示过
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("勾选后将自动消耗钻石购买强化石，是否确定？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 15
            data.sureCallback = function()
                --寻路到npc
                self.toggle.isOn = true
            end
            data.cancelCallback = function()
                self.toggle.isOn = false
            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    end)

    self.has_tips_strength = false
    self.on_click_strength = function()
        if self.toggle.isOn then
            if self.cur_selected_data.enchant <self.model.max_strength_lev then
                if self.has_tips_strength == false then
                    if (self.model.select_luck_data_1 == nil and self.model.select_luck_data_2 == nil and self.model.select_luck_data_2 == nil) or self.model.select_hufu_data ==   nil   then
                        self.has_tips_strength = true
                        if  self.cur_selected_data.enchant >= 8 then
                            local str = TI18N("当前装备强化等级较高，建议放入<color='#ffff00'>幸运石或保护符</color>等辅助道具")
                            local data = NoticeConfirmData.New()
                            data.type = ConfirmData.Style.Normal
                            data.content = str
                            data.sureLabel = TI18N("继续强化")
                            data.cancelLabel = TI18N("取消")
                            data.sureCallback = function()
                                --自动寻路到npc
                                self:on_click_strength_btn()
                            end
                            NoticeManager.Instance:ConfirmTips(data)
                            return
                        end
                    end
                end
                self:on_click_strength_btn()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("该装备已经达到最高强化等级"))
            end
        else
            --判读下强化石够不够
            if self.cur_selected_data.enchant <self.model.max_strength_lev then
                local strength_stone = DataItem.data_get[DataBacksmith.data_enchant[self.cur_selected_data.enchant].need_item[1][1]]
                local strength_need_num = DataBacksmith.data_enchant[self.cur_selected_data.enchant].need_item[1][2]
                local strength_stone_num = BackpackManager.Instance:GetItemCount(strength_stone.id)

                local temp_cfg_data = DataBacksmith.data_enchant_growth[self.cur_selected_data.growth_lev]
                if temp_cfg_data ~= nil and temp_cfg_data.growth_val <= self.cur_selected_data.growth_val then
                    --成长值达到最大则不用判断强化石够不够
                    self:on_click_strength_btn()
                elseif strength_need_num > strength_stone_num then
                    NoticeManager.Instance:FloatTipsByString(TI18N("强化石不足"))
                    -- self.model:OpenStrengthBuyUI(self.cur_selected_data.enchant)
                    self.StrengthCon_slot:SureClick()
                else
                    self:on_click_strength_btn()
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("该装备已经达到最高强化等级"))
            end
        end
    end

    self.on_click_break = function()
        if self.enough then
            EquipStrengthManager.Instance:request10622(self.cur_selected_data.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
            self.BreakCon_slot:SureClick()
        end
    end

    self.CostCon_BtnStrength.onClick:AddListener(self.on_click_strength)
    self.BreakCostCon_BtnBreak.onClick:AddListener(self.on_click_break)

    self.ImgTanHaoBtn.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1、强化可使装备获得额外的<color='#ffff00'>属性加成</color>"))
        table.insert(tips, TI18N("2、装备<color='#ffff00'>本身属性</color>越好，强化增加的属性越高"))
        table.insert(tips, TI18N("3、45级装备强化上限为<color='#ffff00'>+4</color>,50级上限为<color='#ffff00'>+8</color>，60级上限为<color='#ffff00'>+9</color>，70级上限为<color='#ffff00'>+10</color>,80级上限为<color='#ffff00'>+11</color>,85级上限为<color='#ffff00'>+12</color>"))

        -- table.insert(tips, TI18N("3、50级装备强化上限为<color='#ffff00'>+8</color>，60级上限为<color='#ffff00'>+9</color>，70级上限为<color='#ffff00'>+11</color>，80级上限为<color='#ffff00'>+12</color>"))
        table.insert(tips, string.format("%s+%s</color>",TI18N("4、90级装备强化<color='#ffff00'>+12</color>后可以<color='#ffff00'>突破强化极限</color>，突破极限后强化上限为<color='#ffff00'>"), self.model.max_strength_lev))
        table.insert(tips, TI18N("5、强化<color='#ffff00'>+9以上失败</color>后，将会获得<color='#ffff00'>成长值祝福</color>，每次失败将增加成长值，满后可<color='#ffff00'>一键提升</color>至对应强化等级"))
        table.insert(tips, TI18N("6、突破极限后<color='#ffff00'>+12</color>装备最多掉落到<color='#ffff00'>+10</color>，<color='#ffff00'>+13以上</color>最多掉落到<color='#ffff00'>+11</color>"))
        -- if self.cur_selected_data ~= nil and self.model:check_equip_has_broken(self.cur_selected_data) then
        --     --已经突破过
        --     table.insert(tips, TI18N("6、100级装备强化上限为<color='#ff0000'>+15</color>"))
        -- end

        TipsManager.Instance:ShowText({gameObject = self.ImgTanHaoBtn.gameObject, itemData = tips})
    end)

    self.ImgBreakTanHaoBtn.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("该装备已突破强化极限，属性获得大幅提升："))
        table.insert(tips, TI18N("<color='#ffff00'>强化之力：</color>装备强化加成效果<color='#2fc823'>提升2%</color>"))
        table.insert(tips, TI18N("<color='#ffff00'>神匠：</color>装备强化最多掉落至<color='#2fc823'>强化+10</color>"))
        TipsManager.Instance:ShowText({gameObject = self.ImgBreakTanHaoBtn.gameObject, itemData = tips})
    end)

    if self.parent.cur_left_selected_data ~= nil then
        self:update_info(self.parent.cur_left_selected_data)
    end

    self.LuckCon_slot:SetAddCallback(function() self:on_click_luck_stone_add()  end)
    self.ProtectedCon_slot:SetAddCallback(function() self:on_click_luck_stone_add()  end)

    -- EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_equip_update)

    EventMgr.Instance:AddListener(event_name.equip_strength_materail_put, self.on_material_pub)
    self.parent:CheckGuidePoint()
end

--------------------------------------------各种更新
--左边选中装备，右边更新
function EquipStrengthFirstDo:update_info(data)
    if self.has_init == false then
        return
    end
    if data == nil then
        return
    end
    self.cur_selected_data = data
    -- self.num_con:SetActive(false)

    self.num_2.gameObject:SetActive(false)
    if self.cur_selected_data.enchant < 10 then
        self.num_1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_12 , string.format("Num12_%s", self.cur_selected_data.enchant))
        self.num_1:SetNativeSize()
    else
        local shiwei = math.floor(self.cur_selected_data.enchant/10)
        local gewei = self.cur_selected_data.enchant%10
        self.num_1.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_12 , string.format("Num12_%s", shiwei))
        self.num_2.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_12 , string.format("Num12_%s", gewei))
        self.num_2.gameObject:SetActive(true)
        self.num_1:SetNativeSize()
        self.num_2:SetNativeSize()
    end

    self.luck_stone_data = nil
    self.model.select_hufu_data = nil
    self.model.select_luck_data_1 = nil
    self.model.select_luck_data_2 = nil
    self.model.select_luck_data_3 = nil

    self:update_hufu_slot()
    self:update_luck_slot()

    -- self.cur_selected_data.enchant 强化等级是否满级
    self:update_top()
    self:update_success_prog()
    self:update_equip_prop()
    self:update_growup_prog()
    self:update_bottom_cost()
    self:update_bottom_break_cost()

    --记录下当前选中的装备,是否需要播放强化成功或失败的特效
    if self.is_play_effect ~= 1 then
        self.effect_success:SetActive(false)
        self.effect_success_go:SetActive(false)
    end
    if self.is_play_effect ~= 2 then
        self.effect_fail:SetActive(false)
    end
    if self.last_data_base_id ~= nil then
        if self.last_data_base_id == self.cur_selected_data.base_id then
            local cur_break_state = self.model:check_equip_has_broken(self.cur_selected_data)
            if self.last_enchant < self.cur_selected_data.enchant or cur_break_state ~= self.last_break_state then
                --成功
                self.is_play_effect = 1
                self.effect_success:SetActive(false)
                self.effect_success:SetActive(true)

                if cur_break_state == self.last_break_state then
                    self.effect_success_go:SetActive(false)
                    self.effect_success_go:SetActive(true)
                end

                self:update_effect_delay()
            elseif self.last_enchant > self.cur_selected_data.enchant then
                --失败
                self.is_play_effect = 2
                self.effect_fail:SetActive(false)
                self.effect_fail:SetActive(true)
                self:update_effect_delay()
            end
        end
    end
    self.last_data_base_id = self.cur_selected_data.base_id
    self.last_enchant = self.cur_selected_data.enchant
    self.last_break_state = self.model:check_equip_has_broken(self.cur_selected_data)

    if self.last_break_state then
        self.ImgBreakTanHaoBtn.gameObject:SetActive(true)
    else
        self.ImgBreakTanHaoBtn.gameObject:SetActive(false)
    end

    if self.model:check_equip_need_break(self.cur_selected_data) then
        --需要突破
        self.BreakPropCon.gameObject:SetActive(true)
        self.BottomPropCon.gameObject:SetActive(false)
    else
        self.BreakPropCon.gameObject:SetActive(false)
        self.BottomPropCon.gameObject:SetActive(true)
    end
end

--特效延迟
function EquipStrengthFirstDo:update_effect_delay()
    if self.effect_delay_timer_id ~= nil then
        LuaTimer.Delete(self.effect_delay_timer_id)
        self.effect_delay_timer_id = 0
    end
    self.effect_delay_timer_id = LuaTimer.Add(1200, function()
        if self.has_init == false then
            return
        end
        self.is_play_effect = 0
        if self.effect_success ~= nil then
           self.effect_success:SetActive(false)
           self.effect_success_go:SetActive(false)
        end
        if self.effect_fail ~= nil then
           self.effect_fail:SetActive(false)
        end
    end )
end

--强化材料放入，更新幸运石和护符
function EquipStrengthFirstDo:update_material()
    self:update_hufu_slot()
    self:update_luck_slot()
    self:update_success_prog()
end

--更新顶部图标
function EquipStrengthFirstDo:update_top()

    --构建极品预览
    local temp_attr_list = {}
    local temp_attr_dic = {}
    for i=1,#self.cur_selected_data.attr do
        local temp_attr = self.cur_selected_data.attr[i]
        if temp_attr.type ~= GlobalEumn.ItemAttrType.enchant then
            table.insert(temp_attr_list, temp_attr)
            temp_attr_dic[temp_attr.name] = temp_attr
        end
    end
    local temp_data = BaseUtils.copytab(self.cur_selected_data)
    temp_data.attr = temp_attr_list

    local topEnchant = self.model.max_strength_lev
    -- if not self.model:check_equip_has_broken(self.cur_selected_data) then
        if self.cur_selected_data.lev <= 50 then
            topEnchant = 8
        elseif self.cur_selected_data.lev <= 60 then
            topEnchant = 9
        elseif self.cur_selected_data.lev <= 70 then
            topEnchant = 11
        elseif self.cur_selected_data.lev <= 80 then
            topEnchant = 12
        elseif self.cur_selected_data.lev <= 90 then
            topEnchant = 13
        else
            topEnchant = self.model.max_strength_lev
        end
    -- end

    local temp_key = string.format("%s_%s", temp_data.type, temp_data.lev)
    local cfg_base_data = self.model:get_equip_base_prop_list(temp_key)
    local cfg_enchant = DataEqm.data_enchant[string.format("%s_%s", temp_data.type,topEnchant)].target
    for i=1,#cfg_enchant do
        local cfg_temp_data = cfg_enchant[i]
        local base_val = 0  --cfg_base_data[cfg_temp_data.effect_type]
        if temp_attr_dic[cfg_temp_data.effect_type] then
            base_val = temp_attr_dic[cfg_temp_data.effect_type].val
        end
        local temp_val = base_val*cfg_temp_data.val/1000
        if self.model:check_equip_has_broken(self.cur_selected_data) then
            temp_val = (cfg_temp_data.val+20)* base_val /1000
        end
        local _data =  {type = GlobalEumn.ItemAttrType.enchant, val = temp_val, name = cfg_temp_data.effect_type, flag = 0}
        table.insert(temp_data.attr, _data)
    end

    if temp_data.id == 1 or temp_data.id == 5 or temp_data.id == 7 then
        local single_reward_key = string.format("%s_%s", temp_data.type, topEnchant)
        local cfg_single_reward = DataEqm.data_single_enchant_reward[single_reward_key]
        for i=1,#cfg_single_reward.effect do
            local cfg_temp_data = cfg_single_reward.effect[i]
            local temp_val = cfg_temp_data.val
            local _data = {type = GlobalEumn.ItemAttrType.enchant, val = temp_val, name = cfg_temp_data.effect_type, flag = 12}
            table.insert(temp_data.attr, _data)
        end
    end

    temp_data.enchant = topEnchant
    self:set_stone_slot_data(self.BestPreviewCon_slot, temp_data)

    local base_data = DataItem.data_get[self.cur_selected_data.base_id]
    self.TopMidCon_slot:ShowEnchant(true)
    self.TopMidCon_slot:SetAll(BackpackManager.Instance.equipDic[self.cur_selected_data.id])



    local temp_name_str = ColorHelper.color_item_name(base_data.quality, base_data.name)
    for i=1,#self.cur_selected_data.extra do
         if self.cur_selected_data.extra[i].name == 9 then
            local temp_id = self.cur_selected_data.extra[i].value
            temp_name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
            break
         end
    end
    self.TopMidCon_ImgTxt.text = temp_name_str

    self.enough = false
    if self.model:check_equip_need_break(self.cur_selected_data) then
        --需要突破
        local cfg_broken_cost_data = nil
        for i=1,#DataBacksmith.data_equip_broken do
            local temp_cfg_data = DataBacksmith.data_equip_broken[i]
            if temp_cfg_data.type == self.cur_selected_data.type and (temp_cfg_data.need_lev <= self.cur_selected_data.lev or  self.cur_selected_data.lev == 80) then
                cfg_broken_cost_data = temp_cfg_data
                break
            end
        end

        if cfg_broken_cost_data ~= nil then
            local strength_stone = DataItem.data_get[cfg_broken_cost_data.need_item[1][1]]
            local strength_need_num = cfg_broken_cost_data.need_item[1][2]
            local strength_stone_num = BackpackManager.Instance:GetItemCount(strength_stone.id)
            self:set_stone_slot_data(self.BreakCon_slot, strength_stone)
            self.BreakCon_slot:SetNum( strength_stone_num, strength_need_num)
            self.enough = (strength_stone_num >= strength_need_num)
        end
    elseif self.cur_selected_data.enchant < self.model.max_strength_lev then
        local strength_stone = DataItem.data_get[DataBacksmith.data_enchant[self.cur_selected_data.enchant].need_item[1][1]]
        local strength_need_num = DataBacksmith.data_enchant[self.cur_selected_data.enchant].need_item[1][2]
        local strength_stone_num = BackpackManager.Instance:GetItemCount(strength_stone.id)
        self:set_stone_slot_data(self.StrengthCon_slot, strength_stone)
        self.StrengthCon_slot:SetNum( strength_stone_num, strength_need_num)
    else
        local enchant = self.cur_selected_data.enchant
        if enchant == self.model.max_strength_lev then
            enchant = enchant - 1
        end

        local strength_stone = DataItem.data_get[DataBacksmith.data_enchant[enchant].need_item[1][1]]
        local strength_stone_num = BackpackManager.Instance:GetItemCount(strength_stone.id)
        self:set_stone_slot_data(self.StrengthCon_slot, strength_stone)
        self.StrengthCon_slot:SetNum(strength_stone_num, 0, true)
    end


    self.LuckCon_slot:ShowAddBtn(true)
    self.ProtectedCon_slot:ShowAddBtn(true)
end

--更新护符图标
function EquipStrengthFirstDo:update_hufu_slot()
    if self.model.select_hufu_data ~= nil then
        self:set_stone_slot_data(self.ProtectedCon_slot, self.model.select_hufu_data)
        self.ProtectedCon_slot:ShowNum(false)
        self.ProtectedCon_slot:ShowAddBtn(false)
        self.ProtectedCon_slot:SetNotips(true)
        self.ProtectedCon_slot:SetSelectSelfCallback(function()
            self:on_click_luck_stone_add()
        end)
    else
        self:set_stone_slot_data(self.ProtectedCon_slot, nil)
        self.ProtectedCon_slot:ShowAddBtn(true)
        self.ProtectedCon_slot:SetAddCallback(function() self:on_click_luck_stone_add()  end)
    end
end

--更新幸运石图标
function EquipStrengthFirstDo:update_luck_slot()
    local data = nil
    local num = 0
    if self.model.select_luck_data_1 ~= nil then
        data = self.model.select_luck_data_1
    elseif self.model.select_luck_data_2 ~= nil then
        data = self.model.select_luck_data_2
    elseif self.model.select_luck_data_3 ~= nil then
        data = self.model.select_luck_data_3
    end

    if data ~= nil then
        self:set_stone_slot_data(self.LuckCon_slot, data)
        self.LuckCon_slot:ShowNum(false)
        self.LuckCon_slot:ShowAddBtn(false)
        self.LuckCon_slot:SetNotips(true)
        self.LuckCon_slot:SetSelectSelfCallback(function()
            self:on_click_luck_stone_add()
        end)
    else
        self:set_stone_slot_data(self.LuckCon_slot, nil)
        self.LuckCon_slot:ShowAddBtn(true)
        self.LuckCon_slot:SetAddCallback(function() self:on_click_luck_stone_add()  end)
    end
end

--更新中部强化成功率
function EquipStrengthFirstDo:update_success_prog(_data)
    self.luck_stone_data = _data
    if self.cur_selected_data.enchant <self.model.max_strength_lev then
        local cfg_data = DataBacksmith.data_enchant[self.cur_selected_data.enchant]

        local luck_percent = 0
        if self.luck_stone_data ~= nil then
            luck_percent = DataBacksmith.data_enchant_luck[self.luck_stone_data.id].ratio
        end

        local final_prog = cfg_data.base_ratio + luck_percent
        --加上选中的幸运石的百分比
        if self.model.select_luck_data_1 ~= nil then
            final_prog = final_prog + DataBacksmith.data_enchant_luck[self.model.select_luck_data_1.base_id].ratio
        end
        if self.model.select_luck_data_2 ~= nil then
            final_prog = final_prog + DataBacksmith.data_enchant_luck[self.model.select_luck_data_2.base_id].ratio
        end
        if self.model.select_luck_data_3 ~= nil then
            final_prog = final_prog + DataBacksmith.data_enchant_luck[self.model.select_luck_data_3.base_id].ratio
        end
        final_prog = final_prog/1000

        local vval = math.min(100*final_prog, 100)
        local final_prog_str = string.format("%s%s", vval, "%")
        self.MidProgCon_TxtProg.text = string.format("%s:%s", TI18N("强化成功率"), final_prog_str)
    else
        self.MidProgCon_TxtProg.text = TI18N("当前已强化至最高等级")
    end
end

--更新装备属性
function EquipStrengthFirstDo:update_equip_prop()
    for i=1,5 do
        self.TxtAttr_list[i].text = ""
        self.ImgArrow_list[i]:SetActive(false)
        self.TxtUp_list[i].text = ""
        self.TxtStrength_list[i].text = ""
    end

    local cfg_base_data = self.model:get_equip_base_prop_list(string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.lev))
    local cur_percent_key = string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.enchant)
    local cur_percents = {}
    if DataEqm.data_enchant[cur_percent_key] ~= nil then
        cur_percents = DataEqm.data_enchant[cur_percent_key].target
    end

    local next_percent_key = string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.enchant+1)
    local next_percents = {}
    if DataEqm.data_enchant[next_percent_key] ~= nil then
        next_percents = DataEqm.data_enchant[next_percent_key].target
    else
        --已经到最高等级
        next_percent_key = string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.enchant)
        next_percents = DataEqm.data_enchant[next_percent_key].target
    end

    local enchant_props = {}
    for i=1,#next_percents do
        local next_percent_data = next_percents[i]
        local cur_percent_data = cur_percents[i]
        if cur_percent_data ~= nil then --避免下一等级有，当前等级没有
            local temp_val = cfg_base_data[next_percent_data.effect_type]*(next_percent_data.val - cur_percent_data.val)/1000
            enchant_props[next_percent_data.effect_type] = math.ceil(temp_val)
        end
    end


    local temp_attr = {}
    for i=1,#self.cur_selected_data.attr do
        local at = self.cur_selected_data.attr[i]
        if at.type == GlobalEumn.ItemAttrType.enchant and at.flag == 0 then
            if temp_attr[at.name] ~= nil then
                temp_attr[at.name].val = temp_attr[at.name].val + at.val
            else
                temp_attr[at.name] = BaseUtils.copytab(at)
            end
        elseif at.type == GlobalEumn.ItemAttrType.enchant and at.flag ~= 0 then
            temp_attr[at.name] = BaseUtils.copytab(at)
        elseif at.type == GlobalEumn.ItemAttrType.base then
            if temp_attr[at.name] ~= nil then
                temp_attr[at.name].val = temp_attr[at.name].val + at.val
                temp_attr[at.name].flag = at.flag
                temp_attr[at.name].type = at.type
            else
                temp_attr[at.name] = BaseUtils.copytab(at)
            end
        end
    end

    --记录下下个强化等级的属性
    local key = string.format("%s_%s", self.cur_selected_data.type, (self.cur_selected_data.enchant+1))
    local next_enchant_cfg = DataEqm.data_single_enchant_reward[key]
    local next_enchant_list = {}
    local has_next_lev = false
    if next_enchant_cfg ~= nil then
        local temp_effect = next_enchant_cfg.effect
        has_next_lev = true
        for i=1,#temp_effect do
            next_enchant_list[temp_effect[i].effect_type] = temp_effect[i]
        end
    else
        --达到最高等级
        key = string.format("%s_%s", self.cur_selected_data.type, (self.cur_selected_data.enchant))
        next_enchant_cfg = DataEqm.data_single_enchant_reward[key]
        if next_enchant_cfg ~= nil then
            local temp_effect = next_enchant_cfg.effect
            has_next_lev = true
            for i=1,#temp_effect do
                next_enchant_list[temp_effect[i].effect_type] = temp_effect[i]
            end
        end
    end

    local index = 1
    for k, at in pairs(temp_attr) do
        if at.type == GlobalEumn.ItemAttrType.base  then
            if enchant_props[at.name] ~= nil then
                self.ImgArrow_list[index]:SetActive(true)
                self.TxtUp_list[index].text = enchant_props[at.name]
            end
            self.TxtAttr_list[index].text = string.format("<color='#23F0F7'>%s+%s</color>", KvData.attr_name[at.name], at.val)
            index = index + 1
        end
    end
    --没有下一等级，就显示当前等级
    for k, at in pairs(temp_attr) do
        if at.type == GlobalEumn.ItemAttrType.enchant  then
            if next_enchant_list[at.name] ~= nil then
                self.TxtStrength_list[index].text = string.format("<color='#b031d5'>[%s+%s%s]</color>", TI18N("强化"), at.flag, TI18N("奖励"))
            end
            local percent_val = at.val
            if KvData.prop_percent[at.name] ~= nil then
                percent_val = string.format("%s%s" , percent_val/10, "%")
            end
            self.TxtAttr_list[index].text = string.format("<color='#b031d5'>%s+%s</color>", KvData.attr_name[at.name], percent_val)
            index = index + 1
        end
    end
end

--更新成长值
function EquipStrengthFirstDo:update_growup_prog()
    --检查下当前选中的装备是否需要突破
    local need_break = false
    if self.model:check_equip_need_break(self.cur_selected_data) then
        --需要突破
        self.CostCon_BtnStrength.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.CostCon_BtnStrength_txt.text = string.format(ColorHelper.DefaultButton1Str, TI18N("突 破"))
    else
        --强化按钮默认蓝色
        self.CostCon_BtnStrength.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")

        if self:check_enchant_role_lev() then
            self.CostCon_BtnStrength_txt.text = string.format(ColorHelper.DefaultButton1Str, string.format(ColorHelper.DefaultButton1Str, TI18N("强 化")))
        else
            local cfgData = DataBacksmith.data_enchant[self.cur_selected_data.enchant]
            self.CostCon_BtnStrength_txt.text = string.format(ColorHelper.DefaultButton1Str, string.format(TI18N("%s级可强化"), cfgData.need_role_lev))
        end

        self.GrowupProgCon.gameObject:SetActive(false)
        self.GrowupProgCon_txt_desc.text = string.format("+%s%s", self.cur_selected_data.growth_lev,TI18N("成长值"))
        if self.cur_selected_data.growth_val > 0 then
            local max = DataBacksmith.data_enchant_growth[self.cur_selected_data.growth_lev].growth_val

            self.GrowupProgCon_TxtProg.text = string.format("%s/%s", self.cur_selected_data.growth_val, max)
            self.GrowupProgConImgProgBar_rect.sizeDelta = Vector2(223*self.cur_selected_data.growth_val/max, self.GrowupProgConImgProgBar_rect.rect.height)
            self.GrowupProgCon.gameObject:SetActive(true)


            if self.cur_selected_data.growth_val >= max then
                --强化按钮变绿色
                self.CostCon_BtnStrength.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.CostCon_BtnStrength_txt.text = string.format(ColorHelper.DefaultButton2Str, string.format("%s+%s", TI18N("直升"), self.cur_selected_data.growth_lev))
            end
        end
    end
end

--检查当前人物等级，是否满足能够强到下一个强化等级
function EquipStrengthFirstDo:check_enchant_role_lev()
    local state = false
    local cfgData = DataBacksmith.data_enchant[self.cur_selected_data.enchant]
    if cfgData ~= nil then
        if cfgData.need_role_lev <= RoleManager.Instance.RoleData.lev then
            state = true
        end
    else
        state = true
    end
    return state
end

--更新消耗
function EquipStrengthFirstDo:update_bottom_cost()
    if self.cur_selected_data.enchant <self.model.max_strength_lev then
        local cfg_data = DataBacksmith.data_enchant[self.cur_selected_data.enchant]
        local has_num = RoleManager.Instance.RoleData:GetMyAssetById(90000)
        if has_num >= cfg_data.need_coin then
            --绿色
            self.CostCon_TxtCostVal.text = string.format("<color='%s'>%s</color>", "#ffffff", tostring(cfg_data.need_coin))
            self.BreakCostCon_TxtCostVal.text = string.format("<color='%s'>%s</color>", "#ffffff", tostring(cfg_data.need_coin))
        else
            --红色
            self.CostCon_TxtCostVal.text = string.format("<color='%s'>%s</color>", ColorHelper.color[6], tostring(cfg_data.need_coin))
        end
    else
        self.CostCon_TxtCostVal.text = string.format("<color='%s'>%s</color>", "#ffffff" , "--")
    end
end

function EquipStrengthFirstDo:update_bottom_break_cost()
    self.BreakCostCon_TxtCostVal.text = tostring(1)
end

--------------------------------点击监听逻辑
--点击强化监听
function EquipStrengthFirstDo:on_click_strength_btn()
    if self:check_enchant_role_lev() == false then
        local cfgData = DataBacksmith.data_enchant[self.cur_selected_data.enchant]
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("等级不足%s级，无法强化装备"), cfgData.need_role_lev))
        return
    end

    local temp_luck_list = {}
    if self.model.select_luck_data_1 ~= nil then
        temp_luck_list[self.model.select_luck_data_1.base_id] = {luck_id = self.model.select_luck_data_1.base_id, num = 1}
    end

    local temp_data = nil

    if self.model.select_luck_data_2 ~= nil then
        temp_data = temp_luck_list[self.model.select_luck_data_2.base_id]
        if temp_data ~= nil then
            temp_data.num = temp_data.num + 1
        else
            temp_luck_list[self.model.select_luck_data_2.base_id] = {luck_id = self.model.select_luck_data_2.base_id, num = 1}
        end
    end

    if self.model.select_luck_data_3 ~= nil then
        temp_data = temp_luck_list[self.model.select_luck_data_3.base_id]
        if temp_data ~= nil then
            temp_data.num = temp_data.num + 1
        else
            temp_luck_list[self.model.select_luck_data_3.base_id] = {luck_id = self.model.select_luck_data_3.base_id, num = 1}
        end
    end

    local _luck_list = {}
    for k, v in pairs(temp_luck_list) do
        table.insert(_luck_list, v)
    end

    local temp_hufu_id  = 0
    if self.model.select_hufu_data ~= nil then
        temp_hufu_id = self.model.select_hufu_data.base_id
    end

    EquipStrengthManager.Instance:request10602(self.cur_selected_data.id, _luck_list, temp_hufu_id)

    self.model.select_luck_data_1 = nil
    self.model.select_luck_data_2 = nil
    self.model.select_luck_data_3 = nil
    self.model.select_hufu_data = nil
end

--点击强化石图标
function EquipStrengthFirstDo:on_click_luck_stone_add()
    if self.cur_selected_data.enchant >=self.model.max_strength_lev then
        return
    end

    self.model.cur_equip_data = self.cur_selected_data
    self.model:OpenEquipHufuUI()
end


--------------------------------初始化逻辑
--为每个武器创建slot
function EquipStrengthFirstDo:create_equip_slot(slot_con)
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

--对slot设置数据
function EquipStrengthFirstDo:set_stone_slot_data(slot, data)
    if data ~= nil then
        local cell = ItemData.New()
        cell:SetBase(data)
        slot:SetAll(cell, nil)
    else
        slot:SetAll(nil, nil)
    end
end


function EquipStrengthFirstDo:CheckGuidePoint()
    TipsManager.Instance:ShowGuide({gameObject = self.CostCon_BtnStrength.gameObject, data = TI18N("点击强化装备"), forward = TipsEumn.Forward.Up})

    if self.guideEffect == nil then
        self.guideEffect = BibleRewardPanel.ShowEffect(20104,self.CostCon_BtnStrength.transform,Vector3(0.9,0.9,1), Vector3(0,0,-400))
    end
    self.guideEffect:SetActive(true)
end

function EquipStrengthFirstDo:HideGuideEffect()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
end