DungeonExit = DungeonExit or class("DungeonExit", BaseItem);
local this = DungeonExit

function DungeonExit:ctor(parent_node)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonExit"
    self.layer = "UI"
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    DungeonExit.super.Load(self)
end

function DungeonExit:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end
    self.autoschedule = nil;
end

function DungeonExit:LoadCallBack()
    self.nodes = {
        "exitBtn", "endTime", "endTime/auto_text", "endTime/endText", "endTime/timeTimebg",
        "exitBtn/arrow",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.arrow,false)
    SetAlignType(self.exitBtn, bit.bor(AlignType.Right, AlignType.Top))

    SetAlignType(self.endTime, bit.bor(AlignType.Null, AlignType.Top))

    self:InitUI();

    self:AddEvents();
end



function DungeonExit:InitUI()
    self.exitBtn = GetButton(self.exitBtn);
    self.endText = GetText(self.endText);

    SetGameObjectActive(self.endTime, false);

    if self.end_time and self.autoschedule == nil then
        self:HandleAutoExit();
    end

end

function DungeonExit:AddEvents()
    --退出按钮事件
    AddClickEvent(self.exitBtn.gameObject, handler(self, self.HandleExit));

    local call_back = function()
        self.exitBtn.gameObject:SetActive(false);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        self.exitBtn.gameObject:SetActive(true);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);

    AddEventListenerInTab(DungeonEvent.DUNGEON_AUTO_EXIT, handler(self, self.HandleAutoExit), self.events);

    AddEventListenerInTab(DungeonEvent.DUNGEON_CODE_EXIT, handler(self, self.HandleCodeExit), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);
end

function DungeonExit:HandleAutoExit(time, fun)
    if self.immediatelyExit then
        if fun then
            fun();
            fun = nil
        end
        self.immediatelyExit = nil;
        return ;
    end
    time = time or 10;
    self.call_back_fun = fun;
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end
    self.end_time = os.time() + time;
    if self.is_loaded then
        self.autoschedule = GlobalSchedule.StartFun(handler(self, self.StartAutoClose), 0.2, -1);
    end
end

function DungeonExit:HandleCodeExit(fun)
    self.codeExitFun = fun;
    self:HandleExit();
end

function DungeonExit:StartAutoClose()
    local timeTab;
    local timestr = "";
    local formatTime = "%02d";
    if self.end_time then
        SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) or tonumber(timeTab.sec) < 1 then
            GlobalSchedule.StopFun(self.autoschedule);
            SetGameObjectActive(self.endTime.gameObject, false);
            self.autoschedule = nil;
            if self.call_back_fun then
                self.call_back_fun();
                self.call_back_fun = nil;
            end
        else
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endText.text = "" .. timestr;
        end
    end
    local dungeConfig = Config.db_dunge[DungeonModel:GetInstance().curDungeonID];
    if dungeConfig and dungeConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS then
        SetGameObjectActive(self.endTime, false);
    end
end

function DungeonExit:Start()

end

function DungeonExit:HandleExit(target, x, y)
    self.immediatelyExit = true;
    --if Dialog.ShowTwo("提示" , "你确定退出副本吗?\n(当前退出会消耗副本次数)" , "确定" , handler(self,self.SendExitDungeon) , nil , "取消" , nil , nil )
    local sceneid = SceneManager:GetInstance():GetSceneId();
    local config = Config.db_scene[sceneid] or {}
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EXP then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COIN then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD then
        Dialog.ShowTwo("Tip", "Are you sure to exit Guild Guard and give up massive EXP?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EQUIP then
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_MELEEWAR then
        Dialog.ShowTwo("Tip", "If you leave brawl battleground now,all points you earned will be cleared.\nExit?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER then
        self:DungeonExit();
        --Dialog.ShowTwo("提示", "你确定退出副本吗?\n(当前退出会消耗副本次数)", "确定", handler(self, self.DungeonExit), nil, "取消", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MOUNT then
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil);
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_PET then
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave? (Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_DAILY then
        --日常副本
        Dialog.ShowTwo("Tip", "This quest is not finished yet,\nEXit?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE then
        --新手副本分裂
        Dialog.ShowTwo("Tip", "This quest is not finished yet,\nEXit?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
        --elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_NEWBIE_BOSS then --新手副本分裂
        --    Dialog.ShowTwo("提示", "当前任务还未完成，\n是否退出？", "确定", handler(self, self.RealExit), nil, "取消", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL then --圣痕秘境
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_GOD then -- 神灵之路
        self:DungeonExit()

    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_TIMEBOSS then
        Dialog.ShowTwo("Tip", "Are you sure to leave current scene?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR then
        Dialog.ShowTwo("Tip", "Are you sure to leave current scene?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    else
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig then
            if sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_PET or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
                --蛮荒地图：怒气不满100就给提示，怒气已满100就不用给了
                local data = DungeonModel:GetInstance().angryData;
                if data and tonumber(data.anger or 0) >= 100 then
                    self:RealExit();
                else
                    Dialog.ShowTwo("Tip", "Are you sure to leave current scene?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
                end
            elseif sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME then
                --家园地图：如果该图所要求的VIP，大于自己当前的VIP时才给提示框
                local viptab = String2Table(sceneConfig.free);
                if viptab and #viptab > 1 then
                    if viptab[1] == "vip" then
                        if tonumber(viptab[2]) > 4 then
                            --4是当前VIP等级
                            Dialog.ShowTwo("Tip", "Are you sure to leave current scene?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
                        else
                            self:RealExit();
                        end
                    else
                        self:RealExit();
                    end
                end
            elseif sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD 
              or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_NOTIRED then
                Dialog.ShowTwo("Tip", "Leave the dungeon?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil,
                        "Don't notice anymore until next time I log in" , false , nil,"worldbossexitid");
            else
                self:RealExit();
            end
        end
    end

end
function DungeonExit:DungeonExit()
    TaskModel:GetInstance():SetDungeonTaskState(false)
    DungeonCtrl:GetInstance():RequestLeaveDungeon();
    if self.codeExitFun then
        self.codeExitFun();
    end
    self.codeExitFun = nil;
end

function DungeonExit:RealExit()
    SceneControler:GetInstance():RequestSceneLeave();
end

function DungeonExit:ShowArrow(isShow)
    SetGameObjectActive(self.arrow.gameObject , isShow);
    if isShow then
        local action = cc.MoveTo(0.5, -82, -4.5)
        action = cc.Sequence(action, cc.MoveTo(0.5, -72,-4.5))
        action = cc.Repeat(action, 4)
        action = cc.RepeatForever(action)
        cc.ActionManager:GetInstance():addAction(action, self.arrow)
    end

end