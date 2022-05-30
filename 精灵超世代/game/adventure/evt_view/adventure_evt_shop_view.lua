-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      神界神秘商店事件
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureEvtShopView = AdventureEvtShopView or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()

function AdventureEvtShopView:__init(data) 
    if data then
        self.data = data
        self.config = data.config
    end
    self.is_auto_open = false

    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.is_full_screen = false
    self.layout_name = "adventure/adventure_evt_shop_view"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_55"), type = ResourcesType.single},
        { path = PathTool.getPlistImgForDownLoad("mall", "mall"), type = ResourcesType.plist},
    }
    self.shop_item_list = {}
end

function AdventureEvtShopView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("title_label"):setString(TI18N("神秘商店"))
    self.item_container = container:getChildByName("item_container")
    self.desc = container:getChildByName("desc")
    -- self.desc:setTextAreaSize(cc.size(256, 134))
    self.close_btn = container:getChildByName("close_btn")

    self.total_width = self.item_container:getContentSize().width
end

function AdventureEvtShopView:register_event()
    registerButtonEventListener(self.background, function() 
        controller:openEvtViewByType(false)
        controller:openAdventureEvtShopView(false)
    end, false, 2) 

    registerButtonEventListener(self.close_btn, function() 
        controller:openEvtViewByType(false)
        controller:openAdventureEvtShopView(false)
    end, true, 2) 

    self:addGlobalEvent(AdventureEvent.Update_Evt_Shop_Info, function(data)
        self:updateShopItem(data.list)
    end)

	self:addGlobalEvent(AdventureEvent.UpdateShopItemEvent, function(id)
		self:updateSingleShopItem(id)
	end)
end

function AdventureEvtShopView:openRootWnd(data)
    if data then
        self.is_auto_open = true
        self:updateShopItem(data)
        local const_config = Config.AdventureData.data_adventure_const.businessman_description
        if const_config then
            self.desc:setString(const_config.desc)
        end
    else
        if self.config then
            self.desc:setString(self.config.desc)
        end
        if self.data then
            controller:send20620(self.data.id, AdventureEvenHandleType.requst, {})
        end
    end
end

function AdventureEvtShopView:updateShopItem(list)
    local count = #list
    local space = 50
    local cell_width = 100
    local tmp_width = count * cell_width + (count - 1) * space -- 总的个数需要的长度
    local start_x = ( self.total_width - tmp_width ) * 0.5

    for i, v in ipairs(list) do
        local object = self.shop_item_list[v.id]
        if object == nil then
            object = self:createShopItem(i, start_x, cell_width, space, v.id)
            self.shop_item_list[v.id] = object

            -- 设置基础数据
            object.item:setBaseData(v.bid, v.num)

            -- 购买价格
            if object.buy_config == nil then
                local buy_config = Config.ItemData.data_get_data(v.pay_type)
                if buy_config then
                    object.label:setString(string.format("<img src=%s visible=true scale=0.4 />,<div fontColor=#ffffff fontsize=24 shadow=0,-2,2,%s>%s</div>", PathTool.getItemRes(buy_config.icon), Config.ColorData.data_new_color_str[2], v.pay_val))
                    object.buy_config = buy_config
                end
            end
            -- 物品图标
            if object.item_config == nil then
                local item_config = Config.ItemData.data_get_data(v.bid)
                if item_config then
                    object.item_name:setString(item_config.name)
                    object.item_config = item_config 
                end
            end
            -- 折扣价格
            if v.discount == 0 or v.discount == 10 then
                object.discount:setVisible(false)
            else
                object.discount:setVisible(true)
                -- object.discount_label:setString(v.discount..TI18N("折"))
                local zhe_res = PathTool.getResFrame("common", MallConst.Variety_Zhe_Res[v.discount])
                object.discount:loadTexture(zhe_res, LOADTEXT_TYPE_PLIST)
                object.discount:ignoreContentAdaptWithSize(true)
            end
        end
        if v.is_buy == 1 then
            object.sell_over:setVisible(true)
        else
            object.sell_over:setVisible(false)
        end
        object.data = v
    end
end

