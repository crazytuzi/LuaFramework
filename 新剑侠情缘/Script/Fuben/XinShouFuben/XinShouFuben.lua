Require("Script/Fuben/XinShouFuben/XinShouDef.lua");
local tbDef = XinShouLogin.tbDef;
local tbFuben = Fuben:CreateFubenClass("XinShouFuben");
tbFuben.tbCameraAnim =
{
    [1] = "xsg_cam2";   ------------投石车战斗动画
    [2] =
    {
        ["1-1"] = "m2_cam1"; --天王男
        ["1-2"] = "f1_cam1"; --天王女
        ["2-2"] = "f2_cam1"; --峨眉
        ["3-2"] = "f1_cam1"; --桃花
        ["4-1"] = "m1_cam1"; --逍遥男
        ["4-2"] = "f2_cam1"; --逍遥女
        ["5-1"] = "m1_cam1"; --武当男
        ["5-2"] = "f2_cam1"; --武当女
        ["6-1"] = "m1_cam1"; --天忍男
        ["6-2"] = "f2_cam1"; --天忍女
        ["7-1"] = "m2_cam1"; --少林
        ["8-2"] = "f2_cam1"; --翠烟
        ["9-1"] = "m1_cam1"; --唐门
        ["10-1"] = "m2_cam1"; --昆仑男
        ["10-2"] = "f2_cam1"; --昆仑女
        ["11-1"] = "m2_cam1"; --丐帮男
        ["11-2"] = "f1_cam1"; --丐帮女
        ["12-2"] = "f1_cam1"; --五毒
        ["13-1"] = "m1_cam1"; --藏剑
        ["14-2"] = "f2_cam1"; --长歌
        ["15-1"] = "m1_cam1"; --天山男
        ["15-2"] = "f2_cam1"; --天山女
        ["16-1"] = "m2_cam1"; --霸刀男
        ["16-2"] = "f1_cam1"; --霸刀女
        ["17-1"] = "m1_cam1"; --华山男
        ["17-2"] = "f2_cam1"; --华山女
        ["18-1"] = "m1_cam1"; --明教男
        ["18-2"] = "f2_cam1"; --明教女
        ["19-1"] = "m1_cam1"; --段氏男
        ["19-2"] = "f1_cam1"; --段氏女
        ["20-1"] = "m1_cam1"; --万花男
        ["20-2"] = "f2_cam1"; --万花女
        ["21-1"] = "m1_cam1"; --杨门男
        ["21-2"] = "f2_cam1"; --杨门女
    };                             ----------------门派轻功动画
    [3] = "xsg_cam1";               ----------------boss出场动画
    [4] = "xsg_cam3";               ----------------船毁动画
}

function tbFuben:OnCreate()       -- 创建副本时的回调，参数任意
    Ui:OpenWindow("BgBlackAll");
end

function tbFuben:OnJoin(pPlayer)
    pPlayer.nFightMode = 1;
    Ui:OpenWindow("HomeScreenFuben", "XinShouFuben")
    Log("XinShouFuben On Join");
end

function tbFuben:OnMapLoaded()
    Ui:ChangeUiState(Ui.STATE_SPECIAL_FIGHT, false);
    local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId);
    if npcRep then
        npcRep:ShowHeadUI(false)
    end
    self:Start();

    Timer:Register(Env.GAME_FPS * 6, function ()
        if Ui:WindowVisible("BgBlackAll") == 1 then
            Ui:CloseWindow("BgBlackAll");
        end
    end);
end

function tbFuben:OnOut(pPlayer)
    Ui:CloseWindow("HomeScreenFuben")
    Log("XinShouFuben On Out");
end

function tbFuben:GameWin()
    XinShouLogin.nPlayCGAnimation = tbDef.nPlayXinShouCG;
    PreloadResource:PushPreloadCGAni(XinShouLogin.nPlayCGAnimation);
    XinShouLogin.bFinishFuben = true;
    XinShouLogin:LoginServer()

    self:Close();
    Log("XinShouFuben On Game Win");
end

function tbFuben:OnShowTaskDialog(nLockId, nDialogId, bIsOnce, nDealyTime)
    if nDealyTime and nDealyTime > 0 then
        Timer:Register(Env.GAME_FPS * nDealyTime, self.OnShowTaskDialog, self, nLockId, nDialogId, bIsOnce);
        return;
    end

    Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, {self.UnLock, self, nLockId});
end

function tbFuben:OnCloseDynamicObstacle(szObsName)
    CloseDynamicObstacle(me.nMapId, szObsName);
end

function tbFuben:OnDoCommonAct(szNpcGroup, nActId, nActEventId, bLoop, nFrame)
    if not szNpcGroup then
        local pNpc = me.GetNpc();
        if pNpc then
            pNpc.DoCommonAct(nActId or 1, nActEventId or 0, bLoop or 0, nFrame or 0);
        end
        return;
    end

    for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup] or {}) do
        local pNpc = KNpc.GetById(nNpcId);
        if pNpc then
            pNpc.DoCommonAct(nActId or 1, nActEventId or 0, bLoop or 0, nFrame or 0);
        end
    end
end

function tbFuben:OnPostXinshouData(nIndex)
    Login:PostXinshouFubenData(nIndex)
end

function tbFuben:OnOpenCreatNamePanel()
    Ui:OpenWindow("CreateNameInput", XinShouLogin.tbRoleInfo.nFaction, XinShouLogin.tbRoleInfo.nSex)
end

function tbFuben:OnDirectShowNameInput()
    self:OnTlog(7)
    self:PreLoadWindow("SituationalDialogue")
    self:PreLoadWindow("CreateNameInput")
    self.tbLock[43]:StartLock();
    self:UnLock(43)
end

function tbFuben:OnCreateRoleRespond(nRoleId)
    self:UnLock(44)
    Ui:CloseWindow("CreateNameInput")
    XinShouLogin.tbRoleInfo.nRoleID = nRoleId
end

function tbFuben:OnOpenBgBlackAll()
    if Ui:WindowVisible("BgBlackAll") == 1 then
        return
    end
    Ui:OpenWindow("BgBlackAll")
end

function tbFuben:GameLost()
    Ui:ChangeUiState();
    self:Close();
    Log("XinShouFuben On Game Lost");
end

function tbFuben:OnLog( ... )
    Log(...);
end

function tbFuben:OnShowPlayer(bShow)
    Ui.Effect.ShowNpcRepresentObj(me.GetNpc().nId, bShow);
end

function tbFuben:OnTlog(nVal)
    LogBeforeLogin(nVal)
end

function tbFuben:OnPlaySceneCameraAnimation(nIndex, nUnlockId)
    local anim = self.tbCameraAnim[nIndex];
    if type(anim) == "table" then
        local szKey = string.format("%d-%d", me.nFaction, me.nSex);
        anim = anim[szKey];
    end
    assert(anim, "faction animation not exist: " .. nIndex .. ", nFaction: " .. me.nFaction);
    self.nSceneAnimationLockId = nUnlockId;
    CameraAnimation:PlaySceneCameraAnimation("xsg_cam", anim, 1);
end