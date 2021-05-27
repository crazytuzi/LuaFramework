local LunhuiView = LunhuiView or BaseClass(SubView)

function LunhuiView:__init()
	self.texture_path_list = {
		'res/xui/lunhui.png',
	}
	self.config_tab = {
		{"lunhui_ui_cfg", 1, {0}},
		{"lunhui_ui_cfg", 2, {0}},
		{"lunhui_ui_cfg", 3, {0}, false},
		{"lunhui_ui_cfg", 4, {0}},
	}

	self.need_del_objs = {}
end

function LunhuiView:__delete()
end

function LunhuiView:LoadCallBack()
	self:GetProgressBar()
	self:CreateLhRotateEff()
	self:InitTextBtn()
	self:SetLayoutShow(false)
	self:CreateAttrList()
	self:CreateShopView()

	-- local size = self.node_t_list.img9_title_1.node:getContentSize()
	-- self.node_t_list.img9_title_1.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "轮回属性", 1))

	XUI.RichTextSetCenter(self.node_t_list.rich_btn_under.node)

	self.node_t_list.btn_1.node:setTitleText("")
	self.node_t_list.btn_1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_1.node:setTitleFontSize(22)
	self.node_t_list.btn_1.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_1.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_1.node, 1)
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnClickLunHui, self))

	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, BindTool.Bind(self.OnClickLunHuiExchangeTips, self))
	XUI.AddClickEventListener(self.node_t_list.layout_quiky_buy.btn_return.node, BindTool.Bind2(self.ReturnShow, self))

	-- self.cur_attr = self:CreateAttrView(self.node_t_list.layout_lunhui.node, self.ph_list.ph_cur_attr)
	-- self.next_attr = self:CreateAttrView(self.node_t_list.layout_lunhui.node, self.ph_list.ph_next_attr)

	-- self.fight_power_view = FightPowerView.New(270, 605, self.node_t_list.layout_lunhui.node, 99)
	-- self.fight_power_view:SetScale(0.8)

	EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.OnLunHuiDataChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
end

function LunhuiView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}

	if self.confirm_dialog then
		self.confirm_dialog:DeleteMe()
	    self.confirm_dialog = nil
	end

	-- if self.fight_power_view then
	-- 	self.fight_power_view:DeleteMe()
	-- 	self.fight_power_view = nil
	-- end

	if nil ~= self.lh_level_rotate_list then
		for k, v in pairs(self.lh_level_rotate_list) do
			v:DeleteMe()
		end
		self.lh_level_rotate_list = nil
	end

	if self.list_attr then
		self.list_attr:DeleteMe()
		self.list_attr = nil
	end

	if self.buy_list then
		self.buy_list:DeleteMe()
		self.buy_list = nil
	end

	self.max_txt = nil
	self.hp_bar = nil
	self.hp_top_eff = nil
	self.pro_eff = nil
end

function LunhuiView:ShowIndexCallBack()
	self:Flush()
	self:SetLayoutShow(false)
end

function LunhuiView:GetProgressBar()
	local ph = {x = 284, y = 394, h = 160, w = 160}
	-- 进度条光效
	self.hp_top_eff = RenderUnit.CreateEffect(10069, self.node_t_list.layout_lunhui.node, 30, nil, nil, ph.x, 0)
	self.hp_top_eff:setScale(0.7)
	self.hp_top_eff:setVisible(false)
	self.onTopEffHpChange = function (top_height)
		self.hp_top_eff:setPositionY(top_height + ph.y-80)
		local rate = top_height / ph.h
		if rate > 0.5 then
			rate = 1 - rate
		end
		self.hp_top_eff:setScale(rate + 0.6)
		self.hp_top_eff:setVisible(rate >= 0.15)
	end
	
	local hp_bar_bg_node = XUI.CreateLayout(0, 0, ph.w,ph.h)
	local hp_effect = RenderUnit.CreateEffect(10058, nil, 998)
	hp_bar_bg_node:addChild(hp_effect)
	self.hp_bar = MaskProgressBar.New(self.node_t_list.layout_lunhui.node,hp_bar_bg_node,
	 								XUI.CreateImageViewScale9(-ph.w / 2, -ph.h / 2, ph.w, ph.h, ResPath.GetCommon("img9_160"), true,cc.rect(5,5,10,10)),
	 								cc.size(ph.w, ph.h),nil,function (top_height)
	 									self.onTopEffHpChange(top_height)
	 								end)
	self.hp_bar:getView():setPosition(ph.x + 2, ph.y)
	self.hp_bar:getView():setLocalZOrder(5)
	self.hp_bar:setProgressPercent(0)

	-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(10069)
	-- self.pro_eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	-- self.pro_eff:setPosition(287, 338)
	-- self.node_t_list.layout_lunhui.node:addChild(self.pro_eff, 21)
