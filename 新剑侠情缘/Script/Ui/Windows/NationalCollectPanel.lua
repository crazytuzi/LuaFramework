local tbUi = Ui:CreateClass("NationalCollectPanel")
local tbItem = Item:GetClass("CollectAndRobClue");
local tbAct = Activity.CollectAndRobClue

local LINE_COUNT = 4;

function tbUi:OnOpen(nTab)
	self.nTab = nTab or 1;
end

function tbUi:OnOpenEnd(nTab)
	for i=1,3 do
		self.pPanel:Toggle_SetChecked("Btn" .. i, self.nTab == i);
    end	
	self:Update()
	self:CloseTimer()
	self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.UpdateTimer, self)
end

function tbUi:CloseTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:UpdateTimer()
	if self.nTab == 2 then
		local tbMyInfo = tbAct:GetMyInfo()
		local nNow = GetTime()
		local nInteval = tbMyInfo.nLastRobTime + tbAct.ROB_CD - nNow
		self.pPanel:Label_SetText("CD", string.format("冷却时间：%s", nInteval <= 0 and "无" or Lib:TimeDesc3(nInteval)) )
	elseif self.nTab == 3 then
		local tbMyInfo = tbAct:GetMyInfo()
		local nNow = GetTime()
		local nInteval = tbMyInfo.nLastSendTime + tbAct.SEND_CD - nNow
		self.pPanel:Label_SetText("CD", string.format("冷却时间：%s", nInteval <= 0 and "无" or Lib:TimeDesc3(nInteval)) )
	end

	return true
end

function tbUi:OnClose()
	self:CloseTimer()
	self.pCurSelItemGrid = nil
end

function tbUi:UpdateLeft()
	if self.nTab == 1 then
		self:UpdateFlowDesc()
	elseif self.nTab == 2 then
		self:UpdateRobList()
	else 
		self:UpdateSendList()
	end
end

function tbUi:UpdateFlowDesc()
	self.pPanel:SetActive("Panel1", true)
	self.pPanel:SetActive("Panel2", false)
	local tbFlow = Client:GetUserInfo("CollectAndRobClueFlow")
	local szTxt = table.concat( tbFlow, "\n")
	self.Content:SetLinkText(szTxt)
	local tbTextSize = self.pPanel:Label_GetPrintSize("Content");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");
end

