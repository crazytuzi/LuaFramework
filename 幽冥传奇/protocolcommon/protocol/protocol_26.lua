-- 获取玩家的信息
CSGetPlayerInformationReq = CSGetPlayerInformationReq or BaseClass(BaseProtocolStruct)
function CSGetPlayerInformationReq:__init()
	self:InitMsgType(26, 1)
	self.player_name = ""
	self.player_icon = 0
	self.player_grade = 0
	self.player_profession = 0
	self.player_id = 0
	self.player_society_name = ""
	self.player_society_position = 0
	self.player_master_name = ""
	self.player_troops_id  = 0
	self.player_sex = 0
	self.player_camp_id = 0
	self.player_camp_position = 0
	self.count = 0
	self.blood_brother_number = {}
	self.role_name =""
end

function CSGetPlayerInformationReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.player_name)
	MsgAdapter.WriteUChar(self.player_icon)
	MsgAdapter.WriteUChar(self.player_grade)
	MsgAdapter.WriteUChar(self.player_profession)
	MsgAdapter.WriteUInt(self.player_id)
	MsgAdapter.WriteStr(self.player_society_name)
	MsgAdapter.WriteUChar(self.player_society_position)
	MsgAdapter.WriteStr(self.player_master_name)
	MsgAdapter.WriteUChar(self.player_troops_id)
	MsgAdapter.WriteUChar(self.player_sex)
	MsgAdapter.WriteUChar(self.player_camp_id)
	MsgAdapter.WriteUChar(self.player_camp_position)
	MsgAdapter.WriteUChar(self.count)
	for i,v in ipairs(self.blood_brother_number) do
		MsgAdapter.WriteStr(self.role_name)
	end
end

--点击确定需要退出游戏
CSClickSureQuitGameReq = CSClickSureQuitGameReq or BaseClass(BaseProtocolStruct)
function CSClickSureQuitGameReq:__init()
	self:InitMsgType(26, 2)
end

function CSClickSureQuitGameReq:Encode()
	self:WriteBegin()
end

--boss击杀掉落请求
CSBossDropReq = CSBossDropReq or BaseClass(BaseProtocolStruct)
function CSBossDropReq:__init()
	self:InitMsgType(26, 3)
end

function CSBossDropReq:Encode()
	self:WriteBegin()
end

--每日签到
CSEveryDaySignReq = CSEveryDaySignReq or BaseClass(BaseProtocolStruct)
function CSEveryDaySignReq:__init()
	self:InitMsgType(26, 29)
	self.sign_which_day = 0
end

function CSEveryDaySignReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.sign_which_day)
end

--游戏设置保存GameOptions
CSGameOptionsSaveReq = CSGameOptionsSaveReq or BaseClass(BaseProtocolStruct)
function CSGameOptionsSaveReq:__init()
	self:InitMsgType(26, 30)
	self.count = 0   --最大18
	self.save_list ={}
end

function CSGameOptionsSaveReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.count)	
	for i = 0, 17 do
		if self.save_list[i] then
			MsgAdapter.WriteUChar(i)	
			MsgAdapter.WriteInt(self.save_list[i].value)
		end
	end
end

--是否使用登陆器登陆Lander
CSBoolUseLanderLoadingReq = CSBoolUseLanderLoadingReq or BaseClass(BaseProtocolStruct)
function CSBoolUseLanderLoadingReq:__init()
	self:InitMsgType(26, 31)
	self.bool_use = 0   --1是, 0不是
end

function CSBoolUseLanderLoadingReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.bool_use)
end

--请求buff数据
CSGetBuffDataReq = CSGetBuffDataReq or BaseClass(BaseProtocolStruct)
function CSGetBuffDataReq:__init()
	self:InitMsgType(26, 33)
	self.buff_type = 0   
end

function CSGetBuffDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.buff_type)
end

--改名字rename 
CSRenameReq = CSRenameReq or BaseClass(BaseProtocolStruct)
function CSRenameReq:__init()
	self:InitMsgType(26, 40)
	self.item_series = 0 
	self.rename_name = 0
