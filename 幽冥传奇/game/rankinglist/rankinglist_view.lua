--排行榜视图
RankingListView = RankingListView or BaseClass(BaseView)

function RankingListView:__init()
	self.title_img_path = ResPath.GetWord("word_ranking")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/rankinglist.png',
		'res/xui/meridians.png',
		'res/xui/equipbg.png',
		'res/xui/prestige.png',
	}

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		{"rankinglist_ui_cfg", 1, {0}},
		{"rankinglist_ui_cfg", 2, {0}},
		{"rankinglist_ui_cfg", 3, {0}},
		--{"rankinglist_ui_cfg", 4, {0}, false}, -- 默认隐藏 layout_wing
		--{"rankinglist_ui_cfg", 5, {0}, false}, -- 默认隐藏 layout_shilian
		--{"rankinglist_ui_cfg", 6, {0}},
	}
	self.tabbar = nil
	self.ranking_list = nil
	self.shilian_ranking_list = nil
	self.current_index = 1
	self.role_display = nil
	self.role_list = {}
end

function RankingListView:__delete()
end

function RankingListView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	
	if self.ranking_list then	
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end	

	if self.shilian_ranking_list then	
		self.shilian_ranking_list:DeleteMe()
		self.shilian_ranking_list = nil
	end
	
	if self.role_info_view then
		self.role_info_view:DeleteMe()
		self.role_info_view = nil
	end
	
	if self.wing_display then
		self.wing_display:DeleteMe()
		self.wing_display = nil
	end

	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end

	self.role_list = {}
end

function RankingListView:LoadCallBack(index, loaded_times)
	self:InitTabbar()
	
	local size = self.node_t_list.layout_equip.node:getContentSize()
	self:CreateRankingList()
	--self:CreateShilianRankingList()
	self:CreateRoleDisplay()
	--EventProxy.New(RankingListData.Instance, self):AddEventListener(RankingListData.SHILIAN_LIST_CHANGE, BindTool.Bind(self.OnShiLianListChange, self))
end

function RankingListView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RankingListView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RankingListView:ShowIndexCallBack(index)
	local rankinglist_type = RankingListData.GetSendRankingListType(self.current_index)
	RankingListCtrl.Instance:SendMyRankingListDataReq(rankinglist_type)
	RankingListCtrl.Instance:SendRankingListReq(rankinglist_type)
	-- self:Flush()
end

function RankingListView:OnFlush(param_t)
	--if self.current_index == 4 then
	--	self.node_t_list["layout_ranking_list"].node:setVisible(false)
	--	self.node_t_list["layout_equip"].node:setVisible(false)
	--	self.node_t_list["layout_wing"].node:setVisible(false)
	--	self.node_t_list["layout_shilian"].node:setVisible(true)
	--
	--	local my_ranking = RankingListData.Instance:GetMyData()
	--	local text
	--	if my_ranking == 0 then
	--		text = "我的排行：{color;ff2828;" .. Language.RankingList.MyRanking .. "}"
	--	else
	--		text = "我的排行：{color;ff2828;" .. my_ranking .. "}"
	--	end
	--	RichTextUtil.ParseRichText(self.node_t_list["rich_my_ranking"].node, text, 19, COLOR3B.WHITE)
	--
	--	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	--	text = "我的试炼关卡：{color;ff2828;" .. part_num .. "}"
	--	RichTextUtil.ParseRichText(self.node_t_list["rich_my_current_level"].node, text, 19, COLOR3B.WHITE)
	--	self:FlushShiLianRanking()
	--else
	--	self.node_t_list["layout_ranking_list"].node:setVisible(true)
	--	self.node_t_list["layout_shilian"].node:setVisible(false)
		if self.current_index == 1 then
			self.node_t_list.txt_zhanli_type.node:setString(Language.RankingList.Name[1])
		elseif self.current_index == 2 or self.current_index == 5 then
			self.node_t_list.txt_zhanli_type.node:setString(Language.RankingList.Name[2])
		elseif self.current_index == 3 then
			self.node_t_list.txt_zhanli_type.node:setString(Language.RankingList.Name[3])
		 elseif self.current_index == 4 then
		 	self.node_t_list.txt_zhanli_type.node:setString("")
		end

		-- 我的排名
		local my_ranking = RankingListData.Instance:GetMyData()
		if my_ranking == 0 then
			self.node_t_list.txt_my_ranking.node:setString("")
			self.node_t_list.lbl_my_ranking_title.node:setVisible(false)
			
			self.node_t_list.img_text.node:setVisible(true)
		else
			self.node_t_list.txt_my_ranking.node:setString(my_ranking)
			self.node_t_list.lbl_my_ranking_title.node:setVisible(true)

			self.node_t_list.img_text.node:setVisible(false)
		end
	--
	self.node_t_list.text_zhangu.node:setVisible(self.current_index == 4)
		self:FlushRanking()
	self:FlushRoleDisplay()
	--end
	self.tabbar:SelectIndex(self.current_index)
