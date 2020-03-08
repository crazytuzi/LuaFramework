function Survey:Init()
	self.tbLatest = nil
	self.tbAnswers = {}
end

function Survey:SetLatest(tbData)
	self.tbLatest = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_SURVEY_STATE)
end

function Survey:Finish(bUrl)
	RemoteServer.SurveyFinish(bUrl, self.tbLatest.GroupID, self.tbAnswers)
	self:_Finish()
end

function Survey:_Finish()
	self.tbLatest = nil
	self.tbAnswers = {}
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_SURVEY_STATE)
end

function Survey:Available()
	return self.tbLatest~=nil
end

function Survey:IsUrlMode()
	local szUrl = self:GetUrl()
	return szUrl and szUrl~=""
end

function Survey:GetUrl()
	return self.tbLatest.Url
end

function Survey:UpdateQueue()
	self.tbAnswers = {}
	local tbQueue = {}
	for _,tbQuestion in ipairs(self.tbLatest.tbQuestions) do
		table.insert(tbQueue, tbQuestion)
	end
	self.tbQueue = tbQueue
end

local function _ShuffleChoices(tbQuestion)
	if not tbQuestion then return end

	local tbFixed = {}
	local tbShuffled = {}
	math.randomseed(os.time())
	for _,tb in ipairs(tbQuestion.tbChoices) do
		if tb.nPos and tb.nPos>0 then
			table.insert(tbFixed, tb)
		else
			local nCurLen = #tbShuffled
			local nRandPos = nCurLen>0 and math.random(1, nCurLen+1) or 1
			table.insert(tbShuffled, nRandPos, tb)
		end
	end

	table.sort(tbFixed, function(tbA, tbB)
		return tbA.nPos<tbB.nPos
	end)
	for _,tb in ipairs(tbFixed) do
		table.insert(tbShuffled, tb.nPos, tb)
	end
	tbQuestion.tbChoices = tbShuffled
end

function Survey:Next()
	local tbQuestion = table.remove(self.tbQueue, 1)
	if tbQuestion then
		local nType = tbQuestion.Type
		if nType==1 or nType==2 then
			_ShuffleChoices(tbQuestion)
		end
	end
	return tbQuestion
end

function Survey:Add(tbQuestion)
	for _,tbQ in ipairs(self.tbQueue) do
		if tbQ.Index==tbQuestion.Index then
			return
		end
	end
	table.insert(self.tbQueue, 1, tbQuestion)
end

function Survey:AddById(nId)
	local tbQuestion = self.tbLatest.tbQuestions[nId]
	if not tbQuestion then
		print("[x] Survey:AddById failed", nId)
		return
	end
	self:Add(tbQuestion)
end

function Survey:JumpTo(nIndex)
	while true do
		local tbQuestion = self:Next()
		if not tbQuestion then
			print(string.format("[x] Survey:JumpTo %d failed.", nIndex))
			break
		end
		if tbQuestion.Index==nIndex then
			self:Add(tbQuestion)
			break
		end
	end
end

function Survey:IsOptional(tbQuestion)
	return tbQuestion.nOptional and tbQuestion.nOptional>0
end

function Survey:GetMaxSel(tbQuestion)
	return tbQuestion.MaxChoice or 0
end

function Survey:ProcessFlow(tbChoice)
	local nFlowJump = tbChoice.nFlowJump
	if nFlowJump and nFlowJump>0 then
		self:JumpTo(nFlowJump)
		return
	end

	if tbChoice.tbFlowAdd then
		for _,nFlowAdd in ipairs(tbChoice.tbFlowAdd) do
			if nFlowAdd>0 then
				self:AddById(nFlowAdd)
			end
		end
	end
end

function Survey:RecordAnswer(nId, szChoices, szInput)
	self.tbAnswers[nId] = {
		szChoices = szChoices,
		szInput = szInput,
	}
end

function Survey:FilterSpecialChars(szInput)
	szInput = Lib:StrTrim(szInput)
	szInput = Lib:StrFilterChars(szInput, {" ", "\t", "\n", "\r", ",", ";", "|"})
	return szInput
end

--------------------------

local SurveySelInput = Ui:CreateClass("SurveySelInput");

SurveySelInput.tbOnSubmit = {}

function SurveySelInput.tbOnSubmit:InputTxt()
	local szInput = self.pPanel:Input_GetText("InputTxt");
	local szInput = Survey:FilterSpecialChars(szInput)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SURVEY_SEL_INPUT_CHANGE, szInput)
end

