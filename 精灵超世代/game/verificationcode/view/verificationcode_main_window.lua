-- --------------------------------------------------------------------
-- 验证码主界面
--
-- @author: zys@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-11
-- --------------------------------------------------------------------
VerificationcodeMainWindow = VerificationcodeMainWindow or BaseClass(BaseView)

local ctrl = VerificationcodeController:getInstance()

function VerificationcodeMainWindow:__init()
    self.type =  CommonAlert.type.common
    self.offset_height = 95
    -- self.view_tag = ViewMgrTag.MSG_TAG
    self.view_tag = ViewMgrTag.DEBUG_TAG
    self.layout_name = "common/common_alert"
    self.win_type = WinType.Tips
    self.time = 0
end

function VerificationcodeMainWindow:open_callback()
    self.background_panel = self.root_wnd:getChildByName("background_panel")
    self.background_panel:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.main_panel:setContentSize(672,390)
    local width = self.main_panel:getContentSize().width
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.title_contaier = self.main_panel:getChildByName("title_container")
    self.title_label = self.title_contaier:getChildByName("title_label")
    self.title_label:setString(TI18N("验证信息"))
    self.title_contaier:setPosition(width/2,self.title_contaier:getPositionY() + 35)

    self.line = self.main_panel:getChildByName("line")
    self.line:setPositionY(self.line:getPositionY() + 9)

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn.label = self.ok_btn:getChildByName("label")
    self.ok_btn.label:setString(TI18N("确定"))
    self.ok_btn:setPositionX(self.title_contaier:getPositionX()) 

    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn:setVisible(false)

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.close_btn:setVisible(false)

    --描述
    local text = TI18N("如果您连续5次输入错误，服务器将自动断开连接")
    createLabel(26, 175, nil, width/2, 330, text, self.main_panel, nil, cc.p(0.5,1))

    --图片
    self.img = createImage(self.main_panel, nil, width*0.5, 190, cc.p(0,0), false, nil, true)
    self.img:setContentSize(249,78)

    --输入框
    local placeholder = TI18N("请输入答案")
    local flag = ctrl:getFlagValue()
    if flag == 0 then
        placeholder = TI18N("请输入验证码")
    elseif flag ~= 1 then
        placeholder = TI18N("请输入答案")
    end
    self.input_edit = createEditBox(self.main_panel, PathTool.getResFrame("common", "common_1021"), size or cc.size(250, 50), Config.ColorData.data_color3[81], 22, nil, 25, placeholder, nil, 10, LOADTEXT_TYPE_PLIST)
    self.input_edit:setAnchorPoint(cc.p(1, 0.5))
    self.input_edit:setPosition(width/2 - 10, 230)
    self.input_edit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    
    --换一张
    local desc =  TI18N("看不清，换一张")
    local desc_ = TI18N("_____________")
    createLabel(24, 178, nil, width * 0.5 + 125, 144, desc_, self.main_panel, nil, cc.p(0.5,0))
    -- self.change_text = createLabel(24, 178, nil, width * 0.5 + 125, 146, desc, self.main_panel, nil, cc.p(0.5,0))
    self.change_text = createRichLabel(24, 178, cc.p(0.5, 0), cc.p(width * 0.5 + 125, 146), nil, nil, 200)
    self.change_text:setString(desc)
    self.main_panel:addChild(self.change_text)
end

function VerificationcodeMainWindow:register_event()
    registerButtonEventListener(self.ok_btn, function()
        local text = self.input_edit:getText()
        if text == "" or text == nil  then
            message("您尚未输入验证信息")
            return
        end
        ctrl:send10990(text)
    end, true)

    self.change_text:addTouchLinkListener(function()
        if self.time <= os.time() then
            ctrl:send10990(0)   --请求更新验证码
            self.time = os.time() + 1
            -- self.request_code_status = true;
        else
            message("点击太快")
        end
    end,{ "click", "href" })

    self:addGlobalEvent(VerificationcodeEvent.VERIFICATION_CODE_CHANGE, function (data)
        if data.flag ~= 1 then  --(0:(失败/弹出验证码窗口/刷新验证码)
            -- if self.request_code_status == true then
            --     self.request_code_status = false
            -- else
            --     -- message(TI18N("输入错误，请重新验证"))
            -- end

            local res = ctrl:getImgPath()
            self.img:loadTexture(res,LOADTEXT_TYPE)

            self.input_edit:setText("")
            if data.flag == 0 then
                self.input_edit:setPlaceHolder(TI18N("请输入验证码"))
            elseif data.flag == 2 or data.flag == 3 then
                self.input_edit:setPlaceHolder(TI18N("请输入答案"))
            end
        elseif data.flag == 1 then
            -- message(TI18N("验证成功"))
            ctrl:OpenVerificationcodeMainWindow(false)
        end
    end)
end

function VerificationcodeMainWindow:openRootWnd()
    local res = ctrl:getImgPath()
    self.img:loadTexture(res,LOADTEXT_TYPE)
end

function VerificationcodeMainWindow:DeleteMe()
    ctrl:OpenVerificationcodeMainWindow(false)
end