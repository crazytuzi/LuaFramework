--------------------------------------------------------------------------------------
-- 文件名:	Class_TurnTableInfo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-5-26 
-- 版  本:	1.0
-- 描  述:	保存在登录的时候下发来的爱心转盘数据	
-- 应  用:	
---------------------------------------------------------------------------------------

TurnTableInfoData = class("TurnTableInfoData")
TurnTableInfoData.__index = TurnTableInfoData


function TurnTableInfoData:setTableInfo(tbMsg)
	cclog(tostring(tbMsg).."爱心转盘数据")
	local msgData = tbMsg

	local cur_cfg_idx = msgData.cur_cfg_idx	--转盘当前所在的idx
	local turn_show_lst = msgData.turn_show_lst --转盘显示的列表数据，对应配置表中的id
	local coldTiemat =	msgData.cold_timeat --转盘冷却时间
	self.turnTable = {} 
	self.turnTable["cur_cfg_idx"] = cur_cfg_idx + 1 --转盘当前所在的idx
	self.turnTable["coldTiemat"] = coldTiemat  --转盘冷却时间
	self.turnTable["turn_show_lst"] = {}
	for key,value in ipairs(turn_show_lst)  do
		local t = {}
		t["cfg_id"] = turn_show_lst[key]["cfg_id"]
		t["quality"] = turn_show_lst[key]["quality"] 
		table.insert(self.turnTable["turn_show_lst"],t)
	end
	
end

function TurnTableInfoData:getTableInfo()
	return self.turnTable
end


--抽取了那个位置的奖品
function TurnTableInfoData:getCurCfgIdx()
	return self:getTableInfo().cur_cfg_idx
end
--设置抽取后的奖品位置
function TurnTableInfoData:setCurCfgIdx(nIndex)
	local tbInfo = self:getTableInfo()
	tbInfo["cur_cfg_idx"] = nIndex
end

function TurnTableInfoData:getTurnShowLst(nIndex)
	local tbInfo = self:getTableInfo()
	return tbInfo["turn_show_lst"][nIndex]
end

--配置表物品类型
function TurnTableInfoData:getTurnShowLstByCfgId(nIndex)
	return self:getTurnShowLst(nIndex)["cfg_id"]
end
--品质ID
function TurnTableInfoData:getTurnShowLstByQuality(nIndex)
	return self:getTurnShowLst(nIndex)["quality"]
end

--冷却时间 
function TurnTableInfoData:getTurnShowColdTiemat()
	return self:getTableInfo().coldTiemat 
end
function TurnTableInfoData:setTurnShowColdTiemat(coldTiemat)
	self:getTableInfo().coldTiemat = coldTiemat
end

--转盘开始请求 
function TurnTableInfoData:requestTurnTableStartResponse()
	-- g_MsgNetWorkWarning:showWarningText(true)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_TURNTABLESTART_REQUEST)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_TURNTABLESTART_REQUEST) 
end

--转盘开始响应
function TurnTableInfoData:turnTableStartResponse(tbMsg)
	cclog("---------Game_Turntable:turnTableStartResponse----")
	cclog("----转盘开始响应----")
	local rootMsg = zone_pb.TurnTableStartResponse()
	rootMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(rootMsg)
	cclog(msgInfo)
	
	local curTurnIdx = rootMsg.cur_turn_idx + 1
	self:setCurCfgIdx(curTurnIdx)
	
	local updateHeartNum = rootMsg.update_heart_num -- 更新友情点
	g_Hero:setFriendPoints(updateHeartNum)
	
	-- local coldTimeat = rootMsg.cold_timeat
	-- self:setTurnShowColdTiemat(coldTimeat)
	
	g_FormMsgSystem:SendFormMsg(FormMsg_Turn_Info, curTurnIdx)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_TURNTABLESTART_REQUEST, msgid_pb.MSGID_TURNTABLESTART_RESPONSE)
	
end


function TurnTableInfoData:ctor()

	--转盘开始响应
	local order = msgid_pb.MSGID_TURNTABLESTART_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.turnTableStartResponse))	
	
	
end

---------------------------------------------------------------------------------
g_TurnTableInfoData = TurnTableInfoData.new()
