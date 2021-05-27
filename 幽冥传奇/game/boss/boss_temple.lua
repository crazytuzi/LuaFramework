-- BossTemple = BossTemple or BaseClass(XuiBaseView)
-- function BossTemple:__init()
	
-- end	

-- function BossTemple:__delete()
-- 	self:RemoveEvent()
-- 	if nil ~= self.monster_display then
-- 		self.monster_display:DeleteMe()
-- 		self.monster_display = nil
-- 	end
-- 	if self.boss_temple_cell ~= nil then
-- 		for k, v in pairs(self.boss_temple_cell) do
-- 			v:DeleteMe()
-- 		end
-- 		self.boss_temple_cell = {}
-- 	end
-- 	if nil ~= self.temple_boss_list then
-- 		self.temple_boss_list:DeleteMe()
-- 		self.temple_boss_list = nil 
-- 	end
-- 	if self.number_rade_wild ~= nil then
-- 		self.number_rade_wild:DeleteMe()
-- 		self.number_rade_wild = nil
-- 	end
-- 	self.view = nil
-- end	

-- --初始化页面接口
-- function BossTemple:InitPage(view)
-- 	--绑定要操作的元素
-- 	self.view = view
-- 	self.select_index = 1
-- 	self.remian_time = 0
-- 	ph = self.view.ph_list.ph_page12_model
-- 	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page12.node, GameMath.MDirDown)
-- 	self.monster_display:SetAnimPosition(ph.x,ph.y)
-- 	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
-- 	self.monster_display:SetZOrder(30)
-- 	self:InitWindTabber()
-- 	self:CreareCell()
-- 	self:InitEvent()
	
-- end	

-- --初始化事件
-- function BossTemple:InitEvent()
-- 	XUI.AddClickEventListener(self.view.node_t_list["btn_map_temple"].node, BindTool.Bind2(self.OnTansmitBossMap, self))
-- 	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_5"].node, BindTool.Bind2(self.OnTansmitBossMap, self, 2))
-- 	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_6"].node, BindTool.Bind2(self.OnTansmitBossMap, self, 3))
-- 	self.view.node_t_list["btn_map_5"].node:setVisible(false)
-- 	self.view.node_t_list["btn_map_6"].node:setVisible(false)
-- 	self.view.node_t_list["txt_refresh_time_1"].node:setVisible(false)
-- 	self.number_rade_wild = self:CreateUINum(280, 204, 30, 29)
-- 	self.view.node_t_list.page12.node:addChild(self.number_rade_wild:GetView(),999)
-- 	-- self.view.node_t_list.page12.txt_desc.node:setVisible(false)
-- 	-- self.view.node_t_list.page12.txt_desc.node:setString(Language.Boss.BossDesc)
-- end

-- function BossTemple:InitWindTabber()
-- 	if self.temple_boss_list == nil then
-- 		local ph = self.view.ph_list.ph_temple_boss_list
-- 		self.temple_boss_list  = ListView.New()
-- 		self.temple_boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossTempleRender, nil, nil, self.view.ph_list.ph_page12_scroll_item)
-- 		self.temple_boss_list:SetItemsInterval(10)
		
-- 		self.temple_boss_list:SetJumpDirection(ListView.Top)
-- 		self.temple_boss_list:SetSelectCallBack(BindTool.Bind(self.SelectTabBossCallback, self))
-- 		self.view.node_t_list.page12.node:addChild(self.temple_boss_list:GetView(), 20)
-- 	end
-- end

-- function BossTemple:SelectTabBossCallback(item, index)
-- 	if item == nil or item:GetData() == nil then return end
-- 	self.select_index = item:GetIndex()
-- 	self:FlushView(index)
-- end

-- function BossTemple:CreareCell()
-- 	self.boss_temple_cell = {}
-- 	for i = 1, 6 do
-- 		local ph = self.view.ph_list.ph_cell_temple
-- 		local cell = BaseCell.New()
-- 		cell:SetPosition(ph.x + 120*(i-1), ph.y)
-- 		self.view.node_t_list["page12"].node:addChild(cell:GetView(), 103)
-- 		table.insert(self.boss_temple_cell, cell)
-- 	end	
-- end

-- --移除事件
-- function BossTemple:RemoveEvent()

-- end

-- --更新视图界面
-- function BossTemple:UpdateData(data)
-- 	self:FlushView(select_index)
-- 	local name = BossData.Instance:GetTempBossCfgName()
-- 	self.temple_boss_list:SetDataList(name)
-- 	self.temple_boss_list:SelectIndex(1)
-- end	

