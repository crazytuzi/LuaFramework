-- --------------------------------------------------------------------
-- 市场主界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-04
-- --------------------------------------------------------------------
MarketMainWindow = MarketMainWindow or BaseClass(BaseView)

local role_vo = RoleController:getInstance():getRoleVo()
local controller = MarketController:getInstance()
local model = MarketController:getInstance():getModel()

function MarketMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full              	
    self.title_str = TI18N("市场")
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("market","market"), type = ResourcesType.plist },
        {path = PathTool.getEmptyMark(), type = ResourcesType.single },
    }
    self.tab_info_list = {
        {label=TI18N("金币市场"), index=MarketTabConst.gold_market, status=true},
        {label=TI18N("银币市场"), index=MarketTabConst.sliver_market, status=true},
        {label=TI18N("金币出售"), index=MarketTabConst.gold_sell, status=true},
        {label=TI18N("银币摆摊"), index=MarketTabConst.sliver_sell, status=true},
    }

    self.cur_index = nil

    self.sub_tab_list = {}
    self.cur_son_index = nil
    self.cur_son_tab = nil

    self.show_list = {}
    self.gold_market_list = {[0]=TI18N("全部"),[1]=TI18N("技能"),[2]=TI18N("高级技能"),[3]=TI18N("突破"),[4]=TI18N("其他")}
    self.sliver_market_list = {[0]=TI18N("古董"),[1]="",[2]="",[3]="",[4]=""}
end

function MarketMainWindow:open_callback()
    self.mail_root = createCSBNote(PathTool.getTargetCSB("market/market_main_window"))
    self.container:addChild(self.mail_root)
    self.main_container = self.mail_root:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    self.tab_container = self.main_container:getChildByName("tab_container")
    for i=0, 3 do
        local tab_btn = self.tab_container:getChildByName(string.format("guidesign_tab_btn_%s",i))
        tab_btn.label = tab_btn:getChildByName("title")
        tab_btn:setBright(false)
        tab_btn.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        tab_btn.index = i + 1
        self.sub_tab_list[tab_btn.index] = tab_btn
    end

    self.tab_bg = self.tab_container:getChildByName("tab_bg")
    self.scroll_con = self.main_container:getChildByName("scroll_con")
    self.title_con = self.scroll_con:getChildByName("title_con")
    local scroll_view_size = cc.size(self.scroll_con:getContentSize().width,590)
    self.setting1 = {
        item_class = GoldMarketItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = -5,                   -- y方向的间隔
        item_width = 622,               -- 单元的尺寸width
        item_height = 123,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = false
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scroll_con, cc.p(0,4) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, self.setting1)

    self.tips_btn = self.main_container:getChildByName("tips_btn")
    self.tips_btn:setTitleText(TI18N("帮助说明"))
    self.tips_btn.label = self.tips_btn:getTitleRenderer()
    if self.tips_btn.label ~= nil then
        self.tips_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end

    self.grounding_btn = self.main_container:getChildByName("grounding_btn")
    self.grounding_btn:setTitleText(TI18N("重新上架"))
    self.grounding_btn.label = self.grounding_btn:getTitleRenderer()
    if self.grounding_btn.label ~= nil then
        self.grounding_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

    self.get_btn = self.main_container:getChildByName("get_btn")
    self.get_btn:setTitleText(TI18N("一键领取"))
    self.get_btn.label = self.get_btn:getTitleRenderer()
    if self.get_btn.label ~= nil then
        self.get_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end
    self.refresh_btn = CustomButton.New(self.main_container, PathTool.getResFrame("common","common_1017"), nil, nil, LOADTEXT_TYPE_PLIST)
    self.refresh_btn:setSize(cc.size(158,64))
    self.refresh_btn:setPosition(550,self.tips_btn:getPositionY())

    self.refresh_time = self.main_container:getChildByName("refresh_time")

    self.sliver_sell_tips = self.main_container:getChildByName("sliver_sell_tips")

    self.scroll_con = self.main_container:getChildByName("scroll_con")
    self.title_con = self.scroll_con:getChildByName("title_con")
end

