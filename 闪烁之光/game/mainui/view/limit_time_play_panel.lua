 
-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      通用下拉框 
-- <br/>Create:2019年10月28日
-- --------------------------------------------------------------------
LimitTimePlayPanel = LimitTimePlayPanel or BaseClass(BaseView)

local controller = MainuiController:getInstance()
local table_insert = table.insert
local string_format = string.format

function LimitTimePlayPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "mainui/limit_time_play_panel"
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.time_desc_list = {}
end

function LimitTimePlayPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        self.background:setSwallowTouches(false)
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
      --下拉框面板
    self.combobox_panel = self.main_panel:getChildByName("combobox_panel")
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(220, 450) --最大size 根据示意图得出来的
    self.show_max_count = 6
    --最大支持 6个
end

function LimitTimePlayPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
end

--关闭
function LimitTimePlayPanel:onClickCloseBtn()
    controller:openLimitTimePlayPanel(false)
end


--@world_pos 世界坐标位置
--@setting 配置文件.也会从callback原路返回
--@setting.offsetx  调整位置的偏移量 默认 0 
--@setting.offsety  调整位置的偏移量 默认 0 
--@setting.combo_show_type  下拉框的显示类型 目前只有一种样式
--@setting.select_index  当前选择..默认 1
--@setting.item_height  显示item的高度..默认 54
function LimitTimePlayPanel:openRootWnd(setting)
    local dic_data = ActionController:getInstance():getModel():getLimitIconData()
    if dic_data ==nil and next(dic_data) == nil then return end
    local data_list = {}
    for i,v in pairs(dic_data) do
        local config = Config.FunctionData.data_info[v.id]
        local function_vo = controller:createFunctionVo(config)
        if function_vo then
            function_vo:update({v})
            table_insert(data_list, function_vo)
        end
    end

    local sort_func = SortTools.tableLowerSorter({ "pos", "sort" })
    table.sort(data_list, sort_func)

    local setting = setting or {}
    local world_pos = setting.world_pos
    self.setting = setting
    local node_pos = self.main_panel:convertToNodeSpace(world_pos)
    if node_pos then
        local offsetx = 92
        local offsety = 83
        self.combobox_panel:setPosition(cc.p(node_pos.x + offsetx, node_pos.y + offsety))
    end
    self:updateComboboxList(data_list)
    self:startTimeTicket()
end

function LimitTimePlayPanel:startTimeTicket()
    if self.timeticket == nil then
        self:countDownEndTime()
        self.timeticket = GlobalTimeTicket:getInstance():add(function()
            self:countDownEndTime()
        end, 1)
    end
end

function LimitTimePlayPanel:countDownEndTime()
    if self.combobox_scrollview then
         for i,v in pairs(self.combobox_scrollview.activeCellIdx) do
            if v and self.time_desc_list[i] then
                self:updateTimeByIndex(i, self.time_desc_list[i])
            end
        end
    end
end

--更新下拉列表 
function LimitTimePlayPanel:updateComboboxList(data_list)
    if not data_list then return end
    local item_height = 75
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 2,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = self.combobox_max_size.width,                -- 单元的尺寸width
            item_height = item_height,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.combobox_scrollview = CommonScrollViewSingleLayout.new(self.combobox_panel, cc.p(4,3) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.combobox_max_size, setting, cc.p(0, 0))

        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    if next(data_list) ~= nil then 
        local count = #data_list
        if count > self.show_max_count then
            self.combobox_scrollview:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
        else
            self.combobox_scrollview:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
        end
        self.show_list = data_list
        self.combobox_scrollview:reloadData(self.select_index)
    end
end
--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function LimitTimePlayPanel:createNewCell(width, height)
    local cell = LimitTimePlayItem.new(width, height)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function LimitTimePlayPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function LimitTimePlayPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    local time_desc = cell:setData(data)
    self.time_desc_list[index] = time_desc
    self:updateTimeByIndex(index, time_desc)
end

