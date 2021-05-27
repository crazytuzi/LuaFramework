--===================================请求==================================
-- 请求本帮派的详细信息(返回10 1)
CSGetGuildDetailedInfoReq = CSGetGuildDetailedInfoReq or BaseClass(BaseProtocolStruct)
function CSGetGuildDetailedInfoReq:__init()
	self:InitMsgType(10, 1)
end

function CSGetGuildDetailedInfoReq:Encode()
	self:WriteBegin()
end

-- 帮派成员列表(返回10 2)
CSGetGuildMemberList = CSGetGuildMemberList or BaseClass(BaseProtocolStruct)
function CSGetGuildMemberList:__init()
	self:InitMsgType(10, 2)
end

function CSGetGuildMemberList:Encode()
	self:WriteBegin()
end

-- 本服内的所有帮派(返回 10 3)
CSGetGuildList = CSGetGuildList or BaseClass(BaseProtocolStruct)
function CSGetGuildList:__init()
	self:InitMsgType(10, 3)
end

function CSGetGuildList:Encode()
	self:WriteBegin()
end

-- 帮派名片(返回 10 4)
CSGuildBusinessCard = CSGuildBusinessCard or BaseClass(BaseProtocolStruct)
function CSGuildBusinessCard:__init()
	self:InitMsgType(10, 4)
	self.guild_id = 0
end

function CSGuildBusinessCard:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.guild_id)
end

-- 创建帮派(返回 10 5)
CSCreateGuildReq = CSCreateGuildReq or BaseClass(BaseProtocolStruct)
function CSCreateGuildReq:__init()
	self:InitMsgType(10, 5)
	self.cost_type = 0			--消耗物品0, 消耗元宝1
	self.guild_name = ""
end

function CSCreateGuildReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.cost_type)
	MsgAdapter.WriteStr(self.guild_name)
end

-- 删除帮派(返回 10 6)
CSDeleteGuildReq = CSDeleteGuildReq or BaseClass(BaseProtocolStruct)
function CSDeleteGuildReq:__init()
	self:InitMsgType(10, 6)
end

function CSDeleteGuildReq:Encode()
	self:WriteBegin()
end

-- 邀请加入帮派(返回 10 7)
CSInviteJoinGuildReq = CSInviteJoinGuildReq or BaseClass(BaseProtocolStruct)
function CSInviteJoinGuildReq:__init()
	self:InitMsgType(10, 7)
	self.obj_id = 0
	self.role_name = ""
end

function CSInviteJoinGuildReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteStr(self.role_name)
end

-- 玩家拒绝还是接受加入帮派
CSGuildInviteAnswer = CSGuildInviteAnswer or BaseClass(BaseProtocolStruct)
function CSGuildInviteAnswer:__init()
	self:InitMsgType(10, 9)
	self.answer = 0				--0拒绝, 1接受
	self.guild_id = 0
	self.obj_id = 0
end

function CSGuildInviteAnswer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.answer)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteLL(self.obj_id)
end

-- 用户提交加入帮派的申请
CSSubmitJoinGuildReq = CSSubmitJoinGuildReq or BaseClass(BaseProtocolStruct)
function CSSubmitJoinGuildReq:__init()
	self:InitMsgType(10, 10)
	self.guild_id = 0
end

function CSSubmitJoinGuildReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.guild_id)
end

-- 显示用户申请加入的帮派的申请(返回 10 11)
CSJoinGuildReqInfo = CSJoinGuildReqInfo or BaseClass(BaseProtocolStruct)
function CSJoinGuildReqInfo:__init()
	self:InitMsgType(10, 11)
end

function CSJoinGuildReqInfo:Encode()
	self:WriteBegin()
end

-- 帮主的审核结果
CSGuildAuditingResult = CSGuildAuditingResult or BaseClass(BaseProtocolStruct)
function CSGuildAuditingResult:__init()
	self:InitMsgType(10, 12)
	self.obj_id = 0
	self.result = 0				--1可加入, 0不可加入
	self.role_id = 0
end

function CSGuildAuditingResult:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteUChar(self.result)
	MsgAdapter.WriteInt(self.role_id)
end

-- 开除成员
CSGuildExpelMember = CSGuildExpelMember or BaseClass(BaseProtocolStruct)
function CSGuildExpelMember:__init()
	self:InitMsgType(10, 13)
	self.role_id = 0
end

function CSGuildExpelMember:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.role_id)
end

-- 升/降职
CSGuildPositionChange = CSGuildPositionChange or BaseClass(BaseProtocolStruct)
function CSGuildPositionChange:__init()
	self:InitMsgType(10, 14)
	self.role_id = 0
	self.position = 0
end

function CSGuildPositionChange:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteUChar(self.position)
end

-- 帮主让位
CSGuildLeaderYield = CSGuildLeaderYield or BaseClass(BaseProtocolStruct)
function CSGuildLeaderYield:__init()
	self:InitMsgType(10, 15)
	self.role_id = 0
end

function CSGuildLeaderYield:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.role_id)
end

-- 脱离帮派
CSLeaveGuild = CSLeaveGuild or BaseClass(BaseProtocolStruct)
function CSLeaveGuild:__init()
	self:InitMsgType(10, 16)
end

function CSLeaveGuild:Encode()
	self:WriteBegin()
end

-- 设置帮派公告(返回 10 26)
CSSetGuildAffiche = CSSetGuildAffiche or BaseClass(BaseProtocolStruct)
function CSSetGuildAffiche:__init()
	self:InitMsgType(10, 17)
	self.type = 1				--1设置对内的公告, 2设置对外的公告, 3设置行会群公告
	self.content = ""			--公告内容，最长1024
end

function CSSetGuildAffiche:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
	MsgAdapter.WriteStr(self.content)
end

-- 帮派升级(扩充人口)(1返回 10 45, 2返回 10 19)
CSUpgradeGuild = CSUpgradeGuild or BaseClass(BaseProtocolStruct)
function CSUpgradeGuild:__init()
	self:InitMsgType(10, 19)
	self.type = 1				--1获取扩充人口信息, 2升级帮派人口
end

function CSUpgradeGuild:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.type)
end

-- 设置QQ群id(返回 10 26)
CSSetGuildQQ = CSSetGuildQQ or BaseClass(BaseProtocolStruct)
function CSSetGuildQQ:__init()
	self:InitMsgType(10, 20)
	self.group_number = ""
end

function CSSetGuildQQ:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.group_number)
end

-- 被召唤人的回应，是接受还是拒绝
CSGuildCallAnswer = CSGuildCallAnswer or BaseClass(BaseProtocolStruct)
function CSGuildCallAnswer:__init()
	self:InitMsgType(10, 22)
	self.scene_id = 0
	self.x = 0
	self.y = 0
end

function CSGuildCallAnswer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteUShort(self.x)
	MsgAdapter.WriteUShort(self.y)
end

-- 宣战
CSGuildDeclarationWar = CSGuildDeclarationWar or BaseClass(BaseProtocolStruct)
function CSGuildDeclarationWar:__init()
	self:InitMsgType(10, 23)
	self.guild_id = 0
end

function CSGuildDeclarationWar:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.guild_id)
end

-- 请求现在宣战、敌对状态的帮派列表(返回 10 24)
CSGuildWarInfo = CSGuildWarInfo or BaseClass(BaseProtocolStruct)
function CSGuildWarInfo:__init()
	self:InitMsgType(10, 24)
end

function CSGuildWarInfo:Encode()
	self:WriteBegin()
end

-- 设置行会之间的关系(返回 10 29)
CSSetGuildRelationship = CSSetGuildRelationship or BaseClass(BaseProtocolStruct)
function CSSetGuildRelationship:__init()
	self:InitMsgType(10, 29)
	self.relationship = 1					--1联盟, 3解除联盟
	self.guild_id = 0
