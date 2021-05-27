AchieveData = AchieveData or BaseClass(BaseController)

--成就系统中用到的各种事件A
ACHIEVE_ATOM_EVENT_ID = 
{
	ACHIEVE_EVENT_ID_NONE=0,        			--占位的没有实质意义
	ACHIEVE_EVENT_LOGIN =1,       				--登陆游戏 参数1：1 是否使用登陆器,参数2：登陆的天数，参数3：流失的天数，参数4：提取元宝的数目
	ACHIEVE_EVENT_LEVEL_UP=2 ,      			--等级提升
	ACHIEVE_EVENT_JUMP =3,         				--跳跃
	ACHIEVE_EVENT_ACCEPT_QUEST=4,   			--第1次接任务
	ACHIEVE_EVENT_FINISH_QUEST=5,   			--完成任务
	ACHIEVE_EVENT_ATTACK_MONSTER=6, 			--击杀怪物
	ACHIEVE_EVENT_TAKEN_ON_EQUIP=7, 			--穿上装备  参数1 物品的id
	ACHIEVE_EVENT_DAZUO=8,         				--打坐
	ACHIEVE_EVENT_JOIN_TEAM=9,      			--加入队伍
	ACHIEVE_EVENT_ADD_FRIEND=10,    			--添加好友
	ACHIEVE_EVENT_JOIN_GUILD=11,    			--加入帮派
	ACHIEVE_EVENT_JOIN_LEITAI=12,   			--参加擂台战
	ACHIEVE_EVENT_LEITAI_SUCCEED=13, 			--擂台战获胜
	ACHIEVE_EVENT_ENTER_FB=14,      			--进入副本
	ACHIEVE_EVENT_KILLED=15,       				--被杀死
	ACHIEVE_EVENT_CREATE_GUILD=16,   			--创建帮派 参数1表示开服第几天
	ACHIEVE_EVENT_START_GJ=17,      			--开始挂机
	ACHIEVE_EVENT_MATCH=18,         			--开始切磋
	ACHIEVE_EVENT_EQUIP_STRONG=19,   			--装备强化
	ACHIEVE_EVENT_EQUIP_HOLE=20,     			--装备打孔
	ACHIEVE_EVENT_EQUIP_ENLAY =21,   			--嵌入宝石  参数1：宝石等级
	ACHIEVE_EVENT_EQUIP_DELAY =22,    			--宝石拆卸
	ACHIEVE_EVENT_EQUIP_MAKE_DIAMOND =23,  		--合成宝石
	ACHIEVE_EVENT_SHOP_BUY =24,  				--商城购买物品
	ACHIEVE_EVENT_COIN_CHANGE =25 ,				--背包绑定银两+银两数量变化
	ACHIEVE_EVENT_ZHANHUN_CHANGE =26, 			--战魂值变化
	ACHIEVE_EVENT_ZY_CHANGE =27,    			--角色阵营贡献变化
	ACHIEVE_EVENT_FRIEND_COUNT_CHANGE =28,   	--好友的数量变化
	ACHIEVE_EVENT_GUILD_MASTER =29,    			--成为帮派的帮主或者副帮主
	ACHIEVE_EVENT_GUILD_LEVEL_UP =30,   		--所在帮派的等级提升
	ACHIEVE_EVENT_LEITAI_DUR_WEEK_CHANGE =31, 	--一周内擂台战连胜次数改变
	ACHIEVE_EVENT_LEITAI_WINNER =32, 			--成为擂台霸主
	ACHIEVE_EVENT_MATCH_WIN =33, 				--切磋胜利
	ACHIEVE_EVENT_USE_ITEM =34 , 				--使用物品
	ACHIEVE_EVENT_ENTER_SCENE =35 , 			--进入场景
	ACHIEVE_EVENT_BAG_ADD_ITEM =36, 			--背包获取物品
	ACHIEVE_EVENT_GUILD_CONC_CHANGE =37 , 		--参数1：1 成功拜师 2 成功收徒 3 加入行会

	ACHIEVE_EVENT_SEND_FLOWR =38,         		--送花,参数1表示数目
	ACHIEVE_EVENT_RECEIVE_FLOWR =39,        	--收到花,参数1表示数目
	ACHIEVE_EVENT_CONSUMER_YUANBAO =40,     	--消费元宝,,参数1表示数目
	ACHIEVE_EVENT_SUIT_COUNT_CHANGE=41,      	--套装的数目发生改变,参数1表示套装的id,参数2表示套装的数目
	ACHIEVE_EVENT_JIMAI_GAIN_COIN =42,        	--寄卖获得银两,参数1表示银两数目
	ACHIEVE_EVENT_JIMAI_GAIN_YUANBAO =43,       --寄卖获得元宝,参数1表示元宝的数目

	--参加活动 ,参数1表示数目活动的类型 1:参加轻功宗师到达终点(第2个参数名次), (2阵营运镖，其他的以后扩展),3参加华山论剑并获得一定排名(第2个参数名次),
	--4 参加密宗洞(第2个参数名次) 5参加盟主膜拜，6表示千里护送镖  7 圣火保卫战  8 一千零一个愿望 9 击败玉兔(第2个参数名次)
	--10 每日答题（第二参数 答题的数目） 11：每日雕像（第二个参数膜拜的次数） 12：每日诛魔（第二个参数投入的装备数量）
	--13: 每日鲜花 (第二个参数 种植的鲜花次数)  14:护花美女 （完成护送美女的次数） 15:每日角斗场（第2个参数名次）
	--16：每日赛马（第2个参数名次） 17:领取VIP福利1次
	ACHIEVE_EVENT_FINISH_ACTIVITY=44,       
	ACHIEVE_EVENT_JIANGHU_DIWEI_CHANGE =45,   	--江湖地位发生改变,参数1表示江湖地位的id,在config\camp\CampJiangHuDiWei.lua里配置
	ACHIEVE_EVENT_FB_FINISH=46,             	--完成副本，成功通关，参数1表示通关的等级
	ACHIEVE_EVENT_SMITH= 47,             		--全身的装备精锻度发生改变,参数1表示全身装备的精锻度的综合
	ACHIEVE_EVENT_ACUPOINT_CHANGE=48,          	--经脉的总点数发生改变，参数1表示全身经脉的综合	
	ACHIEVE_EVENT_GET_ON_LINE_YUANBAO=49,       --获取在线绑定元宝，参数1表示第几次获得元宝
	ACHIEVE_EVENT_DIAMOND_COUNT_CHANGE =50,   	--全身%d级的宝石的数目发生改变，参数1表示多少件的的宝石到参数2的等级，参数2表示宝石的等级
	ACHIEVE_EVENT_ALL_EQUIP_STRONG_CHANGE =51,  --全身装备强化到%d级以上，参数1表示多少件的装备强化到参数2的等级，参数2表示强化的等级
	ACHIEVE_EVENT_PET_COUNT_CHANGE =52,        	--身上的宠物的数目发生变化，参数1表示宠物的数目
	ACHIEVE_EVENT_PET_SUIT_CHANGE =53,        	--宠物套装的数目发生改变,参数1表示套装的id,参数2表示套装的数目
	ACHIEVE_EVENT_PET_ITEM_LEARN_SKILL =54,   	--通过技能书学习宠物的技能
	ACHIEVE_EVENT_PET_EQUIP_ENLAY =55,        	--宠物的装备打宝石，参数1表示宝石的等级	
	ACHIEVE_EVENT_PET_APTITUDE_CHANGE =56,       --宠物的资质发生改变，参数1表示资质的总和,参数2是否有洗练的造作
	ACHIEVE_EVENT_GEM_GRADE_CHANGE =57,			--宝物的档次发生变化（添加宝物的时候也触发），参数1表示宝物的档次，参数2表示宝物的品质(珍品等)
	ACHIEVE_EVENT_GEM_LEVEL_CHANGE =58,         --宝物的等级发生变化，参数1表示宝物的等级
	ACHIEVE_EVENT_GEM_APTIDUTE_CHANGE =59,      --宝物的灵性发生变化，参数1表示宝物的灵性,参数2为1表示宝物灵性炼化
	ACHIEVE_EVENT_GEM_SUIT_COUNT =60,           --宝物的命盘开孔数目发生变化，参数1表示宝物的命盘开孔的数目
	ACHIEVE_EVENT_KILL_USER =61,              	--杀死玩家，参数1表示阵营是否相同(1表示相同，0表示不同)，参数2表示玩家的职位(见阵营的配置表)
	ACHIEVE_EVENT_GAMBLE =62,               	--盗梦，参数1表示本次盗梦的次数
	ACHIEVE_EVENT_PET_LEVEL_UP=63,           	--宠物的等级提升，参数1表示宠物当前的等级
	ACHIEVE_EVENT_PET_EQUIP_STRONG =64,        	--宠物的装备强化，参数1表示强化的等级
	ACHIEVE_EVENT_GEM_COUNT_CHANGE =65,        	--宝物的数目发生变化，参数1表示当前有多少个宝物
	ACHIEVE_EVENT_GEM_LIGHT =66,        		--宝物开光
	ACHIEVE_EVENT_BROTHER =67,        			--结拜
	ACHIEVE_PASS_TA =68,       					--通过了爬塔的层，参数1表示层的id
	ACHIEVE_SPEED_TRAC = 69,   					--速传
	ACHIEVE_DRAW_YU_BAO = 70,					--提取元宝 参数1表示元宝数量
	ACHIEVE_MO_BAI_SCORE =71,		 			--膜拜积分达到20分 参数1表示膜拜积分
	ACHIEVE_QUESTTRUST =72,		 				--达成任务委托
	ACHIEVE_FINISH_QUEST_TRUST = 73,			--立刻完成一次任务委托
	ACHIEVE_QUEST_FRESH_STAR = 74,				--任务刷星4星  参数1表示星级等级
	ACHIEVE_DART_FRESH_STAR = 75,				--镖车刷星    参数1表示星级等级
	ACHIEVE_PET_QUALITY_CHANGE = 76,			--灵兽品质提升
	ACHIEVE_COMBAT_TIMES = 77,					--每天完成多少次战力竞技的挑战  参数1表示挑战的次数
	ACHIEVE_CIRCLE_TIMES = 78,					--转生   参数1:表示转生的次数
	ACHIEVE_CHARM_VALUE = 79,					--魅力/帅气值   参数1表示魅力/帅气当前值
	ACHIEVE_CONTRIBUTE_YB = 80,					--向祈福仙子捐献元宝时，触发这个事件，参数1捐献了多少元宝
	ACHIEVE_IDENTIFY_TIMES = 81,				--装备鉴定	参数1表示装备总鉴定的次数，参数2表示身上装备的最低鉴定次数的事件 参数3 当天鉴定次数
	ACHIEVE_DONATE_GUILD_COIN = 82,				--捐献行会资金 参数1表示捐献的行会资金数量
	ACHIEVE_CHECK_TIMES = 83,					--签到 参数1表示签到的次数
	ACHIEVE_ACTIVITY_NUM = 84,					--活跃度 参数1表示活跃度的数值
	ACHIEVE_PASS_FUBEN = 85,					--通过副本
	ACHIEVE_DIG = 86,							--挖矿 参数1：1 表示判断纯度 2 表示判断数量 参数2：x纯度或者x数量
	ACHIEVE_RIDE_UP_LEVEL = 87,					--坐骑进阶 参数1：升级到某阶，参数2：升级到某星
	ACHIEVE_HONOUR_LEVEL = 88,					--开启X级荣誉祝福 参数1：开启的荣誉等级
	ACHIEVE_START_STALL = 89,					--进行摆摊
	ACHIEVE_BATTLE = 90,						--战斗力提升 参数1：战斗力
	ACHIEVE_PHONE_EVENT = 91,					--手机卡验证 参数1： 1 表示新手卡 2 表示行会卡 3 表示活动礼包 
	ACHIEVE_WORLD_CONTRIBUTION = 92,			--世界贡献度 参数1：贡献度
	ACHIEVE_SIGN_INTIMES = 93,					--每日签到次数 参数1表示签到的次数
	ACHIEVE_FIRST_VIP = 94,						--首次成为vip
	ACHIEVE_DRAW_YUANBAO_COUNT = 95,			--提取元宝数目统计 参数1：每次提取元宝数
	ACHIEVE_BLOOD_REFINING = 96,				--装备血炼
	ACHIEVE_EVENT_ATTACK_MONSTER_NUM = 97,  	--杀怪数量
	ACHIEVE_ALL_EQUIP_TOTAL_STRONG = 98,   		--全身装备强化等级总和，参数1表示等级总和
	ACHIEVE_SEND_RED_PACKET = 99,         		--发红包,参数1表示金钱数目
	ACHIEVE_INNER_LEVEL_UP = 100,				--内功等级提升,参数1表示新等级
	ACHIEVE_DART_TOTAL_COUNT = 101,				--护送镖车总次数,参数1表示总次数
	ACHIEVE_OFFICE_UPGRADE = 102,				--官职等级提升，参数1表示当前等级
	ACHIEVE_SOUL_UPGRADE = 103,					--通灵等级提升，参数1表示当前等级
	ACHIEVE_EQUIP_LEVEL_UPGRADE = 104,			--装备等级提升，参数1表示装备类型(1玉佩、2护盾、3宝石、4圣珠、5麻痹戒指、6护身戒指、7复活戒指),参数2表示等级
	ACHIEVE_EQUIP_SYNTHESIS = 105,				--装备合成
	ACHIEVE_SWING_UPGRADE = 106,				--翅膀等级提升，参数1表示当前等级
	ACHIEVE_SBK_TIMES = 107,					--参与攻城战次数，每次攻城期间时进入皇宫为1次(地图ID:51)，参数1表示当前次数
	ACHIEVE_TIAN_GUAN_TIMES = 108,				--天关闯到第几关，共200关(地图ID:163)，参数1表示第几关
	ACHIEVE_FENG_MO_GU_TIMES = 109,				--进入封魔谷地图次数统计(地图ID:175)，参数1表示当前次数
	ACHIEVE_MAYA_SHENDIAN_TIMES = 110,			--进入玛雅神殿地图次数统计(地图ID:53)，参数1表示当前次数
	ACHIEVE_KILL_BOSS_TIMES = 111,				--击杀BOSS数量，参数1表示BOSS ID，参数2表示当前次数
		
	MAX_ATOM_EVENT_ID = 112,      				--最大的原子事件的ID   
}
MEDAL_ID = {558, 559}
AchieveData.Group = 9
AchieveData.MaxAcheve = 513
function AchieveData:__init()
	if AchieveData.Instance then
		ErrorLog("[AchieveData] attempt to create singleton twice!")
		return
	end
	AchieveData.Instance = self
	self.name_list = {}
	self.achieve_config = {}
	self.achieve_id = nil 
	self.badge_id = nil 
	self.reward_flag_t = {}
	self.achieve_finish_cnt_t = {}
	self.single_group_config = {}
	self.consume_count_tab = {}
	self.consume_count = {}
	self.achieve_data = {}
	self.data_index_tab = {}
	self.data_number_tab = {}
	self.limit_id = {}
	self.limit_data = {}
	self.count = nil
	self.current_index = nil
	self.total_group = {}
	self:SetTotalConfigAchieveData()
