local tbUi = Ui:CreateClass("CreateRole");
tbUi.tbSerisSprite = {
	[1] = "FiveGold" ;
	[2] = "FiveTree" ;
	[3] = "FiveWater" ;
	[4] = "FiveFire" ;
	[5] = "FiveSoil" ;
};
tbUi.tbFactionButtonSp = {
	[1] = {"FactionIcon_Tianwang01","UI/Atlas/Login/Login.prefab"};
	[2] = {"FactionIcon_Emei01","UI/Atlas/Login/Login.prefab"};
	[3] = {"FactionIcon_Taohua01","UI/Atlas/Login/Login.prefab"};
	[4] = {"FactionIcon_Xiaoyao01","UI/Atlas/Login/Login.prefab"};
	[5] = {"FactionIcon_Wudang01","UI/Atlas/Login/Login.prefab"};
	[6] = {"FactionIcon_Tianren01","UI/Atlas/Login/Login.prefab"};
	[7] = {"FactionIcon_Shaolin01","UI/Atlas/Login/Login.prefab"};
	[8] = {"FactionIcon_Cuiyan01","UI/Atlas/Login/Login.prefab"};
	[9] = {"FactionIcon_Tangmen01","UI/Atlas/Login/Login.prefab"};
	[10]= {"FactionIcon_Kunlun01","UI/Atlas/Login/Login.prefab"};
	[11]= {"FactionIcon_Gaibang01","UI/Atlas/Login/Login.prefab"};
	[12]= {"FactionIcon_Wudu01","UI/Atlas/Login/Login.prefab"};
	[13]= {"FactionIcon_Cangjian01","UI/Atlas/Login/Login.prefab"};
	[14]= {"FactionIcon_Changge01","UI/Atlas/Login/Login.prefab"};
	[15]= {"FactionIcon_Tianshan01","UI/Atlas/Login/Login.prefab"};
	[16]= {"FactionIcon_BaDao01","UI/Atlas/Login/Login.prefab"};
	[17]= {"FactionIcon_Huashan01","UI/Atlas/Login/Login.prefab"};
	[18]= {"FactionIcon_Mingjiao01","UI/Atlas/Login/Login.prefab"};
	[19]= {"FactionIcon_Duanshi01","UI/Atlas/Login/Login.prefab"};
	[20]= {"FactionIcon_Wanhua01","UI/Atlas/Login/Login05.prefab"};
	[21]= {"FactionIcon_Yangmen01","UI/Atlas/Login/Login05.prefab"};
}

tbUi.tbSelButtonSeriesSp = {
	[1] = "FactionIconBg_Gold";
	[2] = "FactionIconBg_Gold";
	[3] = "FactionIconBg_Gold";
	[4] = "FactionIconBg_Gold";
	[5] = "FactionIconBg_Gold";
}

function tbUi:GetSerierData( )
	if self.tbSeriesData  then
		return self.tbSeriesData
	end
	self.tbSeriesData = {}
	local tbSeriesData = self.tbSeriesData

	for nFaction,v in pairs(Faction.tbFactionInfo) do
			local nSex = Player:Faction2Sex(nFaction, Player.SEX_MALE);	
			local tbPlayerInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex);
			local nSeries = tbPlayerInfo.nSeries
			tbSeriesData[nSeries] = tbSeriesData[nSeries] or {}
			table.insert(tbSeriesData[nSeries], nFaction)	
	end

	return tbSeriesData
end

function tbUi:OnCreate()
	self:GetSerierData()
end

