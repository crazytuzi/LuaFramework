local tbUi = Ui:CreateClass("SwornFriendsConnectPanel")

function tbUi:OnOpen(szNames)
    self.bCloseEnabled = false
end

--fnCallBack关闭ui时的回调，bDelayClose是否延迟关闭，延迟关闭会在进入别的地图时关闭
function tbUi:OnOpenEnd(szNames, fnCallBack, bDelayClose)
    self.pPanel:Label_SetText("Text1", "")
    self.pPanel:Label_SetText("Text2", "")
    self.pPanel:Label_SetText("Name", "")

    self.szNames = szNames
    self.fnCallBack  = fnCallBack
    self.bDelayClose = bDelayClose

    self.pPanel.OnTouchEvent = function ()
        if self.bCloseEnabled then
            Ui:CloseWindow(self.UI_NAME)
        end
    end

    self.szOpenAni = self.pPanel:GetOpenAni(self.UI_NAME)
    self.szCloseAni = self.pPanel:GetCloseAni(self.UI_NAME)
end

function tbUi:OnAniEnd(szAniName)
    if Lib:IsEmptyStr(szAniName) then
        return
    end

    if not Lib:IsEmptyStr(self.szOpenAni) and self.szOpenAni == szAniName then
        self:PlayTextAni()
    elseif not Lib:IsEmptyStr(self.szCloseAni) and self.szCloseAni == szAniName then
        if self.fnCallBack then
            self.fnCallBack()
            self.fnCallBack = nil
        end
    end
end

function tbUi:PlayTextAni()
    local tbLabels = {"Text1", "Name", "Text2"}
    for _, szLabel in ipairs(tbLabels) do
        self.pPanel:Label_SetText(szLabel, "")
    end

    local tbWords = {}
    table.insert(tbWords, Lib:GetUft8Chars(SwornFriends.Def.szText1))
    table.insert(tbWords, Lib:GetUft8Chars(self.szNames))
    table.insert(tbWords, Lib:GetUft8Chars(SwornFriends.Def.szText2))

    self.nTimer = Timer:Register(Env.GAME_FPS*SwornFriends.Def.nSwornTextInterval, function()
        for i, tb in ipairs(tbWords) do
            if next(tb) then
                local szWord = table.remove(tb, 1)
                local szOld = self.pPanel:Label_GetText(tbLabels[i])
                self.pPanel:Label_SetText(tbLabels[i], szOld .. szWord)
                return true
            end
        end
        self:OnContentAniEnd()
        return false
    end, self)
end

function tbUi:OnContentAniEnd()
    self.nTimer = nil
    Timer:Register(Env.GAME_FPS * 1, function ()
        self.bCloseEnabled = true
        if self.fnCallBack then
            self.nTimer = nil
            
            if self.bDelayClose then
                self.fnCallBack()
                self.fnCallBack = nil
            else
                Ui:CloseWindow(self.UI_NAME)
            end
        else
            Ui:CloseWindow(self.UI_NAME)
        end
    end)
end

function tbUi:OnClose()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
end