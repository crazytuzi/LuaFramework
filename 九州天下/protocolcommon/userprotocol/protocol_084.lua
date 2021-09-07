-- 完成并掉落
CSFbGuideFinish = CSFbGuideFinish or BaseClass(BaseProtocolStruct)
function CSFbGuideFinish:__init()
	self.msg_type = 8400
end

function CSFbGuideFinish:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(0)
end

-- 创建采集物
CSFbGuideCreateGather = CSFbGuideCreateGather or BaseClass(BaseProtocolStruct)
function CSFbGuideCreateGather:__init()
	self.msg_type = 8401
end

function CSFbGuideCreateGather:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteInt(self.gather_id)
	MsgAdapter.WriteInt(self.gather_time)
end

--组队塔防信息
SCTeamTowerDefendInfo = SCTeamTowerDefendInfo or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendInfo:__init()
	self.msg_type = 8402
	self.reason = 0
	self.life_tower_left_hp = 0
	self.life_tower_left_maxhp = 0
	self.gongji_uid = 0
	self.fangyu_uid = 0
	self.assist_uid = 0
	self.curr_wave = 0
	self.next_wave_refresh_time = 0
	self.score = 0
	self.exp = 0
	self.clear_wave = 0
	self.skill_list = {}
end

function SCTeamTowerDefendInfo:Decode()
	local MAX_SKILL_COUNT = 4
	self.reason = MsgAdapter.ReadInt()
	self.life_tower_left_hp = MsgAdapter.ReadLL()
	self.life_tower_left_maxhp = MsgAdapter.ReadLL()
	self.gongji_uid = MsgAdapter.ReadInt()
	self.fangyu_uid = MsgAdapter.ReadInt()
	self.assist_uid = MsgAdapter.ReadInt()
	self.curr_wave = MsgAdapter.ReadInt()
	self.next_wave_refresh_time = MsgAdapter.ReadInt()
	self.score = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
	self.clear_wave = MsgAdapter.ReadInt()
	self.skill_list = {}
	for i = 1, MAX_SKILL_COUNT do
		self.skill_list[i] = {}
		self.skill_list[i].skill_id = MsgAdapter.ReadUShort()
		self.skill_list[i].skill_level = MsgAdapter.ReadShort()
		self.skill_list[i].last_perform_time = MsgAdapter.ReadUInt()
	end
end


-- 组队塔防加成属性
SCTeamTowerDefendAttrType = SCTeamTowerDefendAttrType or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendAttrType:__init()
	self.msg_type = 8403
	self.uid = 0
	self.attr_type = 0
end

function SCTeamTowerDefendAttrType:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.attr_type = MsgAdapter.ReadInt()
end

-- 塔防技能CD
SCTeamTowerDefendSkill = SCTeamTowerDefendSkill or BaseClass(BaseProtocolStruct)
function SCTeamTowerDefendSkill:__init()
	self.msg_type = 8404
	self.skill_index = 0
	self.skill_level = 0
	self.perform_time = 0
end

function SCTeamTowerDefendSkill:Decode()
	self.skill_index = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadShort()
	self.perform_time = MsgAdapter.ReadUInt()
end

-- 设置防御塔加成属性
CSTeamTowerDefendSetAttrType = CSTeamTowerDefendSetAttrType or BaseClass(BaseProtocolStruct)

function CSTeamTowerDefendSetAttrType:__init()
	self.msg_type = 8405
	self.uid = 0
	self.attr_type = 0
end

function CSTeamTowerDefendSetAttrType:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
	MsgAdapter.WriteInt(self.attr_type)
end

SCEquipFBInfo = SCEquipFBInfo or BaseClass(BaseProtocolStruct)

function SCEquipFBInfo:__init()
	self.msg_type = 8406 
	self.is_personal = 0
	self.max_layer_today_entered = 0
	self.flag = 0
	self.mysterlayer_list = {}
	self.has_first_passed = 1 						--1全服已有人首通。0 全服还未有首通出现
