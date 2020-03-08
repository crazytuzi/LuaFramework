Require("CommonScript/Activity/WarOfIceAndFire.lua");

local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;

local tbItem = Item:GetClass("WarOfIceAndFireAddJoinCount")
tbItem.nAddCount = 1;

function tbItem:CheckJoinCount(pPlayer, nAdd)
    local nDegreeAdd = DegreeCtrl:GetDegree(pPlayer, "WarOfIceAndFireAdd");  
    if nDegreeAdd <= 0 then
        return false, "每天增加的次数不足";
    end

    return true, "";
end

function tbItem:OnUse(it)
    local bRet, szMsg = self:CheckJoinCount(me, tbItem.nAddCount);
    if not bRet then
        me.CenterMsg(szMsg, true);
        return;
    end

    DegreeCtrl:ReduceDegree(me, "WarOfIceAndFireAdd", 1);
    tbWarOfIceAndFire:AddPlayerJoinCount(me, tbItem.nAddCount);
    me.CenterMsg("获得一次参加次数", true);
    return 1
end