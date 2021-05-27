-- 行会事件
local GuildEventsView = GuildEventsView or BaseClass(SubView)

function GuildEventsView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 4, {0}},
		{"guild_ui_cfg", 15, {0}},
	}
end

function GuildEventsView:LoadCallBack()
	self:CreateEventsList()
	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.EventListChange, BindTool.Bind(self.OnFlushEventsView, self))
end

function GuildEventsView:ReleaseCallBack()
	if self.events_list then
		self.events_list:DeleteMe()
		self.events_list = nil
	end
end

function GuildEventsView:ShowIndexCallBack()
	self:OnFlushEventsView()
	GuildCtrl.GetAllGuildInfo()
end

function GuildEventsView:OnFlushEventsView()
	self:FlushEventsList()
end

function GuildEventsView:CreateEventsList()
	if self.events_list ~= nil then return end

	local ph = self.ph_list.ph_event_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, EventsListItem, nil, nil, self.ph_list.ph_event_list_item)
	self.node_t_list.layout_guild_events.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.events_list = list
end

function GuildEventsView:FlushEventsList()
	if nil == self.events_list then return end
	local events_list_data = GuildData.Instance:GetEventsList()
	self.events_list:SetDataList(events_list_data)
end

----------------------------------------------------
-- EventsListItem
----------------------------------------------------
EventsListItem = EventsListItem or BaseClass(BaseRender)

function EventsListItem:__init()
end

function EventsListItem:__delete()

end

function EventsListItem:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_info = self.node_tree.rich_info.node
	self.rich_info:setIgnoreSize(true)
end

function EventsListItem:OnFlush()
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if self.data == nil then 
		RichTextUtil.ParseRichText(self.rich_info, "")
		self.node_tree.lbl_date.node:setString("")
		return 
	end

	local color = COLOR3B.LIGHT_BROWN
	RichTextUtil.ParseRichText(self.rich_info, self.data.content, 18, color)

	local time_params = os.date("*t", self.data.time)
	local time_text = string.format(Language.Guild.EventsTime, time_params.year, time_params.month, time_params.day, time_params.hour, time_params.min)
	self.node_tree.lbl_date.node:setString(time_text)
end

function EventsListItem:CreateSelectEffect()
	
end

return GuildEventsView