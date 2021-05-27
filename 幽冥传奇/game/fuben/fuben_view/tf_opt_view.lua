-- 塔防 操作视图
TafangOptView = TafangOptView or BaseClass(XuiBaseView)

function TafangOptView:__init()
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.config_tab = {
		{"fuben_child_view_ui_cfg", 1, {0}},
	}
	self.item_list = {}
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
end

function TafangOptView:__delete()
end

function TafangOptView:Load(index)
	if nil ~= self.loadstate_list[index] then
		return
	end

	self:LoadUiConfig()

	-- 创建根节点
	if nil == self.real_root_node then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.root_node = XUI.CreateLayout(screen_w, 0, 0, 0)
		self.root_node:setAnchorPoint(0.5, 0.5)

		self.real_root_node = self.root_node
		HandleRenderUnit:AddUi(self.real_root_node, self.zorder, self.zorder)
	end

	-- 创建UI
	if self.is_async_load then
		self:AsyncLoadPlist(index)
	else
		self:CreateUI(index)
	end
end

function TafangOptView:OpenCallBack()
end

function TafangOptView:CloseCallBack()
	if self.big_bg then
		self.big_bg:setVisible(false)
	end
end

function TafangOptView:ReleaseCallBack()
	if self.big_bg then
		self.big_bg:removeFromParent()
		self.big_bg = nil
	end

	if self.fuben_alert then
		self.fuben_alert:DeleteMe()
		self.fuben_alert = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	
	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
	end

	self.is_start_auto_pos = nil
end

function TafangOptView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event)

		local total_angle = 155
		local each_angle = total_angle / #TafangFubenCfg.optItems
		local angle = each_angle / 2 + 90 - (total_angle - 90) * 0.5

		local offset = 120

		for i = 1, #TafangFubenCfg.optItems do
			item = TafangItemRender.New()
			item:SetUiConfig(self.ph_list.ph_tf_item)
			item:SetIsUseStepCalc(true)
			local x, y = self:CalcPosByAngle(GameMath.NormalizeAngle(angle + each_angle * (i - 1)))
			item:GetView():setPosition(x - offset, y + offset + 20)
			item:GetView():setAnchorPoint(0.5, 71 / 135)
			item:SetData(TafangFubenCfg.optItems[i])
			self.root_node:addChild(item:GetView(), 9)
			if i == #TafangFubenCfg.optItems  then
				item:GetView():setPositionX(x - offset + 50)
			end
			self.item_list[i] = item
		end

		self.big_bg = XUI.CreateImageView(HandleRenderUnit:GetWidth() * 0.5 + 100, HandleRenderUnit:GetHeight() - 55, ResPath.GetFuben("fb_tf_bg_100"), true)
		HandleRenderUnit:AddUi(self.big_bg, -10)

		XUI.AddClickEventListener(self.node_t_list.layout_tf_start_btn.node, BindTool.Bind(self.OnClickStart, self), true)
		self.node_t_list.layout_out_fb.node:setVisible(false)
		XUI.AddClickEventListener(self.node_t_list.layout_out_fb.node, BindTool.Bind(self.OnClickOut, self), true)
	end
end

function TafangOptView:ShowIndexCallBack(index)
	self:Flush()
	if self.big_bg then
		self.big_bg:setVisible(true)
	end
end

function TafangOptView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			for k, v in pairs(self.item_list) do
				v:Flush()
			end

			local is_open = FubenData.Instance:GetFubenLeftTime() > 0

			self.node_t_list.img_start_fb.node:setGrey(is_open)
			self.node_t_list.img_start_fb_word.node:setGrey(is_open)
			self.node_t_list.layout_tf_start_btn.node:setTouchEnabled(not is_open)

			if not is_open and next(Scene.Instance:GetSceneLogic():GetGuideT()) == nil then
				UiInstanceMgr.AddCircleEffect(self.node_t_list.layout_tf_start_btn.node)
				self.is_start_auto_pos = true
			else
				UiInstanceMgr.DelCircleEffect(self.node_t_list.layout_tf_start_btn.node)
				self.is_start_auto_pos = nil
			end
		end
	end
end

function TafangOptView:CalcPosByAngle(angle)
	local x = 200 * math.cos(math.rad(angle))
	local y = 200 * math.sin(math.rad(angle))
	return math.floor(x * 100) / 100, math.floor(y * 100) / 100
end

function TafangOptView:ItemDataListChangeCallback(change_type, item_id, item_index, series)
	if item_id then
		for k, v in pairs(TafangFubenCfg.optItems) do
			if v.item_id == item_id then
				self:Flush()
				break
			end
		end
	end
end

function TafangOptView:OnClickStart()
	FubenCtrl.TafangStartReq()
	if self.is_start_auto_pos then
		self.is_start_auto_pos = nil
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), 64, 18, 1)
	end
