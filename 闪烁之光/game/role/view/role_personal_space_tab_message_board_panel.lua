-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      留言板
-- <br/> 2019年6月20日
-- --------------------------------------------------------------------
RolePersonalSpaceTabMessageBoardPanel = class("RolePersonalSpaceTabMessageBoardPanel", function()
    return ccui.Widget:create()
end)

local controller = RoleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

function RolePersonalSpaceTabMessageBoardPanel:ctor(parent)
    --单次申请记录的数量
    self.record_count_param = 300
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:config()
    self:loadResources()
end

function RolePersonalSpaceTabMessageBoardPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolemessageboard","rolemessageboard"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        if tolua.isnull(self) or not self.layoutUI then return end
        self:layoutUI()
        self:registerEvents()
        self.is_load_completed = true
        if self.visible_status then
            self:setVisibleStatus(true)
        end
    end)
end

function RolePersonalSpaceTabMessageBoardPanel:setVisibleStatus(bool)
    if not self.role_vo then return end
    if not self.parent then return end

    self.visible_status = bool or false 
    self:setVisible(bool)

    if bool and self.is_load_completed then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT)
        if self.parent.role_type == RoleConst.role_type.eMySelf then
            controller:send25837(self.role_vo.rid, self.role_vo.srv_id, 0, self.record_count_param or 10)
        else
            if self.parent.other_data  then
                controller:send25837(self.parent.other_data.rid, self.parent.other_data.srv_id, 0, self.record_count_param or 10)
            end
        end
    end
end

function RolePersonalSpaceTabMessageBoardPanel:config()
    self.is_autoscrollEnded = true
    
    local max_count = 48
    local config = Config.RoomGrowData.data_const.bbs_writing_number
    if config then
        max_count = config.val
    end
    self.limit_sad_count = max_count 
    -- self.default_content_msg = string_format(TI18N("发表留言, 最多%s字"), max_count)
    self.default_content_msg = TI18N("发表留言")
    self.select_combox_type = 1
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if self.role_vo then
            self.select_combox_type = self.role_vo.room_bbs_set or 1 --默认1
        end
    else
        if self.parent.other_data then
            self.select_combox_type = self.parent.other_data.room_bbs_set or 1 --默认1
        end
    end
    self.combox_list = {
        [1] = {combox_type = 1, desc = TI18N("允许所有人留言")},
        [2] = {combox_type = 2, desc = TI18N("仅允许好友留言")}
    }

    --记录玩家最新信息
    self.dic_role_info = {}
    
end

function RolePersonalSpaceTabMessageBoardPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("roleinfo/role_personal_space_tab_message_board_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
    -- self.title_img = self.main_container:getChildByName("title_img")
    --  -- 标题
    -- local res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_growth_way_bg", false)
    -- if self.record_title_img_res == nil or self.record_title_img_res ~= res then
    --     self.record_title_img_res = res
    --     self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img_res) 
    -- end 

    --分享按钮
    self.combobox_btn = self.main_container:getChildByName("combobox_btn")
    self.combobox_btn_label = self.combobox_btn:getChildByName("label")
    self.arrow_img = self.combobox_btn:getChildByName("arrow_img")
    -- self.share_btn:getChildByName("label"):setString(TI18N("分享"))

    self.combobox_panel = self.main_container:getChildByName("combobox_panel")
    self.combobox_panel:setVisible(false)
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(self.combobox_bg_size.width, 200) --最大size 根据示意图得出来的
    self:setComboboxName(self.select_combox_type)

    self.message_btn = self.main_container:getChildByName("message_btn")
    self.message_btn:getChildByName("label"):setString(TI18N("留 言"))

    self.face_btn = self.main_container:getChildByName("face_btn")
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        self.arrow_img:setVisible(true)
    else
        self.arrow_img:setVisible(false)
    end

    self.input_edit = createEditBox(self.main_container, PathTool.getResFrame("common", "common_1021"), cc.size(348, 48), Config.ColorData.data_color3[81], 20, nil, 20, self.default_content_msg, nil, self.limit_sad_count, LOADTEXT_TYPE_PLIST)
    self.input_edit:setAnchorPoint(cc.p(0, 1))
        -- self.input_edit:setText(desc)
        -- self.input_edit:getText()
    self.input_edit:setPosition(62, 142)

    self:initScrollview()