function MarketMainWindow:register_event()
    for k, tab_btn in pairs(self.sub_tab_list) do
        tab_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                if tab_btn.index ~= nil then
                    if tab_btn.can_touch == false then
                    else
                        self:changeSonTabView(tab_btn.index)
                    end   
                end
            end
        end)
    end

    if self.tips_btn then
        self.tips_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                MainuiController:getInstance():openCommonExplainView(true, Config.MarketGoldData.data_explain,TI18N("市场规则"))
            end
        end)
    end

    if self.refresh_btn then
        self.refresh_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.rest_time<=0 then
                    controller:sender23509(1)
                else
                    controller:sender23509(2)
                end
            end
        end)
    end

    if self.grounding_btn then
        self.grounding_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:sender23514(1)
            end
        end)
    end

    if self.get_btn then
        self.get_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:sender23514(2)
            end
        end)
    end

    --获取金币市场指定分类的数据
    if self.update_gold_market == nil then
        self.update_gold_market = GlobalEvent:getInstance():Bind(MarketEvent.Update_Gold_Category,function ( data )
            if self.cur_index == MarketTabConst.gold_market and self.cur_son_index == data.catalg then
                local list = model:getShowGoldShowList(data.catalg)
                self.title_con:setVisible(true)
                self.item_scrollview:resetSize(cc.size(self.scroll_con:getContentSize().width,590))
                self.item_scrollview:setData(list,function (  )
                        
                end,self.setting1)
                self:showEmpty(#list==0)
                self.show_list[data.catalg] = list
                
            end
        end)
    end
    	--银币市场购买返回
	if self.sliver_buy_event == nil then
		self.sliver_buy_event = GlobalEvent:getInstance():Bind(MarketEvent.Sliver_Market_Buy_Success,function ( data )
            if self.sliver_item == nil or self.sliver_item.data == nil then return end
            if self.sliver_item.data.id ~= data.id or self.sliver_item.data.type ~= data.type then return end
            self.sliver_item:updateSelfInfo(data.num, data.status)

            local item_base_id = self.sliver_item.data.item_base_id
            local item_list = self.item_scrollview:getItemList()
            if item_base_id and item_list and next(item_list) then
                for k, item in pairs(item_list) do
                    if item and item.data and item.data.item_base_id == item_base_id then
                        if item.checkNeedStatus then
                            item:checkNeedStatus()
                        end
                    end
                end
            end
            -- 更新成功之后,就移除掉当前这个对象
            self.sliver_item = nil
		end)
	end

    --获取银币市场物品
    if self.update_sliver_market == nil then
        self.update_sliver_market = GlobalEvent:getInstance():Bind(MarketEvent.Update_Sliver_Market,function ( data )
            if data == nil or data.data == nil then return end
            if self.cur_index == MarketTabConst.sliver_market then
                self.refresh_btn:setRichText(string.format(TI18N("<img src=%s scale=0.4 visible=true /><div outline=2,#c45a14>%s刷新</div>"),PathTool.getItemRes(Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.silver_coin).icon),Config.MarketSilverData.data_market_sliver_cost.silvermarket_cost.val),24,1)
                self:setLessTime(data.refresh_time-GameNet:getInstance():getTime())
                self.title_con:setVisible(false)
                local list = Config.MarketSilverData.data_market_sliver_cost.silvermarket_type.val
                if #list <= 1 then
                    self.tab_container:setVisible(false)
                    self.scroll_con:setContentSize(cc.size(self.item_scrollview:getContentSize().width,690))
                    self.scroll_con:setPositionY(790)
                    self.item_scrollview:resetSize(cc.size(self.item_scrollview:getContentSize().width,690))
                else
                    self.tab_container:setVisible(true)
                    self.scroll_con:setContentSize(cc.size(self.item_scrollview:getContentSize().width,634))
                    self.scroll_con:setPositionY(739)
                    self.item_scrollview:resetSize(cc.size(self.scroll_con:getContentSize().width,630))
                end
                -- 这个时候只需要取出第一个..
                local data_list = data.data[1]
                if data_list and data_list.goods then
                    local list = {}
                    for i,v in ipairs(data_list.goods) do
                        v.type = data_list.type
                        table.insert( list, v)
                    end
                    local function callback(cell)
                        self:clickSliverItem(cell)
                    end
                    self.item_scrollview:setData(list, callback, self.setting2)
                    self:showEmpty(#list==0)
                end
            end
        end)
    end

    --获取金币出售价格
    if self.update_gold_sell_price == nil then
        self.update_gold_sell_price = GlobalEvent:getInstance():Bind(MarketEvent.Gold_Sell_Price,function (  )
            if self.cur_son_index == nil then return end
            local list = model:getCanSellListII(self.cur_son_index - 1)
            self.item_scrollview:setData(list,function ( cell )
                controller:openBuyOrSellWindow(true,3,cell:getData())
            end,self.setting2)
            self:showEmpty(#list==0)
        end)
    end

    --金币出售 成功返回
    if self.update_gold_sell_num == nil then
        self.update_gold_sell_num = GlobalEvent:getInstance():Bind(MarketEvent.Gold_Sell_Success,function (  )
            if self.cur_son_index == nil then return end
            local temp = model:getCanSellList(self.cur_son_index - 1)
            local list = model:getCanSellListII(self.cur_son_index - 1)
            --Debug.info(list)
            self.item_scrollview:setData(list,function ( cell )
                controller:openBuyOrSellWindow(true,3,cell:getData())
            end,self.setting2)
        end)
    end

    --银币摊位数据
    if self.update_sliver_shop == nil then 
        self.update_sliver_shop = GlobalEvent:getInstance():Bind(MarketEvent.Sliver_Shop_Data,function (  )
            local list = model:getSliverShop()
            self.item_scrollview:setData(list,function ( cell )
                local data = cell:getData()
                if data.is_lock then --未解锁摊位
                    local cost = Config.MarketSilverData.data_shop_open[data.cell_id].loss[1][2]
                    local asset_id = Config.MarketSilverData.data_shop_open[data.cell_id].loss[1][1]
                    local str = string.format(TI18N("确定花费<img src=%s scale=0.3 visible=true />%s解锁新的摊位？"),PathTool.getItemRes(Config.ItemData.data_get_data(asset_id).icon),cost)
                    CommonAlert.show(str, TI18N("确定"), function (  )
                        controller:sender23512()
                    end, TI18N("取消"), nil, CommonAlert.type.rich)
                else
                    if data.is_free==0 then --空闲摊位
                        local list = model:getSliverGroundingItems()
                        controller:openSliverGroundingWindow(true,list,data.cell_id)
                    elseif data.is_free == 1 then --上架摊位
                        if data.status == 1 then --售罄
                            controller:sender23506(data.cell_id)
                        elseif data.status == 5 then --可领取
                            controller:sender23511(data.cell_id)
                        else
                            controller:openSliveSellWindow(true,data)
                        end
                    end
                end
            end,self.setting3)
        end)
    end
end

--- 点击银币市场上面的某个物品返回
function MarketMainWindow:clickSliverItem(cell)
    if cell == nil then return end
    self.sliver_item = cell
    local data = cell:getData()
    if data.status ~= 2 and data.num ~= 0 then
        local price_val = data.price or 0
        local coin = role_vo.silver_coin
        local can_buy_num = math.floor(coin / price_val)
        if can_buy_num < 1 then
            local config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.silver_coin)
            if config then
                BackpackController:getInstance():openTipsSource(true, config)
            end
        else
            controller:openBuyOrSellWindow(true, 2, cell:getData())
        end
    elseif data.status == 2 or data.num == 0 then
        message(TI18N("此物品已经卖完啦"))
    end
end

function MarketMainWindow:showEmpty( status)
    if self.no_image == nil then 
        self.no_image = createImage(self.scroll_con, PathTool.getEmptyMark(), self.scroll_con:getContentSize().width/2, self.scroll_con:getContentSize().height/2, cc.p(0.5,0.5), false)
        self.no_label = createLabel(22,58,nil,self.no_image:getContentSize().width/2,-10,TI18N("空空如也"),self.no_image,0, cc.p(0.5,0.5))
    end
    self.no_image:setVisible(status)
    if self.cur_index == MarketTabConst.sliver_market and status then
        if self.go_to_btn == nil then
            self.go_to_btn = createButton(self.scroll_con, TI18N("我要摆摊"), self.scroll_con:getContentSize().width/2, 190, 
                cc.size(158,64), PathTool.getResFrame("common","common_1017"), 24, Config.ColorData.data_color4[1])
        end
        self.go_to_btn:setVisible(status)
        self.go_to_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                self:setSelecteTab(4)
            end
        end)
    else
        if self.go_to_btn then
            self.go_to_btn:setVisible(false)
        end
    end
