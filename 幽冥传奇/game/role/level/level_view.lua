LevelView = LevelView or BaseClass(SubView)

function LevelView:__init()
    self.texture_path_list = {
        'res/xui/level_and_deify.png',
    }
	self.config_tab = {
		{"level_and_deify_ui_cfg", 1, {0}},
		{"level_and_deify_ui_cfg", 2, {0}},
		{"level_and_deify_ui_cfg", 3, {0}},
		{"level_and_deify_ui_cfg", 4, {0}},
	}
    self.need_del_objs = {}
    self.fight_power_view = nil
end

function LevelView:__delete()

end

function LevelView:LoadCallBack()
    self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99)
    --self.cur_attr = self:CreateAttrView(self.node_t_list.layout_level.node, self.ph_list.ph_attr1)
    --self.next_attr = self:CreateAttrView(self.node_t_list.layout_level.node, self.ph_list.ph_attr2)
    self:CreateMapView()
    self:CreateExplainView(self.node_t_list.layout_level.node, self.ph_list.ph_explain)

    XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnBtnClick, self))
    XUI.AddClickEventListener(self.node_t_list.img_tip_level.node, BindTool.Bind(self.OpenTipView, self))
    EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
    self.alert_dialog = Alert.New()
    self:CreateCell()

    local ph_duihuan = self.ph_list["ph_chumo1"]
    local text = RichTextUtil.CreateLinkText("前往", 19, COLOR3B.GREEN)
    text:setPosition(ph_duihuan.x, ph_duihuan.y)
    self.node_t_list.layout_level.node:addChild(text, 90)
    XUI.AddClickEventListener(text, function()
            MoveCache.end_type = MoveEndType.Normal
            GuajiCtrl.Instance:FlyByIndex(51)
     end, true)

    local ph_buy = self.ph_list["ph_xiulian1"]
    local text = RichTextUtil.CreateLinkText("前往", 19, COLOR3B.GREEN)
    text:setPosition(ph_buy.x, ph_buy.y)
    self.node_t_list.layout_level.node:addChild(text, 90)
    XUI.AddClickEventListener(text, function ()  
            MoveCache.end_type = MoveEndType.Normal
          GuajiCtrl.Instance:FlyByIndex(48)
        end, true)

    local ph_buy = self.ph_list["ph_shilian1"]
    local text = RichTextUtil.CreateLinkText("前往", 19, COLOR3B.GREEN)
    text:setPosition(ph_buy.x, ph_buy.y)
    self.node_t_list.layout_level.node:addChild(text, 90)
    XUI.AddClickEventListener(text, function ()  
            ViewManager.Instance:OpenViewByDef(ViewDef.Experiment)
        end, true)
    
end

function LevelView:OpenTipView()
    DescTip.Instance:SetContent(Language.DescTip.LevelContent, Language.DescTip.LevelTitle)
end


function LevelView:RoleDataChangeCallback(vo)
   if (vo.key == OBJ_ATTR.CREATURE_LEVEL) then
       self:Flush()
    end
end


function LevelView:ItemDataListChangeCallback()
    self:Flush()
end

function LevelView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
    self.need_del_objs = {}
    if self.map_title_list then
        self.map_title_list:DeleteMe()
        self.map_title_list = nil
    end

    if self.consume_cell then
        self.consume_cell:DeleteMe()
        self.consume_cell = nil
    end
end

function LevelView:CreateCell()
    if self.consume_cell == nil then
        local ph = self.ph_list.ph_consume_cell
        self.consume_cell = BaseCell.New()

        self.consume_cell:GetView():setPosition(ph.x, ph.y)
        self.node_t_list.layout_level.node:addChild(self.consume_cell:GetView(), 99)
    end
end

function LevelView:ShowIndexCallBack()
	self:Flush()
end


function LevelView:FLushData( ... )
    local data,name = LevelData.Instance:GetListData()
    self.map_title_list:SetDataList(data)

    self.node_t_list.text_name.node:setString(name or "")
end