end

function CSRenameReq:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_series)
	MsgAdapter.WriteStr(self.rename_name)
end

--vip清洗红名
CSVipCleanUpRedNameReq = CSVipCleanUpRedNameReq or BaseClass(BaseProtocolStruct)
function CSVipCleanUpRedNameReq:__init()
	self:InitMsgType(26, 41)
	self.pk_value = 0 
end

function CSVipCleanUpRedNameReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.pk_value)
end

--获取新手帮助处理框(我要变强功能)
CSGetHelpNewcomerProcessBoxReq = CSGetHelpNewcomerProcessBoxReq or BaseClass(BaseProtocolStruct)
function CSGetHelpNewcomerProcessBoxReq:__init()
	self:InitMsgType(26, 63)
	self.help_name = "" 
end

function CSGetHelpNewcomerProcessBoxReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.help_name)
end

--材料副本领取奖励
CSRecMaterialFubenReward = CSRecMaterialFubenReward or BaseClass(BaseProtocolStruct)
function CSRecMaterialFubenReward:__init()
	self:InitMsgType(26, 64)
	self.reward_type = 0  --1正常领取, 2双倍领取
	self.fuben_index = 0
end

function CSRecMaterialFubenReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_type)
	MsgAdapter.WriteUChar(self.fuben_index)
end

--强制修改名字
CSForceRenameReq = CSForceRenameReq or BaseClass(BaseProtocolStruct)
function CSForceRenameReq:__init()
	self:InitMsgType(26, 68)
	self.rename_name = ""
end

function CSForceRenameReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.rename_name)
end

--升级潜能
CSUpgradeProficiencyReq = CSUpgradeProficiencyReq or BaseClass(BaseProtocolStruct)
function CSUpgradeProficiencyReq:__init()
	self:InitMsgType(26, 70)
	self.proficiency_type = 0
end

function CSUpgradeProficiencyReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.proficiency_type)
end

--请求我的排行榜数据 返回(26, 81)
CSMyselfRankingListDataReq = CSMyselfRankingListDataReq or BaseClass(BaseProtocolStruct)
function CSMyselfRankingListDataReq:__init()
	self:InitMsgType(26, 71)
	self.rankinglist_type = 0
end

function CSMyselfRankingListDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.rankinglist_type)
end

--请求排行榜数据 返回(26, 82)
CSRankingListDataReq = CSRankingListDataReq or BaseClass(BaseProtocolStruct)
function CSRankingListDataReq:__init()
	self:InitMsgType(26, 72)
	self.rankinglist_type = 0
	self.rankinglist_page_id = 0
end

function CSRankingListDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.rankinglist_type)
	MsgAdapter.WriteUChar(self.rankinglist_page_id)
end

--塔防开始刷怪
CSTafangStartReq = CSTafangStartReq or BaseClass(BaseProtocolStruct)
function CSTafangStartReq:__init()
	self:InitMsgType(26, 73)
end

function CSTafangStartReq:Encode()
	self:WriteBegin()
end

--请求洪荒指环记录
CSRingHonghuangRecord = CSRingHonghuangRecord or BaseClass(BaseProtocolStruct)
function CSRingHonghuangRecord:__init()
	self:InitMsgType(26, 74)
end

function CSRingHonghuangRecord:Encode()
	self:WriteBegin()
end

--剧情中请求服务端开始表演
CSServerStartPlay = CSServerStartPlay or BaseClass(BaseProtocolStruct)
function CSServerStartPlay:__init()
	self:InitMsgType(26, 75)
end

function CSServerStartPlay:Encode()
	self:WriteBegin()
end

--请求领取超级宝箱
CSRecSuperChest = CSRecSuperChest or BaseClass(BaseProtocolStruct)
function CSRecSuperChest:__init()
	self:InitMsgType(26, 76)
end

function CSRecSuperChest:Encode()
	self:WriteBegin()
