-- 副本通用 失败显示BOSS剩余血量
SCFBPassOrFailedNotice = SCFBPassOrFailedNotice or BaseClass(BaseProtocolStruct)
function SCFBPassOrFailedNotice:__init()
	self.msg_type = 5429
end

function SCFBPassOrFailedNotice:Decode()
	self.monster_id = MsgAdapter.ReadUShort()
	self.hp_percent = MsgAdapter.ReadShort()
end

--蜜月祝福信息
SCQingyuanBlessInfo = SCQingyuanBlessInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanBlessInfo:__init()
	self.msg_type = 5438

	self.is_fetch_bless_reward = 0
	self.bless_days = 0
	self.lover_bless_days = 0
end

function SCQingyuanBlessInfo:Decode()
	self.is_fetch_bless_reward = MsgAdapter.ReadInt()
	self.bless_days = MsgAdapter.ReadInt()
	self.lover_bless_days = MsgAdapter.ReadInt()
end

--婚宴被邀请列表
SCQingyuanHunyanInviteInfo = SCQingyuanHunyanInviteInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanHunyanInviteInfo:__init()
	self.msg_type = 5439
end

function SCQingyuanHunyanInviteInfo:DecodeInvite()
	local data = {}
	data.man_name = MsgAdapter.ReadStrN(32)
	data.women_name = MsgAdapter.ReadStrN(32)
	data.yanhui_fb_key = MsgAdapter.ReadInt()
	data.hunyan_type = MsgAdapter.ReadInt()
	data.garden_num = MsgAdapter.ReadInt()			--已采集次数
	return data
end

function SCQingyuanHunyanInviteInfo:Decode()
	local count = MsgAdapter.ReadInt()
	self.invite_list = {}
	for i=1,count do
		self.invite_list[i] = self:DecodeInvite()
	end
end

--经验副本
--领取奖励
CSExpFBFetchChapterReward = CSExpFBFetchChapterReward or BaseClass(BaseProtocolStruct)
function CSExpFBFetchChapterReward:__init()
	self.msg_type = 5452

	self.seq = 0
end

function CSExpFBFetchChapterReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(0)
end

---------------------------------------
--剧情本
---------------------------------------
--请求剧情本信息
CSStoryFBGetInfo = CSStoryFBGetInfo or BaseClass(BaseProtocolStruct)
function CSStoryFBGetInfo:__init()
	self.msg_type = 5400
end

function CSStoryFBGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

local function DecodeStoryFBInfo()
	local t = {}
	t.is_pass = MsgAdapter.ReadShort()
	t.today_times = MsgAdapter.ReadShort()

	return t
end

--剧情本信息返回
SCStoryFBInfo = SCStoryFBInfo or BaseClass(BaseProtocolStruct)
function SCStoryFBInfo:__init()
	self.msg_type = 5401
end

function SCStoryFBInfo:Decode()
	self.info_list = {}
	for i = 0, GameEnum.FB_STORY_MAX_COUNT - 1 do
		self.info_list[i] = DecodeStoryFBInfo()
	end
end

-- --剧情本场景信息
-- SCStoryFBInfo = SCStoryFBInfo or BaseClass(BaseProtocolStruct)
-- function SCStoryFBInfo:__init()
-- 	self.msg_type = 5402
-- end

-- function SCStoryFBInfo:Decode()
-- 	self.is_finish = MsgAdapter.ReadChar()
-- 	self.pass_level = MsgAdapter.ReadChar()
-- 	self.is_pass = MsgAdapter.ReadChar()
-- 	self.is_active_leave_fb = MsgAdapter.ReadChar()				-- 主动退出副本 1为主动
-- 	self.pass_time_s = MsgAdapter.ReadInt()
-- 	self.coin = MsgAdapter.ReadInt()
-- 	self.exp = MsgAdapter.ReadInt()
-- end

--剧情本界面信息
SCStoryFBRoleInfo = SCStoryFBRoleInfo or BaseClass(BaseProtocolStruct)
function SCStoryFBRoleInfo:__init()
	self.msg_type = 5403
end

function SCStoryFBRoleInfo:Decode()
	self.open_chapter = MsgAdapter.ReadShort()  --开启到的副本章节,从0开始
	self.open_level = MsgAdapter.ReadShort()	--开启到的副本章节中的等级,从0开始
	MsgAdapter.ReadShort()
	local max_count = MsgAdapter.ReadShort()
	local count = 0

	self.chapter_list = {}
	for i = 0, DailyData.GetStoryFbCfgMaxChapter() do
		self.chapter_list[i] = {}
		self.chapter_list[i].chapter = i
		self.chapter_list[i].level_list = {}
		for j = 0, DailyData.GetStoryCfgMaxLevel() - 1 do
			count = count + 1
			if count <= max_count then
				self.chapter_list[i].level_list[j] = {}
				self.chapter_list[i].level_list[j].max_star = MsgAdapter.ReadChar()
				self.chapter_list[i].level_list[j].day_times = MsgAdapter.ReadChar()
				self.chapter_list[i].level_list[j].buy_times = MsgAdapter.ReadShort()
				self.chapter_list[i].level_list[j].min_time = MsgAdapter.ReadShort()
				self.chapter_list[i].level_list[j].global_min_time = MsgAdapter.ReadShort()
				self.chapter_list[i].level_list[j].winner_name = MsgAdapter.ReadStrN(32)
				self.chapter_list[i].level_list[j].level = j
			end
		end
	end
end

--剧情本本奖池
SCStoryRollPool = SCStoryRollPool or BaseClass(BaseProtocolStruct)
function SCStoryRollPool:__init()
	self.msg_type = 5405

	self.roll_list = {}
end

function SCStoryRollPool:Decode()
	self.roll_list = {}
	for i = 1, 4 do
		local roll_item = {}
		roll_item.item_id = MsgAdapter.ReadShort()
		roll_item.is_bind = MsgAdapter.ReadChar()
		roll_item.num = MsgAdapter.ReadChar()
		table.insert(self.roll_list, roll_item)
	end
