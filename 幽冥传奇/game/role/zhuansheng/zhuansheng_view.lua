--------------------------------------------------------------------------------
-- 人物-转生
--------------------------------------------------------------------------------

local ZhuanshengView = ZhuanshengView or BaseClass(SubView)

function ZhuanshengView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"zhuansheng_ui_cfg", 1, {0}},
		{"zhuansheng_ui_cfg", 2, {0}},
		{"zhuansheng_ui_cfg", 4, {0}},
	}

	self.confirm_dialog = nil
	self.need_del_objs = {}
	require("scripts/game/role/zhuansheng/add_point_view").New(ViewDef.Role.ZhuanSheng.AddPoint)
end

function ZhuanshengView:__delete()

end

function ZhuanshengView:LoadCallBack()
	self:SetLayoutShow(false)

	ZhuangShengCtrl.SendExchangeCultivationRemainingTimeReq()
	self:CreateShopView()

	local ph = self.ph_list["ph_text_add_point"]
	self.rich_go_text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.AddPoint, 19, COLOR3B.GREEN)
	self.rich_go_text:setPosition(ph.x, ph.y)
	self.node_t_list.layout_common_role_1.layout_attr.node:addChild(self.rich_go_text, 90)
	XUI.AddClickEventListener(self.rich_go_text, BindTool.Bind(self.OnTextBtn, self, 1), true)

	local ph_duihuan = self.ph_list["ph_text_duihuan"]
	local text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.DuiHuan, 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x, ph_duihuan.y)
	self.node_t_list.layout_common_role_1.layout_show1.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnDuiHuan, self, 1), true)

	self.red_image = XUI.CreateImageView(ph_duihuan.x + 30, ph_duihuan.y, ResPath.GetMainUiImg("remind_flag"), true)
	self.red_image:setVisible(false)
	self.node_t_list.layout_common_role_1.layout_show1.node:addChild(self.red_image, 999)

	local ph_buy = self.ph_list["ph_text_buy"]
	local text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.Buy, 19, COLOR3B.GREEN)
	text:setPosition(ph_buy.x, ph_buy.y)
	self.node_t_list.layout_common_role_1.layout_show1.node:addChild(text, 90)
	XUI.AddClickEventListener(text, function () self:SetLayoutShow(true) end, true)

	self.node_t_list.btn_1.node:setTitleText("转生")
	self.node_t_list.btn_1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_1.node:setTitleFontSize(22)
	self.node_t_list.btn_1.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_1.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_1.node, 1)
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnClickZhuansheng, self))
	XUI.AddClickEventListener(self.node_t_list.btn_zs_ques.node, BindTool.Bind2(self.OpenTip, self))
	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind2(self.ReturnShow, self))

	local x, y = self.node_t_list.img_word_zhuang.node:getPosition()
	self.zhuan_num = self:NewObj(NumberBar)
	self.zhuan_num:Create(x - 35, y - 10, 0, 0, ResPath.GetCommon("num_131_"))
	self.zhuan_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_zhuansheng.node:addChild(self.zhuan_num:GetView(), 99)

	EventProxy.New(ZhuanshengData.Instance, self):AddEventListener(ZhuanshengData.LEVEL_EXCHANGE_TIMES_CHANGE, BindTool.Bind(self.OnlevelExchangeTimesChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))

	self.fight_power_view = self:NewObj(FightPowerView, 136, 35, self.node_t_list.layout_common_role_1.layout_fighting_power.node, 99)

	self:CreateAttrList()

	self:PlayEff(1145, 266, 325)

	EventProxy.New(ShopData.Instance, self):AddEventListener(ShopData.SHOP_LIMIT_CHANGE, BindTool.Bind(self.OnShopLimitChange, self))
end

function ZhuanshengView:ReturnShow()
	self:SetLayoutShow(false)
end

function ZhuanshengView:OpenTip()
	DescTip.Instance:SetContent(Language.DescTip.ZhuanshengContent, Language.DescTip.ZhuanshengTitle)
end

function ZhuanshengView:OnTextBtn()
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.ZhuanSheng.AddPoint)
end

