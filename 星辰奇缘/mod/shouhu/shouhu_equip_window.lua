ShouhuEquipWindow  =  ShouhuEquipWindow or BaseClass(BaseWindow)

function ShouhuEquipWindow:__init(model)
    self.name  =  "ShouhuEquipWindow"
    self.model  =  model
    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList  =  {
        {file  =  AssetConfig.shouhu_equip_win, type  =  AssetType.Main}
        ,{file  =  AssetConfig.pet_textures, type  =  AssetType.Dep}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.myData = nil
    self.selectedEquipData = nil
    self.current_equip_index = 0

    self.hasClickUpdate = false--记录是否点击了升级按钮
    self.hasClickReset = false--记录是否点击了重置按钮
    self.leftEquipSlot = nil
    self.rightEquipSlot = nil
    self.rightMarkEquipSlot = nil
    self.RightMarkSlot = nil
    self.is_open = false
    self.myData = nil
    self.current_equip_index = 0
    self.selectedEquipData = nil

    self.right_has_open = false
    self.right_stone_has_open = false
    self.right_mark_has_open = false
    self.last_opera = 0
    self.timerEffectId = 0
    self.show_tips = false

    self.restoreFrozen_reset = nil
    self.restoreFrozen_upgrade = nil
    self.restoreFrozen_reset_small = nil
    self.restoreFrozen_stone_upgrade = nil
    self.canUpgrade = true
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.on_item_update = function()
        self:update_mark_con(self.model.my_sh_selected_equip)
    end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)

    return self
end

function ShouhuEquipWindow:OnShow()
    self:init_view()
    self:switch_stone_prop_panel(1)
end

function ShouhuEquipWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    if self.stone_slot_1 ~= nil then
         self.stone_slot_1:DeleteMe()
    end
    if self.stone_slot_2 ~= nil then
        self.stone_slot_2:DeleteMe()
    end
    if self.mid_slot_1 ~= nil then
        self.mid_slot_1:DeleteMe()
    end
    if self.mid_slot_2 ~= nil then
        self.mid_slot_2:DeleteMe()
    end
    if self.mid_slot_3 ~= nil then
        self.mid_slot_3:DeleteMe()
    end
    if self.leftEquipSlot ~= nil then
        self.leftEquipSlot:DeleteMe()
    end
    if self.rightEquipSlot ~= nil then
        self.rightEquipSlot:DeleteMe()
    end
    if self.RightMarkSlot ~= nil then
        self.RightMarkSlot:DeleteMe()
    end
    if self.rightMarkEquipSlot ~= nil then
        self.rightMarkEquipSlot:DeleteMe()
    end

    if self.restoreFrozen_reset ~= nil then
        self.restoreFrozen_reset:DeleteMe()
    end
    if self.restoreFrozen_upgrade ~= nil then
        self.restoreFrozen_upgrade:DeleteMe()
    end

    if self.restoreFrozen_reset_small ~= nil then
        self.restoreFrozen_reset_small:DeleteMe()
    end
    if self.restoreFrozen_stone_upgrade ~= nil then
        self.restoreFrozen_stone_upgrade:DeleteMe()
    end

    self.myData = nil
    self.selectedEquipData = nil
    self.current_equip_index = 0

    self.hasClickUpdate = false--记录是否点击了升级按钮
    self.hasClickReset = false--记录是否点击了重置按钮
    self.leftEquipSlot = nil
    self.rightEquipSlot = nil
    self.RightMarkSlot = nil
    self.rightMarkEquipSlot = nil
    self.is_open = false
    self.myData = nil
    self.current_equip_index = 0
    self.selectedEquipData = nil

    self.is_open = false

    self.right_has_open = false
    self.right_stone_has_open = false
    self.right_mark_has_open = false
    self.last_opera = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuEquipWindow:InitPanel()
    self.is_open = true

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_equip_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuEquipWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.Panel_btn = self.transform:FindChild("Panel"):GetComponent(Button)

    self.Panel_btn.onClick:AddListener(function() self.model:CloseShouhuEquipUI() end)

    self.MainCon = self.transform:FindChild("MainCon").gameObject

    self.ContentCon = self.MainCon.transform:FindChild("ContentCon").gameObject
    local CloseBtn = self.ContentCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseShouhuEquipUI() end)
    self.closeBtn = CloseBtn

    self.leftArrowBtn = self.ContentCon.transform:FindChild("LeftArrowCon"):GetComponent(Button)
    self.rightArrowBtn = self.ContentCon.transform:FindChild("RightArrowCon"):GetComponent(Button)

    self.LeftCon = self.ContentCon.transform:FindChild("LeftCon").gameObject
    self.left_tips_con = self.ContentCon.transform:FindChild("TipsCon").gameObject
    self.tips_con_ly = self.left_tips_con.transform:GetComponent(LayoutElement)
    self.tips_prop_list = {}
    self.tips_prop_position_list = {}
    for i=1, 11 do
        local tips_prop = self.left_tips_con.transform:FindChild(string.format("Prop%s", i-1)):GetComponent(Text)
        table.insert(self.tips_prop_position_list, tips_prop.transform:GetComponent(RectTransform).anchoredPosition)
        table.insert(self.tips_prop_list, tips_prop)
    end
    self.left_tips_con:SetActive(false)
    self.TopCon = self.LeftCon.transform:FindChild("TopCon").gameObject
    self.ImgEye = self.TopCon.transform:FindChild("ImgEye"):GetComponent(Button)
    self.HeadCon = self.TopCon.transform:FindChild("HeadCon").gameObject
    self.TxtName = self.TopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.Txtlev = self.TopCon.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtScore = self.TopCon.transform:FindChild("TxtScore"):GetComponent(Text)
    self.BtnOpenRight = self.LeftCon.transform:FindChild("BtnUpdate"):GetComponent(Button)
    self.BtnMarkRight = self.LeftCon.transform:FindChild("BtnMark"):GetComponent(Button)
    self.BtnSet = self.LeftCon.transform:FindChild("BtnSet"):GetComponent(Button)
    self.BtnOpenRightTxt = self.BtnOpenRight.gameObject.transform:FindChild("Text"):GetComponent(Text)
    self.ImgPoint = self.BtnOpenRight.transform:FindChild("ImgPoint").gameObject
    self.StoneImgPoint = self.BtnSet.transform:FindChild("ImgPoint").gameObject

    self.RItem0 = self.LeftCon.transform:FindChild("Item0").gameObject
    self.tProp0=self.RItem0.transform:FindChild("Prop0"):GetComponent(Text)
    self.tProp1=self.RItem0.transform:FindChild("Prop1"):GetComponent(Text)
    self.tProp2=self.RItem0.transform:FindChild("Prop2"):GetComponent(Text)
    self.tProp3=self.RItem0.transform:FindChild("Prop3"):GetComponent(Text)
    self.tProp4=self.RItem0.transform:FindChild("Prop4"):GetComponent(Text)

    self.StonePropCon_Y = {26, 2, -24, -50, -74}
    self.StonePropCon = self.RItem0.transform:FindChild("StonePropCon")
    self.desc11=self.StonePropCon:FindChild("TxtDesc2"):GetComponent(Text)
    self.tProp5=self.StonePropCon:FindChild("Prop5"):GetComponent(Text)
    self.tProp6=self.StonePropCon:FindChild("Prop6"):GetComponent(Text)

    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)

    ----右边属性逻辑
    self.RightCon = self.ContentCon.transform:FindChild("RightCon").gameObject
    self.RightCon:SetActive(false)
    self.RTopCon = self.RightCon.transform:FindChild("TopCon").gameObject
    self.RHeadCon = self.RTopCon.transform:FindChild("HeadCon").gameObject
    self.RTxtName = self.RTopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.RTxtlev = self.RTopCon.transform:FindChild("TxtLev"):GetComponent(Text)

    self.RItem1 = self.RightCon.transform:FindChild("Item1").gameObject
    self.rightAttrItems = {}
    self.bProp0=self.RItem1.transform:FindChild("Prop0"):GetComponent(Text)
    self.bProp1=self.RItem1.transform:FindChild("Prop1"):GetComponent(Text)
    self.bProp2=self.RItem1.transform:FindChild("Prop2"):GetComponent(Text)
    self.bProp3=self.RItem1.transform:FindChild("Prop3"):GetComponent(Text)
    self.bProp4=self.RItem1.transform:FindChild("Prop4"):GetComponent(Text)
    for i=1,8 do
        table.insert(self.rightAttrItems, self.RItem1.transform:FindChild(string.format("Prop%s", i-1)):GetComponent(Text))
    end
    self.imgUp0 = self.bProp0.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)
    self.imgUp1 = self.bProp1.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)
    self.imgUp2 = self.bProp2.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)

    self.RBottomConRecommandTxt = self.RightCon.transform:FindChild("TxtRecommand"):GetComponent(Text)
    self.RBottomConTxtDesc = self.RightCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.RUpgradeCon = self.RightCon.transform:FindChild("UpgradeTipsCon").gameObject
    self.RUpgradeConTxt = self.RUpgradeCon.transform:FindChild("Text"):GetComponent(Text)
    self.RBottomCon = self.RightCon.transform:FindChild("BottomCon").gameObject
    self.BtnUpdate = self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Button)
    self.FullLevCon = self.RBottomCon.transform:FindChild("FullLevCon").gameObject
    -- Mark 守护装备胡洋要改的别问我
    self.FullLevText = self.FullLevCon.transform:FindChild("Text"):GetComponent(Text)
    self.TxtAutoLevUp = self.RBottomCon.transform:FindChild("TxtAutoLevUp"):GetComponent(Text)
    self.TxtAutoLevUp.gameObject:SetActive(false)
    self.ImgTanHao = self.RBottomCon.transform:FindChild("ImgTanHao"):GetComponent(Button)
    self.BtnUpdateUpgradeCon =self.BtnUpdate.gameObject.transform:FindChild("UpgradeCon").gameObject
    self.TxtCoinCost = self.BtnUpdateUpgradeCon.transform:FindChild("TxtNum"):GetComponent(Text)
    self.TxtUpdate = self.BtnUpdateUpgradeCon.transform:FindChild("Text"):GetComponent(Text)
    self.TxtUnOpen = self.BtnUpdate.gameObject.transform:FindChild("TxtUnOpen"):GetComponent(Text)
    self.BtnSave=self.RBottomCon.transform:FindChild("BtnSave"):GetComponent(Button)
    self.BtnReset=self.RBottomCon.transform:FindChild("BtnReset"):GetComponent(Button)
    self.BtnResetBig = self.RBottomCon.transform:FindChild("BtnResetBig"):GetComponent(Button)
    self.BtnResetBigTxt = self.BtnResetBig.gameObject.transform:FindChild("TxtNum"):GetComponent(Text)
    self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.RBottomCon.transform:FindChild("BtnSave"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    self.RBottomCon.transform:FindChild("BtnReset"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.BtnReset.gameObject:SetActive(false)
    self.BtnSave.gameObject:SetActive(false)

    self.RBottomCon:SetActive(false)
    if RoleManager.Instance.RoleData.lev >= 30 then --大于等于40才开启星阵
        self.RBottomCon.gameObject:SetActive(true)
    end

    ----右边刻印逻辑
    self.RightMarkSlotCon = self.ContentCon.transform:FindChild("MarkCon"):FindChild("SlotCon").gameObject
    self.RightMarkSlotTxtName = self.ContentCon.transform:FindChild("MarkCon"):FindChild("SlotCon"):FindChild("TxtName"):GetComponent(Text)
    self.RightMarkSlot = self:create_stone_slot(self.RightMarkSlotCon)
    self.RightMarkSillTxt = self.ContentCon.transform:FindChild("MarkCon"):FindChild("TxtDesc"):GetComponent(Text)
    self.RightMarkBtn =  self.ContentCon.transform:FindChild("MarkCon"):FindChild("BtnMark"):GetComponent(Button)
    self.RightMarkSaveBtn =  self.ContentCon.transform:FindChild("MarkCon"):FindChild("BtnSave"):GetComponent(Button)
    self.RightMarkEquipSlotCon = self.ContentCon.transform:FindChild("MarkCon"):FindChild("TopCon"):FindChild("HeadCon")
    self.RightMarkEquipNameTxt = self.ContentCon.transform:FindChild("MarkCon"):FindChild("TopCon"):FindChild("TxtName"):GetComponent(Text)
    self.RightMarkEquipLevTxt = self.ContentCon.transform:FindChild("MarkCon"):FindChild("TopCon"):FindChild("TxtLev"):GetComponent(Text)
    self.RightMarkCon = self.ContentCon.transform:FindChild("MarkCon").gameObject
    self.RightMarkCon:SetActive(false)

    ----右边宝石镶嵌逻辑
    self.RightCon_stone = self.ContentCon.transform:FindChild("RightConStone").gameObject
    self.RightCon_stone:SetActive(false)
    self.SlotCon1_stone = self.RightCon_stone.transform:FindChild("TopCon"):FindChild("SlotCon1").gameObject
    self.SlotCon2_stone = self.RightCon_stone.transform:FindChild("TopCon"):FindChild("SlotCon2").gameObject
    self.SlotCon1_stone_txt = self.SlotCon1_stone.transform:FindChild("Text"):GetComponent(Text)
    self.SlotCon2_stone_txt = self.SlotCon2_stone.transform:FindChild("Text"):GetComponent(Text)

    self.stone_mid_con = self.RightCon_stone.transform:FindChild("MidCon")
    self.mid_slot_con = self.stone_mid_con.transform:FindChild("SlotCon")
    self.mid_slot_con1 = self.mid_slot_con:FindChild("SlotCon1").gameObject
    self.mid_slot_txt_name_1 = self.mid_slot_con1.transform:FindChild("TxtName"):GetComponent(Text)
    self.mid_slot_txt_prop_1 = self.mid_slot_con1.transform:FindChild("TxtProp"):GetComponent(Text)
    self.mid_slot_con2 = self.mid_slot_con:FindChild("SlotCon2").gameObject
    self.mid_slot_txt_name_2 = self.mid_slot_con2.transform:FindChild("TxtName"):GetComponent(Text)
    self.mid_slot_txt_prop_2 = self.mid_slot_con2.transform:FindChild("TxtProp"):GetComponent(Text)
    self.mid_slot_con3 = self.mid_slot_con:FindChild("SlotCon3").gameObject
    self.mid_slot_txt_name_3 = self.mid_slot_con3.transform:FindChild("TxtName"):GetComponent(Text)
    self.mid_slot_txt_prop_3 = self.mid_slot_con3.transform:FindChild("TxtProp"):GetComponent(Text)

    self.stone_mid_con2 = self.RightCon_stone.transform:FindChild("MidCon2")
    self.stone_TxtType = self.stone_mid_con2:FindChild("TxtType"):GetComponent(Text)
    self.stone_TxtLev = self.stone_mid_con2:FindChild("TxtLev"):GetComponent(Text)
    self.stone_TxtProp = self.stone_mid_con2:FindChild("TxtProp"):GetComponent(Text)
    self.stone_TxtSet = self.stone_mid_con2:FindChild("TxtSet"):GetComponent(Text)
    self.stone_BtnRemove = self.stone_mid_con2:FindChild("BtnGet"):GetComponent(Button)

    self.stone_BottomCon = self.RightCon_stone.transform:FindChild("BottomCon")
    self.stone_btn_update = self.stone_BottomCon:FindChild("BtnUpdate"):GetComponent(Button)
    self.stone_btn_txt_num = self.stone_btn_update.transform:FindChild("TxtNum"):GetComponent(Text)
    self.stone_btn_txt_name = self.stone_btn_update.transform:FindChild("Text"):GetComponent(Text)
    self.stone_tanhao = self.stone_BottomCon:FindChild("ImgTanHao"):GetComponent(Button)

    -- 注册监听
    self.ImgEye.onClick:AddListener(function() self:on_click_eye_btn() end)
    self.BtnUpdate.onClick:AddListener(function() self:on_click_btn(1) end)
    self.BtnReset.onClick:AddListener(function() self:on_click_btn(2) end)
    self.BtnSave.onClick:AddListener(function() self:on_click_btn(3) end)
    self.BtnOpenRight.onClick:AddListener(function() self:on_click_btn(4) end)
    self.BtnResetBig.onClick:AddListener(function() self:on_click_btn(5) end)
    self.BtnSet.onClick:AddListener(function() self:on_click_btn(6) end)
    self.stone_btn_update.onClick:AddListener(function() self:on_click_btn(7) end)
    self.stone_BtnRemove.onClick:AddListener(function() self:on_click_btn(8) end)
    self.BtnMarkRight.onClick:AddListener(function() self:on_click_btn(9) end)
    self.leftArrowBtn.onClick:AddListener(function()  self:on_switch_left() end)
    self.rightArrowBtn.onClick:AddListener(function()  self:on_switch_right() end)
    self.ImgTanHao.onClick:AddListener(function()  self:on_click_tanhao() end)
    self.stone_tanhao.onClick:AddListener(function()  self:on_click_stone_tanhao() end)
    self.RightMarkBtn.onClick:AddListener(function()
        ShouhuManager.Instance:request10918(self.myData.base_id,self.selectedEquipData.type)
    end)
    self.RightMarkSaveBtn.onClick:AddListener(function()
        ShouhuManager.Instance:request10919(self.myData.base_id,self.selectedEquipData.type)
    end)
    self.restoreFrozen_reset = FrozenButton.New(self.BtnResetBig)
    self.restoreFrozen_upgrade = FrozenButton.New(self.BtnUpdate)
    self.restoreFrozen_reset_small = FrozenButton.New(self.BtnReset)
    self.restoreFrozen_stone_upgrade = FrozenButton.New(self.stone_btn_update)
    self:init_view()
    self:CheckGuide()
end

function ShouhuEquipWindow:on_click_eye_btn()
    self.show_tips = not self.show_tips
    self.left_tips_con:SetActive(self.show_tips)

    self.right_stone_has_open = false
    self.right_has_open = false
    self.right_mark_has_open = false
    self.RightCon_stone:SetActive(self.right_stone_has_open)
    self.RightCon:SetActive(self.right_has_open)
    self.RightMarkCon:SetActive(self.right_mark_has_open)
end

function ShouhuEquipWindow:init_view()
    self.myData=self.model.my_sh_selected_data

    if self.myData.sh_lev ~= nil and self.myData.sh_lev < 40 then
        self.BtnSet.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    else
        self.BtnSet.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    end

    --左边是当前等级，右边的下个等级
    for i=1, #self.myData.equip_list do
        local d = self.myData.equip_list[i]
        if d.base_id == self.model.my_sh_selected_equip.base_id then
            self.current_equip_index = i
            self.model.my_sh_selected_equip = d
        end
    end

    self:update_right_shuxing(self.model.my_sh_selected_equip)
    self:update_left(self.model.my_sh_selected_equip)
    self:update_right_stone_set(self.model.my_sh_selected_equip)
    self:update_mark_con(self.model.my_sh_selected_equip)
end

-- 更新界面
function ShouhuEquipWindow:update_view()
    if self.is_open == false then
        return
    end
    for i=1, #self.model.my_sh_list do
        local d = self.model.my_sh_list[i]
        if d.base_id==self.myData.base_id then
            self.model.my_sh_selected_data = d
            self.myData = d
        end
    end

    for i=1, #self.myData.equip_list do
        local ed = self.myData.equip_list[i]
        if ed.type==self.selectedEquipData.type then
            self:update_left(ed)
            self:update_right_shuxing(ed)
            self:update_right_stone_set(ed)
            self:update_mark_con(ed)
            return
        end
    end
end

---------------------------------------------监听逻辑
--点击左边切换按钮
function ShouhuEquipWindow:on_switch_left(g)
    self.current_equip_index = self.current_equip_index - 1
    if self.current_equip_index <= 0 then
        self.current_equip_index = #self.myData.equip_list
    end
    self.model.my_sh_selected_equip = self.myData.equip_list[self.current_equip_index]
    self:on_switch_help()
end

--点击右边切换按钮
function ShouhuEquipWindow:on_switch_right(g)
    self.current_equip_index = self.current_equip_index + 1
    if self.current_equip_index > #self.myData.equip_list then
        self.current_equip_index = 1
    end
    self.model.my_sh_selected_equip = self.myData.equip_list[self.current_equip_index]
    self:on_switch_help()
end

function ShouhuEquipWindow:on_switch_help()
    self.myData=self.model.my_sh_selected_data
    self:update_right_shuxing(self.model.my_sh_selected_equip)
    self:update_left(self.model.my_sh_selected_equip)
    self:update_right_stone_set(self.model.my_sh_selected_equip)
    self:update_mark_con(self.model.my_sh_selected_equip)
end


--点击叹号提示
function ShouhuEquipWindow:on_click_tanhao(g)
    -- print("--------------------------点击叹号拉")
end

--点击宝石镶嵌叹号提示
function ShouhuEquipWindow:on_click_stone_tanhao(g)
    print("--------------------------点击叹号拉")
    -- local tips = {}
    -- table.insert(tips, string.format(TI18N("1.升级装备可同时提升宝石等级上限")))
    -- table.insert(tips, string.format(TI18N("2.拆除宝石可重新镶嵌")))
    -- TipsManager.Instance:ShowText({gameObject = self.stone_tanhao.gameObject, itemData = tips})
    print("--------------dssss")
    self.model.cur_stone_look_dic = self.cur_can_eqm_list
    self.model:OpeStoneLookTips()
end

-- 按钮点击监听
function ShouhuEquipWindow:on_click_btn(index)
    if index == 1 then--升级按钮
        self.hasClickUpdate = true
        ShouhuManager.Instance:request10902(self.myData.base_id,self.selectedEquipData.type)
        self.last_opera = 1
    elseif index == 3 then
        if self.last_opera == 1 then
            self:switch_stone_prop_panel(1)
        end
        ShouhuManager.Instance:request10907(self.myData.base_id,self.selectedEquipData.type)
        self.last_opera = 2
    elseif index == 2 then
        self.hasClickReset = true
        ShouhuManager.Instance:request10902(self.myData.base_id,self.selectedEquipData.type)
        self.last_opera = 3
    elseif index == 4 then
        if self.canUpgrade == false then
            return
        end
        self.ImgPoint:SetActive(false)
        self:switch_stone_prop_panel(2)
        self.last_opera = 4
    elseif index == 5 then
        self.hasClickReset = true
        ShouhuManager.Instance:request10902(self.myData.base_id,self.selectedEquipData.type)
        self.last_opera = 5
    elseif index == 6 then
        if self.myData.sh_lev < 40 then
            NoticeManager.Instance:FloatTipsByString(TI18N("守护等级达到40级开启"))
            return
        end
        self.StoneImgPoint:SetActive(false)
        self.last_opera = 6
        self:switch_stone_prop_panel(3)
    elseif index == 7 then
        self.last_opera = 7
        --请求镶嵌或者宝石升级
        if self.stone_opera_type == nil then
            return
        end
        if self.stone_opera_type == 1 then --1是升级， 2是镶嵌
            ShouhuManager.Instance:request10911(self.myData.base_id, self.selectedEquipData.type, self.selected_stone_hole)
        elseif self.stone_opera_type == 2 then
            ShouhuManager.Instance:request10910(self.myData.base_id, self.selectedEquipData.type, self.selected_stone_hole, self.stone_opera_cfg_data.base_id)
        end
    elseif index == 8 then
        self.last_opera = 8
        --摘除
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("拆除宝石将<color='#ffff00'>不会退还</color>银币，确认是否要拆除宝石")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            ShouhuManager.Instance:request10912(self.myData.base_id, self.selectedEquipData.type, self.selected_stone_hole)
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif index == 9 then
        self.last_opera = 9
        self:switch_stone_prop_panel(4)
    end
end

--切换右边宝石/属性
function ShouhuEquipWindow:switch_stone_prop_panel(_type)
    self.show_tips = false
    self.left_tips_con:SetActive(self.show_tips)
    if _type == 1 then
        self.right_stone_has_open = false
        self.RightCon_stone:SetActive(self.right_stone_has_open)
        self.right_has_open = false
        self.RightCon:SetActive(self.right_has_open)
        self.right_mark_has_open = false
        self.RightMarkCon:SetActive(self.right_mark_has_open)
    elseif _type == 2 then
        self.right_stone_has_open = false
        self.RightCon_stone:SetActive(self.right_stone_has_open)
        self.right_has_open = not self.right_has_open
        self.RightCon:SetActive(self.right_has_open)
        self.right_mark_has_open = false
        self.RightMarkCon:SetActive(self.right_mark_has_open)
    elseif _type == 3 then
        self.right_stone_has_open = not self.right_stone_has_open
        self.RightCon_stone:SetActive(self.right_stone_has_open)
        self.right_has_open = false
        self.RightCon:SetActive(self.right_has_open)
        self.right_mark_has_open = false
        self.RightMarkCon:SetActive(self.right_mark_has_open)
    elseif _type == 4 then
        self.right_stone_has_open = false
        self.RightCon_stone:SetActive(self.right_stone_has_open)
        self.right_has_open = false
        self.RightCon:SetActive(self.right_has_open)
        self.right_mark_has_open = not self.right_mark_has_open
        self.RightMarkCon:SetActive(self.right_mark_has_open)
    end
end

function ShouhuEquipWindow:update_left(ed)
    if self.is_open == false then
        return
    end
    self.selectedEquipData = ed

    local cfgEqDat = self.model:get_equip_data_by_base_id( self.selectedEquipData.base_id)
    --道具图标
    if self.leftEquipSlot == nil then
        self.leftEquipSlot = ItemSlot.New()
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[cfgEqDat.base_id]
    cell:SetBase(itemData)

    self.leftEquipSlot:SetAll(cell, nil)
    self.leftEquipSlot.gameObject.transform:SetParent(self.HeadCon.transform)
    self.leftEquipSlot.gameObject.transform.localScale = Vector3.one
    self.leftEquipSlot.gameObject.transform.localPosition = Vector3.zero
    self.leftEquipSlot.gameObject.transform.localRotation = Quaternion.identity
    self.leftEquipSlot.noTips = true
    local rect = self.leftEquipSlot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    self.TxtName.text = itemData.name
    self.Txtlev.text=string.format("%s%s", TI18N("等级："), self.selectedEquipData.lev)
    local temp_attrs = {}
    for i=1,#ed.base_attrs do
        table.insert(temp_attrs, ed.base_attrs[i])
    end
    for i=1,#ed.ext_attrs do
        table.insert(temp_attrs, ed.ext_attrs[i])
    end
    self.TxtScore.text = string.format("%s%s", TI18N("评分："), BaseUtils.EquipPoint(temp_attrs))
    self.tProp0.text = ""
    self.tProp1.text=""
    self.tProp2.text=""
    self.tProp3.text=""
    self.tProp4.text=""
    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)
    self:update_left_prop()
end

function ShouhuEquipWindow:update_left_prop()
    if self.is_open == false then
        return
    end
    local index_1=0
    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(self.selectedEquipData.ext_attrs, temp_sort)
    table.sort(self.selectedEquipData.base_attrs, temp_sort)
    table.sort(self.selectedEquipData.eff_attrs, temp_sort)
    --基础属性
    local tips_list = {}
    for k,v in pairs(self.selectedEquipData.base_attrs) do
        local val_str = v.val > 0 and string.format("+%s", v.val) or tostring(v.val)
        local temp_txt = nil
        if index_1 == 0 then
            temp_txt = self.tProp0
        elseif index_1 == 1 then
            temp_txt = self.tProp1
        elseif index_1 == 2 then
            temp_txt = self.tProp2
        end
        if temp_txt ~= nil then
            table.insert(tips_list, v)
            temp_txt.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[v.name], val_str)
            index_1 = index_1 + 1
        end
    end

    local hasMinux = false --有负数
    for i = 1 , #self.selectedEquipData.ext_attrs do
        local d = self.selectedEquipData.ext_attrs[i]
        if d.val < 0 then
            hasMinux = true
            break
        end
    end
    if hasMinux then
        local temp_sort = function(a,b)
            return a.val > b.val
        end
        table.sort(self.selectedEquipData.ext_attrs, temp_sort)
    end

    ---额外属性
    local has_ext_attrs = false
    for k, v in pairs(self.selectedEquipData.ext_attrs) do
        local val_str = v.val > 0 and string.format("+%s", v.val) or tostring(v.val)
        local temp_txt = nil
        has_ext_attrs = true
        if index_1 == 1 then
            temp_txt = self.tProp1
        elseif index_1 == 2 then
            temp_txt = self.tProp2
        else
            temp_txt = self.tProp3
        end
        if temp_txt ~= nil then
            table.insert(tips_list, v)
            if temp_txt.text == "" then
                temp_txt.text = string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[v.name], val_str)
            else
                temp_txt.text = string.format("%s <color='#23F0F7'>%s%s</color>", temp_txt.text, KvData.attr_name[v.name], val_str)
            end
        end
    end

    -- 特效属性
    if has_ext_attrs then
        index_1 = index_1 + 1
    end
    local has_eff_attrs = false

    if self.selectedEquipData.timeout >= 0 then
        local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.selectedEquipData.timeout - BaseUtils.BASE_TIME)
        print(my_date)
        print( my_hour)
        print(my_minute)
        print(my_second)
        local timeStr = ""
        if my_date > 0 then
            if my_hour > 0 then
                my_date = my_date + 1
            end
            timeStr = string.format(TI18N("%s天"), my_date)
        elseif my_hour > 0 then
            timeStr = string.format(TI18N("%s小时"), my_hour)
        elseif my_minute > 0 or my_second > 0 then
            timeStr = TI18N("不到1小时")
        end
        if self.selectedEquipData.timeout == 0 then
            timeStr = TI18N("永久")
        end
        for k,v in pairs(self.selectedEquipData.eff_attrs) do
            has_eff_attrs = true
            local str = ""
            local temp_txt = nil
            has_ext_attrs = true
            if index_1 == 1 then
                temp_txt = self.tProp1
            elseif index_1 == 2 then
                temp_txt = self.tProp2
            elseif index_1 == 3 then
                temp_txt = self.tProp3
            elseif index_1 == 4 then
                temp_txt = self.tProp4
            end
            if temp_txt ~= nil then
                self.effectTxt = temp_txt
                local name_str = ""
                if v.name == 100 then
                    name_str = string.format("%s", DataSkill.data_skill_effect[v.val].name)
                else
                    name_str = KvData.attr_name[v.name]
                end
                if str ~= "" then
                    temp_txt.text = string.format("%s %s", str, string.format(TI18N("<color='#dc83f5'>%s         <color='#88E546'>剩余%s</color></color>"), name_str, timeStr))
                else
                    if self.selectedEquipData.timeout == 0 then
                        temp_txt.text = string.format(TI18N("<color='#dc83f5'>特效:%s                <color='#88E546'>永久</color></color>"), name_str)
                    else
                        temp_txt.text = string.format(TI18N("<color='#dc83f5'>特效:%s                <color='#88E546'>剩余%s</color></color> %s"), name_str, timeStr, temp_txt.text)
                    end
                end
                str = temp_txt.text
            end
        end
    end
    if has_eff_attrs then
        index_1 = index_1 + 1
    end

    --------------tips属性，tips里面不显示宝石属性
    --计算tips的高度
    local new_height_index = #self.selectedEquipData.base_attrs
    local new_height = 0
    if new_height_index == 1 then
        new_height = 106
    elseif new_height_index == 2 then
        new_height = 132
    elseif new_height_index == 3 then
        new_height = 156
    elseif new_height_index == 4 then
        new_height = 186
    end

    --清空上次tips
    for i=1,#self.tips_prop_list do
        self.tips_prop_list[i].text = ""
        self.tips_prop_list[i].transform:GetComponent(RectTransform).sizeDelta = Vector2(195, 25)
        self.tips_prop_list[i].transform:GetComponent(RectTransform).anchoredPosition = self.tips_prop_position_list[i]
    end

    --把配置中的可出现的特效加到tips_list中
    local effect_out_list = self.model:get_can_out_equip_effects(self.selectedEquipData.type, self.selectedEquipData.lev)
    local record_list = {}
    for i=1,#effect_out_list do
        local cfg_data = effect_out_list[i]
        if record_list[cfg_data.val] == nil then
            local temp_data = {type = GlobalEumn.ItemAttrType.effect, name = cfg_data.effect_type, val = cfg_data.val}
            table.insert(tips_list, temp_data)
        end
        record_list[cfg_data.val] = 1
    end

    local tips_index = 1
    local tips_effect_index = 1
    local tips_txt_offset_y = 0
    for i=1,#tips_list do
        local d = tips_list[i]
        local min, max = self.model:get_equip_wash_grade(d.name)
        local val = self.model.base_prop_vals[string.format("%s_%s", self.selectedEquipData.type, self.selectedEquipData.lev)][d.name]
        local temp_txt = nil
        if val ~= nil then
            --基础属性
            local val_str = d.val > 0 and string.format("+%s", d.val) or tostring(d.val)
            temp_txt = self.tips_prop_list[tips_index]

            if temp_txt ~= nil then
                tips_index = tips_index + 1
                temp_txt.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color> %s~%s", KvData.attr_name[d.name], val_str , Mathf.Round(val*min), Mathf.Round(val*max))
            end
        elseif d.type == GlobalEumn.ItemAttrType.effect then
            --特效属性
            temp_txt = self.tips_prop_list[tips_index]
            local name_str = ""
            if temp_txt ~= nil then
                if tips_effect_index == 1 then
                    tips_index = tips_index + 1
                    name_str = TI18N("<color='#ffff00'>可出现特效:</color>")
                    tips_effect_index = tips_effect_index + 1
                    temp_txt.text = name_str
                end
            end
            temp_txt = self.tips_prop_list[tips_index]
            if temp_txt ~= nil then
                tips_index = tips_index + 1
                local cfg_data = nil
                if d.name == 100 then
                    -- 技能
                    cfg_data = DataSkill.data_skill_effect[d.val]
                elseif d.name == 150 then
                -- 易强化
                    cfg_data = DataSkill.data_skill_effect[81019]
                elseif d.name == 151 then
                -- 易成长
                    cfg_data = DataSkill.data_skill_effect[81020]
                end
                name_str = string.format("<color='#dc83f5'>%s</color>:<color='#23F0F7'>%s</color>", cfg_data.name, cfg_data.desc)

                temp_txt.text = name_str
            end

            --自适应一下
            if temp_txt ~= nil then
                local cur_position = temp_txt.transform:GetComponent(RectTransform).anchoredPosition
                local line_num = 1
                if temp_txt.preferredWidth > 195 then
                    line_num = math.ceil(temp_txt.preferredWidth/195)
                    temp_txt.transform:GetComponent(RectTransform).sizeDelta = Vector2(195, line_num*20)
                else
                    temp_txt.transform:GetComponent(RectTransform).sizeDelta = Vector2(195, 20)
                end
                new_height = new_height + line_num*22
                local new_y = cur_position.y + tips_txt_offset_y
                temp_txt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(cur_position.x, new_y)
                tips_txt_offset_y = tips_txt_offset_y - (line_num-1)*20
            end
        end
    end
    self.tips_con_ly.preferredWidth = 250
    self.tips_con_ly.preferredHeight = 402 --new_height

    -------------宝石属性
    self.StonePropCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, self.StonePropCon_Y[index_1])
    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)


    if #self.selectedEquipData.gem > 0 then
        self.desc11.gameObject:SetActive(true)
        self.tProp5.gameObject:SetActive(true)
        self.tProp6.gameObject:SetActive(true)
        self.tProp5.text = ""
        self.tProp6.text = ""
    end
    for i=1,#self.selectedEquipData.gem do
        local d = self.selectedEquipData.gem[i]
        local cfg_data = DataShouhu.data_guard_stone_prop[d.base_id]
        if i==1 then
            self.tProp5.text = string.format("<color='#23F0F7'>%s+%s   (%s%s%s)</color>", KvData.attr_name[cfg_data.attrs[1].attr], cfg_data.attrs[1].val, cfg_data.lev, TI18N("级") , cfg_data.name)
        elseif i ==2 then
            self.tProp6.text = string.format("<color='#23F0F7'>%s+%s   (%s%s%s)</color>", KvData.attr_name[cfg_data.attrs[1].attr], cfg_data.attrs[1].val, cfg_data.lev, TI18N("级") , cfg_data.name)
        end
    end