end

--剧情本翻牌信息
SCStoryRollInfo = SCStoryRollInfo or BaseClass(BaseProtocolStruct)
function SCStoryRollInfo:__init()
	self.msg_type = 5406
end

function SCStoryRollInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.star = MsgAdapter.ReadChar()
	self.hit_seq = MsgAdapter.ReadChar()				--真正命中的数据

	self.clint_click_index = MsgAdapter.ReadShort()		--玩家点击的索引（翻这张位置的牌，但真实数据用hit_seq）
	MsgAdapter.ReadShort()
end

--请求翻牌
CSStoryRollReq = CSStoryRollReq or BaseClass(BaseProtocolStruct)
function CSStoryRollReq:__init()
	self.msg_type = 5407
	self.clint_click_index = 0
end

function CSStoryRollReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.clint_click_index)
	MsgAdapter.WriteShort(0)
end

---------------------------------------
--日常副本
---------------------------------------
-- 请求日常副本信息
CSDailyFBGetRoleInfo = CSDailyFBGetRoleInfo or BaseClass(BaseProtocolStruct)
function CSDailyFBGetRoleInfo:__init()
	self.msg_type = 5410
end

function CSDailyFBGetRoleInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 经验本首通奖励领取
CSExpFBRetchFirstRewardReq = CSExpFBRetchFirstRewardReq or BaseClass(BaseProtocolStruct)
function CSExpFBRetchFirstRewardReq:__init()
	self.msg_type = 5554
	self.fetch_reward_wave = 0
end

function CSExpFBRetchFirstRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.fetch_reward_wave)
end

--日常副本信息（属于场景逻辑那块）
SCDailyFBInfo = SCDailyFBInfo or BaseClass(BaseProtocolStruct)
function SCDailyFBInfo:__init()
	self.msg_type = 5412
end

function SCDailyFBInfo:Decode()
	self.dailyfb_type = MsgAdapter.ReadChar()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_pass = MsgAdapter.ReadChar()
	self.is_active_leave_fb = MsgAdapter.ReadChar()

	self.pass_time_s = MsgAdapter.ReadInt()
	self.m_reward_exp = MsgAdapter.ReadInt()
	self.m_reward_coin = MsgAdapter.ReadInt()

	--经验本： param1 = 波数
	--铜币本： param1 = 波数  param2 = 刷下波的时间
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
end

---------------------------------------
--爬塔副本
---------------------------------------
-- 请求爬塔副本信息
CSPataFbAllInfo = CSPataFbAllInfo or BaseClass(BaseProtocolStruct)
function CSPataFbAllInfo:__init()
	self.msg_type = 5421
end

function CSPataFbAllInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--返回爬塔副本所有信息
SCPataFbAllInfo = SCPataFbAllInfo or BaseClass(BaseProtocolStruct)
function SCPataFbAllInfo:__init()
	self.msg_type = 5422
end

-- local function DecodePataFBInfo()
-- 	local t = {}
-- 	t.pass_level = MsgAdapter.ReadShort()
-- 	t.today_level = MsgAdapter.ReadShort()

-- 	return t
-- end

function SCPataFbAllInfo:Decode()
	-- self.info_list = {}
	-- for i = 0, GameEnum.FB_TOWER_MAX_COUNT - 1 do
		-- self.info_list[i] = DecodePataFBInfo()
	-- end
	self.pass_level = MsgAdapter.ReadShort()
	self.today_level = MsgAdapter.ReadShort()
end

--请求VIP副本信息
CSVipFbAllInfoReq = CSVipFbAllInfoReq or BaseClass(BaseProtocolStruct)
function CSVipFbAllInfoReq:__init()
	self.msg_type = 5423
end

function CSVipFbAllInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--返回VIP副本信息
SCVipFbAllInfo = SCVipFbAllInfo or BaseClass(BaseProtocolStruct)
function SCVipFbAllInfo:__init()
	self.msg_type = 5424
end

function SCVipFbAllInfo:Decode()
	self.is_pass_flag = MsgAdapter.ReadInt()

	self.info_list = {}
	for i = 0, GameEnum.FB_VIP_MAX_COUNT - 1 do
		self.info_list[i] = {today_times = MsgAdapter.ReadChar()}
	end
end

---------------------------------------
--塔防组队副本
---------------------------------------
-- 组队塔防副本内信息
-- SCTeamTowerDefendInfo = SCTeamTowerDefendInfo or BaseClass(BaseProtocolStruct)
-- function SCTeamTowerDefendInfo:__init()
-- 	self.msg_type = 5430
-- end

-- function SCTeamTowerDefendInfo:Decode()
-- 	self.reason = MsgAdapter.ReadInt()  --下发原因 1.初始化 2.下一波
-- 	self.time_out_stamp = MsgAdapter.ReadUInt()
-- 	self.is_finish = MsgAdapter.ReadShort()
-- 	self.is_pass = MsgAdapter.ReadShort()
-- 	self.pass_time_s = MsgAdapter.ReadInt()
-- 	self.life_tower_left_hp = MsgAdapter.ReadInt()
-- 	self.life_tower_left_maxhp = MsgAdapter.ReadInt()
-- 	self.curr_wave = MsgAdapter.ReadInt()
-- 	self.next_wave_refresh_time = MsgAdapter.ReadInt()
-- 	self.clear_wave = MsgAdapter.ReadInt() --消灭波数
-- 	self.mode = MsgAdapter.ReadInt()
-- end

-- 组队塔防副本警告
SCTeamTowerDefendWarning = SCTeamTowerDefendWarning or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendWarning:__init()
	self.msg_type = 5431
end

function SCTeamTowerDefendWarning:Decode()
	self.warning_type = MsgAdapter.ReadShort()
	self.percent = MsgAdapter.ReadShort()
