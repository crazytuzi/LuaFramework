--------------------------------------------------------------------------------------
-- 文件名:	FateData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	猎命 数据	
-- 应  用:	
---------------------------------------------------------------------------------------

FateData = class("FateData")
FateData.__index = FateData

local posX = {
	745,888,888,744,536,393,393,535
}
local posY = {
	642,500,290,148,147,290,500,642
}
--妖兽配置表
-- local tbCardFate = g_DataMgr:getCsvConfig("CardFate")

function FateData:getCardFateInfo(nId,nLevel)
	return g_DataMgr:getCardFateCsv(nId, nLevel)--tbCardFate[nId][nLevel]
end

--保存猎妖请求刷新的初始数据
function FateData:HuntFateRefresh(msg)
	local huntFateInfo = msg.hunt_fate_info
	
	local t = {}
	for i = 1,#huntFateInfo.fate_list do
		local fate_list = {}
		fate_list.id = huntFateInfo.fate_list[i].id
		fate_list.lv = huntFateInfo.fate_list[i].lv
		table.insert(t,fate_list)
	end
	self:setAllTableFateList(t)
	
	local npc_status = {}
	for key, value in ipairs(huntFateInfo.npc_status) do
		local index = 0
		if value == true then 
			index = 1
		end
		npc_status[key] = index
	end
	self:setTableNpcStatus(npc_status)
	
end

function FateData:setAllTableFateList(fate)
	self.allTableFateList = fate
end

function FateData:setAloneFateList(key,nId,nLevel)
	if not key or not self.allTableFateList[key] then return end
	self.allTableFateList[key].id = nId 
	self.allTableFateList[key].lv = nLevel 
end

function FateData:getAloneFateList(key)
	return self.allTableFateList[key]
end

function FateData:getAllTableFateList()
	return self.allTableFateList 
end

--猎妖师Npc的当前状态
function FateData:setTableNpcStatus(npcStatus)
	self.npcStatus = npcStatus
end

function FateData:getTableNpcStats()
	return self.npcStatus
end

--获取当前出现了第几位猎妖师
function FateData:getNpcStatsByIndex()
	local nIndex = 1
	local tbNpcStats = self:getTableNpcStats() or {}
	for i,value in ipairs(tbNpcStats) do
		if value == 1 then 
			nIndex = i + 1
		end
	end
	return nIndex
end
-----------------------------以下是动画函数-----------------------
--[[
	拾取动画 
	在拾取时创建一个新的对象 用来执行动画
]]
function FateData:spriteCreate(rootWidget,key,cardFate)
	
	local pos = nil
	if key <= 0 then 
		pos = ccp(640, 395)
	else
		pos = ccp(posX[key],posY[key])
	end
	local colorType = cardFate.ColorType
	local fateBase = CCSprite:create(getUIImg("FateBase"..colorType))
	fateBase:setScale(0.5)
	fateBase:setPosition(pos)	
	rootWidget:addNode(fateBase,INT_MAX)
	
	local size = fateBase:getContentSize()
	local pos = ccp(size.width/2,size.height/2)
	
	local fateBack = CCSprite:create(getUIImg("FateBack"..colorType))
	fateBack:setPosition(pos)	
	fateBase:addChild(fateBack)
	
	local fate = CCSprite:create(getIconImg(cardFate.Animation))
	fate:setPosition(pos)
	fateBase:addChild(fate)
	
	local fateFrame = CCSprite:create(getUIImg("FateFrame"..colorType))
	fateFrame:setPosition(pos)
	fateBase:addChild(fateFrame)

	return fateBase, fate

end

--[[
	拾取动画
	@param 
	param = {
		widget = nil,key = nil,cardFate = nil,func = nil 
	}
]]
function FateData:moveToAnimation(param)
	local key = param.key
	local cardFate = param.cardFate
	local func = param.func
	local rootWidget = param.widget
	local fateBase = self:spriteCreate(rootWidget,key,cardFate)
	-- local x,y = 67,656
	local x,y = 67,420
	fateSucceedAction(fateBase,x,y,function() 
		if func then func() end
	end)
	
end

function FateData:sellAnimation(rootWidget, AnimationPos, Image_HuntFateItem, sysFunc,pluralLayout)
	if not pluralLayout then pluralLayout = true end
	local function SellFateEvent()
		local tbWorldPos = Image_HuntFateItem:getWorldPosition()
		local param = {
			text = _T("获得")..self:getSellByGold().._T("铜钱"),
			layout = rootWidget,
			fontSize = 24,
			x = tbWorldPos.x,
			y = tbWorldPos.y,
			sysFunc = sysFunc,
			pluralLayout = true,
		}
		g_ShowSysTipsWord(param)
	end
	
	local tbFrameCallBack = { SellFateEvent = SellFateEvent, }
	local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("FateSellAnimation", tbFrameCallBack, nil, 5)
	AnimationPos:addNode(armature)
	userAnimation:playWithIndex(0)	

