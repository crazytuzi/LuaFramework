
ActCanbaogeView = ActCanbaogeView or BaseClass(BaseView)
local RewardView = BaseClass()

local FLOOR_STEP_NUM = 18
function ActCanbaogeView:__init()
	if	ActCanbaogeView.Instance then
		ErrorLog("[ActCanbaogeView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self.is_modal = true
	self:SetBackRenderTexture(true)
	
	self.background_opacity = 170	
	self.def_index = 1

	self.is_arrow_act = true

	self.texture_path_list[1] = 'res/xui/act_canbaoge.png'
	self.texture_path_list[2] = 'res/xui/zhenbaoge.png'
	self.config_tab = {
		{"act_canbaoge_ui_cfg", 1, {0}},
		{"act_canbaoge_ui_cfg", 2, {0}},
	}
end

function ActCanbaogeView:__delete()
end

function ActCanbaogeView:ReleaseCallBack()
	if self.floor_cap ~= nil then
		self.floor_cap:DeleteMe()
		self.floor_cap = nil
	end

	if nil ~= self.cell_charge_list then
    	for k,v in pairs(self.cell_charge_list) do
    		v:DeleteMe()
  		end
    	self.cell_charge_list = nil
    end

    if self.spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_time)
		self.spare_time = nil
	end

	if self.myself_record_list then
		self.myself_record_list:DeleteMe()
		self.myself_record_list = nil
	end

	if self.lingqu_alert then
		self.lingqu_alert:DeleteMe()
		self.lingqu_alert = nil
	end

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end
end

function ActCanbaogeView:ShowIndexCallBack()
	local data = ActivityBrilliantData.Instance:GetCanbaogeData()
	self.reward_view:SetArrowStep(data.step_num, false)
	self.old_step_num = data.step_num
	self.node_t_list.layout_throw_free.node:setEnabled(true)
	self.node_t_list.layout_throw_gold.node:setEnabled(true)
	self:Flush()
end

function ActCanbaogeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:InitCellPosList()
		self:CreateGoldNum()
		-- self:CreateItemList()
		-- self:CreateArrow()
		self:CreateSpareTimer()
		self:CreateRecordList()

		local ph_window = self.ph_list.ph_window
		self.reward_view = RewardView.New(cc.p(ph_window.x, ph_window.y), cc.size(ph_window.w, ph_window.y))
		local award_data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG).config.award
		self.reward_view:SetDataList(award_data)
		self.reward_view:AddTo(self.node_t_list.layout_canbaoge.node, 99)

		local arrow_node = cc.Node:create()
		arrow_node:setAnchorPoint(0.5, 0.5)
		local arrow_size = cc.size(100, 100)
		local inner_x, inner_y = arrow_size.width / 2, arrow_size.height / 2 + 20
		local arrow_img = XUI.CreateImageView(inner_x, inner_y, ResPath.GetCanbaoge("img_arrow"), true)
		arrow_img:setScale(0.8)
		local move_to = cc.MoveTo:create(0.8, cc.p(inner_x, inner_y + 12))
		local move_back = cc.MoveTo:create(0.62, cc.p(inner_x, inner_y))
		local action = cc.RepeatForever:create(cc.Sequence:create(move_to, move_back))
		arrow_img:runAction(action)
		arrow_node:addChild(arrow_img, 10, 10)
		arrow_node:setContentSize(arrow_size)
		self.reward_view:SetArrowNode(arrow_node)

		self.skip_animate =  false
		self.node_t_list.img_hook.node:setVisible(self.skip_animate)

		local x, y = self.ph_list["ph_window"].x, self.ph_list["ph_window"].y - 40
		self.img_dice = XUI.CreateImageView(x, y, ResPath.GetZhenBaoGe("1"), true)
		self.img_dice:setVisible(false)
		self.node_t_list.layout_canbaoge.node:addChild(self.img_dice, 109)

		self.node_t_list.btn_duihuan.node:addClickEventListener(BindTool.Bind(self.OnClickDuiHuanHandler, self))
		self.node_t_list.btn_cengshu_reward.node:addClickEventListener(BindTool.Bind(self.OnClickLingquHandler, self, 3))
		self.node_t_list.btn_bushu_reward.node:addClickEventListener(BindTool.Bind(self.OnClickLingquHandler, self, 2))
		XUI.AddClickEventListener(self.node_t_list.layout_throw_free.node, BindTool.Bind(self.OnClickThorwHandler, self, 1), true)
		XUI.AddClickEventListener(self.node_t_list.layout_throw_gold.node, BindTool.Bind(self.OnClickThorwHandler, self, 2), true)
		XUI.AddClickEventListener(self.node_t_list.img_hook_bg.node, BindTool.Bind(self.SkipAnimate, self),false)
	end
