MeltSoulTipsView = MeltSoulTipsView or BaseClass(XuiBaseView)

local CONTENT_WIDTH = 400
local CONTENT_HEIGHT = 550
local LINE_HEIGHT = 30
local TITLE_HEIGHT = 40

function MeltSoulTipsView:__init()
    self:SetModal(true)
    self:SetIsAnyClickClose(true)

    self.config_tab = {
		{"itemtip_ui_cfg", 11, {0}}
	}


end

function MeltSoulTipsView:ReleaseCallBack()
    self.data = nil
end

function MeltSoulTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
        local ph = self.ph_list.ph_itemcell
        local img_cell = XUI.CreateImageView(ph.x, ph.y, ResPath.GetCommon("cell_100"), true)
        img_cell:setAnchorPoint(0, 0)
        self.node_t_list.layout_content_top.node:addChild(img_cell)

        local size = img_cell:getContentSize()
        self.img_soul_icon = XUI.CreateImageView(ph.x + size.width / 2, ph.y + size.height / 2, "", true)
        self.node_t_list.layout_content_top.node:addChild(self.img_soul_icon, 10)

        self.effect_soul = AnimateSprite:create()
        self.effect_soul:setPosition(ph.x + size.width / 2, ph.y + size.height / 2)
        self.node_t_list.layout_content_top.node:addChild(self.effect_soul, 20)

        self.node_t_list.itemname_txt.node:setColor(COLOR3B.YELLOW)
        self.node_t_list.top_txt1.node:setColor(COLOR3B.YELLOW)
        self.node_t_list.top_txt2.node:setColor(COLOR3B.GREEN)

        local x, y = self.node_t_list.layout_content_top.node:getPosition()
        self.scroll_view = XUI.CreateScrollView(x, y - 20, 400, 0, ScrollDir.Vertical)
        self.scroll_view:setAnchorPoint(0, 1)
        self.node_t_list.layout_melt_soul_tip.node:addChild(self.scroll_view, 20)
    end
end

function MeltSoulTipsView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeltSoulTipsView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MeltSoulTipsView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MeltSoulTipsView:OnFlush(param_t, index)
    if not self.data then return end

    self:SetTopContent()
    self:SetContent()
    self:UpdateContentSize()
end

function MeltSoulTipsView:UpdateContentSize()
    local old_size = self.node_t_list.layout_melt_soul_tip.node:getContentSize()

    local content_size = self.scroll_view:getContentSize()
    local top_size = self.node_t_list.layout_content_top.node:getContentSize()

    local new_height = content_size.height + top_size.height + 20
    local new_width = old_size.width

    self.root_node:setContentWH(new_width, new_height)
    self.node_t_list.layout_melt_soul_tip.node:setContentWH(new_width, new_height)
    self.node_t_list.img9_itemtips_bg.node:setContentWH(self.node_t_list.img9_itemtips_bg.node:getContentSize().width, new_height)

    self.node_t_list.layout_melt_soul_tip.node:setPositionY(new_height / 2)
    self.node_t_list.img9_itemtips_bg.node:setPositionY(new_height / 2) 
    self.node_t_list.layout_content_top.node:setAnchorPoint(0, 1)
    self.node_t_list.layout_content_top.node:setPosition(10, new_height - 10)
    -- self.node_t_list.layout_content_top.node:setBackGroundColor(COLOR3B.GREEN)

    self.node_t_list.btn_close_window.node:setAnchorPoint(1, 1)
    self.node_t_list.btn_close_window.node:setPosition(new_width + 10, new_height + 10)

    self.scroll_view:setAnchorPoint(0, 1)
    self.scroll_view:setPosition(10, new_height - top_size.height)
    -- self.scroll_view:getInnerContainer():setBackGroundColor(COLOR3B.YELLOW)
end

