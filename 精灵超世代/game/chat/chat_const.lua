-- notes: 聊天常量数据
-- author:hp

ChatConst = ChatConst or {}

--说话者类型;1:玩家   2:gm    4:传闻   8:系统    10:宗门
ChatConst.Player = 1
ChatConst.GM     = 2
ChatConst.Notice = 4
ChatConst.System = 8
ChatConst.Gang   = 10

--聊天类型
ChatConst.TYPE_WORD  = 0  --文字聊天
ChatConst.TYPE_VOICE = 1  --语音聊天
ChatConst.TYPE_TASK  = 2  --任务聊天
ChatConst.TYPE_HERO  = 3  --宝可梦聊天
ChatConst.TYPE_PACK  = 4  --背包聊天

--聊天事件
ChatConst.Voice_Translate_Main  = "chat_voice_translate_main"      --更新左下角聊天翻译内容
ChatConst.Voice_Translate_Panel = "chat_voice_translate_panel"     --更新聊天界面翻译内容
ChatConst.AdjustMainChatZorder  = "ChatConst.AdjustMainChatZorder" --调整左下角聊天ZOrder

--聊天点击 事件类型
ChatConst.Link =
{
	Item_Show  = 49,    --物品展示
	Guild_Join = 6,	 --申请入帮
	Guild_mem_red = 7, --公会成员红包
	Guild_show_red = 8,--查看公会成员红包
	BargainHelp = 15,--砍价链接
	BigworldBoss = 16,	-- 大世界的BS
	BigworldBossPos = 17,	-- 世界指定位置
	OtherRole = 18,	-- 弹出信息面板
	Watch_Ladder = 51,  -- 查看天梯录像
	Open_Ladder = 52,   -- 打开天梯界面
	Open_Vedio_info = 57,   -- 打开从录像馆分享的录像
	Crossarena = 58, 	-- 跨服竞技场（挑战）
	Crossarena_honour = 59, -- 跨服竞技场（赛季荣耀）
	Action_Treasure = 60, -- 跳转到一元夺宝

    Honor_Icon = 61, -- 荣誉icon分享
    Task_Exp = 62, -- 历练任务分享
    Honor_Level = 63, -- 荣誉等级分享
    Growth_Way = 64, --成长之路分享
	Crosschampion = 65, -- 周冠军赛
	Elfin_Summon = 68, -- 精灵召唤
	voyage_senior_privilege = 69, -- 远航高级特权
	voyage_Luxury_privilege = 70, -- 远航豪华特权
	select_elite_summon = 71, -- 自选精英召唤
}
--聊天频道,客户端规则
--频道;1:世界;2:场景;4:宗门;8;队伍;16:传闻;32:顶部传闻;64:系统;128:顶部系统
ChatConst.Channel =
{
	Multi     = -1,      --加强频道(综合频道)
	Whole     = 0 ,       --世界频道
	World     = 1,       --世界频道
	Scene     = 2,       --场景频道
	Gang      = 4,       --宗门频道
	Friend    = 7,       --好友频道
	Team      = 8,       --队伍频道
	Notice    = 16,      --传闻频道
	NoticeTop = 32,      --传闻频道
	System    = 64,      --系统频道
	SystemTop = 128,     --顶部系统
	Team_Sys   = 512,     --队伍系统信息
	Gang_Sys  = 256,     --系统宗门
	Cross     = 1024,    --跨服频道
	Drama 	  = 99,		 --剧情频道  
	Province  = 2048, 	 --同省频道

}

--聊天内容标记
ChatConst.ContFlag =
{
	Normal = 0, --文字信息
	Voice  = 1, --语音聊天
	Show   = 2, --展示
}

