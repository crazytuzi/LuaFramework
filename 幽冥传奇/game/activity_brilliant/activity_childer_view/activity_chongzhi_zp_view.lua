ChargeZPView = ChargeZPView or BaseClass(ActTurnbleBaseView)
local DZP_COUNT = 10

function ChargeZPView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChargeZPView:__delete()
	if self.zp_53_log_list then
		self.zp_53_log_list:DeleteMe()
		self.zp_53_log_list = nil
	end
	if self.table_54_reward_t then 
		for k,v in pairs(self.table_54_reward_t) do
			v:DeleteMe()
		end
		self.table_54_reward_t = {}
	end

	if self.cz_zp_progressbar then
		self.cz_zp_progressbar:DeleteMe()
		self.cz_zp_progressbar = nil
	end

	if self.spare_54_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_54_time)
		self.spare_54_time = nil
	end

	if RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.gold_listener)
	end
end

function ChargeZPView:InitView()

	self.node_t_list.btn_54_draw.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.btn_charge_54.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end)

	self.gold_listener = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_GOLD, function ()
		ActivityBrilliantCtrl.ActivityReq(3, self.act_id)
	end)

	self:CreateCZZPReward()
	self:CreateCZZPRewardLog()
	self:CreateSpareFFTimer()
	self:CreateCZZPProgressbar()
	self:InitTurnbel()
end

function ChargeZPView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZZP)

	local zp_data = ActivityBrilliantData.Instance:GetCZZPData()
	self.cz_zp_progressbar:SetPercent(zp_data.per,false)
	self.node_t_list.lbl_pro_num.node:setString(zp_data.str)
	self.node_t_list.layout_turntable_54.lbl_54_draw_num.node:setString(zp_data.draw_num)
	if nil == act_cfg then return end
	for k,v in pairs(param_list) do
		if k == "flush_view" and v.result and v.act_id == act_cfg.act_id and not self:GetIsIgnoreAction() then
			self.node_t_list.layout_dzp_point.node:stopAllActions()
			local rotate = self.node_t_list.layout_dzp_point.node:getRotation() % 360
			local to_rotate =720 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (v.result - 1) - (v.result == 1 and 18 or 18)
			local rotate_by = cc.RotateBy:create(1, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_54_draw.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)
				self.zp_53_log_list:SetDataList(ActivityBrilliantData.Instance:GetCZZPRecordList())
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.node_t_list.layout_dzp_point.node:runAction(sequence)
		else
			if self.node_t_list.btn_54_draw.node:isEnabled() then
				self.zp_53_log_list:SetDataList(ActivityBrilliantData.Instance:GetCZZPRecordList())
			end
		end
	end
end

function ChargeZPView:CreateCZZPReward()
	self.table_54_reward_t = {}
	local r = 130
	local x, y = self.node_t_list.layout_dzp_point.node:getPosition()
	for i = 1, DZP_COUNT do
		local ph = self.ph_list["ph_cell_54_"..i]
		local cell = ActBaseCell.New()
		cell:SetPosition(ph.x,ph.y)
		cell:SetCellBg()
		cell:SetIndex(i)
		cell:GetView():setScale(0.8)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_turntable_54.node:addChild(cell:GetView(), 5)
		table.insert(self.table_54_reward_t, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZZP)
	if act_cfg and act_cfg.config.award then	
		for i,v in ipairs(self.table_54_reward_t) do
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

function ChargeZPView:CreateCZZPProgressbar()
	self.cz_zp_progressbar = ProgressBar.New()
	self.cz_zp_progressbar:SetView(self.node_t_list.prog9_qh.node)
	self.cz_zp_progressbar:SetTailEffect(991, nil, true)
	self.cz_zp_progressbar:SetEffectOffsetX(-20)
	self.cz_zp_progressbar:SetPercent(0,false)
end

function ChargeZPView:CreateCZZPRewardLog()
	local ph = self.ph_list.ph_zp_54_list
	self.zp_53_log_list = ListView.New()
	self.zp_53_log_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityCZZPLogRender, nil, nil, self.ph_list.ph_item_54)
	self.zp_53_log_list:GetView():setAnchorPoint(0, 0)
	self.zp_53_log_list:SetJumpDirection(ListView.Top)
	self.zp_53_log_list:SetItemsInterval(8)
	self.node_t_list.layout_turntable_54.node:addChild(self.zp_53_log_list:GetView(), 100)
end

function ChargeZPView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZZP)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_turntable_54.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ChargeZPView:CreateSpareFFTimer()
	self.spare_54_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function ChargeZPView:OnClickTurntableHandler()
	local zp_data = ActivityBrilliantData.Instance:GetCZZPData()
	if zp_data.draw_num <= 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.ChongZhiZPTip)
		return 
	end

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZZP)
	local can_draw = ActivityBrilliantData.Instance:GetCZZPData().draw_num > 0 
	self:UpdateAutoDrawTimer(6, can_draw) --每隔1秒抽一次

	if self:TryDrawIgnoreAction() then
		self.node_t_list.btn_54_draw.node:setEnabled(true)
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	self:OnClickCZZPHandler()
end


function ChargeZPView:InitTurnbel()
	local a_y = 1 - ((180 -48) / 2 + 48) / 180
	self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, a_y)
	self.node_t_list.layout_dzp_point.node:setPositionY(self.node_t_list.layout_dzp_point.node:getPositionY() - 180 * (0.5 - a_y))
end

function ChargeZPView:OnClickCZZPHandler()
	local act_id = ACT_ID.CZZP

	local rotate_by1 = cc.RotateBy:create(1, 360 * 2)
	local rotate_by2 = cc.RotateBy:create(2, 360 * 5)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_54_draw.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_54_draw.node:setEnabled(false)
	self.node_t_list.layout_dzp_point.node:runAction(sequence)
end

ActivityCZZPLogRender = ActivityCZZPLogRender or BaseClass(BaseRender)
function ActivityCZZPLogRender:__init()	
end

function ActivityCZZPLogRender:__delete()	
end

function ActivityCZZPLogRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ActivityCZZPLogRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CZZP)
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

function ActivityCZZPLogRender:CreateSelectEffect()
end