end

-- 请求下一波
CSTeamTowerDefendNextWave = CSTeamTowerDefendNextWave or BaseClass(BaseProtocolStruct)
function CSTeamTowerDefendNextWave:__init()
	self.msg_type = 5432
end

function CSTeamTowerDefendNextWave:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 组队装备副本掉落拾取信息
SCFbPickItemInfo = SCFbPickItemInfo or BaseClass(BaseProtocolStruct)
function SCFbPickItemInfo:__init()
	self.msg_type = 5443
	self.item_count = 0
	self.item_list = {}
end

function SCFbPickItemInfo:Decode()
	self.item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do
		self.item_list[i] = ProtocolStruct.ReadItemDataWrapper()
	end
end

---------------------------------------
--情缘副本购买BUFF
---------------------------------------
CSQingYuanBuyFBBuff = CSQingYuanBuyFBBuff or BaseClass(BaseProtocolStruct)
function CSQingYuanBuyFBBuff:__init()
	self.msg_type = 5440
end

function CSQingYuanBuyFBBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

---------------------------------------
--副本组队房间
---------------------------------------

-- 副本房间进入确认通知
SCTeamFbRoomEnterAffirm = SCTeamFbRoomEnterAffirm or BaseClass(BaseProtocolStruct)
function SCTeamFbRoomEnterAffirm:__init()
	self.msg_type = 5448
end

function SCTeamFbRoomEnterAffirm:Decode()
	self.team_type = MsgAdapter.ReadInt()
	self.mode = MsgAdapter.ReadInt()
	self.layer = MsgAdapter.ReadInt()
end

--副本房间列表
SCTeamFbRoomList = SCTeamFbRoomList or BaseClass(BaseProtocolStruct)
function SCTeamFbRoomList:__init()
	self.msg_type = 5449
end

function SCTeamFbRoomList:Decode()
	self.team_type = MsgAdapter.ReadInt()
	self.room_list = {}
	self.count = MsgAdapter.ReadInt()
	for i = 1, self.count do
		local room = {}
		room.team_index = MsgAdapter.ReadInt()
		room.leader_name = MsgAdapter.ReadStrN(32)
		room.leader_capability = MsgAdapter.ReadInt()
		room.limit_capability = MsgAdapter.ReadInt()
		room.avatar_key_big = MsgAdapter.ReadUInt()
		room.avatar_key_small = MsgAdapter.ReadUInt()
		room.menber_num = MsgAdapter.ReadChar()
		room.mode = MsgAdapter.ReadChar()
		room.leader_sex = MsgAdapter.ReadChar()
		room.leader_prof = MsgAdapter.ReadChar()
		room.leader_uid = MsgAdapter.ReadInt()
		room.layer = MsgAdapter.ReadChar()
		room.assign_mode = MsgAdapter.ReadChar()
		room.is_must_check = MsgAdapter.ReadChar()
		room.reserve_2 = MsgAdapter.ReadChar()
		table.insert(self.room_list, room)
	end
end

-- 组队副本房间请求操作
CSTeamFbRoomOperate = CSTeamFbRoomOperate or BaseClass(BaseProtocolStruct)
function CSTeamFbRoomOperate:__init()
	self.msg_type = 5450
end

function CSTeamFbRoomOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
	MsgAdapter.WriteInt(self.param5)
end

---------------------------------------
--迷宫仙府副本
---------------------------------------
--接触到假的传送点时，发这个协议。服务端会判断是否角色在这个传送点附近
CSMgxfTeamFbTouchDoor = CSMgxfTeamFbTouchDoor or BaseClass(BaseProtocolStruct)
function CSMgxfTeamFbTouchDoor:__init()
	self.msg_type = 5445

	self.layer = -1
	self.door_index = - 1
end

function CSMgxfTeamFbTouchDoor:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.layer)
	MsgAdapter.WriteShort(self.door_index)
end

SCMgxfTeamFbSceneLogicInfo = SCMgxfTeamFbSceneLogicInfo or BaseClass(BaseProtocolStruct)
function SCMgxfTeamFbSceneLogicInfo:__init()
	self.msg_type = 5446
end

function SCMgxfTeamFbSceneLogicInfo:Decode()
	self.time_out_stamp = MsgAdapter.ReadUInt()
	self.is_finish = MsgAdapter.ReadShort()
	self.is_pass = MsgAdapter.ReadShort()
	self.pass_time_s = MsgAdapter.ReadInt()
	self.mode = MsgAdapter.ReadInt()
	self.layer = MsgAdapter.ReadShort() --玩家自己所处的层
	self.kill_hide_boos_num = MsgAdapter.ReadChar()
	self.kill_end_boss_num = MsgAdapter.ReadChar()

	--传送点当前状态，请改为常量，可根据自己需要重新定义结构。。。by bzw
	self.door_status_list = {}
	for layer = 0, 6 do   	  			--每层
		self.door_status_list[layer] = {}
		for index = 0, 4 do  			--传送点
			local door_obj = {}
			door_obj.layer = layer  	--层从0算起
			door_obj.index = index  	--每次传送点从0算起
			door_obj.status = MsgAdapter.ReadInt()
			self.door_status_list[layer][index] = door_obj
		end
	end
end

--=========================挑战副本品质材料=========================--
--挑战副本购买次数
CSChallengeFBBuyJoinTimes = CSChallengeFBBuyJoinTimes or BaseClass(BaseProtocolStruct)
function CSChallengeFBBuyJoinTimes:__init()
	self.msg_type = 5451
	self.level = 0
end

function CSChallengeFBBuyJoinTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.level)
	MsgAdapter.WriteShort(0)
end

--请求挑战副本信息
CSChallengeReqInfo = CSChallengeReqInfo or BaseClass(BaseProtocolStruct)
function CSChallengeReqInfo:__init()
	self.msg_type = 5456
end

function CSChallengeReqInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--挑战副本信息返回
SCChallengeFBInfo = SCChallengeFBInfo or BaseClass(BaseProtocolStruct)
function SCChallengeFBInfo:__init()
	self.msg_type = 5407
end

function SCChallengeFBInfo:Decode()
	self.info_vo = {}
	self.info_vo.join_times = MsgAdapter.ReadShort()
	self.info_vo.buy_join_times = MsgAdapter.ReadShort()
	self.info_vo.level_list = {}

	for i = 1, COMMON_CONSTS.LEVEL_MAX_COUNT do
		local lev_vo = {}
		lev_vo.index = i
		MsgAdapter.ReadUInt()
		lev_vo.is_pass = MsgAdapter.ReadChar()
		lev_vo.fight_layer = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		table.insert(self.info_vo.level_list, lev_vo)
	end
end

--挑战副本结束
SCChallengePassLevel = SCChallengePassLevel or BaseClass(BaseProtocolStruct)
function SCChallengePassLevel:__init()
	self.msg_type = 5408
	self.info = {}
end

function SCChallengePassLevel:Decode()
	self.info = {}
	self.info.level = MsgAdapter.ReadShort()
	self.info.is_pass = MsgAdapter.ReadChar()  					-- 0失败 1通关 2副本中更新
	self.info.fight_layer = MsgAdapter.ReadChar()
	self.info.is_active_leave_fb = MsgAdapter.ReadChar()		-- 是否主动退出 1为主动
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

--挑战副本每一层的消息
SCChallengeLayerInfo = SCChallengeLayerInfo or BaseClass(BaseProtocolStruct)
function SCChallengeLayerInfo:__init()
	self.msg_type = 5419
	self.info = {}
end

function SCChallengeLayerInfo:Decode()
	self.info.is_pass = MsgAdapter.ReadChar()
	self.info.is_finish = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

--=========================阶段副本商城道具=========================--
--请求阶段副本信息
CSPhaseFBInfoReq = CSPhaseFBInfoReq or BaseClass(BaseProtocolStruct)
function CSPhaseFBInfoReq:__init()
	self.msg_type = 5465
end

function CSPhaseFBInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

local function DecodePhaseFBInfo()
	local t = {}
	t.is_pass = MsgAdapter.ReadChar()
	t.is_pass_today = MsgAdapter.ReadChar()
	t.today_times = MsgAdapter.ReadShort()
	return t
end

--Boss击杀列表信息请求
CSBossKillerInfoReq = CSBossKillerInfoReq or BaseClass(BaseProtocolStruct)
function CSBossKillerInfoReq:__init()
	self.msg_type = 5466
	self.boss_type = 0
	self.boss_id = 0
	self.scene_id = 0
end

function CSBossKillerInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.boss_type)
	MsgAdapter.WriteInt(self.boss_id)
	MsgAdapter.WriteInt(self.scene_id)
end

--阶段副本信息返回
SCPhaseFBInfo = SCPhaseFBInfo or BaseClass(BaseProtocolStruct)
function SCPhaseFBInfo:__init()
	self.msg_type = 5418
end

function SCPhaseFBInfo:Decode()
	self.info_list = {}
	for i = 0, GameEnum.FB_PHASE_MAX_COUNT - 1 do
		self.info_list[i] = DecodePhaseFBInfo()
	end
end

--所有副本扫荡结果
SCAutoFBRewardDetail = SCAutoFBRewardDetail or BaseClass(BaseProtocolStruct)
function SCAutoFBRewardDetail:__init()
	self.msg_type = 5417
end

function SCAutoFBRewardDetail:Decode()
	self.fb_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.reward_coin = MsgAdapter.ReadInt()
	self.reward_exp = MsgAdapter.ReadInt()
	self.reward_xianhun = MsgAdapter.ReadInt()
	self.reward_yuanli = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()

	self.item_list = {}
	for i= 1, self.item_count do
		self.item_list[i] = {}
		self.item_list[i].item_id = MsgAdapter.ReadUShort()
		self.item_list[i].num = MsgAdapter.ReadShort()
		self.item_list[i].is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
	end
end

--副本掉落统计
SCFBDropCount = SCFBDropCount or BaseClass(BaseProtocolStruct)
function SCFBDropCount:__init()
	self.msg_type = 5420
end

function SCFBDropCount:Decode()
	self.get_coin = MsgAdapter.ReadInt()
	self.get_item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.get_item_count do
		self.item_list[i] = {}
		self.item_list[i].num = MsgAdapter.ReadUShort()
		self.item_list[i].item_id = MsgAdapter.ReadUShort()
	end
end

	----------------------多人副本--------------------------

-- 重置挑战本
CSChallengeFBResetLevel = CSChallengeFBResetLevel or BaseClass(BaseProtocolStruct)
function CSChallengeFBResetLevel:__init()
	self.msg_type = 5467
	self.level = 0
end

function CSChallengeFBResetLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.level)
	MsgAdapter.WriteShort(0)

end



---------------------足迹系统-----------------------
--接收足迹
SCFootPrintInfo = SCFootPrintInfo or BaseClass(BaseProtocolStruct)
function SCFootPrintInfo:__init()
	self.msg_type = 5424
	self.select_effect = 0
	self.active_flag = 0
end

function SCFootPrintInfo:Decode()
	self.select_effect = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.active_flag = MsgAdapter.ReadShort()
end


--发送足迹信息
CSFootPrintSelectEffect = CSFootPrintSelectEffect or BaseClass(BaseProtocolStruct)
function CSFootPrintSelectEffect:__init()
	self.msg_type = 5468
	self.select_effect_footprint = 0
end


function CSFootPrintSelectEffect:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.select_effect_footprint)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
end



--------------情缘-----------------

