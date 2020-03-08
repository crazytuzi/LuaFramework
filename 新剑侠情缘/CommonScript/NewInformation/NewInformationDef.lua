NewInformation.nOperationTypeQianngGou =1
NewInformation.nOperationTypeJingji    =2
NewInformation.nOperationTypeHuoDong   =3
NewInformation.nOperationTypeGongGao   =4

NewInformation.tbActivity = {
    FactionBattle = {
        szTitle    = "门派竞技",
        -- szUiName   = "Normal", -- 指定的UI组件，默认用Key作为组件名字
    },
    FactionBattleCross = {
        szTitle    = "跨服门派竞技",
        szUiName = "FactionBattle",
    },
    OpenSrvActivity = {
        szTitle    = "百大家族",
        nReqLevel = 11,
    },
    FactionMonkey = {
        szTitle    = "门派竞选",
    },

    DomainBattle = {
        szTitle    = "攻城战结果",
        szUiName   = "TerritoryInfo",
    },

    LevelRankActivity = {
        szTitle    = "等级排名",
        szUiName   = "LevelRankActivity",
        nReqLevel = 10,
    },

     PowerRankActivity = {
        szTitle    = "战力排名",
        szUiName   = "PowerRankActivity",
        nReqLevel = 10,
    },

	NormalActiveUi = {
		szTitle = "活动",
		szUiName = "DragonBoatFestival",
		nReqLevel = 10,
	},

    HSLJEightRank = {
        szTitle = "华山论剑八强",
        szUiName = "HSLJEightRank",
        nReqLevel = 10,
    },

    HSLJChampionship = {
        szTitle = "华山论剑冠军",
        szUiName = "HSLJChampionship",
        nReqLevel = 10,
    },

    RandomFubenCollection = {
        szTitle    = "凌绝峰收集榜",
        szUiName   = "CardCollectionInfo",
    },

    DomainBattleAct =
    {
        szTitle    = "攻城战狂欢活动",
        szUiName   = "Normal",
    };

    DomainBattleAct2 =
    {
        szTitle    = "攻城战狂欢活动二",
        szUiName   = "Normal",
    };

    JXSH_Collection = {
        szTitle    = "锦绣山河收集榜",
        szUiName   = "JXSH_RankInfo",
    },
    NYLottery = 
    {
        szTitle    = "新年抽奖",
        nReqLevel = 40,
    },
    NYLotteryResult = 
    {
        szTitle    = "抽奖活动幸运名单",
        nReqLevel = 40,
    },
    AnniversaryBag = 
    {
        szTitle    = "周年庆超值礼包",
    },
    WLDHChampionship = 
    {
      szTitle    = "武林大会冠军",  
    },
    HonorMonthRank = {
        szTitle = "武林荣誉白金名侠",
        szUiName = "HonorMonthRank",
    },

    LotteryResult =
    {
        szTitle = "盟主的赠礼",
        szUiName = "LotteryResult",
    },
}
---------------在此的配置适用于数据较大的功能，会单独存储ScriptData，数据小的情况下不许配置---------------

function NewInformation:RegisterButtonCallBack(szType, tbCallBack)
    self.tbButtonCallBack = self.tbButtonCallBack or {};
    self.tbButtonCallBack[szType] = tbCallBack;
end

function NewInformation:UnRegisterButtonCallBack(szType)
    self.tbButtonCallBack = self.tbButtonCallBack or {};
    self.tbButtonCallBack[szType] = nil;
end

function NewInformation:OnButtonEvent(szType)
    local tbCallBack = self.tbButtonCallBack[szType];
    if not tbCallBack or not tbCallBack[1] then
        return;
    end

    Lib:CallBack(tbCallBack);
end