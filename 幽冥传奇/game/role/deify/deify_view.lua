-- 角色-封神
DeifyView = DeifyView or BaseClass(SubView)

function DeifyView:__init()
    self.texture_path_list = {
        'res/xui/level_and_deify.png',
    }
	self.config_tab = {
		{"level_and_deify_ui_cfg", 1, {0}},
		{"level_and_deify_ui_cfg", 2, {0}},
		{"level_and_deify_ui_cfg", 3, {0}},
		{"level_and_deify_ui_cfg", 5, {0}},
	}
    self.need_del_objs = {}
    --self.confirm_dialog = Alert.New()
    self.door = DoorModal.New()
    self.door:BindClickActBtnFunc(BindTool.Bind(self.OnClickUPHandler, self))
end

function DeifyView:__delete()
    self.confirm_dialog:DeleteMe()
    self.confirm_dialog = nil
end

function DeifyView:LoadCallBack()
    self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99)
    --self:CreateMapView(self.node_t_list.layout_deify.node, self.ph_list.ph_map)
    self:CreateExplainView(self.node_t_list.layout_deify.node, self.ph_list.ph_explain)

    XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnClickUPHandler, self))
    XUI.AddClickEventListener(self.node_t_list.img_tip.node, BindTool.Bind(self.OpenTipView, self))
    EventProxy.New(DeifyData.Instance, self):AddEventListener(DeifyData.DEIFY_LEVEL_CHANGE, BindTool.Bind(self.LevelChangeHandler, self))
    EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
    EventProxy.New(ShopData.Instance, self):AddEventListener(ShopData.SHOP_LIMIT_CHANGE, BindTool.Bind(self.OnShopLimitChange, self))
    self:CreateNumber()
    self:CreateBuyList()
    self:CreateStar()
    self:CreateConsumeCell()

    local ph_duihuan = self.ph_list["ph_chumo"]
    local text = RichTextUtil.CreateLinkText(Language.Common.BtnRechargeGo, 19, COLOR3B.GREEN)
    text:setPosition(ph_duihuan.x, ph_duihuan.y)
    self.node_t_list.layout_deify.node:addChild(text, 90)
    XUI.AddClickEventListener(text, function()
            MoveCache.end_type = MoveEndType.Normal
            GuajiCtrl.Instance:FlyByIndex(20)
            ViewManager.Instance:CloseViewByDef(ViewDef.Role)
     end, true)

    local ph_duihuan = self.ph_list["ph_text_btn_2"]
    local text = RichTextUtil.CreateLinkText(Language.Common.BtnRechargeGo, 19, COLOR3B.GREEN)
    text:setPosition(ph_duihuan.x, ph_duihuan.y)
    self.node_t_list.layout_deify.node:addChild(text, 90)
    XUI.AddClickEventListener(text, function()
            MoveCache.end_type = MoveEndType.Normal
            DungeonCtrl.SetViewDefaultChild("LianYu") --设置"副本"面板默认打开"副本-炼狱"面板
            GuajiCtrl.Instance:FlyByIndex(48)
            ViewManager.Instance:CloseViewByDef(ViewDef.Role)
     end, true)
end

function DeifyView:OpenTipView( ... )
   DescTip.Instance:SetContent(Language.DescTip.FengShengContent, Language.DescTip.FengShengTitle)
end

function DeifyView:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
    local level = DeifyData.Instance:GetLevel()
    self.door:SetVis(level == 0, self:GetRootNode())
    if level == 0 then
        self.door:CloseTheDoor()
    else
        self.door:OpenTheDoor()
    end
end


function DeifyView:RoleDataChangeCallback(vo)
    if vo.key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT or vo.key == OBJ_ATTR.CREATURE_LEVEL then
       -- RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeUpGrade)
       self:Flush()
    end
end

function DeifyView:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
    self.door:SetVis(false, self:GetRootNode())
end

function DeifyView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
    self.need_del_objs = {}
    self.door:Release()
    self.fight_power_view = nil

    if self.num_bar then
        self.num_bar:DeleteMe()
        self.num_bar = nil
    end

    if self.buy_list then
        self.buy_list:DeleteMe()
        self.buy_list = nil
    end
    self.satr_list = {}
end

function DeifyView:ShowIndexCallBack()
	self:Flush()
end

function DeifyView:LevelChangeHandler( ... )
    self:Flush()