end

function AchieveData:__delete()
	AchieveData.Instance = nil
end

--得到配置中的数据
function AchieveData.GetConfigData(equip_id)
	-- for k,v in pairs(EquipStoveCfg.BadgeUpgrade) do
	-- 	if v.award.id  == equip_id then
	-- 		return v
	-- 	end
	-- end
	
end

function AchieveData.GetEquipIndex(index)
	if index == TabIndex.achieve_medal then
		return EquipData.EquipIndex.Decoration
	end	
end

function AchieveData:GetAchieveNameList()
	for i,v in ipairs(AchieveGroups) do
		if i <= 9 then
			self.name_list[i] = v.name
		end
	end
	return self.name_list
end

--得到奖励等配置
function AchieveData.GetAchieveConfig(index)
	if nil ~= index then
		return ConfigManager.Instance:GetServerConfig("achieve/achieves/achieve"..index)
	end
end

--得到需求等配置
function AchieveData.GetAchieveEventConfig()
	return ConfigManager.Instance:GetServerConfig("achieve/achieves/achieveEvent1")
end

function AchieveData:SetAchieveData(protocol)
	self.total_data = {}
	local count_index = 1
	for key,v in ipairs(protocol.reward_flag_t) do
		for i = 1, 4 do
			local id = (key - 1) * 4 + i - 1
			if id <= AchieveData.MaxAcheve then
				self.reward_flag_t[id] = {}
				local index = (id + 1) % 4
				index = index == 0 and 4 or index 
				local data = bit:d2b(v)
				self.reward_flag_t[id].finish = data[32 - index * 2 + 2]
				self.reward_flag_t[id].reward = data[32 - index * 2 + 1]
			end
		end
	end
	for k, v in pairs(protocol.type_flag_t) do
		if v.count ~= 0 then
			self.achieve_finish_cnt_t[v.eventid] = {}
			self.achieve_finish_cnt_t[v.eventid].count = v.count
		end
	end
	self:InsertTotalData()
	self:SetTotalChangeData()
	self:SortListData()
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_DATA_CHANGE)
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_DATA_INIT)
end

