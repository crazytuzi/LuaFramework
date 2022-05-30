-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      手机认真窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
CertifyBindPhoneWindow = CertifyBindPhoneWindow or BaseClass(BaseView) 

local controller = WelfareController:getInstance()
function CertifyBindPhoneWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "welfare/certify_bind_phone_window"
end

function CertifyBindPhoneWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel, 2)
    local title_container = main_panel:getChildByName("title_container")
    title_container:getChildByName("title_label"):setString(TI18N("手机号绑定"))

    main_panel:getChildByName("txt1"):setString(TI18N("手机号："))
    main_panel:getChildByName("txt2"):setString(TI18N("验证码："))

    self.ok_btn = main_panel:getChildByName("ok_btn")
    self.ok_btn:getChildByName("label"):setString(TI18N("确定"))

    self.send_btn = main_panel:getChildByName("send_btn")
    self.send_btn_label = self.send_btn:getChildByName("label")
    self.send_btn_label:setString(TI18N("发送验证码"))

    self.phone_box = createEditBox(main_panel, PathTool.getResFrame("mainui", "mainui_chat_input_bg"), cc.size(423,50), Config.ColorData.data_color4[66], 20, 
        Config.ColorData.data_color3[151], 20, TI18N("请输入手机号"), cc.p(196, 249), 11, LOADTEXT_TYPE_PLIST, cc.EDITBOX_INPUT_MODE_PHONENUMBER) 
    self.phone_box:setAnchorPoint(cc.p(0,0.5))

    self.certify_box = createEditBox(main_panel, PathTool.getResFrame("mainui", "mainui_chat_input_bg"), cc.size(240,50), Config.ColorData.data_color4[66], 20, 
        Config.ColorData.data_color3[151], 20, TI18N(""), cc.p(196, 162), 11, LOADTEXT_TYPE_PLIST) 
    self.certify_box:setAnchorPoint(cc.p(0,0.5))
end

function CertifyBindPhoneWindow:register_event()
    registerButtonEventListener(self.background, function() 
		WelfareController:getInstance():openCertifyBindPhoneWindow(false)
    end, false, 2) 

    registerButtonEventListener(self.ok_btn, function() 
        self:sendBindPhone()
    end, true, 1) 
    registerButtonEventListener(self.send_btn, function() 
        self:requestCertifyNumber()
    end, true, 1) 

    self:addGlobalEvent(WelfareEvent.UpdateBindPhoneStatus, function(data)
        self:updateBindStatus(data)
    end)
end

function CertifyBindPhoneWindow:openRootWnd()
end

--==============================--
--desc:请求验证码
--time:2019-01-28 09:25:02
--@return 
--==============================--
function CertifyBindPhoneWindow:requestCertifyNumber()
    local phone_number = self.phone_box:getText()
    if phone_number == "" or string.len( phone_number ) ~= 11 then
        message(TI18N("请输入正确的手机号码!"))
        return
    end
    WelfareController:getInstance():requestBindPhone(phone_number, "")
end

--==============================--
--desc:更新绑定状态
--time:2019-01-30 02:35:03
--@data:
--@return 
--==============================--
function CertifyBindPhoneWindow:updateBindStatus(data)
    if data and data.status == 2 then         -- 只有验证码状态下才做处理
        self.count_down_time = 60
        self.send_btn:setTouchEnabled(false)
        setChildUnEnabled(true, self.send_btn)
        self:clearEneTime()
        self:countDownEndTime()
        self.timeticket = GlobalTimeTicket:getInstance():add(function()
            self:countDownEndTime()
        end, 1) 
    end
end

--==============================--
--desc:验证码倒计时
--time:2019-01-30 02:37:10
--@return 
--==============================--
function CertifyBindPhoneWindow:countDownEndTime()
    self.count_down_time = self.count_down_time - 1
    if self.count_down_time == 0 then
        self.send_btn_label:setString(TI18N("发送验证码"))
        self.send_btn:setTouchEnabled(true)
        setChildUnEnabled(false, self.send_btn)
        self:clearEneTime()
        return
    end
    self.send_btn_label:setString(TI18N("发送中..")..self.count_down_time)
end

function CertifyBindPhoneWindow:clearEneTime()
	if self.timeticket then
		GlobalTimeTicket:getInstance():remove(self.timeticket)
		self.timeticket = nil
	end
end 

--==============================--
--desc:绑定
--time:2019-01-28 09:35:14
--@return 
--==============================--
function CertifyBindPhoneWindow:sendBindPhone()
    local phone_number = self.phone_box:getText()
    if phone_number == "" or string.len( phone_number ) ~= 11 then
        message(TI18N("请输入正确的手机号码!"))
        return
    end
    local certify_number = self.certify_box:getText()
    if certify_number == "" then
        message(TI18N("验证码不能为空!"))
    end
    WelfareController:getInstance():requestBindPhone(phone_number, certify_number)
end

function CertifyBindPhoneWindow:close_callback()
    self:clearEneTime()
	WelfareController:getInstance():openCertifyBindPhoneWindow(false)
end