end

function MarketMainWindow:openRootWnd(index,sub_index,bid)
    index = index or 1
    self.show_sub_index = sub_index or 1 
    self.sub_index = sub_index or 1
    self.target_bid = bid
    self:setSelecteTab(index)
end

function MarketMainWindow:selectedTabCallBack(index)
	self.cur_index = index
    if self.cur_son_index then
        self.cur_son_index = nil
    end

    if index == MarketTabConst.gold_market then
        self.title_con:setVisible(true)
        self.scroll_con:setContentSize(cc.size(self.item_scrollview:getContentSize().width,634))
        self.scroll_con:setPositionY(739)
        self.item_scrollview:resetSize(cc.size(self.scroll_con:getContentSize().width,590))
        self.grounding_btn:setVisible(false)
        self.get_btn:setVisible(false)
        self.refresh_btn:setVisible(false)
        self.refresh_time:setVisible(false)
        self.sliver_sell_tips:setVisible(false)
    else
        self.title_con:setVisible(false)
        self.setting2 = {
            item_class = MarketItem,      -- 单元类
            start_x = 4,                  -- 第一个单元的X起点
            space_x = 2,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = -2,                   -- y方向的间隔
            item_width = 306,               -- 单元的尺寸width
            item_height = 143,              -- 单元的尺寸height
            row = 0,                        -- 行数，作用于水平滚动类型
            col = 2,                         -- 列数，作用于垂直滚动类型
            need_dynamic = false
        }
        self.scroll_con:setContentSize(cc.size(self.item_scrollview:getContentSize().width,634))
        self.scroll_con:setPositionY(739)
        self.item_scrollview:resetSize(cc.size(self.scroll_con:getContentSize().width,630))
        if index == MarketTabConst.sliver_sell then
            self.grounding_btn:setVisible(true)
            self.get_btn:setVisible(true)
            self.sliver_sell_tips:setVisible(true)
            self.refresh_btn:setVisible(false)
            self.refresh_time:setVisible(false)
        elseif index == MarketTabConst.gold_sell then
            self.grounding_btn:setVisible(false)
            self.get_btn:setVisible(false)
            self.sliver_sell_tips:setVisible(false)
            self.refresh_btn:setVisible(false)
            self.refresh_time:setVisible(false)
        elseif index == MarketTabConst.sliver_market then
            self.grounding_btn:setVisible(false)
            self.get_btn:setVisible(false)
            self.sliver_sell_tips:setVisible(false)
            self.refresh_btn:setVisible(true)
            self.refresh_time:setVisible(true)
            self.refresh_btn:setRichText(string.format(TI18N("<img src=%s scale=0.4 visible=true /><div outline=2,#c45a14>%s刷新</div>"),PathTool.getItemRes(Config.ItemData.data_get_data(1).icon),Config.MarketSilverData.data_market_sliver_cost.silvermarket_cost.val),24,1)
        end
    end

    if index == MarketTabConst.sliver_sell then
        self.tab_container:setVisible(false)
        self.title_con:setVisible(false)
        self:showEmpty(false)
        self.setting3 = {
            item_class = SliverSellItem,      -- 单元类
            start_x = 4,                  -- 第一个单元的X起点
            space_x = 2,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 306,               -- 单元的尺寸width
            item_height = 143,              -- 单元的尺寸height
            row = 0,                        -- 行数，作用于水平滚动类型
            col = 2,                         -- 列数，作用于垂直滚动类型
            need_dynamic = false
        }
        controller:sender23507()
    else
        if index == MarketTabConst.sliver_market then --银币市场
            local list = Config.MarketSilverData.data_market_sliver_cost.silvermarket_type.val
            local temp = {}
            for k,v in pairs(list) do
                temp[k] = v
            end
            for k,v in pairs(self.sub_tab_list) do
                --控制下显隐
                if temp[k] then
                    v:setVisible(true)
                    v.label:setString(self.sliver_market_list[k])
                    v.index = k
                else
                    v:setVisible(false)
                end
            end
            self.tab_bg:setContentSize(cc.size(119*(#list),self.tab_bg:getContentSize().height))

            if #list <= 1 then
                self.tab_container:setVisible(false)
                self.item_scrollview:resetSize(cc.size(self.item_scrollview:getContentSize().width,690))
            else
                self.tab_container:setVisible(true)
                self.item_scrollview:resetSize(cc.size(self.scroll_con:getContentSize().width,630))
            end
            self.sub_index = self.show_sub_index or 0
        elseif index == MarketTabConst.gold_sell then --金币出售有全部没其他
            local list = Config.MarketGoldData.data_market_gold_cost.market_type.val
            local temp = {}
            for k,v in pairs(list) do
                temp[k] = v
            end
            local num = 0
            for k,v in pairs(self.sub_tab_list) do
                if temp[k] >= 0 then
                    v:setVisible(true)
                    v.label:setString(self.gold_market_list[temp[k]])
                    v.index = k
                    num = num + 1
                else
                    v:setVisible(false)
                end
            end
            self.tab_container:setVisible(true)
            self.tab_bg:setContentSize(cc.size(119*(num),self.tab_bg:getContentSize().height))
            self.sub_index = self.show_sub_index or 0
        elseif index == MarketTabConst.gold_market then --金币市场标签页没有全部有其他
            local list = {1,2,3,4}
            local num = 0
            for k,v in pairs(self.sub_tab_list) do
                if list[k] >= 0 then
                    v:setVisible(true)
                    v.label:setString(self.gold_market_list[list[k]])
                    v.index = k
                    num = num + 1
                else
                    v:setVisible(false)
                end
            end
            self.tab_container:setVisible(true)
            self.tab_bg:setContentSize(cc.size(119*(num),self.tab_bg:getContentSize().height))
            self.sub_index = self.show_sub_index or 1
        end
        
        self:refreshSonTabPos()
        self:changeSonTabView(self.sub_index)
    end
end

-- 动态调整二级标签页的位置
function MarketMainWindow:refreshSonTabPos(  )
    local tabBgPosX = 5
    local firstTabPosX = 69
    local tabWidth = 117
    local tempTabList = {}
    local num = 0
    for i,tab in ipairs(self.sub_tab_list) do
        if tab:isVisible() then
            num = num + 1
            table.insert(tempTabList, tab)
        end
    end
    firstTabPosX = firstTabPosX + (4-num)*tabWidth/2
    tabBgPosX = tabBgPosX + (4-num)*tabWidth/2
    for i,tab in ipairs(tempTabList) do
        tab:setPositionX(firstTabPosX+(i-1)*tabWidth)
    end
    self.tab_bg:setPositionX(tabBgPosX)
end

--子标签
function MarketMainWindow:changeSonTabView( index )
    if self.cur_son_index == index then return end
    if self.cur_son_tab ~= nil then
        self.cur_son_tab.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
        self.cur_son_tab:setBright(false)
    end

    self.cur_son_index = index

    if self.cur_index == MarketTabConst.gold_market then 
        self.cur_son_tab = self.sub_tab_list[self.cur_son_index]
    else
        self.cur_son_tab = self.sub_tab_list[self.cur_son_index]
    end
    if self.cur_son_tab ~= nil then
        self.cur_son_tab.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.cur_son_tab:setBright(true)
    end
    if self.cur_index == MarketTabConst.gold_market then --金币市场
        controller:sender23520()
        controller:sender23500(self.cur_son_index)
    elseif self.cur_index == MarketTabConst.sliver_market then --银币市场
        controller:sender23509(3)
    elseif self.cur_index == MarketTabConst.gold_sell then --金币出售
        local list = model:getCanSellList(self.cur_son_index - 1)
        local target = {}
        for k,v in pairs(list) do
            table.insert(target,{base_id = v.base_id})
        end
        controller:sender23516(target)
    end
end

--设置倒计时
function MarketMainWindow:setLessTime( less_time )
    if tolua.isnull(self.refresh_time) then return end
    self.refresh_time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.refresh_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.refresh_time:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end)
        )))
    else
        self:setTimeFormatString(less_time)
    end