function AchieveData:SetSuccessData(protocol)
	if self.reward_flag_t[protocol.achieve_id] == nil then
		self.reward_flag_t[protocol.achieve_id] = {finish = 1, reward = 0}
	else
		self.reward_flag_t[protocol.achieve_id].finish = 1
	end
	self.badge_id = protocol.badge_id
	self:InsertData(protocol.achieve_id)
	self:SortIndex(protocol.achieve_id)
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_DATA_CHANGE)
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_STATE_CHANGE,protocol.achieve_id)
end

function AchieveData:SetTouchEvent(protocol)
	if self.achieve_finish_cnt_t[protocol.eventid] == nil then
		self.achieve_finish_cnt_t[protocol.eventid] = {}
		self.achieve_finish_cnt_t[protocol.eventid].count = protocol.achieve_count
	else
		self.achieve_finish_cnt_t[protocol.eventid].count = protocol.achieve_count
	end	

	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_DATA_CHANGE)
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_EVENT_CHANGE,protocol.eventid)
end

function AchieveData:SetRewardResultData(protocol)
	if self.reward_flag_t[protocol.achieve_id] == nil then
		self.reward_flag_t[protocol.achieve_id] = {finish = 0, reward = protocol.result}
	else
		self.reward_flag_t[protocol.achieve_id].reward = protocol.result
	end
	self:SortIndex(protocol.achieve_id)

	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_DATA_CHANGE)
	GlobalEventSystem:Fire(AchievementEventType.ACHIEVE_STATE_CHANGE,protocol.achieve_id)
