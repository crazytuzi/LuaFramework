GuildListView = GuildListView or BaseClass(BaseRender)

function GuildListView:__init(instance)
	if instance == nil then
		return
	end
	self.guild_list_view = instance

	self.row = 8  -- 每一页有多少行，暂定为8行
	--获取list物体
	self.list_table = {}
	self.toggle_table = {}
	for i = 1, self.row do
		self.list_table[i] = self:FindObj("List" .. i)
		self.toggle_table[i] = self:FindObj("Toggle" .. i)
	end

	self.toggle_guild_creat_type1 = self:FindObj("ToggleGuild1")
	self.toggle_guild_creat_type2 = self:FindObj("ToggleGuild2")
	self.create_window = self:FindObj("CreatGuildWindow")

	self.image_table = {}
	for i = 1, 3 do
		self.image_table[i] = self:FindObj("Number" .. i)
	end

	self.button_join = self:FindObj("ButtonJoin")
	self.button_creat = self:FindObj("ButtonCreat")
	self.creat_window_input = self:FindObj("CreatInputField"):GetComponent("InputField")
	-- 获取变量组件
	self.variables = {}
	for i = 1, self.row do
		self.variables[i] = {}
		self.variables[i].rank = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Rank")
		self.variables[i].guild_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("GuildName")
		self.variables[i].master_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MasterName")
		self.variables[i].guild_level = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
		self.variables[i].member_count = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MemberCount")
		self.variables[i].total_fight_power = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("TotalFight")
	end
	self.variable_page = self:FindVariable("Page")

	self:ListenEvent("OnPageUp", BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown", BindTool.Bind(self.OnPageDown, self))
end

function GuildListView:LoadCallBack()
	self.my_guild_name = self:FindVariable("MyGuildName")
    self.my_master_name = self:FindVariable("MyMasterName")
    self.my_member_count = self:FindVariable("MyMemberCount")
    self.my_total_fight = self:FindVariable("MyTotalFight")
    self.my_rank = self:FindVariable("MyRank")
    self.my_img_rank = self:FindVariable("MyRankImg")

    self:GuildInfoList()
 end

function GuildListView:__delete()
	self.guild_list_view = nil
end

-- 刷新View
function GuildListView:Flush()
	self.info_list = GuildDataConst.GUILD_INFO_LIST
	self:FlushPageCount()
	self.current_page = 1
	self:FlushPage(self.current_page)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_id > 0 then
		self.button_join:SetActive(false)
		self.button_creat:SetActive(false)
	else
		self.button_join:SetActive(true)
		self.button_creat:SetActive(true)
	end
	if self.guild_scroller.scroller.isActiveAndEnabled then
        self.guild_scroller.scroller:ReloadData(0)
    end



    local data , my_rank_index = GuildData.Instance:GuildListMyInfo()
	if data then
	  	self.my_guild_name:SetValue(data.guild_name)
	    self.my_master_name:SetValue(data.tuanzhang_name)
	    self.my_member_count:SetValue(data.cur_member_count .. "/" .. data.max_member_count)
	    self.my_total_fight:SetValue(data.total_capability)
	    if my_rank_index <= 3 then 
			local bundle, asset = ResPath.GetRankIcon(my_rank_index)
			self.my_img_rank:SetAsset(bundle, asset)
		else
			self.my_rank:SetValue(my_rank_index)
		end
	end
end

function GuildListView:GuildInfoList()
    self.guild_list = {}
    self.guild_scroller = self:FindObj("GuildScroller")
    local delegate = self.guild_scroller.list_simple_delegate
    -- 生成数量
    delegate.NumberOfCellsDel = function()
        return #GuildData.Instance:GetGuildInfoList()
    end
    -- 格子刷新
    delegate.CellRefreshDel = function(cell, data_index)
        data_index = data_index + 1
        local target_cell = self.guild_list[cell]
        if nil == target_cell then
            self.guild_list[cell] =  GuildListCell.New(cell.gameObject)
            target_cell = self.guild_list[cell]
            target_cell.mother_view = self
        end
        local data = GuildData.Instance:GetGuildInfoList()
        local cell_data = data[data_index]
        cell_data.data_index = data_index
        -- target_cell:SetShowHighLight(GuildData.Instance:GetCurIndex() or false)
        target_cell:SetIndex(data_index)
        target_cell:SetData(cell_data)
    end
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

-- 更新页面
function GuildListView:FlushPage(page)
	if(page > self.page_count or page < 1) then
		return
	end
	self:ResetToggle()
	self.button_join:GetComponent("ButtonEx").interactable = false
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
	if index <= 0 then
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
	self.variables[current_row].member_count:SetValue(info.cur_member_count .. "/" .. info.max_member_count)
	self.variables[current_row].total_fight_power:SetValue(info.total_capability)
end

-- 重置Toggle
function GuildListView:ResetToggle()
	for i = 1, self.row do
		self.toggle_table[i].toggle.isOn = false
	end
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

-- 关闭所有弹窗
function GuildListView:CloseAllWindow()

end

------------------------------家族List----------------------------

GuildListCell = GuildListCell or BaseClass(BaseCell)

function GuildListCell:__init()
    self.guild_name = self:FindVariable("GuildName")
    self.master_name = self:FindVariable("MasterName")
    self.member_count = self:FindVariable("MemberCount")
    self.total_fight = self:FindVariable("TotalFight")
    self.rank = self:FindVariable("Rank")

    self.img_rank = self:FindVariable("RankImg")
end

function GuildListCell:__delete()
 
end

function GuildListCell:SetIndex(index)
 	self.rank_index = index
end

function GuildListCell:OnFlush()
    if nil == self.data then return end
    self.guild_name:SetValue(self.data.guild_name)
    self.master_name:SetValue(self.data.tuanzhang_name)
    self.member_count:SetValue(self.data.cur_member_count .. "/" .. self.data.max_member_count)
    self.total_fight:SetValue(self.data.total_capability)
    if self.rank_index <= 3 then 
		local bundle, asset = ResPath.GetRankIcon(self.rank_index)
		self.img_rank:SetAsset(bundle, asset)
	else
		self.rank:SetValue(self.rank_index)
		self.img_rank:SetAsset("", "")
	end
end