end
function RolePersonalSpaceTabMessageBoardPanel:initScrollview()
    --列表
    self.lay_srollview = self.main_container:getChildByName("lay_srollview")
    local scrollview_size = self.lay_srollview:getContentSize()

    self.space_y        = 10               -- 竖向间隔空间
    self.item_width     = 600             -- 单元的宽度
    self.item_height    = 160              -- 单元的高度

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
    self.scroll_view:setSwallowTouches(true)
    -- self.scroll_view:setBounceEnabled(false)
    self.scroll_view_container = self.scroll_view:getInnerContainer()

end

--事件
function RolePersonalSpaceTabMessageBoardPanel:registerEvents()
    registerButtonEventListener(self.combobox_btn, function() self:onComboboxBtn()  end ,false, 1)
    registerButtonEventListener(self.message_btn, function() self:onMessageBtn()  end ,true, 1)
    registerButtonEventListener(self.face_btn, function(param, sender) self:onFaceBtn(sender)  end ,true, 1)

    registerButtonEventListener(self.main_container, function() self:showComboboxList(false) end ,false, 0)

    

    if self.scroll_view then
        self.scroll_view:addEventListener(function(sender, eventType)
            if eventType == ccui.ScrollviewEventType.containerMoved then
                self:checkOverShowByVertical()
            -- elseif eventType == ccui.ScrollviewEventType.bounceBottom then
            --     --无论是否点击在底部中 无限执行次方法
            --     print("lw--->bounceBottom eventType: "..eventType)
            -- elseif eventType == ccui.ScrollviewEventType.scrollToBottom then
            --     --点击中 到 底部 无限执行次方法
            --     self.is_to_Bottom = true
            --     print("lw--->scrollToBottom eventType: "..eventType)
            -- elseif eventType == ccui.ScrollviewEventType.scrolling then
            --     --点击移动中 无限执行次方法
            --     print("lw--->scrollingeventType: "..eventType)
            --     self.is_autoscrollEnded = false
            elseif eventType == ccui.ScrollviewEventType.autoscrollEnded then
                --点击移动中 无限执行次方法
                self.is_autoscrollEnded = true
            end
        end)
    end


    --获取留言信息
    if self.message_board_get_info_event == nil then
        self.message_board_get_info_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_MESSAGE_BOARD_GET_INFO_EVENT,function (data)
            if not data then return end
            self.is_init = true
            -- if data.start ~= 1 then
            --     self:addGrowthWayData()
            -- else
                self:setData(data)
            -- end
        end)
    end

    --新增留言
    if self.message_board_new_info_event == nil then
        self.message_board_new_info_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_MESSAGE_BOARD_NEW_INFO_EVENT,function (data)
            self:initShowList()
            self.input_edit:setText("")
            if self.scroll_view then
                --需要刷新当前
                -- self.cur_container_x, self.cur_container_y = self.scroll_view_container:getPosition()
                self:reloadData()
            end
        end)
    end

    if self.parent.role_type == RoleConst.role_type.eMySelf then
        --个人特有
        --删除留言
        if self.message_board_delete_info_event == nil then
            self.message_board_delete_info_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_MESSAGE_BOARD_DELETE_INFO_EVENT,function (data)
                self:initShowList()
                if self.scroll_view then
                    --需要刷新当前
                    self.cur_container_x, self.cur_container_y = self.scroll_view_container:getPosition()
                    self:reloadData(true)
                end
            end)
        end
        --修改限制
        if self.message_board_limit_event == nil then
            self.message_board_limit_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_MESSAGE_BOARD_LIMMIT_EVENT,function (data)
                if not data then return end
                self.select_combox_type = data.type
                self:setComboboxName(self.select_combox_type)
            end)
        end


    else --他人特有 
        
    end

    --共有有的
    if not self.add_face_evt then
        self.add_face_evt = GlobalEvent:getInstance():Bind(EventId.CHAT_SELECT_FACE, function(face_id, from_name)
            if not self.input_edit then return end
            if from_name == ChatConst.ChatInputType.eMessageBoardpanel then
                local text = self.input_edit:getText()
                self.input_edit:setText(text..face_id)
                local count = WordCensor:getInstance():relapceFaceIconTag(text)[1] or 0
                count = count + 1
                GlobalEvent:getInstance():Fire(ChatEvent.FACE_COUNT_EVENT, count)
            end
        end)
    end
