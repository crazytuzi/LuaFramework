-- --------------------------------------------------------------------
-- 头像
--
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleHeadPanel =
    class(
    "RoleHeadPanel",
    function()
        return ccui.Widget:create()
    end
)

function RoleHeadPanel:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RoleHeadPanel:config()
    self.ctrl = RoleController:getInstance()
    self.size = cc.size(627, 627)
    self:setContentSize(self.size)
    self.item_list = {}
    self.items = {}
    self.role_vo = self.ctrl:getRoleVo()
    self.is_select_custom = false
end
function RoleHeadPanel:layoutUI()
    self.main_panel = ccui.Widget:create()
    self.main_panel:setContentSize(self.size)
    self.main_panel:setAnchorPoint(cc.p(0.5, 0.5))
    self.main_panel:setPosition(cc.p(self.size.width / 2, 325))
    self:addChild(self.main_panel)

    --local bg = createImage(self.main_panel, PathTool.getResFrame("common","common_90024"), self.size.width/2,self.size.height/2+20, cc.p(0.5,0.5), true, -1)
    --bg:setScale9Enabled(true)
    --bg:setContentSize(self.size)

    -- 自定义头像打开设置的入口
    self.photo_btn =
        createImage(
        self.main_panel,
        PathTool.getResFrame("rolepersonalspace", "role_personal_space_23"),
        self.size.width / 2,
        580,
        cc.p(0.5, 0.5),
        true
    )
    self.photo_btn:setTouchEnabled(true)
    self.photo_label =
        createLabel(
        20,
        Config.ColorData.data_new_color4[6],
        nil,
        self.photo_btn:getContentSize().width / 2,
        0,
        "",
        self.photo_btn,
        nil,
        cc.p(0.5, 1)
    )
    self.photo_label:setString(TI18N("自定义头像"))

    -- 自定义头像的展示，
    self.custom_head = FaceHeadItem.new()
    self.custom_head:setPosition(cc.p(430, 582))
    self.main_panel:addChild(self.custom_head)
    local head_label =
        createLabel(20, Config.ColorData.data_new_color4[6], nil, 64, 0, "", self.custom_head, nil, cc.p(0.5, 1))
    head_label:setString(TI18N("自定义头像"))

    -- 显示状态
    if self.role_vo and self.role_vo.face_file and self.role_vo.face_file == "" then
        self.custom_head:setVisible(false)
    else
        if CAN_USE_CAMERA then
            self.photo_btn:setPositionX(217)
            self.photo_label:setString(TI18N("重新选择"))
            self.custom_head:setPositionX(376)
            self.custom_head:updateCustomHead(
                self.role_vo.face_id,
                self.role_vo.face_file,
                self.role_vo.face_update_time
            )
        else
            self.custom_head:setVisible(false)
        end
    end

    local line =
        createImage(
        self.main_panel,
        PathTool.getResFrame("common", "common_1016"),
        self.size.width / 2,
        485,
        cc.p(0.5, 0.5),
        true
    )
    line:setScale9Enabled(true)
    line:setContentSize(cc.size(590, 3))

    local tips_label = createRichLabel(16, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.size.width/2, -75), 2, nil, 540)
    tips_label:setString(TI18N("除了可选择精美的宝可梦头像，也可设置自定义个性头像哦！"))
    self.main_panel:addChild(tips_label)

    local res = PathTool.getResFrame("common", "common_1017")
    self.use_btn =
        createButton(
        self.main_panel,
        TI18N("更 换"),
        self.size.width / 2,
        -20,
        cc.size(161, 62),
        res,
        26,
        Config.ColorData.data_color4[1]
    )
    self.use_btn:enableShadow(Config.ColorData.data_new_color4[3], cc.size(0, -2), 2)
    self.use_btn:setAnchorPoint(cc.p(0.5, 0.5))
    self.ctrl:requestRoleHeadList()

    -- 设置初始状态
    self:setUserHead()
end

function RoleHeadPanel:setUserHeadStatus(is_had)
    if not CAN_USE_CAMERA then
        return
    end
    if self.check_is_had == is_had then
        return
    end
    self.check_is_had = is_had
    if is_had == true then
        self.photo_btn:setPositionX(217)
        self.photo_label:setString(TI18N("重新选择"))
        self.custom_head:setPositionX(376)
        self.custom_head:setVisible(true)
    else
        self.photo_btn:setPositionX(self.size.width / 2)
        self.photo_label:setString(TI18N("自定义头像"))
        self.custom_head:setVisible(false)
    end
end