end

-----------------更新刻印逻辑
function ShouhuEquipWindow:update_mark_con(ed)
    --把配置中的可出现的特效加到tips_list中
    if ed.lev < 70 then
        return
    end
    --道具图标
    local cfgEqDat = self.model:get_equip_data_by_base_id( self.selectedEquipData.base_id)
    --道具图标
    if self.rightMarkEquipSlot == nil then
        self.rightMarkEquipSlot = ItemSlot.New()
        self.rightMarkEquipSlot.gameObject.transform:SetParent(self.RightMarkEquipSlotCon)
        self.rightMarkEquipSlot.gameObject.transform.localScale = Vector3.one
        self.rightMarkEquipSlot.gameObject.transform.localPosition = Vector3.zero
        self.rightMarkEquipSlot.gameObject.transform.localRotation = Quaternion.identity
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[cfgEqDat.base_id]
    cell:SetBase(itemData)
    self.rightMarkEquipSlot:SetAll(cell, nil)
    self.rightMarkEquipSlot.noTips = true
    local rect = self.rightMarkEquipSlot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    self.RightMarkEquipNameTxt.text = itemData.name
    self.RightMarkEquipLevTxt .text=string.format("%s%s", TI18N("等级："), self.selectedEquipData.lev)

    if self.selectedEquipData.back_effect_timeout > 0 and #self.selectedEquipData.back_effect_attr > 0 then
        self:OnSwitchMarkSaveBtn(true)
    else
        self:OnSwitchMarkSaveBtn(false)
    end

    local cfg_data = nil
    if self.selectedEquipData.back_effect_timeout > 0 then
        --有的保存
        local eff_attrs = self.selectedEquipData.back_effect_attr
        if #eff_attrs > 0 then
            for k,v in pairs(eff_attrs) do
                if v.name == 100 then -- 技能
                    -- local id = self.model:get_can_out_equip_effects_skill(ed.type, ed.lev, 100)
                    -- if id ~= 0 then
                    --     cfg_data = DataSkill.data_skill_effect[id]
                    -- end
                    cfg_data = DataSkill.data_skill_effect[v.val]
                elseif v.name == 150 then -- 易强化
                    cfg_data = DataSkill.data_skill_effect[81019]
                elseif v.name == 151 then -- 易成长
                    cfg_data = DataSkill.data_skill_effect[81020]
                end
            end
        end

        -- local tips_list = {}
        -- local record_list = {}
        -- local effect_out_list = self.model:get_can_out_equip_effects(ed.type, ed.lev)
        -- local descStr = ""
        -- for i=1,#effect_out_list do
        --     local cfg_data = effect_out_list[i]
        --     if record_list[cfg_data.val] == nil then
        --         if cfg_data.effect_type == 100 then -- 技能
        --             cfg_data = DataSkill.data_skill_effect[cfg_data.val]
        --         elseif cfg_data.effect_type == 150 then -- 易强化
        --             cfg_data = DataSkill.data_skill_effect[81019]
        --         elseif cfg_data.effect_type == 151 then -- 易成长
        --             cfg_data = DataSkill.data_skill_effect[81020]
        --         end
        --         if descStr ==  "" then
        --             descStr = string.format("<color='#dc83f5'>%s</color>:<color='#23F0F7'>%s</color>", cfg_data.name, cfg_data.desc)
        --         else
        --             local tempStr = string.format("<color='#dc83f5'>%s</color>:<color='#23F0F7'>%s</color>", cfg_data.name, cfg_data.desc)
        --             descStr = string.format("%s\n\n%s", descStr, tempStr)
        --         end
        --     end
        --     record_list[cfg_data.val] = 1
        -- end
    end
    if cfg_data == nil then
        self.RightMarkSillTxt.text = TI18N("<color='#dc83f5'>特效+??</color>")--descStr
    else
        local curEffectStr = string.format("<color='#dc83f5'>%s</color>:<color='#23F0F7'>%s</color>", cfg_data.name, cfg_data.desc)
        self.RightMarkSillTxt.text = string.format("<color='#dc83f5'>%s %s</color>\n%s", TI18N("特效"), cfg_data.name, curEffectStr)
    end


    local cfgData = DataShouhu.data_guard_mark[string.format("%s_%s", ed.type, ed.lev)]
    local needNum = cfgData.loss[1][2]
    local hasNum = BackpackManager.Instance:GetItemCount(cfgData.loss[1][1])
    self:set_stone_slot_data(self.RightMarkSlot, cfgData.loss[1][1])
    self.RightMarkSlot:SetNum(hasNum, needNum)
    self.RightMarkSlot.noTips = false
    self.RightMarkSlotTxtName.text = DataItem.data_get[cfgData.loss[1][1]].name
