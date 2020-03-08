
ChangeFaction.tbDef = ChangeFaction.tbDef or {};
local tbDef = ChangeFaction.tbDef;

tbDef.nSaveGroup = 104;
tbDef.nSaveFlag  = 1;
tbDef.nSaveUseCD = 2;
tbDef.nSaveOrgFaction = 3;
tbDef.nSaveEnterFaction = 4;
tbDef.nSaveEnterSex = 5;



------策划填写----------------
tbDef.nMapTID = 1005; --地图ID
tbDef.tbEnterPos = {4500, 5700}; --进入点
tbDef.nChangeFactionLing = 2682; --转门派令牌
tbDef.nMinChangeLevel = 40; --最小多少等級可以转
tbDef.nLevelGetLing = 30; --多少等级可以获得令牌
tbDef.tbMailItem = {{"item", 2682, 1}}; --发送令牌
tbDef.nUseFactionLingCD = 3 * 1 * 60 * 60; --使用门派令的时间

tbDef.nOrgFactionItem = 2846; --还原始门派道具ID
tbDef.nOrgFactionTime = 1 * 1 * 60 * 60; --还原始门派的时间

function ChangeFaction:GetUseFactionCD()
    if tbDef.nActUseFactionLingCD then
        return tbDef.nActUseFactionLingCD;
    end

    return tbDef.nUseFactionLingCD;
end