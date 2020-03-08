local tbUi = Ui:CreateClass("RankBoardPanel");

--带头衔的名字设置
local fnSetRecordName = function (pPanel, tbRecord)
	pPanel:SetActive("Col1Name", true)
	pPanel:SetActive("Col1Str", false)

	local SpFaction = Faction:GetIcon(tbRecord.nFaction)
	pPanel:Sprite_SetSprite("Faction",  SpFaction);
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel)
	if ImgPrefix then
		pPanel:SetActive("Name", true)
		pPanel:SetActive("Name2", false)
		pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		pPanel:Label_SetText("Name", tbRecord.szName)
	else
		pPanel:SetActive("Name", false)
		pPanel:SetActive("Name2", true)
		pPanel:Label_SetText("Name2", tbRecord.szName);
	end
end

local tbSetRankItemFunc = {
	["Default"] = function (tbItem, tbRecord) --功力
		fnSetRecordName(tbItem.pPanel, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:Label_SetText("Col2Str", Lib:IsEmptyStr(tbRecord.szKinName) and "-" or tbRecord.szKinName);

		tbItem.pPanel:Label_SetText("Col3Num", tbRecord.szValue);

		local nPlat = Sdk:GetCurPlatform();
		if tbRecord.bGameCenter and nPlat ~= Sdk.ePlatform_None and not Client:IsCloseIOSEntry() and not Sdk:IsOuterChannel() then
			tbItem.pPanel:SetActive("GameCenter", nPlat == Sdk.ePlatform_QQ);
			tbItem.pPanel:SetActive("GameCenterIcon1", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon2", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon3", nPlat == Sdk.ePlatform_Weixin);
		else
			tbItem.pPanel:SetActive("GameCenter", false);
			tbItem.pPanel:SetActive("GameCenterIcon1", false);
			tbItem.pPanel:SetActive("GameCenterIcon2", false);
			tbItem.pPanel:SetActive("GameCenterIcon3", false);
		end
	end;

	["kin"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", true)
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("Col3Num", false)
		tbItem.pPanel:SetActive("GameCenter", false);
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);

		tbItem.pPanel:Label_SetText("Col5Name", tbRecord.szKinName)
		tbItem.pPanel:Label_SetText("Col5Num", tbRecord.nLevel)
		tbItem.pPanel:Label_SetText("Col6Num", tbRecord.nPrestige);
		tbItem.pPanel:Label_SetText("Col6Name", tbRecord.szLeaderName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel)
		if ImgPrefix then
			tbItem.pPanel:SetActive("PlayerTitle6", true)
			tbItem.pPanel:Sprite_Animation("PlayerTitle6", ImgPrefix, Atlas);
		else
			tbItem.pPanel:SetActive("PlayerTitle6", false)
		end
	end;

	["DumplingBanquetAct"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false);
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:SetActive("Col2Str", true)
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);

		tbItem.pPanel:Label_SetText("Col1Str", tbRecord.szKinName)
		tbItem.pPanel:Label_SetText("Col3Num", tbRecord.szValue);
		tbItem.pPanel:Label_SetText("Col2Str", tbRecord.szLeaderName)
		tbItem.pPanel:SetActive("PlayerTitle6", false)
	end;

	["LunJianRank"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", true)
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("Col3Num", false)
		tbItem.pPanel:SetActive("GameCenter", false);
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);
		tbItem.pPanel:SetActive("PlayerTitle6", false)

		tbItem.pPanel:Label_SetText("Col5Name", tbRecord.szName or "-")
		tbItem.pPanel:Label_SetText("Col6Num", tostring(tbRecord.nJiFen or "-"));
		tbItem.pPanel:Label_SetText("Col6Name", tostring(tbRecord.nWin or "-"));
		tbItem.pPanel:Label_SetText("Col5Num", Lib:TimeDesc(tbRecord.nTime or 0));
	end;

	["LingJueFengWeekRank"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("GameCenter", false)
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", true)
		tbItem.pPanel:SetActive("Name", false)
		tbItem.pPanel:SetActive("Name2", true)
		tbItem.pPanel:SetActive("Col2Num", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:SetActive("PlayerTitle6", false);
		tbItem.pPanel:Label_SetText("Col1Str", tbRecord.szName or "1")
		--tbItem.pPanel:Label_SetText("Col6Num", ""); --tostring(tbRecord.nFailed or "2"));
		tbItem.pPanel:Label_SetText("Col2Num", tostring(tbRecord.nLevel or "3"));
		tbItem.pPanel:Label_SetText("Col3Num", Lib:TimeDesc(tbRecord.nTime or 0));
	end;

	["TianJiMiZhen"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("GameCenter", false)
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", true)
		tbItem.pPanel:SetActive("Name", false)
		tbItem.pPanel:SetActive("Name2", true)
		tbItem.pPanel:SetActive("Col2Num", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:SetActive("PlayerTitle6", false);
		tbItem.pPanel:Label_SetText("Col1Str", tbRecord.szName or "1")
		--tbItem.pPanel:Label_SetText("Col6Num", ""); --tostring(tbRecord.nFailed or "2"));
		tbItem.pPanel:Label_SetText("Col2Num", tostring(tbRecord.nPassMJNum or 0));
		tbItem.pPanel:Label_SetText("Col3Num", tostring(tbRecord.nPassNum or 0));
	end;

	["qunyinghui"] = function (tbItem, tbRecord)
	    fnSetRecordName(tbItem.pPanel, tbRecord)

		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:Label_SetText("Col2Str", Lib:IsEmptyStr(tbRecord.szKinName) and "-" or tbRecord.szKinName);

		local nValue = tonumber(tbRecord.szValue);
		local nJiFen = math.floor(nValue / 1000);
		tbItem.pPanel:Label_SetText("Col3Num", tostring(nJiFen));

		local nPlat = Sdk:GetCurPlatform();
		if tbRecord.bGameCenter and nPlat ~= Sdk.ePlatform_None and not Client:IsCloseIOSEntry() and not Sdk:IsOuterChannel() then
			tbItem.pPanel:SetActive("GameCenter", nPlat == Sdk.ePlatform_QQ);
			tbItem.pPanel:SetActive("GameCenterIcon1", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon2", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon3", nPlat == Sdk.ePlatform_Weixin);
		else
			tbItem.pPanel:SetActive("GameCenter", false);
			tbItem.pPanel:SetActive("GameCenterIcon1", false);
			tbItem.pPanel:SetActive("GameCenterIcon2", false);
			tbItem.pPanel:SetActive("GameCenterIcon3", false);
		end
	end;

	["Level"] = function (tbItem, tbRecord)
		fnSetRecordName(tbItem.pPanel, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:Label_SetText("Col2Str", Lib:IsEmptyStr(tbRecord.szKinName) and "-" or tbRecord.szKinName);
		tbItem.pPanel:Label_SetText("Col3Num", tbRecord.nLevel);

		local nPlat = Sdk:GetCurPlatform();
		if tbRecord.bGameCenter and nPlat ~= Sdk.ePlatform_None and not Client:IsCloseIOSEntry() and not Sdk:IsOuterChannel() then
			tbItem.pPanel:SetActive("GameCenter", nPlat == Sdk.ePlatform_QQ);
			tbItem.pPanel:SetActive("GameCenterIcon1", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon2", nPlat == Sdk.ePlatform_Weixin);
			tbItem.pPanel:SetActive("GameCenterIcon3", nPlat == Sdk.ePlatform_Weixin);
		else
			tbItem.pPanel:SetActive("GameCenter", false);
			tbItem.pPanel:SetActive("GameCenterIcon1", false);
			tbItem.pPanel:SetActive("GameCenterIcon2", false);
			tbItem.pPanel:SetActive("GameCenterIcon3", false);
		end
	end;

	["CardCollection_1"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", true)
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("Col3Num", false)
		tbItem.pPanel:SetActive("GameCenter", false);
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);

		tbItem.pPanel:Label_SetText("Col5Name", Lib:IsEmptyStr(tbRecord.szKinName) and "-" or tbRecord.szKinName)
		tbItem.pPanel:Label_SetText("Col6Num", tbRecord.nLowValue)
		tbItem.pPanel:Label_SetText("Col5Num", tbRecord.nHighValue - tbRecord.nLowValue)
		tbItem.pPanel:Label_SetText("Col6Name", tbRecord.szName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel)
		if ImgPrefix then
			tbItem.pPanel:SetActive("PlayerTitle6", true)
			tbItem.pPanel:Sprite_Animation("PlayerTitle6", ImgPrefix, Atlas);
		else
			tbItem.pPanel:SetActive("PlayerTitle6", false)
		end
	end;

	["House"] = function (tbItem, tbRecord)
		fnSetRecordName(tbItem.pPanel, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("GameCenter", false)
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);

		tbItem.pPanel:SetActive("Col2Num", true)
		tbItem.pPanel:SetActive("Col3Num", true)
		tbItem.pPanel:Label_SetText("Col2Num", tbRecord.nHouseLevel or "-");
		tbItem.pPanel:Label_SetText("Col3Num", tostring(House:CalcuComfortLevel(tonumber(tbRecord.szValue))));
	end,

	["KinActivityRankAct"] = function (tbItem, tbRecord)
		tbItem.pPanel:SetActive("Friend", false)
		tbItem.pPanel:SetActive("Family", true)
		tbItem.pPanel:SetActive("Col1Name", false)
		tbItem.pPanel:SetActive("Col1Str", false)
		tbItem.pPanel:SetActive("Col2Num", false)
		tbItem.pPanel:SetActive("Col2Str", false)
		tbItem.pPanel:SetActive("Col3Num", false)
		tbItem.pPanel:SetActive("GameCenter", false);
		tbItem.pPanel:SetActive("GameCenterIcon1", false);
		tbItem.pPanel:SetActive("GameCenterIcon2", false);
		tbItem.pPanel:SetActive("GameCenterIcon3", false);

		tbItem.pPanel:Label_SetText("Col5Name", tbRecord.szKinName or "-")
		tbItem.pPanel:Label_SetText("Col5Num", tbRecord.nLevel)
		tbItem.pPanel:Label_SetText("Col6Num", tbRecord.szValue or "-");
		tbItem.pPanel:Label_SetText("Col6Name", tbRecord.szLeaderName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRecord.nHonorLevel)
		if ImgPrefix then
			tbItem.pPanel:SetActive("PlayerTitle6", true)
			tbItem.pPanel:Sprite_Animation("PlayerTitle6", ImgPrefix, Atlas);
		else
			tbItem.pPanel:SetActive("PlayerTitle6", false)
		end
	end;
}

local tbSetRankTitle = {
	["Default"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "积分")
	end;

	["WorldCupAct"] = function(self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "价值")
	end;

	["MedalFightAct"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "奖章")
	end;

	["kin"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", true);
		self.pPanel:SetActive("TitleListTitleBackground", false);

		self.pPanel:Label_SetText("Label11", "排名")
		self.pPanel:Label_SetText("Label12", "家族名")
		self.pPanel:Label_SetText("Label13", "家族等级")
		self.pPanel:Label_SetText("Label14", "家族威望")
		self.pPanel:Label_SetText("Label15", "家族领袖")
	end;

	["LunJianRank"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", true);
		self.pPanel:SetActive("TitleListTitleBackground", false);

		self.pPanel:Label_SetText("Label11", "排名")
		self.pPanel:Label_SetText("Label12", "战队")
		self.pPanel:Label_SetText("Label14", "积分")
		self.pPanel:Label_SetText("Label15", "胜场数")
		self.pPanel:Label_SetText("Label13", "时间")
	end;

	["LingJueFengWeekRank"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "战队名");
		self.pPanel:Label_SetText("Label3", "通关层数");
		self.pPanel:Label_SetText("Label4", "挑战时间");
	end;

	["TianJiMiZhen"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "战队名");
		self.pPanel:Label_SetText("Label3", "通关秘境数");
		self.pPanel:Label_SetText("Label4", "通关迷阵数");
	end;

	["FightPower"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "战力")
	end;

	["Level"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "等级")
	end;

	["CardCollection"] = function (self, type)
		if type == "1" then
			self.pPanel:SetActive("FriendListTitleBackground", false);
			self.pPanel:SetActive("FamilyListTitleBackground", true);
			self.pPanel:SetActive("TitleListTitleBackground", false);

			self.pPanel:Label_SetText("Label11", "排名")
			self.pPanel:Label_SetText("Label12", "家族")
			self.pPanel:Label_SetText("Label13", "完成度")
			self.pPanel:Label_SetText("Label14", "珍稀度")
			self.pPanel:Label_SetText("Label15", "名称")
		else
			self.pPanel:SetActive("FriendListTitleBackground", false);
			self.pPanel:SetActive("FamilyListTitleBackground", false);
			self.pPanel:SetActive("TitleListTitleBackground", true);
			self.pPanel:Label_SetText("Label2", "名称")
			self.pPanel:Label_SetText("Label3", "家族")
			self.pPanel:Label_SetText("Label4", "完成度")
		end
	end;

	["ZhongQiuJie"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);

		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "祭月值")
	end;

	["House"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称");
		self.pPanel:Label_SetText("Label3", "家园等级");
		self.pPanel:Label_SetText("Label4", "舒适等级");
	end;

	["WulinHonor"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称");
		self.pPanel:Label_SetText("Label3", "家族");
		self.pPanel:Label_SetText("Label4", "武林荣誉");
	end;

	["AchievementPoint"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "成就点")
	end;
	["MaterialCollectAct"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "价值")
	end;
	["DaXueZhangRank"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "积分")
	end;

	["KinActivityRankAct"]	= function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", true);
		self.pPanel:SetActive("TitleListTitleBackground", false);

		self.pPanel:Label_SetText("Label11", "排名")
		self.pPanel:Label_SetText("Label12", "家族名")
		self.pPanel:Label_SetText("Label13", "家族等级")
		self.pPanel:Label_SetText("Label14", "总活跃")
		self.pPanel:Label_SetText("Label15", "家族领袖")
	end;

	["YinXingJiQingAct"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label2", "名称")
		self.pPanel:Label_SetText("Label3", "家族")
		self.pPanel:Label_SetText("Label4", "点赞")
	end;

	["DumplingBanquetAct"] = function (self)
		self.pPanel:SetActive("FriendListTitleBackground", false);
		self.pPanel:SetActive("FamilyListTitleBackground", false);
		self.pPanel:SetActive("TitleListTitleBackground", true);
		self.pPanel:Label_SetText("Label1", "排名")
		self.pPanel:Label_SetText("Label2", "家族名")
		self.pPanel:Label_SetText("Label3","家族领袖");
		self.pPanel:Label_SetText("Label4", "饺子数")
	end;
}

local tbSetMyRank = {
	["Default"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的积分：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["WorldCupAct"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的价值：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["MedalFightAct"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的奖章：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["kin"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "家族排名：")
		self.pPanel:Label_SetText("OwnRanKind", "家族威望：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.nPrestige or "-")
		if me.dwKinId == 0 then
			self.pPanel:Label_SetText("OwnRankVal",  "-")
			self.pPanel:Label_SetText("OwnRankPos",  "无家族")
		end
	end;

	["DumplingBanquetAct"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "家族排名：")
		self.pPanel:Label_SetText("OwnRanKind", "饺子数：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
		if me.dwKinId == 0 then
			self.pPanel:Label_SetText("OwnRankVal",  "-")
			self.pPanel:Label_SetText("OwnRankPos",  "无家族")
		end
	end;

	["LunJianRank"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "战队的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "战队的积分：")
		self.pPanel:Label_SetText("OwnRankVal", tostring(tbMyRankInfo and tbMyRankInfo.nJiFen or "-"))
	end;

	["LingJueFengWeekRank"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "战队排名：")
		self.pPanel:Label_SetText("OwnRanKind", "战队层数:")
		local szLevel = tostring(tbMyRankInfo and tbMyRankInfo.nLevel or 0);
		self.pPanel:Label_SetText("OwnRankVal",szLevel);

	end;

	["TianJiMiZhen"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "战队排名：")
		self.pPanel:Label_SetText("OwnRanKind", "战队通关数：")
		local szLevel = tostring(tbMyRankInfo and tbMyRankInfo.nPassNum or 0);
		self.pPanel:Label_SetText("OwnRankVal",szLevel);
	end;

	["FightPower"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的战力：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["Level"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的等级：")
		self.pPanel:Label_SetText("OwnRankVal", me.nLevel)
	end;

	["CardCollection"] = function (self, tbMyRankInfo, type)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		if type == "1" then
			self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.nLowValue or "-")
			self.pPanel:Label_SetText("OwnRanKind", "珍 稀 度：")
		else
			self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
			self.pPanel:Label_SetText("OwnRanKind", "完 成 度：")
		end
	end;

	["ZhongQiuJie"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "祭月值：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["House"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：");
		self.pPanel:Label_SetText("OwnRanKind", "舒适等级：");

		local szLevel = "-";
		if tbMyRankInfo.szValue then
			szLevel = tostring(House:CalcuComfortLevel(tonumber(tbMyRankInfo.szValue)));
		end
		self.pPanel:Label_SetText("OwnRankVal", szLevel);
	end;

	["AchievementPoint"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "我的成就点：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;

	["KinActivityRankAct"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "家族排名：")
		self.pPanel:Label_SetText("OwnRanKind", "总活跃：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.nValue or "-")
		if me.dwKinId == 0 then
			self.pPanel:Label_SetText("OwnRankVal",  "-")
			self.pPanel:Label_SetText("OwnRankPos",  "无家族")
		end
	end;

	["YinXingJiQingAct"] = function (self, tbMyRankInfo)
		self.pPanel:Label_SetText("OwnRank", "我的排名：")
		self.pPanel:Label_SetText("OwnRanKind", "点赞：")
		self.pPanel:Label_SetText("OwnRankVal", tbMyRankInfo.szValue or "-")
	end;
}

function tbUi:OnOpen(szKey)
	if szKey then
		local tbRankSetting = RankBoard.tbSetting[szKey]
		if tbRankSetting then
			if Lib:IsEmptyStr(tbRankSetting.Sub) then
				self.szCurKey = szKey;
			else
				self.szCurKey = tbRankSetting.Sub
				self.bHasSubs =  true
				self:SetLeftItem()
				self.szCurKey = szKey
			end
		end
	end
	if not self.szCurKey then
		local tbOriShowKeys = RankBoard:GetUiShowOriShowKeys()
		for i,v in ipairs(tbOriShowKeys) do
			if not v.tbSubs then
				self.szCurKey = v.Key
				break;
			end
		end
	end

	self:UpdateLeftBar()
	self:SetLeftBarToCurKey()
	self.nCurPage = 1
	self:UpdateRank();
end

function tbUi:OnClose()
	if self.szCurKey == "GlobalPowerRank" then
		self.szCurKey = nil;
	end
end

function tbUi:SetLeftItem()
	local tbOriShowKeys = RankBoard:GetUiShowOriShowKeys()
	if not self.bHasSubs then
		self.tbCurLeftView = tbOriShowKeys
	else
		local tbCurLeftView = {}
		for i, v in ipairs(tbOriShowKeys) do
			table.insert(tbCurLeftView, v)
			if v.tbSubs and v.Key == self.szCurKey then
				for _,v2 in ipairs(v.tbSubs) do
					table.insert(tbCurLeftView, v2)
				end
			end
		end
		self.tbCurLeftView = tbCurLeftView
	end
end

function tbUi:UpdateLeftBar()
	if not self.tbCurLeftView then
		self:SetLeftItem()
	end

	local fnSelLeftKey = function (tbItemObj)
		local tbData = tbItemObj.tbData
		if not tbData.bSub then
			if tbData.tbSubs then
				if self.szMainKey == tbData.Key then
					self.bHasSubs = not self.bHasSubs
				else
					self.bHasSubs = true
				end
			else
				self.bHasSubs = false
			end
		end
		if tbData.Key == "GlobalPowerRank" then
			Sdk:OpenUrl(string.format("http://www.jxqy.org/?roleid=%d&partition=%d&loginplatid=%d", me.dwID, SERVER_ID, Sdk:GetLoginPlatId()));
			return
		end

		self.szCurKey = tbData.Key

		if not tbData.tbSubs then
			self.nCurPage = 1;
			self:UpdateRank()
		end

		if not tbData.bSub then

			self:SetLeftItem();
			Timer:Register(1, function ( )
				self:UpdateLeftBar()
			end)

			if tbData.tbSubs then
				self.szMainKey = tbData.Key;
				local tbSub = tbData.tbSubs
				local v = tbSub[1]
				self.szCurKey = v.Key
				self.nCurPage = 1;
				self:UpdateRank()
			end
			return
		end

		if self.bHasSubs and tbData.tbSubs then
			self.ScrollViewLeft.pPanel:ScrollViewGoTop();
		end
	end

	local fnSetItem = function (itemObj, index)
		local tbData = self.tbCurLeftView[index]
		if not tbData.bSub then --选中一级目录时
			local pBaseClassPanel = nil;
			if not Lib:IsEmptyStr(tbData.ActivityType) or tbData.Key == "灭火大作战"then --活动UI
				itemObj.pPanel:SetActive("Mark", true)
			else
				itemObj.pPanel:SetActive("Mark", false)
			end
			itemObj.pPanel:SetActive("BaseClass", true)
			itemObj.pPanel:SetActive("SubClass", false)
			pBaseClassPanel = itemObj.BaseClass.pPanel

			local tbNextData = self.tbCurLeftView[index + 1]

			pBaseClassPanel:Toggle_SetChecked("Main",  self.szCurKey == tbData.Key)

			if  tbNextData and tbNextData.bSub then --已经展开的大类
				pBaseClassPanel:SetActive("BtnDownS", false)
				pBaseClassPanel:SetActive("BtnUpS", true)
				pBaseClassPanel:Button_SetSprite("Main", "BtnListMainPress", 1)
			else

				pBaseClassPanel:SetActive("BtnUpS", false)
				pBaseClassPanel:Button_SetSprite("Main", "BtnListMainNormal", 1)
				if tbData.tbSubs then --可展开 但是现在是收起来的
					pBaseClassPanel:SetActive("BtnDownS", true)
				else
					pBaseClassPanel:SetActive("BtnDownS", false)
				end
			end

			pBaseClassPanel:Label_SetText("LabelLight", tbData.Name);
			pBaseClassPanel:Label_SetText("LabelDark", tbData.Name);
			pBaseClassPanel.OnTouchEvent = fnSelLeftKey;

			itemObj.BaseClass.tbData = tbData;
		else
			itemObj.pPanel:SetActive("Mark", false)
			itemObj.pPanel:SetActive("BaseClass", false)
            itemObj.pPanel:SetActive("SubClass", true)
            itemObj.SubClass.pPanel:Label_SetText("Label", tbData.Name );
			itemObj.SubClass.pPanel:Toggle_SetChecked("Main", self.szCurKey == tbData.Key)
			if tbData.Key == "GlobalPowerRank" then
				itemObj.SubClass.pPanel:Toggle_SetChecked("Main", false)
			end
            itemObj.SubClass.tbData = tbData;
			itemObj.SubClass.pPanel.OnTouchEvent = fnSelLeftKey;

		end
	end

	self:UpdateLeftBarHegiht();
	self.ScrollViewLeft:Update(self.tbCurLeftView, fnSetItem)
end

function tbUi:SetLeftBarToCurKey()
	for i, tbInfo in ipairs(self.tbCurLeftView or {}) do
		if tbInfo.Key == self.szCurKey then
			self.ScrollViewLeft.pPanel:ScrollViewGoToIndex("Main", i)
			break
		end
	end
end

function tbUi:UpdateLeftBarHegiht()
	local tbHeight = {};
    for i,v in ipairs(self.tbCurLeftView) do
        table.insert(tbHeight,  v.bSub and 60 or 76);
    end

    self.ScrollViewLeft:UpdateItemHeight(tbHeight);
end

local tbRightPopupKey = {
	["kin"]              = "RankKinView",
	["KinActivityRankAct"] = "RankKinView",
	["DumplingBanquetAct"] = "RankKinView",
	["AchievementPoint"] = "AchievementPoint",
	["Default"]          = "RankView",
}
function tbUi:UpdateRank()
	local szKey = self.szCurKey
	if szKey == "GlobalPowerRank" then
		return
	end

	local nPage = self.nCurPage

	local tbSplitItem = Lib:SplitStr(szKey, "_") --因为有 FightPower_1 这种子类
	local MainKey = tbSplitItem[1]

	local fnSetTitle = tbSetRankTitle[MainKey] or tbSetRankTitle["Default"]
	fnSetTitle(self, tbSplitItem[2])

	local tbData = RankBoard:CheckUpdateData(szKey, nPage)
	self:UpdateMyRankInfo(MainKey, tbSplitItem[2]);

	if not tbData then
		for i = 1, RankBoard.PAGE_NUM do
			self["RankBoardItem" .. i].pPanel:SetActive("Main", false)
		end
		return
	else
		local fnSelRecord = function (tbItem)
			if szKey == "LunJianRank" then
				Ui:OpenWindow("TeamDetailsPanel", tbItem.tbRecord.dwUnitID);
			elseif szKey == "LingJueFengWeekRank" or szKey == "TianJiMiZhen" then
				Fuben.LingJueFengWeek:AskRankBoardMsg(tbItem.tbRecord.dwUnitID);
			else
				local tbRecord = tbItem.tbRecord;
				if tbRecord.nPosition == self.nCurSelfPos or szKey == "Friend" then
					return
				end
				tbItem.nClickTime = tbItem.nClickTime or 0
				tbItem.nClickTime = tbItem.nClickTime + 1
				if tbItem.nClickTime == 2 then
					Ui:OpenWindowAtPos("RightPopup", -100, -90, tbRightPopupKey[szKey] or tbRightPopupKey.Default,
						{dwRoleId = tbRecord.dwUnitID, szName = tbRecord.szName, dwKinId = tbRecord.dwKinId})
					tbItem.nClickTime = 0;
				end
			end
		end

		for i = 1, RankBoard.PAGE_NUM do
			local tbRecord = tbData[i]
			local tbItem = self["RankBoardItem" .. i]

			if tbRecord then
				tbItem.tbRecord = tbRecord
				tbItem.pPanel:SetActive("Main", true)
				local nPos = tbRecord.nPosition;
				if nPos < 4 then
					tbItem.pPanel:SetActive("RankLabel", false)
					tbItem.pPanel:SetActive("RankIcon", true)
					tbItem.pPanel:Sprite_SetSprite("RankIcon", "Rank_top" .. nPos)
				else
					tbItem.pPanel:SetActive("RankLabel", true)
					tbItem.pPanel:SetActive("RankIcon", false)
					tbItem.pPanel:Label_SetText("RankLabel", nPos)
				end

				tbItem.pPanel.OnTouchEvent = fnSelRecord;

				tbItem.pPanel:Button_SetSprite("Main", nPos == self.nCurSelfPos and "BtnListFourthOwn" or "BtnListFourthNormal", 1)

				local fnItemSet = tbSetRankItemFunc[szKey] or tbSetRankItemFunc["Default"]
				fnItemSet(tbItem, tbRecord)

				local fnTouchWXIcon = function ()
					if tbRecord.bGameCenter then
						local tbPos = tbItem.pPanel:GetRealPosition("Main");
						Ui:OpenWindowAtPos("TxtWeixinGameCenter", tbPos.x, tbPos.y - 30);
					end
				end

				tbItem.GameCenterIcon1.pPanel.OnTouchEvent = fnTouchWXIcon;
				tbItem.GameCenterIcon2.pPanel.OnTouchEvent = fnTouchWXIcon;
				tbItem.GameCenterIcon3.pPanel.OnTouchEvent = fnTouchWXIcon;
			else
				tbItem.pPanel:SetActive("Main", false)
			end
		end
	end
end

function tbUi:UpdateMyRankInfo(MainKey, type)
	local tbMyInfo = RankBoard.tbMyRankInfo[self.szCurKey] or {} --如果是分门派的话对应下
	self.nCurSelfPos = tbMyInfo.nPosition
	if not tbMyInfo.nPosition or tbMyInfo.nPosition == 0 then
		self.pPanel:Label_SetText("OwnRankPos", "未上榜")
	else
		self.pPanel:Label_SetText("OwnRankPos", string.format("[ffff00][u]<%s>[/u][-]", tbMyInfo.nPosition) )
	end

	local fnSetMyRank = tbSetMyRank[MainKey] or tbSetMyRank["Default"]
	fnSetMyRank(self, tbMyInfo, type)

	--更新页数
	local nMaxNum = tbMyInfo.nLength or 0 ;--or RankBoard.tbSetting[self.szCurKey].MaxNum
	self.nMaxPage = math.max(math.ceil(nMaxNum / RankBoard.PAGE_NUM), 1)

	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nCurPage, self.nMaxPage))
end


function tbUi:OnSynRankData(szKey, nPage)
	if self.szCurKey ~= szKey or self.nCurPage ~= nPage then
		return
	end
	self:UpdateRank();
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnLeft()
	local nShowPage = math.max(self.nCurPage - 1, 1) ;
	self.nCurPage = nShowPage
	self:UpdateRank();
end

function tbUi.tbOnClick:BtnRight()
	local nShowPage = math.min(self.nCurPage + 1, self.nMaxPage) ;
	self.nCurPage = nShowPage
	self:UpdateRank();
end

function tbUi.tbOnClick:BtnRightUp()
	self.nCurPage = self.nMaxPage
	self:UpdateRank();
end

function tbUi.tbOnClick:BtnLeftUp()
	self.nCurPage = 1
	self:UpdateRank();
end

function tbUi.tbOnClick:OwnRankPos()
	local nCurSelfPos = self.nCurSelfPos
	if not nCurSelfPos or nCurSelfPos == 0 then
		return
	end

	local nMyPage = math.ceil(nCurSelfPos /  RankBoard.PAGE_NUM)
	self.nCurPage = nMyPage
	self:UpdateRank();
end


function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA,           self.OnSynRankData},
    };
end