end

function ActCanbaogeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if nil == self.roledata_change_callback then
		self.roledata_change_callback = BindTool.Bind(self.RoleDataChangeCallback,self)
		RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	end
	-- self:Flush()
	-- self.current_index = 1
end

function ActCanbaogeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	ItemData.Instance:SetDaley(false)
end

function ActCanbaogeView:RoleDataChangeCallback()
	self:Flush()
end

function ActCanbaogeView:OnFlush(param_list, index)
	self:FlushMyRecord()
	local data = ActivityBrilliantData.Instance:GetCanbaogeData()

	-- self:FlushItemList()
	-- self.arrow.UpdatePos(data.step_num - (data.floor_num - 1) * FLOOR_STEP_NUM)
	if data.step_num ~= self.old_step_num then
		local boor = data.step_num < self.old_step_num -- 是否回到1层
		if boor then
			local award_data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG).config.award
			self.reward_view:SetDataList(award_data)
		end
		local setdice = function ()
			self.img_dice:setVisible(true)
			local number = (not boor) and (data.step_num - self.old_step_num) or data.step_num
			self.img_dice:loadTexture(ResPath.GetZhenBaoGe(number))

			local callback2 = cc.CallFunc:create(function ()
				self.img_dice:setVisible(false)
				self.node_t_list.layout_throw_free.node:setEnabled(true)
				self.node_t_list.layout_throw_gold.node:setEnabled(true)
				self.reward_view:SetArrowStep(data.step_num, true, function() ItemData.Instance:SetDaley(false) end)
			end)
			local delay = cc.DelayTime:create(0.5)
			local action = cc.Sequence:create(delay,callback2)
			self.img_dice:runAction(action)
			self.old_step_num = data.step_num
		end
		local x, y = self.img_dice:getPosition()

		if self.skip_animate then
			setdice()
		else
			RenderUnit.PlayEffectOnce(399, self.node_t_list.layout_canbaoge.node, 100, x - 5, y + 170, false, setdice)
		end
	end
	self.floor_cap:SetNumber(data.floor_num)

	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	self.node_t_list.lbl_gold_spare.node:setString(string.format(Language.ActivityBrilliant.Text6, cfg.config.MoveConsume))
	self.node_t_list.lbl_free_throw_tip.node:setString(string.format(Language.ActivityBrilliant.CanbaogeTip1, cfg.config.everyDayMovePoint - data.free_num))
	self.node_t_list.lbl_free_throw_tip.node:setColor((cfg.config.everyDayMovePoint - data.free_num > 0) and COLOR3B.GOLD or COLOR3B.RED)
	self.node_t_list.lbl_gold.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.node_t_list.lbl_qz_num.node:setString(data.qz_sorce)
	self.node_t_list.lbl_mw_num.node:setString(data.mw_sorce)

	local step_can_lingqu, step_show_idx = ActivityBrilliantData.Instance:CheckAndGetStepCanLingquIdx()
	local floor_can_lingqu, floor_show_idx = ActivityBrilliantData.Instance:CheckAndGetFloorCanLingquIdx()

	self.node_t_list.img_remind_flag_step.node:setVisible(step_can_lingqu)
	self.node_t_list.img_remind_flag_floor.node:setVisible(floor_can_lingqu)

	local text_1 = data.step_num .. "/" .. cfg.config.speicalpoint[step_show_idx].point .. Language.ActivityBrilliant.Text23
	local text_2 = data.floor_num .. "/" .. cfg.config.totalpiles[floor_show_idx].piles .. Language.ActivityBrilliant.Text24
	self.node_t_list.lbl_right_text_1.node:setString(text_1)
	self.node_t_list.lbl_right_text_2.node:setString(text_2)

	self:FlushAlert(self.award_tag)
	if self.award_tag == 2 then 
		can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetStepCanLingquIdx()
	elseif self.award_tag == 3 then
		can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetFloorCanLingquIdx()
	end
	if not can_lingqu and self.lingqu_alert then
		self.lingqu_alert:Close()
	end
