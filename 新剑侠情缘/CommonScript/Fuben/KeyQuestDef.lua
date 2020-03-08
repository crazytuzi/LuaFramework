Fuben.KeyQuestFuben = Fuben.KeyQuestFuben or {}
local KeyQuestFuben = Fuben.KeyQuestFuben

KeyQuestFuben.DEFINE = {
    SAVE_GROUP = 157;
    KEY_AWARD_SCORE = {1, 2};
    KEY_PLAY_SCORE = 5; --记录平均分
    KEY_PLAY_COUNT = 6; --记录平均场次

	NAME = "遗迹寻宝"; --活动名
	TIME_FRAME = "OpenKeyQuestFuben"; --时间轴
    JOIN_UI_TIME_DESC = "开启时间：周一和周三晚上19:50~19:55";--报名界面上的时间描述

    READY_MAP_ID = 8007; --准备场地图
    FIGHT_MAP_ID = {
        [1] = 8004; --战斗场地图1
        [2] = 8005; --战斗场地图2
        [3] = 8006; --战斗场地图3
    }; 
    REVIVE_TIME = { --重生时间，单位是秒
        [1] = 10;
        [2] = 20;
        [3] = 50;
    };
    HAVE_KEY_BUFF_ID = { --获取钥匙时是给的一个buffid,分别对应1、2层
        [1] = 5136;
        [2] = 5135;
    };
    HAVE_KEY_TITLE_ID = { --获取钥匙时是给的一个buffid,分别对应1、2层
        [1] = 6806;
        [2] = 6807;
    };
    KEY_DROP_NPC_ID = {
        [1] = 2954; --掉落在地上的钥匙npc，class 是FubenDialogEvent，参数1是开启时间，没填则无时间，2是开启时文字，3是开启后事件 OpenKey
        [2] = 2955;
    };
    KEY_ITEM_ID = { --钥匙道具id
        [1] = 8368; 
        [2] = 8370;
    };
    KEY_TEAM_SPRITE = { --钥匙的图标
        [1] = "DeliverySymbol2";
        [2] = "DeliverySymbol1";
    };

    DROP_KEY_NPC = { --会掉钥匙的怪
        [2958] = 1;
        [2960] = 1;
    };
    BOSS_DROP_SETTING = {
        [3217] = {
            {{ "item",8373,1 },{ "item",8375,1 }}; --排名对应队伍奖励
			{{ "item",8371,1 },{ "item",8372,1 },{ "item",8375,0.5 }}; 
			{{ "item",8372,1 },{ "item",8375,0.25 }}; 
        };
    };


    MAP_NOTIFY_POS_NPCID = {
        [3217]  = "地图中出现了[FFFE0D]偷吃猴王[-]，各位大侠可前往击杀<点击前往>";
    };

    -- SupplementAwardKey = "KeyQuestFuben"; --如果有奖励找回就去掉注释
    -- EverydayTargetKey = "KeyQuestFuben"; --如果有每日目标就去掉注释

    nProtectBuffId = 5137; --死亡保护buffid
    nProtectBuffTime = 40;--死亡保护buff时间
    nDeathProtectTotalTime = 60; --小于该死亡间隔时间总和就加buff
    nRecordDeathTimeCount = 3; --记录最近的几次死亡时间

    DEATH_DROP_KEY_RATE = 0.9; --死亡掉落钥匙概率
    
    SIGNUP_TIME = 60 * 5; --匹配时间

    MIN_LEVEL = 80;--最小参与等级
    MSG_NOTIFY_SIGNUP = "遗迹寻宝开启报名了，请各位侠士准备入场"; --开始报名时的走马灯
    CALENDAR_KEY = "KeyQuestFuben"; --日历key
    MIN_OPEN_NUM = 32; --最小开启人数
    OPENM_MATCH_GAP = { --划分场次时按照几场为一个战力段
        [1] = 4; 
        [2] = 3;
        [3] = 4;
    };
    OPENM_MATCH_NUM_FROM =  { --单场队伍范围 开启一层活动地图,每层单独配置
        [1] = { 6, 11 };  
        [2] = { 6, 11 };  
        [3] = { 4, 7};  
    }; 
    MAX_TEAM_ROLE_NUM = 4; --最大队伍内人数
    HELP_KEY = "KeyQuestFubenHelp"; --帮助key，准备场显示
    READY_MAP_POS = { --准备场随机点
        {7510, 5724};
        {6655, 4955};
		{6539, 6720};
		{3032, 6990};
		{2214, 5687};
    };

    FIGHT_MAP_RAND_POS = { --三层传入的随机点
    	[1]= {
		{12127, 2662};
		{10199, 2713};
		{7683, 3057};
		{5403, 2698};
		{3590, 3596};
		{4057, 6282};
		{5394, 6676};
		{7180, 6282};
		{9422, 5182};
		{9553, 11184};
		{9583, 9083};
		{6162, 9423};
		{2696, 11630};
		{4495, 10771};
		{5241, 12377};
    	};
    	[2]= {
		{8170, 2102};
		{3913, 2052};
		{834, 3494};
		{3151, 4051};
		{5626, 3424};
		{8233, 4203};
		{8917, 7862};
		{6355, 6990};
		{3523, 6442};
		{2103, 7675};
		{2596, 4995};
    	};
    	[3]= {
		{3453, 3314};
		{1305, 1936};
		{5992, 2039};
		{3533, 1603};
		{1335, 4747};
		{3495, 5212};
		{5839, 4765};
    	};
    };

    AWARD_MAIL_TXT = "您在本次遗迹寻宝活动中获得[FFFE0D]%d[-]白银积分和[FFFE0D]%d[-]黄金积分，系统已自动为您兑换为宝箱，不能兑换一个宝箱的[FFFE0D]剩余积分[-]将[FFFE0D]累积至下次一起兑换[-]，请注意查收附件奖励！";

    EXCEPT_OPEN_BOX_LIMIT_NPC_ID = {
        [2962] = 1;
    };
    GATHER_ITEM_MAX_COUNT = {   --每层采集数上限
        [1]  = 14;
        [2]  = 10;
        [3]  = 6;
    };
    DROP_AWARD_ITEM = { --能兑换积分的道具，对应2种不同积分  
        [8371] = {100, 0};
        [8372] = {200, 0};
		[8373] = {500, 0};
		[8374] = {1000, 0};
        [8375] = {0, 200};
		[8376] = {0, 500};
		[8377] = {0, 1000};
    };

    FLOOR_DEATH_DROP = { --不同层死亡时是否会掉率道具
        [1] = true;
		[2] = true;
	    [3] = true;
    };

    DEATH_DROP_NPC_ID = 2956; --死亡掉落物品的npc  class 是FubenDialogEvent，参数1是开启时间，没填则无时间，2是开启时文字，3是开启后事件 OpenDeathDropItem 
    DEATH_DROP_MSG = "您被神秘人击为重伤掉落了[FFFE0D]%s[-]"; --死亡时掉落道具的系统消息
    DROP_AWARD_ITEM_DEATH = {
        { nItemId = 8375, nDropRate = 0.1 }; --物品对应死亡掉落时概率
        { nItemId = 8376, nDropRate = 0.2 }; --物品对应死亡掉落时概率
		{ nItemId = 8377, nDropRate = 0.3 }; --物品对应死亡掉落时概率
    };

    MAX_RANDDOM_VALUE = 1000000;--随机值
    NPC_DROP_AUCTION_PARAM = { --开箱子或者最后一击杀怪拍卖掉落配置
        [2959] = {
                --等级段从低到高
                { 100, {
                    { nDropRate = 1500, tbAward = {{9313, 1, true ,true}}; };--nItemId, nCount, bSilver, bOneUp, bBonusSilver, bForbidStall
                    { nDropRate = 5000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 110, {
                    { nDropRate = 1500, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 6000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 120, {
                    { nDropRate = 2000, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 8000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 130, {
                    { nDropRate = 2000, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 10000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 140, {
                    { nDropRate = 1500, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 5000, tbAward = {{9321, 1, true ,true}}; };
                }},
                { 150, {
                    { nDropRate = 1500, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 6000, tbAward = {{9321, 1, true ,true}}; };
                }},
                { 170, {
                    { nDropRate = 300, tbAward = {{9315, 1, true ,true}}; };
                    { nDropRate = 1000, tbAward = {{9322, 1, true ,true}}; };
                    { nDropRate = 1200, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 4000, tbAward = {{9321, 1, true ,true}}; };
                }},
        };
        [2961] = {
                --等级段从低到高
                { 100, {
                    { nDropRate = 1500, tbAward = {{9313, 1, true ,true}}; };--nItemId, nCount, bSilver, bOneUp, bBonusSilver, bForbidStall
                    { nDropRate = 5000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 110, {
                    { nDropRate = 1500, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 6000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 120, {
                    { nDropRate = 2000, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 8000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 130, {
                    { nDropRate = 2000, tbAward = {{9313, 1, true ,true}}; };
                    { nDropRate = 10000, tbAward = {{9320, 1, true ,true}}; };
                }},
                { 140, {
                    { nDropRate = 1500, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 5000, tbAward = {{9321, 1, true ,true}}; };
                }},
                { 150, {
                    { nDropRate = 1500, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 6000, tbAward = {{9321, 1, true ,true}}; };
                }},
                { 170, {
                    { nDropRate = 300, tbAward = {{9315, 1, true ,true}}; };
                    { nDropRate = 1000, tbAward = {{9322, 1, true ,true}}; };
                    { nDropRate = 1200, tbAward = {{9314, 1, true ,true}}; };
                    { nDropRate = 4000, tbAward = {{9321, 1, true ,true}}; };
                }},
        };
    };

    EX_CHANGE_BOX_INFO = --不同积分兑换的宝箱
    {
        {8379, 500, "白银宝箱"}, --道具id，积分、描述
        {8380, 1000, "黄金宝箱"} , 
    },


};

function KeyQuestFuben:GetMapFloor( nMapTemplateId )
    if not self.tbFloorToMapId then
        self.tbFloorToMapId = {};
        for i,v in ipairs(self.DEFINE.FIGHT_MAP_ID) do
            self.tbFloorToMapId[v] = i
        end
    end
    return self.tbFloorToMapId[nMapTemplateId]
end


function KeyQuestFuben:CanSignUp( pPlayer )
	if MODULE_GAMESERVER then
        if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
            return false, string.format("「%s」当前状态不允许切换地图", pPlayer.szName) 
        end
    end

    if DegreeCtrl:GetDegree(pPlayer, "KeyQuestFuben") < 1 then
        return false, string.format("「%s」参与次数不足", pPlayer.szName) 
    end
    if pPlayer.nLevel < self.DEFINE.MIN_LEVEL then
        return false, string.format("所有队伍成员都达到%d级才可进入遗迹",self.DEFINE.MIN_LEVEL)
    end

    if Battle.LegalMap[pPlayer.nMapTemplateId] ~= 1 then
        if Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" or pPlayer.nFightMode ~= 0 then
            return false, string.format("「%s」当前所在地不能被传入准备场", pPlayer.szName) 
        end
    end
    return true
end

function KeyQuestFuben:GetAllCanShowItems()
    if not self.tbAllCanShowItemID then
        self.tbAllCanShowItemID = {}
        for i,v in ipairs(self.DEFINE.KEY_ITEM_ID) do
            self.tbAllCanShowItemID[v] = 1;
        end
        for k,v in pairs(self.DEFINE.DROP_AWARD_ITEM) do
           self.tbAllCanShowItemID[k] = 1; 
        end
    end
    return self.tbAllCanShowItemID
end