end
------------------------------------------------------------------------------
function RankingListView:RankViewShowIndex()
	local show_index = 1
	if ViewManager.Instance:IsOpen(ViewDef.RankingList.FightingCapacity) then
		show_index = 1
	elseif ViewManager.Instance:IsOpen(ViewDef.RankingList.Rank) then
		show_index = 2
	elseif ViewManager.Instance:IsOpen(ViewDef.RankingList.GodWing) then
		show_index = 3
	elseif ViewManager.Instance:IsOpen(ViewDef.RankingList.Trial) then
		show_index = 4
	elseif ViewManager.Instance:IsOpen(ViewDef.RankingList.Prestige) then
		show_index = 5
	end
	return show_index
end

function RankingListView:ReleaseHelper()
	self.view_manager:AddReleaseObj(self)
end

function RankingListView:Close(...)
	if not ViewManager.Instance:IsOpen(ViewDef.RankingList) then
		RankingListView.super.Close(self, ...)
	end
end

function RankingListView:Open(index)
	self.current_index = self:RankViewShowIndex()
	RankingListView.super.Open(self, self.current_index)
end
------------------------------------------------------------------------------

----------标签栏----------
function RankingListView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(0, 10)
		self.tabbar:SetSpaceInterval(8)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650,
		BindTool.Bind(self.SelectTabCallback, self), Language.RankingList.TabGroup,
		true, ResPath.GetCommon("toggle_110"),20, true, 100)
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function RankingListView:SelectTabCallback(index)
	self.current_index = index
	local rankinglist_type = RankingListData.GetSendRankingListType(self.current_index)
	RankingListCtrl.Instance:SendMyRankingListDataReq(rankinglist_type)
	RankingListCtrl.Instance:SendRankingListReq(rankinglist_type)	
	if self.ranking_list then self.ranking_list:AutoJump() end
	--self.node_t_list.layout_wing.node:setVisible(index == 3)
	--self.node_t_list.layout_equip.node:setVisible(index ~= 3)
	self.node_t_list.text_guild_title.node:setVisible(index ~= 4)
	--if index ~= 3 then
	--	self.wing_display:Show(0)
	--end
	self.node_t_list.text_zhangu.node:setVisible(index == 4)
end
----------end----------
function RankingListView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.RankingRender, nil, nil, self.ph_list.ph_rankinglist_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.ranking_list:SetSelectCallBack(BindTool.Bind(self.OnRankCallBack, self))
		self.node_t_list.layout_ranking_list.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