end

function CSSetGuildRelationship:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.relationship)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 捐献帮派资金
CSDonateGuildBankroll = CSDonateGuildBankroll or BaseClass(BaseProtocolStruct)
function CSDonateGuildBankroll:__init()
	self:InitMsgType(10, 30)
	self.opt_type = 0					--0获得奖励, 1绑金捐献, 2为元宝捐献
	self.donate_num = 0
end

function CSDonateGuildBankroll:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	if self.opt_type == GUILD_DONATE_OPT.BIND_COIN 
		or self.opt_type == GUILD_DONATE_OPT.GOLD then
		MsgAdapter.WriteUInt(self.donate_num)
	end
end

-- 同意或者拒绝行会同盟
CSGuildLeaguesAnswer = CSGuildLeaguesAnswer or BaseClass(BaseProtocolStruct)
function CSGuildLeaguesAnswer:__init()
	self:InitMsgType(10, 31)
	self.answer = 0					--1同意, 2拒绝
	self.guild_id = 0
	self.leader_role_id = 0
end

function CSGuildLeaguesAnswer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.answer)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.leader_role_id)
end

-- 背包拖动物品到行会仓库(返回 10 32)
CSMoveToGuildStorageFromBag = CSMoveToGuildStorageFromBag or BaseClass(BaseProtocolStruct)
function CSMoveToGuildStorageFromBag:__init()
	self:InitMsgType(10, 32)
	self.item_guid = 0
end

function CSMoveToGuildStorageFromBag:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_guid)
end

-- 从仓库拖动物品到背包
CSMoveToBagFromGuildStorage = CSMoveToBagFromGuildStorage or BaseClass(BaseProtocolStruct)
function CSMoveToBagFromGuildStorage:__init()
	self:InitMsgType(10, 33)
	self.item_guid = 0
end

function CSMoveToBagFromGuildStorage:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.item_guid)
end

-- 获取仓库物品的列表(返回 10 34)
CSGetGuildStorageList = CSGetGuildStorageList or BaseClass(BaseProtocolStruct)
function CSGetGuildStorageList:__init()
	self:InitMsgType(10, 34)
end

function CSGetGuildStorageList:Encode()
	self:WriteBegin()
end

-- 获取仓库操作记录(返回 10 35)
CSGetGuildStorageRecord = CSGetGuildStorageRecord or BaseClass(BaseProtocolStruct)
function CSGetGuildStorageRecord:__init()
	self:InitMsgType(10, 35)
end

function CSGetGuildStorageRecord:Encode()
	self:WriteBegin()
end

-- 行会竞价排名(返回 10 31)
CSGuildBidRank = CSGuildBidRank or BaseClass(BaseProtocolStruct)
function CSGuildBidRank:__init()
	self:InitMsgType(10, 36)
end

function CSGuildBidRank:Encode()
	self:WriteBegin()
end

-- 发送求救的信息(返回 10 37)
CSSentHelpReq = CSSentHelpReq or BaseClass(BaseProtocolStruct)
function CSSentHelpReq:__init()
	self:InitMsgType(10, 37)
end

function CSSentHelpReq:Encode()
	self:WriteBegin()
end

-- 设置直接加入(返回 10 39)
CSSetJoinHandle = CSSetJoinHandle or BaseClass(BaseProtocolStruct)
function CSSetJoinHandle:__init()
	self:InitMsgType(10, 39)
	self.handle = 0					--0需要审核 1自动添加
end

function CSSetJoinHandle:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.handle)
end

-- 请求帮派事件(返回 10 38)
CSGetGuildEvents = CSGetGuildEvents or BaseClass(BaseProtocolStruct)
function CSGetGuildEvents:__init()
	self:InitMsgType(10, 40)
end

function CSGetGuildEvents:Encode()
	self:WriteBegin()
end

-- 编辑行会封号
CSEditGuildTitle = CSEditGuildTitle or BaseClass(BaseProtocolStruct)
function CSEditGuildTitle:__init()
	self:InitMsgType(10, 41)
	self.num = 0
	self.title_list = {}
end

function CSEditGuildTitle:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.num)
	for i=1, #self.title_list do
		local data = self.title_list[i]
		MsgAdapter.WriteUChar(data.title_index)
		MsgAdapter.WriteStr(data.role_name)
	end
end

-- 设置封号
CSSetGuildTitle = CSSetGuildTitle or BaseClass(BaseProtocolStruct)
function CSSetGuildTitle:__init()
	self:InitMsgType(10, 42)
	self.role_id = 0
	self.title_index = 0
end

function CSSetGuildTitle:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteUChar(self.title_index)
end

-- 报名攻城
CSApplyGongCheng = CSApplyGongCheng or BaseClass(BaseProtocolStruct)
function CSApplyGongCheng:__init()
	self:InitMsgType(10, 47)
end

function CSApplyGongCheng:Encode()
	self:WriteBegin()
end

-- 获取攻城行会列表(返回 10 48)
CSGetGongChengGuildList = CSGetGongChengGuildList or BaseClass(BaseProtocolStruct)
function CSGetGongChengGuildList:__init()
	self:InitMsgType(10, 48)
	self.day = 0				--1为今天   2为明天
end

function CSGetGongChengGuildList:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.day)
end

-- 行会搜索(返回 10 3)
CSSearchGuildByName = CSSearchGuildByName or BaseClass(BaseProtocolStruct)
function CSSearchGuildByName:__init()
	self:InitMsgType(10, 49)
	self.guild_name = ""
end

function CSSearchGuildByName:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.guild_name)
end

-- 获取沙巴克城战的状态(返回 10 50)
CSGetSbkState = CSGetSbkState or BaseClass(BaseProtocolStruct)
function CSGetSbkState:__init()
	self:InitMsgType(10, 50)
end

function CSGetSbkState:Encode()
	self:WriteBegin()
end

-- 设置沙巴克职位
CSSetSbkPosition = CSSetSbkPosition or BaseClass(BaseProtocolStruct)
function CSSetSbkPosition:__init()
	self:InitMsgType(10, 52)
	self.position = 0
	self.role_name = ""
	self.opt_type = 1				--1任职, 2卸任
end

function CSSetSbkPosition:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.position)
	MsgAdapter.WriteStr(self.role_name)
	MsgAdapter.WriteUChar(self.opt_type)
end

-- 领取沙巴克福利
CSReceiveSbkWelfare = CSReceiveSbkWelfare or BaseClass(BaseProtocolStruct)
function CSReceiveSbkWelfare:__init()
	self:InitMsgType(10, 53)
end

function CSReceiveSbkWelfare:Encode()
	self:WriteBegin()
end

-- 请求守沙行会的信息(返回 10 60)
CSSbkGuildReq = CSSbkGuildReq or BaseClass(BaseProtocolStruct)
function CSSbkGuildReq:__init()
	self:InitMsgType(10, 58)
end

function CSSbkGuildReq:Encode()
	self:WriteBegin()
end

-- 请求行会贡献排行列表(返回 10 61)
CSGuildContributionRank = CSGuildContributionRank or BaseClass(BaseProtocolStruct)
function CSGuildContributionRank:__init()
	self:InitMsgType(10, 60)
end

function CSGuildContributionRank:Encode()
	self:WriteBegin()
end

-- 成员通过帮会积分兑换行会商品
CSGuildExchangeItem = CSGuildExchangeItem or BaseClass(BaseProtocolStruct)
function CSGuildExchangeItem:__init()
	self:InitMsgType(10, 77)
	self.item_id = 0
	self.num = 0
end

function CSGuildExchangeItem:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.item_id)
	MsgAdapter.WriteInt(self.num)
end

