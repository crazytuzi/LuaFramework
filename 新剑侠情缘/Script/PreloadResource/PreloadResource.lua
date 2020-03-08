
local PreloadResC      = luanet.import_type("PreloadResource");
local RepresentSetting = luanet.import_type("RepresentSetting");
PreloadResource.nTotalNeedRes = PreloadResource.nTotalNeedRes or 0;
PreloadResource.nTotalCurLoad = PreloadResource.nTotalCurLoad or 0;
PreloadResource.tbAllLoadPreloadRes = PreloadResource.tbAllLoadPreloadRes or {};
PreloadResource.tbPreloadCGAni = PreloadResource.tbPreloadCGAni or {};

function PreloadResource:LoadSetting()
    local tbFileData = Lib:LoadTabFile("Setting/PreloadRes.tab", {MapTID = 1});
    self.tbMapPreloadSetting = {};
    self.tbResPreloadCheckFunc = {};
    for _, tbData in pairs(tbFileData) do
        self.tbMapPreloadSetting[tbData.MapTID] = self.tbMapPreloadSetting[tbData.MapTID] or {};
        local tbMapPreload = self.tbMapPreloadSetting[tbData.MapTID];
        tbMapPreload[tbData.ResPath] = true;
        if not Lib:IsEmptyStr(tbData.CheckFunc) then
            self.tbResPreloadCheckFunc[tbData.ResPath] = self.tbResPreloadCheckFunc[tbData.ResPath] or {};
            self.tbResPreloadCheckFunc[tbData.ResPath][tbData.MapTID] = tbData.CheckFunc
        end
    end

end

PreloadResource:LoadSetting();

function PreloadResource:GetMapPreload(nMapTId)
    return self.tbMapPreloadSetting[nMapTId];
end

function PreloadResource:SetOnceRecycle(bOnce)
    if bOnce == nil then
        return;
    end

    PreloadResC.m_bOnceRecycle = bOnce;
    Log("PreloadResource SetOnceRecycle", bOnce and "true" or "false");
end

function PreloadResource:OnFirstEnter()
    if self.bFirstEnter then
        return;
    end

    self.bFirstEnter = true;
    self.nPreloadMapTID = -1;


    self:PreloadLoadMapSetting(-1);

    self.nPreloadMapTID = nil;
    Log("PreloadResource OnFirstEnter");
end

function PreloadResource:PreloadLoadMapSetting(nMapTId)
    local tbMapRes = self:GetMapPreload(nMapTId);
    if not tbMapRes then
        return;
    end

    for szRes, _ in pairs(tbMapRes) do
        self:PushPreloadRes(szRes);
    end
end

PreloadResource.nPreloadFaction = PreloadResource.nPreloadFaction or -1;
PreloadResource.nPreloadSex = PreloadResource.nPreloadSex or -1;

function PreloadResource:PreloadMeFaction()
    local nFaction = me.nFaction;
    local nSex = me.nSex;
    if self.nPreloadFaction == nFaction and self.nPreloadSex == nSex then
        return;
    end

    self.nPreloadMapTID = -1;
    local tbFactionSkill = FightSkill:GetFactionSkill(nFaction);
    if tbFactionSkill then
        for _, tbSkillInfo in pairs(tbFactionSkill) do
            self:PreloadSkill(tbSkillInfo.SkillId);
        end
    end

    self.nPreloadMapTID = nil;
    self.nPreloadFaction = nFaction;
    self.nPreloadSex = nSex;
end

function PreloadResource:OnChangeMap(nMapTId)
    PreloadResC.ChangeMap(nMapTId);
    self.tbAllLoadPreloadRes = {};
    self:OnFirstEnter();
    self:PreloadMeFaction();
    self:PreloadLoadMapSetting(nMapTId);
    self:PreloadFunben(nMapTId);
    self:PreloadOtherMap(nMapTId);

    self:PreloadAllCGRes();

    self:PushPreloadRes(Map:GetLoadingTexture(true));
    self:PreloadRes(nMapTId, self.tbAllLoadPreloadRes);
    self.tbAllLoadPreloadRes = {};

    Log("PreloadResource OnChangeMap", nMapTId);