end

function AchieveData:SetBadgeListData(protocol)
	self.badge_list = protocol.badge_list
end


--得到成就的完成状态和领取奖励的状态pa
function AchieveData:GetAwardState(id)
	return self.reward_flag_t[id] or {finish = 0, reward = 0}
end

function AchieveData:GetAchieveFinishCount(event_id)
	return  self.achieve_finish_cnt_t[event_id] or {count = 0}
end

function AchieveData:SetTotalConfigAchieveData()
	local consume_count = {}
	local  total_config = {}
	for i = 0, AchieveData.MaxAcheve do
		local config_tab = AchieveData.GetAchieveConfig(i)
		local event_config = AchieveData.GetAchieveEventConfig()
		if config_tab[1].isDelete == false then
			self.limit_id[i] = config_tab[1].openActiveId
			table.insert(total_config, config_tab)
		end
		-- if i >= 335  and i <= 454 then
		-- 	local event_id = config_tab[1].conds[1].eventId
		-- 	for k,v in pairs(event_config) do
		-- 		if v.id == event_id then
		-- 			if v.conds[2] ~= nil then
		-- 				if v.conds[2].params ~= nil then
		-- 					consume_count[i] = v.conds[2].params[1] 
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		-- else
			consume_count[i] = config_tab[1].conds[1].count
		-- end
		self.limit_data[i] = {data_list = {}}
		self.total_group[i] = {group = 0}
	end
	self.single_group_config = {}	
	for i = 1, AchieveData.Group do
		self.single_group_config[i] = {}
		for k,v in pairs(total_config) do
			if v[1].groupId == i - 1 then
				table.insert(self.single_group_config[i], v)
			end
		end	
		self.achieve_data[i] = {}
		local data_tab = self.single_group_config[i]
		for k,v in pairs(data_tab) do
				local limit_id = self.limit_id[v[1].id]
				self.total_group[v[1].id].group = i
				local consume_count = consume_count[v[1].id]
				local event_id = v[1].conds[1].eventId
				local bool_finish = self.reward_flag_t[v[1].id] and self.reward_flag_t[v[1].id].finish or 0
	 			local bool_reward =	self.reward_flag_t[v[1].id] and self.reward_flag_t[v[1].id].reward or 0

	 			local awards1 = 0
				local awards2 = 0
				if v[1].awards[1] then
					awards1 = v[1].awards[1].count
				end	
				if v[1].awards[2] then
					awards2 = v[1].awards[2].count
				end	
				local item_data = {name = v[1].name, index_id = v[1].id, finishs = bool_finish, limit_id = limit_id, event_id = event_id, consume = consume_count, rewards = bool_reward, current_index = i, award_1 = awards1, award_2 = awards2}
			if limit_id <= 0 then	
				table.insert(self.achieve_data[i], item_data)
			else
				table.insert(self.limit_data[limit_id].data_list, item_data)
			end
		end
	end
