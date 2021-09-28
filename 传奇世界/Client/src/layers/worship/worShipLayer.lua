local worShipLayer = class("worShipLayer", require("src/TabViewLayer"))
local path = "res/layers/worShip/"
worShipLayer.noConfirm = false
local totalRemainTime = 1 --元宝膜拜的总次数.没有配置.前台暂时写死
local costConfig = {100, 100, 100}

local function StrSplit(str, split)
	local strTab={}
	local sp=split or "&"
	local tb = {}
	while type(str)=="string" and string.len(str)>0 do
		local f=string.find(str,sp)
		local ele
		if f then
			ele=string.sub(str,1,f-1)
			str=string.sub(str,f+1)
		else
			ele=str
		end
		table.insert(tb, ele)
		if not f then break	end
	end
	return tb
end

function worShipLayer:ctor(where)
	self.data = {nextTime = 0}
	self.data.king = {}
	self.Where = where or 1
	self.data.FreeTime = 0
	self.data.remainTime = 0
	self.data.factionData = false
	self.DbData = getConfigItemByKey("AdoreConfig", "q_Lv")

	local bigBg = createBgSprite(self, game.getStrByKey("worShip_BgTitle"))
	--local bg = createSprite(bigBg , "res/common/bg/bg-6.png" , cc.p( 15, 25) , cc.p( 0 , 0 ))
    local bg = cc.Node:create()
    bg:setPosition(cc.p(15, 25))
    bg:setContentSize(cc.size(930, 535))
    bg:setAnchorPoint(cc.p(0, 0))
    bigBg:addChild(bg)
	self.bg = bg
	local bgSize = bg:getContentSize()

	local minBg = createSprite(bg, path .. "midBg.jpg", getCenterPos(bg))
	self.minBg = minBg
	self.rightBg = createSprite(minBg, "res/common/bg/infoBg11.png", cc.p(616, 5), cc.p(0, 0))

	self.Btn1 = createMenuItem(bg, "res/component/button/49.png", cc.p(234, 82), function() self:confirmCostBox(0) end, 2, true)
	self.Btn1:setLocalZOrder(2)
	createLabel(self.Btn1, game.getStrByKey("worShip_Text"), getCenterPos(self.Btn1), cc.p(0.5, 0.5), 20, true):setColor(MColor.yellow)

	self.Btn2 = createMenuItem(bg, "res/component/button/49.png", cc.p(434, 82), function() self:confirmCostBox(1) end, 2, true)
	self.Btn2:setLocalZOrder(2)
	local lab = createLabel(self.Btn2, game.getStrByKey("ingot") .. game.getStrByKey("worShip_Text"), getCenterPos(self.Btn2),cc.p(0.5, 0.5), 20, true)
	lab:setColor(MColor.yellow)
	self.Btn1:setEnabled(false)
	self.Btn2:setEnabled(false)

	if G_NO_OPEN_PAY then
		self.Btn2:setVisible(false)
		self.Btn1:setPosition(cc.p(334, 82))
	end

	local MRoleStruct = require("src/layers/role/RoleStruct")
	local qiqi = MRoleStruct:getAttr(PLAYER_VITAL)
	self.curqiqi = createLabel(bg, game.getStrByKey("worShip_text1") .. ":" .. qiqi , cc.p(334, 43), cc.p(0.5, 0.5), 20)
	self.curqiqi:setColor(MColor.lable_black)

	--self.LeftLab = createLabel(bg, game.getStrByKey("times_left") .. " 1", cc.p(434, 43), nil, 20, true):setColor(MColor.lable_black)

	if MRoleStruct:getAttr(ROLE_LEVEL) < 25 then
		self.Btn1:setVisible(false)
		self.Btn2:setVisible(false)
		createLabel(self.bg, game.getStrByKey("worShip_needLevel"), cc.p(334 , 82), cc.p(0.5, 0.5), 20, true):setColor(MColor.red)
	end

	local role_pos  = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
	local targetPos = cc.p(97, 81)
	local npcCfg = getConfigItemByKey("NPC", "q_id"  )[10468]
	targetPos = npcCfg and cc.p(npcCfg.q_x or 97, npcCfg.q_y or 81) or targetPos
	local mapId = 3100
	local offSetX,offSetY = 3 , 3

	if MRoleStruct:getAttr(ROLE_LEVEL) >= 25 and (G_MAINSCENE.map_layer.mapID ~= mapId or (G_MAINSCENE.map_layer.mapID == mapId and (math.abs(role_pos.x - targetPos.x) > offSetX or math.abs(role_pos.y - targetPos.y) > offSetY))) then
		self.Btn1:setVisible(false)
		self.Btn2:setVisible(false)
		local btn3 = createTouchItem(bg, "res/component/button/49.png", cc.p(334, 82), function() 
			local posX = role_pos.x
			if math.abs(role_pos.x - targetPos.x) > offSetX then
				posX = (targetPos.x > role_pos.x) and targetPos.x - offSetX + 1 or targetPos.x + offSetX - 1
			end
			local posY = role_pos.y
			if math.abs(role_pos.y - targetPos.y) > offSetY then
				posY = (targetPos.y > role_pos.y) and targetPos.y - offSetY + 1 or targetPos.y + offSetY - 1
			end				
			if G_MAINSCENE.map_layer.mapID ~= mapId then
				posX = targetPos.x - 2
				posY = targetPos.y + 2
			end
			local function handlerFun()
				__GotoTarget({ ru = "a88", where = where})
			end

			local tempData = { targetType = 4 ,  mapID = mapId ,  x = posX , y = posY , callFun = handlerFun  }
	        __TASK:findPath( tempData )

			__removeAllLayers()	  		
			end)
		createLabel(btn3, game.getStrByKey("go"), getCenterPos(btn3), cc.p(0.5, 0.5), 20, true):setColor(MColor.yellow)
	end

	-- 货币
	-- local Mcurrency = require "src/functional/currency"
	-- local Mnode = require "src/young/node"
	-- Mnode.addChild(
	-- {
	-- 	parent = bigBg,
	-- 	child = Mcurrency.new(
	-- 	{
	-- 		cate = PLAYER_INGOT,
	-- 		--bg = "res/common/19.png",
	-- 		color = MColor.lable_yellow,
	-- 	}),
		
	-- 	anchor = cc.p(0, 0.5),
	-- 	pos = cc.p(35, 600),
	-- })	

	self:initLeftView()
	g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GETSHAINFO, "GetShaInfoProtocol", {})
	addNetLoading(SHAWAR_CS_GETSHAINFO, SHAWAR_SC_GETSHAINFO_RET)

	g_msgHandlerInst:sendNetDataByTableExEx(ADORE_CS_GETDATA, "AdoreGetDataProtocol", {} )
	addNetLoading(ADORE_CS_GETDATA, ADORE_SC_GETDATA_RET)

	local msgids = {SHAWAR_SC_GETSHAINFO_RET, ADORE_SC_ADOREKING_RET, ADORE_SC_GETDATA_RET}
	require("src/MsgHandler").new(self,msgids)