-- 开启帮派等级buff
CSUnlockGuildLevelBuff = CSUnlockGuildLevelBuff or BaseClass(BaseProtocolStruct)
function CSUnlockGuildLevelBuff:__init()
	self:InitMsgType(10, 78)
	self.buff_index = 1
end

function CSUnlockGuildLevelBuff:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.buff_index)
end

-- 沙巴克管理层的名字(返回 10 75)
CSSbkAdminName = CSSbkAdminName or BaseClass(BaseProtocolStruct)
function CSSbkAdminName:__init()
	self:InitMsgType(10, 85)
end

function CSSbkAdminName:Encode()
	self:WriteBegin()
end

-- 获取攻城行会奖励
CSGetGongChengGuildReward = CSGetGongChengGuildReward or BaseClass(BaseProtocolStruct)
function CSGetGongChengGuildReward:__init()
	self:InitMsgType(10, 86)
	self.reward_index = 1
end

function CSGetGongChengGuildReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_index)
end

-- 请求沙巴克领取奖励的信息
CSGetGongChengGuildRewardMsg = CSGetGongChengGuildRewardMsg or BaseClass(BaseProtocolStruct)
function CSGetGongChengGuildRewardMsg:__init()
	self:InitMsgType(10, 87)
end

function CSGetGongChengGuildRewardMsg:Encode()
	self:WriteBegin()
end

-- 获取攻城行会奖励
CSGetGongChengGuildReward = CSGetGongChengGuildReward or BaseClass(BaseProtocolStruct)
function CSGetGongChengGuildReward:__init()
	self:InitMsgType(10, 86)
	self.reward_index = 1
end

function CSGetGongChengGuildReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reward_index)
end

-- 获取行会红包信息 - 总红包 与发放红包个数 倒计时时间 包括红包领取记录(10 77)
CSGetGuildRedEnvelopeInfo = CSGetGuildRedEnvelopeInfo or BaseClass(BaseProtocolStruct)
function CSGetGuildRedEnvelopeInfo:__init()
	self:InitMsgType(10, 88)
end

function CSGetGuildRedEnvelopeInfo:Encode()
	self:WriteBegin()
end

-- 发红包(返回 10 78)
CSSentRedEnvelope = CSSentRedEnvelope or BaseClass(BaseProtocolStruct)
function CSSentRedEnvelope:__init()
	self:InitMsgType(10, 89)
	self.gold_num = 0
	self.num = 0
end

function CSSentRedEnvelope:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.gold_num)
	MsgAdapter.WriteInt(self.num)
end

-- 抢红包(返回 10 79, 10 77)
CSRobRedEnvelope = CSRobRedEnvelope or BaseClass(BaseProtocolStruct)
function CSRobRedEnvelope:__init()
	self:InitMsgType(10, 90)
end

function CSRobRedEnvelope:Encode()
	self:WriteBegin()
end

-- 删除仓库物品
-- CSDelGuildStorageItem = CSDelGuildStorageItem or BaseClass(BaseProtocolStruct)
-- function CSDelGuildStorageItem:__init()
-- 	self:InitMsgType(10, 91)
-- 	self.item_guid = 0
-- end

-- function CSDelGuildStorageItem:Encode()
-- 	self:WriteBegin()
-- 	CommonReader.WriteSeries(self.item_guid)
-- end

--请求召唤成员(返回 10 55)
CSCallGuildMember = CSCallGuildMember or BaseClass(BaseProtocolStruct)
function CSCallGuildMember:__init()
	self:InitMsgType(10, 96)
	self.call_type = 0
	self.obj_id = 0
	self.role_name = ""
end

function CSCallGuildMember:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.call_type)
	if self.call_type == 1 then
		MsgAdapter.WriteInt(self.obj_id)
		MsgAdapter.WriteStr(self.role_name)
	end
end

-- 搜索符合邀请的玩家(返回 10 88)
CSSearchGuildQualifiedPlayer = CSSearchGuildQualifiedPlayer or BaseClass(BaseProtocolStruct)
function CSSearchGuildQualifiedPlayer:__init()
	self:InitMsgType(10, 97)
	self.player_name = 0
end

function CSSearchGuildQualifiedPlayer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.player_name)
end

-- 下发今天报名和明天报名的行会名字(返回 10 76)
CSGetTodayTomorrowSignUpGuildName = CSGetTodayTomorrowSignUpGuildName or BaseClass(BaseProtocolStruct)
function CSGetTodayTomorrowSignUpGuildName:__init()
	self:InitMsgType(10, 103)
end

function CSGetTodayTomorrowSignUpGuildName:Encode()
	self:WriteBegin()
end

-- 请求沙巴克信息(返回 10 51)
CSGetSbkMag = CSGetSbkMag or BaseClass(BaseProtocolStruct)
function CSGetSbkMag:__init()
	self:InitMsgType(10, 104)
end

function CSGetSbkMag:Encode()
	self:WriteBegin()
end

-- 请求行会改名(广播返回 10, 92)
CSRenameGuild = CSRenameGuild or BaseClass(BaseProtocolStruct)
function  CSRenameGuild:__init()
	self:InitMsgType(10, 105)
	self.new_guild_name = ""
end

function CSRenameGuild:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.new_guild_name)
end

-- 一键删除行会装备
CSOnKeyDestroyStorageEq = CSOnKeyDestroyStorageEq or BaseClass(BaseProtocolStruct)
function  CSOnKeyDestroyStorageEq:__init()
	self:InitMsgType(10, 106)
	self.item_list = {}
end

function CSOnKeyDestroyStorageEq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(#self.item_list)
	for _, v in pairs(self.item_list) do
		CommonReader.WriteSeries(v.series)
	end
end

-- 行会悬赏请求
CSGuildOfferReq = CSGuildOfferReq or BaseClass(BaseProtocolStruct)
function CSGuildOfferReq:__init()
	self:InitMsgType(10, 107)
	self.offer_type = 0 			-- 悬赏事件  1悬赏任务信息 2接受悬赏任务 3领取悬赏积分奖 4悬赏任务奖 5快速完成
	self.task_id = 0    -- 任务id
end

function CSGuildOfferReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.offer_type)
	MsgAdapter.WriteUChar(self.task_id)
end

-- 请求弹劾
CSGuildImpeachReq = CSGuildImpeachReq or BaseClass(BaseProtocolStruct)
function CSGuildImpeachReq:__init()
	self:InitMsgType(10, 108)
end

function CSGuildImpeachReq:Encode()
	self:WriteBegin()
end

-- 请求弹劾抽票
CSGuildImpeachVoteReq = CSGuildImpeachVoteReq or BaseClass(BaseProtocolStruct)
function CSGuildImpeachVoteReq:__init()
	self:InitMsgType(10, 109)
	self.index = 0 -- 1赞同, 2反对
end

function CSGuildImpeachVoteReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.index)
end

--===================================下发==================================

-- 本帮派的详细信息，包括帮派名称，阵营，帮主名称等等
SCGuildDetailedInfo = SCGuildDetailedInfo or BaseClass(BaseProtocolStruct)
function SCGuildDetailedInfo:__init()
	self:InitMsgType(10, 1)
	self.is_join_guild = 0					--有没加入帮会, 1有, 0没有
	self.info = {}
end