function tbUi:OnOpen(tbParam)
	local tbRoleInfo = tbParam.tbRoleInfo
	local nNpcId =  tbParam.nNpcId 
	local bPlayAni = tbParam.bPlayAni 
	local tbSelRoleInfo = tbParam.tbSelRoleInfo 
	self.pPanel:SetActive("Faction", true)

	if not self.bInit then
		self.bInit = true
		self:Init()
	end

	self.pPanel:SetActive("Anchor1", false)
	self.pPanel:SetActive("Anchor3", true)
	self.pPanel:SetActive("Anchor4", false)
	self.pPanel:SetActive("BtnSelect", false)
	
	self.pPanel:SetActive("Anchor1", true)
	self.pPanel:SetActive("Anchor2", true)
	self.pPanel:SetActive("Anchor3", true)
	self.pPanel:SetActive("Anchor4", true)
	self.pPanel:SetActive("texiao_dianji", false)

	self.nFaction = nNpcId;
	
	--根据门派找到选定的serris
	local nSex = Player:Faction2Sex(self.nFaction, tbRoleInfo.nSex);	
	self.nSex = nSex --所以肯定是有选中性别的
	local tbPlayerInfo = KPlayer.GetPlayerInitInfo(self.nFaction, nSex);
	local nSeries = tbPlayerInfo.nSeries
	local nCurSerisIndex
	for i,v in ipairs(self.tbInitSerirsIndex) do
		if v == nSeries then
			nCurSerisIndex = i;
			break;
		end
	end
	if nCurSerisIndex ~= self.nCurSerisIndex then
		self:RotateToSerisIndex(nCurSerisIndex)
		self.nCurSerisIndex = nCurSerisIndex
	end
	self:CheckShowRotationPart()
	
	self.tbCreateRole = tbRoleInfo.tbCreateRole
	if self.bCreated then
		self.NameInputFrame:SetText("");
		self.bCreated = false
	end


	Ui:UpdateScreenFramePanel()
end

function tbUi:CheckShowRotationPart()
	local tbPostionC = self.pPanel:GetWorldPosition("Rotation")
	local nX2,nY2 = tbPostionC.x, tbPostionC.y;

	for i,nSeries in ipairs(self.tbInitSerirsIndex) do
		local szWndName = "Five" .. (i - 1)
		local tbPostion = self.pPanel:GetWorldPosition(szWndName)
		local nX1,nY1 = tbPostion.x, tbPostion.y
	    local nAngle = math.atan2(nX1 - nX2, nY1 - nY2) * 180 /math.pi + 180;
	    local bShow = nAngle <=176 and nAngle >  50 or false
	    self.pPanel:SetActive(szWndName, bShow)
	end
end

function tbUi:Init()
	local tbGridAngles = {  }
	local tbSerris = { 1,2,3,4,5 }
	self.tbInitSerirsIndex = {  }
	for i=0,19 do
		table.insert(tbGridAngles, 18 *i)
		local nLeft = (i + 1) % #tbSerris
		nLeft = nLeft == 0 and 5 or nLeft
		local nSeries = tbSerris[nLeft]
		table.insert(self.tbInitSerirsIndex, nSeries)
	end
		
	local tbPostion = self.pPanel:GetWorldPosition("Rotation")
	local CenterX = tbPostion.x
	local CenterY = tbPostion.y
	local tbSize = self.pPanel:Widget_GetSize("Rotation")
	local fnScale =  self.pPanel:GetWorldScale("Rotation")
	local raduis = tbSize.x * fnScale

	self.nCurSerisIndex = 1;

	for i,nAngel in ipairs(tbGridAngles) do
		nAngel = (nAngel + 165) / 180 * math.pi
		local tbTarPos = self.pPanel:GetRelativePosition("Rotation", CenterX + raduis* math.cos(nAngel), CenterY + raduis* math.sin(nAngel))
		self.pPanel:ChangePosition("Five" .. (i - 1), tbTarPos.x, tbTarPos.y)

		local nSerirs = self.tbInitSerirsIndex[i]
		local szPrefix = self.tbSerisSprite[nSerirs]
		self.pPanel:Button_SetSprite("Five" .. (i -1), string.format("%s%s", szPrefix, self.nCurSerisIndex == i and "02" or "01" ) )
	end
end


function tbUi:OnAniEnd(szAni)
end

function tbUi:OnOpenEnd(tbParam)
	self:Update()
end



function tbUi:HideOptButtons()
	self.pPanel:SetActive("Anchor2", false)
	self.pPanel:SetActive("Anchor3", false)

end