end

--切换刻印保存按钮
function ShouhuEquipWindow:OnSwitchMarkSaveBtn(state)
    if state then
        --显示保存按钮
        self.RightMarkBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(70, -160.8)
        self.RightMarkSaveBtn.gameObject:SetActive(true)
    else
        self.RightMarkBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -160.8)
        self.RightMarkSaveBtn.gameObject:SetActive(false)
    end
end

-----------------更新镶嵌逻辑
function ShouhuEquipWindow:update_right_stone_set(ed)

    if self.model:check_equip_can_stone(ed) == true then
        self.StoneImgPoint:SetActive(true)
    else
        self.StoneImgPoint:SetActive(false)
    end

    --创建顶部两个宝石图标
    if self.stone_slot_1 == nil then
        self.stone_slot_1 = self:create_stone_slot(self.SlotCon1_stone)
    end

    if self.stone_slot_2 == nil then
        self.stone_slot_2 = self:create_stone_slot(self.SlotCon2_stone)
    end

    self.stone_slot_1:SetAll(nil, nil)
    self.stone_slot_2:SetAll(nil, nil)


    local left_can_stone = true
    local right_can_stone = true

    if self.myData.sh_lev < 40 then
        left_can_stone = false
        self.stone_slot_1:ShowAddBtn(false)
        self.stone_slot_1:ShowLock(true)
        self.stone_slot_1:SetAddCallback(nil)
        self.stone_slot_1:SetLockCallback(function()  end)
        self.SlotCon1_stone_txt.text = TI18N("40级开启")

    else
        left_can_stone = true
        self.stone_slot_1:ShowAddBtn(true)
        self.stone_slot_1:ShowLock(false)
        self.stone_slot_1:SetLockCallback(nil)
        self.stone_slot_1:SetAddCallback(function()
            local gem_data = self.model:get_equip_eqm_id_data(ed , 1)
            self:on_switch_stone_hole(gem_data, 1)
        end)
        self.SlotCon1_stone_txt.text = TI18N("可镶嵌宝石")
    end

    if self.myData.sh_lev < 60 then
        right_can_stone = false
        self.stone_slot_2:ShowAddBtn(false)
        self.stone_slot_2:ShowLock(true)
        self.stone_slot_2:SetAddCallback(nil)
        self.stone_slot_2:SetLockCallback(function()  end)
        self.SlotCon2_stone_txt.text = TI18N("60级开启")
    else
        right_can_stone = true
        self.stone_slot_2:ShowAddBtn(true)
        self.stone_slot_2:ShowLock(false)
        self.stone_slot_2:SetLockCallback(nil)
        self.stone_slot_2:SetAddCallback(function()
            local gem_data = self.model:get_equip_eqm_id_data(ed , 2)
            self:on_switch_stone_hole(gem_data, 2)
        end)
        self.SlotCon2_stone_txt.text = TI18N("可镶嵌宝石")
    end

    for i=1, #ed.gem do
        local gem_data = ed.gem[i]
        if gem_data.id == 1 then
            left_can_stone = false
            self.stone_slot_1:ShowAddBtn(false)
            self.stone_slot_1:ShowLock(false)
            self:set_stone_slot_data(self.stone_slot_1, gem_data.base_id)

            self.stone_slot_1:SetSelectSelfCallback(function()
                self:on_switch_stone_hole(gem_data, 1)
            end)
            local gen_cfg_data = DataShouhu.data_guard_stone_prop[gem_data.base_id]
            self.SlotCon1_stone_txt.text = string.format("<color='#C7F9FF'>%sLv.%s</color>", gen_cfg_data.name, gen_cfg_data.lev)
        elseif gem_data.id == 2 then
            right_can_stone = false
            self.stone_slot_2:ShowAddBtn(false)
            self.stone_slot_2:ShowLock(false)
            self:set_stone_slot_data(self.stone_slot_2, gem_data.base_id)

            self.stone_slot_2:SetSelectSelfCallback(function()
                self:on_switch_stone_hole(gem_data, 2)
            end)
            local gen_cfg_data = DataShouhu.data_guard_stone_prop[gem_data.base_id]
            self.SlotCon2_stone_txt.text = string.format("<color='#C7F9FF'>%sLv.%s</color>", gen_cfg_data.name, gen_cfg_data.lev)
        end
    end

     --创建中间宝石图标
    if self.mid_slot_1 == nil then
        self.mid_slot_1 = self:create_stone_slot(self.mid_slot_con1)
    end
    if self.mid_slot_2 == nil then
        self.mid_slot_2 = self:create_stone_slot(self.mid_slot_con2)
    end
    if self.mid_slot_3 == nil then
        self.mid_slot_3 = self:create_stone_slot(self.mid_slot_con3)
    end
    self.mid_slot_con1:SetActive(false)
    self.mid_slot_con2:SetActive(false)
    self.mid_slot_con3:SetActive(false)

    --初始化中间三个slot
    self.cur_can_eqm_list = self.model:get_equip_can_eqm_stone(ed)
    local mid_num =0
    for i=1,#self.cur_can_eqm_list do
        local allow_data = self.cur_can_eqm_list[i]
        local temp_data = self.model:get_stone_cfg_data(allow_data.type)
        if i==1 then
            self.mid_slot_con1:SetActive(true)
            self:set_stone_slot_data(self.mid_slot_1, temp_data.base_id)
            self.mid_slot_1:SetSelectSelfCallback(function()
                self:on_select_stone(self.mid_slot_1, 1, temp_data)
            end)
            self.mid_slot_txt_name_1.text = temp_data.name
            self.mid_slot_txt_prop_1.text = string.format("%s+%s", KvData.attr_name[temp_data.attrs[1].attr], temp_data.attrs[1].val)
        elseif i==2 then
            self.mid_slot_con2:SetActive(true)
            self:set_stone_slot_data(self.mid_slot_2, temp_data.base_id)
            self.mid_slot_2:SetSelectSelfCallback(function()
                self:on_select_stone(self.mid_slot_2, 2, temp_data)
            end)
            self.mid_slot_txt_name_2.text = temp_data.name
            self.mid_slot_txt_prop_2.text = string.format("%s+%s", KvData.attr_name[temp_data.attrs[1].attr], temp_data.attrs[1].val)
        elseif i==3 then
            self.mid_slot_con3:SetActive(true)
            self:set_stone_slot_data(self.mid_slot_3, temp_data.base_id)
            self.mid_slot_3:SetSelectSelfCallback(function()
                self:on_select_stone(self.mid_slot_3, 3, temp_data)
            end)
            self.mid_slot_txt_name_3.text = temp_data.name
            self.mid_slot_txt_prop_3.text = string.format("%s+%s", KvData.attr_name[temp_data.attrs[1].attr], temp_data.attrs[1].val)
        end
        mid_num = i
    end

    --做居中处理
    if mid_num == 1 then
        self.mid_slot_con:GetComponent(RectTransform).anchoredPosition = Vector2(80, -15.55)
    elseif mid_num == 2 then
        self.mid_slot_con:GetComponent(RectTransform).anchoredPosition = Vector2(40, -15.55)
    elseif mid_num == 3 then
        self.mid_slot_con:GetComponent(RectTransform).anchoredPosition = Vector2(0, -15.55)
    end

    --默认选中第一个孔
    -- 自动跳到没镶嵌的空的逻辑暂时不要了
    -- if left_can_stone == true and right_can_stone == false then
    --     local gem_data = self.model:get_equip_eqm_id_data(ed , 1)
    --     self:on_switch_stone_hole(gem_data, 1)
    -- elseif left_can_stone == false and right_can_stone == true then
    --     local gem_data = self.model:get_equip_eqm_id_data(ed , 2)
    --     self:on_switch_stone_hole(gem_data, 2)
    -- else
    if self.selected_stone_hole == nil then
        local gem_data = self.model:get_equip_eqm_id_data(ed , 1)
        self:on_switch_stone_hole(gem_data, 1)
    else
        local gem_data = self.model:get_equip_eqm_id_data(ed , self.selected_stone_hole)
        self:on_switch_stone_hole(gem_data, self.selected_stone_hole)
    end