function LevelView:OnFlush()
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
    local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)

    self:FlushAttrView()
    self:FlushPowerValueView()
    local max_level = GlobalConfig.maxLevel[circle+2]
    -- local text1 = string.format(Language.Role.LevelDeify.MaxLevelTips, max_level or 2000)
    --self.node_t_list.lbl_cur_level.node:setString(level.." "..text1)

    local id = LevelData.Instance:GetCurLevelItemID(level)
    if id == nil then
        self.consume_cell:SetData(nil)
         self.consume_cell:SetRightBottomText("")
    else
        self.consume_cell:SetData({item_id = id, num = 1, is_bind = 0})
        local num = BagData.Instance:GetItemNumInBagById(id)

        local text = string.format("%d/%d", num, 1)
        local color = num >= 1 and COLOR3B.GREEN or COLOR3B.RED
        self.consume_cell:SetRightBottomText(text, color)
    end
  
    --local txt = LevelData.Instance:GetCurLevelItemTxt(level)
    --RichTextUtil.ParseRichText(self.node_t_list.rich_consum.node, txt)
    --self.node_t_list.rich_consum.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
    local text2 = ""
    if max_level ~= nil then
        local cur_max_level = GlobalConfig.maxLevel[circle + 1]

         text2 = string.format(Language.Level.showdesc, cur_max_level, circle + 1, max_level)
    end
    RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, text2)
    XUI.RichTextSetCenter(self.node_t_list.rich_text_desc.node)

    local text =  level >= #VocationConfig[1].levelProp and Language.Role.LevelDeify.BtnText[1] or Language.Role.LevelDeify.BtnText[2]
    self.node_t_list.btn_1.node:setTitleText(text)
    self:FLushData()
end

-- 刷新战力值视图
function LevelView:FlushPowerValueView()
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
    local attrs_data = LevelData.Instance:GetAttrTypeValueFormat(level)

    -- 如果配置为空,战力显示为0
    if nil == attrs_data then
        self.power_view:SetNumber(0)
        return
    end

    local power_value = CommonDataManager.GetAttrSetScore(attrs_data)
    self.fight_power_view:SetNumber(power_value)
end