end

function MarketMainWindow:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.refresh_time:setString(string.format(TI18N("下次刷新：%s"),TimeTool.GetTimeFormat(time)))
    else
        self.refresh_btn:setRichText(string.format(TI18N("<div outline=2,#c45a14>免费刷新</div>")),24,1)
        self.refresh_time:setString("")
    end
end

--返回大标签
function MarketMainWindow:getCurIndex(  )
    return self.cur_index or 1 
end
--返回子标签
function MarketMainWindow:getCurSonIndex(  )
    return self.cur_son_index or 1 
end

function MarketMainWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	if self.sliver_buy_event then 
        GlobalEvent:getInstance():UnBind(self.sliver_buy_event)
        self.sliver_buy_event = nil
    end

    if self.update_gold_market then 
        GlobalEvent:getInstance():UnBind(self.update_gold_market)
        self.update_gold_market = nil
    end

    if self.update_sliver_market then 
        GlobalEvent:getInstance():UnBind(self.update_sliver_market)
        self.update_sliver_market = nil
    end

    if self.update_gold_sell_price then 
        GlobalEvent:getInstance():UnBind(self.update_gold_sell_price)
        self.update_gold_sell_price = nil
    end

    if self.update_gold_sell_num then 
        GlobalEvent:getInstance():UnBind(self.update_gold_sell_num)
        self.update_gold_sell_num = nil
    end

    if self.update_sliver_shop then 
        GlobalEvent:getInstance():UnBind(self.update_sliver_shop)
        self.update_sliver_shop = nil
    end

	controller:openMainWindow(false)
end