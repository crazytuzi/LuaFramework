local RidingRightNode = class("RidingRightNode", function() return cc.Node:create() end)

function RidingRightNode:ctor(parent, otherRoleData)
	dump(G_RIDING_INFO)
	dump(otherRoleData)
	self.data = G_RIDING_INFO.id

	--当有该数据时表明是查看被人的资料
	self.isOtherRole = false
	if otherRoleData then
		self.data = otherRoleData.ridingInfo
		self.isOtherRole = true
	end
	self.showIndex = 1

	self:createNode(self.isOtherRole)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_RIDE)
			G_RIDE_RIGHT_NODE = self
		elseif event == "exit" then
			G_RIDE_RIGHT_NODE = nil
		end
	end)
end

function RidingRightNode:createNode()
	-- local msgids = {WOMAN_SC_GET_POTENCY_DATA_RET}
	-- require("src/MsgHandler").new(self,msgids)

	self:removeAllChildren()

	local bg = createSprite(self, "res/common/bg/bg63.jpg", cc.p(0, 0), cc.p(0, 0.5)) 
	self.bg = bg
	self.centerX = 253

	local switchFunc = function() 
	   	log("switchFunc")
	    if self.showIndex == 1 then
	    	if G_RIDING_INFO.state == true then
	    		--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ici", G_ROLE_MAIN.obj_id, 0, self.data[1])
	    		local t = {}
				t.opType = 0
				t.rideID = self.data[1]
				g_msgHandlerInst:sendNetDataByTableExEx(RIDE_CS_CHANG_STATE, "RideChangeStateProtocol", t)
	    	elseif G_RIDING_INFO.state == false then
	    		--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ici", G_ROLE_MAIN.obj_id, 1, self.data[1])
	    		local t = {}
				t.opType = 1
				t.rideID = self.data[1]
				g_msgHandlerInst:sendNetDataByTableExEx(RIDE_CS_CHANG_STATE, "RideChangeStateProtocol", t)
	    	end 
	    else
	    	--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ici", G_ROLE_MAIN.obj_id, 1, self.data[self.showIndex])
	    	local t = {}
			t.opType = 1
			t.rideID = self.data[self.showIndex]
			g_msgHandlerInst:sendNetDataByTableExEx(RIDE_CS_CHANG_STATE, "RideChangeStateProtocol", t)
	    end
	end
	local switchBtn = createMenuItem(bg,"res/component/button/50.png",cc.p(self.centerX,40),switchFunc)
	local switchLabel = createLabel(switchBtn, "", getCenterPos(switchBtn), cc.p(0.5, 0.5), 22, true)
	self.switchLabel = switchLabel
	G_TUTO_NODE:setTouchNode(switchBtn, TOUCH_RIDE_SWITCH)

	--self.name = createLabel(bg, self:getCfgData("q_name"), cc.p(self.centerX, 465), cc.p(0.5, 0.5), 24, true)
	local nameBg = createSprite(bg, "res/layers/role/24.png", cc.p(self.centerX-7, 440), cc.p(0.5, 0)) 
	self.name = createLabel(nameBg, self:getCfgData("q_name"), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)

	local preBtnFunc = function()
		self.showIndex = self.showIndex - 1
		if self.showIndex < 1 then
			self.showIndex = 1
		end

		self:updateUI()
	end
	local preBtn = createTouchItem(bg, "res/group/arrows/13-1.png", cc.p(self.centerX-150, 260), preBtnFunc)
	self.preBtn = preBtn
	preBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(self.centerX-150-5, 260)), cc.MoveTo:create(0.3, cc.p(self.centerX-150, 260)))))

	local nextBtnFunc = function()
		self.showIndex = self.showIndex + 1
		if self.showIndex > #self.data then
			self.showIndex = #self.data
		end

		self:updateUI()
	end
	local nextBtn = createTouchItem(bg, "res/group/arrows/13.png", cc.p(self.centerX+150, 260), nextBtnFunc)
	self.nextBtn = nextBtn
	nextBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(self.centerX+150+5, 260)), cc.MoveTo:create(0.3, cc.p(self.centerX+150, 260)))))

	createLabel(bg, game.getStrByKey("wr_ride_on_off_tip"), cc.p(20, 80), cc.p(0, 0), 20, true, nil, nil, MColor.white)

	--查看别的玩家资料时去掉不必要的按钮
	if self.isOtherRole then
		removeFromParent(switchBtn)
		self.switchLabel = nil
	end

	self:updateUI()
end

function RidingRightNode:refresh()
	self.data = G_RIDING_INFO.id
	self.showIndex = 1
	self:createNode()
end

function RidingRightNode:updateUI()
	if self.showNode then
		removeFromParent(self.showNode)
		self.showNode = nil
	end

	local showNode = require("src/layers/wingAndRiding/WingAndRidingShowNode").new(wingAndRidingType.WR_TYPE_RIDING, self:getCfgData("q_pictureID"), 0.8)
	showNode:setPosition(cc.p(260, 200))
	self.bg:addChild(showNode)
	self.showNode = showNode

	if self.name then
		self.name:setString(self:getCfgData("q_name"))
	end

	if self.showIndex == 1 then
		self.preBtn:setVisible(false)
	else
		self.preBtn:setVisible(true)
	end

	if self.showIndex == #self.data then
		self.nextBtn:setVisible(false)
	else
		self.nextBtn:setVisible(true)
	end

	if self.switchLabel then
		if self.showIndex == 1 then
			log("G_RIDING_INFO.state = "..tostring(G_RIDING_INFO.state))
			if G_RIDING_INFO.state == true then
				self.switchLabel:setString(game.getStrByKey("wr_riding_off"))
			else
				self.switchLabel:setString(game.getStrByKey("wr_riding_on"))
			end
		else
			self.switchLabel:setString(game.getStrByKey("wr_riding_on"))
		end
	end

	if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
		G_RIDE_LEFT_NODE:refresh(self.showIndex)
	end
end

function RidingRightNode:getCfgData(key)
	return getConfigItemByKey("RidingCfg", "q_ID", self.data[self.showIndex], key)
end

function RidingRightNode:networkHander(buff,msgid)
	local switch = {

	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RidingRightNode