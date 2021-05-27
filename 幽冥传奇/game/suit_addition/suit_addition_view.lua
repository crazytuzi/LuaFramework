SuitAdditionView = SuitAdditionView or BaseClass(XuiBaseView)

function SuitAdditionView:__init()
    self:SetModal(true)
    self.texture_path_list[1] = "res/xui/equipbg.png"
    self.config_tab = {
        {"common_ui_cfg", 1, {0}},
        {"suit_addition_ui_cfg", 1, {0}},
        {"suit_addition_ui_cfg", 2, {0}},
        {"common_ui_cfg", 2, {0}},
    }

    self.old_weap_shape = -1
    self.old_dress_shape = -1

    self.item_config_change = BindTool.Bind(self.OnItemConfigChanged, self)
    self.equip_data_change = BindTool.Bind(self.OnEquipDataChanged, self)
end

function SuitAdditionView:ReleaseCallBack()
    if self.tabbar then
        self.tabbar:DeleteMe()
        self.tabbar = nil
    end
    if self.display_modal then
        self.display_modal:DeleteMe()
        self.display_modal = nil
    end
    if self.power_numberbar then
        self.power_numberbar:DeleteMe()
        self.power_numberbar = nil
    end

    if self.eq_cell_list then
        for k, v in pairs(self.eq_cell_list) do
            v:DeleteMe()
        end
        self.eq_cell_list = nil
    end 

    if self.cur_attr_view then
        self.cur_attr_view:DeleteMe()
        self.cur_attr_view = nil
    end

    if self.n_attr_view then
        self.n_attr_view:DeleteMe()
        self.n_attr_view = nil
    end

    EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change)
    self.equip_data_change = nil

    ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_change)
    self.item_config_change = nil

    self.old_dress_shape = -1
    self.old_weap_shape = -1
end

function SuitAdditionView:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        self:CreateTabbar()
        self:CreateEqCells()
        self:CreateModalAnimation()
        self:CreateNumberbar()
        self:CreateAttrView()
        XUI.AddClickEventListener(self.node_t_list.btn_open.node, BindTool.Bind(self.OnClickOpen, self))

        EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change)
        ItemData.Instance:NotifyItemConfigCallBack(self.item_config_change)
    end
end

function SuitAdditionView:CreateTabbar()
    self.tabbar = Tabbar.New()
    self.tabbar:CreateWithNameList(self.node_t_list.layout_suit_addition.node, 20, 535, BindTool.Bind(self.OnSelectTabCallback, self),
         Language.SuitAddition.TabGroup, false, ResPath.GetCommon("toggle_104"), 20)
    self.tabbar:SetSpaceInterval(12)
    self.tabbar:SelectIndex(TabIndex.suit_ad_strength)
end

function SuitAdditionView:CreateEqCells()
    self.eq_cell_list = {}
    for i = 1, 10 do
        local ph = self.ph_list["ph_cell_eq_" .. i]
        local cell = SuitItemRender.New()
        cell:SetUiConfig(ph, true)
        cell:SetAnchorPoint(0.5, 0.5)
        cell:SetPosition(ph.x, ph.y)
        cell:SetIndex(i)
        self.node_t_list.layout_suit_addition.node:addChild(cell:GetView(), 50)
        self.eq_cell_list[i] = cell
    end
end

function SuitAdditionView:CreateModalAnimation()
    local layout = XUI.CreateLayout(268, 250, 250, 250)
    self.display_modal = RoleDisplay.New(layout, -1, false, false, true, true)
    self.display_modal:SetPosition(125, 110)
    self.display_modal:SetScale(1.2)
    self.display_modal:Reset(Scene.Instance:GetMainRole())
    self.node_t_list.layout_suit_addition.node:addChild(layout, 10)
    XUI.AddClickEventListener(layout, BindTool.Bind(self.OnClickDisplayModal, self))
end

