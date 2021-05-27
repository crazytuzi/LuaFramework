ActivityCalendarView = ActivityCalendarView or BaseClass(XuiBaseView)

function ActivityCalendarView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self.config_tab = {
						{"common_ui_cfg", 1, {0}},
						{"activity_ui_cfg", 7, {0}},
						{"common_ui_cfg", 2, {0}},
					}
	-- self.is_any_click_close = true
	self.title_img_path = ResPath.GetActivityPic("act_calendar")
	
end

function ActivityCalendarView:__delete()
	self.select_effect = nil
end

function ActivityCalendarView:ReleaseCallBack()
	if self.type_info_list then
		self.type_info_list:DeleteMe()
		self.type_info_list = nil
	end
	self.select_effect = nil
end

function ActivityCalendarView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:CreateInfoList()
		local server_time = TimeCtrl.Instance:GetServerTime()
		local w_day = tonumber(os.date("%w", server_time))
		local size = self.node_t_list["w_day_" .. w_day].node:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2-227, size.width + 59, size.height + 524, ResPath.GetCommon("img9_173"), true)
		self.node_t_list["w_day_" .. w_day].node:addChild(self.select_effect, 999)
	end
end
function ActivityCalendarView:CloseCallBack()
	self.select_effect = nil
end
function ActivityCalendarView:SetDescData(data)
	self:Flush()
end

function ActivityCalendarView:OnFlush(paramt,index)
	local data = ActivityData.Instance:GetActivityCalendarCfg()
	self.type_info_list:SetDataList(data)
end


function ActivityCalendarView:ShowIndexCallBack(index)
	self:Flush(index)
end
function ActivityCalendarView:CreateInfoList()
	if not self.type_info_list then
		local ph = self.ph_list.ph_calendar_type_list
		self.type_info_list = ListView.New()
		self.type_info_list:Create(ph.x, ph.y, ph.w, ph.h, direction, CalendarItem, nil, false, self.ph_list.ph_calendar_item)
		-- self.type_info_list:SetItemsInterval(3)
		self.type_info_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_calendar.node:addChild(self.type_info_list:GetView(), 5)
	end
end
CalendarItem = CalendarItem or BaseClass(BaseRender)
function CalendarItem:__init()

end

function CalendarItem:__delete()
	
end

function CalendarItem:CreateChild()
	BaseRender.CreateChild(self)
	for i = 1,7 do
		self.node_tree["tran_bg_"..i].node:setOpacity(0)
		if self.data.info[i].name ~= "" then
			XUI.AddClickEventListener(self.node_tree["tran_bg_"..i].node, BindTool.Bind(self.OpenCommonView, self,i), true)
		end	
	end
end

function CalendarItem:OnFlush()
	if self.data == nil then return end
	if self.data.time[2] == 0 then
		self.data.time[2] = "00"
	end
	self.node_tree.txt_open_time.node:setString(self.data.time[1] ..":"..self.data.time[2])
	local server_time = TimeCtrl.Instance:GetServerTime()
	local w_day = tonumber(os.date("%w", server_time))
	for i = 1, 7 do
		self.node_tree["txt_name_"..i].node:setString(self.data.info[i].name)
	end
	if w_day == 0 then 
		w_day = 7
	end	
	self.node_tree["txt_name_"..w_day].node:setColor(COLOR3B.OLIVE)
	self.node_tree.img_bg.node:setVisible(self.index%2 == 1)
end	
	
function CalendarItem:CreateSelectEffect()
	
end
function CalendarItem:OpenCommonView(index)
	local data_cfg = ActivityData.Instance:GetActivityCfg(index,self.index)
	ActivityCtrl.Instance:OpenRewardTip(data_cfg)
end



