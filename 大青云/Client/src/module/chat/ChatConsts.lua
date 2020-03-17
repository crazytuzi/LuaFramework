--[[
聊天常量
lizhuangzhuang
2014年9月17日20:43:36
]]
_G.ChatConsts = {};

--限制字符
ChatConsts.Restrict = "^<>{}#&";
--输入过滤
ChatConsts.InputReg = "[<>{}#&]+";

ChatConsts.ChatParam_SenderName = 0;--聊天发送者;type,roleID,roleName,teamId,guildId,guildPos,vip,lvl,icon,cityPos,vflag,isGM,跨服,fromChannel
ChatConsts.ChatParam_RoleName = 1;--人名;type,roleID,roleName,teamId,guildId,guildPos,vip,lvl,icon,cityPos,vflag,isGM
ChatConsts.ChatParam_Item = 2;--物品;type,物品id
ChatConsts.ChatParam_Equip = 3;--装备;type,装备id
ChatConsts.ChatParam_MapPos = 4;--地图坐标;type,line,mapId,x,y
ChatConsts.ChatParam_Value = 5;--数值;type,value
ChatConsts.ChatParam_Link = 6;--链接;type,脚本参数
ChatConsts.ChatParam_Dungeons = 7;--副本;type,副本id
ChatConsts.ChatParam_Monster = 8;--怪物;type,怪物id
ChatConsts.ChatParam_Title = 9;--称号;type,称号id
ChatConsts.ChatParam_Guild = 10;--帮派;type,帮派id,帮派名
ChatConsts.ChatParam_WorldBoss = 11;--世界BOss;type,活动id
ChatConsts.ChatParam_WuHun = 12;--武魂;type,武魂id
ChatConsts.ChatParam_ShenBing = 13;--神兵;type,神兵id
ChatConsts.ChatParam_Horse = 14;--坐骑;type,坐骑id
ChatConsts.ChatParam_JingJie = 15;--境界;type,境界id
ChatConsts.ChatParam_WebLink = 16;--超链接;type,超链接地址
ChatConsts.ChatParam_Activity = 17;--活动;type,活动id
ChatConsts.ChatParam_BaoJia = 18;--宝甲;type,宝甲id
ChatConsts.ChatParam_GuildPos = 19;--帮派职位;type,职位id
ChatConsts.ChatParam_SuperAttr = 20;--卓越属性;type,id,val1,val2
ChatConsts.ChatParam_FengYao = 21;--封妖;type,封妖id
-- ChatConsts.ChatParam_LingZhen = 22;--灵阵;type,灵阵id
ChatConsts.ChatParam_Timing = 23;--灵光封魔;type,灵光封魔id
ChatConsts.ChatParam_LSHorse = 24;--灵兽做起;type,灵兽坐骑id
ChatConsts.ChatParam_VIPType = 25;--VIP类型;type,vip类型
ChatConsts.ChatParam_MapID = 26;--地图;type,mapID
ChatConsts.ChatParam_EquipGroup = 27;--套装;type,套装id
ChatConsts.ChatParam_WarPrint = 28;--战印;type,战印id
ChatConsts.ChatParam_JueXue = 29;--绝学;type,绝学id
ChatConsts.ChatParam_RideWar = 30;--骑战;type,骑战id
ChatConsts.ChatParam_ShenWu = 31;--神武;type,神武id
ChatConsts.ChatParam_Timestamp = 32;--时间戳;type,时间戳字符串:'2015,12,31'
ChatConsts.ChatParam_ShengQi = 33;--圣器;type,圣器id
ChatConsts.ChatParam_Collection = 34;--采集物;type,采集物id   --adder:houxudong date:2016/7/30
ChatConsts.ChatParam_XinFa = 35;--心法;type,采集物id          --adder:houxudong date:2016/8/9
ChatConsts.ChatParam_TianShen=36; --天神;type,天神id
ChatConsts.ChatParam_MingYu=37; --玉佩;type,玉佩id
ChatConsts.ChatParam_LingQi=38; --灵器;type,灵器id
ChatConsts.ChatParam_Makino=39; --牧野;type,牧野id
ChatConsts.ChatParam_Armor=40; --新宝甲;type,新宝甲id
ChatConsts.ChatParam_DiBoss=41; --地宫boss;type,地宫boss id


