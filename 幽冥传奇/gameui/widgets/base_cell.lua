-----------------------------------------------------
-- 基础物品格子
-- 注意该格子的锚点设计在左下角
-----------------------------------------------------
BaseCell = BaseCell or BaseClass(BaseRender)
BaseCell.index_inc = 0
BaseCell.SIZE = 80
BaseCell.DEFAULT_BG = "cell_100"
BaseCell.ITEM_EFFSET_OFFSET = 100000 -- 物品特效偏移值, icon_id 大于这个值就显特效

function BaseCell:__init()
	self.cell_node = self.view
	
	self.is_show_cell_bg = true
	self.hide_num_if_less_numx = 1 					-- 低于X数量时不显示数字
	self.is_open = true								-- 是否已开启
	self.data_from_index = - 1						-- 数据来自于哪个格子
	self.is_lock = false							-- 是否锁住，锁住后不可变更
	self.is_upflag = false							-- 是否上升箭头
	self.is_remind = false							-- 是否提示
	self.lock_reason_tip = ""						-- 锁定点击提示
	self.is_showtip = true							-- 是否显示物品信息提示
	self.skin_style = {}							-- 皮肤样式
	self.rightbottom_text_isvisible = true			-- 右下角文字是否显示
	self.item_tip_from = nil
	self.cd_key = ""								-- 冷却转圈 key
	self.need_useless_modal = true					-- 是否需要不可用遮罩
	self.role_data_change_callback = nil			-- 角色数据改变回调
	self.item_big_type = 0							-- 物品大类型
	
	self.long_click_callback = nil					-- 长按回调
	
	self.bg_img = nil 								-- 背景图片
	self.bg_ta = nil								-- 背景上的装饰图案
	self.item_icon = nil							-- 物品图标
	self.item_effect = nil							-- 物品特效
	self.bind_icon = nil							-- 绑定图标
	self.useless_modal = nil						-- 不可用显示
	self.quality_icon = nil							-- 品质图标
	self.unopen_icon = nil							-- 未开启图标
	self.lock_icon = nil 							-- 锁定图标
	self.new_flag_icon = nil 						-- 新品标记图标
	self.upflag_icon = nil 							-- 上升标记图标
	self.remind_icon = nil 							-- 提示标记图标
	self.stone_icon = nil 							-- 宝石标记图标
	self.item_desc = nil							-- 背景文字
	self.right_bottom_text = nil					-- 右下角文字，强化等级、数量
	self.right_bottom_imgnum_txt = nil 				-- 右下角图片数量文字
	self.right_top_num_txt = nil 					-- 右上角第一行数字
	self.right_top_num_txt2 = nil 					-- 右上角第二行数字
	self.top_left_text = nil						-- 左上角文字
	self.shen_effect = nil							-- 神特效
	self.exp_menory_effect = nil					-- 经验珠特效
	self.quality_effect = nil						-- 品质特效
	self.cd_mask = nil								-- 冷却转圈
	self.res_path = nil								-- 专有背景
	self.is_show_cfg_effect = true					-- 是否显示配置物品特效
	self.special_ring_bg = nil 						-- 特戒融合标记
	self.fusion_lv_bg = nil 						-- 锻造融合标记
	self.sign_img = nil 							--穿戴标记
	self.step_img = nil 							--阶数标记
	self.decorate_img = nil 						--装饰标记
	self.add_icon = nil 							--加号标记
	self.circle_img = nil 							--转生图片
	self.choice_img = nil 							--勾选图片
	
	self:SetContentSize(BaseCell.SIZE, BaseCell.SIZE)
	self:SetCellBg(ResPath.GetCommon(BaseCell.DEFAULT_BG))
	self:SetAddClickEventListener()
	
end

function BaseCell:SetAddClickEventListener()
	self:AddClickEventListener()
end

function BaseCell:__delete()
	if nil ~= self.itemconfig_callback and ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
		self.itemconfig_callback = nil
	end
	self:ClearEvent()
end

-- 清除事件
function BaseCell:ClearEvent()
	if nil ~= self.role_data_change_callback and RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change_callback)
		self.role_data_change_callback = nil
	end
	self:RemoveCountDown()
end

-- 设置特殊图片
function BaseCell:SetSpecilImgVisible(is_visible, path, x, y)
	x = x or BaseCell.SIZE / 2
	y = y or BaseCell.SIZE / 2
	if is_visible and nil == self.specil_img and nil ~= path then
		self.specil_img = XImage:create(path, true)
		self.specil_img:setPosition(x, y)
		self.view:addChild(self.specil_img, 3, 3)
	elseif nil ~= self.specil_img then
		self.specil_img:setVisible(is_visible)
	end
end

function BaseCell:RegisterNodeEvent()
	if not self.is_register_node_event then
		self.is_register_node_event = true
		self.view:registerScriptHandler(function(event_text)
			if event_text == "cleanup" then			-- 节点移除时清除事件
				self:ClearEvent()
			end
		end)
	end
end

function BaseCell:GetCell()
	return self.view
end

function BaseCell:MakeGray(boolean)
	if nil ~= self.item_icon then
		self.item_icon:setGrey(boolean)
	end
	if nil ~= self.quality_icon then
		self.quality_icon:setGrey(boolean)
	end
	if nil ~= self.useless_modal then
		self.useless_modal:setGrey(boolean)
	end
	if nil ~= self.bg_img then
		self.bg_img:setGrey(boolean)
	end
	if nil ~= self.item_effect then
		XUI.MakeGrey(self.item_effect, boolean)
	end
	if nil ~= self.quality_effect then
		XUI.MakeGrey(self.quality_effect, boolean)
	end

	self.make_gray = boolean
