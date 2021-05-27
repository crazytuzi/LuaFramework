ActZhanPanView = ActZhanPanView or BaseClass(ActTurnbleBaseView)

local DZP_COUNT = 8
function ActZhanPanView:__init(view, parent, act_id)
	-- self.ui_layout_name = "layout_yaoqianshu"
	self:LoadView(parent)
end

function ActZhanPanView:__delete()
	if self.dzp_log_list then
		self.dzp_log_list:DeleteMe()
		self.dzp_log_list = nil
	end
	for k,v in pairs(self.table_reward_t) do
		v:DeleteMe()
	end
	self.table_reward_t = {}

	if RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.gold_listener)
	end
end

function ActZhanPanView:InitView()
	local ph = self.ph_list.ph_pos
	self.btn_arrow = XUI.CreateButton(ph.x, ph.y, 0, 0, false, ResPath.GetCombind("zhuanpan_arrow"), ResPath.GetCombind("zhuanpan_arrow"), nil, true)
	self.node_t_list.layout_turntable.node:addChild(self.btn_arrow, 999)
	self.btn_arrow:setAnchorPoint(0.5, 85 / 250)

	self.node_t_list.btn_truntable.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.btn_dzp_rechange.node:addClickEventListener(BindTool.Bind(self.OnClickDzpRechangeHandler, self))
	self:CreateDZPReward()
	self:CreateDZPRewardLog()
	self.node_t_list.rich_dzp_open_limit.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	self.node_t_list.rich_dzp_open_limit.node:setIgnoreSize(true)
	XUI.RichTextSetCenter(self.node_t_list.rich_dzp_stuff_1.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_dzp_stuff_2.node)
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZP)
	local open_count = act_cfg and act_cfg.config.params[1] or 5000
	RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_open_limit.node, string.format(Language.CombinedServerAct.TurntableOpenDec, open_count), 20)
	self.gold_listener = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_GOLD,BindTool.Bind(self.RefreshView, self))
end


function ActZhanPanView:RefreshView(param_t)
	local data = ActivityBrilliantData.Instance
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZP)
	if nil == act_cfg  then return end
	local today_recharge = ActivityBrilliantData.Instance:GetTodayRecharge()
	local use_num = data.use_num
	self.node_t_list.lbl_chongzhi_num.node:setString(today_recharge)
	self.zp_isopen = today_recharge >= act_cfg.config.params[1]

	local maxYlBook = act_cfg.config.params[2]
	local maxCqBook = act_cfg.config.params[3]

	local  ylq_gold= act_cfg.config.tickets[1].yb
	local  cqq_gold= act_cfg.config.tickets[2].yb

	local consum_gold = data.consum_gold[act_cfg.act_id]
	local ylq_count = math.floor(today_recharge / ylq_gold - use_num * maxYlBook)
	local cqq_count = math.floor(consum_gold / cqq_gold - use_num * maxCqBook)

	for k,v in pairs(param_t) do
		if k == "flush_view" and self.zp_isopen and v.result and not self:GetIsIgnoreAction() then
			self.btn_arrow:stopAllActions()
			local rotate = self.btn_arrow:getRotation() % 360
			local to_rotate =720 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (v.result - 1)
			local rotate_by = cc.RotateBy:create(2, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_truntable.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)
				self.dzp_log_list:SetDataList(ActivityBrilliantData.Instance:GetXunbaoList())

			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.btn_arrow:runAction(sequence)
		else
			if self.node_t_list.btn_truntable.node:isEnabled() then
				self.dzp_log_list:SetDataList(ActivityBrilliantData.Instance:GetXunbaoList())
			end

			self.node_t_list.rich_dzp_open_limit.node:setVisible(not self.zp_isopen)
			self.node_t_list.rich_dzp_stuff_1.node:setVisible(self.zp_isopen)
			self.node_t_list.rich_dzp_stuff_2.node:setVisible(self.zp_isopen)
			self.node_t_list.btn_truntable.node:setVisible(self.zp_isopen)
			local color = ylq_count < maxYlBook and "ff0000" or "00ff00"
			local content = string.format(Language.CombinedServerAct.TurntableStuff1, color, ylq_count, maxYlBook , data.ylq_num)
			RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_stuff_1.node, content, 20)
			color = cqq_count < maxCqBook and "ff0000" or "00ff00"
			local content = string.format(Language.CombinedServerAct.TurntableStuff2, color, cqq_count, maxCqBook , data.cqq_num)
			RichTextUtil.ParseRichText(self.node_t_list.rich_dzp_stuff_2.node, content, 20)
		end
	end
