--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年10月18日
-- @description    : 
        -- 组队竞技场排行奖励
---------------------------------
ArenateamRankRewardPanel = ArenateamRankRewardPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()

function ArenateamRankRewardPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "ladder/ladder_award_window"
end

function ArenateamRankRewardPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 1)

    local win_title = main_container:getChildByName("win_title")
    win_title:setString(TI18N("排名奖励"))
    local range_label = main_container:getChildByName("range_label")
    range_label:setString(TI18N("名次"))
    local reward_label = main_container:getChildByName("reward_label")
    reward_label:setString(TI18N("奖励"))

    self.close_btn = main_container:getChildByName("close_btn")

    local my_rank = main_container:getChildByName("my_rank")
    local award_title = my_rank:getChildByName("award_title")
    award_title:setString(TI18N("保持排名可获得奖励:"))
    local rank_title = my_rank:getChildByName("rank_title")
    rank_title:setString(TI18N("我的排名:"))
    self.rank_label = my_rank:getChildByName("rank_label")
    local tips_label = my_rank:getChildByName("tips_label")
    tips_label:setString(TI18N("结算奖励将在周日23:40通过邮件发放"))
    self.good_con = my_rank:getChildByName("good_con")

    local good_con_size = self.good_con:getContentSize()
    self.good_con_size = good_con_size
    self.item_scroll_view = createScrollView(good_con_size.width, good_con_size.height, 0, 0, self.good_con, ccui.ScrollViewDir.horizontal) 
    self.item_scroll_view:setAnchorPoint(cc.p(0, 0))
    self.item_scroll_view:setInnerContainerSize(cc.size(good_con_size.width, good_con_size.height))
    self.item_scroll_view:setSwallowTouches(false)

    self.item_list = main_container:getChildByName("item_list")
    local bgSize = self.item_list:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = CrossarenaAwardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 608,               -- 单元的尺寸width
        item_height = 124,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.award_scrollview = CommonScrollViewLayout.new(self.item_list, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)
end

function ArenateamRankRewardPanel:openRootWnd(  )
    self:setData()
end

function ArenateamRankRewardPanel:setData(  )
    local award_config = Config.ArenaTeamData.data_rank_reward
    if award_config then
        local award_data = {}
        for k,v in pairs(award_config) do
            table.insert(award_data, v)
        end

        local function sortFunc( objA, objB )
            return objA.min < objB.min
        end
        table.sort(award_data, sortFunc)

        self.award_scrollview:setData(award_data)

        -- 我的排名
        local myBaseData = model:getMyTeamInfo()
        local rank = 0
        if myBaseData then
            rank = myBaseData.rank or 0
        end
        if rank <= 0 then
            self.rank_label:setString(TI18N("未上榜"))
            self.rank_label:setTextColor(cc.c3b(169, 95 ,15))
        else
            self.rank_label:setString(rank)
            self.rank_label:setTextColor(cc.c3b(336, 144, 3))
        end

        local my_award = {}
        for k,v in pairs(award_data) do
            if myBaseData.rank and myBaseData.rank >= v.min and myBaseData.rank <= v.max then
                my_award = v.items
            end
        end

        local scale = 0.8
        local space_x = 15
        local start_x = 35
        self.item_scroll_view:removeAllChildren()
        for i,award in pairs(my_award) do
            if type(award) == "table" then
                local bid = award[1]
                local num = award[2]
                local item_conf = Config.ItemData.data_get_data(bid)
                if item_conf then
                    local item = BackPackItem.new(false, true, false, 1, false, true)
                    local _x = start_x + (BackPackItem.Width*scale + space_x) * (i-1) + BackPackItem.Width*scale*0.5
                    local _y = self.good_con_size.height/2
                    item:setBaseData(bid, num)
                    item:setDefaultTip(true)
                    item:setPosition(_x, _y)
                    item:setScale(scale)
                    self.item_scroll_view:addChild(item)
                end
            end
        end
    end
end

function ArenateamRankRewardPanel:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), true, 2)
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
end

function ArenateamRankRewardPanel:_onClickBtnClose(  )
    controller:openArenateamRankRewardPanel(false)
end

function ArenateamRankRewardPanel:close_callback(  )
    if self.award_scrollview then
        self.award_scrollview:DeleteMe()
        self.award_scrollview = nil
    end
    controller:openArenateamRankRewardPanel(false)
end

-----------------------------------@ 奖励item
CrossarenaAwardItem = class("CrossarenaAwardItem", function()
    return ccui.Widget:create()
end)

function CrossarenaAwardItem:ctor()
    self:configUI()
    self:register_event()
end

function CrossarenaAwardItem:configUI(  )
    self.size = cc.size(608,124)
    self:setTouchEnabled(false)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("ladder/ladder_award_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("main_container")
    self.container = container

    self.rank_label = container:getChildByName("rank_label")
    self.image = container:getChildByName("image")
    self.good_con = container:getChildByName("good_con")
    self.image:ignoreContentAdaptWithSize(true)

    local good_con_size = self.good_con:getContentSize()
    self.good_con_size = good_con_size
    self.item_scroll_view = createScrollView(good_con_size.width, good_con_size.height, 0, 0, self.good_con, ccui.ScrollViewDir.horizontal) 
    self.item_scroll_view:setAnchorPoint(cc.p(0, 0))
    self.item_scroll_view:setInnerContainerSize(cc.size(good_con_size.width, good_con_size.height))
    self.item_scroll_view:setSwallowTouches(false)
end

function CrossarenaAwardItem:register_event(  )
    
end

function CrossarenaAwardItem:setData( data )
    data = data or {}

    if data.min == 1 then
        self.image:setVisible(true)
        self.rank_label:setVisible(false)
        self.image:loadTexture(PathTool.getResFrame("common","common_2001"), LOADTEXT_TYPE_PLIST)
    -- elseif data.min == 2 then
    --     self.image:setVisible(true)
    --     self.rank_label:setVisible(false)
    --     self.image:loadTexture(PathTool.getResFrame("common","common_2002"), LOADTEXT_TYPE_PLIST)
    -- elseif data.min == 3 then
    --     self.image:setVisible(true)
    --     self.rank_label:setVisible(false)
    --     self.image:loadTexture(PathTool.getResFrame("common","common_2003"), LOADTEXT_TYPE_PLIST)
    else
        self.image:setVisible(false)
        self.rank_label:setVisible(true)
        local range_str = ""
        if data.min == data.max then
            range_str = data.min
        else
            if data.max == 999 then
                range_str = string.format("%d+", data.min)
            else
                range_str = string.format("%d~%d", data.min, data.max)
            end
        end
        self.rank_label:setString(range_str)
    end

    local scale = 0.8
    local space_x = 15
    local start_x = 35
    self.item_scroll_view:removeAllChildren()
    for i,award in pairs(data.items) do
        if type(award) == "table" then
            local bid = award[1]
            local num = award[2]
            local item_conf = Config.ItemData.data_get_data(bid)
            if item_conf then
                local item = BackPackItem.new(false, true, false, 1, false, true, false)
                local _x = start_x + (BackPackItem.Width*scale + space_x) * (i-1) + BackPackItem.Width*scale*0.5
                local _y = self.good_con_size.height/2
                item:setBaseData(bid, num)
                item:setDefaultTip(true)
                item:setPosition(_x, _y)
                item:setScale(scale)
                self.item_scroll_view:addChild(item)
            end
        end
    end
    self.item_scroll_view:setTouchEnabled(#data.items > 3)
end

function CrossarenaAwardItem:DeleteMe(  )
    self:removeAllChildren()
    self:removeFromParent()
end