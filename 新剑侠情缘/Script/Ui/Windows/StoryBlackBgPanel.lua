local tbUi = Ui:CreateClass("StoryBlackBg")

function tbUi:OnOpen(szContent)
    if not szContent then
        return 0
    end
end

function tbUi:OnOpenEnd(szContent, szTitle, nRowAniTime, nContentStayTime, nAlphaTime)
    self.szContent        = szContent
    self.szTitle          = szTitle
    self.nContentStayTime = nContentStayTime or 1
    
    self.nTitleHeight = self.nTitleHeight or self.pPanel:Sprite_GetSize("BgTitle1").y
    self.nRowHeight   = self.nRowHeight or self.pPanel:Sprite_GetSize("BgCol1").y

    self.nAlphaTime = math.max(nAlphaTime or 1, 1);
    self.pPanel:Tween_AlphaWithStart("Main", 0, 1, self.nAlphaTime)

    self.nRowAniTime     = math.max(nRowAniTime or 1, 1)
    self.nCharsPerSecond = math.ceil(32/self.nRowAniTime)

    self.pPanel:Label_SetText("Title", "")
    self.pPanel:Label_SetText("PlotDescription", "")
    self.nTimer = Timer:Register(Env.GAME_FPS * (self.nAlphaTime), self.InitBg, self)
end

function tbUi:InitBg()
    if not Lib:IsEmptyStr(self.szTitle) then
        self:PlayTitleAni()
    else
        self:PlayContentAni()
    end
end

function tbUi:PlayTitleAni()
    self.pPanel:Label_SetText("Title", self.szTitle)
    self.pPanel:ResetTypewriterEffect("Title", self.nCharsPerSecond)
    local nLabelH = self.pPanel:Label_GetSize("Title").y
    local nRowNum = math.ceil(nLabelH/self.nTitleHeight)
    self.nTimer = Timer:Register(Env.GAME_FPS*self.nRowAniTime*nRowNum, self.PlayContentAni, self)
end

function tbUi:PlayContentAni()
    self.pPanel:Label_SetText("PlotDescription", self.szContent)
    local nLabelH = self.pPanel:Label_GetSize("PlotDescription").y
    local nRowNum = math.ceil(nLabelH/self.nRowHeight)
    self.nTimer = Timer:Register(Env.GAME_FPS*(self.nRowAniTime*nRowNum + self.nContentStayTime), self.PlayCloseAni, self)
    self.pPanel:ResetTypewriterEffect("PlotDescription", self.nCharsPerSecond)
end

function tbUi:PlayCloseAni()    
    self:ResetTweenAlpha(1, 0)
    self.pPanel:Tween_AlphaWithStart("Main", 1, 0, self.nAlphaTime)
    Timer:Register(Env.GAME_FPS * (self.nAlphaTime), function ()
        Ui:CloseWindow(self.UI_NAME)
        self.nTimer = nil
    end)
    self.nTimer = nil
end

function tbUi:ResetTweenAlpha(nFrom, nTo)
    local tranform = self.pPanel:FindChildTransform("Main")
    local panel = tranform:GetComponent("TweenAlpha");
    panel.From = nFrom
    panel.To = nTo
end

function tbUi:OnClose()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
    
    self.pPanel:UIRect_SetAlpha("Main", 0)
    self:ResetTweenAlpha(0, 1)
end