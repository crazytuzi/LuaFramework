-- -----------------------------------
-- 引导-点击按钮
-- hosr
-- -----------------------------------
GuideClickBtn = GuideClickBtn or BaseClass()

function GuideClickBtn:__init()
    self.mgr = GuideManager.Instance
    self.callback = nil
    --按钮路径
    self.btnPath = nil
    --界面id
    self.panelId = nil
    --标签ID
    self.tabId = nil
    --音效id
    self.soundId = 0

    self.event = nil

    self.listener =
    function()
        self:Finish()
    end

    self.close = function(arg) self:OnClose(arg) end

    self.button = nil
end

function GuideClickBtn:Start(args, callback)
    self.callback = callback
    self.panelId = self.mgr.funcIdToPanelId[tonumber(args[2])]
    self.tabId = tonumber(args[3])
    self.btnPath = tostring(args[4])
    self.soundId = tonumber(args[6])
    self.desc = args[7] or TI18N("点击这里")
    self.forward = tonumber(args[8])
    self.offsetX =  tonumber(args[9]) or 0
    self.offsetY =  tonumber(args[10]) or 0
    self.nextNew = false
    if args[11] ~= nil then
     self.nextNew = tonumber(args[11]) > 0
    end
    local isSpecial = false
    local win = nil
    -- if self.tabId ~= 0 then
    --     if self.panelId == WindowConfig.WinID.backpack then
    --         win = ui_backpack.get_sub_obj(self.tabId)
    --     elseif self.panelId == WindowConfig.WinID.skill then
    --         win = ui_skill.get_sub_obj(self.tabId)
    --     elseif self.panelId == WindowConfig.WinID.pet then
    --         win = ui_pet.get_sub_obj(self.tabId)
    --     elseif self.panelId == WindowConfig.WinID.guardian then
    --         if self.tabId == 3 then
    --             isSpecial = true
    --             win = ui_shouhu_pub.get_can_recruit_btn()
    --         end
    --     elseif self.panelId == WindowConfig.WinID.agendamain then
    --         if self.tabId == 1 then
    --             isSpecial = true
    --             win = AgendaManager.Instance.controller.mainpanel:GetStartBtnByID(true, 1002)
    --         end
    --     elseif self.panelId == WindowConfig.WinID.arena_window then
    --         isSpecial = true
    --         win = ArenaManager.Instance.oneChallengeButton
    --     end
    -- else
        -- win = windows.get_obj(self.panelId)
    -- end
    if WindowManager.Instance.currentWin ~= nil then
        local winId = WindowManager.Instance.currentWin.windowId
        win = WindowManager.Instance.currentWin.gameObject
    end

    if win ~= nil then
        local trans = nil
        if isSpecial then
            trans = win.transform
        else
            trans = win.transform:Find(self.btnPath)
        end
        if trans == nil or trans:Equals(NULL) then
            print(string.format("不存在按钮 path=%s", self.btnPath))
            self:Error()
        else
            MainUIManager.Instance.MainUIIconView:showbaseicon(true, true)
            self.button = trans.gameObject
            if not self.nextNew then
               self.button:GetComponent(Button).onClick:AddListener(self.listener)
            end
            if self.soundId ~= 0 then
                SoundManager.Instance:Play(self.soundId)
            end
            self.mgr.effect:Show(self.button, Vector2(self.offsetX,self.offsetY), winId)
            TipsManager.Instance:ShowGuide({gameObject = self.button, data = self.desc, forward = self.forward})
        end
    else
        print(string.format("不存在界面 ID=%s", self.panelId))
        self:Error()
    end
end

function GuideClickBtn:Finish()
    if not BaseUtils.isnull(self.button) then
        self.button:GetComponent(Button).onClick:RemoveListener(self.listener)
    end
    self.mgr.effect:Hide()
    self.btnPath = nil
    self.panelId = nil
    self.tabId = nil
    self.soundId = 0
    self.event = nil
    self.nextNew = false
    self.offsetX = 0
    self.offsetY = 0
    if self.callback ~= nil then
        self.callback()
    end
end

function GuideClickBtn:OnClose(arg)
    if arg == self.panelId then
        self.callback = nil
        self:Finish()
        GuideManager.Instance:Interupt()
    end
end

function GuideClickBtn:Error()
   self.callback = nil
   self:Finish()
   GuideManager.Instance:Finish()
end
