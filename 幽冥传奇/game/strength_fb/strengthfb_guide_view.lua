-- StrenfthFbGuideView = StrenfthFbGuideView or BaseClass(XuiBaseView)

-- function StrenfthFbGuideView:__init()
-- 	self.zorder = -3

-- 	self.texture_path_list[1] = "res/xui/consign.png"
-- 	self.texture_path_list[2] = "res/xui/fuben.png"

-- 	self.config_tab = {	
-- 		{"strengthfb_ui_cfg", 5, {0}},
-- 	}
	
-- 	self.guide_item_list = {}
-- 	self.item_list_event = BindTool.Bind(self.ItemDataListChangeCallback, self)
-- end

-- function StrenfthFbGuideView:__delete()
-- end

-- function StrenfthFbGuideView:ReleaseCallBack()

-- 	if self.guide_item_list then
-- 		for k,v in pairs(self.guide_item_list) do
-- 			v:DeleteMe()
-- 		end
-- 		self.guide_item_list = {}
-- 	end

-- 	if ItemData.Instance then
-- 		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
-- 	end

-- 	self:ClearTimer()
-- end

-- function StrenfthFbGuideView:LoadCallBack(index, loaded_times)
-- 	if loaded_times <= 1 then
-- 		ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event)

-- 		local screen_w = HandleRenderUnit:GetWidth()
-- 		local screen_h = HandleRenderUnit:GetHeight()
-- 		self.root_node:setPosition(screen_w / 2 + 245, screen_h / 2 - 110)
-- 		local layout_size = self.node_t_list.layout_strfb_guide.node:getContentSize()
-- 		self.node_t_list.layout_strfb_guide.node:setPosition(layout_size.width, layout_size.height)

-- 		self.content_vis = true

-- 		self.guide_item_list = {}
-- 		for i=1,2 do
-- 			local item = StrenfthFbGuideRender.New()
-- 			item:SetUiConfig(self.ph_list.ph_guide_item, true)
-- 			item:SetIsUseStepCalc(true)
-- 			local ph = self.ph_list["ph_guide_item_pos_" .. i]
-- 			item:GetView():setPosition(ph.x, ph.y)
-- 			-- item:SetData()
-- 			self.node_t_list.layout_guide_down.node:addChild(item:GetView(), 9)

-- 			item.name_text = self.node_t_list.layout_guide_down["item_text_" .. i].node
-- 			item.time_text = self.node_t_list.layout_guide_down["item_time_" .. i].node

-- 			self.guide_item_list[i] = item
-- 		end

-- 		self:SetGuideDownVisible(self.content_vis)

-- 		XUI.AddClickEventListener(self.node_t_list.btn_guide_down.node, BindTool.Bind(self.OnClickOpen, self), true)
-- 	end

-- 	self:SetItemsData()
-- 	self:SetTimer()
-- end

-- function StrenfthFbGuideView:OpenCallBack()
-- 	self:SetTimer()
-- 	self:Flush()
-- end

-- function StrenfthFbGuideView:CloseCallBack()
-- 	self:ClearTimer()
-- end

-- -- 定时器
-- function StrenfthFbGuideView:SetTimer()
-- 	if not self.cd_timer then
-- 		self.cd_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnFlushItemTime, self), 1)
-- 	end
-- end
-- function StrenfthFbGuideView:ClearTimer()
-- 	if self.cd_timer then
-- 		GlobalTimerQuest:CancelQuest(self.cd_timer)
-- 		self.cd_timer = nil
-- 	end
-- end

-- function StrenfthFbGuideView:SetGuideDownVisible(is_visible)
-- 	self.content_vis = is_visible
-- 	self.node_t_list.btn_guide_down.node:setFlippedY(self.content_vis)
-- 	self.node_t_list.layout_guide_down.node:setVisible(self.content_vis)
-- end

-- function StrenfthFbGuideView:OnClickOpen()
-- 	self:SetGuideDownVisible(not self.content_vis)
-- end

-- function StrenfthFbGuideView:SetItemsData()
-- 	local item_data_list = StrenfthFbData.GetStrFbGuideItemData()
-- 	if item_data_list and self.guide_item_list then
-- 		for i,v in ipairs(self.guide_item_list) do
-- 			v:SetData(item_data_list[i])
-- 		end
-- 	end
-- end