end

function worShipLayer:sendWorshipMsg( worShipType )
	self.isSendNormal = worShipType
	g_msgHandlerInst:sendNetDataByTableExEx(ADORE_CS_ADOREKING, "AdoreKingProtocol", {useIngot = worShipType}) --self.data.king.name
	addNetLoading(ADORE_CS_ADOREKING, ADORE_SC_ADOREKING_RET)	
end

function worShipLayer:confirmCostBox(worShipType)
	if worShipLayer.noConfirm or worShipType == 0 then
		self:sendWorshipMsg(worShipType)
		return
	end
	local index = totalRemainTime - self.data.remainTime + 1
	local cost = costConfig[index]

	local lev = MRoleStruct:getAttr(ROLE_LEVEL)
	local cfg = self.DbData[lev]
	if cfg and cfg.q_reward then
		local timeAward = unserialize(cfg.q_reward)
		timeAward = timeAward[self.data.remainTime]
		cost = timeAward.ingot
	end

	if MRoleStruct:getAttr(PLAYER_INGOT) < cost then
		MessageBoxYesNo(nil, "本次膜拜需要消耗100元宝，当前元宝余额不足，是否前往充值？", function() __GotoTarget( { ru = "a33" } ) end)
		return
	end
	
	local str = string.format(game.getStrByKey("worShip_CostConfirm"), cost)
	local boxBg = MessageBoxYesNo(nil, str, function() self:sendWorshipMsg(worShipType) end)
	-- local Mcheckbox = require "src/component/checkbox/view"
	-- local checkbox = Mcheckbox.new(
	-- {
	-- 	label = {
	-- 		src = game.getStrByKey("download_text9"),
	-- 		size = 20,
	-- 		color = MColor.green,
	-- 	},
	-- 	margin = 0,
	-- 	value = false,
	-- 	cb = function(value, root)
	-- 		worShipLayer.noConfirm = value
	-- 	end,
	-- })
	-- boxBg:addChild(checkbox, 100)
	-- checkbox:setPosition(cc.p(boxBg:getContentSize().width/2, 110))
	-- checkbox:setAnchorPoint(cc.p(0.5,0.5))
