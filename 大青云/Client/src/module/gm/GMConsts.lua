--[[
GM常量
lizhuangzhuang
2015年10月14日21:04:45
]]

_G.GMConsts = {};

--类型
GMConsts.T_UnChat = 1;
GMConsts.T_UnLogin = 2;
GMConsts.T_UnMac = 3;

GMConsts.MaxChat = 100;

--GM监控的聊天频道
GMConsts.ChatChannel = {
	ChatConsts.Channel_World,
	ChatConsts.Channel_Map,
	ChatConsts.Channel_Camp,
	ChatConsts.Channel_Guild,
	ChatConsts.Channel_Team,
	ChatConsts.Channel_Horn,
	ChatConsts.Channel_Private,
	ChatConsts.Channel_Cross
};

--GM操作(为了和其他模块区分,特意设定一个大值)
GMConsts.Oper_UnChat1Hour = 10001;			--禁言1小时
GMConsts.Oper_UnChat1Day = 10002;			--禁言1天
GMConsts.Oper_UnChatForever = 10003;		--永久禁言
GMConsts.Oper_UnChatUnlock = 10004;			--解除禁言
GMConsts.Oper_UnLogin1Hour = 10005;			--封停1小时
GMConsts.Oper_UnLogin1Day = 10006;			--封停1天
GMConsts.Oper_UnLoginForever = 10007;		--永久封停
GMConsts.Oper_UnLoginUnlock = 10008;		--解除封停
GMConsts.Oper_UnMac = 10009;				--封停Mac
GMConsts.Oper_UnMacUnlock = 10010;			--解除封停Mac
GMConsts.Oper_Offline = 10011;				--踢下线
--所有操作
GMConsts.AllOper = {GMConsts.Oper_UnChat1Hour,GMConsts.Oper_UnChat1Day,GMConsts.Oper_UnChatForever,
					GMConsts.Oper_UnChatUnlock,GMConsts.Oper_UnLogin1Hour,GMConsts.Oper_UnLogin1Day,
					GMConsts.Oper_UnLoginForever,GMConsts.Oper_UnLoginUnlock,GMConsts.Oper_UnMac,
					GMConsts.Oper_UnMacUnlock,GMConsts.Oper_Offline};

					
GMConsts.GOper_Leader = 20001;				--任命帮主
GMConsts.GOper_SubLeader = 20002;			--任副帮主
GMConsts.GOper_Elder = 20003;				--任命长老
GMConsts.GOper_Elite = 20004;				--任命精英
GMConsts.GOper_Common = 20005;				--任命帮众
GMConsts.GOper_KickOut = 20006;				--踢出帮派				

GMConsts.AllGOper = {GMConsts.GOper_Leader,GMConsts.GOper_SubLeader,GMConsts.GOper_Elder,GMConsts.GOper_Elite,
					GMConsts.GOper_Common,GMConsts.GOper_KickOut};
					
function GMConsts:GetOperName(oper)
	if oper == GMConsts.Oper_UnChat1Hour then
		return StrConfig["gm001"];
	elseif oper == GMConsts.Oper_UnChat1Day then
		return StrConfig["gm002"];
	elseif oper == GMConsts.Oper_UnChatForever then
		return StrConfig["gm003"];
	elseif oper == GMConsts.Oper_UnChatUnlock then
		return StrConfig["gm004"];
	elseif oper == GMConsts.Oper_UnLogin1Hour then
		return StrConfig["gm005"];
	elseif oper == GMConsts.Oper_UnLogin1Day then
		return StrConfig["gm006"];
	elseif oper == GMConsts.Oper_UnLoginForever then
		return StrConfig["gm007"];
	elseif oper == GMConsts.Oper_UnLoginUnlock then
		return StrConfig["gm008"];
	elseif oper == GMConsts.Oper_UnMac then
		return StrConfig["gm009"];
	elseif oper == GMConsts.Oper_UnMacUnlock then
		return StrConfig["gm010"];
	elseif oper == GMConsts.Oper_Offline then
		return StrConfig["gm011"];
	elseif oper == GMConsts.GOper_Leader then
		return StrConfig["gm012"];
	elseif oper == GMConsts.GOper_SubLeader then
		return StrConfig["gm013"];
	elseif oper == GMConsts.GOper_Elder then
		return StrConfig["gm014"];
	elseif oper == GMConsts.GOper_Elite then
		return StrConfig["gm015"];
	elseif oper == GMConsts.GOper_Common then
		return StrConfig["gm016"];
	elseif oper == GMConsts.GOper_KickOut then
		return StrConfig["gm017"];
	end
end
									

