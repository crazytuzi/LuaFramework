-- --------------------------------------------------------------------
-- 抢红包
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagGetPanel = class("RedBagGetPanel", function()
    return ccui.Widget:create()
end)
local table_sort = table.sort
function RedBagGetPanel:ctor(parent)  
    self:config()
    self:layoutUI()
end

function RedBagGetPanel:config()
    self.ctrl = RedbagController:getInstance()
    self.size = cc.size(644,740)
    self:setContentSize(self.size)
    self:setTouchEnabled(false)
end

function RedBagGetPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("redbag/redbag_get")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")
end

function RedBagGetPanel:setData(data)
end

--事件
function RedBagGetPanel:registerEvents(status)
    if not status then
        if self.update_data_event then
            GlobalEvent:getInstance():UnBind(self.update_data_event)
            self.update_data_event = nil
        end
    else
        if not self.update_data_event then 
            self.update_data_event = GlobalEvent:getInstance():Bind(RedbagEvent.Get_Data_Event,function()
                self:updateBagList(true)
            end)
        end
    end
end

function RedBagGetPanel:updateBagList(is_event)
    local red_bag_list = self.ctrl:getModel():getRedBagList() or {}
    local list = clone(red_bag_list)
    if not list or next(list) == nil then 
        self:showEmptyIcon(true)
        if self.list_view then
            self.list_view:setVisible(false)
        end
    else
        self:showEmptyIcon(false)

        local sort_func = SortTools.KeyUpperSorter("order")
        table_sort(list, sort_func)

        if not self.list_view then
            local scroll_view_size = cc.size(570,790)
            local setting = {
                item_class = RedBagItem,      -- 单元类
                start_x = 10,                  -- 第一个单元的X起点
                space_x = 23,                    -- x方向的间隔
                start_y = 5,                    -- 第一个单元的Y起点
                space_y = 10,                   -- y方向的间隔
                item_width = 262,               -- 单元的尺寸width
                item_height = 327,              -- 单元的尺寸height
                row = 2,                        -- 行数，作用于水平滚动类型
                col = 2,                         -- 列数，作用于垂直滚动类型
                need_dynamic = true
            }
            self.list_view = CommonScrollViewLayout.new(self.main_panel, cc.p(38, 43) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
        end
        if  is_event == true then
            self.list_view:resetAddPosition(list)
        else
            local function callback(item,vo)
                if vo and next(vo)~=nil then
                    local is_can_get = item:getIsCanGet()
                    if is_can_get == true then
                        self.ctrl:sender13536(vo.id)
                        self.ctrl:setRedBagVo(vo)
                    else
                        self.ctrl:openLookWindow(true,vo)
                    end
                end
            end
            self.list_view:setData(list, callback)
        end
    end
end

function RedBagGetPanel:setVisibleStatus(bool)
    self:setVisible(bool)
    self:registerEvents(bool)

    -- 这里做一次处理是因为可能切换了标签页之后,自己发了红包没更新
    if bool == true then
        self:updateBagList()
    end
end

--仅仅更新，不全部重新创建
function RedBagGetPanel:updateListData(red_bag_list)
    local list = self.list_view:getItemList()
    local index = 1
    for i,v in pairs(red_bag_list) do
        if list[index] then 
            list[index]:setData(v)
        end
        index = index +1
    end
end

--显示空白
function RedBagGetPanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    local main_size = self.main_panel:getContentSize()
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5,0))
        self.empty_con:setPosition(cc.p(main_size.width/2,440))
        self.main_panel:addChild(self.empty_con,10)
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
        local bg = createImage(self.empty_con, res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("当前没有可以抢的红包，不来一发吗？")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function RedBagGetPanel:DeleteMe()
    if self.update_data_event then 
        GlobalEvent:getInstance():UnBind(self.update_data_event)
        self.update_data_event = nil
    end
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
end