ChatConsts.ChatParamMap = {
	[ChatConsts.ChatParam_SenderName] = SenderNameChatParam,
	[ChatConsts.ChatParam_RoleName] = RoleNameChatParam,
	[ChatConsts.ChatParam_Item] = ItemChatParam,
	[ChatConsts.ChatParam_Equip] = EquipChatParam,
	[ChatConsts.ChatParam_MapPos] = MapPosChatParam,
	[ChatConsts.ChatParam_Value] = ValueChatParam,
	[ChatConsts.ChatParam_Link] = LinkChatParam,
	[ChatConsts.ChatParam_Dungeons] = DungeonsChatParam,
	[ChatConsts.ChatParam_Monster] = MonsterChatParam,
	[ChatConsts.ChatParam_Title] = TitleChatParam,
	[ChatConsts.ChatParam_Guild] = GuildChatParam,
	[ChatConsts.ChatParam_WorldBoss] = WorldBossChatParam,
	[ChatConsts.ChatParam_WuHun] = WuHunChatParam,
	[ChatConsts.ChatParam_ShenBing] = ShenBingChatParam,
	[ChatConsts.ChatParam_Horse] = HorseChatParam,
	[ChatConsts.ChatParam_JingJie] = JingJieChatParam,
	[ChatConsts.ChatParam_WebLink] = WebLinkChatParam,
	[ChatConsts.ChatParam_Activity] = ActivityChatParam,
	[ChatConsts.ChatParam_BaoJia] = BaoJiaChatParam,
	[ChatConsts.ChatParam_GuildPos] = GuildPosChatParam,
	[ChatConsts.ChatParam_SuperAttr] = SuperAttrChatParam,
	[ChatConsts.ChatParam_FengYao] = FengYaoChatParam,
	-- [ChatConsts.ChatParam_LingZhen] = LingZhenChatParam,
	[ChatConsts.ChatParam_Timing] = TimingChatParam,
	[ChatConsts.ChatParam_LSHorse] = LSHorseChatParam,
	[ChatConsts.ChatParam_VIPType] = VIPTypeChatParam,
	[ChatConsts.ChatParam_MapID] = MapIDChatParam,
	[ChatConsts.ChatParam_EquipGroup] = EquipGroupChatParam,
	[ChatConsts.ChatParam_WarPrint] = WarPrintChatParam,
	[ChatConsts.ChatParam_JueXue] = JueXueChatParam,
	[ChatConsts.ChatParam_RideWar] = RideWarChatParam,
	[ChatConsts.ChatParam_ShenWu] = ShenWuChatParam,
	[ChatConsts.ChatParam_Timestamp] = TimestampChatParam,
	[ChatConsts.ChatParam_ShengQi] = ShengQiChatParam,
	[ChatConsts.ChatParam_Collection] = CollectionChatParam,
	[ChatConsts.ChatParam_XinFa] = XinFaChatParam,
	[ChatConsts.ChatParam_TianShen] =TianShenChatParam,
	[ChatConsts.ChatParam_MingYu] = MingYuChatParam,
	[ChatConsts.ChatParam_LingQi] = LingQiChatParam,
	[ChatConsts.ChatParam_Armor] = ArmorChatParam,
	[ChatConsts.ChatParam_DiBoss] = XianYuanCaveChatParam,
}

--聊天数量上限
ChatConsts.MaxNum_All = 100;--综合上限
ChatConsts.MaxNum_Channel = 50;--频道上限
--输入上限
ChatConsts.MaxInputNum = 100;
--喇叭输入上限
ChatConsts.HornMaxInputNum = 60;
--私聊人数上限
ChatConsts.MaxPrivateChat = 10;

--面板自动隐藏时间
ChatConsts.PanelAutoHideTime = 20000;
--聊天输入间隔
ChatConsts.InputInterval = 5;
--发送坐标间隔
ChatConsts.UsePosInterval = 5;

