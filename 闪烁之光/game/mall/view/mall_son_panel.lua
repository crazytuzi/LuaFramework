-- --------------------------------------------------------------------
-- 竖版商城子商城
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-5-10
-- --------------------------------------------------------------------
MallSonPanel = class("MallSonPanel", function()
    return ccui.Widget:create()
end)

local treasure_type = 16 --针对探宝的
function MallSonPanel:ctor()
	self.ctrl = MallController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
	self.tab_list = {}
	self.cur_index = nil
	self.cur_tab = nil
    self.data_list = {}
	self:createRootWnd()
	self:configUI()
	self:register_event()
end

function MallSonPanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/mall_son_panel"))
	self.root_wnd:setPosition(40,103)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
end

function MallSonPanel:configUI()
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.tab_container = self.main_container:getChildByName("tab_container")
	for i=1, 5 do
        local tab_btn = self.tab_container:getChildByName(string.format("tab_btn_%s",i))
        tab_btn.label = self.tab_container:getChildByName("title_"..i)
        tab_btn.label:setColor(cc.c3b(0xcf,0xb5,0x93))
        tab_btn:setBright(false)
        tab_btn.index = i
        tab_btn.is_first = true
        self.tab_list[i] = tab_btn
    end

    self.refresh_panel = self.main_container:getChildByName("refresh_panel")
	self.refresh_panel:setVisible(false)
    self.btn_refresh = self.refresh_panel:getChildByName("btn_refresh")
    self.btn_refresh:setPositionY(self.btn_refresh:getPositionY()+6)
    self.refresh_time = self.refresh_panel:getChildByName("refresh_time")
    --self.refresh_time:setPositionY(self.refresh_time:getPositionY()+6)
    self.refresh_time:setString("")

    local config = Config.ExchangeData.data_shop_list[treasure_type]
    local Sprite_1 = self.btn_refresh:getChildByName("Sprite_1")
    Sprite_1:setScale(0.5)
    loadSpriteTexture(Sprite_1, PathTool.getItemRes(Config.ItemData.data_get_data(config.item_bid).icon), LOADTEXT_TYPE)
    local Text_1 = self.btn_refresh:getChildByName("Text_1")
    Text_1:setString(config.cost_list[1][2]..TI18N(" 刷新"))

    self.scrollCon = self.main_container:getChildByName("scrollCon")
    self.coin = self.main_container:getChildByName("coin")
    self.coin:setPositionY(self.coin:getPositionY()+4)
    self.count = self.main_container:getChildByName("count")
    self.count:setPositionY(self.count:getPositionY()+4)
    self.add_btn = self.main_container:getChildByName("add_btn")
    self.add_btn:setVisible(false)
    local scroll_view_size = cc.size(622,648)
    local setting = {
        item_class = MallItem,      -- 单元类
        start_x = 4.5,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 2,                   -- y方向的间隔
        item_width = 306,               -- 单元的尺寸width
        item_height = 143,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 2                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scrollCon, cc.p(0,8) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function MallSonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function MallSonPanel:setList( list )  
    local notice_list = {[5]=Config.ExchangeData.data_shop_exchage_cost.open_guild_lev.desc,
                         [16]=Config.ExchangeData.data_shop_exchage_cost.open_arena_cent_lev.desc,
                         [6]=Config.ExchangeData.data_shop_exchage_cost.open_arena_cent_lev.desc,
                        }
    
    for k,v in pairs(self.tab_list) do
    	if list[k] then
    		v:setVisible(true)
    		v.label:setString(Config.ExchangeData.data_shop_list[list[k]].name)
    		v.type = list[k]
            v.notice = notice_list[v.type]
            self:setTabBtnTouchStatus(self:checkBtnIsOpen(v.type),k)
    	else
    		v:setVisible(false)
    	end
    end

    local select_index = 1
    for i=1,#list do
        if self:checkBtnIsOpen(self.tab_list[i].type) then
            select_index = i
            break
        end
    end
end

function MallSonPanel:register_event()
	for k, tab_btn in pairs(self.tab_list) do
        registerButtonEventListener(tab_btn, function()
            if tab_btn.type ~= nil then
                if tab_btn.can_touch == false then
                    message(TI18N(tab_btn.notice))
                else
                    self:changeTabView(tab_btn.index)
                end   
            end
        end ,false, 1)
    end

    registerButtonEventListener(self.add_btn, function()
        local item_bid = Config.ExchangeData.data_shop_list[self.cur_tab.type].item_bid
        local data = Config.ItemData.data_get_data(item_bid)
        BackpackController:getInstance():openTipsSource( true, data )
    end ,true, 1)

    --获取商品已购买次数(限于购买过的有限购的商品)
    if not self.update_have_count then
        self.update_have_count = GlobalEvent:getInstance():Bind(MallEvent.Open_View_Event,function ( data )
            if not data then return end
            if self.cur_index ~= 4 then
                if self.cur_tab.type == data.type  then
                    local list = self:getConfig(self.cur_tab.type,data)
                    self.data_list[self.cur_index] = list
                    self.item_scrollview:setData(self.data_list[self.cur_index],function ( cell )
                        self.ctrl:openMallBuyWindow(true,cell:getData())
                    end)
                else
                    for k,v in pairs(self.tab_list) do
                        if v.type == data.type then
                            local list = self:getConfig(self.cur_tab.type,data)
                            self.data_list[k] = list
                        end
                    end
                end
            end
        end)
    end

    if self.role_vo then
        if self.role_update_lev_event == nil then
            self.role_update_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                if key == "lev" then
                    for k,v in pairs(self.tab_list) do
                        self:setTabBtnTouchStatus(self:checkBtnIsOpen(v.type),k)
                    end
                elseif key == "gsrv_id" or key == "gid" then
                    self:setTabBtnTouchStatus(self:checkBtnIsOpen(5),1)
                elseif key == "gold" or key == "arena_cent" or key == "guild" or key == "hero_soul" or key == "friend_point" or 
                       key == "arena_guesscent" or key == "star_point" or key == "expedition_medal" or key == "elite_coin" then
                    local item_bid = Config.ExchangeData.data_shop_list[self.cur_tab.type].item_bid
                    if Config.ItemData.data_assets_id2label[item_bid] == key then
                        loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(item_bid).icon), LOADTEXT_TYPE)
                        if self.cur_index == 4 then
                            self.count:setString(MoneyTool.GetMoneyString(self.role_vo.star_point))
                        else
                            if self.cur_index == 1 then
                                self.count:setString(MoneyTool.GetMoneyString(self.role_vo.expedition_medal))
                            elseif self.cur_index == 5 then
                                self.count:setString(MoneyTool.GetMoneyString(self.role_vo.elite_coin))
                            else
                                self.count:setString(MoneyTool.GetMoneyString(self.role_vo[Config.ItemData.data_assets_id2label[item_bid]]))
                            end
                        end
                    end
                end
            end)
        end
    end

    --除神秘神格商城以外的购买成功
    if not self.buy_success_event then
        self.buy_success_event = GlobalEvent:getInstance():Bind(MallEvent.Buy_Success_Event,function ( data )
            if self.cur_index and self.data_list and self.data_list[self.cur_index] then
                for k,v in pairs(self.data_list[self.cur_index]) do
                    if type(v) ~= "number" then
                        if v and v.id and v.has_buy then
                            if v.id == data.eid and next(data.ext or {}) ~= nil then
                                v.has_buy = data.ext[1].val
                            end
                        end
                    end
                end
            end
        end)
    end

