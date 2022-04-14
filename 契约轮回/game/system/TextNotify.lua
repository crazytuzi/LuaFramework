--
--@Author:  R2D2
--@Date:    2019-01-29 16:46:31
--
TextNotify = TextNotify or class("TextNotify", BaseWidget)
local TextNotify = TextNotify
TextNotify.__cache_count = 6

TextNotify.BaseX = 0 --相对于屏幕中心点位置
TextNotify.BaseY = -40 --相对于屏幕中心点位置

TextNotify.DistanceA = 130  --A：渐显到显示并稍停的位置
TextNotify.DistanceB = 225  --B：渐隐到消失的位置

TextNotify.fadeInTime = 0.4 --渐显过渡时间
TextNotify.delayTime = 0.5 --稍停时间
TextNotify.fadeOutTime = 0.4 --B段时间


function TextNotify:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "NotifyText"
    TextNotify.super.Load(self)
end

function TextNotify:dctor()
    self:SetVisible(false)
    self:StopAction()
    SystemTipManager:GetInstance():RemoveTextNotify(self)
end

function TextNotify:LoadCallBack()
    SetLocalScale(self.transform, 1)

    self.nodes = {
        "img_bg",
        "Text"
    }
    self:GetChildren(self.nodes)

    self:SetOrderByParentMax()
    
    self.canvasGroup = GetCanvasGroup(self.gameObject)
    self.show_text = self.Text:GetComponent("Text")
    self.img_component = self.img_bg:GetComponent("Image")

    if self.is_need_SetText then
        self:SetText()
    end
end

function TextNotify:__reset(...)
    TextNotify.super.__reset(self,...)
    self:SetScale(1.0)
    self:SetPosition(TextNotify.BaseX, TextNotify.BaseY, 0)
    self.canvasGroup.alpha = 0

    self:SetOrderByParentMax()
end

function TextNotify:__clear()
    self:StopAction()
    SystemTipManager:GetInstance():RemoveTextNotify(self)
    TextNotify.super.__clear(self)
end

function TextNotify:DoAction(str)
    self.str = str
    self:SetText()
end

function TextNotify:SetText()
    if self.is_loaded then
        self.is_need_SetText = false
        self.show_text.text = self.str or ""

        local width = self.show_text.preferredWidth + 120
        width = width < 90 and 90 or width
        SetSizeDeltaX(self.img_bg, width)

        self:StartAction()
    else
        self.is_need_SetText = true
    end
end

function TextNotify:StartAction()
    self:StopAction()
    
    self:SetPosition(TextNotify.BaseX, TextNotify.BaseY, 0)
    self.canvasGroup.alpha = 0

    self.notifyAction = cc.Spawn(
            cc.FadeIn(TextNotify.fadeInTime, self.canvasGroup),
            cc.MoveTo(TextNotify.fadeInTime, TextNotify.BaseX, TextNotify.DistanceA, 0)
    )

    local action = cc.Spawn(
            cc.FadeOut(TextNotify.fadeOutTime, self.canvasGroup),
            cc.MoveTo(TextNotify.fadeOutTime, TextNotify.BaseX, TextNotify.DistanceB, 0)
    )
    action = cc.EaseExponentialOut(action)
    
    self.notifyAction = cc.Sequence(self.notifyAction, cc.Sequence(cc.DelayTime(TextNotify.delayTime), action),
            cc.CallFunc(handler(self, self.OnEndCallBack)))
    --self.notifyAction = cc.Sequence(self.notifyAction, cc.CallFunc(handler(self, self.OnEndCallBack)))

    cc.ActionManager:GetInstance():addAction(self.notifyAction, self)
end

function TextNotify:OnEndCallBack()
    self:destroy()
end

function TextNotify:StopAction()
    if self.notifyAction then
        cc.ActionManager:GetInstance():removeAction(self.notifyAction)
        self.notifyAction = nil
    end
end