end

function AchieveData:GetGroupData(index)
	return self.single_group_config[index]
end

function AchieveData:GetChangQiData()
	local m = self.data_index_tab[1]
	return m > 0 and 1 or 0
end

function AchieveData:GetLoadingData()
	local m = self.data_index_tab[2]
	return m > 0 and 1 or 0
end

function AchieveData:GetGrowUpData()
	local m = self.data_index_tab[3]
	return m > 0 and 1 or 0
end

function AchieveData:GetXYCMData()
	local m = self.data_index_tab[4]
	return m > 0 and 1 or 0
end

function AchieveData:GetCopterData()
	local m = self.data_index_tab[5]
	return m > 0 and 1 or 0
end

function AchieveData:GetWingData()
	local m = self.data_index_tab[6]
	return m > 0 and 1 or 0
end

function AchieveData:GetStrenthenData()
	local m = self.data_index_tab[7]
	return m > 0 and 1 or 0
end

function AchieveData:GetJadeData()
	-- local m = self.data_index_tab[7]
	-- return m > 0 and 1 or 0
end

function AchieveData:GetGemData()
	-- local m = self.data_index_tab[8]
	-- return m > 0 and 1 or 0
end


function AchieveData:GetAchievementData()
	local n = 0 
	for i, v in ipairs(self.data_index_tab) do
		n = n + v
	end
	return n > 0 and 1 or 0
