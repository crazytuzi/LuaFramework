--boss击杀页面
BossCankillPage = BossCankillPage or BaseClass()


function BossCankillPage:__init()
	
end	

function BossCankillPage:__delete()
	self:RemoveEvent()

	if nil ~= self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil
	end

	if self.shop_cell ~= nil then
		for k, v in pairs(self.shop_cell) do
			v:DeleteMe()
		end
		self.shop_cell = {}
	end

	if nil ~= self.can_kill_boss_list then
		self.can_kill_boss_list:DeleteMe()
		self.can_kill_boss_list = nil 
	end

	if self.number_rade ~= nil then
		self.number_rade:DeleteMe()
		self.number_rade = nil
	end
	self.view = nil
end	

--初始化页面接口
function BossCankillPage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	
	local ph = self.view.ph_list.ph_page1_scroll_bar
	self.can_kill_boss_list = ListView.New()
	self.can_kill_boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossCanKillRender, nil, nil, self.view.ph_list.ph_page1_scroll_item)
	self.can_kill_boss_list:SetItemsInterval(10)
	
	self.can_kill_boss_list:SetJumpDirection(ListView.Top)
	self.can_kill_boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.view.node_t_list.page1.node:addChild(self.can_kill_boss_list:GetView(), 20)

	ph = self.view.ph_list.ph_page1_model
	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page1.node, GameMath.MDirDown)
	self.monster_display:SetAnimPosition(ph.x,ph.y)
	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
	self.monster_display:SetZOrder(30)

	self.shop_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list.ph_reward_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 120*(i-1), ph.y)
		self.view.node_t_list["page1"].node:addChild(cell:GetView(), 103)
		table.insert(self.shop_cell, cell)
	end	
	self.select_index = 1
	self:InitEvent()
end	

function BossCankillPage:SelectBossListCallback(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_data = item:GetData()
	self.select_index = item:GetIndex()
	self:FlushPageView(self.select_data)
end

--初始化事件
function BossCankillPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list["btn_map_1"].node, BindTool.Bind2(self.OnTansmitMap, self, 1))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_2"].node, BindTool.Bind2(self.OnTansmitMap, self, 2))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_3"].node, BindTool.Bind2(self.OnTansmitMap, self, 3))
	self.number_rade = self:CreateUINum(280, 202, 30, 29)
	self.view.node_t_list.page1.node:addChild(self.number_rade:GetView(),999)
end

function BossCankillPage:OnTansmitMap(btn_type)
	local boss_data = BossData.Instance:GetkillBossData()
	local data = self.select_data or boss_data[1]
	local cur_data = data.boss_data and data.boss_data[btn_type] or {}
	local boss_id = cur_data.bossId
	BossCtrl.Instance:SendEnterSceneReq(boss_id, 0)
end

--移除事件
function BossCankillPage:RemoveEvent()

end

--更新视图界面
function BossCankillPage:UpdateData(data)
	self:FlushData()
end	

function BossCankillPage:FlushData()
	local data = {}
	local boss_data = BossData.Instance:GetkillBossData()
	for k, v in pairs(boss_data) do
		table.insert(data, v)
	end
	if #data == 0 then
		self.can_kill_boss_list:SetDataList({})
		for k,v in pairs(self.shop_cell) do
			v:GetView():setVisible(false)
		end
		-- for i = 1, 3 do
		-- 	self.view.node_t_list["btn_map_"..i].node:setVisible(false)
		-- end
		self.view.node_t_list.page1.img_dengji.node:setVisible(false)
		self.number_rade:GetView():setVisible(false)
		self.view.node_t_list["nameText"].node:setString("")
		self.view.node_t_list["txt_refresh_time"].node:setString("")
		self.monster_display:SetVisible(false)
	else
		self.view.node_t_list.page1.img_dengji.node:setVisible(true)
		self.can_kill_boss_list:SetDataList(data)
		self.can_kill_boss_list:SelectIndex(1)
		self.number_rade:GetView():setVisible(true)
		self.monster_display:SetVisible(true)
	end
end

function BossCankillPage:FlushPageView(select_data)
	local cur_data = {}
	local boss_data = BossData.Instance:GetkillBossData()
	for k, v in pairs(boss_data) do
		table.insert(cur_data, v)
	end
	-- for i = 1, 3 do
	-- 	self.view.node_t_list["btn_map_"..i].node:setVisible(false)
	-- end
	local data = select_data or cur_data[1]
	if data ~= nil then 
		self.view.node_t_list["nameText"].node:setString(data.boss_name)
		local boss_id = data.boss_data[1] and data.boss_data[1].bossId
		local cfg = BossData.GetMosterCfg(boss_id)
		if cfg ~= nil then
			self.monster_display:Show(cfg.modelid)
			self.number_rade:SetNumber(cfg.level)
		end
		-- for i = 1, 3 do
		-- 	if i <= data.length then
		-- 		self.view.node_t_list["btn_map_"..i].node:setVisible(true)
		-- 	else
		-- 		self.view.node_t_list["btn_map_"..i].node:setVisible(false)
		-- 	end
		-- end
		for i, v in ipairs(data.boss_data) do
			if i == 1 then
				local scene_name = BossData.Instance:GetSceneCfg(v.sceneId)
				self.view.node_t_list["btn_map_1"].node:setTitleText(scene_name)
				local refresh_time = BossData.Instance:GetReFreshTime(v.bossId) 
				local time = TimeUtil.FormatSecond2Str(refresh_time, 2)
				self.view.node_t_list["txt_refresh_time"].node:setString(refresh_time ~= 0 and (Language.Boss.JianGe.." "..time) or "")
				break
			end
		end

		for i, v in pairs(data.state) do
			XUI.SetButtonEnabled(self.view.node_t_list["btn_map_"..i].node, v.state == 1)
		end
		local reward_data = BossData.Instance:GetCanKillReward()
		local cur_data = reward_data[self.select_index]
		if cur_data and cur_data[1] ~= nil then
			for k, v in pairs(cur_data[1]) do
				self.shop_cell[k]:SetData(v)
			end
			for k,v in pairs(self.shop_cell) do
				if k <= #cur_data[1] then
					v:GetView():setVisible(true)
				else
					v:GetView():setVisible(false)
				end
			end
		else
			for k,v in pairs(self.shop_cell) do
				v:GetView():setVisible(false)
			end
		end
		for k, v in pairs(WildBossConfig) do
			if boss_id == v.boss[1] then
				self.view.node_t_list.page1.txt_desc.node:setString(Language.Boss.BossDesc)
				break
			else
				self.view.node_t_list.page1.txt_desc.node:setString("")
			end
		end
	end
end

function BossCankillPage:CreateUINum(x, y, w, h )
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

BossCanKillRender = BossCanKillRender or BaseClass(BaseRender)
function BossCanKillRender:__init()

end

function BossCanKillRender:__delete()	
end

function BossCanKillRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_boss_name.node:setString(self.data.boss_name)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end	
end

function BossCanKillRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size =self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width,size.height,ResPath.GetCommon("btn_102_select"), true , cc.rect(37,19,73,22))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end