--设置自定义头像的使用
function RoleHeadPanel:setUserHead()
    if self.role_vo == nil then
        return
    end
    if self.role_vo.face_file ~= "" then
        self:setUserHeadStatus(true)
        -- 设置显示
        self.custom_head:updateCustomHead(self.role_vo.face_id, self.role_vo.face_file, self.role_vo.face_update_time)
        if self.role_vo.face_update_time ~= 0 then -- 这个时候表示在使用自定义头像
            self.custom_head:showUseIcon(true)
            self:setCustomHeadSelected(true)
        else
            self.custom_head:showUseIcon(false)
            self:setCustomHeadSelected(false)
        end
    else
        self:setUserHeadStatus(false)
    end
end

function RoleHeadPanel:setData()
end

--事件
function RoleHeadPanel:registerEvents()
    registerButtonEventListener(
        self.photo_btn,
        function()
            if self.role_vo and self.role_vo.lev >= 50 then
                MainuiController:getInstance():openCustomHeadImgWin(true)
            else
                message(TI18N("50级开启自定义头像！"))
            end
        end,
        true
    )

    if self.use_btn then
        self.use_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    if self.is_select_custom == true then -- 使用自定义
                        RoleController:getInstance():resetCustomHeadImage()
                    else
                        if self.select_item then
                            local data = self.select_item.vo
                            if data and data.bid then
                                self.ctrl:changeRoleHead(data.bid)
                            end
                        end
                    end
                end
            end
        )
    end
    --更新解锁列表/更新使用头像
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event =
                self.role_vo:Bind(
                RoleEvent.UPDATE_ROLE_ATTRIBUTE,
                function(key, value)
                    if key == "face_id" then
                        self:updateList()
                    elseif key == "face_list" then
                        self:updateList(value)
                    elseif key == "face_update_time" then
                        self:setUserHead()
                        if value ~= 0 then
                            self:updateList()
                        end
                    end
                end
            )
        end
    end

    -- 点击自定义头像的时候，要取消掉系统头衔选择的
    if self.custom_head then
        self.custom_head:addCallBack(
            function(sender, event_type)
                self:setCustomHeadSelected(true)
            end
        )
    end
end

function RoleHeadPanel:setCustomHeadSelected(status)
    if self.is_select_custom == status then
        return
    end
    self.is_select_custom = status
    if status == true then
        if self.select_item then
            self.select_item:setSelected(false)
            self.select_item = nil
            self.select_bid = nil
        end
        self.custom_head:setSelected(true)
    else
        if self.select_item then
            self.select_item:setSelected(true)
        end
        self.custom_head:setSelected(false)
    end
end

--创建头像列表
function RoleHeadPanel:updateList(has_list)
    if self.list_view == nil then
        local scroll_view_size = cc.size(self.size.width - 12, self.size.height - 180)
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = scroll_view_size.width / 4,
            item_height = 120,
            row = 0,
            col = 4,
            need_dynamic = true
        }
        self.list_view =
            CommonScrollViewSingleLayout.new(
            self.main_panel,
            cc.p(6, 26),
            ScrollViewDir.vertical,
            ScrollViewStartPos.top,
            scroll_view_size,
            list_setting,
            cc.p(0, 0)
        )

        self.list_view:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(
            handler(self, self.updateCellByIndex),
            ScrollViewFuncType.UpdateCellByIndex
        ) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    if has_list ~= nil then
        self.dic_has_bid = {}
        for i, v in pairs(has_list) do
            self.dic_has_bid[v.face_id] = true
        end
    end
    local table_insert = table.insert
    local x = 1
    -- 是否使用了自定义头像
    local is_use_custom =
        self.role_vo.face_file and self.role_vo.face_file ~= "" and self.role_vo.face_update_time and
        self.role_vo.face_update_time ~= 0
    if self.show_list == nil then
        self.show_list = {}
        local head_config = Config.LooksData.data_head_data or {}
        for i, v in pairs(head_config) do
            local data = {}
            data.tips = v.tips
            data.bid = v.id
            if self.dic_has_bid then
                if self.dic_has_bid[v.id] then
                    data.status = 0 --拥有
                else
                    data.status = 1 --未拥有
                end
            else
                data.status = 1 --未拥有
            end
            -- 这里需要判断自定义头像是否在使用中
            if self.role_vo.face_id == v.id and (not is_use_custom) then --正在使用
                data.use = 0
            else
                data.use = 1
            end
            table_insert(self.show_list, data)
        end
    else
        for i, data in ipairs(self.show_list) do
            if self.dic_has_bid then
                if self.dic_has_bid[data.bid] then
                    data.status = 0 --拥有
                else
                    data.status = 1 --未拥有
                end
            else
                data.status = 1 --未拥有
            end
            -- 这里需要判断自定义头像是否在使用中
            if self.role_vo.face_id == data.bid and (not is_use_custom) then --正在使用
                data.use = 0 --使用..因为排序问题
            else
                data.use = 1
            end
        end
    end

    --小到大排序
    local sort_func = SortTools.tableLowerSorter({"use", "status", "bid"})
    table.sort(self.show_list, sort_func)

    if not is_use_custom then
        self.list_view:reloadData(1)
    else
        self.list_view:reloadData()
    end
