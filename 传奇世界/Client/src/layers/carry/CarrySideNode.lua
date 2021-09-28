local CarrySideNode = class("CarrySideNode", function() return cc.Node:create() end)

local path = "res/carry"

function CarrySideNode:ctor()
	local msgids = {ENVOY_SC_GET_INFO_RET, ENVOY_SC_AGAIN_RET}
	require("src/MsgHandler").new(self,msgids)
	g_msgHandlerInst:sendNetDataByTableExEx(ENVOY_CS_GET_INFO, "EnvoyGetInfoReq", {})
	
	self.floor = nil
	self.timeLeft = 3600
	self.monsterLeft = nil
	self.reward = nil
	self.isFinish = false
	self.isShow = false
	self.remainTime = 30 * 60

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	self.NeedChangeVisibleNode = baseNode

	local posX = display.cx + 50
	posX = display.cx + 60 +(display.cx - 270 - 60)/2
	
	self.rankBg = createSprite(baseNode, "res/mainui/sideInfo/textBg.png", cc.p(posX, 50 - 10), cc.p(0.5, 0), 2)
	self.showBtn = createMenuItem(self.rankBg, "res/mainui/anotherbtns/show.png", cc.p(self.rankBg:getContentSize().width/2, self.rankBg:getContentSize().height + 5), function() self:changeRankMode() end)
	self.hideBtn = createMenuItem(self.rankBg, "res/mainui/anotherbtns/hide.png", cc.p(self.rankBg:getContentSize().width/2, self.rankBg:getContentSize().height + 5), function() self:changeRankMode() end)
	self.selfRankNode = cc.Node:create()
	self.rankBg:addChild(self.selfRankNode)

	self.otherRankBg = createSprite(baseNode, "res/mainui/sideInfo/textBg1.png", cc.p(posX, 115 - 10), cc.p(0.5, 0))
	self.otherRankNode = cc.Node:create()

	self.otherRankBg:addChild(self.otherRankNode)
	createLabel(self.otherRankBg, game.getStrByKey("carry_tip_reward"), cc.p(15, 120), cc.p(0, 1), 12):setColor(MColor.lable_yellow)
	self:changeRankMode()

	self:setBeginMode()
end

function CarrySideNode:changeRankMode()
	log("CarrySideNode:changeRankMode")
	self.rankBg:setVisible(false)
	self.otherRankBg:setVisible(false)
	self.hideBtn:setEnabled(false)
	self.hideBtn:setVisible(false)

	self.showBtn:setEnabled(false)
	self.showBtn:setVisible(false)

	-- self.isShow = not self.isShow
	-- self.otherRankBg:setVisible(self.isShow)
	-- self.hideBtn:setEnabled(self.isShow)
	-- self.hideBtn:setVisible(self.isShow)

	-- self.showBtn:setEnabled(not self.isShow)
	-- self.showBtn:setVisible(not self.isShow)
	-- if self.isShow then
	-- 	self:getReward()
	-- elseif self.rewardNode then
	-- 	self.rewardNode:removeAllChildren()
	-- 	self.reward = nil
	-- end
	log("CarrySideNode:changeRankMode end")
end

function CarrySideNode:getReward()
	log("CarrySideNode:getReward")
	if self.floor == nil then
		return
	end
	dump(self.reward)
	dump(self.floor)
	if self.reward == nil then
		local tab = require("src/config/CarryCfg.lua")
		for k,v in pairs(tab) do
			if v.q_floor == self.floor then
				local tabStr = "{"..v.q_dropId.."}"
				self.reward = unserialize(tabStr)
			end
		end
		dump(self.reward)
		self:createRewardList()
	end
	log("CarrySideNode:getReward end")
end