end

-- 请求"跨服副本"数据 返回(26, 86)
CSCrossServerCopyData = CSCrossServerCopyData or BaseClass(BaseProtocolStruct)
function CSCrossServerCopyData:__init()
	self:InitMsgType(26, 86)
	self.copy_id = nil -- 跨服副本id
end

function CSCrossServerCopyData:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.copy_id)
end

-- 设置一个称号
CSTitleReq = CSTitleReq or BaseClass(BaseProtocolStruct)
function CSTitleReq:__init()
	self:InitMsgType(26, 87)
	self.title1 = 0
	self.title2 = 0
end

function CSTitleReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.title1)
	MsgAdapter.WriteUChar(self.title2)
end

-- 请求领取每日礼包(26, 88)
CSGetDailyGiftDagReq = CSGetDailyGiftDagReq or BaseClass(BaseProtocolStruct)
function CSGetDailyGiftDagReq:__init()
	self:InitMsgType(26, 88)
	self.index = 0
end

function CSGetDailyGiftDagReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

--===================================下发==================================
--下发玩家的信息
SCPlayerInformation = SCPlayerInformation or BaseClass(BaseProtocolStruct)
function SCPlayerInformation:__init()
	self:InitMsgType(26, 1)
	self.player_name =""
	self.player_icon_id = 0
	self.player_grade = 0
	self.player_profession = 0
	self.player_id = 0
	self.player_society_name =""
	self.player_society_position = 0
end

function SCPlayerInformation:Decode()
	self.player_name = MsgAdapter.ReadStr()
	self.player_icon_id = MsgAdapter.ReadUChar()
	self.player_grade = MsgAdapter.ReadUShort()
	self.player_profession = MsgAdapter.ReadUChar()
	self.player_id = MsgAdapter.ReadUInt()
	self.player_society_name = MsgAdapter.ReadStr()
	self.player_society_position = MsgAdapter.ReadUChar()
end

--下发服务器的时间
SCServerTime = SCServerTime or BaseClass(BaseProtocolStruct)
function SCServerTime:__init()
	self:InitMsgType(26, 8)
	self.server_time = 0
	self.open_server_time = 0	--开服时间
	self.gm_level = 0			--GM权限
	self.combined_day = 0
end

function SCServerTime:Decode()
	self.server_time = CommonReader.ReadServerUnixTime()
	self.open_server_time = MsgAdapter.ReadUInt() + COMMON_CONSTS.SERVER_TIME_OFFSET
	self.gm_level = MsgAdapter.ReadUChar()
	self.combined_day = MsgAdapter.ReadUInt()
end

--给客户端发送一个倒计时
SCSendCountDown = SCSendCountDown or BaseClass(BaseProtocolStruct)
function SCSendCountDown:__init()
	self:InitMsgType(26, 11)
	self.count_down_time = 0
end

function SCSendCountDown:Decode()
	self.count_down_time = MsgAdapter.ReadUInt()
end

--添加下属
SCAddSubordinate = SCAddSubordinate or BaseClass(BaseProtocolStruct)
function SCAddSubordinate:__init()
	self:InitMsgType(26, 16)
	self.subordinate_type = 0
end

function SCAddSubordinate:Decode()
	self.subordinate_type = MsgAdapter.ReadLL()
end

--删除下属
SCDeleteSubordinate = SCDeleteSubordinate or BaseClass(BaseProtocolStruct)
function SCDeleteSubordinate:__init()
	self:InitMsgType(26, 17)
	self.subordinate_type = 0
end

function SCDeleteSubordinate:Decode()
	self.subordinate_type = MsgAdapter.ReadLL()
end

--播放全屏特效
SCPlayFullScreenEffect= SCPlayFullScreenEffect or BaseClass(BaseProtocolStruct)
function SCPlayFullScreenEffect:__init()
	self:InitMsgType(26, 18)
	self.effect_id = 0
	self.play_time = 0
end