end

function DeifyView:CreateBuyList()
    local ph = self.ph_list.ph_buy_list
    if nil == self.buy_list then
        self.buy_list = ListView.New()
        self.buy_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CommonBuyRender, nil, nil, self.ph_list.ph_list_item)
        self.node_t_list.layout_deify.node:addChild(self.buy_list:GetView(), 100, 100)
        self.buy_list:GetView():setAnchorPoint(0, 0)
        self.buy_list:SetItemsInterval(8)
        self.buy_list:JumpToTop(true)
    end
    self:FlushShopList()
end

function DeifyView:OnShopLimitChange(  )
   self:FlushShopList()
end

function DeifyView:FlushShopList()
    local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.fengshen]
    self.buy_list:SetDataList(data)
end

function DeifyView:CreateNumber( ... )
    if self.num_bar == nil then
        local ph = self.ph_list.ph_numbar_bar
        self.num_bar = NumberBar.New()
        self.num_bar:Create(ph.x + 35, ph.y -5, 0, 0, ResPath.GetCommon("num_133_"))
        self.num_bar:SetSpace(-8)
        self.num_bar:SetGravity(NumberBarGravity.Center)
        self.node_t_list.layout_deify.node:addChild(self.num_bar:GetView(), 101)
    end
end

function DeifyView:SetStarShow( ... )
    local cur_level = DeifyData.Instance:GetChildLevel()
    for k, v in pairs(self.satr_list) do
        if cur_level >= k then
            v:loadTexture(ResPath.GetCommon("star_1_select"))
        else
            v:loadTexture(ResPath.GetCommon("star_1_lock"))
        end
    end
end

function DeifyView:OnFlush()
    local level = DeifyData.Instance:GetLevel()
    
    if 1 > level then return end
    self:SetStarShow()
    self:FlushAttrView()
    self:FlushPowerValueView()

    local step = DeifyData.Instance:GetPhase()
    self.node_t_list.img_cur_level.node:loadTexture(ResPath.LeveAndDeify("map_name_" .. step))

    local next_level = level + 1
    local next_step = 1
    if next_level <= #office_cfg.level_list then
        next_step = math.min(math.floor(next_level / 11) + 1, 20)
    else
        next_step = 20
    end
    self.node_t_list.img_next_level.node:loadTexture(ResPath.LeveAndDeify("map_name_" .. next_step))
   

    local cur_star_level = DeifyData.Instance:GetChildLevel()
    local text = string.format("·%d星", cur_star_level)
    self.node_t_list.text_xing.node:setString(text)

    local next_star_level = (next_level - 1)%11
    local next_text = string.format("·%d星", next_star_level)
    self.node_t_list.next_text_xing.node:setString(next_text)

    if ((next_level - 1) % 11) ~= 0 then
        self.node_t_list["layout_consume_1"].node:setVisible(true)
        self.consume_2:GetView():setVisible(false)
        self.consume_2:SetData()

        local txt1 = DeifyData.Instance:GetNeedLevelTxt()
        RichTextUtil.ParseRichText(self.node_t_list.rich_need_level.node, txt1)

        local txt2 = DeifyData.Instance:GetConsumTxt()
        RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, txt2)
    else
        self.node_t_list["layout_consume_1"].node:setVisible(false)
        self.consume_2:GetView():setVisible(true)

        local level_list = office_cfg and office_cfg.level_list or {}
        local cur_level_list = level_list[next_level] or {}
        local cur_consume = cur_level_list.consume or {}
        local item = cur_consume[1] or {}
        local item_id = item.id or 0
        local item_type = item.type or 0
        local need_num = item.count or 0
        local has_num = BagData.GetConsumesCount(item_id, item_type) or 0
        local color = has_num >= need_num and COLOR3B.GREEN or COLOR3B.RED
        local text = CommonDataManager.ConverMoney(need_num)
        self.consume_2:SetData(ItemData.InitItemDataByCfg(item))
        self.consume_2:SetRightBottomText(text, color)

        local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
        local needlv = cur_level_list.needlv or 0
        local text = level >= needlv and "" or string.format("需要等级%d级", needlv)
        self.node_t_list["lbl_need_level"].node:setString(text)
    end
end