function SCGuildDetailedInfo:Decode()
	self.is_join_guild = MsgAdapter.ReadUChar()
	self.info = {}
	if self.is_join_guild == 1 then
		self.info.guild_rank = MsgAdapter.ReadUInt()							-- 本帮派的排名
		self.info.self_position = MsgAdapter.ReadUChar()						-- 获取本人在帮派的地位
		self.info.leader_role_id = MsgAdapter.ReadInt()							-- 帮主id(角色id)
		self.info.guild_name = MsgAdapter.ReadStr()								-- 帮会名
		self.info.leader_name = MsgAdapter.ReadStr()							-- 帮主名
		self.info.founder_name = MsgAdapter.ReadStr()							-- 创始人的名字
		self.info.private_affiche = MsgAdapter.ReadStr()						-- 对内的公告信息
		self.info.public_affiche = MsgAdapter.ReadStr()							-- 对外的公告信息
		self.info.guild_max_level = MsgAdapter.ReadUChar()						-- 帮派的最大等级
		self.info.max_member_num = MsgAdapter.ReadInt()							-- 现行会总人数
		self.info.cur_member_num = MsgAdapter.ReadInt()							-- 帮派成员的数量
		self.info.today_donate_val = MsgAdapter.ReadInt()						-- 当天捐献值
		self.info.guild_bankroll = MsgAdapter.ReadInt()							-- 帮派资金
		self.info.guild_QQ_id = MsgAdapter.ReadStr()							-- qq群id
		self.info.voice_channel_type = MsgAdapter.ReadUChar()					-- 语音频道类型
		self.info.voice_channel_id = MsgAdapter.ReadStr()						-- 语音频道id
		self.info.voice_channel_declaration = MsgAdapter.ReadStr()				-- 语音频道宣言
		self.info.guild_join_handle = MsgAdapter.ReadUChar()					-- 0需要审核 1 自动添加
		self.info.guild_title_id = MsgAdapter.ReadUChar()						-- 封号序号
		self.info.guild_affiche = MsgAdapter.ReadStr()							-- 群公告
		self.info.contribution = MsgAdapter.ReadInt()							-- 今天的贡献
		self.info.today_donate_ybval = MsgAdapter.ReadUInt()					-- 今天的元宝贡献
		self.info.cur_guild_level = MsgAdapter.ReadInt()						-- 当前行会等级
		self.info.guild_exp = MsgAdapter.ReadInt()								-- 行会经验
		self.info.personal_guild_integral = MsgAdapter.ReadInt()				-- 个人行会积分
		self.info.personal_guild_integral_rank = MsgAdapter.ReadInt()			-- 个人行会积分排行
		self.info.guild_flag_level = MsgAdapter.ReadUChar()						-- 行会宝物等级
		self.info.guild_flag_exp = MsgAdapter.ReadInt()							-- 行会宝物经验
		self.info.collect_times = MsgAdapter.ReadUChar()						-- 采集次数
		self.info.exorcism_times = MsgAdapter.ReadUChar()						-- 降妖除魔次数
		self.info.transportation_times = MsgAdapter.ReadUChar()					-- 押镖次数
	end
end

-- 帮派成员列表
SCGuildMemberList = SCGuildMemberList or BaseClass(BaseProtocolStruct)
function SCGuildMemberList:__init()
	self:InitMsgType(10, 2)
	self.member_num = 0
	self.list = {}
end

function SCGuildMemberList:Decode()
	self.member_num = MsgAdapter.ReadInt()
	self.list = {}
	for i=1,self.member_num do
		local member_info = {}
		member_info.is_online = MsgAdapter.ReadUChar()							-- 1在线, 0不在线
		member_info.role_id = MsgAdapter.ReadUInt()								-- 角色id
		member_info.obj_id = MsgAdapter.ReadLL()								-- 角色句柄
		member_info.sex = MsgAdapter.ReadUChar()								-- 性别
		member_info.level = MsgAdapter.ReadUShort()								-- 等级
		member_info.prof = MsgAdapter.ReadUChar()								-- 职业
		member_info.position = MsgAdapter.ReadUChar()							-- 在帮派的地位
		member_info.login_time = CommonReader.ReadServerUnixTime()				-- 登录时间
		member_info.name = MsgAdapter.ReadStr()									-- 角色名
		member_info.avatar_id = MsgAdapter.ReadInt()							-- 头像ID
		member_info.capacity = MsgAdapter.ReadInt()								-- 玩家的战力
		member_info.guild_title_id = MsgAdapter.ReadUChar()						-- 封号序号
		member_info.donate_degree = MsgAdapter.ReadInt()						-- 玩家个人当前的贡献度
		member_info.donate_total_val = MsgAdapter.ReadInt()						-- 在本行会累计贡献
		member_info.contribution = MsgAdapter.ReadInt()							-- 行会贡献值
		member_info.zhuan = MsgAdapter.ReadUChar()								-- 转生等级
		member_info.gods_level = MsgAdapter.ReadUChar()							-- 封神等级
		
		self.list[i] = member_info
	end
end

-- 本服内的所有帮派
SCCurServerGuildList = SCCurServerGuildList or BaseClass(BaseProtocolStruct)
function SCCurServerGuildList:__init()
	self:InitMsgType(10, 3)
	self.total_pages = 0
	self.cur_page = 0
	self.cur_page_num = 0
end

function SCCurServerGuildList:Decode()
	self.total_pages = MsgAdapter.ReadInt()
	self.cur_page = MsgAdapter.ReadInt()
	self.cur_page_num = MsgAdapter.ReadUShort()
	if nil == self.list or 1 == self.cur_page then
		self.list = {}
	end
	for i = #self.list + 1, #self.list + self.cur_page_num do
		local guild_info = {}
		guild_info.guild_id = MsgAdapter.ReadInt()								-- 帮会id
		guild_info.guild_rank = MsgAdapter.ReadUInt()							-- 本帮会排名
		guild_info.guild_member_num = MsgAdapter.ReadInt()						-- 帮派成员的数量
		guild_info.guild_total_num = MsgAdapter.ReadInt()						-- 帮派总人数
		guild_info.relationship = MsgAdapter.ReadUChar()						-- 行会关系, 0无, 1联盟, 2敌对
		guild_info.war_state = MsgAdapter.ReadUChar()							-- 1 宣战状态 0 正常
		guild_info.war_left_time = MsgAdapter.ReadInt()							-- 下次可以宣战的时间, 秒
		guild_info.guild_name = MsgAdapter.ReadStr()							-- 帮派的名字
		guild_info.leader_name = MsgAdapter.ReadStr()							-- 帮主名
		guild_info.guild_level = MsgAdapter.ReadInt()							-- 帮派等级
		
		self.list[i] = guild_info
	end
end

-- 帮派名片
SCGuildCard = SCGuildCard or BaseClass(BaseProtocolStruct)
function SCGuildCard:__init()
	self:InitMsgType(10, 4)
	self.is_guild_exist = 0
	self.info = {}
end

function SCGuildCard:Decode()
	self.is_guild_exist = MsgAdapter.ReadUChar()
	self.info = {}
	if self.is_guild_exist == 1 then
		self.info.sent_guild_id = MsgAdapter.ReadInt()								-- 发送的帮会id
		self.info.public_affiche = MsgAdapter.ReadStr()								-- 对外的公告信息
		self.info.self_guild_name = MsgAdapter.ReadStr()							-- 自己帮会的名字
		self.info.self_leader_name = MsgAdapter.ReadStr()							-- 自己帮会帮主名
		self.info.guild_member_num = MsgAdapter.ReadInt()							-- 帮会成员数
		self.info.guild_total_num = MsgAdapter.ReadInt()							-- 现行会总人数
		self.info.war_state = MsgAdapter.ReadUChar()								-- 1 宣战状态 0 正常
		self.info.war_left_time = MsgAdapter.ReadInt()								-- 下次可以宣战的剩余时间
	end
end

-- 返回创建帮派结果
SCCreateGuildResult = SCCreateGuildResult or BaseClass(BaseProtocolStruct)
function SCCreateGuildResult:__init()
	self:InitMsgType(10, 5)
	self.error = 0
	self.guild_id = 0
end

function SCCreateGuildResult:Decode()
	self.error = MsgAdapter.ReadUChar()
	self.guild_id = MsgAdapter.ReadInt()
end