--==============================--
--desc:购买物品返回
--time:2019-01-25 09:16:06
--@id:
--@return 
--==============================--
function AdventureEvtShopView:updateSingleShopItem(id)
    if self.shop_item_list == nil then return end
    local object = self.shop_item_list[id]
    if object == nil then return end
    object.data.is_buy = 1      -- 变为已购买
    object.sell_over:setVisible(true) 
end

function AdventureEvtShopView:clickBuyIndex(id)
    if id == nil then return end
    local object = self.shop_item_list[id]
    if object == nil or object.data == nil then return end
    if object.data.is_buy == 1 then
        message(TI18N("该物品已被购买"))
        return
    end
    if object.item_config == nil or object.buy_config == nil then return end
    local color = BackPackConst.quality_color_id[object.item_config.quality] or 0
    local str = string.format("%s<img src=%s visible=true scale=0.3 />%s%s<div fontColor=%s>%s</div>x%s", TI18N("是否消耗"),PathTool.getItemRes(object.buy_config.icon), object.data.pay_val, TI18N("购买"), tranformC3bTostr(color), object.item_config.name, object.data.num)
    CommonAlert.show(str, TI18N("确定"), function()
        if self.is_auto_open == true then
			controller:requestBuyShopItem(object.data.id)
        else
            if self.data then
                local ext_list = {{type = 1, val = object.data.id}} 
                controller:send20620(self.data.id, AdventureEvenHandleType.handle, ext_list)
            end
        end
    end, TI18N("取消"), nil, CommonAlert.type.rich)
end

function AdventureEvtShopView:createShopItem(index, start_x, cell_width, space, id)
    local object = {}
    local node = ccui.Layout:create()
    node:setAnchorPoint(0.5, 0.5)
    node:setContentSize(cc.size(cell_width, 100))
    local _x = start_x + cell_width * 0.5 + (index - 1) * (cell_width + space) 
    local _y = 118
    node:setPosition(_x, _y)
    self.item_container:addChild(node)

    local item = BackPackItem.new(false, true, false, 1, false, true)
    item:setPosition(50, 102)
    node:addChild(item)

    local item_name = createLabel(22, Config.ColorData.data_new_color4[11], nil, 50, 25, TI18N("我是物品名字"), node, nil, cc.p(0.5,0.5))
    item_name:setDimensions(140,48)
    item_name:setAlignment(cc.TEXT_ALIGNMENT_CENTER)

    local button = createImage(node, PathTool.getResFrame("common", "common_1018"), 50, -20, cc.p(0.5, 0.5), true, 1, true) 
    -- button:setContentSize(cc.size(134,52))
    button:setScale(0.8)
    button:setTouchEnabled(true)
    button:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type, 0.8)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:clickBuyIndex(id)
        end
    end)

    local btn_size = button:getContentSize()
    local button_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_size.width*0.5, btn_size.height*0.5)) 
    button_label:setString(TI18N("我是按钮名字"))
    button:addChild(button_label)

    -- local sell_over = createSprite(PathTool.getResFrame("mall", "txt_cn_mall_sell_finish"), 50, 96, node, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
    local sell_over = createSprite("res/resource/mall/txt_mall/txt_mall_sell_finish.png", 50, 96, node, cc.p(0.5,0.5), LOADTEXT_TYPE)
    sell_over:setVisible(false)

    -- local discount = createSprite(PathTool.getResFrame("mall", "mall_06"), 6, 130, node, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    local zhe_res = PathTool.getResFrame("common", MallConst.Variety_Zhe_Res[1])
    local discount = createImage(node, zhe_res, 6, 158, cc.p(0.5, 0.5), true, 1, true)
    discount:ignoreContentAdaptWithSize(true)
    discount:setVisible(false)

    -- local discount_label = createLabel(24, 1, cc.c4b(0xae,0x2a,0x00,0xff), 29, 52, "", discount, nil, cc.p(0.5,0.5))

    object.node = node
    object.item = item
    object.item_name = item_name
    object.button = button
    object.label = button_label
    object.sell_over = sell_over 
    object.discount = discount
    -- object.discount_label = discount_label

    return object
end

function AdventureEvtShopView:close_callback()
    for i,v in pairs(self.shop_item_list) do
        if v.item then
            v.item:DeleteMe()
        end
    end
    self.shop_item_list = nil
    controller:openEvtViewByType(false)
    controller:openAdventureEvtShopView(false)
end 