end

--切换宝石空位
function ShouhuEquipWindow:on_switch_stone_hole(gem_data, index)
    self.selected_stone_hole = index
    self.stone_slot_1:ShowSelect(false)
    self.stone_slot_2:ShowSelect(false)
    if self.selected_stone_hole == 1 then
        self.stone_slot_1:ShowSelect(true)
    elseif self.selected_stone_hole == 2 then
        self.stone_slot_2:ShowSelect(true)
    end

    if gem_data == nil then
        --选中的孔没有宝石镶嵌
        self.stone_mid_con.gameObject:SetActive(true)
        self.stone_mid_con2.gameObject:SetActive(false)

        --默认选中第一个宝石
        local allow_data = self.cur_can_eqm_list[1]
        local temp_data = self.model:get_stone_cfg_data(allow_data.type)
        self:on_select_stone(self.mid_slot_1, 1, temp_data)

        self.stone_btn_txt_name.text = TI18N("镶嵌")
    else
        --选中的孔有宝石镶嵌
        self.stone_mid_con.gameObject:SetActive(false)
        self.stone_mid_con2.gameObject:SetActive(true)

        --根据gem_data获取该空位宝石的属性值
        local cfg_data = DataShouhu.data_guard_stone_prop[gem_data.base_id]
        local equip_types = self.model:get_stone_equip_type(gem_data.type)
        self.stone_TxtType.text = string.format("%s:%s", TI18N("类型"), cfg_data.name)
        self.stone_TxtLev.text = string.format("%s:%s%s", TI18N("等级"), cfg_data.lev, TI18N("级"))
        self.stone_TxtProp.text = string.format("%s:<color='#23F0F7'>%s+%s</color>", TI18N("属性"), KvData.attr_name[cfg_data.attrs[1].attr], cfg_data.attrs[1].val)

        local equip_names = DataShouhu.data_guard_stone_type[cfg_data.type].allow
        local name_str = ""
        for i=1,#equip_names do
            local eqn = BackpackEumn.ItemTypeName[equip_names[i].eqm_type]
            if i==1 then
                name_str = eqn
            else
                name_str = string.format("%s、%s", name_str, eqn)
            end
        end
        self.stone_TxtSet.text = string.format("%s:%s", TI18N("镶嵌"), name_str)
        self:set_current_selected_stone_data(cfg_data, 1)

        self.stone_btn_txt_name.text = TI18N("升级")
    end

