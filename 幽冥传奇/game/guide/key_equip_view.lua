
KeyEquipView = KeyEquipView or BaseClass(BaseView)
KeyEquipView.Width = 200
KeyEquipView.Height = 280

KeyEquipView.HUNSHI_T = {}
KeyEquipView.KEY_USE_T = {[561] = 561}
function KeyEquipView:__init()
	self.can_penetrate = true -- 屏蔽根节点触摸
	self.zorder = COMMON_CONSTS.ZORDER_BETTER_EQUIP
	self.equip_data = CommonStruct.ItemDataWrapper()
	self.body_eq_data = CommonStruct.ItemDataWrapper()

	local start_pos = cc.p(HandleRenderUnit:GetWidth() / 2 + 23, MainuiChat.height)
	local move_end_pos = cc.p(HandleRenderUnit:GetWidth() / 2 + 23, MainuiChat.height + 100)
	local disappear_pos = cc.p(HandleRenderUnit:GetWidth() / 2 + 23 + 200, MainuiChat.height + 100)
	self.move_cfg = {
		start_pos = {[true] = start_pos, [false] = start_pos},
		move_end_pos = {[true] = cc.p(move_end_pos.x, move_end_pos.y + 85), [false] = move_end_pos},
		disappear_pos = {[true] = cc.p(disappear_pos.x, disappear_pos.y + 85), [false] = disappear_pos},
	}

	self.xuelian_items_map =  {}
	for k, v in pairs(CLIENT_GAME_GLOBAL_CFG.xuelian_items) do
		self.xuelian_items_map[v] = v
	end
end

function KeyEquipView:__delete()
end

function KeyEquipView:ReleaseCallBack()
	if self.equip then
		self.equip:DeleteMe()
		self.equip = nil
	end

	if self.zl_num then
		self.zl_num:DeleteMe()
		self.zl_num = nil
	end
end

function KeyEquipView:LoadCallBack(index, loaded_times)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	local bg = XUI.CreateImageViewScale9(260, 210, KeyEquipView.Width, KeyEquipView.Height, ResPath.GetCommon("img9_288"), true, cc.rect(24,22,11,12))
	self.root_node:addChild(bg)
	self.bg = bg
	XUI.AddClickEventListener(bg, BindTool.Bind(self.OnClickEquip, self))

	self.equip = BaseCell.New()
	self.equip:SetPosition(220, 220)
	self.root_node:addChild(self.equip:GetView(), 99)

	self.equip_name = XUI.CreateText(158, KeyEquipView.Height+ 50, 200, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20)
	self.equip_name:setAnchorPoint(0, 1)
	self.root_node:addChild(self.equip_name, 10)

	-- self.equip_cap = XUI.CreateText(90, 40, 200, 20, cc.TEXT_ALIGNMENT_LEFT, "0", nil, 20, COLOR3B.BLUE)
	-- self.equip_cap:setAnchorPoint(0, 1)
	-- self.root_node:addChild(self.equip_cap, 10)

	self.img_up = XUI.CreateImageView(335, KeyEquipView.Height / 2+42, ResPath.GetCommon("uparrow_green2"))
	self.img_up:setScale(0.8)
	self.root_node:addChild(self.img_up, 10)

	self.img_zl = XUI.CreateImageView(195, KeyEquipView.Height / 2+45, ResPath.GetCommon("word_zhanli"))
	self.img_zl:setScale(0.85)
	self.root_node:addChild(self.img_zl, 10)

	if self.zl_num == nil then
		self.zl_num = NumberBar.New()
		self.zl_num:SetGravity(NumberBarGravity.Left)
		self.zl_num:SetRootPath(ResPath.GetCommon("num_100_"))
		self.zl_num:SetPosition(220, KeyEquipView.Height / 2+35)
		self.zl_num:SetSpace(-1)
		self.zl_num:SetNumber(12)
		self.root_node:addChild(self.zl_num:GetView(), 100, 100)
	end

	-- self.equip_cap_up = XUI.CreateText(235 + 25, 40, 50, 20, cc.TEXT_ALIGNMENT_LEFT, "0", nil, 20, COLOR3B.GREEN)
	-- self.equip_cap_up:setAnchorPoint(0, 1)
	-- self.root_node:addChild(self.equip_cap_up, 10)

	self.btn_equip = XUI.CreateButton(KeyEquipView.Width +60, KeyEquipView.Height / 2-10, 0, 0, false, ResPath.GetCommon("btn_151"))
	self.btn_equip:setTitleFontName(COMMON_CONSTS.FONT)
	self.btn_equip:setTitleFontSize(24)
	self.btn_equip:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_EQUIP])
	self.root_node:addChild(self.btn_equip, 10)
	self.btn_equip:addClickEventListener(BindTool.Bind(self.OnClickEquip, self))

	self.auto_equip_txt = XUI.CreateText(KeyEquipView.Width+60, KeyEquipView.Height / 2 - 45, 200, 20, cc.TEXT_ALIGNMENT_center, "", nil, 19, COLOR3B.RED)
	self.root_node:addChild(self.auto_equip_txt, 10)

	self.close_btn = XUI.CreateButton(KeyEquipView.Width+ 155, KeyEquipView.Height + 65, 0, 0, false, ResPath.GetCommon("btn_100"))
	self.close_btn:addClickEventListener(BindTool.Bind(self.OnBtnClose, self))
	self.root_node:addChild(self.close_btn, 100)