-- 刷新加成属性视图
function LevelView:FlushAttrView()
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
    local cur_attrs_data = LevelData.Instance:GetAttrTypeValueFormat(level)
    local next_attrs_data = LevelData.Instance:GetAttrTypeValueFormat(level + 1)
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)

    self.node_t_list.text_level.node:setString("LV."..level)

    -- 获取角色的官职属性,未激活时,显示"未激活"
    local text1 = ""
    if level ~= 0 then
        local attr1 = {}
        for k, v in ipairs(cur_attrs_data) do
            attr1[#attr1 + 1] = v
        end
        local color = {
            type_str_color = "9c9181",
            value_str_color = "cdced0",
        }
        text1 = RoleData.Instance.FormatAttrContent(attr1, color)
    else
        text1 = Language.Common.NoActivate
    end

    -- 获取角色官职下一级的属性,满级时,显示"已是最高级了",并且升级按钮
    local text2 = ""
    local text4 = ""
    if (level + 1) <= #VocationConfig[1].levelProp then
        local attr2 = {}
        for k, v in ipairs(next_attrs_data) do
            attr2[#attr2 + 1] = v
        end
        local color = {
            type_str_color = "9c9181",
            value_str_color = "1ec449",
        }
        text2 = RoleData.Instance.FormatAttrContent(attr2,color)
        text4 = "LV.".. (level + 1)
    else
        text2 = Language.Common.AlreadyTopLv
        --self.node_t_list.rich_next_bonus.node:setPosition(580, 232)
        --self.node_t_list.layout_btn_1.node:setVisible(false)
    end
    self.node_t_list.text_next_level.node:setString(text4)
    
    RichTextUtil.ParseRichText(self.node_t_list.rich_attr1.node, text1, 20, COLOR3B.DULL_GOLD)
    RichTextUtil.ParseRichText(self.node_t_list.rich_attr2.node, text2, 20, COLOR3B.DULL_GOLD)
    --self.node_t_list.rich_attr1.node:setVerticalSpace(-2) --设置垂直间隔
    --self.node_t_list.rich_attr2.node:setVerticalSpace(-2)
end

function LevelView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.ACTOR_CIRCLE_SOUL or vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:Flush()
	end
end

--function LevelView:CreateAttrView(parent_node, ph)
--    local attr_view = AttrView.New(300, 25, 18)
--    self.need_del_objs[#self.need_del_objs + 1] = attr_view
--    attr_view:SetDefTitleText("已达到最高级")
--    attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
--    attr_view:GetView():setPosition(ph.x, ph.y)
--    attr_view:GetView():setAnchorPoint(0.5, 0.5)
--    attr_view:SetContentWH(ph.w, ph.h)
--    parent_node:addChild(attr_view:GetView(), 50)
--    return attr_view
--end

function LevelView:CreateMapView()
    -- self.map_view = XUI.CreateListView(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical)
    -- --self.need_del_objs[#self.need_del_objs + 1] = self.map_view
    -- parent_node:addChild(self.map_view)
    -- for k, v in pairs(LevelTransportToNPC) do
    --     local item_layout = XUI.CreateLayout(0 , 0, ph.w, 27)
    --     local map_name = XUI.CreateText(10, 0, 250, 27, cc.TEXT_ALIGNMENT_LEFT, v[2], nil,
    --             19, cc.c3b(156, 145, 129),nil)
    --     map_name:setAnchorPoint(0, 0)
    --     item_layout:addChild(map_name, 90)
    --     local goto_text = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
    --     goto_text:setAnchorPoint(0, 0)
    --     goto_text:setPosition(260, 0)
    --     item_layout:addChild(goto_text, 90)
    --     XUI.AddClickEventListener(goto_text, function() Scene.SendQuicklyTransportReq(v[1]) end, true)
    --     self.map_view:pushBackItem(item_layout)
    -- end

    if nil == self.map_title_list then
        local ph = self.ph_list.ph_map1--获取区间列表
        self.map_title_list = ListView.New()
        self.map_title_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, MaoTitleRender, nil, nil, self.ph_list.ph_list_item)
        self.map_title_list:SetItemsInterval(0)--格子间距
        self.map_title_list:SetMargin(2)
        self.map_title_list:SetJumpDirection(ListView.Top)--置顶
        self.node_t_list.layout_level.node:addChild(self.map_title_list:GetView(), 20)
       -- self.map_title_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
        self.map_title_list:GetView():setAnchorPoint(0.5, 0.5)
    end

end

function LevelView:CreateExplainView(parent_node, ph)
    --self.explain_view = XUI.CreateListView(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical)
    --self.need_del_objs[#self.need_del_objs + 1] = self.explain_view
    --parent_node:addChild(self.explain_view)
    -- for k, v in pairs(Language.Role.LevelDeify.LevelExplain) do
    --     local item_layout = XUI.CreateLayout(0 , 0, ph.w, 28)
    --     local img_point = XUI.CreateImageView(5,0, ResPath.LeveAndDeify("img_point"), true)
    --     img_point:setAnchorPoint(0, 0)
    --     item_layout:addChild(img_point, 90)

    --     local explain = XUI.CreateText(30, 0, 250, 28, cc.TEXT_ALIGNMENT_LEFT, v, nil,
    --             20, cc.c3b(156, 145, 129), cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    --     explain:setAnchorPoint(0, 0)
    --     item_layout:addChild(explain, 90)
    --     self.explain_view:pushBackItem(item_layout)
    -- end

    --  local text = ""
    -- for k, v in pairs(Language.Role.LevelDeify.LevelExplain) do
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
    --  RichTextUtil.ParseRichText(self.node_t_list.rich_text_show1.node, text, 20, Str2C3b("9c9181"))
    --  XUI.SetRichTextVerticalSpace(self.node_t_list.rich_text_show1.node,2)
end

function LevelView:OnBtnClick()
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
    local item_id = LevelData.Instance:GetCurLevelItemID(level)
    local series = BagData.Instance:GetItemSeriesInBagById(item_id)
    if series == nil then
        local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
        local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
        TipCtrl.Instance:OpenBuyTip(data)
    else
       BagCtrl.Instance:SendUseItem(series)
    end

end

MaoTitleRender = MaoTitleRender or BaseClass(BaseRender)
function MaoTitleRender:__init( ... )
    -- body
end

function MaoTitleRender:__delete( ... )
    self.goto_text = nil 
end

function MaoTitleRender:CreateChild( ... )
   BaseRender.CreateChild(self)

   local ph = self.ph_list.ph_link
   if nil == self.goto_text then
        self.goto_text = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
        self.view:addChild(self.goto_text, 90)
    end
   self.goto_text:setAnchorPoint(0, 0)
    self.goto_text:setPosition(ph.x, ph.y - 5)
     XUI.AddClickEventListener(self.goto_text, BindTool.Bind(self.GoToMap, self))
     -- XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnBtnClick, self))
     local vis = self.index %2 == 0 and true or false
     self.node_tree.img_bg.node:setVisible(not vis)

end

function MaoTitleRender:OnFlush( ... )
   if self.data == nil then
        return
   end
   self.node_tree.text_map_name.node:setString(self.data[2])
   local color = COLOR3B.GRAY
   if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= self.data[3] then
        color = COLOR3B.GREEN
   end
   self.node_tree.text_map_name.node:setColor(color)
end

function MaoTitleRender:GoToMap( ... )
   Scene.SendQuicklyTransportReq(self.data[1]) 
end

function MaoTitleRender:CreateSelectEffect()
   
end

return LevelView