function MeltSoulTipsView:SetContent()
    self.scroll_view:removeAllChildren()
    local rich_elements = {}
    local element = self:CreateTitle(Language.Tip.MeltSoulAttr)
    table.insert(rich_elements, element)

    local attr_cfg = WingData.GetRonghunAttrCfg(self.data.slot, self.data.level == 0 and self.data.level + 1 or self.data.level)
    if attr_cfg then
        local attr_data = RoleData.FormatRoleAttrStr(attr_cfg)
        for k, v in pairs(attr_data) do
            element = self:CreateLineText(string.format( "{wordcolor;00ff00;%s：%s}", v.type_str, v.value_str))
            table.insert( rich_elements, element )
        end
    end

    element = self:CreateTitle(Language.Tip.PhantomDesc)
    table.insert( rich_elements, element )
    element = self:CreateLineText(WingData.GetRonghunPhantomDesc(self.data.slot))
    -- element:setBackGroundColor(COLOR3B.GREEN)
    -- element:setBackGroundColorOpacity(125)
    table.insert( rich_elements, element )

    local count = #rich_elements
    local height = 5
    for i = count, 1, -1 do
        local v = rich_elements[i]
        v:setAnchorPoint(0, 0)
        v:setPosition(0, height)
        height = height + v:getContentSize().height
        self.scroll_view:addChild(v)
    end
    -- print("melt_soul_tip.lua ==> line123 ", height)
    self.scroll_view:setContentWH(CONTENT_WIDTH, height + 10 > CONTENT_HEIGHT and CONTENT_HEIGHT or height + 10)
    self.scroll_view:setInnerContainerSize(cc.size(CONTENT_WIDTH, height + 10))
    self.scroll_view:jumpToTop()
end

function MeltSoulTipsView:CreateTitle(title_text)
    local layout = XUI.CreateLayout(0, 0, CONTENT_WIDTH, TITLE_HEIGHT)
    local bg = XUI.CreateImageView(0, TITLE_HEIGHT / 2, ResPath.GetCommon("bg_122"))
    bg:setAnchorPoint(0, 0.5)
    layout:addChild(bg)
    local point = XUI.CreateImageView(0, TITLE_HEIGHT / 2, ResPath.GetCommon("orn_100"))
    point:setAnchorPoint(0, 0.5)
    layout:addChild(point)
    local line = XUI.CreateImageView(20, 35, ResPath.GetCommon("line_101"))
    line:setAnchorPoint(0, 1)
    layout:addChild(line)
    local text = XUI.CreateText(20, TITLE_HEIGHT / 2, 0, 0)
    text:setString(title_text)
    text:setColor(COLOR3B.GOLD)
    text:setAnchorPoint(0, 0.5)
    layout:addChild(text)
    return layout
end

function MeltSoulTipsView:CreateLineText(str)
    local layout = XUI.CreateLayout(0, 0, CONTENT_WIDTH, LINE_HEIGHT)
    local text = XUI.CreateRichText(0, 0, CONTENT_WIDTH, LINE_HEIGHT)
    text:setHorizontalAlignment(RichHAlignment.HA_LEFT)
    text:setVerticalAlignment(RichVAlignment.VA_BOTTOM)
    text:setAnchorPoint(0, 0)
    RichTextUtil.ParseRichText(text, str, 20)
    text:refreshView()
    layout:addChild(text)
    layout:setContentWH(CONTENT_WIDTH, math.max( LINE_HEIGHT, text:getInnerContainerSize().height))
    text:setContentWH(CONTENT_WIDTH, math.max( LINE_HEIGHT, text:getInnerContainerSize().height))
    return layout
end

function MeltSoulTipsView:SetTopContent()
    local name = WingData.Instance:GetRonghunNameBySlot(self.data.slot)
    self.node_t_list.itemname_txt.node:setString(string.format("%s·%s", Language.Tip.MeltSoul, name))

    self.node_t_list.top_txt1.node:setString(Language.Tip.TypePhantom)

    local max_level = WingData.Instance:GetRonghunMaxLevel(self.data.slot)
    local cfg = WingData.Instance:GetRonghunUpGradeData(self.data.slot, self.data.level + 1 > max_level and max_level or self.data.level + 1)
    if cfg then
        local _, grade = WingData.GetWingUpLevelCfg(cfg.condition.swingid)
        self.node_t_list.top_txt2.node:setString(string.format(Language.Tip.MeltSoulLevel, CommonDataManager.GetSimplifiedCHNNum(grade)))
    end

    local index = self.data.level + 1
    index = index > #Language.Tip.States and #Language.Tip.States or index
    self.node_t_list.top_txt3.node:setString(Language.Tip.MeltSoulState .. Language.Tip.States[index])
    self.node_t_list.top_txt3.node:setColor(self.data.level > 0 and COLOR3B.GREEN or COLOR3B.GRAY)

    self.img_soul_icon:loadTexture(ResPath.GetWingResPath("ronghun_" .. self.data.slot))
    self.img_soul_icon:setGrey(self.data.level <= 0)

    local anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.data.slot + 1212 - 1)
    self.effect_soul:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
    AdapterToLua:makeGray(self.effect_soul, self.data.level <= 0)
end

function MeltSoulTipsView:SetData(data)
    self.data = data
end