end

function KeyEquipView:OpenCallBack()
end

function KeyEquipView:CloseCallBack()
	CountDown.Instance:RemoveCountDown(self.delay_cd)
	self.delay_cd = nil
end

function KeyEquipView:ShowIndexCallBack(index)
	local s_pos = self:GetPos("start_pos")
	local e_pos = self:GetPos("move_end_pos")

	self.root_node:setContentWH(KeyEquipView.Width, KeyEquipView.Height)
	self.root_node:setPosition(s_pos.x, s_pos.y)
	self.root_node:setOpacity(0)

	self:SetViewTouchEnabled(false)
	local move_to = cc.MoveTo:create(0.2, e_pos)
	local fade_in = cc.FadeIn:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_in)
	local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function()
		self:SetViewTouchEnabled(true)
	end))
	self.root_node:runAction(sequence)

	CountDown.Instance:RemoveCountDown(self.delay_cd)
	self.delay_cd = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.OnDelayCountDownUpdate, self))
--    if IS_AUDIT_VERSION then  
--        self:OnDelayCountDownUpdate(0, 0)
--    else
	    self:OnDelayCountDownUpdate(0, 2.9)
--    end

	self:Flush(index)
end

function KeyEquipView:OnFlush(param_t, index)
	if self.equip_data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.equip_data.item_id)
	if nil == item_cfg then return end

	-- 不是批量使用的物品数量调为1
	if ItemData.BatchStatus.OpenViewAndBatchUse ~= item_cfg.batchStatus then
		self.equip_data.num = 1
	end
	self.equip:SetData(self.equip_data)
	self.equip_name:setString(item_cfg.name)
	self.equip_name:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
	self.img_up:setVisible(not self:IsNormalUseItem(self.equip_data))
	self.img_zl:setVisible(not self:IsNormalUseItem(self.equip_data))

	if self.zl_num then
		self.zl_num:GetView():setVisible(not self:IsNormalUseItem(self.equip_data))
	end
	if self:IsNormalUseItem(self.equip_data) then
		local content =  Language.KeyUseItem[self.equip_data.item_id] or ""
		-- self.equip_cap:setString(content)
		-- self.equip_cap_up:setString("")
	else
		local cap = ItemData.Instance:GetItemScoreByData(self.equip_data)
		local eq_cap = ItemData.Instance:GetItemScoreByData(self.body_eq_data)
		-- self.equip_cap:setString(Language.Common.Capacity .. ":" .. cap)
		if self.zl_num then
			self.zl_num:SetNumber(cap)
		end
		-- self.equip_cap_up:setString(cap - eq_cap)
	end

	if self:IsNormalUseItem(self.equip_data) then
		self.btn_equip:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_USE])
	else
		self.btn_equip:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_EQUIP])
	end

end

-------------------------------------------------------------------------------------------
function KeyEquipView:GetPos(type)
	local mainui_task_bar = ViewManager.Instance:GetUiNode("MainUi", NodeName.MainuiTaskBar)
	local is_show_mainui_task = false
	if mainui_task_bar then
		is_show_mainui_task = mainui_task_bar:isVisible()
	end
	return self.move_cfg[type][is_show_mainui_task]
end

function KeyEquipView:OnBtnClose()
	if GuideCtrl.Instance:IsAutoTask() then
		self:OnAutoEquip()
	else
		self:Close(self.equip_data.item_id)
	end
end

function KeyEquipView:Close(item_id)
	GuideCtrl.Instance:KeyEquipViewCloseCallBack(item_id)
	if not self:IsOpen() then return end
	self:SetViewTouchEnabled(false)
	local move_to = cc.MoveTo:create(0.2, self:GetPos("disappear_pos"))
	local fade_out = cc.FadeOut:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_out)
	local callback = cc.CallFunc:create(function()
		BaseView.Close(self)
		GuideCtrl.Instance:UpdateRemindItemUse()
		GuideCtrl.Instance:OnChangeOneEquip()
	end)
	local action = cc.Sequence:create(spawn, callback)
	self.root_node:runAction(action)
end

