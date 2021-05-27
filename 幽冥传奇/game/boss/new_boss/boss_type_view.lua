local BossTypeView = BaseClass(SubView)

function BossTypeView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
   		{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 9, {0}},
	}

	self.boss_index = 1
end

function BossTypeView:__delete()
end

function BossTypeView:ReleaseCallBack()
	if self.boss_map_list then
		self.boss_map_list:DeleteMe()
		self.boss_map_list = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function BossTypeView:LoadCallBack(index, loaded_times)
	NewBossCtrl.Instance:SendBossKillInfoReq()

	EventProxy.New(NewBossData.Instance, self):AddEventListener(NewBossData.FLUSH_TYPE_BOSS, BindTool.Bind(self.BossKillWorldInfo, self))

	self:TypeBossMapList()
	self:InitTabbar()
	
end

function BossTypeView:BossKillWorldInfo()
	self:Flush()
end

function BossTypeView:ShowIndexCallBack()
	NewBossCtrl.Instance:SendBossTypeReq(1)
	-- self.tabbar:SelectIndex(1)
	self.boss_index = 1
	
	self:Flush()
end

function BossTypeView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 8, -3,
			BindTool.Bind1(self.SelectTabCallback, self), NewBossData.Instance:GetBossTabble(), 
			true, ResPath.GetCommon("toggle_120"))
		-- self.tabbar:ChangeToIndex(1)
	end
end

function BossTypeView:SelectTabCallback(index)
	NewBossCtrl.Instance:SendBossTypeReq(index)
	self.boss_index = index

	self:Flush()
end

function BossTypeView:TypeBossMapList()
	if nil == self.boss_map_list then
		local ph = self.ph_list.ph_type_list
		self.boss_map_list = ListView.New()
		self.boss_map_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossTypeView.BossMapRender, nil, nil, self.ph_list.ph_type_item)
		self.boss_map_list:GetView():setAnchorPoint(0, 0)
		self.boss_map_list:SetJumpDirection(ListView.Top)
		self.boss_map_list:SetItemsInterval(5)
		self.node_t_list.layout_boss_type.node:addChild(self.boss_map_list:GetView(), 100)
	end		
end

function BossTypeView:OnFlush(param_t)

	local data = NewBossData.Instance:BossTypeData(self.boss_index)
	
	self.boss_map_list:SetDataList(data)
end

BossTypeView.BossMapRender = BaseClass(BaseRender)
local BossMapRender = BossTypeView.BossMapRender
function BossMapRender:__init()	
end

function BossMapRender:__delete()	
end

function BossMapRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_go.node, BindTool.Bind1(self.OnEnter, self), true)
end

function BossMapRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)

	self.node_tree.boss_map.node:setString(self.data.map_name)
	self.node_tree.boss_on_lv.node:setString(self.data.limit_lv)
	self.node_tree.boss_num.node:setString(self.data.remind_num)

	local color = self.data.is_allow and COLOR3B.GREEN or COLOR3B.RED
	local btn_txt = self.data.is_allow and Language.Boss.BossTyprBtn[1] or Language.Boss.BossTyprBtn[2]
	self.node_tree.boss_on_lv.node:setColor(color)
	self.node_tree.btn_go.node:setVisible(self.data.is_allow)
	self.node_tree.lbl_not_txt.node:setVisible(not self.data.is_allow)
	self.node_tree.lbl_not_txt.node:setString(btn_txt)
end

function BossMapRender:OnEnter()
	GuajiCtrl.Instance:FlyByIndex(self.data.npc_id)
end

function BossMapRender:CreateSelectEffect()
end

return BossTypeView