end

function LunhuiView:CreateAttrList()
	local ph = self.ph_list.ph_get_value
	if nil == self.list_attr then
		self.list_attr = ListView.New()
		self.list_attr:Create(ph.x, ph.y, ph.w, ph.h, nil, AttrLunhuiRender, nil, nil, self.ph_list.ph_attr_txt_item)
		self.node_t_list.layout_attr.node:addChild(self.list_attr:GetView(), 101, 100)
		self.list_attr:GetView():setAnchorPoint(0.5, 0.5)
		self.list_attr:SetItemsInterval(8)
		self.list_attr:JumpToTop(true)
	end
end

function LunhuiView:CreateShopView()

	local ph = self.ph_list.ph_list
	if nil == self.buy_list then
		self.buy_list = ListView.New()
		self.buy_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CommonBuyRender, nil, nil, self.ph_list.ph_list_item)
		self.node_t_list.layout_quiky_buy.node:addChild(self.buy_list:GetView(), 100, 100)
		self.buy_list:GetView():setAnchorPoint(0, 0)
		self.buy_list:SetItemsInterval(8)
		self.buy_list:JumpToTop(true)
	end
	local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.lunhui]
	self.buy_list:SetDataList(data)
end

-- function LunhuiView:CreateAttrView(parent_node, ph)
-- 	local attr_view = AttrView.New(300, 25, 20)
-- 	self.need_del_objs[#self.need_del_objs + 1] = attr_view
-- 	attr_view:SetDefTitleText("")
-- 	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
-- 	attr_view:GetView():setPosition(ph.x, ph.y)
-- 	attr_view:GetView():setAnchorPoint(0.5, 0.5)
-- 	attr_view:SetContentWH(ph.w, ph.h)
-- 	parent_node:addChild(attr_view:GetView(), 50)
-- 	return attr_view
-- end

function LunhuiView:OnFlush()
	self:FlushParts()
	self:FlushAttrView()
	self:FlushGetLunhuiValView()
	self:SetRedImgVis()
end

function LunhuiView:InitTextBtn()
	local ph
	local text_btn
	local parent = self.node_t_list.layout_show1.node
	ph = self.ph_list["ph_text_btn_1"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self), true)

	self.red_image = XUI.CreateImageView(ph.x + 30, ph.y, ResPath.GetMainUiImg("remind_flag"), true)
	self.red_image:setVisible(false)
	parent:addChild(self.red_image, 999)

	ph = self.ph_list["ph_text_btn_2"]
	text_btn = RichTextUtil.CreateLinkText(Language.Tip.ButtonLabel[17], 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, function () self:SetLayoutShow(true) end, true)
end

function LunhuiView:OnLunHuiDataChange()
	self:Flush()
end

function LunhuiView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:FlushGetLunhuiValView()
		self:SetRedImgVis()
	end
end

function LunhuiView:ReturnShow( ... )
	self:SetLayoutShow(false)
end

function LunhuiView:SetLayoutShow(vis)
	self.node_t_list.layout_quiky_buy.node:setVisible(vis)
	self.node_t_list.layout_attr.node:setVisible(not vis)
end

function LunhuiView:FlushAttrView()
	local cur_cfg = LunHuiData.Instance:GetRoleLunHuiAttrCfg()
	self.list_attr:SetDataList(cur_cfg)

	-- self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(cur_cfg))

	-- local level = LunHuiData.Instance:GetLunLevel()
	-- local attr_cfg = LunHuiData.Instance:GetRoleLunHuiAttrCfg(nil, level + 1)
	-- self.next_attr:SetData(attr_cfg)
end

function LunhuiView:SetRedImgVis()
	local vis = LunHuiData.Instance:GetLunLeftExchangeNum() > 0
	self.red_image:setVisible(vis)
