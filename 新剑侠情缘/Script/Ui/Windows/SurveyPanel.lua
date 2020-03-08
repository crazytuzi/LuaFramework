local tbUI = Ui:CreateClass("SurveyPanel")

local handlers = {
	[1] = {	--单选
		fnShowQuestion = "ShowSingleSel",
		fnSubmit = "SubmitSingleSel",
	},
	[2] = {	--多选
		fnShowQuestion = "ShowMultiSel",
		fnSubmit = "SubmitMultiSel",
	},
	[3] = {	--填空
		fnShowQuestion = "ShowInput",
		fnSubmit = "SubmitInput",
	},
	[4] = {	--矩阵
		fnShowQuestion = "ShowMatrix",
		fnSubmit = "SubmitMatrix",
	},
}

tbUI.tbOnClick = 
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnBeginToAnswer = function(self)
    	self:Begin()
    end,

    BtnNextQuestion = function(self)
    	self:Next()
    end,

    BtnFinish = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUI:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_SURVEY_SEL_INPUT_CHANGE, self.OnSurveySelInputChange, self },
	};

	return tbRegEvent;
end

local tbQuestion = {}
local tbSingleSels = {}
local tbSingleSelData = {nCurSel=0, szCurText=""}
local tbMutiSels = {}
local tbMultiSelData = {tbCurSels={}, szCurText=""}
local tbMatrixRows = {}

function tbUI:InitLogic()
	Survey:UpdateQueue()
end

function tbUI:ShowPanel(szType)
	self.pPanel:SetActive("CoverPanel", szType=="welcome")
	self.pPanel:SetActive("QuestionPanel", szType=="question")
	self.pPanel:SetActive("ThanksPanel", szType=="thanks")
end

function tbUI:InitUI()
	local tb = {"Gold", Survey.tbLatest.RewardGold}
	self.itemframe:SetGenericItem(tb)
	local szDesc = Lib:StrTrim(Survey.tbLatest.Description)
	if szDesc and szDesc~="" then
		self.pPanel:Label_SetText("Txt1", szDesc)
	end
	self.pPanel:Input_SetText("TextareaPanel", "")
	self.pPanel:Input_SetDefaultText("TextareaPanel", "请输入要回答的内容（不超过120字）")
end

function tbUI:OnOpen()
	if Survey:IsUrlMode() then
		local szUrl = Survey:GetUrl()
		Sdk:OpenUrl(szUrl)
		Survey:Finish(true)
		return 0
	else
		self:InitLogic()
		self:InitUI()
		self:ShowPanel("welcome")
	end
end

function tbUI:HideAllQuestionPanels()
	self.pPanel:SetActive("SelectPanel", false)
	self.pPanel:SetActive("TextareaPanel", false)
	self.pPanel:SetActive("MatrixPanel", false)
end

function tbUI:ShowQuestion()
	self:HideAllQuestionPanels()
	self.pPanel:Label_SetText("Content", tbQuestion.Question)

	local nType = tbQuestion.Type
	local handler = handlers[nType]
	if not handler then
		print("[x] tbUI:ShowQuestion, unknown Type", nType)
		return
	end
	self[handler.fnShowQuestion](self)
end

local function _SingleTouchHandler(pSender, nRealId)
	for _,p in ipairs(tbSingleSels) do
		p.pPanel:SetActive("CheckMark", p.TypeIcons==pSender)
	end

	tbSingleSelData.nCurSel = nRealId
end

local function _MultiTouchHandler(pSender, nRealId)
	local pBtnSender = nil
	for _,p in ipairs(tbMutiSels) do
		if p.TypeIcons==pSender then
			pBtnSender = p
			break
		end
	end

	local bChecked = pBtnSender.pPanel:IsActive("CheckMark")
	local nMaxSel = Survey:GetMaxSel(tbQuestion)
	if nMaxSel>0 and not bChecked then
		local nCurCount = 0
		for _,bChecked in pairs(tbMultiSelData.tbCurSels) do
			if bChecked then
				nCurCount = nCurCount+1
			end
		end
		if nCurCount>=nMaxSel then
			me.CenterMsg(string.format("最多可选%d个", nMaxSel))
			return
		end
	end
	pBtnSender.pPanel:SetActive("CheckMark", not bChecked)

	tbMultiSelData.tbCurSels[nRealId] = not bChecked