end

function worShipLayer:initLeftView()
	local LeftNode = cc.Node:create()
	self.rightBg:addChild(LeftNode)

	local posX , posY = 25, 437
	local centerX = getCenterPos(self.rightBg).x
	local bg = createSprite(LeftNode, "res/common/bg/infoBg11-2.png", cc.p(centerX, 465), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("rule_description"), getCenterPos(bg), nil, 20, true):setColor(MColor.lable_yellow)

	local str = game.getStrByKey("worShip_Rule1")
	if G_NO_OPEN_PAY then
		str = game.getStrByKey("worShip_Rule2")
	end
	local richText = require("src/RichText").new(LeftNode, cc.p(centerX, 360), cc.size(235, 60), cc.p(0.5, 0.5), 32, 20, MColor.lable_black)
	richText:setAutoWidth()
	richText:addText(str)
	richText:format()	    

	local bg = createSprite(LeftNode, "res/common/bg/infoBg11-2.png", cc.p(centerX, 215), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("worShip_Award"), getCenterPos(bg), nil, 20, true):setColor(MColor.lable_yellow) 
	self.awardLab = {}
	createLabel(LeftNode, game.getStrByKey("worShip_award1"), cc.p(posX, 170), cc.p(0, 0.5), 20):setColor(MColor.lable_black)
	self.awardLab[1] = createLabel(LeftNode, "", cc.p(posX , 135), cc.p(0, 0.5), 20)
	local glod = createLabel(LeftNode, game.getStrByKey("worShip_award2"), cc.p(posX, 100), cc.p(0, 0.5), 20):setColor(MColor.lable_black)
	self.awardLab[2] = createLabel(LeftNode, "", cc.p(posX , 65), cc.p(0, 0.5), 20)

	self.awardLab[1]:setColor(MColor.white)
	self.awardLab[2]:setColor(MColor.yellow)

	if G_NO_OPEN_PAY then
		glod:setVisible(false)
		self.awardLab[2]:setVisible(false)		
	end
end

function worShipLayer:UpdateMidInfo()
	local centerX = 334
	local MidNode = cc.Node:create()
	self.bg:addChild(MidNode)
	MidNode:setPosition(cc.p(0, 0))
	
	if self.data.factionData then
		local func = function(Data, node)
			LookupInfo(Data.name, 1, 0)
		end
		local roleNode = createRoleNode(self.data.king.school, self.data.king.clothes, self.data.king.weaponId, self.data.king.wing, 0.9, self.data.king.sex ,function() func(self.data.king, self) end)
		MidNode:addChild(roleNode, -1, 100)
		roleNode:setPosition(cc.p(centerX, 240))
	else
		local roleNode = createRoleNode(1, 5110505, 5110106, 4075, 0.9, 1) --衣服
		MidNode:addChild(roleNode, -1, 100)
		roleNode:setPosition(cc.p(centerX, 240))		
	end

	local strTitle = ""
	local strDay = ""
	local itemData = getConfigItemByKey("AreaFlag", "mapID", 6005)
	if self.data.isActive then
		strTitle = "沙城争霸战" .. game.getStrByKey("empire_biqi_time_active")
	else
		if self.data.nextTime then
			strDay = os.date("%m-%d ", tonumber(self.data.nextTime * 24 * 3600) + self.data.currTime)
		end	
		strTitle = "下次沙城争霸战开启时间:"
	end

	local strTime = ""
	if itemData and itemData.openTime then
		strTime = getStrTimeByValue(itemData.openTime, (not self.data.isActive and self.data.nextTime == -1))
	end

	local showStr = ""
	if self.data.isActive then
		showStr = "^c(green)" .. strTitle .. strTime .."^"
	else
		showStr = strTitle .. "^c(white) " .. strDay .. strTime .."^"	
	end

	local richText = require("src/RichText").new(MidNode, cc.p(centerX, 495), cc.size(600, 60), cc.p(0.5, 0.5), 32, 20, MColor.lable_black)
	richText:setAutoWidth()
	richText:addText(showStr)
	richText:format()	    

	--名字
	local nameBg = createSprite(MidNode, "res/layers/role/24.png", cc.p(centerX, 450), cc.p(0.5, 0.5)) 
	if self.data.factionData then
		createLabel(nameBg, game.getStrByKey("worShip_Title3") .. "【" .. self.data.king.name .. "】", getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 22, true):setColor(MColor.lable_yellow)
	else
		createLabel(nameBg, game.getStrByKey("worShip_Title3") .."【" .. game.getStrByKey("biqi_str16") .. "】", getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 22, true):setColor(MColor.lable_yellow)
	end