-- function BossTemple:FlushView(select_index)
-- 	local index = select_index or 1
-- 	local name_list = BossData.Instance:GetTempBossCfgName()
-- 	local data = BossData.Instance:GetTempleCfg()
-- 	-- local scene_list = BossData.Instance:GetTempleBossSCeneName()
-- 	self.view.node_t_list["boss_nameText"].node:setString(name_list[index])
-- 	local scene_name = BossData.Instance:GetSceneCfg(MayaPalaceConfig[1].sceneId)
-- 	self.view.node_t_list.page12.btn_map_temple.node:setTitleText(scene_name)
-- 	-- self.view.node_t_list["btn_map_temple"].node:setTitleText(scene_list[index])
-- 	local rew_data = MayaPalaceConfig[1].enterConsume[1]
-- 	local config = ItemData.Instance:GetItemConfig(rew_data.id)
-- 	if config == nil then return end
-- 	self.view.node_t_list.page12.txt_desc.node:setString("消耗" .. config.name .. " X " .. rew_data.count)
-- 	-- local time = TimeUtil.FormatSecond2Str(data[index].time, 2)
-- 	-- -- self.view.node_t_list["txt_refresh_time_1"].node:setString(Language.Boss.JianGe.." "..time)
-- 	local temple_boss_id = data[1][index].boss_id
-- 	local cfg = BossData.GetMosterCfg(temple_boss_id)
-- 	if cfg ~= nil then
-- 		self.monster_display:Show(cfg.modelid)
-- 		self.number_rade_wild:SetNumber(cfg.level)
-- 	end
-- 	local reward_data = BossDropShowConfig[temple_boss_id]
-- 	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
-- 	for k,v in pairs(self.boss_temple_cell) do
-- 		v:GetView():setVisible(false)
-- 	end
-- 	local cur_data = {}
-- 	for k,v in pairs(reward_data) do
-- 		if v.job == prof then
-- 			table.insert(cur_data, v)
-- 		end
-- 	end
-- 	for i, v in ipairs(cur_data) do
-- 		if self.boss_temple_cell[i] ~= nil then
-- 			self.boss_temple_cell[i]:GetView():setVisible(true)
-- 			if v.id == 0 then
-- 				local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
-- 				if virtual_item_id then
-- 					self.boss_temple_cell[i]:SetData{["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
-- 				end
-- 			else
-- 				self.boss_temple_cell[i]:SetData{item_id = v.id, num = v.count, is_bind = 0}
-- 			end
-- 		end
-- 	end
-- 	-- local is_can_kill = BossData.Instance:GetCanKillBoss()
-- 	-- XUI.SetButtonEnabled(self.view.node_t_list["btn_map_temple"].node, false)
-- 	-- for k, v in pairs(is_can_kill) do
-- 	-- 	if v.boss_id == temple_boss_id then
-- 	-- 		XUI.SetButtonEnabled(self.view.node_t_list["btn_map_temple"].node, true)
-- 	-- 	end
-- 	-- end
-- end

-- function BossTemple:OnTansmitBossMap()
-- 	local data = BossData.Instance:GetTempleCfg()
-- 	local index = select_index or 1
-- 	if data[1][index].pos ~= nil then 
-- 		BossCtrl.Instance:SendEnterMaYaTempleReq(data[1][index].pos)
-- 	end
-- end

-- function BossTemple:CreateUINum(x, y, w, h )
-- 	local number_bar = NumberBar.New()
-- 	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
-- 	number_bar:SetPosition(x, y)
-- 	number_bar:SetContentSize(w, h)
-- 	number_bar:SetSpace(-2)
-- 	return number_bar
-- end

-- BossTempleRender = BossTempleRender or BaseClass(BaseRender)
-- function BossTempleRender:__init()

-- end

-- function BossTempleRender:__delete()	
-- end

-- function BossTempleRender:OnFlush()
-- 	if self.cache_select and self.is_select then
-- 		self.cache_select = false
-- 		self:CreateSelectEffect()
-- 	end
-- 	if self.data == nil then return end
-- 	self.node_tree.lbl_boss_name.node:setString(self.data)
-- 	if self.cache_select and self.is_select then
-- 		self.cache_select = false
-- 		self:CreateSelectEffect()
-- 	end
	
-- end

-- function BossTempleRender:CreateSelectEffect()
-- 	if nil == self.node_tree.img_bg then
-- 		self.cache_select = true
-- 		return
-- 	end
-- 	local size =self.node_tree.img_bg.node:getContentSize()
-- 	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width,size.height,ResPath.GetCommon("btn_106_select"), true , cc.rect(37,19,73,22))
-- 	if nil == self.select_effect then
-- 		ErrorLog("BaseRender:CreateSelectEffect fail")
-- 		return
-- 	end
-- 	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
-- end
BossTemple = BossTemple or BaseClass()


function BossTemple:__init()
	
end	

function BossTemple:__delete()
	self:RemoveEvent()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
	if nil ~= self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil
	end
	if self.boss_cell ~= nil then
		for k, v in pairs(self.boss_cell) do
			v:DeleteMe()
		end
		self.boss_cell = {}
	end
	
	if self.number_rade_home ~= nil then
		self.number_rade_home:DeleteMe()
		self.number_rade_home = nil
	end
	
	self.view = nil
end	

--初始化页面接口
function BossTemple:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.select_index = 1
	self.btn_index = 1
	ph = self.view.ph_list.ph_page10_model
	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page10.node, GameMath.MDirDown)
	self.monster_display:SetAnimPosition(ph.x,ph.y)
	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
	self.monster_display:SetZOrder(4)
	self:CreateBtnBoss()
	self:CreareCell()
	self:InitEvent()
