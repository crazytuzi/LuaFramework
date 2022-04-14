-- 
-- @Author: LaoY
-- @Date:   2018-08-20 15:27:45
-- 
require('game.system.dialog.DialogPanel')
Dialog = Dialog or {}
Dialog.Type = {
    One = "One",
    Two = "Two",
    CheckBox = "CheckBox",
    ShowBGOne = "ShowBGOne",
}

-- 缓存不在提示
Dialog.CheckPromptList = {

}

function Dialog.ShowOne(title_str, message, btn_str, btn_func, auto_time, close_func)
    if not PreloadManager:GetInstance().is_loaded then
        return
    end

    local data = {
        dialog_type = Dialog.Type.One,
        title_str = title_str,
        message = message,
        ok_str = btn_str,
        ok_func = btn_func,
        ok_time = auto_time and auto_time + os.time(),
        close_func = close_func,
    }
    lua_panelMgr:GetPanelOrCreate(DialogPanel):Open(data)
end

--[[
    @des    两个按钮+复选框
    @param  isNeedOn   是否自动选择复选框
    @param  check_id   复选框唯一ID，可以用__cname或者自定义key，用于不再提示
    @return number

    @cd_data 倒计时数据，不为空时中间显示倒计时
        @end_time               cd_data里必须得带
        @show_str_after_end     倒计时结束后，倒计时处的显示文字，默认结束后隐藏
        CountDownText类的用法，其他的传需要的参数就好了
--]]
function Dialog.ShowTwo(title_str, message, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, checkText, isNeedOn, isLoacteCenterLeft, check_id, content_Data, toggle_Data, cd_data)
    if not PreloadManager:GetInstance().is_loaded then
        return
    end

    if Dialog.CheckPromptList[check_id] then
        if ok_func then
            ok_func(true)
        end
        return
    end
    local ok_call_back
    if checkText and check_id then
        ok_call_back = function(isOn)
            if isOn then
                Dialog.CheckPromptList[check_id] = true
            end
            if ok_func then
                ok_func(isOn)
            end
        end
    else
        ok_call_back = ok_func
    end
    local data = {
        dialog_type = Dialog.Type.Two,
        title_str = title_str,
        message = message,
        ok_str = ok_str,
        ok_func = ok_call_back,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),
        isCheck = checkText ~= nil or false,
        checkText = checkText,
        isNeedOn = isNeedOn,
        isLoacteCenterLeft = isLoacteCenterLeft,
        content_Data = content_Data,
        toggle_Data = toggle_Data,
        cd_data = cd_data,
    }
    --  他会与 加载界面冲突
    local time_id
    local function call_back()
        local panel = LoadingCtrl:GetInstance().loadingPanel
        if panel then
            if not time_id then
                time_id = GlobalSchedule.StartFun(call_back, 2, -1)
            end
        else
            lua_panelMgr:GetPanelOrCreate(DialogPanel):Open(data)
            if time_id then
                GlobalSchedule:Stop(time_id)
                time_id = nil
            end
        end
    end
    call_back()
end

--显示2个按钮，带多次点击确定按钮，点了一次确定按钮，继续显示下一条提示，直到最后一条提示，才执行确定回调
function Dialog.ShowTwoWithMultyClickOK(title_str_lst, message_lst, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, checkText)
    if not PreloadManager:GetInstance().is_loaded then
        return
    end
    local data = {
        dialog_type = Dialog.Type.Two,
        title_str_lst = title_str_lst,
        message_lst = message_lst,
        ok_str = ok_str,
        ok_func = ok_func,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),
        isCheck = checkText ~= nil or false,
        checkText = checkText,
    }
    lua_panelMgr:GetPanelOrCreate(DialogPanel):Open(data)
end

function Dialog.ShowTwoCheck(title_str, message, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, checkText)
    if not PreloadManager:GetInstance().is_loaded then
        return
    end
    local data = {
        dialog_type = Dialog.Type.Two,
        title_str = title_str,
        message = message,
        ok_str = ok_str,
        ok_func = ok_func,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),

    }
    lua_panelMgr:GetPanelOrCreate(DialogPanel):Open(data)
end

function Dialog:ShowCheckBox(type, title, message, ok_text, ok_func, ok_time, cancel_text, cancel_func, cancel_time)
end
--显示复活界面
function Dialog.ShowRevive(title_str, message, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, _reviveText)
    local data = {
        dialog_type = Dialog.Type.Two,
        title_str = title_str,
        message = message,
        ok_str = ok_str,
        ok_func = ok_func,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),
        reviveText = _reviveText,
        hideClose = true,
    }
    lua_panelMgr:GetPanelOrCreate(RevivePanel):Open(data)
end

function Dialog.ShowRevive2(title_str, message, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, _reviveText, auto_revive)
    local data = {
        dialog_type = Dialog.Type.Two,
        title_str = title_str,
        message = message,
        ok_str = ok_str,
        ok_func = ok_func,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),
        reviveText = _reviveText,
        dialog_type = Dialog.Type.One,
        --auto_revive = auto_revive,
    }
    lua_panelMgr:GetPanelOrCreate(RevivePanel2):Open(data)
end

--显示带背景1
function Dialog.ShowWithBGOne(title_str, message, ok_str, ok_func, ok_time, cancel_str, cancel_func, cancel_time, checkText, isNeedOn)
    if not PreloadManager:GetInstance().is_loaded then
        return
    end
    local data = {
        dialog_type = Dialog.Type.ShowBGOne,
        title_str = title_str,
        bg_one_message = message,
        ok_str = ok_str,
        ok_func = ok_func,
        ok_time = ok_time and ok_time + os.time(),
        cancel_str = cancel_str,
        cancel_func = cancel_func,
        cancel_time = cancel_time and cancel_time + os.time(),
        isCheck = checkText ~= nil or false,
        checkText = checkText,
        isNeedOn = isNeedOn,
    }
    lua_panelMgr:GetPanelOrCreate(DialogPanel):Open(data)
end