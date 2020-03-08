local tbUi = Ui:CreateClass("TaskStoryBlackPanel")
function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap, self},
    }
end

function tbUi:OnOpen(szTitle, szContent)
    if not szContent then
        return 0
    end

    self.bCloseEnabled = false
end

--fnCallBack关闭ui时的回调，bDelayClose是否延迟关闭，延迟关闭会在进入别的地图时关闭
function tbUi:OnOpenEnd(szTitle, szContent, fnCallBack, bDelayClose)
    self.szTitle     = szTitle
    self.szContent   = szContent
    self.fnCallBack  = fnCallBack
    self.bDelayClose = bDelayClose

    -- self.tbTitlePos   = self.tbTitlePos or self.pPanel:GetPosition("BgTitle1")
    self.nTitleHeight = self.nTitleHeight or self.pPanel:Sprite_GetSize("BgTitle1").y
    -- self.tbColPos     = self.tbColPos or self.pPanel:GetPosition("BgCol1")
    self.nRowHeight   = self.nRowHeight or self.pPanel:Sprite_GetSize("BgCol1").y
    -- self.nBgNum       = self.nBgNum or 1

    self:InitBg()
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
        if not Lib:IsEmptyStr(self.szTitle) then
            self:PlayTitleAni()
        else
            self:PlayContentAni()
        end
    elseif not Lib:IsEmptyStr(self.szCloseAni) and self.szCloseAni == szAniName then
        if self.fnCallBack then
            self.fnCallBack()
            self.fnCallBack = nil
        end
    end
end

function tbUi:InitBg()
    self.pPanel:SetActive("Title", not Lib:IsEmptyStr(self.szTitle))
    self.pPanel:Label_SetText("PlotDescription", "")
end

tbUi.nTextTime = 5
function tbUi:PlayTitleAni()
    self.pPanel:Label_SetText("Title", self.szTitle or "")
    self.pPanel:ResetTypewriterEffect("Title")
    local nLabelH = self.pPanel:Label_GetSize("Title").y
    local nRowNum = math.ceil(nLabelH/self.nTitleHeight)
    self.nTimer = Timer:Register(self.nTextTime * nRowNum * Env.GAME_FPS, self.PlayContentAni, self)
end

function tbUi:PlayContentAni()
    self.pPanel:Label_SetText("PlotDescription", self.szContent or "")
    self.pPanel:ResetTypewriterEffect("PlotDescription")
    local nLabelH = self.pPanel:Label_GetSize("PlotDescription").y
    local nRowNum = math.ceil(nLabelH/self.nRowHeight)
    self.nTimer = Timer:Register(self.nTextTime * nRowNum * Env.GAME_FPS, self.OnContentAniEnd, self)
end

function tbUi:OnContentAniEnd()
    self.nTimer = nil
    self.pPanel:SetActive("BgColumn", false)
    self.pPanel:SetActive("BgTitle", false)

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

function tbUi:OnEnterMap()
    Ui:CloseWindow(self.UI_NAME)
end