function SCPlayFullScreenEffect:Decode()
	self.effect_id = MsgAdapter.ReadUShort()
	self.play_time = MsgAdapter.ReadInt()
end

--播放全屏特效，与消息18的区别是，这个是代码实现的特效
SCCodeRealizePlayFullScreenEffect = SCCodeRealizePlayFullScreenEffect or BaseClass(BaseProtocolStruct)
function SCCodeRealizePlayFullScreenEffect:__init()
	self:InitMsgType(26, 19)
	self.effect_id = 0
	self.play_time = 0
	self.pos_x = 0   --相对屏幕x
	self.pos_y = 0   --相对屏幕y
end

function SCCodeRealizePlayFullScreenEffect:Decode()
	self.effect_id = MsgAdapter.ReadUShort()
	self.play_time = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

--有玩家经验改变
SCPlayerChangeExperience = SCPlayerChangeExperience or BaseClass(BaseProtocolStruct)
function SCPlayerChangeExperience:__init()
	self:InitMsgType(26, 20)
	self.player_name = ""
	self.add_experience_value = 0
end

function SCPlayerChangeExperience:Decode()
	self.player_name = MsgAdapter.ReadStr()
	self.add_experience_value = MsgAdapter.ReadInt()
end

--杀怪数量
-- SCKillMonsterNum = SCKillMonsterNum or BaseClass(BaseProtocolStruct)
-- function SCKillMonsterNum:__init()
-- 	self:InitMsgType(26, 22)
-- 	self.kill_num = 0
-- end

-- function SCKillMonsterNum:Decode()
-- 	MsgAdapter.ReadUChar()
-- 	MsgAdapter.ReadInt()
-- 	self.kill_num = MsgAdapter.ReadInt()
-- end

--改变实体模型
SCChangeEntityModel= SCChangeEntityModel or BaseClass(BaseProtocolStruct)
function SCChangeEntityModel:__init()
	self:InitMsgType(26, 26)
	self.model_item = 0  
	self.model_id = 0
end

function SCChangeEntityModel:Decode()
	self.model_item = CommonReader.ReadSeries()
	self.model_id = MsgAdapter.ReadInt()
end

-- 下发开服第几天, 角色登录初始化时下发和新的一天也下发
SCOpenServerDays = SCOpenServerDays or BaseClass(BaseProtocolStruct)
function SCOpenServerDays:__init()
	self:InitMsgType(26, 28)
	self.open_server_day = 0			--开服第几天
	self.combined_server_day = 0		--合服第几天
	self.combined_server_time = 0
	self.open_server_time = 0
end

function SCOpenServerDays:Decode()
	self.open_server_day = MsgAdapter.ReadInt()
	self.combined_server_day = MsgAdapter.ReadInt()
	self.combined_server_time = CommonReader.ReadServerUnixTime()
	self.open_server_time = CommonReader.ReadServerUnixTime()
end

--下发游戏设置的数据
SCGameSetData= SCGameSetData or BaseClass(BaseProtocolStruct)
function SCGameSetData:__init()
	self:InitMsgType(26, 31)
	self.save_list = {}
end

function SCGameSetData:Decode()
	local count = MsgAdapter.ReadInt()
	self.save_list = {}
	for i = 1, count do
		local vo = {}
		vo.index = MsgAdapter.ReadUChar()		--从0开始
		vo.value = MsgAdapter.ReadInt()
		vo.type = 1
		self.save_list[vo.index] = vo
	end
end

--下发删除全屏场景特效
SCDeleteFullScreenEffect = SCDeleteFullScreenEffect or BaseClass(BaseProtocolStruct)
function SCDeleteFullScreenEffect:__init()
	self:InitMsgType(26, 32)
	self.effect_id = 0
end

function SCDeleteFullScreenEffect:Decode()
	self.effect_id = MsgAdapter.ReadUShort()
end

--返回BUff数据
SCReturnBuffData = SCReturnBuffData or BaseClass(BaseProtocolStruct)
function SCReturnBuffData:__init()
	self:InitMsgType(26, 33)
	self.buff_count ={}
