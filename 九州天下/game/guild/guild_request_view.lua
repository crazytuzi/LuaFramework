GuildRequestView = GuildRequestView or BaseClass(BaseRender)

function GuildRequestView:__init(instance)
	if instance == nil then
		return
	end
	self.guild_list_view = instance

	self.row = 7  -- 每一页有多少行，暂定为8行
	self.current_page = 1
	-- self.panel = self:FindObj("Panel")
	self.list_table = {}
	self.toggle_table = {}
	for i = 1, self.row do
		self.list_table[i] = self:FindObj("List" .. i)
		self.toggle_table[i] = self:FindObj("Toggle" .. i)
	end

	self.toggle_guild_creat_type1 = self:FindObj("ToggleGuild1")
	self.toggle_guild_creat_type2 = self:FindObj("ToggleGuild2")
	self.create_window = self:FindObj("CreatGuildWindow")
	self.jump_window = self:FindObj("JumpWindowList")
	self.search_input = self:FindObj("SearchInput"):GetComponent("InputField")
	self.toggle_auto = self:FindObj("ToggleAuto").toggle
	self.auto_btn = self:FindObj("AutoBtn")

	self.creat_window_input = self:FindObj("CreatInputField"):GetComponent("InputField")
	self:ListenEvent("InptuValueChange", BindTool.Bind(self.InptuValueChange, self))
	-- 获取变量组件
	self.variables = {}
	for i = 1, self.row do
		self.variables[i] = {}
		self.variables[i].has_request = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("HasRequest")
		self.variables[i].guild_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("GuildName")
		self.variables[i].master_name = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MasterName")
		self.variables[i].guild_level = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
		self.variables[i].member_count = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("MemberCount")
		self.variables[i].total_fight_power = self.list_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("TotalFight")
	end

	self.variable_page = self:FindVariable("Page")
	self.level = self:FindVariable("Level")
	self.fp = self:FindVariable("Fp")
	self.notice = self:FindVariable("Notice")
	self.reminding = self:FindVariable("Reminding")
	self.show_reminding = self:FindVariable("ShowReminding")
	self.jump_page_text = self:FindVariable("JumpPage")

	self:ListenEvent("OnPageUp",
		BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown",
		BindTool.Bind(self.OnPageDown, self))
	self:ListenEvent("SelectGuild",
		BindTool.Bind(self.OnSelectGuild, self))
	self:ListenEvent("CreatGuild",
		BindTool.Bind(self.OnCreatGuild, self))
	self:ListenEvent("OnFirstPage",
		BindTool.Bind(self.OnFirstPage, self))
	self:ListenEvent("OnLastPage",
		BindTool.Bind(self.OnLastPage, self))
	self:ListenEvent("OnPageJump",
		BindTool.Bind(self.OnPageJump, self))
	self:ListenEvent("OnOpenJumpWindow",
		BindTool.Bind(self.OnOpenJumpWindow, self))
	self:ListenEvent("OnOpenCreatWindow",
		BindTool.Bind(self.OnOpenCreatWindow, self))
	self:ListenEvent("OnClickPageInput",
		BindTool.Bind(self.OnClickPageInput, self))
	self:ListenEvent("Search",
		BindTool.Bind(self.Search, self))
	self:ListenEvent("Reset",
		BindTool.Bind(self.Reset, self))
	self:ListenEvent("ClickAuto",
		BindTool.Bind(self.ClickAuto, self))
	self:ListenEvent("AutoEnter",
		BindTool.Bind(self.AutoEnter, self))

	for i = 1, self.row do
		self:ListenEvent("JoinGuild" .. i,
			function() self:OnJoinGuild(i) end)
	end

	self.creat_guild1 = self:FindVariable("CreatGuild1")

	local need_bind_gold = GuildData.Instance:GetGuildCreatBindGoldCount()
	self.creat_guild1:SetValue(string.format(Language.Guild.CreateGuildByBindGold, need_bind_gold))

	self.is_search = false
	self.jump_page = 1

	self.last_join_time = 0
    self.join_cd = 3
    local other_cfg = GuildData.Instance:GetOtherConfig()
    if other_cfg then
        self.join_cd = other_cfg.atuo_join_guild_cd or 3
    end
end

function GuildRequestView:__delete()
	self.guild_list_view = nil
end

-- 刷新View
function GuildRequestView:Flush()
	if self.is_search then
		self.is_search = false
	else
		self.info_list = self:GetList()
	end
	self:FlushPageCount()
	self.current_page = 1
	self:FlushPage(self.current_page)
	self:FlushGuildDetails()
end

-- 刷新页面数目
function GuildRequestView:FlushPageCount()
	self.info_count = self.info_list.count
	self.page_count = self.info_count / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

