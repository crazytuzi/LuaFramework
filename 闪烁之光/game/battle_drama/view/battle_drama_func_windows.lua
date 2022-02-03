-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      掉落信息查看面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattlDramafuncWindow = BattlDramafuncWindow or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 

function BattlDramafuncWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "battledrama/battle_drama_open_func_view"
    self.item_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("battleopen", "battleopen"), type = ResourcesType.plist},
    }

end
function BattlDramafuncWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.item_container = self.main_container:getChildByName("item_container")
    local setting = {
        item_class = BattleDramaFuncItem,
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BattleDramaFuncItem.WIDTH, -- 单元的尺寸width
        item_height = BattleDramaFuncItem.HEIGHT, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类
        need_dynamic = true,
    }
    self.scroll_view = CommonScrollViewLayout.new(self.item_container, nil, nil, ScrollViewStartPos.top, cc.size(self.item_container:getContentSize().width, self.item_container:getContentSize().height), setting)
    self.scroll_view:setPosition(0, 0)

    self.back_container = self.main_container:getChildByName("back_container")
    self.desc_label = self.main_container:getChildByName("desc_label")
    self.empty_bg = self.main_container:getChildByName('empty_bg')
    self.empty_bg:setVisible(false)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName('desc_label')
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N('暂无记录'))
end

function BattlDramafuncWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openBattleDramaFuncView(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openBattleDramaFuncView(false) 
            end
        end)
    end
end

function BattlDramafuncWindow:openRootWnd()
    delayRun(self.main_container,0.1,function ()
        self:updateItemReward(Config.DungeonData.data_drama_pre_fun)
    end)
end


function BattlDramafuncWindow:updateItemReward(data)
    if data then
        local list  = {}
        local base_data = BattleDramaController:getInstance():getModel():getDramaData()
        if base_data then
            for i, v in ipairs(data) do
                v.has_open = 0
                if v.limit_id <= base_data.max_dun_id then
                    v.has_open = 1
                end
                table.insert(list,v)
            end
        end
        local sort_func = SortTools.tableLowerSorter({"has_open","id"})
        table.sort(list,sort_func)
        self.empty_bg:setVisible(false)
        if list and next(list or {}) ~= nil then
            self.scroll_view:setData(list)
        else
            self.empty_bg:setVisible(true)
        end
    end


end

function BattlDramafuncWindow:close_callback()
    if self.cur_item then
        self.cur_item:DeleteMe()
        self.cur_item = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
                v = nil
            end
        end
    end
    self.item_list = {}
    controller:openBattleDramaFuncView(false)
end