local rules = class( "rules", layout );

global_event.RULE_SHOW = "RULE_SHOW";
global_event.RULE_HIDE = "RULE_HIDE";

function rules:ctor( id )
	rules.super.ctor( self, id );
	self:addEvent({ name = global_event.RULE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.RULE_HIDE, eventHandler = self.onHide});
	self.allPreView = {}
end

function rules:onShow(event)
	if self._show then
		return;
	end
	
	self.data = {}
	self.battleType = event.battleType
	if(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED)then
		self.data.RankText = "你当前的排名是:"
		
		if dataManager.playerData:isSpeedChallegeSuccess() then
			self.data.Rank  = dataManager.speedChallegeRankData:getMyRank();
		else
			self.data.Rank = "未上榜"
		end
		self.data.rewardText = "可获得奖励:"
		self.data.Reward  = dataManager.speedChallegeRankData:getRankReward();
		self.data.HistroyScoreText = ""
		self.data.HistroyScore  =""
		self.data.rulesText = "规则说明：\n1.   极速挑战的开启时间是每天的凌晨5:00到24:00\n2.  玩家每天可以进行1轮极速挑战。极速挑战共有8关，每     关通过后都会获得奖励\n3.  全部8关打通后按照8关总行动次数进行排名，使用行动     数越少，排名越高\n4.  每天会随机出现4个超级魔法，超级魔法可以大大减少       总行动次数，但是每个超级魔法每轮挑战只能使用1次\n5.  必须打通前一关才可以挑战下一关，已经打通的关卡不     可以再次挑战\n6.  玩家共有2次挑战失败的机会，当失败次数达到3次时将     无法继续挑战。挑战失败不会增加总行动次数\n7.  挑战进度和失败次数在每天凌晨5点重置\n8.  关卡中的军团数量和装备会随着玩家的等级成长\n9.  系统在每天的24:00按照玩家在伤害排名榜上的排名发       放邮件奖励，排名越高奖励越好"
		self.data.ruleSimpleText = "根据每天结算时间的排名发放奖励"
		self.data.RewardAll  =  global.getSpeedChallengeRewardList()

	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE)then
	
		self.data.RankText = ""
		self.data.Rank  = ""
		self.data.rewardText = ""
		self.data.Reward  = {}
		self.data.HistroyScoreText = ""
		self.data.HistroyScore  =""
		self.data.rulesText = "规则说明：\n1.   远征活动于开服第三日开启，国王等级达到25以上的        玩家均可参与本活动\n2.  远征活动全天开放，玩家每日可进行1轮包含8个关卡的     征战，每个关卡通关后将给予奖励\n3.  奖励分为通关奖励和额外奖励，通关奖励只需通过关卡     即可获得。额外奖励需要通关时军团总血量大于等于60     %才能获得\n4.  每日已通关的关卡不可重复挑战，挑战失败的关卡可继     续不限次挑战\n5.  挑战进度和关卡阵容在次日凌晨5点重置"
		self.data.ruleSimpleText = "根据在活动中使用的总回合数发放奖励"
		self.data.RewardAll  =  {};
			
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL)then
	
		self.data.RankText = ""
		self.data.Rank  = ""
		self.data.rewardText = ""
		self.data.Reward  = {}
		self.data.HistroyScoreText = ""
		self.data.HistroyScore  = ""
		self.data.rulesText = "规则说明：\n副本挑战规则：\n1.  玩家每天可完成若干次副本挑战（次数随VIP等级提升     ），挑战失败不会扣除挑战次数\n2.  每天凌晨5点重置挑战次数\n3.  等级越高开放的副本越多\n4.  必须打通前一个副本才可以开启下一个副本\n5.  已经打通的副本可以再次挑战\n6.  玩家可以任意选择适合自己的副本难度，难度越高奖励     越好\n7.  针对性的更换军团和调整位置更容易挑战成功"
		self.data.ruleSimpleText = ""
		self.data.RewardAll  =  {}
	
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
		self.data.RankText = "你当前的排名是:"
		self.data.Rank  = dataManager.hurtRankData:getRanking()
		self.data.rewardText = "可获得奖励:"
		self.data.Reward  = dataManager.hurtRankData:getRankReward()
		self.data.HistroyScoreText = "你的本日最好成绩:"
		self.data.HistroyScore  = dataManager.hurtRankData:getHistroyScore()
		self.data.rulesText = "规则说明：\n伤害排行榜规则：\n1.   伤害排行榜的开启时间是每天的凌晨5:00到23:00\n2.  BOSS每天都会更换，所有BOSS在活动中循环出现\n3.  伤害排行榜按照所有玩家每天的最高伤害进行排名\n4.  每个玩家每天有3次挑战BOSS的机会\n5.  每个BOSS都有各自的特色技能，针对性的调整阵容和        军团位置可以进一步提高伤害\n6.  玩家可以观看排行榜前50名玩家的挑战录像\n7.  系统在每天的23:00按照玩家在伤害排名榜上的排名发       放邮件奖励。排名越高奖励越好\n8.  伤害排行榜和每个玩家的挑战次数在每天凌晨5点重置"
		self.data.ruleSimpleText = "根据每天结算时间的排名发放奖励"
		self.data.RewardAll  = dataManager.hurtRankData:getRewardList()

	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR)then
	
		self.data.RankText = ""
		self.data.Rank  = ""
		self.data.rewardText = ""
		self.data.Reward  = {}
		self.data.HistroyScoreText = ""
		self.data.HistroyScore  = ""
		self.data.rulesText = "开启条件：开服第四日开启\n\n开启时间：每日10:00~13:00\n\n玩法简述：\n公会战开始时，各公会将进入各自独立的公会战副本。公会玩家可在有限次数内，对某个战区内的守军进行挑战。首个以最快速度完全击败某个战区中所有守军的公会，将获得该战区所有权。在公会战中被占领的战区，将进入休战状态，其他公会无法继续挑战。非公会战时段内，公会会长和官员将可以进入自己的战区布置守军，为下一次公会战开启做准备。\n\n积分计算：\n 1.公会积分：公会成员挑战守军，将根据胜负情况给予不同数量的公会积分，积分数量与战区品质有关。成功占领战区或成功防守战区将获得额外公会积分。\n 2.个人积分：公会成员挑战守军，将根据胜负情况给予不同数量的个人积分，个人积分将影响当日公会战积分排名奖励的加成系数。\n\n奖励：\n 1.战区击破奖励：公会占领某一战区的公会，公会全体成员将根据公会身份不同通过邮件形式收到不同数量的战区击破奖励。\n 2.公会积分奖励：每日将根据公会战积分计算公会排名，并根据公会排名以邮件方式向公会成员发放奖励，最终获得数量与当日个人积分和公会身份相关。\n\n公会战Q&A：\n^FF0000怎么进入公会战？^FFFFFF\n点击公会界面上的公会战传送门，即可进入公会战界面。\n^FF0000进入公会战会长应该做什么？^FFFFFF\n公会战开始后，建议各会长根据自身公会实力和目前各战区情况，选择最适合本公会攻打的战区，并组织会员对该战区进行集中进攻，争取攻下该战区。\n^FF0000进入公会战会员应该做什么？^FFFFFF\n公会战开始后，建议会员听从会长安排，挑战目标战区内的守军，争取胜利。\n^FF0000我和另外一个公会都在攻打同一个战区，会有影响吗？^FFFFFF\n攻打过程中没有任何影响，只当任何一个公会率先攻下战区后，其他公会将无法继续挑战该战区，比拼的是速度。\n^FF0000有什么帮助胜利的妙计吗？^FFFFFF\n注意针对对手阵型布阵，挑战水平相当的对手。进攻的玩家可以通过“王者祝福”增强自身实力。防守战区公会成员可以针对单独战区进行“集结呐喊”，增强守军实力。\n^FF0000什么样的公会成员可以成为守军？^FFFFFF\n加入公会超过24小时，并且48小时之内有上线记录的公会成员都可以作为战区守军加入守军列表。\n\n公会积分排名奖励："
		self.data.ruleSimpleText = ""
		self.data.RewardAll  = dataManager.guildWarData:getRewardInfo();
			 
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE)then
		self.data.RankText = "你当前胜场数:"
		self.data.Rank  =   dataManager.pvpData:getOnlineWinNum()
		self.data.rewardText = "可获得奖励:"
		self.data.Reward  = dataManager.pvpData:getReward()
		self.data.HistroyScoreText = ""
		self.data.HistroyScore  = ""
		self.data.rulesText = "规则说明：\n竞技场规则：\n1.竞技场开启时间为中午12:00-13:00,晚上21:00-22:00。\n2.玩家在两个时间段内参加的是同一轮比赛，5胜或者3负则一轮比赛结束。\n3.一轮比赛结束时，会根据胜场数自动发放奖励。\n4.点击开始按钮后系统自动匹配净胜场数相近的对手。\n5.竞技场比赛中不能使用加速功能。双方随机1方做为进攻方，先手行动。\n6.在国王魔法回合需要轮流等待对手施放国王魔法。\n7.如果超过30秒没有施放国王魔法，则会自动施放1个魔法。\n8.若战斗超过200次行动还没有结束，则算作进攻方失败。\n9.即使没能完成1轮比赛，只要进行过至少1场竞技场战斗，会在凌晨4点通过邮件收到相应的奖励。 "
		self.data.ruleSimpleText = "根据每轮比赛最终的胜场数发放奖励"
	
		self.data.RewardAll  =  dataManager.pvpData:getRewardList()
	end
	
	self:Show();

	self.pvprule_scroll = LORD.toScrollPane(self:Child( "pvprule-scroll" ));
	self.pvprule_close = self:Child( "pvprule-close" );
	self.pvprule_scroll:init();
	
	function onClickClosepvprule()
		self:onHide()		
	end
		
	self.pvprule_close:subscribeEvent("ButtonClick", "onClickClosepvprule")	 
	self:upDate();
