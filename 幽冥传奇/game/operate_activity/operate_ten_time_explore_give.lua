	-- 累计登陆界面
TenTimeExplGivePage = TenTimeExplGivePage or BaseClass()

function TenTimeExplGivePage:__init()
	self.view = nil

end

function TenTimeExplGivePage:__delete()
	self:RemoveEvent()

	if self.data_info_list then
		self.data_info_list:DeleteMe()
		self.data_info_list = nil 
	end

	self.view = nil
end



function TenTimeExplGivePage:InitPage(view)
	self.view = view
	XUI.RichTextSetVCenter(self.view.node_t_list.rich_10_time_give_des2.node)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnDataChangeEvent()
end

function TenTimeExplGivePage:InitEvent()
	self.ten_time_expl_give_event = GlobalEventSystem:Bind(OperateActivityEventType.TEN_TIME_GIVE_DATA_CHANGE, BindTool.Bind(self.OnDataChangeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
	XUI.AddClickEventListener(self.view.node_t_list.btn_ten_time_go_explore.node, BindTool.Bind(self.OnGoExplore, self))
end

function TenTimeExplGivePage:RemoveEvent()
	if self.ten_time_expl_give_event then
		GlobalEventSystem:UnBind(self.ten_time_expl_give_event)
		self.ten_time_expl_give_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function TenTimeExplGivePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_list_10_time_give
	self.data_info_list = ListView.New()
	self.data_info_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TenTimeExplGiveRender, nil, nil, self.view.ph_list.ph_10_time_give_award_item)
	self.data_info_list:SetItemsInterval(10)

	self.data_info_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_ten_time_give.node:addChild(self.data_info_list:GetView(), 20)

end

function TenTimeExplGivePage:OnDataChangeEvent()
	self:FlushTime()
	local unit = OperateActivityData.Instance:GetTenTimeExploreGiveUnit()
	local cnt = OperateActivityData.Instance:GetTenTimeExploreGiveCnt() / unit
	local content = string.format(Language.OperateActivity.TenExploreCnt, cnt)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_10_time_give_des2.node, content, 20)
	local data = TableCopy(OperateActivityData.Instance:GetTenTimeExploreGiveData())
	local function sort_func()
		return function(a, b)
			if a.state == b.state then
				return a.idx < b.idx
			else
				if a.state ~= 2 and b.state ~= 2 then
					return a.state > b.state
				else
					local order_a = 1000
					local order_b = 1000
					if a.state == 2 then
						order_b = order_b + 100
					else
						order_a = order_a + 100
					end

					return order_a > order_b
				end
			end
		end
	end
	table.sort(data, sort_func())
	self.data_info_list:SetDataList(data)
end

-- 倒计时
function TenTimeExplGivePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.txt_10_time_give_time then
		self.view.node_t_list.txt_10_time_give_time.node:setString(time_str)
	end
end

function TenTimeExplGivePage:UpdateData(param_t)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.TEN_TIME_EXPLORE_GIVE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_10_time_give_des.node, content, 24, COLOR3B.YELLOW)
end

function TenTimeExplGivePage:OnGoExplore()
	if self.view then
		ViewManager.Instance:Open(ViewName.Explore)
		self.view:Close()
	end
end