end

function ActCanbaogeView:SkipAnimate()
	self.skip_animate = not self.skip_animate
	self.node_t_list.img_hook.node:setVisible(self.skip_animate)
end

function ActCanbaogeView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_time_spare.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActCanbaogeView:InitCellPosList()
	self.ph_cell_list = {}
	local ph_start = self.ph_list.ph_cell
	local width, height = 76.5, 79

	for i = 1, 18 do
		self.ph_cell_list[i] = {}
		if i == 18 then
			self.ph_cell_list[i][1] = ph_start.x
			self.ph_cell_list[i][2] = ph_start.y
		elseif i == 9 then
			self.ph_cell_list[i][1] = ph_start.x + width * 7
			self.ph_cell_list[i][2] = ph_start.y - height * 2
		elseif i < 9 then
			self.ph_cell_list[i][1] = ph_start.x + width * (i - 1)
			self.ph_cell_list[i][2] = ph_start.y - height * 3
		elseif i > 9 then
			self.ph_cell_list[i][1] = ph_start.x + width * (FLOOR_STEP_NUM - i -1)
			self.ph_cell_list[i][2] = ph_start.y - height
		end
	end
end

function ActCanbaogeView:CreateSpareTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
	self:UpdateSpareTime()
end

function ActCanbaogeView:CreateArrow()
	if nil == self.ph_cell_list then return end
	if self.is_arrow_act then
		self.arrow = XUI.CreateImageView(self.ph_cell_list[1][1], self.ph_cell_list[1][2] + 30, ResPath.GetCanbaoge("img_arrow"))
		self.arrow:setScale(0.8)
		self.node_t_list.layout_canbaoge.node:addChild(self.arrow, 999)

		self.arrow.UpdatePos = function (idx)
			if idx <= 0 then idx = 1 end
			local x = self.ph_cell_list[idx][1]
			local y = self.ph_cell_list[idx][2] + 30
			self.arrow:setPosition(x, y)
			self.arrow:stopAllActions()
			local move_to = cc.MoveTo:create(0.8, cc.p(x, y + 10))
			local move_back = cc.MoveTo:create(0.6, cc.p(x, y))
			local spawn = cc.Sequence:create(move_to, move_back)
			local action = cc.RepeatForever:create(spawn)
			self.arrow:runAction(action)
		end
		self.arrow.UpdatePos(1)
	else
	end

	self.arrow:setVisible(false)
end

function ActCanbaogeView:CreateItemList()
	self.cell_charge_list = {}
	if nil == self.ph_cell_list then return end
	for i = 1, 18 do
		local cell = BaseCell.New()
		cell:SetPosition(self.ph_cell_list[i][1], self.ph_cell_list[i][2])
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		-- cell:GetView():setScale(0.9)
		self.node_t_list.layout_canbaoge.node:addChild(cell:GetView(), 300)
		table.insert(self.cell_charge_list, cell)
	end

	-- self:FlushItemList()
end

function ActCanbaogeView:FlushItemList()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	if nil == cfg then return end

	local floor_num = ActivityBrilliantData.Instance:GetCanbaogeData().floor_num
	self.floor_cap:SetNumber(floor_num)

	local data = cfg.config.award
	for k,v in pairs(self.cell_charge_list) do
		local item_data = {}
		local pos = (floor_num - 1) * FLOOR_STEP_NUM + k
		if nil ~= data[pos] then
			item_data.item_id = data[pos].id
			item_data.num = data[pos].count
			item_data.is_bind = data[pos].bind
			item_data.effectId = data[pos].effectId
			if data[pos].string == "curiositiesScore" then
				item_data.item_id = 3989
			elseif data[pos].string == "secretScore" then
				item_data.item_id = 3990
			end
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
		-- v:SetVisible(data[k] ~= nil)
		v:SetVisible(false)
	end
end

function ActCanbaogeView:CreateSpareTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareTime, self), 1)
end

