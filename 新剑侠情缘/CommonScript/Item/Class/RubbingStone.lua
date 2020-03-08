---------------拓印道具相关---------------
local tbPaper = Item:GetClass("RubbingPaper")
tbPaper.ExtParam_Finish = 1

function tbPaper:GetUseSetting(nItemTemplateId, nItemId)
    return {}
end

function tbPaper:GetFinishItemTID(nItemTemplateId)
	return KItem.GetItemExtParam(nItemTemplateId, self.ExtParam_Finish)
end

local tbPDP = Item:NewClass("RubbingPaper_DuanPian", "RubbingPaper")
local tbPMB = Item:NewClass("RubbingPaper_MiBen", "RubbingPaper")



local tbStone = Item:GetClass("RubbingStone")
function tbStone:OnUse(it)
end

function tbStone:OnClientUse(it)
	Ui:CloseWindow("ItemTips")
	Ui:OpenWindow("JueXueRubbingPanel", it.dwId)
end

function tbStone:TryRubbing(pPlayer, nStoneId, nPaperId)
	local pStone = KItem.GetItemObj(nStoneId)
	local pPaper = KItem.GetItemObj(nPaperId)
	local nCount = 1
	if not pStone or not pPaper or pStone.nCount < nCount or pPaper.nCount < nCount then
		return
	end
	local szClass = string.gsub(pStone.szClass, "Stone", "Paper")
	if szClass ~= pPaper.szClass then
		return
	end
	if pPlayer.ConsumeItem(pStone, nCount, Env.LogWay_Rubbing) ~= nCount then
		Log("RubbingStone ConsumeStone Fail", pPlayer.dwId, nStoneId)
		return
	end
	if pPlayer.ConsumeItem(pPaper, nCount, Env.LogWay_Rubbing) ~= nCount then
		Log("RubbingStone ConsumePaper Fail", pPlayer.dwId, nPaperId)
		return
	end

	local nFinish = KItem.GetItemExtParam(pPaper.dwTemplateId, tbPaper.ExtParam_Finish)
	pPlayer.SendAward({{"Item", nFinish, 1}}, false, false, Env.LogWay_Rubbing)
end

tbStone.tbSafeFunc = {
	["TryRubbing"] = true,
}
function tbStone:OnClientCall(pPlayer, szFunc, ...)
	if not self.tbSafeFunc[szFunc] then
		return
	end
	self[szFunc](self, pPlayer, ...)
end

local tbSDP = Item:NewClass("RubbingStone_DuanPian", "RubbingStone")
local tbSMB = Item:NewClass("RubbingStone_MiBen", "RubbingStone")