-- 删除帮派
SCDelGuildResult = SCDelGuildResult or BaseClass(BaseProtocolStruct)
function SCDelGuildResult:__init()
	self:InitMsgType(10, 6)
end

function SCDelGuildResult:Decode()
end

-- 通知玩家有人邀请他加入帮派
SCJoinGuildInvite = SCJoinGuildInvite or BaseClass(BaseProtocolStruct)
function SCJoinGuildInvite:__init()
	self:InitMsgType(10, 7)
	self.guild_id = 0
	self.obj_id = 0
	self.guild_name = ""
	self.role_name = ""
	self.cur_member_num = 0
	self.guild_total_num = 0
end

function SCJoinGuildInvite:Decode()
	self.guild_id = MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadLL()
	self.guild_name = MsgAdapter.ReadStr()
	self.role_name = MsgAdapter.ReadStr()
	self.cur_member_num = MsgAdapter.ReadInt()
	self.guild_total_num = MsgAdapter.ReadInt()
end

-- 显示用户申请加入的帮派的列表
SCJoinGuildReqList = SCJoinGuildReqList or BaseClass(BaseProtocolStruct)
function SCJoinGuildReqList:__init()
	self:InitMsgType(10, 11)
	self.join_req_num = 0
	self.join_req_list = {}
end

function SCJoinGuildReqList:Decode()
	self.join_req_num = MsgAdapter.ReadInt()
	self.join_req_list = {}
	for i=1,self.join_req_num do
		local role_info = {}
		role_info.role_id = MsgAdapter.ReadInt()								-- 申请人的角色id
		role_info.obj_id = MsgAdapter.ReadLL()									-- 申请人的句柄
		role_info.sex = MsgAdapter.ReadUChar()									-- 申请人性别
		role_info.level = MsgAdapter.ReadInt()									-- 申请人等级
		role_info.prof = MsgAdapter.ReadUChar()									-- 申请人职业
		role_info.role_name = MsgAdapter.ReadStr()								-- 申请人名字
		role_info.zhuansheng_level = MsgAdapter.ReadUChar()						-- 申请人转生等级
		
		self.join_req_list[i] = role_info
	end
end
--开除成员结果
SCFireSomeMemberResult = SCFireSomeMemberResult or BaseClass(BaseProtocolStruct)
function SCFireSomeMemberResult:__init()
	self:InitMsgType(10, 13)
	self.role_id = 0						--(int)被开除角色id
end

function SCFireSomeMemberResult:Decode()
	self.role_id = MsgAdapter.ReadInt()
end	

-- 行会成员职位改变
SCGuildPositionChange = SCGuildPositionChange or BaseClass(BaseProtocolStruct)
function SCGuildPositionChange:__init()
	self:InitMsgType(10, 14)
	self.role_id = 0
	self.position = 0
end

function SCGuildPositionChange:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.position = MsgAdapter.ReadUChar()
end

-- 帮派升级(扩充人口)
SCGuildUpgrade = SCGuildUpgrade or BaseClass(BaseProtocolStruct)
function SCGuildUpgrade:__init()
	self:InitMsgType(10, 19)
	self.member_num = 0
end

function SCGuildUpgrade:Decode()
	self.member_num = MsgAdapter.ReadInt()
end

-- 客户端请求召唤某个成员，服务器下发给被召唤的人也是用这个消息号
SCCallGuildMember = SCCallGuildMember or BaseClass(BaseProtocolStruct)
function SCCallGuildMember:__init()
	self:InitMsgType(10, 21)
	self.obj_id = 0
	self.role_name = ""
end

function SCCallGuildMember:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.role_name = MsgAdapter.ReadStr()
end

-- 下发敌对状态的帮派列表
SCOnWarGuildList = SCOnWarGuildList or BaseClass(BaseProtocolStruct)
function SCOnWarGuildList:__init()
	self:InitMsgType(10, 24)
	self.on_war_num = 0
	self.on_war_list = {}
end

function SCOnWarGuildList:Decode()
	self.on_war_num = MsgAdapter.ReadUShort()
	self.on_war_list = {}
	for i=1, self.on_war_num do
		local guild_info = {}
		guild_info.guild_id = MsgAdapter.ReadInt()								-- 帮派的名字
		guild_info.guild_name = MsgAdapter.ReadStr()								-- 帮派的名字
		guild_info.relationship = MsgAdapter.ReadUChar()							-- 关系
		guild_info.war_left_time = MsgAdapter.ReadUInt()							-- 可以宣战的剩余秒数
		
		self.on_war_list[i] = guild_info
	end
end

-- 下发帮派战历史记录，最多100条
SCGuildWarRecord = SCGuildWarRecord or BaseClass(BaseProtocolStruct)
function SCGuildWarRecord:__init()
	self:InitMsgType(10, 25)
	self.record_num = 0
	self.record_list = {}
end

function SCGuildWarRecord:Decode()
	self.record_num = MsgAdapter.ReadUChar()
	self.record_list = {}
	for i=1, self.record_num do
		local record_info = {}
		record_info.date = MsgAdapter.ReadStr()									-- 记录时间
		record_info.guild_name = MsgAdapter.ReadStr()							-- 行会名字
		record_info.kill_enemy_num = MsgAdapter.ReadInt()						-- 杀敌数
		record_info.own_kill_num = MsgAdapter.ReadInt()							-- 己方被杀数量
		
		self.record_list[i] = record_info
	end
end

-- 更新帮派的信息 
SCUpdateGuildInfo = SCUpdateGuildInfo or BaseClass(BaseProtocolStruct)
function SCUpdateGuildInfo:__init()
	self:InitMsgType(10, 26)
end

function SCUpdateGuildInfo:Decode()
end

-- 发送给行会有其他行会请求联盟
SCGuildLeagueReq = SCGuildLeagueReq or BaseClass(BaseProtocolStruct)
function SCGuildLeagueReq:__init()
	self:InitMsgType(10, 29)
end

function SCGuildLeagueReq:Decode()
	self.guild_id = MsgAdapter.ReadInt()
	self.role_id = MsgAdapter.ReadInt()
	self.guild_name = MsgAdapter.ReadStr()
	self.role_name = MsgAdapter.ReadStr()
	self.cur_member_num = MsgAdapter.ReadInt()
	self.max_member_num = MsgAdapter.ReadInt()
end

-- 通知有更新行会列表
SCGuildListUpdate = SCGuildListUpdate or BaseClass(BaseProtocolStruct)
function SCGuildListUpdate:__init()
	self:InitMsgType(10, 31)
end

function SCGuildListUpdate:Decode()
end

-- 背包拖动物品到行会仓库 - 表示操作成功
SCMoveToGuildStorageFromBag = SCMoveToGuildStorageFromBag or BaseClass(BaseProtocolStruct)
function SCMoveToGuildStorageFromBag:__init()
	self:InitMsgType(10, 32)
end

function SCMoveToGuildStorageFromBag:Decode()
end

-- 发送仓库物品的列表
SCGuildStorageItem = SCGuildStorageItem or BaseClass(BaseProtocolStruct)
function SCGuildStorageItem:__init()
	self:InitMsgType(10, 34)
	self.item_num = 0
	self.item_list = {}
end

function SCGuildStorageItem:Decode()
	self.item_num = MsgAdapter.ReadUShort()
	self.item_list = {}
	for i=1, self.item_num do
		local role_id = MsgAdapter.ReadInt()
		local currency_type = MsgAdapter.ReadUChar()
		local currency_num = MsgAdapter.ReadInt()
		local role_name = MsgAdapter.ReadStr()
		
		self.item_list[i] = CommonReader.ReadItemData()
	end
end

-- 下发仓库操作记录
SCGuildStorageOptRecord = SCGuildStorageOptRecord or BaseClass(BaseProtocolStruct)
function SCGuildStorageOptRecord:__init()
	self:InitMsgType(10, 35)
	self.record_num = 0
	self.record_list = {}
