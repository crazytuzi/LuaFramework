-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛录像预览
-- <br/> 2019年3月1日
-- --------------------------------------------------------------------
ElitematchFightRecordPanel = ElitematchFightRecordPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchFightRecordPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_fight_record_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    -- self.dic_reward_list = {}
    -- self.show_list = {}
    self.arena_elite_log_list = {}
end

function ElitematchFightRecordPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.tab_container = self.main_panel:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("我的录像"),
        [2] = TI18N("大师风采")
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("战斗记录"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_label = self.main_panel:getChildByName("top_label")
    self.bottom_label = self.main_panel:getChildByName("bottom_label")

     self.top_label:setString(TI18N("录像可以在\"详细\"中观看"))
end

function ElitematchFightRecordPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

     --积分发送改变的时候
    self:addGlobalEvent(ElitematchEvent.Elite_Challenge_Record_Event, function(data)
        if not data then return end
        self.arena_elite_log_list[data.type] = data
        if self.index == data.type then
            self:setData(data.arena_elite_log)
        end
    end)
end

--关闭
function ElitematchFightRecordPanel:onClickBtnClose()
    controller:openElitematchFightRecordPanel(false)
end


-- 切换标签页
function ElitematchFightRecordPanel:changeSelectedTab( index )
    if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
    self.index = index
    --数据
    if self.arena_elite_log_list[index] == nil then
        controller:sender24930(index)
    else
        self:setData(self.arena_elite_log_list[index].arena_elite_log)
    end
end

--@level_id 段位
function ElitematchFightRecordPanel:openRootWnd(index, level_id)
    self.index = index or 1
    self.level_id = level_id or 1

    local config  = Config.ArenaEliteData.data_elite_level[self.level_id]
    if config then
         self.bottom_label:setString(TI18N("当前你的段位为:")..config.name)
    end
    -- controller:sender24930(index)
    self:changeSelectedTab(self.index)
end

function ElitematchFightRecordPanel:setData(list)
    self.show_list = list
    self:updateList()
end

function ElitematchFightRecordPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            item_height = 244,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)
    end
    self.item_scrollview:reloadData()
end

--显示空白
function ElitematchFightRecordPanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then
        return
    end
    local main_size = self.scroll_container:getContentSize()
    if not self.empty_con then
        local size = cc.size(200, 200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5, 0))
        self.empty_con:setPosition(cc.p(main_size.width / 2, 330))
        self.scroll_container:addChild(self.empty_con, 10)
        local res = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3')
        local bg = createImage(self.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
        
        local login_data = LoginController:getInstance():getModel():getLoginData()
        local str 
        if login_data and login_data.isTry then
            local content_list = {"先行体验服暂时无法显示该内容", "其他服务器同步跨服数据后将正常显示","请耐心等待"}
            self:updateNotCanMatchIngInfo(content_list, self.empty_con, size.width / 2, -10)
        else
            self.empty_label = createLabel(26, Config.ColorData.data_color4[175], nil, size.width / 2, -10, '', self.empty_con, 0, cc.p(0.5, 0))
            self.empty_label:setString(TI18N("暂无数据"))
        end 
        
    end

    self.empty_con:setVisible(bool)
end

--更新不能匹配界面信息
--@ content_list显示的内容信息
function ElitematchFightRecordPanel:updateNotCanMatchIngInfo(content_list, parent, x, y)
    if not content_list then return end

    if self.tips_label_list == nil then
        self.tips_label_list = {}
    end
    for i,label in ipairs(self.tips_label_list) do
        label:setVisible(false)
    end
    local label_height = 28
    local start_y = y
    for i,content in ipairs(content_list) do
        local y = start_y - label_height * (i - 1)
        if self.tips_label_list[i] == nil then
            self.tips_label_list[i] = createLabel(26, Config.ColorData.data_color4[175], nil, x, y, "", parent, 2, cc.p(0.5, 0.5))
        else
            self.tips_label_list[i]:setPositionY(y)
        end
        self.tips_label_list[i]:setString(TI18N(content))
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ElitematchFightRecordPanel:createNewCell(width, height)
   local cell = ElitematchFightRecordItem.new()
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ElitematchFightRecordPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ElitematchFightRecordPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.index)
end


function ElitematchFightRecordPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openElitematchFightRecordPanel(false)
end