end

function BaseCell:SetIconScale(scale)
	if nil ~= self.item_icon then
		self.item_icon:setScale(scale)
	end
	if nil ~= self.quality_icon then
		self.quality_icon:setScale(scale)
	end
	if nil ~= self.useless_modal then
		self.useless_modal:setScale(scale)
	end
end

function BaseCell:GetIsOpen()
	return self.is_open
end

function BaseCell:SetOpen(is_open)
	if self.is_open == is_open then
		return
	end
	
	self.is_open = is_open
	if not is_open then
		self:ClearData()
	end
	
	self:SetUnopenIconVisible(not is_open)
end

function BaseCell:GetFromIndex()
	return self.data_from_index
end

function BaseCell:SetFromIndex(data_from_index)
	self.data_from_index = data_from_index
end

function BaseCell:SetItemTipFrom(item_tip_from)
	self.item_tip_from = item_tip_from
end

function BaseCell:SetIsLock(is_lock, reason_tip, lock_type)
	self.is_lock = is_lock
	self.lock_type = lock_type
	self.lock_reason_tip = reason_tip or Language.Common.Cell_Lock_Tip
	if self.item_icon ~= nil then
		if lock_type == nil or lock_type == 1 then
			self:MakeGray(is_lock)
		elseif lock_type == 2 then
			self:SetLockIconVisible(is_lock)
		end
	end
end

function BaseCell:SetHideNumTxtLessNum(less_num)
	self.hide_num_if_less_numx = less_num
end

function BaseCell:GetIsLock()
	return self.is_lock
end

function BaseCell:SetIsShowTips(flag)
	self.is_showtip = flag
end

function BaseCell:SetRightBottomTexVisible(is_visible)
	if self.right_bottom_text then
		self.right_bottom_text:setVisible(is_visible)
	end
	if self.right_bottom_imgnum_txt then
		self.right_bottom_imgnum_txt:SetVisible(is_visible)
	end
	self.rightbottom_text_isvisible = is_visible
end

function BaseCell:GetIsShowTips()
	return self.is_showtip
end

--设置皮肤样式
--{ bg = "ResPath.GetCommon("lock_1")", bg_ta = nil, cell_desc = nil }
function BaseCell:SetSkinStyle(style)
	if style == nil then
		return
	end
	self.skin_style = style
	
	if nil ~= style.bg then
		self:SetCellSpecialBg(style.bg)
	end
	
	if nil ~= style.bg_ta then
		self:SetBgTa(style.bg_ta)
	end
	
	if nil ~= style.bg_ta2 then
		self:SetBgTa2(style.bg_ta2)
	end
	
	if nil ~= style.cell_desc then
		self:SetItemDesc(style.cell_desc)
	else
		if nil ~= self.item_desc then
			self.item_desc:setVisible(false)
		end
	end
end

function BaseCell:SetLongClickCallBack(callback)
	self.long_click_callback = callback
	
	self.view:addLongTouchEventListener(BindTool.Bind(self.OnClickLong, self))
end

function BaseCell:SetData(data)
	self.data = data and next(data) and data or nil -- 兼容nil值和空表
	self.is_select = false
	if nil ~= self.data then
		if nil == ItemData.Instance:GetItemConfig(data.item_id) and nil == self.itemconfig_callback then
			self.itemconfig_callback = BindTool.Bind1(self.ItemConfigCallback, self)
			ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_callback)
		end
	end
	self:Flush()
end

function BaseCell:ItemConfigCallback(item_config_t)
	for k, v in pairs(item_config_t) do
		if self.data and self.data.item_id == v.item_id then
			if nil ~= self.itemconfig_callback then
				ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
				self.itemconfig_callback = nil
			end
			self:Flush()
		end
	end
end

-- 刷新
local COMMON_QUALITY_COLOR = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = 1,
}