end

function SCGuildStorageOptRecord:Decode()
	self.record_num = MsgAdapter.ReadInt()
	self.record_list = {}
	for i=1, self.record_num do
		local record_info = {}
		record_info.time = MsgAdapter.ReadInt()									-- 操作的时间
		record_info.opt = MsgAdapter.ReadStr()									-- 记录
		
		self.record_list[i] = record_info
	end
end

-- 下发行会推荐信息
SCGuildRecommendInfo = SCGuildRecommendInfo or BaseClass(BaseProtocolStruct)
function SCGuildRecommendInfo:__init()
	self:InitMsgType(10, 36)
	self.guild_id = 0
	self.guild_name = ""
end

function SCGuildRecommendInfo:Decode()
	self.guild_id = MsgAdapter.ReadInt()
	self.guild_name = MsgAdapter.ReadStr()
end

-- 反馈玩家请求求救的信息
SCPlayerHelpReqInfo = SCPlayerHelpReqInfo or BaseClass(BaseProtocolStruct)
function SCPlayerHelpReqInfo:__init()
	self:InitMsgType(10, 37)
	self.player_role_name = ""
	self.scene_id = 0
	self.x = 0
	self.y = 0
end

function SCPlayerHelpReqInfo:Decode()
	self.player_role_name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadInt()
	self.x = MsgAdapter.ReadUShort()
	self.y = MsgAdapter.ReadUShort()
end

-- 下发帮派事件
SCGuildEventList = SCGuildEventList or BaseClass(BaseProtocolStruct)
function SCGuildEventList:__init()
	self:InitMsgType(10, 38)
	self.record_num = 0
	self.record_list = {}
end

function SCGuildEventList:Decode()
	local package = MsgAdapter.ReadUShort()
	if package == 0 then
		self.record_list = {}
	end
	self.record_num = MsgAdapter.ReadUShort()
	for i=1, self.record_num do
		local data = {}
		local time = MsgAdapter.ReadUInt()									-- 记录时间
		time = bit:_and(time, 0x7fffffff)
		time = time + COMMON_CONSTS.SERVER_TIME_OFFSET
		data.time = time
		data.content = MsgAdapter.ReadStr()									-- 事件内容
		table.insert(self.record_list, data)
	end
end

-- 返回设置直接加入的结果
SCJoinHandleResult = SCJoinHandleResult or BaseClass(BaseProtocolStruct)
function SCJoinHandleResult:__init()
	self:InitMsgType(10, 39)
	self.result = 0							--0需要审核 1自动添加
end

function SCJoinHandleResult:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 下发封号列表
SCGuildTitleList = SCGuildTitleList or BaseClass(BaseProtocolStruct)
function SCGuildTitleList:__init()
	self:InitMsgType(10, 41)
	self.title_num = 0
	self.title_list = {}
end

function SCGuildTitleList:Decode()
	self.title_num = MsgAdapter.ReadUChar()
	self.title_list = {}
	for i = 1, self.title_num do
		self.title_list[i] = MsgAdapter.ReadStr()
	end
end

-- 返回设置封号的结果
SCGuildTitleResult = SCGuildTitleResult or BaseClass(BaseProtocolStruct)
function SCGuildTitleResult:__init()
	self:InitMsgType(10, 42)
	self.role_id = 0
	self.title_id = 0					--封号id, 0为没有
end

function SCGuildTitleResult:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.title_id = MsgAdapter.ReadUChar()
end

-- 下发添加或者删除帮派成员的消息
SCEditGuildMemberInfo = SCEditGuildMemberInfo or BaseClass(BaseProtocolStruct)
function SCEditGuildMemberInfo:__init()
	self:InitMsgType(10, 44)
	self.opt_type = 0				-- 1添加成员, 2删除成员
	self.data = {}
end

function SCEditGuildMemberInfo:Decode()
	self.opt_type = MsgAdapter.ReadUChar()
	local role_id = MsgAdapter.ReadInt()
	local obj_id = MsgAdapter.ReadLL()
	local name = MsgAdapter.ReadStr()
	local sex = MsgAdapter.ReadUChar()
	local level = MsgAdapter.ReadInt()
	local capacity = MsgAdapter.ReadInt()
	local prof = MsgAdapter.ReadUShort()
	local position = MsgAdapter.ReadUShort()
	local contribution = MsgAdapter.ReadUInt()
	self.data = {
		role_id = role_id,
		obj_id = obj_id,
		name = name,
		sex = sex,
		level = level,
		capacity = capacity,
		prof = prof,
		position = position,
		contribution = contribution,
		is_online = 1,
		login_time = 0,
	}
end

-- 返回扩充人口需要的信息
SCGuildUpgradeNeed = SCGuildUpgradeNeed or BaseClass(BaseProtocolStruct)
function SCGuildUpgradeNeed:__init()
	self:InitMsgType(10, 45)
	self.gold_need = 0
	self.max_member_num = 0
end

function SCGuildUpgradeNeed:Decode()
	self.gold_need = MsgAdapter.ReadInt()
	self.max_member_num = MsgAdapter.ReadInt()
end

-- 获取攻城行会列表
SCGongChengGuildList = SCGongChengGuildList or BaseClass(BaseProtocolStruct)
function SCGongChengGuildList:__init()
	self:InitMsgType(10, 48)
	self.is_sign_up = 1							--1接受报名, 2不接受报名
	self.day = 1								--1今天, 2明天
	self.sign_up_guild_name = ""
	self.sign_up_guild_num = 0
	self.sign_up_guild_list = {}
end

function SCGongChengGuildList:Decode()
	self.is_sign_up = MsgAdapter.ReadUChar()
	self.day = MsgAdapter.ReadUChar()
	if self.is_sign_up == 1 then
		self.sign_up_guild_name = MsgAdapter.ReadStr()
		self.sign_up_guild_num = MsgAdapter.ReadInt()
		self.sign_up_guild_list = {}
		for i=1, self.sign_up_guild_num do
			local guild_name = MsgAdapter.ReadStr()
			table.insert(self.sign_up_guild_list, guild_name)
		end
	end
end

-- 下发沙巴克城战的状态
SCSbkWarState = SCSbkWarState or BaseClass(BaseProtocolStruct)
function SCSbkWarState:__init()
	self:InitMsgType(10, 50)
	self.state = 0								--0开始, 1开始, 2本行会正在攻城
end

function SCSbkWarState:Decode()
	self.state = MsgAdapter.ReadUChar()
end

-- 下发沙巴克基本信息
SCSbkBaseMsg = SCSbkBaseMsg or BaseClass(BaseProtocolStruct)
function SCSbkBaseMsg:__init()
	self:InitMsgType(10, 51)
	self.guild_name = ""
	-- self.guild_main_mb_num = 0
	self.guild_main_mb_list = {}
end