function ActCanbaogeView:CreateGoldNum()
	local ph = self.ph_list["ph_number"]
	self.floor_cap = NumberBar.New()
	self.floor_cap:SetRootPath(ResPath.GetCommon("num_213_"))
	self.floor_cap:SetPosition(ph.x, ph.y)
	self.floor_cap:SetSpace(-2)
	self.floor_cap:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_canbaoge.node:addChild(self.floor_cap:GetView(), 99, 300)
	self.floor_cap:SetNumber(1)
end

function ActCanbaogeView:CreateTurntableReward()
	self.table_reward_t = {}
end

function ActCanbaogeView:CreateRecordList()
	local ph = self.ph_list.ph_myself_records_list
	if self.myself_record_list == nil then
		self.myself_record_list = ListView.New()
		self.myself_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActCanbaogeRecordRender, nil, nil, self.ph_list.ph_my_record)
		self.myself_record_list:GetView():setAnchorPoint(0, 0)
		self.myself_record_list:SetJumpDirection(ListView.Top)
		self.myself_record_list:SetItemsInterval(8)
		self.node_t_list.layout_canbaoge.node:addChild(self.myself_record_list:GetView(), 100)
	end
end

function ActCanbaogeView:FlushMyRecord()
	self.myself_record_list:SetDataList(ActivityBrilliantData.Instance:GetCanbaogeLingquRecord())
end

function ActCanbaogeView:OnClickThorwHandler(tag)
	if not self.reward_view:ArrowCanMove() then
		return
	end
	ItemData.Instance:SetDaley(true)
	self.node_t_list.layout_throw_free.node:setEnabled(false)
	self.node_t_list.layout_throw_gold.node:setEnabled(false)
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.CBG, tag, 1)
end

function ActCanbaogeView:OnClickDuiHuanHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ActCanbaogeDuiHuan)
end

function ActCanbaogeView:OnClickLingquHandler(tag)
	self.award_tag = tag
	if nil == self.lingqu_alert then
		self.lingqu_alert = ActLingquAwardAlertView.New()
	end
	self.lingqu_alert:Open()

	self:FlushAlert(tag)
	self.lingqu_alert:SetOkFunc(function ()
		self:FlushAlert(tag)
		local can_lingqu, show_idx
		if tag == 2 then 
			can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetStepCanLingquIdx()
		elseif tag == 3 then
			can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetFloorCanLingquIdx()
		end
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.CBG, show_idx, tag)
	end)

end

function ActCanbaogeView:FlushAlert(tag)
	if nil == self.lingqu_alert then return end
	if nil == tag then tag = self.award_tag and self.award_tag or 2 end
	local can_lingqu, show_idx
	if tag == 2 then 
		can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetStepCanLingquIdx()
	elseif tag == 3 then
		can_lingqu, show_idx = ActivityBrilliantData.Instance:CheckAndGetFloorCanLingquIdx()
	end
	local _desc = Language.ActivityBrilliant.CanbaogeAlert[tag]
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	if nil == cfg then return end
	local data = tag == 2 and cfg.config.speicalpoint[show_idx].award or cfg.config.totalpiles[show_idx].award
	local _item_list = {}
	for i, v in ipairs(data) do
		local vo = {}
		vo.item_id = v.id
		vo.num = v.count
		vo.is_bind = v.bind
		vo.effectId = v.effectId
		_item_list[i] = vo
	end
	self.lingqu_alert:Flush(0, "all", {desc = _desc, item_list = _item_list})
end

ActCanbaogeRecordRender = ActCanbaogeRecordRender or BaseClass(BaseRender)
function ActCanbaogeRecordRender:__init()	
end

function ActCanbaogeRecordRender:__delete()	
end

function ActCanbaogeRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ActCanbaogeRecordRender:OnClickItemTipsHandler()
	TipCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_NORMAL)
end

function ActCanbaogeRecordRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	if nil == cfg then return end

	local num, text
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	if self.data.num and self.data.num == 1 then
		num = cfg.config.speicalpoint[self.data.index].point
		text = string.format(Language.ActivityBrilliant.CanbaogeLingqu2, self.rolename_color, self.data.name, num)
	else
		num = cfg.config.totalpiles[self.data.index].piles
		text = string.format(Language.ActivityBrilliant.CanbaogeLingqu, self.rolename_color, self.data.name, num)
	end

	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node,text, 18)