end

function SCEquipFBInfo:Decode()
	self.is_personal = MsgAdapter.ReadInt()
	self.max_layer_today_entered = MsgAdapter.ReadShort()
	self.flag = MsgAdapter.ReadShort()
	for i=1,96 do
		MsgAdapter.ReadChar()
	end
	self.has_first_passed = MsgAdapter.ReadInt()
end

-- 组队副本个人信息
SCTeamFBUserInfo = SCTeamFBUserInfo or BaseClass(BaseProtocolStruct)
function SCTeamFBUserInfo:__init()
    self.msg_type = 8411
end

function SCTeamFBUserInfo:Decode()
	self.team_tower_defend_fb_is_first = MsgAdapter.ReadChar()     	-- 是否第一次组队塔防
    self.team_yaoshoujitan_fb_is_first = MsgAdapter.ReadChar()    	-- 是否第一次组队妖兽祭坛
    self.team_equip_fb_is_first = MsgAdapter.ReadChar()      		-- 是否第一次组精英须臾
end

-- 我们结婚吧
SCRAMarryMeAllInfo = SCRAMarryMeAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMarryMeAllInfo:__init()
	self.msg_type = 8416
end

function SCRAMarryMeAllInfo:Decode()
	self.cur_couple_count = MsgAdapter.ReadInt()
	self.couple_list = {}
	for i = 1, self.cur_couple_count do
		self.couple_list[i] = {}
		self.couple_list[i].propose_id = MsgAdapter.ReadInt()						-- 求婚者id
		self.couple_list[i].propose_name = MsgAdapter.ReadStrN(32)					-- 求婚者名字
		self.couple_list[i].accept_proposal_id = MsgAdapter.ReadInt()				-- 被求婚者id
		self.couple_list[i].accept_proposal_name = MsgAdapter.ReadStrN(32)			-- 被求婚者名字
		self.couple_list[i].proposer_sex = MsgAdapter.ReadChar()					-- 求婚者性别
		self.couple_list[i].accept_proposal_sex = MsgAdapter.ReadChar()				-- 被求婚者性别
		self.couple_list[i].reserve_sh = MsgAdapter.ReadShort()
	end
end

-- 副本鼓舞8417
CSFbGuwu = CSFbGuwu or BaseClass(BaseProtocolStruct)
function CSFbGuwu:__init()
	self.msg_type = 8417
end

function CSFbGuwu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.is_gold)
	MsgAdapter.WriteShort(self.guwu_type)
end

-- 开服红包
SCRARedEnvelopeGiftInfo = SCRARedEnvelopeGiftInfo or BaseClass(BaseProtocolStruct)
function SCRARedEnvelopeGiftInfo:__init()
	self.msg_type = 8410

	self.consume_gold_num = 0
	self.reward_flag = 0
end

function SCRARedEnvelopeGiftInfo:Decode()
	self.consume_gold_num_list = {}
	for i = 1 , 7 do
		self.consume_gold_num_list[i] = MsgAdapter.ReadInt()
	end
	self.reward_flag = MsgAdapter.ReadInt()
end


-- 开服七天充值18元档次
CSChongZhi7DayFetchReward = CSChongZhi7DayFetchReward or BaseClass(BaseProtocolStruct)
function CSChongZhi7DayFetchReward:__init()
	self.msg_type = 8420
end

function CSChongZhi7DayFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCMasterCollectInfo = SCMasterCollectInfo or BaseClass(BaseProtocolStruct)
function SCMasterCollectInfo:__init()
	self.msg_type = 8421
end

function SCMasterCollectInfo:Decode()
	self.master_collect_flags = {}
	for i = 1, MASTER_COLLECT_TYPE.MASTER_COLLECT_ITEM_COUNT do
		local vo = {}
		vo.flag = MsgAdapter.ReadChar()
		self.master_collect_flags[i] = vo
	end
end

