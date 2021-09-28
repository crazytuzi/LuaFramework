--------------------------------------------------------------------------------------
-- 文件名:	WJQ_TipsConfig.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	王家麒
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	Tips
-- 应  用:  
---------------------------------------------------------------------------------------

--注册Tip显示事件
--注册Tip显示事件

--世界Boss排序好的奖励
local function sortGuildWorldBosssReward(tbItemA, tbItemB)
	return tbItemA.Rank < tbItemB.Rank
end

local function getGuildWorldBosssRewardCsv()	
	if not g_TableGuildWorldBosssRewardInSort then
		g_TableGuildWorldBosssRewardInSort = {}
		for k, v in pairs (ConfigMgr.GuildWorldBosssReward) do
			table.insert(g_TableGuildWorldBosssRewardInSort, v)
		end
		table.sort(g_TableGuildWorldBosssRewardInSort, sortGuildWorldBosssReward)
	end
	
	return g_TableGuildWorldBosssRewardInSort
end

local function sortActivityWorldBossReward(tbItemA, tbItemB)
	return tbItemA.Rank < tbItemB.Rank
end

local function getGuildDragonPrayRewardCsv()	
	if not g_TableGuildDragonPrayRewardInSort then
		g_TableGuildDragonPrayRewardInSort = {}
		for k, v in pairs (ConfigMgr.GuildDragonPrayReward) do
			table.insert(g_TableGuildDragonPrayRewardInSort, v)
		end
		table.sort(g_TableGuildDragonPrayRewardInSort, sortActivityWorldBossReward)
	end
	
	return g_TableGuildDragonPrayRewardInSort
end

local function getDragonPrayTip(nTag)
	local nSkillRewardIncrease = g_DragonPray:getSkillRewardIncrease()
	local CSV_ActivityDragonPraySkill = g_DataMgr:getCsvConfigByOneKey("ActivityDragonPraySkill", nTag)
	local tbString = {}
	table.insert(tbString, {Enum_DragonPraySkill[nTag]})
	for nShaiZiNum = 3, 7 do
		local CSV_ActivityDragonPraySkillSub = CSV_ActivityDragonPraySkill[nShaiZiNum]
		local nRewardValue = math.floor(CSV_ActivityDragonPraySkillSub.Coins * nSkillRewardIncrease/10000)
		local nIncreasePercent = (nSkillRewardIncrease-10000)/100
		local strTip = _T("第一次摇出")..nShaiZiNum.._T("个")..Enum_DragonPrayShaiZi[nTag].._T("可获得")..nRewardValue.."(+"..nIncreasePercent.._T("%d)铜钱作为奖励")
		table.insert(tbString, {strTip, ccc3(0,255,0)})
	end
	local nSkillRewardIncreaseNext = g_DragonPray:getSkillRewardIncreaseNext()
	if nSkillRewardIncreaseNext == 0 then
		table.insert(tbString, {_T("当前神龙等级已满级"), ccc3(255,255,0)})
	else
		local nIncreasePercentNext = (nSkillRewardIncreaseNext-10000)/100
		table.insert(tbString, {_T("下一神龙等级铜钱奖励倍数为")..nIncreasePercentNext.."%", ccc3(255,255,0)})
	end
	
	return tbString
end

function g_OnCloseTip(pSender, nTag)
	g_ClientMsgTips:closeTip()
end

function g_RegisterGuideTipButton(Button_Guide, strClickCountKey, fScale, nTag)
	local fScale = fScale or 0.9
	Button_Guide:removeAllNodes()
	if not strClickCountKey then
		local armature, userAnimation = g_CreateCoCosAnimation("ExclamationMark", nil, 6)
		armature:setScale(fScale)
		Button_Guide:addNode(armature)
		userAnimation:playWithIndex(1)
		g_SetBtnWithPressingEvent(Button_Guide, nTag, nil, g_OnShowTip, nil, true, 0.0)
	else
		local nClickCount = CCUserDefault:sharedUserDefault():getIntegerForKey(strClickCountKey, 1)
		if nClickCount < 5 then
			local armature, userAnimation = g_CreateCoCosAnimation("ExclamationMark", nil, 6)
			armature:setScale(fScale)
			Button_Guide:addNode(armature)
			userAnimation:playWithIndex(1)
			local function onPressed_Button_Guide(pSender, nTag)
				local nClickCount = CCUserDefault:sharedUserDefault():getIntegerForKey(strClickCountKey, 1)
				if nClickCount < 5 then
					g_OnShowTip(pSender, nTag)
					nClickCount = nClickCount + 1
					CCUserDefault:sharedUserDefault():setIntegerForKey(strClickCountKey, nClickCount)
					if nClickCount == 5 then
						Button_Guide:removeAllNodes()
						Button_Guide:setTouchEnabled(false)
					end
				end
			end
			g_SetBtnWithPressingEvent(Button_Guide, nTag, nil, onPressed_Button_Guide, nil, true, 0.0)
		end
	end
end

function g_RegisterGuideTipButtonWithoutAni(Button_Guide, strClickCountKey)
	if not strClickCountKey then
		g_SetBtnWithPressingEvent(Button_Guide, nTag, nil, g_OnShowTip, nil, true, 0.0)
	else
		local nClickCount = CCUserDefault:sharedUserDefault():getIntegerForKey(strClickCountKey, 1)
		if nClickCount < 5 then
			local function onPressed_Button_Guide(pSender, nTag)
				local nClickCount = CCUserDefault:sharedUserDefault():getIntegerForKey(strClickCountKey, 1)
				if nClickCount < 5 then
					g_OnShowTip(pSender, nTag)
					nClickCount = nClickCount + 1
					CCUserDefault:sharedUserDefault():setIntegerForKey(strClickCountKey, nClickCount)
					if nClickCount == 5 then
						Button_Guide:removeAllNodes()
						Button_Guide:setTouchEnabled(false)
					end
				end
			end
			g_SetBtnWithPressingEvent(Button_Guide, nTag, nil, onPressed_Button_Guide, nil, true, 0.0)
		end
	end
