-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      背包内出售物品的面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BackPackSellWindow = BackPackSellWindow or BaseClass(BaseView)

local table_insert = table.insert

function BackPackSellWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.ctrl = BackpackController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Mini
    self.item_list = {}
    self.layout_name = "backpack/backpack_sell_window"
    self.wait_sell_list = {}
end

function BackPackSellWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.total_width = self.container:getContentSize().width

    self.cell_resoult = self.container:getChildByName("cell_resoult")  -- img是资产图片节点，是个image  value 是值
    self.cell_resoult:setVisible(false)

    local aaaa = self.cell_resoult:clone()
    self.container:addChild(aaaa)

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.confirm_btn = self.container:getChildByName("confirm_btn")

    local label = self.cancel_btn:getChildByName("label")
    label:setString(TI18N("取消"))

    self.cell_label = self.confirm_btn:getChildByName("label")
    self.win_title = self.container:getChildByName("win_title")

    self.sell_desc = self.container:getChildByName("sell_desc")
    self.sell_title = self.container:getChildByName("sell_title")
end

function BackPackSellWindow:register_event()
    self.cancel_btn:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                BackpackController:getInstance():openSellWindow(false)
            end
        end
    )
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                BackpackController:getInstance():openSellWindow(false) 
            end
        end)
    end
    self.confirm_btn:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                if next(self.wait_sell_list) and self.bag_code then
                    BackpackController:getInstance():sender10522(self.bag_code, self.wait_sell_list)
                end
            end
        end
    )
end

--[[
    @desc:待出售的物品列表
    author:{author}
    time:2018-05-21 16:58:41
    --@list:是 goodvo 类型
    return
]]
function BackPackSellWindow:openRootWnd(bag_code, list)
    self.bag_code = bag_code
    self.wait_sell_list = {}
    local sell_value_list = {}
    for i,v in ipairs(list) do
        if v.id ~= nil and v.config ~= nil and v.config.value and next(v.config.value) then
            table_insert(self.wait_sell_list, {id = v.id, bid = v.base_id, num = v.quantity})
            for i, value in ipairs(v.config.value) do
                if sell_value_list[value[1]] == nil then
                    sell_value_list[value[1]] = {id=value[1], num=0}
                end
                sell_value_list[value[1]].num = sell_value_list[value[1]].num + value[2] * v.quantity
            end

            -- 如果是装备，则还需要判断他的精炼附加
            if self.bag_code == BackPackConst.Bag_Code.EQUIPS then 
                if v.enchant ~= 0 then
                    local config = Config.PartnerEqmData.data_partner_eqm(getNorKey(v.config.type, v.enchant))
                    if config ~= nil and config.sell ~= nil and next(config.sell) ~= nil then
                        for i,value in ipairs(config.sell) do
                            if sell_value_list[value[1]] == nil then
                                sell_value_list[value[1]] = {id = value[1], num = 0}
                            end
                            sell_value_list[value[1]].num = sell_value_list[value[1]].num + value[2] * v.quantity
                        end
                    end
                end
                local stone_id = 0
                local stone_count = 0
                for i,d in ipairs(v.gemstones) do
                    local key = getNorKey(v.config.type, d.lev)
                    local stone_config = Config.PartnerGemstoneData.data_upgrade[key]
                    if stone_config and next(stone_config.add) then
                        stone_id = stone_config.add[1][1]
                        stone_count = stone_count + stone_config.add[1][2]
                    end
                end
                if stone_count > 0 then
                    if sell_value_list[stone_id] == nil then
                        sell_value_list[stone_id] = {id = stone_id, num = 0}
                    end
                    sell_value_list[stone_id].num = sell_value_list[stone_id].num + stone_count
                end
            end

        end
    end
    self:showSellItemValue(sell_value_list)

    local title = ""
    if bag_code == BackPackConst.Bag_Code.BACKPACK then
        title = TI18N("分解")
    elseif bag_code == BackPackConst.Bag_Code.EQUIPS then
        title = TI18N("熔炼")
    end
    self.win_title:setString(title)
    self.cell_label:setString(title)
    self.sell_desc:setString(string.format(TI18N("%s后物品将不可找回"), title))
    self.sell_title:setString(string.format(TI18N("%s后将获得下列物品："), title))
end

--[[
    @desc:展示待出售物品可获得资产
    author:{author}
    time:2018-05-21 17:41:46
    --@list: 
    return
]]
function BackPackSellWindow:showSellItemValue(list)
    if list == nil then return end
    if tolua.isnull(self.cell_resoult) then return end
    local sum = 0
    local sell_item = nil
    local sell_list = {}
    local max_column = 3 --最大列数
    local total_width = 0
    local init_y = self.cell_resoult:getPositionY()
    local width = self.cell_resoult:getContentSize().width
    local height = self.cell_resoult:getContentSize().height
    for k,v in pairs(list) do
        local config = Config.ItemData.data_get_data(v.id)
        if config ~= nil then
            sum = sum + 1
            sell_item = self.cell_resoult:clone()
            sell_item:setVisible(true)
            self.container:addChild(sell_item)
            sell_item.img = sell_item:getChildByName("item_img")
            sell_item.img:loadTexture(PathTool.getItemRes(config.icon), LOADTEXT_TYPE)
            sell_item.value = sell_item:getChildByName("value")
            sell_item.value:setString(math.floor(v.num))
            -- sell_item:setPositionY(self.init_y)
            table.insert(sell_list, sell_item)
            if sum < 4 then
                total_width = total_width + sell_item:getContentSize().width
            end
        end
    end
    local row_count = math.floor((#sell_list - 1)/max_column) + 1 
    local start_x = ( self.total_width -  (#sell_list - 1) * 18 - total_width ) * 0.5
    local start_y = init_y + (row_count - 1)* height
    if row_count >= 2 then
        start_y = start_y - 10
    end
    for i, item in ipairs(sell_list) do
        local x = start_x + ((i-1)% max_column)*(width+18)
        local y = start_y - math.floor((i-1)/max_column) * (height + 10)
        item:setPosition(x, y)
    end
end

function BackPackSellWindow:close_callback()
    BackpackController:getInstance():openSellWindow(false)
end