-- 情缘副本基本信息下发
SCQingyuanInfo = SCQingyuanInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanInfo:__init()
	self.msg_type = 5425
	self.join_fb_times = 0
	self.buy_fb_join_times = 0
	self.is_hunyan_already_open = 0
	self.qingyuan_value = 0
	self.yanhui_fb_key = 0
end

function SCQingyuanInfo:Decode()
	self.join_fb_times = MsgAdapter.ReadChar()
	self.buy_fb_join_times = MsgAdapter.ReadChar()
	self.is_hunyan_already_open = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.qingyuan_value = MsgAdapter.ReadInt()
	self.yanhui_fb_key = MsgAdapter.ReadInt()
end

-- 情缘副本场景信息下发
SCQingyuanFBInfo = SCQingyuanFBInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanFBInfo:__init()
	self.msg_type = 5426
	self.curr_wave = 0
	self.max_wave_count = 0
	self.is_pass = 0
	self.is_finish = 0
	self.next_refresh_monster_time = 0
	self.add_qingyuan_value = 0
	self.buy_buff_times = 0
	self.buff_out_timestamp = 0
	self.per_wave_remain_time = 0
	self.total_get_uplevel_stuffs = 0
	self.exp = 0
	self.kick_out_timestamp = 0
end

function SCQingyuanFBInfo:Decode()
	self.curr_wave = MsgAdapter.ReadChar()
	self.max_wave_count = MsgAdapter.ReadChar()
	self.is_pass = MsgAdapter.ReadChar()
	self.is_finish = MsgAdapter.ReadChar()
	self.next_refresh_monster_time = MsgAdapter.ReadInt()
	self.add_qingyuan_value = MsgAdapter.ReadShort()
	self.buy_buff_times = MsgAdapter.ReadShort()
	self.buff_out_timestamp = MsgAdapter.ReadInt()
	self.per_wave_remain_time = MsgAdapter.ReadInt()
	self.total_get_uplevel_stuffs = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.kick_out_timestamp = MsgAdapter.ReadInt()
end

-- 情缘装备信息
SCQingyuanEuipmentInfo = SCQingyuanEuipmentInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanEuipmentInfo:__init()
	self.msg_type = 5427
end

function SCQingyuanEuipmentInfo:Decode()
	self.consume_num = MsgAdapter.ReadInt()
	self.baoji_num = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.star = MsgAdapter.ReadInt()
	self.lover_level = MsgAdapter.ReadInt()
	self.lover_ring_item_id = MsgAdapter.ReadShort()
	self.ring_item_id = MsgAdapter.ReadShort()
	self.lover_star = MsgAdapter.ReadShort()
	self.lover_prof = MsgAdapter.ReadShort()
end

-- 伴侣情缘值下发
SCQingyuanMateValueSend = SCQingyuanMateValueSend or BaseClass(BaseProtocolStruct)
function SCQingyuanMateValueSend:__init()
	self.msg_type = 5428
end

function SCQingyuanMateValueSend:Decode()
	self.mate_qingyuan_value = MsgAdapter.ReadInt()
end

-- 伴侣信息下发
SCQingyuanLoverInfo = SCQingyuanLoverInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanLoverInfo:__init()
	self.msg_type = 5441
end

function SCQingyuanLoverInfo:Decode()
	self.lover_level = MsgAdapter.ReadInt()
	self.lover_ring_item_id = MsgAdapter.ReadShort()
	self.lover_star = MsgAdapter.ReadShort()
end

SCQingyuanFBRewardRecordInfo = SCQingyuanFBRewardRecordInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanFBRewardRecordInfo:__init()
	self.msg_type = 5442
	self.is_finish = 0
	self.is_pass = 0
	self.reward_list = {}
end

function SCQingyuanFBRewardRecordInfo:Decode()
	self.is_finish = MsgAdapter.ReadShort()
	self.is_pass = MsgAdapter.ReadShort()

	local item_count = MsgAdapter.ReadInt()
	self.reward_list = {}
	for i = 1, item_count do
		local reward_data = {}
		reward_data.item_id = MsgAdapter.ReadUShort()
		reward_data.num = MsgAdapter.ReadShort()
		table.insert(self.reward_list, reward_data)
	end
end

-- 请求打宝boss信息
CSGetBossInfoReq = CSGetBossInfoReq or BaseClass(BaseProtocolStruct)
function CSGetBossInfoReq:__init()
	self.msg_type = 5463
	self.enter_type = 0
end

function CSGetBossInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.enter_type)
end

-- 请求情缘副本基本信息
CSQingyuanReqInfo = CSQingyuanReqInfo or BaseClass(BaseProtocolStruct)
function CSQingyuanReqInfo:__init()
	self.msg_type = 5469
end

function CSQingyuanReqInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 购买情缘副本进入次数
CSQingyuanBuyJoinTimes = CSQingyuanBuyJoinTimes or BaseClass(BaseProtocolStruct)
function CSQingyuanBuyJoinTimes:__init()
	self.msg_type = 5470
end

function CSQingyuanBuyJoinTimes:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 情缘装备升级
CSQingyuanUpLevel = CSQingyuanUpLevel or BaseClass(BaseProtocolStruct)

function CSQingyuanUpLevel:__init()
	self.msg_type = 5471
	self.stuff_id = 0
	self.repeat_tiems = 1
	self.is_auto_buy = 0
end

function CSQingyuanUpLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.stuff_id)
	MsgAdapter.WriteShort(self.repeat_tiems)
	MsgAdapter.WriteInt(self.is_auto_buy)
end

-- 取下情缘装备
CSQingyuanTakeOffEquip = CSQingyuanTakeOffEquip or BaseClass(BaseProtocolStruct)

function CSQingyuanTakeOffEquip:__init()
	self.msg_type = 5472
end

function CSQingyuanTakeOffEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	print_log("#################CSQingyuanTakeOffEquip")
end

-- 情缘装备信息请求
CSQingyuanReqEquipInfo = CSQingyuanReqEquipInfo or BaseClass(BaseProtocolStruct)

