ActShopView = ActShopView or BaseClass(ActBaseView)

function ActShopView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActShopView:__delete()
	if nil~=self.grid_shop_scroll_list then
		self.grid_shop_scroll_list:DeleteMe()
	end
	self.grid_shop_scroll_list = nil

	if self.next_shop_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.next_shop_flush_timer)
		self.next_shop_flush_timer = nil
	end
end

function ActShopView:InitView()
	self:CreateFlushShopTimer()
	self:CreateShopGridScroll()

	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SHOP)
	self.node_t_list["lbl_flush_consume"].node:setString(cfg.config.params[3])
	
	XUI.AddClickEventListener(self.node_t_list.btn_shop_flush.node, BindTool.Bind(self.OnClickBtnShopFlush, self), false)
end

function ActShopView:RefreshView(param_list)
	self.grid_shop_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetShopItemList())
	self.grid_shop_scroll_list:JumpToTop()
end

function ActShopView:ItemConfigCallback()
	for k, v in pairs(self.grid_shop_scroll_list and self.grid_shop_scroll_list:GetItems() or {}) do
		v:Flush()
	end
end

function ActShopView:OnClickBtnShopFlush()
	self:ShowRefreshConfirm()
end

function ActShopView:UpdateNextShopFlushTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SHOP)
	if nil == cfg then return end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local flush_time =  ActivityBrilliantData.Instance.shop_flush_time + cfg.config.params[1]
	local next_flush_time = math.floor(flush_time - server_time)
 	local act_id = ACT_ID.SHOP
	if next_flush_time <= 1 then
		ActivityBrilliantCtrl.Instance.ActivityReq(3, act_id)
	end
	self.node_t_list.layout_shop.lbl_shop_flush_time.node:setString(TimeUtil.FormatSecond2Str(next_flush_time))
	self.node_t_list.layout_shop.lbl_shop_flush_time.node:setColor(COLOR3B.GREEN)
end

function ActShopView:CreateFlushShopTimer()
	GlobalTimerQuest:CancelQuest(self.next_shop_flush_timer)
	self.next_shop_flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateNextShopFlushTime, self), 1)
	self:UpdateNextShopFlushTime()
end

function ActShopView:CreateShopGridScroll()
	if nil == self.node_t_list.layout_shop then
		return
	end
	if nil == self.grid_shop_scroll_list then
		local ph = self.ph_list.ph_shop_list
		self.grid_shop_scroll_list = GridScroll.New()
		self.grid_shop_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 3, self.ph_list.ph_act_shop_render.h + 2, SecretShopItemRender, ScrollDir.Vertical, false, self.ph_list.ph_act_shop_render)
		self.node_t_list.layout_shop.node:addChild(self.grid_shop_scroll_list:GetView(), 100)
	end
end

function ActShopView:ShowRefreshConfirm()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SHOP)
	local str = string.format(Language.ActivityBrilliant.RefreshItemTip, cfg.config.params[3], Language.Common.Diamond)
	self.refresh_alert = self.refresh_alert or Alert.New()
	self.refresh_alert:SetShowCheckBox(true)
	self.refresh_alert:SetLableString(str)
	--发送刷新神秘商店的指令到服务端
	self.refresh_alert:SetOkFunc(self.RefreshItem)
	self.refresh_alert:Open()
end

--请求刷新神秘商店物品
function ActShopView.RefreshItem()
	local act_id = ACT_ID.SHOP 
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
end