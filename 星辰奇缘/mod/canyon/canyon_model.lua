-- 峡谷之巅-model
-- @author hze
-- @date 2018/07/20

CanYonModel = CanYonModel or BaseClass()

function CanYonModel:__init()
end

function CanYonModel:__delete()

end

--对战信息
function CanYonModel:OpenFightInfoPanel()
    if self.fightinfopanel == nil then
        self.fightinfopanel = CanYonFightInfoPanel.New(self)
    end
    self.fightinfopanel:Show()
end

function CanYonModel:CloseFightInfoPanel()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:DeleteMe()
        self.fightinfopanel = nil
    end
end

--攻塔
function CanYonModel:OnAttackFire()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:AttackFire()
    end
end

--守塔
function CanYonModel:OnDefend()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:Defend()
    end
end

--有效区域内
function CanYonModel:EnterArea(data)
    -- BaseUtils.dump(data, "进入")
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:OnEnterArea(data)
    end
end

--改变守塔的图标标志
function CanYonModel:ChangeDefendIcon(Open)
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:ChangeDefendIcon(Open)
    end
end

--cd时操作锁定
function CanYonModel:FinishMotion(id)
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:LockBtn(id)
    end
end

--地图
function CanYonModel:OpenMapWindow()
    if self.mapwindow == nil then
        self.mapwindow = CanYonMapWindow.New(self)
    end
    self.mapwindow:Open()
end

function CanYonModel:CloseMapWindow()
    if self.mapwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mapwindow)
    end
end

--开启塔控制器
function CanYonModel:StartTowerControll()
    if self.towercontroller == nil then
        self.towercontroller = CanYonTowerControl.New(self)
    end
end

--关闭塔控制器
function CanYonModel:StopTowerControll()
    if self.towercontroller ~= nil then
        self.towercontroller:DeleteMe()
        self.towercontroller = nil
    end
end

--结算面板
function CanYonModel:OpenResultpanel(args)
    if self.resultpanel == nil then
        self.resultpanel = CanyonResultPanel.New(self)
    end
    self.resultpanel:Show(args)
end

function CanYonModel:CloseResultpanel()
    if self.resultpanel ~= nil then
        self.resultpanel:DeleteMe()
        self.resultpanel = nil
    end
end

--阵营排行信息
function CanYonModel:OpenMemberFightInfoRankPanel()
    if self.memberfight_rankpanel == nil then
        self.memberfight_rankpanel = CanYonMemberFightRankPanel.New(self)
    end
    self.memberfight_rankpanel:Show()
end

function CanYonModel:CloseMemberFightInfoRankPanel()
    if self.memberfight_rankpanel ~= nil then
        self.memberfight_rankpanel:DeleteMe()
        self.memberfight_rankpanel = nil
    end
end

--便捷组队面板
function CanYonModel:OpenMakeTeamPanel()
    if self.make_team_panel == nil then
        self.make_team_panel = CanyonMakeTeamPanel.New(self)
    end
    self.make_team_panel:Show()
end
--关闭组队面板
function CanYonModel:CloseMakeTeamPanel()
    if self.make_team_panel ~= nil then
        self.make_team_panel:DeleteMe()
        self.make_team_panel = nil
    end
end

--规则描述面板
function CanYonModel:OpenDescPanel()
    if self.desc_panel == nil then 
        self.desc_panel = CanyonDescPanel.New(self)
    end
    self.desc_panel:Show()
end

function CanYonModel:CloseDescPanel()
    if self.desc_panel ~= nil then 
        self.desc_panel:DeleteMe()
        self.desc_panel = nil 
    end
end