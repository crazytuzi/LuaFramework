-- --------------------------------------------------------------------
-- 点金兑换
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ExchangeWindow = ExchangeWindow or BaseClass(BaseView)

local table_sort = table.sort
local string_format = string.format
local game_net = GameNet:getInstance()
local controller = ExchangeController:getInstance()
function ExchangeWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "exchange/exchange_main_win"       	
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("exchange","exchange"), type = ResourcesType.plist },
    }
end

function ExchangeWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)

    local bg = main_container:getChildByName("bg")
    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_65")
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
    self.btn_tips = main_container:getChildByName("btn_tips")
    self.object = {}
    local pos = {110,320,532}
    for i=1,3 do
    	local tab = {}
    	tab.btn = main_container:getChildByName("btn_"..i)
    	tab.get = main_container:getChildByName("get_"..i)
    	tab.get:setVisible(false)
    	tab.remain = main_container:getChildByName("remain_text_"..i)
    	tab.price = createRichLabel(22, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(tab.btn:getContentSize().width/2,tab.btn:getContentSize().height/2), nil, nil, nil)
    	tab.btn:addChild(tab.price)
    	tab.gold = createRichLabel(22, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(pos[i],325), nil, nil, nil)
        main_container:addChild(tab.gold)
        local tips_bg = main_container:getChildByName("tips_bg_"..i)
        tab.tips = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5,0.5), cc.p(90,50), 5, nil, nil)
        tips_bg:addChild(tab.tips)
    	self.object[i] = tab
    end
    self.textTime = main_container:getChildByName("textTime")
    main_container:getChildByName("Text_1"):setString(TI18N("刷新时间:"))
end

function ExchangeWindow:openRootWnd()
	controller:send23606()
end

function ExchangeWindow:register_event()
	registerButtonEventListener(self.background, function()
        controller:openExchangeMainView(false)
    end, false, 2)

	for i, v in pairs(self.object) do
		registerButtonEventListener(v.btn, function()
        	if self.exchange_data then
        		controller:send23607(self.exchange_data[i].id)
        	end
    	end, true, 1)
	end

	self:addGlobalEvent(ExchangeEvent.Extra_Reward, function(data)
		self:getUpdataRewardItem(data)
	end)
    registerButtonEventListener(self.btn_tips, function(param,sender, event_type)
        local config = Config.MiscData.data_const.touch_gold_tips.desc
        TipsManager:getInstance():showCommonTips(config, sender:getTouchBeganPosition(),nil,nil,550)
    end, false, 1)
end

function ExchangeWindow:getUpdataRewardItem(data)
    if not data then return end
    local time = data.ref_time - game_net:getTime()
    self:setLessTime(time)

    if not data.list then return end
    table_sort(data.list, function(a, b) 
        return a.id < b.id
    end)
    self.exchange_data = data.list
    local exchange_cfg =  Config.ConvertData.data_exchange[data.camp_type]
    for i,v in pairs(data.list) do
        local times = v.max - v.num
        if times < 0 then times = 0 end
        self.object[i].remain:setString(TI18N("剩余:  ")..times)

        local item_config = Config.ItemData.data_get_data(2)
        local res = PathTool.getItemRes(item_config.icon)
        local str = string_format("<img src=%s visible=true scale=0.30 /> <div> %d</div>", res, v.gain)
        self.object[i].gold:setString(str)
        
        
        if exchange_cfg and exchange_cfg[v.id] then
            local time_num = exchange_cfg[v.id].time/60
            local common_2034_res =  PathTool.getResFrame("common", "common_2034")
            self.object[i].tips:setString(string_format(TI18N("挂机<div fontcolor=#249003>%.1f</div>小时收益"),time_num))
        end
        if times <= 0 then
            self.object[i].btn:setVisible(false)
            self.object[i].get:setVisible(true)
        else
            self.object[i].btn:setVisible(true)
            self.object[i].get:setVisible(false)
            local str = ""
            if v.price == 0 then
                str = string_format(TI18N("<div shadow=0,-2,2,#854000>免费获取</div>"))
            else
                local item_config = Config.ItemData.data_get_data(3)
                local res = PathTool.getItemRes(item_config.icon)
                str = string_format(TI18N("<img src=%s visible=true scale=0.30 />   <div shadow=0,-2,2,#854000>%d获取</div>"), res, v.price)
            end
            self.object[i].price:setString(str)
        end
    end
end

--设置倒计时
function ExchangeWindow:setLessTime(less_time)
    if tolua.isnull(self.textTime) then return end
    self.textTime:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.textTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.textTime:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end
function ExchangeWindow:setTimeFormatString(time)
    if time > 0 then
        self.textTime:setString(TimeTool.GetTimeFormat(time))
    else
        self.textTime:setString("00:00:00")
    end
end

function ExchangeWindow:close_callback()	
	if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    doStopAllActions(self.textTime)
	controller:openExchangeMainView(false)
end