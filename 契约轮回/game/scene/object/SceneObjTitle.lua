---
--- Created by  Administrator
--- DateTime: 2019/10/29 19:27
---
SceneObjTitle = SceneObjTitle or class("SceneObjTitle", BaseWidget)
local this = SceneObjTitle

SceneObjTitle.FadeInTime = 0.8 --渐入时间
SceneObjTitle.FadeOutTime = 1 --渐隐时间
SceneObjTitle.StartAlpha = 0.7 --初始透明度
SceneObjTitle.EndAlpha = 0 --结束透明度
SceneObjTitle.pauseTime = 1  --暂停时间

SceneObjTitle.posX = 280  --中心点在屏幕正中间
SceneObjTitle.posY = 0

function SceneObjTitle:ctor(parent_node, builtin_layer)

    self.abName = "system"
    self.assetName = "SceneObjTitle"
    SceneObjTitle.super.Load(self)
end

function SceneObjTitle:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
    self:StopAction()
end

function SceneObjTitle:LoadCallBack()
    self.nodes = {
        "img"
    }
    self.canvasGroup = GetCanvasGroup(self.gameObject)
    self:GetChildren(self.nodes)
    self.img = GetImage(self.img)
    self:SetPosition(SceneObjTitle.posX,SceneObjTitle.posY)
    self:InitUI()
    self:AddEvent()
end

function SceneObjTitle:InitUI()

end

function SceneObjTitle:AddEvent()

end

function SceneObjTitle:ShowAni(sceneId)
    local function call_back(sprite)
        self.img.sprite = sprite
        self.img:SetNativeSize()
        self:StartAction()
    end
    lua_resMgr:SetImageTexture(self,self.img,"iconasset/icon_sceneTitle",sceneId, false,call_back)
end




function SceneObjTitle:StartAction()
    self:StopAction()
    self.canvasGroup.alpha = SceneObjTitle.StartAlpha
    self.notifyAction = cc.FadeIn(SceneObjTitle.FadeInTime, self.canvasGroup)
    local action = cc.FadeTo(SceneObjTitle.FadeOutTime,SceneObjTitle.EndAlpha ,self.canvasGroup)

    self.notifyAction = cc.Sequence(self.notifyAction, cc.Sequence(cc.DelayTime(SceneObjTitle.pauseTime), action),
            cc.CallFunc(handler(self, self.OnEndCallBack)))

    cc.ActionManager:GetInstance():addAction(self.notifyAction, self)
end

function SceneObjTitle:OnEndCallBack()
    self:destroy()
end

function SceneObjTitle:StopAction()
    if self.notifyAction then
        cc.ActionManager:GetInstance():removeAction(self.notifyAction)
        self.notifyAction = nil
    end
end