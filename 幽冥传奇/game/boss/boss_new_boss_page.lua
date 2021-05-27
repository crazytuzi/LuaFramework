-- BossHomePage = BossHomePage or BaseClass()


-- function BossHomePage:__init()
	
-- end	

-- function BossHomePage:__delete()
-- 	self:RemoveEvent()
-- 	if nil ~= self.tabbar then
-- 		self.tabbar:DeleteMe()
-- 		self.tabbar = nil 
-- 	end
-- 	if nil ~= self.monster_display then
-- 		self.monster_display:DeleteMe()
-- 		self.monster_display = nil
-- 	end
-- 	if self.boss_cell ~= nil then
-- 		for k, v in pairs(self.boss_cell) do
-- 			v:DeleteMe()
-- 		end
-- 		self.boss_cell = {}
-- 	end
	
-- 	if self.number_rade_home ~= nil then
-- 		self.number_rade_home:DeleteMe()
-- 		self.number_rade_home = nil
-- 	end
	
-- 	self.view = nil
-- end	

-- --初始化页面接口
-- function BossHomePage:InitPage(view)
-- 	--绑定要操作的元素
-- 	self.view = view
-- 	self.select_index = 1
-- 	self.btn_index = 1
-- 	ph = self.view.ph_list.ph_page10_model
-- 	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page10.node, GameMath.MDirDown)
-- 	self.monster_display:SetAnimPosition(ph.x,ph.y)
-- 	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
-- 	self.monster_display:SetZOrder(30)
-- 	self:CreateBtnBoss()
-- 	self:CreareCell()
-- 	self:InitEvent()
-- end	

-- function BossHomePage:CreateBtnBoss()
-- 	if nil == self.tabbar then
-- 		local size = self.view.node_t_list.scroll_tabbar.node:getContentSize()
-- 		self.tabbar = Accordion.New()
-- 		self.tabbar:SetItemsInterval(12)
-- 		self.tabbar:Create(self.view.node_t_list.scroll_tabbar.node, 0, -3, size.width, size.height, AccordionBossRender, 1, 1)
-- 		self.tabbar:SetTreeItemSelectCallBack(BindTool.Bind(self.SelectTreeNodeCallback, self))
-- 		self.tabbar:SetSelectCallBack(BindTool.Bind(self.SelectChildCallback, self))
-- 		self.tabbar:SetExpandCallBack(BindTool.Bind(self.TreeExpandCallback, self))
-- 		self.tabbar:SetUnExpandCallBack(BindTool.Bind(self.TreeUnExpandCallback, self))
-- 		self.tabbar:SetChildrenInterval(2)
-- 	end
-- end

-- function BossHomePage:SelectTreeNodeCallback(item)
-- 	if not item or not item:GetData() then return end
-- 	self.btn_index = item:GetData().index
-- 	self.tabbar:SetCurSelectChildIndex(1)
-- 	self:FlushView()
-- end

-- function BossHomePage:SelectChildCallback(item)
-- 	if not item or not item:GetData() then return end
-- 	self.select_data = item:GetData()
-- 	self.select_index = item:GetData().index
-- 	self:FlushView()
-- end

-- function BossHomePage:TreeExpandCallback(item)
-- 	if nil == item or nil == item:GetData() then return end
-- 	item:OnSelectChange(true)
-- end

-- function BossHomePage:TreeUnExpandCallback(item)
-- 	if nil == item or nil == item:GetData() then return end
-- 	item:OnSelectChange(false)
-- end


-- --初始化事件
-- function BossHomePage:InitEvent()
-- 	XUI.AddClickEventListener(self.view.node_t_list["btn_map_4"].node, BindTool.Bind2(self.OnBossHomeTansmitBossMap, self))
-- 	self.number_rade_home = self:CreateUINum(280, 202, 30, 29)
-- 	self.view.node_t_list.page10.node:addChild(self.number_rade_home:GetView(),999)
-- 	self.view.node_t_list["nameText_1"].node:setLocalZOrder(998)
-- end

-- function BossHomePage:CreareCell()
-- 	self.boss_cell = {}
-- 	for i = 1, 6 do
-- 		local ph = self.view.ph_list.ph_cell_wild
-- 		local cell = BaseCell.New()
-- 		cell:SetPosition(ph.x + 120*(i-1), ph.y)
-- 		self.view.node_t_list["page10"].node:addChild(cell:GetView(), 103)
-- 		table.insert(self.boss_cell, cell)
-- 	end	
-- end


-- --移除事件
-- function BossHomePage:RemoveEvent()

-- end

-- --更新视图界面
-- function BossHomePage:UpdateData(data)
-- 	local data = BossData.Instance:GetBossHomeData()
-- 	self.tabbar:SetData(data)
-- 	self.tabbar:SetSelectChildIndex(self.select_index, self.btn_index, true)
-- end	

