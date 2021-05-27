--boss野外页面
BossWildPage = BossWildPage or BaseClass()


function BossWildPage:__init()
	
end	

function BossWildPage:__delete()
	self:RemoveEvent()
	-- if nil ~= self.tabbar_2 then
	-- 	self.tabbar_2:DeleteMe()
	-- 	self.tabbar_2 = nil 
	-- end
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

	if nil ~= self.wild_boss_list then
		self.wild_boss_list:DeleteMe()
		self.wild_boss_list = nil 
	end
	if self.number_rade_wild ~= nil then
		self.number_rade_wild:DeleteMe()
		self.number_rade_wild = nil
	end
	
	self.view = nil
end	

--初始化页面接口
function BossWildPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.select_index = 1
	ph = self.view.ph_list.ph_page2_model
	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page2.node, GameMath.MDirDown)
	self.monster_display:SetAnimPosition(ph.x,ph.y)
	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
	self.monster_display:SetZOrder(4)
	self:InitWindTabber()
	self:CreareCell()
	self:InitEvent()
	
end	

--初始化事件
function BossWildPage:InitEvent()
	self.view.node_t_list.img_kill.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list["btn_map_4"].node, BindTool.Bind2(self.OnTansmitBossMap, self))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_5"].node, BindTool.Bind2(self.OnTansmitBossMap, self, 2))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_6"].node, BindTool.Bind2(self.OnTansmitBossMap, self, 3))
	self.view.node_t_list["btn_map_5"].node:setVisible(false)
	self.view.node_t_list["btn_map_6"].node:setVisible(false)
	self.number_rade_wild = self:CreateUINum(280, 205, 30, 29)
	self.view.node_t_list.page2.node:addChild(self.number_rade_wild:GetView(),999)
	self.view.node_t_list.page2.txt_desc.node:setVisible(false)
	self.view.node_t_list.page2.txt_desc.node:setString(Language.Boss.BossDesc)
end

function BossWildPage:InitWindTabber()
	if self.wild_boss_list == nil then
		local ph = self.view.ph_list.ph_wild_boss_list
		self.wild_boss_list  = ListView.New()
		self.wild_boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossWildeRender, nil, nil, self.view.ph_list.ph_page2_scroll_item)
		self.wild_boss_list:SetItemsInterval(10)
		
		self.wild_boss_list:SetJumpDirection(ListView.Top)
		self.wild_boss_list:SetSelectCallBack(BindTool.Bind(self.SelectTabBossCallback, self))
		self.view.node_t_list.page2.node:addChild(self.wild_boss_list:GetView(), 20)
	end
end

function BossWildPage:SelectTabBossCallback(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_index = item:GetIndex()
	self:FlushView(index)
end

function BossWildPage:CreareCell()
	self.boss_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list.ph_cell_wild
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 120*(i-1), ph.y)
		self.view.node_t_list["page2"].node:addChild(cell:GetView(), 103)
		table.insert(self.boss_cell, cell)
	end	
end

--移除事件
function BossWildPage:RemoveEvent()

end

--更新视图界面
function BossWildPage:UpdateData(data)
	self:FlushView(select_index)
	local name = BossData.Instance:GetWindBossName()
	self.wild_boss_list:SetDataList(name)
	self.wild_boss_list:SelectIndex(1)
end	

function BossWildPage:FlushView(select_index)
	local index = select_index or 1
	local name_list = BossData.Instance:GetWindBossName() 
	local scene_list = BossData.Instance:GetWindBossSCeneName()
	self.view.node_t_list["nameText_1"].node:setString(name_list[index])
	local data = BossData.GetWildBossCfg()
	local cfg_data = BossData.GetTempleCfg()
	self.view.node_t_list["btn_map_4"].node:setTitleText(scene_list[index])
	local time = TimeUtil.FormatSecond2Str(data[index].time, 2)
	self.view.node_t_list["txt_refresh_time_1"].node:setString(Language.Boss.JianGe.." "..time)
	local id = data[index].monster_id
	local cfg = BossData.GetMosterCfg(id)
	if cfg ~= nil then
		self.monster_display:Show(cfg.modelid)
		self.number_rade_wild:SetNumber(cfg.level)
	end
	local data = BossData.Instance:GetWildRewardCfg()
	local cur_data = data[index]
	if cur_data and cur_data[1] then
		for k,v in pairs(cur_data[1]) do
			self.boss_cell[k]:SetData(v)
		end
		for k,v in pairs(self.boss_cell) do
			if k <= #cur_data[1] then
				v:GetView():setVisible(true)
			else
				v:GetView():setVisible(false)
			end
		end
	end
	local state_list = BossData.Instance:GetWildBossState()
	local boss_state = state_list[select_index] and state_list[select_index].state or 0
	XUI.SetButtonEnabled(self.view.node_t_list["btn_map_4"].node, boss_state == 1)
	self.view.node_t_list.img_kill.node:setVisible(boss_state == 0)
end

function BossWildPage:OnTansmitBossMap()
	local boss_data = BossData.GetWildBossCfg()
	local data = boss_data[self.select_index]
	local boss_id = data.monster_id
	BossCtrl.Instance:SendEnterSceneReq(boss_id, 0)
end

function BossWildPage:CreateUINum(x, y, w, h )
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

BossWildeRender = BossWildeRender or BaseClass(BaseRender)
function BossWildeRender:__init()

end

function BossWildeRender:__delete()	
end

function BossWildeRender:OnFlush()
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	if self.data == nil then return end
	self.node_tree.lbl_boss_name.node:setString(self.data)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	
end

function BossWildeRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size =self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width,size.height,ResPath.GetCommon("btn_106_select"), true , cc.rect(37,19,73,22))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end