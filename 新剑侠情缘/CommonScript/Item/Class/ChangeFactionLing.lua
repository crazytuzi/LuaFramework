
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");
local tbDef = ChangeFaction.tbDef;
local tbItem = Item:GetClass("ChangeFactionLing");

function tbItem:OnUse(it)
    local nLastTime = me.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD);
    local nRetTime = nLastTime - GetTime();
    if nRetTime > 0 then
        me.CenterMsg(string.format("%s后才可以使用", Lib:TimeDesc2(nRetTime)), true);
        return;
    end    

	local bRet, szMsg = self:CheckCanUse(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	
    me.MsgBox("你要前往洗髓岛进行转门派吗？\n进入洗髓岛后，无论[FF0000]是否转职[-]，均会[FF0000]消耗1个天剑令[-]", {{"前往", self.Affirm, self, me.dwID}, {"取消"}})
end

function tbItem:Affirm(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        Log("ERROR ChangeFactionLing Not Player");
        return;
    end

    ChangeFaction:ApplyEnterMap(pPlayer);
end

function tbItem:CheckCanUse(pPlayer)
	return true
end

