-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      成长之路
-- <br/> 2019年6月12日
-- --------------------------------------------------------------------
RolePersonalSpaceTabGrowthWayPanel = class("RolePersonalSpaceTabGrowthWayPanel", function()
    return ccui.Widget:create()
end)

local controller = RoleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

function RolePersonalSpaceTabGrowthWayPanel:ctor(parent)
    --单次申请记录的数量
    self.record_count_param = 10
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:config()
    self:loadResources()
end

function RolePersonalSpaceTabGrowthWayPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolepersonalspace","rolepersonalspace"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        if tolua.isnull(self) then return end
        self:layoutUI()
        self:registerEvents()
        self.is_load_completed = true
        if self.visible_status then
            self:setVisibleStatus(true)
        end
    end)
end

function RolePersonalSpaceTabGrowthWayPanel:setVisibleStatus(bool)
    if not self.role_vo then return end
    if not self.parent then return end

    self.visible_status = bool or false 
    self:setVisible(bool)

    if bool and self.is_load_completed then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT)
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            controller:send25830(0, self.record_count_param or 10)
        else
            if self.parent.other_data  then
                controller:send25832(self.parent.other_data.rid, self.parent.other_data.srv_id, 0, self.record_count_param or 10)
            end
        end
    end
end

function RolePersonalSpaceTabGrowthWayPanel:config()

end

function RolePersonalSpaceTabGrowthWayPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("roleinfo/role_personal_space_tab_growth_way_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_img = self.main_container:getChildByName("title_img")

     -- 标题
    local res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_growth_way_bg", false)
    if self.record_title_img_res == nil or self.record_title_img_res ~= res then
        self.record_title_img_res = res
        self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img_res) 
    end 

    --分享按钮
    self.share_btn = self.main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("分享"))

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        self.share_btn:setVisible(true)
    else
        self.share_btn:setVisible(false)
    end

    self.player_name = self.main_container:getChildByName("player_name")

    self:initScrollview()
end
function RolePersonalSpaceTabGrowthWayPanel:initScrollview()

    --列表
    self.lay_srollview = self.main_container:getChildByName("lay_srollview")
    local scrollview_size = self.lay_srollview:getContentSize()

    self.space_y        = 10               -- 竖向间隔空间
    self.item_width     = 580             -- 单元的宽度
    self.item_height    = 140              -- 单元的高度

    self.col = 1

    self.cacheMaxSize = math.ceil(scrollview_size.height / (self.item_height + self.space_y)) + 1
    --存放所有格子结构体
    self.cellList = {}
    --缓存Cell所用到的对象
    self.cacheList = {}
    --记录活跃得格子ID
    self.activeCellIdx = {}
    self.scroll_view_size = cc.size(scrollview_size.width, scrollview_size.height)
    self.scroll_view = createScrollView(scrollview_size.width, scrollview_size.height, 0, 0, self.lay_srollview, ScrollViewDir.vertical)
    -- self.scroll_view:setBounceEnabled(false)
    self.scroll_view_container = self.scroll_view:getInnerContainer()

end

--事件
function RolePersonalSpaceTabGrowthWayPanel:registerEvents()
    registerButtonEventListener(self.share_btn, function(param, sender) self:onShareBtn(sender)  end ,true, 1)
    registerButtonEventListener(self.show_set_btn, function() self:onShowSetBtn()  end ,true, 1)
    registerButtonEventListener(self.honor_btn, function() self:onHonorBtn()  end ,true, 1)

    if self.scroll_view then
        self.scroll_view:addEventListener(function(sender, eventType)
            if eventType == ccui.ScrollviewEventType.containerMoved then
                self:checkOverShowByVertical()
            end
        end)
    end

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if self.myself_growth_way_event == nil then
            self.myself_growth_way_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_MYSELF_GROWTH_WAY_EVENT,function (data)
                if not data then return end
                self.is_init = true
                if data.start ~= 0 then
                    self:addGrowthWayData()
                else
                    self:setData(data)
                end
            end)
        end
    else --他人 
        if self.other_growth_way_event == nil then
            self.other_growth_way_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_OHTER_GROWTH_WAY_EVENT,function (data)
                if not data then return end
                self.is_init = true
                if data.start ~= 0 then
                    self:addGrowthWayData()
                else
                    self:setData(data)
                end
            end)
        end
    end
