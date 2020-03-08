local tbUi = Ui:CreateClass("FloatingWindowDisplay");

tbUi.tbShowQueue = tbUi.tbShowQueue or {};

local tbShowDetailItemId = {
		[10284] = true;
		[10285] = true;
		[10286] = true;
		[10287] = true;
	};

function tbUi:OnOpen(nItemId)
	if not nItemId then
		self.nItemId = self:QueuePop();
	else
		self.nItemId = nItemId;
	end
	
	local pItem = me.GetItemInBag(self.nItemId);
	if not pItem or not KItem.GetItemObj(self.nItemId) or not self.tbShowQueue or not next(self.tbShowQueue) then
		return 0;
	end

	if pItem.nEquipPos and pItem.nEquipPos ~= -1 then
		if version_kor then
			self.pPanel:Label_SetText("Label", "穿上");
		else
			self.pPanel:Label_SetText("Label", "装备");
		end
		self.szKind = "Equip";
	elseif tbShowDetailItemId[pItem.dwTemplateId] then
		self.pPanel:Label_SetText("Label", "查看");
		self.szKind = "ShowBoxDetail";
	else
		self.pPanel:Label_SetText("Label", "使用");
		self.szKind = "Box";
	end

	local szName = Item:GetDBItemShowInfo(pItem, me.nFaction);
	self.pPanel:Label_SetText("ItemName", szName);
	self:Update();
end

function tbUi:Update()
	local tbGridParams = {bShowTip = true}
	self.itemframe:SetItem(self.nItemId, tbGridParams);
	self.itemframe.szItemOpt = "ItemBox";
	self.itemframe.fnClick = self.itemframe.DefaultClick;
	local nCount = self:GetItemCount(self.nItemId);
	if nCount > 1 then
		self.itemframe.pPanel:Label_SetText("LabelSuffix", string.format("%s", nCount));
	else	
		self.itemframe.pPanel:SetActive("LabelSuffix", false);
	end	
end

function tbUi:GetItemCount(nItemId)
    local nTotalCount = #self.tbShowQueue;
    local nCount = 0;
    for nI = nTotalCount, 1, -1 do
    	if self.tbShowQueue[nI] == nItemId then
    		nCount = nCount + 1;
    	else
    		break;	
    	end	
    end

    return nCount;	
end

function tbUi:QueuePop()
	local nNumber = #self.tbShowQueue;
	if nNumber == 1 then
		self.tbShowQueue[nNumber] = nil;
		return  nil, false;
	elseif nNumber <= 0 then
		return  nil, false;
	end
	self.tbShowQueue[nNumber] = nil;
	local value = self.tbShowQueue[nNumber - 1];
	return value, true;
end

function tbUi:HaveUse(nItemId)
	if not self.tbShowQueue then
		return
	end

	if not next(self.tbShowQueue) or nItemId == self.tbShowQueue[#self.tbShowQueue] then
		self:fnBtnClose();
		return
	end
	for nSub = 1, #self.tbShowQueue - 1 do
		if self.tbShowQueue[nSub] == nItemId then
			table.remove(self.tbShowQueue, nSub)
			break;
		end
	end

end

function tbUi:fnBtnClose()

	local nItemId, bHaveValue = self:QueuePop()

	if not bHaveValue then
		Ui:CloseWindow("FloatingWindowDisplay");
		return;
	end

	if me.GetItemInBag(nItemId) then
		Ui:OpenWindow("FloatingWindowDisplay", nItemId);
	else
		self:fnBtnClose();
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi:ClearSameItem(nItemId)
	local FloatingWindowDisplay = Ui:GetClass("FloatingWindowDisplay");
	local tbNewShowQueue = {}
	local nNewIndex = 1;
	for nIndex=1,#FloatingWindowDisplay.tbShowQueue do
		if FloatingWindowDisplay.tbShowQueue[nIndex] ~= nItemId then
			tbNewShowQueue[nNewIndex] = FloatingWindowDisplay.tbShowQueue[nIndex];
			nNewIndex = nNewIndex + 1;
		end
	end
	FloatingWindowDisplay.tbShowQueue = tbNewShowQueue;
	table.insert(FloatingWindowDisplay.tbShowQueue,nItemId)			--为了消除掉当前关闭的弹窗
end


function tbUi.tbOnClick:BtnClose()
	if #self.tbShowQueue ~= 1 then
		if self.tbShowQueue[#self.tbShowQueue] then
			self:ClearSameItem(self.tbShowQueue[#self.tbShowQueue]);
		end
	end
	self:fnBtnClose();
end

function tbUi:CloseThisWindow()
	Ui:CloseWindow("FloatingWindowDisplay");
end

function tbUi.tbOnClick:BtnUse()

	if not self.nItemId or not KItem.GetItemObj(self.nItemId) then
		self:CloseThisWindow();
		return;
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return;
	end
	if self.szKind == "ShowBoxDetail" then
		Ui:OpenWindow("ItemTips", "Item", self.nItemId, pItem.dwTemplateId)
		self:CloseThisWindow();
		return;
	end

	if self.szKind == "Equip" then
		if pItem.nUseLevel > me.nLevel then
			me.CenterMsg("等级不足，无法装备")
			return;
		end

		if pItem.szClass == "SkillBook" then
			local tbSkillBook = Item:GetClass("SkillBook");
			local nEquipPos = tbSkillBook:FinEmptyHole(me);
			if not nEquipPos then
				me.CenterMsg("格子已经满了！");
				return;
			end

			RemoteServer.UseEquip(self.nItemId, nEquipPos);
		elseif pItem.szClass == "JuexueBook" then
			Item:GetClass("JuexueBook"):OnClientUse(pItem)
		elseif pItem.szClass == "MibenBook" or pItem.szClass == "DuanpianBook" then
			local nPos
			if pItem.szClass == "MibenBook" then
				nPos = JueXue:FindEmptyMibenPos(me)
			else
				nPos = JueXue:FindEmptyDuanpianPos(me)
			end
			if not nPos then
				local szMsg = "您尚未激活绝学区域"
				if JueXue:GetActivateAreaCount() ~= 0 then
					szMsg = (pItem.szClass == "MibenBook" and "秘本" or "断篇") .. "栏位已满，无法装备"
				end 
				me.CenterMsg(szMsg)
				return
			end
			RemoteServer.UseEquip(self.nItemId, nPos)
		else
			RemoteServer.UseEquip(self.nItemId);
		end
	elseif self.szKind == "Box" then
		Item:ClientUseItem(self.nItemId)
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.HaveUse },
		{ UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END,		self.CloseThisWindow },
    };

    return tbRegEvent;
end