end

function PreloadResource:PushPreloadCGAni(nCGID)
    PreloadResource.tbPreloadCGAni[nCGID] = 1;
end

function PreloadResource:PushPreloadRes(szPath)
    if not szPath or Lib:IsEmptyStr(szPath) then
        return;
    end

    local nMapTId = 0;
    if self.nPreloadMapTID then
        nMapTId = self.nPreloadMapTID;
    end

    self.tbAllLoadPreloadRes[szPath] = nMapTId;
end

function PreloadResource:PushPreloadEffecRes(nEffectID)
    if not nEffectID or nEffectID <= 0 then
        return;
    end

    local szPath = RepresentSetting.GetEffectRes(nEffectID);
    PreloadResource:PushPreloadRes(szPath);
end

PreloadResource.tbCheckFunc = {
    ["CameraAnimation"] = function (nMapTId, szRes)
        return CameraAnimation:CheckPlayCityAni(nMapTId)
    end;
}
--附加的检查函数，有些资源不一定需要预加载
function PreloadResource:PreloadResAdditionCheck(nMapTId, szRes)
    if not self.tbResPreloadCheckFunc[szRes] or not self.tbResPreloadCheckFunc[szRes][nMapTId] then
        return true
    end
    local fnCheck = self.tbCheckFunc[self.tbResPreloadCheckFunc[szRes][nMapTId]]
    if not fnCheck then
        Log("PreloadResource PreloadResAdditionCheck Func Not Found", szRes, nMapTId)
        return
    end
    local bRet = fnCheck(nMapTId, szRes)
    return bRet
end

function PreloadResource:PreloadRes(nMapTId, tbAllLoadRes)
    Log("------PreloadResource------");
    Lib:LogTB(tbAllLoadRes);
    Log("------PreloadResource------");
    self.nTotalNeedRes = 0;
    self.nTotalCurLoad = 0;
    for szRes, nCurMapTID in pairs(tbAllLoadRes) do
        local nPreloadMapTID = nMapTId;
        if nCurMapTID ~= 0 then
            nPreloadMapTID = nCurMapTID;
        end

        if self:PreloadResAdditionCheck(nPreloadMapTID, szRes) then
            self:AddPreloadRes(nPreloadMapTID, szRes);
            self.nTotalNeedRes = self.nTotalNeedRes + 1
        end
    end

    Log("PreloadResource PreloadRes Total Res", self.nTotalNeedRes);
end

function PreloadResource:PreloadAllCGRes()
    for nCGID, _ in pairs(self.tbPreloadCGAni) do
        self:PreloadCG(nCGID);
    end

    self.tbPreloadCGAni = {};
end

function PreloadResource:PreloadCG(nCGID)
    local tbCGList = CGAnimation:GetCGAimation(nCGID);
    if not tbCGList then
        return;
    end

    for _, tbEvent in pairs(tbCGList) do
        if tbEvent.szEvent == "PlayEffect" or tbEvent.szEvent == "PlayCameraEffect" then
            self:PushPreloadEffecRes(tbEvent.tbParam[1]);
        elseif tbEvent.szEvent == "PlayFactionEffect" then
            local tbFactionResInfo = tbEvent.tbParam[self.nPreloadFaction]
            local nResId = tbFactionResInfo and tbFactionResInfo[self.nPreloadSex]
            if nResId and nResId > 0 then
                self:PushPreloadEffecRes(nResId);
            end
        elseif tbEvent.szEvent == "PlayCameraAnimation" then
            self:PushPreloadRes(tbEvent.tbParam[1]);
        end
    end
end