end

function rules:onUpDate(event)
	self:upDate();
end

function rules:upDate()
	 if not self._show then
		return;
	end
	
	
	if not self._show then
		return;
	end
	self.pvprule_scroll:ClearAllItem() 
	
	
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 0)
	
	function onTouchDownPvpruleRank(args)	
		local clickImage = LORD.toWindowEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			v:SetProperty("ImageName",  "set:common.xml image:ditu10")
		end	
		clickImage:SetProperty("ImageName",  "")
		if(userdata ~= -1)then
	 		self.selectPlayer = userdata
		end				
 	end	 
	function onTouchUpPvpruleRank(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata ~= -1)then				
		end
 	end	 		
	function onTouchReleasePvpruleRank(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata == -1)then
			return
		end
		 
		
 	end	 	
	 

	for k,v in pairs (self.allPreView) do
		self.allPreView[k].record:removeEvent("ButtonClick");		
	end		
	self.allPreView = {}
	self.tempUi  = {}
	
	
	local  info1 = LORD.toLayout(LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("rules_", "ruledetail.dlg"))
	
	local  ruledetail_top =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-top"))
	
	local  ruledetail_text1 =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1"))
	local  ruledetail_text2_reward =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text2-reward"))
	local  ruledetail_text2 = (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text2"));
	
	local  rewardText =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-reward"))
	local  warning = (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-warning"))
	
	
	local  info1RankText =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-rank-now"))
    local  info1Rank =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-rank-now-num"))
	local  info1gem =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_pvpruletext1-reward1-num"))	
	
	
	local  info1HistroyRankText =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-rank-now_2"))
	local  info1HistroyRank =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-rank-now-num_2"))
	
	
	local  ruledetail_text2_text =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text2-text"))
	
	local  ruledetail_text2_reward_text =   (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text2-reward-text"))
	
	
	
	
	info1RankText:SetText(self.data.RankText )
	info1HistroyRankText:SetText(self.data.HistroyScoreText )
	rewardText:SetText(self.data.rewardText )
	 
	ruledetail_text2_text:SetText(self.data.rulesText)
	ruledetail_text2_reward_text:SetText(self.data.ruleSimpleText)
	

		
	 
	info1Rank:SetText(self.data.Rank)
	info1HistroyRank:SetText(self.data.HistroyScore)
	 
	
	local rewars = {}
	for i = 1, 4 do
			rewars[i] = {}
			rewars[i].icon =  LORD.toStaticImage( (LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-reward"..i)))
			rewars[i].num = LORD.GUIWindowManager:Instance():GetGUIWindow("rules_".."_ruledetail-text1-reward"..i.."-num")
			rewars[i].num:SetText(0)		 
	end
 
	local t = 	self.data.Reward
	local tsize = table.nums(t)
	
	for i = 1, 4 do
		if(t[i])then
		    rewars[i].icon:SetVisible(tsize ~= 0);
			warning:SetVisible(tsize == 0);
			rewars[i].icon:SetProperty("ImageName",  t[i].icon)
			rewars[i].num:SetText(t[i].count)
			rewars[i].icon:SetVisible(true);
		else
			rewars[i].num:SetText("0")	
			if(tsize ~= 0 )then
				rewars[i].icon:SetVisible(false);	
				rewars[i].num:SetText("")
			end
		end	
	end	
	--[[
	local  info2 = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprule2_", "pvpruletext2.dlg");
	info2:SetPosition(LORD.UVector2(xpos, ypos));		
	self.pvprule_scroll:additem(info2);
	xpos = LORD.UDim(0, 10)
	ypos = ypos + info2:GetHeight() + LORD.UDim(0, 5)	
	]]--
	
	
	
	
	if(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED)then
	
		--info1:RemoveChildWindow(ruledetail_text1)
		--engine.windowManager:DestroyGUIWindow(ruledetail_text1)

		info1HistroyRank:SetText("")
		info1HistroyRankText:SetText("奖励将自动发送到你的邮箱")
	
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR)then

		info1:RemoveChildWindow(ruledetail_text1)
		info1:RemoveChildWindow(ruledetail_text2_reward)

		engine.windowManager:DestroyGUIWindow(ruledetail_text1)
		engine.windowManager:DestroyGUIWindow(ruledetail_text2_reward)
								
		info1HistroyRank:SetText("")
		info1HistroyRankText:SetText("奖励将自动发送到你的邮箱")
		
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL)then

		info1:RemoveChildWindow(ruledetail_text1)
		info1:RemoveChildWindow(ruledetail_text2_reward)
		
		engine.windowManager:DestroyGUIWindow(ruledetail_text1)
		engine.windowManager:DestroyGUIWindow(ruledetail_text2_reward)
		
 	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE)then
 		
 		engine.windowManager:DestroyGUIWindow(ruledetail_text1)
		engine.windowManager:DestroyGUIWindow(ruledetail_text2)
		
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
		info1HistroyRank:SetText("")
		info1HistroyRankText:SetText("奖励将自动发送到你的邮箱")
	elseif(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE)then
		info1HistroyRank:SetText("")
		info1HistroyRankText:SetText("奖励将自动发送到你的邮箱")
	end	
	
	info1:SetPosition(LORD.UVector2(xpos, ypos));		
	info1:LayoutChild()
	self.pvprule_scroll:additem(info1);
	xpos = LORD.UDim(0, 150)
	ypos = ypos + info1:GetHeight() + LORD.UDim(0, 5)	
	
	
	local preRankLevel = nil
	--self.data.RewardAll = {}
	for i,v in ipairs (self.data.RewardAll) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if v then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprule3_"..i, "pvpruletext3.dlg");
			self.tempUi[i].rank = LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward")
			self.tempUi[i].gem =   LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward1-num"))
			self.tempUi[i].prew :SetPosition(LORD.UVector2(xpos, ypos));								
			self.pvprule_scroll:additem(self.tempUi[i].prew);
			
			xpos = LORD.UDim(0, 150)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		 	self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownPvpruleRank")
	 		self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpPvpruleRank")
	 		self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleasePvpruleRank")
	 		self.tempUi[i].prew:SetUserData(i)

			if(preRankLevel)then
				if(v.rank - preRankLevel == 1)then
					self.tempUi[i].rank:SetText("第"..v.rank.."名")		
				else
					self.tempUi[i].rank:SetText("第"..(preRankLevel+1)  .."-"..v.rank.."名")	
				end	
			else
				self.tempUi[i].rank:SetText("第"..v.rank.."名")	
			end
			
			if(self.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE)then
					self.tempUi[i].rank:SetText("胜"..v.rank.."场")		
			end
			preRankLevel = v.rank
 
			table.insert(self.allPreView,self.tempUi[i].prew)
			if(i == self.selectPlayer)then
				self.tempUi[i].prew:SetProperty("ImageName",  "")
			else
				self.tempUi[i].prew:SetProperty("ImageName",  "set:common.xml image:ditu10")	
			end	
	 
			
			self.tempUi[i].rewars = {}
			for j = 1, 4 do
					self.tempUi[i].rewars[j] = {}
					self.tempUi[i].rewars[j].icon =  LORD.toStaticImage( (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward"..j)))	
					self.tempUi[i].rewars[j].num = (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward"..j.."-num"))
					self.tempUi[i].rewars[j].num:SetText(0)		 
			end
																			
			local t = v	
			for j = 1, 4 do
				if(t[j])then
					self.tempUi[i].rewars[j].icon:SetProperty("ImageName",  t[j].icon)
					self.tempUi[i].rewars[j].num:SetText(t[j].count)
					self.tempUi[i].rewars[j].icon:SetVisible(true);	
				else
					self.tempUi[i].rewars[j].icon:SetVisible(false);	
					self.tempUi[i].rewars[j].num:SetText("")
				end	
			end	
			
			
	 
	 	end		
	end		

	
 
end

function rules:onHide(event)
	self:Close()
	self.allPreView = {}
end

return rules;