function BaseCell:OnFlush()
	if not self.is_open then
		return false
	end
	self:ClearAllParts()
	
	if nil == self.data then
		self.data_from_index = - 1
		self:SetIsLock(false)
		self:SetUpFlagIconVisible(false)
		self:SetStoneIconVisible(false)
		if nil == self.res_path then
			self:SetCellBg(ResPath.GetCommon(BaseCell.DEFAULT_BG))
		end
		return false
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon_id = tonumber(item_cfg.icon)

	if nil == self.res_path and COMMON_QUALITY_COLOR[item_cfg.showQuality] then
		self:SetCellBg(ResPath.GetCommon("cell_quality_" .. item_cfg.showQuality))
	end

	if (self.data.item_id >= 10000 and item_cfg.type == 1000) then
		if nil ~= self.item_icon then self.item_icon:setVisible(false) end
	else
		if icon_id and icon_id >= 0 then
			if icon_id >= BaseCell.ITEM_EFFSET_OFFSET then
				if nil ~= self.item_icon then self.item_icon:setVisible(false) end
				self:SetItemEffect(icon_id - BaseCell.ITEM_EFFSET_OFFSET, 0.35)
			else
				local path = ResPath.GetItem(icon_id)
				self:SetItemIcon(path)
				self:SetItemEffect(0)
			end
			self:SetNoIconImgVis(false)
		else
			if nil ~= self.item_icon then self.item_icon:setVisible(false) end
			self:SetNoIconImgVis(true)
			self:SetItemEffect(0)
		end
	end

	local hand_pos = self.data.hand_pos
	if self.name ~= "equip" then
		hand_pos = QianghuaData.Instance:GetBetterStrengthHandPos(item_cfg.type)
	end
	local slot_strength = self.data.slot_strength or 0
	local fuling_level = self.data.fuling_level or 0
	local fuling_exp = self.data.fuling_exp or 0
	if QianghuaData.IsStrengthEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
		local right_top_num = 0
		local right_top_num2 = 0
		local color_1 = nil
		local color_2 = nil
		if slot_strength > 0 then
			right_top_num = "+" .. slot_strength
			color_1 = Str2C3b(STRENGTH_COLOR[slot_strength] or STRENGTH_COLOR[0])
		end
		if 0 < fuling_exp or 0 < fuling_level then
			if 0 == right_top_num then
				right_top_num = "+" .. fuling_level
				color_1 = COLOR3B.BLUE
			else
				right_top_num2 = "+" .. fuling_level
				color_2 = COLOR3B.BLUE
			end
		end
		self:SetRightTopNumText(right_top_num, color_1)
		self:SetRightTopNumText2(right_top_num2, color_2)
	end

	if self.data.xinghun_level and self.data.xinghun_level > 0 then
		local right_top_num = "+" .. self.data.xinghun_level
		color = COLOR3B.GREEN
		self:SetRightTopNumText(right_top_num, color)
	end
	if EquipmentData.IsXuelianEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
		local slot_xuelian = 0
		if self.data.slot_xuelian and self.data.slot_xuelian > 0 then
			slot_xuelian = self.data.slot_xuelian % 10 == 0 and 10 or self.data.slot_xuelian % 10
		end
		if self.data.slot_xuelian and self.data.slot_xuelian > 0 and self.data.slot_xuelian <= 10 then
			self:SetRightTopNumText(slot_xuelian, COLOR3B.BLUE, true)
		elseif self.data.slot_xuelian and self.data.slot_xuelian > 10 then
			self:SetRightTopNumText(slot_xuelian, COLOR3B.RED, true)
		else
			self:SetRightTopNumText(0)
		end
	end
	self:SetItemNumTxt()
	
	if nil ~= self.item_desc then self.item_desc:setVisible(false) end
	
	-- 绑定标记
	self:SetBindIconVisible(0 ~= self.data.is_bind)
	self:SetStoneIconVisible(false)
	local show_up_flag = false
	if BaseCell.IsMyGrid(self.name)
	and(EquipData.Instance:GetIsBetterEquip(self.data, {[ItemData.UseCondition.ucLevel] = 1, [ItemData.UseCondition.ucMinCircle] = 1})
	or FuwenData.Instance:GetIsBetterFuwen(self.data, true)) then
		show_up_flag = true
	end
	self:SetUpFlagIconVisible(show_up_flag)
	if self.is_upflag then
		self:SetUpFlagIconVisible(self.is_upflag)
	end
	if self.is_remind then
		self:SetRemind(self.is_remind)
	end
	if item_cfg.type == ItemData.ItemType.itHpPot and self.data.durability and self.data.durability == item_cfg.dura then
		self:SetExpMenoryEffect(true)
	end
	
	--物品过期文字
	self:SetOverdueTipText()
	
	if self.is_show_cfg_effect then
		local cfg_eff_id = (self.data.effectId and self.data.effectId > 0 and self.data.effectId) or (item_cfg.effectId and item_cfg.effectId > 0 and item_cfg.effectId)

		local scale = self.data.item_id >= 10000 and 0.4 or 1

		self:SetQualityEffect(cfg_eff_id or 0,scale)
	end

	if item_cfg.type == ItemData.ItemType.itSpecialRing then
		local special_ring = self.data.special_ring
		if special_ring then
			local fusion_num = #self.data.special_ring -- 已融合的特戒数量
			for i,v in ipairs(special_ring) do
				if v.type == 0 then
					fusion_num = fusion_num - 1
				end
			end
			self:SetSpecialRingBg(fusion_num)
		end
	else
		if self.special_ring_bg then
			self.special_ring_bg:setVisible(false)
		end
	end
	if item_cfg.type ==  ItemData.ItemType.itFashion
	or item_cfg.type ==  ItemData.ItemType.itWuHuan
	or item_cfg.type ==  ItemData.ItemType.itGenuineQi
	then
		local vis = self.data.zhuan_level == 1 and true or false
		self:SetShowImageSign(vis)

		local is_over_time = FashionData.Instance:GetFashionIsOverTime(self.data)
		self:MakeGray(self.make_gray or is_over_time)
	end
	if ItemData.IsReXueEquip(self.data.item_id) then
		local order = item_cfg.orderType
		if order > 0 then
			local path = ResPath.GetCommon("step_rexue_"..order)
			self:SetStepImg(path)
		end
	elseif ItemData.IsZhanShenEquip(self.data.item_id) then
		local order = item_cfg.orderType
		if order > 0 then
			local path = ResPath.GetCommon("z"..order)
			self:SetStepImg(path)
		end
	elseif ItemData.IsShaShenEquip(self.data.item_id) then
		local order = item_cfg.orderType
		if order > 0 then
			local path = ResPath.GetCommon("sha_shen_"..order)
			self:SetStepImg(path)
		end
	end
	--基础装备才有 
	if item_cfg.type >= ItemData.ItemType.itWeapon and item_cfg.type <= ItemData.ItemType.itShoes then
		local circle = 0
		for k,v in pairs(item_cfg.conds or{}) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				circle = v.value
				break
			end
		end

		if circle > 0 then
			self:SetRightBottomImageCircleShow(circle)
		end
	end

	local fusion_lv = EquipmentFusionData.GetFusionLv(self.data)
	self:SetFusionLv(fusion_lv)

	if nil ~= self.make_gray then
		self:MakeGray(self.make_gray)
	end
