InnerView = InnerView or BaseClass(SubView)

function InnerView:__init()
	self.texture_path_list = {
		'res/xui/inner.png',
	}
	self.config_tab = {
		{"inner_ui_cfg", 1, {0}},
		{"inner_ui_cfg", 2, {0}},
		{"inner_ui_cfg", 3, {0}},
	}

	self.need_del_objs = {}
	self.stage_list = {}
    self.ball_to_stage_eff = {}
    self.fly_eff_to_ball = false
end

function InnerView:__delete()
end

function InnerView:NewObj(type, ...)
	local obj = type.New(...)
	self.need_del_objs[#self.need_del_objs + 1] = obj
	return obj
end

function InnerView:LoadCallBack()
    self.is_first_open = true
	-- 重数
    local dian_x, dian_y = self.node_t_list.img_dian.node:getPosition()
    self.chong_num = self:NewObj(NumberBar)
    self.chong_num:SetGravity(NumberBarGravity.Center)
    self.chong_num:Create(dian_x, dian_y + 24, 0, 0, ResPath.GetInner("num_135_"))
    self.node_t_list.layout_inner.node:addChild(self.chong_num:GetView(), 100)

    -- 台子
    local stage_num = InnerData.STAGE_NUM
    local circle_x, circle_y = self.node_t_list.img_frame.node:getPosition()
    circle_y = circle_y - 60
    local begin_angle = 60
    local interval_angle = (360 - begin_angle * 2) / (stage_num - 1)
    local r = self.node_t_list.img_frame.node:getContentSize().width / 2 - 5

    self.stage_list = {}
    local x, y = 0, 0
    local angle = 0
    for i = 1, stage_num do
        angle = (begin_angle + interval_angle * (i - 1)) % 360
        x = circle_x - math.sin(angle / 180 * math.pi) * r
        y = circle_y - math.cos(angle / 180 * math.pi) * r

        self.stage_list[i] = self:NewObj(InnerView.InnerStageRender, i, x, y, cc.p(circle_x, circle_y), self.node_t_list.layout_inner.node)
    end

    local x, y = self.node_t_list.img_ball_bg.node:getPosition()
    local bottom_h = 100
    local bar_size = cc.size(400, 135 + bottom_h * 2)
    local bar_layout = XUI.CreateLayout(x, y - bar_size.height / 2, bar_size.width, bar_size.height)
    bar_layout:setAnchorPoint(0.5, 0)
    bar_layout:setClippingEnabled(true)
    self.node_t_list.layout_inner.node:addChild(bar_layout, 99)
    function bar_layout:setPercent(percent)
        local height = 0
        if percent > 0 then
        	height = percent >= 100 and bar_size.height or math.max(percent * 0.01 * (bar_size.height - bottom_h * 2) + bottom_h, 0)            
        end
    	self:setContentSize(cc.size(bar_size.width, height))
    end
    local anim_path, anim_name = ResPath.GetEffectUiAnimPath(60)
    local ball_eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect / 1.2, false)
    ball_eff:setPosition(bar_size.width / 2, bar_size.height / 2 - 8)
    bar_layout:addChild(ball_eff, 10)

    self.ball_bar = self:NewObj(ProgressBar)
    self.ball_bar:SetView(bar_layout)

    XUI.RichTextSetCenter(self.node_t_list.rich_btn_under.node)

    self.node_t_list.btn_1.node:setTitleText("")
	self.node_t_list.btn_1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_1.node:setTitleFontSize(22)
	self.node_t_list.btn_1.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnClickUpBtn, self))

    self.node_t_list.btn_2.node:setTitleText("")
    self.node_t_list.btn_2.node:setTitleFontName(COMMON_CONSTS.FONT)
    self.node_t_list.btn_2.node:setTitleFontSize(22)
    self.node_t_list.btn_2.node:setTitleColor(COLOR3B.G_W2)
    self.node_t_list.btn_2.node:setTitleText("一键修炼")
    XUI.AddClickEventListener(self.node_t_list.btn_2.node, BindTool.Bind(self.OnClickOneKeyUpBtn, self))

    local size = self.node_t_list.img9_title_1.node:getContentSize()
	self.node_t_list.img9_title_1.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "内功总属性", 1))

	local size = self.node_t_list.img9_title_2.node:getContentSize()
	self.node_t_list.img9_title_2.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "内功说明", 1))

	self.fight_power_view = self:NewObj(FightPowerView, 288, 121, self.node_t_list.layout_inner.node, 99)
	self.fight_power_view:SetScale(0.8)

	local ph = self.ph_list.ph_attr
	self.attr_view = self:NewObj(AttrView, 300, 25, 20)
	self.attr_view:SetDefTitleText("")
	self.attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.attr_view:GetView():setPosition(ph.x, ph.y)
	self.attr_view:GetView():setAnchorPoint(0.5, 0.5)
	self.attr_view:SetContentWH(ph.w, ph.h)
	self.node_t_list.layout_inner.node:addChild(self.attr_view:GetView(), 50)
	
	local ph = self.ph_list.ph_layout_tips
	local content = CLIENT_GAME_GLOBAL_CFG.inner_tip_content
	self.tips_rich = RichTextUtil.ParseRichText(nil, content, 20, nil, ph.x, ph.y, ph.w, ph.h, COLOR3B.OLIVE)
	self.tips_rich:setVerticalSpace(15)
	self.node_t_list.layout_inner.node:addChild(self.tips_rich, 10)

	for i = InnerData.InnerEquipPos.ShaYuDanPos, InnerData.InnerEquipPos.InnerEquipPosMax do
		local node_t = self.node_t_list["layout_equip_" .. i]
		if node_t then
        --更换按钮图片
        local item_id = i + 3514
        local item_cfg = ItemData.Instance:GetItemConfig(item_id)
        node_t.img_bg.node:loadTexture(ResPath.GetItem(item_cfg.icon), false)
        node_t.node:setScale(0.8)

		XUI.AddClickEventListener(node_t.node, BindTool.Bind(self.OnClickEquip, self, i), true)
		end
	end

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
	EventProxy.New(InnerData.Instance, self):AddEventListener(InnerData.EQUIP_CHANGE, BindTool.Bind(self.OnEquipChange, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function InnerView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}

    GlobalTimerQuest:CancelQuest(self.fly_eff_to_ball_timer)
    self.fly_eff_to_ball_timer = nil

	self.stage_list = {}
	self.fight_power_view = nil
    self.ball_bar = nil
	self.attr_view = nil
	self.tips_rich = nil
    self.ball_to_stage_eff = {}

    self.fly_eff_to_ball = false
end

function InnerView:CloseCallBack(...)
    self.is_first_open = true
end

function InnerView:ShowIndexCallBack()
	self:Flush()
end

function InnerView:OnFlush()
    local cur_chong_num = InnerData.Instance:GetChongNum()
    if nil ~= self.last_chong_num and cur_chong_num > 1 and self.last_chong_num < cur_chong_num then
        self:PlayBigAction()
    end
	self.chong_num:SetNumber(cur_chong_num)
    self.last_chong_num = cur_chong_num

    self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(InnerData.Instance:GetAllAttrs()))

    self:FlushBall()
    self:FlushStage()
    self:FlushAttrView()
    self:FlushBtn()
    self:FlushConsumeDesc()
    self:FlushInnerEquip()
    self.is_first_open = false
