--ChatConstant.lua

Channel_ID_Privacy	= 1		--私聊
Channel_ID_Team		= 2		--队伍频道
Channel_ID_Faction	= 3		--帮派
Channel_ID_World	= 4		--世界频道(广播)
Channel_ID_Bugle	= 5		--小喇叭
Channel_ID_System	= 6		--系统公告
Channel_ID_Area 	= 7 	--区域频道

--CD表
CHAT_CD_TIME =
{
	{
		[Channel_ID_Privacy] = 3,
		[Channel_ID_Team] = 3,
		[Channel_ID_Faction] = 3,
		[Channel_ID_World] = 25, 			--由30改为25
		[Channel_ID_Bugle] = 0, 			--由10改为0
		[Channel_ID_Area] = 3,
		[Channel_ID_System] = 0,
	},
	{
		[Channel_ID_Privacy] = 3,
		[Channel_ID_Team] = 3,
		[Channel_ID_Faction] = 3,
		[Channel_ID_World] = 25, 			--由10改为25
		[Channel_ID_Bugle] = 0,
		[Channel_ID_Area] = 3,
		[Channel_ID_System] = 0,
	},
}

-----------------------------------
CHAT_WORLD_LEVEL = 25	--世界频道发言所需等级
BUGLE_ITEMID = 1000 -- 小喇叭ID
BUGLE_REGTIME = 1	--小喇叭喊话效果停留时间    由8秒修改为1
FREE_BUGLE_NUM = 5

MAX_MSG_STORE = 5	--世界频道消息存储数
STORAGE_NUM = 15	--数据库存储的私聊条数
MSG_MAX_LENGTH = 400   	--单条聊天输入文字的最大长度

------------------------eCode----------------
CHATERR_CHAT_INCD = -1		--还在CD中
CHATERR_BESILENT= -2		--被禁言
CHATERR_NOT_INTEAM = -3		--不在队伍中
CHATERR_NOT_INFACTION = -4	--不在帮会中
CHATERR_WORLD_LEVEL = -5	--世界频道需要30级
CHATERR_HAS_NO_BUGLE = -6	--没有小喇叭
CHATERR_PLAYER_OFFLINE = -7	--玩家不在线，数据丢失
CHATERR_ITEM_CHANGED = -8	--物品位置已经变更
CHATERR_BE_LOOKUP = -9		--被人查看提示
CHATERR_MAX_LENGTH = -15 	--内容过长
CHATERR_IN_COPY = -16 		--副本中无法进行区域聊天
CHATERR_INPUT_ERR = -20 	--输入内容有误
CHATERR_BESILENT_EVER = -21 --永久禁言
CHATERR_AUTHKEY_TEIMOUT = -22 -- 获取离线语音KEY超时
CHATERR_TRANSLATE_TIMEOUT = -23 --时实翻译超时

TEAM_DATA_SERVER_ID = 1
ITEM_SHARE_TIME = 24


--短语输入
PHRASE_MAX_INDEX = 6
PHRASE_MAX_LEN = 40

--[[
Phrase_Old = {
	'初来乍到，各位兄弟姐妹，在下于此见个礼啦！',
	'无兄弟，不传世！加我好友，一起传世！',
	'给你阳光你就灿烂，给你洪水你就泛滥，我让老奶奶涂点红唇儿，给你点颜色看看',
	'来啊！干啊！',
	'中州安全区集合',
	'弟兄们跟我上！',
}
]]

Phrase_Old = {
	'',
	'',
	'',
	'',
	'',
	'',
}


--每秒发送消息条数
ONCE_SEND_WORLD = 30 		--小喇叭
ONCE_SEND_BUGLE = 2 		--世界频道