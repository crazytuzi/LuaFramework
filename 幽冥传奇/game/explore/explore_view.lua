--------------------------------------------------------
-- 寻宝主视图
--------------------------------------------------------

ExploreView = ExploreView or BaseClass(BaseView)

function ExploreView:__init()
	self.root_node_off_pos = {x = 50, y = 0}
	self.texture_path_list[1] = 'res/xui/explore.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"explore_ui_cfg", 1, {0}},
		{"explore_ui_cfg", 11, {0}, nil, 999},	
	}

	self.tabbar_group = {ViewDef.Explore.Xunbao, ViewDef.Explore.Fullserpro, ViewDef.Explore.RareTreasure, 
	ViewDef.Explore.Exchange, ViewDef.Explore.Storage, ViewDef.Explore.Swap}
	require("scripts/game/explore/explore_xunbao").New(ViewDef.Explore.Xunbao, self)
	require("scripts/game/explore/explore_progress").New(ViewDef.Explore.Fullserpro, self)
	require("scripts/game/explore/explore_storage").New(ViewDef.Explore.Storage, self)
	-- require("scripts/game/explore/explore_time").New(ViewDef.Explore.PrizeInfo, self)
	require("scripts/game/explore/explore_exchange").New(ViewDef.Explore.Exchange, self)
	require("scripts/game/explore/explore_raretreasure_view").New(ViewDef.Explore.RareTreasure, self)
	require("scripts/game/explore/explore_swap_view").New(ViewDef.Explore.Swap, self)
	
	self.tabbar = nil
	self.opendiamondscreate = true
	self.eff = nil -- 窗口标题栏特效
end

function ExploreView:__delete()
end

--释放回调
function ExploreView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.eff = nil
	if self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end
end

--加载回调
function ExploreView:LoadCallBack(index, loaded_times)
	-- ExploreCtrl.Instance:SendReturnWarehouseDataReq() --请求寻宝仓库数据
	ExploreCtrl.Instance:WorldInfoReq() 			-- 请求全服奖励信息

	self:CreateTabbar()
	self:FlushYuanBaoView()
	-- self.ShowXBStorageView()
	self:ExploreRemindTabbar()

	self.node_t_list.layout_xunbao_common.node:setVisible(false)

	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_GOLD, BindTool.Bind(self.OnRoleAttrChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.WEAR_HOUSE_DATA_CHANGE, BindTool.Bind(self.FlushStorageRemind, self))
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.ExploreRemindTabbar, self))
	self.remind_event = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChanged, self))
end

function ExploreView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ExploreCtrl.Instance:WorldInfoReq()
	ExploreCtrl.Instance:SendFirstPageDataReq()

	--特效
	-- if not self.eff then
	-- 	local path, name = ResPath.GetEffectUiAnimPath(259)
	-- 	self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
	-- 	self.eff:setPosition(612, 615)
	-- 	self:GetRootNode():addChild(self.eff, 999)
	-- 	self.eff:setVisible(true)
	-- end
end

function ExploreView:CloseCallBack(is_all)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function ExploreView:ShowIndexCallBack(index)
	self:FlushTabbarSelect()
end

function ExploreView:OnFlush(param_list)

end

-- 寻宝仓库有东西变化是提醒
function ExploreView:FlushStorageRemind()
	local bag_data = ExploreData.Instance:GetWearHouseAllData()
	self.tabbar:SetRemindByIndex(5, nil ~= bag_data[0])
end

function ExploreView:OnBagItemChange()
	self:ExploreRemindTabbar()
end

--从服务端获取寻宝仓库数据
-- function ExploreView.ShowXBStorageView()
-- 	-- if ExploreData.Instance:GetChangeData() then
-- 	-- 	ExploreCtrl.Instance:SendReturnWarehouseDataReq()
-- 	-- end
-- end

function ExploreView:OnRoleAttrChange()
	self:FlushYuanBaoView()
end

--刷新钻石显示
function ExploreView:FlushYuanBaoView()
	local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	self.node_t_list.txt_gold.node:setString(yuanbao)
end

function ExploreView:CreateTabbar()
	if nil == self.tabbar then
		local name_list = {}
		for k, v in pairs(self.tabbar_group) do
			name_list[#name_list + 1] = v.name
		end
		self.tabbar = Tabbar.New()
		-- self.tabbar:SetTabbtnTxtOffset(-10, 0)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 145, 530, function (index)
			ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
		end, name_list, false, ResPath.GetCommon("toggle_105"))
	end
end

function ExploreView:FlushTabbarSelect()
	for k, v in pairs(self.tabbar_group) do
		if ViewManager.Instance:IsOpen(v) then
		self.node_t_list.img_rew_bg.node:setVisible(k == 2)
			self.tabbar:ChangeToIndex(k)
			break
		end
	end

	self.tabbar:SetRemindByIndex(3, RemindManager.Instance:GetRemind(RemindName.ExploreRareTreasure) > 0)
	--self.tabbar:SetRemindByIndex(5, RemindManager.Instance:GetRemind(RemindName.ExploreRareplace) > 0)
	self:FlushStorageRemind()					  
end

--选择标签回调
-- function ExploreView:TabSelectCellBack(index)
-- 	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
-- end

function ExploreView:OnGetUiNode(node_name)
	local view_def = self:GetViewManager():GetViewByStr(node_name)
	if nil ~= view_def then
		local tabbar_index = nil
		for k, v in pairs(self.tabbar_group) do
			if v == view_def then
				return self.tabbar and self.tabbar:GetToggleByIndex(k)
			end
		end
	end
	return ExploreView.super.OnGetUiNode(self, node_name)
end

-- 标签栏提醒
function ExploreView:ExploreRemindTabbar()
	self.tabbar:SetRemindByIndex(1, ExploreData.Instance.GetXunbaoRemindIndex() > 0)
	self.tabbar:SetRemindByIndex(3, (ExploreData.Instance:GetOwnRewardState() + ExploreData.Instance:GetRareTreasureRemind()) > 0)
	self.tabbar:SetRemindByIndex(4, ExploreData.Instance.GetIsDuihuan() > 0)

end

function ExploreView:OnRemindChanged(remind_name, num)
	if remind_name == RemindName.ExploreRareTreasure then
		self.tabbar:SetRemindByIndex(3, num > 0)
	elseif remind_name == RemindName.ExploreRareplace then
		--self.tabbar:SetRemindByIndex(5, num > 0)
	end
	self:FlushStorageRemind()					  
end