end

----------------------------------------------------------------------------------------------------------------
-- 播放凝气动画
function InnerView:PlayBigAction()
    if nil ~= self.fly_eff_to_ball_timer then
        return
    end

    for k, v in pairs(self.stage_list) do
        v:FlyEffToCircleCenter(self)
    end
    self.fly_eff_to_ball_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlyEffToBall, self), 0.8)
end

local effect_cfg = {
    [1] = {x = 0, y = 160, rota = -96, scale = 0.75},
    [2] = {x = 0, y = 160, rota = -70, scale = 0.80},
    [3] = {x = 0, y = 160, rota = -45, scale = 0.85},
    [4] = {x = 0, y = 160, rota = -22, scale = 0.95},
    [5] = {x = 0, y = 160, rota = 0, scale = 1.00},
    [6] = {x = 0, y = 160, rota = 22, scale = 0.97},
    [7] = {x = 0, y = 160, rota = 44, scale = 0.95},
    [8] = {x = 0, y = 160, rota = 66, scale = 0.88},
    [9] = {x = 0, y = 160, rota = 90, scale = 0.78},
    [10] = {x = 0, y = 160, rota = 118, scale = 0.72},
}
function InnerView:PlayOneEffectToStage(index)
    local play_cfg = effect_cfg[index]
    if nil == play_cfg then
        return
    end

    if nil == self.ball_to_stage_eff[index] then
        local anim_path, anim_name = ResPath.GetEffectUiAnimPath(59)
        self.ball_to_stage_eff[index] = AnimateSprite:create(anim_path, anim_name, 1, FrameTime.Effect, false)
        self.ball_to_stage_eff[index]:addEventListener(function(sender, event_type, frame)
            if event_type == AnimateEventType.Stop then
                self.stage_list[index]:SetShowEffect(InnerData.Instance:GetStateIsAct(index), true)
            end
        end)
        self.node_t_list.layout_inner.node:addChild(self.ball_to_stage_eff[index], 300)
    else
        self.ball_to_stage_eff[index]:setStop()
        local anim_path, anim_name = ResPath.GetEffectUiAnimPath(59)
        self.ball_to_stage_eff[index]:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
    end

    local eff = self.ball_to_stage_eff[index]
    local x, y = self.ball_bar:GetView():getPosition()
    eff:setPosition(x + play_cfg.x, y + play_cfg.y)
    eff:setRotation(play_cfg.rota)
    eff:setScale(play_cfg.scale)