-- 精通收集物品信息
SCMasterCollectItemInfo = SCMasterCollectItemInfo or BaseClass(BaseProtocolStruct)
function SCMasterCollectItemInfo:__init()
	self.msg_type = 8422
end

function SCMasterCollectItemInfo:Decode()
	self.seq = MsgAdapter.ReadInt()

	self.item_info_list = {}
	for i = 0, MASTER_COLLECT_TYPE.MASTER_COLLECT_TYPE_MAX - 1 do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()		-- 物品ID
		vo.level = MsgAdapter.ReadShort()			-- 对应等级
		vo.index = MsgAdapter.ReadInt()				-- 相应的配置索引

		self.item_info_list[i] = vo
	end
end

-------------------------战报
-- 战场
local function ReadListInfo()
	local data = {}
	data.type = MsgAdapter.ReadInt()					-- 战报类型
	data.killer_camp_post = MsgAdapter.ReadChar()		-- 击杀者官职
	data.dead_camp_post = MsgAdapter.ReadChar()			-- 被杀者官职
	data.killer_camp = MsgAdapter.ReadChar()			-- 击杀者阵营
	data.dead_camp = MsgAdapter.ReadChar()				-- 被杀者阵营
	data.killer_name = MsgAdapter.ReadStrN(32)			-- 击杀者名字
	data.dead_name = MsgAdapter.ReadStrN(32)			-- 被杀者名字
	data.multi_kill_num = MsgAdapter.ReadInt()			-- 连杀次数
	data.kill_num = MsgAdapter.ReadInt()				-- 击杀次数
	data.scene_id = MsgAdapter.ReadInt()				-- 发生场景
	data.pos_x = MsgAdapter.ReadInt()
	data.pos_y = MsgAdapter.ReadInt()
	return data
end

CSQueryBattleReportList = CSQueryBattleReportList or BaseClass(BaseProtocolStruct)
function CSQueryBattleReportList:__init()
	self.msg_type = 8425
end

function CSQueryBattleReportList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCQueryBattleReportHonorList = SCQueryBattleReportHonorList or BaseClass(BaseProtocolStruct)
function SCQueryBattleReportHonorList:__init()
	self.msg_type = 8426

	self.camp_type = 0
	self.my_kill_rank = 0
	self.my_kill_num = 0
	self.honor_report_list = {}
end

function SCQueryBattleReportHonorList:Decode()
	self.camp_type = MsgAdapter.ReadInt()
	self.my_kill_rank = MsgAdapter.ReadInt()
	self.my_kill_num = MsgAdapter.ReadInt()

	local count = MsgAdapter.ReadInt()
	self.honor_report_list = {}
	for i = 1, count do
		self.honor_report_list[i] = ReadListInfo()
	end
end

SCQueryBattleReportNormalList = SCQueryBattleReportNormalList or BaseClass(BaseProtocolStruct)
function SCQueryBattleReportNormalList:__init()
	self.msg_type = 8427

	self.camp_type = 0
	self.my_kill_rank = 0
	self.my_kill_num = 0
	self.normal_report_list = {}
end

function SCQueryBattleReportNormalList:Decode()
	self.camp_type = MsgAdapter.ReadInt()
	self.my_kill_rank = MsgAdapter.ReadInt()
	self.my_kill_num = MsgAdapter.ReadInt()

	local count = MsgAdapter.ReadInt()
	self.normal_report_list = {}
	for i = 1, count do
		self.normal_report_list[i] = ReadListInfo()
	end
end

CSQueryCampBuildReport = CSQueryCampBuildReport or BaseClass(BaseProtocolStruct)
function CSQueryCampBuildReport:__init()
	self.msg_type = 8428
end

function CSQueryCampBuildReport:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCQueryCampBuildReport = SCQueryCampBuildReport or BaseClass(BaseProtocolStruct)
function SCQueryCampBuildReport:__init()
	self.msg_type = 8429

	self.camp_type = 0
	self.report_list = {}
