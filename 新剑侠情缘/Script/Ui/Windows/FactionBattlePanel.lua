local tbUi = Ui:CreateClass("FactionBattlePanel")

tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnOpen()
	self:Update()
end

local idListAtIdx = {
	[1] = {1}, [2] = {2}, [3] = {3}, [4] = {4}, [5] = {5}, [6] = {6}, [7] = {7},
	[8] = {8}, [9] = {9}, [10] = {10}, [11] = {11}, [12] = {12}, [13] = {13},
	[14] = {14}, [15] = {15}, [16] = {16},
	[17] = {1,2}, [18] = {3,4}, [19] = {5,6}, [20] = {7,8},
	[21] = {9,10}, [22] = {11,12}, [23] = {13,14}, [24] = {15,16},
	[25] = {1,2,3,4}, [26] = {5,6,7,8},
	[27] = {9,10,11,12}, [28] = {13,14,15,16},
	[29] = {1,2,3,4,5,6,7,8},
	[30] = {9,10,11,12,13,14,15,16},
	[31] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16},
}

function tbUi:GetMinWin(idx)
	if idx<=16 then
		return 0
	elseif idx<=24 then
		return 1
	elseif idx<=28 then
		return 2
	elseif idx<=30 then
		return 3
	else
		return 4
	end
	return 0
end

function tbUi:GetName(idx)
	if idx>0 and idx<=#idListAtIdx then
		local minWin = self:GetMinWin(idx)
		local idList = idListAtIdx[idx]
		for _,id in pairs(idList) do
			local info = FactionBattle.tb16thPlayer[id]
			if info and info.nWinCount>=minWin then
				return info.szName, info.nPlayerId, info.nWinCount == minWin
			end
		end
	end
	return "", 0, false
end

function tbUi:Update()
	for i=1,31 do
		local ctrlName = string.format("n%d", i)
		local szStarName = string.format("n%dIcon", i)
		self.pPanel:SetActive(szStarName, false)
		local name, nPlayerId, bCur = self:GetName(i)
		if nPlayerId == me.dwID and bCur then
			name = string.format("[c8ff00]%s[-]", name)
			self.pPanel:SetActive(szStarName, true)
		end
		self.pPanel:Label_SetText(ctrlName, name)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_FACTION_TOP_CHANGE, self.Update},
	}
	return tbRegEvent
end

local tbReportUi = Ui:CreateClass("FactionReportPanel")
tbReportUi.tbOnClick = {}
function tbReportUi.tbOnClick:BtnFactionReport()
	if not Ui:WindowVisible("FactionBattlePanel") then
	    Ui:OpenWindow("FactionBattlePanel")
	end
end
