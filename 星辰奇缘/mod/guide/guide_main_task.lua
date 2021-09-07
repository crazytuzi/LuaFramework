-- --------------------------
-- 引导-点击主线任务寻路
-- hosr
-- --------------------------
GuideMainTask = GuideMainTask or BaseClass()

function GuideMainTask:__init()
    self.mgr = GuideManager.Instance
    self.callback = nil
    self.mainObj = nil
    self.soundId = 0
    self.event = nil
    self.listener = function() self:OnClick() end
end

function GuideMainTask:Start(args, callback)
    self.callback = callback
    self.soundId = tonumber(args[3])
    self.mainObj = MainUIManager.Instance:GetMainTraceObj()
    if self.mainObj ~= nil and not self.mainObj:Equals(NULL) then
        self.mgr.effect:Show(self.mainObj, Vector2(0, -self.mainObj:GetComponent(RectTransform).rect.height/2), 3)
        TipsManager.Instance:ShowGuide({gameObject = self.mainObj, data = TI18N("点这里开始<color='#ffff00'>任务寻路</color>"), forward = TipsEumn.Forward.Left})
        if self.soundId ~= 0 then
            SoundManager.Instance:Play(self.soundId)
        end
        self.mainObj:GetComponent(Button).onClick:AddListener(self.listener)
    else
        self:OnClick()
    end
end

function GuideMainTask:OnClick()
    GuideManager.Instance.effect:Hide()
    if self.mainObj ~= nil then
        self.mainObj:GetComponent(Button).onClick:RemoveListener(self.listener)
    end
    if self.callback ~= nil then
        self.callback()
    end
    self.callback = nil
    self.mainObj = nil
    self.event = nil
end
