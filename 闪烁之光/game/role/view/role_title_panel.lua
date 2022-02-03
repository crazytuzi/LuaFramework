-- --------------------------------------------------------------------
-- 称号面板
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RoleTitlePanel = class("RoleTitlePanel", function()
    return ccui.Widget:create()
end)

local backpack_model = BackpackController:getInstance():getModel() 
local table_insert = table.insert

function RoleTitlePanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
    self.cur_touch_index = nil
    self.have_list = {}
end

function RoleTitlePanel:config()
    self.ctrl = RoleController:getInstance()
    self.size = cc.size(624,660)
    self:setContentSize(self.size)
    self.role_vo = self.ctrl:getRoleVo()
    self.use_id = 0
    self.title_list = {}                -- 全部称号列表
    self:initItemConfigList()
end

function RoleTitlePanel:layoutUI()
    self.main_panel = ccui.Widget:create()
    self.main_panel:setContentSize(self.size)
    self.main_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.main_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self:addChild(self.main_panel)

    local bg = createImage(self.main_panel, PathTool.getResFrame("common","common_1034"), 0, 0, cc.p(0,0), true)
    bg:setScale9Enabled(true)
    bg:setContentSize(self.size)

    local scroll_view_size = cc.size(self.size.width - 12,self.size.height - 10)
    local setting = {
        item_class = TitleItem,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = scroll_view_size.width,
        item_height = 127,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.main_panel, cc.p(6, 5), nil, nil, scroll_view_size, setting) 

    local res = PathTool.getResFrame("common","common_1017")
    self.use_btn = createButton(self.main_panel, TI18N("更 换"), self.size.width/2, -36, cc.size(161,62), res, 26, Config.ColorData.data_color4[1])
    self.use_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.ctrl:sender23300()
end

function RoleTitlePanel:setData(data)
    if not data then return end
    self.data = data
end

--事件
function RoleTitlePanel:registerEvents()
    if self.use_btn then 
        self.use_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if self.select_data == nil then return end
                
                local data = self.select_data
                local loss_bid = data.loss[1][1]
                local loss_num = data.loss[1][2]

                if data and data.base_id then 
                    if data.has == 0 then
                        self.ctrl:sender23303(data.base_id)--激活
                    elseif data.has == 3 then
                        if data.source and data.source ~= 0 then 
                            self:SourceClick(data.source)
                        end
                    else
                        self.ctrl:sender23301(data.base_id)--更换
                    end
                end
            end
        end)
    end

    --拥有列表
    if self.updateList == nil then
        self.updateList = GlobalEvent:getInstance():Bind(RoleEvent.GetTitleList,function ( data )
            self.use_id = data.base_id --正在使用的称号
            self:updateHaveList(data)
            self:createItemList()
        end)
    end

    if self.updateHaveList_event == nil then
        self.updateHaveList_event = GlobalEvent:getInstance():Bind(RoleEvent.UpdataTitleList,function ( data )
            self:updateHaveList(data,true)
            self:createItemList()
        end)
    end

    --使用称号
    if self.use_event == nil then
        self.use_event = GlobalEvent:getInstance():Bind(RoleEvent.UseTitle,function ( id )
            if id then
                self.use_id = id
                self:createItemList()
            end
        end)
    end
    
end

--==============================--
--desc:优先储存已经有的称号
--time:2018-10-26 05:54:41
--@data:
--@is_active:
--@return 
--==============================--
function RoleTitlePanel:updateHaveList(data,is_active)
    if data and data.honor then
        for i, v in pairs(data.honor) do
            if v and v.base_id then
                self.have_list[v.base_id] = v
            end
        end
    end
end

--==============================--
--desc:读取配置称号数据,做缓存显示
--time:2018-10-26 05:54:55
--@return 
--==============================--
function RoleTitlePanel:initItemConfigList()
    self.title_list = {}
    for k, v in pairs(Config.HonorData.data_title) do
        if v.is_show == 1 then
            table_insert(self.title_list, v)
        end
    end
end

