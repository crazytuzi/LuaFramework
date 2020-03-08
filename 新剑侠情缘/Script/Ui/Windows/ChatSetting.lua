local tbUi = Ui:CreateClass("ChatSetting");
local ChatDecorate = ChatMgr.ChatDecorate

tbUi.Ui_Type = 
{
	MsgSetting = "MsgSetting",
	ChatDecorate = "ChatDecorate",
}

tbUi.tbTabData = 
{
	[tbUi.Ui_Type.MsgSetting] = {
		fnUpdate = function (self) self:UpdateMsgSettingUi() end,			-- panel更新
		szPanel = "ChatPart",												-- panel名字
		szToggle = "BtnChatSetting", 										-- 右侧toggle名字
		szTitle = "聊天设置",
	},
	[tbUi.Ui_Type.ChatDecorate] = {
		fnUpdate = function (self) self:UpdateChatDecorateUi() end,			-- panel更新
		szPanel = "HeadFramePart",											-- panel名字
		szToggle = "BtnPersonalitySetting", 								-- 右侧toggle名字
		szTitle = "个性设置",
	},
}

local szShowFlag = "nShowTheme"

function tbUi:OnOpen()
	self.tbCurDecorateData = {}
	ChatDecorate:ApplyKinData()
	ChatDecorate:TryCheckValid()
	Ui:CloseWindow("ChatLargePanel");
	ChatMgr:CheckNamePrefixInfo();
end

function tbUi:OnOpenEnd()
	self:ChangeTag(self.Ui_Type.MsgSetting)
end

function tbUi:UpdateMsgSettingUi()
	local tbChatSetting = ChatMgr:GetSetting();

	for szCheckName, bCheck in pairs(tbChatSetting) do
		if tbUi.tbOnClick[szCheckName] then
			self.pPanel:Toggle_SetChecked(szCheckName, bCheck);
		end
	end

	if not version_tx then
		--除大陆版 其他版本不能使用语音转文字
		self.pPanel:SetActive("CheckTextVoice", false);
	end
end

function tbUi:InitChatDecorateData(bCur)
	
	for _,nPartsType in pairs(ChatDecorate.PartsType) do
		local tbData = ChatDecorate.tbChatDecorateSetting[nPartsType]
		if not tbData then
			return
		end
		local nCurPartsID = ChatDecorate[tbData.szFnCur](ChatDecorate,me)
		self.tbCurDecorateData[nPartsType] = bCur and nCurPartsID or (self.tbCurDecorateData[nPartsType] or nCurPartsID)
	end
end

local nRowNum = 2

