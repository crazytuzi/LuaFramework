--自选礼包 
local arard_data = Config.RecruitHolidayLuckyData.data_award

HeroSelectPanel = HeroSelectPanel or BaseClass(BaseView)
function HeroSelectPanel:__init()
    self.layout_name = "elitesummon/hero_select_panel"
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.cur_item = nil
end

function HeroSelectPanel:open_callback()
    local main_panel = self.root_wnd:getChildByName("main_panel")  
    self:playEnterAnimatianByObj(main_panel, 2)
    self.close_btn = main_panel:getChildByName("close_btn") 
    main_panel:getChildByName("top_panel"):getChildByName("title_label"):setString(TI18N("自选奖励"))

    self.desc_label = createRichLabel(24, Config.ColorData.data_color4[156], cc.p(0.5,1), cc.p(315,710), 2, nil, 600)
    main_panel:addChild(self.desc_label)
    self.desc_label:setString("")

    self.item_scroll = main_panel:getChildByName("item_scroll")
    local scroll_view_size = self.item_scroll:getContentSize()
    local setting = {
        item_class = HeroSelectItem, -- 单元类
        start_x = 8, -- 第一个单元的X起点
        space_x = 20, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = HeroSelectItem.width,
        item_height = HeroSelectItem.height,
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.item_scroll,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)

    --领取按钮
    self.use_btn = main_panel:getChildByName("use_btn")
    self.use_btn:getChildByName("label"):setString(TI18N("使用"))
    self.use_btn:setVisible(false)
end
function HeroSelectPanel:register_event()
    registerButtonEventListener(self.close_btn, function() 
        TimesummonController:getInstance():openHeroSelectView(false)
    end, false, 2)

    registerButtonEventListener(self.use_btn, function()
        if self.group_id and self.self_award_id then
            EliteSummonController:getInstance():send23232(5, self.self_award_id)
        end
    end, false, 1)
end

function HeroSelectPanel:openRootWnd(data, cur_times)
    if self.item_scrollview then
        self.group_id = data.camp_id
        if arard_data[self.group_id] and arard_data[self.group_id][5] and arard_data[self.group_id][5].self_reward then
            if data.status == false then
                if cur_times >= arard_data[self.group_id][5].times then
                    data.status = true
                end
            end
            if data.status then
                self.use_btn:setVisible(true)
                self.desc_label:setString(TI18N("请从以下奖励中选择1个"))
            else
                self.desc_label:setString(TI18N("达到指定招募次数后可从以下奖励中任选1个"))
            end

            local list = arard_data[self.group_id][5].self_reward
            self.item_scrollview:setData(list,function(cell)
                if self.cur_item ~= nil then
                    self.cur_item:setSelected(false)
                end
                self.cur_item = cell
                self.self_award_id = cell:getData()[1]
                self.award_index = cell:getData()._index
                cell:setSelected(true)
            end,nil, data.status)
        end
    end
end

function HeroSelectPanel:close_callback()
    TimesummonController:getInstance():openHeroSelectView(false)
end

--****************
--子项
--****************
HeroSelectItem = class("HeroSelectItem", function()
    return ccui.Widget:create()
end)
HeroSelectItem.width = 585
HeroSelectItem.height = 130

function HeroSelectItem:ctor(index, is_single)
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("elitesummon/hero_select_item"))
    self:setContentSize(cc.size(HeroSelectItem.width,HeroSelectItem.height))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName("container")
    self.select_btn = self.container:getChildByName("select_btn")
    self.select_btn:setVisible(false)
    self.select_choose = self.select_btn:getChildByName("Sprite_6_0")
    self.select_choose:setVisible(false)
    self.item = BackPackItem.new(true, true)
    self.item:setAnchorPoint(0.5, 0.5)
    self.item:setPosition(80,65)
    self.item:setScale(0.85)
    self.container:addChild(self.item)

    self:register_event()
end
function HeroSelectItem:register_event()
    registerButtonEventListener(self.select_btn, function()
        if self.call_fun then
            self:call_fun(self.item_data)
        end
    end, false, 1)
end

function HeroSelectItem:setExtendData(status)
    self.item_status = status or false
end
function HeroSelectItem:setData(data)
    self.item_data = data
    self.select_btn:setVisible(self.item_status)
    if data and self.item then
        self.item:setBaseData(data[1], data[2])
        if self.item_name == nil then
            self.item_name = createLabel(26, Config.ColorData.data_color4[156], nil, 180, 65, "", self.container, nil, cc.p(0, 0.5))
        end
        local config_data = Config.ItemData.data_get_data(data[1])
        self.item_name:setString(config_data.name .. "X" .. data[2])
    end
end


function HeroSelectItem:addCallBack( value )
    self.call_fun =  value
end
function HeroSelectItem:setSelected(bool)
    bool = bool or false
    self.select_choose:setVisible(bool)
end
function HeroSelectItem:getData( )
    return self.item_data
end

function HeroSelectItem:DeleteMe()
    if self.item then 
        self.item:DeleteMe()
        self.item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