end

--分享
function RolePersonalSpaceTabGrowthWayPanel:onShareBtn(sender)
    local setting = {}
    setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
    setting.callback = function(share_type) 
        if self and self.root_wnd and(not tolua.isnull(self.root_wnd)) then
            self:shareCallback(share_type) 
        end
    end
    setting.y = -20 
    TaskController:getInstance():openTaskSharePanel(true, setting)
end

function RolePersonalSpaceTabGrowthWayPanel:shareCallback(share_type)
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        controller:send25831(ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        controller:send25831(ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        controller:send25831(ChatConst.Channel.Cross)
    end
end

function RolePersonalSpaceTabGrowthWayPanel:setData()
    if not self.role_vo then return end
    if not self.parent then return end
    self.isLoadingData = false
    self:updateGrowthWaylist()

    local player_name = ""
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        local sever_name = getServerName(self.role_vo.srv_id) or TI18N("异域")
        player_name =  string_format("%s - %s", sever_name, self.role_vo.name) 
        
    else
        if self.parent.other_data then
            local sever_name = getServerName(self.parent.other_data.srv_id) or TI18N("异域")
            player_name =  string_format("%s - %s", sever_name, self.parent.other_data.name) 
        end
    end
    self.player_name:setString(player_name)
end


function RolePersonalSpaceTabGrowthWayPanel:checkOverShowByVertical()
    if not self.cellList then return end
    if not self.scroll_view_container_size then return end
    if not self.is_data_load_finish then return end
    local container_y = self.scroll_view_container:getPositionY()
    --计算 视图的上部分和下部分在self.scroll_view_container 的位置
    local bot = -container_y
    local top = self.scroll_view_size.height + bot
    local col_count = math.ceil(#self.cellList/self.col)
    --下面因为 self.cellList 是一维数组 所以要换成二维来算
    --活跃cell开始行数
    local activeCellStartRow = 1
    local item_height = 0
    for i=1, col_count do
        local index = 1 + (i-1)* self.col
        local cell = self.cellList[index]
        activeCellStartRow = i
        item_height = cell.item_height or self.item_height
        if cell and cell.y - item_height <= top then
            break
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = col_count
    if bot > 0 then
        for i = activeCellStartRow, col_count do
            local index = 1 + (i-1)* self.col
            local cell = self.cellList[index]
            -- item_height = cell.item_height or self.item_height
            if cell and cell.y < bot then
                activeCellEndRow = i - 1
                break
            end
        end
    end
    -- print("保留--> top --> :"..top .." self.col:"..self.col)
    -- print("保留--> bot --> :"..bot )
    -- print("保留--> 开始行: "..activeCellStartRow.."结束行: "..activeCellEndRow)
    local max_count = self:numberOfCells()
    for i=1, col_count do
        if i >= activeCellStartRow and i <= activeCellEndRow then
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if not self.activeCellIdx[index] then
                    if index <= max_count then
                        self:updateCellAtIndex(index)
                        self.activeCellIdx[index] = true
                    end
                end    
            end
        else
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if index <= max_count then
                    self.activeCellIdx[index] = false
                end
            end
        end
    end

    if top >= self.scroll_view_container_size.height then
        self:checkLoadData()
    end
end

function RolePersonalSpaceTabGrowthWayPanel:reloadData(is_keep_position)
    if not self.show_list then return end
    if self.test_content == nil then
        self.test_content = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,1), cc.p(-10000, 80), 6, nil, 488)
        self.main_container:addChild(self.test_content)
    end

    self.is_data_load_finish = false
    self.cellList = {}
    self.activeCellIdx = {}

    local old_width , old_height = 0, 0
    if self.scroll_view_container_size then
        old_width = self.scroll_view_container_size.width
        old_height = self.scroll_view_container_size.height
    end

    for k, v in ipairs(self.cacheList) do
        --相当于隐藏
        v:setPositionX(-10000)
    end

    local number = self:numberOfCells()
    if number == 0 then
        return
    end

    local x = self.item_width * 0.5 + 3
    local single_text_height = 24
    local total_y = 0 
    local last_time = 0

    local min_distance = 2
    local max_distance = 92
    local day_distance = (max_distance - min_distance)/30
    local days = TimeTool.day2s()
    for i = 1, number do
        local data = self.show_list[i]
        if not data then return end
        local cell = self:getCacheCellByIndex(i)
        self.test_content:setString(data.desc) --测试用
        local size = self.test_content:getContentSize()

        local text_height = size.height - single_text_height
        if text_height < 0 then
            text_height = 0
        end
        local item_height = self.item_height + text_height

        local distance = 0
        if last_time == 0 then
            last_time = data.time
            distance = 0
        else

            local temp_time = data.time - last_time
            if temp_time < 0 then
                temp_time = 0
            end
            local day = math_floor(temp_time/days)
            distance = min_distance + day * day_distance
            if distance > max_distance then
                distance = max_distance
            end
            last_time = data.time
        end
        total_y = total_y + distance
        local cellData = {cell = cell, x = x, _y = total_y, item_height = item_height}
        table_insert(self.cellList, cellData)

        total_y = total_y + item_height + self.space_y
    end

    local container_height = total_y - self.space_y
    self:setInnerContainer(container_height)

    --计算一下所在的y位置
    for i,v in ipairs(self.cellList) do
        v.y = self.scroll_view_container_size.height - v._y
    end
    self.is_data_load_finish = true

    if is_keep_position then
        local cur_container_x =  self.cur_container_x or 0
        local cur_container_y =  self.cur_container_y or 0
        -- local temp_height = self.scroll_view_container_size.height - old_height
        -- cur_container_y = cur_container_y -  temp_height

        if cur_container_y > 0 then
            cur_container_y = 0
        elseif cur_container_y < (self.scroll_view_size.height - self.scroll_view_container_size.height) then
            cur_container_y = self.scroll_view_size.height - self.scroll_view_container_size.height
        end
        
        self.scroll_view_container:setPositionY(cur_container_y)
    else
        self.scroll_view_container:setPositionY(0)
    end
    self:checkOverShowByVertical()
end

--设置列表高度
function RolePersonalSpaceTabGrowthWayPanel:setInnerContainer(container_height)
    local container_width = self.scroll_view_size.width
    local container_height = math.max(container_height, self.scroll_view_size.height)
    self.scroll_view_container_size = cc.size(container_width, container_height)
    self.scroll_view:setInnerContainerSize(self.scroll_view_container_size)
end

--获得格子下标对应的缓存itemCell
function RolePersonalSpaceTabGrowthWayPanel:getCacheCellByIndex(index)
    local cacheIndex = (index - 1) % self.cacheMaxSize + 1
    if not self.cacheList[cacheIndex] then
        local newCell = self:createNewCell()
        if newCell then
            newCell:setAnchorPoint(cc.p(0.5, 1))
            newCell:setPositionX(-10000)--隐藏
            self.cacheList[cacheIndex] = newCell
            self.scroll_view:addChild(newCell)
        end
        return newCell
    else
        return self.cacheList[cacheIndex]
    end
end

--更新格子，并记为活跃
function RolePersonalSpaceTabGrowthWayPanel:updateCellAtIndex(index)
    if not self.scroll_view_container_size then return end
    -- if index > self.time_show_index then
    --     return
    -- end
    if not self.cellList[index] then return end
    local cellData = self.cellList[index]
    if cellData.cell == nil then
        cellData.cell = self:getCacheCellByIndex(index)
    end
    cellData.cell:setPosition(cellData.x, cellData.y)
    self:updateCellByIndex(cellData.cell, index, cellData.item_height)
end

--检测加载数据
function RolePersonalSpaceTabGrowthWayPanel:checkLoadData()
    if not self.show_list then return end
    if self.show_list[1] and self.show_list[1].order ~= 1 then
        if self.isLoadingData then return end
        self.isLoadingData = true
        --说明有数据需要从网络获取
        local start = self.show_list[1].order
        start = start - self.record_count_param
        if start <= 0 then
            start = 1
        end
        local num = self.show_list[1].order - start
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            controller:send25830(start, num)
        else
            if self.parent.other_data then
                controller:send25832(self.parent.other_data.rid, self.parent.other_data.srv_id, start, num)
            else
                return
            end
        end
        --加loadingui
        self:showLoadingUI(true)
        self:setLoadingTime()
    end
end

function RolePersonalSpaceTabGrowthWayPanel:showLoadingUI(status)
    if not self.scroll_view_container_size then return end

    if status then
        local container_height = self.scroll_view_container_size.height + 50
        self:setInnerContainer(container_height)
        if self.loadingLayout == nil then
            self.loadingLayout = ccui.Widget:create()
            self.loadingLayout:setContentSize(cc.size(self.item_width, 50))
            self.loadingLayout:setAnchorPoint(cc.p(0.5, 1))
            self.loadingLayout:setPosition(self.item_width * 0.5, container_height)
            local text_content = TI18N("加载中")
            self.loading_label = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, self.item_width * 0.5 , 25, text_content, self.loadingLayout, nil, cc.p(0.5,0.5))
            self.scroll_view:addChild(self.loadingLayout)
        else
            self.loadingLayout:setPosition(self.item_width * 0.5, container_height)
            self.loadingLayout:setVisible(true)
        end
    else
        if self.loadingLayout then
           self.loadingLayout:setVisible(false) 
        end
        local container_height = self.scroll_view_container_size.height - 50
        self:setInnerContainer(container_height)
    end