end

function g_OnShowTip(pSender, nTag)
	local name = pSender:getName()
	if name == "Button_Energy" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("体力")},
			[2] = {_T("进入副本需要消耗体力值")},
			[3] = {_T("每6分钟恢复1点")},
			[3] = {_T("每天最多可花费元宝购买5次")},
			[4] = {_T("提升VIP等级可增加购买次数"), ccc3(255,255,0)},
			[5] = {_T("提升VIP等级可增加体力的上限值"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_TongQian" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("铜钱")},
			[2] = {_T("可通过副本和各项活动等途径获得铜钱")},
			[3] = {_T("可通过招财神符获得大量铜钱"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_YuanBao" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("元宝")},
			[2] = {_T("通过充值RMB获得, 副本、活动、成就等途径也可获得")},
			[3] = {_T("充值元宝可提升VIP等级,获得更多游戏特权"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_XueShi" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("阅历")},
			[2] = {_T("可通过副本和各项活动获得阅历")},
			[3] = {_T("可用于升级阵法、心法、战术"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_Prestige" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("声望")},
			[2] = {_T("通过天榜竞技场、神仙试炼、封印妖魔、八仙过海、爱心转盘等活动获得")},
			[3] = {_T("可用于兑换聚宝阁中的宝物"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_Elements" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("灵力")},
			[2] = {_T("副本通关星级宝箱、小助手活跃礼包等途径可获得")},
			[3] = {_T("可用于消除元素获得灵核,灵核可用于增强主角的神识"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_Elements1" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("灵力")},
			[2] = {_T("副本通关星级宝箱、小助手活跃礼包等途径可获得")},
			[3] = {_T("可用于消除元素获得灵核,灵核可用于增强主角的神识"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Incense" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("香贡")},
			[2] = {_T("通过药园、感悟、小助手活跃礼包、副本通关星级宝箱等途径获得")},
			[3] = {_T("可用于上香培养伙伴的基础属性"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_FriendPoints" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("友情之心")},
			[2] = {_T("通过好友之间互赠爱心获得")},
			[3] = {_T("可在爱心大转盘那里进行抽奖"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_AreaTimes" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("天榜挑战次数")},
			[2] = {_T("每天最多可免费挑战10次")},
			[3] = {_T("元宝可购买挑战次数, VIP等级越高购买次数越多"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_XianLing" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 30
		local tbString = {
			[1] = {_T("仙令")},
			[2] = {_T("通过天榜排行榜竞技获得")},
			[3] = {_T("可用于兑换聚宝阁中的宝物"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_DragonBall" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 30
		local tbString = {
			[1] = {_T("神龙令")},
			[2] = {_T("通过神龙上供、轮回塔等玩法获得")},
			[3] = {_T("可用于装备镀金从而提升装备的星级"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_ActiveNess" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 40
		local tbString = {
			[1] = {_T("活跃度")},
			[2] = {_T("可在小助手中完成每天的任务获得活跃度")},
			[3] = {_T("每天可以根据活跃度在小助手那领取礼包奖励"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_JiangHunShi" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 30
		local tbString = {
			[1] = {_T("将魂石")},
			[2] = {_T("通过分解伙伴获得")},
			[3] = {_T("可用于在将魂商店购买物品"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Button_RefreshToken" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 30
		local tbString = {
			[1] = {_T("将魂令")},
			[2] = {_T("日常活跃任务礼包或活动赠送")},
			[3] = {_T("可以用于将魂商店刷新"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "BitmapLabel_TeamStrength" or name == "Label_TeamStrengthLB" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 45
		local tbString = {
			[1] = {_T("阵容战斗力")},
			[2] = {_T("阵容实力的象征")},
			[3] = {_T("通过提升伙伴的属性可提高阵容的战斗力"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "BitmapLabel_Initiative" or name == "Label_InitiativeLB" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 45
			
		local tbString = {
			[1] = {_T("阵容先攻值")},
			[2] = {_T("战斗中双方的出手顺序将由阵容先攻值决定")},
			[3] = {_T("提升伙伴的等级、突破等级、星级、境界、武力、法术、绝技可提升先攻值"), ccc3(0,255,0)},
			[4] = {_T("提升装备的强化等级、档次、星级可提升先攻值"), ccc3(0,255,0)},
			[5] = {_T("妖兽增加的命力可提升伙伴的先攻值"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "BitmapLabel_Rank" or name == "Label_RankLB" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = tbPos.y - 45
		local tbString = {
			[1] = {_T("天榜排名")},
			[2] = {_T("在天榜竞技场中的名次")},
			[3] = {_T("每天根据天榜排名可领取奖励, 排名越高奖励越高"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 7)
	elseif name == "Image_LevelPNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("伙伴等级")},
			[2] = {_T("伙伴等级提高后, 伙伴的二级属性会增加")},
			[3] = {_T("伙伴的武力、法术、绝技越高, 其对应的二级属性增加的越多"), ccc3(0,255,0)},
			[4] = {_T("伙伴星级品质越高, 其对应的二级属性增加的越多"), ccc3(0,255,0)},
			[5] = {_T("二级属性=伙伴等级×一级属性×星级品质系数"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_BasePropPNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("基础属性")},
			[2] = {_T("武力 - 武力和星级品质共同影响物理攻击和物理防御的成长")},
			[3] = {_T("法术 - 法术和星级品质共同影响法术攻击和法术防御的成长")},
			[4] = {_T("绝技 - 绝技和星级品质共同影响绝技攻击和绝技防御的成长")},
			[5] = {_T("突破、升星、渡劫、上香可升伙伴的基础属性"), ccc3(0,255,0)},
			[6] = {_T("二级属性=伙伴等级×一级属性×星级品质系数"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_StarUpPNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("升星")},
			[2] = {_T("升星之后可以提升伙伴的品质")},
			[3] = {_T("伙伴的品质越高, 伙伴升级后成长的属性越多"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_RealmPNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("渡劫")},
			[2] = {_T("修仙是一段艰辛但颇有意思的一段历程")},
			[3] = {_T("随着每一层境界的圆满，修仙者便可渡劫进入下一境界乃至成仙")},
			[4] = {_T("境界提升可大幅提升生命值与基础属性"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_FatePNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("伙伴命力")},
			[2] = {_T("强大的异兽寄托在宿主身上将大幅提高宿主的能力，甚至改变命运")},
			[3] = {_T("命力可大幅增加伙伴的先攻值"), ccc3(0,255,0)},
			[4] = {_T("命力为装备在伙伴身上的所有异兽的经验总和"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_ProfessionInfoPNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("职业")},
			[2] = {_T("武圣 - 初始属性为韧性和格挡，格挡后增加1点气势")},
			[3] = {_T("剑灵 - 初始属性为闪避，闪避后增加1点气势")},
			[4] = {_T("飞羽 - 初始属性为暴击，暴击后增加1点气势")},
			[5] = {_T("术士 - 初始属性为命中，是战斗中的强力辅助")},
			[6] = {_T("将星 - 初始属性为必杀，变身后大幅度增加能力")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_PropDetailBasePNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("二级属性")},
			[2] = {_T("物理攻击 - 增加物理型职业的普攻及绝招伤害")},
			[3] = {_T("物理防御 - 减少受到物理型职业的普攻及绝招伤害")},
			[4] = {_T("法术攻击 - 增加法术型职业的普攻及绝招伤害")},
			[5] = {_T("法术防御 - 减少受到法术型职业的普攻及绝招伤害")},
			[6] = {_T("绝技攻击 - 增加所有职业的绝招伤害")},
			[7] = {_T("绝技防御 - 减少受到所有职业的绝招伤害")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_PropDetailRatePNL" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("二级属性")},
			[2] = {_T("暴击 - 增加伙伴的暴击几率")},
			[3] = {_T("必杀 - 增加伙伴的暴击伤害倍数")},
			[4] = {_T("命中 - 减少被攻击目标的闪避几率")},
			[5] = {_T("破击 - 减少被攻击目标的格挡几率")},
			[6] = {_T("韧性 - 减少攻击方的暴击几率")},
			[7] = {_T("刚毅 - 减少攻击方的暴击伤害倍数")},
			[8] = {_T("闪避 - 增加伙伴的闪避几率，闪避后不会受到伤害")},
			[9] = {_T("格挡 - 增加伙伴的格挡几率，格挡后受到伤害减半，并能反击")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Image_FateStreangth" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y + 40
		local tbString = {
			[1] = {_T("伙伴命力")},
			[2] = {_T("强大的异兽寄托在宿主身上将大幅提高宿主的能力，甚至改变命运")},
			[3] = {_T("命力可大幅增加伙伴的先攻值"), ccc3(0,255,0)},
			[4] = {_T("命力为装备在伙伴身上的所有异兽的经验总和"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 2)
	elseif name == "Button_ShangXiangPos" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		if nTag == 1 then
			local tbString = {
				[1] = {_T("生命")},
				[2] = {_T("通过给伙伴上香培养伙伴生命")},
				[3] = {_T("伙伴星级提升可以增加生命培养属性的上限"), ccc3(0,255,0)},
			}
			g_ClientMsgTips:showTip(tbString, tbPos, 7)
		elseif nTag == 2 then
			local tbString = {
				[1] = {_T("武力")},
				[2] = {_T("通过给伙伴上香培养伙伴武力")},
				[3] = {_T("伙伴星级提升可以增加武力培养属性的上限"), ccc3(0,255,0)},
			}
			g_ClientMsgTips:showTip(tbString, tbPos, 7)
		elseif nTag == 3 then
			local tbString = {
				[1] = {_T("法术")},
				[2] = {_T("通过给伙伴上香培养伙伴法术")},
				[3] = {_T("伙伴星级提升可以增加法术培养属性的上限"), ccc3(0,255,0)},
			}
			g_ClientMsgTips:showTip(tbString, tbPos, 7)
		elseif nTag == 4 then
			local tbString = {
				[1] = {_T("绝技")},
				[2] = {_T("通过给伙伴上香培养伙伴绝技属性")},
				[3] = {_T("伙伴星级提升可以增加绝技培养属性的上限"), ccc3(0,255,0)},
			}
			g_ClientMsgTips:showTip(tbString, tbPos, 5)
		end
	elseif name == "Label_FriendCapacity" or  name == "Image_FriendIcon" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x - pSender:getSize().width/2
		tbPos.y = tbPos.y - 30
		local tbString = {
			[1] = {_T("好友数量")},
			[2] = {_T("提升VIP等级可以增加好友数量的上限")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 2)
	elseif name == "Button_Skill1" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		g_ClientMsgTips:showTip(getDragonPrayTip(nTag), tbPos, 5)
	elseif name == "Button_Skill2" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		g_ClientMsgTips:showTip(getDragonPrayTip(nTag), tbPos, 5)
	elseif name == "Button_Skill3" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		g_ClientMsgTips:showTip(getDragonPrayTip(nTag), tbPos, 5)
	elseif name == "Button_Skill4" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		g_ClientMsgTips:showTip(getDragonPrayTip(nTag), tbPos, 5)
	elseif name == "Button_Skill5" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		g_ClientMsgTips:showTip(getDragonPrayTip(nTag), tbPos, 5)
	elseif name == "Button_Skill6" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {}
		table.insert(tbString, {Enum_DragonPraySkill[nTag]})
		for nEventType = 1, 8 do
			local CSV_ActivityDragonPrayEventSub = g_DataMgr:getCsvConfig_FirstKeyData("ActivityDragonPrayEvent", nEventType)
			local nDragonBall = CSV_ActivityDragonPrayEventSub.DragonBall
			local nKnowledgeValue = CSV_ActivityDragonPrayEventSub.Knowledge
			local strTip = _T("摇出")..(nEventType-1).._T("个")..Enum_DragonPrayShaiZi[nTag].._T("可获得")..nDragonBall.._T("个神龙令和")..nKnowledgeValue.._T("点阅历作为奖励")
			table.insert(tbString, {strTip, ccc3(0,255,0)})
		end
		table.insert(tbString, {_T("可使用逆天改运增加出现吉的数量"), ccc3(255,255,0)})
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Label_DragonLevelLB" or  name == "Label_DragonLevel" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x + 75
		tbPos.y = tbPos.y + 30
		local tbString = {
			[1] = {_T("神龙等级")},
			[2] = {_T("提升神龙等级可提升神龙技能")},
			[3] = {_T("神龙技能提高后可提高神龙技能的奖励")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 9)
	elseif name == "Image_DragonExp" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y + 30
		local tbString = {
			[1] = {_T("神龙经验")},
			[2] = {_T("神龙上供成功后为神龙增加经验")},
			[3] = {_T("吉数越多增加经验多")},
			[4] = {_T("提升神龙等级可提升神龙技能")},
			[5] = {_T("神龙技能提高后可提高神龙技能的奖励")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 9)
	elseif name == "Label_FreeRevertTimesLB" or  name == "Label_FreeRevertTimes" or  name == "Label_FreeRevertTimesMax" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x + 75
		tbPos.y = tbPos.y + 30
		local tbString = {
			[1] = {_T("逆天改运")},
			[2] = {_T("逆天改运可重新刷新非吉的骰子")},
			[3] = {_T("您每天可免费获得")..g_VIPBase:getVipValue("DragonFreeChangeCnt").._T("逆天改运的次数")},
			[4] = {_T("免费次数消耗完后将只能用元宝进行改运")},
			[5] = {_T("提高VIP等级可增加免费改运的次数")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 9)
	elseif name == "BitmapLabel_PayRemainNum" or  name == "Image_PayRemainNum1" or  name == "Image_PayRemainNum2" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x - 200
		tbPos.y = tbPos.y
		local tbString = {
			[1] = {_T("神龙上供次数")},
			[2] = {_T("每天最多可免费上供")..g_DataMgr:getGlobalCfgCsv("dragon_pray_cnt").._T("次")},
			[3] = {_T("提高VIP等级可增加每天购买神龙上供的次数")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 6)
	elseif name == "Button_XiaoChuSkill1" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {Enum_GanWuSkillName[nTag]},
			[2] = {_T("感悟后有一定几率激活该技能")},
			[3] = {_T("勾选后技能进行感悟将无需消耗任何的铜钱或元宝"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_XiaoChuSkill2" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {Enum_GanWuSkillName[nTag]},
			[2] = {_T("感悟后有一定几率激活该技能")},
			[3] = {_T("勾选后技能进行感悟将可直接引爆当前选中的两个元素"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_XiaoChuSkill3" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {Enum_GanWuSkillName[nTag]},
			[2] = {_T("感悟后有一定几率激活该技能")},
			[3] = {_T("勾选后技能进行感悟将可直接消除当前选中两个元素的所有花色"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_XiaoChuSkill4" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {Enum_GanWuSkillName[nTag]},
			[2] = {_T("感悟后有一定几率激活该技能")},
			[3] = {_T("勾选后技能进行感悟可将当前选中两个元素的所有花色变为同一种"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_XiaoChuSkill5" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {Enum_GanWuSkillName[nTag]},
			[2] = {_T("感悟后有一定几率激活该技能")},
			[3] = {_T("勾选后技能进行感悟将使所有元素按照选定的元素进行两两相间排列"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Element11" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("感悟元素")},
			[2] = {_T("请点击铜钱感悟或元宝感悟按钮进行消除元素"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_TongQianGanWu" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y
		local tbString = {
			[1] = {_T("铜钱感悟")},
			[2] = {_T("消耗铜钱进行感悟,有概率造成2倍暴击"), ccc3(0,255,0)},
			[3] = {_T("感悟完成后有概率激活感悟技能"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 9)
	elseif name == "Button_YuanBaoGanWu" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y
		local tbString = {
			[1] = {_T("元宝感悟")},
			[2] = {_T("消耗元宝进行感悟,最高可造成5倍暴击"), ccc3(0,255,0)},
			[3] = {_T("提高VIP等级可提高元宝感悟的暴击倍数上限"), ccc3(255,255,0)},
			[4] = {_T("感悟完成后有概率激活感悟技能"), ccc3(0,255,0)},
			[5] = {_T("提高VIP等级可提高元宝感悟触发技能的概率"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 9)
	elseif name == "Button_YueLiGuWu" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y
		local tbString = {
			[1] = {_T("阅历鼓舞")},
			[2] = {_T("消耗阅历进行鼓舞, 鼓舞成功可增加10%攻击力"), ccc3(0,255,0)},
			[3] = {_T("阅历鼓舞有一定概率会失败")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 4)
	elseif name == "Button_YuanBaoGuWu" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y
		local tbString = {
			[1] = {_T("元宝鼓舞")},
			[2] = {_T("消耗元宝进行鼓舞, 鼓舞成功可增加10%攻击力"), ccc3(0,255,0)},
			[3] = {_T("元宝鼓舞百分百成功")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 4)
	elseif name == "Button_Npc1" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_ActivityBaXianNpc = g_BaXianGuoHaiSystem:GetActivityBaXianNpc(nTag)
		local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nTag)
		local tbString = {
			[1] = {CSV_ActivityBaXianNpc.Name.." ".._T("Lv.")..g_BaXianGuoHaiSystem:GetRefreshNPCLevel(nTag)},
			[2] = {_T("灵气").." "..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nTag).."/"..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nTag)},
			[3] = {"\n"},
			[4] = {_T("护送结束后铜钱奖励+")..nCoinsReward, ccc3(0,255,0)},
			[5] = {_T("护送结束后声望奖励+")..nPrestigeReward, ccc3(0,255,0)},
			[6] = {_T("需要")..nConvoyTime.._T("分钟到达目的地"), ccc3(255,255,0)},
			[7] = {_T("护送时受到")..CSV_ActivityBaXianNpc.Name.._T("的庇佑, 生命和战力+")..(CSV_ActivityBaXianNpc.BuffValue/100).."%", ccc3(255,255,0)},
			[8] = {_T("护送结束后")..CSV_ActivityBaXianNpc.Name.._T("经验+")..CSV_ActivityBaXianNpc.AddExp, ccc3(255,255,0)},
			[9] = {_T("NPC等级提高后奖励会增加"), ccc3(0,180,255)},
			[10] = {_T("玩家等级提高后铜钱奖励会增加"), ccc3(0,180,255)},
			[11] = {_T("祭拜道祖神像后当天可获得奖励提高和缩短护送时间的增益Buff"), ccc3(0,180,255)},
			[12] = {_T("道祖神像升级后其增益Buff会增强"), ccc3(0,180,255)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Npc2" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_ActivityBaXianNpc = g_BaXianGuoHaiSystem:GetActivityBaXianNpc(nTag)
		local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nTag)
		local tbString = {
			[1] = {CSV_ActivityBaXianNpc.Name.." ".._T("Lv.")..g_BaXianGuoHaiSystem:GetRefreshNPCLevel(nTag)},
			[2] = {_T("灵气").." "..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nTag).."/"..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nTag)},
			[3] = {"\n"},
			[4] = {_T("护送结束后铜钱奖励+")..nCoinsReward, ccc3(0,255,0)},
			[5] = {_T("护送结束后声望奖励+")..nPrestigeReward, ccc3(0,255,0)},
			[6] = {_T("需要")..nConvoyTime.._T("分钟到达目的地"), ccc3(255,255,0)},
			[7] = {_T("护送时受到")..CSV_ActivityBaXianNpc.Name.._T("的庇佑, 生命和战力+")..(CSV_ActivityBaXianNpc.BuffValue/100).."%", ccc3(255,255,0)},
			[8] = {_T("护送结束后")..CSV_ActivityBaXianNpc.Name.._T("经验+")..CSV_ActivityBaXianNpc.AddExp, ccc3(255,255,0)},
			[9] = {_T("NPC等级提高后奖励会增加"), ccc3(0,180,255)},
			[10] = {_T("玩家等级提高后铜钱奖励会增加"), ccc3(0,180,255)},
			[11] = {_T("祭拜道祖神像后当天可获得奖励提高和缩短护送时间的增益Buff"), ccc3(0,180,255)},
			[12] = {_T("道祖神像升级后其增益Buff会增强"), ccc3(0,180,255)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Npc3" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_ActivityBaXianNpc = g_BaXianGuoHaiSystem:GetActivityBaXianNpc(nTag)
		local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nTag)
		local tbString = {
			[1] = {CSV_ActivityBaXianNpc.Name.." ".._T("Lv.")..g_BaXianGuoHaiSystem:GetRefreshNPCLevel(nTag)},
			[2] = {_T("灵气").." "..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nTag).."/"..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nTag)},
			[3] = {"\n"},
			[4] = {_T("护送结束后铜钱奖励+")..nCoinsReward, ccc3(0,255,0)},
			[5] = {_T("护送结束后声望奖励+")..nPrestigeReward, ccc3(0,255,0)},
			[6] = {_T("需要")..nConvoyTime.._T("分钟到达目的地"), ccc3(255,255,0)},
			[7] = {_T("护送时受到")..CSV_ActivityBaXianNpc.Name.._T("的庇佑, 生命和战力+")..(CSV_ActivityBaXianNpc.BuffValue/100).."%", ccc3(255,255,0)},
			[8] = {_T("护送结束后")..CSV_ActivityBaXianNpc.Name.._T("经验+")..CSV_ActivityBaXianNpc.AddExp, ccc3(255,255,0)},
			[9] = {_T("NPC等级提高后奖励会增加"), ccc3(0,180,255)},
			[10] = {_T("玩家等级提高后铜钱奖励会增加"), ccc3(0,180,255)},
			[11] = {_T("祭拜道祖神像后当天可获得奖励提高和缩短护送时间的增益Buff"), ccc3(0,180,255)},
			[12] = {_T("道祖神像升级后其增益Buff会增强"), ccc3(0,180,255)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Npc4" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_ActivityBaXianNpc = g_BaXianGuoHaiSystem:GetActivityBaXianNpc(nTag)
		local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nTag)
		local tbString = {
			[1] = {CSV_ActivityBaXianNpc.Name.." ".._T("Lv.")..g_BaXianGuoHaiSystem:GetRefreshNPCLevel(nTag)},
			[2] = {_T("灵气").." "..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nTag).."/"..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nTag)},
			[3] = {"\n"},
			[4] = {_T("护送结束后铜钱奖励+")..nCoinsReward, ccc3(0,255,0)},
			[5] = {_T("护送结束后声望奖励+")..nPrestigeReward, ccc3(0,255,0)},
			[6] = {_T("需要")..nConvoyTime.._T("分钟到达目的地"), ccc3(255,255,0)},
			[7] = {_T("护送时受到")..CSV_ActivityBaXianNpc.Name.._T("的庇佑, 生命和战力+")..(CSV_ActivityBaXianNpc.BuffValue/100).."%", ccc3(255,255,0)},
			[8] = {_T("护送结束后")..CSV_ActivityBaXianNpc.Name.._T("经验+")..CSV_ActivityBaXianNpc.AddExp, ccc3(255,255,0)},
			[9] = {_T("NPC等级提高后奖励会增加"), ccc3(0,180,255)},
			[10] = {_T("玩家等级提高后铜钱奖励会增加"), ccc3(0,180,255)},
			[11] = {_T("祭拜道祖神像后当天可获得奖励提高和缩短护送时间的增益Buff"), ccc3(0,180,255)},
			[12] = {_T("道祖神像升级后其增益Buff会增强"), ccc3(0,180,255)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_Npc5" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_ActivityBaXianNpc = g_BaXianGuoHaiSystem:GetActivityBaXianNpc(nTag)
		local nCoinsReward, nPrestigeReward, nConvoyTime = g_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nTag)
		local tbString = {
			[1] = {CSV_ActivityBaXianNpc.Name.." ".._T("Lv.")..g_BaXianGuoHaiSystem:GetRefreshNPCLevel(nTag)},
			[2] = {_T("灵气").." "..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nTag).."/"..g_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nTag)},
			[3] = {"\n"},
			[4] = {_T("护送结束后铜钱奖励+")..nCoinsReward, ccc3(0,255,0)},
			[5] = {_T("护送结束后声望奖励+")..nPrestigeReward, ccc3(0,255,0)},
			[6] = {_T("需要")..nConvoyTime.._T("分钟到达目的地"), ccc3(255,255,0)},
			[7] = {_T("护送时受到")..CSV_ActivityBaXianNpc.Name.._T("的庇佑, 生命和战力+")..(CSV_ActivityBaXianNpc.BuffValue/100).."%", ccc3(255,255,0)},
			[8] = {_T("护送结束后")..CSV_ActivityBaXianNpc.Name.._T("经验+")..CSV_ActivityBaXianNpc.AddExp, ccc3(255,255,0)},
			[9] = {_T("NPC等级提高后奖励会增加"), ccc3(0,180,255)},
			[10] = {_T("玩家等级提高后铜钱奖励会增加"), ccc3(0,180,255)},
			[11] = {_T("祭拜道祖神像后当天可获得奖励提高和缩短护送时间的增益Buff"), ccc3(0,180,255)},
			[12] = {_T("道祖神像升级后其增益Buff会增强"), ccc3(0,180,255)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_JueXingGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("觉醒")},
			[2] = {_T("消耗灵力消除识海中的七种元素可精粹出提升灵根所需的灵核")},
			[3] = {_T("共有七种属性的灵核分别为金、木、水、火、土、风、雷, 对主角的七种灵根")},
			[4] = {_T("消耗灵核进行激活灵根, 七种灵根都激活后可觉醒神识, 提高神识的品阶")},
			[5] = {_T("主角神识属性对所有出战伙伴都有作用"), ccc3(0,255,0)},
			[6] = {_T("灵力可通过副本通关星级宝箱和小助手活跃礼包获得"), ccc3(0,255,0)},
			[7] = {_T("使用强大的消除技能可以消除更多的元素"), ccc3(0,255,0)},
			[8] = {_T("提高VIP等级可增加消除技能的每日使用上限"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_BaXianGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("八仙过海")},
			[2] = {_T("护送八仙过海可获得高额的铜钱奖励和声望奖励")},
			[3] = {_T("星期一至五玩家可护送铁拐李、汉钟离、吕洞宾、何仙姑、蓝采和")},
			[4] = {_T("星期六、日玩家可护送何仙姑、蓝采和、张果老、韩湘子、曹国舅, 奖励将更高"), ccc3(255,0,255)},
			[5] = {_T("护送前可免费刷新八仙1次, 之后如希望护送更高品质的NPC则需元宝刷新")},
			[6] = {_T("可对护送中的玩家进行挑战, 挑战成功可获得12.5%奖励")},
			[7] = {_T("挑战你的玩家将被标记为对手, 将在屏幕上方显示"), ccc3(255,0,0)},
			[8] = {_T("护送前祭拜道祖神像可提高护送的奖励以及缩短护送的时间"), ccc3(0,255,0)},
			[9] = {_T("道祖神像乃全服共享, 需要全服玩家共同提升其等级"), ccc3(0,255,0)},
			[10] = {_T("提高VIP等级可增加每天挑战的额外购买次数"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_GanWuGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("感悟")},
			[2] = {_T("所谓感悟乃消除杂念, 从而达到心旷神怡的境地")},
			[3] = {_T("感悟后可获得香贡奖励")},
			[4] = {_T("并且感悟有几率暴击从而获得更多的香贡奖励")},
			[5] = {_T("铜钱感悟最多造成2倍暴击, 元宝感悟必定暴击, 可造成2~6倍的暴击")},
			[6] = {_T("每次感悟有几率触发感悟技能, 使用感悟技能能消除更多的杂念")},
			[7] = {_T("感悟技能之前互相配合可获得更好的效果"), ccc3(0,255,0)},
			[8] = {_T("提升VIP等级可提高感悟技能的触发概率"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_HuntFateGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("猎妖塔")},
			[2] = {_T("妖兽可以寄宿在主人身上提高主人的能力")},
			[3] = {_T("妖兽之间也可以通过互相吞噬进行升级")},
			[4] = {_T("消耗铜钱可委托猎妖师进行猎妖")},
			[5] = {_T("猎妖师猎取妖兽后有概率激活更强大猎妖师")},
			[6] = {_T("猎妖师更强大猎取的妖兽也越稀有和强大"), ccc3(0,255,0)},
			[7] = {_T("您也可以花费元宝直接委托姜子牙进行猎妖, 有更高几率产出极品妖兽"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ShangXiangGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("伙伴上香")},
			[2] = {_T("给神佛上香可获得庇佑从而提高伙伴的属性")},
			[3] = {_T("上香时需要消耗香贡")},
			[4] = {_T("然后并不是每次上香神佛都是笑纳的, 如果不满意反而会收到惩罚")},
			[5] = {_T("有钱能使鬼推磨, 上香时孝敬些元宝是能大幅提高神灵的满意度的"), ccc3(255,255,0)},
			[6] = {_T("如果对上香的结果不满意, 选择取消不会对属性有任何影响"), ccc3(0,255,0)},
			[7] = {_T("通过感悟可获得大量的香贡来源"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ZhuanPanGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("爱心转盘")},
			[2] = {_T("爱心转盘上面的奖励类型每天凌晨进行重置")},
			[3] = {_T("每天转动爱心转盘10次, 转动爱心转盘需要消耗友情之心")},
			[4] = {_T("友情之心通过好友之间互相赠送获得")},
			[5] = {_T("提升VIP等级可增加爱心转盘的每日购买次数上限")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_FengYinGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nTag)
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
		local tbString = {
			[1] = {_T("封印妖魔")},
			[2] = {_T("每天21:00随机刷新一个全服挑战的妖魔Boss")},
			[3] = {_T("战斗中根据对Boss造成的伤害值给予铜钱奖励")},
			[4] = {_T("每天根据玩家累计对Boss的伤害发放排名奖励")},
		}
		local tbActivityWorldBossRewardInSort = g_DataMgr:getActivityWorldBossRewardCsv()
		for i = 1, #tbActivityWorldBossRewardInSort do
			table.insert(tbString, {
					tbActivityWorldBossRewardInSort[i].RankAresStr.."："..CSV_CardBase.Name.._T("魂魄×")..tbActivityWorldBossRewardInSort[i].HunPoRewardNum..", ".._T("铜钱×")..tbActivityWorldBossRewardInSort[i].CoinsRewardNum..", ".._T("声望×")..tbActivityWorldBossRewardInSort[i].PrestigeRewardNum,
					ccc3(0,255,0)
				}
			)
		end
		table.insert(tbString, {_T("提高VIP等级可增加神仙试炼的额外购买次数"), ccc3(255,255,0)})
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ShenXianShiLianGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nTag)
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
		local tbString = {
			[1] = {_T("神仙试炼")},
			[2] = {_T("每天凌晨随机刷新一个全服挑战的神仙Boss")},
			[3] = {_T("战斗中根据对Boss造成的伤害值给予铜钱奖励")},
			[4] = {_T("每天根据玩家累计对Boss的伤害发放排名奖励")},
		}
		local tbActivityWorldBossRewardInSort = g_DataMgr:getActivityWorldBossRewardCsv()
		for i = 1, #tbActivityWorldBossRewardInSort do
			if tbActivityWorldBossRewardInSort[i].Rank > 0 then
				table.insert(tbString, {
						tbActivityWorldBossRewardInSort[i].RankAresStr.."："..CSV_CardBase.Name.._T("魂魄×")..tbActivityWorldBossRewardInSort[i].HunPoRewardNum..", ".._T("铜钱×")..tbActivityWorldBossRewardInSort[i].CoinsRewardNum..", ".._T("声望×")..tbActivityWorldBossRewardInSort[i].PrestigeRewardNum,
						ccc3(0,255,0)
					}
				)
			end
		end
		table.insert(tbString, {_T("提高VIP等级可增加神仙试炼的额外购买次数"), ccc3(255,255,0)})
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_DragonPrayGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("神龙上供")},
			[2] = {_T("神龙有七个龙珠, 每个龙珠里面有1个骰子")},
			[3] = {_T("骰子有六个面, 分别表示'福、禄、寿、喜、财、吉'")},
			[4] = {_T("点击上供后, 根据首次摇骰子的结果会触发神龙技能奖励")},
			[5] = {_T("神龙技能奖励规则点击下方的'福、禄、寿、喜、财'图标按钮查看")},
			[6] = {_T("根据摇出的吉的数量不同, 给予不同奖励, 可点击右下角'吉'按钮查看")},
			[7] = {_T("神龙上供后, 可使用逆天改运功能重新刷新剩余非'吉'的筛子"), ccc3(0,255,0)},
			[8] = {_T("提高VIP等级可增加每天的免费改运次数和神龙上供额外购买次数"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_DragonPrayGuildGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("帮派吉星高照")},
			[2] = {_T("每天可以摇动骰子10次")},
			[3] = {_T("根据每次摇出骰子的吉的数量计算积分")},
			[4] = {_T("每天根据积分的排名进行发放奖励")},
		}
		local tbGuildDragonPrayRewardInSort = getGuildDragonPrayRewardCsv()
		local nGuildLevel = g_Guild:getUserGuildLevel()
		for i = 1, #tbGuildDragonPrayRewardInSort do
			if tbGuildDragonPrayRewardInSort[i].Rank > 0 then
				local nRewardCoins = tbGuildDragonPrayRewardInSort[i].CoinsRewardBase + tbGuildDragonPrayRewardInSort[i].CoinsRewardGrowth * (nGuildLevel - 1)
				local nRewardKnowledge = tbGuildDragonPrayRewardInSort[i].KnowledgeRewardBase + tbGuildDragonPrayRewardInSort[i].KnowledgeRewardGrowth * (nGuildLevel - 1)
				table.insert(tbString, {
						tbGuildDragonPrayRewardInSort[i].RankAresStr.."：".._T("铜钱×")..nRewardCoins..", ".._T("阅历×")..nRewardKnowledge,
						ccc3(0,255,0)
					}
				)
			end
		end
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ShenXianShiLianGuildGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nTag)
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
		local tbString = {
			[1] = {_T("帮派神仙试炼")},
			[2] = {_T("每天凌晨随机刷新一个帮派挑战的神仙Boss")},
			[3] = {_T("战斗中根据对Boss造成的伤害值给予铜钱奖励")},
			[4] = {_T("每天根据玩家累计对Boss的伤害发放排名奖励")},
		}
		local tbGuildWorldBosssRewardInSort = getGuildWorldBosssRewardCsv()
		local nGuildLevel = g_Guild:getUserGuildLevel()
		for i = 1, #tbGuildWorldBosssRewardInSort do
			if tbGuildWorldBosssRewardInSort[i].Rank > 0 then
				local nRewardCoins = tbGuildWorldBosssRewardInSort[i].CoinsRewardBase + tbGuildWorldBosssRewardInSort[i].CoinsRewardGrowth * (nGuildLevel - 1)
				local nRewardKnowledge = tbGuildWorldBosssRewardInSort[i].KnowledgeRewardBase + tbGuildWorldBosssRewardInSort[i].KnowledgeRewardGrowth * (nGuildLevel - 1)
				local nRewardPrestige = tbGuildWorldBosssRewardInSort[i].PrestigeRewardBase + tbGuildWorldBosssRewardInSort[i].PrestigeRewardGrowth * (nGuildLevel - 1)
				table.insert(tbString, {
						tbGuildWorldBosssRewardInSort[i].RankAresStr.."："..CSV_CardBase.Name.._T("魂魄×")..tbGuildWorldBosssRewardInSort[i].HunPoRewardNum..", ".._T("铜钱×")..nRewardCoins..", ".._T("阅历×")..nRewardKnowledge..", ".._T("声望×")..nRewardPrestige,
						ccc3(0,255,0)
					}
				)
			end
		end
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_FengYinGuildGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nTag)
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
		local tbString = {
			[1] = {_T("帮派封印妖魔")},
			[2] = {_T("每天12:30随机刷新一个帮派挑战的妖魔Boss")},
			[3] = {_T("战斗中根据对Boss造成的伤害值给予铜钱奖励")},
			[4] = {_T("每天根据玩家累计对Boss的伤害发放排名奖励")},
		}
		local tbGuildWorldBosssRewardInSort = getGuildWorldBosssRewardCsv()
		local nGuildLevel = g_Guild:getUserGuildLevel()
		for i = 1, #tbGuildWorldBosssRewardInSort do
			local nRewardCoins = tbGuildWorldBosssRewardInSort[i].CoinsRewardBase + tbGuildWorldBosssRewardInSort[i].CoinsRewardGrowth * (nGuildLevel - 1)
			local nRewardKnowledge = tbGuildWorldBosssRewardInSort[i].KnowledgeRewardBase + tbGuildWorldBosssRewardInSort[i].KnowledgeRewardGrowth * (nGuildLevel - 1)
			local nRewardPrestige = tbGuildWorldBosssRewardInSort[i].PrestigeRewardBase + tbGuildWorldBosssRewardInSort[i].PrestigeRewardGrowth * (nGuildLevel - 1)
			table.insert(tbString, {
					tbGuildWorldBosssRewardInSort[i].RankAresStr.."："..CSV_CardBase.Name.._T("魂魄×")..tbGuildWorldBosssRewardInSort[i].HunPoRewardNum..", ".._T("铜钱×")..nRewardCoins..", ".._T("阅历×")..nRewardKnowledge..", ".._T("声望×")..nRewardPrestige,
					ccc3(0,255,0)
				}
			)
		end
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ChongZhuGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("装备重铸")},
			[2] = {_T("选择某个附加属性后, 通过重铸可重新随机生成其属性")},
			[3] = {_T("附加属性分为白、绿、蓝、紫、金等品质")},
			[4] = {_T("附加属性的随机上限跟装备当前的颜色品质对应")},
			[5] = {_T("如白色的逍遥装备的附加属性颜色上限是白色")},
			[6] = {_T("越高品质的附加属性出现的可能性越低")},
			[7] = {_T("装备重铸需要消耗对应品质的重铸晶石"), ccc3(0,255,0)},
			[8] = {_T("低级的重铸晶石可以合成更好品质的重铸晶石"), ccc3(0,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_SummonGuide1" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("普通召唤")},
			[2] = {_T("普通召唤有几率获得道具、装备合成材料和碎片、丹药碎片、魂魄等物品")},
			[3] = {_T("普通召唤同时还有一定几率可召唤出伙伴"), ccc3(0,255,0)},
			[4] = {_T("普通召唤十连抽必产出三种魂魄"), ccc3(0,255,0)},
			[5] = {_T("普通召唤十连抽必产出三星魂魄"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_SummonGuide2" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("高级召唤")},
			[2] = {_T("高级召唤有几率获得伙伴, 有几率获得2~5个魂魄，有几率获得3~5个丹药碎片")},
			[3] = {_T("高级召唤十连抽必召唤出三个伙伴"), ccc3(0,255,0)},
			[4] = {_T("高级召唤十连抽必出三星伙伴"), ccc3(255,255,0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ZhaoCaiGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 360
		local tbString = {
			[1] = {_T("招财进宝")},
		}
		local CSV_VipLevel = g_DataMgr:getCsvConfig("VipLevel")
		for i = 1, #CSV_VipLevel do
			local cccColor
			if i == 1 then
				cccColor = ccc3(255, 255, 255)
			elseif i <= 3 then
				cccColor = ccc3(0, 255, 0)
			elseif i <= 5 then
				cccColor = ccc3(0, 180, 255)
			elseif i <= 7 then
				cccColor = ccc3(255, 0, 255)
			elseif i <= 9 then
				cccColor = ccc3(255, 255, 0)
			elseif i <= 11 then
				cccColor = ccc3(255, 150, 0)
			elseif i <= 13 then
				cccColor = ccc3(255, 0, 0)
			end
			table.insert(tbString, {
					_T("VIP")..CSV_VipLevel[i].Id.._T(": 每天招财上限为")..CSV_VipLevel[i].ZhaoCaiMaxNum.._T("次"),
					cccColor
				}
			)
		end
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ZhenXinGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("战术")},
			[2] = {_T("战术是伙伴战斗时互相配合的策略")},
			[3] = {_T("根据战术的策略不同分为防守策略、进攻策略等")},
			[4] = {_T("战术将根据每个阵位的出手顺序提高阵位上伙伴的属性"), ccc3(0, 255, 0)},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_KuangHuanGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("终极大奖")},
			[2] = {_T("玩家可在活动开启8天内完成前5天开启的任务列表")},
			[3] = {_T("超过8天后, 活动将自动关闭")},
			[4] = {_T("完成全部目标即可领取全部的奖励")},
			[5] = {_T("或者在第8天可以根据当前进度所在的档位领取最终奖励")},
			[6] = {_T("全目标奖励只可领取一次，领取后便不再领取")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	elseif name == "Button_ChuanChengGuide" then
		local tbPos = pSender:getWorldPosition()
		tbPos.x = 640
		tbPos.y = 355
		local tbString = {
			[1] = {_T("伙伴传承")},
			[2] = {_T("可传承等级、装备、境界、上香、异兽、丹药、技能、突破等级")},
			[3] = {_T("传承后上述的伙伴属性将互相交换")},
		}
		g_ClientMsgTips:showTip(tbString, tbPos, 5)
	end
end