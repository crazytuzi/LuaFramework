-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛 双方阵容战斗信息 对战详情
-- <br/> 2019年11月19日
-- --------------------------------------------------------------------
ArenapeakchampionFightInfoPanel = ArenapeakchampionFightInfoPanel or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenapeakchampionFightInfoPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "arenapeakchampion/arenapeakchampion_fight_info_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    -- self.dic_reward_list = {}
    self.show_list = {}
end

function ArenapeakchampionFightInfoPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("对战详情"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.bottom_label = self.main_panel:getChildByName("bottom_label")
    self.bottom_label:setString(TI18N("系统默认将第三队伍信息隐藏"))
end

function ArenapeakchampionFightInfoPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


    --  --积分发送改变的时候
    -- self:addGlobalEvent(ElitematchEvent.Elite_Challenge_Record_Info_Event, function(data)
    --     if not data then return end
    --     self:setData(data)
    -- end)
end

--关闭
function ArenapeakchampionFightInfoPanel:onClickBtnClose()
    controller:openArenapeakchampionFightInfoPanel(false)
end

function ArenapeakchampionFightInfoPanel:openRootWnd(setting)
    local setting = setting or {}

    self.data = setting.data
    if not self.data then return end
    self:setData(self.data)
end
function ArenapeakchampionFightInfoPanel:setData(data)
    local second_data = model:getSecondData(data, nil, 3)

    self.show_list = second_data.arena_replay_infos or {}
    
    table_sort(self.show_list,function(a, b) return a.order < b.order end)
    self:updateList()
end

function ArenapeakchampionFightInfoPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 280,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    self.item_scrollview:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenapeakchampionFightInfoPanel:createNewCell(width, height)
   local cell = ArenapeakchampionFightInfoItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenapeakchampionFightInfoPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenapeakchampionFightInfoPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    if index == 3 then --第三队隐藏
        cell:setData(cell_data, true, true)
    else
        cell:setData(cell_data)
    end
    
end


function ArenapeakchampionFightInfoPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil

    controller:openArenapeakchampionFightInfoPanel(false)
end