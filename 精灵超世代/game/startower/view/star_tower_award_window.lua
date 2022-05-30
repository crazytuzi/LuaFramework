-- --------------------------------------------------------------------
-- 竖版星命塔奖励总览
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerAwardWindow = StarTowerAwardWindow or BaseClass(BaseView)

local table_insert =table.insert
local table_sort = table.sort
local string_format = string.format
local controller = StartowerController:getInstance()
local reward_data = Config.StarTowerData.data_get_floor_award

function StarTowerAwardWindow:__init(set_id,pos)
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = false
    self.title_str = TI18N("奖励总览")
    self.cloth_data = data or {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_71"), type = ResourcesType.single },
    }
    self.win_type = WinType.Big
end

function StarTowerAwardWindow:open_callback()
    local csbPath = PathTool.getTargetCSB("startower/star_tower_award")
    local root = cc.CSLoader:createNode(csbPath)
    self.container:addChild(root)

    self.main_panel = root:getChildByName("main_panel")
    self.title_icon = self.main_panel:getChildByName("title_icon")
    self.title_icon:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_71"), LOADTEXT_TYPE)

    self:updateAwardList()
end

function StarTowerAwardWindow:register_event()
    self:addGlobalEvent(StartowerEvent.Update_Reward_Event,function()
        self:updateAwardList()
    end)

end
function StarTowerAwardWindow:openRootWnd()
end

function StarTowerAwardWindow:updateAwardList()
    
    if not self.list_view then
        local scroll_view_size = cc.size(620,590)
        local setting = {
            item_class = StarTowerAwardItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 620,               -- 单元的尺寸width
            item_height = 125,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(13, 12) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    end

    local dic_reward = self.ctrl:getModel():getRewardData()
    local list = {}
    for k,v in pairs(dic_reward) do
        if reward_data[v.id] then --过滤
            table_insert(list, v)
        end
    end
    list = self.ctrl:getModel():sortFunc(list)
    self.list_view:setData(list)
end

function StarTowerAwardWindow:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    self.ctrl:openAwardWindow(false)
end

-- --------------------------------------------------------------------
-- 竖版奖励子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerAwardItem = class("StarTowerAwardItem", function()
    return ccui.Widget:create()
end)

function StarTowerAwardItem:ctor()
    self.reward_list = {}
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function StarTowerAwardItem:config()
    self.size = cc.size(620,125)
    self:setContentSize(self.size)
end
function StarTowerAwardItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("startower/star_tower_award_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
   
    self.sprite_get = self.main_panel:getChildByName("sprite_get")
    self.sprite_get:setVisible(false)
    self.btn_goto = self.main_panel:getChildByName("btn_goto")
    local btn_goto_label = self.btn_goto:getChildByName("Text_4")
    -- btn_goto_label:setString(TI18N("前往"))
    -- btn_goto_label:enableOutline(Config.ColorData.data_color4[263], 2)

    self.btn_get = self.main_panel:getChildByName("btn_get")
    self.btn_get:setVisible(false)
    local btn_get_label = self.btn_get:getChildByName("Text_4")
    -- btn_get_label:setString(TI18N("领取"))
    -- btn_get_label:enableOutline(Config.ColorData.data_color4[264], 2)
    
    self.good_cons = self.main_panel:getChildByName("good_cons")
    -- self.text_floor = self.main_panel:getChildByName("text_floor")
    self.text_floor = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(18,102), nil, nil, 600)
    self.main_panel:addChild(self.text_floor)

    local scroll_view_size = self.good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7,
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function StarTowerAwardItem:setData(data)
    if not data then return end
    local item_data = data --controller:getModel():getRewardData(data._index)
    self.tower_data = item_data
    self.sprite_get:setVisible(item_data.status == 2)
    self.btn_get:setVisible(item_data.status == 1)
    self.btn_goto:setVisible(item_data.status == 0)

    if not reward_data[item_data.id] then return end
    local str = string_format(TI18N("通过%d层<div fontcolor=%s>(%d/%d)</div>"),reward_data[item_data.id].tower,Config.ColorData.data_new_color_str[12],controller:getModel():getNowTowerId(),reward_data[item_data.id].tower)

    self.text_floor:setString(str)

    local list = {}
    for i,v in pairs(reward_data[item_data.id].award) do
        local tab = {}
        tab.id = v[1]
        tab.quantity = v[2]
        table_insert(list,tab)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function ()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end
function StarTowerAwardItem:registerEvents()
    registerButtonEventListener(self.btn_goto, function()
        controller:openAwardWindow(false)
    end,true, 1)
    registerButtonEventListener(self.btn_get, function()
        controller:sender11328(self.tower_data.id)
    end,true, 1)
end

function StarTowerAwardItem:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end 
    if self.reward_list and next(self.reward_list or {}) ~= nil then
        for i, v in ipairs(self.reward_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
end