--聊天频道方框资源
ChatConst.ChannelRes=
{
	[0]   = "world",
	[1]   = "world",
	[2]   = "scene",--场景频道，临时资源
	[4]   = "gang",
	[7]   = "friend",
	[8]   = "system", --队伍频道，临时资源
	[16]  = "notice",
	[64]  = "system",
	[256] = "gang",
	[512] = "system",
	[1024] = "cross",
	[99] = "drama",
}
--聊天频道方框资源
ChatConst.ChannelWord=
{
	[0]   = "世界",
	[1]   = "世界",
	[2]   = "场景",--场景频道，临时资源
	[4]   = "gang",
	[7]   = "私聊",
	[8]   = "队伍", --队伍频道，临时资源
	[16]  = "传闻",
	[64]  = "系统",
	[256] = "gang",
	[512] = "系统",
	[1024] = "跨服",
	[99] = "剧情",
}
ChatConst.capacity = 
{
	[0]   = "",
}


ChatConst.ornament = 
{
	[1] = {type=1,x=13, y=17},
	[2] = {type=2,x=9, y=3},
}

ChatConst.ornamentAnchor = 
{
	[1] = cc.p(1,1),
	[2] = cc.p(0,0),
}

ChatConst.ViewType = 
{
	Normal = 1,     -- 普通界面
	Adventure = 2,  -- 冒险界面
}

-- 不同界面对应聊天框的高度
ChatConst.ChatBoxHeight = 
{
	[ChatConst.ViewType.Normal] = {231, 412}, 
	[ChatConst.ViewType.Adventure] = {131, 412}, 
}
ChatConst.ChatPanelHeight = 
{
	[ChatConst.ViewType.Normal] = {166, 347}, 
	[ChatConst.ViewType.Adventure] = {66, 347}, 
}
ChatConst.ChatTabHeight = 
{
	[ChatConst.ViewType.Normal] = {239, 420}, 
	[ChatConst.ViewType.Adventure] = {139, 420}, 
}

-- 主界面全部频道聊天内容颜色
ChatConst.MainMsgColor = 
{
	[ChatConst.Channel.World]     = cc.c3b(255, 255, 255),
	[ChatConst.Channel.Gang]      = cc.c3b(19, 252, 96),
	[ChatConst.Channel.Friend]    = cc.c3b(255, 255, 255),
	[ChatConst.Channel.Notice]    = cc.c3b(255, 250, 118),
	[ChatConst.Channel.System]    = cc.c3b(255, 250, 118),
	[ChatConst.Channel.Drama]    = cc.c3b(255, 250, 118),
	[ChatConst.Channel.Cross]     = cc.c3b(255, 255, 255),
	[ChatConst.Channel.Province]     = cc.c3b(255, 255, 255),
}

-- 主界面私聊频道聊天内容颜色
ChatConst.MainFriendMsgColor = 
{
	[1] = cc.c3b(19, 252, 96),
	[2] = cc.c3b(255, 255, 255)
}

-- 主界面聊天玩家名称颜色
ChatConst.MainNameColor = 
{
	[ChatConst.Channel.World]     = "#24ecf3",
	[ChatConst.Channel.Gang]      = "#24ecf3",
	[ChatConst.Channel.Friend]    = "#24ecf3",
	[ChatConst.Channel.Drama]     = "#24ecf3",
	[ChatConst.Channel.Cross]     = "#24ecf3",
	[ChatConst.Channel.Province]     = "#24ecf3",
}

-- 聊天输入框提示文字颜色
ChatConst.MianInputColor = cc.c3b(95, 63, 32)

-- 聊天好友项颜色
ChatConst.MainChatButtonColor = 
{
	[1] = cc.c3b(155, 70, 18),
	[2] = cc.c3b(208, 183, 159),
}

-- X秒后清掉聊天数据
ChatConst.Clear_Chat_Time = 300

ChatConst.ChatInputType = {
	eChatWindw 					= "chatWindow", --聊天的 --未更新对应位置代码
	eMessageBoardpanel 			= "MessageBoardpanel", --留言板的 
	eMessageBoardReplyPanel 	= "MessageBoardReplyPanel", --留言板弹窗的 
	eArenateam 					= "Arenateam", --组队竞技场 --by lwc
}