function ZhuanshengView:OnDuiHuan()
	local function ok_callback()
		if ZhuanshengData.Instance:GetLeftExchangeTimes() < 0 then return end
		local exchange_cfg = ZhuanshengData.GetZhuanshengSoulExchangeCfg(#Circle.CircleSoulExchange - ZhuanshengData.Instance:GetLeftExchangeTimes() + 1)
		if exchange_cfg ~= nil then
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) >= exchange_cfg.Consume[1].count then
				ZhuangShengCtrl.SendExchangeTurnTimeReq()
			else
				TipCtrl.Instance:OpenGetStuffTip(493)
			end
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.ZhuanSheng.HasNoCount)
		end
	end

	if nil == self.confirm_dialog then
		self.confirm_dialog = Alert.New()
		self:AddObj("confirm_dialog")
	end

	local consume_data = ZhuanshengData.Instance:GetBuyConsumeValData()
	self.confirm_dialog:SetOkString(Language.Common.Confirm)
	self.confirm_dialog:SetCancelString(Language.Common.Cancel)
	self.confirm_dialog:SetLableString5(consume_data.consume_rich, RichVAlignment.VA_CENTER)
	self.confirm_dialog:SetLableString4(consume_data.btn_top_desc_rich, RichVAlignment.VA_CENTER)
	self.confirm_dialog:SetOkFunc(ok_callback)
	self.confirm_dialog:Open()
end

function ZhuanshengView:NewObj(type, ...)
	local obj = type.New(...)
	self.need_del_objs[#self.need_del_objs + 1] = obj
	return obj
end

function ZhuanshengView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}

	self.byg_list = nil
	self.zhuan_num = nil
	self.fight_power_view = nil
	if self.list_attr then
		self.list_attr:DeleteMe()
		self.list_attr = nil
	end
	if self.confirm_desc then
		self.confirm_desc:DeleteMe()
		self.confirm_desc = nil
	end
	if self.buy_list then
		self.buy_list:DeleteMe()
		self.buy_list = nil
	end
end

function ZhuanshengView:ShowIndexCallBack()
	self:Flush()
	self:SetLayoutShow(false)
end

function ZhuanshengView:CreateAttrList()
	local ph = self.ph_list.ph_cur_attr
	if nil == self.list_attr then
		self.list_attr = ListView.New()
		self.list_attr:Create(ph.x, ph.y, ph.w, ph.h, nil, AttrZhuanShengItemRender, nil, nil, self.ph_list.ph_item)
		self.node_t_list.layout_common_role_1.layout_attr.node:addChild(self.list_attr:GetView(), 100, 100)
		self.list_attr:GetView():setAnchorPoint(0.5, 0.5)
		self.list_attr:SetItemsInterval(8)
		self.list_attr:JumpToTop(true)
	end
	
end

function ZhuanshengView:CreateShopView()

	local ph = self.ph_list.ph_list
	if nil == self.buy_list then
		self.buy_list = ListView.New()
		self.buy_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CommonBuyRender, nil, nil, self.ph_list.ph_list_item)
		self.node_t_list.layout_common_role_1.layout_quiky_buy.node:addChild(self.buy_list:GetView(), 100, 100)
		self.buy_list:GetView():setAnchorPoint(0, 0)
		self.buy_list:SetItemsInterval(8)
		self.buy_list:JumpToTop(true)
	end
	local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.zhuangsheng]
	self.buy_list:SetDataList(data)
end

function ZhuanshengView:OnFlush()
	self:FlushParts()
	self:FlushAttrView()
	self:FlushShow()
	self:SetRedImgVis()
	--self:FlushGetValView()
end

function ZhuanshengView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.ACTOR_CIRCLE_SOUL or vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:Flush()
		self:SetRedImgVis()
	end
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		if vo.value > vo.old_value then
			self:PlayEff(1146, 271, 280, 1)
		end
	end
	if vo.key == OBJ_ATTR.ACTOR_COIN then
		self:SetRedImgVis()
	end
end


function ZhuanshengView:SetRedImgVis()
	local vis = ZhuanshengData.Instance:GetCanChangeLevel()
	self.red_image:setVisible(vis)
end

function ZhuanshengView:PlayEff(eff_id, x, y, times)
	local parent = self.node_t_list["layout_zhuansheng"].node
	local eff = AnimateSprite:create()
	parent:addChild(eff, 100)
	eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	eff:setAnimate(anim_path, anim_name, times or COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
end

function ZhuanshengView:OnShopLimitChange()
	local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.zhuangsheng]
	self.buy_list:SetDataList(data)
end

function ZhuanshengView:OnlevelExchangeTimesChange()
	self:Flush()
end

