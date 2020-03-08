local tbUi = Ui:CreateClass("PartnerCardAttribContainer");
tbUi.TYPE_PROTECT = 1
tbUi.TYPE_BASIC = 2
tbUi.TYPE_SUIT = 3
tbUi.tbSetting = 
{
	[tbUi.TYPE_PROTECT] = {
		szPanelName = "NurseAttributePanel";
		szTagName = "BtnNurseAttribute";
	};
	[tbUi.TYPE_BASIC] = {
		szPanelName = "BasicsAttributePanel";
		szTagName = "BtnBasicsAttribute";
	};
	[tbUi.TYPE_SUIT] = {
		szPanelName = "TeamAttributePanel";
		szTagName = "BtnTeamAttribute";
	};
}

function tbUi:GetDefaultSkillAttrib(pPlayerAsync)
	local tbSkillAttrib = {}
	local tbPosInfo = not pPlayerAsync and me.GetPartnerPosInfo() or {}
	local fnGetPartnerTId = function (nIdx, pPlayerAsync)
		local nPartnerTId 
		if pPlayerAsync then
			nPartnerTId = pPlayerAsync.GetPartnerInfo(nIdx)
		else
			local tbPartner = me.GetPartnerInfo(tbPosInfo[nIdx] or 0) or {};
			nPartnerTId = tbPartner.nTemplateId
		end
		return nPartnerTId
	end
	
	for i = 1 , 4 do
		local nPartnerTempleteId = fnGetPartnerTId(i, pPlayerAsync) or 0
		local nCardId = PartnerCard:GetCardIdByPartnerTempleteId(nPartnerTempleteId) or 0
		local tbCardInfo = PartnerCard:GetCardInfo(nCardId)
		local szPName = GetOnePartnerBaseInfo(nPartnerTempleteId) 
		if tbCardInfo then
			local tbDes = {}
			tbDes.szCardName = tbCardInfo.szName
			tbDes.szSkillDes = string.format("未激活（需要上阵%s门客方可激活）", szPName or "")
			table.insert(tbSkillAttrib, tbDes)
		end
	end
	return tbSkillAttrib
end

function tbUi:CombineAttribInfo(tbAttribInfo)
	local tbAttrib = {}
	for _, szType in ipairs(PartnerCard.tbPlayerShowAttrib) do
		tbAttrib[szType] = tbAttribInfo[szType] or {nSeq = 1, tbValue = {0,0,0}}
	end
	return tbAttrib
end

function tbUi:CombineSkillAttrib(tbSkillAttrib, tbDefaultSkillAttrib)
	local tbCombineAttrib = Lib:CopyTB(tbSkillAttrib)
	local fnCheckIsActive = function (szCardName)
		for _, v in pairs(tbSkillAttrib) do
			if v.szCardName == szCardName then
				return true
			end
		end
	end
	for _,v in ipairs(tbDefaultSkillAttrib) do
		if not fnCheckIsActive(v.szCardName) then
			table.insert(tbCombineAttrib, v)
		end
	end
	return tbCombineAttrib
end

