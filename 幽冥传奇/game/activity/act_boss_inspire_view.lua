--------------------------------------------------------
-- 日常活动-Boss鼓舞面板(世界boss 行会boss)
--------------------------------------------------------

ActBossInspireView = ActBossInspireView or BaseClass(BaseView)

function ActBossInspireView:__init()
	self.texture_path_list[1] = 'res/xui/activity.png'
	self.config_tab = {
		{"daily_activity_ui_cfg", 11, {0}}
	}
	self.cfg = StdActivityCfg
end

function ActBossInspireView:__delete()
end

--释放回调
function ActBossInspireView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end

	self.rich_times = nil
end

--加载回调
function ActBossInspireView:LoadCallBack(index, loaded_times)
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	local w, h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

----------更换父节点----------
	local node = self.real_root_node
	node:retain()
	node:removeFromParent()
	node:setParent(nil)
	right_top:TextLayout():addChild(node)
	node:release()
-------------end--------------

	local size = self.node_t_list["layout_boss_inspire"].node:getContentSize()
	self.root_node:setPosition(w / 2 - size.width / 2+8, 80)
	self.root_node:setAnchorPoint(0, 0)
	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnInspire, self) )

	-- 数据监听
	EventProxy.New(ActivityData.Instance, self):AddEventListener(ActivityData.BOSS_INSPIRE_TIMES_CHANGE, BindTool.Bind(self.OnBossInspireTimesChange, self))
end

function ActBossInspireView:OpenCallBack()
end

function ActBossInspireView:CloseCallBack(is_all)
end

--显示指数回调
function ActBossInspireView:ShowIndexCallBack(index)
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
	self:FlushView()
end

function ActBossInspireView:FlushView()
	local act_id = ActivityData.Instance:GetActivityID()
	local cfg = self.cfg[act_id]
	local inspire_cfg = cfg.buyInfo
	local need_yb = cfg.buffConsume or inspire_cfg.needYb or 0
	local max_times = cfg.maxBuyBuffTms or inspire_cfg.limit or 5
	local times = ActivityData.Instance:GetBossInspireTimes(act_id)

	self:FlushTimesRich()
	self.node_t_list["lbl_yb"].node:setString(need_yb)

	local buff_id
	if cfg.buff then
		buff_id = cfg.buff.id
	elseif inspire_cfg then
		buff_id = inspire_cfg.buff.id
	end
	local boff_attr = StdBuff[buff_id].attrs[1]
	local count = boff_attr.value and boff_attr.value * times or 0
	self.node_t_list["lbl_attr"].node:setString(string.format(Language.Activity.AddAttr, count))
end

----------视图函数----------

-- 刷新抽取次数文本
function ActBossInspireView:FlushTimesRich()
	local node = self.rich_times or self.node_t_list["rich_times"].node
	local act_id = ActivityData.Instance:GetActivityID()
	local cfg = self.cfg[act_id]
	local inspire_cfg = cfg.buyInfo
	local max_times = cfg.maxBuyBuffTms or inspire_cfg.limit or 5
	local times = ActivityData.Instance:GetBossInspireTimes(act_id)
	times = times > 0 and "{color;ffc800;" .. times .. "}" or "{color;ff2828;" .. times .. "}"
	
	local text = string.format(Language.Activity.InspireTimes, times, max_times)

	node = RichTextUtil.ParseRichText(node, text, 20, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.rich_times = node
end

----------end----------

function ActBossInspireView:OnInspire()
	local act_id = ActivityData.Instance:GetActivityID()
	ActivityCtrl.Instance.SentBuyInspireReq(act_id)
end

-- 鼓舞次数改变回调
function ActBossInspireView:OnBossInspireTimesChange()
	local act_id = ActivityData.Instance:GetActivityID()
	local cfg = self.cfg[act_id]
	local inspire_cfg = cfg.buyInfo
	local need_yb = cfg.buffConsume or inspire_cfg.needYb or 0
	local times = ActivityData.Instance:GetBossInspireTimes(act_id)

	self:FlushTimesRich()
	self.node_t_list["lbl_yb"].node:setString(need_yb)

	local buff_id
	if cfg.buff then
		buff_id = cfg.buff.id
	elseif inspire_cfg then
		buff_id = inspire_cfg.buff.id
	end
	local boff_attr = StdBuff[buff_id].attrs[1]
	local count = boff_attr.value * times or 0
	self.node_t_list["lbl_attr"].node:setString(string.format(Language.Activity.AddAttr, count))
end

function ActBossInspireView:OnSceneChangeComplete()
	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.ActBossInspire)
end
--------------------
