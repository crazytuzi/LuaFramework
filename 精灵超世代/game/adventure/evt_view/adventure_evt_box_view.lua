-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      事件宝箱
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AdventureEvtBoxWindow = AdventureEvtBoxWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()

function AdventureEvtBoxWindow:__init(data)
    self.win_type = WinType.Big
    self.data = data
    self.config = data.config
    self.layout_name = "adventure/adventure_evt_box_view"
    self.is_full_screen = false
    self.item_list = {}
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
    }
    self.is_send_proto = false
    self.is_use_csb = false
    self.need_list = {}
end
function AdventureEvtBoxWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.item_container = self.main_container:getChildByName("item_container")

    self.ack_button = self.main_container:getChildByName("ack_button")
    self.ack_button:getChildByName("label"):setString(TI18N("打 开"))

    self.title_label = self.main_container:getChildByName("title_label")
    self.title_label:setString(TI18N("宝箱"))
    self.reward_label = self.main_container:getChildByName("reward_label")
    self.reward_label:setString(TI18N("随机奖励预览"))
    self.swap_desc_label = createRichLabel(24, 175, cc.p(0.5, 1), cc.p(360, 750), nil, nil, 610)
    self.main_container:addChild(self.swap_desc_label)
    self.swap_desc_label:setVisible(true)
    local scroll_view_size = self.item_container:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 25, -- 第一个单元的X起点
        space_x = 15, -- x方向的间隔
        start_y = 20, -- 第一个单元的Y起点
        space_y = 10, -- y方向的间隔
        item_width = BackPackItem.Width * 0.9, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.9, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 5, -- 列数，作用于垂直滚动类型
        scale = 0.9
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.item_container, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(scroll_view_size.width,scroll_view_size.height - 49), setting)
    
    -- self.tips_desc_label = createRichLabel(24, 175, cc.p(1, 0.5), cc.p(665, 320), nil, nil, 500)
    -- self.main_container:addChild(self.tips_desc_label)
    -- self.tips_desc_label:setVisible(true)
    self:updatedata()
end

function AdventureEvtBoxWindow:updatedata()
    if self.config then
        self.swap_desc_label:setString(self.config.desc)
        if self.config.lose and next(self.config.lose[1] or {}) ~= nil then 
            self:updateItemData(self.config.lose)
        end
        self:updateTipsLabel(self.config.base_items)
        -- self:createEffect(self.config.effect_str)
        local res_data = self.config.effect_str[1]
        local res_type = res_data[1]    -- 1.图片资源(如果是怪物或者boss事件的,就创建特效) 2.特效资源
        local res_id = res_data[2]  -- 资源名字
        if res_type == 2 then
            self:createEffect(res_id)
        end
        if self.config.box_show_item and next(self.config.box_show_item or {}) ~= nil then
            self:updateRankItemData(self.config.box_show_item)
        end
    end
end

