-- ---------------------------------
-- 引导-关闭界面
-- hosr
-- ---------------------------------
GuideCloseWin = GuideCloseWin or BaseClass()

function GuideCloseWin:__init()
    self.mgr = GuideManager.Instance
    self.callback = nil
    --关闭按钮路径
    self.btnPath = nil
    --关闭的界面id
    self.panelId = nil
    --标签ID
    self.tabId = nil
    --音效id
    self.soundId = 0

    self.close = function(arg) self:OnClose(arg) end
end

function GuideCloseWin:Start(args, callback)
    self.callback = callback
    self.panelId = self.mgr.funcIdToPanelId[tonumber(args[2])]
    self.tabId = tonumber(args[3])
    self.btnPath = tostring(args[4])
    self.soundId = tonumber(args[6])
    local win = nil
    -- if self.tabId ~= 0 then
    --     if self.panelId == windows.panel.backpack then
    --         win = ui_backpack.get_sub_obj(self.tabId)
    --     elseif self.panelId == windows.panel.skill then
    --         win = ui_skill.get_sub_obj(self.tabId)
    --     elseif self.panelId == windows.panel.pet then
    --         win = ui_pet.get_sub_obj(self.tabId)
    --     elseif self.panelId == windows.panel.guardian then
    --     end
    -- else
        -- win = windows.get_obj(self.panelId)
    -- end
    win = WindowManager.Instance.currentWin.gameObject

    if win ~= nil then
        local trans = win.transform:Find(self.btnPath)
        if trans == nil or trans:Equals(NULL) then
            print(string.format("不存在按钮 path=%s", self.btnPath))
            self:Error()
        else
            self.mgr.effect:Show(trans.gameObject, Vector2.zero, 2)
            TipsManager.Instance:ShowGuide({gameObject = trans.gameObject, data = TI18N("点击关闭界面"), forward = TipsEumn.Forward.Left})
            if self.soundId ~= 0 then
                SoundManager.Instance:Play(self.soundId)
            end
        end
    else
        print(string.format("不存在界面 ID=%s", self.panelId))
        self:Error()
    end
end

function GuideCloseWin:OnClose(arg)
    if arg == self.panelId then
        self:Finish()
    end
end

function GuideCloseWin:Finish()
    GuideManager.Instance.effect:Hide()
    self.btnPath = nil
    self.panelId = nil
    if self.callback ~= nil then
        self:callback()
    end
    self.callback = nil
end

function GuideClickBtn:Error()
   self.callback = nil
   self:Finish()
   GuideManager.Instance:Finish()
end
