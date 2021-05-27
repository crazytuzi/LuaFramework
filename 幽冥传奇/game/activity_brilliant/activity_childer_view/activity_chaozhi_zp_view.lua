ChaozhiTurntableView = ChaozhiTurntableView or BaseClass(ActTurnbleBaseView)
local DZP_COUNT = 8

function ChaozhiTurntableView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChaozhiTurntableView:__delete()
	if self.draw_record_list then
		self.draw_record_list:DeleteMe()
		self.draw_record_list = nil
	end
	if self.reward_cell_list then 
		for k,v in pairs(self.reward_cell_list) do
			v:DeleteMe()
		end
		self.reward_cell_list = {}
	end

	if self.spare_79_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_79_time)
		self.spare_79_time = nil
	end
end

function ChaozhiTurntableView:InitView()
	self.node_t_list.btn_79_draw.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
	self.node_t_list.layout_draw_point.node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.btn_charge.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge) end)
	self.node_t_list.btn_pay.node:addClickEventListener(function () ViewManager.Instance:OpenViewByDef(ViewDef.Explore) end)

	self:CreateCZZPReward()
	self:CreateDrawRecordList()
	self:CreateSpareFFTimer()
end

function ChaozhiTurntableView:RefreshView(param_list)
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SVZP)
	local draw_integral = ActivityBrilliantData.Instance:GetDrawIntegral()
	self.node_t_list.lbl_jifen.node:setString(draw_integral)
	if nil == act_cfg then return end
	for k,v in pairs(param_list) do
		if k == "flush_view" and v.result and v.act_id == act_cfg.act_id and not self:GetIsIgnoreAction() then
			self.node_t_list.layout_draw_point.node:stopAllActions()
			local rotate = self.node_t_list.layout_draw_point.node:getRotation() % 360
			local to_rotate = 697.5 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (v.result - 1)
			local rotate_by = cc.RotateBy:create(2, to_rotate)
			local callback = cc.CallFunc:create(function ()
				self.node_t_list.btn_79_draw.node:setEnabled(true)
				ItemData.Instance:SetDaley(false)
				self.draw_record_list:SetDataList(ActivityBrilliantData.Instance:GetSVZPDrawRecord())
			end)
			local sequence = cc.Sequence:create(rotate_by, callback)
			self.node_t_list.layout_draw_point.node:runAction(sequence)
		else
			if self.node_t_list.btn_79_draw.node:isEnabled() then
				self.draw_record_list:SetDataList(ActivityBrilliantData.Instance:GetSVZPDrawRecord())
			end
		end
	end
end

function ChaozhiTurntableView:CreateCZZPReward()
	self.reward_cell_list = {}
	local r = 125
	local x, y = self.node_t_list.layout_draw_point.node:getPosition()
	for i = 1, DZP_COUNT do
		local cell = ActBaseCell.New()
		cell:SetPosition(x + r * math.cos(math.rad(90 - 360 / DZP_COUNT * (i - 1))), y + r * math.sin(math.rad(90 - 360 / DZP_COUNT * (i - 1))))
		-- cell:SetCellBg()
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_chaozhi_turntable.node:addChild(cell:GetView(), 300)
		table.insert(self.reward_cell_list, cell)
	end
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SVZP)
	if act_cfg and act_cfg.config.proTable then	
		for i,v in ipairs(self.reward_cell_list) do
			local data =  act_cfg.config.proTable[i]
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

function ChaozhiTurntableView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SVZP)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_chaozhi_turntable.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ChaozhiTurntableView:CreateSpareFFTimer()
	self.spare_79_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
	self:UpdateSpareFFTime()
end

function ChaozhiTurntableView:CreateDrawRecordList()
	local ph = self.ph_list.ph_drow_record_list
	self.draw_record_list = ListView.New()
	self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ZPDrawRecordRender, nil, nil, nil)
	self.draw_record_list:GetView():setAnchorPoint(0.5, 0.5)
	self.draw_record_list:SetJumpDirection(ListView.Top)
	self.draw_record_list:SetItemsInterval(5)
	self.node_t_list.layout_chaozhi_turntable.node:addChild(self.draw_record_list:GetView(), 100)
end

function ChaozhiTurntableView:OnClickTurntableHandler()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SVZP)
	local can_draw = ActivityBrilliantData.Instance:GetDrawIntegral() >= 100
	if not can_draw then
		SysMsgCtrl.Instance:FloatingTopRightText("积分不足")
		return
	end
	self:UpdateAutoDrawTimer(6, can_draw) --每隔1秒抽一次

	if self:TryDrawIgnoreAction() then
		self.node_t_list.btn_79_draw.node:setEnabled(true)
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	self:OnClickCZZPHandler()
end

local x = 1
function ChaozhiTurntableView:OnClickCZZPHandler()
	local act_id = ACT_ID.SVZP
	local rotate_by1 = cc.RotateBy:create(2, 360 * 5)
	local rotate_by2 = cc.RotateBy:create(4, 360 * 10)
	local callback = cc.CallFunc:create(function ()
		ItemData.Instance:SetDaley(true)
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
	end)
	local callback2 = cc.CallFunc:create(function ()
		self.node_t_list.btn_79_draw.node:setEnabled(true)
	end)
	local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
	self.node_t_list.btn_79_draw.node:setEnabled(false)
	self.node_t_list.layout_draw_point.node:runAction(sequence)
end

ZPDrawRecordRender = ZPDrawRecordRender or BaseClass(BaseRender)
function ZPDrawRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(305, 24)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view	
end

function ZPDrawRecordRender:__delete()	
end

function ZPDrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	-- self.rich_text:setIgnoreSize(true)
	self.view:addChild(self.rich_text, 9)
end

function ZPDrawRecordRender:OnFlush()
	if self.data == nil then return end
	local content = string.format(Language.ActivityBrilliant.SuperValueRecord, self.data.name, self.data.item_name)
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function ZPDrawRecordRender:CreateSelectEffect()
end