function SuitAdditionView:CreateNumberbar()
    self.power_numberbar = NumberBar.New()
    self.power_numberbar:Create(660, 455, 180, 40, ResPath.GetMainui("num_"))
    self.power_numberbar:SetSpace(-8)
    self.power_numberbar:SetNumber(0)
    self.power_numberbar:SetGravity(NumberBarGravity.Center)
    self.node_t_list.layout_suit_addition.node:addChild(self.power_numberbar:GetView(), 99)

    RenderUnit.CreateEffect(988, self.node_t_list.layout_suit_addition.node, 28, nil, nil, 750, 490)
end

function SuitAdditionView:CreateAttrView()
    self.cur_attr_view = AttrView.New(250, 25, 18)
    self.cur_attr_view:GetView():setPosition(605, 355)
    self.cur_attr_view:SetDefTitleText(Language.Common.No)
    self.cur_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
    self.node_t_list.layout_suit_addition.node:addChild(self.cur_attr_view:GetView(), 100)
    
    self.n_attr_view = AttrView.New(250, 25, 18)
    self.n_attr_view:GetView():setPosition(605, 175)
    self.n_attr_view:SetDefTitleText(Language.Common.MaxLevel)
    self.n_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
    self.node_t_list.layout_suit_addition.node:addChild(self.n_attr_view:GetView(), 100)
end

function SuitAdditionView:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SuitAdditionView:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SuitAdditionView:OnFlush(param_t, index)
    local tab_index = self.tabbar:GetCurSelectIndex()

    for k, v in pairs(param_t) do
        if k == "all" then
            self:SetEquipCells(tab_index)
            self:SetRoleDisplay(tab_index)
            self:SetAttrPlusView(tab_index)
        elseif k == "item_config" then
            self:SetRoleDisplay(tab_index)
        elseif k == "equip_data" then
            self:SetEquipCells(tab_index)
        end
    end
end

function SuitAdditionView:SetAttrPlusView(tab_index)
   local config = SuitAdditionData.GetOpenBtnCfg(tab_index)
    if config then
        self.node_t_list.lbl_add_name.node:setString(config.label)
    end
    
    local tip_level = SuitAdditionData.GetTipLevel(tab_index)
    if tip_level == nil then return end

    local plus_cfg = SuitAdditionData.GetPlusConfig(tab_index, tip_level)
    local n_plus_cfg = SuitAdditionData.GetPlusConfig(tab_index, tip_level + 1)
    local current = SuitAdditionData.GetLevel(tab_index)
    local max = 0

    if plus_cfg then
        if tab_index == TabIndex.suit_ad_strength or tab_index == TabIndex.suit_ad_legend then
            max = plus_cfg.level or plus_cfg.count
        else
            max = plus_cfg.count
        end
        self.node_t_list.lbl_cur_total_level.node:setVisible(true)
        self.node_t_list.lbl_cur_total_level.node:setString(plus_cfg.name)
        self.power_numberbar:SetNumber(CommonDataManager.GetAttrSetScore(plus_cfg.attrs))
        self.cur_attr_view:SetData(plus_cfg.attrs)
        self.node_t_list.lbl_add_title.node:setVisible(true)
        self.node_t_list.lbl_add_title.node:setString(string.format("%s (%d/%d)", plus_cfg.name, current, max))
        self.node_t_list.img_active_state.node:loadTexture(current >= max and ResPath.GetCommon("part_111") or ResPath.GetCommon("part_112"))
    else
        self.node_t_list.lbl_add_title.node:setVisible(false)
        self.power_numberbar:SetNumber(0)
        self.node_t_list.lbl_cur_total_level.node:setVisible(false)
        self.node_t_list.img_active_state.node:loadTexture(ResPath.GetCommon("part_112"))
        self.cur_attr_view:SetData()
    end

    if n_plus_cfg then
        self.node_t_list.lbl_next_total_level.node:setVisible(true)
        self.node_t_list.lbl_next_total_level.node:setString(n_plus_cfg.name)
        self.n_attr_view:SetData(n_plus_cfg.attrs, CommonDataManager.LerpAttributeAttr(plus_cfg and plus_cfg.attrs, n_plus_cfg.attrs))
    else
        self.node_t_list.lbl_next_total_level.node:setVisible(false)
        self.n_attr_view:SetData()
    end 
