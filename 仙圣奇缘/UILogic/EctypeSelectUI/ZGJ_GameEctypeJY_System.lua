--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-30
-- 版  本:	1.0
-- 描  述:	精英副本System
-- 应  用:  
---------------------------------------------------------------------------------------

EctypeJYItem = class("EctypeJYItem")
EctypeJYItem.__index = EctypeJYItem

function EctypeJYItem:isEnable()

end










EctypeJY = class("EctypeJY")
EctypeJY.__index = EctypeJY

-- function EctypeJY:ctor()
	-- self.tbEctype = {}
-- end
-- function g_getDataFormTb(tb,...)
-- 	if type(tb) ~= "table" then
-- 		return nil
-- 	end
-- 	local tbData = g_copyTab(tb)
-- 	local nNum = select('#', ...)
--     local i = 1;
-- 	for i = 1, nNum do  
--         local arg = select(i, ...)
--         if type(tbData[arg]) == "table" then
-- 			tbData = tbData[arg]
-- 		else
-- 			break
-- 		end 
--     end
--     if i == nNum then
--     	return tbData
--     else
--     	return nil
--     end
-- end

function EctypeJY:isPassed(nPage, nIndex)
	--return g_getDataFormTb(self.tbEctype,...)
	return self.tbEctype and self.tbEctype[nPage] and self.tbEctype[nPage][nIndex]
end

function EctypeJY:getMaxAttackPage()
	if 0 == #self.tbEctype then
		return 1
	end
	local tb = self.tbEctype[#self.tbEctype]
	if 1 == #self.tbEctype and 5 == #tb then
		return 2
	elseif 4 == #tb then
		return #self.tbEctype + 1
	end
	return #self.tbEctype
end

function EctypeJY:getStarNum(nPage,nIndex)
	return self.tbEctype and self.tbEctype[nPage] and self.tbEctype[nPage][nIndex] and self.tbEctype[nPage][nIndex].star_num or 0
end

function EctypeJY:getAttackNum(nPage,nIndex)
	return self.tbEctype and self.tbEctype[nPage] and self.tbEctype[nPage][nIndex] and self.tbEctype[nPage][nIndex].attack_num or 0
end

function EctypeJY:setAttackNum(nPage,nIndex,nNum)
	if self.tbEctype and self.tbEctype[nPage] and self.tbEctype[nPage][nIndex] then 
		self.tbEctype[nPage][nIndex].attack_num = nNum
	else
		cclog("没有值")
	end
end

function EctypeJY:getTotalPages()
 	local csv = g_DataMgr:getCsvConfig("MapEctypeJingYing")
 	return #csv
end

function EctypeJY:getCurAttackJY()
	return self.nCurPage, self.nCurIndex
end

function EctypeJY:setCurAttackJY(nPage, nIndex)
	self.nCurPage, self.nCurIndex = nPage, nIndex
end

function EctypeJY:getDirty()
	return self.bDirty
end

function EctypeJY:setDirty(flag)
	self.bDirty = flag
end
--在 self.tbReward还没有保存数据的时候 取表 物品掉落时使用到
function EctypeJY:getReward(nPage,nIndex)
	return self.tbReward and self.tbReward[nPage] and self.tbReward[nPage][nIndex] or g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing",nPage,nIndex)
end

function EctypeJY:setReward(csvInfo, nPage, nIndex)
	--构造掉落数据
	--副本配置表有三个固定的掉落项
	if not self.tbReward then
		self.tbReward = {}
	end
	if not self.tbReward[nPage] then
		self.tbReward[nPage] = {}
	end
	if self.tbReward[nPage][nIndex] then
		return
	end

	local tbReward = {}
	if csvInfo ~= nil then
		for nPreViewDropPackType = 1, 7 do
			local nDropSubPackClientID = csvInfo["ShowDropPackID"..nPreViewDropPackType]
			if nDropSubPackClientID > 0 then
				local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", nDropSubPackClientID)--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", nDropSubPackClientID)
				if CSV_DropSubPackClient then
					for k, v in pairs (CSV_DropSubPackClient) do
						if v.DropItemID > 0 then
							table.insert(tbReward, v)
						end
					end
				end
			end
		end
		self.tbReward[nPage][nIndex] = tbReward
	end
end

--是否初始化
function EctypeJY:isInit()
	return self.isFirst
end

function EctypeJY:requestJYInfo()
	if self.isFirst then
		self.isFirst = false
		g_MsgMgr:sendMsg(msgid_pb.MSGID_JING_YING_INFO_REQUEST)
	else
		if ( g_WndMgr:getWnd("Game_Ectype") and g_WndMgr:isVisible("Game_Ectype") ) or g_WndMgr:isVisible("Game_Assistant") then
			g_WndMgr:openWnd("Game_EctypeJY")
		else
			-- 这里是掉落指引那里请求精英副本数据，所以不需要打开界面
		end
	end
end

function EctypeJY:requestAttackJY()
	local msg = zone_pb.AttackJingYingEctypeRequest()
	msg.page_id, msg.idx_id = self:getCurAttackJY()
	g_MsgNetWorkWarning:showWarningText()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ATTACK_JING_YING_REQUEST, msg)
end

function EctypeJY:requestJYInfoResponse(tbMsg)
	local msg = zone_pb.JingYingEctypeInfoResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local jing_ying = msg.jing_ying
	self.nMaxPage = jing_ying.pass_page_id
	self.nMaxNum = jing_ying.pass_idx_id
	local page_list = jing_ying.page_list
	local tbEctype = {}
	if self.nMaxPage ~= 0 then	
		for k,v in ipairs(page_list) do
			tbEctype[v.page_id] = {}
			for key,val in ipairs(v.ectype_list) do
				table.insert(tbEctype[v.page_id],val)
			end
		end
		
	end
	self.tbEctype = tbEctype
	if ( g_WndMgr:getWnd("Game_Ectype") and g_WndMgr:isVisible("Game_Ectype") ) or g_WndMgr:isVisible("Game_Assistant") then
		g_WndMgr:openWnd("Game_EctypeJY")
	else
		-- 这里是掉落指引那里请求精英副本数据，所以不需要打开界面
	end
end

function EctypeJY:requestAttackJYResponse(tbMsg)
	local msg = zone_pb.AttackJingYingEctypeResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:setEnergy(msg.cur_energy)
	local nPage = msg.page_id or 1
	local nIndex = msg.idx_id or 1
	if not self.tbEctype[nPage] then
		self.tbEctype[nPage] = {}
	end
	self.tbEctype[nPage][nIndex]={star_num = msg.star_num, attack_num = msg.attack_num}
	self:setDirty(true) 
end

function EctypeJY:refreshAttackNum()
	if not self.isFirst then
		for k, v in pairs(self.tbEctype) do
			for m, n in pairs(v) do
				n.attack_num = 0
			end
		end
	end
end

function EctypeJY:ctor()
	self.isFirst = true
	self.tbEctype = {}
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_JING_YING_INFO_RESPONSE,handler(self,self.requestJYInfoResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ATTACK_JING_YING_RESPONSE,handler(self,self.requestAttackJYResponse))
end


g_EctypeJY = EctypeJY.new()