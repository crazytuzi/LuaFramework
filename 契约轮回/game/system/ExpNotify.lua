---
--- 获得经验时飘字
--- Created by R2D2.
--- DateTime: 2019/1/24 15:07
---

ExpNotify = ExpNotify or class("ExpNotify", BaseWidget)

ExpNotify.__cache_count = 10

ExpNotify.BaseX = 230
ExpNotify.BasyY = -230

ExpNotify.FadeInTime = 0.2
ExpNotify.ShowTime = 1
ExpNotify.FadeOutTIme = 0.2
ExpNotify.Distance = 100

function ExpNotify:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "ExpNotify"
    ExpNotify.super.Load(self)
end

function ExpNotify:dctor()
    self.str = nil
    self:SetVisible(false)
    self:StopAction()
    SystemTipManager:GetInstance():RemoveExpNotify(self)
end

function ExpNotify:__clear()
    self:StopAction()
    SystemTipManager:GetInstance():RemoveExpNotify(self)
    ExpNotify.super.__clear(self)
end

function ExpNotify:LoadCallBack()

    SetLocalScale(self.transform, 1)
    self.nodes = { "Text", }
    self:GetChildren(self.nodes)

    self.contentText = GetText(self.Text)
    if (self.WaitForLoad) then
        if self.str then
            self.contentText.text = self.str
        end
        self:StartAction()
    end
end

function ExpNotify:DoAction(str)

    if self.is_loaded then
        self.WaitForLoad = false
        self.contentText.text = str
        self:StartAction()
    else
        self.str = str
        self.WaitForLoad = true
    end
end

function ExpNotify:Reset()
    SetLocalPosition(self.transform, self.BaseX, self.BasyY, 0)
    SetLocalPosition(self.Text, 0, 0, 0)
    SetAlpha(self.contentText, 0)
end

function ExpNotify:StartAction()
    self:StopAction()
    self:Reset()

    self.TextAction = cc.Spawn(cc.FadeIn(ExpNotify.FadeInTime, self.contentText),
            cc.MoveTo(ExpNotify.ShowTime, 0, ExpNotify.Distance, 0))
    self.TextAction = cc.Sequence(self.TextAction,
            cc.FadeOut(ExpNotify.FadeOutTIme, self.contentText),
            cc.CallFunc(handler(self, self.OnEndCallBack))
    )
    cc.ActionManager:GetInstance():addAction(self.TextAction, self.Text)
end

function ExpNotify:OnEndCallBack()
    self:destroy()
end

function ExpNotify:StopAction()
    if self.TextAction then
        cc.ActionManager:GetInstance():removeAction(self.TextAction)
        self.TextAction = nil
    end
end