function CSQingyuanReqEquipInfo:__init()
	self.msg_type = 5473
end

function CSQingyuanReqEquipInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求伴侣情缘值查询
CSQingyuanMateValueQuery = CSQingyuanMateValueQuery or BaseClass(BaseProtocolStruct)

function CSQingyuanMateValueQuery:__init()
	self.msg_type = 5474
end

function CSQingyuanMateValueQuery:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求离婚协议
CSQingyuanDivorceReqCS = CSQingyuanDivorceReqCS or BaseClass(BaseProtocolStruct)

function CSQingyuanDivorceReqCS:__init()
	self.msg_type = 5475
	self.is_forced_divorce= 0
end

function CSQingyuanDivorceReqCS:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_forced_divorce)
end

-- 副本请求下一关
CSFBReqNextLevel = CSFBReqNextLevel or BaseClass(BaseProtocolStruct)

function CSFBReqNextLevel:__init()
	self.msg_type = 5476
end

function CSFBReqNextLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


--------------BOSS-----------------

-- 进入Boss之家请求
CSEnterBossFamily = CSEnterBossFamily or BaseClass(BaseProtocolStruct)

function CSEnterBossFamily:__init()
	self.msg_type = 5477

	self.enter_type = 0
	self.scene_id = 0
	self.is_buy_dabao_times = 0
	self.boss_id = 0
end

function CSEnterBossFamily:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.enter_type)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteChar(self.is_buy_dabao_times)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteUShort(self.boss_id)
end

--仙盟
SCGuildFBInfo = SCGuildFBInfo or BaseClass(BaseProtocolStruct)
function SCGuildFBInfo:__init()
	self.msg_type = 5478

	self.notify_reason = 0
	self.curr_wave = 0
	self.next_wave_time = 0
	self.wave_enemy_count = 0
	self.wave_enemy_max = 0
	self.is_pass = 0
	self.is_finish = 0
	self.hp = 0
	self.max_hp = 0
	self.kick_role_time = 0
end

function SCGuildFBInfo:Decode()
	self.notify_reason = MsgAdapter.ReadShort()
	self.curr_wave =  MsgAdapter.ReadShort()
	self.next_wave_time =  MsgAdapter.ReadUInt()
	self.wave_enemy_count =  MsgAdapter.ReadShort()
	self.wave_enemy_max =  MsgAdapter.ReadShort()
	self.is_pass =  MsgAdapter.ReadShort()
	self.is_finish =  MsgAdapter.ReadShort()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.kick_role_time = MsgAdapter.ReadUInt()
end

-- 请求怪物生成点列表信息
CSReqMonsterGeneraterList = CSReqMonsterGeneraterList or BaseClass(BaseProtocolStruct)

function CSReqMonsterGeneraterList:__init()
	self.msg_type = 5479

	self.scene_id = 0
end

function CSReqMonsterGeneraterList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_id)
end

-- 下发当前场景怪物生成点列表信息
SCMonsterGeneraterList = SCMonsterGeneraterList or BaseClass(BaseProtocolStruct)

function SCMonsterGeneraterList:__init()
	self.msg_type = 5480

	self.scene_id = 0
	self.boss_list = {}
end

function SCMonsterGeneraterList:Decode()
	local boss_count = MsgAdapter.ReadInt()
	local scene_id = MsgAdapter.ReadInt()
	self.scene_id = scene_id
	self.boss_list = {}
	for i=1,boss_count do
		local vo = {}
		vo.boss_id = MsgAdapter.ReadInt()
		vo.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_list[i] = vo
	end
end

-- 请求妖兽广场状态
CSGetYaoShouGuangChangState = CSGetYaoShouGuangChangState or BaseClass(BaseProtocolStruct)

function CSGetYaoShouGuangChangState:__init()
	self.msg_type = 5481
end

function CSGetYaoShouGuangChangState:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 下发妖兽广场状态
SCYaoShouGuangChangState = SCYaoShouGuangChangState or BaseClass(BaseProtocolStruct)

function SCYaoShouGuangChangState:__init()
	self.msg_type = 5482

	self.status = 0
	self.next_status_time = 0
	self.next_standby_time = 0
	self.next_stop_time = 0
	self.syt_max_score = 0
	self.datais_valid = 0
	self.quanfu_topscore = 0
	self.quanfu_topscore_uid = 0
	self.quanfu_topscore_name = 0
	self.next_freetimes_invalid_time = 0
end

function SCYaoShouGuangChangState:Decode()
	self.status = MsgAdapter.ReadInt()
	self.next_status_time = MsgAdapter.ReadUInt()
	self.next_standby_time = MsgAdapter.ReadUInt()
	self.next_stop_time = MsgAdapter.ReadUInt()
	self.datais_valid = MsgAdapter.ReadInt()
	self.syt_max_score = MsgAdapter.ReadInt()
	self.quanfu_topscore = MsgAdapter.ReadInt()
	self.quanfu_topscore_uid = MsgAdapter.ReadInt()
	self.quanfu_topscore_name = MsgAdapter.ReadStrN(32)

end

-- 下发妖兽广场副本信息
SCYaoShouGuangChangFBInfo = SCYaoShouGuangChangFBInfo or BaseClass(BaseProtocolStruct)

function SCYaoShouGuangChangFBInfo:__init()
	self.msg_type = 5483

	self.reason = 0
	self.wave_index = 0
	self.fb_lv = 0
	self.user_list = {}
end

function SCYaoShouGuangChangFBInfo:Decode()
	self.reason = MsgAdapter.ReadInt()
	self.wave_index = MsgAdapter.ReadInt()
	self.fb_lv = MsgAdapter.ReadInt()
	self.role_num = MsgAdapter.ReadInt()
	self.monster_num = MsgAdapter.ReadInt()
	user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i = 1, user_count do
		self.user_list[i] = {}
		self.user_list[i].uid = MsgAdapter.ReadInt()
		self.user_list[i].score = MsgAdapter.ReadInt()
	end