end

function SCReturnBuffData:Decode()
	local count = MsgAdapter.ReadUChar()
	for i=1,count do
		local vo  = {}
		vo.buff_type =  MsgAdapter.ReadUShort()
		vo.buff_group =  MsgAdapter.ReadUChar()
		vo.buff_remain_time =  MsgAdapter.ReadInt()
		vo.buff_name =  MsgAdapter.ReadStr()
		vo.buff_value_type =  MsgAdapter.ReadUChar()
		vo.buff_value =  MsgAdapter.ReadUShort()
		vo.buff_action_cycle=  MsgAdapter.ReadUShort()
		vo.buff_icon =  MsgAdapter.ReadUChar()
		self.buff_count[i] = vo
	end
end

--开启引导箭头提升
SCOpenGuideArrowPromote = SCOpenGuideArrowPromote or BaseClass(BaseProtocolStruct)
function SCOpenGuideArrowPromote:__init()
	self:InitMsgType(26, 62)
	self.view_id = 0
	self.interface_x = 0
	self.interface_y = 0
	self.direction = 0
end

function SCOpenGuideArrowPromote:Decode()
	self.view_id = MsgAdapter.ReadUShort()
	self.interface_x = MsgAdapter.ReadFloat()
	self.interface_y = MsgAdapter.ReadFloat()
	self.direction = MsgAdapter.ReadUChar()
end

--关闭引导箭头提升
SCCloseGuideArrowPromote = SCCloseGuideArrowPromote or BaseClass(BaseProtocolStruct)
function SCCloseGuideArrowPromote:__init()
	self:InitMsgType(26, 63)
	self.view_id = 0
end

function SCCloseGuideArrowPromote:Decode()
	self.view_id = MsgAdapter.ReadUShort()
end

--Boss信息
SCBossInfo = SCBossInfo or BaseClass(BaseProtocolStruct)
function SCBossInfo:__init()
	self:InitMsgType(26, 64)
	self.boss_list = {}
end

function SCBossInfo:Decode()
	self.boss_list = {}
	local now_time = Status.NowTime
	for i = 1, MsgAdapter.ReadUShort() do
		self.boss_list[i] = {
			boss_id = MsgAdapter.ReadInt(),
			refresh_time = MsgAdapter.ReadUInt() * 0.001,
			boss_type = MsgAdapter.ReadUChar(),
			scene_id = MsgAdapter.ReadInt(),
			now_time = now_time,
			type_boss = MsgAdapter.ReadUChar(),
		}
	end
end

--新手帮助, 我要变强, 这个跟旧的不一样的了, 需要改
SCNewcomerHelp = SCNewcomerHelp or BaseClass(BaseProtocolStruct)
function SCNewcomerHelp:__init()
	self:InitMsgType(26, 68)
	self.function_name = ""
end

function SCNewcomerHelp:Decode()
	self.function_name = MsgAdapter.ReadStr()
end

--进入副本场景，初始化活动面板
SCEnterFubenInit = SCEnterFubenInit or BaseClass(BaseProtocolStruct)
function SCEnterFubenInit:__init()
	self:InitMsgType(26, 69)
	self.fuben_id = 0
	self.fuben_name = ""
	self.fuben_left_time = 0
end

function SCEnterFubenInit:Decode()
	self.fuben_id = MsgAdapter.ReadInt()
	self.fuben_type = MsgAdapter.ReadUChar()
	self.fuben_name = MsgAdapter.ReadStr()
	self.fuben_left_time = MsgAdapter.ReadUInt()
	
	-- self.fuben_info = {}
	-- if self.fuben_type == FubenType.Main then
	-- elseif self.fuben_type == FubenType.PersonalBoss then
	-- elseif self.fuben_type == FubenType.Material then
	-- elseif self.fuben_type == FubenType.Guild then
	-- elseif self.fuben_type == FubenType.Strength then
	-- 	self.fuben_info = {
	-- 		Level = MsgAdapter.ReadUShort() + 1,
	-- 		left_award_num = MsgAdapter.ReadUInt(),
	-- 	}
	-- end
