DragonPrayGuild = class("DragonPrayGuild")
DragonPrayGuild.__index = DragonPrayGuild

Enum_DragonPrayGuildShaiZi =
{
	[1] = _T("福"),
	[2] = _T("禄"),
	[3] = _T("寿"),
	[4] = _T("喜"),
	[5] = _T("财"),
	[6] = _T("吉"),
}

Enum_DragonPrayGuildSkill =
{
	[1] = _T("福如东海"),
	[2] = _T("高官厚禄"),
	[3] = _T("寿比南山"),
	[4] = _T("喜从天降"),
	[5] = _T("财源广进"),
	[6] = _T("吉星高照"),
}

function DragonPrayGuild:getScoreAndRank()
	return self.nScore or 0 , self.nRank or 0
end

function DragonPrayGuild:getRank()
	return self.tbRank or {}
end

function DragonPrayGuild:getPrayTime()
	return g_DataMgr:getCsvConfigByTwoKey("GuildActivity", 1, "MaxTimes") - g_Hero:getDailyNoticeByType(macro_pb.DT_JiXing)
end

function DragonPrayGuild:getDiceType(nIndex)
	if self.tbDiceType and self.tbDiceType[nIndex] then
		return self.tbDiceType[nIndex]
	end
	return macro_pb.DiceType_Ji
end

function DragonPrayGuild:openRank()
    local tbData = {}
    tbData.tbBossRankInfo = self.tbRank
    tbData.nMax = self.nMaxRank
    tbData.bScore = true
	g_WndMgr:showWnd("Game_WorldBossRank", tbData)
end

function DragonPrayGuild:requestPray()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_JI_XING_REQUEST)
end

function DragonPrayGuild:requestPrayResponse(tbMsg)
	local msg = zone_pb.JiXingRsp()
	msg:ParseFromString(tbMsg.buffer)
	self.nScore = msg.update_my_score
	self.nRank = msg.update_my_rank
	self.tbDiceType = msg.type
	self.tbRank = msg.role

	g_Hero:incDailyNoticeByType(macro_pb.DT_JiXing)

	g_FormMsgSystem:PostFormMsg(FormMsg_DragonPrayGuild_Pray)
end

--复用BOSS排名协议, damage即score
function DragonPrayGuild:requestInitResponse(tbMsg)
	local msg = zone_pb.JiXingInitRsp()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	self.tbDiceType = msg.dice_type
	self.tbRank = msg.role
	self.nMaxRank = msg.max_rank
	if self.tbRank then
		for k,v in ipairs(self.tbRank) do
			if v.uin == g_MsgMgr:getUin() then
				self.nScore = v.damage
				self.nRank = k
			end
		end
	end

	self.bInit = true
	g_WndMgr:openWnd("Game_DragonPrayGuild")
end

function DragonPrayGuild:requestRankResponse(tbMsg)
	local msg = zone_pb.JiXingRankListRsp()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

end

function DragonPrayGuild:isInit()
	if not self.bInit then
		g_MsgMgr:sendMsg(msgid_pb.MSGID_JI_XING_INIT_REQUEST)
	end
	return self.bInit
end

function DragonPrayGuild:reset()
	self.bInit = false
end

function DragonPrayGuild:ctor()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_JI_XING_INIT_RESPONSE,handler(self,self.requestInitResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_JI_XING_RESPONSE,handler(self,self.requestPrayResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_JI_XING_RANK_LIST_RESPONSE,handler(self,self.requestRankResponse))
end

g_DragonPrayGuild = DragonPrayGuild.new()