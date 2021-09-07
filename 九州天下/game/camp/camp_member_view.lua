CampMemberView = CampMemberView or BaseClass(BaseRender)

function CampMemberView:__init()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_DEFAULT
end

function CampMemberView:__delete()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_DEFAULT

	if self.camp_member_cell_list then
		for k,v in pairs(self.camp_member_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_member_cell_list = {}

	self.label_page = nil

end

function CampMemberView:SendQueryCampMemInfo()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_DEFAULT
	CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
end

function CampMemberView:LoadCallBack(instance)

	----------------------------------------------------
	-- 列表生成滚动条
	self.camp_member_cell_list = {}
	self.camp_member_listview_data = {}
	self.camp_member_list = self:FindObj("CampMemberListView")

	local camp_member_list_delegate = self.camp_member_list.list_simple_delegate
	--生成数量
	camp_member_list_delegate.NumberOfCellsDel = function()
		return #self.camp_member_listview_data or 0
	end
	--刷新函数
	camp_member_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampMemberListView, self)
	-- 移动scrollerview的时候调用
	-- self.camp_member_list.scroller.scrollerScrollingChanged = function ()
	-- end
	----------------------------------------------------

	-- 监听UI事件
	self:ListenEvent("OnPageUp", BindTool.Bind(self.OnBtnPageHandler, self, 0))
	self:ListenEvent("OnPageDown", BindTool.Bind(self.OnBtnPageHandler, self, 1))
	self:ListenEvent("OnRankCapacity", BindTool.Bind(self.OnRankCapacityHandler, self))
	self:ListenEvent("OnRankJunGong", BindTool.Bind(self.OnRankJunGongHandler, self))
	self:ListenEvent("OnRankKillNum", BindTool.Bind(self.OnRankKillNumHandler, self))
	self:ListenEvent("OnRankGuanZhi", BindTool.Bind(self.OnRankGuanZhiHandler, self))
	self:ListenEvent("OnGoChangeCamp", BindTool.Bind(self.OnGoChangeCamp, self))

	-- 获取变量
	self.label_page = self:FindVariable("PageText")
	self.lable_my_guanzhi = self:FindVariable("MyGuanZhi")
	self.lable_my_name = self:FindVariable("MyName")
	self.lable_my_family = self:FindVariable("MyFamily")
	self.is_king = self:FindVariable("IsKing")
	self.is_vip = self:FindVariable("IsVip")
	self.my_sex = self:FindVariable("MySex")
	self.lbl_my_level = self:FindVariable("MyLevel")
	self.lbl_my_capability = self:FindVariable("MyCapability")
	self.lbl_my_jungong = self:FindVariable("MyJunGong")
	self.lbl_my_numberkill = self:FindVariable("MyNumberKill")
	self:Flush()
end

function CampMemberView:OnFlush(param_list)
	local camp_mem_info = CampData.Instance:GetCampMemInfo()
	self.label_page:SetValue(camp_mem_info.page .. "/" .. camp_mem_info.total_page)

	-- 设置list数据
	self.camp_member_listview_data = camp_mem_info.mem_info_item_list
	if self.camp_member_list.scroller.isActiveAndEnabled then
		self.camp_member_list.scroller:ReloadData(0)
	end

	self:FlushMyInfo()
	--print_log(GameVoManager.Instance:GetMainRoleVo())
end

-- 列表listview
function CampMemberView:RefreshCampMemberListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_member_cell = self.camp_member_cell_list[cell]
	if camp_member_cell == nil then
		camp_member_cell = CampMemberItemRender.New(cell.gameObject)
		camp_member_cell:SetToggleGroup(self.camp_member_list.toggle_group)
		-- camp_member_cell:SetClickCallBack(BindTool.Bind1(self.ClickCampMemberHandler, self))
		self.camp_member_cell_list[cell] = camp_member_cell
	end

	camp_member_cell:SetIndex(data_index)
	camp_member_cell:SetData(self.camp_member_listview_data[data_index])
end

-- 回调函数
function CampMemberView:ClickCampMemberHandler(cell)
	if nil == cell or nil == cell.data then end
end

-- 翻页
function CampMemberView:OnBtnPageHandler(page_type)
	local camp_mem_info = CampData.Instance:GetCampMemInfo()
	if page_type == 0 then
		if self.page - 1 > 0 then
			CampMemberItemRender.SelectIndex = -1
			self.page = self.page - 1
			CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
		end
	else
		if camp_mem_info.total_page >= self.page + 1 then
			CampMemberItemRender.SelectIndex = -1
			self.page = self.page + 1
			CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
		end
	end
end

-- 战斗力排序
function CampMemberView:OnRankCapacityHandler()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_CAPABILITY
	CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
end

-- 军功排序
function CampMemberView:OnRankJunGongHandler()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_JUNGONG
	CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
end

-- 击杀排序
function CampMemberView:OnRankKillNumHandler()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_KILLNUM
	CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
end

-- 官职排序
function CampMemberView:OnRankGuanZhiHandler()
	self.page = 1
	self.order_type = CAMP_MEM_QUERY_ORDER_TYPE.CMQOT_DEFAULT
	CampCtrl.Instance:SendQueryCampMemInfo(self.page, self.order_type)