end

--设置倒计时
function RolePersonalSpaceTabGrowthWayPanel:setLoadingTime()
    if tolua.isnull(self.loading_label) then
        return 
    end
    self.loading_label:stopAllActions()
    local btn_time = 1
    self.time_step = 0
    self:setLoadingFormatString(btn_time)
    self.loading_label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),
    cc.CallFunc:create(function()
            btn_time = btn_time + 1
            if btn_time > 4 then
                btn_time = 1
            end
            self.time_step = self.time_step + 1
            -- if self.time_step > 5 then
            --     --模拟数据回来
            --     self:addGrowthWayData()
            -- end
            self:setLoadingFormatString(btn_time)
    end))))
end

function RolePersonalSpaceTabGrowthWayPanel:setLoadingFormatString(time)
    if time == 1 then
        self.loading_label:setString(TI18N("加载中."))
    elseif time == 2 then
        self.loading_label:setString(TI18N("加载中.."))
    elseif time == 3 then
        self.loading_label:setString(TI18N("加载中..."))
    else
        self.loading_label:setString(TI18N("加载中"))
    end
end

function RolePersonalSpaceTabGrowthWayPanel:initShowList()
    local list 
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        list = model:getGrowthWayData()
    else
        list = model:getOtherGrowthWayData(self.parent.other_data.rid, self.parent.other_data.srv_id)
    end
    if not list then return end 
    local growth_way_desc_fun = Config.RoomGrowData.data_growth_way_desc
    self.show_list = {}
    for k,v in pairs(list) do
        if v.desc == nil then
            local config = growth_way_desc_fun(v.id)
            if config then
                table_sort(v.arge, function(a, b) return a.pos < b.pos end)
                local params = {}
                for i=1,4 do
                    local txt = v.arge[i]
                    if txt == nil then
                        table_insert(params, TI18N("<div fontcolor=#e25a00>未知</div>"))
                    else
                        local val = txt.val
                        if i == 1 and BT_Power_Rate ~= 1 and string.find(config.desc, "战力") and v.id ~= 132003 then --BT适配
                            val = tostring(changeBtValueForPower(tonumber(val)))
                        end
                        table_insert(params, string_format("<div fontcolor=#e25a00>%s</div>", val))
                    end
                end
                v.desc = string_format(config.desc, unpack(params))
            else
                v.desc = TI18N("无记录:"..tostring(v.id))
            end
        end
        table_insert(self.show_list, v)
    end
    if #self.show_list > 0 then
        local last_data = {}
        last_data.is_last = true
        last_data.order = 999999
        last_data.time = self.show_list[#self.show_list].time
        last_data.desc = TI18N("继续记录你的冒险之旅")
        table_insert(self.show_list, last_data)
    end
    --xie dao l 
    table_sort(self.show_list, function(a, b) return a.order < b.order end)
end

function RolePersonalSpaceTabGrowthWayPanel:addGrowthWayData()
    if not self.loading_label then return end
    self.loading_label:stopAllActions()
    self.cur_container_x, self.cur_container_y = self.scroll_view_container:getPosition()
    self.isLoadingData = false
    self:showLoadingUI(false)

    self:initShowList()
    --测试数据-->
    -- local curTime = os.time()
    -- for i=1,10 do
    --     local data = {}
    --     data.order = i 
    --     data.time = curTime + i * 86400
    --     data.desc = i.."加载的数据测试显示"
    --     local tttt = i%3
    --     if tttt == 1 then
    --         data.desc = data.desc.."第一种长度"
    --     elseif tttt == 2 then
    --         data.desc = data.desc.."第二种长度第二种长度第二种长度第二种长度"
    --     else
    --         data.desc = data.desc.."其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度"
    --     end

    --     table_insert(self.show_list, data)
    -- end
    -- table_sort(self.show_list, function(a, b) return a.order < b.order end)
    --测试数据-->
    self:reloadData(true)
end

--列表
function RolePersonalSpaceTabGrowthWayPanel:updateGrowthWaylist()
    self:initShowList()
    --测试数据-->
    -- self.show_list = {}
    -- local curTime = os.time()
    -- for i=1,20 do
    --     local data = {}
    --     data.order = i + 20
    --     data.time = curTime + i * 86400
    --     data.desc = i.."测试显示"
    --     local tttt = i%3
    --     if tttt == 1 then
    --         data.desc = data.desc.."第一种长度"
    --     elseif tttt == 2 then
    --         data.desc = data.desc.."第二种长度第二种长度第二种长度第二种长度"
    --     else
    --         data.desc = data.desc.."其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度其他长度"
    --     end
    --     table_insert(self.show_list, data)
    -- end

    -- table_sort(self.show_list, function(a, b) return a.order < b.order end)
    --测试数据-->
    self:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true)
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end    
end