end

function SuitAdditionView:SetRoleDisplay(index)
    local weaponpos_data = nil
    local dresspos_data = nil
    if index == TabIndex.suit_ad_legend then
        weaponpos_data = EquipData.Instance:GetGridData(EquipData.EquipIndex.PeerlessWeaponPos)
        dresspos_data = EquipData.Instance:GetGridData(EquipData.EquipIndex.PeerlessDressPos)
    else
        weaponpos_data = EquipData.Instance:GetGridData(EquipData.EquipIndex.Weapon)
        dresspos_data = EquipData.Instance:GetGridData(EquipData.EquipIndex.Dress)
    end

    local wapon_cfg, dress_cfg
    if weaponpos_data then
        wapon_cfg = ItemData.Instance:GetItemConfig(weaponpos_data.item_id)
    end
    if dresspos_data then
        dress_cfg = ItemData.Instance:GetItemConfig(dresspos_data.item_id)
    end

    local anim_path, anim_name = "", ""
    if wapon_cfg and wapon_cfg.shape and self.old_weap_shape ~= wapon_cfg.shape then
        local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
        anim_path, anim_name = ResPath.GetWuqiBigAnimPath(wapon_cfg.shape, SceneObjState.Stand, GameMath.DirDown, sex)
        self.display_modal:ChangeLayerResFrameAnim(InnerLayerType.WuqiUp, anim_path, anim_name, false)
        self.old_weap_shape = wapon_cfg.shape
    end

    if dress_cfg and dress_cfg.shape and self.old_dress_shape ~= dress_cfg.shape then
        anim_path, anim_name = ResPath.GetRoleBigAnimPath(dress_cfg.shape, SceneObjState.Stand, GameMath.DirDown)
        self.display_modal:ChangeLayerResFrameAnim(InnerLayerType.Main, anim_path, anim_name, false)
        self.old_dress_shape = dress_cfg.shape
    end
end

function SuitAdditionView:SetEquipCells(tab_index)
    local data_list = SuitAdditionData.GetSuitEquipList(tab_index)
    for k, v in pairs(self.eq_cell_list) do
        if tab_index == TabIndex.suit_ad_samsara then
            v:SetVisible(k >= 7 or k == 5)
            if k == 5 then
                v:SetData(data_list[1])
            elseif k >= 7 then
                v:SetData(data_list[k - 5])
            else
                v:SetData()
            end
        else
            v:SetVisible(true)
            v:SetData(data_list[k])
        end
    end
end

function SuitAdditionView:OnSelectTabCallback(index)
    self:ChangeToIndex(index)
    self:Flush()
end

function SuitAdditionView:ShowIndexCallBack(index)
    self:Flush()
end

function SuitAdditionView:OnClickOpen()
    local tab_index = self.tabbar:GetCurSelectIndex()
    local config = SuitAdditionData.GetOpenBtnCfg(tab_index)
    if config ~= nil then
        ViewManager.Instance:Open(config.view_name, config.index)
    end
end

