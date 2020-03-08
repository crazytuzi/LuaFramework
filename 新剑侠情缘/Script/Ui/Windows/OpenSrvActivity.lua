local tbUI = Ui:CreateClass("NewInfo_OpenSrvActivity")

--[[
{
	bResult = false,
	nDeadline = 123,
	{{reward1, count1}, {reward2,count2}, {reward3, count3}},
	{{reward1, count1}, {reward2,count2}, {reward3, count3}},
	{{reward1, count1}, {reward2,count2}, {reward3, count3}},
	{{reward1, count1}, {reward2,count2}, {reward3, count3}},
	{{reward1, count1}, {reward2,count2}, {reward3, count3}},
}

{
	bResult = true,
	{
		szKinName = "",
		szMasterName = "",
	},
	...
}
]]
local pPanel = nil
function tbUI:OnOpen(tbData)
	pPanel = self.pPanel
	local bResult = tbData.bResult
	self.pPanel:SetActive("Panel1", not bResult)
	self.pPanel:SetActive("Panel2", bResult)
	self.BtnCheck.pPanel.OnTouchEvent = function()
		Ui:OpenWindow("RankBoardPanel")
	end

	local szRank = ""
	if not me.dwKinId or me.dwKinId<=0 then
		szRank = "家族排名：无家族"
	else
		self:ReqMyKinRank()
	end
	self.pPanel:Label_SetText("FamilyRanking", szRank)

	if bResult then
		self:UpdateResult(tbData)
	else
		self:UpdateRewards(tbData)
	end
end

function tbUI:ReqMyKinRank()
	RemoteServer.OnKinRequest("OpenSrvMyKinRankReq")
end

function tbUI:SetMyKinRank(nRank)
	if not pPanel then return end

	local szRank = "家族排名：榜外"
	if nRank>0 and nRank<=100 then
		szRank = string.format("家族排名：%d", nRank)
	end
	pPanel:Label_SetText("FamilyRanking", szRank)
end

function tbUI:UpdateRewards(tbData)
	local nDeadline = tbData.nDeadline
	local szDeadline = Lib:GetTimeStr(nDeadline)

	local szTimeInfo = "（正在结算...）"
	local nSecondsLeft = nDeadline-GetTime()
	if nSecondsLeft>0 then
		local szDelta = Lib:TimeDesc6(nSecondsLeft)
		szTimeInfo = string.format("（%s后）", szDelta)
	end
	
	local szTxt = string.format("[FFFE0D]%s%s[-]\n\t\t百大家族评选：[ffb400]【第一家族】[-]、[ff68a1]【十大家族】[-]、[9f5fff]【卓越家族】[-]\n\t\t（[FFFE0D]%s[-]之前进入家族的成员可领奖,包括[9f5fff]家族指挥[-]）", szDeadline, szTimeInfo, Lib:GetTimeStr(nDeadline-2*24*3600))
	self.pPanel:Label_SetText("Details1", szTxt)

	local tbRankTitles = {
		"第一名",
		"第二名",
		"第三名",
		"第四名",
		"第五名",
		"6~100名",
	}

	self.ScrollViewRewardItem:Update(#tbRankTitles, function(pGrid, nIdx)
		pGrid.pPanel:Label_SetText("MarkTxt", tbRankTitles[nIdx])
		local tbRewards = tbData[nIdx]
		for i=1,3 do
			local tbReward = tbRewards[i]
			local nItemId, nCount = unpack(tbReward)
			local pItem = pGrid["itemframe"..i]
			pItem:SetGenericItem({"Item", nItemId, nCount})
			pItem.fnClick = pItem.DefaultClick
			local szName = Item:GetItemTemplateShowInfo(nItemId)
			pGrid.pPanel:Label_SetText("ItemName"..i, szName)
		end
	end)
end

function tbUI:UpdateResult(tbData)
	for i=1,10 do
		local tbRow = tbData[i]
		self.pPanel:SetActive("TopTenFamily"..i, not not tbRow)
		if tbRow then
			self.pPanel:Label_SetText("FamilyName"..i, tbRow.szKinName)

			local szName = tbRow.bMaster and "族长：" or "领袖："
			szName = szName..tbRow.szName
			self.pPanel:Label_SetText("LeaderName"..i, szName)
		end
	end
end