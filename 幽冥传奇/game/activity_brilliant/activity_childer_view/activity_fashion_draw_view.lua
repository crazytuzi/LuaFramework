FashionDrawView = FashionDrawView or BaseClass(ActBaseView)

function FashionDrawView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function FashionDrawView:__delete()
	-- if self.cell then
	-- 	self.cell:DeleteMe()
	-- 	self.cell = nil
	-- end	
	-- if self.cell_1 then
	-- 	self.cell_1:DeleteMe()
	-- 	self.cell_1 = nil
	-- end	
	-- if self.cell_2 then
	-- 	self.cell_2:DeleteMe()
	-- 	self.cell_2 = nil
	-- end
end

function FashionDrawView:InitView()
	self.act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZBXB)
	self.node_t_list.layout_fashion_draw.node:setVisible(false)
	self.node_t_list.btn_go_change.node:addClickEventListener(BindTool.Bind(self.OnClickGoOperate, self, 1))
	self.node_t_list.btn_go_buy.node:addClickEventListener(BindTool.Bind(self.OnClickGoOperate, self, 2))
	-- self:CreateExchangeItem()
end

function FashionDrawView:RefreshView(param_list)
	self.act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZBXB)
	if nil == self.act_cfg or nil == self.act_cfg.config then
		return
	end
	-- local item_data = {}
	-- local award_list = {}
	-- local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	-- if self.act_cfg.config.Awards then
	-- 	award_list = self.act_cfg.config.Awards
	-- 	local data = award_list.awards[role_sex + 1] or award_list.awards[1]
	-- 	item_data.item_id = data.id
	-- 	item_data.num = data.count
	-- 	item_data.is_bind = data.bind
	-- 	item_data.effectId = data.effectId
	-- 	self.cell:SetData(item_data)
	-- 	self.node_t_list.layout_fashion_draw.lbl_item_sale_cost.node:setString(award_list.consume.count)
	-- 	self.node_t_list.layout_fashion_draw.lbl_item_cost.node:setString(award_list.consume.oldcount)
	-- 	self.node_t_list.layout_fashion_draw.lbl_item_name.node:setString(ItemData.Instance:GetItemName(data.id))
	-- else
	-- 	self.cell:SetData(nil)
	-- end


	-- self.cell_1 = ActBaseCell.New()
	-- ph = self.ph_list["ph_cost"]
	-- self.cell_1:SetPosition(ph.x, ph.y)
	-- self.cell_1:SetAnchorPoint(0.5, 0.5)
	-- self.node_t_list.layout_fashion_draw.node:addChild(self.cell_1:GetView(), 300)
	-- item_data = {}
	-- item_data.item_id = award_list.consume.id
	-- item_data.num = 1
	-- item_data.is_bind = 0
	-- item_data.effectId = award_list.consume.effectId
	-- self.cell_1:SetData(item_data)
	-- self.cell_1:SetCellBg(nil)
	-- self.cell_1:SetIsShowTips(false)
	-- self.cell_1:GetView():setScale(0.35)	
	
	
	-- self.cell_2 = ActBaseCell.New()
	-- ph = self.ph_list["ph_cost_2"]
	-- self.cell_2:SetPosition(ph.x, ph.y)
	-- self.cell_2:SetAnchorPoint(0.5, 0.5)
	-- self.node_t_list.layout_fashion_draw.node:addChild(self.cell_2:GetView(), 300)
	-- self.cell_2:SetData(item_data)
	-- self.cell_2:SetCellBg(nil)
	-- self.cell_2:SetIsShowTips(false)
	-- self.cell_2:GetView():setScale(0.35)

	-- if award_list.consume.oldcount > 1000 then
	-- 	self.node_t_list.layout_fashion_draw.text_1.node:setScaleX(3)
	-- else
	-- 	self.node_t_list.layout_fashion_draw.text_1.node:setScaleX(2)
	-- end

	-- self.node_t_list.img_show_role.node:loadTexture(ResPath.GetBigPainting("activity_role_" .. (self.act_cfg.config.id)))

	-- local is_exchange = ActivityBrilliantData.Instance:GetIsExchange()
	-- if 0 == is_exchange then
	-- 	self.node_t_list.layout_fashion_draw.img_exchange_reward_state.node:setVisible(false)
	-- 	self.node_t_list.layout_fashion_draw.layout_exchange.node:setVisible(true)
	-- else
	-- 	self.node_t_list.layout_fashion_draw.img_exchange_reward_state.node:setVisible(true)
	-- 	self.node_t_list.layout_fashion_draw.layout_exchange.node:setVisible(false)
	-- 	self.node_t_list.layout_fashion_draw.img_exchange_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	-- end
end

-- function FashionDrawView:CreateExchangeItem()
-- 	self.cell = ActBaseCell.New()
-- 	local ph = self.ph_list["ph_item_cell"]
-- 	self.cell:SetPosition(ph.x, ph.y)
-- 	self.cell:SetAnchorPoint(0.5, 0.5)
-- 	self.node_t_list.layout_fashion_draw.node:addChild(self.cell:GetView(), 300)
-- 	XUI.AddClickEventListener(self.node_t_list.layout_fashion_draw.layout_exchange.node, BindTool.Bind(self.OnClickBtnExchange, self), true)
-- 	self.node_t_list.layout_fashion_draw.img_exchange_reward_state.node:setVisible(false)
-- end

-- function FashionDrawView:OnClickBtnExchange()
--  	local act_id = ACT_ID.ZBXB
--  	local award_list = {}
-- 	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
-- 	if self.act_cfg.config.Awards then
-- 		award_list = self.act_cfg.config.Awards
-- 		local item_num = BagData.Instance:GetItemNumInBagById(award_list.consume.id)
-- 		if item_num < award_list.consume.count then
-- 			SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.FashionDrawTip)
-- 			return
-- 		end
-- 	end
-- 	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 1)
-- end

function FashionDrawView:OnClickGoOperate(index)
	if index == 1 then
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	elseif index == 2 then
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.VipChild)
	end
	-- ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function FashionDrawView:ItemConfigCallback()
	self:RefreshView()
end