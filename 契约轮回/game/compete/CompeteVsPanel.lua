---
--- Created by  Administrator
--- DateTime: 2019/12/5 15:16
---
CompeteVsPanel = CompeteVsPanel or class("CompeteVsPanel", BasePanel)
local this = CompeteVsPanel

function CompeteVsPanel:ctor(parent_node, parent_panel)
    self.abName = "compete";
    self.image_ab = "compete_image";
    self.assetName = "CompeteVsPanel"
    self.use_background = false
    self.show_sidebar = false
    self.model = CompeteModel:GetInstance()
    self.events = {}
end

function CompeteVsPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end
end

function CompeteVsPanel:Open(data)
    self.data = data
    CompeteVsPanel.super.Open(self)
end


function CompeteVsPanel:LoadCallBack()
    self.nodes = {
        "left","middle","right",
        "left/leftDownObj/leftServer","left/leftRole",
        "left/leftPowerObj/leftPower","left/leftSheng","left/leftDownObj/leftScore","left/leftDownObj/leftLv","left/leftFu",

        "right/rightFu","right/rightSheng","right/rigthDownObj/rightServer","right/rigthDownObj/rightScore",
        "right/rigthDownObj/rightLv","right/rightRole","right/rightPowerObj/rightPower",
        "okBtn",
        "left/leftDownObj","right/rigthDownObj","left/leftPowerObj","right/rightPowerObj"

    }
    self:GetChildren(self.nodes)
    self.leftServer = GetText(self.leftServer)
    self.leftRole = GetImage(self.leftRole)
    self.leftPower = GetText(self.leftPower)
    self.leftSheng = GetText(self.leftSheng)
    self.leftScore = GetText(self.leftScore)
    self.leftLv = GetText(self.leftLv)
    self.leftFu = GetText(self.leftFu)

    self.rightFu = GetText(self.rightFu)
    self.rightSheng = GetText(self.rightSheng)
    self.rightServer = GetText(self.rightServer)
    self.rightScore = GetText(self.rightScore)
    self.rightLv = GetText(self.rightLv)
    self.rightRole = GetImage(self.rightRole)
    self.rightPower = GetText(self.rightPower)
    self.canvasGroup = GetCanvasGroup(self.middle)
    --SetVisible(self.middle,false)
    self:InitUI()
    self:AddEvent()

    self:StartAction()
    self:StartCount()
end

function CompeteVsPanel:InitUI()

    local role1 = self.data.role1
    local role2 = self.data.role2

    self.leftLv.text = string.format("Lv.%s %s",role1.level,role1.name)
    self.leftServer.text = "S."..role1.suid
    self.leftPower.text = role1.power
    self.leftScore.text = role1.score
    self.leftSheng.text = role1.win
    self.leftFu.text = role1.lose

    self.rightLv.text = string.format("Lv.%s %s",role2.level,role2.name)
    self.rightServer.text = "S."..role2.suid
    self.rightPower.text = role2.power
    self.rightScore.text = role2.score
    self.rightSheng.text = role2.win
    self.rightFu.text = role2.lose

    local role1Gender = "compete_gender1"
    if role1.gender == 2 then
        role1Gender = "compete_gender2"
    end
    lua_resMgr:SetImageTexture(self, self.leftRole, "compete_image", role1Gender, true)


    local role2Gender = "compete_gender1"
    if role2.gender == 2 then
        role2Gender = "compete_gender2"
    end
    lua_resMgr:SetImageTexture(self, self.rightRole, "compete_image", role2Gender, true)
end

function CompeteVsPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
end

function CompeteVsPanel:StartAction()
    self.canvasGroup.alpha = 0
    local moveAction = cc.MoveTo(0.3, 10, 0, 0)
    moveAction = cc.EaseIn(moveAction,4)
    local function end_call_back()
        local moveAction = cc.MoveTo(0.2, 0, 0, 0)
        local function call_back()
           -- logError("11212")
            local moveAction1 = cc.MoveTo(10, 50, 0, 0)
            cc.ActionManager:addAction(moveAction1, self.leftDownObj);

            local moveAction2 = cc.MoveTo(15, 50, 0, 0)
            cc.ActionManager:addAction(moveAction2,self.leftPowerObj);


            local moveAction3 = cc.MoveTo(12, -115, 0, 0)
            cc.ActionManager:addAction(moveAction3,self.leftRole.transform);
        end
        local sys_action = cc.Sequence(cc.DelayTime(0),moveAction,cc.CallFunc(call_back))
        cc.ActionManager:GetInstance():addAction(sys_action, self.left)

    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action,moveAction,call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.left)


    local moveAction = cc.MoveTo(0.3, -10, 0, 0)
    moveAction = cc.EaseIn(moveAction,4)
    local function end_call_back()
        local moveAction = cc.MoveTo(0.2, 0, 0, 0)
        local function call_back()
               -- SetVisible(self.middle,true)
            local moveAction1 = cc.MoveTo(10, -50, 0, 0)
            cc.ActionManager:addAction(moveAction1, self.rigthDownObj);

            local moveAction2 = cc.MoveTo(15, 675, 0, 0)
            cc.ActionManager:addAction(moveAction2,self.rightPowerObj);


            local moveAction3 = cc.MoveTo(12, 175, 68, 0)
            cc.ActionManager:addAction(moveAction3,self.rightRole.transform);
        end
        local sys_action = cc.Sequence(cc.DelayTime(0),moveAction,cc.CallFunc(call_back))
        cc.ActionManager:GetInstance():addAction(sys_action, self.right)


        local alphaAction  = cc.FadeTo(0.2,1 ,self.canvasGroup)
        cc.ActionManager:addAction(alphaAction, self.canvasGroup);
    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action,moveAction,call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.right)
end

function CompeteVsPanel:StartCount()
    local time = 3
    local function callBack()
        time = time - 1
        --if self.tips then
        --    self.tips.text = "提示："..tostring(time) .. "秒后自动关闭";
        --end
        if time <= 0 then
            self:Close()
        end
    end
    self.autoschedule = GlobalSchedule:Start(callBack, 1, -1);
end