function PreloadResource:PreloadFunben(nMapTId)
    local tbFubenSetting = Fuben:GetFubenSettingByMapTID(nMapTId);
    if not tbFubenSetting then
        return;
    end

    if tbFubenSetting.NPC then
        for _, tbNpcInfo in pairs(tbFubenSetting.NPC) do
            local tbAllNpc = {};
            if type(tbNpcInfo.nTemplate) == "number" then
                table.insert(tbAllNpc, tbNpcInfo.nTemplate);
            else
                if Fuben.tbNpcTemplateIdx[tbNpcInfo.nTemplate] then
                    table.insert(tbAllNpc, Fuben.tbNpcTemplateIdx[tbNpcInfo.nTemplate][1]);
                    table.insert(tbAllNpc, Fuben.tbNpcTemplateIdx[tbNpcInfo.nTemplate][2]);
                end
            end

            for _, nNpcTemplate in pairs(tbAllNpc or {}) do
                self:PreloadNpc(nNpcTemplate);
            end
        end
    end

    if tbFubenSetting.LOCK then
        for _, tbLockInfo in pairs(tbFubenSetting.LOCK) do
            self:PreloadFubenLockEvent(tbLockInfo.tbStartEvent);
            self:PreloadFubenLockEvent(tbLockInfo.tbUnLockEvent);
        end
    end

    if tbFubenSetting.ANIMATION then
        for _, szPath in pairs(tbFubenSetting.ANIMATION) do
            self:PushPreloadRes(szPath);
        end
    end

    return tbPreloadRes;
end

function PreloadResource:PreloadOtherMap(nMapTId)
    if nMapTId == 1020 then --新手战场
        
        for nFaction,v in pairs(Faction.tbFactionInfo) do
            self:PreloadFakePlayer(nFaction)
        end
    end
end

function PreloadResource:PreloadFubenLockEvent(tbLockEvent)
    if not tbLockEvent then
        return;
    end

    for _, tbEvent in pairs(tbLockEvent) do
        if tbEvent[1] == "PlayEffect" or tbEvent[1] == "PlayCameraEffect" then
            self:PushPreloadEffecRes(tbEvent[2]);
        end

        if tbEvent[1] == "RaiseEvent" and tbEvent[2] == "AddNpcWithAward" then
            self:PushPreloadEffecRes(tbEvent[11]);
        end

        if tbEvent[1] == "PlayCGAnimation" then
            self:PreloadCG(tbEvent[2]);
        end

        if tbEvent[1] == "PlayFactionEffect" and tbEvent[2] then
            local tbFactionResInfo = tbEvent[2][self.nPreloadFaction]
            local nResId = tbFactionResInfo and tbFactionResInfo[self.nPreloadSex]
            if nResId and nResId > 0 then
                self:PushPreloadEffecRes(nResId);
            end
        end
    end
end

function PreloadResource:PreloadNpc(nNpcTID)
    local tbNpcTemplate = KNpc.GetNpcTemplateInfo(nNpcTID);
    if not tbNpcTemplate then
        return;
    end

    if tbNpcTemplate.nNpcResID > 0 then
        local NpcTemplateRes = RepresentSetting.GetNpcRes(tbNpcTemplate.nNpcResID);
        if NpcTemplateRes then
            self:PushPreloadRes(NpcTemplateRes.m_szResFile);
        end
    end

    for _, nSkillId in pairs(tbNpcTemplate.tbNormallSkill) do
        self:PreloadSkill(nSkillId);
    end

    local tbAI = tbNpcTemplate.tbAi;
    if tbAI and tbAI.tbSkill then
        for _, nSkillId in pairs(tbAI.tbSkill) do
            self:PreloadSkill(nSkillId);
        end
    end
end

