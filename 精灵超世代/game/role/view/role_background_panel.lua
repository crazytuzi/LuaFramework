-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      空间背景面板
-- <br/>Create: 2019年7月12日
-- --------------------------------------------------------------------
RoleBackgroundPanel = class("RoleBackgroundPanel", function()
    return ccui.Widget:create()
end)

local controller = RoleController:getInstance()

function RoleBackgroundPanel:ctor(setting)
    if setting then
        --配置的是物品id
        self.show_item_id = setting.id
    end
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function RoleBackgroundPanel:config()
    self.size = cc.size(624,660)
    self:setContentSize(self.size)
    self.item_list = {}
    self.items = {}
    self.role_vo = controller:getRoleVo()
end
function RoleBackgroundPanel:layoutUI()
    self.main_panel = ccui.Widget:create()
    self.main_panel:setContentSize(self.size)
    self.main_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.main_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self:addChild(self.main_panel)

    local bg = createImage(self.main_panel, PathTool.getResFrame("common","common_90024"), 0,0, cc.p(0,0), true, -1)
    bg:setScale9Enabled(true)
    bg:setContentSize(self.size)

    local res = PathTool.getResFrame("common","common_1017")
    self.use_btn = createButton(self.main_panel, TI18N("更 换"), self.size.width/2, -36, cc.size(161,62), res, 26, Config.ColorData.data_color4[1])
    self.use_btn:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)



    controller:sender10328()
end

--事件
function RoleBackgroundPanel:registerEvents()
    if self.use_btn then 
        self.use_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:onUseBtn()
            end
        end)
    end
    --更新解锁列表/更新使用头像
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key,value)
                if not self.show_list then return end
                if not self.list_view then return end
                if key == "backdrop_id" then 
                    for i,v in ipairs(self.show_list) do
                        v.use = 3
                    end
                    for i,v in ipairs(self.show_list) do
                        if v.backdrop_id == value then
                            v.use = 1
                        end
                    end
                    local sort_func = SortTools.tableLowerSorter({"use", "backdrop_id"})
                    table.sort(self.show_list, sort_func)
                    self.list_view:reloadData(1)
                end
            end)
        end
    end

        --更换
    if not self.background_list_event then
        self.background_list_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_BACKGROUND_LIST_EVENT,function ( data )
            if not data then return end
            self:updateList(data.backdrop_list)
        end)
    end
end

--使用
function RoleBackgroundPanel:onUseBtn()
    if not self.role_vo then return end
    if self.select_backdrop_id and self.select_backdrop_id ~= self.role_vo.backdrop_id then
        controller:sender10329(self.select_backdrop_id)
    else
        message(TI18N("已在使用中"))
    end 
end

--创建头像列表 backdrop_list --@10328 协议 
function RoleBackgroundPanel:updateList(backdrop_list)
    if not backdrop_list then return end
    if not self.role_vo then return end
    if self.list_view == nil then
        local scroll_view_size = cc.size(self.size.width - 12,self.size.height - 10)
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = scroll_view_size.width,
            item_height = 190,
            row = 0,
            col = 1,
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.main_panel, cc.p(6, 5), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    self.show_list = {}
    --把默认的填进来(后端传过来了)
    -- table_insert(backdrop_list, {backdrop_id = 0})
    local table_insert = table.insert
    for i,v in ipairs(backdrop_list) do
        local config = Config.ItemData.data_get_data(v.backdrop_id)
        if v.backdrop_id == 0 or config then
            v.config = config
            if self.show_item_id and self.show_item_id == v.backdrop_id then
                v.use = 2
            elseif v.backdrop_id == self.role_vo.backdrop_id then
                v.use = 1
            else
                v.use = 3
            end
            table_insert(self.show_list, v)
        end
    end


    --小到大排序
    local sort_func = SortTools.tableLowerSorter({"use", "backdrop_id"})
    table.sort(self.show_list, sort_func)

    self.list_view:reloadData(1)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RoleBackgroundPanel:createNewCell(width, height)
    local cell = RoleBackgroundItem.new(width, height)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function RoleBackgroundPanel:numberOfCells()
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RoleBackgroundPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    cell:setData(cell_data)
    if self.select_backdrop_id then
        if self.select_backdrop_id == cell_data.backdrop_id then
            cell:setSelected(true)
        else
            cell:setSelected(false)
        end
    else
        if cell_data.use == 1 then
            cell:setSelected(true)
        else
            cell:setSelected(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RoleBackgroundPanel:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]

    if self.select_item ~= nil then
        self.select_item:setSelected(false)
    end
    self.select_backdrop_id = cell_data.backdrop_id
    self.select_item = cell
    self.select_item:setSelected(true)
end

function RoleBackgroundPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RoleBackgroundPanel:DeleteMe()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    self.select_item = nil

    if self.set_background_event then
        GlobalEvent:getInstance():UnBind(self.set_background_event)
        self.set_background_event = nil
    end
    if self.background_list_event then
        GlobalEvent:getInstance():UnBind(self.background_list_event)
        self.background_list_event = nil
    end

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
RoleBackgroundItem = class("RoleBackgroundItem", function()
    return ccui.Widget:create()
end)

function RoleBackgroundItem:ctor(width, height)
    self.width = width or 600 
    self.height = height or 180
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:configUI()
end

function RoleBackgroundItem:addCallBack( value )
    self.call_fun =  value
end

--[[
@功能:创建视图
@参数:
@返回值:
]]
function RoleBackgroundItem:configUI()
    --底内框 
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    self.back:setTouchEnabled(true)
    self.back:setSwallowTouches(false)
    self:addChild(self.back)

    self.back:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.call_fun then
                self.call_fun()
            end
        end
    end)
    
    self.icon = createSprite(nil, self.width * 0.5, self.height * 0.5, self, cc.p(0.5, 0.5), ResourcesType.single)
    self.icon:setScale(0.95)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function RoleBackgroundItem:setData(data)
    if data == nil then return end
    self.data = data
    self:showUseIcon(data.use == 1)
    local res_id 
    if self.data.config then
        res_id = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace_head", self.data.config.icon)
    else
        --默认图片
        res_id = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace_head", "100000")
    end
    if self.record_res_id == nil or self.record_res_id ~= res_id then
        self.record_res_id = res_id
        self.item_load = loadSpriteTextureFromCDN(self.icon, res_id, ResourcesType.single, self.item_load, 60)
    end
end

function RoleBackgroundItem:setSelected(bool)
    if bool then
         --选择框
        if self.select == nil then
            self.select = createImage(self, PathTool.getResFrame("common", "common_90019"), self.width * 0.5, self.height * 0.5, cc.p(0.5, 0.5), true, nil, true)
            self.select:setContentSize(cc.size(598, 187))
        end
        self.select:setVisible(bool)
        local fadein = cc.FadeIn:create(0.7)
        local fadeout = cc.FadeOut:create(0.7)
        self.select:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein,fadeout)))
    else
        if self.select then
           doStopAllActions(self.select)
           self.select:setVisible(bool)
        end
    end
end

--使用中
function RoleBackgroundItem:showUseIcon(bool)
    if not self.use_icon and  not bool then return end 
    if not self.use_icon then 
        local res = PathTool.getTargetRes("face/txt_face","txt_face_use",false)
        self.use_icon = createImage(self, res, 557, 23, cc.p(0.5,0.5), false, 1, false)
    end
    self.use_icon:setVisible(bool)
end

function RoleBackgroundItem:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
