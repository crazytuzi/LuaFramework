local tbUi = Ui:CreateClass("WantedAccountS");

function tbUi:OnOpen(bFightResult, tbRoleInfo, nReduceHate, tbRobParam, bCallback, fCloseCallBack) --tbRobParam 可以是抢钱或者抢碎片
	if not bCallback then
		local fnCallBack = function ()
			Ui:OpenWindow("WantedAccountS", bFightResult, tbRoleInfo, nReduceHate, tbRobParam, true, fCloseCallBack)
		end
		
		if tbRoleInfo.dwID and tbRoleInfo.dwID ~= 0 then
			ViewRole:OpenWindow("ViewFight", tbRoleInfo.dwID, fnCallBack) 
		elseif tbRoleInfo.nFaction then
			ViewRole:OpenWindowWithFaction("ViewFight", tbRoleInfo.nFaction, fnCallBack) 
		end
		
		return 0;
	end

	self.dwRoleId = tbRoleInfo.dwID
	self.fCloseCallBack = fCloseCallBack

	self.pPanel:Label_SetText("Title", tbRobParam.szKindName)

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRoleInfo.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);			
		self.pPanel:SetActive("lbRoleName", true)
		self.pPanel:SetActive("lbRoleName2", false);
		self.pPanel:Label_SetText("lbRoleName", tbRoleInfo.szName)	
	else
		self.pPanel:SetActive("PlayerTitle", false);
		self.pPanel:SetActive("lbRoleName", false)
		self.pPanel:SetActive("lbRoleName2", true);
		self.pPanel:Label_SetText("lbRoleName2", tbRoleInfo.szName)	
	end

	self.pPanel:Label_SetText("lbLevel", tbRoleInfo.nLevel) 
	
	local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait)
	self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);
	if tbRoleInfo.nState == 2 then
		self.pPanel:Sprite_SetSprite("SpRoleHead",  szPortrait, szAltas); 	
	else
		self.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szPortrait, szAltas); 	
	end
	

	
	if bFightResult then
		self.pPanel:SetActive("Success", true)
		self.pPanel:SetActive("Failure", false)

		self.pPanel:SetActive("Result", true)

		self.pPanel:SetActive("BtnChack", false)

		if tbRobParam[1] == "Coin" then
			self.pPanel:Label_SetText("titleRob", "抢夺银两")
			self.pPanel:SetActive("coin", true)
			self.pPanel:SetActive("debris", false)
			if bFightResult and  tbRobParam[2] > 0 then
				self.pPanel:NumberAni_SetNumber("CoinInfo", tbRobParam[2], true)--prefa默认先CoinInfo显示，不然没先调awake
				self.pPanel:SetActive("BtnOut", false)
				Timer:Register(Env.GAME_FPS * 1, function ()
					self.pPanel:SetActive("BtnOut", true)
				end)
			else
				self.pPanel:NumberAni_SetNumberDirect("CoinInfo", 0, true)		
			end

			UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FRIEND_DATA)
		end

	else
		self.pPanel:SetActive("Success", false)
		self.pPanel:SetActive("Failure", true)

		self.pPanel:SetActive("Result", false)
		self.pPanel:SetActive("BtnChack", true)
	end
end

function tbUi:OnClose()
	if self.fCloseCallBack then
		self.fCloseCallBack();
	end
end

function tbUi:Quit()
	Ui:CloseWindow("WantedAccountS")
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnOut()
	self:Quit()
end

function tbUi.tbOnClick:BtnChack()
	self:Quit()
end

function tbUi.tbOnClick:Head()
	if self.dwRoleId and self.dwRoleId ~= 0 then
		ViewRole:OpenWindow("ViewRolePanel", self.dwRoleId)
	end
end