end

--打开挂机引导
SCOpenOnHookGuide = SCOpenOnHookGuide or BaseClass(BaseProtocolStruct)
function SCOpenOnHookGuide:__init()
	self:InitMsgType(26, 72)
	self.on_hook_type = 0   --0打开设置挂机的窗口, 1自动打怪
end

function SCOpenOnHookGuide:Decode()
	self.on_hook_type = MsgAdapter.ReadUChar()
end

--强制改名
SCForceRename = SCForceRename or BaseClass(BaseProtocolStruct)
function SCForceRename:__init()
	self:InitMsgType(26, 77)
end

function SCForceRename:Decode()
end

--累积经验
-- SCFubenCumulativeExp = SCFubenCumulativeExp or BaseClass(BaseProtocolStruct)
-- function SCFubenCumulativeExp:__init()
-- 	self:InitMsgType(26, 79)
-- 	self.cumulative_exp = 0
-- 	self.loss_exp = 0
-- end

-- function SCFubenCumulativeExp:Decode()
-- 	self.cumulative_exp = MsgAdapter.ReadUInt()
-- 	self.loss_exp = MsgAdapter.ReadUInt()
-- end

--返回我的排行榜数据
SCReturnMyRankinglistData= SCReturnMyRankinglistData or BaseClass(BaseProtocolStruct)
function SCReturnMyRankinglistData:__init()
	self:InitMsgType(26, 81)
	self.rankinglist_type = 0 
	self.myself_ranking = 0
end

function SCReturnMyRankinglistData:Decode()
	self.rankinglist_type = MsgAdapter.ReadUChar()
	self.myself_ranking = MsgAdapter.ReadInt()
end

--返回排行榜数据
SCReturnRankinglistData = SCReturnRankinglistData or BaseClass(BaseProtocolStruct)
function SCReturnRankinglistData:__init()
	self:InitMsgType(26, 82)
	self.rankinglist_type = 0
	self.rankinglist_list = {}
end

function SCReturnRankinglistData:Decode()
	self.rankinglist_type = MsgAdapter.ReadUChar()
	local count = MsgAdapter.ReadUChar()
	self.rankinglist_list = {}
	for i = 1, count do
		self.rankinglist_list[i] = {
			rankinglist_type = self.rankinglist_type,
			role_id = MsgAdapter.ReadUInt(),
			role_name = MsgAdapter.ReadStr(),
			role_profession = MsgAdapter.ReadUChar(),
			sex = MsgAdapter.ReadUChar(),
			ranking_value = MsgAdapter.ReadUInt(),
			society_name = MsgAdapter.ReadStr(),
		}
	end
end

-- 签到返回结果
SCGetEveryDaySignResult = SCGetEveryDaySignResult or BaseClass(BaseProtocolStruct)
function SCGetEveryDaySignResult:__init()
	self:InitMsgType(26, 83)
	self.get_reward_result = 0   -- (uchar)1成功, 0失败
end

function SCGetEveryDaySignResult:Decode()
	self.get_reward_result = MsgAdapter.ReadUChar()
end

-- 下发购买洪荒指环记录
SCRingHonghuangRecord = SCRingHonghuangRecord or BaseClass(BaseProtocolStruct)
function SCRingHonghuangRecord:__init()
	self:InitMsgType(26, 84)
	self.record_type = 0
	self.record_num = 0
	self.record_list = {}
end

