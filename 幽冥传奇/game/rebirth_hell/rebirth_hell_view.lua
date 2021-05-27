--------------------------------------------------------
-- 跨服BOSS-轮回地狱主视图  配置 reincarnationHellCfg
--------------------------------------------------------

RebirthHellView = RebirthHellView or BaseClass(BaseView)

function RebirthHellView:__init()
	self.texture_path_list[1] = 'res/xui/rebirth_hell.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"rebirth_hell_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.tabbar_group = {ViewDef.RebirthHell.RebirthHell, ViewDef.RebirthHell.RotaryTable}
	require("scripts/game/rebirth_hell/rebirth_hell_child_view").New(ViewDef.RebirthHell.RebirthHell, self) -- 烈焰幻境
	require("scripts/game/rebirth_hell/rotary_table_view").New(ViewDef.RebirthHell.RotaryTable, self) -- 幸运转盘

	self.tabbar = nil
end

function RebirthHellView:__delete()
end

--释放回调
function RebirthHellView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

--加载回调
function RebirthHellView:LoadCallBack(index, loaded_times)
	self:InitTabbar()
	if IS_ON_CROSSSERVER then
		self.tabbar:SetRemindByIndex(2, RebirthHellData.Instance.GetRemindIndex() > 0)
	end

	EventProxy.New(RebirthHellData.Instance, self):AddEventListener(RebirthHellData.ROTARY_TABLE_DATA_CHANGE, BindTool.Bind(self.FlushRemind, self))
end

function RebirthHellView:OpenCallBack()
	-- 请求"轮回地狱"数据 返回(144, 8)
	RebirthHellCtrl.Instance.SendRebirthHellDataReq(2)
	-- 请求"跨服转盘"数据 返回(144, 7)
	RebirthHellCtrl.Instance.SendRotaryTableReq(1)

	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RebirthHellView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function RebirthHellView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(1)
end
----------视图函数----------

--标签栏初始化
function RebirthHellView:InitTabbar()
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
function RebirthHellView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.tabbar_group[index])
	--刷新标签栏显示
	for k, v in pairs(self.tabbar_group) do
		if v.open then
			self.tabbar:ChangeToIndex(k)
			break
		end
	end
end

function RebirthHellView:FlushRemind()
	if IS_ON_CROSSSERVER then
		self.tabbar:SetRemindByIndex(2, RebirthHellData.Instance.GetRemindIndex() > 0)
	end
end
----------end----------

--------------------