end

-- 请求妖兽广场奖励
CSGetYaoShouGuangChangReward = CSGetYaoShouGuangChangReward or BaseClass(BaseProtocolStruct)

function CSGetYaoShouGuangChangReward:__init()
	self.msg_type = 5484
	self.times = 0
end

function CSGetYaoShouGuangChangReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.times)
end

-- 下发妖兽广场奖励
SCNotifyYaoShouGuangChangReward = SCNotifyYaoShouGuangChangReward or BaseClass(BaseProtocolStruct)

function SCNotifyYaoShouGuangChangReward:__init()
	self.msg_type = 5485

	self.score = 0
	self.exp = 0
	self.bind_coin = 0
end

function SCNotifyYaoShouGuangChangReward:Decode()
	self.score = MsgAdapter.ReadUInt()
	self.exp = MsgAdapter.ReadUInt()
	self.bind_coin = MsgAdapter.ReadUInt()
end

-- 请求进入妖兽广场
CSEnterYaoShouGuangChang = CSEnterYaoShouGuangChang or BaseClass(BaseProtocolStruct)

function CSEnterYaoShouGuangChang:__init()
	self.msg_type = 5486
	self.is_buy_times = 0
end

function CSEnterYaoShouGuangChang:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_buy_times)
end

-- 捉鬼副本状态
SCZhuaGuiFbInfo = SCZhuaGuiFbInfo or BaseClass(BaseProtocolStruct)

function SCZhuaGuiFbInfo:__init()
	self.msg_type = 5487
end

function SCZhuaGuiFbInfo:Decode()
	self.reason = MsgAdapter.ReadInt()
	self.monster_count = MsgAdapter.ReadInt()
	self.ishave_boss = MsgAdapter.ReadShort()
	self.boss_isdead = MsgAdapter.ReadShort()
	self.kick_time = MsgAdapter.ReadUInt()

	self.zhuagui_info_list = {}
	for i=1,GameEnum.MAX_TEAM_MEMBER_NUM do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt()
		vo.get_hunli = MsgAdapter.ReadInt()
		vo.get_mojing = MsgAdapter.ReadInt()
		vo.kill_boss_count = MsgAdapter.ReadInt()
		self.zhuagui_info_list[i] = vo
	end

	self.enter_role_num = MsgAdapter.ReadShort()
	self.item_count = MsgAdapter.ReadShort()

	self.zhuagui_item_list = {}
	for i=1,self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.is_bind = MsgAdapter.ReadChar()
		vo.is_first = MsgAdapter.ReadChar()
		vo.num = MsgAdapter.ReadInt()
		self.zhuagui_item_list[i] = vo
	end
end

-- 请求锁妖塔状态
CSGetSuoYaoTaState = CSGetSuoYaoTaState or BaseClass(BaseProtocolStruct)

function CSGetSuoYaoTaState:__init()
	self.msg_type = 5490
end

function CSGetSuoYaoTaState:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 下发锁妖塔状态
SCSuoYaoTaState = SCSuoYaoTaState or BaseClass(BaseProtocolStruct)

function SCSuoYaoTaState:__init()
	self.msg_type = 5491

	self.status = 0
	self.next_status_time = 0
	self.next_standby_time = 0
	self.next_stop_time = 0
	self.syt_max_score = 0
	self.datais_valid = 0
	self.quanfu_topscore = 0
	self.quanfu_topscore_uid = 0
	self.quanfu_topscore_name = 0
	self.next_freetimes_invalid_time = 0
end

function SCSuoYaoTaState:Decode()
	self.status = MsgAdapter.ReadInt()
	self.next_status_time = MsgAdapter.ReadUInt()
	self.next_standby_time = MsgAdapter.ReadUInt()
	self.next_stop_time = MsgAdapter.ReadUInt()
	self.datais_valid = MsgAdapter.ReadInt()
	self.syt_max_score = MsgAdapter.ReadInt()
	self.quanfu_topscore = MsgAdapter.ReadInt()
	self.quanfu_topscore_uid = MsgAdapter.ReadInt()
	self.quanfu_topscore_name = MsgAdapter.ReadStrN(32)
end

-- 下发锁妖塔副本信息
SCSuoYaoTaFBInfo = SCSuoYaoTaFBInfo or BaseClass(BaseProtocolStruct)

function SCSuoYaoTaFBInfo:__init()
	self.msg_type = 5492

	self.reason = 0
	self.wave_index = 0
	self.fb_lv = 0
	self.task_list = {}
	self.user_list = {}
end

function SCSuoYaoTaFBInfo:Decode()
	self.reason = MsgAdapter.ReadInt()
	self.fb_lv = MsgAdapter.ReadInt()
	self.task_list = {}
	for i = 1, GameEnum.SUOYAOTA_TASK_MAX do
		self.task_list[i] = {}
		self.task_list[i].task_index = i
		self.task_list[i].task_type = MsgAdapter.ReadInt()
		self.task_list[i].param_id = MsgAdapter.ReadInt()
		self.task_list[i].param_num = MsgAdapter.ReadInt()
		self.task_list[i].param_max = MsgAdapter.ReadInt()
	end
	local user_count = MsgAdapter.ReadInt()
	self.user_list = {}
	for i = 1, user_count do
		self.user_list[i] = {}
		self.user_list[i].uid = MsgAdapter.ReadInt()
		self.user_list[i].score = MsgAdapter.ReadInt()
	end
end

-- 请求锁妖塔奖励
CSGetSuoYaoTaReward = CSGetSuoYaoTaReward or BaseClass(BaseProtocolStruct)

function CSGetSuoYaoTaReward:__init()
	self.msg_type = 5493
	self.times = 0
end

function CSGetSuoYaoTaReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.times)
end

