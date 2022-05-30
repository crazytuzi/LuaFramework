-- --------------------------------------------------------------------
-- 竖版物品合成
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BackPackComposeWindow = BackPackComposeWindow or BaseClass(BaseView)

local table_sort = table.sort
function BackPackComposeWindow:__init(data)
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.layout_name = "backpack/backpack_compose_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("backpack","backpack"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Big    
    self.compose_list = {}
    self.view_list = {}
    self.select_btn = nil
    self.data = data
end

function BackPackComposeWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background") 
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.fast_compose_btn = self.main_panel:getChildByName("fast_compose_btn")
    self.fast_compose_btn:setTitleText(TI18N("一键合成"))
    local title = self.fast_compose_btn:getTitleRenderer()   
    title:enableOutline(cc.c4b(0xc4, 0x5a, 0x14, 0xff),2)

    self.compose_btn = self.main_panel:getChildByName("compose_btn")
    self.compose_btn:setTitleText(TI18N("合成"))
    local title = self.compose_btn:getTitleRenderer()   
    title:enableOutline(cc.c4b(0x47, 0x84, 0x25, 0xff),2)
    

    self.title = self.main_panel:getChildByName("title")
    self.title:setString(TI18N("物品合成"))

    

    self.cost_label = createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,0),cc.p(265,200),500)
    self.main_panel:addChild(self.cost_label)
    --创建5个格子
    self:createComposeList()
    self:updateItemList()
end

function BackPackComposeWindow:createComposeList()
    local size = self.main_panel:getContentSize()
    local label = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,172,"",self.main_panel,2, cc.p(0.5,0))
    label:setString(TI18N("合成费用"))
    self.goods_name = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,726,"",self.main_panel,2, cc.p(0.5,0))
    local pos_list = {[1]={x=size.width/2,y=650},[2]={x=size.width/2+200,y=480},[3]={x=size.width/2,y=310},[4]={x=size.width/2-200,y=480}}
    for i=1,4 do
        if not self.compose_list[i] then 
            local item = BackPackItem.new(false,true)
            self.main_panel:addChild(item)
            item:setPosition(cc.p(pos_list[i].x,pos_list[i].y))
            self.compose_list[i] = item
            item:addCallBack(function(cli_item)
                local vo  = cli_item:getData()
                if vo and next(vo) ~=nil then 
                    self.ctrl:openTipsSource(true,vo)
                end
            end)
        end
    end

    self.last_item = BackPackItem.new(false,true)
    self.main_panel:addChild(self.last_item)
    self.last_item:setPosition(cc.p(size.width/2,size.height/2+75))
end
function BackPackComposeWindow:register_event()

    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openBackPackComposeWindow(false)
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openBackPackComposeWindow(false)
        end
    end)

    self.fast_compose_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.select_vo then return end
            local id = self.select_vo.bid or 0
            self.ctrl:sender10523(id,0)
        end
    end)

    self.compose_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.select_vo then return end
            local id = self.select_vo.bid or 0
            self.ctrl:sender10523(id,1)
        end
    end)

    if not self.compose_goods_success then 
        self.compose_goods_success = GlobalEvent:getInstance():Bind(BackpackEvent.Compose_Goods_Success,function()
            self:clickFun(self.select_vo)
            self:checkIsCanCompose()
        end)
    end