function CarrySideNode:setBeginMode()
	-- self.monsterTipLabel = createLabel(self.rankBg, game.getStrByKey("carry_tip_monster"), cc.p(15, 40), cc.p(0, 0.5), 12)
	-- self.mosterLeftLabel = createLabel(self.rankBg, "", cc.p(self.monsterTipLabel:getContentSize().width + 35, 40), cc.p(0, 0.5), 12)
	-- self.monsterEndTipLabel = createLabel(self.rankBg, game.getStrByKey("carry_tip_monster_end"), cc.p(15, 15), cc.p(0, 0.5), 12, false, nil, nil, MColor.red)

	local richText = require("src/RichText").new(self.rankBg , getCenterPos(self.rankBg) , cc.size(150, 30) , cc.p(0.5, 0.5) ,18 ,18 ,MColor.lable_yellow)
	richText:addText(game.getStrByKey("carry_tip_item"), lable_yellow, true )
	richText:format()

	local exitFunc = function()
		log("exitFunc")
		local function goExit()
			--g_msgHandlerInst:sendNetDataByFmtExEx(ENVOY_CS_OUT, "i", G_ROLE_MAIN.obj_id)
			g_msgHandlerInst:sendNetDataByTableExEx(ENVOY_CS_OUT, "EnvoyOutReq", {})
			addNetLoading(ENVOY_CS_OUT, ENVOY_SC_OUT_RET)
		end
		MessageBoxYesNo("", game.getStrByKey("carry_tip_exit_confirm"), goExit, nil)
	end

    local item = createMenuItem(self,"res/component/button/1.png", cc.p(g_scrSize.width-67, g_scrSize.height-98), exitFunc)
    item:setSmallToBigMode(false)
    createLabel(item, game.getStrByKey("exit"), getCenterPos(item), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow) 
    self.exitBtn = item
end

function CarrySideNode:setFinishMode(isFinish)
	log("CarrySideNode:setFinishMode")
	-- if self.mosterLeftLabel then
	-- 	removeFromParent(self.mosterLeftLabel)
	-- 	self.mosterLeftLabel = nil
	-- end

	-- if self.monsterTipLabel then
	-- 	removeFromParent(self.monsterTipLabel)
	-- 	self.monsterTipLabel = nil
	-- end

	-- if self.monsterEndTipLabel then
	-- 	removeFromParent(self.monsterEndTipLabel)
	-- 	self.monsterEndTipLabel = nil
	-- end

	local nextFunc = function()
		log("nextFunc")
		--g_msgHandlerInst:sendNetDataByFmtExEx(ENVOY_CS_ENTER_NEXT, "i", G_ROLE_MAIN.obj_id)
		addNetLoading(ENVOY_CS_ENTER_NEXT, ENVOY_CS_ENTER_NEXT_RET)
	end

	local outFunc = function()
		log("outFunc")
		--g_msgHandlerInst:sendNetDataByFmtExEx(ENVOY_CS_OUT, "i", G_ROLE_MAIN.obj_id)
		addNetLoading(ENVOY_CS_OUT, ENVOY_SC_OUT_RET)
	end

	local nextBtnFunc = nextFunc
	local nextBtnText = game.getStrByKey("carry_tip_next_floor")
	if isFinish then
		nextBtnFunc = outFunc
		nextBtnText = game.getStrByKey("carry_tip_exit")
	end

	if self.nextBtn == nil and isFinish ~= true then	
		self.nextBtn = createMenuItem(self.rankBg, "res/component/button/39.png", cc.p(self.rankBg:getContentSize().width/2, 28), nextBtnFunc)
		createLabel(self.nextBtn, nextBtnText, getCenterPos(self.nextBtn), cc.p(0.5, 0.5), 22, true):setColor(MColor.lable_yellow)
		self.nextBtn:setScale(0.8)
	end
	log("CarrySideNode:setFinishMode end")
end