end

function worShipLayer:updateBtn()
	local func = function()
		if self.data.FreeTime <= 0 then
			self.Btn1:setEnabled(false)
		else
			self.Btn1:setEnabled(true)
		end
		
		if self.data.remainTime <= 0 then
			self.Btn2:setEnabled(false)
		else
			self.Btn2:setEnabled(true)
		end
	end
	performWithDelay(self, func, 0)

	-- if self.LeftLab then
	-- 	local num = self.data.remainTime
	-- 	self.LeftLab:setString(game.getStrByKey("times_left") .. self.data.remainTime)
	-- end

	local timeLeft = self.data.remainTime < 1 and 1 or self.data.remainTime	
	local lev = MRoleStruct:getAttr(ROLE_LEVEL)
	local cfg = self.DbData[lev]
	if cfg and self.awardLab then
		local timeAward = unserialize(cfg.q_reward)
		timeAward = timeAward[timeLeft]
		local strCfg = {string.format(game.getStrByKey("worShip_award3"), numToFatString(cfg.q_rewards_exp or 0),cfg.q_rewards_sw),
						string.format(game.getStrByKey("worShip_award4"), numToFatString(timeAward.exp or 0), timeAward.vital),						
						}
		for i=1,#self.awardLab do
			self.awardLab[i]:setString(strCfg[i])
		end
	end
end

function worShipLayer:updateqiqiNum()
	if self.qiqitime then
		self:stopAction(self.qiqitime)
		self.qiqitime = nil
	end
	self.qiqitime = startTimerAction(self, 0.3, true, function ()
		if self.curqiqi then
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local qiqi = MRoleStruct:getAttr(PLAYER_VITAL)
			if self.curqiqi then
				self.curqiqi:setString(game.getStrByKey("worShip_text1") .. ":" .. qiqi)
			end
		end
	end)
end

function worShipLayer:networkHander(buff,msgid)
	print("worShipLayer networkHander")
	local switch = {
	[SHAWAR_SC_GETSHAINFO_RET] = function()
		print("get SHAWAR_SC_GETSHAINFO_RET")
		local retTab = g_msgHandlerInst:convertBufferToTable("GetShaInfoRetProtocol", buff)

		self.data.isActive = retTab.isOpen	
		if not self.data.isOpen then
			self.data.nextTime = retTab.remainDayNum
		end
		self.data.currTime = retTab.curTiem
		self.data.factionData = retTab.beOccupy

		self.data.king = {}
		if self.data.factionData then
			self.data.king.sex = retTab.leaderSex
			self.data.king.school = retTab.Leadersch
			self.data.king.name  = retTab.leadername
			self.data.king.weaponId = retTab.weapon
			self.data.king.clothes  = retTab.upperbody
			self.data.king.wing   = retTab.wingID
		end

		dump(self.data, "self.data")
		self:UpdateMidInfo()
	end,
	[ADORE_SC_ADOREKING_RET] = function()  --膜拜成功
		g_msgHandlerInst:sendNetDataByTableExEx(ADORE_CS_GETDATA, "AdoreGetDataProtocol", {})
		addNetLoading(ADORE_CS_GETDATA, ADORE_SC_GETDATA_RET)
		self:updateBtn()
		self:updateqiqiNum()
	end,
	[ADORE_SC_GETDATA_RET] = function()          --获取膜拜数据
		local retTable = g_msgHandlerInst:convertBufferToTable("AdoreGetDataRetProtocol", buff)
		self.data.FreeTime   = retTable.remainTimes                --玩家剩余免费膜拜次数
		self.data.remainTime = retTable.remainIngotTimes           --玩家剩余元宝膜拜次数
		print("ADORE_SC_GETDATA_RET,FreeTime=" .. self.data.FreeTime .. ",remainTime=" .. self.data.remainTime)

		self:updateBtn()
	end,
	}
	
	if switch[msgid] then
		switch[msgid]()
	end

end

return worShipLayer

