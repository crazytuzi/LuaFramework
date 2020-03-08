local tbUi = Ui:CreateClass("ArenaPanel");

function tbUi:OnOpen()
	self:RefreshUi()
	ArenaBattle:SynArenaData()
end


function tbUi:RefreshUi()
	local tbArenaData = ArenaBattle:GetArenaData()
	
	for nArenaId = 1,ArenaBattle.nArenaNum do

		local szItem = string.format("Item%d",nArenaId)
		self[szItem].pPanel:SetActive("Head",false)
		self[szItem].pPanel:SetActive("BtnChallenge",false)
		self[szItem].pPanel:SetActive("BtnWaiting",false)
		self[szItem].pPanel:SetActive("PlayerTitle",false)
		self[szItem].pPanel:SetActive("Name",false)
		self[szItem].pPanel:SetActive("Number",false)
		self[szItem].pPanel:SetActive("Arena",false)
		self[szItem].pPanel:SetActive("Bg",false)

		self[szItem].pPanel:SetActive("ArenaName",true)
		self[szItem].pPanel:SetActive("BgEmpty",true)
		self[szItem].pPanel:SetActive("BtnRing",true)
		
		local tbArenaInfo = tbArenaData[nArenaId]
		if tbArenaInfo then
			self[szItem].pPanel:SetActive("Head",true)
			self[szItem].pPanel:SetActive("BtnChallenge",true)
			self[szItem].pPanel:SetActive("PlayerTitle",true)
			self[szItem].pPanel:SetActive("Name",true)
			self[szItem].pPanel:SetActive("Number",true)
			self[szItem].pPanel:SetActive("Arena",true)
			self[szItem].pPanel:SetActive("Bg",true)

			self[szItem].pPanel:SetActive("ArenaName",false)
			self[szItem].pPanel:SetActive("BgEmpty",false)
			self[szItem].pPanel:SetActive("BtnRing",false)

			self[szItem].pPanel:SetActive("BtnWaiting",false)

			local szName = tbArenaInfo.szName
			local nLevel = tbArenaInfo.nLevel
			local nHonorLevel = tbArenaInfo.nHonorLevel
			local nPortrait = tbArenaInfo.nPortrait
			local nFaction = tbArenaInfo.nFaction
			local nTeammate = tbArenaInfo.nTeammate
			local tbApply = tbArenaInfo.tbApply or {}
			local bApply
			for _,nId in pairs(tbApply) do
				if nArenaId == nId then
					bApply = true
				end
			end

			self[szItem].pPanel:Label_SetText("Name", szName);
			local SpFaction = Faction:GetIcon(nFaction)
			self[szItem].pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
			self[szItem].pPanel:Label_SetText("lbLevel", nLevel);

			self[szItem].pPanel:SetActive("PlayerTitle", nHonorLevel > 0);

			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
			self[szItem].pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);

		    local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(nPortrait)
		    self[szItem].pPanel:Sprite_SetSprite("SpRoleHead", szIcon,szAtlas);

		    self[szItem].pPanel:SetActive("BtnChallenge",not bApply)
		    self[szItem].pPanel:SetActive("BtnWaiting",bApply)

		    local szTeammate = ""
		    if nTeammate == -1 then
		    	szTeammate = "队伍人数：单人"
		    else
		    	szTeammate = string.format("队伍人数：%s人",nTeammate)
		    end
		    self[szItem].pPanel:Label_SetText("Number", szTeammate);
		end

		local function fnApply(itemObj)
			if not itemObj.nArenaId then
				return
			end

	    	ArenaBattle:ApplyChallenge(itemObj.nArenaId)
	    end

	    local function fnWait(itemObj)
	    	me.CenterMsg("请耐心等候")
	    end

	    self[szItem]["BtnChallenge"].nArenaId = nArenaId
	    self[szItem]["BtnRing"].nArenaId = nArenaId
	    self[szItem]["BtnWaiting"].nArenaId = nArenaId

	    self[szItem]["BtnChallenge"].pPanel.OnTouchEvent = fnApply;
	    self[szItem]["BtnRing"].pPanel.OnTouchEvent = fnApply;
	    self[szItem]["BtnWaiting"].pPanel.OnTouchEvent = fnWait;

	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYN_ARENA_DATA, self.RefreshUi, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow("ArenaPanel");
	end,
}