function tbUi:ShowCreatedRole(tbCreateRole)
	self.pPanel:SetActive("NameInputFrame", false)
	self.pPanel:SetActive("Dice", false)
	
	if tbCreateRole.tbOhters then
		local szSelName;
		self.pPanel:PopupList_Clear("BtnSelect")
		for i,v in ipairs(tbCreateRole.tbOhters) do
			local szVal = string.format("%s(%d)", v.szName, v.nLevel)
			self.pPanel:PopupList_AddItem("BtnSelect",  szVal)
			if v.szName == tbCreateRole.szName then
				szSelName = szVal
			end
		end
		if szSelName then
			self.pPanel:PopupList_Select("BtnSelect", szSelName)		
		end

		self.pPanel:SetActive("BtnSelect", true)
	else
		self.pPanel:SetActive("BtnSelect", false)
	end

	--[[if tbCreateRole.nBanEndTime < 0 or (tbCreateRole.nBanEndTime > 0 and tbCreateRole.nBanEndTime > nCurTime) then
		self.pPanel:Button_SetEnabled("BtnEnter", false)
	else
		self.pPanel:Button_SetEnabled("BtnEnter", true)
	end]]
end

function tbUi:ShowNewRole()
	if XinShouLogin:IsOpenFunben() then
		self.pPanel:SetActive("NameInputFrame", false)
		self.pPanel:SetActive("Dice", false)			
	else
		self.pPanel:SetActive("NameInputFrame", true)
		self.pPanel:SetActive("Dice", true)
	end
	
	self.pPanel:Button_SetEnabled("BtnEnter", true)
end

function tbUi:OnCreateRoleRespond(nCode, nRoleID)
	self.bLockButton = nil;
	if nCode ~= 0 then
		self.bCreated = false
	else
		Login:LoginRole(nRoleID)
	end
end

function tbUi:OnConnectServerEnd()
	self.bLockButton = nil;
end

function tbUi:LockButton()
	if self.bLockButton then
		return
	end
	self.bLockButton = true
	Timer:Register(Env.GAME_FPS * 3, function ()
		self.bLockButton = nil
	end)
end

function tbUi:OnMapLoaded()
	Ui:CloseWindow(self.UI_NAME) --丢包客户端没有 login事件时这个会没关
end

function tbUi:OnDragSelGridEnd()
	self.pPanel:SetActive("BtnArrow1", not self.ScrollView:IsTop())
	self.pPanel:SetActive("BtnArrow2", not self.ScrollView:IsBottom())
end

function tbUi:RotateToSerisIndex(nIndex, bAni)
	local tbRotation = self.pPanel:GetRotateEulerAngles("Rotation")
	local nCurSerisIndex = self.nCurSerisIndex
	local nMinus = nIndex - nCurSerisIndex
	local nToZ = tbRotation.z
	if nMinus > 2 then
		nMinus = nMinus - 20
	elseif nMinus < -2 then
		nMinus = nMinus + 20
	end
	nToZ = nToZ -  18 * nMinus
	
	self:UpdateShowSelButton()
	self:CheckShowRotationPart()		
	

	if bAni then
		self:LockButton()

		local nTime = math.abs(nMinus) == 1 and 0.2 or 0.3
		self.bInRotaAni = true
		for i,nSeries in ipairs(self.tbInitSerirsIndex) do
			self.pPanel:Tween_RotateAbsolute("Five" .. (i - 1), 0, nTime);			
		end

		self.pPanel:Tween_Rotate("Rotation", nToZ, nTime);
		self.pPanel:SetActive("texiao_dianji", false)

		Timer:Register(math.ceil(Env.GAME_FPS * nTime ) , function ()
			self.bInRotaAni = false
			self.bLockButton = nil;
			self.nCurSerisIndex = nIndex
			-- self.nFaction = nil;
			-- self.nSex = nil
			self.pPanel:SetActive("texiao_dianji", true)
			self:Update()
			self:CheckShowRotationPart()		
		end)
	else
		self.pPanel:ChangeLocalRotate("Rotation", nToZ);	
		for i,nSeries in ipairs(self.tbInitSerirsIndex) do
			self.pPanel:ChangeRotate("Five" .. (i -1), 0)
		end
	end
