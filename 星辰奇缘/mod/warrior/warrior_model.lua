WarriorModel = WarriorModel or BaseClass(BaseModel)

function WarriorModel:__init()
    self.warrior_magic_buff = {}
    self.warriors = {}
    self.scenePanel = nil
    self.score1 = 0
    self.score2 = 0
    self.pos_list = {}

    self.mode = 0   -- 未知模式

    self.reviveTime = 4
    self.readyDesc = TI18N("1.活动开始后，将随机划分至<color='#ffff00'>2个阵营</color>，每<color='#ffff00'>30秒</color>匹配战斗，拥有<color='#ffff00'>%s</color>次复活机会\n2.<color=#ffff00>圣剑</color>将在开场<color=#ffff00>5分钟</color>时奖励，圣剑持有人将获得攻击加成、定时功勋奖励\n3.战斗胜利可夺取对方的圣剑，最终获胜的阵营将开启<color=#ffff00>战场宝箱</color>")
    self.readyDesc = string.format(self.readyDesc, tostring(self.reviveTime))

    self.battleString = TI18N("1.在常规模式基础上，世界等级<color=#13fc60>50</color>级后新增<color=#13fc60>生存模式</color>、<color=#13fc60>60</color>级新增<color=#13fc60>策反模式</color>、<color=#13fc60>70</color>级增加<color=#13fc60>萌宠模式</color>\n2.每周将随机开启一种，本次勇士战场为<color=#13fc60>%s</color>")

    self.titleString = {
        [1] = TI18N("常规模式"),
        [2] = TI18N("生存模式"),
        [3] = TI18N("策反模式"),
        [4] = TI18N("萌宠模式")
    }
    self.modeString = {
        [1] = self.readyDesc,
        [2] = TI18N("1.活动开始后，将随机划分至<color='#13fc60'>2个阵营</color>，每<color='#13fc60'>30秒</color>匹配战斗，拥有<color='#13fc60'>4</color>次复活机会\n2.每回合结束时，所有人将<color=#13fc60>自动损失一定生命值</color>\n3.单位生命值<color=#13fc60>低于20%</color>时，将不再受此影响\n4.最终获胜的阵营将开启<color=#13fc60>战场宝箱</color>"),
        [3] = TI18N("1.活动开始后，将随机划分至<color='#13fc60'>2个阵营</color>，每<color='#13fc60'>30秒</color>匹配战斗，拥有<color='#13fc60'>4</color>次复活机会\n2.每场战斗开始时，双方将<color='#13fc60'>随机交换1-2名守护</color>\n3.最终获胜的阵营将开启<color=#13fc60>战场宝箱</color>"),
        [4] = TI18N("1.战斗中可同时安排<color='#13fc60'>3只宠物</color>和<color='#13fc60'>2名守护</color>\n2.宠物分1只<color='#13fc60'>主战宠</color>和2只<color='#13fc60'>辅战宠</color>\n3.主战宠即玩家的出战宠物，可在战斗中进行操作，辅战宠<color='#13fc60'>无法操作</color>\n4.未设置辅战宠时，自动上阵高等级宠物\n5.最终获胜的阵营将开启<color='#13fc60'>战场宝箱</color>"),
    }
    self.modeShortString = {
        [1] = TI18N("1.随机划分<color=#ffff00>2个阵营</color>，每<color=#ffff00>30秒</color>匹配战斗，拥有<color=#ffff00>4</color>次复活机会\n2.夺得<color=#ffff00>圣剑</color>将获得大量<color='#ffff00'>功勋奖励</color>\n3.最终获得胜利的阵营将开启<color='#ffff00'>战场宝箱</color>"),
        [2] = TI18N("1.随机划分<color=#ffff00>2个阵营</color>，每<color=#ffff00>30秒</color>匹配战斗，拥有<color=#ffff00>4</color>次复活机会\n2.每回合<color=#ffff00>结束</color>时，所有单位将<color=#ffff00>自动损失一定生命值</color>\n3.最终获胜的阵营将开启<color=#ffff00>战场宝箱</color>"),
        [3] = TI18N("1.随机划分<color=#ffff00>2个阵营</color>，每<color=#ffff00>30秒</color>匹配战斗，拥有<color=#ffff00>4</color>次复活机会\n2.每场战斗开始时，双方将<color='#ffff00'>随机交换1-2名守护</color>\n3.最终获胜的阵营将开启<color=#ffff00>战场宝箱</color>"),
        [4] = TI18N("1.战斗将同时上阵<color='#ffff00'>3只宠物</color>和<color='#ffff00'>2名守护</color>\n2.主战宠可在战斗中进行操作，辅战宠<color='#ffff00'>无法操作</color>\n3.最终获胜的阵营将开启<color='#ffff00'>战场宝箱</color>"),
    }
    self.modeRes = {
        [1] = "NormalModeI18N",
        [2] = "SurvivedModeI18N",
        [3] = "SubvertModeI18N",
        [4] = "CutepetModeI18N",
    }
end

function WarriorModel:__delete()

end

function WarriorModel:EnterScene()
    if self.scenePanel == nil then
        self.scenePanel = WarriorMainUIPanel.New(self)
    end
    self.scenePanel:Show()

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {17, 107})
    end
end

function WarriorModel:ExitScene()
    if self.scenePanel ~= nil then
        self.scenePanel:DeleteMe()
        self.scenePanel = nil

        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)

        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {107})
        end
    end
end

function WarriorModel:UpdateScene()
    local phase = self.phase
    if self.scenePanel ~= nil and self.scenePanel.mainObj ~= nil then
        if phase == 4 or phase == 5 then
            self.scenePanel.isShow = true
            self.scenePanel:Dropdown()
        else
            self.scenePanel.isShow = false
            self.scenePanel:Dropdown()
        end
        self.scenePanel:ShowCountDown()
    end
end

function WarriorModel:SetStatus(data)
    self.phase = data.phase
    self.restTime = data.time
end

function WarriorModel:SetTop3(warriors)

end

function WarriorModel:OpenWindow(args)
    if self.warriorWin == nil then
        self.warriorWin = WarriorWindow.New(self)
    end
    self.warriorWin:Open(args)
end

function WarriorModel:Close()
    if self.warriorWin ~= nil then
        WindowManager.Instance:CloseWindow(self.warriorWin)
    end
end

function WarriorModel:UpdateScores()
    if self.scenePanel ~= nil then
        self.scenePanel:UpdateScore()
    end
end

function WarriorModel:OpenSettle(args)
    BaseUtils.dump(args)
    if self.settleWin == nil then
        self.settleWin = WarriorSettleWindow.New(self)
    end
    self.settleWin:Open(args)
end

function WarriorModel:OpenDesc(args)
    if self.descWin == nil then
        self.descWin = WarriorDescWindow.New(self)
    end
    self.descWin:Open(args)
end
