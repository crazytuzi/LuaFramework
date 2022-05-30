-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      伙伴召唤当前卡池的预览宝可梦界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonPreviewView = PartnerSummonPreviewView or BaseClass(BaseView)

function PartnerSummonPreviewView:__init()
    self.ctrl = PartnersummonController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Big
    --self.layout_name = "partnersummon/partnersummon_preview_view"
    self.item_list = {}--宝可梦头像
    self.partner_list = {}
    self.is_full_screen = false
    self.select_item = nil
    self.title_str = TI18N("召唤预览")
end

function PartnerSummonPreviewView:open_callback()
    -- self.bg = createScale9Sprite(PathTool.getResFrame("common", "common_1034"), 323, 403, LOADTEXT_PLIST, self.container)
    -- self.bg:setContentSize(cc.size(617, 780))
    self.size = cc.size(623,780)
    self.scroll_view = createScrollView(self.size.width,self.size.height,11,11,self.container,ccui.ScrollViewDir.vertical)
end



function PartnerSummonPreviewView:initTabButton(group_id)
    self.group_id = group_id
    self.pre_patner_list,self.pre_type_list  = self.model:getPreDataByGroupID(group_id)
    table.sort(self.pre_type_list,function(a,b)
        return a.rare_type > b.rare_type
    end)
    self:updateSingleItem(self.pre_type_list)
end

function PartnerSummonPreviewView:updateSingleItem(data)
   if data then
        local height = 0
        for i, v in ipairs(self.pre_type_list) do
            if not self.item_list[i] then
                local item= self:createSingleItem(v)
                self.scroll_view:addChild(item)
                height = height + item:getContentSize().height
                self.item_list[i] = item
            end
        end
        local temp_height = 5
        local max_height = math.max(self.scroll_view:getContentSize().height, height + temp_height * tableLen(self.pre_type_list))
        self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, max_height))
        if self.item_list then
            local offy = 5
            for i, item in ipairs(self.item_list) do
                if item then
                    item:setPosition(0,max_height - offy)
                    offy = offy + item:getContentSize().height + temp_height
                end
            end
        end
   end 
end

function PartnerSummonPreviewView:createSingleItem(data)
    local height = 0
    local container = ccui.Layout:create()
    container:setAnchorPoint(cc.p(0,1))
    container:setContentSize(self.scroll_view:getContentSize().width,0)
    local res = PathTool.getResFrame("common", "common_90024")
    local bg = createImage(container, res, 0, 0, cc.p(0, 0), true, 0, true)
    --bg:setCapInsets(cc.rect(170, 20, 1, 1))
    bg:setContentSize(cc.size(self.scroll_view:getContentSize().width, 44))
    res = PathTool.getResFrame("common", "common_90025")
    local title_bg = createImage(container, res, 3, 3, cc.p(0, 1), true, 0, true)
    -- title_bg:setCapInsets(cc.rect(170, 20, 1, 1))
    title_bg:setContentSize(cc.size(self.scroll_view:getContentSize().width - 7, 44))
    local name_str = {[1] = TI18N("A级宝可梦"),[2] = TI18N("S级宝可梦"),[3] = TI18N("SS级宝可梦")}
    local title_label = createLabel(26,175,nil,20,title_bg:getContentSize().height/2,name_str[data.rare_type],title_bg,nil,cc.p(0,0.5))
    height = height + title_bg:getContentSize().height
    local partner_list = self.pre_patner_list[data.rare_type]
    local item_height = self:updatePartnerList(partner_list,container)
    height = height + item_height
    container:setContentSize(self.scroll_view:getContentSize().width,height) 
    bg:setContentSize(cc.size(self.scroll_view:getContentSize().width,height))
    title_bg:setPosition(3,height - 4)
    return container
end

function PartnerSummonPreviewView:updatePartnerList(data,parent)
    if data then
        local single_item_height = PartnerSummonPreviewItem.Height + 10
        local single_item_width = PartnerSummonPreviewItem.Width + 10

        local row = 1 
        if math.ceil(tableLen(data) / 4) > 1 then
            row = math.ceil(tableLen(data) / 4)
        end
        local item_height = single_item_height * row + (10 * tableLen(data) % 4)
        for i, v in ipairs(data) do
            if not self.partner_list[v.partner_data.bid] then
                local partner_item = PartnerSummonPreviewItem.new()
                partner_item:setAnchorPoint(cc.p(0, 1))
                partner_item:setData(v)
                partner_item:setPosition(3 + single_item_width * ((i - 1) % 4), item_height - 8 - (single_item_height - 5) * math.floor((i - 1) / 4))
                if parent then
                    parent:addChild(partner_item)
                end
                self.partner_list[v.partner_data.bid] = partner_item
            end
        end
        return item_height
    end
   
