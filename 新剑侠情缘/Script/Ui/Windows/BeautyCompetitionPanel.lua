local tbUi = Ui:CreateClass("BeautyCompetitionPanel");
-- 好声音评选和美女评选活动共用好友投票界面,好声音推荐好友也用这个界面
local tbBeautyPageantAct = Activity.BeautyPageant;
local tbGoodVoiceAct = Activity.GoodVoice
tbUi.TYPE_BEAUTY_COMPETITION = 1
tbUi.TYPE_GOODVOICE_COMPETITION = 2
tbUi.TYPE_GOODVOICE_RECOMMOND = 3
tbUi.tbSetting = 
{
	[tbUi.TYPE_BEAUTY_COMPETITION] = 
	{
		fnRequest = function ()
			tbBeautyPageantAct:RequestSignUpFriend()
		end;
		fnGetList = function ()
			return tbBeautyPageantAct:GetSignUpFriendList()
		end;
		fnVoteForClick = function (tbInfo)
			local szUrl = string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(Activity.BeautyPageant:GetPlayerUrl(), tbInfo.nPlayerId, Sdk:GetServerId()))
			Ui.HyperTextHandle:Handle(szUrl);
		end;
		szButtonOtherText = "其他佳人";
		fnBtnOtherClick = function ()
			tbBeautyPageantAct:OpenMainPage()
		end;
		szTitle = "参赛好友";
		szNoneTip = "暂无参赛的好友";
	};
	[tbUi.TYPE_GOODVOICE_COMPETITION] = 
	{
		fnRequest = function ()
			tbGoodVoiceAct:RequestSignUpFriend()
		end;
		fnGetList = function ()
			return tbGoodVoiceAct:GetSignUpFriendList()
		end;
		fnVoteForClick = function (tbInfo)
			local szUrl = string.format(Activity.GoodVoice:GetPlayerPage(tbInfo.nPlayerId, tbInfo.szAccount))
			Ui.HyperTextHandle:Handle(szUrl);
		end;
		szButtonOtherText = "其他选手";
		fnBtnOtherClick = function ()
			tbGoodVoiceAct:MainEnter()
		end;
		szTitle = "参赛好友";
		szNoneTip = "暂无参赛的好友";
	};
	[tbUi.TYPE_GOODVOICE_RECOMMOND] = 
	{
		fnRequest = function ()
			tbGoodVoiceAct:RequestUnSignUpFriend()
		end;
		fnGetList = function ()
			return tbGoodVoiceAct:GetUnSignUpFriendList()
		end;
		fnVoteForClick = function (tbInfo)
			tbGoodVoiceAct:RequestRecommend(tbInfo.nPlayerId)
		end;
		szTitle = "可邀请好友";
		szNoneTip = "暂无可邀请的好友";
		szBtnGiveTxt = "邀请";
	};
}
function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_BEAUTY_FRIEND_LIST, self.UpdateList, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen(nType)
	self.tbData = self.tbSetting[nType]
	if not self.tbData then
		return
	end
	if self.tbData.fnRequest then
		self.tbData.fnRequest()
	end
	self:UpdateList();
end

function tbUi:GetRunningAct()
	local tbAct = tbBeautyPageantAct
	local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
	if bGoodVoiceRunning then
		tbAct = tbGoodVoiceAct
	end
	return tbAct
end

function tbUi:UpdateList()
	local tbPlayerMap = self.tbData.fnGetList()

	local tbList = {};

	for nPlayerId,szAccount in pairs(tbPlayerMap) do
		local tbData = FriendShip:GetFriendDataInfo(nPlayerId)
		if tbData then
			local tbInfo = 
			{
				nPlayerId = nPlayerId,
				szName = tbData.szName,
				nLevel = tbData.nLevel,
				nFaction = tbData.nFaction,
				nPortrait = tbData.nPortrait,
				nHonorLevel = tbData.nHonorLevel,
				nImity = tbData.nImity,
				szAccount = szAccount,
			}
			table.insert(tbList, tbInfo);
		end
	end
	--按亲密度排序
	local function fnImitySort(a,b)
		return a.nImity > b.nImity
	end

	table.sort(tbList, fnImitySort)

	local fnSetItem = function (tbItem, nIndex)
		local tbInfo = tbList[nIndex];

		tbItem.pPanel:Label_SetText("lbRoleName", tbInfo.szName);
		tbItem.pPanel:Label_SetText("lbLevel", tostring(tbInfo.nLevel));

		if tbInfo.nHonorLevel > 0 then
			tbItem.pPanel:SetActive("PlayerTitle", true);

			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
			tbItem.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			tbItem.pPanel:SetActive("PlayerTitle", false);
		end

		local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbInfo.nPortrait);
		if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
			tbItem.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);
		end

		tbItem.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction));
		tbItem["BtnGive"].pPanel:Label_SetText("Label", self.tbData.szBtnGiveTxt or "前去赠送");
		tbItem.BtnGive.pPanel.OnTouchEvent = function()
			self.tbData.fnVoteForClick(tbInfo)
		end
	end

	self.ScrollView:Update(tbList, fnSetItem);

	self.pPanel:SetActive("Tip", #tbList <= 0)
	self.pPanel:Label_SetText("Tip", self.tbData.szNoneTip or "暂无参赛的好友")
	if self.tbData.szButtonOtherText then
		self.pPanel:SetActive("BtnOther", true)
		self.pPanel:Label_SetText("Label", self.tbData.szButtonOtherText);
	else
		self.pPanel:SetActive("BtnOther", false)
	end
	self.pPanel:Label_SetText("Title", self.tbData.szTitle or "参赛好友")
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnOther = function (self)
	if self.tbData.fnBtnOtherClick then
		self.tbData.fnBtnOtherClick()
	end
	local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
	if bGoodVoiceRunning then
		Ui.HyperTextHandle:Handle(Activity.GoodVoice:GetMainPage());
	else
		Activity.BeautyPageant:OpenMainPage()
	end
	Ui:CloseWindow(self.UI_NAME);
end
