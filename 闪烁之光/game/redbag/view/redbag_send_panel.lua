-- --------------------------------------------------------------------
-- 发红包
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RedBagSendPanel = class("RedBagSendPanel", function()
    return ccui.Widget:create()
end)
local table_insert = table.insert
function RedBagSendPanel:ctor(extend_id)  
    self:config(extend_id)
    self:layoutUI()
    self:registerEvents()
    self:requireProto()
end
function RedBagSendPanel:config(extend_id)
    self.ctrl = RedbagController:getInstance()
    self.size = cc.size(644,740)
    self:setContentSize(self.size)
    self:setTouchEnabled(false)
    self.is_can_save =false
    self.item_list = {}
    self.need_list = {}
    self.default_msg = TI18N("身为土豪，有钱任性")
    self.is_send_proto = false
    self.use_assert = 0 --使用道具还是资产法红包
    self.msg_list = {}
    self.extend_id = extend_id or self.ctrl:getModel():getHaveItemID() or 1
    self.select_msg = nil
end

function RedBagSendPanel:layoutUI()

    local csbPath = PathTool.getTargetCSB("redbag/redbag_send")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.bottom_panel = self.main_panel:getChildByName("bottom_panel")

    self.num_panel = self.bottom_panel:getChildByName("num_panel")

    self.send_btn = self.bottom_panel:getChildByName("send_btn")
    self.send_btn_red_point = self.send_btn:getChildByName("red_point")
    self.send_btn_red_point:setVisible(false)
    local btn_size = self.send_btn:getContentSize()
    self.send_btn_label = createRichLabel(26, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.send_btn:addChild(self.send_btn_label)
    self.send_tips = self.bottom_panel:getChildByName("send_tips")
    self.send_tips:setVisible(false)

    self.left_btn = self.top_panel:getChildByName("left_btn")
    self.right_btn = self.top_panel:getChildByName("right_btn")
    self.right_btn_red_point = self.right_btn:getChildByName("red_point")
    self.right_btn_red_point:setVisible(false)

    self.left_btn_red_point = self.left_btn:getChildByName("red_point")
    self.left_btn_red_point:setVisible(false)

    self.item_container = self.bottom_panel:getChildByName("item_container")

    self.bottom_panel:getChildByName("num_desc"):setString(TI18N("个数:"))
    self.num_label = self.bottom_panel:getChildByName("num_label")

    self.bottom_panel:getChildByName("send_msg"):setString(TI18N("红包寄语:"))
    self.bottom_panel:getChildByName("title_label"):setString(TI18N("红包信息"))
    self.bottom_panel:getChildByName("send_value"):setString(TI18N("红包金额:"))

    self.send_content = self.bottom_panel:getChildByName("send_content")

    self:createDesc()
end

function RedBagSendPanel:createDesc()
    self.send_notice = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(self.top_panel:getContentSize().width*0.5, 32))
    self.top_panel:addChild(self.send_notice)
    self.send_notice:setString(string.format(TI18N("(今日还可发<div fontcolor=#249003>%s</div>)"), 100))

    --红包金额
    self.red_coin = createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,0.5),cc.p(162,226),nil,nil,500)
    self.bottom_panel:addChild(self.red_coin)

    self:updateBagList()
end

function RedBagSendPanel:requireProto()
    RedbagController:getInstance():send13546()
end

function RedBagSendPanel:setData(data)
end

