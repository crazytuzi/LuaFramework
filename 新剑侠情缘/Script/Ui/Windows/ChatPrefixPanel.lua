local tbUi = Ui:CreateClass("ChatPrefixPanel");

function tbUi:OnOpen()
	Ui:ClearRedPointNotify("ChatNamePrefix");
	self.nCurSelect = ChatMgr:GetNamePrefixCurrentSelect(me);
end

function tbUi:OnOpenEnd()
	self:Update();
end

function tbUi:Update()
	local tbNamePrefixs = {};
	local nNow = GetTime();
	local bHasSelect = false;
	for _, nPrefixId in pairs(ChatMgr.NamePrefixType) do
		local nTimeOut = ChatMgr:GetNamePrefixExpireTimeById(me, nPrefixId);
		if nNow < nTimeOut then
			if nPrefixId == self.nCurSelect then
				bHasSelect = true;
			end
			table.insert(tbNamePrefixs, nPrefixId);
		end
	end

	table.sort(tbNamePrefixs, function (a, b)
		local sA = ChatMgr:GetNamePrefixInfo(a).Sort;
		local sB = ChatMgr:GetNamePrefixInfo(b).Sort;
		return sA < sB;
	end)

	if not bHasSelect and #tbNamePrefixs > 0 then
		self.nCurSelect = tbNamePrefixs[1];
	end

	local fnSetSubItem = function (itemObj, nPrefixId)
		local szEmotion = ChatMgr:GetNamePrefix(nPrefixId, false, ChatMgr.ChannelType.Public, me.nFaction, nil, me.nSex);
		itemObj.pPanel:Label_SetText("Label", szEmotion);
		itemObj.pPanel:Toggle_SetChecked("Main", nPrefixId == self.nCurSelect);
		itemObj.pPanel.OnTouchEvent = function ()
			self.nCurSelect = nPrefixId;
			itemObj.pPanel:Toggle_SetChecked("Main", true);
		end
	end

	local fnSetItem = function (itemObj, nIdx)
		local nPrefixId1 = tbNamePrefixs[2*nIdx-1];
		local nPrefixId2 = tbNamePrefixs[2*nIdx];
		fnSetSubItem(itemObj.Item01, nPrefixId1);

		if nPrefixId2 then
			fnSetSubItem(itemObj.Item02, nPrefixId2);
		end
		itemObj.pPanel:SetActive("Item02", nPrefixId2 and true or false);
	end

	self.pPanel:SetActive("NoneTip", #tbNamePrefixs <= 0);
	self.PrefixScrollView:Update(math.ceil(#tbNamePrefixs/2), fnSetItem);
end


function tbUi:OnClose()
	if self.nCurSelect == ChatMgr:GetNamePrefixCurrentSelect(me) then
		return;
	end
	ChatMgr:SetCurrentNamePrefixInfo(self.nCurSelect);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end