end	

function BossTemple:CreateBtnBoss()
	if nil == self.tabbar then
		local size = self.view.node_t_list.scroll_tabbar.node:getContentSize()
		self.tabbar = Accordion.New()
		self.tabbar:SetItemsInterval(12)
		self.tabbar:Create(self.view.node_t_list.scroll_tabbar.node, 0, -3, size.width, size.height, AccordionBossRender, 1, 1)
		self.tabbar:SetTreeItemSelectCallBack(BindTool.Bind(self.SelectTreeNodeCallback, self))
		self.tabbar:SetSelectCallBack(BindTool.Bind(self.SelectChildCallback, self))
		self.tabbar:SetExpandCallBack(BindTool.Bind(self.TreeExpandCallback, self))
		self.tabbar:SetUnExpandCallBack(BindTool.Bind(self.TreeUnExpandCallback, self))
		self.tabbar:SetChildrenInterval(2)
	end
end

function BossTemple:SelectTreeNodeCallback(item)
	if not item or not item:GetData() then return end
	self.btn_index = item:GetData().index
	self.tabbar:SetCurSelectChildIndex(1)
	self:FlushView()
end

function BossTemple:SelectChildCallback(item)
	if not item or not item:GetData() then return end
	self.select_data = item:GetData()
	self.select_index = item:GetData().index
	self:FlushView()
end

function BossTemple:TreeExpandCallback(item)
	if nil == item or nil == item:GetData() then return end
	item:OnSelectChange(true)
end

function BossTemple:TreeUnExpandCallback(item)
	if nil == item or nil == item:GetData() then return end
	item:OnSelectChange(false)
end


--初始化事件
function BossTemple:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list["btn_temple_map"].node, BindTool.Bind2(self.OnBossHomeTansmitBossMap, self))
	self.number_rade_home = self:CreateUINum(280, 202, 30, 29)
	self.view.node_t_list.page10.node:addChild(self.number_rade_home:GetView(),999)
	self.view.node_t_list["nameText_temple"].node:setLocalZOrder(998)
end

function BossTemple:CreareCell()
	self.boss_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list.ph_cell_wild
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 120*(i-1), ph.y)
		self.view.node_t_list["page10"].node:addChild(cell:GetView(), 103)
		table.insert(self.boss_cell, cell)
	end	
end


--移除事件
function BossTemple:RemoveEvent()

end

--更新视图界面
function BossTemple:UpdateData(data)
	local data = BossData.Instance:GetTempleBossData()
	self.tabbar:SetData(data)
	self.tabbar:SetSelectChildIndex(self.select_index, self.btn_index, true)
end	

