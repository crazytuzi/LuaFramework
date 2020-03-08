local tbItem = Item:GetClass("KinElectTitleItem1")

-- 仅用于修复bug
-- http://10.11.10.104:8081/browse/FT-14429
function tbItem:OnUse(it)
    local nTime = 31536000    --时限（秒），-1为永久
    local tbCfg = {
        [6894] = {  --称号id
            [350234478]=30309,
            [356517838]=30309,
            [346040132]=30309,
            [338709660]=30309,
            [341851954]=30309,
            [351275010]=30309,
            [339750258]=30309,
        },
        [6895] = {  --称号id
            [318782019]=30296,
            [318771135]=30296,
            [319832580]=30296,
            [319826423]=30296,
            [311442007]=30296,
            [310392675]=30296,
            [319818894]=30296,
        },
        [6896] = {  --称号id
            [55589785]=30044,
            [60832895]=30044,
            [48235503]=30044,
            [48250590]=30044,
            [55591359]=30044,
            [63982329]=30044,
            [53485070]=30044,
        },
        [6897] = {  --称号id
            [1152386117]=31099,
            [1152408778]=31099,
            [1152387630]=31099,
            [1152386120]=31099,
            [1152387482]=31099,
            [1152409147]=31099,
            [1152403745]=31099,
        },
        [6898] = {  --称号id
            [342884694]=30309,
            [356521526]=30309,
            [344989055]=30309,
            [344988814]=30309,
            [342900036]=30309,
            [342884498]=30309,
            [341849966]=30309,
        },
        [6899] = {  --称号id
            [89142320]=30084,
            [92291306]=30084,
            [90189363]=30084,
            [101723260]=30084,
            [89158660]=30084,
            [89156111]=30084,
            [103819764]=30084,
        },
        [6900] = {  --称号id
            [1221591323]=31165,
            [1221592500]=31165,
            [1221591770]=31165,
            [1221592688]=31165,
            [1221601045]=31165,
            [1221593656]=31165,
        },
    }

    local nServerId = GetServerIdentity()
    local nPlayerId = me.dwID

    local nTitleId = 0
    for nTid, tb in pairs(tbCfg) do
        if tb[nPlayerId] == nServerId then
            nTitleId = nTid
            break
        end
    end

    if (nTitleId or 0) <= 0 then
        Log("Error KinElectTitleItem1 Not nTitleId", nPlayerId, me.dwKinId, nServerId, nTitleId)
        return;
    end

    local bOk = me.AddTitle(nTitleId, nTime, false, true)
    Log("KinElectTitleItem1", nPlayerId, me.dwKinId, nTitleId, nTime, tostring(bOk))
    return bOk and 1 or 0
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    return {szFirstName = "使用", fnFirst = "UseItem"}
end