--==============================--
--desc:创建称号列表
--time:2018-10-26 05:55:17
--@return 
--==============================--
function RoleTitlePanel:createItemList()
    if self.title_list == nil or next(self.title_list) == nil then return end
    local had_auto_click = false
    for i,v in ipairs(self.title_list) do
        v.has = 3                                       --默认都是未激活
        v.auto_click = false                            --默认都不选中
        if self.have_list[v.base_id] == nil then
            local loss_bid = v.loss[1][1]
            local loss_num = v.loss[1][2]
            local has_num = backpack_model:getBackPackItemNumByBid(loss_bid)
            if has_num >= loss_num then 
                v.has = 0                               --可激活的
                if had_auto_click == false then
                    v.auto_click = true
                    had_auto_click = true
                end
            end
        else
            local have_item = self.have_list[v.base_id]
            if have_item then
                v.expire_time = have_item.expire_time 
                v.has = 2                           -- 已拥有
            end
            if v.base_id == self.use_id then
                v.has = 1                               -- 当前正在使用
                if had_auto_click == false then
                    v.auto_click = true
                    had_auto_click = true
                end
            end
        end
    end

    local list = {}
    for i,v in pairs(self.title_list) do
        if v.is_show_title == 1 then
            if v.has ~= 3 then
                table_insert(list,v)
            end
        else
            table_insert(list,v)
        end
    end
    local sort_func = SortTools.tableLowerSorter({"has","base_id"})
    table.sort(list, sort_func)
    if had_auto_click == false then
        local first_data = list[1]
        if first_data then
            first_data.auto_click = true 
        end
    end
    local function click_callback(face_item,vo)
        self:titleItemClick(face_item, vo)
    end

    self.scroll_view:setData(list, click_callback) 
end

--==============================--
--desc:选中指定称号
--time:2018-10-26 04:25:48
--@face_item:
--@vo:
--@return 
--==============================--
function RoleTitlePanel:titleItemClick(face_item,vo)
    if self.select_item then
        self.select_item:setSelected(false)
    end
    if self.select_data then
        self.select_data.auto_click = false
    end

    self.select_item = face_item
    self.select_item:setSelected(true)
    self.select_data = self.select_item:getData()
    if self.select_data == nil then return end

    if self.cur_touch_index == self.select_data.base_id then return end
    self.cur_touch_index = self.select_data.base_id

    local is_has = self.select_data.has 
    local loss_bid = self.select_data.loss[1][1]
    local loss_num = self.select_data.loss[1][2]
    if is_has == 3 then
        self.use_btn:setBtnLabel(TI18N("前往获取")) 
    elseif is_has == 0 then
        self.use_btn:setBtnLabel(TI18N("激 活")) 
    else
        self.use_btn:setBtnLabel(TI18N("更 换"))
        -- if self.have_list[vo.base_id] then
            -- self.select_data.expire_time = self.have_list[self.select_data.base_id].expire_time
        -- end
    end
end

--是否是同组的
function RoleTitlePanel:isSameGroup(bid1,bid2)
    local config_1 = Config.HonorData.data_title[bid1]
    if not config_1 then return false end
    local config_2 = Config.HonorData.data_title[bid2]
    if not config_2 then return false end

    if config_1.group and config_1.group == config_2.group then 
        return true
    end
    return false
end

function RoleTitlePanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool == true then 
    end
end

----跳转
function RoleTitlePanel:SourceClick( id )
    local data = Config.SourceData.data_source_data[id]
    if data.evt_type and data.extend then
        BackpackController:getInstance():gotoItemSources(data.evt_type, data.extend)
    end
end

function RoleTitlePanel:DeleteMe()
    if self.updateList ~= nil then
        GlobalEvent:getInstance():UnBind(self.updateList)
        self.updateList = nil
    end
    if self.updateHaveList_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.updateHaveList_event)
        self.updateHaveList_event = nil
    end
    if self.use_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.use_event)
        self.use_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil
end





-- --------------------------------------------------------------------
-- 称号子项
-- 
-- --------------------------------------------------------------------
TitleItem = class("TitleItem", function()
	return ccui.Widget:create()
end)

function TitleItem:ctor()
	self.width = 605
	self.height = 127
    self.is_lock = false
    self.is_use =false
    self.is_can_active = false
	self.ctrl = RoleController:getInstance()
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
   	self:setAnchorPoint(cc.p(0.5, 0.5))
    self:configUI()
end

function TitleItem:addCallBack(call_back)
    self.call_fun = call_back
end

function TitleItem:clickHandler( ... )
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function TitleItem:setTouchFunc( value )
	self.call_fun =  value
end

function TitleItem:getTouchPos(  )
    return self.touchPos or nil
end

