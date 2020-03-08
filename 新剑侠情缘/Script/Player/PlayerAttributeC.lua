
Require("CommonScript/Player/PlayerAttribute.lua");
local tbDef = PlayerAttribute.tbDef;

PlayerAttribute.tbDoFlyChar = 
{
   [tbDef.nStrengthType]  = 10; -- 基本力量
   [tbDef.nDexterityType] = 11; -- 基本敏捷
   [tbDef.nVitalityType]  = 9; -- 基本体质
   [tbDef.nEnergyType]    = 12; -- 基本灵巧 
}

function PlayerAttribute:UpdatePlayerAttrib(pPlayer, nType)
    local tbInfo = self:GetAttributInfo(nType);
    if not tbInfo then
        Log("Error PlayerAttribute UpdatePlayerAttrib tbInfo", pPlayer.dwID, nType);
        return;
    end

    local nValue = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID);
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end
        
    if nValue > 0 then
        self:SetAutoAttributeValue(pNpc, nType, nValue);
        --pPlayer.ApplyExternAttrib(tbInfo.nAttributeID, nValue);
    else
        self:SetAutoAttributeValue(pNpc, nType, 0);
        --pPlayer.RemoveExternAttrib(tbInfo.nAttributeID);
    end    
end

function PlayerAttribute:UpdatePlayerAllAttrib(pPlayer)
    for nType, tbInfo in pairs(tbDef.tbAttributeGroup) do
        local bRet = self:CheckSaveID(tbInfo.nSaveID);
        if bRet then
            local nValue = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbInfo.nSaveID);
            if nValue > 0 then
                self:UpdatePlayerAttrib(pPlayer, nType);
            end
        end        
    end    
end

function PlayerAttribute:UpdateSelfAllAttrib()
    self:UpdatePlayerAllAttrib(me);
end

function PlayerAttribute:UpdateSelfAttrib(nType, nAdd)
    self:UpdatePlayerAttrib(me, nType);

    local nFlyType = PlayerAttribute.tbDoFlyChar[nType];
    if nFlyType and nAdd > 0 then
        self.nExtFlyTime = self.nExtFlyTime or 0;
        self.nExtFlyTime = math.max(1, self.nExtFlyTime);
        self.nExtFlyTime = self.nExtFlyTime + 8;

        Timer:Register(self.nExtFlyTime, function ()

            self.nExtFlyTime = self.nExtFlyTime or 0;
            self.nExtFlyTime = self.nExtFlyTime - 8;
            self.nExtFlyTime = math.max(0, self.nExtFlyTime);

            me.GetNpc().DoFlyChar(nFlyType, nAdd);
        end)
    end

    Player:ServerSyncData("PlayerAttribute", nType, nAdd);     
end


function PlayerAttribute:OnLogin()
    self:UpdateSelfAllAttrib();
end

PlayerEvent:RegisterGlobal("OnLogin",   PlayerAttribute.OnLogin, PlayerAttribute);