end

--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function RoleHeadPanel:createNewCell(width, height)
    local cell = FaceHeadItem.new()
    cell:addCallBack(
        function()
            self:onCellTouched(cell)
        end
    )
    return cell
end

--获取数据数量
function RoleHeadPanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RoleHeadPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    cell:setData(cell_data)
    if self.select_bid then
        if (not self.is_select_custom) and self.select_bid == cell_data.bid then
            cell:setSelected(true)
        else
            cell:setSelected(false)
        end
    else
        -- 没有选中自定义头像的时候
        if (not self.is_select_custom) and cell_data.use == 0 then
            cell:setSelected(true)
        else
            cell:setSelected(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RoleHeadPanel:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    if self.select_bid and self.select_bid == cell_data.bid then
        return
    end
    -- 自定义的取消选中
    if self.custom_head then
        self.custom_head:setSelected(false)
        self.is_select_custom = false
    end

    if cell_data.status == 1 then
        message(cell_data.tips)
    elseif cell_data.status == 0 then
        if self.select_item ~= nil then
            self.select_item:setSelected(false)
        end
        self.select_bid = cell_data.bid
        self.select_item = cell
        self.select_item:setSelected(true)
    end
end

function RoleHeadPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RoleHeadPanel:DeleteMe()
    if self.custom_head then
        self.custom_head:DeleteMe()
        self.custom_head = nil
    end
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    self.select_item = nil
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
end

-- --------------------------------------------------------------------
-- 头像子项
--
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
FaceHeadItem =
    class(
    "FaceHeadItem",
    function()
        return ccui.Widget:create()
    end
)

function FaceHeadItem:ctor()
    self.width = 128
    self.height = 120
    self.is_select = false
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width, self.height))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:configUI()
end

function FaceHeadItem:clickHandler(sender, event_type)
    if self.call_fun then
        self.touchPos = sender:getTouchBeganPosition()
        self:call_fun(sender, event_type)
    end
end
function FaceHeadItem:addCallBack(value)
    self.call_fun = value
end

--[[
@功能:创建视图
@参数:
@返回值:
]]
function FaceHeadItem:configUI()
    --底内框
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    self.back:setTouchEnabled(true)
    self.back:setSwallowTouches(false)
    self:addChild(self.back)

    self.back:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:clickHandler(sender, event_type)
            end
        end
    )

    self.player_head = PlayerHead.new(PlayerHead.type.circle)
    self.player_head:setAnchorPoint(cc.p(0.5, 0.5))
    self.player_head:setPosition(cc.p(self.width / 2, 60))
    --self.player_head:setScale(0.8)
    self:addChild(self.player_head)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function FaceHeadItem:setData(data)
    if data == nil then
        return
    end
    self.vo = data
    self.player_head:setHeadRes(data.bid)
    self:setGrey(data.status == 1)
    self:showUseIcon(data.use == 0)
end

function FaceHeadItem:setSelected(bool)
    if self.is_select == bool then
        return
    end
    self.is_select = bool
    if bool then
        --选择框
        if self.select == nil then
            self.select = ccui.ImageView:create(PathTool.getResFrame("common", "common_1060"), LOADTEXT_TYPE_PLIST)
            self.select:setAnchorPoint(cc.p(0.5, 0.5))
            self.select:setPosition(cc.p(self.player_head:getPositionX(), self.player_head:getPositionY()))
            self:addChild(self.select)
        end
        self.select:setVisible(bool)
        local fadein = cc.FadeIn:create(0.7)
        local fadeout = cc.FadeOut:create(0.7)
        self.select:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
    else
        if self.select then
            doStopAllActions(self.select)
            self.select:setVisible(bool)
        end
    end
end

--使用中
function FaceHeadItem:showUseIcon(bool)
    self.is_use = bool
    if not self.use_icon and bool == false then
        return
    end
    if not self.use_icon then
        local res = PathTool.getTargetRes("face/txt_face","txt_face_use",false)
        self.use_icon = createImage(self, res, 85, 30, cc.p(0.5, 0.5), false, 1, false)
    end
    self.use_icon:setVisible(bool)
end

-- 设置自定义头像相关信息
function FaceHeadItem:updateCustomHead(base_id, face_file, face_update_time)
    if self.player_head then
        self.player_head:setHeadRes(base_id, false, LOADTEXT_TYPE, face_file, face_update_time, true)
    end
end

function FaceHeadItem:setGrey(status)
    setChildUnEnabled(status, self, cc.c4b(105, 85, 85, 255))
end

function FaceHeadItem:DeleteMe()
    if self.player_head then
        self.player_head:DeleteMe()
        self.player_head = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
    self.vo = nil
end
