
local CardHandlebookView = BaseClass(SubView)
-- CardHandlebookView = CardHandlebookView or BaseClass(BaseView)

function CardHandlebookView:__init()
	if	CardHandlebookView.Instance then
		ErrorLog("[CardHandlebookView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self.is_modal = true
	-- self.def_index = 1

	self.texture_path_list = {
		'res/xui/card_handlebook.png',
		'res/xui/card_btn.png',
		'res/xui/wing.png',
	}
	self.config_tab = {
		{"card_handlebook_ui_cfg", 2, {0}},
	}
end

function CardHandlebookView:__delete()
end
 
function CardHandlebookView:ReleaseCallBack()
	if nil ~= self.grid_card_scroll_list then
		self.grid_card_scroll_list:DeleteMe()
	end
	self.grid_card_scroll_list = nil

	if nil ~= self.card_power_num then
		self.card_power_num:DeleteMe()
		self.card_power_num = nil
	end	
end

function CardHandlebookView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGridScroll()
		self:CreateCardPowerNumberBar()

		self.select_index = 1
		-- local size = self.node_t_list.img_title_1.node:getContentSize()
		-- self.title = XUI.CreateTextByType(size.width / 2, size.height / 2 + 5, 200, 20, Language.CardHandlebook.TypeName[self.select_index], 1)
		-- self.node_t_list.img_title_1.node:addChild(self.title, 10)

		self.decompose_txt = RichTextUtil.CreateLinkText(Language.CardHandlebook.DescomposeOtherCard, 20, COLOR3B.GREEN, nil, true)
		self.decompose_txt:setPosition(self.node_t_list.lbl_exp_num.node:getContentSize().width, 16)
		XUI.AddClickEventListener(self.decompose_txt, function() ViewManager.Instance:OpenViewByDef(ViewDef.CardHandlebook.Descompose) end, true)
		self.node_t_list.lbl_exp_num.node:addChild(self.decompose_txt, 10)

		-- self.remind_flag = XUI.CreateImageView((self.node_t_list.layout_base_attr.node:getContentSize().width + self.decompose_txt:getContentSize().width) / 2 , 35, ResPath.GetMainui("remind_flag"), true)
		-- self.node_t_list.layout_base_attr.node:addChild(self.remind_flag, 10)
		-- self.remind_flag:setVisible(false)
		XUI.AddClickEventListener(self.node_t_list.btn_suit.node, BindTool.Bind2(self.OnClickCardSuit, self))

		EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.UPDATE_CARD_INFO, BindTool.Bind(self.OnFlushCardInfo, self))
		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
		self:OnFlushCardInfo()
		self.grid_card_scroll_list:JumpToTop()
	end
end

function CardHandlebookView:CreateGridScroll()
	if nil == self.grid_card_scroll_list then
		local ph = self.ph_list.ph_list
		self.grid_card_scroll_list = GridScroll.New()
		self.grid_card_scroll_list:Create(ph.x+2, ph.y, ph.w, ph.h, 4, 182, CardGridItemRender, ScrollDir.Vertical, false, self.ph_list.ph_item)
		self.node_t_list.layout_card_list.node:addChild(self.grid_card_scroll_list:GetView(), 100)
		self.grid_card_scroll_list:SetSelectCallBack(BindTool.Bind(self.OnClickCardInfo, self))
		self.grid_card_scroll_list:JumpToTop()
	end
end

function CardHandlebookView:CreateCardPowerNumberBar()
	local ph = self.ph_list.ph_pre_num
	self.card_power_num = NumberBar.New()
	self.card_power_num:SetRootPath(ResPath.GetCommon("num_133_"))
	self.card_power_num:SetSpace(-10)
	self.card_power_num:SetPosition(ph.x, ph.y)
	self.card_power_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list.layout_card_list.node:addChild(self.card_power_num:GetView(), 320, 300)
	self.card_power_num:SetNumber(CardHandlebookData.Instance:GetAllPowerNum())
end

function CardHandlebookView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CardHandlebookView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CardHandlebookView:OnFlush(param_list, index)
	