end

function TafangOptView:OnClickOut()
	if TafangFubenCfg.totalMonsterNum > FubenData.Instance.cur_monster_num then
		self.fuben_alert = self.fuben_alert or Alert.New()
		self.fuben_alert:SetLableString(Language.Fuben.ExitFubenAlert)
		self.fuben_alert:SetOkFunc(function()
			FubenCtrl.OutFubenReq(FubenData.Instance:GetFubenId())
		end)
		self.fuben_alert:SetCancelString(Language.Common.Cancel)
		self.fuben_alert:SetOkString(Language.Common.Confirm)
		self.fuben_alert:SetShowCheckBox(false)
		self.fuben_alert:Open()
	else
		FubenCtrl.OutFubenReq(FubenData.Instance:GetFubenId())
	end
end

----------------------------------------------------
-- TafangItemRender
----------------------------------------------------
TafangItemRender = TafangItemRender or BaseClass(BaseRender)
function TafangItemRender:__init()
end

function TafangItemRender:__delete()
end

function TafangItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.RichTextSetCenter(self.node_tree.layout_buy_item.rich_show_text.node)
	self.node_tree.img_item.node:loadTexture(ResPath.GetFuben(self.data.icon))
	XUI.AddClickEventListener(self.node_tree.img_item.node, BindTool.Bind(self.OnClickUse, self), true)
	XUI.AddClickEventListener(self.node_tree.layout_buy_item.node, BindTool.Bind(self.OnClickBuy, self), true)
end

function TafangItemRender:OnFlush()
	if self.data.item_id then
		local num = BagData.Instance:GetItemNumInBagById(self.data.item_id)
		self.node_tree.lbl_num.node:setString(num)
		self.node_tree.img_item.node:setGrey(num <= 0)
		-- self.node_tree.img_item.node:setTouchEnabled(num > 0)

		local guide_tab = Scene.Instance:GetSceneLogic():GetGuideT()
		if guide_tab[1] then
			if self.data.item_id == guide_tab[1].item_id then
				UiInstanceMgr.AddCircleEffect(self.node_tree.img_item.node)
			end
		end

		local item_price_cfg
		if 825 == self.data.item_id then
			item_price_cfg = ShopData.GetItemPriceCfg(self.data.item_id, MoneyType.BindCoin)
		else
			item_price_cfg = ShopData.GetItemPriceCfg(self.data.item_id)
		end
		local item_price = item_price_cfg and item_price_cfg.price[1].price
		local item_type = item_price_cfg and item_price_cfg.price[1].type
		if item_price and self.node_tree.layout_buy_item and self.node_tree.layout_buy_item.rich_show_text then
			RichTextUtil.ParseRichText(self.node_tree.layout_buy_item.rich_show_text.node, string.format(Language.Fuben.TafangBuyItem, item_price, ShopData.GetMoneyTypeName(item_type) or ""))
		end
	end
end

function TafangItemRender:OnClickUse()
	if self.data.item_id then
		local data = BagData.Instance:GetOneItem(self.data.item_id)
		if data then
			local pos_t = Scene.Instance:GetSceneLogic():GetAutoPlacePosT()
			local pos = pos_t[1]
			if pos then
				local function MoveEndOpt()
					BagCtrl.Instance:SendUseItem(data.series, 0, 1)
					table.remove(pos_t, 1)

					self:UpdateGuide()				
				end
				MoveCache.end_type = MoveEndType.OtherOpt
				MoveCache.param1 = MoveEndOpt
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.x, pos.y, 1)
			else
				BagCtrl.Instance:SendUseItem(data.series, 0, 1)
				self:UpdateGuide()			
			end
		else-- 没有物品的时候打开购买界面
			self:OnClickBuy()
		end
	end
end

function TafangItemRender:UpdateGuide()
	local guide_tab = Scene.Instance:GetSceneLogic():GetGuideT()
	if guide_tab[1] then
		if self.data.item_id == guide_tab[1].item_id then
			guide_tab[1].times = guide_tab[1].times - 1
			if guide_tab[1].times <= 0 then
				table.remove(guide_tab, 1)
				UiInstanceMgr.DelCircleEffect(self.node_tree.img_item.node)
			end
		end
	end
end

function TafangItemRender:OnClickBuy()
	if self.data.item_id then
		ViewManager.Instance:Open(ViewName.QuickBuy)
		local param = {self.data.item_id}
		if 825 == self.data.item_id then
			param[2] = MoneyType.BindCoin
		end
  		ViewManager.Instance:FlushView(ViewName.QuickBuy, 0, "param", param)
	end
end

function TafangItemRender:CreateSelectEffect()
end
