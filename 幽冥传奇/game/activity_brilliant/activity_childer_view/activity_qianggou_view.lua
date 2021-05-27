QiangGouView = QiangGouView or BaseClass(ActBaseView)

function QiangGouView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function QiangGouView:__delete()
	if nil~=self.grid_qianggou_scroll_list then
		self.grid_qianggou_scroll_list:DeleteMe()
	end
	self.grid_qianggou_scroll_list = nil

	if self.next_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.next_flush_timer)
		self.next_flush_timer = nil
	end

	if self.refresh_alert then
		self.refresh_alert:DeleteMe()
		self.refresh_alert = nil
	end
end

function QiangGouView:InitView()
	self:CreateFlushTimer()
	self:CreateQianggouGridScroll()
	XUI.AddClickEventListener(self.node_t_list.btn_flush_buy.node, BindTool.Bind(self.OnClickBtnFlush, self), false)

	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local params = cfg.config and cfg.config.params or {}
	self.node_t_list["lbl_refresh_consume"].node:setString(params[3] or 0)
end

function QiangGouView:RefreshView(param_list)
	self.grid_qianggou_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetQianggouItemList())
	self.grid_qianggou_scroll_list:JumpToTop()
end

function QiangGouView:OnClickBtnFlush()
	self:ShowRefreshConfirm()
end

function QiangGouView:UpdateNextFlushTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.QG)
	if nil == cfg then return end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local flush_time =  ActivityBrilliantData.Instance.flush_time + cfg.config.params[1]
	local next_flush_time = math.floor(flush_time - server_time)
 	local act_id = ACT_ID.QG
	if next_flush_time <= 0 then
		ActivityBrilliantCtrl.Instance.ActivityReq(3, act_id)
	end
	self.node_t_list.layout_qianggou.lbl_activity_tip.node:setString(TimeUtil.FormatSecond2Str(next_flush_time))
	self.node_t_list.layout_qianggou.lbl_activity_tip.node:setColor(COLOR3B.GREEN)
end

function QiangGouView:CreateFlushTimer()
	self.set_now_time = TimeCtrl.Instance:GetServerTime()
	self.next_flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateNextFlushTime, self), 1)
end

function QiangGouView:CreateQianggouGridScroll()
	if nil == self.node_t_list.layout_qianggou then
		return
	end
	if nil == self.grid_qianggou_scroll_list then
		local ph = self.ph_list.ph_qianggou_view_list
		self.grid_qianggou_scroll_list = GridScroll.New()
		self.grid_qianggou_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, QianggouItemRender, ScrollDir.Vertical, false, self.ph_list.ph_qianggou_list)
		self.node_t_list.layout_qianggou.node:addChild(self.grid_qianggou_scroll_list:GetView(), 100)
	end
end

function QiangGouView:ShowRefreshConfirm()
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local params = cfg.config and cfg.config.params or {}
	local str = string.format(Language.ActivityBrilliant.RefreshItemTip, params[3] or 0, Language.Common.Diamond)
	self.refresh_alert = self.refresh_alert or Alert.New()
	self.refresh_alert:SetShowCheckBox(true)
	self.refresh_alert:SetLableString(str)
	--发送刷新神秘商店的指令到服务端
	self.refresh_alert:SetOkFunc(BindTool.Bind(self.RefreshItem, self))
	self.refresh_alert:Open()
end

--请求刷新神秘商店物品
function QiangGouView:RefreshItem()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, self.act_id, 0)
end