end


--出售动画 
function FateData:failureAnimation(rootWidget, AnimationPos, Image_HuntFateItem, funcCallBack)
	if not Image_HuntFateItem then return end 
	Image_HuntFateItem:setCascadeOpacityEnabled(true)
	self:sellAnimation(rootWidget, AnimationPos, Image_HuntFateItem, funcCallBack)
	fateFailureOutAction(Image_HuntFateItem, nil)
end

-------------------------------以上是动画函数----------------------------------

--猎妖刷新请求
function FateData:requestHuntFateRefresh()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_REFRESH_REQUEST)
	g_MsgNetWorkWarning:showWarningText(true)
	cclog("==========FateData:requestHuntFateRefresh===========")
end

--猎妖刷新请求响应
function FateData:requestHuntFateRefreshResponse(tbMsg)
	cclog("---------requestHuntFateRefreshResponse-------------")
	local msgDetail = zone_pb.HuntFateRefreshResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail)) 
	
	self:HuntFateRefresh(msgDetail)
	
	g_WndMgr:openWnd("Game_HuntFate1")

	g_MsgNetWorkWarning:closeNetWorkWarning()
	
end

--一键猎妖
function FateData:requestHuntFateAutoHunt()
echoj("=============一键猎妖==================")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_AUTO_HUNT_REQUEST)
	g_MsgNetWorkWarning:showWarningText(true)
end
--一键猎妖响应
function FateData:requestHuntFateAutoHuntResponse(tbMsg)
	cclog("---------requestHuntFateAutoHuntResponse------一键猎妖响应-------")
	local msgDetail = zone_pb.HuntFateAutoHuntResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local tbHunt = {}
	local huntList = msgDetail.hunt_list
	
	--if huntList == nil or huntList == {} then
	if huntList == nil or next(huntList) == nil then
		SendError("==msgDetail.hunt_list is nil or empty==")
	end
	
	for _, v in ipairs(huntList) do
		if v.fate_info then 
			local fateInfo = v.fate_info
			local id = fateInfo.id
			local nLevel = fateInfo.lv
			local nIndex = v.idx
			self:setAloneFateList(nIndex,id,nLevel)
			g_Hero:setCoins(v.total_golds)
		end
		
		local npcValue = {}
		for key = 1, #v.npc_status do 
			table.insert(npcValue, v.npc_status[key])
		end
		
		table.insert(tbHunt,npcValue)
	end

    if next(tbHunt) == nil then
		SendError("==requestHuntFateAutoHuntResponse==服务器数据下发妖兽数据为空==")
	end
	
	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_OneKeyHuntFate, tbHunt)
end


--猎妖请求
function FateData:requestHuntFateHunt(npcIdx)
	cclog("---------猎妖请求---requestHuntFateHunt----------"..npcIdx)
	local msg = zone_pb.HuntFateHuntRequest()
	msg.npc_idx = npcIdx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_HUNT_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText(true)
end

--单个猎妖请求响应	-- local nRandom = math.random(1,9)
function FateData:requestHuntFateHuntResponse(tbMsg)
	cclog("---------requestHuntFateHuntResponse--------------")
	cclog("---------猎妖请求响应--------------")
	local msgDetail = zone_pb.HuntFateHuntResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	local totalGolds = msgDetail.total_golds
	g_Hero:setCoins(totalGolds)
	
	local fateInfo = msgDetail.fate_info
	local id = fateInfo.id 
	local nLevel = fateInfo.lv
	
	local idx = msgDetail.idx
	
	self:setAloneFateList(idx,id,nLevel)
	
	--设置猎妖Npc状态
	local npcStatus = msgDetail.npc_status

	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_Info,{id = id,nLevel = nLevel,npcStatus = npcStatus})
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
end

