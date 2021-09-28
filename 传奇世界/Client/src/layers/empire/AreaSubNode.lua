local AreaSubNode = class("AreaSubNode", function() return cc.Node:create() end)

local path = "res/empire/area/"

function AreaSubNode:ctor(id, mapId, data)
	local msgids = {MANORWAR_SC_PICKREWARD_RET}
	require("src/MsgHandler").new(self,msgids)

	local record = data[id]
	self.record = record
	dump(self.record, "self.record")
	self.data = data
	self.id = id
	self.mapId = mapId
	local itemData = getBattleAreaInfo(mapId)
	self.manorID = itemData.manorID
	--dump(self.manorID, "self.manorID")
	--dump(record)

	local bg = createSprite(self, "res/common/bg/bg27.png")
	local bgSize = bg:getContentSize()
	createSprite(bg, "res/common/bg/bg27-1.png", cc.p(201, 280), cc.p(0.5, 0.5))
	createLabel(bg, getConfigItemByKey("AreaFlag", "mapID", mapId, "name"), cc.p(201,503), nil, 22, true)
	self.bg = bg
	local showBg = createSprite(bg, path..id..".jpg", cc.p(bg:getContentSize().width/2, 303), cc.p(0.5, 0))
	createSprite(bg, "res/common/bg/bg27-2.png", cc.p(bg:getContentSize().width/2, 287), cc.p(0.5, 0))

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-35, bg:getContentSize().height-25), closeFunc)
	registerOutsideCloseFunc(bg, closeFunc, true)

	--获得奖励
	local function getBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_PICKREWARD, "PickManorRewardProtocol", {manorID = self.id})
    	addNetLoading(MANORWAR_CS_PICKREWARD, MANORWAR_SC_PICKREWARD_RET)
	end
	local getBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(117, 50), getBtnFunc)
	self.getBtn = getBtn
	getBtn:setEnabled(self.data[self.id].rewardAvailable == true)
	createLabel(getBtn, game.getStrByKey("biqi_get"), getCenterPos(getBtn), cc.p(0.5, 0.5), 22, true)

	--进入战场
	local function goBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_ENTERMANORWAR, "EnterManorWarProtocol", {manorID = self.manorID or 2})
	    __removeAllLayers()
	end
	local goBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(290, 50), goBtnFunc)
	createLabel(goBtn, game.getStrByKey("biqi_enter"), getCenterPos(goBtn), cc.p(0.5, 0.5), 22, true)
	goBtn:setEnabled(record.isTime)

	--所属行会
	local lab = createLabel(bg, game.getStrByKey("empire_area_info_faction"), cc.p(30, 260), cc.p(0, 0), 20)
	lab:setColor(MColor.lable_yellow)
	createLabel(bg, record.factionName or game.getStrByKey("biqi_str9"), cc.p(lab:getContentSize().width + 30, 260), cc.p(0, 0), 20):setColor(MColor.yellow)

	lab = createLabel(bg, game.getStrByKey("empire_area_info_leader"), cc.p(30, 220), cc.p(0, 0), 20)
	lab:setColor(MColor.lable_yellow)
	createLabel(bg, record.factionKingName or game.getStrByKey("biqi_str9"), cc.p(lab:getContentSize().width + 30, 220), cc.p(0, 0), 20):setColor(MColor.yellow)
	
	--下次开启时间
	self.nextTimeLabel = createLabel(bg, "", cc.p(30, 320), cc.p(0, 0.5), 18)
	if record.isTime then
		self.nextTimeLabel:setString(game.getStrByKey("empire_biqi_time_active"))
		self.nextTimeLabel:setColor(MColor.green)
	elseif record.starttime == -1 then	
		local strTime = ""
		if itemData.openTime then
			strTime = getStrTimeByValue(itemData.openTime)
		end				
		self.nextTimeLabel:setString(strTime)
		self.nextTimeLabel:setColor(MColor.yellow)
		-- self.nextTimeLabel:setString(game.getStrByKey("join_activityLate"))
		-- self.nextTimeLabel:setColor(MColor.yellow)
	else
		local strDayTime = ""
		if record.starttime then
			strDayTime = os.date("%Y-%m-%d ", record.starttime * 24 * 3600 + record.currTime)
		end

		local strTime = ""
		if itemData.openTime then
			strTime = getStrTimeByValue(itemData.openTime, false)
		end

		self.nextTimeLabel:setString(strDayTime .. strTime)
		self.nextTimeLabel:setColor(MColor.yellow)
	end	

	lab = createLabel(bg, game.getStrByKey("empire_area_info_daily"), cc.p(30, 180), cc.p(0, 0), 20)
	lab:setColor(MColor.lable_yellow)
	if record.dailyReward then
		local x = 205
		local y = 160
		local addX = 90
		local itemIndex = 1
		local Mprop = require "src/layers/bag/prop"
		for k,v in pairs(record.dailyReward) do
			local icon = Mprop.new(
			{
				protoId = tonumber(k),
				num = tonumber(v.q_count),
				swallow = true,
				cb = "tips",
                showBind = true,
                isBind = tonumber(v.bdlx or 0) == 1,     				
			})
			icon:setScale(1)
			icon:setPosition(cc.p(x+(itemIndex-1)*addX, y))
			bg:addChild(icon)
			itemIndex = itemIndex + 1
		end
	end
end

function AreaSubNode:networkHander(buff,msgid)
	local switch = {
		[MANORWAR_SC_PICKREWARD_RET] = function()    
			local retTab = g_msgHandlerInst:convertBufferToTable("PickManorRewardRetProtocol", buff)
			local id = retTab.manorID
			if self.data[id] then
				self.data[id].rewardAvailable = false
			end

			if id == self.id then
				local func = function()
					if self.getBtn then
						self.getBtn:setEnabled(false)
					end
				end
				performWithDelay(self, func, 0.25)
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return AreaSubNode