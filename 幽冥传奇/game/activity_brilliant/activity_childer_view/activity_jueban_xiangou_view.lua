OutOfPrintQuotaView = OutOfPrintQuotaView or BaseClass(ActBaseView)

function OutOfPrintQuotaView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function OutOfPrintQuotaView:__delete()
	-- if self.grid_node then
	--	self.grid_node:DeleteMe()
	--	self.grid_node = nil
	-- end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
end

function OutOfPrintQuotaView:InitView()
	self.node_t_list.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnClickBuyHandler, self))
	-- self.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind(self.OnClickLeftBackHandler, self))
	-- self.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind(self.OnClickRightBackHandler, self))
	-- --self:CreateGrid()
	self:CreateTabbar()

	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect_show
		self.effect_show1 = AnimateSprite:create()
		self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
		 self.node_t_list.layout_jueban_xiangou.node:addChild(self.effect_show1, 999)
	end

	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_jueban_xiangou.node, 100, false, false, true, true)
		local ph = self.ph_list.ph_effect_show
		self.role_display:SetPosition(ph.x + 10,ph.y + 100)
		self.role_display:SetScale(0.8)
	end
	
	self.index = 1
	self:CreateShowCell()
end

function OutOfPrintQuotaView:CreateGrid()
	-- if nil == self.grid_node then
	--	local col, row = 1, 1
	--	local ph = self.ph_list.ph_show_bg
	--	self.grid_node = BaseGrid.New()
	--	local grid_node = self.grid_node:CreateCells({w = ph.w, h = ph.h, itemRender = ActivityJBXGRender, cell_count = col*row,
	--		col = col, row = row, ui_config = self.ph_list.ph_show_bg})
	--	grid_node:setPosition(ph.x, ph.y)
	--	grid_node:setAnchorPoint(0.5, 0.5)
	--	self.grid_node:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	--	self.node_t_list.layout_jueban_xiangou.node:addChild(grid_node, 100)
	-- end
end


function OutOfPrintQuotaView:CreateTabbar()
	if  nil == self.tabbar then
		local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
		local config = cfg and cfg.config or {}
		local tabbar_list = {}
		for i,v in ipairs(config) do
			table.insert(tabbar_list, i)
		end

		self.tabbar = Tabbar.New()
		local ph = self.ph_list.ph_tabbar
		self.tabbar:CreateWithNameList(self.node_t_list.layout_jueban_xiangou.node, ph.x, ph.y, BindTool.Bind(self.TabSelectCellBack, self),
			tabbar_list, false, ResPath.GetActivityBrilliant("act_68"), 25, true)
	end
end

function OutOfPrintQuotaView:TabSelectCellBack(index)

	self.index = index
	self.sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	self.prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self:FlushShow()
end

function OutOfPrintQuotaView:CreateShowCell()
	self.cell_list = {}

	for i=1,5 do
		local ph = self.ph_list.ph_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 76*(i-1), ph.y)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_jueban_xiangou.node:addChild(cell:GetView(), 300)
		table.insert(self.cell_list, cell)
	end
	


	
	self.img_stamp = self.node_t_list.img_stmap.node
	-- self.img_stamp = XUI.CreateImageView(ph.x + 40, ph.y + 40, ResPath.GetCommon("stamp_5"))
	-- self.node_t_list.layout_jueban_xiangou.node:addChild(self.img_stamp, 500)
	self.img_stamp:setVisible(false)
end

local money_type = {
	[tagAwardType.qatBindMoney] = Language.Common.BindCoin,
	[tagAwardType.qatMoney] = Language.Common.Coin,
	[tagAwardType.qatBindYb] = Language.Common.BindGold,
	[tagAwardType.qatYuanbao] = Language.Common.Diamond,
}

