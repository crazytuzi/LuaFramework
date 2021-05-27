-- 运营活动 元宝转盘
GoldTurntableView = GoldTurntableView or BaseClass(BaseView)

local TURNTABLE_COUNT = 10
function GoldTurntableView:__init()

	if	GoldTurntableView.Instance then
		ErrorLog("[GoldTurntableView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self.is_modal = true
	self.background_opacity = 170	
	self.def_index = 1
	self.texture_path_list[1] = 'res/xui/recharge.png'
	self.texture_path_list[2] = 'res/xui/activity_brilliant.png'
	self.texture_path_list[3] = 'res/xui/scene.png'
	self.config_tab = {
		{"gold_turntable_ui_cfg", 1, {0}},
	}
	self.def_index = 1
	self.is_ten_draw = false
	self.is_fiften_draw = false
	self.turntable_cap = nil
end

function GoldTurntableView:__delete()
end

function GoldTurntableView:ReleaseCallBack()
	if self.spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_time)
		self.spare_time = nil
	end

	if self.turntable_cap ~= nil then
		self.turntable_cap:DeleteMe()
		self.turntable_cap = nil
	end

	if nil~=self.grid_truntable_scroll_list then
		self.grid_truntable_scroll_list:DeleteMe()
	end
	self.grid_truntable_scroll_list = nil

	self.world_record_list:DeleteMe()
end

local draw_num = 0
local draw_num_fif = 0

function GoldTurntableView:ButtonTenSetEnabled(bool)
	self.node_t_list.layout_draw_ten.node:setEnabled(bool)
	for k, v in pairs(self.node_t_list.layout_draw_ten.node:getChildren()) do
		v:setGrey(not bool)
	end
end

function GoldTurntableView:ButtonFifTenSetEnabled(bool)
	self.node_t_list.layout_draw_fiften.node:setEnabled(bool)
	for k, v in pairs(self.node_t_list.layout_draw_fiften.node:getChildren()) do
		v:setGrey(not bool)
	end
end

function GoldTurntableView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local ph = self.ph_list.ph_pos
		self.img_arrow = XUI.CreateImageView(ph.x, ph.y, ResPath.GetActivityBrilliant("turntable_arrow"), true)
		self.node_t_list.layout_gold_turntable.node:addChild(self.img_arrow, 10)
		-- self.img_arrow:setAnchorPoint(0.5, 102 / 250)

		self:CreateSpareTimer()
		self:CreateTurntableGridScroll()
		self:InitWorldRecord()
		self:CreateTurntableReward()
		self:CreateGoldNum()
		self.node_t_list.btn_draw.node:addClickEventListener(BindTool.Bind(self.OnClickGoldTurntableHandler, self))
		XUI.AddClickEventListener(self.node_t_list.layout_draw_ten.node, BindTool.Bind(self.OnClickGoldTurntableTenHandler, self), true)
		XUI.AddClickEventListener(self.node_t_list.layout_draw_fiften.node, BindTool.Bind(self.OnClickGoldTurntableFifTenHandler, self), true)
	end
	self.node_t_list.layout_33_auto_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind(self.OnClickTSAutoUse, self))
	self.node_t_list.layout_33_auto_hook.img_hook.node:setVisible(false)
end

function GoldTurntableView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function GoldTurntableView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if draw_num < 10 and true == self.is_ten_draw then
		for i = 1, 9 - draw_num do
			GlobalTimerQuest:AddDelayTimer(function ()
				ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.GOLDZP, 0)
			end, 1, 1)
		end
		self.current_index = 1
		self.is_ten_draw = false
		ItemData.Instance:SetDaley(false)
		draw_num = 0
	end
	if draw_num_fif < 50 and true == self.is_fiften_draw then
		for i = 1, 49 - draw_num_fif do
			GlobalTimerQuest:AddDelayTimer(function ()
				ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.GOLDZP, 0)
			end, 1, 1)
		end
		self.current_index = 1
		self.is_fiften_draw = false
		ItemData.Instance:SetDaley(false)
		draw_num_fif = 0
	end
end

function GoldTurntableView:OnClickTSAutoUse()
	local vis = self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible()
	self.node_t_list.layout_33_auto_hook.img_hook.node:setVisible(not vis)
