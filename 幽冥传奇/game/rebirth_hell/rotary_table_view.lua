------------------------------------------------------------
-- 跨服BOSS-轮回地狱子视图	配置 CrossWheelCfg
------------------------------------------------------------

local RotaryTableView = BaseClass(SubView)

function RotaryTableView:__init()
	self.texture_path_list[1] = 'res/xui/rebirth_hell.png'
	self.config_tab = {
		{'rebirth_hell_ui_cfg', 3, {0}},
	}
	
	self.data = nil
end

function RotaryTableView:__delete()
end

function RotaryTableView:ReleaseCallBack()
	
	if self.item_cell_list then
		for _, v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = nil
	end

	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end
end

function RotaryTableView:LoadCallBack(index, loaded_times)
	self.data = RebirthHellData.Instance:GetRotaryTableData()

	self:CreateCellView()
	self:CreateRecordList()

	local text = Language.RebirthHell.LuckyDrawDost .. CrossWheelCfg.drawOnceYb
	self.node_t_list['lbl_lucky_draw_cost'].node:setString(text)

	self.node_t_list['img_pointer'].node:setAnchorPoint(cc.p(0.5, 0))

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list['btn_lucky_draw'].node, BindTool.Bind(self.OnLuckyDraw, self), true)

	-- 数据监听
	EventProxy.New(RebirthHellData.Instance, self):AddEventListener(RebirthHellData.ROTARY_TABLE_DATA_CHANGE, BindTool.Bind(self.OnRotaryTableDataChange, self))

end

--显示索引回调
function RotaryTableView:ShowIndexCallBack(index)
	self:FlushNumberView()
	self:FlushMyRecord()
	self:FlushCellView()
	self.node_t_list['btn_lucky_draw'].node:setEnabled(true)
end

----------视图函数----------

-- 创建'物品图标'视图
function RotaryTableView:CreateCellView()
	local cfg = RebirthHellData.Instance.GetRotaryTableItemData(1)
	self.item_cell_list = {}
	for i = 1, 10 do
		ph = self.ph_list['ph_cell_' .. i]
		self.item_cell_list[i] = BaseCell.New()
		self.item_cell_list[i]:SetPosition(ph.x, ph.y)
		self.item_cell_list[i]:SetData(cfg[i])
		self.node_t_list['layout_rotary_table'].node:addChild(self.item_cell_list[i]:GetView(), 1)
		if cfg[i].percent ~= nil and cfg[i].percent ~= 0 then
			if nil ~= self.node_t_list['lbl_item_name_' .. i] then
				local percent = cfg[i].percent * 100
				self.node_t_list['lbl_item_name_' .. i].node:setString(percent .. "%奖池")
			end
		end
	end
end

function RotaryTableView:FlushCellView()
	if nil == next(self.item_cell_list) then return end
	local cfg = RebirthHellData.Instance.GetRotaryTableItemData(tonumber(self.data.show_index))
	for i = 1, 10 do
		self.item_cell_list[i]:SetData(cfg[i])
		if cfg[i].percent ~= nil and cfg[i].percent ~= 0 then
			if nil ~= self.node_t_list['lbl_item_name_' .. i] then
				local percent = cfg[i].percent * 100
				self.node_t_list['lbl_item_name_' .. i].node:setString(percent .. "%奖池")
			end
		end
	end
end

-- 刷新可击杀数量和奖池
function RotaryTableView:FlushNumberView()
	local text = Language.RebirthHell.LotteryNumber .. self.data.number
	self.node_t_list['lbl_lottery_number'].node:setString(text)
	self.node_t_list['lbl_jackpot'].node:setString(self.data.jackpot)
end

-- 创建'转盘动作'
function RotaryTableView:FlushAction()
	if self.data.show_index == 0 then return end
	local item_index = self.data.index

	self.node_t_list['img_pointer'].node:stopAllActions()

	local act_info = {{0.5, 0.5}, {0.3, 0.5}, {0.2, 0.5}, {1.5, 5}} -- 启动动作
	local act_info_item ={{0.18, 0.6}, {0.16, 0.4}, {0.2, 0.4}, {0.25, 0.4}, {0.15, 0.2}, {0.25, 0.25}, {0.4, 0.2}, {0.15, 0.05}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation()
	local item_Angle = (item_index * 360 / 10 - 18 - current_angle%360 + 360)%360
	local ratio = (item_Angle  + 900) / 900
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end

	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t))
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self)))
	self.node_t_list['img_pointer'].node:runAction(seq_act)