function SCRingHonghuangRecord:Decode()
	self.record_type = MsgAdapter.ReadUChar()
	self.record_num = MsgAdapter.ReadUChar()

	if self.record_type == 1 then 
		self.record_list = {}
		for i=1,self.record_num do
			local vo = {}
			vo.id = MsgAdapter.ReadUShort()
 			vo.type = MsgAdapter.ReadUChar()
 			vo.count = MsgAdapter.ReadUChar()
 			vo.times = MsgAdapter.ReadUChar()
 			vo.level = MsgAdapter.ReadUChar()
			vo.name = MsgAdapter.ReadStr()
			self.record_list[i] = vo
		end
	elseif self.record_type == 2 then
		local vo = {}
		vo.id = MsgAdapter.ReadUShort()
 		vo.type = MsgAdapter.ReadUChar()
 		vo.count = MsgAdapter.ReadUChar()
 		vo.times = MsgAdapter.ReadUChar()
 		vo.level = MsgAdapter.ReadUChar()
		vo.name = MsgAdapter.ReadStr()
		table.insert(self.record_list, vo)
	end
	
end

-- 下发超级宝箱领取状态标记
SCSuperChestState = SCSuperChestState or BaseClass(BaseProtocolStruct)
function SCSuperChestState:__init()
	self:InitMsgType(26, 85)
	self.flag = 0		-- 0不可领取，1可领取，2已领取
end

function SCSuperChestState:Decode()
	self.flag = MsgAdapter.ReadUChar()
end

-- 接收"跨服副本"数据 请求(26, 86)
SCCrossServerCopyData = SCCrossServerCopyData or BaseClass(BaseProtocolStruct)
function SCCrossServerCopyData:__init()
	self:InitMsgType(26, 86)
	self.scene_num = 0

	self.scene_list = {}
	self.boss_list = {}
end

function SCCrossServerCopyData:Decode()
	self.copy_id = MsgAdapter.ReadInt() -- 跨服副本id
	self.scene_num = MsgAdapter.ReadUChar() -- 跨服副本的场景数量
	self.scene_list = {}		
	self.boss_list = {}
	for i1 = 1, self.scene_num do
		local scene_id = MsgAdapter.ReadInt() -- 场景id
		self.scene_list[scene_id] = { --跨服场景数据列表
			scene_id = scene_id,
			player_num = MsgAdapter.ReadUShort(), -- 当前场景玩家数量
			boss_num = MsgAdapter.ReadInt(), -- boss数量
		}

		local now_time = Status.NowTime
		for i2 = 1, self.scene_list[scene_id].boss_num do
			local boss_id = MsgAdapter.ReadInt() -- boss id
			self.boss_list[boss_id] = { -- 跨服boss数据列表
				boss_id = boss_id,
				scene_id = scene_id,
				refresh_time = MsgAdapter.ReadUInt() * 0.001 + Status.NowTime, -- 下一次刷新时间, 0为已刷新 单位：秒
				monster_type = MsgAdapter.ReadInt(), -- 怪物类型
				player_id = MsgAdapter.ReadInt(), -- 归属者id
				player_name = MsgAdapter.ReadStr(), -- 归属者名
				now_time = now_time, -- 接收数据的时间(用于效准)
			}
		end
	end
end


-- "未知暗殿"泡点经验
SCUnknownDarkHouseExpResult = SCUnknownDarkHouseExpResult or BaseClass(BaseProtocolStruct)
function SCUnknownDarkHouseExpResult:__init()
	self:InitMsgType(26, 87)
	self.role_name = ""
	self.exp_num = 0
end

function SCUnknownDarkHouseExpResult:Decode()
	self.role_name = MsgAdapter.ReadStr()
	self.exp_num = MsgAdapter.ReadUInt()
	self.exp_mul = MsgAdapter.ReadUInt()
end

-- 接收特殊效果信息
SCSpecialEffInfo = SCSpecialEffInfo or BaseClass(BaseProtocolStruct)
function SCSpecialEffInfo:__init()
	self:InitMsgType(26, 88)
	self.type = 0 --特殊效果类型, 1篝火
	self.state = 0 -- 角色特殊效果的状态, 1在篝火范围, 2不在篝火范围
	self.now_time = 0
	self.left_time = 0
	self.ppl_qty = 0 -- 当前泡点人数
	self.max_ppl_qty = 0 -- 当前泡点最大人数