end

function GoldTurntableView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GoldTurntableView:OnFlush(param_list, index)
	if self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible() then
		self:FlushWorldRecord()
	end
	self.turntable_cap:SetNumber(ActivityBrilliantData.Instance:GetJackpotNum())

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == act_cfg then return end
	local list = ActivityBrilliantData.Instance:GetTurntableRewardList()
	table.sort(list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)
	self.grid_truntable_scroll_list:SetDataList(list)
	self.grid_truntable_scroll_list:JumpToTop()
	self.node_t_list.lbl_draw_consum.node:setString(act_cfg.config.consume)
	self.node_t_list.lbl_gold_num.node:setString(act_cfg.config.addYb)
	-- self.node_t_list.lbl_gold_num.node:enableShadow(COLOR4B.BLACK)
	self.node_t_list.lbl_gold_num.node:enableOutline(COLOR4B.BLACK)
	for k,v in pairs(param_list) do
		if k == "result" and v.act_id == act_cfg.act_id and v.is_draw == 0  and v.result ~= 0 then
			if self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible() then
				self.node_t_list.btn_draw.node:setEnabled(true)
				self:ButtonTenSetEnabled(true)
				self:ButtonFifTenSetEnabled(true)
				-- self:FlushWorldRecord()
				return
			end
			self.node_t_list.btn_draw.node:setEnabled(false)
			self:ButtonTenSetEnabled(false)
			self:ButtonFifTenSetEnabled(false)
			self.img_arrow:stopAllActions()
			local rotate = self.img_arrow:getRotation() % 360
			local to_rotate =720 - rotate + 360 / TURNTABLE_COUNT / 2 + 360 / TURNTABLE_COUNT * (v.result - 1)
			local rotate_by = cc.RotateBy:create(1.2, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_draw.node:setEnabled(true)
				self:ButtonTenSetEnabled(true)
				ItemData.Instance:SetDaley(false)
				self:FlushWorldRecord()
				if self.is_ten_draw then
					draw_num = draw_num + 1
					if draw_num < 10 then
						self:OnClickGoldTurntableHandler()
						self.node_t_list.btn_draw.node:setEnabled(false)
						self:ButtonTenSetEnabled(false)
					else
						self.node_t_list.btn_draw.node:setEnabled(true)
						self:ButtonTenSetEnabled(true)
						self.is_ten_draw = false
						draw_num = 0
					end
				else
					self:ButtonTenSetEnabled(true)
					if self.node_t_list.btn_draw.node:isEnabled() then
						self:FlushWorldRecord()
					end
				end
				if self.is_fiften_draw then
					draw_num_fif = draw_num_fif + 1
					if draw_num_fif < 50 then
						self:OnClickGoldTurntableHandler()
						self.node_t_list.btn_draw.node:setEnabled(false)
						self:ButtonFifTenSetEnabled(false)
					else
						self.node_t_list.btn_draw.node:setEnabled(true)
						self:ButtonFifTenSetEnabled(true)
						self.is_fiften_draw = false
						draw_num_fif = 0
					end
				else
					self:ButtonFifTenSetEnabled(true)
					if self.node_t_list.btn_draw.node:isEnabled() then
						self:FlushWorldRecord()
					end
				end
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.img_arrow:runAction(sequence)
		else
			ItemData.Instance:SetDaley(true)
			-- self.node_t_list.layout_draw_ten.node:setEnabled(true)
			-- self.node_t_list.btn_draw.node:setEnabled(true)
		end
	end
end

function GoldTurntableView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_turntable_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function GoldTurntableView:CreateTurntableGridScroll()
	if nil == self.grid_truntable_scroll_list then
		local ph = self.ph_list.ph_turntable_reward_list
		self.grid_truntable_scroll_list = GridScroll.New()
		self.grid_truntable_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 135, TurntableItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gold_turntable_item)
		self.node_t_list.layout_gold_turntable.node:addChild(self.grid_truntable_scroll_list:GetView(), 100)
		self.grid_truntable_scroll_list:JumpToTop()
	end
end

