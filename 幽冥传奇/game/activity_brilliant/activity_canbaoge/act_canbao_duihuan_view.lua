ActCanbaoDuihuanView = ActCanbaoDuihuanView or BaseClass(BaseView)

function ActCanbaoDuihuanView:__init()
	self:SetBackRenderTexture(true)
	
	self.texture_path_list[1] = 'res/xui/jifenequipment.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"canbao_duihuan_ui_cfg", 1, {0}},
		-- {"canbao_duihuan_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.def_index = 1
	self.tabbar = nil
	self.itemconfig_change_callback = BindTool.Bind1(self.ItemConfigChangeCallback, self)	  --监听Config
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化、
	self.jifen_data = {}
	self.sign_num = 0
end

function ActCanbaoDuihuanView:__delete()
end

function ActCanbaoDuihuanView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.exchange_item_list then
		self.exchange_item_list:DeleteMe()
		self.exchange_item_list = nil
	end

	if self.world_record_list then
		self.world_record_list:DeleteMe()
		self.world_record_list = nil
	end

	if self.mw_cell then
		self.mw_cell:DeleteMe()
		self.mw_cell = nil
	end

	if self.qz_cell then
		self.qz_cell:DeleteMe()
		self.qz_cell = nil
	end

	ViewManager.Instance:UnRegsiterTabFunUi(ViewDef.ActCanbaogeDuiHuan)
end

function ActCanbaoDuihuanView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		JiFenEquipmentCtrl.Instance:SendGetFullScaleAnnouncementInfReq()
		self:InitBar()
		self:CreateCellIcon()
		self:UpdateTextList()
		self:UpdateItemList()
		ViewManager.Instance:RegsiterTabFunUi(ViewDef.ActCanbaogeDuiHuan, self.tabbar)
	end
end

function ActCanbaoDuihuanView:CreateCellIcon()
	if nil == self.qz_cell then
		self.qz_cell = BaseCell.New()
		local ph = self.ph_list.ph_qz_cell
		self.qz_cell:SetPosition(ph.x, ph.y)
		self.qz_cell:SetIndex(i)
		self.qz_cell:SetAnchorPoint(0.5, 0.5)
		self.qz_cell:SetData({item_id = 3989, is_bind = 0})
		self.qz_cell:GetView():setScale(0.5)
		self.qz_cell:SetCellBg()
		self.node_t_list.layout_exchange.node:addChild(self.qz_cell:GetView(), 103)
	end	
	if nil == self.mw_cell then
		self.mw_cell = BaseCell.New()
		local ph = self.ph_list.ph_mw_cell
		self.mw_cell:SetPosition(ph.x, ph.y)
		self.mw_cell:SetIndex(i)
		self.mw_cell:SetAnchorPoint(0.5, 0.5)
		self.mw_cell:SetData({item_id = 3990, is_bind = 0})
		self.mw_cell:GetView():setScale(0.5)
		self.mw_cell:SetCellBg()
		self.node_t_list.layout_exchange.node:addChild(self.mw_cell:GetView(), 103)
	end	
end

function ActCanbaoDuihuanView:InitBar()
	if nil == self.tabbar then
		local ph = self.ph_list["ph_tabbar"]
		self.exchange_layout = self.node_t_list.layout_exchange
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y,
			function(index) self:ChangeToIndex(index) end, 
			Language.ActivityBrilliant.CanbaogeTabGroup, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end	
end

function ActCanbaoDuihuanView:OpenCallBack()
	ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	AudioManager.Instance:PlayOpenCloseUiEffect()

	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	if self.sign_num <= 0 then
		self.jifen_data = {}
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)	
		self.jifen_data[1] = {}
		for k,v in ipairs(cfg.config.curiositiesExchange) do
			local tab = v
			if tab.award[prof] and tab.award[prof][role_sex + 1] then
				table.insert(self.jifen_data[1], {item_id = tab.award[prof][role_sex + 1].id, num = tab.award[prof][role_sex + 1].count, is_bind = tab.award[prof][role_sex + 1].bind, score = tab.score,  index = 1, id = v.id})
				ItemData.Instance:GetItemConfig(v.award[prof][role_sex + 1].id)
			else
				table.insert(self.jifen_data[1], {item_id = tab.award[1][1].id, num = tab.award[1][1].count, is_bind = tab.award[1][1].bind, score = tab.score,  index = 1, id = v.id})
				ItemData.Instance:GetItemConfig(v.award[1][1].id)
			end
		end

		self.jifen_data[2] = {}
		for k,v in ipairs(cfg.config.secretExchange) do
			local tab = v
			if tab.award[prof] and tab.award[prof][role_sex + 1] then
				table.insert(self.jifen_data[2], {item_id = tab.award[prof][role_sex + 1].id, num = tab.award[prof][role_sex + 1].count, is_bind = tab.award[prof][role_sex + 1].bind, score = tab.score,  index = 2, id = v.id})
				ItemData.Instance:GetItemConfig(v.award[prof][role_sex + 1].id)
			else
				table.insert(self.jifen_data[2], {item_id = tab.award[1][1].id, num = tab.award[1][1].count, is_bind = tab.award[1][1].bind, score = tab.score,  index = 2, id = v.id})
				ItemData.Instance:GetItemConfig(v.award[1][1].id)
			end
		end
	end
