-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      我的矿脉信息
-- <br/> 2019年7月16日
-- --------------------------------------------------------------------
ActiontermbeginsCollectResultPanel = ActiontermbeginsCollectResultPanel or BaseClass(BaseView)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ActiontermbeginsCollectResultPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "actiontermbegins/action_term_begins_collect_reward_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("termbeginsreward","termbeginsreward"), type = ResourcesType.plist }
    }

    self.dic_collect_schedule = {}

     self.paper_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.paper_item_id
    if config then
        self.paper_item_id = config.val
    end
end

function ActiontermbeginsCollectResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("收集奖励"))
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.scroll_container = self.main_container:getChildByName("scroll_container")

    self.tip_1 = self.main_container:getChildByName("tip_1")
    self.tip_1:setString(TI18N("关卡大挑战活动可以掉落满分试卷"))
    self.tip_2 = self.main_container:getChildByName("tip_2")
    self.tip_2:setString(TI18N("达成条件未领取的奖励,将会在活动结束后通过邮件发放"))

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("提交试卷"))
end

function ActiontermbeginsCollectResultPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickBtnComfirm) ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)


    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_PAPER_REWARD_LIST_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)

    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_RECEIVE_PAPER_EVENT, function(data)
        if not data then return end
        if self.dic_collect_schedule and self.dic_collect_schedule[data.id] then
            self.dic_collect_schedule[data.id].staus = 2
            self.dic_collect_schedule[data.id].sort = 3
            self:updateList()
            GlobalEvent:getInstance():Fire(ActiontermbeginsEvent.TERM_BEGINS_REWARD_REDPOINT_EVENT, data)
        end
    end)

    -- --提交试卷
    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_SUBIT_PAPER_EVENT, function(data)
        if not data then return end
        if not self.show_list then return end
        controller:sender26705()
        self:updateComfirmRedPoint()
    end)
end

--关闭
function ActiontermbeginsCollectResultPanel:onClickBtnClose()
    controller:openActiontermbeginsCollectResultPanel(false)
end
--提交试卷
function ActiontermbeginsCollectResultPanel:onClickBtnComfirm()
    local setting = {}
     self.paper_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.paper_item_id
    if config then
        self.paper_item_id = config.val
    end
    
    setting.item_id = self.paper_item_id
    setting.shop_type = MallConst.MallType.TermBeginsBuy
    ActiontermbeginsController:getInstance():openActionBuyPanel(true, setting)
end

--@level_id 段位
function ActiontermbeginsCollectResultPanel:openRootWnd(setting)
    local setting = setting or {}
    self.is_time_out = setting.is_time_out
    local confing_list = Config.HolidayTermBeginsData.data_cellect_reward_info
    if not confing_list then return end    
    table_sort( confing_list, function(a, b) return a.id < b.id end)

    self.show_list = {}
    self.dic_collect_schedule = {}
    for i,v in ipairs(confing_list) do
        self.dic_collect_schedule[v.id] = {}
        self.dic_collect_schedule[v.id].config = v
        self.dic_collect_schedule[v.id].staus = 0 
        self.dic_collect_schedule[v.id].sort = 2
        self.dic_collect_schedule[v.id].id = v.id
        table_insert(self.show_list, self.dic_collect_schedule[v.id])
    end
    controller:sender26705()
    self:updateComfirmRedPoint()
end

function ActiontermbeginsCollectResultPanel:updateComfirmRedPoint()
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.paper_item_id)
    if not self.is_time_out and count > 0 then 
        addRedPointToNodeByStatus(self.comfirm_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.comfirm_btn, false, 5, 5)
    end
end

function ActiontermbeginsCollectResultPanel:setData(data)
    if not self.show_list then return end 

    for _,progress_data in ipairs(data.collect_schedule) do
        if self.dic_collect_schedule[progress_data.id] then
            for k,v in pairs(progress_data) do
                self.dic_collect_schedule[progress_data.id][k] = v
            end
            
            if progress_data.staus == 2 then --已领取
                self.dic_collect_schedule[progress_data.id].sort = 3
            elseif  progress_data.staus == 1 then -- 可领取
                self.dic_collect_schedule[progress_data.id].sort = 1
            else
                self.dic_collect_schedule[progress_data.id].sort = 2
            end
        end
    end

    self.paper_num = data.num or 0

    self:updateList()
end

function ActiontermbeginsCollectResultPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 612,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    local sort_func = SortTools.tableLowerSorter({"sort", "id"})
    table_sort(self.show_list, sort_func)
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无奖励数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActiontermbeginsCollectResultPanel:createNewCell(width, height)
   local cell = ActionTermBeginsCollectRewardItem.new(width, height, self)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActiontermbeginsCollectResultPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActiontermbeginsCollectResultPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.paper_num)
end


function ActiontermbeginsCollectResultPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openActiontermbeginsCollectResultPanel(false)
end


-- 子项
ActionTermBeginsCollectRewardItem = class("ActionTermBeginsCollectRewardItem", function()
    return ccui.Widget:create()
end)

function ActionTermBeginsCollectRewardItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ActionTermBeginsCollectRewardItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("actiontermbegins/action_term_begins_collect_reward_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.name = self.container:getChildByName("name")
    self.count = self.container:getChildByName("count")
    self.box_img = self.container:getChildByName("box_img")
    self.is_receive = self.container:getChildByName("is_receive")

    -- self.desc_1 = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(self.name_x, 28), 6, nil, 900)
    -- self.container:addChild(self.desc_1)

    self.receive_btn = self.container:getChildByName("receive_btn")
    self.receive_btn:getChildByName("label"):setString(TI18N("领 取"))
    self.goto_btn = self.container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("前 往"))

    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
end

function ActionTermBeginsCollectRewardItem:register_event( )
    registerButtonEventListener(self.receive_btn, function() self:onReceiveBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.goto_btn, function() self:onGotoBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

--领取
function ActionTermBeginsCollectRewardItem:onReceiveBtn()
    if not self.data then return end
    controller:sender26706(self.data.id)
end

--前往
function ActionTermBeginsCollectRewardItem:onGotoBtn()
    if not self.data then return end
    self.parent:onClickBtnClose()
end


function ActionTermBeginsCollectRewardItem:setData(data, paper_num)
    if not data then return end
    if not data.config then return end

    self.data = data
    if self.box_img then
        local res = data.config.res or  "termbeginsreward_02"
        if self.record_res == nil or self.record_res ~= res then
            self.record_res = res
            local res_path = PathTool.getResFrame("termbeginsreward",res)
            loadSpriteTexture(self.box_img, res_path, LOADTEXT_TYPE_PLIST)
        end
    end
    local str = string_format(TI18N("提交%s份满分试卷可以获得"), data.config.count)
    self.name:setString(str)
    local  num 
    local paper_num = paper_num or 0
    if paper_num > data.config.count then
        num = data.config.count
    else
        num = paper_num
    end

    local count_str = string_format("(%s/%s)", num, data.config.count)
    self.count:setString(count_str)
    
    local data_list = data.config.award
    local setting = {}
    setting.scale = 0.7
    setting.max_count = 3
    -- setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)

    local staus = data.staus or 0
    self.is_receive:setVisible(staus == 2) --已领取
    self.receive_btn:setVisible(staus == 1) --可领取
    self.goto_btn:setVisible(staus == 0) --不可领取
end

function ActionTermBeginsCollectRewardItem:DeleteMe()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    self:removeAllChildren()
    self:removeFromParent()
end