----------------------------------------------
    registerButtonEventListener(self.btn_refresh, function()
        local list =  Config.ExchangeData.data_shop_list[treasure_type].cost_list
        if self.role_vo.star_point >= list[1][2] then
            self.ctrl:sender13405(treasure_type)
        else
            message(TI18N("探宝积分不足"))
            BackpackController:getInstance():openTipsSource(true, 18)
        end
    end ,true, 1)

    if not self.update_son_list then
        self.update_son_list = GlobalEvent:getInstance():Bind(MallEvent.Get_Buy_list,function ( data )
            if data.type == treasure_type then

                self:setLessTime( data.refresh_time - GameNet:getInstance():getTime())

                for k,v in pairs(data.item_list) do
                    v.shop_type = treasure_type
                end
                self.data_list[self.cur_index] = data

                self.item_scrollview:setData(self.data_list[self.cur_index].item_list,function ( cell )
                    self.ctrl:openMallBuyWindow(true,cell:getData())
                end)
            end
        end)
    end
end

--设置倒计时
function MallSonPanel:setLessTime( less_time )
    if tolua.isnull(self.refresh_time) then return end
    doStopAllActions(self.refresh_time)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.refresh_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.refresh_time)
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function MallSonPanel:setTimeFormatString(time)
    if time > 0 then
        self.refresh_time:setString(TimeTool.GetTimeFormat(time))
    else
        self.refresh_time:setString("00:00:00")
    end