--[[
@功能:创建视图
@参数:
@返回值:
]]
function TitleItem:configUI( ... )
	--底内框 
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    self.back:setTouchEnabled(true)
    self:addChild(self.back)

    local res = PathTool.getResFrame("common","common_1029")
    self.background = createScale9Sprite(res, self.width/2,self.height/2, LOADTEXT_TYPE_PLIST, self.back)
    self.background:setContentSize(cc.size(self.width, self.height))
    self.back:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touchPos = sender:getTouchBeganPosition()
			self:clickHandler()
        end
    end)
   
    self.face_icon = createImage(self, nil, 110, 75, cc.p(0.5,0.5), false, 1, false)

    self.attr_label = createRichLabel(22, 58, cc.p(0,0.5), cc.p(self.width/2-50,80),2,0,320)   
    self.attr_label:setString(TI18N("无属性加成"))
    self:addChild(self.attr_label)

    self.get_label = createRichLabel(20, 186, cc.p(0,0.5), cc.p(self.width/2-50,35),0,0,320) 
    self.get_label:setString(TI18N("获得条件"))
    self:addChild(self.get_label)  

    self.time_label = createRichLabel(24, 175, cc.p(0.5,0.5), cc.p(105,35)) 
    self.time_label:setString(TI18N("未获得"))
    self:addChild(self.time_label)  
    local res = PathTool.getResFrame('face', 'txt_cn_face_use')
    self.use_icon = createImage(self, res, 35, 105, cc.p(0.5, 0.5), true, 1, false)
    self.use_icon:setVisible(false)
    self.active = createSprite(PathTool.getResFrame("common", "txt_cn_common_30017"), 35, 105, self)
    self.active:setLocalZOrder(99)
    self.active:setScale(0.7)
    self.active:setVisible(false)
    self:showLock(true)
end

function TitleItem:showActive(bool)
    if self.active then
        self.active:setVisible(bool)
    end
end

function TitleItem:updateAttr()
    if self.vo == nil then return end
    local data = self.vo
    local str = ""

    local attr_list = {}
    if data.attr and next(data.attr) then
        for i,v in ipairs(data.attr) do
            table_insert(attr_list, v)
        end
    end
    if data.add_exp ~= 0 then
        table_insert(attr_list, {"_add_exp", data.add_exp})    
    end

    if next(attr_list) ~= nil then
        for k,v in pairs(attr_list) do
            local attr_key = v[1]
            local attr_value = v[2]
            if attr_key == "_add_exp" then
                str = str..TI18N("挂机经验: ")..(attr_value*0.1).."%"
            else
                local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                if is_per then
                    attr_value = (attr_value*0.1) .. "%"
                end
                str = str..Config.AttrData.data_key_to_name[attr_key]..": "..attr_value
            end
            if k%2 == 0 then 
                str = str.."\n"
            else
                str = str.."       "
            end
        end
    else
        str = str..TI18N("无")
    end
    self.attr_label:setString(str)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function TitleItem:setData( data )
	if data == nil then return end
	self.vo = data
    self:updateAttr()
    if data.res_id then
        local res = PathTool.getTargetRes("honor","txt_cn_honor_"..data.res_id,false,false)
        if self.title_res_id ~= res then
            self.title_res_id = res
            self.item_load = loadImageTextureFromCDN(self.face_icon, res, ResourcesType.single, self.item_load) 
        end
    end
    self.get_label:setString(TI18N("获得条件：")..data.desc)

    if data.has == 0 then
        self:showActive(true)
        self:showLock(true) 
        self:showUseIcon(false)
    elseif data.has == 1 then
        self:showUseIcon(true)
        self:showActive(false)
        self:showLock(false) 
    elseif data.has == 2 then
        self:showUseIcon(false)
        self:showLock(false) 
        self:showActive(false)
    else
        self:showUseIcon(false)
        self:showActive(false)
        self:showLock(true)
    end

    -- 默认选中处理
    if data.auto_click == true then
        self:clickHandler()
    else
        self:setSelected(false)
    end
end

function TitleItem:setSelected(bool)
    if bool then
        self.vo.auto_click = true
        loadScale9SpriteTexture(self.background, PathTool.getResFrame("common","common_1020"), LOADTEXT_TYPE_PLIST)
    else
        loadScale9SpriteTexture(self.background, PathTool.getResFrame("common","common_1029"), LOADTEXT_TYPE_PLIST)
    end
    self.background:setContentSize(cc.size(self.width, self.height))
end

--锁定 未激活
function TitleItem:showLock(bool)
    self.is_can_active = false
    self.is_lock = bool 
    local val = ""
    if self.vo then 
        if self.is_lock then 
            val = TI18N("未激活")
        else
            if self.vo.expire_time > 0 then
                val = TimeTool.GetTimeFormatDay(self.vo.expire_time - GameNet:getInstance():getTime())
            else
                val = TI18N("永久")
            end
        end
    end
    self.time_label:setString(val)
end

--使用中
function TitleItem:showUseIcon(bool)
    self.is_use = bool 
    self.use_icon:setVisible(bool)
end

function TitleItem:reset()
	self.vo = nil
end

function TitleItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end
function TitleItem:getData( )
	return self.vo
end
function TitleItem:getIsLock()
    return self.is_lock
end
function TitleItem:getIsActive()
    return self.is_can_active
end
function TitleItem:getIsUse()
    return self.is_use
end

function TitleItem:suspendAllActions()
    self.vo = nil
end

function TitleItem:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
	self.vo =nil
end