function SCSbkBaseMsg:Decode()
	self.guild_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list = {}

	local msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_LEADER] = msg

	msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER] = msg

	msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR] = msg

	msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_TANGZHU_SRC] = msg

	msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_TANGZHU_THI] = msg

	msg = {}
	msg.role_id = MsgAdapter.ReadInt()
	msg.role_name = MsgAdapter.ReadStr()
	self.guild_main_mb_list[SOCIAL_MASK_DEF.GUILD_TANGZHU_FOU] = msg
	-- self.guild_main_mb_num = MsgAdapter.ReadUChar()
	-- self.guild_main_mb_list = {}
	-- for i=1, self.guild_main_mb_num do
	-- 	local mb_msg = {}
	-- 	mb_msg.mb_state = MsgAdapter.ReadUChar() 		-- (uchar)状态, 1在线, 2离线, 0空职位
	-- 	if mb_msg.mb_state ~= 0 then
	-- 		mb_msg.guild_position = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo = RoleVo.New()

	-- 		mb_msg.vo.name = MsgAdapter.ReadStr()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_PROF] = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_CIRCLE] = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo.guild_name = MsgAdapter.ReadStr()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_BATTLE_POWER] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_MOUNT_APPEARANCE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo.equip_count = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo.equip_list = {}
	-- 		for i = 1, mb_msg.vo.equip_count do
	-- 			mb_msg.vo.equip_list[i] = CommonReader.ReadItemData()
	-- 			mb_msg.vo.equip_list[i].index = i
	-- 		end
	-- 		mb_msg.vo.equip_slots_count = MsgAdapter.ReadUChar()
	-- 		mb_msg.vo.equip_slots = {}
	-- 		for i = 0, mb_msg.vo.equip_slots_count - 1 do
	-- 			mb_msg.vo.equip_slots[i] = MsgAdapter.ReadUChar()
	-- 		end
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_SOCIAL_MASK] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_VIP_GRADE] = MsgAdapter.ReadInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_MAGIC_EQUIPID] = MsgAdapter.ReadInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_OFFICE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_SOUL1] = MsgAdapter.ReadUInt()   --通灵境界1总等级 = 阶数*等级,(最高16阶, 每阶12级)
	-- 		CommonReader.ReadBaseAttr(mb_msg.vo)
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_HP] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_MAX_HP] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_MP] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_MAX_MP] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_HIT_RATE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_DOGE_RATE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_LUCK] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.CREATURE_CURSE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_HONOUR] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_PK_VALUE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_CHARM_VALUE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_CIRCLE_SOUL] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_INNER] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_MAX_INNER] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_MOUNT_EXP] = MsgAdapter.ReadInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_SWING_EXP] = MsgAdapter.ReadInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_MAGIC_EQUIPEXP] = MsgAdapter.ReadInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_CRITRATE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_RESISTANCECRIT] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_RESISTANCECRITRATE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_BOSSCRITRATE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_BATTACKBOSSCRITVALUE] = MsgAdapter.ReadUInt()
	-- 		mb_msg.vo[OBJ_ATTR.ACTOR_DIERRFRESHCD] = CommonReader.ReadServerUnixTime()
	-- 		mb_msg.vo.achieve_babge = CommonReader.ReadAchieveBabge()
	-- 	end
	-- 	table.insert(self.guild_main_mb_list, mb_msg)
	-- end
end

-- 发送打开行会集结令的面板
SCOpenCallGuildMember = SCOpenCallGuildMember or BaseClass(BaseProtocolStruct)
function SCOpenCallGuildMember:__init()
	self:InitMsgType(10, 55)
	self.call_type = 0 --1召唤个人, 2召唤群体
	self.role_name = ""
	self.scene_id = 0
	self.scene_name = ""
	self.x = 0
	self.y = 0
end

function SCOpenCallGuildMember:Decode()
	self.call_type = MsgAdapter.ReadUChar()
	self.role_name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadInt()
	self.scene_name = MsgAdapter.ReadStr()
	self.x = MsgAdapter.ReadUShort()
	self.y = MsgAdapter.ReadUShort()
end

-- 反馈有成员申请加入行会
SCFeedbackSomebodyReqJoinGuild = SCFeedbackSomebodyReqJoinGuild or BaseClass(BaseProtocolStruct)
function SCFeedbackSomebodyReqJoinGuild:__init()
	self:InitMsgType(10, 56)
end

function SCFeedbackSomebodyReqJoinGuild:Decode()
end

-- 下发沙巴克守沙的信息
SCSbkWatchInfo = SCSbkWatchInfo or BaseClass(BaseProtocolStruct)
function SCSbkWatchInfo:__init()
	self:InitMsgType(10, 60)
	self.have_success_guild = 0						--0没有成功守沙三天的行会, 1有成功守沙三天的行会
	self.guild_name = ""
	self.leader_name = ""
	self.watch_times = 0							--守沙次数, 没有为0
end

function SCSbkWatchInfo:Decode()
	self.have_success_guild = MsgAdapter.ReadUChar()
	self.guild_name = MsgAdapter.ReadStr()
	self.leader_name = MsgAdapter.ReadStr()
	self.watch_times = MsgAdapter.ReadUChar()
end

-- 下发贡献列表
SCGuildDonateList = SCGuildDonateList or BaseClass(BaseProtocolStruct)
function SCGuildDonateList:__init()
	self:InitMsgType(10, 61)
	self.num = 0
	self.donate_list = {}
end

function SCGuildDonateList:Decode()
	self.num = MsgAdapter.ReadInt()
	self.donate_list = {}
	for i=1, self.num do
		local data = {}
		data.role_id = MsgAdapter.ReadInt()					-- 行会成员的角色id
		data.rank = MsgAdapter.ReadInt()					-- 排行名次, 0为没有
		data.name = MsgAdapter.ReadStr()					-- 成员名字
		data.sex = MsgAdapter.ReadUChar()					-- 性别
		data.donate_val = MsgAdapter.ReadInt()				-- 贡献值 

		self.donate_list[i] = data
	end
end

-- 下发当天的贡献
SCGuildDonateVal = SCGuildDonateVal or BaseClass(BaseProtocolStruct)
function SCGuildDonateVal:__init()
	self:InitMsgType(10, 73)
	self.donate_val = 0
	self.today_donate_ybval = 0
end

function SCGuildDonateVal:Decode()
	self.donate_val = MsgAdapter.ReadInt()
	self.today_donate_ybval = MsgAdapter.ReadUInt()
end

-- 下发沙巴克管理层的名字
SCSBKManagerName = SCSBKManagerName or BaseClass(BaseProtocolStruct)
function SCSBKManagerName:__init()
	self:InitMsgType(10, 75)
	self.have_guild_occupy = 0					--还没有行会占领, 1已有行会占领
	self.guild_name = ""
	self.manager_num = 0
	self.mamager_list = {}
end

function SCSBKManagerName:Decode()
	self.have_guild_occupy = MsgAdapter.ReadUChar()
	if self.have_guild_occupy == 1 then
		self.guild_name = MsgAdapter.ReadStr()
		self.manager_num = MsgAdapter.ReadUChar()
		self.mamager_list = {}
		for i=1, self.manager_num do
			local role_info = {}
			role_info.pos = MsgAdapter.ReadUChar()
			role_info.name = MsgAdapter.ReadStr()
			role_info.sex = MsgAdapter.ReadUChar()

			self.mamager_list[i] = role_info
		end
	end
end

-- 下发今天报名和明天报名的行会名字
SCSBKSignUpList = SCSBKSignUpList or BaseClass(BaseProtocolStruct)
function SCSBKSignUpList:__init()
	self:InitMsgType(10, 76)
	self.day_num = 0
	self.sing_up_data = {}
end

function SCSBKSignUpList:Decode()
	self.day_num = MsgAdapter.ReadUChar()
	self.sing_up_data = {}
	for i=1, self.day_num do
		self.sing_up_data.day = MsgAdapter.ReadUChar()
		self.sing_up_data.guild_num = MsgAdapter.ReadUShort()
		local guild_name_list = {}
		for i=1, self.sing_up_data.guild_num do
			table.insert(guild_name_list, MsgAdapter.ReadStr())
		end
		self.sing_up_data.guild_name_list = guild_name_list
	end
end

-- 帮会红包信息
SCGuildRedEnvelopeInfo = SCGuildRedEnvelopeInfo or BaseClass(BaseProtocolStruct)
function SCGuildRedEnvelopeInfo:__init()
	self:InitMsgType(10, 77)
	self.sender_name = ""
	self.money = 0
	self.total_num = 0
	self.left_time = 0
	self.left_money = 0
	self.receive_member_num = 0
	self.receive_list = {}
end