end

function MallSonPanel:changeTabView( index )
	if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setColor(cc.c3b(0xcf,0xb5,0x93))
        self.cur_tab:setBright(false)
    end

    self.cur_index = index
    self.cur_tab = self.tab_list[self.cur_index]

    if self.cur_tab ~= nil then
        self.cur_tab.label:setColor(cc.c3b(0xff,0xed,0xd6))
        self.cur_tab:setBright(true)
    end

    if self.cur_index == 4 then
        self.refresh_panel:setVisible(true)
    else
        self.refresh_panel:setVisible(false)
    end
    if self.cur_tab.is_first then  --避免频繁请求
        self.ctrl:sender13401(self.cur_tab.type)
        self.cur_tab.is_first = false
    else
        if self.cur_index ~= 4 then
            self.item_scrollview:setData(self.data_list[self.cur_index],function ( cell )
                self.ctrl:openMallBuyWindow(true,cell:getData())
            end)
        end
    end

    if self.cur_index == 4 then
        self.item_scrollview:setData({})
        self.ctrl:sender13403(treasure_type)
    end
    
    local item_bid = Config.ExchangeData.data_shop_list[self.cur_tab.type].item_bid
    if item_bid then
        if self.cur_index == 4 then
            local item_bid = Config.ExchangeData.data_shop_list[treasure_type].item_bid
            loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(item_bid).icon), LOADTEXT_TYPE)
            self.count:setString(self.role_vo.star_point)
        else
            loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(item_bid).icon), LOADTEXT_TYPE)
            if self.cur_index == 1 then
                self.count:setString(MoneyTool.GetMoneyString(self.role_vo.expedition_medal))
            elseif self.cur_index == 5 then
                self.count:setString(MoneyTool.GetMoneyString(self.role_vo.elite_coin))
            else
                self.count:setString(MoneyTool.GetMoneyString(self.role_vo[Config.ItemData.data_assets_id2label[item_bid]]))    
            end
        end
    end
end

--根据商城类型打开
function MallSonPanel:openById( id  )
    for k,v in pairs(self.tab_list) do
        if v.type == id then
            self.cur_index = nil
            self:changeTabView(v.index)
            return
        end
    end
end