end

function SCQueryCampBuildReport:Decode()
	self.camp_type = MsgAdapter.ReadInt()

	local count = MsgAdapter.ReadInt()
	self.report_list = {}
	for i = 1, count do
		local item = {}
		item.report_time = MsgAdapter.ReadUInt()		-- 日志时间
		item.type = MsgAdapter.ReadInt()				-- 日志类型
		item.my_uid = MsgAdapter.ReadInt()				-- 参与玩家UID
		item.my_name = MsgAdapter.ReadStrN(32)			-- 参与玩家姓名
		item.param = MsgAdapter.ReadInt()				-- 相关参数
		self.report_list[i] = item
	end
end

------------------------军衔
SCJunXianInfo = SCJunXianInfo or BaseClass(BaseProtocolStruct)
function SCJunXianInfo:__init()
	self.msg_type = 8450
	
	self.jungong = 0
	self.jx_level = 0
	self.jx_star = 0
	self.active_timestamp = {}
end

function SCJunXianInfo:Decode()
	self.jungong = MsgAdapter.ReadInt()
	self.jx_level = MsgAdapter.ReadShort()
	self.jx_star = MsgAdapter.ReadShort()
	self.active_timestamp = {}
	for i = 0, GameEnum.MAX_JUNXIAN_LEVEL - 1 do
		self.active_timestamp[i] = MsgAdapter.ReadUInt()
	end
end

CSJunXianGetInfo = CSJunXianGetInfo or BaseClass(BaseProtocolStruct)
function CSJunXianGetInfo:__init()
	self.msg_type = 8451
end

function CSJunXianGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

CSJunXianUpStarReq = CSJunXianUpStarReq or BaseClass(BaseProtocolStruct)
function CSJunXianUpStarReq:__init()
	self.msg_type = 8452
end

function CSJunXianUpStarReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCJunXianUplevelResult = SCJunXianUplevelResult or BaseClass(BaseProtocolStruct)
function SCJunXianUplevelResult:__init()
	self.msg_type = 8453

	self.jx_level = 0
end

function SCJunXianUplevelResult:Decode()
	self.jx_level = MsgAdapter.ReadShort()
end


--------------------------------------智能熔炉-------------------------------------------------
-- 请求熔炉信息
CSGetRongluInfo = CSGetRongluInfo or BaseClass(BaseProtocolStruct)
function CSGetRongluInfo:__init()
	self.msg_type = 8460
end

function CSGetRongluInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 熔炉信息
SCSendRongluInfo = SCSendRongluInfo or BaseClass(BaseProtocolStruct)
function SCSendRongluInfo:__init()
	self.msg_type = 8461
end

function SCSendRongluInfo:Decode()
	self.ronglu_info = {}
	self.ronglu_info.ronglu_level = MsgAdapter.ReadInt()
	self.ronglu_info.ronglu_jingyan = MsgAdapter.ReadInt()
end

-- 熔炼装备的请求
CSRonglianReq = CSRonglianReq or BaseClass(BaseProtocolStruct)
function CSRonglianReq:__init()
	self.msg_type = 8462
	self.equip_count = 0
	self.equip_list = {}		
end

function CSRonglianReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.equip_count)
	for i = 1, 8 do
		MsgAdapter.WriteInt(self.equip_list[i].index or 0)		-- 需要熔炼的装备的物品id
	end
	for k = 1, 8 do
		MsgAdapter.WriteInt(self.equip_list[k].num or 0)		-- 需要熔炼的装备的物品数量
	end

end

-- 熔炉经验增加
SCRongluResultInfo = SCRongluResultInfo or BaseClass(BaseProtocolStruct)
function SCRongluResultInfo:__init()
	self.msg_type = 8465
	self.change_type = 0
	self.delta = 0
end

function SCRongluResultInfo:Decode()
	self.change_type = MsgAdapter.ReadInt()
	self.delta = MsgAdapter.ReadInt()
end