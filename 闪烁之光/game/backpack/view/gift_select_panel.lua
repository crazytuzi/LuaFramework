--自选礼包 
GiftSelectPanel = GiftSelectPanel or BaseClass(BaseView)
function GiftSelectPanel:__init()
    self.layout_name = "backpack/gift_select"
    self.win_type = WinType.Mini
    self:config()
end

function GiftSelectPanel:config()
    self.WIDTH = 460  --界面的宽度
    self.HEIGHT = 350 --
    self.GOODS_WIDTH = 68 --偏移量
    self.select_type = 1
    self.ctrl = BackpackController:getInstance()
end

function GiftSelectPanel:open_callback()
    self.main_panel = self.root_wnd:getChildByName("main_panel")  
    self:playEnterAnimatianByObj(self.main_panel, 2)
    local size = self.main_panel:getContentSize() 
    self.close_btn =self.main_panel:getChildByName("close_btn") 
    self.top_panel = self.main_panel:getChildByName("top_panel") 
    local title = self.top_panel:getChildByName("title_label") 
    title:setString(TI18N("自选礼包"))

    --领取按钮
    self.use_btn = self.main_panel:getChildByName("use_btn")
    self.use_btn:getChildByName("label"):setString(TI18N("使用"))
    --滚动部分
    self.scroll_view = createScrollView(585, 495, size.width/2, 105, self.main_panel, ccui.ScrollViewDir.vertical)
    self.scroll_view:setAnchorPoint(cc.p(0.5,0))

    self.desc_label = createRichLabel(24, Config.ColorData.data_color4[156], cc.p(0.5,1), cc.p(size.width/2,655), 2, nil, 400)
    self.main_panel:addChild(self.desc_label)
end


--设置数据
function GiftSelectPanel:updateGiftList(giftid,giftBid, goods_list, choose_num)
    self.giftid = giftid
    self.giftBid = giftBid
    self.goods_list = goods_list or {}
    self.choose_num = choose_num or 1
    --物品列表
    self.desc_label:setString(string.format(TI18N("请从以下奖励中选择%s个"), self.choose_num ))
    if not self.item_list then self.item_list = {} end
    if not self.name_list then self.name_list = {} end
    local scroll_size = self.scroll_view:getContentSize()
    local is_single = true

    local len = 0
    local role_vo = RoleController:getInstance():getRoleVo()
    local sort_id_list = {}
    for i, v in ipairs(self.goods_list) do
        if v.min_lev <=role_vo.lev and v.max_lev >=role_vo.lev then
            if sort_id_list[v.sort_id] == nil then
                sort_id_list[v.sort_id] = {}
            end
            table.insert(sort_id_list[v.sort_id], v)
            if #sort_id_list[v.sort_id] >1 then
                is_single = false
            end
        end
    end

    for k, v in pairs(sort_id_list) do
        len = len + 1
    end
    
    local max_height = math.max(scroll_size.height, len*130 +20)
    self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, max_height))

    local index = 1
    for i, v in pairs(sort_id_list) do
        local x, y
        x = scroll_size.width/2
        y =max_height -130*index
        if not self.item_list[index] then
            self.item_list[index] = GiftSelectItem.new(index, is_single)
            self.scroll_view:addChild(self.item_list[index])    
        end
        self.item_list[index]:setPosition(cc.p(x, y))
        self.item_data = {}
        for i1, v1 in ipairs(v) do
            local temp = {sort_id = i, base_id = v1.bid,quantity = v1.num}
            table.insert(self.item_data, temp)
        end
        self.item_list[index]:setData(self.item_data)
        self.item_list[index]:addCallBack(function(item,vo)
            local id = item.index or 1
            self:clickCallBack(id, vo)
        end)
        index = index +1
    end

    --选择列表置空
    self.select_list = {}
end


--点击的事件
function GiftSelectPanel:clickCallBack(goods_id, vo)
    --判断该bid是否存在的
    if self.select_list and #self.select_list > 0 then
        for i = #self.select_list, 1, -1 do
            local temp_id = self.select_list[i].goods_id
            if temp_id == goods_id then
                table.remove(self.select_list, i)
                self:setSelectedState(goods_id, false)
                return
            end
        end
    end
    
    --判断数量是否满了
    if #self.select_list >= self.choose_num then
        
         local item = table.remove(self.select_list, 1)
         local goods_id = item.goods_id
        self:setSelectedState(goods_id, false)
--        message2("选择数量已满！")
--        return
    end

    --插入数据
    table.insert(self.select_list, {goods_id=goods_id})
    self:setSelectedState(goods_id, true)
end

function GiftSelectPanel:register_event()
    self.use_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onUseBtn()
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.ctrl:closeGiftSelectPanel()
        end
    end)
end

function GiftSelectPanel:onUseBtn()
    if not self.gift_vo then return end
    if self.select_list and #self.select_list >= self.choose_num then
        local gift_id = self.giftid
        local chose_ids = {}
        local goods_num = 1
        for __, info in ipairs(self.select_list) do
            local item_data = {}
            if self.item_list then
                for __, item in pairs(self.item_list) do
                    if item.index and item.index == info.goods_id then
                        item_data = item.vo
                        break
                    end
                end
            end
            local cur_sort_id = -1
            for i, v in ipairs(item_data) do
                table.insert(chose_ids, {name=1,value = v.base_id,str =""})
                cur_sort_id = v.sort_id
            end
            if cur_sort_id >= 0 then
                table.insert(chose_ids, {name=2,value = cur_sort_id,str =""})
            end
            goods_num = info.num
        end
        local count = BackpackController:getInstance():getModel():getPackItemNumByBid(BackPackConst.Bag_Code.BACKPACK,self.giftBid)
        if count >1 and self.choose_num==1 then
            local item_id = self.gift_vo.base_id
            local item_config = Config.ItemData.data_get_data(item_id)
            if item_config and item_config.overlap == 1 then --如果堆叠数 是1 就直接打开吧
                self.ctrl:sender10515(gift_id,1,chose_ids)
                self.ctrl:closeGiftSelectPanel()
            else
                self.ctrl:openBatchUseItemView(true, self.gift_vo,1,chose_ids)
            end
        else
            self.ctrl:sender10515(gift_id,1,chose_ids)
            self.ctrl:closeGiftSelectPanel()
        end
    else
        message2(StringFormat(TI18N("请选择{0}个物品！"), self.choose_num))
    end
