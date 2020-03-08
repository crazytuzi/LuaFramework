ViewRole.tbAllRole = {}; --[dwRoleId1] = tbROle
ViewRole.tbAllRoleId = {};  --dwRoleId1, dwRoleId2, dwRoleId3...
ViewRole.MAX_SAVE_ROLE_NUM = 30; --本地存超过该值就会删除最前面一个
ViewRole.UPDATE_TIME_CD = 600; --超过该时间的角色数据会重新请求

function ViewRole:GetRoleInfoById(dwRoleId)
    local tbRole = self.tbAllRole[dwRoleId]
    if not tbRole then
        return
    end
    if GetTime() - tbRole.nUpdateTime > self.UPDATE_TIME_CD then
        return 
    end
     --跨服带服务器id的就不缓存了，因为角色id可能重复且不常用
    if tbRole.nServerId then
        self.tbAllRole[dwRoleId] = nil;
    end
    return tbRole
end

function ViewRole:OpenWindow(szWnd, dwRoleId, ...)
    local tbArgs = {...}
    local tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole,tbNpcResEffect = self:GetCurResInfo(dwRoleId, szWnd); --不一定需要同伴数据吧
    if not tbEquip then
        self.szWaitWnd = szWnd;
        self.fWaitCallback = function ()
            ViewRole:OpenWindow(szWnd, dwRoleId, unpack(tbArgs));
        end        
        return
    end

    Ui:OpenWindow(szWnd, tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole,tbNpcResEffect, ...)
end

function ViewRole:OpenWindowWithServerId(szWnd, dwRoleId, nServerId,  ...)
    local tbArgs = {...}
    local tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole,tbNpcResEffect = self:GetCurResInfo(dwRoleId, szWnd, nServerId); --不一定需要同伴数据吧
    if not tbEquip then
        self.szWaitWnd = szWnd;
        self.fWaitCallback = function ()
            ViewRole:OpenWindow(szWnd, dwRoleId, unpack(tbArgs));
        end        
        return
    end

    Ui:OpenWindow(szWnd, tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole,tbNpcResEffect , ...)
end

function ViewRole:OpenWindowWithFaction(szWnd, nFaction, ...)
    local pAsyncRole = {}
    pAsyncRole.GetFaction = function ()
        return nFaction;
    end
    local tbNpcRes = {}

    local nSex = Player:Faction2Sex(nFaction, me.nSex);
    local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex);

    tbNpcRes[0] = tbPlayerInfo.nBodyResId
    tbNpcRes[1] = tbPlayerInfo.nWeaponResId

   Ui:OpenWindow(szWnd, {}, tbNpcRes, {}, pAsyncRole, ...) 
end

function ViewRole:OpenWindowWithNpcResId(szWnd, nNpcResId, szActName, ...)
    local pAsyncRole = {}
    pAsyncRole.GetActName = function ()
        return szActName
    end
    local tbNpcRes = {}
    tbNpcRes[0] = nNpcResId

   Ui:OpenWindow(szWnd, {}, tbNpcRes, {}, pAsyncRole, ...) 
end


function ViewRole:OnGetSyncData(tbRole)
    if not tbRole then
        return
    end
    local dwRoleId = tbRole.dwID
    tbRole.nUpdateTime = GetTime()
    if #self.tbAllRoleId >= self.MAX_SAVE_ROLE_NUM then
        local dwRoleId = table.remove(self.tbAllRoleId, 1);
        self.tbAllRole[dwRoleId] = nil;
    end
    self.tbAllRole[dwRoleId] = tbRole
    table.insert(self.tbAllRoleId, dwRoleId)

    if not self.szWaitWnd or Ui:WindowVisible(self.szWaitWnd) then
        return
    end
    local pAsyncRole = KPlayer.GetAsyncData(dwRoleId) --没调一次就会添加一次道具，也是很坑爹，里面加个限制吧
    if not pAsyncRole then
        return
    end
    if self.fWaitCallback then
        self.fWaitCallback();
        self.fWaitCallback = nil;
        self.szWaitWnd = nil;
    end
end




--查看获取玩家的属性, 不同的窗口要的数据量不一样
function ViewRole:GetCurResInfo(dwRoleId, szWnd, nServerId)
	local pAsyncRole = KPlayer.GetAsyncData(dwRoleId) 
    local tbRole = self:GetRoleInfoById(dwRoleId)
    if not pAsyncRole or not tbRole  then
        RemoteServer.ViewPlayerInfo(dwRoleId, szWnd, nServerId)
        return
    end
    pAsyncRole.tbRoleInfo = tbRole

    if self.dwRoleId  then
        KPlayer.CloseAsyncData(self.dwRoleId)
        self.pAsyncRole = nil;
        self.dwRoleId = nil;   
    end

    local tbEquip, tbNpcRes, tbPartnerInfo = KPlayer.ViewAsyncData(dwRoleId)
    self.tbEquip = tbEquip;
    self.tbNpcRes = tbNpcRes;
    self.tbPartnerInfo = tbPartnerInfo;
    pAsyncRole.tbEquip = tbEquip
    if tbEquip then
        -- 更新套装信息
        local tbActiedSuitIndex,tbSuitIndexEquipNum = Item.GoldEquip:GetActiedSuitIndexFromEquips(tbEquip)
        pAsyncRole.tbActiedSuitIndex = tbActiedSuitIndex
        pAsyncRole.tbSuitIndexEquipNum = tbSuitIndexEquipNum

        self.dwRoleId = dwRoleId;
        local nFaction = pAsyncRole.GetFaction()
        local nSex = Player:Faction2Sex(nFaction, pAsyncRole.GetSex());
        local _tbNpcRes, tbNpcResEffect = ViewRole:GetShowResInfo( nFaction, nSex, nil, tbEquip)
        tbNpcRes = _tbNpcRes;
        self.tbNpcRes = _tbNpcRes
        local nLightID = pAsyncRole.GetOpenLight();
        if nLightID > 0 then
            tbNpcResEffect[Npc.NpcResPartsDef.npc_part_weapon] = OpenLight:GetFactionEffectByLight(nLightID, nFaction, nSex);
        end

        return  tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole,tbNpcResEffect
    end
