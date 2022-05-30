--[[
    例子:
    local callback = function(index, data, setting)
        print("返回的idnex: "..index)
        dump(data, "数据是:")
    end
    local data_list = {{id = 1, value = "测试1"}, {id = 2, value = "测试2"},{id = 3, value = "测试3"},{id = 4, value = "测试4"}}
    local setting = {} --属于可以选参数..都有默认值的.
    setting.offsetx = 0  --调整位置的偏移量 默认 0 
    setting.offsety = 0  --调整位置的偏移量 默认 0 
    setting.combo_show_type = 1  --下拉框的显示类型 目前只有一种样式 默认 1
    setting.select_index = 1  --当前选择..默认 1
    setting.item_height = 54  --显示item的高度..默认 54
    CommonUIController:getInstance():openCommonComboboxPanel(true, world_pos, callback, data_list, setting )
]]--

-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      通用下拉框 
-- <br/>Create:2019年10月28日
-- --------------------------------------------------------------------
CommonComboboxPanel = CommonComboboxPanel or BaseClass(BaseView)

local controller = CommonUIController:getInstance()

function CommonComboboxPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "common/common_combobox_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    self.item_height = 54
end

function CommonComboboxPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        -- self.background:setSwallowTouches(false)
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
      --下拉框面板
    self.combobox_panel = self.main_panel:getChildByName("combobox_panel")
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(308, 190) --最大size 根据示意图得出来的
end

function CommonComboboxPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
end

--关闭
function CommonComboboxPanel:onClickCloseBtn()
    controller:openCommonComboboxPanel(false)
end


--@world_pos 世界坐标位置
--@callback 回调函数 返回时候自行处理自己的函数
--@data_list  数据列表 格式 {{id = id, value = value}, ...} 
--@setting 配置文件.也会从callback原路返回
--@setting.offsetx  调整位置的偏移量 默认 0 
--@setting.offsety  调整位置的偏移量 默认 0 
--@setting.combo_show_type  1 默认颜色  2 巅峰冠军赛暗黑样式(图片也是巅峰冠军赛图集的)
--@setting.select_index  当前选择..默认 1
--@setting.item_height  显示item的高度..默认 54
--@setting.dir_type  方向 1 表示下拉  2 表示上拉
function CommonComboboxPanel:openRootWnd(world_pos, callback, data_list, setting)
    if not world_pos then return end
    local data_list = data_list
    if data_list == nil or next(data_list) == nil then return end

    self.callback = callback
    local setting = setting or {}
    self.setting = setting

    self.combo_show_type = setting.combo_show_type or 1

    self.select_index = setting.select_index or 1
    self.item_height = setting.item_height or 54

    --默认值 在open_callback里面定义
    if setting.combobox_max_size then
        self.combobox_max_size = setting.combobox_max_size
        self.combobox_panel:setContentSize(self.combobox_max_size)
        self.combobox_bg:setPositionX(self.combobox_max_size.width * 0.5)
    end
    self.show_max_count = math.floor(self.combobox_max_size.height/self.item_height)
    if setting.combobox_bg_size then
        self.combobox_bg_size = setting.combobox_bg_size
    end

    self.other_index = setting.other_index

    self.dir_type = setting.dir_type or 1

    local node_pos = self.main_panel:convertToNodeSpace(world_pos)
    if node_pos then
        local offsetx = setting.offsetx or 0
        local offsety = setting.offsety or 0
        self.combobox_panel:setPosition(cc.p(node_pos.x + offsetx, node_pos.y + offsety))
    end
    self:updateComboboxList(data_list)

    -- if self.combo_show_type == 2 then
    --     local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_mian_14", false, "arenapeak_guessing")
    --     self.combobox_bg:loadTexture(res, LOADTEXT_TYPE_PLIST)
    -- end
end

