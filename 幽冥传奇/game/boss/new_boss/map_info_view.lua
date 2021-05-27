-- 地图信息
local MapInfoView = BaseClass(SubView)

function MapInfoView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
    	{"boss_ui_cfg", 1, {0}},
		{"boss_ui_cfg", 7, {0}},
	}

	self.map_data = {}
end

function MapInfoView:__delete()
end

function MapInfoView:LoadCallBack(index, loaded_times)
	self.award_cell_list = nil
	self.fuben_id = 0 
	self.select_index = 1
	self:CreateBossList()
	self:CreateAwardCells()
	self:CreatScollGird()

	XUI.AddClickEventListener(self.node_t_list.layout_map_info.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnBossStateChange, self))
end

function MapInfoView:ShowIndexCallBack()
	self:Flush()
end

function MapInfoView:ReleaseCallBack()
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil 
	end 

	if self.award_cell_list  then
		for k,v in pairs(self.award_cell_list ) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end
	GlobalEventSystem:UnBind(self.scene_change)

	if self.grid_map_list then
		self.grid_map_list:DeleteMe()
	end
	self.grid_map_list = nil
end

function MapInfoView:CreateBossList()
	if nil ~= self.boss_list then
		return
	end

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x + 6, ph.y, ph.w, ph.h, nil, MapInfoView.MapItemRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(10)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_map_info.node:addChild(self.boss_list:GetView(), 20)
end

function MapInfoView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 7 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_map_info.node:addChild(cell:GetView(), 20)
		table.insert(self.award_cell_list, cell)
	end
end

function MapInfoView:CreatScollGird()
	if nil == self.grid_map_list then
		local ph = self.ph_list.ph_map_list
		self.grid_map_list = GridScroll.New()
		self.grid_map_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 60, MapInfoView.MapRender, ScrollDir.Vertical, false, self.ph_list.ph_map_item)
		self.node_t_list.layout_map_info.node:addChild(self.grid_map_list:GetView(), 100)
		self.grid_map_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
		self.grid_map_list:JumpToTop()
	end
end

function MapInfoView:SelectCellCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	
	self:FlushMapInfo(data)
end

function MapInfoView:OnFlush(param_t)
	self:OnBossStateChange()
	self:MapInfoFlush()
end

function MapInfoView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
		self:OnBossStateChange()
	end
end

function MapInfoView:OnBossStateChange()
	
	self.boss_list:SetDataList(CleintBossMapInfoCfg)
	
	self.boss_list:SelectIndex(self.select_index)
end

function MapInfoView:SelectBossListCallback(item, index)
	local data = item:GetData()
	if data == nil then return end

	self.select_index = index

	self:MapInfoFlush()
end

-- 地图信息刷新
function MapInfoView:MapInfoFlush()
	local data = NewBossData.Instance:BossInfoData(self.select_index)
	self.grid_map_list:SetDataList(data)
	self.grid_map_list:JumpToTop()
	self:FlushMapInfo(data[1])
end

function MapInfoView:FlushMapInfo(data)
	if data == nil or next(data) == nil then return end

	local drop_list = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(data.award) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self:FlushAwardList(drop_list)

	self.map_data = data

	self.node_t_list.layout_map_info.btn_challenge.node:setVisible(data.is_allow)
	self.node_t_list.lbl_not_desc.node:setVisible(not data.is_allow)
	self.node_t_list.lbl_not_desc.node:setString(data.desc .. Language.Boss.BossTyprBtn[3])
end

function MapInfoView:FlushAwardList(data_list)
	for k, v in pairs(self.award_cell_list) do
		v:SetData(data_list[k])
		v:GetView():setVisible(data_list[k] ~= nil)
	end
end

function MapInfoView:OnClickChallengeHandler()
	local data = self.boss_list:GetSelectItem():GetData()
	
	-- if data and data.fubenId then
	-- 	FubenCtrl.EnterFubenReq(data.fubenId)
	-- 	self.fuben_id = data.fubenId
	-- end
	if not self.map_data then return end
	Scene.SendQuicklyTransportReq(self.map_data.npc_id)
end

function MapInfoView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.MapInfo then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end


MapInfoView.MapItemRender = BaseClass(BaseRender)
local MapItemRender = MapInfoView.MapItemRender
function MapItemRender:__init()
end

function MapItemRender:__delete()
end

function MapItemRender:CreateChild()
	MapItemRender.super.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_boss_name.node)
end

function MapItemRender:OnFlush()
	self.node_tree.img_remind_flag.node:setVisible(false)

	local str = self.data.name
	RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, str, 19)

	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
end

function MapItemRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("toggle_120_select"), true)
	
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end




-- MapInfoView.PerBossListView = BaseClass(ListView)
-- local PerBossListView = MapInfoView.PerBossListView

-- --list事件回调
-- function PerBossListView:ListEventCallback(sender, event_type, index)
-- 	if self.items[index + 1] then 
-- 		local data = self.items[index + 1].data
-- 		if data.state == 0 then return end
-- 	end
-- 	PerBossListView.super.ListEventCallback(self, sender, event_type, index)
-- end

MapInfoView.MapRender = BaseClass(BaseRender)
local MapRender = MapInfoView.MapRender
function MapRender:__init()
end

function MapRender:__delete()
end

function MapRender:CreateChild()
	MapRender.super.CreateChild(self)
	self.node_tree.img_bg.node:setVisible(false)
end

function MapRender:OnFlush()
	local color = self.data.is_allow and "00ff00" or "ff0000"
	local txt = string.format(Language.Boss.RareBossName, color, self.data.map_name) .. "(" .. self.data.desc .. ")"
	RichTextUtil.ParseRichText(self.node_tree.rich_boss_name.node, txt, 20, COLOR3B.OLIVE)
end

function MapRender:CreateSelectEffect()

end

function MapRender:OnSelectChange(is_select)
	self.node_tree.img_bg.node:setVisible(is_select)
end

return MapInfoView