--function RankingListView:CreateShilianRankingList()
--	if nil == self.shilian_ranking_list then
--		local ph = self.ph_list.ph_shilian_ranking_list
--		self.shilian_ranking_list = ListView.New()
--		self.shilian_ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.ShilianRankingRender, nil, nil, self.ph_list.ph_rankinglist_item_2)
--		self.shilian_ranking_list:GetView():setAnchorPoint(0, 0)
--		self.shilian_ranking_list:SetMargin(2)
--		self.shilian_ranking_list:SetItemsInterval(5)
--		self.shilian_ranking_list:SetJumpDirection(ListView.Top)
--		-- self.ranking_list:SetSelectCallBack(BindTool.Bind(self.OnRankCallBack, self))
--		self.node_t_list.layout_shilian.node:addChild(self.shilian_ranking_list:GetView(), 100)
--	end
--end

function RankingListView:OnRankCallBack(select_item, index)
	--if select_item then
	--	local data = select_item:GetData()
		--阶数显示
		--if self.current_index == 3 then
		--	if data.ranking_value then
		--		local show_level, show_grade = WingData.GetWingLevelAndGrade(data.ranking_value)
		--		if not cc.FileUtils:getInstance():isFileExist(string.format("res/chibang/%d/big_stand_4.png", show_level)) and show_level ~= 0 then return end
		--		--self.wing_display:Show(show_level)
		--		--self.node_t_list.layout_upgrade_jie.node:setVisible(show_level > 0)
		--		--CommonDataManager.FlushUiGradeView(self.node_tree.layout_wing.layout_upgrade_jie.img_jie1.node, self.node_tree.layout_wing.layout_upgrade_jie.img_jie2.node, show_level)
		--	else
		--		--self.node_t_list.layout_upgrade_jie.node:setVisible(false)
		--	end
		--end
		--BrowseCtrl.Instance:BrowRoleInfo(data.role_name, 0, BindTool.Bind(self.OnOffLineRoleData, self))
	--end
end

function RankingListView:OnOffLineRoleData(protocol)
	if not self:IsOpen() then return end
	self.role_info_view:SetRoleVo(protocol.vo)
	-- self.wing_display:Show(protocol.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE])
	
	-- 普通装备
	local equip_list = {}
	for _, equip in pairs(protocol.vo.equip_list) do
		local slot = EquipData.Instance:GetEquipSlotByType(equip.type, equip.hand_pos)
		equip_list[slot] = equip

		-- 强化等级
		equip.strengthen_level = protocol.vo.equip_slots[slot] or 0

		-- 宝石镶嵌
		local equip_inset_info = protocol.vo.stone_info[slot]
		if equip_inset_info then
			for index, v in pairs(equip_inset_info) do
				equip["slot_" .. index] = v
			end
		end

		-- 铸魂
		equip.slot_soul = protocol.vo.soul_info[slot] or 0

		-- 精炼
		equip.slot_apotheosis = protocol.vo.apotheosis_info[slot] or 0
	end
	
	-- 神炉装备
	for k, v in pairs(protocol.vo.godf_eq_levels) do
		GodFurnaceData.Instance:SetOtherVirtualEquipData(protocol.vo[OBJ_ATTR.ACTOR_PROF], k, v)
	end
	
	self.role_info_view:SetGetEquipData(function(slot_data)
		if slot_data.equip_slot then
			return equip_list[slot_data.equip_slot]
		elseif slot_data.gf_equip_slot then
			return GodFurnaceData.Instance:GetOtherVirtualEquipData(slot_data.gf_equip_slot)
		end
		return nil
	end)
	
	--设置神器数据来源
	self.role_info_view.shenqi_cell:SetGetShenqiLevelFunc(function ()
		return protocol.vo.shenqi_level
	end)
	self.role_info_view.shenqi_cell:SetGetShenqiEquipDataFunc(function ()
		return ShenqiData.Instance:GetOtherVirtualEquipData(protocol.vo)
	end)

	self.role_info_view:FlushEquipGrid()
	self.role_info_view:GetView():setVisible(true)
end

