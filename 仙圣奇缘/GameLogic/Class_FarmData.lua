--------------------------------------------------------------------------------------
-- 文件名:	Class_FarmData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-5-26 
-- 版  本:	1.0
-- 描  述:	保存在登录的时候下发来的农田数据	
-- 应  用:	
---------------------------------------------------------------------------------------

FarmData = class("FarmData")
FarmData.__index = FarmData

--农田数据保存
function FarmData:setFarmBaseInfo(tbMsg)
	local fieldExp = tbMsg.field_exp --农田经验
	local incenseTimes = tbMsg.incense_times --祝福次数
	self.expTimes = tbMsg.plant_exp_times
	self.tbFarmData = {}

	self.tbFarmData.field_exp = fieldExp
	self.tbFarmData.incense_times = incenseTimes
	self.tbFarmData.fields = {}

	local fields = tbMsg.fields
	for key = 1, #fields do
		local tbView = {
			status = fields[key].status,--农田状态
			deadline = fields[key].deadline,--冷却时间戳
			reward_lv = fields[key].reward_lv,--奖励等级
			plant_type = fields[key].plant_type,--种植类型
		}
		table.insert(self.tbFarmData.fields,tbView)
	end
	
	
end

function FarmData:getFarmRefresh()
	return self.tbFarmData
end

--设置药园某一个地方的状态 status
--[[
	@param nIndex 传入农田编号
]]
function FarmData:setFarmDataStatus(nIndex,status,deadline,plant_type,reward_lv)
	if nIndex <= 0 then nIndex = 1 end 
	if status then
		self.tbFarmData.fields[tonumber(nIndex)].status = status
	end

	if deadline then
		self.tbFarmData.fields[tonumber(nIndex)].deadline = deadline
	end

	if plant_type then
		self.tbFarmData.fields[tonumber(nIndex)].plant_type = plant_type
	end

	if reward_lv then
		self.tbFarmData.fields[tonumber(nIndex)].reward_lv = reward_lv
	end

end

--祝福次数
function FarmData:setIncenseCount()
	if self.tbFarmData.incense_times <= 0 then return end
	self.tbFarmData.incense_times = self.tbFarmData.incense_times - 1
end
--经验树种植次数
function FarmData:getExpTimes()
	return self.expTimes
end

function FarmData:setExpTimes(num)
	self.expTimes = self.expTimes + num
end

function FarmData:setExpTimesZero(num)
	self.expTimes = num
end

function FarmData:initResponse()
	--刷新响应
	local order = msgid_pb.MSGID_FARM_NEW_OPEN_NOTIFY
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmNewOpenNotifyResponse))
	
end

--新开启了几个就发几个
function FarmData:requestFarmNewOpenNotifyResponse(tbMsg)
	cclog("---------requestFarmNewOpenNotifyResponse-------------")
	cclog("---------农田新开启了几个就发几个-------------")
	local msgDetail = zone_pb.FarmNewOpenNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local openList = msgDetail.open_list 
	for i = 1,#openList do
		local nIndex = openList[i].field_idx --农田下标
		local field = openList[i].field
		local status = field.status			--农田状态
		local deadline = field.deadline		--冷却时间戳
		local reward_lv = field.reward_lv		--奖励等级
		local plant_type = field.plant_type	--种植类型
		self:setFarmDataStatus(nIndex,status,deadline,plant_type,reward_lv)
	end
	
end

function FarmData:getOpenFarmNum()
	local openNum = 0
	local data = self:getFarmRefresh().fields
	for i = 1,#data do
		if data[i].status == common_pb.FFS_OPENED --空闲
			or data[i].status == common_pb.FFS_COOLINGDOWN 	--冷却中
			or data[i].status == common_pb.FFS_PLANTED then --已种植
			openNum = openNum + 1
		-- else
			-- openNum = openNum - 1
		end
		
	end
	return openNum
end

---------------------------------------------------------------------------------
g_FarmData = FarmData.new()
g_FarmData:initResponse()
