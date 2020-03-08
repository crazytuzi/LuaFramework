
-- PlayEffect                   说明：在指定位置播放特效
--                              参数：nResId 特效资源 Id, nX 坐标 X（填 0 或者不填，则表示使用玩家当前坐标）, nY 坐标 Y（填 0 或者不填，则表示使用玩家当前坐标）, nZ 高度 （不填则表示 0）

-- ForbiddenOperation           说明：禁止玩家操作
--                              参数：bForbidden 是否禁止玩家操作， 1 表示禁止玩家操作， 0 表示不禁止
--                              示例：{"ForbiddenOperation", 1},

-- SetAllUiVisable              说明：设置UI显示
--                              参数：bShow 是否显示， 1 表示是， 0 表示否
--                              示例：{"SetAllUiVisable", 1},

-- PlayCameraAnimation          说明：播放录制好的摄像机动画，同时摄像机进入动画模式
--                              参数：相机动画路径
--                              示例：{"PlayCameraAnimation", "ddd/ddd"},

-- PlayCameraEffect             说明：在指定位置播放特效
--                              参数：nResId 特效资源 Id
--                              实例：{"PlayCameraEffect", 206},

-- PlayFactionEffect            说明：门派播放特效
--                              参数：nResId 特效资源 Id
--                              实例：{"PlayFactionEffect", 1， 2， 3， 4, 5},

-- End                          说明：播放CG结束
--                              参数：结束的时间
--                              实例：{"End", 1024},

-- ShowPlayer                   说明：显示玩家
--                              参数：bShow 是否显示， 1 表示是， 0 表示否
--                              实例：{"ShowPlayer", 1},

-- RestoreCamera                说明：恢复相机
--                              参数：时间
--                              实例：{"RestoreCamera", 15},

-- ShowAllRepresentObj          说明：是否显示或隐藏所有对象
--                              参数：是否
--                              实例：{"ShowAllRepresentObj", 1},

-- PlaySound                    说明：播放声音
--                              参数：声音的ID
--                              实例：{"PlaySound", 声音的ID， 延迟多少帧执行},

-- OpenWindow                    说明：打开窗口
--                              参数：窗口的名称
--                              实例：{"OpenWindow", 窗口的名称},

-- CloseWindowTimer                    说明：--单独的定时器关闭界面，不在end的处理中
--                              参数：窗口的名称
--                              实例：{"CloseWindowTimer", 窗口的名称, 帧数},

CGAnimation.tbAllTimer = CGAnimation.tbAllTimer or {};

function CGAnimation:Play(nCGID, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, nCGID, "Play", nCGID);
    if bRet then
        return;
    end 

    local tbCGEvent = self:GetCGAimation(nCGID);
    if not tbCGEvent then
        Log("Error CGAnimation Play", nCGID);
        return;
    end

    for _, tbEvent in ipairs(tbCGEvent) do
        if self[tbEvent.szEvent] then
            local tbParam = {};
            for nI = 1, tbEvent.nMaxParam do
                tbParam[nI] = tbEvent.tbParam[nI] or 0;
            end

            self[tbEvent.szEvent](self, unpack(tbParam));   
        else
            Log("Error CGAnimation Play szEvent", tbEvent.szEvent);
        end    
    end

    Log("CGAnimation Play", nCGID);    
end  

function CGAnimation:End(nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "End");
    if bRet then
        return;
    end    

    self:CloseAllTimer();
    self:ForbiddenOperation(0);
    self:SetAllUiVisable(1);
    self:RestoreCamera();
    self:ShowAllRepresentObj(1);
    Log("CGAnimation End");
end

function CGAnimation:RegisterCallbackTimer(nDelayTime, szIndex, szFun, ...)
    local szName = szFun .. (szIndex or "");
    local nTimer = self.tbAllTimer[szName];
    if nTimer then
        Timer:Close(nTimer);
    end

    self.tbAllTimer[szName] = nil;
    if not nDelayTime or nDelayTime <= 0 then
        return false;
    end

    local funCallback = self[szFun];
    if not funCallback then
        Log("Error CGAnimation RegisterCallbackTimer", szFun);
        return false;
    end     

    self.tbAllTimer[szName] = Timer:Register(nDelayTime, funCallback, self, ...);
    return true;
end

function CGAnimation:CloseAllTimer()
    for _, nTimer in pairs(self.tbAllTimer) do
        Timer:Close(nTimer);
    end

    self.tbAllTimer = {};    