-- 更新页面
function GuildRequestView:FlushPage(page)
	if (page > self.page_count or page < 1) then
		return
	end
	self:ResetToggle()
	self.current_page = page
	self.variable_page:SetValue(self.current_page .. "/" .. self.page_count)
	if(page == self.page_count) then  -- 如果是最后一页
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
function GuildRequestView:FlushRow(index)
	if index <= 0 then
		return
	end
	local current_row = index % self.row
	if(current_row == 0) then
		current_row = self.row
	end

	local info = self.info_list.list[index]
	self.variables[current_row].guild_name:SetValue(info.guild_name)
	self.variables[current_row].master_name:SetValue(info.tuanzhang_name)
	self.variables[current_row].guild_level:SetValue(info.guild_level)
	self.variables[current_row].member_count:SetValue(info.cur_member_count .. "/" .. info.max_member_count)
	self.variables[current_row].total_fight_power:SetValue(info.total_capability)
	self.variables[current_row].has_request:SetValue(info.is_apply == 1)
end

-- 重置Toggle
function GuildRequestView:ResetToggle()
	self.toggle_table[1].toggle.isOn = true
	self:OnSelectGuild()
end

function GuildRequestView:CreateGuildByItem()
	self:OnOpenCreatWindow()
	self.toggle_guild_creat_type2.toggle.isOn = true
end
-- 向上翻页
function GuildRequestView:OnPageUp()
	self.current_page = self.current_page - 1
	self.current_page = self.current_page < 1 and 1 or self.current_page
	self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildRequestView:OnPageDown()
	self.current_page = self.current_page + 1
	self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
	self:FlushPage(self.current_page)
end

-- 跳转到首页
function GuildRequestView:OnFirstPage()
	self:FlushPage(1)
end

-- 跳转到尾页
function GuildRequestView:OnLastPage()
	self:FlushPage(self.page_count)
end

-- 跳转页面
function GuildRequestView:OnPageJump()
	self:FlushPage(self.jump_page)
	self.jump_page_text:SetValue(self.jump_page)
	self.jump_window:SetActive(false)
end

-- 打开跳转窗口
function GuildRequestView:OnOpenJumpWindow()
	self.jump_window:SetActive(true)
	self.jump_page = self.current_page
	self.jump_page_text:SetValue(self.jump_page)
end

-- 打开创建公会窗口
function GuildRequestView:OnOpenCreatWindow()
	self.create_window:SetActive(true)
	self:FlushCreatWindow()
end

-- 刷新创建公会窗口
function GuildRequestView:FlushCreatWindow()
	self.creat_window_input.text = ""
	self.toggle_guild_creat_type1.toggle.isOn = true
end

-- 选择公会
function GuildRequestView:OnSelectGuild()
	local index = 0
	for i = 1, self.row do
		if(self.toggle_table[i].toggle.isOn == true) then
			index = i + (self.current_page - 1) * 7
			break
		end
	end
	local info = self:GetInfoByIndex(index)
	if info then
		GuildCtrl.Instance:SendGuildInfoReq(info.guild_id)
	end
end

-- 申请加入公会
function GuildRequestView:OnJoinGuild(index)
	local select_guild_index = (self.current_page - 1) * self.row + index
	local info = self:GetInfoByIndex(select_guild_index)

	if info then
		GuildCtrl.Instance:SendApplyForJoinGuildReq(info.guild_id)
		if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
			info.is_apply = 1
			self:FlushRow(select_guild_index)
		end
	end
end

function GuildRequestView:GetInfoByIndex(index)
	return self.info_list.list[index]
end

-- 申请创建公会
function GuildRequestView:OnCreatGuild()
	local name = ""
	local guild_type = GuildCtrl.Instance.create_model.coin
	if(self.creat_window_input.text == "") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ShuRuXianMengMingZi)
		return
	else
		name = self.creat_window_input.text
	end
	if string.utf8len(name) > COMMON_CONSTS.GUILD_NAME_MAX then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildNameMaxLen)
		return
	end
	if ChatFilter.Instance:IsIllegal(name, true) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		return
	end
	local index = 0
	if(self.toggle_guild_creat_type1.toggle.isOn == false) then   -- 使用建盟令创建
		guild_type = GuildCtrl.Instance.create_model.jianmengling
		local create_item_id = GuildData.Instance:GetOtherConfig().create_item_id
		index = ItemData.Instance:GetItemIndex(create_item_id)
	else -- 使用绑定钻石创建
		local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
		local gold = GameVoManager.Instance:GetMainRoleVo().gold     			-- 元宝
		local need_bind_gold = GuildData.Instance:GetGuildCreatBindGoldCount()
		local function ok_func()
			guild_type = GuildCtrl.Instance.create_model.coin
			GuildCtrl.Instance:SendGuildBaseInfoReq(name, guild_type, index)
		end
		
		if bind_gold >= need_bind_gold then
			-- TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.Guild.GuildCraet)
			ok_func()
		elseif gold >= need_bind_gold or (gold + bind_gold) >= need_bind_gold then
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.Guild.GuildCraet)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
end