end
--显示自己的信息
function CampMemberView:FlushMyInfo()
	self.is_king:SetValue(GameVoManager.Instance:GetMainRoleVo().camp_post == 1)
	self.lable_my_guanzhi:SetValue(Language.Common.CampPost[GameVoManager.Instance:GetMainRoleVo().camp_post])
	self.lable_my_name:SetValue(GameVoManager.Instance:GetMainRoleVo().name or "")
	self.is_vip:SetValue(GameVoManager.Instance:GetMainRoleVo().vip_level>0)
	self.my_sex:SetValue(GameVoManager.Instance:GetMainRoleVo().sex == 0)
	self.lbl_my_level:SetValue(GameVoManager.Instance:GetMainRoleVo().level)
	self.lable_my_family:SetValue(GameVoManager.Instance:GetMainRoleVo().guild_name or Language.Common.No)
	if GameVoManager.Instance:GetMainRoleVo().guild_name == "" then
		self.lable_my_family:SetValue(Language.Common.No)
	else
		self.lable_my_family:SetValue(GameVoManager.Instance:GetMainRoleVo().guild_name)
	end
	self.lbl_my_capability:SetValue(GameVoManager.Instance:GetMainRoleVo().capability)
	
	if CampData.Instance:GetCampMemInfo().oneself_mem_info.jungong then
	self.lbl_my_jungong:SetValue(CampData.Instance:GetCampMemInfo().oneself_mem_info.jungong)
	end
	if CampData.Instance:GetCampMemInfo().oneself_mem_info.kill_num then 
	self.lbl_my_numberkill:SetValue(CampData.Instance:GetCampMemInfo().oneself_mem_info.kill_num)
	end
end

function CampMemberView:OnGoChangeCamp()
	local camp_change_npc = CampData.Instance:GetOtherByStr("change_camp_npc_id")
	local camp_change_scene = CampData.Instance:GetOtherByStr("change_camp_npc_scene")
	local npc_info = nil
	if camp_change_npc ~= nil and camp_change_scene ~= nil then
		local scene_info = ConfigManager.Instance:GetSceneConfig(camp_change_scene)
		if scene_info and scene_info.npcs then
			for k, v in pairs(scene_info.npcs) do
				if v.id == camp_change_npc then
					npc_info = v
					break
				end
			end
		end

		if npc_info ~= nil then
			local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list
			local npc_name = ""
			if npc_config and npc_config[npc_info.id] then
				npc_name = npc_config[npc_info.id].name
			end

			local str = string.format(Language.Common.IsGoToChangeTip, scene_info.name .. npc_name)
			TipsCtrl.Instance:ShowCommonTip(function() 
					MoveCache.end_type = MoveEndType.NpcTask
					MoveCache.param1 = camp_change_npc
					GuajiCtrl.Instance:MoveToPos(camp_change_scene, npc_info.x, npc_info.y, 4, 2, false)
					ViewManager.Instance:Close(ViewName.Camp)
				end, nil, str)
		end
	end
end

----------------------------------------------------------------------------
--CampMemberItemRender	成员列表
----------------------------------------------------------------------------
CampMemberItemRender = CampMemberItemRender or BaseClass(BaseCell)
CampMemberItemRender.SelectIndex = -1

function CampMemberItemRender:__init()
	self.is_monarch = self:FindVariable("IsMonarch")
	self.lbl_guanzhi = self:FindVariable("GuanZhi")
	self.is_online = self:FindVariable("IsOnline")
	self.lbl_player_name = self:FindVariable("PlayerName")
	self.show_vip_icon = self:FindVariable("ShowVipIcon")
	self.is_female = self:FindVariable("IsFemale")
	self.lbl_level = self:FindVariable("Level")
	self.lbl_subjection_family = self:FindVariable("SubjectionFamily")
	self.lbl_capability = self:FindVariable("Capability")
	self.lbl_jun_gong = self:FindVariable("JunGong")
	self.lbl_number_kill = self:FindVariable("NumberKill")

	self:ListenEvent("OnClickHandler", BindTool.Bind(self.OnClickHandler, self))
end

function CampMemberItemRender:__delete()
	self.is_monarch = nil
	self.lbl_guanzhi = nil
	self.is_online = nil
	self.lbl_player_name = nil
	self.show_vip_icon = nil
	self.is_female = nil
	self.lbl_level = nil
	self.lbl_subjection_family = nil
	self.lbl_capability = nil
	self.lbl_jun_gong = nil
	self.lbl_number_kill = nil
end

function CampMemberItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local is_monarch = self.data.post == CAMP_POST.CAMP_POST_KING

	self.is_monarch:SetValue(is_monarch)
	self.lbl_guanzhi:SetValue(is_monarch and "" or ToColorStr(Language.Common.CampPost[self.data.post] or "", CAMP_POST_NAME[self.data.post] or TEXT_COLOR.BLUE))
	self.is_online:SetValue(self.data.is_online == 1)

	self.lbl_player_name:SetValue(self.data.name or "")
	self.show_vip_icon:SetValue(self.data.vip_level > 0)
	self.is_female:SetValue(self.data.sex == GameEnum.FEMALE)
	self.lbl_level:SetValue(self.data.level)
	if self.data.guild_name == "" then
		self.lbl_subjection_family:SetValue(Language.Common.No)
	else
		self.lbl_subjection_family:SetValue(self.data.guild_name or Language.Common.No)
	end
	self.lbl_capability:SetValue(self.data.capability)
	self.lbl_jun_gong:SetValue(self.data.jungong)
	self.lbl_number_kill:SetValue(self.data.kill_num)

	self.root_node.toggle.isOn = (CampMemberItemRender.SelectIndex == self.index)
end

function CampMemberItemRender:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CampMemberItemRender:OnClickHandler()
	self.root_node.toggle.isOn = true
	CampMemberItemRender.SelectIndex = self.index
	local my_name = PlayerData.Instance.role_vo.name
	if self.data.name ~= "" and self.data.name ~= my_name then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name)
	end
end