end

function AchieveData:GetMedalData()
	local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itDecoration)
	local num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE)
	if equip == nil then
		return 1 
	else
		local level = equip.compose_level
		local next_consume = AchieveData.Instance:GetConsume(5, level + 1)
		if next_consume == nil then
			return 0
		else
			local equip_level, cur_level = 0, 0
			equip_level = self:GetEquipLevel(equip_type, level + 1) or 300
			_, cur_level = self:GetEquipLevel(equip_type, level + 1)
			local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
			local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			if circle >= equip_level and level >= cur_level then
				if next_consume[1] and next_consume[1].count ~= nil then
					if num and num >= next_consume[1].count then
						return 1
					else
						return 0 
					end
				else
					return 0 
				end
			else
				return 0 
			end
		end
	-- else
	-- 	return 0 
	end
end

--设置总体数据
function AchieveData:SetTotalChangeData()
	self.data_index_tab = {}
	self.data_number_tab = {}
	for k,v in pairs(self.achieve_data) do
		local n = 0
		for k1,v1 in pairs(v) do
			if self.reward_flag_t[v1.index_id] then
				v1.finishs = self.reward_flag_t[v1.index_id].finish
				v1.rewards = self.reward_flag_t[v1.index_id].reward
				if v1.finishs == 1 and v1.rewards == 0 then
					n = n + 1
				end
			end
		end
		self.data_number_tab[k] = n
		self.data_index_tab[k] = n > 0 and 1 or 0
	end