function BossTemple:FlushView()
	if self.select_data ~= nil then
		local cfg = BossData.GetMosterCfg(self.select_data.boss_id)
		if cfg ~= nil then
			self.monster_display:Show(cfg.modelid)
			self.number_rade_home:SetNumber(cfg.level)
			local name = DelNumByString(self.select_data.name)
			self.view.node_t_list["nameText_temple"].node:setString(name)
		end
		local reward_data = BossData.Instance:GetRewardByBossId(self.select_data.boss_id)
		for k,v in pairs(self.boss_cell) do
			v:GetView():setVisible(false)
		end
		for k,v in pairs(reward_data) do
			if self.boss_cell[k] ~= nil then
				self.boss_cell[k]:GetView():setVisible(true)
				self.boss_cell[k]:SetData({item_id = v.id, num = v.count, is_bind = 0})
			end
		end
		local name = BossData.Instance:GetSceneCfg(self.select_data.scene_id)
		self.view.node_t_list["btn_temple_map"].node:setTitleText(name)
		local consume_count = self.select_data.enterConsume.count
		local consume_config = ItemData.Instance:GetItemConfig(self.select_data.enterConsume.id)
		local num = ItemData.Instance:GetItemNumInBagById(self.select_data.enterConsume.id)
		local color = "ff0000"
		if num >= consume_count then
			color = "00ff00"
		end
		if consume_config == nil then return end
		local name = consume_config.name
		local txt = string.format(Language.Boss.Consume, color, name, consume_count)
		-- self.view.node_t_list.txt_consume.node:removeAllElements()
		RichTextUtil.ParseRichText(self.view.node_t_list.page10.txt_consume.node, txt, 22)
		local txt_lv = ""
		if self.select_data.enterLevelLimit[1] == 0 then
			txt_lv = string.format(Language.Boss.MaYaDescConsume, self.select_data.enterLevelLimit[2])
		else
			txt_lv = string.format(Language.Boss.MaYaDescCircle, self.select_data.enterLevelLimit[1])
		end
		self.view.node_t_list.page10.txt_consume_lv.node:setString(txt_lv)
	end
end

function BossTemple:OnBossHomeTansmitBossMap()
	if self.select_data ~= nil then
		BossCtrl.Instance:SendEnterMaYaTempleReq(self.select_data.boss_pos)
	end
end

function BossTemple:CreateUINum(x, y, w, h )
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

AccordionBossRender = AccordionBossRender or BaseClass(AccordionItemRender)
function AccordionBossRender:__init(w, h, parent_node)
	self.width = parent_node and w - 16 or w
	self.height = 54
	self.img_normal = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_normal"), true)
	self.img_select = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_select"), true)
	self.img_select:setVisible(false)
	self.view:addChild(self.img_normal)
	self.view:addChild(self.img_select)

	self.txt_title = XUI.CreateText(self.width / 2, self.height / 2, w, h, h_alignment, "", font, font_size, COLOR3B.OLIVE, v_alignment)
	self.view:addChild(self.txt_title, 1, 1)
	if nil == self.img_expland then
		self.img_expland = XUI.CreateImageView(20, self.height / 2, ResPath.GetCommon("btn_down_3"))
		self.view:addChild(self.img_expland, 99)
	end
	if self:IsChild() then
		-- self.img_child_normal = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("img9_158"), true, cc.rect(13,16,12,7))
		-- self.view:addChild(self.img_child_normal)
		-- self.img_child_normal:setVisible(false)
	end
end

function AccordionBossRender:__delete()
	self.has_changed_img = nil
end

function AccordionBossRender:CreateChild()
	BaseRender.CreateChild(self)
	self.view:setContentWH(self.width, self.height)
	if self:IsChild() then
		self.img_expland:setVisible(false)
	end
end

-- 刷新
function AccordionBossRender:OnFlush()
	if not self.data then return end
	self.change_to_index = self.data.index
	if not self.data or not self.data.name then return end
	local str = DelNumByString(self.data.name)

	self.txt_title:setString(str)
	if self.data.child ~= nil then
	end

	if self:IsChild() then
		if self.has_changed_img == nil then
			self.has_changed_img = true
			-- self.img_normal:setVisible(false)
			-- self.img_child_normal:setVisible(true)
			self.img_normal:loadTexture(ResPath.GetCommon("img9_158"))
		end

	end

end

-- 选择状态改变
function AccordionBossRender:OnSelectChange(is_select)
	if self.img_expland ~= nil then
		local path = ResPath.GetCommon("btn_down_3")
		if is_select then
			path = ResPath.GetCommon("btn_down_4")
		end
		self.img_expland:loadTexture(path)
	end
end

function AccordionBossRender:CreateSelectEffect()
	if self:IsChild() then
		local height = self:GetHeight()
		self.select_effect = XUI.CreateImageViewScale9(self.width / 2, height / 2, self.width + 15, height + 15, ResPath.GetCommon("select_effect_1"), true, cc.rect(18, 21, 9, 7))
		self.view:addChild(self.select_effect, 200, 200)
	end
end