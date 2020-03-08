  local tbUi = Ui:CreateClass("AnniversaryPanel");

tbUi.tbActSetting = {
	{
		szName = "签到领奖";
		szActName = "NewYearLoginAct";
		szStartTime = "2019/1/30 3:59:59";
		szEndTime = "2019/2/14 3:59:59"; 
		fnOnClick = function (self)
			local nStartTime = Lib:ParseDateTime(self.szStartTime)
			local nEndTime   = Lib:ParseDateTime(self.szEndTime)
			if GetTime() < nStartTime then
				local szMsg = string.format("活动尚未开始，下次开放时间为%s", Lib:TimeDesc11(nStartTime))
				me.CenterMsg(szMsg)
			elseif GetTime() > nEndTime then
				me.CenterMsg("活动已结束")
			else
				Ui:OpenWindow("LoginAwardsPanel", true)
			end
		end;
	};	
	{
		szName = "新年抽奖";
		szStartTime = "2019/1/30 3:59:59";
		szEndTime = "2019/2/19 23:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]新年抽奖活动开始了！[-]
				活动期间[FFFE0D]2月3日[-]、[FFFE0D]2月6日[-]、[FFFE0D]2月9日[-]的[FFFE0D]22:00[-]均会在本服抽出相应数量的幸运玩家发放丰厚奖励！诸位大侠使用[aa62fc][url=openwnd:新年奖券, ItemTips, "Item", nil, 3689][-]后就可以参与即将开始的下一次抽奖。
				此外，在[FFFE0D]2月19日[-]元宵节当晚[FFFE0D]22:00[-]还会在之前使用过奖券的玩家中抽取相应数量的豪华大奖！
				注：具体奖品内容详见最新消息。
				]];
				})	
		end;

	};
	{
		szName = "舞龙舞狮";
		szStartTime = "2019/1/28 3:59:59";
		szEndTime = "2019/2/7 23:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]新年舞龙舞狮活动开始了！[-]
				[FFFE0D]舞龙道具售卖时间：[-]2019年1月28日-2019年2月7日
				始看鱼跃方成海，即睹飞龙利在天。值此新春佳节，特开启舞龙迎春活动，商城限时特惠出售舞龙天工宝物，诸位大侠可以召集伙伴共同接龙。
				接龙成功将有特殊效果显示，若飞龙乘云，多人接龙会有相应奖励，若同家族的侠士在族长、领袖带领下组成一定人数的长龙，族长、领袖还会有特殊奖励：
				5人接龙：每人获得贡献*2000
				10人接龙：每人获得贡献*4000
				20人接龙：每人获得贡献*6000，领袖、族长获得家族红包、[ff578c][url=openwnd:称号·画龙点睛, ItemTips, "Item", nil, 10304]*1[-]
				30人接龙：每人获得贡献*8000，领袖、族长获得家族红包
				50人接龙：每人获得贡献*10000，领袖、族长获得家族红包、[ff8f06][url=openwnd:称号·飞龙乘云, ItemTips, "Item", nil, 10305]*1[-]
				70人接龙：每人获得贡献*20000，领袖、族长获得家族红包
				100人接龙：每人获得贡献*30000，领袖、族长获得家族红包、[e6d012][url=openwnd:称号·龙行天下, ItemTips, "Item", nil, 10306]*1[-]
				注：[FFFE0D]每个玩家每档奖励只能拿一次，每个家族每档红包也只能触发一次。
					领袖、族长获得家族红包必须是领袖、族长参与接龙且接龙成员全部为本家族成员才会触发相应领袖、族长奖励。
					本次舞龙道具为限时出售，限购结束后无法购买，但接龙奖励依然有效。[-]
				]];
				szBtnName = "前往";
				fnOnClick = function ()
					if (bStartAct == false) then
						Ui:OpenWindow("CommonShop","Treasure");
					else
						Ui:OpenWindow("CommonShop","Treasure","tabActShop");
					end;
				end;
				})
		end;
	};
	{
		szName = "风味年夜饭";
		szStartTime = "2019/1/30 3:59:59";
		szEndTime = "2019/2/4 23:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]风味家族年夜饭活动开始了！[-]
				[FFFE0D]活动时间：[-]2019年1月30日-2019年2月4日
				活动开始时，[FFFE0D]族长[-]会收到一个[11adf6][url=openwnd:酒馆之邀（年夜饭）, ItemTips, "Item", nil, 10282][-]。所有大侠都会收到一个[11adf6][url=openwnd:年夜饭邀请函, ItemTips, "Item", nil, 10283][-]。
				持有[11adf6][url=openwnd:酒馆之邀（年夜饭）, ItemTips, "Item", nil, 10282][-]的大侠可以在活动期间任意一天晚上[FFFE0D]18：00-24：00[-]期间前往[FFFE0D]临安忘忧酒馆老板娘[-]处开启年夜饭。
				开启后本家族所有成员均可进入忘忧酒馆享用丰盛的年夜饭，猜红包送祝福，赏烟花捡宝箱。详情可在活动副本中查看。
				注：
				[FFFE0D]每个家族只能开启一次年夜饭[-],请选择合适的时间召集大家开启年夜饭。
				[11adf6][url=openwnd:年夜饭邀请函, ItemTips, "Item", nil, 10283][-]将在参加一次年夜饭后扣除,无邀请函的玩家无法享用年夜饭菜品和拾取宝箱，即每位大侠[FFFE0D]只有一次[-]获取年夜饭奖励的机会。
				]];
				})

		end;
	};
	{
		szName = "锦盒赠送";
		szStartTime = "2019/1/28 3:59:59";
		szEndTime = "2019/2/11 3:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]锦盒赠送活动开始了！[-]
				[FFFE0D]活动时间：[-]2019年1月28日-2019年2月10日
				[FFFE0D]参与等级：[-]50级
				[FFFE0D]获得锦盒 随机品质[-]
				活动期间每天活跃度达到[FFFE0D]80、100[-]以及领取[FFFE0D]6元礼包[-]时均会从[FFFE0D]3种[-]品质的锦盒中随机获得一种，大侠在进行[FFFE0D]元宝协助养护[-]时有概率会获得[ff578c][url=openwnd:神奇的法杖, ItemTips, "Item", nil, 10292][-]，使用可将背包中最低品质的锦盒重新随机品质。
				[FFFE0D]送礼上门 填写寄语[-]
				大侠需于[FFFE0D]24小时[-]内在好友的家园中使用锦盒并填写[FFFE0D]寄语[-]，填写完毕之后即将锦盒摆放在好友的家园中，一个家园最多同时摆放[FFFE0D]10个[-]锦盒，锦盒可在家园中存在[FFFE0D]3天[-]，及时通知好友领取锦盒吧！
				[FFFE0D]猜对好友 收取礼物[-]
				大侠可在自己家园中收取好友赠送的锦盒，点击之后需要先猜一下当前锦盒是谁赠送的，猜完之后方能领取锦盒中的礼物，锦盒的品质越高，其中包含的奖励越好！每人每天最多开启[FFFE0D]3个[-]锦盒。
				如果大侠猜对了赠送人，那赠收双方均可以获得一份奖励！且锦盒的品质越高，双方获得的奖励会越好！
				]];
				})
		end;
	};
	{
		szName = "驱逐年兽";
		szStartTime = "2019/2/1 3:59:59";
		szEndTime = "2019/2/10 23:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]新年对春联、驱年兽活动开始了！[-]
				[FFFE0D]活动时间：[-]2019年2月1日~2019年2月10日
				[FFFE0D]参与等级：[-]20级
				年兽又称年，是古代汉族神话传说中的恶兽。相传古时候每到年末的午夜，年兽就会进攻村庄，大肆破坏。后来人们发现年兽惧怕红色及放鞭炮，故以此驱赶年兽的进攻。为了防止年兽的再次骚扰，放爆竹、贴春联渐渐成为节日习俗，春节由此成为中华民族的象征之一，潜移默化地沿袭至今以及影响世界各地。
				1、对春联
				活动期间，家族烤火开始后30秒会在[FFFE0D]家族属地[-]中装点大量的[FFFE0D]大红灯笼[-]，每个灯笼里面都藏着一副对联，成功对出对联的大侠可以获得[aa62fc][url=openwnd:烟花爆竹, ItemTips, "Item", nil, 3688][-]。每次烤火期间刷新[FFFE0D]2次[-]灯笼。
				[FFFE0D]小窍门[-]：春联中上下联的相同位置的字是不能重复的哦！
				2、驱年兽
				家族烤火期间[FFFE0D]家族属地[-]会出现捣乱的[FFFE0D]年兽[-]，其有上古戾气护体，传言只能通过燃放[FFFE0D]烟花爆竹[-]对其造成有效伤害并获得积分，请大家在其出现后齐心协力将其赶跑。
				年兽被赶跑时，会在附近出现宝箱，但每人每天最多可以采集[FFFE0D]15个[-]宝箱。
				活动结束后，年兽掉落的宝物会在家族中进行拍卖，家族总积分越高，年兽掉落的宝物也会越多，参与驱逐年兽活动并获得积分的玩家可以获得[FFFE0D]拍卖分红[-]。
				活动结束时当天本家族获得积分最高的玩家会获得限时橙色称号[FFFE0D]年兽终结者[-]！
				年兽活动期间，家族答题将暂停，同时烤火经验在家族属地[FFFE0D]全地图[-]均可获得。
				]];
				})
		end;
	};
	{
		szName = "热点活动";
		szStartTime = "2019/2/5 3:59:59";
		szEndTime = "2019/2/12 3:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]活动奖励翻倍开始了！[-]
				[FFFE0D]活动时间：[-]2019年2月5日-2019年2月11日
				从大年初一到大年初七，每天均有一个活动奖励翻倍，各位少侠不容错过！

				大年初一：武林盟主，拍卖物品的产出将提升50%
				大年初二：普通通天塔，最后获得的通天荣誉将提升100%
				大年初三：白虎堂，击杀怪物获得的奖励将为双倍
				大年初四：战场，您当天的第一场战场荣誉将提升100%
				大年初五、初六：单人心魔绝地，根据您的最好成绩给予高额奖励（元气、银两、和氏璧与[11adf6][url=openwnd:小金猪, ItemTips, "Item", nil, 10288][-]），详情请查看[FFFE0D]单人心魔绝地[-]的最新消息
				大年初七：门派竞技，最终奖励将为双倍
				]];
				})

		end;
	};
	{
		szName = "商城限购";
		szStartTime = "2019/1/28 04:00:00";
		szEndTime = "2019/2/7 23:59:59"; 
		fnOnClick = function (self)
			local bStartAct = tbUi:IsActStart(self.szStartTime);
			Ui:OpenWindow("AnniversaryTipPanel",{
				szText = [[
				[FFFE0D]热门商品打折出售！[-]
				[FFFE0D]活动时间：[-]1月28日-2月7日
				活动期间内商城大量热卖商品低价出售，还等什么，快快抢购吧！
				]];
				szBtnName = "前往";
				fnOnClick = function ()
					if (bStartAct == false) then
						Ui:OpenWindow("CommonShop","Treasure");
					else
						Ui:OpenWindow("CommonShop","Treasure","tabActShop");
					end;
				end;
				})	
		end;
	};
};

