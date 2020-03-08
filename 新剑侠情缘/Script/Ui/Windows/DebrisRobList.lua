
local tbUi = Ui:CreateClass("DebrisRobList");
local tbGrid = Ui:CreateClass("DebrisRobListGrid");

local tbProbLb = {"Lowest", "Lower", "General", "Higher", "Highest"}

function tbGrid:SetData(tbRole, tbParent)
	self.tbRole = tbRole
	self.tbParent = tbParent

	local SpFaction = Faction:GetIcon(tbRole.nFaction)
	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRole.nPortrait)

	self.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas); --TODO 先用门派头像了
	self.pPanel:Label_SetText("lbLevel", tbRole.nLevel) 
	self.pPanel:Sprite_SetSprite("SpFaction", SpFaction);
	for i,v in ipairs(tbProbLb) do
		self.pPanel:SetActive(v, tbRole.nProbLevel == i)
	end
	if tbRole.dwID == 0 then
		self.pPanel:SetActive("PlayerTarget", false)
		self.pPanel:SetActive("GuardianTarget", true)
		self.pPanel:Label_SetText("lbNpcName", tbRole.szName)

	else
		self.pPanel:SetActive("PlayerTarget", true)
		self.pPanel:SetActive("GuardianTarget", false)

		self.pPanel:Label_SetText("lbRoleName", tbRole.szName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRole.nHonorLevel)
		if ImgPrefix then
			self.pPanel:SetActive("PlayerTitle", true);
			self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);			
		else
			self.pPanel:SetActive("PlayerTitle", false);
		end
	end
end

tbGrid.tbOnClick = {}

--抢玩家
function tbGrid.tbOnClick:BtnSnatch()
	self.tbParent:RobHim(self.tbRole.dwID)
end

-- 抢npc5次
function tbGrid.tbOnClick:BtnSnatch5()
	self.tbParent:RobHim(self.tbRole.dwID, 5)
	Debris.tbDebrisRobNpcInfo = self.tbRole
end

--抢npc1次
function tbGrid.tbOnClick:BtnSnatch1()
	self.tbParent:RobHim(self.tbRole.dwID, 1)
	Debris.tbDebrisRobNpcInfo = self.tbRole
end


local function GetProbLevel(nProb)
	if nProb < 0.15 then
		return 1
	elseif nProb< 0.4 then
		return 2
	elseif nProb < 0.6 then
		return 3
	elseif nProb < 0.85 then
		return 4
	else
		return 5
	end
end 


function tbUi:OnOpen(tbData, nItemId, nIndex)
	--计算每个的概率
	if not tbData then --刷新界面时
		tbData = self.tbData;
		nItemId = self.nItemId
		nIndex = self.nIndex
	else
		self.nItemId = nItemId
		self.nIndex = nIndex	
		self.tbData = tbData
	end
	
	local nKind = Debris.tbItemIndex[nItemId]
	local tbKindInfo = Debris.tbSettingLevel[nKind]
	local nMyHonor = me.nHonorLevel
	for i, tbRole in ipairs(tbData) do
		local nProb = 0; 
		local tbCardInfo = Debris.tbFipCardSetting[tbKindInfo.nFlipCardSetIndex]
		if tbRole.dwID == 0 then
			nProb = tbCardInfo[1].nProb
			tbRole.nIndex = i;
			--产生随机名字
			if not tbRole.szName then
				tbRole.szName = Player:GetRandomName();	
				
			end
			if not tbRole.nFaction then
				tbRole.nFaction = MathRandom(4)
			end
			
			tbRole.nLevel = me.nLevel;
		else
			local nHonorMinus = tbRole.nHonorLevel - nMyHonor
			 nProb = Lib.Calc:Link(nHonorMinus, FriendShip.tbHonorProb, true);
			 nProb = nProb * (tbKindInfo.nRobProb * Debris:GetProbFactor(nHonorMinus) + tbCardInfo[1].nProb)
		end

		tbRole.nProb = nProb;
		tbRole.nProbLevel = GetProbLevel(nProb)
	end

	local fnSort = function (a, b)
		if a.nIndex and b.nIndex then
			return a.nIndex < b.nIndex
		end
		return a.nProb > b.nProb
	end
	table.sort(tbData, fnSort)

	local fnSetData = function (itemClass, index)
		itemClass:SetData(tbData[index], self);
	end
	self.ScrollView:Update(tbData, fnSetData)

	local nDegree = DegreeCtrl:GetDegree(me, "Debris")
	self.pPanel:Label_SetText("TxtTimes", string.format("%d/%d", nDegree, DegreeCtrl:GetMaxDegree("Debris", me)))
	self.pPanel:SetActive("BtnBuyTimes", nDegree <= 0)
end

function tbUi:CheckRobTimes()
	local nDegree = DegreeCtrl:GetDegree(me, "Debris")
	if nDegree <= 0 then
		me.BuyTimes("Debris", 5)
		return
	end
	return true
end

function tbUi:RobHim(dwRoleId, nCount)
	--次数检查
	if not self:CheckRobTimes() then
		return
	end

	local fnConfirm = function ()
		RemoteServer.DebrisRobHim(dwRoleId, self.nItemId, self.nIndex, nCount)
		Ui:CloseWindow(self.UI_NAME)	
	end

	if not nCount and Debris:GetMyAvoidRobLeftTime() > 0 then
		Ui:OpenWindow("MessageBox", "免战期间成功抢得其他玩家碎片将解除免战状态，是否继续抢夺？", 
		{{fnConfirm},{} })

	else
		fnConfirm()
	end	
end


function tbUi:OnClose()
end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:btnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnChange()
	Debris:DoRequestRobList(self.nItemId, self.nIndex)
end

function tbUi.tbOnClick:BtnBuyTimes()
	if self:CheckRobTimes() then
		me.CenterMsg("您的次数还没有花完哦")
		return
	end
end

function tbUi:RegisterEvent()
	return
	{
		{ UiNotify.emNOTIFY_SYNC_DEBRIS_ROB_DATA, self.OnOpen },
		{ UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS, self.OnOpen },
	};
end


