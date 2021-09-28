local SecondaryPassword = class("SecondaryPassword")

local isSecPassChecked = true
local passwordState = -1     -- 0 not setted 1 using 2 forgetting
local passInvalidSeconds = 0
local forgetRemindLabel = nil
function SecondaryPassword.isSecPassChecked()
    return isSecPassChecked
end

function SecondaryPassword.checkSecondaryPassword()
    SecondaryPassword.inputPassword()
end

function SecondaryPassword.setPassState(passState,passInvilidSecs)
    passwordState = passState
    passInvalidSeconds = passInvilidSecs
    isSecPassChecked = false
    if passwordState == 0 then
        isSecPassChecked = true
    end
end

function SecondaryPassword.inputPassword()
    if passwordState == 1 or passwordState == 2 then
        SecondaryPassword.validPassword()
    elseif passwordState == 0 then
        SecondaryPassword.settingPassword()
    end
end

function SecondaryPassword.validPassword()          -- only valid password here
    local rScene = getRunScene()
    local bg = createSprite(rScene,"res/common/bg/bg52.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5),299)
    local bgWidth,bgHeight = bg:getContentSize().width,bg:getContentSize().height

    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(bgWidth/2,bgHeight/2),
        cc.size(443, 204),
        4,
        cc.p(0.5,0.5)
    )

    createSprite(bg,"res/jieyi/titlebg.png",cc.p(bgWidth/2,bgHeight-35))
    createLabel(bg,game.getStrByKey("secondarypass_inputtitle"),cc.p(249,307),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_input"),cc.p(249,239),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_inputremind"),cc.p(249,143),cc.p(0.5,0.5),22,nil,nil,nil,MColor.alarm_red)

    forgetRemindLabel = createLabel(bg, "",cc.p(249,103),cc.p(0.5,0.5),22,nil,nil,nil,MColor.alarm_red)
    
    --local editePwdBg = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(247,191), cc.p(0.5,0.5))
    local editePwdBg = SecondaryPassword.addScale9EditBoxBg(cc.p(247,191),cc.p(0.5,0.5),bg)
    local editePwd = createEditBox(editePwdBg, nil ,cc.p(130, 19) ,cc.size(250,194),nil , 22,game.getStrByKey("sp_psssFormat"))    -- last param placeholder
    editePwd:setAnchorPoint(cc.p(0.5, 0.5))
    editePwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    local function modifyPass()
        bg:removeFromParent()
        SecondaryPassword.modifyPassword()
    end

    local function fogetPass()
        bg:removeFromParent()
        SecondaryPassword.forgetPassword()
    end

    local function onSecondaryPassSetRes(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassSetPasswordRetPrtocol", luaBuffer)
        -- no data {}
        TIPS({type=1,str=game.getStrByKey("sp_passSuccess")})
        isSecPassChecked = true
        bg:removeFromParent()
    end

    local function onSecondaryPassValidCheck(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassCheckPasswordRetProtocol", luaBuffer)
        -- no data {}
        TIPS({type=1,str=game.getStrByKey("sp_passValid")})
        isSecPassChecked = true
        bg:removeFromParent()
    end

    local function confirmPass()
        local secPwd = editePwd:getText()
        if not SecondaryPassword.checkPasswordValid(secPwd) then
            return
        end 

        g_msgHandlerInst:sendNetDataByTableExEx( ESPASS_CS_CHECK_PASSWORD, "SecondPassCheckPasswordProtocol", {strPass=secPwd})
        addNetLoading(ESPASS_CS_CHECK_PASSWORD,ESPASS_SC_CHECK_PASSWORD)
        g_msgHandlerInst:registerMsgHandler( ESPASS_SC_CHECK_PASSWORD , onSecondaryPassValidCheck )
        
    end

    local btnM = createMenuItem(bg,"res/component/button/50.png",cc.p(100,35),modifyPass)
    createLabel(btnM,game.getStrByKey("secondarypass_modifyPass"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    local btnF = createMenuItem(bg,"res/component/button/50.png",cc.p(253,35),fogetPass)
    createLabel(btnF,game.getStrByKey("secondarypass_forgetPass"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    local btnC = createMenuItem(bg,"res/component/button/50.png",cc.p(403,35),confirmPass)
    createLabel(btnC,game.getStrByKey("confirm"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

    --SwallowTouches(bg)
    local function removeLayer()
        bg:removeFromParent()
    end
    registerOutsideCloseFunc( bg ,removeLayer,true)

    -- get password state
    local function setBtnState()
        if passwordState == 0 then
            -- pass not setted
            btnM:setEnabled(false)
            btnF:setEnabled(false)
            btnC:setEnabled(true)
        elseif passwordState == 2 then
            btnM:setEnabled(true)
            btnF:setEnabled(false)
            btnC:setEnabled(true)
        elseif passwordState == 1 then
            btnM:setEnabled(true)
            btnF:setEnabled(true)
            btnC:setEnabled(true)
        else
            btnM:setEnabled(false)
            btnF:setEnabled(false)
            btnC:setEnabled(true)
        end
    end
    setBtnState()

    local function onPasswordStateRet(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassGetInvalidSecondsRetProtocol", luaBuffer)
        SecondaryPassword.setPassState(retTable.dwPassStatus,retTable.dwInvalidSeconds)
        setBtnState()
        if passwordState == 2 and passInvalidSeconds > 0 then
            local osDate = os.date("*t",passInvalidSeconds+os.time())
            local yearTime = osDate.year .. "-" .. osDate.month .. "-" .. osDate.day .. " " .. string.format("%02d",osDate.hour) .. ":" .. string.format("%02d",osDate.min) .. ":" .. string.format("%02d",osDate.sec) .. " "
            forgetRemindLabel:setString(string.format(game.getStrByKey("sp_unlockTime"),yearTime) )
        else
            forgetRemindLabel:setVisible(false)
        end
    end

    -- restore ori callback func
    local func1 = g_msgHandlerInst:getMsgHandler( ESPASS_SC_PASSWORD_INVALID_SECONDS ) 
    
    g_msgHandlerInst:sendNetDataByTableExEx( ESPASS_CS_PASSWORD_INVALID_SECONDS, "SecondPassGetInvalidSecondsProtocol", {})
    addNetLoading(ESPASS_CS_PASSWORD_INVALID_SECONDS,ESPASS_SC_PASSWORD_INVALID_SECONDS)
    g_msgHandlerInst:registerMsgHandler( ESPASS_SC_PASSWORD_INVALID_SECONDS , onPasswordStateRet )

     local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( ESPASS_SC_PASSWORD_INVALID_SECONDS , func1 )  
            g_msgHandlerInst:registerMsgHandler( ESPASS_SC_SET_PASSWORD , nil )  
            g_msgHandlerInst:registerMsgHandler( ESPASS_SC_CHECK_PASSWORD , nil )  
        end
    end
     bg:registerScriptHandler(eventCallback)

end

function SecondaryPassword.modifyPassword()
    local rScene = getRunScene()
    local bg = createSprite(rScene,"res/common/bg/bg52.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5),299)
    local bgWidth,bgHeight = bg:getContentSize().width,bg:getContentSize().height

    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(bgWidth/2,bgHeight/2),
        cc.size(443, 204),
        4,
        cc.p(0.5,0.5)
    )

    createSprite(bg,"res/jieyi/titlebg.png",cc.p(bgWidth/2,bgHeight-35))
    local downDis = 30
    local leftDis = 20
    createLabel(bg,game.getStrByKey("secondarypass_modifyTitle"),cc.p(266-leftDis,327-20),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_inputoldPass"),cc.p(176-leftDis,265-downDis),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_inputnewPass"),cc.p(176-leftDis,204-downDis),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_confirmPass"),cc.p(176-leftDis,145-downDis),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    
    --local editePwdBg = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(191-leftDis,267-downDis), cc.p(0,0.5))
    local editePwdBg = SecondaryPassword.addScale9EditBoxBg(cc.p(191-leftDis,267-downDis),cc.p(0,0.5),bg)
    local editePwdOld = createEditBox(editePwdBg, nil ,cc.p(2, 19) ,cc.size(270,47), nil, 22,"")    -- last param placeholder
    editePwdOld:setAnchorPoint(cc.p(0, 0.5))
    editePwdOld:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwdOld:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    --local editePwdBgNew = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(191-leftDis,203-downDis), cc.p(0,0.5))
    local editePwdBgNew = SecondaryPassword.addScale9EditBoxBg(cc.p(191-leftDis,203-downDis),cc.p(0,0.5),bg)
    local editePwdNew1 = createEditBox(editePwdBgNew, nil ,cc.p(2, 19) ,cc.size(270,47), nil, 22,game.getStrByKey("sp_psssFormat"))    -- last param placeholder
    editePwdNew1:setAnchorPoint(cc.p(0, 0.5))
    editePwdNew1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwdNew1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    --local editePwdBgNew2 = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(191-leftDis,140-downDis), cc.p(0,0.5))
    local editePwdBgNew2 = SecondaryPassword.addScale9EditBoxBg(cc.p(191-leftDis,140-downDis),cc.p(0,0.5),bg)
    local editePwdNew2 = createEditBox(editePwdBgNew2, nil ,cc.p(2, 19) ,cc.size(270,47), nil, 22,"")    -- last param placeholder
    editePwdNew2:setAnchorPoint(cc.p(0, 0.5))
    editePwdNew2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwdNew2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    local function onResetPassRet(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassChangePasswordRetProtocol", luaBuffer)
        bg:removeFromParent()
        isSecPassChecked = true
        passwordState = 1
        TIPS({type=1,str=game.getStrByKey("sp_passModify")})
    end
    local function yesCallBack()
        local oldPass = editePwdOld:getText()
        local new1 = editePwdNew1:getText()
        local new2 = editePwdNew2:getText()
        if not SecondaryPassword.checkModifyPasswordValid(oldPass,new1,new2) then
            return
        end 
        
        g_msgHandlerInst:sendNetDataByTableExEx( ESPASS_CS_CHANGE_PASSWORD, "SecondPassChangePasswordProtocol", {strOldPass=oldPass,strNewPass=new1})
        addNetLoading(ESPASS_CS_CHANGE_PASSWORD,ESPASS_SC_CHANGE_PASSWORD)
        g_msgHandlerInst:registerMsgHandler( ESPASS_SC_CHANGE_PASSWORD , onResetPassRet )
    end

    local function noCallBack(luaBuffer)
        bg:removeFromParent()
    end

    local btn = createMenuItem(bg,"res/component/button/50.png",cc.p(160-leftDis,65-downDis),yesCallBack)
    createLabel(btn,game.getStrByKey("sure"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    btn = createMenuItem(bg,"res/component/button/50.png",cc.p(369-leftDis,65-downDis),noCallBack)
    createLabel(btn,game.getStrByKey("cancel"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

    --SwallowTouches(bg)
    local function removeLayer()
        bg:removeFromParent()
    end
    registerOutsideCloseFunc( bg ,removeLayer,true)

    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( ESPASS_SC_CHANGE_PASSWORD , nil )  
        end
    end
     bg:registerScriptHandler(eventCallback)
end

function SecondaryPassword.forgetPassword()
    local function onResetPassClick(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassResetPasswordRetProtocol", luaBuffer)
        TIPS({type=1,str=game.getStrByKey("sp_passForgetSuccess")})
        -- no need update data here layer will be closed
    end
    local function yesCallBack()
        g_msgHandlerInst:sendNetDataByTableExEx( ESPASS_CS_RESET_PASSWORD, "SecondPassResetPasswordProtocol", {})
        addNetLoading(ESPASS_CS_RESET_PASSWORD,ESPASS_SC_RESET_PASSWORD)
        g_msgHandlerInst:registerMsgHandler( ESPASS_SC_RESET_PASSWORD , onResetPassClick )
    end

    local contentId = 66
    local data = require("src/config/PromptOp")
    local title = data:record(contentId).q_Promptobject
	local str = data:content(contentId)

    MessageBoxYesNo(game.getStrByKey("tip"),str,yesCallBack,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"),MColor.lable_yellow)
end

function SecondaryPassword.checkPasswordValid(password)
    local _,num = string.gsub(password, "%A%D", ".")
    if string.len(password) ~= 6 or num >0 then
        TIPS({type=1,str=game.getStrByKey("sp_passNotValid")})
        return false
    end
    return true
end

function SecondaryPassword.checkModifyPasswordValid(old,new1,new2)
    if not SecondaryPassword.checkPasswordValid(old) or not SecondaryPassword.checkPasswordValid(new1) or not SecondaryPassword.checkPasswordValid(new2) then
        return false
    end
    
    if new1 ~= new2 then
        TIPS({type=1,str=game.getStrByKey("sp_pass1pass2")})
        return false
    end
    return true
end

function SecondaryPassword.checkSettingPasswordValid(new1,new2)
    if not SecondaryPassword.checkPasswordValid(new1) or not SecondaryPassword.checkPasswordValid(new2) then
        return false
    end
    
    if new1 ~= new2 then
        TIPS({type=1,str=game.getStrByKey("sp_pass1pass2")})
        return false
    end
    return true
end

-------------------------------------------------------------------------------------------
---- password setting ----
function SecondaryPassword.settingPassword()
    local rScene = getRunScene()
    local bg = createSprite(rScene,"res/common/bg/bg52.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5),299)
    local bgWidth,bgHeight = bg:getContentSize().width,bg:getContentSize().height
    
    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(bgWidth/2,bgHeight/2),
        cc.size(443, 204),
        4,
        cc.p(0.5,0.5)
    )

    createSprite(bg,"res/jieyi/titlebg.png",cc.p(bgWidth/2,bgHeight-35))
    local downDis = 30
    local leftDis = 20
    createLabel(bg,game.getStrByKey("sp_settingPassword"),cc.p(246,307),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_inputnewPass"),cc.p(176-leftDis,250-downDis),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(bg,game.getStrByKey("secondarypass_confirmPass"),cc.p(176-leftDis,190-downDis),cc.p(1,0.5),22,nil,nil,nil,MColor.lable_yellow)
    
    --local editePwdBgNew = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(191-leftDis,250-downDis), cc.p(0,0.5))
    local editePwdBgNew = SecondaryPassword.addScale9EditBoxBg(cc.p(191-leftDis,250-downDis),cc.p(0,0.5),bg)

    local editePwdNew1 = createEditBox(editePwdBgNew, nil ,cc.p(2, 19) ,cc.size(270,47), nil, 22,"")    -- last param placeholder
    editePwdNew1:setAnchorPoint(cc.p(0, 0.5))
    editePwdNew1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwdNew1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    --local editePwdBgNew2 = createSprite(bg, "res/jieyi/passwordInputbg.png", cc.p(191-leftDis,190-downDis), cc.p(0,0.5))
    local editePwdBgNew2 = SecondaryPassword.addScale9EditBoxBg(cc.p(191-leftDis,190-downDis),cc.p(0,0.5),bg)
    local editePwdNew2 = createEditBox(editePwdBgNew2, nil ,cc.p(2, 19) ,cc.size(270,47), nil, 22,"")    -- last param placeholder
    editePwdNew2:setAnchorPoint(cc.p(0, 0.5))
    editePwdNew2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editePwdNew2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    createLabel(bg,game.getStrByKey("sp_psssFormat"),cc.p(245,100),cc.p(0.5,0.5),22,nil,nil,nil,MColor.alarm_red)

    local function onSecondaryPassSetRes(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassSetPasswordRetPrtocol", luaBuffer)
        bg:removeFromParent()
        isSecPassChecked = true
        passwordState = 1
        TIPS({type=1,str=game.getStrByKey("sp_passSuccess")})
    end
    local function yesCallBack()
        local new1 = editePwdNew1:getText()
        local new2 = editePwdNew2:getText()
        if not SecondaryPassword.checkSettingPasswordValid(new1,new2) then
            return
        end 
        
        g_msgHandlerInst:sendNetDataByTableExEx( ESPASS_CS_SET_PASSWORD, "SecondPassSetPasswordPrtocol", {strPass=new1})
        addNetLoading(ESPASS_CS_SET_PASSWORD,ESPASS_SC_SET_PASSWORD)
        g_msgHandlerInst:registerMsgHandler( ESPASS_SC_SET_PASSWORD , onSecondaryPassSetRes )
    end

    local function noCallBack(luaBuffer)
        bg:removeFromParent()
    end

    local btn = createMenuItem(bg,"res/component/button/50.png",cc.p(160-leftDis,65-downDis),yesCallBack)
    createLabel(btn,game.getStrByKey("sure"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    btn = createMenuItem(bg,"res/component/button/50.png",cc.p(369-leftDis,65-downDis),noCallBack)
    createLabel(btn,game.getStrByKey("cancel"),cc.p(71,31),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

    --SwallowTouches(bg)
    local function removeLayer()
        bg:removeFromParent()
    end
    registerOutsideCloseFunc( bg ,removeLayer,true)

    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( ESPASS_SC_SET_PASSWORD , nil )  
        end
    end
     bg:registerScriptHandler(eventCallback)
end

function SecondaryPassword.addScale9EditBoxBg(pos,anchorPoint,par)
    local editePwdBgNew = cc.Scale9Sprite:create("res/common/bg/inputBg9.png")
    editePwdBgNew:setContentSize(cc.size(272,47))
    editePwdBgNew:setCapInsets(cc.rect(40,2,322-80,40))
    editePwdBgNew:setPosition(pos)
    editePwdBgNew:setAnchorPoint(anchorPoint)
    par:addChild(editePwdBgNew)
    return editePwdBgNew
end
-------------------------------------------------------------------------------------------

return SecondaryPassword