end

function tbUI:_ShowSel(bSingle)
	local tbSels = bSingle and tbSingleSels or tbMutiSels

	local nCount = #tbQuestion.tbChoices
	local nRows = math.ceil(nCount/2)
	local fnSetItem = function(pGrid, nIdx)
		for i=1,2 do
			local pBtn = pGrid[string.format("BtnAnswer%d", i)]
			local nRealId = (nIdx-1)*2+i
			local tbChoice = tbQuestion.tbChoices[nRealId]
			local bValid = not not tbChoice
			pBtn.pPanel:SetActive("Main", bValid)
			if bValid then
				table.insert(tbSels, pBtn)
				pBtn.TypeIcons.pPanel:SetActive("Single", bSingle)
				pBtn.TypeIcons.pPanel:SetActive("Multi", not bSingle)

				local bChecked = false
				if bSingle then
					bChecked = tbSingleSelData.nCurSel==nRealId
				else
					bChecked = not not tbMultiSelData.tbCurSels[nRealId]
				end

				pBtn.pPanel:SetActive("CheckMark", bChecked)
				pBtn.pPanel:Label_SetText("Title", tbChoice.szA)
				local bInput = tbChoice.nOther and tbChoice.nOther>0
				if bInput then
					local szTxt = ""
					if bSingle then
						szTxt = tbSingleSelData.szCurText
					else
						szTxt = tbMultiSelData.szCurText
					end
					pBtn.pPanel:Input_SetText("InputTxt", szTxt)
				end
				pBtn.pPanel:SetActive("FreeInput", bInput)
				pBtn.TypeIcons.pPanel.OnTouchEvent = function(pSender)
					local fnSel = bSingle and _SingleTouchHandler or _MultiTouchHandler
					fnSel(pSender, nRealId)
				end
			end
		end
	end
	self.SelectPanel:Update(nRows, fnSetItem)
end

function tbUI:ShowSingleSel()
	tbSingleSels = {}
	tbSingleSelData = {nCurSel=0, szCurText=""}
	self:_ShowSel(true)

	self.pPanel:SetActive("SelectPanel", true)
end

function tbUI:ShowMultiSel()
	tbMutiSels = {}
	tbMultiSelData = {tbCurSels={}, szCurText=""}
	self:_ShowSel(false)

	self.pPanel:SetActive("SelectPanel", true)
end

function tbUI:ShowInput()
	self.pPanel:Input_SetText("TextareaPanel", "")
	self.pPanel:SetActive("TextareaPanel", true)
end

function tbUI:ShowMatrix()
	local nRows = #tbQuestion.tbChoices
	if nRows>4 then
		print("[x] tbUI:ShowMatrix, overflow", nRows)
		return
	end
	tbMatrixRows = {}
	local nChoiceCount = tbQuestion.tbChoices[1].nOther
	for i=1,11 do
		if i<=nChoiceCount then
			self.pPanel:Label_SetText(string.format("MatrixTitle%d", i), tbQuestion.tbHeader[i])
		end
		self.pPanel:SetActive(string.format("MatrixTitle%d", i), i<=nChoiceCount)
	end

	self.MatrixGroup:Update(nRows, function(pGrid, nIdx)
		table.insert(tbMatrixRows, pGrid)
		local tbChoice = tbQuestion.tbChoices[nIdx]
		pGrid.pPanel:Label_SetText("Title", tbChoice.szA)
		for i=1,11 do
			local pSelect = pGrid[string.format("Select%d", i)]
			pSelect.pPanel:SetActive("Main", i<=nChoiceCount)
			pSelect.pPanel:SetActive("CheckMark", false)
			pSelect.pPanel.OnTouchEvent = function()
				for j=1,11 do
					local pCurSel = pGrid[string.format("Select%d", j)]
					if not pCurSel.pPanel:IsActive("Main") then
						break
					end
					pCurSel.pPanel:SetActive("CheckMark", pCurSel==pSelect)
				end
			end
		end
	end)
	self.pPanel:SetActive("MatrixPanel", true)
end