end

function RolePersonalSpaceTabMessageBoardPanel:onFaceBtn()
    local world_pos = self.face_btn:convertToWorldSpace(cc.p(0, 0))
    local setting = {}
    setting.world_pos = world_pos
    setting.offset_y = 78
    RefController:getInstance():openView(ChatConst.ChatInputType.eMessageBoardpanel, setting, ChatConst.Channel.Province)
end

--下拉框点击
function RolePersonalSpaceTabMessageBoardPanel:onComboboxBtn()
    if not self.parent then return end
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        if self.is_show_combobox_panel then
            self:showComboboxList(false)
        else
            self:showComboboxList(true)
        end
    end
end
--留言点击
function RolePersonalSpaceTabMessageBoardPanel:onMessageBtn()
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not self.input_edit then return end
    if not self.parent then return end
    if not self.role_vo then return end
    local content_str = self.input_edit:getText()
    if content_str == nil or content_str == "" then
        message(TI18N("请输入留言内容"))
        return
    end
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        controller:send25835(self.role_vo.rid, self.role_vo.srv_id, content_str)
    else
        if self.parent.other_data then
            controller:send25835(self.parent.other_data.rid, self.parent.other_data.srv_id, content_str)
        end
    end
    
end

function RolePersonalSpaceTabMessageBoardPanel:setData()
    if not self.role_vo then return end
    if not self.parent then return end
    self.isLoadingData = false
    self:updateMessageBoardlist()
end


function RolePersonalSpaceTabMessageBoardPanel:checkOverShowByVertical()
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

    -- if top >= self.scroll_view_container_size.height then
    if self.is_autoscrollEnded and bot < -30 then
        self.is_autoscrollEnded = false
        self:checkLoadData()
    end

end

function RolePersonalSpaceTabMessageBoardPanel:reloadData(is_keep_position, other_height)
    if not self.show_list then return end
    if self.test_content == nil then
        self.test_content = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(-10000, 48), 6, nil, 488)
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
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("还没有留言信息哦")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end 

    if number == 0 then
        return
    end

    local x = self.item_width * 0.5
    local single_text_height = 24
    local total_y = 20
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

        local cellData = {cell = cell, x = x, _y = total_y, item_height = item_height, text_height = text_height}
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
        local other_height = other_height or 0
        local cur_container_x =  self.cur_container_x or 0
        local cur_container_y =  self.cur_container_y or 0
        local temp_height = self.scroll_view_container_size.height - old_height
        cur_container_y = cur_container_y -  temp_height + other_height

        if cur_container_y > 0 then
            cur_container_y = 0
        elseif cur_container_y < (self.scroll_view_size.height - self.scroll_view_container_size.height) then
            cur_container_y = self.scroll_view_size.height - self.scroll_view_container_size.height
        end
        
        self.scroll_view_container:setPositionY(cur_container_y)
    else
        local cur_container_y = self.scroll_view_size.height - self.scroll_view_container_size.height
        self.scroll_view_container:setPositionY(cur_container_y)
    end
    if self.parent.bbs_id then
        for i,v in ipairs(self.show_list) do
            if v.bbs_id == self.parent.bbs_id and self.cellList[i] then
                local container_y = self.cellList[i].y - self.scroll_view_size.height
                self.scroll_view_container:setPositionY(- container_y)
                break
            end
        end
        self.parent.bbs_id = nil
    end

    self:checkOverShowByVertical()
end

--设置列表高度
function RolePersonalSpaceTabMessageBoardPanel:setInnerContainer(container_height)
    local container_width = self.scroll_view_size.width
    local container_height = math.max(container_height, self.scroll_view_size.height)
    self.scroll_view_container_size = cc.size(container_width, container_height)
    self.scroll_view:setInnerContainerSize(self.scroll_view_container_size)
end

