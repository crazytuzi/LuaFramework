--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 活动结束警告
-- @DateTime:    2019-05-27 19:59:33
-- *******************************
OrderActionEndWarnWindow = OrderActionEndWarnWindow or BaseClass(BaseView)

local controller = OrderActionController:getInstance()

function OrderActionEndWarnWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG     
    self.layout_name = "orderaction/orderaction_end_warn_window"
end
function OrderActionEndWarnWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:getChildByName("Image_16"):getChildByName("Text_15"):setString(TI18N("活动提醒"))
    self.btn_close = main_container:getChildByName("btn_close")
    self.btn_ok = main_container:getChildByName("btn_ok")
    self.btn_ok:getChildByName("Text_14"):setString(TI18N("我知道了"))
    local str = TI18N("花火映秋")
    local cur_period = OrderActionController:getInstance():getModel():getCurPeriod()
    if cur_period == 7 then
        str = TI18N("奇妙之夜")
    elseif cur_period == 8 then
        str = TI18N("雪舞冬季")
    elseif cur_period == 9 then
        str = TI18N("岁初礼赞")
    elseif cur_period == 10 then
        str = TI18N("踏雪拾春")
    end
    local str_warn = string.format(TI18N("                %s活动将于          后结束\n活动结束后，累积等级、任务进度及经验将会清\n除，请及时完成试炼任务，领取相应奖励，以免\n错过奖励哦！"),str) 
    main_container:getChildByName("desc_text"):setString(str_warn)
    self.reamin_day = main_container:getChildByName("reamin_day")
end

function OrderActionEndWarnWindow:register_event()
	registerButtonEventListener(self.background, function()
        controller:openEndWarnView(false)
    end,false, 2)
    registerButtonEventListener(self.btn_close, function()
        controller:openEndWarnView(false)
    end,true, 2)
    registerButtonEventListener(self.btn_ok, function()
        controller:openEndWarnView(false)
    end,true, 1)
end

function OrderActionEndWarnWindow:openRootWnd(day)
	day = day or 0
	local str = ""
    local cur_period = OrderActionController:getInstance():getModel():getCurPeriod()
	local remain_day = 30 - day
    if cur_period == 10 then
        remain_day = 29 - day
    end
	if remain_day <= 0 then
		remain_day = 0
		str = TI18N("今天")
    else
        str = remain_day..TI18N("天")    
	end
	self.reamin_day:setString(str)
end
function OrderActionEndWarnWindow:close_callback()

	controller:openEndWarnView(false)
end