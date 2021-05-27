--------------------------------------------------------
-- 未知暗殿  配置 WeiZhiAnDianCfg
--------------------------------------------------------

UnknownDarkHouseView = UnknownDarkHouseView or BaseClass(BaseView)

function UnknownDarkHouseView:__init()
	self.texture_path_list[1] = 'res/xui/daily_tasks.png'
	-- self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"unknown_dark_house_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}},
	}

end

function UnknownDarkHouseView:__delete()
end

--释放回调
function UnknownDarkHouseView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function UnknownDarkHouseView:LoadCallBack(index, loaded_times)
	self.data = UnknownDarkHouseData.Instance:GetData()

	self.node_t_list["btn_challenge"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_challenge"].node, 1)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_challenge"].node, BindTool.Bind(self.OnChallenge, self, 2), true)

	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function UnknownDarkHouseView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function UnknownDarkHouseView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function UnknownDarkHouseView:ShowIndexCallBack(index)
	local text = "消耗：" .. WeiZhiAnDianCfg.Money[1].count .."绑元"
	local boor = self.data.times >= WeiZhiAnDianCfg.freeTimes
	text = boor and text or "免费"
	self.node_t_list.lbl_consume.node:setString(text)

	self.node_t_list["btn_challenge"].remind_eff:setVisible(not boor)
	ViewManager.Instance:CloseViewByDef(ViewDef.Tasks) -- 加载完后关闭"任务面板"
end
----------视图函数----------

----------end----------

-- "未知暗殿"进入按钮点击回调
function UnknownDarkHouseView:OnChallenge()
	UnknownDarkHouseCtrl.Instance:SendUnknownDarkHouseReq(2)
	self:Close()
end

--------------------