function SuitAdditionView:OnClickDisplayModal()
    ViewManager.Instance:Open(ViewName.RoleRule)
	local data = {}
    local tab_index = self.tabbar:GetCurSelectIndex()
    if tab_index == TabIndex.suit_ad_strength then
        local qianghua_tip_level = SuitAdditionData.GetTipLevel(tab_index)
        local strenth_level = SuitAdditionData.GetLevel(tab_index)
        data = {tiptype = 1, level = qianghua_tip_level, qianghua_level = strenth_level}
    elseif tab_index == TabIndex.suit_ad_stone then
        local level = EquipData.Instance:GetCurrentLevel()
        local gem_min_num = RoleRuleData.Instance:GetALLGemNum(1)
        local gem_max_num = RoleRuleData.Instance:GetALLGemNum(level)
        local gem_next_num = RoleRuleData.Instance:GetALLGemNum(level + 1)
        local gem_data = nil
        if level == 0 then
            gem_data = RoleRuleData.GetData(1) 
        elseif level == #StonePlusCfg then
            gem_data = RoleRuleData.GetData(#StonePlusCfg)
        else
            gem_data = RoleRuleData.GetData(level + 1)
        end
        data = {tiptype = 2, level = level, next_level = level + 1, min_num = gem_min_num, max_num = gem_max_num, next_num = gem_next_num, gem_tab = gem_data}
    elseif tab_index == TabIndex.suit_ad_soul then
        local soul_tip_level = SuitAdditionData.GetTipLevel(tab_index)
		local soul_level = SuitAdditionData.GetLevel(tab_index)
		data = {tiptype = 6, level = soul_tip_level, molding_soul_level = soul_level}
    elseif tab_index == TabIndex.suit_ad_legend then
        local blood_tip_level = RoleRuleData.GetXueLianTipsLevel()
        local level = EquipData.Instance:GetPeerlessEquipLevel()
        if level > 0 then
			local blood_level = EquipmentData.Instance:GetAllBmStrengthLevel()
			data = {tiptype = 4, level = blood_tip_level, blood_mixing_level = blood_level}
		else
			local min_count = RoleRuleData.GetPeerlessSuitNum(level)
			local tab = RoleRuleData.Instance:GetPeerlessSuitData(level)
			local tab_1 = RoleRuleData.Instance:GetPeerlessSuitData(level)
			data = {tiptype = 5, level = level, min_count = min_count, max_count = 10, next_count = 10, tab = tab, tab_1 = tab_1}
		end
    elseif tab_index == TabIndex.suit_ad_god then
        local god_tip_level = SuitAdditionData.GetTipLevel(tab_index)
		local god_level = SuitAdditionData.GetLevel(tab_index)
		data = {tiptype = 7, level = god_tip_level, god_level = god_level}
    elseif tab_index == TabIndex.suit_ad_samsara then
        local level = SuitAdditionData.GetTipLevel(tab_index)
        local min_count = LunHuiData.GetCountByTipLevel(1)
        local max_count = LunHuiData.GetCountByTipLevel(level)
        local next_count = LunHuiData.GetCountByTipLevel(level + 1)
        local tab = LunHuiData.GetLunhuiEquipIndex(level)
        local tab_1 = LunHuiData.GetLunhuiEquipIndex(level + 1)
        data = {tiptype = 3, level = level, min_count = min_count, max_count = max_count, next_count = next_count, tab = tab, tab_1 = tab_1}
    end
	ViewManager.Instance:FlushView(ViewName.RoleRule, 0, nil, data)
end

function SuitAdditionView:OnEquipDataChanged()
    self:Flush(0, "equip_data")
end

function SuitAdditionView:OnItemConfigChanged()
    self:Flush(0, "item_config")
end


SuitItemRender = SuitItemRender or BaseClass(BaseRender)
function SuitItemRender:__delete()
    if self.cell then
        self.cell:DeleteMe()
        self.cell = nil
    end
end

function SuitItemRender:CreateChild()
    BaseRender.CreateChild(self)

    local size = self.view:getContentSize()

    self.cell = BaseCell.New()
    self.view:addChild(self.cell:GetView())

    self.left_top_text = XUI.CreateText(5, size.height - 12, 0, 0, nil, "", nil, 18)
    self.left_top_text:setAnchorPoint(0, 1)
    self.view:addChild(self.left_top_text, 50)

    self.bottom_text = XUI.CreateText(size.width / 2, 2, 0, 0, nil, "", nil, 16)
    self.bottom_text:setAnchorPoint(0.5, 0)
    self.view:addChild(self.bottom_text)
end

function SuitItemRender:OnFlush()
    if self.data == nil then return end

    self.cell:SetData(self.data.equip_data)
    self.cell:SetProfIconVisible(false)
    local size = self.view:getContentSize()
    self.left_top_text:setAnchorPoint(0, 1)
    self.left_top_text:setPosition(5, size.height - 12)
    if self.data.tab_index == TabIndex.suit_ad_strength then
        self.cell:SetRightBottomTexVisible(true)
        self.cell:SetStoneIconVisible(false)

        self.left_top_text:setVisible(false)
        self.bottom_text:setVisible(false)
    elseif self.data.tab_index == TabIndex.suit_ad_stone then
        self.cell:SetRightBottomTexVisible(true)
        self.cell:SetRightTopNumText(0)

        self.left_top_text:setVisible(false)
        self.bottom_text:setVisible(false)

        local next_tip_lv = EquipData.Instance:GetCurrentLevel() + 1
        next_tip_lv = next_tip_lv > StoneData.GetMaxStonePlusLevel() and StoneData.GetMaxStonePlusLevel() or next_tip_lv
        self.cell:SetStoneIconVisible(StoneData.Instance:ContainUpperStone(self.index, next_tip_lv))

    elseif self.data.tab_index == TabIndex.suit_ad_soul then
        self.cell:SetRightBottomTexVisible(false)
        self.cell:SetRightTopNumText(0)
        self.cell:SetStoneIconVisible(false)

        self.left_top_text:setVisible(true)
        self.left_top_text:setAnchorPoint(1, 1)
        self.left_top_text:setPosition(size.width - 10, size.height - 12)
        self.bottom_text:setVisible(true)
        local format_level = 0
		if self.data.soul_level > 0 then
			format_level = self.data.soul_level % 12 == 0 and 12 or self.data.soul_level % 12
		end
        self.left_top_text:setString(format_level .. Language.Common.Ji)

        local t = MoldingSoulData.GetMoldingSoulDesc(self.data.soul_level)
        self.bottom_text:setColor(t[1])
		self.bottom_text:setString(t[2])
		self.bottom_text:enableOutline(t[3])

        self.left_top_text:setColor(t[1])
        self.left_top_text:enableOutline(t[3])
    elseif self.data.tab_index == TabIndex.suit_ad_legend then
        self.cell:SetRightTopNumText(0)
        self.cell:SetRightBottomTexVisible(false)
        self.cell:SetStoneIconVisible(false)

        self.left_top_text:setVisible(true)
        self.bottom_text:setVisible(false)
        self.left_top_text:setColor(COLOR3B.RED)
        self.left_top_text:disableEffect()
        self.left_top_text:setString("+" .. self.data.blood_level)
    elseif self.data.tab_index == TabIndex.suit_ad_god then
        self.cell:SetRightTopNumText(0)
        self.cell:SetRightBottomTexVisible(false)
        self.cell:SetStoneIconVisible(false)

        self.left_top_text:setVisible(true)
        self.bottom_text:setVisible(false)
        self.left_top_text:setAnchorPoint(0, 0)
        self.left_top_text:setPosition(5, 5)
        self.left_top_text:setColor(COLOR3B.RED)
        self.left_top_text:disableEffect()
        self.left_top_text:setString(AffinageData.GetGodLevelName(self.data.god_level))
    elseif self.data.tab_index == TabIndex.suit_ad_samsara then
        self.cell:SetRightTopNumText(0)
        self.cell:SetRightBottomTexVisible(false)
        self.cell:SetStoneIconVisible(false)

        self.left_top_text:setVisible(false)
        self.bottom_text:setVisible(false)
    end

    if self.data.equip_data == nil then
        if self.data.tab_index == TabIndex.suit_ad_legend then
            self.cell:SetBgTa(ResPath.GetEquipBg(string.format( "cs_ta_%d", self.index)))
        elseif self.data.tab_index == TabIndex.suit_ad_samsara then
            if self.index >= 7 then
                self.cell:SetBgTa(ResPath.GetEquipBg(string.format( "lunhui_ta_%d", self.index - 5)))
            elseif self.index == 5 then
                self.cell:SetBgTa(ResPath.GetEquipBg(string.format( "lunhui_ta_%d", self.index - 4)))
            else
                self.cell:SetBgTa("")
            end
        else
            self.cell:SetBgTa(ResPath.GetEquipBg(string.format( "equip_ta_%d", self.index + EquipData.EquipIndex.Weapon - 1)))
        end
    end
end