end

function CardHandlebookView:OnClickCardSuit()
	CardHandlebookCtrl.Instance:OpenCardCheckSuit(self.select_index)
end

-- 判断点击
function CardHandlebookView:GetCardIndex()
	if self:GetViewDef() == ViewDef.CardHandlebook.CardView.DaibuCar then
		self.select_index = 1
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.PrivateCar then
		self.select_index = 2
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.SeniorCar then
		self.select_index = 3
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.LuxuryCar then
		self.select_index = 4
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.KuCar then
		self.select_index = 5
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.AssembleCar then
		self.select_index = 6
	elseif self:GetViewDef() == ViewDef.CardHandlebook.CardView.PersonalityCar then
		self.select_index = 7
	end
end

function CardHandlebookView:OnFlushCardInfo()
	self:GetCardIndex()
	self:FlushCardListInfo()
	self:FlushCardTypeInfo()
end

function CardHandlebookView:FlushCardListInfo()
	self.grid_card_scroll_list:SetDataList(CardHandlebookData.Instance:GetTypeCardShowData(self.select_index))
	self.card_power_num:SetNumber(CardHandlebookData.Instance:GetAllPowerNum())
	local card_exp = string.format(Language.CardHandlebook.RoleCardExp, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RIDE_LEVEL))
	self.node_t_list.lbl_exp_num.node:setString(card_exp)
end

function CardHandlebookView:FlushCardTypeInfo()
	-- self.title:setString(Language.CardHandlebook.TypeName[self.select_index])
	local data = CardHandlebookData.Instance:GetCardAddtionStringDataByIdx(self.select_index, true)
	local rich_text = RichTextUtil.ParseRichText(self.node_t_list.rich_suit_attr.node, data[3], 20, COLOR3B.OLIVE)
	rich_text:setVerticalSpace(10)
	local obtain_str = string.format(Language.CardHandlebook.CardObtain, data[1], data[2])
	-- self.node_t_list.lbl_obtain_num.node:setString(obtain_str)
end

function CardHandlebookView:OnClickCardInfo(item)
	CardHandlebookCtrl.Instance:OpenCardCheckView(item:GetData())
end

function CardHandlebookView:OnBagItemChange(vo)
	self:OnFlushCardInfo()
end

-------------------
--图鉴render
-------------------
CardGridItemRender = CardGridItemRender or BaseClass(BaseRender)
function CardGridItemRender:__init()

end

function CardGridItemRender:__delete()
	if nil ~= self.card_power_num then
		self.card_power_num:DeleteMe()
		self.card_power_num = nil
	end	

	self.item_name = nil
end

function CardGridItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCardOnePowerNumberBar()
	self:CreateCardLevelStar()
	local size = self.view:getContentSize()
	self.can_jihu_img = XUI.CreateImageView(size.width / 2 -10, size.height - 100, ResPath.GetCommon("stamp_13"))
	self.can_jihu_img:setScale(0.8)
	self.view:addChild(self.can_jihu_img, 20)

	self.can_jihu_img:setVisible(false)
	self.node_tree.remind_flag.node:setVisible(false)
	self.node_tree.img_jihuo.node:setVisible(false)
	self.node_tree.img_card.node:setGrey(true)
	if self.node_tree.btn_up then 
		self.node_tree.btn_up.node:setTitleText(Language.Common.Activate)
		XUI.AddClickEventListener(self.node_tree.btn_up.node, BindTool.Bind(self.OnClickGetUpLevelBtn, self), true)
	end
end

function CardGridItemRender:CreateCardOnePowerNumberBar()
	self.card_power_num = NumberBar.New()
	self.card_power_num:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	self.card_power_num:SetPosition(70, 2)
	self.card_power_num:SetSpace(-5)
	self.card_power_num:GetView():setScale(0.7)
	self.card_power_num:SetGravity(NumberBarGravity.Left)
	self.node_tree.img_zdl.node:addChild(self.card_power_num:GetView(), 300, 300)
end

