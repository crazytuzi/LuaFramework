---
--- Created by  Administrator
--- DateTime: 2020/6/4 20:01
---
FactionSerWardDungeEndPanel = FactionSerWardDungeEndPanel or class("FactionSerWardDungeEndPanel", BasePanel)
local this = FactionSerWardDungeEndPanel

function FactionSerWardDungeEndPanel:ctor()
    self.abName = "dungeon"
    self.assetName = "FactionSerWardDungeEndPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
   -- FactionSerWardDungeEndPanel.super.Load(self)
end

function FactionSerWardDungeEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end

    if self.effect_Win ~= nil then
        self.effect_Win:destroy()
    end

    if self.effect_Win2 ~= nil then
        self.effect_Win2:destroy()
    end
end


function FactionSerWardDungeEndPanel:Open(isWin)
    self.isWin = isWin
    WindowPanel.Open(self)
end


function FactionSerWardDungeEndPanel:LoadCallBack()
    self.nodes = {
        "sureBtn","lose","autoCloseText","win/bg","win/WinEffect","win"
    }
    self:GetChildren(self.nodes)
    self.autoCloseText = GetText(self.autoCloseText)
    self:InitUI()
    self:AddEvent()
    self:StartAutoClose(5)
    LayerManager:GetInstance():AddOrderIndexByCls(self, self.bg, nil, true, nil, false, 5)
    --SetVisible(self.win,self.isWin)
    --SetVisible(self.lose,not self.isWin)
end

function FactionSerWardDungeEndPanel:InitUI()
    if self.isWin then
        self:LoadWinEffect()
        SetGameObjectActive(self.win.gameObject,true)
        SetGameObjectActive(self.lose.gameObject,false)
    else
        SetGameObjectActive(self.win.gameObject,false)
        SetGameObjectActive(self.lose.gameObject,true)
    end
end

function FactionSerWardDungeEndPanel:LoadWinEffect()
    self.effect_Win = UIEffect(self.WinEffect, 10401, false, self.layer)
    self.effect_Win:SetConfig({ orderOffset = 3 , })

    self.effect_Win2 = UIEffect(self.WinEffect, 10402, false, self.layer)
    self.effect_Win2:SetConfig({ scale = 1.06, orderOffset = 7, pos = { x = 0, y = 10, z = 0 } })
end

function FactionSerWardDungeEndPanel:AddEvent()
    
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.sureBtn.gameObject,call_back)
end

function FactionSerWardDungeEndPanel:StartAutoClose(closetime)
    closetime = closetime or 60;
    local function callBack1 (data)
        closetime = closetime - 1;
        --以下这个迟点要注释掉,因为想改成按钮上的文字显示关闭
        if self.autoCloseText then
            self.autoCloseText.text = tostring(closetime) .. "sec later auto close";
        end
        if closetime <= 0 then
            --SceneControler:GetInstance():RequestSceneLeave();
            --if self.autoCloseFun then
            --    self.autoCloseFun();
            --    self.autoCloseFun = nil;
            --end
            --GlobalSchedule.StopFun(self.autoschedule);
            --SetGameObjectActive(self.autoCloseText, false);
            self:Close()
        end
    end
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end
   -- self:SetBtnText(closetime);
    self.autoschedule = GlobalSchedule:Start(callBack1, 1, -1);
end