--聊天频道
ChatConsts.Channel_All = 1;--综合
ChatConsts.Channel_World = 2;--世界
ChatConsts.Channel_Map = 3;--区域
ChatConsts.Channel_Camp = 4;--阵营
ChatConsts.Channel_Guild = 5;--帮派
ChatConsts.Channel_Team = 6;--队伍
ChatConsts.Channel_Horn = 7;--喇叭
ChatConsts.Channel_Private = 8;--私聊
ChatConsts.Channel_Cross = 9;--跨服
ChatConsts.Channel_System = 10;--系统
ChatConsts.Channel_Cross_Map = 101;--跨服，区域
ChatConsts.Channel_Cross_Server = 102;--跨服，本服

--公告位置
ChatConsts.NoticePos_AllServer = 1;--全服
ChatConsts.NoticePos_Server = 2;--本服
ChatConsts.NoticePos_Activity = 3;--活动
ChatConsts.NoticePos_Chat = 4;--聊天窗口

--频道颜色
ChatConsts.Color_All = "#ffa734";--综合
ChatConsts.Color_World = "#ffa302";--世界
ChatConsts.Color_Map = "#ffffff";--区域
ChatConsts.Color_Camp = "#22a140";--阵营
ChatConsts.Color_Guild = "#00ffd2";--帮派
ChatConsts.Color_Team = "#3d8fff";--组队
ChatConsts.Color_Private = "#ff359e";--私聊
ChatConsts.Color_Horn = "#ff8000";--喇叭
ChatConsts.Color_Cross = "#a64df9";--跨服
ChatConsts.Color_System = "#dc1d03";--系统

--对人名的菜单操作
ChatConsts.ROper_Chat = 1;--私聊
ChatConsts.ROper_ShowInfo = 2;--查看资料
ChatConsts.ROper_AddFriend = 3;--加为好友
ChatConsts.ROper_AddBlack = 4;--加入黑名单
ChatConsts.ROper_GuildInvite = 5;--邀请入帮
ChatConsts.ROper_GuildApply = 6;--申请入帮
ChatConsts.ROper_TeamCreate = 7;--创建队伍
ChatConsts.ROper_TeamApply = 8;--申请入队
ChatConsts.ROper_TeamInvite = 9;--邀请入队
ChatConsts.ROper_CopyName = 10;--复制名字
ChatConsts.ROper_Report = 11;--举报
--所有操作
ChatConsts.AllROper = {ChatConsts.ROper_Chat,ChatConsts.ROper_ShowInfo,ChatConsts.ROper_AddFriend,ChatConsts.ROper_AddBlack,
						ChatConsts.ROper_GuildInvite,ChatConsts.ROper_GuildApply ,
						ChatConsts.ROper_TeamCreate,ChatConsts.ROper_TeamApply,ChatConsts.ROper_TeamInvite,
						ChatConsts.ROper_CopyName,ChatConsts.ROper_Report};

--获取操作名
function ChatConsts:GetOperName(oper)
	if oper == ChatConsts.ROper_Chat then
		return StrConfig['chat400'];
	elseif oper == ChatConsts.ROper_ShowInfo then
		return StrConfig['chat401'];
	elseif oper == ChatConsts.ROper_AddFriend then
		return StrConfig['chat402'];
	elseif oper == ChatConsts.ROper_AddBlack then
		return StrConfig['chat403'];
	elseif oper == ChatConsts.ROper_GuildInvite then
		return StrConfig['chat404'];
	elseif oper == ChatConsts.ROper_GuildApply then
		return StrConfig['chat405'];
	elseif oper == ChatConsts.ROper_TeamCreate then
		return StrConfig['chat406'];
	elseif oper == ChatConsts.ROper_TeamApply then
		return StrConfig['chat407'];
	elseif oper == ChatConsts.ROper_TeamInvite then
		return StrConfig['chat408'];
	elseif oper == ChatConsts.ROper_CopyName then
		return StrConfig['chat409'];
	elseif oper == ChatConsts.ROper_Report then
		return StrConfig['chat410']
	end
end						
						