end

--给所有数据排序、
function AchieveData:SortListData()
	for k,v in pairs(self.achieve_data) do
		local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
			return function(c, d)
				if c.rewards ~= d.rewards then
					return c.rewards < d.rewards
				elseif c.rewards == 0 then
					if c.finishs ~= d.finishs then
						return c.finishs > d.finishs
					end
				end
				return c.index_id < d.index_id
			end
		end
		table.sort(self.achieve_data[k], sort_list()) 
	end
end

--开始插入数据
function AchieveData:InsertTotalData()
	for k,v in pairs(self.single_group_config) do
		for k1,v1 in pairs(v) do
			if self.reward_flag_t[v1[1].id] then
				if self.reward_flag_t[v1[1].id].finish and self.reward_flag_t[v1[1].id].finish == 1 then
					if self.limit_data[v1[1].id] then
						local index = self.total_group[v1[1].id] and self.total_group[v1[1].id].group
						local data = self.limit_data[v1[1].id].data_list or 0
						if index and index ~= 0 and data ~= 0 then
							for k,v in pairs(data) do
								table.insert(self.achieve_data[index], v)
							end
						end
					end
				end
			end
		end
	end
end

function AchieveData:SortIndex(achieve_id)
	local index = self.total_group[achieve_id] and self.total_group[achieve_id].group
	if index and index ~= 0 then
		self:SetSingleIndexData(index)
	end
end

function AchieveData:InsertData(achieve_id)
	local index = self.total_group[achieve_id] and self.total_group[achieve_id].group
	local data = self.limit_data[achieve_id] and self.limit_data[achieve_id].data_list 
	if index ~= nil or data ~= nil then 
		for k,v in pairs(data) do
			table.insert(self.achieve_data[index], v)
		end
	end
end