function GoldTurntableView:CreateSpareTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareTime, self), 1)
end

function GoldTurntableView:CreateGoldNum()
	local cap_x, cap_y = self.node_t_list.lbl_gold_num.node:getPosition()
	self.turntable_cap = NumberBar.New()
	self.turntable_cap:SetRootPath(ResPath.GetCommon("num_155_"))
	-- self.turntable_cap:SetRootPath(ResPath.GetScene("zdl_y_"))
	self.turntable_cap:SetPosition(cap_x - 80, cap_y + 8)
	self.turntable_cap:SetSpace(-2)
	self.node_t_list.layout_gold_turntable.node:addChild(self.turntable_cap:GetView(), 300, 300)
end

function GoldTurntableView:CreateTurntableReward()
	self.table_reward_t = {}
	local r = 165
	local x, y = self.img_arrow:getPosition()
	for i = 1, TURNTABLE_COUNT do
		local cell = ActBaseCell.New()
		cell:SetPosition(x + r * math.cos(math.rad(70 - 360 / TURNTABLE_COUNT * (i - 1))),y  + r * math.sin(math.rad(72 - 360 / TURNTABLE_COUNT * (i - 1))))
		cell:SetCellBg()
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_gold_turntable.node:addChild(cell:GetView(), 8)
		table.insert(self.table_reward_t, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if act_cfg and act_cfg.config.award_1 then	
		for i,v in ipairs(self.table_reward_t) do
			local data =  act_cfg.config.award_1[i]

			if data then
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = 0 , effectId = data.effectId})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind =  0})
					end
				end
				if data.percent then
					local pos_x = x + r * math.cos(math.rad(70 - 360 / TURNTABLE_COUNT * (i - 1)))
					local pos_y = y + 10 + r * math.sin(math.rad(72 - 360 / TURNTABLE_COUNT * (i - 1)))
					local text = XUI.CreateText(pos_x, pos_y - 50, 100, 50, nil, string.format(Language.ActivityBrilliant.Text10, data.percent * 100 .. "%"))
					text:setColor(COLOR3B.GREEN)
					self.node_t_list.layout_gold_turntable.node:addChild(text,999)
					local bg = XUI.CreateImageViewScale9(pos_x, pos_y - 35, 100, 30, ResPath.GetCommon("bg_106"))
					self.node_t_list.layout_gold_turntable.node:addChild(bg,998)
				end
			else
				v:SetData()
			end
		end
	end
end

local draw_min_interval = 0.5
local last_draw_time = -1
function GoldTurntableView:OnClickGoldTurntableHandler()
	if NOW_TIME - last_draw_time < draw_min_interval then
		return
	end
	last_draw_time = NOW_TIME

	local act_id = ACT_ID.GOLDZP
	--跳过动画
	if self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible() and not self.is_ten_draw and not self.is_fiften_draw then 
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
		ItemData.Instance:SetDaley(false)
		return
	elseif self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible() and self.is_ten_draw then
		local num = draw_num
		if 10 - num > 0 then 	
			for i = 1, 10 - num do
				ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
			end
		end 
		draw_num = 0
		self.is_ten_draw = false
		ItemData.Instance:SetDaley(false)
		return
	elseif self.node_t_list.layout_33_auto_hook.img_hook.node:isVisible() and self.is_fiften_draw then
		local num = draw_num_fif
		if 50 - num > 0 then
			for i = 1 ,50 - num do
				ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
			end
		end
		draw_num_fif = 0
		self.is_fiften_draw = false
		ItemData.Instance:SetDaley(false)
		return
   	end
	ItemData.Instance:SetDaley(true)
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
end

function GoldTurntableView:OnClickGoldTurntableTenHandler()
	self.is_ten_draw = true
	self:OnClickGoldTurntableHandler()
end

function GoldTurntableView:OnClickGoldTurntableFifTenHandler()
	self.is_fiften_draw = true
	self:OnClickGoldTurntableHandler()
end