end

function InnerView:FlushBall()
end

function InnerView:FlyEffToBall()
    GlobalTimerQuest:CancelQuest(self.fly_eff_to_ball_timer)
    self.fly_eff_to_ball_timer = nil
    local x, y = self.ball_bar:GetView():getPosition()
    RenderUnit.PlayEffectOnce(61, self.node_t_list.layout_inner.node, 50, x + 3, y + 165, true, nil, FrameTime.Effect / 1.2)

    self:Flush()
end

function InnerView:FlushStage()
    if self.fly_eff_to_ball_timer then
        return
    end

    for k, v in pairs(self.stage_list) do
        local is_act = InnerData.Instance:GetStateIsAct(v:GetIndex())
        if nil ~= v._show_effect and not v._show_effect and is_act then
            self:PlayOneEffectToStage(k)
            self.ball_bar:SetPercent(100)
        end
        if nil == v._show_effect then
            v:SetShowEffect(is_act)
        end
        v._show_effect = is_act
    end

    local cur_percent = InnerData.Instance:GetExpPercent()
    self.ball_bar:SetPercent(cur_percent * 100, not self.is_first_open)
end

function InnerView:FlushAttrView()
    self.attr_view:SetData(InnerData.Instance:GetShowAllAttrs())
end

function InnerView:FlushConsumeDesc()
    local consume_coin_num = InnerData.Instance:GetBindCoinConsumeNum()
    local role_coin_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
    local color = role_coin_num >= consume_coin_num and COLORSTR.GREEN or COLORSTR.RED
    local content = string.format("{color;1eff00;消耗绑金：}{color;%s;%d}{color;1eff00;/%d}", color, role_coin_num, consume_coin_num)
    RichTextUtil.ParseRichText(self.node_t_list.rich_btn_under.node, content)
    self.node_t_list.rich_btn_under.node:setVisible(consume_coin_num > 0)
end

function InnerView:FlushBtn()
    local is_max_level = InnerData.Instance:IsMaxLevel()
    local is_not_act = InnerData.Instance:IsNotAct()
    local btn_name = "修炼"
    if InnerData.Instance:IsNotAct() then
        btn_name = "激活"
    elseif InnerData.Instance:IsMaxLevel() then
        btn_name = "凝气"
    end
    self.node_t_list.btn_1.node:setTitleText(btn_name)
