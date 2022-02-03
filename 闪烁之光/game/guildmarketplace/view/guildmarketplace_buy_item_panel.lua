-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      购买 放入
-- <br/>Create: 2019年9月19日
-- --------------------------------------------------------------------
GuildmarketplaceBuyItemPanel = GuildmarketplaceBuyItemPanel or BaseClass(BaseView)

local controller = GuildmarketplaceController:getInstance()
local string_format = string.format

--@show_type  1 表示购买 2 表示放入物品
function GuildmarketplaceBuyItemPanel:__init(show_type)
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini    
    self.layout_name = "guildmarketplace/guildmarketplace_buy_item_panel"        
    self.res_list = {
        
    }
    self.show_type = show_type or 1

    self.num = 1
end

function GuildmarketplaceBuyItemPanel:open_callback(  )
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
    self.tips_1 = self.item_con:getChildByName("tips_1")
    self.item_bg = self.item_con:getChildByName("item_bg")
    self.item_bg:setVisible(false)
    self.item_icon = self.item_bg:getChildByName("icon")
    self.item_count_label = self.item_bg:getChildByName("count")

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
    self.buy_count:setString(self.num)
    self.min_btn = self.info_con:getChildByName("min_btn")
    self.max_btn = self.info_con:getChildByName("max_btn")
    self.total_price_title = self.info_con:getChildByName("total_price_title")
    self.total_price_title:setString(TI18N("总价："))
    self.total_price = self.info_con:getChildByName("total_price")
    self.buy_desc = self.main_container:getChildByName("buy_desc")
    self.buy_desc:setString("")
    -- self.tips_label = createLabel(22, 15, nil, 385, 277, TI18N('只能买这么多了'), self.main_container, nil, cc.p(0.5, 0.5))
    -- self.tips_label:setVisible(false)

    if self.show_type == 1 then
        self.title_label:setString(TI18N("购买"))
        self.ok_btn:setTitleText(TI18N("购买"))
        self.buy_count_title:setString(TI18N("购买数量："))
        self.tips_1:setString("")
        self.item_bg:setPosition(214, -16)
        self.less_time_label = createRichLabel(22, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 0.5), cc.p(214, 40),nil,nil,1000)
        self.item_con:addChild(self.less_time_label)

        self.limit_buy_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(434, 36) ,nil,nil,1000)
        self.main_container:addChild(self.limit_buy_label)

    else
        self.tips_1:setString(TI18N("可获得:"))
        self.title_label:setString(TI18N("放入物品"))
        self.ok_btn:setTitleText(TI18N("放入"))
        self.buy_count_title:setString(TI18N("放入数量："))
    end
end


function GuildmarketplaceBuyItemPanel:register_event()
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

--@setting
--setting.item_id --道具id (如果不是道具id 未支持)
--setting.item_count --道具数量
--setting.name 显示的名字 如果nil 默认道具名字
--setting.shop_type 商店类型 参考 MallConst.MallType 暂时没用
--setting.limit_num 限制数量 
--setting.price 物品价格
--setting.goods_id 商品id 发送协议需要
--setting.less_time 剩余时间 不填不显示
--setting.less_count 剩余时间对应的数量 不填不显示
--限购信息
--setting.limit_total_num = 限购最大数量
--setting.limit_day  每日限购数量
--setting.其他限购未加入
function GuildmarketplaceBuyItemPanel:openRootWnd(setting)
    if not setting then return end
    self.setting = setting
    local item_id = setting.item_id
    self.item_count = setting.item_count or 1
    local name = setting.name
    local shop_type = setting.shop_type
    self.price_item_id = setting.price_item_id 
    self.price_val = setting.price or 1

    self.goods_id = setting.goods_id
    self.less_time = setting.less_time
    self.less_count = setting.less_count

    self.limit_num = setting.limit_num or 1
    --公会宝库的放入和购买 策划要求最大100
    if self.limit_num > 100 then
        self.limit_num = 100
    end
    --
    if self.setting.limit_day and self.setting.limit_total_num then --每日限购
        if self.setting.limit_day == self.setting.limit_total_num then
            self.limit_num = 1
        else
            local limit_count = self.setting.limit_total_num - self.setting.limit_day
            if self.limit_num > limit_count then
                self.limit_num = limit_count
            elseif self.limit_num < 1 then
                self.limit_num = 1 
            end
        end
    end
    self.item_config = Config.ItemData.data_get_data(item_id)
    if self.item_config then
        self.goods_item:setData(self.item_config )
        -- 设置数量显示
        self.goods_item:setSelfNum(self.item_count)
        if name then
            self.name:setString(name) 
        else
            self.name:setString(self.item_config.name) 
        end
    else
        --icon 待写 暂时不支持不是item_id的显示.
        self.name:setString(name)
    end
    -- self:initShopTypeUI(shop_type)

    self:setCurUseItemInfoByNum(self.num, true)

    if self.price_item_id then
        self.item_bg:setVisible(true)
        if self.record_item_id == nil or self.record_item_id ~= self.price_item_id then
            self.record_item_id = self.price_item_id
            local config = Config.ItemData.data_get_data(self.price_item_id)
            if config then
                local head_icon = PathTool.getItemRes(config.icon, false)
                loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)
            end
        end
        self.item_count_label:setString(self.price_val)
    end

    --倒计时
    if self.less_time then
        local time = self.less_time - GameNet:getInstance():getTime()
        if time <= 0 then
            time = 0
        end
        commonCountDownTime(self.less_time_label, time, {callback = function(time) self:setTimeFormatString(time) end})
    end

    self:initLimitBuyInfo()