end

function BaseCell:SetShowImageSign(vis)
	if nil == self.sign_img then
		self.sign_img = self:CreateImage(ResPath.GetCommon("stamp_hhicon"), 20, 50, 999)
	end
	self.sign_img:setVisible(vis)
end

function BaseCell.IsMyGrid(name)
	if name == GRID_TYPE_BAG then
		return true
	elseif name == GRID_TYPE_STORAGE then
		return true
	elseif name == GRID_TYPE_RECYCLE_BAG then
		return true
	elseif name == GRID_TYPE_RECYCLE then
		return true
	elseif name == "GuildStorage" then
		return true
	end
	return false
end

function BaseCell:ClearData()
	if self.data == nil then
		return
	end
	self.data_from_index = - 1
	self.data = nil
	self.is_lock = false
	
	self.is_select = false
	self:ClearAllParts()
	self:ClearEvent()
end

function BaseCell:ClearAllParts()
	if self.select_effect and not self.is_select then self.select_effect:setVisible(false) end
	if self.bg_ta then self.bg_ta:setVisible(true) end
	if self.bg_ta2 then self.bg_ta2:setVisible(true) end
	if self.item_icon then self.item_icon:setVisible(false) end
	if self.bind_icon then self.bind_icon:setVisible(false) end
	if self.useless_modal then self.useless_modal:setVisible(false) end
	if self.quality_icon then self.quality_icon:setVisible(false) end
	if self.unopen_icon then self.unopen_icon:setVisible(false) end
	if self.lock_icon then self.lock_icon:setVisible(false) end
	if self.new_flag_icon then self.new_flag_icon:setVisible(false) end
	if self.item_desc then self.item_desc:setVisible(true) end
	if self.right_bottom_text then self.right_bottom_text:setVisible(false) end
	if self.right_bottom_imgnum_txt then self.right_bottom_imgnum_txt:SetVisible(false) end
	if self.right_top_num_txt then self.right_top_num_txt:setVisible(false) end
	if self.right_top_num_txt2 then self.right_top_num_txt2:setVisible(false) end
	if self.top_left_text then self.top_left_text:setVisible(false) end
	if self.special_ring_bg then self.special_ring_bg:setVisible(false) end
	if self.fusion_lv_bg then self.fusion_lv_bg:setVisible(false) end
	if self.sign_img then self.sign_img:setVisible(false) end
	if self.step_img then self.step_img:setVisible(false) end
	if self.decorate_img then self.decorate_img:setVisible(false) end
	if self.add_icon then self.add_icon:setVisible(false) end
	if self.circle_img then self.circle_img:setVisible(false) end

	self:SetRightBottomImageNumText(0)
	self:SetQualityEffect(0)
	self:SetShenEffect(false)
	self:SetExpMenoryEffect(false)
	self:CompleteCd()
end