end

function ActZhanPanView:CreateDZPReward()
	self.table_reward_t = {}
	local r = 115
	local x, y = self.btn_arrow:getPosition()
	for i = 1, DZP_COUNT do
		local cell = ActBaseCell.New()
		cell:SetPosition(x + r * math.cos(math.rad(67.5 - 360 / DZP_COUNT * (i - 1))), y + 6 + r * math.sin(math.rad(67.5 - 360 / DZP_COUNT * (i - 1))))
		cell:SetCellBg()
		-- cell:SetCellBgVis(false)
		-- cell:SetBindIconVisible(false)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		if i == 1 then
			self.node_t_list.layout_turntable.node:addChild(cell:GetView(), 300)
		else
			self.node_t_list.layout_turntable.node:addChild(cell:GetView(), 200)
		end
		table.insert(self.table_reward_t, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZP)
	if act_cfg and act_cfg.config.award then	
		for i,v in ipairs(self.table_reward_t) do
			local data =  act_cfg.config.award[i]
			if data then
				if data.type == tagAwardType.qatEquipment then
					v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
				else
					local virtual_item_id = ItemData.GetVirtualItemId(data.type)
					if virtual_item_id then
						v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = data.bind or 0})
					end
				end
			else
				v:SetData()
			end
		end
	end
end

function ActZhanPanView:CreateDZPRewardLog()
	local ph = self.ph_list.ph_dzp_reward_list
	self.dzp_log_list = ListView.New()
	self.dzp_log_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityDZPLogRender, nil, nil, self.ph_list.ph_dzp_reward_item)
	self.dzp_log_list:GetView():setAnchorPoint(0.5, 0.5)
	self.dzp_log_list:SetJumpDirection(ListView.Top)
	self.dzp_log_list:SetItemsInterval(8)
	self.node_t_list.layout_turntable.node:addChild(self.dzp_log_list:GetView(), 100)
end

function ActZhanPanView:OnClickTurntableHandler()
	local data = ActivityBrilliantData.Instance
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZP)
	if nil == act_cfg  then return end

	local today_recharge = ActivityBrilliantData.Instance:GetTodayRecharge()
	local use_num = data.use_num
	self.zp_isopen = today_recharge >= act_cfg.config.params[1]

	local maxYlBook = act_cfg.config.params[2]
	local maxCqBook = act_cfg.config.params[3]

	local  ylq_gold= act_cfg.config.tickets[1].yb
	local  cqq_gold= act_cfg.config.tickets[2].yb

	local consum_gold = data.consum_gold[act_cfg.act_id]
	local ylq_count = today_recharge / ylq_gold - use_num * maxYlBook
	local cqq_count = consum_gold / cqq_gold - use_num * maxCqBook

	local can_draw = self.zp_isopen and ylq_count >= maxYlBook and cqq_count >= maxCqBook
	self:UpdateAutoDrawTimer(5, can_draw) --每隔5秒抽一次

	if self:TryDrawIgnoreAction() then
		self.btn_arrow:stopAllActions()
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	if not self.zp_isopen then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[1])
		return
	end
	if ylq_count < maxYlBook then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[2])
		return
	end
	if cqq_count < maxCqBook then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CombinedServerAct.TurntableLimit[3])
		return
	end


	local rotate_by1 = cc.RotateBy:create(2, 360 * 5)
	local rotate_by2 = cc.RotateBy:create(4, 360 * 10)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
		local act_id = ACT_ID.ZP
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_truntable.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_truntable.node:setEnabled(false)
	self.btn_arrow:runAction(sequence)
end

function ActZhanPanView:OnClickDzpRechangeHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function ActZhanPanView:ItemConfigCallback()
	self.dzp_log_list:SetDataList(ActivityBrilliantData.Instance:GetXunbaoList())
end

ActivityDZPLogRender = ActivityDZPLogRender or BaseClass(BaseRender)
function ActivityDZPLogRender:__init()	
end

function ActivityDZPLogRender:__delete()	
end

function ActivityDZPLogRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ActivityDZPLogRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZP)
	if nil == cfg then return end
	local id = cfg.config.award[tonumber(self.data.index)].id
	local count = cfg.config.award[tonumber(self.data.index)].count

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
	local text2  = self.data.name ..item_name
	local text = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name ,id,color,count)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node,text, 18)
end

function ActivityDZPLogRender:CreateSelectEffect()
end
