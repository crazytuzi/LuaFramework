--------------------------------------------------------------------------------------
-- 文件名:	EquipRefineStarUpData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	装备精炼升级
-- 应  用: 
---------------------------------------------------------------------------------------
EquipRefineStarUpData = class("EquipRefineStarUpData")
EquipRefineStarUpData.__index = EquipRefineStarUpData

local equipRefineCost = g_DataMgr:getCsvConfig("EquipRefineCost")

-- 装备精炼升级请求	
function EquipRefineStarUpData:requestEquipRefineLvupRequest(equipId)
	cclog("============装备精炼升级请求===requestEquipRefineLvupRequest===")
	local msg = zone_pb.EquipRefineLvupRequest()
	msg.equip_id = equipId	--装备ID
	g_MsgMgr:sendMsg(msgid_pb.MSGID_EQUIP_REFINE_LVUP_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()
end

-- 装备精炼升级响应
function EquipRefineStarUpData:requestEquipRefineLvupResponse(tbMsg)
	cclog("---------requestEquipRefineLvupResponse---装备精炼升级响应---------")
	local msgDetail = zone_pb.EquipRefineLvupResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local equipId = msgDetail.equip_id --服务器装备id 
	local curRefineLv = msgDetail.cur_refine_lv --当前精炼等级
	local curCoin = msgDetail.cur_coin 	-- 当前铜钱
	local curDragonBall = msgDetail.cur_dragon_ball -- 当前龙珠
	
	g_Hero:setDragonBall(curDragonBall) 
	g_Hero:setCoins(curCoin) 
	
	local tbEquip = g_Hero:getEquipObjByServID(equipId)
	tbEquip:setRefineLev(curRefineLv)
	
	if self.UpFunc then 
		self.UpFunc(equipId)
		self.UpFunc = nil
	end
	
	local instance = g_WndMgr:getWnd("Game_Equip1")
	if instance then instance:updateEquipIcon() end
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

function EquipRefineStarUpData:ctor()
	-- 购买次数，清除CD请求
	local order = msgid_pb.MSGID_EQUIP_REFINE_LVUP_RESPONSE	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestEquipRefineLvupResponse))	
	
	self.UpFunc = nil
	
end
function EquipRefineStarUpData:upFunc(func)
	self.UpFunc = func
end

function EquipRefineStarUpData:getCsvConfigItem(refineLevel)
	local cvsInfo = equipRefineCost[refineLevel]
	if refineLevel >= #equipRefineCost then 
		return equipRefineCost[#equipRefineCost]
	end
	
	if not cvsInfo then 
		return ConfigMgr.EquipRefineCost_[0]
	end
	return cvsInfo
end

function EquipRefineStarUpData:getCSVEquipRefineCost()
	return equipRefineCost
end
-----------------------------------------------------------------------
g_EquipRefineStarUpData = EquipRefineStarUpData.new()
