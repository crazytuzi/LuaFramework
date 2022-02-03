--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com
-- @description: 活动结束警告
-- @DateTime:    2020-02-20
-- *******************************
NewOrderActionEndWarnWindow = NewOrderActionEndWarnWindow or BaseClass(BaseView)

local controller = NeworderactionController:getInstance()

function NewOrderActionEndWarnWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "neworderaction/neworderaction_end_warn_window"
end

function NewOrderActionEndWarnWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    main_container:getChildByName("Image_16"):getChildByName("Text_15"):setString(TI18N("活动提醒"))
    self.btn_close = main_container:getChildByName("btn_close")
    self.btn_ok = main_container:getChildByName("btn_ok")
    self.btn_ok:getChildByName("Text_14"):setString(TI18N("我知道了"))
    self.btn_unlock = main_container:getChildByName("btn_unlock")
    self.btn_unlock:getChildByName("label"):setString(TI18N("前往解锁"))
    local str_warn = string.format(TI18N("当前周期剩余天数：\n活动周期重置后，累计等级、任务进度经验将会\n清除，请尽快完成任务领取奖励哦！"))
    main_container:getChildByName("desc_text"):setString(str_warn)
    self.reamin_day = main_container:getChildByName("reamin_day")
end

function NewOrderActionEndWarnWindow:register_event()
    registerButtonEventListener(
        self.background,
        function()
            controller:openEndWarnView(false)
        end,
        false,
        2
    )
    registerButtonEventListener(
        self.btn_close,
        function()
            controller:openEndWarnView(false)
        end,
        true,
        2
    )
    registerButtonEventListener(
        self.btn_ok,
        function()
            controller:openEndWarnView(false)
        end,
        true,
        1
    )
    registerButtonEventListener(
        self.btn_unlock,
        function()
            controller:openEndWarnView(false)
            controller:openBuyCardView(true)
        end,
        true,
        1
    )
end

function NewOrderActionEndWarnWindow:openRootWnd(day)
    day = day or 0
    local str = ""
    local remain_day = 30 - day
    -- if remain_day <= 0 then
    -- 	remain_day = 0
    -- 	str = TI18N("今天")
    -- else
    str = remain_day .. TI18N("天")
    -- end
    self.reamin_day:setString(str)
end
function NewOrderActionEndWarnWindow:close_callback()
    controller:openEndWarnView(false)
end
