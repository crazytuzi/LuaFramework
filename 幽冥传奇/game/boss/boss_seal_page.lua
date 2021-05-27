--封印BOSS

BossSealPage = BossSealPage or BaseClass()


function BossSealPage:__init()
	
end	

function BossSealPage:__delete()
	self:RemoveEvent()
	-- if nil ~= self.tabbar_2 then
	-- 	self.tabbar_2:DeleteMe()
	-- 	self.tabbar_2 = nil 
	-- end
	if nil ~= self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil
	end
	if self.boss_reward_cell ~= nil then
		for k, v in pairs(self.boss_reward_cell) do
			v:DeleteMe()
		end
		self.boss_reward_cell = {}
	end

	if nil ~= self.seal_boss_list then
		self.seal_boss_list:DeleteMe()
		self.seal_boss_list = nil 
	end

	if self.number_rade_seal ~= nil then
		self.number_rade_seal:DeleteMe()
		self.number_rade_seal = nil
	end
	
	self.view = nil
end	

--初始化页面接口
function BossSealPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	-- self.select_index = 1
	ph = self.view.ph_list.ph_page4_model
	self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view.node_t_list.page6.node, GameMath.MDirDown)
	self.monster_display:SetAnimPosition(ph.x,ph.y)
	self.monster_display:SetFrameInterval(FrameTime.RoleStand)
	self.monster_display:SetZOrder(4)
	self:InitSealTabber()
	self:CreareCell()
	self:InitEvent()
	
end	

--初始化事件
function BossSealPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list["btn_shuomimng"].node, BindTool.Bind2(self.OnOpenShuoMingView, self))
	XUI.AddClickEventListener(self.view.node_t_list["btn_enter"].node, BindTool.Bind2(self.OnTansmitBossMap, self))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_map_6"].node, BindTool.Bind2(self.OnTansmitBossMap, self, 3))
	-- self.view.node_t_list["btn_map_5"].node:setVisible(false)
	-- self.view.node_t_list["btn_map_6"].node:setVisible(false)
	self.number_rade_seal = self:CreateUINum(280, 209, 30, 29)
	self.view.node_t_list.page6.node:addChild(self.number_rade_seal:GetView(),999)
end

function BossSealPage:InitSealTabber()
	if self.seal_boss_list == nil then
		local ph = self.view.ph_list.ph_page4_scroll_bar
		self.seal_boss_list  = ListView.New()
		self.seal_boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossSealRender, nil, nil, self.view.ph_list.ph_page4_scroll_item)
		self.seal_boss_list:SetItemsInterval(10)
		
		self.seal_boss_list:SetJumpDirection(ListView.Top)
		self.seal_boss_list:SetSelectCallBack(BindTool.Bind(self.SelectTabBossCallback, self))
		self.view.node_t_list.page6.node:addChild(self.seal_boss_list:GetView(), 20)
	end
end

function BossSealPage:SelectTabBossCallback(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_index = item:GetIndex()
	self.select_data = item:GetData()
	self:FlushView(self.select_data)
end

function BossSealPage:CreareCell()
	self.boss_reward_cell = {}
	for i = 1, 6 do
		local ph = self.view.ph_list.ph_reward_cell4
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 120*(i-1), ph.y)
		self.view.node_t_list["page6"].node:addChild(cell:GetView(), 103)
		table.insert(self.boss_reward_cell, cell)
	end	
end

--移除事件
function BossSealPage:RemoveEvent()

end

--更新视图界面
function BossSealPage:UpdateData(data)
	local boss_data = BossData.Instance:GetSealBossInfo()
	self.seal_boss_list:SetDataList(boss_data)
	self.seal_boss_list:SelectIndex(1)
	self:FlushView()
end	

function BossSealPage:FlushView(data)
	local cur_data = BossData.Instance:GetSealBossInfo()
	local boss_data = data or cur_data[1]
	if boss_data ~= nil then
		for k,v in pairs(self.boss_reward_cell) do
			v:GetView():setVisible(false)
		end
		local reward = boss_data.reward_data or {}
		for k, v in pairs(reward) do
			self.boss_reward_cell[k]:GetView():setVisible(true)
			self.boss_reward_cell[k]:SetData({item_id = v.id, num = 1, is_bind = 0})
		end
		local boss_id = boss_data.boss_id
		local cfg = BossData.GetMosterCfg(boss_id)
		if cfg ~= nil then
			self.monster_display:Show(cfg.modelid)
			self.number_rade_seal:SetNumber(cfg.level or 0)
			local name = cfg.name or ""
			self.view.node_t_list.nameText4.node:setString(name)
		end
		self.view.node_t_list.img_refresh.node:setVisible(boss_data.boss_state == 0)
		self.view.node_t_list.btn_enter.node:setVisible(boss_data.boss_state == 1)
		self.view.node_t_list.txt_percent.node:setString(boss_data.current_schedule.."/"..boss_data.limit_schedule)
		self.view.node_t_list.prog9_sche.node:setPercent(boss_data.current_schedule/(boss_data.limit_schedule == 0 and 1 or boss_data.limit_schedule)*100)
		self.view.node_t_list.btn_enter.node:setTitleText(boss_data.scene_name)
		local target_id = boss_data.target_boss_id
		local boss_cfg = BossData.GetMosterCfg(target_id)
		if boss_cfg ~= nil then
			local txt = string.format(Language.Boss.JiSha, boss_cfg.name or "")
			self.view.node_t_list.txt_refresh_tijian.node:setString(txt)
		end
	end
end

function BossSealPage:OnTansmitBossMap()
	local cur_data =  BossData.Instance:GetSealBossInfo()
	local boss_data = self.select_data or cur_data[1]
	local transmit_id = boss_data.transmit_id
	if transmit_id ~= nil then
		Scene.Instance:CommonSwitchTransmitSceneReq(transmit_id)
	end
end

function BossSealPage:CreateUINum(x, y, w, h )
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function BossSealPage:OnOpenShuoMingView()
	DescTip.Instance:SetContent(Language.Boss.SealBossContent, Language.Boss.SealBossShuoMing)
end

BossSealRender = BossSealRender or BaseClass(BaseRender)
function BossSealRender:__init()

end

function BossSealRender:__delete()	
end

function BossSealRender:OnFlush()
	if self.data == nil then return end
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	local cfg = BossData.GetMosterCfg(self.data.boss_id)
	if cfg == nil then return end
	local name = cfg.name
	self.node_tree.lbl_boss_name.node:setString(name)
	self.node_tree.img_flag_boss.node:setVisible(self.data.boss_state == 1)
end

function BossSealRender:CreateSelectEffect()
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