end

function GiftSelectPanel:setSelectedState(id, bool)
    if self.item_list then
        for __, item in pairs(self.item_list) do
            if item.index and item.index == id then
                item:setSelected(bool)
            end
        end
    end
end

function GiftSelectPanel:createTitleTxt(txt, x, y)
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0.5, 1))
    local size = cc.size(400, 20)
    container:setContentSize(size)
    container:setPosition(cc.p(x, y))
    local bg = createSprite(PathTool.getCommonRes("line7"), 0, 20)
    bg:setAnchorPoint(cc.p(0, 1))
    container:addChild(bg)
    bg = createSprite(PathTool.getCommonRes("line7"), size.width, 20)
    bg:setFlippedX(true)
    bg:setAnchorPoint(cc.p(1, 1))
    container:addChild(bg)
    local title = createLabel(22,Config.ColorData.data_color4[1],nil,size.width/2, 12,"",self.scroll_view,nil,cc.p(0,0))
    title:setString(txt)
    container:addChild(title)
    return container, title
end


function GiftSelectPanel:close_callback( ... )
    for k,item in pairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil
    self.select_list = nil
    self.name_list = nil
end

function GiftSelectPanel:openRootWnd(giftvo)
    local choose_num = 1
    self.gift_vo = giftvo
    if not giftvo then return end
    local giftId = giftvo.id

    local giftBid = giftvo.base_id
    local item_list = {}
    if Config.GiftData.data_choose_gift[giftBid] then
        -- local item = Config.ItemData.data_get_data(giftBid)
        -- if item and item.ext and #item.ext>0 then
        --     for i,v in pairs(item.ext) do
        --         choose_num = v
        --     end
        -- end
        local gift_cfg = Config.GiftData.data_choose_gift[giftBid]
        for k,v in pairs(gift_cfg) do
            table.insert(item_list, v)
        end
    end
    table.sort(item_list, SortTools.KeyLowerSorter("sort_id"))
    self:updateGiftList(giftId, giftBid, item_list, choose_num)
end









-- --------------------------------------------------------------------
-- 自选礼包子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
GiftSelectItem = class("GiftSelectItem", function()
	return ccui.Widget:create()
end)

function GiftSelectItem:ctor(index, is_single)
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("backpack/gift_select_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0))
    self:setContentSize(self.size)
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName("container")
    self.select_btn = self.container:getChildByName("select_btn")
    self.goods_con = self.container:getChildByName("goods_con")
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 20, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BackPackItem.Width * 0.9, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.9, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.9
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con,cc.p(0, 0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    self.is_single = is_single
    self:setTouchEnabled(true)
    self.index = index or 1
    self.is_break = false
    self.old_lev = 0
    self.attr_list ={}
    self:register_event()
    self.select_btn:setSelected(false)
end

function GiftSelectItem:register_event()
    registerButtonEventListener(self, function() 
        self:clickSelect()  
    end, false, 2)
    -- registerButtonEventListener(self.select_btn, function() 
    --     self:clickSelect()  
    -- end, false, 2)

    self.select_btn:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                self.check_box_status = self.select_btn:isSelected()
            elseif event_type == ccui.TouchEventType.ended then
                self:clickSelect()
            elseif event_type == ccui.TouchEventType.canceled then
                self.select_btn:setSelected(self.check_box_status or false)
            end
        end
    )
end

function GiftSelectItem:clickSelect()
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function GiftSelectItem:addCallBack( value )
	self.call_fun =  value
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function GiftSelectItem:setData( data)
    if data == nil then return end
    self.vo = data
    local list = {}
    for k, v in ipairs(self.vo) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.base_id))
        if vo then
            vo.quantity = v.quantity or 1
            table.insert(list, vo)
        end
    end

    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k, v in pairs(list) do
            v.effect = false
            v:setDefaultTip()
            v:setSwallowTouches(true)
        end
        if self.is_single then
            local name_text = list[1].data.name
            local quantity_text = list[1].data.quantity
            if self.item_name == nil then
                self.item_name = createLabel(26, Config.ColorData.data_color4[156], nil, 180, 65, name_text .. "X" .. quantity_text, self.container, nil, cc.p(0, 0.5))
            else
                self.item_name:setVisible(true)
                self.item_name:setString(name_text .. "X" .. quantity_text)
            end
            self.item_scrollview:setClickEnabled(false)
        elseif self.item_name ~= nil then
            self.item_name:setVisible(false)
            self.item_scrollview:setClickEnabled(true)
        end
    
    end)
    self.item_scrollview:setData(list)
end

function GiftSelectItem:setSelected(bool)
    bool = bool or false
    self.select_btn:setSelected(bool)
end

function GiftSelectItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end


function GiftSelectItem:getData( )
	return self.vo
end
function GiftSelectItem:DeleteMe()
    if self.goods_item then 
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
    self.vo =nil
end