--获得格子下标对应的缓存itemCell
function RolePersonalSpaceTabMessageBoardPanel:getCacheCellByIndex(index)
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
function RolePersonalSpaceTabMessageBoardPanel:updateCellAtIndex(index)
    if not self.scroll_view_container_size then return end
    -- if index > self.time_show_index then
    --     return
    -- end
    if not self.cellList[index] then return end
    local cellData = self.cellList[index]
    if cellData.cell == nil then
        cellData.cell = self:getCacheCellByIndex(index)
    end
    if self.isLoadingData then
        cellData.cell:setPosition(cellData.x, cellData.y + 50)
    else
        cellData.cell:setPosition(cellData.x, cellData.y)
    end
    self:updateCellByIndex(cellData.cell, index, cellData.text_height)
end

--刷新一下当前位置
function RolePersonalSpaceTabMessageBoardPanel:resetCurrentPos()
    for index, active in pairs(self.activeCellIdx) do
        if active and self.cellList[index] then
            local cellData = self.cellList[index]
            if cellData.cell == nil then
                cellData.cell = self:getCacheCellByIndex(index)
            end
            if self.isLoadingData then
                cellData.cell:setPosition(cellData.x, cellData.y + 50)
            else
                cellData.cell:setPosition(cellData.x, cellData.y)
            end
        end
    end
end

--检测加载数据
function RolePersonalSpaceTabMessageBoardPanel:checkLoadData()
    --数据加载先忽视..赶不上的了 后期补上 --by lwc
-- if not self.show_list then return end
    -- local max_count = #self.show_list
    -- if max_count == 0 then return end
    -- if max_count < model.message_board_max_count then
    --     if self.isLoadingData then return end
    --     self.isLoadingData = true
    --     --说明有数据需要从网络获取
    --     local start = max_count + 1
    --     local num = self.record_count_param
    --     if self.show_list[max_count].order + num > model.growth_way_max_count then
    --         num = model.growth_way_max_count - self.show_list[max_count].order
    --     end
    --     if self.parent.role_type == RoleConst.role_type.eMySelf then
    --         controller:send25837(self.role_vo.rid, self.role_vo.srv_id, start, num)
    --     else
    --         if self.parent.other_data then
    --             controller:send25837(self.parent.other_data.rid, self.parent.other_data.srv_id, start, num)
    --         else
    --             return
    --         end
    --     end
    --     --加loadingui
    --     self:showLoadingUI(true)
    --     self:resetCurrentPos()
    --     self:setLoadingTime()
    -- end
end

function RolePersonalSpaceTabMessageBoardPanel:showLoadingUI(status)
    if not self.scroll_view_container_size then return end

    if status then
        local container_height = self.scroll_view_container_size.height + 50
        self:setInnerContainer(container_height)
        if self.loadingLayout == nil then
            self.loadingLayout = ccui.Widget:create()
            self.loadingLayout:setContentSize(cc.size(self.item_width, 50))
            self.loadingLayout:setAnchorPoint(cc.p(0.5, 0))
            self.loadingLayout:setPosition(self.item_width * 0.5, 0)
            local text_content = TI18N("加载中")
            self.loading_label = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, self.item_width * 0.5 , 25, text_content, self.loadingLayout, nil, cc.p(0.5,0.5))
            self.scroll_view:addChild(self.loadingLayout)
        else
            self.loadingLayout:setPosition(self.item_width * 0.5, 0)
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
function RolePersonalSpaceTabMessageBoardPanel:setLoadingTime()
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
            -- end
            self:setLoadingFormatString(btn_time)
    end))))
end

function RolePersonalSpaceTabMessageBoardPanel:setLoadingFormatString(time)
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

