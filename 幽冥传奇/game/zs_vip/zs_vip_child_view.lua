local ZsVipChildView = ZsVipChildView or BaseClass(SubView)

function ZsVipChildView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/zs_vip.png',
		'res/xui/vip.png',
	}
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"zs_vip_ui_cfg", 3, {0}},
		-- {"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.page_award_idx = 1
end

function ZsVipChildView:ReleaseCallBack()
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function ZsVipChildView:LoadCallBack(index, loaded_times)
	self.data = ZsVipData.Instance				--数据
	ZsVipData.Instance:AddEventListener(ZsVipData.INFO_CHANGE, function ()
		self:Flush()
	end)

	self:CreateAwardPage()

    --地图展示
	self.node_zorder_t = {}
    for i = 1, 5 do
        local goadd_rich_link = RichTextUtil.CreateLinkText(Language.ZsVip.IntoMap, 20, COLOR3B.GREEN, nil, true)
		goadd_rich_link:setPosition(130, 30)
		local node = self.node_t_list["map_" .. i].node
		node:addChild(goadd_rich_link, 999, 1)

		node:setLocalZOrder(i)
		node:setVisible(false)
		-- node:setTouchEnabled(true)
		self.node_zorder_t[node] = i
		node:setTouchEnabled(true)
		node:setIsHittedScale(false)
		node:addTouchEventListener(function (sender, event_type, touch)
			if event_type == 2 or event_type == 3 then
				local lv = self.data:GetZsVipLv()
				local e_lv = (lv + 1) % ZsVipView.ENUM_JIE == 0 and ZsVipView.ENUM_JIE or (lv + 1) % ZsVipView.ENUM_JIE
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.ZsVip.Tip4, Language.ZsVip.jieshu[math.ceil(self.data:GetZsVipLv() / ZsVipView.ENUM_JIE)] .. Language.ZsVip.level[e_lv]))
			end
		end)

		XUI.AddClickEventListener(goadd_rich_link, function ()
			if self.data:GetZsVipLv() <= 0 then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.ZsVip.IntoMapTip2)
				return
			end
			if self.alert == nil then
				self.alert = Alert.New()
			end
			-- self.alert:SetShowCheckBox(true)
			self.alert:SetLableString(string.format(Language.ZsVip.IntoMapTip, SVipConfig.SVipGrade[self.data:GetZsVipLv()].SceneNeedYB, Language.ZsVip.jieshu[math.ceil(self.data:GetZsVipLv() / ZsVipView.ENUM_JIE)]))
			self.alert:SetOkFunc(function ()	
				ZsVipCtrl.SendZsVipIntoMapReq()
				ViewManager.Instance:CloseViewByDef(ViewDef.ZsVip)
		  	end)
			self.alert:Open()
		end)	
    end

	-- ZsVipData.Instance:AddEventListener(ZsVipData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	XUI.AddClickEventListener(self.node_t_list.btn_lingqu.node, function ()
		ZsVipCtrl.SendZsVipGetAwardReq(1, self.page_award_idx)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_gold_lingqu.node, function ()
			if self.alert == nil then
				self.alert = Alert.New()
			end
			-- self.alert:SetShowCheckBox(true)
			self.alert:SetLableString(string.format(Language.ZsVip.Tip3, SVipConfig.SVipGrade[self.page_award_idx].buyGift.consume[1].count))
			self.alert:SetOkFunc(function ()	
				ZsVipCtrl.SendZsVipGetAwardReq(2, self.page_award_idx)
		  	end)
			self.alert:Open()
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_turnleft.node, function ()
		self.slot_grid:ChangeToPage(self.page_award_idx - 1)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_turnright.node, function ()
		self.slot_grid:ChangeToPage(self.page_award_idx + 1)
	end)


	-- XUI.AddClickEventListener(self.node_t_list.btn_into_map1.node, function ()
	-- 	ZsVipCtrl.SendZsVipIntoMapReq()
	-- end)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function ZsVipChildView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_CUTTING_LEVEL then
		-- self.node_t_list.lbl_vip_level.node:setString(self.data:GetZsVipLv())
		self:Flush()
	elseif key == OBJ_ATTR.ACTOR_MAX_EXP_L or OBJ_ATTR.ACTOR_MAX_EXP_H then
		self:Flush()
	end
end

function ZsVipChildView:ShowIndexCallBack()
	self:Flush()
end

function ZsVipChildView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipChildView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipChildView:OnFlush(vo)
	-- 下一级提示
	local lv = self.data:GetZsVipLv()

	local curr_e_lv = lv % ZsVipView.ENUM_JIE
	if curr_e_lv == 0 and lv > 0 then
		curr_e_lv = ZsVipView.ENUM_JIE
	end

	local show_jieshu = math.ceil(lv / ZsVipView.ENUM_JIE)
	if show_jieshu == 0 then
		show_jieshu = 1
	end
	
    self:SelectMap(show_jieshu)

    local datas = DeepCopy(SVipConfig.SVipGrade)
    datas[0] = table.remove(datas, 1)
    self.slot_grid:SetDataList(datas)
    self.slot_grid:ChangeToPage(self.data:GetCanLingquPage() or self.page_award_idx)
    self:OnPageChage(self.data:GetCanLingquPage() or self.page_award_idx)
end

local MaxMapZorder = 5
local Zorder2Xpos = {-180, 280, 180, -80, 50}
local Zorder2scale = {0.8, 0.8, 0.9, 0.9, 1}
function ZsVipChildView:SelectMap(map_idx)
	local old_top = nil
	for k,v in pairs(self.node_zorder_t) do
		if v == MaxMapZorder then
			old_top = k
			break
		end
	end

	local change_node = self.node_t_list["map_" .. map_idx].node
	-- if old_top == change_node then return end

	self.node_zorder_t[old_top], self.node_zorder_t[change_node] = self.node_zorder_t[change_node], self.node_zorder_t[old_top]
	old_top:setLocalZOrder(self.node_zorder_t[old_top])
	change_node:setLocalZOrder(self.node_zorder_t[change_node])

	for k,v in pairs(self.node_zorder_t) do
		k:setPositionX(Zorder2Xpos[v] + 300)
		k:setScale(Zorder2scale[v])
		k:setVisible(true)
	end
end

function ZsVipChildView:OnPageChage(page_index)
    self.page_award_idx = page_index
    self.node_t_list.img_remind_l.node:setVisible(self.data:GetCanLingquLeft(self.page_award_idx))
    self.node_t_list.img_remind_r.node:setVisible(self.data:GetCanLingquRight(self.page_award_idx))

    local is_free_lingqu = ZsVipData.Instance:GetIsFreeLingQuByLv(self.page_award_idx)
    local is_buy = ZsVipData.Instance:GetIsBuyLingQuByLv(self.page_award_idx)
    self.node_t_list.btn_lingqu.node:setVisible(not is_free_lingqu)
    self.node_t_list.layout_gold_buy.node:setVisible(is_free_lingqu and not is_buy)
    self.node_t_list.img_stamp.node:setVisible(is_free_lingqu and is_buy)
    self.node_t_list.img_gitf_tip.node:loadTexture(is_free_lingqu and ResPath.GetZsVip("bg_4") or ResPath.GetZsVip("bg_2"))

	self.node_t_list.lbl_gold_num.node:setString(SVipConfig.SVipGrade[self.page_award_idx].buyGift.consume[1].count)
	
    self.node_t_list.btn_lingqu.node:setEnabled(ZsVipData.Instance:GetIsCanFreeLingQuByLv(self.page_award_idx))
    self.node_t_list.img_remind_lingqu.node:setVisible(ZsVipData.Instance:GetIsCanFreeLingQuByLv(self.page_award_idx))

    local show_jieshu = math.ceil(self.page_award_idx / ZsVipView.ENUM_JIE)
    local show_lv = self.page_award_idx % ZsVipView.ENUM_JIE
    show_lv = show_lv == 0 and ZsVipView.ENUM_JIE or show_lv
    self.node_t_list.img_txt.node:loadTexture(ResPath.GetZsVip("txt_" .. show_jieshu))
    self.node_t_list.img_num.node:loadTexture(ResPath.GetZsVip("hz_" .. show_lv))
end

function ZsVipChildView:CreateAwardPage()
    local ph = self.ph_list.ph_show_view
    self.slot_grid = BaseGrid.New()
    local grid_node = self.slot_grid:CreateCells({ w=ph.w, h=ph.h, cell_count= #SVipConfig.SVipGrade, col=1, row=1, itemRender = ZsvIPShowItem,
                                                   direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_show_item})
    grid_node:setPosition(ph.x, ph.y)
    -- self.slot_grid:SetSelectCallBack(BindTool.Bind(self.OnClickGrid, self))
    self.slot_grid:SetPageChangeCallBack(function (item, page_index, prve_page_index)
    	self:OnPageChage(page_index)
    end)
    self.node_t_list.layout_bootom.node:addChild(grid_node, 100)
    local datas = DeepCopy(SVipConfig.SVipGrade)
    datas[0] = table.remove(datas, 1)
    self.slot_grid:SetDataList(datas)
    self.slot_grid:ChangeToPage(self.data:GetCanLingquPage() or 1)
    self:OnPageChage(self.data:GetCanLingquPage() or 1)
end

function ZsVipChildView:OnDataChange(vo)
end

----------------------------------------------------
-- 奖励展示
----------------------------------------------------
ZsvIPShowItem = ZsvIPShowItem or BaseClass(BaseRender)

function ZsvIPShowItem:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(0, 0, 546, 90, ScrollDir.Horizontal, AwardBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)
end

function ZsvIPShowItem:__init()
end

function ZsvIPShowItem:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function ZsvIPShowItem:OnFlush(...)
	if nil == self.data then return end
	local data_t = {}
	if not ZsVipData.Instance:GetIsFreeLingQuByLv(self:GetIndex() + 1) then
		for k,v in pairs(self.data.reward) do
			data_t[k] = {item_id = v.id, num = v.count, is_bind = v.bind, effectId = v.effectId}
		end
	else
		for k,v in pairs(self.data.buyGift.award) do
			data_t[k] = {item_id = v.id, num = v.count, is_bind = v.bind, effectId = v.effectId}
		end
	end
	self.cell_charge_list:SetDataList(data_t)
end

function ZsvIPShowItem:CreateSelectEffect()
end


AwardBaseCell = AwardBaseCell or BaseClass(BaseCell)

function AwardBaseCell:OnFlush()
	BaseCell.OnFlush(self)
	self:SetQualityEffect(self.data and self.data.effectId or 0)
end

function AwardBaseCell:CreateSelectEffect()
end

return ZsVipChildView