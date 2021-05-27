
local AddPointView = BaseClass(SubView)

function AddPointView:__init()
	self.texture_path_list = {
		 'res/xui/zhuansheng.png',
	}
	self.config_tab = {
		{"zhuansheng_ui_cfg", 3, {0}},
		{"zhuansheng_ui_cfg", 4, {0}},
	}
end

function AddPointView:__delete()
end

function AddPointView:ReleaseCallBack()
	if nil ~= self.list then
		self.list:DeleteMe()
		self.list = nil
	end

	if nil ~= self.cur_attr then
		self.cur_attr:DeleteMe()
		self.cur_attr = nil
	end

	if nil ~= self.add_point_attr then
		self.add_point_attr:DeleteMe()
		self.add_point_attr = nil
	end
	if self.confirm_desc then
		self.confirm_desc:DeleteMe()
		self.confirm_desc = nil
	end
end

function AddPointView:LoadCallBack(index, loaded_times)
	local ph = self.ph_list["ph_recommend_add_point"]
	local text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.RecommendAddPoint, 19, COLOR3B.GREEN)
	text:setPosition(ph.x, ph.y)
	self.node_t_list.layout_add_point.layout_left.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnRecommendAddPoint, self, 1), true)

	local ph = self.ph_list["ph_reset_add_point"]
	local text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.ResetAddPoint, 19, COLOR3B.GREEN)
	text:setPosition(ph.x, ph.y)
	self.node_t_list.layout_add_point.layout_left.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnResetAddPoint, self, 1), true)

	self.node_t_list.lbl_left_point.node:setString(ZhuanshengData.Instance:GetLeftPoint())

	XUI.AddClickEventListener(self.node_t_list.btn_send_points.node, BindTool.Bind(self.OnSendPoints, self))
	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind(self.ReturnZhuangSheng, self))
	self:CreateAttrOptList()
	local ph = self.ph_list.ph_cur_attr
	self.cur_attr = self:CreateAttrList(ph)
	ph = self.ph_list.ph_add_point_attr
	self.add_point_attr = self:CreateAttrList(ph)
end

function AddPointView:OpenCallBack()
end

function AddPointView:ShowIndexCallBack(index)
	self:Flush()
end

function AddPointView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "left_point" then
			local point = ZhuanshengData.Instance:GetLeftPoint() - ZhuanshengData.Instance:GetTotleOptPoints()
			self.node_t_list.lbl_left_point.node:setString(point < 0 and 0 or point)
			self.add_point_attr:SetData(ZhuanshengData.Instance:GetOprateAttrList())
		elseif k == "all" then
			--PrintTable(ZhuanshengData.Instance:GetAddPointData())
			self.list:SetData(ZhuanshengData.Instance:GetAddPointData())
			self.cur_attr:SetData(ZhuanshengData.Instance:GetAttrList(ZhuanshengData.Instance.attr_point_list))
			self.add_point_attr:SetData(ZhuanshengData.Instance:GetOprateEndPoint())
			self.node_t_list.lbl_left_point.node:setString(ZhuanshengData.Instance:GetLeftPoint())
		end

	end
end

function AddPointView:CreateAttrOptList()
	self.list = ListView.New()
	local ph = self.ph_list.ph_add_point_list
	self.list:Create(ph.x, ph.y, ph.w, ph.h, nil, AddPointView.OptItem, nil, nil, self.ph_list.ph_add_point)
	self.node_t_list.layout_add_point.layout_left.node:addChild(self.list:GetView(), 100, 100)
	self.list:GetView():setAnchorPoint(0.5, 0.5)
	self.list:SetItemsInterval(15)
	self.list:JumpToTop(true)
end

function AddPointView:CreateAttrList(ph)
	local list_view = ListView.New()
	list_view:Create(ph.x, ph.y, ph.w, ph.h, nil, AttrZhuanShengItemRender, nil, nil, self.ph_list.ph_item)
	self.node_t_list.layout_add_point.layout_attr.node:addChild(list_view:GetView(), 100, 100)
	list_view:GetView():setAnchorPoint(0.5, 0.5)
	list_view:SetItemsInterval(8)
	list_view:JumpToTop(true)
	return list_view
end

function AddPointView:ReturnZhuangSheng( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.ZhuanSheng)
end

function AddPointView:CreateAddPointAttrList()

end

