
local tbDef = XinShouLogin.tbDef;

function XinShouLogin:IsOpenFunben()
   return true; 
end

function XinShouLogin:CheckEnterFuben(nFaction, nSex)
    local tbFubenSetting = Fuben:GetFubenSettingByMapTID(tbDef.nFubenMapID);
    if not tbFubenSetting then
        return false, "Not FubenSetting";
    end

    local bHaveNpc = me.HaveNpc();
    if bHaveNpc then
        return false, "Error XinShouLogin Have Npc";
    end

    local tbAllRoleInfo = GetRoleList();
    local tbRoleInfo = nil;
    for _, tbInfo in pairs(tbAllRoleInfo) do
        if tbInfo.nFaction == nFaction and tbInfo.nSex == nSex then
            tbRoleInfo = tbInfo;
        end    
    end

    if tbRoleInfo then
        return false, "XinShouLogin Has Role Info"; 
    end

    tbRoleInfo = {
        szName = "",
        nFaction = nFaction,
        nRoleID = 0,
    }

    return true, "", tbRoleInfo, tbFubenSetting;  
end

function XinShouLogin:ResetInfo()
    XinShouLogin.bFinishFuben = false;
    XinShouLogin.nPlayCGAnimation = nil;
    XinShouLogin.tbRoleInfo       = nil;
    UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self)
end

function XinShouLogin:EnterFuben(nFaction, nSex)
    local bRet, szMsg, tbRoleInfo, tbFubenSetting = self:CheckEnterFuben(nFaction, nSex);
    if not bRet then
        Log(szMsg);
        return;
    end    
    self:ResetInfo();

    tbRoleInfo.nSex = Player:Faction2Sex(nFaction, nSex);
    XinShouLogin.tbRoleInfo = tbRoleInfo;

    -- XinShouLogin:RegisterEvent(); --没起名字前都不需要连服务器
    UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self);

    local tbPos = tbFubenSetting.tbBeginPoint;
    me.EnterClientMap(tbDef.nFubenMapID, tbPos[1], tbPos[2]);
    local nBuffID = self:GetFactionBuffTID(tbRoleInfo.nFaction);
    local pNpc = KNpc.Add(tbDef.nNpcTID, tbDef.nNpcLevel, -1, 0, tbPos[1], tbPos[2]);
    me.BindNpc(pNpc.nId);
    pNpc.szName = tbRoleInfo.szName;
    me.nFaction = tbRoleInfo.nFaction;
    me.nSex = tbRoleInfo.nSex;
    local nPortrait = PlayerPortrait:GetDefaultId(me.nFaction, me.nSex)
    me.SetPortrait(nPortrait);
    me.dwID = tbRoleInfo.nRoleID;

    if nBuffID then
        pNpc.AddSkillState(nBuffID, 1, 0, 10 * 24 * 60 * 60 * Env.GAME_FPS, 0, 1);
    end

    pNpc.RestoreHP();
    me.ModifyFeatureEquip(0, 0);    
    Fuben:CreateFuben(tbDef.nFubenMapID, tbDef.nFubenMapID, 1, tbRoleInfo);
    Map:OnEnter(tbDef.nFubenMapID, tbDef.nFubenMapID, 1);
    Ui:OnEnterGame();
end

function XinShouLogin:GetFactionBuffTID(nFaction)
    return tbDef.tbFactionBuff[nFaction];
end

function XinShouLogin:OnMapLodingEnd()
    if not XinShouLogin.tbRoleInfo then
        return
    end
    if not XinShouLogin.bFinishFuben then
        return
    end

    if XinShouLogin.nPlayCGAnimation then
        CGAnimation:Play(XinShouLogin.nPlayCGAnimation);
        XinShouLogin.nPlayCGAnimation = nil;   
    end

    self:ResetInfo();
    return;     
end

function XinShouLogin:OnConnectLost()
    if not XinShouLogin.tbRoleInfo then
        return;
    end

    Ui:ReconnectServer();
end

function XinShouLogin:LoginServer()
    if not XinShouLogin.tbRoleInfo then
        return;
    end

    if not XinShouLogin.bFinishFuben then 
        return;
    end

    SetStandAlone(0);
    Login:LoginRole(XinShouLogin.tbRoleInfo.nRoleID)


    Log("XinShouLogin LoginServer PhoneLogin");
end

function XinShouLogin:RequestSkipFuben()
    if XinShouLogin.bFinishFuben then
        return
    end
    if not XinShouLogin.tbRoleInfo then
        return
    end
    local tbFubenInst = Fuben:GetFubenInstance(me)
    if not tbFubenInst then
        return
    end
    local fnYes = function ()
        tbFubenInst:OnDirectShowNameInput()
    end;

    Ui:OpenWindow("MessageBox",
      "确定跳过新手关卡吗?",
     { {fnYes},{} },
     {"同意", "取消"});
end