--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 活动结束警告
-- @DateTime:    2019-11-25 9:45:33
-- *******************************
ElitematchOrderActionEndWarnWindow = ElitematchOrderActionEndWarnWindow or BaseClass(BaseView)

local controller = ElitematchController:getInstance()

function ElitematchOrderActionEndWarnWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG     
    self.layout_name = "elitematch/elitematch_orderaction_end_warn_window"
end
function ElitematchOrderActionEndWarnWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_container:getChildByName("Image_16"):getChildByName("Text_15"):setString(TI18N("活动提醒"))
    self.Image_23 = self.main_container:getChildByName("Image_23")
    self.Image_15 = self.main_container:getChildByName("Image_15")
    self.btn_close = self.main_container:getChildByName("btn_close")
    self.btn_ok = self.main_container:getChildByName("btn_ok")
    self.btn_ok:getChildByName("Text_14"):setString(TI18N("我知道了"))
    
    self.desc_text = createRichLabel(26, cc.c4b(64,32,23,255), cc.p(0.5, 1), cc.p(323.5, 341),nil,nil,548)
    self.main_container:addChild(self.desc_text)
    
end

function ElitematchOrderActionEndWarnWindow:register_event()
	registerButtonEventListener(self.background, function()
        controller:openElitematchEndWarnView(false)
    end,false, 2)
    registerButtonEventListener(self.btn_close, function()
        controller:openElitematchEndWarnView(false)
    end,true, 2)
    registerButtonEventListener(self.btn_ok, function()
        controller:openElitematchEndWarnView(false)
    end,true, 1)
end

function ElitematchOrderActionEndWarnWindow:openRootWnd(day)
	day = day or 0
	local str = ""
	local remain_day = 30 - day
	if remain_day <= 0 then
		remain_day = 0
		str = TI18N("今天")
    else
        str = remain_day..TI18N("天")    
    end
    local config = Config.ArenaEliteWarOrderData.data_constant
    if config then
        local config_desc = config.warn_desc
        local str_warn = string.format(config_desc.desc,str) 
        self.desc_text:setString(str_warn)
    end
    local height = self.desc_text:getContentSize().height
    local temp_height = 234.00
    if height > temp_height then
        temp_height = height+30
    end
    self.Image_15:setContentSize(cc.size(647,temp_height+166))
    self.Image_23:setContentSize(cc.size(593.00,temp_height))
    self.btn_ok:setPositionY(61.00+234-temp_height)
end
function ElitematchOrderActionEndWarnWindow:close_callback()

	controller:openElitematchEndWarnView(false)
end