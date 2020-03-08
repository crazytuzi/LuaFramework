local tbUi = Ui:CreateClass("WorldCupGuessSelPanel")
local tbAct = Activity.WorldCupGuessAct

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnDetermine = function(self)
		if not self.nSelected or self.nSelected<=0 then
			me.CenterMsg("请选择球队")
			return
		end

		local fnUse = function ()
	        tbAct:Guess(self.nIdx, self.nSelected)
		    Ui:CloseWindow(self.UI_NAME)
	    end
	    local tbTeam = tbAct.tbTeamCfg[self.nSelected]
		local szType = self.nIdx <= 1 and "冠军" or "四强"
	    me.MsgBox(string.format("确定花费[FFFE0D]%d元宝[-]竞猜[FFFE0D]%s[-]为[FFFE0D]%s[-]吗？确定后将不能改变竞猜内容！", tbAct.tbGuessCost[self.nIdx], tbTeam[1], szType), {{"确定", fnUse}, {"取消"}})
	end,

	BtnCancel = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

for nRow=1, 8 do
	for nCol=1, 4 do
		tbUi.tbOnClick[string.format("Group%dCountry%d", nRow, nCol)] = function(self)
			local nItemTemplateId = tbAct.tbSelectCfg[nRow][nCol]
			if self.tbCantSel[nItemTemplateId] then
				self.pPanel:Toggle_SetChecked(string.format("Group%dCountry%d", nRow, nCol), false)
				me.CenterMsg("此队伍已经竞猜过，请勿重复竞猜！")
				return
			end
			self.nSelected = nItemTemplateId
		end
	end
end

function tbUi:OnOpen(nIdx, tbData)
	self.nIdx = nIdx

	local _, tbCfg = tbAct:GetTimeIdx(nIdx <= 1 and tbAct.tbTop1Cfg or tbAct.tbTop4Cfg)
	if not tbCfg then
		me.CenterMsg("当前不可竞猜")
		return 0
	end
	self.pPanel:Label_SetText("Label4", string.format("当前阶段竞猜可获得奖励倍数：%d", tbCfg[3]))
	self.pPanel:Label_SetText("ConsumeProposeTxt2", tostring(tbAct.tbGuessCost[self.nIdx]))

	self.nSelected = nil
	self.tbCantSel = {}
	if nIdx <= 1 then
		if tbData[1][1] then
			self.tbCantSel[tbData[1][1]] = true
		end
	else
		for i=2, 5 do
			if tbData[1][i] then
				self.tbCantSel[tbData[1][i]] = true
			end
		end
	end
	for nRow=1, 8 do
		for nCol=1, 4 do
			local nItemTemplateId = tbAct.tbSelectCfg[nRow][nCol]
			local tbTeam = tbAct.tbTeamCfg[nItemTemplateId]

			local szBtn = string.format("Group%dCountry%d", nRow, nCol)
			self[szBtn].pPanel:Label_SetText(string.format("Group%dCountry%dTxt", nRow, nCol), tbTeam[1])
			self.pPanel:Toggle_SetChecked(szBtn, false)
		end
	end
end