Require("CommonScript/Npc/NpcDefine.lua")
local tbUi = Ui:CreateClass("FirstRecharge")
tbUi.NORMAL_VALUE =  --首充奖励价值量
{
    {40,  2660000, {2990000, 3660000, 4660000, 5660000, 5990000, 6660000}},  --39级段的奖励价值量，包含晚进服价值（为了显示的数值好看，这个价值≠礼包的实际价值）
    {50,  2660000, {2990000, 3660000, 4660000, 5660000, 5990000, 6660000}},
    {60,  2660000, {2990000, 3660000, 4660000, 5660000, 5990000, 6660000}},
    {70,  2660000, {2990000, 3660000, 4660000, 5660000, 5990000, 6660000}},
    {80,  2990000, {3660000, 4660000, 4990000, 5660000, 6660000, 7660000}},
    {90,  3660000, {3990000, 4660000, 5660000, 6660000, 6990000, 7660000}},
    {100, 4660000, {4990000, 5660000, 6660000, 7990000, 7990000, 8660000}},
    {999, 4660000, {4990000, 5660000, 6660000, 7990000, 7990000, 8660000}},
}

-- 补偿
tbUi.tbComItem = {
    {"Contrib", 2000},
    {"Coin", 20000},
    {"Item", 212, 20},
    {"Item", 2154, 2},
    {"Item", 786, 5},
    {"Item", 787, 5},
}

--外装展示
tbUi.tbRes = {
    [Npc.NpcResPartsDef.npc_part_head] = {{7001, 8001}, 9001, 8001, 6001, {6001, 9001}, 9001, 7001, 9001, 6001, {7001,9001}, 7001, 8001, 6001, 9001, {6001, 9001},{7001, 8001}, {6001, 9001}, {6001, 9001}},
    [Npc.NpcResPartsDef.npc_part_body] = {{7001, 8001}, 9001, 8001, 6001, {6001, 9001}, 9001, 7001, 9001, 6001, {7001,9001}, 7001, 8001, 6001, 9001, {6001, 9001},{7001, 8001}, {6001, 9001}, {6001, 9001}},
}

function tbUi:OnOpen()
    self.bNpcOpen = true
    self:Update()
    self.pPanel:Label_SetText("FirstRechargeTip", "赠送限时外装体验")
end

function tbUi:Update()
    local bGetFirstRecharge = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_GET_FIRST_RECHARGE) == 1
    self.pPanel:SetActive("BtnRecharge", not bGetFirstRecharge)
    self.pPanel:SetActive("GiveOut", bGetFirstRecharge)
    self.pPanel:Label_SetText("GiveOut", "已发放至背包中")

    local nOffTime = 4*60*60
    local nServerCreateDay = Lib:GetLocalDay(GetServerCreateTime() - nOffTime)
    local nPlayerCreateDay = Lib:GetLocalDay(me.dwCreateTime - nOffTime)
    local nCompensationDay = math.min(nPlayerCreateDay - nServerCreateDay, Recharge.MAX_COMPENSATION)
    -- self.pPanel:SetActive("citemflame", nCompensationDay > 0)
    local nAllValue = 0
    for _, tbInfo in ipairs(self.NORMAL_VALUE) do
        if me.nLevel < tbInfo[1] then
            if nCompensationDay > 0 then
                nAllValue = tbInfo[3][nCompensationDay]
            else
                nAllValue = tbInfo[2]
            end
            break
        end
    end
    if version_hk or version_tw then
        --self.pPanel:Label_SetText("GiftNum", "三千元宝")
    else
        local fMoney, szMoneyName = Recharge:GetMoneyShowDesc( math.floor(nAllValue/100) )
        if version_vn then
            self.pPanel:Label_SetText("GiftNum", string.format("%s%s", Lib:ThousandSplit(fMoney), szMoneyName))
        elseif version_kor then
        	self.pPanel:Label_SetText("GiftNum", string.format("%s%d", szMoneyName, fMoney))
        else
            self.pPanel:Label_SetText("GiftNum", string.format("%d%s", fMoney, szMoneyName))
        end
    end
    local nParamId = KItem.GetItemExtParam(Recharge.nFirstAwardItem, 1)
    nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(me.nLevel, nParamId)
    local _, _, tbItem = Item:GetClass("RandomItem"):RandomItemAward(me, nParamId)
    local nAwardLen = #tbItem
    for nIdx, tbInfo in ipairs(tbItem) do
        self["itemflame" .. nIdx]:SetGenericItem(tbInfo)
        self["itemflame" .. nIdx].fnClick = self["itemflame" .. nIdx].DefaultClick
    end
--[[
    if nCompensationDay > 0 then
        for nIdx, tbInfo in ipairs(self.tbComItem) do
            local tbMulAward = {unpack(tbInfo)}
            local nLen = #tbMulAward
            tbMulAward[nLen] = tbMulAward[nLen] * nCompensationDay
            nAwardLen = nAwardLen + 1
            self["itemflame" .. nAwardLen]:SetGenericItem(tbMulAward)
            self["itemflame" .. nAwardLen].fnClick = self["itemflame" .. nAwardLen].DefaultClick
        end
    end
]]
    for i = nAwardLen + 1, 99 do
        if not self["itemflame" .. i] then
            break
        end
        self.pPanel:SetActive("itemflame" .. i, false)
    end

    self.pPanel:NpcView_Open("ShowRole", me.nFaction, me.nSex)
    for nPos, tbInfo in pairs(self.tbRes) do
        local res = tbInfo[me.nFaction]
        res = (type(res) == "table") and res[me.nSex] or res
        self.pPanel:NpcView_ChangePartRes("ShowRole", nPos, res)
    end
end

function tbUi:OnClose()
    if self.bNpcOpen then
        self.bNpcOpen = false;
        self.pPanel:NpcView_Close("ShowRole");
    end
end

tbUi.tbOnClick = {
    BtnRecharge = function ()
        Ui:CloseWindow("WelfareActivity")
        Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    end
}

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,
}