function CarrySideNode:reloadData()
	log("CarrySideNode:reloadData")
	-- if self.monsterLeft then
	-- 	if self.mosterLeftLabel then
	-- 		self.mosterLeftLabel:setString(self.monsterLeft)
	-- 	end
	-- end

	-- if self.monsterType and self.monsterType==1 then
	-- 	if self.monsterTipLabel then
	-- 		self.monsterTipLabel:setString(game.getStrByKey("carry_tip_boss"))
	-- 	end
	-- end

	-- if self.isFinish then
	-- 	if self.monsterEndTipLabel then
	-- 		self.monsterEndTipLabel:setString(game.getStrByKey("carry_tip_end"))
	-- 	end
	-- end
	if self.isShow then
		self:getReward()
	end
	log("CarrySideNode:reloadData end")
end

function CarrySideNode:createRewardList()
	log("createRewardList")
	if self.rewardNode == nil then
		self.rewardNode = cc.Node:create()
		self.otherRankBg:addChild(self.rewardNode)
		self.rewardNode:setPosition(cc.p(5, 60))
	end

	self.rewardNode:removeAllChildren()

	local startX = self.rewardNode:getPositionX()
	local startY = self.rewardNode:getPositionY()
	if self.reward then
		local paddingX = 45
		local paddingY = -40
		local lineNumber = 4
		for i,v in ipairs(self.reward) do
			local posX = ((i - 1) % lineNumber) * paddingX + 5
			local posY = (math.ceil(i / lineNumber) - 1) * paddingY

			local Mprop = require("src/layers/bag/prop")
			local iconNode = Mprop.new({cb = "tips", protoId = v})
			iconNode:setAnchorPoint(cc.p(0, 0.5))
	        iconNode:setScale(0.5)
	        self.rewardNode:addChild(iconNode)
	        iconNode:setPosition(cc.p(posX, posY))
		end
	end
	log("createRewardList end")
end