function tbUi:Update()
	if self.nTab ~= 3 then
		self.pCurSelItemGrid = nil;
	end
	self:UpdateLeft()

	local tbAllItemIds = {};
	for i,v in ipairs(tbItem.tbAllClueCombine) do
		table.insert(tbAllItemIds, v)
		table.insert(tbAllItemIds, tbItem.tbAllClueDebris[i])
	end

	local tbMyDebrisList, tbMyItemList = tbAct:GetMyItemListData();
	local bCanCombineAll = Item:GetClass("CollectAndRobClue"):CanCombieDebris(tbMyItemList) 

	local fnOnClickItem = function (tbItemGrid)
		Item:ShowItemDetail(tbItemGrid);
		if self.nTab == 3 then
			if self.pCurSelItemGrid then
				self.pCurSelItemGrid.pPanel:SetActive("Select", false)
			end
			tbItemGrid.pPanel:SetActive("Select", true)
			self.pCurSelItemGrid = tbItemGrid
		end
	end

	local fnSet = function (itemObj, i)
		local tbLine = { unpack(tbAllItemIds,  (i -1) * LINE_COUNT + 1,  i * LINE_COUNT ) }
		for i2=1,LINE_COUNT do
			local tbItemGrid = itemObj["itemframe" .. i2]
			tbItemGrid.pPanel:SetActive("Select", self.pCurSelItemGrid == tbItemGrid)
			local nItemId = tbLine[i2]
			if nItemId then
				local nHasCount = tbMyDebrisList[nItemId]
				if not nHasCount then
					nHasCount = tbMyItemList[nItemId] or 0;
				end
				if nHasCount == 0 then
					local pIFPanel = tbItemGrid.pPanel
					tbItemGrid:Clear();
					local _, nIcon, _, nQuality = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
                    local szIconAtlas, szIconSprite = Item:GetIcon(nIcon)
					pIFPanel:SetActive("ItemLayer", true)
                    pIFPanel:Sprite_SetSpriteGray("ItemLayer", szIconSprite, szIconAtlas)
                    pIFPanel:SetActive("CDLayer", true)
                    pIFPanel:Sprite_SetGray("CDLayer", true)
                    pIFPanel:SetActive("Color", true)
                    pIFPanel:Sprite_SetGray("Color", true)
                    tbItemGrid.nTemplate = nItemId
				else
					tbItemGrid:SetItemByTemplate(nItemId, nHasCount)	
					local bCanCombie = false
					if  tbMyItemList[nItemId] then
						bCanCombie = bCanCombineAll
					elseif tbMyDebrisList[nItemId] then
						bCanCombie = nHasCount >= tbItem.COMBIE_COUNT
					end
					if bCanCombie  then
						tbItemGrid.pPanel:SetActive("TagTip", true)
						tbItemGrid.pPanel:Sprite_SetSprite("TagTip", "itemtag_kehecheng");
					else
						tbItemGrid.pPanel:SetActive("TagTip", false)
					end
				end
				
				tbItemGrid.fnClick = fnOnClickItem
			else
				tbItemGrid:Clear();
			end
		end
	end
	self.ScrollView1:Update(math.ceil(#tbAllItemIds / LINE_COUNT), fnSet)
end


function tbUi:UpdateRobList()
	self.pPanel:SetActive("Panel1", false)
	self.pPanel:SetActive("Panel2", true)
	
	local tbMyInfo = tbAct:GetMyInfo()
	local tbRobList, tbStrangersInfo = tbAct:GetRobList()
	local bEnable = true
	local nCDTime = tbMyInfo.nLastRobTime + tbAct.ROB_CD - GetTime()
	if tbMyInfo.nRobCount >= tbAct.MAX_ROB_COUNT or nCDTime > 0 then
		bEnable = false
	end
	self.pPanel:Label_SetText("Time1", string.format("今日抢夺次数：%d/%d", tbMyInfo.nRobCount, tbAct.MAX_ROB_COUNT))
	self.pPanel:Label_SetText("Time2", string.format("被抢次数：%d/%d", tbMyInfo.nCountRobed, tbAct.MAX_ROBED_COUNT))
	
	
	local fnSet = function (itemObj, index)
		local dwRoleId = tbRobList[index]
		local tbRoleInfo = FriendShip:GetFriendDataInfo(dwRoleId)
		if not tbRoleInfo then
			tbRoleInfo = tbStrangersInfo[dwRoleId]
		end
		itemObj:SetData(tbRoleInfo, true, bEnable)
	end
	self.ScrollView2:Update(#tbRobList, fnSet)
	
end

function tbUi:UpdateSendList()
	self.pPanel:SetActive("Panel1", false)
	self.pPanel:SetActive("Panel2", true)

	local tbMyInfo = tbAct:GetMyInfo()
	local tbSendList, tbStrangersInfo = tbAct:GetFriendList()
	local bEnable = true
	local nCDTime = tbMyInfo.nLastSendTime + tbAct.SEND_CD - GetTime() 
	if tbMyInfo.nSendCount >= tbAct.MAX_SEND_COUNT or nCDTime > 0 then
		bEnable = false
	end

	self.pPanel:Label_SetText("Time1", string.format("今日赠送次数：%d/%d", tbMyInfo.nSendCount, tbAct.MAX_SEND_COUNT))
	self.pPanel:Label_SetText("Time2", string.format("获赠次数：%d/%d", tbMyInfo.nGetSendCount, tbAct.MAX_GETSEND_COUNT))

	
	local fnSet = function (itemObj, index)
		local dwRoleId = tbSendList[index]
		local tbRoleInfo = FriendShip:GetFriendDataInfo(dwRoleId)
		if not tbRoleInfo then
			tbRoleInfo = tbStrangersInfo[dwRoleId]
		end
		itemObj:SetData(tbRoleInfo, false, bEnable, self)
	end
	self.ScrollView2:Update(#tbSendList, fnSet)
end

function tbUi:DoSend(dwRoleId, szRoleName)
	if not self.pCurSelItemGrid then
		me.CenterMsg("请先选中碎片")
		return
	end
	local nDerbisId = self.pCurSelItemGrid.nTemplate
	if not nDerbisId then
		me.CenterMsg("请先选中碎片")
		return
	end
	local fnYes = function ()
		tbAct:SendHim(dwRoleId, nDerbisId)
	end
	local tbItemBase = KItem.GetItemBaseProp(nDerbisId)

	 me.MsgBox(string.format("确认赠送给[FFFE0D]%s[-]1个[FFFE0D]%s[-]吗？", szRoleName, tbItemBase.szName),
    {
        {"确定", fnYes },
        {"取消"},
    })

	
end

function tbUi:OnSyncData(szType)
	if szType == "ActClueRobMyDebris" or szType == "ActClueRobMyItem" then
		self:Update()
	elseif szType == "ActClueRobList" or szType == "ActClueSendList" or szType == "ActClueRobMyInfo"  or szType == "" then 
		self:UpdateLeft()
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData},
    };

    return tbRegEvent;
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnChange()
	if self.nTab == 2 then
		tbAct:TryRefreshRobList()
	elseif self.nTab == 3 then
		tbAct:TryRefreshSendList()
	end
end

for i=1,3 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self.nTab = i
		self:Update()
	end
end