function RankingListView:FlushRanking()
	if not self.ranking_list then return end
	local rankinglist_type = RankingListData.GetSendRankingListType(self.current_index)
	local rankinglist_data = RankingListData.Instance:GetRankingListData(rankinglist_type)
	local data_list = {}
	for k, v in pairs(rankinglist_data) do
		if v.ranking_value ~= 0 then
			table.insert(data_list, v)
		end
	end
	self.ranking_list:SetDataList(data_list)
	self.ranking_list:SelectIndex(1)
end

function RankingListView:FlushShiLianRanking()
	if not self.ranking_list then return end
	local rankinglist_type = RankingListData.GetSendRankingListType(self.current_index)
	local rankinglist_data = RankingListData.Instance:GetRankingListData(rankinglist_type)
	local data_list = {}
	local first_data
	for k, v in pairs(rankinglist_data) do
		if v.ranking_value ~= 0 and #data_list < 19 then
			if k == 1 then
				first_data = v
			else
				table.insert(data_list, v)
			end
		end
	end
	if first_data ~= nil then
		self.node_t_list["lbl_current_level"].node:setString("(" .. first_data.ranking_value .. "关)" or "")
	end
	self.shilian_ranking_list:SetDataList(data_list)
	self.shilian_ranking_list:SetSelectItemToTop(1)
	self.shilian_ranking_list:SelectIndex(0)
end

-- 创建角色显示
function RankingListView:CreateRoleDisplay()
	for i = 1, 3 do
		local ph = self.ph_list["ph_role_display"]
		self.role_list[i] = RoleDisplay.New(self.node_t_list["layout_display_role_" .. i].node, 999, false, false, true, true)
		self.role_list[i]:SetPosition(ph.x+ 10, ph.y -60)
		self.role_list[i]:SetScale(0.5)
	end
end

---- 设置角色数据
--function RankingListView:SetRoleData(protocol)
--
--		if self.top_three_name[i] then
--			if self.top_three_name[i] == protocol.vo.name then
--				self.role_list[i]:SetRoleVo(protocol.vo)
--				self.role_list[i]:SetVisible(true)
--				self.role_list[i]:SetScale(0.75)
--				self.node_t_list["txt_role_name_" .. i].node:setString(self.top_three_name[i])
--				XUI.EnableOutline(self.node_t_list["txt_role_name_" .. i].node)
--				break
--			end
--		else
--			print("i = ", i)
--			self.role_list[i]:SetRoleVo(nil)
--			self.role_list[i]:SetVisible(true)
--			self.role_list[i]:SetScale(0.75)
--			self.node_t_list["txt_role_name_" .. i].node:setString("")
--		end
--
--end

function RankingListView:FlushRoleDisplay()
	local rankinglist_type = RankingListData.GetSendRankingListType(self.current_index)
	self.top_three_name = RankingListData.Instance:GetTopThreeName(rankinglist_type)

	for i = 1, 3  do
		if self.top_three_name[i] then
			BrowseCtrl.Instance:BrowRoleInfo(self.top_three_name[i], 0, 	function (protocol)
				self.role_list[i]:SetRoleVo(protocol.vo)
				self.role_list[i]:SetVisible(true)
				self.role_list[i]:SetScale(0.5)
				self.node_t_list["txt_role_name_" .. i].node:setString(self.top_three_name[i])
				XUI.EnableOutline(self.node_t_list["txt_role_name_" .. i].node)
			end)
		else
			--self.role_list[i]:SetRoleVo(nil)
			self.role_list[i]:SetVisible(false)
			self.role_list[i]:SetScale(0.5)
			self.node_t_list["txt_role_name_" .. i].node:setString("")
			XUI.EnableOutline(self.node_t_list["txt_role_name_" .. i].node)
		end
	end

		--if nil ~= next(self.role_list) then
		--	BrowseCtrl.Instance:BrowRoleInfo(self.top_three_name[1], 0, BindTool.Bind(self.SetRoleData, self))
		--	BrowseCtrl.Instance:BrowRoleInfo(self.top_three_name[2], 0, BindTool.Bind(self.SetRoleData, self))
		--	BrowseCtrl.Instance:BrowRoleInfo(self.top_three_name[3], 0, BindTool.Bind(self.SetRoleData, self))
		--end
	end