end

function ActCanbaoDuihuanView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActCanbaoDuihuanView:CloseCallBack(is_all)
	ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.tabbar:SelectIndex(1)
end

function ActCanbaoDuihuanView:ItemDataChangeCallback()
	self:Flush()
end

function ActCanbaoDuihuanView:ItemConfigChangeCallback()
	self:Flush()
end

function ActCanbaoDuihuanView:OnFlush(param_t, index)
	local tab = ExploreData.Instance:GetXunBaoData()
	-- local xunbao_jifen = tab.current_treasure_jifen
	-- self.node_t_list.txt_count.node:setString(xunbao_jifen)
	local data = ActivityBrilliantData.Instance:GetCanbaogeData()
	self.node_t_list.layout_exchange.lbl_qz_num.node:setString(data.qz_sorce)
	self.node_t_list.layout_exchange.lbl_mw_num.node:setString(data.mw_sorce)
	self:FlushList()
	self:FlushTextList()
end

function ActCanbaoDuihuanView:UpdateItemList()
	if nil == self.exchange_item_list then
		local ph = self.ph_list.ph_item_list
		self.exchange_item_list = ListView.New()
		self.exchange_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActExchangeItemRender, nil, nil, self.ph_list.ph_list_item)
		self.exchange_item_list:GetView():setAnchorPoint(0, 0)
		self.exchange_item_list:SetItemsInterval(5)
		self.exchange_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_exchange.node:addChild(self.exchange_item_list:GetView(), 100)
	end
end

function ActCanbaoDuihuanView:FlushList()
	local current_index = self:GetShowIndex()
	self.exchange_item_list:SetDataList(self.jifen_data[current_index])
end

function ActCanbaoDuihuanView:UpdateTextList()
	if nil == self.world_record_list then
		local ph = self.ph_list.ph_txt_item_list
		self.world_record_list = ListView.New()
		self.world_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActCanbaogeWorldRender, nil, nil, self.ph_list.ph_my_record)
		self.world_record_list:GetView():setAnchorPoint(0, 0)
		self.world_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_exchange.node:addChild(self.world_record_list:GetView(), 100)
	end	
end

function ActCanbaoDuihuanView:FlushTextList()
	local exchange_record = ActivityBrilliantData.Instance:GetExchangeRecordList()
	self.world_record_list:SetDataList(exchange_record or {})
end

ActExchangeItemRender = ActExchangeItemRender or BaseClass(BaseRender)
function ActExchangeItemRender:__init()
end

function ActExchangeItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end	

	if self.icon_cell then
		self.icon_cell:DeleteMe()
		self.icon_cell = nil
	end
end

function ActExchangeItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.cell then
		local ph = self.ph_list["ph_item"]
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x,ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
	end	
	self.node_tree.btn_item_duihuan.node:addClickEventListener(BindTool.Bind1(self.OnClickExchangeHandler, self))

	self.node_tree.rich_person_num.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.node_tree.rich_qf_num.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)

	self:CreateCellIcon()
end