function ZhuanshengView:FlushAttrView()
	--PrintTable(ZhuanshengData.Instance:GetAttrList(ZhuanshengData.Instance.attr_point_list))
	self.list_attr:SetDataList(ZhuanshengData.Instance:GetAttrList(ZhuanshengData.Instance.attr_point_list))
	local power_value = CommonDataManager.GetAttrSetScore(ZhuanshengData.Instance:GetAttrList(ZhuanshengData.Instance.attr_point_list))
	self.fight_power_view:SetNumber(power_value)
	--self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(cur_cfg or {}))
	self.node_t_list.lbl_add_point.node:setString(ZhuanshengData.Instance:GetLeftPoint())

	local points = ZhuanshengData.Instance:GetLeftPoint()
	if points > 0 then
		UiInstanceMgr.AddRectEffect({node = self.rich_go_text, init_size_scale = 1.3, act_size_scale = 1.6, offset_w =10, offset_h = 3, color = COLOR3B.GREEN})
	else
		UiInstanceMgr.DelRectEffect(self.rich_go_text)
	end
end

function ZhuanshengView:FlushGetValView()
	self.byg_list:SetDataList(ZhuanshengData.Instance:GetBuyConsumeValData())
end

function ZhuanshengView:FlushParts()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local is_max = ZhuanshengData.Instance:IsMax(circle + 1)
	
	self.zhuan_num:SetNumber(circle)

	-- 消耗
	local consume_cfg = ZhuanshengData.GetZhuanshengConsumeCfg(circle + 1)
	local consume_has_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE_SOUL)
	local content = ""
	local require_level = ""
	local is_enough = false
	if is_max then
		content = "转生已达到最高级"
		--require_level = Circle.CircleConsumes[circle].reqLevel
	else
		local consume_need_num = consume_cfg.consumes[1].count
		is_enough = consume_has_num >= consume_need_num
		local colorstr = is_enough and COLORSTR.GREEN or COLORSTR.RED
		content = string.format("{color;%s;%d}{color;1eff00;/%d}", colorstr, consume_has_num, consume_need_num)
		--require_level = Circle.CircleConsumes[circle + 1].reqLevel
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_btn_under.node, content)
	self.node_t_list.lbl_require_level.node:setString("")

	self.node_t_list.btn_1.node:setVisible(not is_max)
	self.node_t_list.btn_1.remind_eff:setVisible(is_enough)
	--self.node_t_list.img_bg222.node:setVisible(false)
end

function ZhuanshengView:OnClickZhuansheng()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)

	local next_circcle = circle + 1 
	local config = Circle.CircleConsumes[next_circcle]
	if config then
		local consume_cfg = ZhuanshengData.GetZhuanshengConsumeCfg(next_circcle)
		local consume_has_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE_SOUL)
		local consume_need_num = consume_cfg.consumes[1].count
		if consume_has_num >=consume_need_num then

			ZhuangShengCtrl.SendTurnReq()
		else
			self:SetLayoutShow(true)
		end
		
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ZhuanSheng.TipsDesc)
	end
end

function ZhuanshengView:OnClickTip()
	-- DescTip.Instance:SetContent(Language.Role.LunHuiExchangeTips, Language.Role.LunHuiExchangeTipsTitle)
end


function ZhuanshengView:SetLayoutShow(vis)
	self.node_t_list.layout_quiky_buy.node:setVisible(vis)
	self.node_t_list.layout_fighting_power.node:setVisible(not vis)
	self.node_t_list.layout_attr.node:setVisible(not vis)
end


function ZhuanshengView:FlushShow( ... )
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local next_circcle = circle + 1 
	local config = Circle.CircleConsumes[next_circcle]
	local text = ""
	if config then
		local max_level = GlobalConfig.maxLevel[circle + 1]
		text = string.format(Language.ZhuanSheng.ZhuanShengDesc, next_circcle, max_level)
	else
		text = Language.ZhuanSheng.ZhuanShengMax
	end
	if self.node_t_list.rich_zhang_sheng_desc then
		RichTextUtil.ParseRichText(self.node_t_list.rich_zhang_sheng_desc.node, text)
		XUI.RichTextSetCenter(self.node_t_list.rich_zhang_sheng_desc.node)
	end
end

AttrZhuanShengItemRender = AttrZhuanShengItemRender or BaseClass(BaseRender)
function AttrZhuanShengItemRender:__init( ... )
	-- body
end


function AttrZhuanShengItemRender:__delete( ... )
	-- body
end

function AttrZhuanShengItemRender:CreateChild( ... )
	BaseRender.CreateChild(self)
end


function AttrZhuanShengItemRender:OnFlush( ... )
	if self.data == nil then
		return 
	end
	self.node_tree.lbl_this_time_poist.node:setString(self.data.value)
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str)
end

function BaseRender:CreateSelectEffect()

end

return ZhuanshengView