function MallSonPanel:getConfig( index,data)
	local config = {}
	local list = {}
    
	if index == 5 then
		config = deepCopy(Config.ExchangeData.data_shop_exchage_guild)
	elseif index == 6 then
		config = deepCopy(Config.ExchangeData.data_shop_exchage_arena)
	elseif index == 7 then
		config = deepCopy(Config.ExchangeData.data_shop_exchage_boss)
	elseif index == 8 then
		config = deepCopy(Config.ExchangeData.data_shop_exchage_expediton)
    elseif index == 16 then --探宝
		config = deepCopy(Config.ExchangeData.data_shop_exchage_guess)
    elseif index == 17 then --精英段位赛
        config = deepCopy(Config.ExchangeData.data_shop_exchage_elite)
	end

    local list = deepCopy(data.item_list)
    local show_list = {}
    for a,j in pairs(config) do
        if j.type == self.cur_tab.type then
            if list and next(list) then
                for k,v in pairs(list) do --已经买过的限购物品
                    if j.id == v.item_id then
                        if v.ext[1].val then --不管是什么限购 赋值已购买次数就好了。。
                            j.has_buy = v.ext[1].val
                            table.remove(list,k)
                        end
                        break
                    else
                        j.has_buy = 0
                    end
                end
            else
                j.has_buy = 0
            end
            if j.open_srv_timestamp and j.open_srv_timestamp ~= 0 then  --竞技商店老服去掉周限购
                local openServerTime = InviteCodeController:getInstance():getModel():getOpenServerTime()
                if openServerTime <= j.open_srv_timestamp then
                    if j["limit_week"] and j.limit_week ~= 0 then
                        j.limit_week = 0
                    end
                end
            end
            local is_show = true
            if self.role_vo then
                is_show = self:checkShowLev(j.role_lev)
            end
            if is_show then
                table.insert(show_list,j)
            end
        end
    end
	return show_list
end

function MallSonPanel:checkShowLev(role_lev)
    if role_lev ~= nil and next(role_lev) ~= nil then
        for i,v in ipairs(role_lev) do
            if v[1] == "lv" then
                if self.role_vo.lev and self.role_vo.lev < v[2] then
                    return false
                end
            end
        end
    end
    return true
end

--判断是否开启按钮
function MallSonPanel:checkBtnIsOpen( type )
    if type == 5 then --公会
        if self.role_vo.lev>=Config.ExchangeData.data_shop_exchage_cost.open_guild_lev.val and self.role_vo:isHasGuild() then
            return true
        else
            return false
        end
    elseif type == 6 or type == 16 then --竞技
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
        if build_vo and build_vo.is_lock then 
            return false
        else
            return true
        end
    elseif type == 7 then --boss
        if self.role_vo.lev>=Config.ExchangeData.data_shop_exchage_cost.open_god_point_lev.val then
            return true
        else
            return false
        end
    end
    return true
end

--设置按钮是否变灰
function MallSonPanel:setTabBtnTouchStatus(status, index)
    local tab_btn = self.tab_list[index]
    if tab_btn then
        if status == true then
            setChildUnEnabled(false, tab_btn)
            tab_btn.label:setColor(cc.c3b(0xcf,0xb5,0x93))
            tab_btn.label:enableOutline(cc.c4b(0x2A,0x16,0x0E,0xff), 2)
        else
            setChildUnEnabled(true, tab_btn)
            tab_btn.label:setColor(cc.c3b(0xd8,0xd7,0xd7))
            tab_btn.label:enableOutline(cc.c4b(0x40,0x40,0x40,0xff), 2)
        end       
        tab_btn.can_touch = status
    end
end

function MallSonPanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    
    if self.update_have_count then 
        GlobalEvent:getInstance():UnBind(self.update_have_count)
        self.update_have_count = nil
    end

    if self.update_son_list then 
        GlobalEvent:getInstance():UnBind(self.update_son_list)
        self.update_son_list = nil
    end
    if self.buy_success_event then 
        GlobalEvent:getInstance():UnBind(self.buy_success_event)
        self.buy_success_event = nil
    end
    
    if self.role_vo then
        if self.role_update_lev_event then
            self.role_vo:UnBind(self.role_update_lev_event)
            self.role_update_lev_event = nil
        end
        self.role_vo = nil
    end
    doStopAllActions(self.refresh_time)
end
