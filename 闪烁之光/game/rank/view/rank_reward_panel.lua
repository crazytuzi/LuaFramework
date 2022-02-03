-- --------------------------------------------------------------------
-- 竖版排行榜排行界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      奖励预览排行榜
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RankRewardPanel = RankRewardPanel or BaseClass(BaseView)

local controller = RankController:getInstance()
local table_sort = table.sort
local string_format = string.format
--@排行榜奖励类型
function RankRewardPanel:__init(rank_reward_type)
    self.is_full_screen = false
    self.win_type = WinType.Big      
    self.layout_name = "rank/rank_reward_panel"

    self.res_list = {
    }

   
    self.rank_reward_type = rank_reward_type or 1
end

function RankRewardPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

    self.rank_panel = self.main_container:getChildByName("rank_panel")
    self.my_rank = self.main_container:getChildByName("my_rank")
    local title = self.my_rank:getChildByName("title")
    title:setString(TI18N("我的排名"))

    self.rank_index = self.my_rank:getChildByName("rank_id")
    self.label_tips = self.my_rank:getChildByName("label_tips")
    self.item_scrollview = self.my_rank:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    -- self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()


    self.title_con = self.main_container:getChildByName("title_con")
    local title = self.title_con:getChildByName("title_label")
    local name = "奖励预览" or ""
    title:setString(name)
end

function RankRewardPanel:register_event()
    registerButtonEventListener(self.background, function() self:onClosedBtn() end ,false, 1)

    --协议16650返回
    self:addGlobalEvent(ActionEvent.RANK_REWARD_LIST, function(data)
        if not data then return end
        self.cell_data_list = data.rank_award
        table_sort(self.cell_data_list, function(a, b) return a.rank1 < b.rank2 end)
        if #self.cell_data_list  == 0 then
            self:showEmptyIcon()
        else
            self:updateRankList()
        end
        self:updateMyRankInfo(data.rank)
    end)
end

function RankRewardPanel:onClosedBtn()
    controller:openRankRewardPanel(false)
end

--@rank_data 排行奖励预览信息 结构参考 本类 --协议16650返回的下返回的结构
--@my_rank -- 我排名
function RankRewardPanel:openRootWnd(rank_data, my_rank)
    if rank_data ~= nil then
        self.cell_data_list = rank_data
        if #self.cell_data_list  == 0 then
            self:showEmptyIcon()
        else
            self:updateRankList()
        end
        self:updateMyRankInfo(my_rank)
    else
        ActionController:getInstance():send16650(self.rank_reward_type)
    end
end

--更新我的排行信息
--@my_rank 我的排名
function RankRewardPanel:updateMyRankInfo(my_rank)
    if not self.cell_data_list then return end
    if my_rank == nil or my_rank == 0 then
        self.rank_index:setVisible(false)
        self.label_tips:setString(TI18N("未上榜"))
        return    
    end
    self.rank_index:setString(my_rank)
    local cell_data = nil
    for i, data in ipairs(self.cell_data_list) do
        if data.rank1 and data.rank2 then
            if my_rank >= data.rank1 and my_rank <= data.rank2 then
                cell_data = data
            end
        elseif data.rank1 then
            if my_rank <= data.rank1 then
                cell_data = data
            end
        end
    end
    if not cell_data then return end
    --道具列表
    local scale = 0.8
    local offsetX = 10
    local item_count = #cell_data.award
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(self.item_scrollview_size.width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview_size.height))

    if item_count <= 3 then
        --小于等于3 个不给移动
        self.item_scrollview:setTouchEnabled(false)
    end

    self.item_list = {}
    self.start_x = offsetX * 0.5
    local item = nil
    local size = #self.item_list 
    for i, v in ipairs(cell_data.award) do
        delayRun(self.item_scrollview,i / display.DEFAULT_FPS,function ()
            if not self.item_list[i] then
                item = BackPackItem.new(true, true)
                item:setAnchorPoint(0, 0.5)
                item:setScale(scale)
                item:setSwallowTouches(false)
                self.item_scrollview:addChild(item)
                self.item_list[i] = item
                local _x = self.start_x + (i - 1) * (item_width + offsetX) + 8
                item:setPosition(_x, self.item_scrollview_size.height * 0.5)
                item:setBaseData(v.bid, v.num, true)
                item:setDefaultTip()
            end
        end)
    end
end

