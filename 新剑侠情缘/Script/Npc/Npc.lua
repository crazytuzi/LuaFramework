
Require("CommonScript/Npc/Npc.lua");

Npc.tbActDoCallScript =
{
    [1] = function (pNpc, nParam1, nParam2, nParam3, nParam4)
    end;

    [2] = function (pNpc, nParam1, nParam2, nParam3, nParam4)
        if pNpc.nKind ~= Npc.KIND.player then
            return;
        end
    end;

--restore  map sound setting
    [3] = function (pNpc, nParam1, nParam2, nParam3, nParam4)
        if pNpc.nKind ~= Npc.KIND.player or pNpc.dwPlayerID ~= me.dwID then
            return;
        end
        Ui:UpdateSoundSetting()
        Map:RestartPlayMapSound()
    end;
}

function Npc:ActDoCallScript(pNpc, nType, ...)
    local funCallBack = Npc.tbActDoCallScript[nType];
    if not funCallBack then
        return;
    end

    funCallBack(pNpc, ...); 
end

function Npc:OnAttachLink(nType)
    local tbAttachParam = him.GetNpcAttachParam();
    if not tbAttachParam then
        return;
    end

    if tbAttachParam.nType ~= Npc.AttachType.npc_attach_type_none then
        Ui.Effect.AddShowRepNpc(him.nId);
        Ui.Effect.AddVisibleRepNpc(him.nId);
        local nShowType = Ui.Effect.GetShowAllObjType();
        if nShowType ~= 0 then
            Ui.Effect.ShowNpcRepresentObj(him.nId, true);
        end
        Map.bLeaveClearShowRep = true;
    else
        Ui.Effect.RemoveVisibleRepNpc(him.nId);
        Ui.Effect.ClearShowRepNpc();
    end
end

function Npc:InitGameC()
end

function Npc:NotifyOnDialog()
    UiNotify.OnNotify(UiNotify.emNOTIFY_ON_NPC_DIALOG)
end