end

function ActCanbaogeRecordRender:CreateSelectEffect()
end


-----------------------------------------------------------------
-- RewardView begin
-----------------------------------------------------------------
RewardView.MOVE_ARROW_STATE = {
	MOVE_END = 0,
	MOVE_ARROW = 1,
	MOVE_LAYER = 2,
}
function RewardView:__init(pos, size)
	self.pos = pos
	self.size = size
	self.rewards = {}
	self.data_list = {}

	self.row_interval = 1
	self.col_interval = 0
	self.vertical_margin = 0
	self.horizontal_margin = 0
	self.item_w = 77
	self.item_h = 78

	self.reward_pos_t = {
		{1,	2, 3, 4, 5, 6, 7},
		{0, 0, 0, 0, 0, 0, 8},
		{15, 14, 13, 12, 11, 10, 9},
		{16, 0, 0, 0, 0, 0, 0, 0},
	}
	self.idx_row_col = {}
	for row, col_t in pairs(self.reward_pos_t) do
		for col, i in pairs(col_t) do
			if i > 0 then
				self.idx_row_col[i] = {row  = row, col = col}
			end
		end 
	end

	self.layer_row = #self.reward_pos_t
	self.layer_col = #self.reward_pos_t[1]
	self.layer_item_num = #self.idx_row_col
	self.one_layer_h = self.layer_row * self.item_h + self.vertical_margin + (self.layer_row - 0) * self.row_interval

	self.last_step = -1
	self.cur_step = -1
	self.step = -1
	self.move_arrow_state = 0
	self.move_end_callback = nil
	self.cur_layer = 1

	self.view = XUI.CreateScrollView(self.pos.x, self.pos.y, self.size.width, self.one_layer_h, ScrollDir.Vertical)
	self.view:setTouchEnabled(false)
	self.create_rewards_task = nil
end

function RewardView:__delete()
	GlobalTimerQuest:CancelQuest(self.move_timer)
	self.move_timer = nil
	self.view = nil
	Runner.Instance:RemoveRunObj(self)
	self.create_rewards_task = nil
end

function RewardView:AddTo(parent, zorder)
	if nil ~= parent then
		parent:addChild(self.view, zorder or 0)
	end
end

function RewardView:ArrowCanMove()
	return self.move_arrow_state == RewardView.MOVE_ARROW_STATE.MOVE_END
end

function RewardView:SetArrowStep(step, is_move, move_end_callback)
	if self.step ~= step then
		self.last_step = self.step
		self.step = step
	else
		return false
	end

	self.move_end_callback = move_end_callback
	if is_move then
		if not self:ArrowCanMove() then
			return false
		end

		self.arrow_move_speed = 1
		self:ArrowMove()
	else
		self:ArrowMoveEnd()
	end

	return true
end

function RewardView:ArrowMove()
	self:GetArrow():setVisible(self.cur_step > 0)

	local next_step = self.cur_step + 1
	if next_step > self.step then
		self:ArrowMoveEnd()
		return
	end

	local next_layer = self:GetLayer(next_step)
	if self.cur_layer ~= next_layer then
		self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_LAYER
		local jump_time = 0.88
		self:JumpTolayer(self:GetLayer(next_step), jump_time)
		GlobalTimerQuest:CancelQuest(self.move_timer)
		self.move_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.move_timer = nil
			self:ArrowMove()
		end, jump_time)
		return
	end

	self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_ARROW
	local callfunc = cc.CallFunc:create(function()
		self.cur_step = self.cur_step + 1
		self:ArrowMove()
	end)
	-- local act = cc.Sequence:create(cc.DelayTime:create(0.14), cc.Place:create(cc.p(self:GetPosByStep(next_step))), callfunc)
	self.arrow_move_speed = (self.arrow_move_speed * 0.5) > 0.27 and self.arrow_move_speed * 0.5 or 0.27
	local act = cc.Sequence:create(cc.MoveTo:create(0.21 * self.arrow_move_speed, cc.p(self:GetPosByStep(next_step))), cc.DelayTime:create(0.05), callfunc)
	self:GetArrow():stopAllActions()
	self:GetArrow():runAction(act)