end

function LunhuiView:FlushGetLunhuiValView()
	local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.lunhui]
	self.buy_list:SetDataList(data)

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local is_lv = role_level < LunHui.LunHuiValueExchange.lvLimit
	self.node_t_list.lbl_need_lv.node:setVisible(is_lv)
	self.node_t_list.lbl_need_lv.node:setString(string.format("需要%s级", LunHui.LunHuiValueExchange.lvLimit))
	
end

function LunhuiView:FlushParts()
	local level = LunHuiData.Instance:GetLunLevel()
	local grade = LunHuiData.Instance:GetLunGrade()
	local is_max = LunHuiData.Instance:IsLunHuiMax()
 
	self.node_t_list.img_cur_dao.node:loadTexture(ResPath.GetLunHui("lunhui_level_" .. math.max(grade, 0)), true)
	-- self.node_t_list.img_jing.node:loadTexture(ResPath.GetLunHui("word_jing_" .. math.max(level, 1)), true)

	-- 消耗
	local grade = LunHuiData.Instance:GetLunGrade()
	local consume_has_num = LunHuiData.Instance:GetConsumeNum()
	local content = ""
	local is_enough = false
	local consume_need_num = LunHuiData.Instance:GetNextLevelConsumeNum()
	if is_max then
	else
		is_enough = consume_has_num >= consume_need_num
		local colorstr = is_enough and COLORSTR.GREEN or COLORSTR.RED
		content = string.format("{color;e8e1c5;消耗业力：}{color;%s;%d}{color;1eff00;/%d}", colorstr, consume_has_num, consume_need_num)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_btn_under.node, content)

	local pro_num = consume_has_num / consume_need_num
	pro_num = pro_num > 1 and 1 or pro_num
	self.hp_bar:getView():setVisible(pro_num ~= 0)
	self.hp_bar:setProgressPercent(pro_num)

	self.node_t_list.btn_1.remind_eff:setVisible(is_enough)
	local btn_title_txt = 0 == consume_need_num and "免费轮回" or "轮回"
	self.node_t_list.btn_1.node:setTitleText(btn_title_txt)
	self.node_t_list.btn_1.node:setVisible(not is_max)
	self.node_t_list.rich_btn_under.node:setVisible(not is_max)

	if is_max then
		if nil == self.max_txt then
			self.max_txt = XUI.CreateText(390, 104, 300, 40, nil, "已满级", nil, 28, COLOR3B.YELLOW)
			self.node_t_list.layout_lunhui.node:addChild(self.max_txt, 30)
		end
		self.max_txt:setVisible(true)
	elseif nil ~= self.max_txt then
		self.max_txt:setVisible(false)
	end

	for k, v in pairs(self.lh_level_rotate_list) do
		v:Flush()
	end
end

-- 创建轮回旋转境界
function LunhuiView:CreateLhRotateEff()
	local max_level = LunHuiData.Instance:GetLunHuiMaxLevel()
	local x, y = self.node_t_list.img_ball_light.node:getPosition()
	self.lh_level_rotate_list = {}
	for i = 1, max_level do
		local render = LunHuiLevelRender.New(i, nil, nil, nil, {x = x, y = y})
		render:StartRoll()
		render:Flush()
		self.node_t_list.layout_lunhui.node:addChild(render:GetView(), 300)
		table.insert(self.lh_level_rotate_list, render)
	end
end

function LunhuiView:OnClickLunHui()
	LunHuiCtrl.SendLunHuiReq(1)
end

function LunhuiView:OnClickLunHuiExchangeTips()
	DescTip.Instance:SetContent(Language.Role.LunHuiExchangeTips, Language.Role.LunHuiExchangeTipsTitle)
end