--创建cell  
--@width 是setting.item_width
--@height 是setting.item_height
function RolePersonalSpaceTabGrowthWayPanel:createNewCell()
    local cell = RoleGrowtnWayItem.new(self.item_width, self.item_height, self.parent, self.test_content)
    return cell
end

--获取数据数量
function RolePersonalSpaceTabGrowthWayPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RolePersonalSpaceTabGrowthWayPanel:updateCellByIndex(cell, index, item_height)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data, item_height)
end

--点击cell .需要在 createNewCell 设置点击事件
function RolePersonalSpaceTabGrowthWayPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
end


--移除
function RolePersonalSpaceTabGrowthWayPanel:DeleteMe()
    if self.myself_growth_way_event then
        GlobalEvent:getInstance():UnBind(self.myself_growth_way_event)
        self.myself_growth_way_event = nil
    end
    if self.other_growth_way_event then
        GlobalEvent:getInstance():UnBind(self.other_growth_way_event)
        self.other_growth_way_event = nil
    end

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end

    self:showLoadingUI(false)
end


-- 子项
RoleGrowtnWayItem = class("RoleGrowtnWayItem", function()
    return ccui.Widget:create()
end)

function RoleGrowtnWayItem:ctor(width, height, parent, test_content)
    self.parent = parent
    self.test_content = test_content
    self:configUI(width, height)
    self:register_event()