--妖兽单个出售
function FateData:requestHuntFateSell(idx)
	cclog("---妖兽单个出售--")
	local msg = zone_pb.HuntFateSellRequest()
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_SELL_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText(true)
end
--单个妖兽出售
function FateData:requestHuntFateSellResponse(tbMsg)
	cclog("---------requestHuntFateSellResponse-------------")
	cclog("---------单个妖兽出售-------------")
	local msgDetail = zone_pb.HuntFateSellResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	-- cclog(tostring(msgDetail))

	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local nIndex = msgDetail.idx
	local golds = msgDetail.total_golds

	local addGold = golds - g_Hero:getCoins()
	self:setSellByGold(addGold)
	
	local fateList = self:getAloneFateList(nIndex)
	if not fateList then
		return false
	end

	local id = fateList.id
	local nLevel = fateList.lv
	local cardFate = self:getCardFateInfo(id,nLevel)
	
	g_playSoundEffect("Sound/Drop_Money.mp3")
	g_Hero:setCoins(golds)
	
	self:setAloneFateList(nIndex,0,0)

	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_OneSell,{nIndex = nIndex,addGold = addGold})
	
	g_playSoundEffect("Sound/Drop_Money.mp3")

	return true
end

--一键出售
function FateData:requestHuntFateAutoSell()
	echoj("=============一键出售==================")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_AUTO_SELL_REQUEST)
	g_MsgNetWorkWarning:showWarningText(true)
	-- g_MsgNetWorkWarning:showWarningText()
end

--一键出售响应
function FateData:requestHuntFateAutoSellResponse(tbMsg)
	cclog("---------requestHuntFateAutoSellResponse-一键出售响应------------")
	local msgDetail = zone_pb.HuntFateAutoSellResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local gold = msgDetail.total_golds
	local indexList = msgDetail.idx_list
	local addGold = gold - g_Hero:getCoins()
	
	self:setSellByGold(addGold/#indexList)
	g_Hero:setCoins(gold)
	

	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_OneKeySell,indexList)
	
	g_playSoundEffect("Sound/Drop_Money.mp3")

end

--一键拾取
function FateData:requestHuntFateAutoPick()
	echoj("=============一键拾取==================")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_AUTO_PICK_REQUEST)
	-- g_MsgNetWorkWarning:showWarningText(true)
end


--一键拾取响应
function FateData:requestHuntFateAutoPickResponse(tbMsg)
	cclog("---------requestHuntFateAutoPickResponse----一键拾取响应---------")
	local msgDetail = zone_pb.HuntFateAutoPickResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	-- cclog(tostring(msgDetail))
	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local indexList = msgDetail.idx_list
	
	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_OneKeyHarvest,indexList)
	
end

--妖兽单个拾取
function FateData:requestHuntFatePick(idx)
	cclog("---妖兽单个拾取--")
	local msg = zone_pb.HuntFatePickRequest()
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_PICK_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText(true)
end
--单个拾取响应
function FateData:requestHuntFatePickResponse(tbMsg)
	cclog("---------requestHuntFatePickResponse-------------")
	cclog("---------单个拾取响应-------------")
	local msgDetail = zone_pb.HuntFatePickResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	-- cclog(tostring(msgDetail))
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local nIndex = msgDetail.idx

	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_OneHarvest,nIndex)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_HuntFate1") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function FateData:ctor()

	self.allTableFateList = {}
	self.npcStatus = {}
	self.FateShape_ = nil
	self.tbFateSprite = {}
	self.tbGlobCfg = {} --猎妖数值
	self.coverFate = nil
	for i = 1,5 do
		local data = g_DataMgr:getGlobalCfgCsv("hunt_fate_"..i.."_price")
		table.insert(self.tbGlobCfg,data)
	end
	
	--注册消息
	--猎命刷新响应
	local order = msgid_pb.MSGID_HUNT_FATE_REFRESH_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFateRefreshResponse)) 
	
	--单个猎妖请求响应
	local order = msgid_pb.MSGID_HUNT_FATE_HUNT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFateHuntResponse))		
	
	--单个拾取响应
	local order = msgid_pb.MSGID_HUNT_FATE_PICK_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFatePickResponse))		
	
	--单个出售响应
	local order = msgid_pb.MSGID_HUNT_FATE_SELL_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFateSellResponse))
	
	--一键出售响应
	local order = msgid_pb.MSGID_HUNT_FATE_AUTO_SELL_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFateAutoSellResponse))	
	
	--一键猎妖响应
	local order = msgid_pb.MSGID_HUNT_FATE_AUTO_HUNT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestHuntFateAutoHuntResponse))	
	
	--一键拾取响应
	local order = msgid_pb.MSGID_HUNT_FATE_AUTO_PICK_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self, self.requestHuntFateAutoPickResponse))	
	
	-- 狂暴猎命响应
	local order = msgid_pb.MSGID_CRIT_HUNT_FATE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self, self.requestCritHuntFateResponse))		
	--元宝八连抽猎命响应
	local order = msgid_pb.MSGID_HUNT_FATE_8_YUANBAO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self, self.requestHuntFate8YuanBaoResponse))	