--点击cell .需要在 createNewCell 设置点击事件
function LimitTimePlayPanel:onCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
    MainuiController:getInstance():iconClickHandle(data.config.id, nil, data.action_id)    
    self:onClickCloseBtn()
end

function LimitTimePlayPanel:updateTimeByIndex(index, time_val)
    -- body 
    local cell_data = self.show_list[index]
    if cell_data then
        if time_val then TimeTool.GetTimeForFunction(time)
            local time = cell_data.end_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
            end
            local time_desc = "0"
            if cell_data.config.id == MainuiConst.icon.champion then
                if cell_data.status == 1 then
                    time_desc = string_format(TI18N("<div fontcolor=#249003>%s</div>后开启"),TimeTool.GetTimeForFunction(time))
                elseif cell_data.status == 2 then
                    time_desc = string_format(TI18N("进行中:<div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
                end
            elseif cell_data.config.id == MainuiConst.icon.godbattle then
                if cell_data.status == 1 then
                    time_desc = string_format(TI18N("报名中:<div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
                elseif cell_data.status == 2 then
                    time_desc = string_format(TI18N("进行中:<div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
                end
            elseif cell_data.config.id == MainuiConst.icon.guildwar then
                if cell_data.status == 1 then
                    time_desc = string_format(TI18N("<div fontcolor=#249003>%s</div>后开启"),TimeTool.GetTimeForFunction(time))
                elseif cell_data.status == 2 then
                    time_desc = string_format(TI18N("<div fontcolor=#249003>%s</div>后结束"),TimeTool.GetTimeForFunction(time))
                end
            elseif cell_data.config.id == MainuiConst.icon.peak_champion then
                time_desc = string_format(TI18N("<div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
            else
                time_desc = string_format(TI18N("<div fontcolor=#249003>%s</div>"),TimeTool.GetTimeForFunction(time))
            end
            time_val:setString(time_desc)
        end
    end
end


function LimitTimePlayPanel:close_callback()
    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end

    if self.timeticket then
        GlobalTimeTicket:getInstance():remove(self.timeticket)
        self.timeticket = nil
    end

    controller:openLimitTimePlayPanel(false)
end

------------------------------------------
-- 子项
LimitTimePlayItem = class("LimitTimePlayItem", function()
    return ccui.Widget:create()
end)

function LimitTimePlayItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function LimitTimePlayItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("mainui/limit_time_play_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.root_wnd:setPosition(-1 , 0)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.btn_name = main_container:getChildByName("btn_name")

    self.time_val = createRichLabel(18, cc.c4b(0x64,0x32,0x23,0xff), cc.p(1,0.5), cc.p(200, 22), 6, nil, 900)
    main_container:addChild(self.time_val)

    self.goto_btn = main_container:getChildByName("goto_btn")
    self.icon = self.goto_btn:getChildByName("icon")
end

function LimitTimePlayItem:register_event( )
    registerButtonEventListener(self.goto_btn, function() self:onGotoBtn() end,true, 1)
end

function LimitTimePlayItem:onGotoBtn()
    if not self.data then return end
    if self.callback then
        self.callback()
    end
end

function LimitTimePlayItem:addCallBack(callback)
    self.callback = callback
end

function LimitTimePlayItem:setData( data )
    self.data = data
    if self.data == nil or self.data.config == nil then return end

    if self.data.real_name and self.data.real_name ~= "" and self.data.real_name ~= "null" then
        self.btn_name:setString(self.data.real_name)
    else
        self.btn_name:setString(self.data.config.icon_name)
    end
    --图
    local res_id = self.data.real_res_id
    if res_id == "" then
        res_id = self.data.res_id
    end
    local target_res = PathTool.getFunctionRes(res_id)
    if target_res ~= self.res_id then
        self.res_id = target_res
        loadSpriteTexture(self.icon, self.res_id, LOADTEXT_TYPE)
    end

    return self.time_val
end

function LimitTimePlayItem:DeleteMe( )
    self:removeAllChildren()
    self:removeFromParent()
end