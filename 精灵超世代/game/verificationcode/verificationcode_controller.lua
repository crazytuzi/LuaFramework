-- --------------------------------------------------------------------
-- 验证码ctrl(必填),
--
-- @author: zys@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-11
-- --------------------------------------------------------------------
VerificationcodeController = VerificationcodeController or BaseClass(BaseController)

function VerificationcodeController:config()
    self.model = VerificationcodeModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function VerificationcodeController:getModel()
    return self.model
end

function VerificationcodeController:registerEvents()

end

function VerificationcodeController:registerProtocals()
    self:RegisterProtocal(10990, "handle10990")    
end


function VerificationcodeController:send10990(code)
    if not self.cmd then
        return
    end
    local protocal = {}
    protocal.code = tonumber(code)
    protocal.cmd = self.cmd
    self:SendProtocal(10990, protocal)
end

function VerificationcodeController:handle10990(data)
    -- print("打印输出10990")
    -- dump(data);
    if data then
        self.cmd = data.cmd
        self.flag = data.flag

        if self.flag == 99 then
            self:OpenVerificationcodeMainWindow(false)
            CommonAlert.show(TI18N("验证码错误，请重启游戏后尝试"), TI18N("确定"), sdkOnSwitchAccount, nil ,nil ,nil, nil, {view_tag = ViewMgrTag.RECONNECT_TAG})
            return
        end

        local name = "code"
        local path = PathTool.getVerificationcodePath(name);
        self.path = path
        display.removeImage(path)
        writeBinaryFile(path, data.img)

        self.dispather:Fire(VerificationcodeEvent.VERIFICATION_CODE_CHANGE,data)

        if data.flag ~= 1 then
            self:OpenVerificationcodeMainWindow(true)
        end
    end
end

function VerificationcodeController:getImgPath()
    return self.path
end

function VerificationcodeController:getFlagValue()
    return self.flag or 0
end

function VerificationcodeController:OpenVerificationcodeMainWindow(status)
    if status == true then
		if not self.code_window then
			self.code_window = VerificationcodeMainWindow.New()
		end
		if self.code_window:isOpen() == false then
			self.code_window:open()
		end
    else
		if self.code_window then
			self.code_window:close()
			self.code_window = nil
		end
	end
end

function VerificationcodeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end