function OutOfPrintQuotaView:OnPageChangeCallBack()
	-- if self.node_t_list.lbl_page and self.grid_node then
	--	local page_idx = self.grid_node:GetCurPageIndex()
	--	self.node_t_list.lbl_page.node:setString((page_idx or 1) .. "/" .. (self.grid_node:GetPageCount() or 1))
	--	local list = ActivityBrilliantData.Instance:GetGradeList()
	--	local buy_levels = self.act_data.config[page_idx].BuyLevels[list[page_idx].grade]
	--	self.img_stamp:setVisible(false)
	--	self.node_t_list.btn_buy.node:setEnabled(true)
	--	if nil == buy_levels then 
	--		self.node_t_list.btn_buy.node:setEnabled(false)
	--		self.img_stamp:setVisible(true)
	--		buy_levels = self.act_data.config[page_idx].BuyLevels[list[page_idx].grade - 1]
	--	end
	--	local item_id = buy_levels.award[1].id[self.sex + 1][self.prof]
	--	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	--	local str = string.format(Language.ActivityBrilliant.OutOfPrintDesFormat, buy_levels.money.count, money_type[buy_levels.money.type], string.format("%06x", item_cfg.color), item_cfg.name)
	--	self.cell:SetData({item_id = item_id, num = 1, is_bind = false})
	--	RichTextUtil.ParseRichText(self.node_t_list.rich_des.node, str, 18)
	-- end
end

