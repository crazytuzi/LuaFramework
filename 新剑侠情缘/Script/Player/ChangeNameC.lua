function ChangeName:OnChangeName( nCode )
    if nCode and nCode ~= 0 then
        me.CenterMsg(Login.tbCREATE_ROLE_RESPOND_CODE[nCode] or "未知错误！改名失败")
    else
        me.CenterMsg(string.format("成功改名为「%s」", me.szName))
        Ui:CloseWindow("ChangeName")
    end
end

function ChangeName:CheckShowRedPoint()
    if me.nLevel < self.OPEN_LEVEL or me.nLevel > self.FREE_LEVEL then
        Ui:ClearRedPointNotify("ChanfeNameInfo")
        return
    end
    
    if Client:GetFlag("ChangeNameRed") then
        Ui:ClearRedPointNotify("ChanfeNameInfo")
        return
    end
    
    Ui:SetRedPointNotify("ChanfeNameInfo")
end