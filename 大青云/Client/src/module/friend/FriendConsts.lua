--[[
好友常量
lizhuangzhuang
2014年10月17日21:19:56
]]

_G.FriendConsts = {};

--关系类型
FriendConsts.RType_Friend = 1;--好友
FriendConsts.RType_Enemy = 2;--仇人
FriendConsts.RType_Black = 3;--黑名单
FriendConsts.RType_Recent = 4;--最近

--好友刷新时间
FriendConsts.UpdateTime = 10000;

--好友操作
FriendConsts.Oper_ShowInfo = 1;--查看资料
FriendConsts.Oper_Chat = 2;--私聊
FriendConsts.Oper_TeamCreate = 3;--创建队伍
FriendConsts.Oper_TeamApply = 4;--申请入队
FriendConsts.Oper_TeamInvite = 5;--邀请入队
FriendConsts.Oper_GuildInvite = 6;--邀请入帮
FriendConsts.Oper_GuildApply = 7;--申请入帮
FriendConsts.Oper_AddFriend = 8;--添加好友
FriendConsts.Oper_RemoveFriend = 9;--删除好友
FriendConsts.Oper_CopyName = 10;--复制名字
FriendConsts.Oper_RemoveRecent = 11;--移除最近联系人
FriendConsts.Oper_RemoveEnemy = 12;--移除仇人
FriendConsts.Oper_AddBlack = 13;--加入黑名单
FriendConsts.Oper_RemoveBlack = 14;--移除黑名单 
--所有操作
FriendConsts.AllOper = {FriendConsts.Oper_ShowInfo,FriendConsts.Oper_Chat,
						FriendConsts.Oper_TeamCreate,FriendConsts.Oper_TeamApply,FriendConsts.Oper_TeamInvite,
						FriendConsts.Oper_GuildInvite,FriendConsts.Oper_GuildApply,
						FriendConsts.Oper_AddFriend,FriendConsts.Oper_RemoveFriend,FriendConsts.Oper_CopyName,
						FriendConsts.Oper_RemoveRecent,FriendConsts.Oper_RemoveEnemy,
						FriendConsts.Oper_AddBlack,FriendConsts.Oper_RemoveBlack};
						
--获取操作名
function FriendConsts:GetOperName(oper)
	if oper == FriendConsts.Oper_ShowInfo then
		return StrConfig["friend401"];
	elseif oper == FriendConsts.Oper_Chat then
		return StrConfig["friend402"];
	elseif oper == FriendConsts.Oper_TeamCreate then
		return StrConfig["friend403"];
	elseif oper == FriendConsts.Oper_TeamApply then
		return StrConfig["friend404"];
	elseif oper == FriendConsts.Oper_TeamInvite then
		return StrConfig["friend405"];
	elseif oper == FriendConsts.Oper_GuildInvite then
		return StrConfig["friend406"];
	elseif oper == FriendConsts.Oper_GuildApply then
		return StrConfig["friend407"];
	elseif oper == FriendConsts.Oper_AddFriend then
		return StrConfig["friend408"];
	elseif oper == FriendConsts.Oper_RemoveFriend then
		return StrConfig["friend409"];
	elseif oper == FriendConsts.Oper_CopyName then
		return StrConfig["friend410"];
	elseif oper == FriendConsts.Oper_RemoveRecent then
		return StrConfig["friend411"];
	elseif oper == FriendConsts.Oper_RemoveEnemy then
		return StrConfig["friend412"];
	elseif oper == FriendConsts.Oper_AddBlack then
		return StrConfig["friend413"];
	elseif oper == FriendConsts.Oper_RemoveBlack then
		return StrConfig["friend414"];
	end
	return "";
end

function FriendConsts:GetOnlineStr(status)
	if status == 1 then
		return "";
	elseif status == 0 then
		return StrConfig["friend103"];
	elseif status == 2 then
		return StrConfig["friend102"];
	end
	return "";
end