function CardGridItemRender:CreateCardLevelStar()
	self.card_stars = {}
	for i = 1, 10 do
		local start = XUI.CreateImageView((i - 1) * 20, 37, ResPath.GetCardHandlebook("star_1_lock"))
		self.node_tree.img_zdl.node:addChild(start, 99)
		start:setVisible(false)
		self.card_stars[i] = start
	end
end

function CardGridItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.remind_flag.node:setVisible(false)

	self:FlushItemName()

	self:FlushStar(self.data.level)

	self:FlushCardState()

	self.node_tree.img_card.node:loadTexture(ResPath.GetCardHandlebookImg(self.data.item_id))

	self.card_power_num:SetNumber(self.data.battle_num)

	self.node_tree.remind_flag.node:setVisible(self:IsRightButtonRemind())

	for i = 1, 10 do
		self.card_stars[i]:setVisible(self.data.is_jihuo)
	end

	self.node_tree.img_jiashi.node:setVisible(self.data.is_jihuo)

	local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(self.data.xl_index)[self.data.cw_index] - 1
	if self.node_tree.btn_up then 
		self.node_tree.btn_up.node:setVisible(not (self.data.is_jihuo and self.data.level == max_level))
	end
end

function CardGridItemRender:IsRightButtonRemind()
	local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(self.data.xl_index)[self.data.cw_index] - 1
	if self.data.is_jihuo then
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RIDE_LEVEL) >= CardHandlebookData.Instance.GetOneCardConsumNum(self.data.xl_index, self.data.cw_index, self.data.level) and self.data.level < max_level then
		 	return true
		end
	elseif BagData.Instance:GetOneItem(self.data.item_id) then
		return true
	end
	return false
end

--可激活或可升级
function CardGridItemRender:FlushCardState()
	self.node_tree.img_card.node:setGrey(not self.data.is_jihuo)
	self.node_tree.img_jihuo.node:setVisible(not self.data.is_jihuo)
	if not self.data.is_jihuo and BagData.Instance:GetOneItem(self.data.item_id) then 
		self.can_jihu_img:setVisible(true)
		CommonAction.ShowScaleAction(self.can_jihu_img, 0.7)
	else
		self.can_jihu_img:setVisible(false)
		self.can_jihu_img:stopAllActions()
	end
	if self.node_tree.btn_up then 
		self.node_tree.btn_up.node:setTitleText(self.data.is_jihuo and Language.Common.UpLevel or Language.Common.Activate)
	end
end

function CardGridItemRender:FlushItemName()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)

	local level_bg = CardHandlebookData.Instance.GetCardShowLevelByColor(color)
	self.node_tree.img_level.node:loadTexture(ResPath.GetCardHandlebook(string.format("level_%d_bg", level_bg)))

	self.item_name = ItemData.Instance:GetItemName(self.data.item_id)
	self.node_tree.lbl_card_name.node:setString(self.item_name)
	self.node_tree.lbl_card_name.node:setColor(Str2C3b(color))
	XUI.EnableOutline(self.node_tree.lbl_card_name.node)
end

function CardGridItemRender:FlushStar(num)
	for k,v in pairs(self.card_stars) do
		if num and num > 0 and num >= k then
			v:loadTexture(ResPath.GetCardHandlebook("star_1_select"))
		else
			v:loadTexture(ResPath.GetCardHandlebook("star_1_lock"))
		end
	end
end

function CardGridItemRender:OnClickGetUpLevelBtn()
	if nil == self.data then return end	
	if nil == self.data.level then 
		local series = BagData.Instance:GetOneItem(self.data.item_id) and BagData.Instance:GetOneItem(self.data.item_id).series
		if nil == BagData.Instance:GetOneItem(self.data.item_id) then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.CardHandlebook.JihuoTip)
			return
		end
		CardHandlebookCtrl.CardFireReq(series)
	else
		CardHandlebookCtrl.CardUpLevelReq(self.data.xl_index, self.data.cw_index)
	end
end

function CardGridItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height - 5, ResPath.GetCommon("img9_120"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 5)
end

return CardHandlebookView