function tbUi:OnOpen( ... )
	self:Update()
end

function tbUi:Update()
	local nNow = GetTime()
	for i,v in ipairs(self.tbActSetting) do
		local bEndAct = self:IsActEnd(v)
		self.pPanel:SetActive("Ending" .. i, bEndAct)
		self.pPanel:Sprite_SetGray("Btn" .. i, bEndAct)
		self.pPanel:Label_SetText("Txt"..i, v.szName);
		if v.szCalendarKey then
			if Calendar:IsActivityInOpenState(Activity.DanceMatch.tbSetting.szCalendarKey) then
				self.pPanel:SetActive("Being" .. i, true)
			else
				self.pPanel:SetActive("Being" .. i, false)
			end
		end
	end
end

function tbUi:IsActEnd(v)
	local bEndAct = false;
	if v.szEndTime then
		local nEndTime = Lib:ParseDateTime(v.szEndTime)
		if GetTime() > nEndTime  then
			bEndAct = true
		end
	else
		if not Activity:__IsActInProcessByType(v.szActName) then
			bEndAct = true	
		end
	end
	return bEndAct
end

function tbUi:IsActStart(szStartTime)
	local bStartAct = false;
	if szStartTime then
		local nStartTime = Lib:ParseDateTime(szStartTime)
		if GetTime() > nStartTime then
			bStartAct = true;
		end
	end
	return bStartAct;