end

function FateData:setSellByGold(gold)
	self.sellGold_ = gold
end	

function FateData:getSellByGold()
	return self.sellGold_ or 0
end
--[[ 
	没有妖兽拾取了 
	@param returm false 没有妖兽拾取了 
]]
function FateData:canHarvestFateData()
	local fateList = self:getAllTableFateList()
	for key,value in pairs(fateList) do
		if value.id ~= 0 then 
			local id = value.id
			local lv = value.lv
			local fate = self:getCardFateInfo(id,lv) 
			if fate.ColorType ~= 1 then 
				return true 
			end
		end
	end
	return false
end

--[[ 
	没有灰色妖兽出售了 
	@param false 没有可以出售的妖兽 （灰色） 
]]
function FateData:canSellFateData()
	local fateList = self:getAllTableFateList()
	for key,value in pairs(fateList) do
		local id = value.id 
		if id > 0 then 
			local lv = value.lv 
			local fate = self:getCardFateInfo(id,lv)
			if fate.ColorType == 1 then 
				return true
			end
		end
	end
	return false
end
--[[
	封印罗盘已满
	@param return false 罗盘满 
]]
function FateData:compassFateMax()
	local fateList = self:getAllTableFateList()
	for key,value in pairs(fateList) do
		if value.id == 0 then 
			return true
		end
	end
	return false
end


function FateData:getAllFateGlobalCfgCsv()
	return self.tbGlobCfg --猎妖数值
end

function FateData:getFateGlobalCfgCsv(key)
	return self.tbGlobCfg[key] --猎妖数值
end

---- 一些动画 --------------------------------------

function FateData:createFateSprite(rootWidget, cardFate)
	local FateShape = CCSprite:create(getIconImg(cardFate.Animation))
	FateShape:setPosition(ccp(640+cardFate.OffsetX, 395+cardFate.OffsetY))
	FateShape:setOpacity(0)
	FateShape:setScale(0.3)
	rootWidget:addNode(FateShape,91)
	
	local function repeatFateIconShape()
		local function actionFinish()
			FateShape:removeFromParentAndCleanup(true)
		end
		local arrAct = CCArray:create()
		local actionFadeTo = CCFadeTo:create(0.1, 0)
		local actionMoveTo = CCMoveTo:create(0.1, CCPoint(640, 560))
		local actionSpawn = CCSpawn:createWithTwoActions(actionFadeTo, actionMoveTo)
		arrAct:addObject(actionSpawn)
		arrAct:addObject(CCCallFuncN:create(actionFinish))
		local action = CCSequence:create(arrAct)
		FateShape:runAction(action)
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.1,255),CCScaleTo:create(0.1,0.8))
	local action_FateShape = sequenceAction({ spawn, CCCallFuncN:create(repeatFateIconShape) })
	FateShape:runAction(action_FateShape)	
	-- self.FateShape_:setCascadeOpacityEnabled(true)
end

--[[
	狂暴猎命 动画  
	描述  首先出现闪光动画一次 然后妖兽动画 由小变大 逐次出现 
	local param = {
		rootWidget = , image = , updateCover = , endlFunc = ,data = 
	}
]]
function FateData:folieFate(param)
	if not param then return end
	local rootWidget = param.rootWidget 
	if not rootWidget then return end
	
	local data = param.data
	if not data then return end 
	
	local image = param.image
	local updateCover = param.updateCover
	local endlFunc = param.endlFunc

	self.coverFate = creationCover(rootWidget,true)
	-- g_MsgNetWorkWarning:showWarningText(true)

	local arrAct = CCArray:create()
	for key = 1,#data do 
		local id = data[key].id
		local lv = data[key].lv
		local npcStatus = data[key].npcStatus
		local cardFate = self:getCardFateInfo(id, lv)
		
		arrAct:addObject(CCDelayTime:create(0.1))
		
		local function createSprite()
			self:createFateSprite(rootWidget, cardFate)
		end
		arrAct:addObject(CCCallFuncN:create(createSprite))
		local function upCover() 
			if updateCover then 
				updateCover(cardFate)
			end
			--再保存最新一次遇到的猎妖师
			g_FateData:setTableNpcStatus(npcStatus)
		end
		arrAct:addObject(CCCallFuncN:create(upCover))
		
		if cardFate.ColorType == 1 then 
			local function sell()
				local tbWorldPos = image:getWorldPosition()
				local param = {
					text = _T("获得")..self:getSellByGold().._T("铜钱"),
					layout = rootWidget,
					fontSize = 24,
					x = tbWorldPos.x,
					y = tbWorldPos.y + 160,
					-- sysFunc = sysFunc,
					pluralLayout = false,
				}
				g_ShowSysTipsWord(param)
				
			end
			arrAct:addObject(CCCallFuncN:create(sell))
		else
			local function move()
				local param = { widget = rootWidget,key = 0,cardFate = cardFate, func = function() 	end}
				self:moveToAnimation(param)
			end
			arrAct:addObject(CCCallFuncN:create(move))
		end
	end
	
	if endlFunc then 
		arrAct:addObject(CCCallFuncN:create(endlFunc))
	end
	local function closes()
		-- g_MsgNetWorkWarning:closeNetWorkWarning()
		self:removeCoverFate()
	end
	arrAct:addObject(CCCallFuncN:create(closes))
	rootWidget:runAction(CCSequence:create(arrAct))
	
