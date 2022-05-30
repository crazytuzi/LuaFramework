-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      试卷提交
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionBuyPanel = ActionBuyPanel or BaseClass(BaseView)

local controller = ActiontermbeginsController:getInstance()

function ActionBuyPanel:__init()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini    
    self.layout_name = "actiontermbegins/action_buy_panel"        
    self.res_list = {
        
    }
    self.is_can_buy_max = false
end

function ActionBuyPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setPosition(360, 640)
    self.background:setAnchorPoint(cc.p(0.5, 0.5))
    self.background:setScale(display.getMaxScale())
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)

    self.title_con = self.main_container:getChildByName("title_con")
    self.title_label = self.title_con:getChildByName("title_label")
    self.title_label:setString(TI18N("购买"))

    self.ok_btn = self.main_container:getChildByName("ok_btn")
    self.ok_btn:setTitleText(TI18N("购买"))
    self.ok_btn.label = self.ok_btn:getTitleRenderer()
    if self.ok_btn.label ~= nil then
        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn:setTitleText(TI18N("取消"))
    self.cancel_btn.label = self.cancel_btn:getTitleRenderer()
    if self.cancel_btn.label ~= nil then
        self.cancel_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.item_con = self.main_container:getChildByName("item_con")
    self.name = self.item_con:getChildByName("name")
    self.have_count_title = self.item_con:getChildByName("have_count_title")
    self.have_count_title:setString(TI18N("当前拥有:"))
    self.have_count = self.item_con:getChildByName("have_count")

    -- self.coin = self.item_con:getChildByName("coin")
    -- self.price = self.item_con:getChildByName("price")
    -- self.limit = self.item_con:getChildByName("limit")

    self.icon_bg_image = self.item_con:getChildByName("Image_1")

    self.goods_item = BackPackItem.new()
    --self.goods_item:setData(Config.ItemData.data_get_data(1))
    --self.goods_item:setScale(0.8)
    self.goods_item:setPosition(110,self.item_con:getContentSize().height/2-2)
    self.item_con:addChild(self.goods_item)

    self.info_con = self.main_container:getChildByName("info_con")
    self.slider = self.info_con:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(10, 89)
    self.buy_count_title = self.info_con:getChildByName("buy_count_title")
    self.buy_count_title:setString(TI18N("购买数量："))
    self.plus_btn = self.info_con:getChildByName("plus_btn")
    self.buy_count = self.info_con:getChildByName("buy_count")
    self.num = 1
    self.buy_count:setString(self.num)
    self.min_btn = self.info_con:getChildByName("min_btn")
    self.max_btn = self.info_con:getChildByName("max_btn")
    -- self.total_price_title = self.info_con:getChildByName("total_price_title")
    -- self.total_price_title:setString(TI18N("总价："))
    -- self.total_price = self.info_con:getChildByName("total_price")
    self.buy_desc = self.main_container:getChildByName("buy_desc")
    self.buy_desc:setString("")
    -- self.tips_label = createLabel(22, 15, nil, 385, 277, TI18N('只能买这么多了'), self.main_container, nil, cc.p(0.5, 0.5))
    -- self.tips_label:setVisible(false)
end

--@setting写到这里
--setting.item_id --道具id (如果不是道具id 未支持)
--setting.name 显示的名字 如果nil 默认道具名字
--setting.shop_type 商店类型 参考 MallConst.MallType
--setting.limit_num 限制数量 如果不限制 拥有的数量
function ActionBuyPanel:openRootWnd(setting)
    if not setting then return end
    self.setting = setting
    local item_id = setting.item_id
    local name = setting.name
    local shop_type = setting.shop_type

    self.limit_num = setting.limit_num
    local config = Config.ItemData.data_get_data(item_id)
    if config then
        self.goods_item:setData(config)
        if name then
            self.name:setString(name) 
        else
            self.name:setString(config.name) 
        end

        --当前拥有
        local count = BackpackController:getInstance():getModel():getItemNumByBid(config.id)
        self.have_count:setString(count)
        if self.limit_num == nil or self.limit_num == 0 then
            self.limit_num = count
        end

    else
        --icon 待写 暂时不支持不是item_id的显示.
        self.name:setString(name)
    end
    self:initShopTypeUI(shop_type)

    self:setCurUseItemInfoByNum(self.num, true)
end

--根据不同商店类型不同ui调整
function ActionBuyPanel:initShopTypeUI(shop_type)
    if not shop_type then return end
    if shop_type == MallConst.MallType.TermBeginsBuy then --开学季提交试卷
        self.buy_count_title:setString(TI18N("提交数量:"))
        self.ok_btn:setTitleText(TI18N("提交"))
        self.title_label:setString(TI18N("提交试卷"))
    end
end

function ActionBuyPanel:onClickBtnClose()
    controller:openActionBuyPanel(false)
end

function ActionBuyPanel:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.ok_btn, handler(self, self.sendBuy) ,true, 1)

    if self.slider ~= nil then
        self.slider:addEventListener(function ( sender,event_type )
            if event_type == ccui.SliderEventType.percentChanged then
                if self.limit_num <= 0 then
                    self.slider:setPercent(0)
                    return
                end
                -- if self.slider:getPercent() == 100 and self.is_can_buy_num >= self.limit_num and self.is_can_buy_max == false then
                --     self.tips_label:setVisible(true)
                -- else
                --     self.tips_label:setVisible(false)
                -- end
                self:setCurUseItemInfoByPercent(self.slider:getPercent())
            end
        end)
    end

    self.min_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.num <= 0 then return end
            self.num = self.num - 1
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
    self.plus_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.num = self.num + 1
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.num = self.limit_num
            self:setCurUseItemInfoByNum(self.num)
        end
    end)
end

function ActionBuyPanel:sendBuy()
    if not self.setting then return end
    if self.num > 0 then
        if self.setting.shop_type == MallConst.MallType.TermBeginsBuy then --开学季提交试卷
           ActiontermbeginsController:getInstance():sender26704(self.num)
        end
    end
    controller:openActionBuyPanel(false)
end

function ActionBuyPanel:setCurUseItemInfoByPercent(percent)
    local num = math.floor( percent * self.limit_num * 0.01 )
    self:setCurUseItemInfoByNum(num)
end

function ActionBuyPanel:setCurUseItemInfoByNum(num, not_check)
    if not not_check and self.limit_num <= 0 then
        message(TI18N("数量不足"))
        return
    end

    self.num = num
    
    if self.num < 1 then
        self.num = 1
    end

    if self.num > self.limit_num then
        self.num = self.limit_num
    end

    local percent = self.num / self.limit_num * 100
    if percent < 1 then --进度条数值区间[1,100]
        percent = math.ceil(percent)
    end
    self.slider:setPercent(percent)
    self.buy_count:setString(self.num)
end

function ActionBuyPanel:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    controller:openActionBuyPanel(false)
end