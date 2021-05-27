--------------------------------------------------------
-- 日常活动总奖励  配置 MeridiansCfg
--------------------------------------------------------

ActivityTotalRewardView = ActivityTotalRewardView or BaseClass(BaseView)

function ActivityTotalRewardView:__init()
	self.texture_path_list[1] = 'res/xui/daily_activity_ui_cfg.png'
	self:SetModal(true)
	self.config_tab = {
		{"daily_activity_ui_cfg", 1, {0}},
		{"daily_activity_ui_cfg", 2, {0}},
	}


end

function ActivityTotalRewardView:__delete()
end

--释放回调
function ActivityTotalRewardView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function ActivityTotalRewardView:LoadCallBack(index, loaded_times)


	-- 按钮监听
	-- XUI.AddClickEventListener(self.node_t_list.layout_xunbao_10.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 2), true)


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function ActivityTotalRewardView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityTotalRewardView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function ActivityTotalRewardView:ShowIndexCallBack(index)

end
----------视图函数----------

function ActivityTotalRewardView:Create()

end

function ActivityTotalRewardView:InitView()

end

function ActivityTotalRewardView:FlushView()

end

----------end----------

--------------------