function DeifyView:CreateStar( ... )
    self.satr_list = {}
    local ph = self.ph_list.ph_star_1
    for i = 1, 10 do
        local star = XUI.CreateImageView(ph.x + (i - 1) * 30 + 22, ph.y +10, ResPath.GetCommon("star_1_lock"), true)
        self.node_t_list.layout_deify.node:addChild(star, 99)
        self.satr_list[i] = star
    end
end

function DeifyView:CreateConsumeCell()
    local parent = self.node_t_list["layout_deify"].node
    local ph = self.ph_list["ph_consume_2"] or {x = 0, y = 0, w = 10, h = 10}
    local cell = BaseCell.New()
    cell:SetIsShowTips(false)
    cell:SetPosition(ph.x, ph.y)
    parent:addChild(cell:GetView(), 99)
    self.consume_2 = cell
    self:AddObj("consume_2")

    cell:GetView():setVisible(false)
end

-- 刷新战力值视图
function DeifyView:FlushPowerValueView()
    local level = DeifyData.Instance:GetLevel()   -- 获取官职基础等级

    -- 如果配置为空,战力显示为0
    if nil == office_cfg.level_list[level] then
        self.fight_power_view:SetNumber(0)
        return
    end

    -- 获取角色的官职属性
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
    local attr = {}
    for k, v in ipairs(office_cfg.level_list[level].attrs) do
        if v.type ~= 115 then
            if v.job == prof or v.job == 0 then
                attr[#attr + 1] = v
            end
        end
    end
    local power_value = CommonDataManager.GetAttrSetScore(attr)
    self.fight_power_view:SetNumber(power_value)
end

-- 刷新加成属性视图
function DeifyView:FlushAttrView()
    local level = DeifyData.Instance:GetLevel()
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)

    -- 获取角色的官职属性,未激活时,显示"未激活"
    local text1 = ""
    local text3 = ""
    local num = 0
    if level ~= 0 then
        local attr1 = {}
        for k, v in ipairs(office_cfg.level_list[level].attrs) do
            if v.type ~= 115 then  -- 屏蔽属性显示
                if v.job == prof or v.job == 0 then
                    attr1[#attr1 + 1] = v
                end
            end
        end
        local color = {
            type_str_color = "9c9181",
            value_str_color = "cdced0",
        }
        text1 = RoleData.Instance.FormatAttrContent(attr1, color)
        local client_attrs_value = office_cfg.level_list[level].client_attrs.value
        text3 = string.format("{wordcolor;%s;%s}", "9c9181", Language.Role.VirtualAttrName).." : " .. string.format("{wordcolor;%s;%s}", "cdced0", (client_attrs_value /100).. "%")
       -- text3 = Language.Role.VirtualAttrName .." "..
       num = office_cfg.level_list[level].client_attrs.value/ 100
    else
        text1 = Language.Common.NoActivate
        text3 = ""
        num = 0
    end
    self.num_bar:SetNumber(num)
    -- 获取角色封神下一级的属性,满级时,显示"已是最高级了",并且升级按钮
    local text2 = ""
    local text4 = ""
    if (level + 1) <= #office_cfg.level_list then
        local attr2 = {}
        for k, v in ipairs(office_cfg.level_list[level + 1].attrs) do
            if v.type ~= 115 then -- 屏蔽属性显示
                if v.job == prof or v.job == 0 then
                    attr2[#attr2 + 1] = v
                end
            end
        end
        local color = {
            type_str_color = "9c9181",
            value_str_color = "1ec449",
        }
         text2 = RoleData.Instance.FormatAttrContent(attr2,color)
         local client_attrs_value = office_cfg.level_list[level+1].client_attrs.value
         text4 = string.format("{wordcolor;%s;%s}", "9c9181", Language.Role.VirtualAttrName).." : " .. string.format("{wordcolor;%s;%s}", "1ec449", (client_attrs_value /100).. "%")
    else
        text2 = Language.Common.AlreadyTopLv
        --self.node_t_list.rich_next_bonus.node:setPosition(580, 232)
        self.node_t_list.btn_1.node:setVisible(false)
        text4 =""
    end

    RichTextUtil.ParseRichText(self.node_t_list.rich_attr1.node, text1.."\n"..text3, 20, COLOR3B.DULL_GOLD)
    RichTextUtil.ParseRichText(self.node_t_list.rich_attr2.node, text2.."\n"..text4, 20, COLOR3B.DULL_GOLD)
    --self.node_t_list.rich_attr1.node:setVerticalSpace(-2) --设置垂直间隔
    --self.node_t_list.rich_attr2.node:setVerticalSpace(-2)
end

function DeifyView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.ACTOR_CIRCLE_SOUL or vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT then
		self:Flush()
	end
end

-- function DeifyView:CreateMapView(parent_node, ph)
--     self.map_view = XUI.CreateListView(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical)
--     --self.need_del_objs[#self.need_del_objs + 1] = self.map_view
--     parent_node:addChild(self.map_view)
--     for k, v in pairs(DeifyransportToNPC) do
--         local item_layout = XUI.CreateLayout(0 , 0, ph.w, 27)
--         local map_name = XUI.CreateText(10, 0, 250, 27, cc.TEXT_ALIGNMENT_LEFT, v[2], nil,
--                 19, cc.c3b(156, 145, 129),nil)
--         map_name:setAnchorPoint(0, 0)
--         item_layout:addChild(map_name, 90)
--         local goto_text = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
--         goto_text:setAnchorPoint(0, 0)
--         goto_text:setPosition(260, 0)
--         item_layout:addChild(goto_text, 90)
--         XUI.AddClickEventListener(goto_text, function() Scene.SendQuicklyTransportReq(v[1]) end, true)
--         self.map_view:pushBackItem(item_layout)
--     end
-- end

function DeifyView:CreateExplainView(parent_node, ph)
   -- self.explain_view = XUI.CreateListView(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical)
    -- --self.need_del_objs[#self.need_del_objs + 1] = self.explain_view
    -- -- parent_node:addChild(self.explain_view)
    -- local text = ""
    -- for k, v in pairs(Language.Role.LevelDeify.DeifyExplain) do
    --     text = text .. string.format(v, ResPath.LeveAndDeify("img_point")).."\n"
    --     -- local item_layout = XUI.CreateLayout(0 , 0, ph.w, 28)
    --     -- local img_point = XUI.CreateImageView(5,0, ResPath.LeveAndDeify("img_point"), true)
    --     -- img_point:setAnchorPoint(0, 0)
    --     -- item_layout:addChild(img_point, 90)

    --     -- local explain = XUI.CreateText(30, 0, 350, 28, cc.TEXT_ALIGNMENT_LEFT, v, nil,
    --     --         20, cc.c3b(156, 145, 129), cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    --     -- explain:setAnchorPoint(0, 0)
    --     -- item_layout:addChild(explain, 90)
    --     -- self.explain_view:pushBackItem(item_layout)
    -- end
    --  RichTextUtil.ParseRichText(self.node_t_list.rich_text_show.node, text, 20, Str2C3b("9c9181"))
    --  XUI.SetRichTextVerticalSpace(self.node_t_list.rich_text_show.node,2)
end

function DeifyView:OnClickUPHandler()
    local has_count, need_count = DeifyData.Instance:GetHasCountAndNeedCount()
    if has_count < need_count then
        self:OpenGetVolumeWindow()
    else
        local index = DeifyData.Instance:GetLevel() == 0 and 2 or 3
        OfficeCtrl.Instance:SendOfficeReq(index)
    end

end

-- 打开获取官职单窗口
function DeifyView:OpenGetVolumeWindow()
    local item_data = self.consume_2:GetData()
    if item_data then
        TipCtrl.Instance:OpenGetStuffTip(item_data.item_id)
    else
        local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[1662]
        local data = string.format("{reward;0;%d;1}", 1662) .. (ways and ways or "")
        TipCtrl.Instance:OpenNewBuyTip(data)
    end

end

-- 等级改变处理程序
function DeifyView:LevelChangeHandler()
    --self:FlushPowerValueView()
    --self:FlushBtnUpView()
    --self:FlushVolumeView()
    --self:FlushStarsView()
    --self:FlushBonusView()
    --
    --local phase = OfficeData.Instance:GetPhase()
    --if self.phase ~= phase then
    --    self.phase = phase
    --    self:FlushPhaseView()
    --end
    self.door:OpenTheDoor()
    self:Flush()
end

function DeifyView:OnGetUiNode(node_name)
    if node_name == NodeName.OfficeActBtn then
        return self.door:GetActBtnNode(), true
    end
    return DeifyView.super.OnGetUiNode(self, node_name)
end

return DeifyView