function RolePersonalSpaceTabMessageBoardPanel:initShowList()
    if not self.role_vo then return end
    local list 
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        list = model:getMessageBoardData(self.role_vo.srv_id, self.role_vo.rid)
    else
        list = model:getMessageBoardData(self.parent.other_data.srv_id, self.parent.other_data.rid)
    end

    if not list then return end 
    self.dic_role_info = {}
    self.show_list = {}
    for k,v in pairs(list) do
        if v.desc == nil then
            local msg = WordCensor:getInstance():relapceFaceIconTag(v.msg or "")[2]
            if v.bbs_type == 2 then --回复
                v.desc = string_format(TI18N("回复<div fontcolor=#e25a00>%s</div>：%s"), v.reply_name, msg) 
            else
                v.desc = msg
            end
        end
        table_insert(self.show_list, v)
    end
    table_sort(self.show_list, function(a, b) return a.bbs_id > b.bbs_id end)

    for i,v in ipairs(self.show_list) do
        local key = model:getKeyBySrvidAndRid(v.srv_id, v.rid)
        if self.dic_role_info[key] == nil then
            self.dic_role_info[key] = v
        end
    end
end

function RolePersonalSpaceTabMessageBoardPanel:addGrowthWayData()
    if self.loading_label then
        self.loading_label:stopAllActions()
    end
    self.cur_container_x, self.cur_container_y = self.scroll_view_container:getPosition()
    
    self:showLoadingUI(false)
    self:initShowList()
    self:reloadData(true, 50)
    self.isLoadingData = false
end

--列表
function RolePersonalSpaceTabMessageBoardPanel:updateMessageBoardlist()
    self:initShowList()
    self:reloadData()   
end

--创建cell  
--@width 是setting.item_width
--@height 是setting.item_height
function RolePersonalSpaceTabMessageBoardPanel:createNewCell()
    local cell = RoleMessageBoardItem.new(self.item_width, self.item_height, self.parent, self.test_content)
    return cell
end

--获取数据数量
function RolePersonalSpaceTabMessageBoardPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RolePersonalSpaceTabMessageBoardPanel:updateCellByIndex(cell, index, text_height)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setZOrder(index)
    cell:setData(data, text_height, self.dic_role_info)


end

--点击cell .需要在 createNewCell 设置点击事件
function RolePersonalSpaceTabMessageBoardPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
end

--设置下拉框的名字
function RolePersonalSpaceTabMessageBoardPanel:setComboboxName(index)
    if not self.combox_list then return end
    if not index then return end
    if self.combox_list[index] then
        self.combobox_btn_label:setString(self.combox_list[index].desc)
    end
end

--更新下拉框
function RolePersonalSpaceTabMessageBoardPanel:showComboboxList(status)
    if not self.combobox_panel then return end
    if not self.combox_list then return end

    if status then
        self.is_show_combobox_panel = true
        self.combobox_panel:setVisible(true)
        if self.combox_item_list ==nil then
            self.combox_item_list = {}
            local count = #self.combox_list
            local item_height = 42

            local total_height = count * item_height + 30
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
            
            local x = self.combobox_bg_size.width * 0.5
            local start_y = 180
            for i,v in ipairs(self.combox_list) do
                local index = i
                local item = self:createNewComboxItem(item_height, function()
                    for i,v in ipairs(self.combox_list) do
                        if v.combox_type == index then
                            if self.combox_item_list[i] then
                                self.combox_item_list[i].select_bg:setVisible(true)
                                self.combox_item_list[i].mark_img:setVisible(true)
                            end
                        else
                            if self.combox_item_list[i] then
                                self.combox_item_list[i].select_bg:setVisible(false)
                                self.combox_item_list[i].mark_img:setVisible(false)
                            end
                        end
                    end
                    if index ~= self.select_combox_type then
                        --需要发协议
                        controller:send25839(index)
                        self:showComboboxList(false)
                    end
                end)
                item.label:setString(v.desc)
                item.layout:setPosition(x, start_y - item_height * 0.5 - (i-1) * item_height )
                self.combobox_panel:addChild(item.layout)
                self.combox_item_list[i] = item
            end
        end
        for i,v in ipairs(self.combox_list) do
            if v.combox_type == self.select_combox_type then
                if self.combox_item_list[i] then
                    self.combox_item_list[i].select_bg:setVisible(true)
                    self.combox_item_list[i].mark_img:setVisible(true)
                end
            else
                if self.combox_item_list[i] then
                    self.combox_item_list[i].select_bg:setVisible(false)
                    self.combox_item_list[i].mark_img:setVisible(false)
                end
            end
        end
    else
        self.is_show_combobox_panel = false
        self.combobox_panel:setVisible(false)
    end
end