end

--选择要镶嵌或者升级的宝石
function ShouhuEquipWindow:on_select_stone(select_slot, index, cfg_data)
    if self.mid_slot_1 ~= nil then
        self.mid_slot_1:ShowSelect(false)
    end
    if self.mid_slot_2 ~= nil then
        self.mid_slot_2:ShowSelect(false)
    end
    if self.mid_slot_3 ~= nil then
        self.mid_slot_3:ShowSelect(false)
    end
    select_slot:ShowSelect(true)
    self:set_current_selected_stone_data(cfg_data, 2)
end

--设置当前要升级或者要镶嵌的宝石的数据
function ShouhuEquipWindow:set_current_selected_stone_data(cfg_data, _type)
    self.stone_opera_type = _type --1是升级， 2是镶嵌
    self.stone_opera_cfg_data = cfg_data --要镶嵌或者升级的宝石的配置data

    if self.stone_opera_type == 1 then
        local next_cfg_data = DataShouhu.data_guard_stone_prop[cfg_data.next_base_id]
        if next_cfg_data ~= nil then
            self.stone_btn_txt_num.text = tostring(next_cfg_data.loss_coin[1].val)
            self.stone_btn_update.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.stone_btn_update.enabled = true
        else
            self.stone_btn_txt_num.text = TI18N("已达最高等级")
            self.stone_btn_update.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.stone_btn_update.enabled = false
        end
    else
        self.stone_btn_txt_num.text = tostring(cfg_data.loss_coin[1].val)
        self.stone_btn_update.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.stone_btn_update.enabled = true
    end
end

--创建宝石道具格子
function ShouhuEquipWindow:create_stone_slot(slot_con)
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

--设置宝石道具各自数据
function ShouhuEquipWindow:set_stone_slot_data(slot, base_id)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
    slot:SetNotips(true)
end