end

function SCSpecialEffInfo:Decode()
	self.type = MsgAdapter.ReadUChar()
	self.state = MsgAdapter.ReadUChar()
	self.now_time = Status.NowTime
	self.left_time = MsgAdapter.ReadUInt() / 1000
	self.ppl_qty = MsgAdapter.ReadInt()
	self.max_ppl_qty = MsgAdapter.ReadInt()
end

-- 接收每日礼包数据变化
SCDailyGiftBagInfoChange = SCDailyGiftBagInfoChange or BaseClass(BaseProtocolStruct)
function SCDailyGiftBagInfoChange:__init()
	self:InitMsgType(26, 89)
	self.grade  = 0 -- 档次
	self.buy_num = 0 -- 购买次数
	self.get_num = 0 -- 领取次数
end

function SCDailyGiftBagInfoChange:Decode()
	self.grade = MsgAdapter.ReadUChar()
	self.buy_num = MsgAdapter.ReadInt()
	self.get_num = MsgAdapter.ReadInt()
end

-- 接收每日礼包数据
SCDailyGiftBagInfo = SCDailyGiftBagInfo or BaseClass(BaseProtocolStruct)
function SCDailyGiftBagInfo:__init()
	self:InitMsgType(26, 90)
	self.sum = 0 -- 数组总数(档次总数)
	self.data_list = {} -- 礼包数据列表
end

function SCDailyGiftBagInfo:Decode()
	self.sum = MsgAdapter.ReadUChar()
	for i= 1, self.sum do
		self.data_list[i] = {
			grade = MsgAdapter.ReadUChar(),
			buy_num = MsgAdapter.ReadInt(),
			get_num = MsgAdapter.ReadInt(),
		}
	end
end

--是否开启双倍充值（充值返利）
SCDoubleRebageMsg = SCDoubleRebageMsg or BaseClass(BaseProtocolStruct)
function  SCDoubleRebageMsg:__init()
	self:InitMsgType(26, 91)
	self.is_open_double = 0
	self.max_times = 0
end

function SCDoubleRebageMsg:Decode()
	self.is_open_double = MsgAdapter.ReadUChar()
	self.max_times = MsgAdapter.ReadInt()
end

-- 更新行会BOSS排行榜(26, 92)
SCUpdateGuildBossRanking = SCUpdateGuildBossRanking or BaseClass(BaseProtocolStruct)
function  SCUpdateGuildBossRanking:__init()
	self:InitMsgType(26, 92)
	self.is_open_double = 0
	self.max_times = 0
end

function SCUpdateGuildBossRanking:Decode()
	self.ranking_count = MsgAdapter.ReadInt()	-- 行会数量
	self.rakning_list = {}
	for i=1, self.ranking_count do
		self.rakning_list[i] = {
			rank = MsgAdapter.ReadInt(), -- 第几名
			id = MsgAdapter.ReadInt(), -- 行会id
			score = MsgAdapter.ReadInt(),-- 积分
			name = MsgAdapter.ReadStr(),-- 行会名称
		}
	end
end

-- BOSS击杀掉落信息
SCBossRecord = SCBossRecord or BaseClass(BaseProtocolStruct)
function SCBossRecord:__init()
	self:InitMsgType(26, 93)
	self.drop_list = {}
end

function SCBossRecord:Decode()
	self.info_count = MsgAdapter.ReadUShort()
	self.drop_list = {}
	for i = self.info_count, 1, -1 do
		local vo = {
			mon = MsgAdapter.ReadUChar(),
			day = MsgAdapter.ReadUChar(),
			hour = MsgAdapter.ReadUChar(),
			minute = MsgAdapter.ReadUChar(),
			name = MsgAdapter.ReadStr(),
			scene_id = MsgAdapter.ReadUShort(),
			boss_id = MsgAdapter.ReadUInt(),
			item_id = MsgAdapter.ReadUShort(),
		}
		self.drop_list[i] = vo
	end
end