function AddPointView:OnRecommendAddPoint()
	local left_point = ZhuanshengData.Instance:GetLeftPoint()
	local add_point_list = ZhuanshengData.Instance:GetAddPointData()
	-- while( left_point > 0 )
	-- do
	--PrintTabl
	-- local rate = 
	-- for k, v in pairs(Circle.RecommentAddPoint) do
	-- 	print(k,v)
	-- end
		for _, v in pairs(add_point_list) do
			if left_point >= math.floor(Circle.RecommentAddPoint[v.type] * ZhuanshengData.Instance:GetLeftPoint()) then
				local add_point = math.floor(Circle.RecommentAddPoint[v.type] * ZhuanshengData.Instance:GetLeftPoint())
				if add_point == 0 and left_point > 0 then
					add_point = 1
				end

				v.opt_point = v.opt_point + add_point
				left_point = left_point -add_point
				if left_point < 0 then
					v.opt_point = (v.opt_point + left_point) < 0 and 0 or (v.opt_point + left_point)
					left_point = 0
				end
			else
				break
			end
		end
	--end
	self.list:SetData(add_point_list)
	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint, 0, "left_point")
end

function AddPointView:OnResetAddPoint()
	if self.confirm_desc == nil then
		self.confirm_desc = SpecialAlertBuy.New()
	end
	local consume = Circle.clearCirclePoint[1]
	local consume_id = consume.id 
	self.confirm_desc:SetShowConetent(consume_id)
	
	self.confirm_desc:SetOkString("重置")
	self.confirm_desc:SetOkFunc(function ()
		if BagData.Instance:GetItemNumInBagById(consume_id, nil) >= consume.count then
			ZhuangShengCtrl.SendInitPointReq()
		else
			local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[consume_id]
	        local data = string.format("{reward;0;%d;1}", consume_id) .. (ways and ways or "")
	        TipCtrl.Instance:OpenBuyTip(data)
		end
	end)
	self.confirm_desc:SetBuyFunc(function ()
		local item_price_cfg = ShopData.GetItemPriceCfg(consume_id, 3)
		ShopCtrl.BuyItemFromStore(item_price_cfg.id, 1, consume_id, 0)
	end)
	self.confirm_desc:Open()
	-- self.confirm_desc:Open()
   	
    
end

function AddPointView:OnSendPoints()
	local req_lis = {}
	--PrintTable(ZhuanshengData.Instance:GetLastOptPointsList())
	for k, v in pairs(Circle.point) do

		req_lis[k] = ZhuanshengData.Instance:GetLastOptPointsList()[v.type]
	end	
	ZhuangShengCtrl.SendAddPointInfReq(req_lis)
end


---------------------------------------------
AddPointView.OptItem = BaseClass(BaseRender)
local OptItem = AddPointView.OptItem
function OptItem:__init()
end

function OptItem:__delete()

end

function OptItem:CreateChildCallBack()
	local path_ball = ResPath.GetZhuanSheng("bg_3")
	local path_progress = ResPath.GetZhuanSheng("prog")
	local path_progress_bg = ResPath.GetZhuanSheng("prog_progress_1")

	local ph = self.ph_list.ph_slider

	self.slider_add_point = XUI.CreateSlider(ph.x, ph.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_add_point:setMaxPercent(100)
	self:GetView():addChild(self.slider_add_point, 100)
	self.slider_add_point:addSliderEventListener(BindTool.Bind(self.OnSliderEvent, self))
	self.slider_add_point:getBallImage():addClickEventListener(BindTool.Bind(self.OnClick, self))
	self:SetIndex(self.data.type)
	XUI.AddClickEventListener(self.node_tree.btn_subtract.node, BindTool.Bind(self.OnSubtract, self))
	XUI.AddClickEventListener(self.node_tree.btn_add.node, BindTool.Bind(self.OnAdd, self))

	--self.node_t_list.layout_effect_setting.node:setPositionY(self.node_t_list.layout_effect_setting.node:getPositionY())
end


function OptItem:OnFlush(param_t, index)
	if self.data == nil then return end
	self:SetIndex(self.data.type)
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str)
	--self.node_tree.lbl_this_time_poist.node:setString(self.data.opt_point)
	-- local text = string.format("{wordcolor;00ff00;%d} / {wordcolor;c7c7c7;%d}", self.data.opt_point, self.data.old_point)
	-- RichTextUtil.ParseRichText(self.node_tree.lbl_this_time_poist.node, text)
	--print("<<<<<<<<", self.data.percent)
	self.slider_add_point:setMinPercent(self.data.percent)
	local text = string.format("{wordcolor;00ff00;%d} / {wordcolor;c7c7c7;%d}", self.data.opt_point or 0, self.data.old_point or 0)
	RichTextUtil.ParseRichText(self.node_tree.lbl_this_time_poist.node, text)
	XUI.RichTextSetCenter(self.node_tree.lbl_this_time_poist.node)
	self:OnFlushItemTime()
	
	--self.slider_add_point:setPercent(self.data.percent)