function tbUI:SubmitSingleSel()
	local nCurSel = tbSingleSelData.nCurSel
	if nCurSel<=0 then
		if not Survey:IsOptional(tbQuestion) then
			return false, "请先选择答案，再点击下一题"
		end
	else
		local tbChoice = tbQuestion.tbChoices[nCurSel]
		Survey:ProcessFlow(tbChoice)
		local bInput = tbChoice.nOther and tbChoice.nOther>0
		local szInput = nil
		if bInput then
			szInput = tbSingleSelData.szCurText
			if szInput=="" then
				return false, "请输入填空，再点击下一题"
			end
		end
		Survey:RecordAnswer(tbQuestion.Index, tostring(tbChoice.nIdx), szInput)
	end
	return true
end

function tbUI:SubmitMultiSel()
	local tbCurSels = {}
	for nId,bChecked in pairs(tbMultiSelData.tbCurSels) do
		if bChecked then
			table.insert(tbCurSels, nId)
		end
	end

	if not next(tbCurSels) then
		if not Survey:IsOptional(tbQuestion) then
			return false, "请先选择答案，再点击下一题"
		end
	else
		table.sort(tbCurSels, function(nA, nB)
			local tbA = tbQuestion.tbChoices[nA]
			local tbB = tbQuestion.tbChoices[nB]
			return tbA.nIdx<tbB.nIdx
		end)

		local szChoices = ""
		local szInputs = ""
		for _,nCurSel in ipairs(tbCurSels) do
			local tbChoice = tbQuestion.tbChoices[nCurSel]
			szChoices = szChoices..tostring(tbChoice.nIdx)..";"
			Survey:ProcessFlow(tbChoice)
			local bInput = tbChoice.nOther and tbChoice.nOther>0
			if bInput then
				local szInput = tbMultiSelData.szCurText
				if szInput=="" then
					return false, "请输入填空，再点击下一题"
				end
			end
		end
		szInputs = tbMultiSelData.szCurText
		Survey:RecordAnswer(tbQuestion.Index, szChoices, szInputs)
	end
	return true
end

function tbUI:SubmitInput()
	local szContent = self.pPanel:Input_GetText("TextareaPanel")
	szContent = Survey:FilterSpecialChars(szContent)
	if szContent=="" then
		if not Survey:IsOptional(tbQuestion) then
			return false, "请先回答，再点击下一题"
		end
	else
		Survey:RecordAnswer(tbQuestion.Index, nil, szContent)
	end
	return true
end

function tbUI:SubmitMatrix()
	local tbCurSels = {}
	for _,pRow in ipairs(tbMatrixRows) do
		for i=1,11 do
			local pSelect = pRow[string.format("Select%d", i)]
			if not pSelect.pPanel:IsActive("Main") then
				break
			end

			local bChecked = pSelect.pPanel:IsActive("CheckMark")
			if bChecked then
				table.insert(tbCurSels, i)
				break
			end
		end
	end

	if #tbCurSels~=#tbQuestion.tbChoices then
		return false, "请回答所有问题，再点击下一题"
	end
	local szChoices = table.concat(tbCurSels, ";")
	Survey:RecordAnswer(tbQuestion.Index, szChoices, nil)
	return true
end

function tbUI:ShowNextQuestion()
	tbQuestion = Survey:Next()
	if not tbQuestion then
		self:Finish()
		return
	end
	self:ShowQuestion()
end

function tbUI:Begin()
	self:ShowPanel("question")
	self:ShowNextQuestion()
end

function tbUI:Next()
	local nType = tbQuestion.Type
	local handler = handlers[nType]
	if not handler then
		print("[x] tbUI:Next, unknown Type", nType)
		return
	end

	local bOk, szErr = self[handler.fnSubmit](self)
	if not bOk then
		me.CenterMsg(szErr)
		return
	end

	self:ShowNextQuestion()
end

function tbUI:Finish()
	Survey:Finish(false)
	self:ShowPanel("thanks")
end

function tbUI:OnSurveySelInputChange(szInput)
	if tbQuestion.Type==1 then
		tbSingleSelData.szCurText = szInput
	elseif tbQuestion.Type==2 then
		tbMultiSelData.szCurText = szInput
	end
end