end

function FateData:removeCoverFate()
	if self.coverFate then 
		self.coverFate:removeFromParentAndCleanup(false)
		self.coverFate = nil
	end
end

---------------------------------
local function npcStatusRegroup(npcIdx)
	local t = {0,0,0,0}
	if npcIdx == 1 then 
		return t
	end
	
	for i = 2, 5 do 
		if i == npcIdx then 
			t[i - 1] = 1
		else
			t[i - 1] = 0
		end
	end
	return t 
end

function FateData:requestCritHuntFate()
	cclog("=====================狂暴猎命请求=============")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CRIT_HUNT_FATE_REQUEST)
end


function FateData:requestCritHuntFateResponse(tbMsg)
	cclog("---------requestCritHuntFateResponse----狂暴猎命响应---------")
	local msgDetail = zone_pb.CritHuntFateRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog("狂暴"..tostring(msgDetail))
	
	local tbFate = {}
	local allData = msgDetail.all_data
	for idx = 1,#allData do
		local fateInfo = allData[idx].fate_info
		local npcIdx = allData[idx].npc_idx
		local tbNpcStats = npcStatusRegroup(npcIdx)
		local t = {}
		t.id = fateInfo.id
		t.lv = fateInfo.lv
		t.npcStatus = tbNpcStats
		if t.lv and t.id then 
			table.insert(tbFate,t)
		end
	end
	
	local npcStatus = msgDetail.npc_status -- npc状态  
	local updateGolds = msgDetail.update_golds -- 更新铜钱
	local getGolds = msgDetail.get_golds -- 获得总铜钱
	
	self:setSellByGold(g_DataMgr:getGlobalCfgCsv("hunt_fate_sell_fate"))
	g_Hero:setCoins(updateGolds)
		
	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_FolieHuntFate,tbFate)	
	
end

function FateData:requestHuntFate8YuanBao()
	cclog("==============八连抽猎命请求=============")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_HUNT_FATE_8_YUANBAO_REQUEST)
end

function FateData:requestHuntFate8YuanBaoResponse(tbMsg)
	cclog("---------requestHuntFate8YuanBaoResponse---八连抽猎命元宝响应----------")
	local msgDetail = zone_pb.HuntFate8YuanBaoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local tbHunt = {}
	local huntList = msgDetail.hunt_list
	
	if huntList == nil or huntList == {} then
		SendError("==msgDetail.hunt_list is nil or empty==")
	end
	
	for _, v in ipairs(huntList) do
		if v.fate_info then 
			local fateInfo = v.fate_info
			local id = fateInfo.id
			local nLevel = fateInfo.lv
			local nIndex = v.idx
			self:setAloneFateList(nIndex,id,nLevel)
			g_Hero:setCoins(v.total_golds)
		end
		local npcValue = {}
		for key = 1, #v.npc_status do 
			table.insert(npcValue,v.npc_status[key])
		end
		table.insert(tbHunt, npcValue)
	end
	
	g_FormMsgSystem:SendFormMsg(FormMsg_HuntFate_YuanBaoHuntFate, tbHunt)
	
	local nBaLianChouCost = g_DataMgr:getGlobalCfgCsv("hunt_fate_balianchou_gold_cost") 
	gTalkingData:onPurchase(TDPurchase_Type.TDP_HUNT_FATE_BALIANCHOU_GOLD_COST, 1, nBaLianChouCost)
end
---------------------------------------------------------------------------------
g_FateData = FateData.new()
