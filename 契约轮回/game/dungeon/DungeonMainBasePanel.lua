--
-- @Author: LaoY
-- @Date:   2018-12-11 20:18:17
-- 副本等玩法 主界面基类，主要控制自动关闭

DungeonMainBasePanel = DungeonMainBasePanel or class("DungeonMainBasePanel",BasePanel)
local this = DungeonMainBasePanel
function DungeonMainBasePanel:ctor()
    self.layer = "Bottom"
    self.model = DungeonModel.GetInstance()
    self.events1 = {};
end

function DungeonMainBasePanel:dctor()
	if self.event_leave_dungeon then
		GlobalEvent:RemoveListener(self.event_leave_dungeon)
		self.event_leave_dungeon = nil
	end

	if self.dungeonExit then
		self.dungeonExit:destroy()
		self.dungeonExit = nil
	end

    if self.countDown then
        self.countDown:destroy();
    end
    GlobalEvent.RemoveTabEventListener(self.events1);
end


-- 派生类不需要重复调用
function DungeonMainBasePanel:AddEvent()
	if not self.event_leave_dungeon then
		local function call_back()
			self:Close()
		end
		self.event_leave_dungeon = GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE,call_back)
	end
    GlobalEvent.AddEventListenerInTab(EventName.GameReset , function() self:destroy() end , self.events1);
end

function DungeonMainBasePanel:AfterCreate()
	DungeonMainBasePanel.AddEvent(self)
	-- self.dungeonExit = DungeonExit(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.UI));
	self.dungeonExit = DungeonExit(self.child_transform);--
	--self.dungeonExit = DungeonExit(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.UI));
	DungeonMainBasePanel.super.AfterCreate(self)
 
	-- 进入副本停止移动，开始自动战斗
	-- TaskModel:GetInstance():StopTask()
    OperationManager:GetInstance():StopAStarMove();
    AutoFightManager:GetInstance():StartAutoFight()
end

function DungeonMainBasePanel:EndDungeon()
    if self.hideByIcon or self.dungeon_is_exit or self.startSchedule then
        SetGameObjectActive(self.endTime.gameObject , false);
    end
end

--开启一个倒计时退出
function DungeonMainBasePanel:StartExitCountDown(sec)
    if self.countDown then
        self.countDown:destroy();
    end
    self.countDown = DungeonCountDownExit(self.transform or LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Top),"UI" , (sec + os.time()));
end



function DungeonMainBasePanel:HandleDungeonStartCountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";--"%02d";
    if self.startDungeonTime then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.startDungeonTime);

        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.startSchedule);
            if self.startTime and self.startTime.gameObject then
                SetGameObjectActive(self.startTime.gameObject , false);
            end
            if self.endDungeonStartCountDownFun then
                self.endDungeonStartCountDownFun();
            end
            self.startSchedule = nil;
        else
            --timeTab.min = timeTab.min or 0;
            --if timeTab.min then
            --    timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            --end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.time.text = timestr;
        end
    end
end