function CarrySideNode:addInfo()
    --剩余时间
    if not self.timeBg then
	    self.timeBg = createSprite(self, "res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
	    local timeBgSize = self.timeBg:getContentSize()
	    createLabel(self.timeBg, game.getStrByKey("carry_tip_time_title"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), cc.p(0.5, 0.5), 18, true):setColor(MColor.lable_yellow)
	    self.remainTimeText = createLabel(self.timeBg, self:getTimeStr(self.remainTime), cc.p(timeBgSize.width/2, timeBgSize.height/2-8), cc.p(0.5, 0.5), 22, true)
	    self.remainTimeText:setColor(MColor.green)
	end
end

function CarrySideNode:UpdateInfo()
    if self.TimeAction then
        self.TimeAction:stopAllActions()
        self.TimeAction = nil
    end

    if self.remainTime == nil then
    	self:resetTime()
    end

    if not self.TimeAction and self.remainTime > 0 then
        self.TimeAction = startTimerActionEx(self, 1, true, function(delTime)
            self.remainTime = self.remainTime - delTime
            if self.remainTime >= 0 then
                self.remainTimeText:setString(self:getTimeStr(self.remainTime))
                if self.remainTime <= 299 and not G_NO_OPEN_PAY and not self.isExperience then
                	if self.MessageBg == nil then
                    	self.MessageBg = self:messageBoxYesNo(nil, game.getStrByKey("carry_tip_no_time"), function() 
                    			--g_msgHandlerInst:sendNetDataByFmtExEx(ENVOY_CS_AGAIN, "i", G_ROLE_MAIN.obj_id) 
								g_msgHandlerInst:sendNetDataByTableExEx(ENVOY_CS_AGAIN, "EnvoyAgainReq", {})
                    		end)
                    end
                end
            end
            if self.remainTime <= 0 then
                self.TimeAction:stopAllActions()
                self.TimeAction = nil
                -- self:exit()
            end
        end)
    end
end

function CarrySideNode:resetTime()
	self.remainTime = 30 * 60
end

function CarrySideNode:getTimeStr(time)
    return string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
end

function CarrySideNode:networkHander(buff,msgid)
	local switch = {
		-- [ENVOY_SC_MONSTER_UPDATE] = function()
		-- 	log("get ENVOY_SC_MONSTER_UPDATE")
		-- 	local floor = buff:popChar()
		-- 	local monsterType = buff:popChar()
		-- 	local monsterNum = buff:popInt()
		-- 	log("floor = "..floor)
		-- 	log("monsterType = "..monsterType)
		-- 	log("monsterNum = "..monsterNum)

		-- 	self.floor = floor
		-- 	self.monsterType = monsterType
		-- 	self.monsterLeft = monsterNum

		-- 	if self.floor > 3 and self.monsterLeft <= 0 then
		-- 		self.floor = 3
		-- 		self.monsterLeft = 0
		-- 		self.isFinish = true
		-- 	end

		-- 	self:reloadData()
		-- end
		-- ,

		-- [ENVOY_SC_CAN_NEXT] = function()
		-- 	log("get ENVOY_SC_CAN_NEXT")
		-- 	local floor = buff:popChar()
		-- 	log("floor = "..floor)
		-- 	if floor ~= -1 then
		-- 		self.monsterLeft = 0
		-- 		self:setFinishMode()
		-- 		self.floor = floor - 1
		-- 	else
		-- 		self.monsterLeft = 0
		-- 		self.isFinish = true
		-- 		self.floor = 3
		-- 		--self:setFinishMode(true)
		-- 		--self.floor = floor - 1
		-- 	end

		-- 	self:reloadData()
		-- end
		-- ,
		
		[ENVOY_SC_AGAIN_RET] = function()
			log("get ENVOY_SC_AGAIN_RET")
			local t = g_msgHandlerInst:convertBufferToTable("EnvoyAgainRet", buff)
			self.remainTime = t.endTime
			dump(self.remainTime)
			--self:resetTime()
			if self.MessageBg then
				removeFromParent(self.MessageBg)
				self.MessageBg = nil
			end
		end
		,
		[ENVOY_SC_GET_INFO_RET] = function()
			local t = g_msgHandlerInst:convertBufferToTable("EnvoyGetInfoRet", buff)
			self.floor = t.floor
			self.remainTime = t.endTime
			self.isExperience = t.isExperience
			--dump(self.remainTime)
			self:addInfo()
			self:UpdateInfo()			
			self:reloadData()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function CarrySideNode:messageBoxYesNo(title, text, yesCallback, noCallback, yesText, noText)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite, title or game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, MColor.white)
	contentRichText:addText(text, MColor.white)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local funcYes = function()
		local removeFunc = function()
		    if retSprite then
		        --removeFromParent(retSprite)
		        retSprite = nil
		    end
		end
		if yesCallback then
			yesCallback()
		end
	end

	local funcNo = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		local removeFunc = function()
		    if retSprite then
		        removeFromParent(retSprite)
		        retSprite = nil
		    end
		end
		if noCallback then
			noCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.CallFunc:create(removeFunc)))	
		end
	end
	local btn_img,spanx = "res/component/button/50.png",0
	if noCallback == false then
		btn_img = "res/component/button/51.png"
		spanx = 30
	end
	local menuItem = createMenuItem(retSprite,btn_img,cc.p(315+spanx,45),funcYes)
	createLabel(menuItem,yesText or  game.getStrByKey("sure") ,getCenterPos(menuItem),nil,21,true)

	if G_TUTO_NODE then G_TUTO_NODE:setTouchNode(menuItem, TOUCH_CONFIRM_YES) end

	local menuItem = createMenuItem(retSprite,btn_img,cc.p(100-spanx,45),funcNo,nil,nil,true)
	createLabel(menuItem,noText or  game.getStrByKey("cancel"),getCenterPos(menuItem),nil,21,true)
	getRunScene():addChild(retSprite,200)
	retSprite:setPosition(cc.p(display.cx, display.cy))

	SwallowTouches(retSprite)

	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
    return retSprite
end

return CarrySideNode