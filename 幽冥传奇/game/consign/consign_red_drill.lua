-- 红钻界面

local RedDrillChangePage = BaseClass(SubView)
local RedDiamondItemRender = RedDiamondItemRender or BaseClass(BaseRender)

function RedDrillChangePage:__init()
	self.texture_path_list[1] = 'res/xui/consign.png'
	self.config_tab = {
		{"consign_ui_cfg", 6, {0}},
	}
	if RedDrillChangePage.Instance then
		ErrorLog("[ConsignData] Attemp to create a singleton twice !")
	end
	
	RedDrillChangePage.Instance = self
end

function RedDrillChangePage:LoadCallBack()
	self:UpdateGridScroll()
	XUI.AddClickEventListener(self.node_t_list.btn_duihuan.node, BindTool.Bind(self.OnExchange, self))

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function RedDrillChangePage:ReleaseCallBack()
	if self.grid_scroll_list then
		self.grid_scroll_list:DeleteMe()
		self.grid_scroll_list = nil
	end
end

function RedDrillChangePage:OnExchange()
	ViewManager.Instance:OpenViewByDef(ViewDef.RedDrillExchange)
end

function RedDrillChangePage:ShowIndexCallBack()
	self:Flush()
end

function RedDrillChangePage:UpdateGridScroll()
	if nil == self.node_t_list.layout_red_zuan then
		return
	end

	if nil == self.grid_scroll_list then
		local ph = self.ph_list.ph_red_zuan_list
		local ph_item = self.ph_list.ph_red_zuan_item
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, ph_item.h, RedDiamondItemRender, ScrollDir.Vertical, false, ph_item)
		self.grid_scroll_list = grid_scroll
		self.node_t_list.layout_red_zuan.node:addChild(grid_scroll:GetView(), 100)
	end

	self.grid_scroll_list:SetDataList(ConsignData.Instance:GetRechargeCfg())
	self.grid_scroll_list:JumpToTop()
end

function RedDrillChangePage:OnFlush(param_t)
	local red_zuan = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS))
	self.node_t_list.lbl_my_zuan.node:setString(red_zuan)
end

function RedDrillChangePage:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_RED_DIAMONDS then
	-- or key == OBJ_ATTR.ACTOR_BIND_GOLD
	-- or key == OBJ_ATTR.ACTOR_GOLD
	-- or key == OBJ_ATTR.ACTOR_BRAVE_POINT
	-- or OBJ_ATTR.ACTOR_STALL_GRID_COUNT
	-- or OBJ_ATTR.ACTOR_BAG_BUY_GRID_COUNT then
		self:Flush()
	end
end

------------------------------------------------------
-- RedDiamondItemRender
------------------------------------------------------
function RedDiamondItemRender:__init()
end

function RedDiamondItemRender:__delete()
	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end
	self.effect = nil
end

function RedDiamondItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- if self.cache_select and self.is_select then
	-- 	self.cache_select = false
	-- 	self:CreateSelectEffect()
	-- end

	-- self.rich_give_bind_gold = RichTextUtil.ParseRichText(nil, "", 19, COLOR3B.YELLOW,
	-- 	142, 107 - 27, 200, 30)
	-- XUI.RichTextSetCenter(self.rich_give_bind_gold)
	-- self.view:addChild(self.rich_give_bind_gold, 11)

	-- self.effect=AnimateSprite:create()
	-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(404)
	-- self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	-- if nil~=self.effect then
	-- 	self.effect:setPosition(200,110)
	-- 	self.view:addChild(self.effect, 101,101)
	-- end

	local ph = self.ph_list["ph_money"]
	local number = NumberBar.New()
	number:Create(ph.x, ph.y, ph.w, ph.h, ResPath.GetCommon("num_1_"))
	number:SetGravity(NumberBarGravity.Center)
	number:SetHasPlus(true)
	number:SetSpace(-5)
	self.view:addChild(number:GetView(), 20)
	self.money = number
end

function RedDiamondItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
	ChongzhiCtrl.BuyRedDiamond(self.data.money)
end

function RedDiamondItemRender:OnFlush()
	if nil == self.data then
		return
	end

	self.node_tree.lbl_money.node:setString(self.data.gold .. Language.Common.RedDiamond)
	
	local money_str = self.data.money_type or Language.Common.MoneyTypeStr[0]
	self.money:SetNumber(self.data.money)
	
	-- if ChongzhiData.Instance:GetIsOpenDouble() == 1 then
	-- 	local times = ChongzhiData.Instance:GetMaxTimes()
	-- 	self.effect:setVisible(self.data.show_double < times)
	-- 	if self.data.show_double < times then
	-- 		self.node_tree.lbl_double_times.node:setString(string.format(Language.ChongZhi.RebateTimes,times - self.data.show_double))
	-- 		XUI.EnableOutline(self.node_tree["lbl_double_times"].node)
	-- 	else
	-- 		self.node_tree.lbl_double_times.node:setString(" ")
	-- 	end
	-- else
	-- 	self.effect:setVisible(false)
	-- 	self.node_tree.lbl_double_times.node:setString(" ")
	-- end

	local index = self.index > 8 and 8 or self.index
	self.node_tree["img_bg"].node:loadTexture(ResPath.GetBigPainting("hz_bg_" .. index))
end

function RedDiamondItemRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end

return RedDrillChangePage 