--获取频道名
function ChatConsts:GetChannelName(channel)
	if channel == ChatConsts.Channel_All then
		return StrConfig["chat200"];
	elseif channel == ChatConsts.Channel_World then
		return StrConfig["chat201"];
	elseif channel == ChatConsts.Channel_Map then
		return StrConfig["chat202"];
	elseif channel == ChatConsts.Channel_Camp then
		return StrConfig["chat203"];
	elseif channel == ChatConsts.Channel_Guild then
		return StrConfig["chat204"];
	elseif channel == ChatConsts.Channel_Team then
		return StrConfig["chat205"];
	elseif channel == ChatConsts.Channel_Horn then
		return StrConfig["chat206"];
	elseif channel == ChatConsts.Channel_Cross then
		return StrConfig["chat207"];
	elseif channel == ChatConsts.Channel_System then
		return StrConfig["chat208"];
	elseif channel == ChatConsts.Channel_Private then
		return StrConfig['chat601'];
	elseif channel == ChatConsts.Channel_Cross_Map then
		return StrConfig['chat603']
	elseif channel == ChatConsts.Channel_Cross_Server then
		return StrConfig['chat602']
	end
	return "";
end

--获取频道颜色
function ChatConsts:GetChannelColor(channel)
	if channel == ChatConsts.Channel_All then
		return ChatConsts.Color_All;
	elseif channel == ChatConsts.Channel_World then
		return ChatConsts.Color_World;
	elseif channel == ChatConsts.Channel_Map then
		return ChatConsts.Color_Map;
	elseif channel == ChatConsts.Channel_Camp then
		return ChatConsts.Color_Camp;
	elseif channel == ChatConsts.Channel_Guild then
		return ChatConsts.Color_Guild;
	elseif channel == ChatConsts.Channel_Team then
		return ChatConsts.Color_Team;
	elseif channel == ChatConsts.Channel_Private then
		return ChatConsts.Color_Private;
	elseif channel == ChatConsts.Channel_Horn then
		return ChatConsts.Color_Horn;
	elseif channel == ChatConsts.Channel_Cross then
		return ChatConsts.Color_Cross;
	elseif channel == ChatConsts.Channel_System then
		return ChatConsts.Color_System;
	end
	return ChatConsts.Color_All;
end