function GoldTurntableView:InitWorldRecord()
	local ph = self.ph_list.ph_turntable_record_list
	-- self.world_record_list = AutoHeightListView.New()
	-- self.world_record_list:Create(ph.x + 150, ph.y + 145, ph.w - 30, ph.h - 5, TurnItemRender)
	self.world_record_list = ListView.New()
	self.world_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldRecordTurntableRender, nil, nil, self.ph_list.ph_world_item)
	self.world_record_list:GetView():setAnchorPoint(0, 0)
	self.world_record_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_gold_turntable.node:addChild(self.world_record_list:GetView(), 100)
	self:FlushWorldRecord()
end

function GoldTurntableView:FlushWorldRecord()
	local item_name_list = ActivityBrilliantData.Instance:GetTurntableList()
	self.world_record_list:SetDataList(item_name_list)
	self.world_record_list:JumpToTop()
end

TurntableItemRender = TurntableItemRender or BaseClass(BaseRender)
function TurntableItemRender:__init()

end

function TurntableItemRender:__delete()
	if nil ~= self.qianggou_cell then
    	self.qianggou_cell:DeleteMe()
    	self.qianggou_cell = nil
    end
end

function TurntableItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.qianggou_cell = ActBaseCell.New()
	local ph = self.ph_list.ph_item_cell
	self.qianggou_cell:SetPosition(ph.x, ph.y)
	self.qianggou_cell:SetIndex(i)
	self.qianggou_cell:SetAnchorPoint(0.5, 0.5)
	self.view:addChild(self.qianggou_cell:GetView(), 300)
	XUI.AddClickEventListener(self.node_tree.layout_lingqu.node, BindTool.Bind(self.OnClickLingqu, self), true)
end

function TurntableItemRender:OnClickLingqu()
	if self.data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.data.act_id, self.data.index)
end




function TurntableItemRender:OnClick()
	-- local index=self:GetIndex()
	local view=ViewManager.Instance:GetView(ViewName.ActivityBrilliant)
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function TurntableItemRender:OnFlush()
	if nil == self.data then
		return
	end
	if self.data then
		if self.data.awards[1].type == tagAwardType.qatEquipment then
			self.qianggou_cell:SetData({["item_id"] = self.data.awards[1].id, ["num"] = self.data.awards[1].count, is_bind = self.data.awards[1].bind, effectId = self.data.awards[1].effectId})
		else
			local virtual_item_id = ItemData.GetVirtualItemId(self.data.awards[1].type)
			if virtual_item_id then
				self.qianggou_cell:SetData({["item_id"] = virtual_item_id, ["num"] = self.data.awards[1].count, is_bind = self.data.awards[1].bind or 0})
			end
		end
	else
		self.qianggou_cell:SetData()
	end
	local is_lingqu = self.data.sign > 0
	self.can_get_reward = self.data.awards[1].count <= ActivityBrilliantData.Instance.gold_draw_num
	if is_lingqu == true  then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.layout_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if self.can_get_reward then
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree.layout_lingqu.node:setVisible(true)
		else
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.layout_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_not_reach"))
		end
	end

	local draw_num = self.data.draw_num >= self.data.awards[1].count and self.data.awards[1].count or self.data.draw_num
	local color = self.data.draw_num >= self.data.awards[1].count and "1eff00" or "DC143C"
	local text = string.format(Language.ActivityBrilliant.Text9, color, draw_num, self.data.count)
	RichTextUtil.ParseRichText(self.node_tree.rich_draw_num.node,text, 18)
end

function TurntableItemRender:CreateSelectEffect()
end

WorldRecordTurntableRender = WorldRecordTurntableRender or BaseClass(BaseRender)
function WorldRecordTurntableRender:__init()	
end

function WorldRecordTurntableRender:__delete()	
end

function WorldRecordTurntableRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WorldRecordTurntableRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == cfg then return end
	local id = cfg.config.award_1[tonumber(self.data.index)].id
	local count = cfg.config.award_1[tonumber(self.data.index)].count

	if  ActivityBrilliantData.Instance == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local item_name = ItemData.Instance:GetItemName(id)
	local text_1 = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name ,id,color,count)
	local rich_1 = RichTextUtil.ParseRichText(self.node_tree.rich_turntable_record.node,text_1, 18)
end

function WorldRecordTurntableRender:CreateSelectEffect()
end