end



function OptItem:CreateSelectEffect()
end

function OptItem:OnSliderEvent(sender, percent, ...)
	local total_point = ZhuanshengData.GetTotalPoints()
	local opt_point = total_point * percent /100- self.data.value
	opt_point = opt_point > 0 and opt_point or 0

	self.data.opt_point = math.floor(string.format("%.2f", opt_point))
	self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point

	self.old_percent = percent --故意设置不同，让其回弹
	if percent ==  self.slider_add_point:getMaxPercent() or percent ==  self.slider_add_point:getMinPercent()then
		self:OnClick()
	end

	--if self.data.opt_point >= ZhuanshengData.Instance:GetLeftPoint() then
	--	self.data.opt_point = ZhuanshengData.Instance:GetLeftPoint()
	--	local percent = (self.data.opt_point + self.data.attr_value) / ZhuanshengData.GetTotalPoints() * 100
	--	self.slider_add_point:setPercent(percent)
	--end
	--self:Flush(0, "max_percent")

end



function OptItem:OnClick()
	local left_point = ZhuanshengData.Instance:GetLeftPoint()                   --剩余属性点
	local total_point = ZhuanshengData.Instance:GetTotleOptPoints()				--上次每种属性一共分配的点数
	local last_point = ZhuanshengData.Instance:GetLastOptPoints(self.index)     --上次本属性分配的点数

	local cur_opt_point = self.data.opt_point - last_point
	if cur_opt_point > 0 then  --cur_opt_point > 0 滑块正向拉动，如果超过剩余的属性点则回弹
		if total_point == left_point then --剩余点数用完，所有正向操作都回弹到上次的位置
			self.data.opt_point = last_point
			self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point
		elseif total_point +  cur_opt_point > left_point then --如果超过剩余的属性点则回弹到还没有操作的点数上
			self.data.opt_point = left_point - total_point + last_point
			if self.data.opt_point > ZhuanshengData.Instance:GetLeftPoint() then
				self.data.opt_point = ZhuanshengData.Instance:GetLeftPoint()
			end

			self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point
		end
	end
	self:Flush()
	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint, 0, "left_point")
	--GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.OnFlushItemTime, self, percent), 0, 1)
end


function OptItem:OnFlushItemTime()
	self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point
	ZhuanshengData.Instance:SetOptPointList(self.index, self.data.opt_point)

	local percent = (self.data.opt_point + self.data.value) / ZhuanshengData.GetTotalPoints() * 100
	if self.old_percent == percent then
		return
	end
	self.slider_add_point:setPercent(percent)
	self.old_percent = percent
	local text = string.format("{wordcolor;00ff00;%d} / {wordcolor;c7c7c7;%d}", self.data.opt_point, self.data.old_point)
	RichTextUtil.ParseRichText(self.node_tree.lbl_this_time_poist.node, text)
	XUI.RichTextSetCenter(self.node_tree.lbl_this_time_poist.node)
end

function OptItem:OnSubtract()
	if 0 >= self.data.opt_point then return end
	self.data.opt_point = self.data.opt_point - 1
	self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point

	self:Flush()
	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint, 0, "left_point")
end

function OptItem:OnAdd()
	local left_point = ZhuanshengData.Instance:GetLeftPoint()                   --剩余属性点
	local total_point = ZhuanshengData.Instance:GetTotleOptPoints()				--上次每种属性一共分配的点数
	if left_point <= total_point then return end
	self.data.opt_point = self.data.opt_point + 1
	self.data.opt_point = self.data.opt_point < 0 and 0 or self.data.opt_point

	self:Flush()
	ViewManager.Instance:FlushViewByDef(ViewDef.Role.ZhuanSheng.AddPoint, 0, "left_point")
end

return AddPointView