function BaseCell:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(BaseCell.SIZE / 2, BaseCell.SIZE / 2,
	ResPath.GetCommon("cell_select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	
	self.view:addChild(self.select_effect, 999, 999)
end

-- 双击回调
function BaseCell:OnDoubleClick()
	if self.data == nil then
		return
	end
	local is_use = TipCtrl.Instance:DoubleClickUseItem(self.data, EquipTip.FROM_BAG) --双击使用物品
	if not is_use then 
		TipCtrl.Instance:OpenItem(self.data, EquipTip.FROM_BAG)
	end
end

-- 点击格子
local last_click_time = 0
local is_double = false
local click_space = 0
function BaseCell:OnClick()
	if self.is_lock ~= true then
		self:SetNewFlagIconVisible(false)
		if self.is_showtip and self.data ~= nil then
			if self.item_tip_from == EquipTip.FROM_BAG then
				--双击判断
				GlobalTimerQuest:AddDelayTimer(function ()
					if click_space > 0.24 then
						TipCtrl.Instance:OpenItem(self.data, self.item_tip_from or EquipTip.FROM_NORMAL)
					end
					is_double = false
				end, 0.25)
				click_space = Status.NowTime - last_click_time
				if click_space <= 0.24 then
					self:OnDoubleClick()
					is_double = true
				end
			else
				TipCtrl.Instance:OpenItem(self.data, self.item_tip_from or EquipTip.FROM_NORMAL)
			end

		end
		BaseRender.OnClick(self)
	else
		SysMsgCtrl.Instance:ErrorRemind(self.lock_reason_tip)
	end

	last_click_time = Status.NowTime
end

-- 长按
function BaseCell:OnClickLong()
	if not self.is_lock then
		if nil ~= self.long_click_callback then
			self.long_click_callback(self)
		end
	end
end

-- 数量
function BaseCell:SetItemNumTxt()
	if (self.data.item_id == CLIENT_GAME_GLOBAL_CFG.mainui_stone[1] or self.data.item_id == CLIENT_GAME_GLOBAL_CFG.mainui_stone[2])
	and self.data.durability and self.data.durability / 1000 > self.hide_num_if_less_numx then
		self:SetRightBottomText(tostring(self.data.durability / 1000))
	elseif ItemData.GetIsTransferStone(self.data.item_id) and self.data.durability and self.data.durability / 1000 > self.hide_num_if_less_numx then
		self:SetRightBottomText(tostring(self.data.durability / 1000))
	elseif self.data.num and self.data.num > self.hide_num_if_less_numx then
		if self.data.num >= 10000 then
			local num_wan = math.floor(self.data.num / 10000)
			self:SetRightBottomText(num_wan .. Language.Common.Wan)
		else
			self:SetRightBottomText(tostring(self.data.num))
		end
		-- self:SetRightBottomText(tostring(self.data.num))
	else
		self:SetRightBottomText("")
		self:SetRightBottomImageNumText(0)
	end
end

function BaseCell:CreateImage(path, x, y, zorder)
	if nil == self.view or nil == self.view.addChild then return end
	local img = XImage:create(path, true)
	img:setPosition(x, y)
	self.view:addChild(img, zorder, zorder)
	return img
end

function BaseCell:SetCfgEffVis(vis)
	self.is_show_cfg_effect = vis
	self:Flush()
end

-- 设置背景显示/隐藏
function BaseCell:SetCellBgVis(vis)
	self.is_show_cell_bg = vis
end

-- 设置背景
function BaseCell:SetCellBg(path)
	if self.is_show_cell_bg then
		if nil == self.bg_img and path then
			self.bg_img = self:CreateImage(path, BaseCell.SIZE / 2, BaseCell.SIZE / 2, - 1)
		elseif path then
			self.bg_img:loadTexture(path, true)
		end
	end
	if self.bg_img then
		self.bg_img:setVisible(self.is_show_cell_bg and path ~= nil)
	end
end

-- 设置专有背景
function BaseCell:SetCellSpecialBg(path)
	self.res_path = path
	self:SetCellBg(path)
end

-- 设置背景上图案
function BaseCell:SetBgTa(path)
	if nil == self.bg_ta then
		self.bg_ta = self:CreateImage(path, BaseCell.SIZE / 2, BaseCell.SIZE / 2, 1)
	else
		self.bg_ta:loadTexture(path)
		self.bg_ta:setVisible(true)
	end
end

-- 设置背景上图案2
function BaseCell:SetBgTa2(path)
	if nil == self.bg_ta2 then
		self.bg_ta2 = self:CreateImage(path, BaseCell.SIZE / 2, BaseCell.SIZE / 2 - 20, 1)
	else
		self.bg_ta2:loadTexture(path)
		self.bg_ta2:setVisible(true)
	end
end

-- 设置背景上图案显示
function BaseCell:SetBgTaVisible(value)
	if nil ~= self.bg_ta then
		self.bg_ta:setVisible(value)
	end
end

-- 设置物品图标
function BaseCell:SetItemIcon(path, scale)
	scale = scale or 1
	if nil == self.item_icon then
		self.item_icon = self:CreateImage(ResPath.GetItem(0), BaseCell.SIZE / 2, BaseCell.SIZE / 2 - 2, 2)
	else
		self.item_icon:loadTexture(ResPath.GetItem(0))
		self.item_icon:setVisible(true)
	end
	if self.item_icon then
		self.item_icon:loadTexture(path)
		self.item_icon:setScale(scale)
	end
end

-- 设置物品特效
function BaseCell:SetItemEffect(id, scale, boolean)
	scale = scale or 1
	boolean = boolean or false
	if id > 0 and nil == self.item_effect then
		self.item_effect = RenderUnit.CreateEffect(id, self:GetView(), 99, nil, nil, BaseCell.SIZE / 2, BaseCell.SIZE / 2 - 2)
		if boolean then
			CommonAction.ShowJumpAction(self.item_effect, 4, 1.5)
		end
		self.item_effect:setScale(scale)
		self.item_effect.SetAnimateRes = function(node, res_id)
			if nil ~= node.animate_res_id and node.animate_res_id == res_id then
				return
			end

			node.animate_res_id = res_id
			if res_id == 0 then
				node:setStop()
				return
			end

			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
			node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
	elseif nil ~= self.item_effect then
		self.item_effect:SetAnimateRes(id)
		self.item_effect:setVisible(id > 0)
		self.item_effect:setScale(scale)
	end
end

-- 设置绑定图标
function BaseCell:SetBindIconVisible(is_visible)
	if is_visible and nil == self.bind_icon then
		self.bind_icon = self:CreateImage(ResPath.GetCommon("lock_1"), 12, 12, 3)
	elseif nil ~= self.bind_icon then
		self.bind_icon:setVisible(is_visible)
	end
end

function BaseCell:SetStepImg(path)
	if nil == self.step_img then
		self.step_img = self:CreateImage(path, 20, BaseCell.SIZE / 2 + 10, 4)
	else
		self.step_img:loadTexture(path)
		self.step_img:setVisible(true)
	end
end

function BaseCell:SetDecorateImg(path)
	if nil == self.decorate_img then
		self.decorate_img = self:CreateImage(path, BaseCell.SIZE / 2, BaseCell.SIZE / 2 , 2)
	else
		self.decorate_img:loadTexture(path)
		self.decorate_img:setVisible(true)
	end
end

-- 设置是否需要不可用遮罩
function BaseCell:SetNeedUselessModdal(need_useless_modal)
	self.need_useless_modal = need_useless_modal
end

-- 设置不可用遮罩
function BaseCell:SetUselessModalVisible(is_visible)
	if is_visible and nil == self.useless_modal then
		self.useless_modal = self:CreateImage(ResPath.GetCommon("useless_modal"), BaseCell.SIZE / 2, BaseCell.SIZE / 2, 4)
	elseif nil ~= self.useless_modal then
		self.useless_modal:setVisible(self.need_useless_modal and is_visible)
	end
	
	-- 监听角色数据变化，只在有遮罩的时候监听
	if self.need_useless_modal and is_visible and nil == self.role_data_change_callback then
		self.role_data_change_callback = BindTool.Bind(self.OnRoleDataChange, self)
		RoleData.Instance:NotifyAttrChange(self.role_data_change_callback)
		self:RegisterNodeEvent()
	end
end

-- 设置勾选
function BaseCell:SetIsChoiceVisible(is_visible)
	if is_visible and nil == self.choice_img then
		self.choice_img = self:CreateImage(ResPath.GetCommon("img_gou"), BaseCell.SIZE / 2, BaseCell.SIZE / 2, 11)
	elseif nil ~= self.choice_img then
		self.choice_img:setVisible(is_visible)
	end
end

-- 装备越级改变
function BaseCell:OnEquipLevelAddChange()
	if self.need_useless_modal and self.item_big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		self:Flush()
	end
end

-- 角色数据改变
function BaseCell:OnRoleDataChange(attr_name, value)
	if self.need_useless_modal and self.item_big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and "level" == attr_name then
		self:Flush()
	end
end

-- 设置品质图标
function BaseCell:SetQualityIcon(path)
	if nil == self.quality_icon then
		self.quality_icon = self:CreateImage(path, BaseCell.SIZE / 2, BaseCell.SIZE / 2, 2)
	else
		self.quality_icon:loadTexture(path)
		self.quality_icon:setVisible(true)
	end
end

-- 设置未开启图标
function BaseCell:SetUnopenIconVisible(is_visible)
	if is_visible and nil == self.unopen_icon then
		self.unopen_icon = self:CreateImage(ResPath.GetCommon("cell_unopen"), BaseCell.SIZE / 2, BaseCell.SIZE / 2, 4)
	elseif nil ~= self.unopen_icon then
		self.unopen_icon:setVisible(is_visible)
	end
end

-- 锁定图标
function BaseCell:SetLockIconVisible(is_visible)
	if is_visible and nil == self.lock_icon then
		self.lock_icon = self:CreateImage(ResPath.GetCommon("cell_unopen"), BaseCell.SIZE / 2, BaseCell.SIZE / 2, 4)
	elseif nil ~= self.lock_icon then
		self.lock_icon:setVisible(is_visible)
	end
end

-- 新品图标标记
function BaseCell:SetNewFlagIconVisible(is_visible)
	if is_visible and self:GetData() == nil then return end
	
	if is_visible and nil == self.new_flag_icon and self:GetData() ~= nil then
		self.new_flag_icon = self:CreateImage(ResPath.GetCommon("new_item_flag"), BaseCell.SIZE, BaseCell.SIZE, 4)
		self.new_flag_icon:setAnchorPoint(1, 1)
	elseif nil ~= self.new_flag_icon then
		self.new_flag_icon:setVisible(is_visible)
	end
end

--设置上升标记
function BaseCell:SetUpFlagIconVisible(is_visible, lay)
	if lay then
		self.is_upflag = is_visible
	end
	if is_visible and self.upflag_icon == nil then
		self.upflag_icon = self:CreateImage(ResPath.GetCommon("uparrow_green2"), BaseCell.SIZE - 35, BaseCell.SIZE - 45, 10)
		self.upflag_icon:setAnchorPoint(0, 0)
		self.upflag_icon:setScale(0.8)
	end
	if self.upflag_icon then
		if is_visible then
			CommonAction.ShowJumpAction(self.upflag_icon)
		else
			self.upflag_icon:stopAllActions()
		end
		self.upflag_icon:setVisible(is_visible)
	end
end


function BaseCell:SetAddIconPath(vis)
	if nil == self.add_icon then
		self.add_icon = self:CreateImage(ResPath.GetRole("img_add"), BaseCell.SIZE/2, BaseCell.SIZE/2,1001)
	end
	self.add_icon:setVisible(vis)
end

--设置提醒标记
function BaseCell:SetRemind(is_visible, lay, x, y)
	if lay then
		self.is_remind = is_visible
	end
	if is_visible and self.remind_icon == nil then
		self.remind_icon = self:CreateImage(ResPath.GetMainui("remind_flag"), x or 0, y or(BaseCell.SIZE - 25), 1000)
		self.remind_icon:setAnchorPoint(0, 0)
	end
	if self.remind_icon then
		self.remind_icon:setVisible(is_visible)
	end
end

--设置宝石标记
function BaseCell:SetStoneIconVisible(is_visible)
	if is_visible and self.stone_icon == nil then
		self.stone_icon = self:CreateImage(ResPath.GetCommon("orn_102"), BaseCell.SIZE - 25, BaseCell.SIZE - 25, 4)
		self.stone_icon:setAnchorPoint(0, 0)
	end
	if self.stone_icon then
		self.stone_icon:setVisible(is_visible)
	end
end


--设置职业标记
function BaseCell:SetProfIconVisible(is_visible, prof)
	if is_visible and self.prof_icon == nil then
		self.prof_icon = self:CreateImage(ResPath.GetCommon("prof_" .. prof), BaseCell.SIZE - 25, 0, 4)
		self.prof_icon:setAnchorPoint(0, 0)
	end
	if self.prof_icon then
		self.prof_icon:setVisible(is_visible)
		if is_visible then
			self.prof_icon:loadTexture(ResPath.GetCommon("prof_" .. prof))
		end
	end
end

function BaseCell:SetOverdueTipText()
	if self.data and ItemData.IsShowTimeItem[self.data.item_id] and ItemData.Instance:CheckItemIsOverdue(self.data) then
		self:SetRightBottomText(Language.Tip.TimeTip2, COLOR3B.G_Y)
	end
end

-- 设置右下角文字
function BaseCell:SetRightBottomText(text, color, fontSize, outline_size)
	if nil == self.right_bottom_text then
		self.right_bottom_text = XUI.CreateText(BaseCell.SIZE - 6, 1, 80, 20,
		cc.TEXT_ALIGNMENT_RIGHT, text, COMMON_CONSTS.FONT, fontSize or 18, color)
		self.right_bottom_text:setAnchorPoint(1, 0)
		self.view:addChild(self.right_bottom_text, 999, 10)
	else
		self.right_bottom_text:setString(text)
		if color then
			self.right_bottom_text:setColor(color)
		end
		if fontSize then
			self.right_bottom_text:setFontSize(fontSize)
		end
		self.right_bottom_text:setVisible(self.rightbottom_text_isvisible)
	end
	if outline_size then
		self.right_bottom_text:enableOutline(COLOR4B.BLACK, outline_size)
	end
end

--设置右下角图片数字
function BaseCell:SetRightBottomImageNumText(num)
	if nil == self.right_bottom_imgnum_txt then
		if 0 == num then return end
		
		self.right_bottom_imgnum_txt = NumberBar.New()
		self.right_bottom_imgnum_txt:Create(BaseCell.SIZE - 5, 5, BaseCell.SIZE - 10, 20, ResPath.GetFightRoot("g_"))
		self.right_bottom_imgnum_txt:SetHasPlus(true)
		self.right_bottom_imgnum_txt:SetHasMinus(true)
		self.right_bottom_imgnum_txt:SetGravity(NumberBarGravity.Right)
		self.right_bottom_imgnum_txt:SetAnchorPoint(1, 0)
		self.right_bottom_imgnum_txt:GetView():setScale(0.4)
		self.view:addChild(self.right_bottom_imgnum_txt:GetView(), 10, 10)
	end
	
	self.right_bottom_imgnum_txt:SetVisible(0 ~= num and self.rightbottom_text_isvisible)
	self.right_bottom_imgnum_txt:SetNumber(num)
end

--设置右上角数字
function BaseCell:SetRightTopNumText(text, color, is_down)
	color = color or COLOR3B.WHITE
	if nil == self.right_top_num_txt then
		if text == 0 then return end
		self.right_top_num_txt = XUI.CreateText(5, is_down and 20 or BaseCell.SIZE - 4, BaseCell.SIZE - 8, 16, cc.TEXT_ALIGNMENT_RIGHT, text, nil, 18, color)
		self.right_top_num_txt:setAnchorPoint(0, 1)
		self.right_top_num_txt:enableOutline(cc.c4b(255, 255, 255, 150), 1)
		-- XUI.EnableShadow(self.right_top_num_txt, nil, cc.size(2, -2))
		self.view:addChild(self.right_top_num_txt, 3, 3)
	else
		self.right_top_num_txt:setString(text)
		self.right_top_num_txt:setColor(color)
		self.right_top_num_txt:setVisible(text ~= 0)
	end
end


function BaseCell:SetRightBottomImageCircleShow(circle)
	if self.circle_img == nil then
		self.circle_img =  self:CreateImage(ResPath.GetCommon("circle_img" .. circle), 5, 5, 10)
		self.circle_img:setAnchorPoint(0, 0)
	else
		self.circle_img:loadTexture(ResPath.GetCommon("circle_img" .. circle))
	end
	self.circle_img:setVisible(true)
end

--设置右上角第二行数字
function BaseCell:SetRightTopNumText2(text, color)
	color = color or COLOR3B.WHITE
	if nil == self.right_top_num_txt2 then
		if text == 0 then return end
		self.right_top_num_txt2 = XUI.CreateText(5, BaseCell.SIZE - 4 - 20, BaseCell.SIZE - 8, 16, cc.TEXT_ALIGNMENT_RIGHT, text, nil, 18, color)
		self.right_top_num_txt2:setAnchorPoint(0, 1)
		self.right_top_num_txt2:enableOutline(cc.c4b(255, 255, 255, 150), 1)
		XUI.EnableOutline(self.right_top_num_txt2, nil, 1)
		self.view:addChild(self.right_top_num_txt2, 3, 3)
	else
		self.right_top_num_txt2:setString(text)
		self.right_top_num_txt2:setColor(color)
		self.right_top_num_txt2:setVisible(text ~= 0)
	end
end

-- 设置背景文字
function BaseCell:SetItemDesc(text)
	if nil == self.item_desc then
		self.item_desc = XUI.CreateText(BaseCell.SIZE / 2, BaseCell.SIZE / 2, BaseCell.SIZE - 24, BaseCell.SIZE,
		cc.TEXT_ALIGNMENT_CENTER, text, COMMON_CONSTS.FONT, 20, COLOR3B.OLIVE, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		self.view:addChild(self.item_desc, 2, 2)
	else
		self.item_desc:setString(text)
		self.item_desc:setVisible(true)
	end
end

-- 设置左上角文字
function BaseCell:SetLeftTopText(text, color)
	color = color or COLOR3B.WHITE
	if nil == self.top_left_text then
		self.top_left_text = XUI.CreateText(4, BaseCell.SIZE - 4, BaseCell.SIZE - 8, 16, cc.TEXT_ALIGNMENT_LEFT, text, nil, 16, color)
		self.top_left_text:setAnchorPoint(0, 1)
		self.view:addChild(self.top_left_text, 3, 3)
	else
		self.top_left_text:setString(text)
		self.top_left_text:setColor(color)
		self.top_left_text:setVisible(true)
	end
end

--设置神特效
function BaseCell:SetShenEffect(value)
	if value and nil == self.shen_effect then
		self.shen_effect = AnimateSprite:create()
		self.view:addChild(self.shen_effect, 999, 999)
		self.shen_effect:setPosition(52, 52)
	end
	
	if self.shen_effect == nil then
		return
	end
	if value then
		local path, name = ResPath.GetEffectAnimPath(3062)
		self.shen_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		self.shen_effect:setVisible(true)
	else
		self.shen_effect:setVisible(false)
	end
end

--设置附灵特效
function BaseCell:SetExpMenoryEffect(value)
	if value and nil == self.exp_menory_effect then
		self.exp_menory_effect = AnimateSprite:create()
		self.exp_menory_effect:setPosition(BaseCell.SIZE / 2, BaseCell.SIZE / 2)
		-- self.exp_menory_effect:setScale(1.3)
		self.view:addChild(self.exp_menory_effect)
	end
	
	if nil ~= self.exp_menory_effect then
		if value then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(920)
			self.exp_menory_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		else
			self.exp_menory_effect:setStop()
		end
		self.exp_menory_effect:setVisible(value)
	end
end

--设置品质特效
function BaseCell:SetQualityEffect(effect_id, scale)
	scale = scale or 1
	if effect_id > 0 and nil == self.quality_effect then
		self.quality_effect = AnimateSprite:create()
		self.quality_effect:setPosition(BaseCell.SIZE / 2, BaseCell.SIZE / 2)
		self.view:addChild(self.quality_effect)
	end
	
	if nil ~= self.quality_effect then
		if effect_id > 0 then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.quality_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
			self.quality_effect:setScale(scale)
		else
			self.quality_effect:setStop()
		end
		self.quality_effect:setVisible(effect_id > 0)
	end
end

-- 设置无图标时图片的显示
function BaseCell:SetNoIconImgVis(vis)
	if nil ~= self.bg_ta then
		self.bg_ta:setVisible(vis)
	end
	if nil ~= self.bg_ta2 then
		self.bg_ta2:setVisible(vis)
	end
end

-- 设置CD
function BaseCell:SetCD(end_time, client_colddown)
	if client_colddown <= 0 or "" == self.name then
		self:CompleteCd()
		return
	end
	
	if nil == self.cd_mask then
		local sprite = XUI.CreateSprite(ResPath.GetCommon("cell_mask"))
		self.cd_mask = cc.ProgressTimer:create(sprite)
		self.cd_mask:setType(0)
		self.cd_mask:setPercentage(0)
		self.cd_mask:setReverseDirection(true)
		self.cd_mask:setPosition(BaseCell.SIZE / 2, BaseCell.SIZE / 2)
		self.view:addChild(self.cd_mask, 10, 10)
	end
	
	local cd_time = end_time - Status.NowTime
	if cd_time > 0 then
		self.cd_mask:setVisible(true)
		local init_time = client_colddown - cd_time
		
		self.cd_mask:setVisible(true)
		self.cd_mask:setPercentage((1 - init_time / client_colddown) * 100)
		
		local function update_cd(elapse_time, total_time)
			self.cd_mask:setPercentage((1 -(elapse_time + init_time) /(total_time + init_time)) * 100)
		end
		
		self:RemoveCountDown()
		BaseCell.index_inc = BaseCell.index_inc + 1
		self.cd_key = "base_cell_" .. BaseCell.index_inc
		-- CountDownManager.Instance:AddCountDown(self.cd_key, update_cd, BindTool.Bind(self.CompleteCd, self), nil, cd_time, 0.05)
	else
		self:CompleteCd()
	end
end

function BaseCell:CompleteCd()
	if nil ~= self.cd_mask then
		self.cd_mask:setVisible(false)
	end
	self:RemoveCountDown()
end

function BaseCell:RemoveCountDown()
	if "" ~= self.cd_key then
		-- CountDownManager.Instance:RemoveCountDown(self.cd_key)
		self.cd_key = ""
	end
end

-- 设置特戒融合标记
function BaseCell:SetSpecialRingBg(num)
	if num > 0 then
		if self.special_ring_bg then
			self.special_ring_bg:loadTexture(ResPath.GetCommon("stamp_special_ring_" .. num))
			self.special_ring_bg:setVisible(true)
		else
			self.special_ring_bg = XUI.CreateImageView(0, BaseCell.SIZE, ResPath.GetCommon("stamp_special_ring_" .. num), XUI.IS_PLIST)
			self.special_ring_bg:setAnchorPoint(0, 1)
			self.view:addChild(self.special_ring_bg, 2)
		end
	else
		if self.special_ring_bg then
			self.special_ring_bg:setVisible(false)
		end
	end
end

function BaseCell:SetFusionLv(fusion_lv)
	if fusion_lv > 0 then
		local path = ""
		local bool = ItemData.GetIsBasisEquip(self.data.item_id)
		if bool then
			path = ResPath.GetCommon("fusion_lv_1" .. fusion_lv)
		else
			path = ResPath.GetCommon("fusion_lv_" .. fusion_lv)
		end

		if self.fusion_lv_bg then
			self.fusion_lv_bg:loadTexture(path)
			self.fusion_lv_bg:setVisible(true)
		else
			if bool then
				self.fusion_lv_bg = self:CreateImage(path, 7, BaseCell.SIZE - 6, 2)
			else
				self.fusion_lv_bg = self:CreateImage(path, BaseCell.SIZE - 6, 7, 2)
			end
		end

		if bool then
			self.fusion_lv_bg:setAnchorPoint(0, 1)
			self.fusion_lv_bg:setPosition(7, BaseCell.SIZE - 6)
		else
			self.fusion_lv_bg:setAnchorPoint(1, 0)
			self.fusion_lv_bg:setPosition(BaseCell.SIZE - 6, 7)
		end
	else
		if self.fusion_lv_bg then
			self.fusion_lv_bg:setVisible(false)
		end
	end
end