--------------------------------------------------------------end
---- 创建角色显示
--function RankingListView:CreateRoleDisplay()
--	self.role_display_layout = XUI.CreateLayout(240, 140, 310, 360)
--	self.role_display_layout:setAnchorPoint(0, 0)
--	self.node_t_list["layout_shilian"].node:addChild(self.role_display_layout, 99)
--	self.role_display = RoleDisplay.New(self.role_display_layout, 100, false, false, true, true)
--	self.role_display:SetPosition(90, 130)
--	self.role_name = XUI.CreateText(330, 460, 200, 21, nil, "999")
--	self.role_name:setColor(COLOR3B.WHITE)
--	self.node_t_list["layout_shilian"].node:addChild(self.role_name, 100)
--
--	local eff_id = TITLE_CLIENT_CONFIG[45].effect_id
--	RenderUnit.CreateEffect(eff_id, self.node_t_list["layout_shilian"].node, 999, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, 335, 505)
--end

---- 设置角色数据
--function RankingListView:SetRoleData(protocol)
--	self.role_display:SetRoleVo(protocol.vo)
--	self.role_display:SetVisible(true)
--	self.role_display:SetScale(0.9)
--
--	XUI.AddClickEventListener(self.role_display_layout, BindTool.Bind(self.OnClickTipsHandler, self, protocol.vo))
--end

function RankingListView:OnClickTipsHandler(vo)
	local menu_list = {
		{menu_index = 0},
		{menu_index = 3},
		{menu_index = 4},
		{menu_index = 5},
		{menu_index = 6},
	}
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername ~= vo.name then
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, vo)
	end
end


--function RankingListView:OnShiLianListChange()
--	local rankinglist_data = RankingListData.Instance:GetRankingListData(3)
--	BrowseCtrl.Instance:BrowRoleInfo(rankinglist_data[1].role_name, 0, BindTool.Bind(self.SetRoleData, self))
--	self.role_name:setString(rankinglist_data[1].role_name)
--	XUI.EnableOutline(self.role_name) -- 描边
--end

----------排行榜列表----------
RankingListView.RankingRender = BaseClass(BaseRender)
local RankingRender = RankingListView.RankingRender
function RankingRender:__init()
	self.save_data = {}
	self.img_list = {}
end

function RankingRender:__delete()
end

function RankingRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.index <= 3 then
		self.img_bg = XUI.CreateImageView(45, 25, ResPath.GetRankingList("img_rankinglist_" .. self.index), true)
		self.view:addChild(self.img_bg, 100)
	end
end

function RankingRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.img9_stripes_1.node:setVisible(self.index % 2 == 1)
	self.node_tree.img9_stripes_2.node:setVisible(self.index % 2 == 0)
	
	--前三名的颜色
	if self.index == 1 then
		self.node_tree.lbl_rankinglistplayer_name.node:setColor(Str2C3b("df953e"))
		self.node_tree.txt_count.node:setColor(Str2C3b("df953e"))
		self.node_tree.text_guild.node:setColor(Str2C3b("df953e"))
	elseif self.index == 2 then
		self.node_tree.lbl_rankinglistplayer_name.node:setColor(Str2C3b("ed10e0"))
		self.node_tree.txt_count.node:setColor(Str2C3b("ed10e0"))
		self.node_tree.text_guild.node:setColor(Str2C3b("ed10e0"))
	elseif self.index == 3 then
		self.node_tree.lbl_rankinglistplayer_name.node:setColor(Str2C3b("34b7dd"))
		self.node_tree.txt_count.node:setColor(Str2C3b("34b7dd"))
		self.node_tree.text_guild.node:setColor(Str2C3b("34b7dd"))
	else
		self.node_tree.txt_ranking.node:setString(self.index)
	end	
	
	self.node_tree.lbl_rankinglistplayer_name.node:setString(self.data.role_name)
	if "" == self.data.society_name then
		self.node_tree.text_guild.node:setString(Language.RankingList.Wu)
	else
		self.node_tree.text_guild.node:setString(self.data.society_name)
	end

	XUI.AddClickEventListener(self.node_tree.lbl_rankinglistplayer_name.node, BindTool.Bind(self.OnClickTipsHandler, self))
	
	if self.data.no_data == 1 then
		self.node_tree.txt_count.node:setString("")
	end
	self.node_tree.text_guild.node:setVisible(true)
	local value = nil
	if self.data.rankinglist_type == 0 or self.data.rankinglist_type == 1 or self.data.rankinglist_type == 2 or self.data.rankinglist_type == 3 then
		value = self.data.ranking_value
		if nil ~= self.img_list[self.index] then
			self.img_list[self.index]:setVisible(false)
		end
	elseif self.data.rankinglist_type == 4 then	-- 威望
		if nil == self.img_list[self.index] then
			local cfg = PrestigeData.Instance:GetNowPrestigeByTotalValue(self.data.ranking_value)
			local index = cfg and cfg.index or 1
			local path = ResPath.GetPrestigeResPath("prestige_title_" .. index)
			self.img_list[self.index] = XUI.CreateImageView(283, 23, path, XUI.IS_PLIST)
			self.img_list[self.index]:setScale(0.88)
			self.view:addChild(self.img_list[self.index], 10)	
		else
			self.img_list[self.index]:setVisible(true)
		end
		self.node_tree.text_guild.node:setVisible(false)
	end
	if self.data.rankinglist_type == 2 then
		local show_level, show_grade = WingData.GetWingLevelAndGrade(value)
		local show_string = show_level .. "阶" .. show_grade .. "星"
		self.node_tree.txt_count.node:setString(show_string or "")
	else
		self.node_tree.txt_count.node:setString(value or "")
	end
end

function RankingRender:OnClickTipsHandler()
	local menu_list = {
		{menu_index = 0},
		{menu_index = 3},
		{menu_index = 4},
		{menu_index = 5},
		{menu_index = 6},
	}
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername ~= self.data.role_name and self.data.no_data ~= 1 then
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, self.data)
	end
end

----------试炼榜列表----------
RankingListView.ShilianRankingRender = BaseClass(BaseRender)
local ShilianRankingRender = RankingListView.ShilianRankingRender

function ShilianRankingRender:__init()
	self.save_data = {}
	self.img_list = {}
end

function ShilianRankingRender:__delete()	
end

function ShilianRankingRender:CreateChild()
	BaseRender.CreateChild(self)
	self.role_head = RoleHeadCell.New(false)
	self.role_head:SetPosition(57, 42)
	self.role_head:GetView():setScale(0.7)
	self.view:addChild(self.role_head:GetView(), 999)
	self:AddClickEventListener(BindTool.Bind(self.OnClickTipsHandler, self))
end

function ShilianRankingRender:OnFlush()
	if self.data == nil then return end
	self.node_tree["lbl_ranking"].node:setString(self.index + 1)
	self.node_tree["lbl_name"].node:setString(self.data.role_name)
	self.node_tree["lbl_current_level"].node:setString(self.data.ranking_value and self.data.ranking_value .. "关" or "")
	self.role_head:SetRoleInfo(self.data.role_id, self.data.role_name, self.data.role_profession, true, self.data.sex or 0)
end

function ShilianRankingRender:OnClickTipsHandler()
	local menu_list = {
		{menu_index = 0},
		{menu_index = 3},
		{menu_index = 4},
		{menu_index = 5},
		{menu_index = 6},
	}
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername ~= self.data.role_name and self.data.no_data ~= 1 then
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, self.data)
	end
end
