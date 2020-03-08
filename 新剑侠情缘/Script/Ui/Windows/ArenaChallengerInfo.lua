--[[
	tbData = {}

	ArenaBattle:
	tbData["ChallengeInfo"] = {1,2,3}
	tbData["ChallengeTitle"] = {szText = "",nTime = 123}
]]


local tbUi = Ui:CreateClass("ArenaChallengerInfoPanel");
local tbType = 
{
	Default = "Default",
	ArenaBattle = "ArenaBattle",
}

local tbUiName = 
{
	["ChallengeInfo"] = "右侧文本",
	["ChallengeTitle"] = "顶部文本",
}

function tbUi:OnOpen(szType,tbData)
	if not szType or not tbData then
		return
	end
	self:HideAll()
	self:CloseTimer()
	self:RefreshUi(szType,tbData)
end

function tbUi:HideAll()
	for szUiName,_ in pairs(tbUiName) do
		self.pPanel:SetActive(szUiName,false)
	end
end

function tbUi:RefreshUi(szType,tbData)
	szType = szType or ""
	tbData = tbData or {}
	if not tbType[szType] then
		return
	end
	if szType == tbType.ArenaBattle then
		if tbData["ChallengeInfo"] then
			self.pPanel:SetActive("ChallengeInfo",true)
			local tbApply = tbData["ChallengeInfo"] or {}
			local szApply = ""
			local nApplyNum = #tbApply
			if nApplyNum > 0 then
				for nIdx = 1,nApplyNum - 1 do
					if tbApply[nIdx] then
						szApply = szApply ..string.format("%s号、",tbApply[nIdx])
					end
				end
				if tbApply[nApplyNum] then
					szApply = szApply ..string.format("%s号",tbApply[nApplyNum])
				end
			end
			self.pPanel:Label_SetText("ChallengeArena", szApply);
		end

		if tbData["ChallengeTitle"] then
			self.pPanel:SetActive("ChallengeTitle",true)
			local nTime = tbData["ChallengeTitle"].nTime
			self.szText = tbData["ChallengeTitle"].szText or ""
			if nTime then
				self.nTime = tonumber(nTime) or 0
				if self.nTime > 0 then
					if not self.nMainTimer then
						self.nMainTimer = Timer:Register(Env.GAME_FPS, self.UpdateChallengeTitle, self);
					end
				end
			else
				self.pPanel:Label_SetText("ChallengeTitle",self.szText)
			end
		end
	elseif szType == tbType.Default then
		if tbData["TopTitle"] then
			self.szText = tbData["TopTitle"]
			self.pPanel:SetActive("ChallengeTitle",true)
			self.pPanel:Label_SetText("ChallengeTitle", self.szText);
			if tbData["nTime"] then
				self.nTime = tonumber(tbData["nTime"]) or 0
				if self.nTime > 0 then
					if self.nMainTimer then
						Timer:Close(self.nMainTimer)
						self.nMainTimer = nil
					end
					self.nMainTimer = Timer:Register(Env.GAME_FPS, self.UpdateChallengeTitle, self);

					self.pPanel:Label_SetText("ChallengeTitle",(self.szText or "") ..Lib:TimeDesc(self.nTime))
				end
			end
		else
			self.pPanel:SetActive("ChallengeTitle",false)
		end

		if tbData["RightTitle"] then
			self.pPanel:SetActive("ChallengeInfo",true)
			self.pPanel:SetActive("ChallengeArenaTitle",true)
			local nPivot = tonumber(tbData["RightTitlePivot"])
			if nPivot then
				self.pPanel:ChangePivot("ChallengeArenaTitle", nPivot)
			end
			self.pPanel:Label_SetText("ChallengeArenaTitle", tbData["RightTitle"]);
		else
			self.pPanel:SetActive("ChallengeArenaTitle",false)
		end

		if tbData["RightInfo"] then
			self.pPanel:SetActive("ChallengeInfo",true)
			self.pPanel:SetActive("ChallengeArena",true)
			local nPivot = tonumber(tbData["RightInfoPivot"])
			if nPivot then
				self.pPanel:ChangePivot("ChallengeArena", nPivot)
			end
			self.pPanel:Label_SetText("ChallengeArena", tbData["RightInfo"]);
		elseif tbData["RightTime"] then
			self.nRightTime = tonumber(tbData["RightTime"]) or 0
			if self.nRightTime > 0 then
				if self.nRightTimer then
					Timer:Close(self.nRightTimer)
					self.nRightTimer = nil
				end
				self.nRightTimer = Timer:Register(Env.GAME_FPS, self.UpdateRightTimer, self);
			end

			self.pPanel:SetActive("ChallengeInfo",true)
			self.pPanel:SetActive("ChallengeArena",true)

			local nPivot = tonumber(tbData["RightInfoPivot"])
			if nPivot then
				self.pPanel:ChangePivot("ChallengeArena", nPivot)
			end
			self.pPanel:Label_SetText("ChallengeArena", Lib:TimeDesc(self.nRightTime));
		else
			self.pPanel:SetActive("ChallengeArena",false)
		end

		self.pPanel:SetActive("HelpInfo",false)
	end
end

function tbUi:UpdateChallengeTitle()
	if not self.nTime or self.nTime < 0 then
		self:CloseTimer()
		self.nTime = nil
		self.pPanel:SetActive("ChallengeArena",false)
		return
	end
	self.nTime = self.nTime - 1
	self.pPanel:Label_SetText("ChallengeTitle",(self.szText or "") ..Lib:TimeDesc(self.nTime))
	return true
end

function tbUi:UpdateRightTimer()
	if not self.nRightTime or self.nRightTime < 0 then
		self:CloseRightTimer()
		self.nRightTime = nil
		self:CloseSelf()
		return
	end

	self.nRightTime = self.nRightTime - 1

	self.pPanel:Label_SetText("ChallengeArena", Lib:TimeDesc(self.nRightTime));

	return true
end

function tbUi:CloseSelf()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnClose()
	self:CloseTimer()
	self:CloseRightTimer()
end

function tbUi:CloseTimer()
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function tbUi:CloseRightTimer()
	if self.nRightTimer then
		Timer:Close(self.nRightTimer)
		self.nRightTimer = nil
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYN_PLAYER_APPLY_ARENA_DATA, self.RefreshUi, self },
	};

	return tbRegEvent;
end