--聊天表情定义
--图片后面要多加个空格，别问为什么，fuck
ChatConsts.Face = {
	[1] = {key="[/01]",url='<img src="img://resfile/icon/face_01.gif"/> '},
	[2] = {key="[/02]",url='<img src="img://resfile/icon/face_02.gif"/> '},
	[3] = {key="[/03]",url='<img src="img://resfile/icon/face_03.gif"/> '},
	[4] = {key="[/04]",url='<img src="img://resfile/icon/face_04.gif"/> '},
	[5] = {key="[/05]",url='<img src="img://resfile/icon/face_05.gif"/> '},
	[6] = {key="[/06]",url='<img src="img://resfile/icon/face_06.gif"/> '},
	[7] = {key="[/07]",url='<img src="img://resfile/icon/face_07.gif"/> '},
	[8] = {key="[/08]",url='<img src="img://resfile/icon/face_08.gif"/> '},
	[9] = {key="[/09]",url='<img src="img://resfile/icon/face_09.gif"/> '},
	[10] = {key="[/10]",url='<img src="img://resfile/icon/face_10.gif"/> '},
	[11] = {key="[/11]",url='<img src="img://resfile/icon/face_11.gif"/> '},
	[12] = {key="[/12]",url='<img src="img://resfile/icon/face_12.gif"/> '},
	[13] = {key="[/13]",url='<img src="img://resfile/icon/face_13.gif"/> '},
	[14] = {key="[/14]",url='<img src="img://resfile/icon/face_14.gif"/> '},
	[15] = {key="[/15]",url='<img src="img://resfile/icon/face_15.gif"/> '},
	[16] = {key="[/16]",url='<img src="img://resfile/icon/face_16.gif"/> '},
	[17] = {key="[/17]",url='<img src="img://resfile/icon/face_17.gif"/> '},
	[18] = {key="[/18]",url='<img src="img://resfile/icon/face_18.gif"/> '},
	[19] = {key="[/19]",url='<img src="img://resfile/icon/face_19.gif"/> '},
	[20] = {key="[/20]",url='<img src="img://resfile/icon/face_20.gif"/> '},
	
	[21] = {key="[/v01]",url='<img src="img://resfile/icon/face_v01.gif"/> ',vip=true},
	[22] = {key="[/v02]",url='<img src="img://resfile/icon/face_v02.gif"/> ',vip=true},
	[23] = {key="[/v03]",url='<img src="img://resfile/icon/face_v03.gif"/> ',vip=true},
	[24] = {key="[/v04]",url='<img src="img://resfile/icon/face_v04.gif"/> ',vip=true},
	[25] = {key="[/v05]",url='<img src="img://resfile/icon/face_v05.gif"/> ',vip=true},
	[26] = {key="[/v06]",url='<img src="img://resfile/icon/face_v06.gif"/> ',vip=true},
	[27] = {key="[/v07]",url='<img src="img://resfile/icon/face_v07.gif"/> ',vip=true},
	[28] = {key="[/v08]",url='<img src="img://resfile/icon/face_v08.gif"/> ',vip=true},
	[29] = {key="[/v09]",url='<img src="img://resfile/icon/face_v09.gif"/> ',vip=true},
	[30] = {key="[/v10]",url='<img src="img://resfile/icon/face_v10.gif"/> ',vip=true},
	[31] = {key="[/v11]",url='<img src="img://resfile/icon/face_v11.gif"/> ',vip=true},
	[32] = {key="[/v12]",url='<img src="img://resfile/icon/face_v12.gif"/> ',vip=true},
	[33] = {key="[/v13]",url='<img src="img://resfile/icon/face_v13.gif"/> ',vip=true},
	[34] = {key="[/v14]",url='<img src="img://resfile/icon/face_v14.gif"/> ',vip=true},
	[35] = {key="[/v15]",url='<img src="img://resfile/icon/face_v15.gif"/> ',vip=true},
	[36] = {key="[/v16]",url='<img src="img://resfile/icon/face_v16.gif"/> ',vip=true},
	[37] = {key="[/v17]",url='<img src="img://resfile/icon/face_v17.gif"/> ',vip=true},
	[38] = {key="[/v18]",url='<img src="img://resfile/icon/face_v18.gif"/> ',vip=true},
	[39] = {key="[/v19]",url='<img src="img://resfile/icon/face_v19.gif"/> ',vip=true},
	[40] = {key="[/v20]",url='<img src="img://resfile/icon/face_v20.gif"/> ',vip=true},
}

--城主职位
ChatConsts.CityPos_None = 0;
ChatConsts.CityPos_Duke = 1;--城主
ChatConsts.CityPos_DeputyDuke = 2;--副城主
ChatConsts.CityPos_QL = 3;--青龙
ChatConsts.CityPos_BH = 4;--白虎
ChatConsts.CityPos_ZQ = 5;--朱雀
ChatConsts.CityPos_XW = 6;--玄武
ChatConsts.CityPos_Guild = 7;--至尊王帮

function ChatConsts:GetCityPosName(pos)
	if pos == ChatConsts.CityPos_None then
		return "";
	elseif pos == ChatConsts.CityPos_Duke then
		return StrConfig['chat500'];
	elseif pos == ChatConsts.CityPos_DeputyDuke then
		return StrConfig['chat501'];
	elseif pos==ChatConsts.CityPos_QL or pos==ChatConsts.CityPos_BH or
			pos==ChatConsts.CityPos_ZQ or pos==ChatConsts.CityPos_XW then
		return StrConfig['chat502'];	
	elseif pos == ChatConsts.CityPos_Guild then
		return StrConfig['chat503'];
	end
	return "";
end

--世界呐喊类型 CS
ChatConsts.WorldNoticeXuanShang 	  = 1;	--悬赏
--世界呐喊类型 CW
ChatConsts.WorldNoticeTimeDungeon 	  = 1;	--灵光封魔
ChatConsts.WorldNoticeUnion 		  = 2;	--帮派招人
ChatConsts.WorldNoticePataDungeon     = 3;  --爬塔副本
ChatConsts.WorldNoticeMakinoDungeon   = 4;  --牧野之战