--事件
function RedBagSendPanel:registerEvents()
    self.send_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.red_send_info == nil or self.select_vo == nil then return end
            if self.cost_item_bid and self.cost_item_bid ~= 0 then -- 表示可消耗道具进行红包发放
                self.ctrl:sender13535(self.select_vo.id, 1)
            else
                local charge_config = Config.ChargeData.data_charge_data[self.select_vo.charge_id] 
                if charge_config then
                    sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name) 
                end
            end
        end
    end)

    self.left_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.list_view and not tolua.isnull(self.list_view) then 
                self.list_view:runLeftPostion()
            end
        end
    end)
    self.right_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.list_view and not tolua.isnull(self.list_view) then 
                self.list_view:runRightPostion()
            end
        end
    end)
    if not self.send_success_event then 
        self.send_success_event = GlobalEvent:getInstance():Bind(RedbagEvent.Update_Red_Bag_Event ,function(data)
            self:updateRedInfo(data)
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
end

function RedBagSendPanel:updateBagList()
    if not self.list_view then
        local scroll_view_size = cc.size(580,370)
        local setting = {
            item_class = RedBagItem,      -- 单元类
            start_x = 10,                  -- 第一个单元的X起点
            space_x = 30,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 10,                   -- y方向的间隔
            item_width = 262,               -- 单元的尺寸width
            item_height = 327,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1                         -- 列数，作用于垂直滚动类型
        }
        self.list_view = RedBagListPanel.new(self.top_panel, cc.p(33, 20) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    end
   
    local config = Config.GuildData.data_guild_red_bag

    local list = {}
    local index = 1
    for i,v in pairs(config) do
        list[index] = {data=v,open_type=1}
        index =index +1
    end
    
    for i, v in ipairs(list) do
        v.sort_index = 1
        if v.data.id == self.extend_id then
            v.sort_index = 0
        end
    end
    local sort_func = SortTools.tableLowerSorter({"sort_index","id"})
    table.sort(list,sort_func)

    self.list_view:setData(list)
    self.list_view:addEndCallBack(function()
        self:updateMessage()
    end)
end

function RedBagSendPanel:updateMessage()
    local item = self.list_view:getSelectItem()
    local vo = nil
    if item then 
        vo = item:getData()
    end
    if self.select_vo and self.select_vo == vo then return end
    self.select_vo = vo
    if not self.select_vo then return end
    local data = self.select_vo

    --红包金额
    local coint = data.assets
    local item_id = Config.ItemData.data_assets_label2id[coint]
    local item_config = Config.ItemData.data_get_data(item_id)
    if item_config then
        local val = data.val
        local res = PathTool.getItemRes(item_config.icon)
        local str = string.format(TI18N("<img src='%s' scale=0.35 />%s"),res,val)
        self.red_coin:setString(str)
    end

    self.send_content:setString(self.select_vo.msg) 
    self.num_label:setString(self.select_vo.num)
    self:fileRewardsItem(self.select_vo.reward)
    self:showRedSendNum()
end

function RedBagSendPanel:fileRewardsItem(list)
    if list == nil or next(list) == nil then return end
    for k,v in pairs(self.item_list) do
        v:setVisible(false)
    end
    local scale = 0.7
    local off = 10
    for i,v in ipairs(list) do
        local bid = v[1]
        local num = v[2]
        if self.item_list[i] == nil then
            self.item_list[i] = BackPackItem.new(false, true, false, scale, false, true)
            self.item_container:addChild(self.item_list[i])
            local _x = 10 + (120 * scale + off) * (i - 1) + 120 * scale * 0.5 
            self.item_list[i]:setPosition(_x, 50)
        end
        local item = self.item_list[i]
        item:setBaseData(bid,num)
        item:setVisible(true)
    end
end

--==============================--
--desc:设置红包可发次数
--time:2019-01-16 05:48:16
--@data:
--@return 
--==============================--
function RedBagSendPanel:updateRedInfo(data)
    self.red_send_info = data
    self:showRedSendNum()
end

function RedBagSendPanel:updateItemNum( bag_code, data_list )
    if self.cost_item_bid then
        if bag_code and data_list then
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                for i,v in pairs(data_list) do
                    if v and v.base_id and self.cost_item_bid == v.base_id then
                        self:showRedSendNum()
                        break
                    end
                end
            end
        end
    end
end

function RedBagSendPanel:showRedSendNum()
    if self.red_send_info == nil or self.select_vo == nil then return end
    local red_config = Config.GuildData.data_guild_red_bag[self.select_vo.id]
    if not red_config then return end
    
    self.cost_item_bid = 0 -- 可以消耗道具发红包的道具bid
    self.send_tips:setVisible(false)
    addRedPointToNodeByStatus(self.send_btn, false)

    local send_num = 0
    for i,v in ipairs(self.red_send_info) do
        if v.id == self.select_vo.id then
            send_num = v.num
            break
        end
    end
    send_num = self.select_vo.limit - send_num
    if send_num < 0 then
        send_num = 0
    end
    self.send_notice:setString(string.format(TI18N("(今日还可发<div fontcolor=#249003>%s</div>)"), send_num))
    if send_num == 0 then
        self.send_btn_label:setString(TI18N("次数已达上限"))
    else
        local charge_config = Config.ChargeData.data_charge_data[self.select_vo.charge_id]
        if self:checkLossItemIsEnough(red_config.loss_item) then
            local bid = red_config.loss_item[1][1]
            local num = red_config.loss_item[1][2]
            local item_cfg = Config.ItemData.data_get_data(bid)
            if item_cfg then
                self.cost_item_bid = bid
                self.send_btn_label:setString(string.format(TI18N("<img src=%s scale=0.5 /><div outline=2,#764519>%d 发红包</div>"), PathTool.getItemRes(item_cfg.icon), num))
                self.send_tips:setString(string.format(TI18N("当前拥有红包令，消耗%d个可发放1次该红包"), num))
                self.send_tips:setVisible(true)
                addRedPointToNodeByStatus(self.send_btn, true, 7, 7)
            end
        elseif charge_config then
            self.send_btn_label:setString(string.format(TI18N("<div outline=2,#764519>%s元 发红包</div>"), charge_config.val))
        end
    end
    if self.cur_send_num ~= send_num then
        self.cur_send_num = send_num
        if send_num == 0 then
            setChildUnEnabled(true, self.send_btn) 
            self.send_btn:setTouchEnabled(false)
        else
            setChildUnEnabled(false, self.send_btn) 
            self.send_btn:setTouchEnabled(true)
        end
    end
end

-- 判断道具数量是否足够发红包
function RedBagSendPanel:checkLossItemIsEnough( loss_items )
    local is_enough = false
    if loss_items and loss_items[1] then
        local bid = loss_items[1][1]
        local need_num = loss_items[1][2]
        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
        if have_num >= need_num then
            is_enough = true
        end
    end
    return is_enough
end

function RedBagSendPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RedBagSendPanel:DeleteMe()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.send_success_event then
        GlobalEvent:getInstance():UnBind(self.send_success_event)
        self.send_success_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
end