end

function InnerView:OnClickEquip(slot)
	-- local equip_data = InnerData.Instance:GetCanEquipDataInBag(slot)
	-- if nil ~= equip_data then
	-- 	InnerCtrl.SendInnerEquipReq(equip_data.series)
	-- end
     TipCtrl.Instance:OpenInnerTip(slot)
end

function InnerView:FlushInnerEquip()
    if not self:IsOpen() then
        return
    end
	local is_act = GameCondMgr.Instance:GetValue(ViewDef.Role.Inner.inner_equip_open_cond)
	self.node_t_list.layout_inner_equip.node:setVisible(is_act)
	if not is_act then
		return
	end

	for i = InnerData.InnerEquipPos.ShaYuDanPos, InnerData.InnerEquipPos.InnerEquipPosMax do
		local node_t = self.node_t_list["layout_equip_" .. i]
		if node_t then
            node_t.lbl_num.node:enableOutline(COLOR4B.BLACK,1)
            node_t.lbl_num.node:setVisible(false)
			node_t.img_remind_flag.node:setVisible(nil ~= InnerData.Instance:GetCanEquipDataInBag(i))
			node_t.lbl_num.node:setString(string.format("%d/%d", InnerData.Instance:GetEquipNum(i), InnerData.Instance:GetEquipMaxNum(i)))
		end
	end
end

function InnerView:OnBagItemChange()
    self:FlushInnerEquip()
end

function InnerView:OnEquipChange(vo)
    self:Flush()
end

