--角色称号页面
RoleTitlePage = RoleTitlePage or BaseClass()


function RoleTitlePage:__init()
	self.view = nil
	self.cur_title_id = 1
end	

function RoleTitlePage:__delete()
	self:RemoveEvent()
	if self.title_list then
		self.title_list:DeleteMe()
		self.title_list = nil
	end
	if self.grid_scroll_list then
		self.grid_scroll_list:DeleteMe()
		self.grid_scroll_list = nil
	end
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
	self.view = nil
end	

--初始化页面接口
function RoleTitlePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateTitle()
	self:CreateTitleList()
	self.cur_select_title = 1
	self.view.node_t_list.btn_wear_title.node:addClickEventListener(BindTool.Bind(self.OnWearTitle, self))
	self:InitEvent()
	
end	

--初始化事件
function RoleTitlePage:InitEvent()
	
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function RoleTitlePage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--更新视图界面
function RoleTitlePage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			self:UpdatePage()
		end
	end
end	

function RoleTitlePage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE or key == OBJ_ATTR.ACTOR_HEAD_TITLE then
		-- self:UpdatePage()
	end
end	

function RoleTitlePage:CreateTitle()
	self.title = Title.New()
	self.title:GetView():setPosition(cc.p(690, 473))
	self.view.node_t_list.layout_title.node:addChild(self.title:GetView(), 100)
	self.view.node_t_list.txt_tiitle_q.node:setString(Language.Role.Title_txt)
end

function RoleTitlePage:CreateTitleList()
	local ph = self.view.ph_list.ph_title_list
	self.title_list = ListView.New()
	self.title_list:Create(ph.x, ph.y-20, ph.w, ph.h, nil, TitleListRender, nil, nil, self.view.ph_list.ph_title_item)
	self.title_list:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_title.node:addChild(self.title_list:GetView(), 100)
	self.title_list:SetMargin(2)
	self.title_list:SetItemsInterval(15)
	self.title_list:SetJumpDirection(ListView.Top)
	self.title_list:SetSelectCallBack(BindTool.Bind1(self.SelectTitleCallBack, self))

	if not  self.grid_scroll_list then
		self.grid_scroll_list = GridScroll.New()
		local ph = self.view.ph_list.ph_title_attr_list
		local grid_node = self.grid_scroll_list:Create(ph.x+300,ph.y+80,ph.w,ph.h,2,self.view.ph_list.ph_title_attr_item.h + 5,RoleTitleAttrItemRender,ScrollDir.Vertical,true,self.view.ph_list.ph_title_attr_item)
		self.view.node_t_list.layout_title.node:addChild(grid_node, 100)
		-- self.grid_scroll_list:SetDataList(ChargePlatFormData.Instance:GetRechargeCfg())
		-- self.grid_scroll_list:JumpToTop()
	end

end

function RoleTitlePage:UpdatePage()
	local show_title_lis = TitleData.Instance:GetShowTitleList()
	self.title_list:SetDataList(show_title_lis)
	self.title_list:SelectIndex(self.cur_select_title)
	self:UpdateContent()
	self:FlushRemainTime()
end

function RoleTitlePage:SelectTitleCallBack(item, index)
	if nil == item or nil == item:GetData() then return end
	self.cur_select_title = index
	local data = item:GetData()
	self.title:SetTitleId(data.titleid)
	self.cur_title_id = data.titleid

	RichTextUtil.ParseRichText(self.view.node_t_list.rich_text.node, data.titleDesc)
	local staitcAttrs = TitleData.Instance:GetSelectTitleAttr(data.titleid)
	local title_attrs = RoleData.FormatRoleAttrStr(staitcAttrs)
	local attr_cnt = #title_attrs
	for i = 1, 6 do
		self.view.node_t_list["txt_attr_name_" .. i].node:setString("")
		self.view.node_t_list["txt_attr_value_" .. i].node:setString("")
		if self.view.node_t_list["txt_attr_name_c_" .. i] then
			self.view.node_t_list["txt_attr_name_c_" .. i].node:setString("")
		end
		if self.view.node_t_list["txt_attr_value_c_" .. i] then
			self.view.node_t_list["txt_attr_value_c_" .. i].node:setString("")
		end
	end

	for i,v in ipairs(title_attrs) do
		if attr_cnt <= 3 then
			self.view.node_t_list["txt_attr_name_c_" .. i].node:setString(v.type_str .. "：")
			self.view.node_t_list["txt_attr_value_c_" .. i].node:setString(v.value_str)
		else
			self.view.node_t_list["txt_attr_name_" .. i].node:setString(v.type_str .. "：")
			self.view.node_t_list["txt_attr_value_" .. i].node:setString(v.value_str)
		end
	end
	local isActive = TitleData.Instance:GetTitleActive(data.titleid) == 1
	self.view.node_t_list.btn_wear_title.node:setEnabled(isActive)
	local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
	local cur_title = bit:_and(head_title, 0x000000ff)
	local wear_text = (cur_title == data.titleid) and Language.Role.WearBtnTexts[2] or Language.Role.WearBtnTexts[1]
	self.view.node_t_list.btn_wear_title.node:setTitleText(wear_text)

	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function RoleTitlePage:OnWearTitle()
	if not self.title_list:GetSelectItem() then return end
	local seleItemData = self.title_list:GetSelectItem():GetData()

	if TitleData.Instance:GetTitleActive(seleItemData.titleid) == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoActTitle)
		return 
	end
	local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
	local title_1 = bit:_and(head_title, 0x000000ff)
	-- local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
	-- title_1 = seleItemData.titleid
	if title_1 == 0 or title_1 ~= seleItemData.titleid then
		title_1 = seleItemData.titleid
	else
		title_1 = 0
	end

	TitleCtrl.SetCurUseTitleReq(title_1, 0)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function RoleTitlePage:FlushRemainTime()
	local count_down_time = TitleData.Instance:GetTimeLimitTitleRestTime(self.cur_title_id)
	local time_str = ""
	if count_down_time > 0 then
		time_str = TimeUtil.FormatSecond2Str(count_down_time, 1)
	end

	self.view.node_t_list.txt_count_down_time.node:setString(time_str)
end

function RoleTitlePage:UpdateContent()
	local get_cnt = 0
	local bit_t = bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_HEAD_TITLE), false)
	for k, v in pairs(bit_t) do
		if v == 1 then
			get_cnt = get_cnt + 1
		end
	end
	local all_show_cnt = TitleData.Instance:GetCount()
	self.view.node_t_list.txt_get_title.node:setString(get_cnt .. "/" .. all_show_cnt)
	local attrs_t = TitleData.Instance:GetAllActiveTitleAttr()
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, true)
	self.grid_scroll_list:SetDataList(title_attrs)
	self.grid_scroll_list:JumpToTop()
end


RoleTitleAttrItemRender = RoleTitleAttrItemRender or BaseClass(BaseRender)
function RoleTitleAttrItemRender:__init()
	
end

function RoleTitleAttrItemRender:__delete()

end

function RoleTitleAttrItemRender:CreateChild()
	BaseRender.CreateChild(self)

end

function RoleTitleAttrItemRender:OnFlush()
	if not self.data then return end	
	self.node_tree.txt_name_info.node:setString(self.data.type_str..":")
	self.node_tree.txt_value_info.node:setString(self.data.value_str)
end