function RankRewardPanel:updateRankList()
    if self.common_scrollview == nil then
        local lay_scrollview = self.main_container:getChildByName("lay_scrollview")
        local scroll_view_size = lay_scrollview:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 634,                -- 单元的尺寸width
            item_height = 142,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.common_scrollview = CommonScrollViewSingleLayout.new(lay_scrollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.common_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.common_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RankRewardPanel:createNewCell(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("rank/rank_reward_item"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.main_container = cell.root_wnd:getChildByName("main_container")
    cell.rank_img = cell.main_container:getChildByName("rank_img")
    cell.rank_label = cell.main_container:getChildByName("rank_label")

    --列表
    cell.item_scrollview = cell.main_container:getChildByName("item_scrollview")
    cell.item_scrollview:setScrollBarEnabled(false)
    cell.item_scrollview:setSwallowTouches(false)
    cell.item_scrollview_size = cell.item_scrollview:getContentSize()

    --道具列表
    cell.item_list = {}
    --回收用
    cell.DeleteMe = function() 
        doStopAllActions(cell.item_scrollview)
        if cell.item_list ~= nil then
            for k,v in pairs(cell.item_list) do
                v:DeleteMe()
            end
            cell.item_list = nil
        end
    end
    return cell
end
--获取数据数量
function RankRewardPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RankRewardPanel:updateCellByIndex(cell, index)
    local cell_data = self.cell_data_list[index]

    if not cell_data then return end
    --前三名用图片
    if cell_data.rank1 <= 3  then
        cell.rank_label:setVisible(false)
        cell.rank_img:setVisible(true)
        local res_id = PathTool.getResFrame("common", "common_200"..cell_data.rank1)
        loadSpriteTexture(cell.rank_img, res_id, LOADTEXT_TYPE_PLIST)
    else
        cell.rank_label:setVisible(true)
        cell.rank_img:setVisible(false)
        local str = nil
        if cell_data.rank1 and cell_data.rank2 then
            --和运营协议 如果 后面9999的默认变成 200+
            if cell_data.rank2 == 9999 then
                str = string_format("%s+",cell_data.rank1)
            else
                str = string_format("%s~%s",cell_data.rank1, cell_data.rank2)
            end
        else
            str = cell_data.rank1
        end
        cell.rank_label:setString(str)
    end

    --物品
    if cell.item_list then
        for i,v in ipairs(cell.item_list) do
            v:setVisible(false)
        end
    end
    --道具列表
    local scale = 0.9
    local offsetX = 14
    local item_count = #cell_data.award
    local item_width = BackPackItem.Width * scale

    local total_width =  (item_width + offsetX) * item_count
    local max_width = math.max(cell.item_scrollview_size.width, total_width)
    cell.item_scrollview:setInnerContainerSize(cc.size(max_width, cell.item_scrollview_size.height))
    if item_count <= 3 then
        --小于等于3 个不给移动
        cell.item_scrollview:setTouchEnabled(false)
    end
    cell.start_x = offsetX * 0.5
    cell.item_scrollview:stopAllActions()
    local item = nil
    local size = #cell.item_list 
    for i, v in ipairs(cell_data.award) do
        item = cell.item_list[i]
        if item then
            item:setVisible(true)
            local _x = cell.start_x + (i - 1) * (item_width + offsetX) + 8
            item:setPosition(_x, cell.item_scrollview_size.height * 0.5)
            item:setBaseData(v.bid, v.num, true)
            item:setDefaultTip()
        else
            local dealey = i - size
            if dealey <= 0 then
                dealey = 1
            end
            delayRun(cell.item_scrollview,dealey / display.DEFAULT_FPS,function ()
                if not cell.item_list[i] then
                    item = BackPackItem.new(true, true)
                    item:setAnchorPoint(0, 0.5)
                    item:setScale(scale)
                    item:setSwallowTouches(false)
                    cell.item_scrollview:addChild(item)
                    cell.item_list[i] = item
                    local _x = cell.start_x + (i - 1) * (item_width + offsetX) + 8
                    item:setPosition(_x, cell.item_scrollview_size.height * 0.5)
                    item:setBaseData(v.bid, v.num, true)
                    item:setDefaultTip()
                end
            end)
        end
    end
end

--显示空白
function RankRewardPanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    local main_size = self.main_container:getContentSize()
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5,0))
        self.empty_con:setPosition(cc.p(main_size.width/2,330))
        self.main_container:addChild(self.empty_con,10)
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
        local bg = createImage(self.empty_con, res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("暂无奖励数据")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function RankRewardPanel:close_callback()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)
    if self.common_scrollview then 
        self.common_scrollview:DeleteMe()
        self.common_scrollview = nil
    end
end
