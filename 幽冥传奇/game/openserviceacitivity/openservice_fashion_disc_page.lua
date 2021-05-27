-- 开服时装折扣
OpenSerFashionDiscPage = OpenSerFashionDiscPage or BaseClass()
function OpenSerFashionDiscPage:__init()
	self.tick = 0
end	

function OpenSerFashionDiscPage:__delete()
	self:RemoveEvent()
	if self.mysterious_shop_grid ~= nil then
		self.mysterious_shop_grid:DeleteMe()
		self.mysterious_shop_grid = nil
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	self.tick = 0
end	

--初始化页面接口
function OpenSerFashionDiscPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateItemCell()
	self:InitEvent()
	self:FlushShopItems()
end	


--初始化事件
function OpenSerFashionDiscPage:InitEvent()
	-- self.view.node_t_list["btn_refresh"].node:addClickEventListener(BindTool.Bind(self.OnRefrShopItem, self))
	-- if self.timer then
	-- 	GlobalTimerQuest:CancelQuest(self.timer)
	-- 	self.timer = nil
	-- end
	-- self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self, -1),  1)
	self.data_event  = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_FASHION_DISC_DATA, BindTool.Bind(self.FlushShopItems, self))
end

--移除事件
function OpenSerFashionDiscPage:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end
end

--更新视图界面
function OpenSerFashionDiscPage:UpdateData(data)
	
end	

function OpenSerFashionDiscPage:FlushShopItems()
	local cur_data = OpenServiceAcitivityData.Instance:GetOpenSerFashionDiscountShowItems()
	self.mysterious_shop_grid:SetDataList(cur_data)
	if self.tick == 0 then
		self.tick = self.tick + 1
		self.mysterious_shop_grid:JumpToTop()
	end
end

-- function OpenSerFashionDiscPage:FlushTime()
-- 	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.SECRET_SHOP)
-- 	if self.view.node_t_list.text_secrect_shop_rest_time then
-- 		self.view.node_t_list.text_secrect_shop_rest_time.node:setString(time_str)
-- 	end
-- 	local time = OperateActivityData.Instance:GetSecretShopRefrCD() - Status.NowTime
-- 	if time < 0 then
-- 		local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
-- 		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
-- 		if cmd_id then
-- 			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
-- 		end
-- 	else
-- 		local c_time = TimeUtil.FormatSecond2Str(time)
-- 		local txt = string.format(Language.CombineServerActivity.Refreshtime, c_time)
-- 		self.view.node_t_list.txt_refresh_time.node:setString(txt)
-- 	end
-- end

function OpenSerFashionDiscPage:CreateItemCell()
	if self.mysterious_shop_grid == nil then
		local ph = self.view.ph_list.ph_shop_grid
		local item_ui_cfg = self.view.ph_list.ph_item_info_panel
		self.mysterious_shop_grid = GridScroll.New()
		self.mysterious_shop_grid:Create(ph.x, ph.y, ph.w, ph.h, 3, item_ui_cfg.h + 5, OpenSerFashionDiscRender, ScrollDir.Vertical, false, item_ui_cfg)
		self.view.node_t_list.layout_fashion_discount.node:addChild(self.mysterious_shop_grid:GetView(), 100)
	end
end

function OpenSerFashionDiscPage:OnRefrShopItem()
	if self.alert_view == nil then
		self.alert_view = Alert.New()
		local cost = OperateActivityData.Instance:GetSecretShopRefrCost()
		self.alert_view:SetShowCheckBox(true)
		local txt = string.format(Language.CombineServerActivity.Refresh_Tips, cost)
		self.alert_view:SetLableString(txt)
		self.alert_view:SetOkFunc(function ()
			local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
			end
	  	end)
	end
  	self.alert_view:Open()
end