function LunhuiView:OnTextBtn()
    if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < LunHui.LunHuiValueExchange.lvLimit then
    	local txt = string.format("等级不满%s级，兑换未开启", LunHui.LunHuiValueExchange.lvLimit)
		SysMsgCtrl.Instance:FloatingTopRightText(txt)
		return
    end

	local time = LunHuiData.Instance:GetLunLeftExchangeNum() == 0
    if time then
    	SysMsgCtrl.Instance:FloatingTopRightText("兑换次数已用完")
    	return
    end
    local consume_data = LunHuiData.Instance:GetLvExchangeData()
	local function ok_callback()
		if consume_data.dh_time <= 0 then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.ZhuanSheng.LunhuiNoCount)
		else
    		LunHuiCtrl.SendLunHuiReq(2)
    	end
    end
    self.confirm_dialog = Alert.New()
    self.confirm_dialog:SetOkString(Language.Common.Confirm)
    self.confirm_dialog:SetCancelString(Language.Common.Cancel)
    self.confirm_dialog:SetLableString5(consume_data.consume_rich, RichVAlignment.VA_CENTER)
    self.confirm_dialog:SetLableString4(consume_data.btn_top_desc_rich, RichVAlignment.VA_CENTER)
    self.confirm_dialog:SetOkFunc(ok_callback)
    self.confirm_dialog:Open()
end

----------------------------------------------------------
-- LunHuiLevelRender  轮回境界显示render
---------------------------------------------------------------
LunHuiLevelRender = LunHuiLevelRender or BaseClass(BaseRender)

function LunHuiLevelRender:__init(show_id, w, h, r, c_p)
	self.width = w or 100
	self.height = h or 100
	self.show_id = show_id or 1
	self.angle_val = - (show_id - 1) * 360 / 6
	self.r = r or 146 - 11
	self.c_p = c_p or {x = 253, y = 384}
end

function LunHuiLevelRender:__delete()
	if nil ~= self.lh_update_timer then
		GlobalTimerQuest:CancelQuest(self.lh_update_timer)
		self.lh_update_timer = nil
	end
end

function LunHuiLevelRender:CreateChild()
	BaseRender.CreateChild(self)

	self.view:setContentWH(self.width, self.height)
	self.view:setAnchorPoint(0.5, 0.5)
	local c_x = self.width / 2
	local c_y = self.height / 2
	self.img1 = XUI.CreateImageView(c_x, c_y, ResPath.GetLunHui("lunhui_cell"), true)
	self.img2 = XUI.CreateImageView(c_x, c_y, ResPath.GetLunHui("lunhui_" .. self.show_id))
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(10070)
	self.eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	self.eff:setVisible(true)
	self.eff:setPosition(c_x+2, c_y-3)
	self.eff:setScale(1.1)
	self.view:addChild(self.img1, 0)
	self.view:addChild(self.img2, 20)
	self.view:addChild(self.eff, 21)

	self:Flush()
end

function LunHuiLevelRender:OnFlush()
	local cur_lh_level = LunHuiData.Instance:GetLunLevel()
	local is_act = cur_lh_level >= self.show_id
	self.eff:setVisible(is_act)
	self.img2:setGrey(not is_act)
end

function LunHuiLevelRender:StartRoll()
	if nil ~= self.lh_update_timer then
		GlobalTimerQuest:CancelQuest(self.lh_update_timer)
	end
	self.lh_update_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Update, self), 0.03)
	self:Update()
end

function LunHuiLevelRender:Update()
	local pi = 3.14
	local angle_interval = -0.7

	self.angle_val = (self.angle_val + angle_interval) % 360
	local x = self.c_p.x + math.sin(self.angle_val / 180 * pi) * self.r
	local y = self.c_p.y - math.cos(self.angle_val / 180 * pi) * self.r

	self.view:setPosition(x, y)
end

function LunHuiLevelRender:CreateSelectEffect()
end

AttrLunhuiRender = AttrLunhuiRender or BaseClass(BaseRender)
function AttrLunhuiRender:__init()
	-- body
end


function AttrLunhuiRender:__delete()
	-- body
end

function AttrLunhuiRender:CreateChild()
	BaseRender.CreateChild(self)
end


function AttrLunhuiRender:OnFlush()
	if self.data == nil then
		return 
	end

	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str)
	local _, n_attr = LunHuiData.Instance:GetRoleLunHuiAttrCfg()
	if n_attr then
		self.node_tree.img_arrow.node:setVisible(true)
		self.node_tree.lbl_n_attr.node:setString(n_attr[self.index].value_str)
	else
		self.node_tree.img_arrow.node:setVisible(false)
		self.node_tree.lbl_n_attr.node:setString("")
	end
end

function AttrLunhuiRender:CreateSelectEffect()

end

return LunhuiView