-----------------更新属性逻辑
function ShouhuEquipWindow:update_right_shuxing(ed)
    if self.is_open == false then
        return
    end

    self.RBottomConRecommandTxt.text = ""
    self.selectedEquipData = ed
    local curlev = self.selectedEquipData.lev

    local roleLev = RoleManager.Instance.RoleData.lev
    if RoleManager.Instance.RoleData.lev_break_times ~= 0 then
        --突破过了
        if roleLev < 100 then
            roleLev = 100
        end
    end
    local nextUpgradelev = math.floor(roleLev/10)*10
    nextUpgradelev = nextUpgradelev < 10 and 10 or nextUpgradelev

    local nextShowlev = nextUpgradelev
    if nextShowlev == curlev then
        nextShowlev = curlev + 10
    end
    if nextShowlev > roleLev then
        nextShowlev = math.floor(roleLev/10)*10
    end
    if nextShowlev > self.model.equipMaxLev then
        nextShowlev = self.model.equipMaxLev
    end

    local cfgEqDat = self.model:get_equip_data_by_base_id(self.selectedEquipData.base_id)

    self.TxtCoinCost.text= tostring(0)
    self.BtnResetBigTxt.text= tostring(0)
    self.TxtUnOpen.text = ""
    self.BtnUpdateUpgradeCon:SetActive(true)

    for k, v in pairs(self.rightAttrItems) do
        v.text = ""
        v.gameObject.transform:FindChild("ImgUp").gameObject:SetActive(false)
    end

    self.FullLevCon:SetActive(false)
    self.BtnUpdate.gameObject:SetActive(false)
    self.BtnReset.gameObject:SetActive(false)
    self.BtnSave.gameObject:SetActive(false)
    self.BtnResetBig.gameObject:SetActive(false)
    self.RUpgradeCon:SetActive(false)
    self.TxtAutoLevUp.gameObject:SetActive(false)
    self.ImgPoint:SetActive(false)

    self.canUpgrade = true
    self.RBottomConTxtDesc.text = ""
    if nextUpgradelev < 30 then --小于三十级自动升级
        self.RBottomCon.gameObject:SetActive(true)
        self.TxtAutoLevUp.gameObject:SetActive(true)

        self:upate_right_prop()
    else--可以重置或者升级
        self.RBottomCon.gameObject:SetActive(true)
        self.TxtUnOpen.text = ""

        print("dddddddddddddddddddddddddddddddddddd")
        print(nextUpgradelev)
        print(curlev)

        if nextUpgradelev-curlev>= self.model.init_equip_lev then--可以升级
                local roleLev = RoleManager.Instance.RoleData.lev
                print("------------------------dddddd")
                if roleLev >= ShouhuManager.Instance.maxRoleLev and curlev == ShouhuManager.Instance.maxRoleLev then
                    --不能升级
                    self.canUpgrade = false
                     self.FullLevCon:SetActive(true)
                     --不可提升，不可升级，显示升级按灰掉
                     self.RBottomConTxtDesc.text = ""

                     if self.selectedEquipData.lev >= 70 then
                         self.BtnOpenRight.gameObject:SetActive(false)
                         self.BtnMarkRight.gameObject:SetActive(true)
                         if self.last_opera == 4 or self.last_opera == 1 then
                             self.last_opera = 9
                             self:switch_stone_prop_panel(4)
                         end
                     end

                     self.BtnOpenRightTxt.text = TI18N("升 级")
                     self.BtnOpenRight.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                     self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Button).image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                     self.BtnUpdateUpgradeCon:SetActive(false)
                     if nextShowlev <= roleLev then
                         nextShowlev = math.floor(roleLev/10)*10 + 10
                     end
                     if nextShowlev > self.model.equipMaxLev then
                         nextShowlev = self.model.equipMaxLev
                     end

                     -- Mark 守护装备胡洋要改的别问我
                     if curlev >= self.model.equipMaxLev then
                         self.FullLevText.text = TI18N("装备已满级")
                     else
                         self.FullLevText.text = string.format(TI18N("%s级可升级"), nextShowlev)
                     end
                else
                    self.RBottomCon.gameObject:SetActive(true)
                    self.BtnUpdate.gameObject:SetActive(true)
                    self.BtnOpenRightTxt.text = TI18N("升 级")
                    self.TxtUpdate.text = TI18N("升级")
                    if not self.right_has_open then
                        self.ImgPoint:SetActive(true)
                    end
                    self.BtnOpenRight.gameObject:SetActive(true)
                    self.BtnMarkRight.gameObject:SetActive(false)
                    if self.last_opera == 9 then
                        self.last_opera = 4
                        self:switch_stone_prop_panel(2)
                    end
                    self.BtnOpenRight.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                    self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Button).image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.TxtUnOpen.text = ""
                    self.RBottomConTxtDesc.text = TI18N("<color='#00ff00'>升级</color>后可获得上方属性")
                end
        else
            print("----------------------dddd")
            if self.selectedEquipData.is_init == 0 then
                self.BtnUpdate.gameObject:SetActive(true)
                --可以提升
                self.BtnOpenRightTxt.text = TI18N("提 升")
                self.TxtUpdate.text = TI18N("提升")
                if not self.right_has_open then
                    self.ImgPoint:SetActive(true)
                end
                self.BtnOpenRight.gameObject:SetActive(true)
                self.BtnMarkRight.gameObject:SetActive(false)
                if self.last_opera == 9 then
                    self.last_opera = 4
                    print("--------------------2")
                    self:switch_stone_prop_panel(2)
                end
                self.BtnOpenRight.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Button).image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.RUpgradeCon:SetActive(true)

                if #self.selectedEquipData.eff_attrs > 0 then
                    self.RUpgradeConTxt.text = "<color='#00ff00'>提升</color>后将获得以上<color='#00ff00'>固定属性</color>\n装备属性不再需要重置\n<color='#ffff00'>(装备特效不再保留)</color>"
                else
                    self.RUpgradeConTxt.text = "<color='#00ff00'>提升</color>后将获得以上<color='#00ff00'>固定属性</color>\n装备属性不再需要重置"
                end
            else
                self.canUpgrade = false
                self.FullLevCon:SetActive(true)
                --不可提升，不可升级，显示升级按灰掉
                self.RBottomConTxtDesc.text = ""

                print("--------------------3")
                if self.selectedEquipData.lev >= 70 then
                    self.BtnOpenRight.gameObject:SetActive(false)
                    self.BtnMarkRight.gameObject:SetActive(true)
                    if self.last_opera == 4 or self.last_opera == 1 then
                        self.last_opera = 9
                        self:switch_stone_prop_panel(4)
                    end
                end

                self.BtnOpenRightTxt.text = TI18N("升 级")
                self.BtnOpenRight.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.RBottomCon.transform:FindChild("BtnUpdate"):GetComponent(Button).image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.BtnUpdateUpgradeCon:SetActive(false)
                if nextShowlev <= roleLev then
                    nextShowlev = math.floor(roleLev/10)*10 + 10
                end
                if nextShowlev > self.model.equipMaxLev then
                    nextShowlev = self.model.equipMaxLev
                end

                -- Mark 守护装备胡洋要改的别问我
                if curlev >= self.model.equipMaxLev then
                    self.FullLevText.text = TI18N("装备已满级")
                else
                    self.FullLevText.text = string.format(TI18N("%s级可升级"), nextShowlev)
                end
            end
        end
        local nextCfgDat = DataShouhu.data_guard_equip_cfg_two[string.format("%s_%s_%s", nextShowlev, cfgEqDat.classes, cfgEqDat.type)]
        --道具图标
         self.RTxtlev.text=string.format("%s%s", TI18N("等级："), nextShowlev)
        if self.rightEquipSlot == nil then
            self.rightEquipSlot = ItemSlot.New()
        end

        local cell = ItemData.New()
        local itemData = DataItem.data_get[nextCfgDat.base_id]  --
        cell:SetBase(itemData)
        self.rightEquipSlot:SetAll(cell, nil)
        self.rightEquipSlot.gameObject.transform:SetParent(self.RHeadCon.transform)
        self.rightEquipSlot.gameObject.transform.localScale = Vector3.one
        self.rightEquipSlot.gameObject.transform.localPosition = Vector3.zero
        self.rightEquipSlot.gameObject.transform.localRotation = Quaternion.identity
        self.rightEquipSlot.noTips = true
        local rect = self.rightEquipSlot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one
        self.RTxtName.text=itemData.name

        local lossNum = nextCfgDat.loss_coin
        if nextShowlev < RoleManager.Instance.world_lev - 5 then
            lossNum = Mathf.Round(lossNum*0.5)
        end
        self.TxtCoinCost.text= tostring(lossNum)
        self.BtnResetBigTxt.text= tostring(nextCfgDat.loss_coin)
         --显示的属性列表
        local attrList = {}
        local cfgAttrData = DataShouhu.data_guard_attr_prop[string.format("%s_%s", cfgEqDat.type, cfgEqDat.classes)]
        local baseAttrStepDic = {}
        for k, v in pairs(DataShouhu.data_guard_base_grade)  do
            if cfgAttrData.base_flag == v.step then
                baseAttrStepDic[v.attr_name] = v
            end
        end
        local baseAttrValList = self.model.base_prop_vals[string.format("%s_%s", cfgEqDat.type, nextShowlev)]
        for k, v in pairs(baseAttrValList) do
            if baseAttrStepDic[k] ~= nil then
                table.insert(attrList, {type = 1,name = k, val = v*baseAttrStepDic[k].ratio/1000})
            end
        end
        local extrAttrVal = DataShouhu.data_guard_extr_val[nextShowlev].val
        local extrAttrTypeData = DataShouhu.data_guard_extr_type[cfgAttrData.step_type]
        local extrAttrStepData = DataShouhu.data_guard_extr_step[cfgAttrData.step]
        table.insert(attrList, {type = 2, name = cfgAttrData.point_type1, val = extrAttrVal*(extrAttrTypeData.val1/1000)*(extrAttrStepData.ratio/1000)})
        table.insert(attrList, {type = 2, name = cfgAttrData.point_type2, val = extrAttrVal*(extrAttrTypeData.val2/1000)*(extrAttrStepData.ratio/1000)})
        self:update_right_attr_show(attrList)
    end

    self.hasClickReset = false