function RolePersonalSpaceTabMessageBoardPanel:createNewComboxItem(height, callback)
    local width = 280 
    local height = height or 42
    local cell = {}
    cell.layout = ccui.Layout:create()
    cell.layout:setCascadeOpacityEnabled(true)
    cell.layout:setAnchorPoint(0.5,0.5)
    cell.layout:setTouchEnabled(true)
    cell.layout:setContentSize(cc.size(width, height))

    local size = cc.size(width, height - 2)

    local res = PathTool.getResFrame("common","common_90058_1")
    cell.select_bg = createImage(cell.layout, res, 0, 2, cc.p(0, 0), true, 0, true)
    cell.select_bg:setContentSize(size)
    -- cell.select_bg:setOpacity(90)
    cell.select_bg:setCapInsets(cc.rect(8, 10, 2, 1))
    cell.select_bg:setVisible(false)

    cell.label = createLabel(20, cc.c4b(0xff,0xf9,0xda,0xff), nil, 10, height * 0.5 , "", cell.layout, nil, cc.p(0,0.5))
    local mark_res = PathTool.getResFrame("common", "common_1043")
    cell.mark_img = createSprite(mark_res, width - 10, height * 0.5 + 2, cell.layout, cc.p(1,0.5), LOADTEXT_TYPE_PLIST)
    cell.mark_img:setScale(0.8)

    cell.layout:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
        --     cell.select_bg:setVisible(true)
        --     cell.touch_began = sender:getTouchBeganPosition()
        -- elseif event_type == ccui.TouchEventType.moved then
        --     cell.select_bg:setVisible(false)
        elseif event_type == ccui.TouchEventType.ended then
            -- local touch_began = cell.touch_began
            -- local touch_end = sender:getTouchEndPosition()
            -- if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 10 or math.abs(touch_end.y - touch_began.y) > 10) then 
            --     --点击无效了
            --     return
            -- end 

            playButtonSound2()
            -- 点击-->
            if callback then
                callback()
            end
        end
    end)
    return cell
end



--移除
function RolePersonalSpaceTabMessageBoardPanel:DeleteMe()
    if self.message_board_get_info_event then
        GlobalEvent:getInstance():UnBind(self.message_board_get_info_event)
        self.message_board_get_info_event = nil
    end
    if self.message_board_new_info_event then
        GlobalEvent:getInstance():UnBind(self.message_board_new_info_event)
        self.message_board_new_info_event = nil
    end

    if self.message_board_limit_event then
        GlobalEvent:getInstance():UnBind(self.message_board_limit_event)
        self.message_board_limit_event = nil
    end
    if self.message_board_delete_info_event then
        GlobalEvent:getInstance():UnBind(self.message_board_delete_info_event)
        self.message_board_delete_info_event = nil
    end

    if self.other_growth_way_event then
        GlobalEvent:getInstance():UnBind(self.other_growth_way_event)
        self.other_growth_way_event = nil
    end

    if self.add_face_evt then
        GlobalEvent:getInstance():UnBind(self.add_face_evt)
        self.add_face_evt = nil
    end

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end

    if self.parent.role_type == RoleConst.role_type.eOther then
        --如果是他人的.消除记录
        if self.parent.other_data then
            model:removeMessageBoardData(self.parent.other_data.srv_id, self.parent.other_data.rid)
        end
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.BBS_message)
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.BBS_message_reply_self)
        if self.role_vo then
            RoleController:getInstance():send25840(self.role_vo.rid, self.role_vo.srv_id, 0)
        end
    end


    self:showLoadingUI(false)
end


-- 子项
RoleMessageBoardItem = class("RoleMessageBoardItem", function()
    return ccui.Widget:create()
end)

function RoleMessageBoardItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function RoleMessageBoardItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("roleinfo/role_message_board_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.box_bg_03 = self.main_container:getChildByName("box_bg_03")
    self.box_bg_03_size = self.box_bg_03:getContentSize()
    self.box_bg_04 = self.main_container:getChildByName("box_bg_04")
    self.box_bg_04_size = self.box_bg_04:getContentSize()

    self.time = self.main_container:getChildByName("time")
    self.name = self.main_container:getChildByName("name")

    self.chat_btn = self.main_container:getChildByName("chat_btn")
    self.remove_btn = self.main_container:getChildByName("remove_btn")

    if self.parent.role_type == RoleConst.role_type.eOther then
        self.remove_btn:setVisible(false)
    end

    self.desc = createRichLabel(22, cc.c4b(0x78,0x50,0x46,0xff), cc.p(0,1), cc.p(36, 50), 6, nil, 510)
    self.main_container:addChild(self.desc)

    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setPosition(cc.p(16, 77))
    self.head:setScale(0.7)
    self.main_container:addChild(self.head)

    self.head:addCallBack(function() self:onHeadBtn() end)
end

function RoleMessageBoardItem:register_event( )
    registerButtonEventListener(self.chat_btn, function() self:onChatBtn()  end ,true, 1)
    registerButtonEventListener(self.remove_btn, function() self:onRemoveBtn()  end ,true, 1)
end

--聊天
function RoleMessageBoardItem:onChatBtn()
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not self.data then return end
    local setting = {}
    setting.name = self.data.name
    if self.parent.role_type == RoleConst.role_type.eMySelf then
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo then
            setting.rid = role_vo.rid
            setting.srv_id = role_vo.srv_id 
        end
    else
        if self.parent.other_data then
            setting.rid = self.parent.other_data.rid
            setting.srv_id = self.parent.other_data.srv_id
        end
    end
    setting.bbs_id = self.data.bbs_id
    controller:openRoleMessageBoardReplyPanel(true, setting)
end

--删除聊天
function RoleMessageBoardItem:onRemoveBtn()
    if not self.data then return end
    local call_back = function()
        controller:send25838(self.data.bbs_id)    
    end
    CommonAlert.show(TI18N("确定要删除这条留言吗？"), TI18N("确定"), call_back, TI18N("取消"))
end

function RoleMessageBoardItem:onHeadBtn()
    if not self.data then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    if self.data.rid == role_vo.rid and self.data.srv_id == role_vo.srv_id then
        message(TI18N("连自己都不认识了吗"))
    else
        FriendController:getInstance():openFriendCheckPanel(true, self.data)    
    end
end

--text_height 文本新增加的高度
function RoleMessageBoardItem:setData(data, text_height, dic_role_info)
    if not data then return end
    self.data = data
    
    local name_str
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo and role_vo.srv_id == data.srv_id then
        name_str = data.name
    else
        local server_name = getServerName(data.srv_id) or ""
        name_str = string_format("[%s]%s",server_name, data.name)
    end
    
    self.name:setString(name_str)

    self.desc:setString(data.desc)
    self.time:setString(TimeTool.getMessageBoardTime(data.time))
    self.box_bg_03:setContentSize(cc.size(self.box_bg_03_size.width, self.box_bg_03_size.height + text_height - 2))
    self.box_bg_04:setContentSize(cc.size(self.box_bg_04_size.width, self.box_bg_04_size.height + text_height - 2))

    if role_vo and role_vo.srv_id == data.srv_id and role_vo.rid == data.rid then
        --是自己
        --头像
        self.head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        --头像框
        local vo = Config.AvatarData.data_avatar[role_vo.avatar_base_id]
        if vo then
            local res_id = vo.res_id or 1 
            local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
            self.head:showBg(res,nil,false,vo.offy)
        end
        --等级
        self.head:setLev(role_vo.lev)
        --性别
        self.head:setSex(role_vo.sex,cc.p(70,4))
    else
        local key = model:getKeyBySrvidAndRid(data.srv_id, data.rid)
        local head_data = dic_role_info[key]
        if head_data == nil then
            head_data = data
        end
        --头像
        self.head:setHeadRes(head_data.face_id, false, LOADTEXT_TYPE, head_data.face_file, head_data.face_update_time)
        --头像框
        local vo = Config.AvatarData.data_avatar[head_data.avatar_id]
        if vo then
            local res_id = vo.res_id or 1 
            local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
            self.head:showBg(res,nil,false,vo.offy)
        end
        --等级
        self.head:setLev(head_data.lev)
        --性别
        self.head:setSex(head_data.sex,cc.p(70,4))
    end
    
end

function RoleMessageBoardItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.honor_item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