function PreloadResource:PreloadFakePlayer(nFaction)
    local nSex = Player:Faction2Sex(nFaction);
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex);
    if not tbPlayerInfo then
        return
    end

    for i = 0, 1 do
        local NpcPartRes = RepresentSetting.GetPartRes(i,tbPlayerInfo.nBodyResId);
        if NpcPartRes then
            if NpcPartRes.m_ResFile ~= "" then
                self:PushPreloadRes(NpcPartRes.m_ResFile);
            end
            if NpcPartRes.m_ResFile2 ~= "" and NpcPartRes.m_ResFile2 ~= NpcPartRes.m_ResFile then
                self:PushPreloadRes(NpcPartRes.m_ResFile2);
            end
        end
    end
end

function PreloadResource:PreloadSkill(nSkillId, bSubSkill)
    if nSkillId <= 0 then
        return;
    end

    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId);
    if not tbSkillInfo then
        return;
    end

    if not bSubSkill then
        local nActEvent = tbSkillInfo.ActionEventID;
        if nActEvent > 0 then
            self:PreloadActEvent(nActEvent);
        end
    end

    if tbSkillInfo.SkillType == FightSkill.SkillTypeDef.skill_type_inst_missile or
        tbSkillInfo.SkillType == FightSkill.SkillTypeDef.skill_type_missile then
        local nMissileTID = tbSkillInfo.ChildID;
        if nMissileTID > 0 then
            local tbMissile = KFightSkill.GetMissileTemplateInfo(nMissileTID);
            if tbMissile then
                self:PushPreloadEffecRes(tbMissile.nMissileResID);
                self:PushPreloadEffecRes(tbMissile.nEnemyResID);
                self:PushPreloadEffecRes(tbMissile.nCollResID);
            end
        end
    end

    self:PushPreloadEffecRes(tbSkillInfo.CastEffectRestId);
    PreloadResource:PreloadSkill(tbSkillInfo.StartSkillID, true);
    PreloadResource:PreloadSkill(tbSkillInfo.FlySkillID, true);
    PreloadResource:PreloadSkill(tbSkillInfo.HitSkillID, true);
end

function PreloadResource:PreloadActEvent(nActEvent)
    local tbActEvent = KNpc.GetNpcActionEvent(nActEvent);
    if not tbActEvent then
        return;
    end

    self:PreloadActEvetList(tbActEvent.tbStartEvent);
    self:PreloadActEvetList(tbActEvent.tbEndEvent);
    for _, tbEventList in pairs(tbActEvent.tbFrameEvent) do
        self:PreloadActEvetList(tbEventList);
    end
end

function PreloadResource:PreloadActEvetList(tbEventList)
    if not tbEventList then
        return;
    end

    for _, tbInfo in pairs(tbEventList) do
        if tbInfo.nEventName == Npc.ActEventNameType.act_cast_skill then
            if tbInfo.tbEventParam[1] > 0 then
                self:PreloadSkill(tbInfo.tbEventParam[1], true);
            end

        elseif tbInfo.nEventName == Npc.ActEventNameType.act_play_effect or
            tbInfo.nEventName == Npc.ActEventNameType.act_play_scene_effect then
            self:PushPreloadEffecRes(tbInfo.tbEventParam[1]);
        end
    end
end


function PreloadResource:AddPreloadRes(nMapTId, szResPath)
    PreloadResC.AddPreloadRes(nMapTId, szResPath);
end

function PreloadResource:AddPreloadEffectRes(nMapTId, nEffectID)
    PreloadResC.AddPreloadEffectRes(nMapTId, nEffectID);
end


function PreloadResource:OnLoadResFinish(nMapTId, szResPath)

    self.nTotalCurLoad = self.nTotalCurLoad + 1;
    if self.nTotalCurLoad == self.nTotalNeedRes then
        self:OnFinishAllResLoad();
    end
end

function PreloadResource:GetLoadPercent()
    if self.nTotalNeedRes <= 0 then
        return 1.0;
    end

    return self.nTotalCurLoad / self.nTotalNeedRes;
end

function PreloadResource:OnFinishAllResLoad()

    Log("PreloadResource FinishAllResLoad");
end

