--------------------------------------------------------
-- 龙魂圣域主视图  配置 dragonSoulSacredAreaCfg
--------------------------------------------------------

DragonSoulView = DragonSoulView or BaseClass(BaseView)

function DragonSoulView:__init()
	self.texture_path_list[1] = 'res/xui/fire_vision.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"dragon_soul_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.tabbar_group = {ViewDef.DragonSoul.DragonSoul, ViewDef.DragonSoul.MarkBlessing}
	require("scripts/game/dragon_soul/dragon_soul_child_view").New(ViewDef.DragonSoul.DragonSoul, self) -- 龙魂圣域
	require("scripts/game/dragon_soul/dragon_soul_mark_blessing_view").New(ViewDef.DragonSoul.MarkBlessing, self) -- 印记祈福
	self.tabbar = nil
	self.data = nil
	self.copy_id = dragonSoulSacredAreaCfg.fbid -- 跨服副本ID
end

function DragonSoulView:__delete()
end

--释放回调
function DragonSoulView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

--加载回调
function DragonSoulView:LoadCallBack(index, loaded_times)
	self:InitTabbar()
	if IS_ON_CROSSSERVER then
		self.tabbar:SetRemindByIndex(2, DragonSoulData.Instance.GetRemindIndex() > 0)
	end

	EventProxy.New(DragonSoulData.Instance, self):AddEventListener(DragonSoulData.DRAGON_SOUL_DATA_CHANGE, BindTool.Bind(self.FlushRemind, self))
end

function DragonSoulView:OpenCallBack()
	-- 请求"龙魂圣域副本"数据 返回(26, 86)
	CrossServerCtrl.Instance.SendCrossServerCopyDataReq(self.copy_id)
	-- 请求"龙魂圣域"数据 返回(144, 11)
	DragonSoulCtrl.Instance.CSDragonSoulDataReq(1)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DragonSoulView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function DragonSoulView:ShowIndexCallBack(index)

end
----------视图函数----------

--标签栏初始化
function DragonSoulView:InitTabbar()
	if nil == self.tabbar then
		local tabgroup = {}
		for k, v in pairs(self.tabbar_group) do
			tabgroup[#tabgroup + 1] = v.name
		end
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(-10, 0)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 1103, 650,
			BindTool.Bind(self.TabSelectCellBack, self),
			tabgroup, true, ResPath.GetCommon("toggle_110"), 23)
		self.tabbar:SetSpaceInterval(15)
		self.tabbar:GetView():setLocalZOrder(1)
	end
end

--选择标签回调
function DragonSoulView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
	--刷新标签栏显示
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			break
		end
	end
end

function DragonSoulView:FlushRemind()
	if IS_ON_CROSSSERVER then
		self.tabbar:SetRemindByIndex(2, DragonSoulData.Instance.GetRemindIndex() > 0)
	end
end

----------end----------

--------------------