AutoHeightListView = AutoHeightListView or BaseClass(ChatListView)
function AutoHeightListView:__init(list_view, w)
	self.item_render = nil
end

function AutoHeightListView:__delete()
end

function AutoHeightListView:Create(x, y, w, h, item_render)
	if nil ~= self.list_view then
		return
	end
	self.item_render = item_render
	self.width = w
	self.list_view = XUI.CreateListView(x, y, w, h, ScrollDir.Vertical)
	self.list_view:setGravity(ListViewGravity.CenterHorizontal)
	self.list_view:setBounceEnabled(true)
	self.list_view:setMargin(5)
	self.list_view:setItemsInterval(5)

	self.list_view:addListEventListener(BindTool.Bind1(self.ListEventCallback, self))

	return self.list_view
end

function AutoHeightListView:RefreshItems()
	if self.data_list == nil or self.list_view == nil then
		return
	end

	local item_count = #self.items
	local data_count = #self.data_list

	if item_count > data_count then					-- item太多 删掉
		for i = item_count, data_count + 1, -1 do
			self:RemoveAt(i)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		for i = item_count + 1, data_count do
			item = self.item_render.New(self, self.width)
			item:SetIsUseStepCalc(self.is_step)
			table.insert(self.items, item)
			self.list_view:pushBackItem(item:GetView())
		end
	end

	for i = data_count, 1, -1 do
		self.items[i]:SetData(self.data_list[i])
	end
	local p = self.list_view:getInnerPosition()
end

function AutoHeightListView:JumpToTop()
	if need_refresh then
		self.list_view:refreshView()
	end
	self.list_view:jumpToTop()
end

TurnItemRender = TurnItemRender or BaseClass(BaseRender)
TurnItemRender.DefH = 20

function TurnItemRender:__init(list_view, w)
	self.list_view = list_view

	self.layout_w = w
	self.layout_h = TurnItemRender.DefH
	self.max_text_w = w - 10

	self.text_channel = nil
	self.rich_content = nil
	self.record_item = nil 

	self.view:setContentWH(self.layout_w, TurnItemRender.DefH)
end

function TurnItemRender:__delete()
	if self.record_item then
		self.record_item:DeleteMe()
		self.record_item = nil
	end
end

function TurnItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- 内容
	self.rich_content = XUI.CreateRichText(20, 15, self.max_text_w, 10, false)
	self.rich_content:setAnchorPoint(0, 1)
	self.view:addChild(self.rich_content)
end

function TurnItemRender:ClearContent()
	if self.rich_content then
		self.rich_content:removeAllElements()
	end
end

function TurnItemRender:OnFlush()
	self:ParseContent()
	self:UpdataLayout()
end

function TurnItemRender:ParseContent()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == cfg then return end
	local id = cfg.config.award_1[tonumber(self.data.index)].id
	local count = cfg.config.award_1[tonumber(self.data.index)].count

	if  ActivityBrilliantData.Instance == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end

	local text_1 = ""
	local item_name = ""
	if cfg.config.award_1[tonumber(self.data.index)].percent then 
		item_name = string.format(Language.ActivityBrilliant.Text10, cfg.config.award_1[tonumber(self.data.index)].percent * 100 .. "%")
		count =  self.data.num
		text_1 = string.format(Language.ActivityBrilliant.Txt2, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.ActivityBrilliant.Text11, color, item_name, id, Language.ActivityBrilliant.Text12, color,count)
	else
		text_1 = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name, id, color, count)
	end
	RichTextUtil.ParseRichText(self.rich_content, text_1, 18)
	self.rich_content:refreshView()
end

-- 更新布局
function TurnItemRender:UpdataLayout()
	-- 计算大小
	local final_h = 0

	local content_render_size = self.rich_content:getInnerContainerSize()
	final_h = final_h + content_render_size.height

	if final_h < TurnItemRender.DefH then final_h = TurnItemRender.DefH end

	if self.layout_h ~= final_h then
		self.layout_h = final_h
		self.view:setContentWH(self.layout_w, self.layout_h)
		self.list_view:OnItemHeightChange()
	end

	self.rich_content:setPosition(10, self.layout_h)
end