end
--限购信息
function GuildmarketplaceBuyItemPanel:initLimitBuyInfo()
    if not self.setting then return end
    if self.setting.limit_day then --每日限购
        local total_count = self.setting.limit_total_num or 0
        self.limit_buy_label:setString(string_format(TI18N("每日限购<div fontcolor=#249003>%s/%s</div>个"), self.setting.limit_day, total_count))
    end
end

function GuildmarketplaceBuyItemPanel:setTimeFormatString(time)
    local count = self.less_count or 1
    if time > 0 then
        local str = string_format(TI18N("%s个物品于<div fontcolor=#249003>%s</div>后过期"), count, TimeTool.GetTimeFormatDayIIIIII(time))
        self.less_time_label:setString(str)
    else
        local str = string_format(TI18N("%s个物品已过期"), count)
        self.less_time_label:setString(str)
    end
end

--根据不同商店类型不同ui调整
function GuildmarketplaceBuyItemPanel:initShopTypeUI(shop_type)
    if not shop_type then return end
    if shop_type == MallConst.MallType.TermBeginsBuy then --开学季提交试卷
        self.buy_count_title:setString(TI18N("提交数量:"))
        self.ok_btn:setTitleText(TI18N("提交"))
        self.title_label:setString(TI18N("提交试卷"))
    end
end

function GuildmarketplaceBuyItemPanel:onClickBtnClose()
    controller:openGuildmarketplaceBuyItemPanel(false)
end


function GuildmarketplaceBuyItemPanel:sendBuy()
    if not self.setting then return end
    if self.num > 0 then
        -- if self.setting.shop_type == MallConst.MallType.TermBeginsBuy then --开学季提交试卷
        --    ActiontermbeginsController:getInstance():sender26704(self.num)
        -- end
        if self.goods_id then
            if self.show_type  == 1 then 
                --购买
                controller:sender26902(self.goods_id, self.num * self.item_count)
            else
                --放入(出售)
                local storage
                if self.item_config.sub_type == BackPackConst.item_tab_type.EQUIPS or 
                    self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then
                    storage = BackPackConst.Bag_Code.EQUIPS
                else
                    storage = BackPackConst.Bag_Code.BACKPACK
                end
                controller:sender26901(self.goods_id, self.num * self.item_count, storage)
            end
        end
    end
    self:onClickBtnClose()
end

function GuildmarketplaceBuyItemPanel:setCurUseItemInfoByPercent(percent)
    local num = math.floor( percent * self.limit_num * 0.01 )
    self:setCurUseItemInfoByNum(num)
end

function GuildmarketplaceBuyItemPanel:setCurUseItemInfoByNum(num, not_check)
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
    self.total_price:setString(self.num * self.price_val)
end

function GuildmarketplaceBuyItemPanel:close_callback()
    if self.less_time_label then
        doStopAllActions(self.less_time_label) 
    end
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    controller:openGuildmarketplaceBuyItemPanel(false)
end