end

-- 创建"抽奖记录"列表
function RotaryTableView:CreateRecordList()
	local ph = self.ph_list.ph_record_list
	if self.record_list == nil then
		self.record_list = ListView.New()
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.RotaryTableRender, nil, nil, self.ph_list.ph_item)
		self.record_list:GetView():setAnchorPoint(0, 0)
		self.record_list:SetItemsInterval(2)
		self.node_t_list['layout_rotary_table'].node:addChild(self.record_list:GetView(), 100)
	end
end

-- 刷新"抽奖记录"
function RotaryTableView:FlushMyRecord()
	if nil == self.record_list then return end
	self.record_list:SetDataList(RebirthHellData.Instance:GetRotaryTableRecord())
end

----------end----------

-- '抽奖按钮'点击回调
function RotaryTableView:OnLuckyDraw()
	self.node_t_list['btn_lucky_draw'].node:setEnabled(false)
	BagData.Instance:SetDaley(true)
	RebirthHellCtrl.Instance.SendRotaryTableReq(2)
end

-- '转盘数据'改变回调
function RotaryTableView:OnRotaryTableDataChange()
	self:FlushNumberView()
	if self.data.index == 0 then
		self:FlushCellView()
	else
		self:FlushAction()
	end
end

-- 转盘动作回调
function RotaryTableView:OnTableActionChange()
	self:FlushMyRecord()
	BagData.Instance:SetDaley(false)
	if self.item_daley_timer == nil then
		self.item_daley_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.node_t_list['img_pointer'].node:setRotation(0)
			self.node_t_list['btn_lucky_draw'].node:setEnabled(true)
			self:FlushCellView()
			GlobalTimerQuest:CancelQuest(self.item_daley_timer)
			self.item_daley_timer = nil
		end, 2)
	end
end
-----------------------------------------
-- 转盘记录
-----------------------------------------
RotaryTableView.RotaryTableRender = BaseClass(BaseRender)
local RotaryTableRender = RotaryTableView.RotaryTableRender

function RotaryTableRender:__init()	
end

function RotaryTableRender:__delete()	
end

function RotaryTableRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self.node_tree.rich_record.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function RotaryTableRender:OnClickItemTipsHandler()
	TipsCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_NORMAL)
end

function RotaryTableRender:OnFlush()
	if nil == self.data then return end
	local cfg = CrossWheelCfg.awardPool[tonumber(self.data.show_index)].award
	local id = cfg[tonumber(self.data.idx)].id
	local item_cfg, color ,num
	if cfg[tonumber(self.data.idx)].percent == nil then
		item_cfg = ItemData.Instance:GetItemConfig(id)
		item_color = string.format("%06x", item_cfg.color)
		num_color = string.format("%06x", item_cfg.color)
		num = self.data.num
	else
		id = 3586
		local percent = cfg[tonumber(self.data.idx)].percent * 100
		item_cfg = {}
		item_cfg.name = percent .. "%奖池"
		item_color = COLORSTR.ORANGE
		num_color = COLORSTR.RED
		num = "元宝" .. self.data.num
	end
	local playername = Scene.Instance:GetMainRole():GetName()
	local rolename_color = playername == self.data.name and 'CCCCCC' or 'FFFF00'

	local text = string.format(Language.ActivityBrilliant.Txt, rolename_color, rolename_color, self.data.name, rolename_color, Language.XunBao.Prefix .. '\n', item_color, item_cfg.name , id, num_color, num)
	local rich = RichTextUtil.ParseRichText(self.node_tree.rich_record.node, text, 17)
	rich:setIgnoreSize(true)
end

function RotaryTableRender:CreateSelectEffect()
end

return RotaryTableView