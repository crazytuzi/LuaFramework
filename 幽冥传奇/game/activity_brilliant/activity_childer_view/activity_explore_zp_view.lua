ExploreTurnblePage = ExploreTurnblePage or BaseClass(ActTurnbleBaseView)
local DZP_COUNT = 12

function ExploreTurnblePage:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ExploreTurnblePage:__delete()
	if self.zp_61_log_list then
		self.zp_61_log_list:DeleteMe()
		self.zp_61_log_list = nil
	end
	if self.table_61_reward_t then 
		for k,v in pairs(self.table_61_reward_t) do
			v:DeleteMe()
		end
		self.table_61_reward_t = {}
	end

	if self.spare_61_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_61_time)
		self.spare_61_time = nil
	end

	if RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.gold_listener)
	end
end

function ExploreTurnblePage:InitView()
	self.node_t_list.layout_check_auto_draw.node:setVisible(false)
	self.node_t_list.btn_61_draw.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.btn_charge_61.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end)
	self.node_t_list.btn_xunbao_61.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao) end)
	self.node_t_list.btn_61_tip.node:addClickEventListener(function () 
		local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
		DescTip.Instance:SetContent(act_cfg.act_desc, act_cfg.act_name)
	end)

	self.gold_listener = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_GOLD, function ()
		ActivityBrilliantCtrl.ActivityReq(3, self.act_id)
	end)

	self:CreateTSMBReward()
	self:CreateTSMBRewardLog()
	self:CreateSpareFFTimer()
	self:InitTurnbel()
end

function ExploreTurnblePage:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)

	local zp_data = ActivityBrilliantData.Instance:GetTSMBData()
	local text = string.format("还需要寻宝{wordcolor;ff0000;%s}次", zp_data.draw_num)
	RichTextUtil.ParseRichText(self.node_t_list.rich_need_xb_time.node, text, 20, COLOR3B.WHITE)
	XUI.RichTextSetCenter(self.node_t_list.rich_need_xb_time.node)
	self.node_t_list.img_lun_time.node:loadTexture(ResPath.GetActivityBrilliant("act_61_num_" .. zp_data.cond))
	if nil == act_cfg then return end
	for k,v in pairs(param_list) do
		if k == "flush_view" and v.result and v.act_id == act_cfg.act_id and not self:GetIsIgnoreAction() then
			self.node_t_list.layout_dzp_point.node:stopAllActions()
			local rotate = self.node_t_list.layout_dzp_point.node:getRotation() % 360
			local to_rotate =720 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (v.result - 1) - (v.result == 1 and 18 or 18)
			local rotate_by = cc.RotateBy:create(1, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_61_draw.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)
				self.zp_61_log_list:SetDataList(ActivityBrilliantData.Instance:GetTSMBRecordList())
				self:FlushRewardCell()
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.node_t_list.layout_dzp_point.node:runAction(sequence)
		else
			if self.node_t_list.btn_61_draw.node:isEnabled() then
				self.zp_61_log_list:SetDataList(ActivityBrilliantData.Instance:GetTSMBRecordList())
				self:FlushRewardCell()
			end
		end
	end
end

function ExploreTurnblePage:CreateTSMBReward()
	self.table_61_reward_t = {}
	local r = 130
	local x, y = self.node_t_list.layout_dzp_point.node:getPosition()
	for i = 1, DZP_COUNT do
		local ph = self.ph_list["ph_cell_61_"..i]
		local cell = ActBaseCell.New()
		cell:SetPosition(ph.x,ph.y)
		cell:SetCellBg()
		cell:SetIndex(i)
		cell:GetView():setScale(0.7)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_turntable_61.node:addChild(cell:GetView(), 5)
		table.insert(self.table_61_reward_t, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
	if act_cfg and act_cfg.config.award_pool then	
		for i,v in ipairs(self.table_61_reward_t) do
			local data =  act_cfg.config.award_pool[1][i].awards[1]
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
	self:FlushRewardCell()
end

function ExploreTurnblePage:CreateTSMBRewardLog()
	local ph = self.ph_list.ph_zp_61_list
	self.zp_61_log_list = ListView.New()
	self.zp_61_log_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityTSMBRender, nil, nil, self.ph_list.ph_item_61)
	self.zp_61_log_list:GetView():setAnchorPoint(0, 0)
	self.zp_61_log_list:SetJumpDirection(ListView.Top)
	self.zp_61_log_list:SetItemsInterval(8)
	self.node_t_list.layout_turntable_61.node:addChild(self.zp_61_log_list:GetView(), 100)
end

function ExploreTurnblePage:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_turntable_61.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ExploreTurnblePage:CreateSpareFFTimer()
	self.spare_61_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function ExploreTurnblePage:OnClickTurntableHandler()
	local zp_data = ActivityBrilliantData.Instance:GetTSMBData()
	if zp_data.draw_num > 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.MingbaoZPTip)
		return 
	end

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
	local can_draw = ActivityBrilliantData.Instance:GetTSMBData().draw_num == 0 
	self:UpdateAutoDrawTimer(6, can_draw) --每隔1秒抽一次

	if self:TryDrawIgnoreAction() then
		self.node_t_list.btn_61_draw.node:setEnabled(true)
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	self:OnClickTSMBHandler()
end

-- 格子变灰显示
function ExploreTurnblePage:FlushRewardCell()
	local reward = ActivityBrilliantData.Instance:GetRewardSign()
	if self.table_61_reward_t then
		for k, v in pairs(self.table_61_reward_t) do
			v:MakeGray(reward[k] == 1)
			v:SetIsChoiceVisible(reward[k] == 1)
		end
	end
end

function ExploreTurnblePage:InitTurnbel()
	local a_y = 1 - ((180 -48) / 2 + 48) / 180
	self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, a_y)
	self.node_t_list.layout_dzp_point.node:setPositionY(self.node_t_list.layout_dzp_point.node:getPositionY() - 180 * (0.5 - a_y))
end

function ExploreTurnblePage:OnClickTSMBHandler()
	local act_id = ACT_ID.TSMB

	local rotate_by1 = cc.RotateBy:create(1, 360 * 2)
	local rotate_by2 = cc.RotateBy:create(2, 360 * 5)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_61_draw.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_61_draw.node:setEnabled(false)
	self.node_t_list.layout_dzp_point.node:runAction(sequence)
end

ActivityTSMBRender = ActivityTSMBRender or BaseClass(BaseRender)
function ActivityTSMBRender:__init()	
end

function ActivityTSMBRender:__delete()	
end

function ActivityTSMBRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ActivityTSMBRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
	if nil == cfg then return end
	local id = cfg.config.award_pool[tonumber(self.data.cound)][tonumber(self.data.index)].awards[1].id
	local count = cfg.config.award_pool[tonumber(self.data.cound)][tonumber(self.data.index)].awards[1].count
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
	local rich = "{color;%s;[}{rolename;%s;%s}{color;%s;]}{eq;%s;%s;%s}{color;%s;X%s}"
	local text = string.format(rich, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, color, item_cfg.name ,id,color,count)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node, text, 18)
end

function ActivityTSMBRender:CreateSelectEffect()
end
