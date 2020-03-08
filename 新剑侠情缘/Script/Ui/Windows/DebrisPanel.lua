
local tbUi = Ui:CreateClass("DebrisPanel");
local tbEquipDebris = ValueItem.EqiupDebris; 

local ANI_TIME = 2; --合成动画总时间
local ANI_TIME_CENTER = 0.7 --所有道具都移动到中间的时间
local ANI_TIME_DIFF = 0.05 --移动道具的差值


local nItemListStartX = -223.27
local nItemListWidth = 100;


function tbUi:OnOpen()
	self.pPanel:SetActive("hecheng", false);

	local tbAllDebris = tbEquipDebris:GetAllValue(me) --如果新获得碎片，直接点面板就无效了，必须重新打开才行

	local tbSortDebris = {}
	for nItemId, nVal in pairs(tbAllDebris) do
		local nKind = Debris.tbItemIndex[nItemId]
		tbSortDebris[nKind] = tbSortDebris[nKind] or {}

		tbSortDebris[nKind][nItemId] = KLib.GetBitList(nVal) --{1,4,7} --拥有1，4，7号碎片
	end
	self.tbSortDebris = tbSortDebris;

	local tbAllKinds = {}
	for nKind, v in pairs(tbSortDebris) do
		table.insert(tbAllKinds, nKind)
	end
	table.sort(tbAllKinds, function (a, b)
		return a > b;
	end)

	local tbShowList = {} 
	for _, nKind in ipairs(tbAllKinds) do
		local v = tbSortDebris[nKind]
		for nItemId, _ in pairs(v) do
			table.insert(tbShowList, nItemId)
		end
	end

	if #tbShowList == 0 then
		me.CenterMsg("您当前没有装备碎片")
		Ui:CloseWindow(self.UI_NAME)
		return 0;
	end

	self.tbShowList = tbShowList

 	--更新免战时间
	local nAvoidRobTime = Debris:GetMyAvoidRobLeftTime();

	if nAvoidRobTime == 0 then
		self.pPanel:SetActive("Countdown", false)
	else
		self.pPanel:SetActive("Countdown", true)
		if self.nTimerRobTime then
			Timer:Close(self.nTimerRobTime);	
		end

		self.nTimerRobTime = Timer:Register(Env.GAME_FPS, function ()
			if nAvoidRobTime <= 0 then
				self.pPanel:SetActive("Countdown", false)
				return false
			end
			self.pPanel:Label_SetText("lbAvoidRobTime", string.format("%d:%d:%d", nAvoidRobTime / 3600, (nAvoidRobTime % 3600) / 60, nAvoidRobTime % 60));
			if  Lib:GetTodaySec() >= 36000 then
				nAvoidRobTime = nAvoidRobTime - 1	
			end
			
			return true
		end)	
	end

	self:UpdateLevelShow()
end

function tbUi:OnClose()
	if self.nTimerRobTime then
		Timer:Close(self.nTimerRobTime)
		self.nTimerRobTime = nil;
	end
end