function KeyEquipView:OnDelayCountDownUpdate(elapse_time, total_time)
	if nil == self.equip_data then 
		self:Close()
		return 
	end
	if elapse_time >= total_time then
		self:OnAutoEquip()
	end
	local left_time = total_time - elapse_time
	left_time = left_time > 0 and math.floor(left_time) or 0
 	if self:IsNormalUseItem(self.equip_data) then
 		self.auto_equip_txt:setString(string.format("%d秒后自动使用", left_time))
 	else
 		self.auto_equip_txt:setString(string.format("%d秒后自动装备", left_time))
 	end
end

function KeyEquipView:SetData(equip, eq_cfg, eq_data)
	if self.root_node then
		self.root_node:stopAllActions()
		BaseView.Close(self)
	end
	self.equip_data = TableCopy(equip)
	self.body_eq_data = eq_data or CommonStruct.ItemDataWrapper()
	self:Open()
	self:Flush()
end

function KeyEquipView:GetEquipData()
	return self.equip_data
end

function KeyEquipView:SetViewTouchEnabled(enabled)
	if self.equip then self.equip:GetView():setTouchEnabled(enabled) end
	if self.bg then self.bg:setTouchEnabled(enabled) end
end

function KeyEquipView:OnAutoEquip()
	if self:IsNormalUseItem(self.equip_data) then
		if self.xuelian_items_map[self.equip_data.item_id] and RoleData.HasBuffGroup(BUFF_GROUP.BLOOD_RETURNING) then
			self:Close(self.equip_data.item_id)
		else
			self:OnClickEquip()
		end
	else
		self:OnClickEquip()
	end
end

function KeyEquipView:OnClickEquip()
	local item_cfg = ItemData.Instance:GetItemConfig(self.equip_data.item_id)
	if nil == item_cfg then return end

	if self:IsNormalUseItem(self.equip_data) then
		BagCtrl.Instance:SendUseItem(self.equip_data.series, 0, self.equip_data.num)
	elseif ItemData.IsBaseEquipType(item_cfg.type) then
		local is_better, hand_pos = EquipData.Instance:GetIsBetterEquip(self.equip_data)
		hand_pos = hand_pos or EquipData.EQUIP_HAND_POS.LEFT
		EquipCtrl.Instance:FitOutEquip(self.equip_data, hand_pos)
	elseif ItemData.IsGuardEquip(item_cfg.type) then 				-- 守护神装
		GuardEquipCtrl.Instance.SendWearGuardEquipReq(self.equip_data.series)
	elseif ItemData.GetIsHandedDown(self.equip_data.item_id) then  -- 传世装备
		EquipCtrl.Instance:FitOutEquip(self.equip_data)
	elseif ItemData.GetIsConstellation(self.equip_data.item_id) then 	-- 星魂
		HoroscopeCtrl.PutOnConstellation(self.equip_data.series)
	elseif ItemData.IsRexue(item_cfg.type) then 	-- 热血装备
		EquipCtrl.Instance:FitOutEquip(self.equip_data)
	elseif ItemData.GetIsWingEquip(self.equip_data.item_id) then -- 翅膀装备
		WingCtrl.SendEquipmentShenyu(self.equip_data.series)
	elseif item_cfg.type == ItemData.ItemType.itFashion
	or item_cfg.type == ItemData.ItemType.itWuHuan
	or item_cfg.type == ItemData.ItemType.itGenuineQi
	then
		local item_type = item_cfg.type or 0
		local data_list = FashionData:GetFashionDataByItemType(item_type)
		
		local cur_count = 0
		for i,v in pairs(data_list or {}) do
			cur_count = cur_count + 1
		end
		
		if cur_count < GlobalConfig.nImageGridMaxCount then
			FashionCtrl.Instance:SendXingXiangGuan(self.equip_data.series) --放入形象框的直接幻化
			FashionCtrl.Instance:SendHuanhuaEquipReq(self.equip_data.series) --幻化
		else
			local EquipTypeName = Language.EquipTypeName[item_type] or ""
			local str  = Language.EquipTypeName[item_type] .. "槽位已满"
			SysMsgCtrl.Instance:FloatingTopRightText(str)
		end
	elseif ItemData.GetIsHeroEquip(self.equip_data.item_id) then
		ZhanjiangCtrl.HeroPutOnEquipReq(self.equip_data.series)
	elseif ItemData.GetIsZhanwenType(item_cfg.type) then
		local _, slot = BattleFuwenData.Instance:CheckIsWearable(self.equip_data)
		BattleFuwenData.Instance:SendCloth(self.equip_data, slot)
	elseif ItemData.GetIHandEquip(item_cfg.item_id) then
		EquipCtrl.SendFitOutEquip(self.equip_data.series)
	end

	self:Close()
end

-- 是否是普通的可使用的物品
function KeyEquipView:IsNormalUseItem(item)
	if nil == item then return false end
	return self.xuelian_items_map[item.item_id] or ItemData.Instance:CanCleanUpAutoUse(item)
end
