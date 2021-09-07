-- @author pwj
-- @date 2018年6月27日,星期三

CrossVoiceModel = CrossVoiceModel or BaseClass(BaseModel)

function CrossVoiceModel:__init()
    self.itemList = { }  --传声道具列表
    self.System_MsgList = { }  --默认内容列表
end

function CrossVoiceModel:__delete()
end

function CrossVoiceModel:OpenWindow(args)
    if self.mainWin == nil then
    end
    self.mainWin:Open(args)
end

function CrossVoiceModel:CloseWindow()
end

function CrossVoiceModel:OpenCrossVoiceWindow(args)
    if self.CrossVoiceWin == nil then
        self.CrossVoiceWin = CrossVoiceWindow.New(self)
    end
    self.CrossVoiceWin:Open(args)
end

function CrossVoiceModel:CloseCrossVoiceWindow()
    WindowManager.Instance:CloseWindow(self.CrossVoiceWin)
end

function CrossVoiceModel:OpenCrossVoiceContent(args)
    if self.CrossVoicecontent == nil then
        self.CrossVoicecontent = CrossVoiceContent.New(self)
    end
    self.CrossVoicecontent:Show(args)
end

function CrossVoiceModel:CloseCrossVoiceContent()
    if self.CrossVoicecontent ~= nil then
        self.CrossVoicecontent:DeleteMe()
        self.CrossVoicecontent = nil
    end
    --WindowManager.Instance:CloseWindow(self.CrossVoicecontent)
end