end

function CGAnimation:ForbiddenOperation(nForbidden, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "ForbiddenOperation", nForbidden);
    if bRet then
        return;
    end

    local bForbidden = false;
    if nForbidden == 1 then
        bForbidden = true;
    end    

    Ui:SetForbiddenOperation(bForbidden);
end

function CGAnimation:ShowPlayer(nShow, nDelayTime)
    local pNpc = me.GetNpc();
    if not pNpc and not nDelayTime then
        nDelayTime = 5;
    end    

    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "ShowPlayer", nShow);
    if bRet then
        return;
    end    

    Ui.Effect.ShowNpcRepresentObj(pNpc.nId, nShow == 1);
    Log("CGAnimation ShowPlayer");
end

function CGAnimation:SetAllUiVisable(nShow, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "SetAllUiVisable", nShow);
    if bRet then
        return;
    end

    local bShow = false;
    if nShow == 1 then
        bShow = true;
    end    

    Ui:SetAllUiVisable(bShow);
end

function CGAnimation:PlayEffect(nResId, nX, nY, nZ)
    if not Lib:IsTrue(nResId) then
        return;
    end    

    Ui:PlayEffect(nResId, nX, nY, nZ or 0, true);
end

function CGAnimation:PlayFactionEffect(...)
    local tbResID = {...};
    local nRestID = tbResID[me.nFaction];
    if not Lib:IsTrue(nResId) then
        return;
    end

    Ui:PlayEffect(nRestID, 0, 0, 0, true);    
end

function CGAnimation:PlayCameraEffect(nResId)
    if not Lib:IsTrue(nResId) then
        return;
    end    

    Ui:PlayCameraEffect(nResId)
end

function CGAnimation:OpenWindow(szWnd, ...)
    Ui:OpenWindow(szWnd, ...);
end

function CGAnimation:CloseWindow(szWnd, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, szWnd, "CloseWindow", szWnd);
    if bRet then
        return;
    end

    Ui:CloseWindow(szWnd);
end

function CGAnimation:CloseWindowTimer(szWnd, nDelayTime)
   --单独的定时器关闭界面，不在end的处理中
   Timer:Register(nDelayTime, function ()
       Ui:CloseWindow(szWnd);
   end)   
end

function CGAnimation:PlayCameraAnimation(szPath)
    if Lib:IsEmptyStr(szPath) then
        return;
    end    

    Ui.CameraMgr.PlayCameraAnimation(szPath)
end

function CGAnimation:RestoreCamera(nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "RestoreCamera");
    if bRet then
        return;
    end

    Ui.CameraMgr.LeaveCameraAnimationState();
    Ui.CameraMgr.RestoreCameraRotation();
end

function CGAnimation:ShowAllRepresentObj(nShow, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, "", "ShowAllRepresentObj", nShow);
    if bRet then
        return;
    end

    Ui:ShowAllRepresentObj(nShow == 1);
end

function CGAnimation:PlaySound(nSoundID, nDelayTime)
    local bRet = self:RegisterCallbackTimer(nDelayTime, nSoundID, "PlaySound", nSoundID);
    if bRet then
        return;
    end

    Ui:PlaySceneSound(nSoundID);    
end    

function CGAnimation:GetCGAimation(nCGID)
    return self.tbCGSetting[nCGID];
end

function CGAnimation:LoadSetting()
    self.tbCGSetting = {};
    local tbFileData = Lib:LoadTabFile("Setting/CGAnimation.tab", {CGID = 1});
    for _, tbData in pairs(tbFileData) do
        local tbEvent = {};
        tbEvent.szEvent = tbData.Event;
        tbEvent.tbParam = {};
        tbEvent.nMaxParam  = 0;

        for nI = 1, 20 do
            local szParam = tbData["Param"..nI];
            if not Lib:IsEmptyStr(szParam) then
                local Value = string.match(szParam, "^(%d+)$")
                if Value ~= nil then
                    Value = tonumber(szParam);
                else
                    Value = szParam;
                end

                tbEvent.nMaxParam = nI;
                tbEvent.tbParam[nI] = Value;    
            end    
        end

        self.tbCGSetting[tbData.CGID] = self.tbCGSetting[tbData.CGID] or {};
        table.insert(self.tbCGSetting[tbData.CGID], tbEvent);
    end 

end

CGAnimation:LoadSetting();