function tbUi:UpdateLevelShow()
	local tbShowList = self.tbShowList

	local fnClick = function (itemObj)
		local nItemId = itemObj.nTemplate 
		if not nItemId then
			return
		end

		self.nSelItemId = nItemId
		self:SwitchDebrisGrids(nItemId);
		self.nSelItemRowIndex = itemObj.nIndex
		self.ItemGroup.pPanel:UpdateScrollView(#tbShowList);
	end

	local bHasShowOne = false;
	local function fnSelect(itemContain, nIndex)
		local itemObj = itemContain.itemframe
		itemObj.nIndex = nIndex
		if self.nSelItemRowIndex and itemObj.nIndex == self.nSelItemRowIndex then
			itemContain.pPanel:SetActive("SelSprite", true)
		else
			itemContain.pPanel:SetActive("SelSprite", false)
		end

		local nItemId = tbShowList[nIndex]
		local nKind = Debris.tbItemIndex[nItemId]
		local tbMyInfo = self.tbSortDebris[nKind][nItemId]

		itemObj:SetItemByTemplate(nItemId, string.format("%d/%d", #tbMyInfo, Debris.tbSettingLevel[nKind].nNum))

		itemObj.fnClick = fnClick;
		if self.nSelItemId then
			if self.nSelItemId == nItemId then
				bHasShowOne = true
				self:SwitchDebrisGrids(nItemId); --不用itemObj:fnClick 是为了不掉2次
			end
		elseif nIndex == 1 then
			itemObj:fnClick()  --刷新无任何选中就默认第一个
		end
	end

	self.ItemGroup:Update(tbShowList, fnSelect);

	if not bHasShowOne then
		self.ItemGroup.Grid.Item0.itemframe:fnClick()
	end
end

--选中了具体道具时
function tbUi:SwitchDebrisGrids(nItemId)
	local nMaxNum = 0
	local nKind;
	if nItemId and tbEquipDebris:GetValue(me, nItemId) ~= 0 then
		--这个传过来的道具id 可能是自己已经没有了
		nKind = Debris.tbItemIndex[nItemId]
		nMaxNum = Debris.tbSettingLevel[nKind].nNum 
	end

	self.pPanel:SetActive("CompleteItem", false)
	for i = 3, 7 do
		self.pPanel:SetActive("Combination" .. i, nMaxNum == i)
	end	
	if nMaxNum == 0 then
		return
	end
	local fnClickGrid = function (itemObj)
		self:OnClickGrid(itemObj.nDebrisIndex)
	end

	local fnClickHasDebris = function ()
		me.CenterMsg("您已拥有该碎片了")
	end

	
	local tbMyInfo = self.tbSortDebris[nKind][nItemId]
	local tbKeyInfo = {}
	for i,v in ipairs(tbMyInfo) do
		tbKeyInfo[v] = 1
	end

	for i = 1, nMaxNum do
		local tbItemGrid = self["itemframe"..nMaxNum..i]
		tbItemGrid.nDebrisIndex = i;

		--已有的碎片就是灰的
		if not tbKeyInfo[i] then
			tbItemGrid.fnClick = fnClickGrid;
			tbItemGrid:Clear();
			tbItemGrid.pPanel:SetActive("ItemLayer", true)
			tbItemGrid.pPanel:Sprite_SetSprite("ItemLayer", "Snatch", "UI/Atlas/Item/Item/Item.prefab");
		else
			tbItemGrid.fnClick = tbItemGrid.DefaultClick;
			tbItemGrid:SetItemByTemplate(nItemId, nil, nil, nil, nil, i)
		end
		
	end

	--显示中间的 灰的
	self.pPanel:SetActive("CompleteItem", true)
	self["itemframe"]:SetItemByTemplate(nItemId, nil, nil, nil, {bShowCDLayer = true})
	self["itemframe"].fnClick = self["itemframe"].DefaultClick
	local szName = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
	self.pPanel:Label_SetText("lbItemName", szName)
end

--如果难道的是碎片，但是自己又没有这个碎片，那说明是合成了，可以播放动画了，点确定时调的
function tbUi:PlayMergeAni(nItemId)
	--  对应的碎片是为空 因为刚和成，道具就不用检查了吧
	if tbEquipDebris:GetValue(me, nItemId) ~= 0 then
		return
	end

	--刚和成，serv调过client ，所以显示的肯定是空的
	local nKind = Debris.tbItemIndex[nItemId]
	local nMaxNum = Debris.tbSettingLevel[nKind].nNum 
	self.pPanel:SetActive("Combination" .. nMaxNum, true)
	self.pPanel:SetActive("CompleteItem", true)

	self["itemframe"]:SetItemByTemplate(nItemId)

	local tbOldPos = {}

	local  tbTarPos = self.pPanel:GetWorldPosition("itemframe"); 
	tbTarPos = self.pPanel:GetRelativePosition("Combination" .. nMaxNum, tbTarPos.x, tbTarPos.y)

	local nMoveTime = ANI_TIME_CENTER - (nMaxNum - 1) * ANI_TIME_DIFF
	for i = 1, nMaxNum do
		local tbItemGrid = self["itemframe"..nMaxNum..i]
		tbItemGrid:SetItemByTemplate(nItemId)		

		tbOldPos[i] = tbItemGrid.pPanel:GetPosition("Main")
		if i == 1 then
			tbItemGrid.pPanel:Tween_Run("Main", tbTarPos.x, tbTarPos.y, nMoveTime);
		else
			Timer:Register(Env.GAME_FPS * (i -1) * ANI_TIME_DIFF, function ()
				tbItemGrid.pPanel:Tween_Run("Main", tbTarPos.x, tbTarPos.y, nMoveTime);
			end )	
		end
	end

	self.pPanel:SetActive("hecheng", true);
	self.pPanel:PlayParticleSystem("xi")

	Timer:Register(Env.GAME_FPS * ANI_TIME, function ()
		self.pPanel:SetActive("Combination" .. nMaxNum, false)
		self.pPanel:SetActive("CompleteItem", false)
		
		--归位
		for i = 1, nMaxNum do
			local tbItemGrid = self["itemframe"..nMaxNum..i]
			tbItemGrid.pPanel:ChangePosition("Main", tbOldPos[i].x, tbOldPos[i].y)
		end

		--碎片已经变化了，刷新下显示
		self.nSelItemId = nil;
		self:UpdateLevelShow()

		Ui:OpenWindow("DebrisResult", nItemId)		
	end)


end

--点了具体第几个格子 当前是什么道具是知道的，所以只需要传第几个格子
function tbUi:OnClickGrid(nIndex)
	Debris:DoRequestRobList(self.nSelItemId, nIndex)
end

function tbUi:OnGetCardAward(tbAward)
	if tbAward[1] == "EquipDebris" then
		self:OnOpen();
	end
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnBack()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:Btn_Msjp()
	Ui:OpenWindow("DebrisAvoidRob")
end

function tbUi:RegisterEvent()
	return
	{
		{ UiNotify.emNOTIFY_GET_DEBRIS, self.PlayMergeAni },
		{ UiNotify.emNOTIFY_DEBRIS_UPDATE, self.OnOpen },
		{ UiNotify.emNOTIFY_ON_DEBRIS_CARD_AWARD, self.OnGetCardAward },
	};
end