end

-- 半身像模型缩放
function ViewRole:GetScale(tbParent, szWndParentName)
    if tbParent.nScale then
        return tbParent.nScale
    end
    local tbWnd = tbParent;
    if not Lib:IsEmptyStr(szWndParentName) then
        tbWnd = Ui(szWndParentName)
        if not tbWnd then
            Log(debug.traceback())
            return 0.45
        end
    end
    local tbSceenszie = tbWnd.pPanel:Panel_GetSize("Main")
    if tbSceenszie.y == 0 then
        tbParent.nScale = 0.45
    else
        local fScreenParam =tbSceenszie.x / tbSceenszie.y
        if fScreenParam >= 1366/768 then
            tbParent.nScale = 0.45    
        elseif fScreenParam <= 4/3 then
            tbParent.nScale = 0.35
        else
            tbParent.nScale = (0.35 - 0.45) / (4/3 - 1366/768) * ( fScreenParam - 1366/768) + 0.45    
        end
    end
    return tbParent.nScale
end

function ViewRole:GetShowResInfo( nFaction, nSex, tbItems, tbItemIds )
    local tbNpcRes, tbNpcResEffect = {}, {};
    local tbEffectRest = {};
    for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
        if nI ~= Npc.NpcResPartsDef.npc_part_horse then
            tbNpcRes[nI] = 0;
            tbNpcResEffect[nI] = 0;
        end
    end
    local tbPlayerInitInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex);
    if tbPlayerInitInfo.nBodyResId and tbPlayerInitInfo.nBodyResId > 0 then
        tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = tbPlayerInitInfo.nBodyResId    
    end
    if tbPlayerInitInfo.nWeaponResId and tbPlayerInitInfo.nWeaponResId > 0 then
        tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = tbPlayerInitInfo.nWeaponResId    
    end
    if tbPlayerInitInfo.nHeadResId and tbPlayerInitInfo.nHeadResId > 0 then
        tbNpcRes[Npc.NpcResPartsDef.npc_part_head] = tbPlayerInitInfo.nHeadResId
    end

    local tbPos = {Item.EQUIPPOS_BODY, Item.EQUIPPOS_WEAPON, Item.EQUIPPOS_HEAD,Item.EQUIPPOS_WAIYI,Item.EQUIPPOS_WAI_WEAPON,Item.EQUIPPOS_WAI_HEAD, Item.EQUIPPOS_WAI_BACK, Item.EQUIPPOS_BACK2, Item.EQUIPPOS_WAI_BACK2};

    if tbItemIds then
        tbItems = tbItems or {}
        for _,nPos in ipairs(tbPos) do
            local nItemId = tbItemIds[nPos]
            if nItemId then
                local pItem = KItem.GetItemObj(nItemId)
                if pItem then
                    tbItems[nPos] = pItem.dwTemplateId
                end
            end
        end
    end
    
    if tbItems then --决赛最终没有获取在线时的装备数据时就用门派默认信息
        for _,nPos in ipairs(tbPos) do
            local dwTemplateId = tbItems[nPos]
            if dwTemplateId then
                local nResId,nEffectResId = Item.tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction, nSex); 
                local nNpcPart = Item.tbItemPosToNpcPart[nPos]
                if nResId ~= 0 then
                    tbNpcRes[nNpcPart] = nResId;    
                end
                if nEffectResId ~= 0 then
                    tbNpcResEffect[nNpcPart] = nEffectResId
                end
            end    
        end
    end
    return tbNpcRes, tbNpcResEffect
end

ViewRole.tbFactionSexAniEffect = {
    [11] = {
        [Player.SEX_FEMALE] = {
            [Npc.ActionId.st01] = {8,9987,1,false,2}; --丐帮萝莉吃鸡腿
        };
    }
}

function ViewRole:CheckPlayeRoleAniEffect(tbUi,nActId )
    local tbEff1 = self.tbFactionSexAniEffect[me.nFaction]
    if tbEff1 then
        local tbEff2 = tbEff1[me.nSex]
        if tbEff2 then
            local tbEff3 = tbEff2[nActId]
            if tbEff3 then
                local nId = tbUi.pPanel:NpcView_GetFeatureNodeId("ShowRole")
                local tbFea = Ui.NpcViewMgr.GetFeatureNode(nId)
                if tbFea and tbFea.m_NpcFeature then
                    --@_@
                    --if tbFea.m_NpcFeature.m_byActionModeFlag ~= 0 then
                    --    return
                    --end
                end

                local nDelay = tbEff3[1]
                local fnFnc = function (  )
                    Ui.NpcViewMgr.PlayNpcEffect(nId, unpack( tbEff3, 2))                
                end
                if nDelay > 0 then
                    Timer:Register( nDelay, fnFnc)
                else
                    fnFnc()
                end
            end
        end
    end
end