function OutOfPrintQuotaView:FlushShow()
	if self.act_data and self.act_data.config then

		local list = ActivityBrilliantData.Instance:GetGradeList()
		local buy_levels = self.act_data.config[self.index].BuyLevels[list[self.index].grade]
		self.img_stamp:setVisible(false)
		self.node_t_list.btn_buy.node:setVisible(true)
		if nil == buy_levels then 
			self.node_t_list.btn_buy.node:setVisible(false)
			self.img_stamp:setVisible(true)
			buy_levels = self.act_data.config[self.index].BuyLevels[list[self.index].grade - 1]
		end
		local item_id = buy_levels.award[1].id[self.sex + 1][self.prof]
		local count = buy_levels.award[1].count
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local str = string.format(Language.ActivityBrilliant.OutOfPrintDesFormat, buy_levels.money.count, money_type[buy_levels.money.type], string.format("%06x", item_cfg.color), item_cfg.name)
		--self.cell:SetData({item_id = item_id, num = count, is_bind = false})

		for k, v in pairs(self.cell_list) do
			v:SetVisible(false)
		end

		for k, v in pairs(buy_levels.award) do
			if self.cell_list[k] then
				self.cell_list[k]:SetVisible(true)
				local cell = self.cell_list[k]
				local item_id = v.id[self.sex + 1][self.prof]
				local count = v.count
				cell:SetData({item_id = item_id, num = count, is_bind = v.bind})
			end
		end
		local ph = self.ph_list.ph_cell 
		local offest = (5 - #buy_levels.award) *76/2 
		for k, v in pairs(self.cell_list) do
			v:GetView():setPosition(ph.x + (k -1) * 76  + offest, ph.y)
		end

		RichTextUtil.ParseRichText(self.node_t_list.rich_des.node, str, 18)
		-- local effect_id = self.act_data.config[self.index].effect_id
		-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		-- self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)



		local effect_id = buy_levels.effect_id or 7
		local effect_type =  buy_levels.effect_type  or 1
		local role_data = buy_levels.role_model_effect  or {}
		self.role_display:SetVisible(false)
		self.effect_show1:setVisible(false)
		if effect_type == 1 then
			self.effect_show1:setVisible(true)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		else
			self.role_display:SetVisible(true)
			
			local info = {[OBJ_ATTR.ENTITY_MODEL_ID] = 0, [OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = 0,
				[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0,	[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
				[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
			local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
			local role_model_id = role_data.yifu_model[sex + 1]  or 0
			local weaponpos_id = role_data.wuqi_model  or 0 
			local wing_model = role_data.wing_model or 0
			local zhenqi_model = role_data.zhenqi_model or 0
			info[OBJ_ATTR.ENTITY_MODEL_ID] = role_model_id
			info[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]= weaponpos_id
			info[OBJ_ATTR.ACTOR_WING_APPEARANCE] = wing_model
			info[OBJ_ATTR.ACTOR_GENUINEQI_APPEARANCE] = zhenqi_model

			self.role_display:SetRoleVo(info)
			local ph = self.ph_list.ph_effect_show
			if weaponpos_id ~= 0 and role_model_id == 0 then
				self.role_display:SetPosition(ph.x + 150,ph.y - 2)
			else
				self.role_display:SetPosition(ph.x + 10,ph.y + 100)
			end 
		end


		local zs_lv = buy_levels.zslv
		local show_jieshu = math.ceil(zs_lv / ZsVipView.ENUM_JIE)
		if show_jieshu == 0 then
			show_jieshu = 1
		end

		local curr_e_lv = zs_lv % ZsVipView.ENUM_JIE
		if curr_e_lv == 0 and zs_lv > 0 then
			curr_e_lv = ZsVipView.ENUM_JIE
		end
		self.node_t_list.img_lv_68.node:loadTexture(ResPath.GetZsVip("txt_" .. show_jieshu))
		self.node_t_list.img_level_68.node:loadTexture(ResPath.GetZsVip("hz_" .. curr_e_lv))
	end
end

function OutOfPrintQuotaView:RefreshView(param_list)
	if nil == self.act_data then 
		self.act_data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JBXG)
		self.sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		self.prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	end
	if self.act_data and self.act_data.config then 
		local cfg = self.act_data.config
		self.node_t_list.img_act_des.node:loadTexture(ResPath.GetActivityBrilliant("act_68_des_"..cfg[1].des_id))
		self:FlushShow()
		local day =  math.ceil((self.act_data.end_time - self.act_data.beg_time)/ (24*3600))
		self.node_t_list.img_day_path.node:loadTexture(ResPath.GetActivityBrilliant("act_68_day_"..day))

	--	beg_time = 1577894401,	-- 活动开始时间(unix timestamp)
	-- end_time = 1578239999,	-- 活动结束时间(unix timestamp)

		-- local effect_list = {}
		-- for i,v in ipairs(cfg) do
		--	effect_list[i] = {}
		--	effect_list[i].effect_id = v.effect_id
		-- end
		-- if self.grid_node then 
		--	while self.grid_node:GetPageCount() > table.getn(effect_list) do
		--		self.grid_node:RemoveLastPage()		-- 多了删除
		--	end
		--	self.grid_node:ExtendGrid(table.getn(effect_list))	-- 少了扩展
		--	if not effect_list[0] and effect_list[1] then
		--		effect_list[0] = table.remove(effect_list, 1)
		--	end
		--	self.grid_node:SetDataList(effect_list)
		--	self:OnPageChangeCallBack()
		-- end
	end
end

-- function OutOfPrintQuotaView:OnClickRightBackHandler()
--	if self.grid_node then 
--		if self.grid_node:GetCurPageIndex() < self.grid_node:GetPageCount() then
--			self.grid_node:ChangeToPage(self.grid_node:GetCurPageIndex() + 1)
--		end
--	end
-- end

-- function OutOfPrintQuotaView:OnClickLeftBackHandler()
--	if self.grid_node then 
--		if self.grid_node:GetCurPageIndex() > 1 then
--			self.grid_node:ChangeToPage(self.grid_node:GetCurPageIndex() - 1)
--		end
--	end
-- end

function OutOfPrintQuotaView:OnClickBuyHandler()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.JBXG, self.index)
end


-- ActivityJBXGRender = ActivityJBXGRender or BaseClass(BaseRender)
-- function ActivityJBXGRender:__init()	
-- end

-- function ActivityJBXGRender:__delete()	
-- end

-- function ActivityJBXGRender:CreateChild()
--	BaseRender.CreateChild(self)
-- end

-- function ActivityJBXGRender:OnFlush()
--	if self.data == nil then return end
--	local effect_id = self.data.effect_id or 414
--	local act_effect = RenderUnit.CreateEffect(effect_id, self.view, 999)
--	-- act_effect:setPosition(ph.x, ph.y)
-- end

-- function ActivityJBXGRender:CreateSelectEffect()
-- end