-- 下发锁妖塔奖励
SCNotifySuoYaoTaReward = SCNotifySuoYaoTaReward or BaseClass(BaseProtocolStruct)

function SCNotifySuoYaoTaReward:__init()
	self.msg_type = 5494

	self.score = 0
	self.exp = 0
	self.bind_coin = 0
end

function SCNotifySuoYaoTaReward:Decode()
	self.score = MsgAdapter.ReadUInt()
	self.exp = MsgAdapter.ReadUInt()
	self.bind_coin = MsgAdapter.ReadUInt()
end

-- 请求进入锁妖塔
CSEnterSuoYaoTa = CSEnterSuoYaoTa or BaseClass(BaseProtocolStruct)

function CSEnterSuoYaoTa:__init()
	self.msg_type = 5495
	self.is_buy_times = 0
end

function CSEnterSuoYaoTa:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_buy_times)
end

-- 请求仙盟副本守卫位置
CSGetGuildFBGuardPos = CSGetGuildFBGuardPos or BaseClass(BaseProtocolStruct)

function CSGetGuildFBGuardPos:__init()
	self.msg_type = 5496
end

function CSGetGuildFBGuardPos:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 下发仙盟副本守卫位置
SCGuildFBGuardPos = SCGuildFBGuardPos or BaseClass(BaseProtocolStruct)

function SCGuildFBGuardPos:__init()
	self.msg_type = 5497

	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function SCGuildFBGuardPos:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- Boss死亡广播
SCWorldBossDead = SCWorldBossDead or BaseClass(BaseProtocolStruct)

function SCWorldBossDead:__init()
	self.msg_type = 5488

	self.boss_id = 0
end

function SCWorldBossDead:Decode()
	self.boss_id = MsgAdapter.ReadInt()
end

--秘境降魔抓鬼个人信息
SCZhuaguiAddPerInfo = SCZhuaguiAddPerInfo or BaseClass(BaseProtocolStruct)

function SCZhuaguiAddPerInfo:__init()
	self.msg_type = 5489

	self.couple_hunli_add_per = 0
	self.couple_boss_add_per = 0
	self.team_hunli_add_per = 0
	self.team_boss_add_per = 0
end

function SCZhuaguiAddPerInfo:Decode()
	self.couple_hunli_add_per = MsgAdapter.ReadShort()
	self.couple_boss_add_per = MsgAdapter.ReadShort()
	self.team_hunli_add_per = MsgAdapter.ReadShort()
	self.team_boss_add_per = MsgAdapter.ReadShort()
end

---------------------------------------
--副本通用
---------------------------------------
-- 跨服组队本信息
SCCrossTeamFbInfo = SCCrossTeamFbInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFbInfo:__init()
	self.msg_type = 5498

	self.user_count = 0
	self.user_info = {}
end

function SCCrossTeamFbInfo:Decode()
	self.user_info = {}
	self.user_count = MsgAdapter.ReadInt()
	for i = 1, self.user_count do
		self.user_info[i] = {}
		self.user_info[i].user_name = MsgAdapter.ReadStrN(32)
		self.user_info[i].dps = MsgAdapter.ReadInt()
	end
end

--副本逻辑同步信息
SCFBSceneLogicInfo = SCFBSceneLogicInfo or BaseClass(BaseProtocolStruct)
function SCFBSceneLogicInfo:__init()
	self.msg_type = 5499

	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function SCFBSceneLogicInfo:Decode()
	self.time_out_stamp = MsgAdapter.ReadUInt()  				--副本超时结束时间戳（可用于倒计时）
	self.scene_type = MsgAdapter.ReadChar()						--场景类型
	self.is_finish = MsgAdapter.ReadChar()						--是否结束
	self.is_pass = MsgAdapter.ReadChar()						--是否通关
	self.is_active_leave_fb = MsgAdapter.ReadChar()				--是否主动退出

	self.total_boss_num = MsgAdapter.ReadShort()				--boss总数量
	self.total_allmonster_num = MsgAdapter.ReadShort()			--怪物总数量（包括普通怪和boss)
	self.kill_boss_num = MsgAdapter.ReadShort()					--已击杀boss数量
	self.kill_allmonster_num = MsgAdapter.ReadShort()			--已击杀怪物总数量（包括普通怪和boss)

	self.pass_time_s = MsgAdapter.ReadInt()						--进入副本到目前经过的时间（少）
	self.coin = MsgAdapter.ReadInt()							--铜币
	self.exp = MsgAdapter.ReadInt()								--经验

	self.param1 = MsgAdapter.ReadInt() 							--波数
	self.param2 = MsgAdapter.ReadInt()
	self.param3 = MsgAdapter.ReadInt()
end

-- 经验副本所有信息
SCDailyFBRoleInfo = SCDailyFBRoleInfo or BaseClass(BaseProtocolStruct)
function SCDailyFBRoleInfo:__init()
	self.msg_type = 5411
end

function SCDailyFBRoleInfo:Decode()
	self.expfb_today_pay_times = 0
	self.expfb_today_enter_times = 0
	self.last_enter_fb_time = 0
	self.max_exp = 0
	self.max_wave = 0

	-- 临时处理协议报错
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

CSEquipFBGetInfo = CSEquipFBGetInfo or BaseClass(BaseProtocolStruct)

function CSEquipFBGetInfo:__init()
	self.msg_type = 5457
	self.operate_type = 0 			-- 1.请求单人装备信息 0 请求组队信息
end

function CSEquipFBGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
end

--组队副本须臾幻境
SCEquipFBResult = SCEquipFBResult or BaseClass(BaseProtocolStruct)
function SCEquipFBResult:__init()
	self.msg_type = 5409
end

function SCEquipFBResult:Decode()
	self.is_over = MsgAdapter.ReadInt()
	self.is_passed = MsgAdapter.ReadInt()
	self.can_jump = MsgAdapter.ReadInt()
	self.is_first_passed = MsgAdapter.ReadInt()
end