end
function PartnerSummonPreviewView:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                PartnersummonController:getInstance():openPartnerSummonPreView(false)
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                PartnersummonController:getInstance():openPartnerSummonPreView(false)
            end
        end)
    end
end

function PartnerSummonPreviewView:openRootWnd(group_id)
    self:initTabButton(group_id)
end

function PartnerSummonPreviewView:close_callback()
    for k,v in pairs(self.partner_list) do
        v:DeleteMe()
    end
    self.partner_list = nil

    PartnersummonController:getInstance():openPartnerSummonPreView(false)
end

PartnerSummonPreviewItem = class("PartnerSummonPreviewItem", function()
    return ccui.Layout:create()
end)
PartnerSummonPreviewItem.Height = 181
PartnerSummonPreviewItem.Width = 147
function PartnerSummonPreviewItem:ctor()
    self.size = cc.size(147, 181)
    self.star_list = {}
    self:setContentSize(self.size)
    self.item_bg = createScale9Sprite(PathTool.getResFrame("partnersummon", "partnersummon_item_bg"),self.size.width/2, self.size.height/2, LOADTEXT_PLIST, self)
    self.partnersummon_head_bg = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_head_bg"), self.size.width / 2, self.size.height/2 +15, self)
   
    self.name_label = createRichLabel(24, 175, cc.p(0.5, 0.5), cc.p(70, 32))
    self:addChild(self.name_label)
    self.head_icon = createSprite(PathTool.getResFrame("common", "common_90033"), self.size.width / 2, self.size.height / 2 + 15, self)
    self.head_icon:setVisible(false)
    self.partnersummon_head = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_head"), self.size.width / 2, self.size.height / 2 + 15, self)
    self.type_icon = createSprite(PathTool.getResFrame("common", "common_90033"), 28.5, 160.5, self)
    self.type_icon:setVisible(false)

    local res = PathTool.getResFrame("common", "common_90046")
    self.hero_career = createImage(self, res, 94,52, cc.p(0, 0), true, 10, false)

    self.star_con = ccui.Layout:create()
    self.star_con:setAnchorPoint(cc.p(0.5,0.5))
    self.star_con:setPosition(cc.p(70,62))
    self:addChild(self.star_con)
    self:registerEvent()
end

function PartnerSummonPreviewItem:registerEvent()
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                -- local config = Config.PartnerData.data_partner_base[self.partner_bid]
                if self.data then
                    PokedexController:getInstance():openCheckHeroWindow(true, self.data)
                end
            end
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.canceled then
        end
    end)
end

function PartnerSummonPreviewItem:setData(data)
    if data ~= nil then
        self.data = data.partner_data
        self.type_icon:setVisible(true)
        self.head_icon:setVisible(true)
        local rate_type = {[1] = "common_90033", [2] = "common_90032", [3] = "common_90031" }
        loadSpriteTexture(self.type_icon, PathTool.getResFrame("common", rate_type[self.data.rare_type]), LOADTEXT_PLIST)
        loadSpriteTexture(self.head_icon,PathTool.getHeadIcon(self.data.bid),LOADTEXT_TYPE)

        local hero_type = self.data.type or 0
        local res = PathTool.getResFrame('common', 'common_900' .. (45 + hero_type))
        self.hero_career:loadTexture(res, LOADTEXT_TYPE_PLIST)


        self.name_label:setString(self.data.name)
        self:createStar(self.data.show_star)
    end
end

function PartnerSummonPreviewItem:createStar(num)
    num = num or 0
    local size = cc.size(14 * num, 15)
    self.star_con:setContentSize(size)
    for i = 1, num do
        if not self.star_list[i] then
            local res = PathTool.getResFrame("common", "common_90013")
            local star = createImage(self.star_con, res, 0, size.height / 2, cc.p(0, 0.5), true, 0, false)
            star:setScale(0.9)
            self.star_list[i] = star
        end
        self.star_list[i]:setVisible(true)
        self.star_list[i]:setPosition(cc.p((i - 1) * 14 - 3, size.height / 2))
    end
end

function PartnerSummonPreviewItem:selected(bool)
    if not self.selected_bg then
        self.selected_bg = createScale9Sprite(PathTool.getResFrame("common", "common_90019"), 0, 0, LOADTEXT_PLIST, self)
        self.selected_bg:setAnchorPoint(cc.p(0, 0))
        self.selected_bg:setContentSize(self.size)
    end
    if self.selected_bg then
        self.selected_bg:setVisible(bool)
    end
end
function PartnerSummonPreviewItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