--更新下拉列表 
function CommonComboboxPanel:updateComboboxList(data_list)
    if not data_list then return end
    local item_height = 54
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
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
        local height = 0
        if count > self.show_max_count then
            self.combobox_scrollview:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
            height = self.combobox_bg_size.height
        else
            self.combobox_scrollview:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
            height = total_height
        end
        if self.dir_type == 2 then
            --往上的
            local y = self.combobox_panel:getPositionY()
            self.combobox_panel:setPositionY(y + height)
        end
        self.show_list = data_list
        self.combobox_scrollview:reloadData(self.select_index)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function CommonComboboxPanel:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(true)
    cell:setContentSize(cc.size(width, height))

    self:initComboItemStyle(cell, width, height)
    cell:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            -- cell.select_bg:setVisible(true)
            cell.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.moved then
            -- cell.select_bg:setVisible(false)
        elseif event_type == ccui.TouchEventType.ended then
            local touch_began = cell.touch_began
            local touch_end = sender:getTouchEndPosition()
            if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 10 or math.abs(touch_end.y - touch_began.y) > 10) then 
                --点击无效了
                return
            end 

            playButtonSound2()
            self:setCellTouched(cell)
        end
    end)
    return cell
end

--获取数据数量
function CommonComboboxPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function CommonComboboxPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    if self.combo_show_type == 1 then 
        cell.label:setString(data.value)
    else
        cell.label:setString(data.value)
        if self.other_index == index then
            cell.icon:setVisible(true)
        else
            cell.icon:setVisible(false)
        end
        if self.select_index == index then
            cell.select_bg:setVisible(true)
        else
            cell.select_bg:setVisible(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function CommonComboboxPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
    if self.callback then
        self.callback(index, data, self.setting)
    end
    self:onClickCloseBtn()
end

--初始化item的样式.. 根据 combo_show_type 来决定
function CommonComboboxPanel:initComboItemStyle(cell, width, height)
    
    if self.combo_show_type == 1 then
        local size = cc.size(width - 15, 3)
        local res = PathTool.getResFrame("common","common_1016")
        cell.bg = createImage(cell, res, 5, 2, cc.p(0, 0), true, 0, true)
        cell.bg:setContentSize(size)
        cell.bg:setOpacity(90)
        cell.bg:setCapInsets(cc.rect(13, 1, 1, 1))
        cell.label = createLabel(26, cc.c4b(0x64,0x32,0x23,0xff), nil, 10, height * 0.5 , "", cell, nil, cc.p(0,0.5))
        -- local mark_res = PathTool.getResFrame("common", "common_1043")
        -- cell.mark_img = createSprite(mark_res, width - 10, height * 0.5 + 2, cell, cc.p(1,0.5), LOADTEXT_TYPE_PLIST)
        -- cell.mark_img:setScale(0.8)
    elseif self.combo_show_type == 2 then 
        local size = cc.size(width - 15, 3)
        -- local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_mian_16", false, "arenapeak_guessing")
        local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_mian_19", false, "arenapeak_guessing")
        cell.bg = createImage(cell, res, 5, 2, cc.p(0, 0), true, 0, true)
        cell.bg:setContentSize(size)
        cell.bg:setOpacity(90)
        cell.bg:setCapInsets(cc.rect(13, 1, 1, 1))

        -- local res = PathTool.getResFrame("common","common_1044")
        local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_mian_20", false, "arenapeak_guessing")
        cell.select_bg = createImage(cell, res, 2, 4, cc.p(0, 0), true, 0, true)
        -- cell.select_bg:setContentSize(cc.size(width, height))
        cell.select_bg:setContentSize(cc.size(width-10, height-6))
        -- cell.select_bg:setOpacity(90)
        cell.select_bg:setCapInsets(cc.rect(84, 18, 1, 1))
        cell.select_bg:setVisible(false)

        cell.label = createLabel(26, Config.ColorData.data_new_color4[6], nil, width * 0.5, height * 0.5 , "", cell, 2, cc.p(0.5,0.5))
        local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_mian_17", false, "arenapeak_guessing")
        cell.icon = createImage(cell, res, 0, height * 0.5, cc.p(0, 0.5), true, 0, false)
    end
end


function CommonComboboxPanel:close_callback()
    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end

    controller:openCommonComboboxPanel(false)
end