--设置单个数据并得到当前是否是可操作的
function AchieveData:SetSingleIndexData(index)
	local n = 0
	for k,v in pairs(self.achieve_data[index]) do
		if self.reward_flag_t[v.index_id] then 
			v.finishs = self.reward_flag_t[v.index_id].finish
			v.rewards = self.reward_flag_t[v.index_id].reward
			if v.finishs == 1 and v.rewards == 0 then
				n = n + 1
			end
		end
	end
	self:SortListSingleData(index)
	local m = n > 0 and 1 or 0
	for i, v in ipairs(self.data_index_tab) do
		if i == index then
			self.data_number_tab[i] = n
			self.data_index_tab[i] = m
		end
	end
end

--给单个index排序
function AchieveData:SortListSingleData(index)
 	local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
		return function(c, d)
			if c.rewards ~= d.rewards then
				return c.rewards < d.rewards
			elseif c.rewards == 0 then
				if c.finishs ~= d.finishs then
					return c.finishs > d.finishs
				end
			end
			return c.index_id < d.index_id
		end
	end
	table.sort(self.achieve_data[index], sort_list())
end

function AchieveData:GetAchieveListData(index)
	return self.achieve_data[index]
end

function AchieveData:GetMinIndex(index)
	return self.data_index_tab[index]
end

function AchieveData:GetMinIndexT()
	return self.data_index_tab
end

function AchieveData:GetSignNum(index)
	return self.data_number_tab[index]
end

--根据类型获取配置
function AchieveData:GetConfigByType(type)
	return EquipFurnaceCfg[type]
end	

function AchieveData:GetConsume(type,level)
	local step,star = self:GetStepStar(level)
	local config = self:GetConfigByType(type) --得到对应类型的配置
	local currentStepConfig = config[step] --得到当前阶数配置
	if currentStepConfig then
		local currentConsumeConfig = currentStepConfig.upgradeConsumes
		if star < #currentConsumeConfig then
			return currentConsumeConfig[star]
		end	
	end
	step = step + 1
	star = 1
	currentStepConfig = config[step] 

	if currentStepConfig then
		currentConsumeConfig = currentStepConfig.upgradeConsumes
		return currentConsumeConfig[star]
	end	
	return nil
end	

function AchieveData:GetAttr(level)
	local attrConfig = ConfigManager.Instance:GetServerConfig("attr/FurnaceDecorationAttrsConfig")[1]
	if attrConfig then
		local step, star = self:GetStepStar(level)
		return attrConfig[step] and attrConfig[step][star] or {}
	end	
end

function AchieveData:GetStepStar(level)
	--print("总数:" , level)
	if level == 0 then
		return 1,1
	end	
	local step = math.floor((level - 1) * 0.1) + 1
	local star = (level - 1) % 10 + 1
	--print("阶数:" , step , star)
	return step,star
end	

function AchieveData:GetStepStarConfig(level)
	local step, star = self:GetStepStar(level)
	local config = self:GetConfigByType(5) --得到对应类型的配置
	return config[star]
end	

--得到装备配置
function AchieveData:GetEquipLevel(type,level)
	local step,star = self:GetStepStar(level)
	local config = self:GetConfigByType(5) --得到对应类型的配置
	local currentStepConfig = config[step] 		--得到当前阶数配置
	local equip_level = 0 
	local cur_level = 0
	if currentStepConfig then
		local item_cfg = ItemData.Instance:GetItemConfig(currentStepConfig.itemId)
		if item_cfg == nil then return end
		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				equip_level = v.value
			end
			if v.cond == ItemData.UseCondition.ucLevel then
				cur_level = v.value
			end
		end
	end
	return equip_level, cur_level
end

function AchieveData:GetActivityIntroduceCfg()
	for k,v in pairs(self.achieve_data) do
		for k1, v1 in pairs(v) do
			for k2, v2 in pairs(ClientActIntroduceCfg) do
				local scene_id = Scene.Instance:GetSceneId()
				if v1.finishs == 0 and v1.index_id == v2.achieve_id and scene_id == v2.scene_id then
					ViewManager.Instance:Open(ViewName.ActivityIntroduce)
				end	
			end
		end
	end
end