end

function RewardView:ArrowMoveEnd()
	GlobalTimerQuest:CancelQuest(self.move_timer)
	self.move_timer = nil

	self:GetArrow():stopAllActions()
	self:GetArrow():setPosition(self:GetPosByStep(self.step))
	self:JumpTolayer(self:GetLayer(self.step), 0)
	self.cur_step = self.step
	self:GetArrow():setVisible(self.cur_step > 0)

	if self.move_end_callback then
		self.move_end_callback()
	end
	self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_END
end

function RewardView:GetArrow()
	return self.view:getChildByName("arrow")
end

function RewardView:SetArrowNode(node)
	if nil == self.view:getChildByName("arrow") then
		self.view:addChild(node, 200)
		node:setName("arrow")
	end
	-- self:SetArrowStep(self.step, false)
end

function RewardView:GetPosByRowCol(row, col)
	return (col - 1) * (self.item_w + self.col_interval) + self.item_w * 0.5 + self.horizontal_margin,
		(row - 1) * (self.item_h + self.row_interval) + self.item_h * 0.5 + self.vertical_margin
end

function RewardView:GetLayer(idx)
	return math.floor((idx - 1) / self.layer_item_num) + 1
end

function RewardView:GetRowCol(idx)
	return self.idx_row_col[idx] or {row = 0, col = 0}
end

function RewardView:JumpTolayer(layer, time, attenuated)
	self.view:scrollToPositionY(- (layer - 1) * self.one_layer_h, time or 0.5, attenuated or false)
	self.cur_layer = layer
end

function RewardView:GetPosByStep(step)
	local layer_idx = self:GetLayer(step)
	local row_col_t = self:GetRowCol(step - (layer_idx - 1) * self.layer_item_num)
	local row = row_col_t.row + (layer_idx - 1) * self.layer_row
	local col = row_col_t.col
	return self:GetPosByRowCol(row, col)
end

function RewardView:Update()
	if nil ~= self.create_rewards_task then
	    local status = coroutine.resume(self.create_rewards_task, self)
	    if not status then
	    	self.create_rewards_task = nil
			Runner.Instance:RemoveRunObj(self)
	    end
	end
end

function RewardView:SetDataList(data_list)
	self.data_list = data_list or {}

	local max_row = math.floor(#self.data_list / self.layer_item_num) * self.layer_row
	self.view:setInnerContainerSize(cc.size(
		self.layer_col * self.item_w + (self.layer_col - 1) * self.col_interval + 2 * self.horizontal_margin,
		max_row * self.item_h + (max_row - 1) * self.row_interval + 2 * self.vertical_margin
	))

    self.create_rewards_task = coroutine.create(self.CreateRewards)
	Runner.Instance:AddRunObj(self)
end

function RewardView:CreateRewards(begin_step)
	self.rewards = self.rewards or {}

	local idx = self.step - ((self.step - 1) % self.layer_item_num)			-- 当前楼层第一格
	idx = (self.rewards[idx] or self.data_list[idx] == nil) and 1 or idx 	-- 已创建过时,从第一格开始检查

	local item_cfg = self.data_list[idx]

	while item_cfg do
		if self.rewards[idx] == nil then
			local item_data = {
				item_id = item_cfg.id,
				num = item_cfg.count,
				is_bind = item_cfg.bind,
				effectId = item_cfg.effectId,
			}
			if item_cfg.string == "curiositiesScore" then
				item_data.item_id = 3989
			elseif item_cfg.string == "secretScore" then
				item_data.item_id = 3990
			end

			local cell = BaseCell.New()
			cell:SetIsUseStepCalc(true)
			cell:SetPosition(self:GetPosByStep(idx))
			cell:SetIndex(idx)
			cell:SetAnchorPoint(0.5, 0.5)
			cell:SetData(item_data)
			cell:GetView():setPropagateTouchEvent(false)
			cell:SetCfgEffVis(false)
			self.view:addChild(cell:GetView(), 99)
			self.rewards[idx] = cell
		end
		idx = idx + 1
		item_cfg = self.data_list[idx]

		if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.012 then
	        coroutine.yield(idx)
		end
	end
end
-----------------------------------------------------------------
-- RewardView end
-----------------------------------------------------------------