end

function tbUi:OnSelSeris( nIndex )
	if self.bLockButton then
		return
	end
	--防止动画中
	local pRotate = self.pPanel:FindChildTransform("Rotation");
	if self.bInRotaAni then
		return
	end
	local TweenRotation = pRotate:GetComponent("TweenRotation");
	if  TweenRotation and TweenRotation.enabled then
		return
	end

	nIndex = nIndex + 1;
	
	self:RotateToSerisIndex(nIndex, true)
end

function tbUi:SelFaction( nFaction)
	local nSex = Player:Faction2Sex(nFaction, self.nSex)
	if nFaction ~= self.nFaction then
		local bCan,nChangeSex = Login:IsForbitFaction(nFaction, self.nSex)
		if nChangeSex then
			nSex = nChangeSex
		end	
	end
	self.nFaction = nFaction
	Login:SelRole(nFaction, false, nSex)
end

function tbUi:UpdateShowSelButton()
	local nTotalCount = #self.tbInitSerirsIndex
	local tbShowedSeris = { self.nCurSerisIndex }
	local fnGetIndex = function (i)
		local nIndex = self.nCurSerisIndex + i
		if nIndex > nTotalCount then
			nIndex = nIndex - nTotalCount
		elseif nIndex <= 0 then
			nIndex = nIndex + nTotalCount
		end
		return nIndex
	end
	for i=1,4 do
		local nIndex = fnGetIndex(i)
		table.insert(tbShowedSeris, 1, nIndex)
	end
	for i = -1,-4, -1 do
		local nIndex = fnGetIndex(i)
		table.insert(tbShowedSeris, nIndex)
	end

	local tbIndexes = {
		60,60,75,85,
		90,
		85,75,60,60,
	}
	local tbCreateRoleSp = { --对应前面的index
		[3] = {24, 	  -24, 0.4}; --X,Y ,缩放
		[4] = {32, 	  -32, 0.5};
		[6] = {32, 	  -32, 0.5};
		[7] = {24, 	  -24, 0.4};
	};

	if not self.tbSerirsRolePortiait then
		self.tbSerirsRolePortiait = {};

		local tbRoles = GetRoleList() -- 先按系， 再按门派划分下
		table.sort( tbRoles, function ( a, b )
			return a.nLevel > b.nLevel
		end )

		local tbFactionRoles = {}
		for i, v in ipairs(tbRoles) do
			if not tbFactionRoles[v.nFaction] then
				tbFactionRoles[v.nFaction] = v;
			end
		end

		local tbSeriesFactions = self:GetSerierData();		
		for nSerirs, tbFactions in ipairs(tbSeriesFactions) do
			local tbMaxRoleInSeris;
			local nMaxLevel = 0
			for _, nFaction in ipairs(tbFactions) do
				local tbRole = tbFactionRoles[nFaction]
				if tbRole then
					if tbRole.nLevel > nMaxLevel then
						nMaxLevel = tbRole.nLevel
						tbMaxRoleInSeris = tbRole
					end
				end
			end
			if tbMaxRoleInSeris then
				self.tbSerirsRolePortiait[nSerirs] = { tbMaxRoleInSeris.nFaction, tbMaxRoleInSeris.nSex }
			end
		end
	end

	for nIndex, i in ipairs(tbShowedSeris) do
		local nSerirs = self.tbInitSerirsIndex[i]
		local szPrefix = self.tbSerisSprite[nSerirs]
		self.pPanel:Button_SetSprite("Five" .. (i -1), string.format("%s%s", szPrefix, self.nCurSerisIndex == i and "02" or "01" ) )

		local nSize = tbIndexes[nIndex]
		self.pPanel:Widget_SetSize("Five" .. (i -1), nSize, nSize)
		self.pPanel:ChangeRotate("Five" .. (i -1), 0)

		local tbCreateRoleSpInfo = tbCreateRoleSp[nIndex]
		local szHeadUI = "Head" .. (i-1);
		local tbRoleInfo = self.tbSerirsRolePortiait[nSerirs]
		if tbCreateRoleSpInfo and tbRoleInfo then
			self.pPanel:SetActive(szHeadUI, true)
			local x, y, fnScale = unpack(tbCreateRoleSpInfo)
			self.pPanel:ChangePosition(szHeadUI, x, y)
			self.pPanel:ChangeScale(szHeadUI, fnScale, fnScale, fnScale)
			local nCurFaction, nCurSex = unpack(tbRoleInfo)
			local nPortrait = PlayerPortrait:GetDefaultId(nCurFaction, nCurSex);
			local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(nPortrait);
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. (i-1), szIcon, szIconAtlas)
		else
			self.pPanel:SetActive(szHeadUI, false)
		end
	end