-- function StrenfthFbGuideView:ItemDataListChangeCallback(change_type, item_id, item_index, series)
-- 	if item_id then
-- 		local cfg = StrenfthFbData.GetStrFbGuideItemCfg()
-- 		if cfg then
-- 			for k,v in pairs(cfg) do
-- 				if v.item_id and v.item_id == item_id then
-- 					self:Flush()
-- 					break
-- 				end
-- 			end
-- 		end
-- 	end
-- end


-- ---------------------------
-- -- 刷新
-- function StrenfthFbGuideView:OnFlush(param_t, index)
-- 	self:OnFlushItemTime()
-- 	self:OnFlushItems()
-- end

-- -- 刷新物品时间
-- function StrenfthFbGuideView:OnFlushItemTime()
-- 	if not self.guide_item_list then return end
-- 	local mainrole_vo = Scene.Instance:GetMainRole():GetVo()
-- 	for k,v in pairs(self.guide_item_list) do
-- 		local data = v:GetData()
-- 		if data then
-- 			local prof = data.prof
-- 			if prof and v.name_text then
-- 				v.name_text:setString(string.format(Language.StrenfthFb.ItemText, Language.StrenfthFb.ItemName[prof] or ""))
-- 			end

-- 			if mainrole_vo.buff_list and data.buff_id then
-- 				for k1,v1 in pairs(mainrole_vo.buff_list) do
-- 					if v1 and data.buff_id == v1.buff_id and v1.buff_time and v.time_text then
-- 						v.time_text:setString(TimeUtil.FormatSecond2HMS(v1.buff_time - Status.NowTime))
-- 					end
-- 				end
-- 			end

-- 		end
-- 	end
-- end

-- function StrenfthFbGuideView:OnFlushItems()
-- 	if self.guide_item_list then
-- 		for k,v in pairs(self.guide_item_list) do
-- 			v:Flush()
-- 		end
-- 	end
-- end




-- ---------------------------------
-- -- StrenfthFbGuideRender
-- ---------------------------------
-- StrenfthFbGuideRender = StrenfthFbGuideRender or BaseClass(BaseRender)

-- function StrenfthFbGuideRender:__init()
	
-- end

-- function StrenfthFbGuideRender:__delete()
	
-- end

-- function StrenfthFbGuideRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	XUI.AddClickEventListener(self.node_tree.img_item.node, BindTool.Bind(self.OnClickUse, self), true)
-- 	XUI.AddClickEventListener(self.node_tree.layout_buy_item.node, BindTool.Bind(self.OnClickBuy, self), true)
-- end

-- function StrenfthFbGuideRender:OnFlush()
-- 	if not self.data or not self.data.item_id then return end

-- 	local num = ItemData.Instance:GetItemNumInBagById(self.data.item_id)
-- 	self.node_tree.lbl_num.node:setString(num)
-- 	self.node_tree.img_item.node:setGrey(num <= 0)
-- 	self.node_tree.img_item.node:setTouchEnabled(num > 0)

-- 	if self.data.prof then self.node_tree.img_item.node:loadTexture(ResPath.GetFuben("cg_item_" .. self.data.prof)) end

-- 	-- local guide_tab = Scene.Instance:GetSceneLogic():GetGuideT()
-- 	-- if guide_tab[1] then
-- 	-- 	if self.data.item_id == guide_tab[1].item_id then
-- 	-- 		UiInstanceMgr.AddCircleEffect(self.node_tree.img_item.node)
-- 	-- 	end
-- 	-- end
-- end

-- function StrenfthFbGuideRender:OnClickUse()
-- 	if not self.data or not self.data.item_id then return end
-- 	local data = ItemData.Instance:GetOneItem(self.data.item_id)
-- 	if data then BagCtrl.Instance:SendUseItem(data.series, 0, 1) end
-- end

-- function StrenfthFbGuideRender:OnClickBuy()
-- 	if not self.data or not self.data.item_id then return end
-- 	ViewManager.Instance:Open(ViewName.QuickBuy)
-- 	ViewManager.Instance:FlushView(ViewName.QuickBuy, 0, "param", {self.data.item_id})
-- end

-- function StrenfthFbGuideRender:CreateSelectEffect()
-- end