-- function BossHomePage:FlushView()
-- 	if self.select_data ~= nil then
-- 		local cfg = BossData.GetMosterCfg(self.select_data.boss_id)
-- 		if cfg ~= nil then
-- 			self.monster_display:Show(cfg.modelid)
-- 			self.number_rade_home:SetNumber(cfg.level)
-- 			local name = DelNumByString(self.select_data.name)
-- 			self.view.node_t_list["nameText_1"].node:setString(name)
-- 		end
-- 		local reward_data = BossData.Instance:GetRewardByBossId(self.select_data.boss_id)
-- 		for k,v in pairs(self.boss_cell) do
-- 			v:GetView():setVisible(false)
-- 		end
-- 		for k,v in pairs(reward_data) do
-- 			if self.boss_cell[k] ~= nil then
-- 				self.boss_cell[k]:GetView():setVisible(true)
-- 				self.boss_cell[k]:SetData({item_id = v.id, num = v.count, is_bind = 0})
-- 			end
-- 		end
-- 		local name = BossData.Instance:GetSceneCfg(self.select_data.scene_id)
-- 		self.view.node_t_list["btn_map_4"].node:setTitleText(name)
-- 	end
-- end

-- function BossHomePage:OnBossHomeTansmitBossMap()
-- 	if self.select_data ~= nil then
-- 		BossCtrl.Instance:SendEnterSceneReq(self.select_data.boss_id, 0)
-- 	end
-- end

-- function BossHomePage:CreateUINum(x, y, w, h )
-- 	local number_bar = NumberBar.New()
-- 	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
-- 	number_bar:SetPosition(x, y)
-- 	number_bar:SetContentSize(w, h)
-- 	number_bar:SetSpace(-2)
-- 	return number_bar
-- end

-- AccordionBossRender = AccordionBossRender or BaseClass(AccordionItemRender)
-- function AccordionBossRender:__init(w, h, parent_node)
-- 	self.width = parent_node and w - 16 or w
-- 	self.height = 54
-- 	self.img_normal = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_normal"), true)
-- 	self.img_select = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_select"), true)
-- 	self.img_select:setVisible(false)
-- 	self.view:addChild(self.img_normal)
-- 	self.view:addChild(self.img_select)

-- 	self.txt_title = XUI.CreateText(self.width / 2, self.height / 2, w, h, h_alignment, "", font, font_size, COLOR3B.OLIVE, v_alignment)
-- 	self.view:addChild(self.txt_title, 1, 1)
-- 	if nil == self.img_expland then
-- 		self.img_expland = XUI.CreateImageView(20, self.height / 2, ResPath.GetCommon("btn_down_3"))
-- 		self.view:addChild(self.img_expland, 99)
-- 	end
-- 	if self:IsChild() then
-- 		-- self.img_child_normal = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("img9_158"), true, cc.rect(13,16,12,7))
-- 		-- self.view:addChild(self.img_child_normal)
-- 		-- self.img_child_normal:setVisible(false)
-- 	end
-- end

-- function AccordionBossRender:__delete()
-- 	self.has_changed_img = nil
-- end

-- function AccordionBossRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	self.view:setContentWH(self.width, self.height)
-- 	if self:IsChild() then
-- 		self.img_expland:setVisible(false)
-- 	end
-- end

-- -- 刷新
-- function AccordionBossRender:OnFlush()
-- 	if not self.data then return end
-- 	self.change_to_index = self.data.index
-- 	local str = DelNumByString(self.data.name)

-- 	self.txt_title:setString(str)
-- 	if self.data.child ~= nil then
-- 	end

-- 	if self:IsChild() then
-- 		if self.has_changed_img == nil then
-- 			self.has_changed_img = true
-- 			-- self.img_normal:setVisible(false)
-- 			-- self.img_child_normal:setVisible(true)
-- 			self.img_normal:loadTexture(ResPath.GetCommon("img9_158"))
-- 		end

-- 	end

-- end

-- -- 选择状态改变
-- function AccordionBossRender:OnSelectChange(is_select)
-- 	if self.img_expland ~= nil then
-- 		local path = ResPath.GetCommon("btn_down_3")
-- 		if is_select then
-- 			path = ResPath.GetCommon("btn_down_4")
-- 		end
-- 		self.img_expland:loadTexture(path)
-- 	end
-- end

-- function AccordionBossRender:CreateSelectEffect()
-- 	if self:IsChild() then
-- 		local height = self:GetHeight()
-- 		self.select_effect = XUI.CreateImageViewScale9(self.width / 2, height / 2, self.width + 15, height + 15, ResPath.GetCommon("select_effect_1"), true, cc.rect(18, 21, 9, 7))
-- 		self.view:addChild(self.select_effect, 200, 200)
-- 	end
-- end