function tbUi:RefreshData(tbAttrib, pPlayerAsync)
	local _,_, tbSkillAttrib = PartnerCard:GetSkillAttribDesc(tbAttrib.tbPartnerSkill, " ")
	local tbDefaultSkillAttrib = self:GetDefaultSkillAttrib(pPlayerAsync)
	tbSkillAttrib = self:CombineSkillAttrib(tbSkillAttrib, tbDefaultSkillAttrib)
	local fnSetSkill = function (itemObj, nIdx)
		local tbDes = tbSkillAttrib[nIdx]
		local szCardName = tbDes.szCardName or ""
		local szSkillDes = tbDes.szSkillDes or ""
		itemObj.pPanel:Label_SetText("Name", szCardName)
		itemObj.pPanel:Label_SetText("NurseAttribute", szSkillDes)
	end
	
	self.NurseAttributeScrollView:Update(tbSkillAttrib, fnSetSkill)

	local tbAttribInfo = PartnerCard:GetAttribInfo(tbAttrib.tbPlayerAttrib)
	tbAttribInfo = self:CombineAttribInfo(tbAttribInfo)
	local _,_,_, tbAttribDesc = PartnerCard:GetAttribDesc(tbAttribInfo)
	local nLine = math.ceil(#PartnerCard.tbPlayerShowAttrib/2)

	local fnSubAttrib = function (szDes)
		local szAttribName, szValue = "", ""
		local nSubIndx = string.find(szDes, "+")
		if nSubIndx then
			szAttribName = string.sub(szDes, 1, nSubIndx - 1)
			szValue = string.sub(szDes, nSubIndx+1)
		end
		return szAttribName, szValue
	end
	local fnSetPlayer = function (itemObj, nIdx)
		local nLeft = (nIdx - 1) * 2 + 1
		local nRight = (nIdx - 1) * 2 + 2
		local szLeftType = PartnerCard.tbPlayerShowAttrib[nLeft]
		local szRightType = PartnerCard.tbPlayerShowAttrib[nRight]
		itemObj.pPanel:SetActive("Item1", false)
		if szLeftType then
			local szLeftDes = tbAttribDesc[szLeftType] or ""
			local szAttribName, szValue = fnSubAttrib(szLeftDes) 
			itemObj.pPanel:SetActive("Item1", true)
			itemObj["Item1"].pPanel:Label_SetText("lbAttri1", szAttribName or "")
			itemObj["Item1"].pPanel:Label_SetText("lbValue1", szValue or "")
		end
		itemObj.pPanel:SetActive("Item2", false)
		if szRightType then
			local szRightDes = tbAttribDesc[szRightType] or ""
			local szAttribName, szValue = fnSubAttrib(szRightDes) 
			itemObj.pPanel:SetActive("Item2", true)
			itemObj["Item2"].pPanel:Label_SetText("lbAttri2", szAttribName or "")
			itemObj["Item2"].pPanel:Label_SetText("lbValue2", szValue or "")
		end
		
	end
	self.BasicsAttributeScrollView:Update(nLine, fnSetPlayer)

	local tbSuitDesInfo = PartnerCard:GetSuitAttribDesInfo(tbAttrib.tbSuitAttrib, nil, pPlayerAsync)
	local fnSetSuit = function (itemObj, nIdx)
		local tbDes = tbSuitDesInfo[nIdx]
		itemObj.pPanel:Label_SetText("TeamName", tbDes.szSuitName)
		itemObj.pPanel:Label_SetText("TeamMember", string.format("(%s)", tbDes.szCardName or ""))
		itemObj.pPanel:Label_SetText("AttributeAdd", tbDes.szAttribDes)
	end
	self.TeamAttributeScrollView:Update(tbSuitDesInfo, fnSetSuit)

	self["BtnNurseAttribute"].pPanel.OnTouchEvent = function (itemObj)
		self:Update(self.TYPE_PROTECT)
	end
	self["BtnBasicsAttribute"].pPanel.OnTouchEvent = function (itemObj)
		self:Update(self.TYPE_BASIC)
	end
	self["BtnTeamAttribute"].pPanel.OnTouchEvent = function (itemObj)
		self:Update(self.TYPE_SUIT)
	end
	self:Update(self.nType or self.TYPE_PROTECT)
end

function tbUi:Update(nType)
	self.nType = nType or self.nType
	for nIdx, v in pairs(self.tbSetting) do
		self.pPanel:SetActive(v.szPanelName, nIdx == nType)
		self[v.szTagName].pPanel:SetActive("LabelLight", nIdx == nType)
		local szSprite = nIdx == nType and "BtnMain_02" or "BtnMain_01"
		self[v.szTagName].pPanel:Sprite_SetSprite("Main", szSprite)
	end
end