function tbUi:UpdateChatDecorateUi(bCur)
	self:InitChatDecorateData(bCur)
	local nShowHave = Client:GetFlag(szShowFlag)
	local bShowCan = not nShowHave or nShowHave == 0
	local tbTheme = ChatDecorate:GetAllShowTheme(me,bShowCan)
	self.pPanel:Toggle_SetChecked("ChatThemeToggle",bShowCan); 
	local fnSetItem = function (itemObj, nIdx)
		for i=1,nRowNum do
			itemObj.pPanel:SetActive("Name" ..i,false)
			itemObj.pPanel:SetActive("HeadFrame" ..i,false)
			itemObj.pPanel:SetActive("ChatBubble" ..i,false)

			local objHeadFrame = itemObj["HeadFrame" ..i]
			local objChatBubble = itemObj["ChatBubble" ..i]

			local nIndex = (nIdx - 1) * nRowNum + i
			local nThemeID = tbTheme[nIndex] and tbTheme[nIndex].nThemeID
			
			local nThemeInfo = ChatDecorate:GetThemeInfo(nThemeID)
			if nThemeInfo then
				itemObj.pPanel:SetActive("Name" ..i,true)
				itemObj.pPanel:SetActive("HeadFrame" ..i,true)
				itemObj.pPanel:SetActive("ChatBubble" ..i,true)

				itemObj.pPanel:Label_SetText("Name" ..i,ChatDecorate:GetTitleByThemeId(nThemeID, me.nSex))

				local nEndTime = ValueItem.ValueDecorate:GetValue(me,nThemeID)
				local nNowTime = GetTime()
				local bTime = nEndTime > 0 and nNowTime < nEndTime
				itemObj.pPanel:SetActive("Time" ..i,bTime)
				if bTime then
					local szTime = Lib:TimeDesc2(nEndTime - nNowTime) or "--"
					itemObj.pPanel:Label_SetText("Time" ..i,string.format("  时效：%s",szTime))
				end

				for nPartsType,nPartsID in ipairs(nThemeInfo.tbParts or {}) do
					local nCurPartsID = self.tbCurDecorateData[nPartsType]
					local bUsing = nCurPartsID == nPartsID
					local obj = nPartsType == ChatDecorate.PartsType.HEAD_FRAME and objHeadFrame or objChatBubble

					obj.pPanel:SetActive("Mark",bUsing)
					local bCanApply = ChatDecorate:CanApply(me,nPartsID)
					local szGet = ChatDecorate:GetTips(nPartsID,me.nSex)

			
					if nPartsType == ChatDecorate.PartsType.HEAD_FRAME then
						local nIcon = ChatDecorate:GetIcon(me.nSex,nPartsID)
                		local szFrameAtlas, szFrameSprite = Item:GetIcon(nIcon);
						local szRoleHead, szRoleAtlas = PlayerPortrait:GetSmallIcon(me.nPortrait);
						if bCanApply then
	                		obj.pPanel:Sprite_SetSprite("Head" ..i,szRoleHead, szRoleAtlas)
	                		obj.pPanel:Sprite_SetSprite("Main",szFrameSprite, szFrameAtlas)
	                	else
	                		obj.pPanel:Sprite_SetSpriteGray("Head" ..i,szRoleHead, szRoleAtlas)
	                		obj.pPanel:Sprite_SetSpriteGray("Main",szFrameSprite, szIconAtlas)
	                	end
	                elseif nPartsType == ChatDecorate.PartsType.BUBBLE then
	                	local nIcon = ChatDecorate:GetIcon(me.nSex,nPartsID)
                		local szIconAtlas, szIconSprite = Item:GetIcon(nIcon);
	                	if bCanApply then
	                		obj.pPanel:Sprite_SetSprite("Main",szIconSprite, szIconAtlas)
	                	else
	                		obj.pPanel:Sprite_SetSpriteGray("Main",szIconSprite, szIconAtlas)
	                	end

	                	local szDes = string.format("[365888]剑侠情缘[-]")
		                if not bCanApply then
		                	szDes = string.format("[747474]剑侠情缘[-]")
		                end 
			            obj.pPanel:Label_SetText("Txt" ..i, szDes)
					end

					obj.pPanel.OnTouchEvent = function (childObj)
                		if not bCanApply then
							me.SendBlackBoardMsg(szGet or "请先获得该主题")
							return
						end
	                    self.tbCurDecorateData[nPartsType] = nPartsID
	                    self:HideMark(nPartsType)
	                    childObj.pPanel:SetActive("Mark", true)
               		end
				end
			end
		end
	end
	
	self.ScrollView:Update(math.ceil(#tbTheme/2),fnSetItem)
end

-- 隐藏所有的选择特效，选中当前点击
function tbUi:HideMark(nPartsType)
	for i=0,100 do
		local pObj = self.ScrollView.Grid["Item" ..i]
		if not pObj then
			break
		end
		for j=1,100 do
			local cObj = nPartsType == ChatDecorate.PartsType.HEAD_FRAME and pObj["HeadFrame" ..j] or pObj["ChatBubble" ..j]
			if not cObj then
				break;
			end
			cObj.pPanel:SetActive("Mark",false)
		end
	end
end

function tbUi:OnClose()
	ChatDecorate:ApplyDecorate(self.tbCurDecorateData)
end

function tbUi:ChangeTag(szType)
	for szUiType,tbData in pairs(self.tbTabData) do

		local bActive = (szUiType == szType)
		if bActive then
			tbData.fnUpdate(self)
		end

		local szPanel = tbData.szPanel
		if szPanel then
			self.pPanel:SetActive(szPanel, bActive)
		end

		local szToggle = tbData.szToggle
		if szToggle then
			self.pPanel:Toggle_SetChecked(szToggle, bActive)
			self[szToggle].pPanel:SetActive("LabelLight", bActive);
		end

		local szTitle = bActive and tbData.szTitle
		if szTitle then
			self.pPanel:Label_SetText("Title", szTitle)
		end
	end
end

function tbUi:OnCheckClick(szCheckName)
	local bChecked = self.pPanel:Toggle_GetChecked(szCheckName);
	local tbChatSetting = ChatMgr:GetSetting();
	tbChatSetting[szCheckName] = bChecked;
end

tbUi.tbOnClick = {
	CheckKin = tbUi.OnCheckClick;
	CheckTeam = tbUi.OnCheckClick;
	CheckPublic = tbUi.OnCheckClick;
	CheckFriend = tbUi.OnCheckClick;
	CheckSystem = tbUi.OnCheckClick;
	CheckNearby = tbUi.OnCheckClick;
	CheckKinVoice = tbUi.OnCheckClick;
	CheckFriendVoice = tbUi.OnCheckClick;
	CheckTeamVoice = tbUi.OnCheckClick;
	CheckPublicVoice = tbUi.OnCheckClick;
	CheckNearbyVoice = tbUi.OnCheckClick;
	CheckTextVoice = tbUi.OnCheckClick;
	CheckPubVoice = tbUi.OnCheckClick;
	BtnChatSetting = function(self) self:ChangeTag(self.Ui_Type.MsgSetting) end;
	BtnPersonalitySetting = function(self) 
		self:ChangeTag(self.Ui_Type.ChatDecorate) 
		Ui:ClearRedPointNotify("Theme")
		Client:SetFlag("nChatDecorate", 0)
	end;
	ChatThemeToggle = function (self) 
		local bChoose = self.pPanel:Toggle_GetChecked("ChatThemeToggle");
		local nShowCan = bChoose and 0 or 1
		Client:SetFlag(szShowFlag,nShowCan)
		self:UpdateChatDecorateUi()
	end;
	
};

function tbUi.tbOnClick:BtnClose()
	ChatMgr:SaveSetting();
	Ui:CloseWindow("ChatSetting");
end

function tbUi.tbOnClick:BtnBlackList()
	Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelBlackList);
end

function tbUi.tbOnClick:BtnChatPrefix()
	Ui:OpenWindow("ChatPrefixPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_CHAT_THEME_OVERDUE,           self.UpdateChatDecorateUi},
    };

    return tbRegEvent;
end
