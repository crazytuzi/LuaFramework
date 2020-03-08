--[[
	tbData 格式 {}
	tbData.nCurWatchId = 0 	-- 当前观战中的npcID 没有传0
	tbData.szType = szType  -- 对应活动类型
	tbData.tbPlayer = 
	{
		[1] = {[1] = {name=szName, id=nNpcId},[2] = {name=szName, id=nNpcId}}, 		     -- 阵营一
		[2] = {[1] = {name=szName, id=nNpcId},[2] = {name=szName, id=nNpcId}},           -- 阵营二
		...
	}
]]

local tbUi = Ui:CreateClass("WatchMenuPanel");

local tbBattleType = 
{
	["FactionBattleWatch"] = {
		fnWatch = function (itemObj)
			if itemObj.nNpcId then
				FactionBattle:StartWatch(itemObj.nNpcId)
				UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnLeave"})
			end
		end,
		fnEndWatch = function ()
			FactionBattle:EndWatch(nil, true)
			UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN,"FactionBattle",{"BtnLeave"},true)
		end
	},
	["ArenaBattleWatch"] = {
		fnWatch = function (itemObj)
			if itemObj.nNpcId then
				ArenaBattle:StartWatch(itemObj.nNpcId)
			end
		end,
		fnEndWatch = function ()
			ArenaBattle:EndWatch(nil, true)
		end
	},
	["CommonWatchMenu"] = {
		fnWatch = function (itemObj)
			if itemObj.nNpcId then
				CommonWatch:DoStartWatch(itemObj.nNpcId);
			end
		end,

		fnEndWatch = function ()
			CommonWatch:EndWatch()
		end
	},

	["HSLJTeam"] = {
		fnWatch = function (itemObj)
			if not itemObj.nNpcId then
				return;
			end

			if WuLinDaHui:IsInMap(me.nMapTemplateId) then
				RemoteServer.DoRequesWLDH("SyncWatchTeamPlayerData", itemObj.nNpcId);
			else
				RemoteServer.DoRequesHSLJ("SyncWatchTeamPlayerData", itemObj.nNpcId);	
			end
       	 	
       	 	Timer:Register(2, function ()
       	 		local tbData = HuaShanLunJian:GetHSLJWatchPlayerData(itemObj.nNpcId);
       	 	    Ui:OpenWindowAtPos("WatchMenuPanel", 250, 30, tbData, "HSLJPlayer")
       	 	end)
		end,

		fnEndWatch = function ()
			CommonWatch:EndWatch();
			CommonWatch:StopAutoPath();
		end
	},

	["HSLJPlayer"] = {
		fnWatch = function (itemObj)
			if not itemObj.nNpcId then
				return;
			end
			if WuLinDaHui:IsInMap(me.nMapTemplateId) then
				RemoteServer.DoRequesWLDH("PlayerWatchTeamPlayer", itemObj.nNpcId);
			else
				RemoteServer.DoRequesHSLJ("PlayerWatchTeamPlayer", itemObj.nNpcId);	
			end
       	 	
		end,

		fnEndWatch = function ()
			CommonWatch:EndWatch();
			CommonWatch:StopAutoPath();
		end
	},
}

function tbUi:OnOpen(tbData, szSyncData)
	self:Refresh(tbData)
	self.szSyncDataType = szSyncData or "-";
end

function tbUi:Refresh(tbData)
	if not tbData or not tbData.nCurWatchId or not tbData.szType or not tbBattleType[tbData.szType] or not tbData.tbPlayer or #tbData.tbPlayer == 0 then
		return
	end
	self.szType = tbData.szType

	local tbCamp1 = self:ManageData(tbData.tbPlayer[1] or {},tbData.nCurWatchId)
	local tbCamp2 = self:ManageData(tbData.tbPlayer[2] or {},tbData.nCurWatchId)

	self.pPanel:SetActive("BtnOutMatch", (tbData.nCurWatchId > 0) or (tbData.nShowMatch == 1))
	if tbBattleType[self.szType].fnEndWatch then
		local function fnEndWatch(itemObj)
			tbBattleType[self.szType].fnEndWatch(itemObj)
			Ui:CloseWindow(self.UI_NAME);
		end
		self["BtnOutMatch"].pPanel.OnTouchEvent = fnEndWatch
	end

	self:UpdateScrollView("ScrollView1",tbCamp1)
	self:UpdateScrollView("ScrollView2",tbCamp2);
	self:CheckShowDown()
end

function tbUi:CheckShowDown()
	self.pPanel:SetActive("down1", not self.ScrollView1.pPanel:ScrollViewIsBottom())
	self.pPanel:SetActive("down2", not self.ScrollView2.pPanel:ScrollViewIsBottom())
end

function tbUi:UpdateScrollView(szScrollView,tbCamp)

	local function fnSetItem(itemObj,nIdx)
		itemObj.pParent = self;
		local szName = tbCamp[nIdx] and tbCamp[nIdx].name or ""
		itemObj["item"].pPanel:Label_SetText("Name", szName);

		itemObj["item"].nNpcId = tbCamp[nIdx] and tbCamp[nIdx].id or 0
		if tbBattleType[self.szType].fnWatch then
			local function fnStartWatch(itemObj)
				tbBattleType[self.szType].fnWatch(itemObj)
				Ui:CloseWindow(self.UI_NAME); 
			end
			itemObj["item"].pPanel.OnTouchEvent = fnStartWatch
		end
	end

	self[szScrollView]:Update(#tbCamp, fnSetItem);
end

function tbUi:ManageData(tbCamp,nCurWatchId)
	local tbManageData = {}
	for _,tbInfo in ipairs(tbCamp) do
		if tbInfo.id ~= nCurWatchId then
			table.insert(tbManageData,tbInfo)
		end
	end

	return tbManageData
end

function tbUi:OnSyncData(szType)
    if szType == "HSLJTeamWatchData" and self.szSyncDataType == "HSLJTeam" then
    	local tbShowData = HuaShanLunJian:GetHSLJFinalsWatchTeam();
    	self:Refresh(tbShowData);
    elseif string.find(szType, "HSLJWatchPlayer:") and self.szSyncDataType == "HSLJPlayer" then
    	local _, _, nFightTeam = string.find(szType, "HSLJWatchPlayer:(%d+)");
    	local tbData = HuaShanLunJian:GetHSLJWatchPlayerData(nFightTeam);
        self:Refresh(tbData);  	
    end    
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_REFRESH_WATCH, self.Refresh, self},
	    { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData, self},
	};

	return tbRegEvent;
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
end


local tbGrid = Ui:CreateClass("ArenaMatchItemGrid")
tbGrid.tbOnDrag =
{
	item = function (self, szWnd, nX, nY)
	end
}

tbGrid.tbOnDragEnd =
{
	item = function (self, szWnd, nX, nY)
		self.pParent:CheckShowDown()
	end
}