end

function RoleGrowtnWayItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("roleinfo/role_growtn_way_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    --self.line_1 = self.main_container:getChildByName("line_1")
    self.time = self.main_container:getChildByName("time")
    self.box_bg = self.main_container:getChildByName("box_bg")
    self.box_bg_size = self.box_bg:getContentSize()
    self.desc = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0,1), cc.p(85, 80), 6, nil, 488)
    self.main_container:addChild(self.desc)
end

function RoleGrowtnWayItem:register_event( )

end

function RoleGrowtnWayItem:setData(data, item_height)
    self.data = data
    if data.is_last then
        --self.line_1:setVisible(false)
        self.time:setVisible(false)
        local res = PathTool.getResFrame("rolepersonalspace", "role_personal_space_38")
        local desc = string_format("%s<img src=%s scale=1 />", data.desc, res)
        self.desc:setString(desc)
        self.desc:setPositionY(70)
    else
        --self.line_1:setVisible(true)
        self.time:setVisible(true)
        self.desc:setString(data.desc)
        self.desc:setPositionY(80)
        self.time:setString(TimeTool.getYMD3(data.time).."(UTC +0)")
    end
    self.box_bg:setContentSize(cc.size(self.box_bg_size.width, item_height - 2))
end

function RoleGrowtnWayItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.honor_item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end