end

local check_has_attr = function(_table, name)
    for i=1, #_table do
        local it = _table[i]
        if it.attr == name then
            return true
        end
    end
    return false
end

-- 更新右部数据显示
function ShouhuEquipWindow:update_right_attr_show(attrList)
    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(attrList, temp_sort)

    local index = 1
    for i = 1 , #attrList do
        local d = attrList[i]
        if d.type == 1 and d.val ~= 0 then --基础属性
            local item = self.rightAttrItems[index]
            local imgUp = item.gameObject.transform:FindChild("ImgUp").gameObject
            if d.val > 0 then
                item.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>+%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val))
            else
                item.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val))
            end
            index = index + 1
            self:check_up_and_down(item, imgUp, d, self.selectedEquipData.base_attrs)
        end
    end

    local hasMinux = false --有负数
    for i = 1 , #attrList do
        local d = attrList[i]
        if d.val < 0 then
            hasMinux = true
            break
        end
    end
    if hasMinux then
        local temp_sort = function(a,b)
            return a.val > b.val
        end
        table.sort(attrList, temp_sort)
    end
    local showStr = ""
    for i = 1 , #attrList do
        local d = attrList[i]
        if d.type == 2 and d.val ~= 0 then --额外属性
            if showStr ~= "" then
                if d.val > 0 then
                    showStr = string.format("%s %s", showStr, string.format("<color='#23F0F7'>%s+%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val)))
                else
                    showStr = string.format("%s %s", showStr, string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val)))
                end
            else
                if d.val > 0 then
                    showStr = string.format("<color='#23F0F7'>%s+%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val))
                else
                    showStr = string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[d.name], Mathf.Round(d.val))
                end
            end
        end
    end

    --
    self.rightAttrItems[index].text = showStr
end

-- 更新底部配置数据
function ShouhuEquipWindow:upate_right_prop(showType)
    if self.is_open == false then
        return
    end

    local index_1 = 0

    local reset_base_attrs = self.selectedEquipData.reset_base_attrs_next
    local reset_ext_attrs = self.selectedEquipData.reset_ext_attrs_next
    local reset_eff_attrs = self.selectedEquipData.reset_eff_attrs_next

    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(reset_ext_attrs, temp_sort)
    table.sort(reset_base_attrs, temp_sort)

    self.imgUp0.gameObject:SetActive(false)
    self.imgUp1.gameObject:SetActive(false)

    if (reset_base_attrs == nil or #reset_base_attrs == 0) and (reset_ext_attrs == nil or #reset_ext_attrs == 0) and (reset_eff_attrs == nil or #reset_eff_attrs == 0) then
        --把配置中的可出现的特效加到tips_list中
        local tips_list = {}
        for k, v in pairs(self.selectedEquipData.base_attrs) do
            table.insert(tips_list, v)
        end

        table.sort(tips_list, temp_sort)

        local tips_index = 0
        for i=1,#tips_list do
            local d = tips_list[i]
            local min, max = self.model:get_equip_wash_grade(d.name)
            local val = self.model.base_prop_vals[string.format("%s_%s", self.selectedEquipData.type, self.selectedEquipData.lev)][d.name]
            if val ~= nil then
                --基础属性
                local val_str = d.val > 0 and string.format("+%s", d.val) or tostring(d.val)
                if tips_index == 0 then
                    self.bProp0.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color> %s~%s", KvData.attr_name[d.name], val_str , Mathf.Round(val*min), Mathf.Round(val*max))
                elseif tips_index == 1 then
                    self.bProp1.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color> %s~%s", KvData.attr_name[d.name], val_str , Mathf.Round(val*min), Mathf.Round(val*max))
                elseif tips_index == 2 then
                    self.bProp2.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color> %s~%s", KvData.attr_name[d.name], val_str , Mathf.Round(val*min), Mathf.Round(val*max))
                end
                tips_index = tips_index + 1
            end
        end
        return
    end

    --基础属性
    if reset_base_attrs ~= nil or #reset_base_attrs ~= 0 then
        for i=1,#reset_base_attrs do
            local attr = reset_base_attrs[i]
            local val_str = attr.val > 0 and string.format("+%s", attr.val) or tostring(attr.val)
            if index_1 == 0 then
                self.bProp0.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[attr.name], val_str)
                self:check_up_and_down(self.bProp0, self.imgUp0,attr, self.selectedEquipData.base_attrs)
                index_1 = index_1 + 1
            elseif index_1 == 1 then
                self.bProp1.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[attr.name], val_str)
                self:check_up_and_down(self.bProp1, self.imgUp1,attr, self.selectedEquipData.base_attrs)
                index_1 = index_1 + 1
            elseif index_1 == 2 then
                self.bProp2.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[attr.name], val_str)
                self:check_up_and_down(self.bProp2, self.imgUp2,attr, self.selectedEquipData.base_attrs)
                index_1 = index_1 + 1
            end
        end
    end
    --额外属性
    if reset_ext_attrs ~= nil and #reset_ext_attrs ~= 0 then
        local str = ""
        for i=1,#reset_ext_attrs do
            local attr = reset_ext_attrs[i]
            local val_str = attr.val > 0 and string.format("+%s", attr.val) or tostring(attr.val)
            local temp_txt = nil
            if index_1 == 1 then
                temp_txt = self.bProp1
            elseif index_1 == 2 then
                temp_txt = self.bProp2
            elseif index_1 == 3 then
                temp_txt = self.bProp3
            end
            if temp_txt ~= nil then
                if str ~= "" then
                    temp_txt.text = string.format("%s %s", str, string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[attr.name], val_str))
                else
                    temp_txt.text = string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[attr.name], val_str)
                end
                str = temp_txt.text
            end
        end
        index_1 = index_1 + 1
    end


    --特效属性
    if reset_eff_attrs ~= nil or #reset_eff_attrs ~= 0 then
        for i=1,#reset_eff_attrs do
            local attr = reset_eff_attrs[i]
            -- local val_str = attr.val > 0 and string.format("+%s", attr.val) or tostring(attr.val)
            local str = ""
            local temp_txt = nil
            if index_1 == 1 then
                temp_txt = self.bProp1
            elseif index_1 == 2 then
                temp_txt = self.bProp2
            elseif index_1 == 3 then
                temp_txt = self.bProp3
            elseif index_1 == 4 then
                temp_txt = self.bProp4
            end

            local name_str = ""
            if attr.name == 100 then
                name_str = string.format("%s", DataSkill.data_skill_effect[attr.val].name)
            else
                name_str = KvData.attr_name[attr.name]
            end

            if temp_txt ~= nil then
                if str ~= "" then
                    temp_txt.text = string.format("%s %s", str, string.format("<color='#dc83f5'>%s</color>", name_str))
                else
                    temp_txt.text = string.format(TI18N("<color='#dc83f5'>特效:%s</color> %s"), name_str, temp_txt.text)
                end
                str = temp_txt.text
            end
        end
    end
end

function ShouhuEquipWindow:check_up_and_down(pt ,imgArrow, attr, list)
    for i=1, #list do
        local d = list[i]
        if d.name == attr.name then
            if d.val < attr.val then
                imgArrow.gameObject:SetActive(true)
                imgArrow.transform:GetComponent(RectTransform).anchoredPosition = Vector2( pt.preferredWidth+10, -5)
            end
        end
    end
end

function ShouhuEquipWindow:CheckGuide()
    local role = RoleManager.Instance.RoleData
    if role.lev >= 40 and role.lev < 50
        and role.coin >= 50000
        and QuestManager.Instance.questTab[41570] ~= nil and QuestManager.Instance.questTab[41570].finish ~= QuestEumn.TaskStatus.Finish
        and ShouhuManager.Instance.model:check_all_shangzhen_no_up()
    then
        if self.model.main_win.guideScript ~= nil then
            self.model.main_win.guideScript:DeleteMe()
            self.model.main_win.guideScript = nil
        end
        -- 装备升级
        if self.guideScript == nil then
            self.guideScript = GuideGuardUpgradeSec.New(self)
            self.guideScript:Show()
        end
        return
    end
end