function InnerView:OnRoleAttrChange(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_INNER_LEVEL or key == OBJ_ATTR.ACTOR_INNER_EXP or key == OBJ_ATTR.ACTOR_BIND_COIN then
		self:Flush()
	end
end

function InnerView:OnClickUpBtn()
    InnerCtrl.SendInnerUpReq()
    if InnerData.Instance:IsNotAct() then
        local x, y = self.ball_bar:GetView():getPosition()
        RenderUnit.PlayEffectOnce(14, self.node_t_list.layout_inner.node, 999, x - 10, y + 165, true, nil, FrameTime.Effect * 0.7)
    end
end

function InnerView:OnClickOneKeyUpBtn()
    InnerCtrl.SendInnerOneKeyUpReq()
end

function InnerView:OnGameCondChange(cond_def)
    if cond_def == ViewDef.Role.Inner.inner_equip_open_cond then
        self:Flush()
    end
end

----------------------------------------
-- InnerStageRender
----------------------------------------
InnerView.InnerStageRender = BaseClass()
local InnerStageRender = InnerView.InnerStageRender

function InnerStageRender:__init(index, x, y, circle_center, view_parent)
    self.index = index
    self._x, self._y = x, y
    self._w, self._h = 80, 80
    self.circle_center = circle_center
    self.view_parent = view_parent
    self.center_p = cc.p(self._w / 2, self._h / 2)
    self.is_created = false

    self.fly_eff = nil

    self.view = XUI.CreateLayout(self._x, self._y, self._w, self._h)
    self.view_parent:addChild(self.view, 300)

    self:CreateChild()
end

function InnerStageRender:__delete()
    self.act_effect = nil
    self.fly_eff = nil
    self.blast_eff = nil
end

function InnerStageRender:CreateChild()
    if self.is_created then
        return
    end
    self.is_created = true

    self.img_normal_bg = XUI.CreateImageView(self.center_p.x, self.center_p.y, ResPath.GetInner("img_fire_bg"), true)
    self.view:addChild(self.img_normal_bg, 1, 1)
end

function InnerStageRender:GetView()
    return self.view
end

function InnerStageRender:GetIndex()
    return self.index
end

function InnerStageRender:SetShowEffect(is_show, is_show_blast)
    if is_show and self.act_effect == nil then
        self.act_effect = RenderUnit.CreateEffect(57, self.view, 99, FrameTime.Effect / 1.2, nil, self.center_p.x, self.center_p.y)
        self.act_effect:setScale(0.7)
    elseif self.act_effect then
        self.act_effect:setVisible(is_show)
    end

    if is_show then
        if is_show_blast then
            self.act_effect:stopAllActions()
            self.act_effect:setOpacity(60)
            -- self.act_effect:runAction(cc.FadeIn:create(0.3))
            self:SetShowBlastEff(58)
        end
    end
end

function InnerStageRender:StopFlyEff()
    if self.fly_eff then
        self.fly_eff:removeFromParent()
        self.fly_eff = nil
    end
end

function InnerStageRender:FlyEffToCircleCenter(view)
    if self.fly_eff then
        return
    end

    self:SetShowEffect(false)

    local p_world_pos = self.view_parent:convertToWorldSpace(cc.p(self.circle_center.x, self.circle_center.y - 70))
    local tag_pos = self.view:convertToNodeSpace(p_world_pos)

    self.fly_eff = RenderUnit.CreateEffect(57, self.view, 99, FrameTime.Effect / 1.2, nil, self.center_p.x, self.center_p.y)
    self.fly_eff:setScale(0.7)
    local callfunc = cc.CallFunc:create(function()
        self.fly_eff:removeFromParent()
        self.fly_eff = nil
        if InnerData.Instance:GetStateIsAct(self.index) then
            view:PlayOneEffectToStage(self.index)
        end
    end)

    local move = cc.EaseExponentialIn:create(cc.MoveTo:create(0.8, tag_pos))
    local seq = cc.Sequence:create(move, callfunc)
    self.fly_eff:runAction(seq)
end

local area_angle = {
    [1] = {[1] = 1, [-1] = 4},
    [-1] = {[1] = 2, [-1] = 3},
}
local function get_rota_angle(p1, p2)   -- 得到p1->p2的直角坐标系上的角度
    local xc = p2.x - p1.x
    local yc = p2.y - p1.y
    local abs_xc = math.abs(xc)
    local abs_yc = math.abs(yc)

    local a = math.atan(abs_yc / abs_xc)
    local i1 = xc == 0 and 1 or (xc / abs_xc)
    local i2 = yc == 0 and 1 or (yc / abs_yc)
    local area_idx = area_angle[i1][i2]
    if area_idx == 1 then
        a = a
    elseif area_idx == 2 then
        a = 1 * math.pi - a
    elseif area_idx == 3 then
        a = 1 * math.pi + a
    elseif area_idx == 4 then
        a = 2 * math.pi - a
    end
    return a / math.pi * 180
end

function InnerStageRender:FlyEffFromCircleCenter()
    if self.fly_eff then
        return
    end

    self:SetShowEffect(false)

    local p_world_pos = self.view_parent:convertToWorldSpace(self.circle_center)
    local move_begin_pos = self.view:convertToNodeSpace(p_world_pos)
    local move_end_pos = cc.p(self.center_p.x - 2, self.center_p.y + 4)

    self.fly_eff = RenderUnit.CreateEffect(57, self.view, 99, FrameTime.Effect * 0.5, nil, move_begin_pos.x, move_begin_pos.y)
    -- self.fly_eff:setScale(0.8)
    self.fly_eff:setRotation(- get_rota_angle(move_begin_pos, move_end_pos) - 90)
    local callfunc = cc.CallFunc:create(function()
        self.fly_eff:removeFromParent()
        self.fly_eff = nil

        self:SetShowBlastEff(58, nil, nil, 0.3)
        self:SetShowEffect(true)
    end)

    local move = cc.EaseSineIn:create(cc.MoveTo:create(0.5, move_end_pos))
    local seq = cc.Sequence:create(move, callfunc)
    self.fly_eff:runAction(seq)
end

function InnerStageRender:SetShowBlastEff(eff_id, x, y, scale)
    local pos = self.view:convertToWorldSpace(self.center_p)
    local ui_node = HandleRenderUnit:GetUiNode()
    RenderUnit.PlayEffectOnce(eff_id, ui_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, pos.x, pos.y, true, function() 
        if self.act_effect then 
            self.act_effect:runAction(cc.FadeIn:create(0.1)) 
        end 
    end, FrameTime.Effect / 1.2)
end

return InnerView