-- 关闭所有弹窗
function GuildRequestView:CloseAllWindow()
	self.create_window:SetActive(false)
end

-- 点击翻页输入框
function GuildRequestView:OnClickPageInput()
	TipsCtrl.Instance:OpenCommonInputView(self.jump_page, BindTool.Bind(self.PageInputEnd, self), nil, self.page_count)
end

function GuildRequestView:PageInputEnd(str)
	local num = tonumber(str)
	if(num < 1) then
		num = 1
	elseif(num > self.page_count) then
		num = self.page_count
	end
	self.jump_page = num
	self.jump_page_text:SetValue(self.jump_page)
end

function GuildRequestView:Search()
	local str = self.search_input.text
	if not str or str == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ShuRuXianMengMingZi)
		return
	end

	local list = {}
	list.is_first = GuildDataConst.GUILD_INFO_LIST.is_first
	list.is_server_backed = GuildDataConst.GUILD_INFO_LIST.is_server_backed
	list.list = {}
	local count = 0
	local guild_list = GuildDataConst.GUILD_INFO_LIST.list
	for i = 1, GuildDataConst.GUILD_INFO_LIST.count do
		if nil ~= string.find(guild_list[i].guild_name, str) then
			table.insert(list.list, guild_list[i])
			count = count + 1
		end
	end
	list.count = count
	self.info_list = list
	self.is_search = true
	if count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSearch)
	end
	self:Flush()
end

function GuildRequestView:Reset()
	self:Flush()
end

function GuildRequestView:GetList()
	local list = {}
	list.is_first = GuildDataConst.GUILD_INFO_LIST.is_first
	list.is_server_backed = GuildDataConst.GUILD_INFO_LIST.is_server_backed
	list.list = {}
	local count = 0
	local guild_list = GuildDataConst.GUILD_INFO_LIST.list
	for i = 1, GuildDataConst.GUILD_INFO_LIST.count do
		if not self.toggle_auto.isOn or guild_list[i].applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS then
			table.insert(list.list, guild_list[i])
			count = count + 1
		end
	end
	list.count = count
	return list
end

function GuildRequestView:FlushGuildDetails()
	local info = GuildData.Instance:GetOtherGuildInfo()
	if info and next(info) then
		if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS then
			local level_color = COLOR.RED
			local capability_color = COLOR.RED

			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if role_vo then
				if role_vo.level >= info.applyfor_need_level then
					level_color = COLOR.GREEN
				end
			
				if role_vo.capability >= info.applyfor_need_capability then
					capability_color = COLOR.GREEN
				end
			end

			self.show_reminding:SetValue(false)
			self.level:SetValue(ToColorStr(info.applyfor_need_level or 0, level_color))
			self.fp:SetValue(ToColorStr(info.applyfor_need_capability or 0, capability_color))
		else
			self.show_reminding:SetValue(true)
			if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
				self.reminding:SetValue(Language.Guild.NeedSupply)
			else
				self.reminding:SetValue(Language.Guild.RefuseSupply)
			end
		end
		local guild_notice = info.guild_notice
		if guild_notice == nil or guild_notice == "" then
			guild_notice = Language.Guild.EmptyNotice
		end
		self.notice:SetValue(guild_notice)
	else
		self:ClearDetails()
	end
end

function GuildRequestView:ClearDetails()
	self.level:SetValue("")
	self.fp:SetValue("")
	self.notice:SetValue("")
	self.show_reminding:SetValue(true)
	self.reminding:SetValue(Language.Common.ZanWu)
end

function GuildRequestView:ClickAuto(switch)
	self:Flush()
end

function GuildRequestView:AutoEnter()
	if GuildDataConst.GUILD_INFO_LIST.count <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Guild.NoSuitable)
		--self:OnOpenCreatWindow()
		return
	end
	if self.last_join_time + self.join_cd <= Status.NowTime then
        self.last_join_time = Status.NowTime
        GuildCtrl.Instance:SendApplyForJoinGuildReq(0, 1)
    else
        SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CaoZuoTaiKuai)
    end
end

function GuildRequestView:GetAutoBtn()
	return self.auto_btn
end

function GuildRequestView:InptuValueChange()
	local max = self.creat_window_input.characterLimit
	local length = StringUtil.GetCharacterCount(self.creat_window_input.text)
	if length >= max then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InputDes)
	end
end
