GuildListView = GuildListView or BaseClass(BaseView)

function GuildListView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildsList"}
	self.view_layer = UiLayer.Pop
	self.row = 7  -- 每一页有多少行，暂定为7行
end

function GuildListView:__delete()

end

function GuildListView:LoadCallBack()

	self.info_list = GuildDataConst.GUILD_INFO_LIST
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self.panel = self:FindObj("List")
	self.variable_page = self:FindVariable("Page")
	self.list_table = {}
	self.variables = {}
	self.is_load = false

	PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "GuildListInfo"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, self.row do
            local obj = GameObject.Instantiate(prefab)
            local obj_transform = obj.transform
            obj_transform:SetParent(self.panel.transform, false)
            self.list_table[i] = U3DObject(obj)
            self.variables[i] = {}
			self.variables[i].rank = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Rank")
			self.variables[i].guild_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("GuildName")
			self.variables[i].master_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MasterName")
			self.variables[i].guild_level = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
			self.variables[i].member_count = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MemberCount")
			self.variables[i].total_fight_power = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("TotalFight")
        end

        PrefabPool.Instance:Free(prefab)
        self.is_load = true
        self:Flush()
    end)

	self:ListenEvent("OnPageUp",
		BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown",
		BindTool.Bind(self.OnPageDown, self))
end

function GuildListView:ReleaseCallBack()
	self.scroller = nil
	for i = 1, self.row do
		self.variables[i] = nil
		self.list_table[i] = nil
	end
	self.panel = nil
	self.variable_page = nil
end

function GuildListView:OnClickClose()
	self:Close()
end

-- 刷新页面数目
function GuildListView:FlushPageCount()
	self.info_count = self.info_list.count
	self.page_count = self.info_count / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

-- 刷新View
function GuildListView:OnFlush()
	self.info_list = GuildDataConst.GUILD_INFO_LIST
	self:FlushPageCount()
	self.current_page = 1
	self:FlushPage(self.current_page)
end

-- 更新页面
function GuildListView:FlushPage(page)
	if(page > self.page_count or page < 1) or not self.is_load then
		return
	end
	self.current_page = page
	self.variable_page:SetValue(self.current_page .. "/" .. self.page_count)
	if page == self.page_count then  -- 如果是最后一页
		for i = 1, self.row do
			if(i <= page * self.row - self.info_count) then
				self.list_table[self.row + 1 - i]:SetActive(false)
			else
				self.list_table[self.row + 1 - i]:SetActive(true)
			end
		end
	else
		for i = 1, self.row do
			self.list_table[i]:SetActive(true)
		end
	end
	for i = (page - 1) * self.row + 1, page * self.row do
		if(i > self.info_count) then
			break
		end
		self:FlushRow(i)
	end
end

-- 更新每一行的信息
function GuildListView:FlushRow(index)
	if index <= 0 or not self.is_load then
		return
	end
	local current_row = index % self.row
	if current_row == 0 then
		current_row = self.row
	end

	self.variables[current_row].rank:SetValue(index)
	local info = self.info_list.list[index]
	self.variables[current_row].guild_name:SetValue(info.guild_name)
	self.variables[current_row].master_name:SetValue(info.tuanzhang_name)
	self.variables[current_row].guild_level:SetValue(info.guild_level)
	self.variables[current_row].member_count:SetValue(info.cur_member_count .. " / " .. info.max_member_count)
	self.variables[current_row].total_fight_power:SetValue(info.total_capability)
end

-- 向上翻页
function GuildListView:OnPageUp()
	self.current_page = self.current_page - 1
	self.current_page = self.current_page < 1 and 1 or self.current_page
	self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildListView:OnPageDown()
	self.current_page = self.current_page + 1
	self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
	self:FlushPage(self.current_page)
end