end

function tbUi:OnClickButton(i)
	local v = self.tbActSetting[i]
	if self:IsActEnd(v) then
		return
	end
	local fnOnClick = v.fnOnClick
	if fnOnClick then
		fnOnClick(self.tbActSetting[i]);
	end

end

tbUi.tbOnClick  = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

for i=1,8 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		self:OnClickButton(i)
	end
end

function tbUi.tbOnClick:TencentVideos()
	local szUrl = "tenvideo2://?action=65&from=30168&openurl=https%3A%2F%2Fiwan.qq.com%2Fcommunity%2Fhotgames%3Fhidetitlebar%3D1%26business%3Dgame%26openapp%3D1%26reportParams%3Diwan_out_rpk%26ADTAG%3Dtxsp.yxhz.yxnzr%26jump%3Dhttps%253A%252F%252Fiwan.qq.com%252Factivity%252F0wiDc157.html%253Fid%253D0wiDc157%2526actpayid%253D200000103%2526actadid%253D2000001030wiDc157"
	if IOS then
		local szModelName = GetAppleModelName()
		if string.find(szModelName, "iPad") then
			szUrl = " tenvideo2://?action=10&from=30168&openurl=https%3A%2F%2Fiwan.qq.com%2Factivity%2F0wiDc157.html%3Fid%3D0wiDc157%26actpayid%3D200000103%26actadid%3D2000001030wiDc157"
		end
	end
	local nTimeStart = GetTime()
	Sdk:OpenUrl(szUrl)
	Timer:Register(3, function() 
						if GetTime() - nTimeStart <= 1 then
							Sdk:OpenUrl("https://iwan.qq.com/act/xjxqygame/index.html?ADTAG=yx.xjxqy.sprk")
						end
					end)
end