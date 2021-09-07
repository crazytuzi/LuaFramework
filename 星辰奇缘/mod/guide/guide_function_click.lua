-- ------------------------------------
-- 引导--指引功能按钮
-- hosr
-- ------------------------------------
GuideFuncBtn = GuideFuncBtn or BaseClass()

function GuideFuncBtn:__init()
    self.callback = nil
    self.funcId = 0
    self.button = nil
    self.event = nil
    self.soundId = 0
    self.listener = function() self:Finish() end
end
--注意：正常执行的时候，不会 calback，需要在打开对应的Window处理下步指引
--原因：窗口初始化是异步回调的，只能在窗口初始化完毕后才能回调指引(GuideManager.Instance:OpenWindow(winID))，否则可能导致下步引导找不到gameObject
function GuideFuncBtn:Start(args, callback)
    self.callback = callback
    self.funcId = tonumber(args[2])
    self.soundId = tonumber(args[4])
    self.desc = args[5] or TI18N("点击这里")
    self.forward = tonumber(args[6])
    local pos = nil
    if self.funcId == 10500 then
        if MainUIManager.Instance.petInfoView ~= nil then
            self.button = MainUIManager.Instance.petInfoView.barBg
            pos = Vector2(65, -5)
        end
    elseif self.funcId == 17 then
        if MainUIManager.Instance.MainUIIconView ~= nil then
            self.button = MainUIManager.Instance.MainUIIconView:getbuttonbyid(self.funcId)
            pos = Vector2(0, 25)
        end
    elseif self.funcId == 14 then
        if MainUIManager.Instance.MainUIIconView ~= nil then
            self.button = MainUIManager.Instance.MainUIIconView:getbuttonbyid(self.funcId)
            pos = Vector2(15, 30)
        end
    else
        if MainUIManager.Instance.MainUIIconView ~= nil then
            self.button = MainUIManager.Instance.MainUIIconView:getbuttonbyid(self.funcId)
            pos = Vector2(0, 40)
        end
    end
    if self.button ~= nil then
        MainUIManager.Instance.MainUIIconView:showbaseicon(true, true)
        if self.funcId == 10500 then
            GuideManager.Instance.effect:Show(self.button, pos, 4, {gameObject = self.button, data = self.desc, forward = self.forward})
        else
            GuideManager.Instance.effect:Show(self.button, pos, 1, {gameObject = self.button, data = self.desc, forward = self.forward})
        end
        -- TipsManager.Instance:ShowGuide({gameObject = self.button, data = self.desc})
        if DataSystem.data_icon[self.funcId] and DataSystem.data_icon[self.funcId].icon_type == 1 then
            GuideManager.Instance.isfunctionguide = true
        end
        if self.soundId ~= 0 then
            SoundManager.Instance:Play(self.soundId)
        end
    else
        print(string.format("不存在功能按钮 ID=%s", self.funcId))
        self:Finish()
        GuideManager.Instance:Finish()
        self.callback = nil
        self:OnOpen(GuideManager.Instance.funcIdToPanelId[self.funcId])
    end
end

function GuideFuncBtn:Finish()
    if DataSystem.data_icon[self.funcId] and DataSystem.data_icon[self.funcId].icon_type == 1 then
        GuideManager.Instance.isfunctionguide = false
    end
    GuideManager.Instance.effect:Hide()
    self.button = nil
    self.event = nil
end

function GuideFuncBtn:OnOpen(arg)
    if arg == GuideManager.Instance.funcIdToPanelId[self.funcId] then
        GuideManager.Instance.effect:Hide()
        if self.callback ~= nil then
            self.callback()
        end
        self.callback = nil
        self.funcId = 0
    end
end
