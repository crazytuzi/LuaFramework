local DigShowRender = BaseClass(BaseRender)
function DigShowRender:__init()
	-- GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	-- --挖矿信息改变
	-- EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INFO_CHANGE, function ()
	-- 	self:SetData(ExperimentData.Instance:GetBaseInfo())
	-- end)

	self.change_event = ExperimentData.Instance:AddEventListener(ExperimentData.INFO_CHANGE, function ()
		self:SetData(ExperimentData.Instance:GetBaseInfo())
	end)
end

function DigShowRender:__delete()
	if nil ~= self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	ExperimentData.Instance:RemoveEventListener(self.change_event)

	-- self:RemoveAllEventlist()
	self:DeleteDigTimer()
end

function DigShowRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_exit.node, function ()
		Scene.SendTransmitSceneReq(2, 108, 87)
	end)
end

function DigShowRender:FlushAwardByIdx(idx)
	if nil == self.award_list then
		local ph = self.ph_list.ph_award_list
		local list_view = ListView.New()
		list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BaseCell, nil, false)
		list_view:SetItemsInterval(3)
		list_view:GetView():setScale(0.8)
		list_view:GetView():setAnchorPoint(0, 0.5)
		self.view:addChild(list_view:GetView(), 100)
		self.award_list = list_view
	end
	local data = {}
	for k,v in ipairs(MiningActConfig.Miner[idx].Awards) do
		data[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self.award_list:SetData(data)
end

-- 创建选中特效
function DigShowRender:CreateSelectEffect()
end

function DigShowRender:OnFlush()
	if nil == self.data or nil == self.data.quality then
		return
	end
	self:FlushAwardByIdx(self.data.quality)
	self:FlushDigTimer()
end

function DigShowRender:FlushDigTimer()
	if ExperimentData.Instance:CheckCanLingquDigAward() then
		self.node_tree.lbl_time_tip.node:setString("可领取")
	elseif not ExperimentData.Instance:IsDiging() then
		self.node_tree.lbl_time_tip.node:setString("未开始")
	end

	local update_time_func = function ()
		local time2 = ExperimentData.Instance:GetBaseInfo().start_dig_time + MiningActConfig.finTimes - TimeCtrl.Instance:GetServerTime() --结束挖矿时间
		if time2 <= 0 then
			self:DeleteDigTimer()
			self.node_tree.lbl_time_tip.node:setString("可领取")
		else
			self.node_tree.lbl_time_tip.node:setString(Language.Dig.AccountName[self.data.quality] .. "(" ..TimeUtil.FormatSecond(time2) .. ")")
		end
	end

	if nil == self.dig_timer and ExperimentData.Instance:IsDiging() then
		self.dig_timer = GlobalTimerQuest:AddRunQuest(function ()
			update_time_func()
		end, 1)
		update_time_func()
	end
end

function DigShowRender:DeleteDigTimer()
	if self.dig_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.dig_timer)
		self.dig_timer = nil
	end
end


return DigShowRender