function SCGuildRedEnvelopeInfo:Decode()
	self.sender_name = MsgAdapter.ReadStr()
	self.money = MsgAdapter.ReadUInt()
	self.total_num = MsgAdapter.ReadUInt()
	self.left_time = MsgAdapter.ReadUInt()				-- 剩余时间, 单位秒
	self.get_data_client_time = NOW_TIME				-- 获取数据时的客户时间
	self.left_money = MsgAdapter.ReadInt()
	self.receive_member_num = MsgAdapter.ReadUChar()
	self.receive_list = {}
	for i=1, self.receive_member_num do
		self.receive_list[i] = MsgAdapter.ReadUShort()
	end
end

-- 发帮会红包结果
SCSentRedEnvelopeResult = SCSentRedEnvelopeResult or BaseClass(BaseProtocolStruct)
function SCSentRedEnvelopeResult:__init()
	self:InitMsgType(10, 78)
	self.gift = 0
	self.sender_name = ""
	self.left_num = 0
	self.left_time = 0
	self.rec_num = 0
	self.rec_hb_list = 0
end

function SCSentRedEnvelopeResult:Decode()
	self.gift = MsgAdapter.ReadUInt()				-- 礼物句柄
	self.sender_name = MsgAdapter.ReadStr()			-- 发送者名字 
	self.total_gold_num = MsgAdapter.ReadInt()		-- 元宝数量
	self.total_num = MsgAdapter.ReadInt()			-- 红包数量
	self.left_num = MsgAdapter.ReadInt()			-- 剩余数量
	self.left_time = MsgAdapter.ReadUInt()			-- 剩余时间， 秒
	self.get_data_client_time = NOW_TIME			-- 获取数据时的客户时间
	self.rec_num = MsgAdapter.ReadUInt()			-- 领取人数量
	self.rec_hb_list = {}
	for i = 1, self.rec_num do
		local data = {
			name = MsgAdapter.ReadStr(),			-- 领取者名
			tx = MsgAdapter.ReadInt(),				-- 头像
			sex = MsgAdapter.ReadUInt(),			-- 性别
			gold_num = MsgAdapter.ReadInt(),		-- 抢到的元宝数
		}
		table.insert(self.rec_hb_list, data)
	end
end

-- 抢帮会红包结果
SCRobGuildEnvelopeResult = SCRobGuildEnvelopeResult or BaseClass(BaseProtocolStruct)
function SCRobGuildEnvelopeResult:__init()
	self:InitMsgType(10, 79)
	self.result = 0									--1成功, 0失败
end

function SCRobGuildEnvelopeResult:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 返回搜索符合邀请的玩家结果
SCQualifiedInvitePlayer = SCQualifiedInvitePlayer or BaseClass(BaseProtocolStruct)
function SCQualifiedInvitePlayer:__init()
	self:InitMsgType(10, 88)
	self.player_num = 0
	self.player_list = {}
end

function SCQualifiedInvitePlayer:Decode()
	self.player_num = MsgAdapter.ReadUChar()
	self.player_list = {}
	for i=1, self.player_num do
		local data = {}
		data.role_name = MsgAdapter.ReadStr()
		data.role_id = MsgAdapter.ReadInt()
		data.prof = MsgAdapter.ReadUChar()
		data.level = MsgAdapter.ReadInt()
		data.capacity = MsgAdapter.ReadUInt()
		self.player_list[i] = data
	end
end

-- 广播自己的状态
SCGuildMemberInfoChange = SCGuildMemberInfoChange or BaseClass(BaseProtocolStruct)
function SCGuildMemberInfoChange:__init()
	self:InitMsgType(10, 90)
	self.role_id = 0
	self.is_online = 0
	self.level = 0
	self.contribution = 0
	self.position = 0
end

function SCGuildMemberInfoChange:Decode()
	self.is_online = MsgAdapter.ReadUChar()
	self.role_id = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadUShort()
	self.contribution = MsgAdapter.ReadUInt()
	self.position = MsgAdapter.ReadUChar()
end

-- 下发沙巴克领取奖励信息
SCSBKRewardMsg = SCSBKRewardMsg or BaseClass(BaseProtocolStruct)
function SCSBKRewardMsg:__init()
	self:InitMsgType(10, 91)
	self.can_get_mark = 0 	-- (uchar)0可以领取, 1不可领取
end

function SCSBKRewardMsg:Decode()
	self.can_get_mark = MsgAdapter.ReadUChar()
end

-- 下发行会改名成功信息
SCGuildRenameSuccess = SCGuildRenameSuccess or BaseClass(BaseProtocolStruct)
function SCGuildRenameSuccess:__init()
	self:InitMsgType(10, 92)
	self.guild_id = 0
	self.guild_old_name = ""
	self.guild_new_name = ""
end

function SCGuildRenameSuccess:Decode()
	self.guild_id = MsgAdapter.ReadInt()
	self.guild_old_name = MsgAdapter.ReadStr()
	self.guild_new_name = MsgAdapter.ReadStr()
end


SCGuildSuccessResult = SCGuildSuccessResult or BaseClass(BaseProtocolStruct)
function SCGuildSuccessResult:__init()
	self:InitMsgType(10, 93)
	self.guild_name = ""
	self.guild_huizhang_name = ""
	self.guild_fuhuizhuang_name = ""
end

function SCGuildSuccessResult:Decode()
	self.guild_name = MsgAdapter.ReadStr()
	self.guild_huizhang_name = MsgAdapter.ReadStr()
	self.guild_fuhuizhuang_name = MsgAdapter.ReadStr()
end

-- 行会悬赏结果
SCGuildOfferResult = SCGuildOfferResult or BaseClass(BaseProtocolStruct)
function SCGuildOfferResult:__init()
	self:InitMsgType(10, 94)
	self.score = 0 					--积分
	self.rew_sign = 0 				--领取标记
	self.task_list = {}
end

function SCGuildOfferResult:Decode()
	self.score = MsgAdapter.ReadInt()
	self.rew_sign = MsgAdapter.ReadInt()
	self.task_count = MsgAdapter.ReadUChar()
	for i = 1, self.task_count do
		local vo = {
			task_id = MsgAdapter.ReadUChar(), 			-- 任务id
			task_state = MsgAdapter.ReadUChar(), 		-- 任务状态 0未接 1已接 2完成
			complete_num = MsgAdapter.ReadUChar(), 		-- 已完成次数
			is_reward = MsgAdapter.ReadUChar(), 		-- 是否已领取任务奖  0否 1是
		}
		self.task_list[i] = vo
	end
end

-- 接收行会弹劾数据
-- key = 0-会长本次的登录时间 1-会长上次的下线时间 2-弹劾开始时间  3-上次弹劾结束时间  4-发起弹劾玩家id  5-赞成票数  6-反对票数 7-发起弹劾玩家名字
SCGuildImpeachInfo = SCGuildImpeachInfo or BaseClass(BaseProtocolStruct)
function SCGuildImpeachInfo:__init()
	self:InitMsgType(10, 95)
	self.info = {}
	self.now_time = 0
end

function SCGuildImpeachInfo:Decode()
	local count = MsgAdapter.ReadUChar()
	local list = {}
	for i = 1, count do
		local key = MsgAdapter.ReadInt()
		if key == 7 then
			list[key] = MsgAdapter.ReadStr()
		else
			list[key] = MsgAdapter.ReadUInt()
		end
	end
	self.info = list
end

-- 接收玩家投票数据
SCGuildImpeachVote = SCGuildImpeachVote or BaseClass(BaseProtocolStruct)
function SCGuildImpeachVote:__init()
	self:InitMsgType(10, 96)
	self.vote = 0 -- 1赞同, 2反对
end

function SCGuildImpeachVote:Decode()
	self.vote = MsgAdapter.ReadInt()
end