function AdventureEvtBoxWindow:createEffect(bid)
    if bid ~= "" then
        if not tolua.isnull(self.main_container) and self.box_effect == nil then 
            self.box_effect = createEffectSpine(bid, cc.p(375, 855), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.box_effect:setScale(1.5)
            self.main_container:addChild(self.box_effect)
        end
    end
end

function AdventureEvtBoxWindow:updateItemData(data)
    if data and next(data or {}) ~= nil then
        self.need_list = data
        local item_width = BackPackItem.Width * #data
        local total_width = #data * BackPackItem.Height + #data * 5
        self.start_x = (self.item_container:getContentSize().width - total_width) * 0.5
        for i, v in ipairs(data) do
            if not self.item_list[i] then
                local item = BackPackItem.new(true,true)
                item:setBaseData(v[1],v[2])
                item:setScale(0.8)
                item:setAnchorPoint(cc.p(0.5,0.5))
                item:setDefaultTip()

                -- local config = Config.ItemData.data_get_data(v[1])
                -- local name_label = createRichLabel(26, 175, cc.p(0.5, 0.5), cc.p(105, 315))
                -- name_label:setString(config.name)
                -- self.main_container:addChild(name_label)
                
                local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(v[1])
                item:setNeedNum(v[2], num)
                -- local num_label = createRichLabel(26,175,cc.p(0,0.5),cc.p(160,380))
                -- num_label:setString(string.format(TI18N("拥有<div fontcolor=#e14737>%s</div>个"),num))
                -- self.main_container:addChild(num_label)

                -- local btn = createButton(self.main_container,"+",num_label:getPositionX() + num_label:getSize().width + 57/2,380,cc.size(57,50),PathTool.getResFrame("common","common_1046"),45)
                -- btn:setLabelPosition(27.5,28)
                -- btn:addTouchEventListener(function(sender, event_type)
                --     customClickAction(sender,event_type)
                --     if event_type == ccui.TouchEventType.ended then
                --         MallController:getInstance():openMallPanel(true)
                --     end
                -- end)
                item.bid = v[1]
                -- item.num_label = num_label
                -- item.name_label = name_label
                self.main_container:addChild(item)
                item:setPosition(360,440)
                self.item_list[i] = item
            end
        end 
    end
end

function AdventureEvtBoxWindow:updateRankItemData(data)
    if not data then return end
    local list = {}
    for k,v in ipairs(data) do
        local vo = {}
        vo = deepCopy(Config.ItemData.data_get_data(v[1]))
        vo.num = v[2]
		table.insert(list,vo)
    end
    self.item_scrollview:setData(list)

    self.item_scrollview:addEndCallBack(function (  )
		local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            if v.data and v.data.num ~= 1 then
                v:setNum(v.data.num)
            end
		end
	end)
end

function AdventureEvtBoxWindow:updateTipsLabel(data)
    -- if data then
    --     local str = ""
    --     for i, v in ipairs(data) do
    --         local name = Config.ItemData.data_get_data(v[1]).name
    --         str = str..name..v[2]
    --     end
    --     local final_str = TI18N("必定获得:") .. str
    --     self.tips_desc_label:setString(final_str)
    -- end
end

function AdventureEvtBoxWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    
    registerButtonEventListener(self.ack_button, function() 
        if self.data then
            local ext_list = { { type = 1, val = 0 } }
            controller:send20620(self.data.id, AdventureEvenHandleType.handle,ext_list)
        end
    end, true, 1) 

    --更新物品数量
    -- if not self.add_goods_event then
    --     self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             for i, v in pairs(data_list) do
    --                 if v and v.base_id then
    --                     self:updateNum(v.base_id)
    --                 end
    --             end
    --         end
    --     end)
    -- end

    -- if not self.sell_goods_event then 
    --     self.sell_goods_event = GlobalEvent:getInstance():Bind(MarketEvent.Gold_Sell_Price,function()
    --         self:updateGoodPrice()
    --     end)
    -- end

    if not self.update_box_event then
        self.update_box_event = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Box_Result_Info,function (data)
            if data then
                self:updateResult(data)
            end
        end)
    end
end

function AdventureEvtBoxWindow:updateResult(data)
    self.box_effect:setAnimation(0,PlayerAction.action_1,false)
    delayOnce(function ()
		controller:showGetItemTips(data.items)
        controller:openEvtViewByType(false) 
    end,1)
end

function AdventureEvtBoxWindow:updateNum(base_id)
    if self.item_list then
        for i, item in ipairs(self.item_list) do
            if item and item.num_label then
                if item.bid == base_id then
                    local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item.bid)
                    item.num_label:setString(string.format(TI18N("拥有<div fontcolor=#e14737>%s</div>个"), num))
                end
            end
        end
    end
end


function AdventureEvtBoxWindow:openRootWnd(type)
end

function AdventureEvtBoxWindow:close_callback()
    if self.item_list then
        for i, item in ipairs(self.item_list) do
            if item then
                item:DeleteMe()
            end
        end
        self.item_list = {}
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    -- if self.add_goods_event then
    --     GlobalEvent:getInstance():UnBind(self.add_goods_event)
    --     self.add_goods_event = nil
    -- end
    -- if self.sell_goods_event then
    --     GlobalEvent:getInstance():UnBind(self.sell_goods_event)
    --     self.sell_goods_event = nil
    -- end
    if self.update_box_event then
        GlobalEvent:getInstance():UnBind(self.update_box_event)
        self.update_box_event = nil
    end
    controller:openEvtViewByType(false)
end