end

tbUi.tbSexButtonName = {
	[1] = "maleBTN";
	[2] = "FemaleBTN";
}
tbUi.tbSexButtonNormalSprite = {
	[1] = "MaleMark1";
	[2] = "FemaleMark1";
}
tbUi.tbSexButtonSelSprite = {
	[1] = "MaleMark2";
	[2] = "FemaleMark2";
}
tbUi.tbSexButtonDisableSprite = {
	[1] = "MaleMark3";
	[2] = "FemaleMark3";
}

function tbUi:Update()
	--转完以后的update是没有选中门派和性别的
	local nCurSerisIndex = self.nCurSerisIndex
	self:UpdateShowSelButton()
	local nCurSeris = self.tbInitSerirsIndex[nCurSerisIndex]
	local tbFactions = self.tbSeriesData[nCurSeris];
	local szSelButtonSeriesSp = self.tbSelButtonSeriesSp[nCurSeris]
	local tbForceShowFaction = Player.tbForceShowFaction[self.nSex]
	if tbForceShowFaction[self.nFaction] then
		for i,v in ipairs(self.tbSexButtonName) do
			self.pPanel:SetActive(v, false)
		end
	else
		for i,v in ipairs(self.tbSexButtonName) do
			self.pPanel:SetActive(v, true)
		end
	end

	local nSelSeris;
	--todo 4个以上
	local tbFactionsButPos = {
		[4] = {
			{11,118};
			{-38,42};
			{-43,-45};
			{-39,-128};
		};
		[5] = {
			{30,146};
			{-5,80};
			{-42,0};
			{-43,-82};
			{-42,-164};
		};
	}	
	local nShowCount = 0
	local tbUseBtnPos = tbFactionsButPos[#tbFactions]
	for i=1,5 do
		local nFaction = tbFactions[i]
		local tbButton = self["FactionBtn0" .. i]
		if nFaction then
			nShowCount = nShowCount + 1;
			tbButton.pPanel:SetActive("Main", true)
			tbButton.pPanel:ChangePosition("Main", tbUseBtnPos[i][1],tbUseBtnPos[i][2])
			local szName = Faction:GetName(nFaction)
			tbButton.pPanel:Label_SetText("ligting", szName)
			-- tbButton.pPanel:Label_SetText("dark", szName)
			if self.nFaction == nFaction then
				nSelSeris = i;
			end

			local bHasRolesInFaction = false
			local tbSexes = Player:GetFactionSexs(nFaction)
			for _, nSex in ipairs(tbSexes) do
				local tbSelInfo = Login:GetRealRoleInfo(nFaction, nSex)		
				bHasRolesInFaction = tbSelInfo.tbCreateRole
				if 	bHasRolesInFaction then
					break;
				end
			end
			if bHasRolesInFaction then
				tbButton.pPanel:Button_SetSprite("Main", szSelButtonSeriesSp .. "02", 3)	
				tbButton.pPanel:Button_SetSprite("Main", szSelButtonSeriesSp, 1)	
			else
				tbButton.pPanel:Button_SetSprite("Main", "FactionIconBg_02", 1)	
				tbButton.pPanel:Button_SetSprite("Main", "FactionIconBg_01", 3)	
			end

			tbButton.pPanel:Toggle_SetChecked("Main", self.nFaction == nFaction)
			if self.nFaction == nFaction then
				tbButton.pPanel:SetActive("Effect_H", bHasRolesInFaction)
				tbButton.pPanel:SetActive("Effect_L", not bHasRolesInFaction)
			else
				tbButton.pPanel:SetActive("Effect_H", false)
				tbButton.pPanel:SetActive("Effect_L", false)
			end
			local szFactionSp, szAtlas = unpack(self.tbFactionButtonSp[nFaction]) 
			tbButton.pPanel:Sprite_SetSprite("Sprite01", szFactionSp,szAtlas)
			tbButton.pPanel.OnTouchEvent = function ()
				self:SelFaction(nFaction)
			end
			if self.nFaction == nFaction then
				local tbFactionHasSex = {}
				for _, nSex in ipairs(tbSexes) do
					tbFactionHasSex[nSex] = true;
				end
				for nSex=1,2 do
					local szButtonSexName = self.tbSexButtonName[nSex]
					if tbFactionHasSex[nSex] then
						local bCheckedSex = self.nSex == nSex
						self.pPanel:Sprite_SetSprite(szButtonSexName, bCheckedSex and self.tbSexButtonSelSprite[nSex] or self.tbSexButtonNormalSprite[nSex])
					else
						self.pPanel:Sprite_SetSprite(szButtonSexName, self.tbSexButtonDisableSprite[nSex])
					end
				end
			end
		else
			tbButton.pPanel:SetActive("Main", false)
		end
	end
	-- local tbPosInfo = tbFactionsButPos[nShowCount]
	-- self.pPanel:ChangePosition("Faction", tbPosInfo[1], tbPosInfo[2])

	for i=1,4 do
		self["FactionBtn0" .. i].pPanel:Toggle_SetChecked("Main",  nSelSeris == i)
	end

	if self.nFaction and self.nSex then
		local tbCurSelRoleInfo = Login:GetRealRoleInfo(self.nFaction, self.nSex)		
		if tbCurSelRoleInfo and tbCurSelRoleInfo.tbCreateRole then
			self:ShowCreatedRole(tbCurSelRoleInfo.tbCreateRole)
		else
			self:ShowNewRole()
		end
		self.pPanel:Sprite_SetSprite("SchoolSubs", Faction:GetFactionSchoolIcon(self.nFaction))	
	end
	for i,v in ipairs(self.tbSexButtonName) do
		self.pPanel:Toggle_SetChecked(v, i == self.nSex)
	end
	
end

tbUi.tbOnClick = {}

for i = 0, 19 do
	tbUi.tbOnClick["Five" .. i] = function (self)
		self:OnSelSeris(i)
	end
end

function tbUi.tbOnClick:BtnEnter()
	if self.bLockButton then
		return
	end
	
	if not self.tbCreateRole then --当前输的新建角色进入
		--角色数限制检查
		if not self.nFaction then
			me.CenterMsg("请选择门派")
			return
		end
		if not Login:CheckRoleCountLimit() then
			return
		end

		if XinShouLogin:IsOpenFunben() then
			Login:EnterXinShouFuben()
		else
			local szName = self.NameInputFrame:GetText();
			if not Login:CheckNameinValid(szName) then
				return
			end
			self:LockButton()--CreateRole 和 LoginRole 的各种响应都要注册解锁bLockButton

			local nSex = Player:Faction2Sex(self.nFaction, self.nSex);
			local nPortrait = PlayerPortrait:GetDefaultId(self.nFaction, nSex);
			CreateRole(szName, self.nFaction, nSex, nPortrait);   --创建成功会直接进游戏的
		end

		self.bCreated = true;
	else
		local nBanEndTime = self.tbCreateRole.nBanEndTime;
		local szBanReason = self.tbCreateRole.szBanReason;
		local nNoTimeNotice = 0;
		if szBanReason then
			szBanReason, nNoTimeNotice = string.gsub(szBanReason, "(%[no_time_notice%])", "")
		end

		local szBanInfo = nil;
		if nBanEndTime < 0 then
			if szBanReason == nil or szBanReason == "" then
				if nNoTimeNotice > 0 then
					szBanInfo = XT("此角色已被冻结");
				else
					szBanInfo = XT("此角色已被永久冻结");
				end
			else
				if nNoTimeNotice > 0 then
					szBanInfo = string.format(XT("此角色由于%s已被冻结", szBanReason))
				else
					szBanInfo = string.format(XT("此角色由于%s已被永久冻结", szBanReason))
				end
			end
		elseif (nBanEndTime > 0 and nBanEndTime > GetTime()) then
			if szBanReason == nil or szBanReason == "" then
				if nNoTimeNotice > 0 then
					szBanInfo = XT("此角色已被冻结");
				else
					szBanInfo = string.format(XT("此角色已被冻结，解冻时间%s"), Lib:GetTimeStr3(nBanEndTime));
				end
			else
				if nNoTimeNotice > 0 then
					szBanInfo = string.format(XT("此角色由于%s已被冻结", szBanReason))
				else
					szBanInfo = string.format(XT("此角色由于%s已被冻结\n解冻时间%s"), szBanReason, Lib:GetTimeStr3(nBanEndTime));
				end
			end
		end

		if szBanInfo then
			Ui:OpenWindow("MessageBox", szBanInfo, {{},},{"确认"}, nil, nil, true);
			return
		end
		self:LockButton()
		Login:LoginRole(self.tbCreateRole.nRoleID)
	end
end

tbUi.tbOnDrag = 
{
}

tbUi.tbUiPopupOnChange = 
{
}

function tbUi.tbUiPopupOnChange:BtnSelect(szWndName, val)
	for i,v in ipairs(self.tbCreateRole.tbOhters) do
		if string.format("%s(%d)", v.szName, v.nLevel) ==  val then
			Login:SwitchRoleSelIndex(self.tbCreateRole, i)
			self:ShowCreatedRole(self.tbCreateRole)
			return
		end
	end
end


function tbUi:OnClose()
	self.bLockButton = nil;
	self.tbSerirsRolePortiait = nil;
end

function tbUi:OnBtnEnterResponse()
	self.bLockButton = nil;
end

function tbUi.tbOnClick:Dice()
	local szName = Player:GetRandomName(self.nSex, self.nFaction);
	for i = 1, 3 do
		if CheckNameAvailable(szName) then
			break;
		end
	end
	self.NameInputFrame:SetText(szName)
end

function tbUi.tbOnClick:BtnTitles()
	Ui.ToolFunction.DirPlayCGMovie("OpenCG.mp4")
end

function tbUi:OnSelSex( nSex )
	if self.nSex == nSex then
		return
	end
	local tbSexes = Player:GetFactionSexs(self.nFaction)
	local bFind = false
	for i,v in ipairs(tbSexes) do
		if v == nSex then
			bFind = true
			break;
		end
	end
	if not bFind then
		me.CenterMsg("未开放")
		return
	end

	self.nSex = nSex
	
	if #tbSexes == 2 then
		self:SelFaction(self.nFaction)
	end
end

function tbUi.tbOnClick:maleBTN(  )
	self:OnSelSex(1)
end

function tbUi.tbOnClick:FemaleBTN(  )
	self:OnSelSex(2)
end

function tbUi.tbOnClick:BtnArrow3(  )
	self.bFold  = not self.bFold
	self.pPanel:PlayUiAnimation(self.bFold and "CreateRolePanel_ZPDelete" or "CreateRolePanel_ZPOpen",false,false,{})
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END,		self.OnBtnEnterResponse },
		{ UiNotify.emNOTIFY_CREATE_ROLE_RESPOND,		self.OnCreateRoleRespond },
		{ UiNotify.emNOTIFY_CONNECT_SERVER_END,		 	self.OnConnectServerEnd },
		{ UiNotify.emNOTIFY_MAP_LOADED,		 			self.OnMapLoaded },

	};

	return tbRegEvent;
end

local tbGrid = Ui:CreateClass("SelRoleGrid")
tbGrid.tbOnDrag = {
	Btn = function (self)
	end	;		
};
tbGrid.tbOnDragEnd =
{
	Btn = function (self)
		Ui("CreateRole"):OnDragSelGridEnd()
	end	;
}