function ActExchangeItemRender:CreateCellIcon()
	if nil == self.icon_cell then
		self.icon_cell = BaseCell.New()
		local ph = self.ph_list.ph_cell
		self.icon_cell:SetPosition(ph.x, ph.y)
		self.icon_cell:SetIndex(i)
		self.icon_cell:SetAnchorPoint(0.5, 0.5)
		self.icon_cell:GetView():setScale(0.5)
		self.icon_cell:SetCellBg()
		self.view:addChild(self.icon_cell:GetView(), 103)
	end	
end

function ActExchangeItemRender:OnClickExchangeHandler()
	local tag = self.data.index == 1 and 4 or 5 --4为奇珍，5为秘闻
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.CBG, self:GetIndex(), tag)
end

function ActExchangeItemRender:OnFlush()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CBG)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg or nil == cfg then return end
	self.node_tree.txt_name.node:setString(item_cfg.name)

	RichTextUtil.ParseRichText(self.node_tree.rich_person_num.node, "", 18)
	RichTextUtil.ParseRichText(self.node_tree.rich_qf_num.node, "", 18)

	--兑换所得显示
	local data = {item_id = self.data.item_id, num = 1, is_bind = self.data.is_bind}
	self.cell:SetData(data)

	--根据类型 显示
	local canbaoge_data = ActivityBrilliantData.Instance:GetCanbaogeData()
	local exc_cfg
	local qf_sign_list, mine_sign_list
	if self.data.index == 1 then
		if canbaoge_data.qz_sorce >= self.data.score then 
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, true)
		else 
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, false)
		end	
		exc_cfg = cfg.config.curiositiesExchange
		qf_sign_list = canbaoge_data.qz_qf_lingqu_num_list
		mine_sign_list = canbaoge_data.qz_mine_lingqu_num_list

		self.icon_cell:SetData({item_id = 3898, is_bind = 0})
	elseif self.data.index == 2 then
		if canbaoge_data.mw_sorce >= self.data.score then
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, true)
		else
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, false)
		end 
		exc_cfg = cfg.config.secretExchange
		qf_sign_list = canbaoge_data.mw_qf_lingqu_num_list
		mine_sign_list = canbaoge_data.mw_mine_lingqu_num_list

		self.icon_cell:SetData({item_id = 3990, is_bind = 0})
	end	
	-- self.node_tree.txt_desc.node:setString(Language.ActivityBrilliant.ExchangeTextGroup[self.data.index] .. self.data.score)
	self.node_tree.txt_desc.node:setString(self.data.score)

	--限兑提示
	if exc_cfg[self:GetIndex()].personLimit > 0 then
		local color = mine_sign_list[self:GetIndex()] >= exc_cfg[self:GetIndex()].personLimit and "DC143C" or "1eff00"
		local txt_1 = Language.ActivityBrilliant.ExcTip2 .. string.format(Language.ActivityBrilliant.NumTip, color, mine_sign_list[self:GetIndex()], exc_cfg[self:GetIndex()].personLimit)
		RichTextUtil.ParseRichText(self.node_tree.rich_person_num.node, txt_1, 18)
	end
	if exc_cfg[self:GetIndex()].systemLimit > 0 then
		local color = qf_sign_list[self:GetIndex()] >= exc_cfg[self:GetIndex()].systemLimit and "DC143C" or "1eff00"
		local txt_2 = Language.ActivityBrilliant.ExcTip .. string.format(Language.ActivityBrilliant.NumTip, color, qf_sign_list[self:GetIndex()], exc_cfg[self:GetIndex()].systemLimit)
		RichTextUtil.ParseRichText(self.node_tree.rich_qf_num.node, txt_2, 18)
	end
end

ActCanbaogeWorldRender = ActCanbaogeWorldRender or BaseClass(BaseRender)
function ActCanbaogeWorldRender:__init()
	self.view:setContentWH(430, 30)
end

function ActCanbaogeWorldRender:__delete()	
end

function ActCanbaogeWorldRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ActCanbaogeWorldRender:OnFlush()
	if self.data == nil then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.index)
	if nil == item_cfg then 
		return 
	end
	local  color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local text = string.format(Language.ActivityBrilliant.ActRecordStr, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.ActivityBrilliant.Text25, color, item_cfg.name, self.data.index)
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node, text, 18)
end

function ActCanbaogeWorldRender:CreateSelectEffect() 
end