end
function BackPackComposeWindow:updateItemList()
    if not self.list_view then
        local scroll_view_size = cc.size(610,140)
        local setting = {
            item_class = BackPackItem,      -- 单元类
            start_x = 5.5,                  -- 第一个单元的X起点
            space_x = 20,                    -- x方向的间隔
            start_y = 9,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 119,               -- 单元的尺寸width
            item_height = 119,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 0                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(32, 30) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    end
    local config =Config.ItemProductData.data_product_data
    local list = {}
    local index =1
    for i,v in pairs(config) do
        list[index] = v
        index = index +1
    end
    
    if not list or next(list) == nil then return end
    local sort_func = SortTools.KeyLowerSorter("order")
    table_sort(list, sort_func)
    local function callback(item)
        local vo = item:getData()
        if vo and next(vo)~=nil then
            if self.select_vo and self.select_vo.bid == vo.bid then return end
            if self.select_item then 
                self.select_item:setSelected(false)
            end
            self.select_vo = vo
            self.select_item = item
            if self.select_item then 
                self.select_item:setSelected(true)
            end
            self:clickFun(vo)
		end
    end
    self.list_view:setData(list, callback)
    self.list_view:addEndCallBack(function()
        self:checkIsCanCompose()
    end)
end
function BackPackComposeWindow:clickFun(data)
    if not data or not data.need_items then return false end
    local need_items = data.need_items or {}
    local need_assert = data.loss or {}
    local backpack_model = self.ctrl:getModel()
    local is_show = true
    for i=1,4 do
        self.compose_list[i]:setData()
        self.compose_list[i]:showArtifactLock(true)
    end
    for i=1,#need_items do
        local vo = need_items[i]
        if vo and vo[1] and vo[2] then
            local count = backpack_model:getBackPackItemNumByBid(vo[1])
            local item_config = Config.ItemData.data_get_data(vo[1])
            self.compose_list[i]:setData(item_config)
            self.compose_list[i]:showArtifactLock(false)
            self.compose_list[i]:setNeedNum(vo[2],count)
        end 
    end
    local role_vo = RoleController:getInstance():getRoleVo()
    if need_assert and need_assert[1] then 
        local vo = need_assert[1]
        local assert_id = vo[1] or 0
        local assert_num = vo[2] or 0
        local item_config = Config.ItemData.data_get_data(assert_id)
        local assert_str = Config.ItemData.data_assets_id2label[vo[1]]
        local color = 175
        if role_vo[assert_str] then 
            if role_vo[assert_str] < vo[2] then 
                color = 183
            end
        end
        local res = PathTool.getItemRes(item_config.icon)
        local str = string.format("<img src='%s' scale=0.4 /><div fontcolor=%s> %s</div>",res,tranformC3bTostr(color),assert_num)
        self.cost_label:setString(str)
    end

    self.last_item:setData(data)
    local name = data.name or ""
    self.goods_name:setString(name)

end
function BackPackComposeWindow:checkIsCanCompose()
    local list = self.list_view:getItemList() or {}

    for i,v in pairs(list) do
        local vo = v:getData()
        local bool = self:checkGoodsIsEnough(vo) or false
        v:showRedPoint(bool)
        if self.data and next(self.data) ~=nil then 
            if self.data.bid == vo.bid then 
                self.select_item =v
                self.select_item:setSelected(true)
                local vo = self.select_item:getData()
                self.select_vo = vo
                self:clickFun(vo)
            end
        end
        if not self.select_item and bool == true then 
            self.select_item =v
            self.select_item:setSelected(true)
            local vo = self.select_item:getData()
            self.select_vo = vo
            self:clickFun(vo)
        end
    end

    if not self.select_item then 
        local list = self.list_view:getItemList() or {}
        if list and list[1] then
            self.select_item = list[1]
            self.select_item:setSelected(true)
            local vo = self.select_item:getData()
            self.select_vo = vo
            self:clickFun(vo)
        end
    end
end
function BackPackComposeWindow:checkGoodsIsEnough(data)
    if not data or not data.need_items then return false end
    local need_items = data.need_items or {}
    local need_assert = data.loss or {}
    local backpack_model = self.ctrl:getModel()
    for i,v in pairs(need_items) do
        if v and v[1] and v[2] then
            local count = backpack_model:getBackPackItemNumByBid(v[1])
            if count < v[2] then 
                return false
            end
        end
    end
    local role_vo = RoleController:getInstance():getRoleVo()
    for i,v in pairs(need_assert) do
        if v and v[1] and v[2]  then
            local assert_str = Config.ItemData.data_assets_id2label[v[1]]
            if role_vo[assert_str] then 
                if role_vo[assert_str] < v[2] then 
                    return false
                end
            else
                return false
            end
        end
    end

    return true
end
function BackPackComposeWindow:openRootWnd()
end
--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function BackPackComposeWindow:setPanelData()
end

function BackPackComposeWindow:close_callback()
    self.ctrl:openBackPackComposeWindow(false)
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    for i,v in pairs(self.compose_list) do
        v:DeleteMe()
    end
    self.compose_list = nil

    if self.last_item then 
        self.last_item:DeleteMe()
    end
    self.last_item = nil
    if self.compose_goods_success then
        GlobalEvent:getInstance():UnBind(self.compose_goods_success)
        self.compose_goods_success = nil
    end
end
