local WingAndRidingRightNode = class("WingAndRidingRightNode", function() return cc.Node:create() end)

function WingAndRidingRightNode:ctor(parent, type, isSuccess, otherRoleData, param)
	self.type = type
	self.parent = parent

	--当有该数据时表明是查看被人的资料
	self.isOtherRole = false
	if otherRoleData then
		self.otherRoleData = otherRoleData
		self.isOtherRole = true
	end

	self:createNode(isSuccess, self.isOtherRole)
end

function WingAndRidingRightNode:createNode(isSuccess, isOtherRole)
	local addSprite = createSprite
	local addLabel = createLabel
	
	local pathCommon = "res/wingAndRiding/common/"
	local pathWing = "res/wingAndRiding/wing/"
	local pathRiding = "res/wingAndRiding/riding/"
	local path
	--dump(G_WING_INFO)
	self.getString = game.getStrByKey
	self.base_node = cc.Node:create()
	self.update_node = cc.Node:create()
	self:addChild(self.base_node, 3)
	self.load_data = {}
	self.state = self:getData("state")
	
	if self.type == wingAndRidingType.WR_TYPE_WING then
		path = pathWing
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		path = pathRiding
	end 

	local msgids = {WOMAN_SC_GET_POTENCY_DATA_RET}
	require("src/MsgHandler").new(self,msgids)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			if self.type == wingAndRidingType.WR_TYPE_WING then
				G_TUTO_NODE:setShowNode(self, SHOW_WING)
			elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
				G_TUTO_NODE:setShowNode(self, SHOW_RIDE)
			end 
		elseif event == "exit" then
			if isOtherRole then return end
			if self.type == wingAndRidingType.WR_TYPE_WING then
				--if self.state ~= self:getData("state") then
					if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
						--g_msgHandlerInst:sendNetDataByFmtExEx(WING_CS_CHANG_STATE, "ic", G_ROLE_MAIN.obj_id, self.state)
						local t = {}
						t.opType = self.state
						g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_CHANG_STATE, "WingChangeStateProtocol", t)
					end
				--end
			elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
				--if self.state ~= self:getData("state") then
					if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
						--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ic", G_ROLE_MAIN.obj_id, self.state)
						local t = {}
						t.opType = self.state
						g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_CHANG_STATE, "WingChangeStateProtocol", t)
					end
				--end
			end 
		end
	end)


	local switchFunc = function() 
	   	log("switchFunc")
	   	self.state = (self.state + 1) % 2
	   	self:setData("state", self.state)
	   	self:onStateLableSwitch()
	end

	local explainFun = function()
		log("explainFun")
		local layer = require("src/layers/wingAndRiding/explainLayer").new(self.type)
		Director:getRunningScene():addChild(layer, 9999)
		layer:setPosition(0, 0)
	end
	local detailFun = function()
		log("detailFun")
		-- if self.skillNode ~= nil then
		-- 	self:removeChild(self.skillNode)
		-- 	self.skillNode = nil
		-- end
		local parent = self.parent
		local detailNode = require("src/layers/wingAndRiding/WingAndRidingLeftNode").new(parent, self.type, false, self.otherRoleData)
		parent.switchLeftView(parent, detailNode, 30)

		self.detailBtn:setPosition(cc.p(display.width*2,45))
		self.skillBtn:setPosition(cc.p(self.bg:getContentSize().width/2+150,45))
	end
	-- local skillFun = function()
	-- 	log("skillFun")
	-- 	-- if self.skillNode == nil then
	-- 	-- 	self.skillNode = require("layers/wingAndRiding/WingAndRidingSkillNode").new(self.type)
	-- 	-- 	self:addChild(self.skillNode)
	-- 	-- 	self.skillNode:setPosition(cc.p(-420, 0))
	-- 	-- end
	-- 	local parent = self.parent
	-- 	local skillNode = require("src/layers/wingAndRiding/WingAndRidingSkillNode").new(parent, self.type, self.otherRoleData)
	-- 	parent.switchLeftView(parent, skillNode, 30)

	-- 	self.detailBtn:setPosition(cc.p(self.bg:getContentSize().width/2+150,45))
	-- 	self.skillBtn:setPosition(cc.p(display.width*2,45))
	-- end
	local advanceFun = function()
		log("advanceFun")
		if self:getCfgData("q_nextID") ~= 0 then
			-- -- local advanceNode = require("src/layers/wingAndRiding/WingAndRidingAdvanceNode").new(self.type, self.onAdvanceSuccess)
			-- -- self:addChild(advanceNode)
			-- -- advanceNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)

			-- local parent = self.parent
			-- local advanceLeftNode = require("src/layers/wingAndRiding/WingAndRidingAdvanceLeftNode").new(parent, self.type)
			-- parent.switchRightView(parent, advanceLeftNode, 30)

			-- local advanceNode = require("src/layers/wingAndRiding/WingAndRidingAdvanceNode").new(parent, self.type, self.onAdvanceSuccess)
			-- parent.switchLeftView(parent, advanceNode)

			-- local advanceNode = require("src/layers/wingAndRiding/WingAndRidingAdvanceNode").new()
			-- self.base_node:addChild(advanceNode)
			-- --advanceNode:setPosition(self:convertToNodeSpace(cc.p(display.cx, display.cy)))
			-- advanceNode:setPosition(cc.p(200, 200))
            __GotoTarget( {ru = "a214", params = self.parent} )
		else
			local str
			if self.type == wingAndRidingType.WR_TYPE_WING then
				str = self.getString("wr_wing_advance_bestTip")
			elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
				str = self.getString("wr_riding_advance_bestTip")
			end 
			MessageBox(str, game.getStrByKey("sure"), nil)
		end
	end

	local bg = addSprite(self, "res/common/bg/bg63.jpg", cc.p(0,0), cc.p(0.5,0.5)) 
	self.bg = bg
	self.centerX = 253
	--bg:setOpacity(0)

	-- --addSprite(bg, pathCommon.."20.png", cc.p(245,470), cc.p(0.5,0.5))
	-- local posX = 75
	-- local posY = 45
	-- local padding = 140
	local btnLablePos = cc.p(61, 30)

	-- local switchBtn = createMenuItem(bg,"res/component/button/50.png",cc.p(self.centerX+100,70),switchFunc)
	-- switchBtn:setSmallToBigMode(false)
	-- self:onStateLableSwitch(switchBtn)
	--posX = posX + padding

	-- local explainBtn = createMenuItem(bg,"res/component/button/4.png",cc.p(bg:getContentSize().width/2,45),explainFun)
	-- explainBtn:setSmallToBigMode(false)
	-- addLabel(explainBtn,self.getString("wr_explain"),btnLablePos,cc.p(0.5,0.5),22,true)
	--posX = posX + padding

	-- local detailBtn = createMenuItem(bg,"res/component/button/4.png",cc.p(display.width*2,45),detailFun)
	-- self.detailBtn = detailBtn
	-- detailBtn:setSmallToBigMode(false)
	-- addLabel(detailBtn,self.getString("wr_detail"),btnLablePos,cc.p(0.5,0.5),22,true)
	--posX = posX + padding

	-- local skillBtn = createMenuItem(bg,"res/component/button/4.png",cc.p(bg:getContentSize().width/2+150,45),skillFun)
	-- self.skillBtn = skillBtn
	-- skillBtn:setSmallToBigMode(false)
	-- if self.type == wingAndRidingType.WR_TYPE_WING then
	-- 	addLabel(skillBtn,self.getString("wr_wing_skill"),btnLablePos,cc.p(0.5,0.5),22,true)
	-- elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
	-- 	addLabel(skillBtn,self.getString("wr_riding_skill"),btnLablePos,cc.p(0.5,0.5),22,true)
	-- end	
	--posX = posX + padding

	local showNode
	if self.type == wingAndRidingType.WR_TYPE_WING then
		showNode = require("src/layers/wingAndRiding/WingAndRidingShowNode").new(self.type, self:getCfgData("q_level"), 1)
		showNode:setPosition(cc.p(self.centerX+20, 260))
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		showNode = require("src/layers/wingAndRiding/WingAndRidingShowNode").new(self.type, self:getCfgData("q_panelSouceID"), 0.8)
		showNode:setPosition(cc.p(self.centerX, 230))
	end	
	bg:addChild(showNode)

	-- local nameBg = createSprite(bg, pathCommon.."54.png", cc.p(292, 465), cc.p(0.5, 0.5))
	-- --addLabel(bg,self:getCfgData("q_name"),cc.p(292, 500),cc.p(0.5,0.5),40)
	-- local getNamePath = function(id)
	-- 	local resId = id % 10
	-- 	return path.."model/"..resId..".png"
	-- end
	-- createSprite(nameBg, getNamePath(self:getData("id")), cc.p(113, 30), cc.p(0.5, 0.5))
	local nameBg = createSprite(bg, "res/layers/role/24.png", cc.p(self.centerX-7, 440), cc.p(0.5, 0)) 
	addLabel(nameBg, self:getCfgData("q_name"), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)

	local levelBg = createSprite(bg, pathCommon.."1.png", cc.p(445, 435), cc.p(0.5, 0.5))
	local levelNum = self:getCfgData("q_level")
	createMultiLineLabel(levelBg, game.getStrByKey("num_"..levelNum)..game.getStrByKey("grade"), cc.p(levelBg:getContentSize().width/2, levelBg:getContentSize().height-25), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_yellow, 30, 25, true)
	--createSprite(bg, pathCommon..(levelNum+9)..".png", cc.p(510, 475), cc.p(0.5, 0.5))

	local advanceBtn = createMenuItem(bg,"res/component/button/50.png",cc.p(self.centerX,70),advanceFun)
	if self.type == wingAndRidingType.WR_TYPE_WING then
		G_TUTO_NODE:setTouchNode(advanceBtn, TOUCH_WING_ADVANCE)
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		G_TUTO_NODE:setTouchNode(advanceBtn, TOUCH_RIDE_ADVANCE)
	end 
	
	advanceBtn:setSmallToBigMode(false)
	addLabel(advanceBtn,self.getString("wr_advance_start"),getCenterPos(advanceBtn),cc.p(0.5,0.5),22,true)

	if self.type == wingAndRidingType.WR_TYPE_RIDING then
		addLabel(bg, self.getString("wr_ride_on_off_tip"), cc.p(20, 110), cc.p(0, 0), 20, true, nil, nil, MColor.white)
	end 

	-- if not self.isOtherRole then
	-- 	local bless = self:getData("bless")
	-- 	local needNum = self:getCfgData("q_needNum")
	-- 	--进度条
	-- 	local progressBg = createSprite(bg, "res/component/progress/1.png", cc.p(self.centerX, 10), cc.p(0.5, 0))
	-- 	self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/1-1.png"))  
	-- 	progressBg:addChild(self.progress)
	--     self.progress:setPosition(getCenterPos(progressBg))
	--     self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	--     self.progress:setAnchorPoint(cc.p(0.5, 0.5))
	--     self.progress:setBarChangeRate(cc.p(1, 0))
	--     self.progress:setMidpoint(cc.p(0, 1))
	--     if needNum then
	-- 	    self.progress:setPercentage(bless*100/needNum)
	-- 	    --进度
	-- 		self.progressLabel = createLabel(progressBg, bless.."/"..needNum, getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
	-- 	else
	-- 		progressBg:setVisible(false)
	-- 	end
	-- end

	self:setContentSize(bg:getContentSize())
	self:setAnchorPoint(cc.p(0.5, 0.5))
	bg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	--dump(self:getContentSize(), "getContentSize")
	--SwallowTouches(self)

	--潜能丹
	--self:createPotencyIcon(bg)

	self:createStar()

	--进阶成功时播放成功特效
	if isSuccess then
		--进阶成功特效
		local animateSpr = Effects:create(false)
		performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,2)
		animateSpr:playActionData("wingAndRidingSuccess", 11, 1.5, 1)
		addEffectWithMode(animateSpr, 1)
		getRunScene():addChild(animateSpr, 400)
		--local pos = self:convertToNodeSpace(cc.p(display.cx, display.cy))
		-- local pos = self:convertToNodeSpace(cc.p(-135, 50))
		-- log("pos.x = "..pos.x)
		-- log("pos.y = "..pos.y)
		animateSpr:setPosition(cc.p(display.cx, display.cy))
		startTimerAction(self, 2, false, function() removeFromParent(animateSpr) end)

		advanceFun()
	end

	--查看别的玩家资料时去掉不必要的按钮
	if isOtherRole then
		removeFromParent(switchBtn)
		--removeFromParent(explainBtn)
		removeFromParent(advanceBtn)
		--detailBtn:setPositionX(150)
		--skillBtn:setPositionX(430)
	end
end

function WingAndRidingRightNode:createStar()
	if self.star == nil then
		self.star = {}
		local padding = 36
		local y = 415
		self.star[1] = createSprite(self.bg, "res/group/star/s3.png", cc.p(self.centerX-padding*2, y), cc.p(0.5, 0.5))
		self.star[2] = createSprite(self.bg, "res/group/star/s3.png", cc.p(self.centerX-padding, y), cc.p(0.5, 0.5))
		self.star[3] = createSprite(self.bg, "res/group/star/s3.png", cc.p(self.centerX, y), cc.p(0.5, 0.5))
		self.star[4] = createSprite(self.bg, "res/group/star/s3.png", cc.p(self.centerX+padding, y), cc.p(0.5, 0.5))
		self.star[5] = createSprite(self.bg, "res/group/star/s3.png", cc.p(self.centerX+padding*2, y), cc.p(0.5, 0.5))
	end

	local star = self:getCfgData("q_star")
	for i=1,star do
		createSprite(self.star[i], "res/group/star/s4.png", getCenterPos(self.star[i]), cc.p(0.5, 0.5))
	end
end

-- function WingAndRidingRightNode:onExit()
-- 	log("WingAndRidingRightNode:onExit")	
-- 	if self.type == wingAndRidingType.WR_TYPE_WING then
-- 		if self.state ~= self:getData("state") then
-- 			g_msgHandlerInst:sendNetDataByFmtExEx(WING_CS_CHANG_STATE, "ic", G_ROLE_MAIN.obj_id, self.state)
-- 		end
-- 	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
-- 		if self.state ~= self:getData("state") then
-- 			g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ic", G_ROLE_MAIN.obj_id, self.state)
-- 		end
-- 	end 
-- end
function WingAndRidingRightNode:createPotencyIcon(parent)
	print("test 1")
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	local potencyType
	if self.type == wingAndRidingType.WR_TYPE_WING then
		potencyType = 2
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		potencyType = 1
	elseif self.type == wingAndRidingType.WR_TYPE_ZHJ then
		potencyType = 3
	elseif self.type == wingAndRidingType.WR_TYPE_ZHR then
		potencyType = 4
	end
	--dump(potencyType)
	--dump(school)
	local record
	for k,v in pairs(require("src/config/PotencyDB")) do
		if v.q_type == potencyType and v.q_school == school then
			record = v
			break
		end
	end
	--dump(record)
	if record then
		local Mprop = require("src/layers/bag/prop")
		local iconNode = Mprop.new({cb = "tips", protoId = record.q_itemID})
		iconNode:setAnchorPoint(cc.p(0.5, 0.5))
		if parent then
			print("test 2")
			parent:addChild(iconNode)
			iconNode:setPosition(cc.p(65, 470))
		end
	end

	--g_msgHandlerInst:sendNetDataByFmtExEx(WOMAN_CS_GET_POTENCY_DATA, "ic", G_ROLE_MAIN.obj_id, potencyType)
	self.potencyTip = createLabel(parent, "0/0", cc.p(115, 470), cc.p(0, 0.5), 24, true, nil, nil, MColor.white)
	self.potencyType = potencyType
end

function WingAndRidingRightNode:onStateLableSwitch(parent)
	local str
	if self.type == wingAndRidingType.WR_TYPE_WING then
		if self.state == 1 then
			str = self.getString("wr_wing_hide")
		elseif self.state == 0 then
			str = self.getString("wr_wing_show")
		end
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		if self.state == 1 then
			str = self.getString("wr_riding_off")
		elseif self.state == 0 then
			str = self.getString("wr_riding_on")
		end
	end	

	if str then
		if self.stateLabel == nil then
			self.stateLabel = createLabel(parent,str,getCenterPos(parent),cc.p(0.5,0.5),22,true)
		else
			self.stateLabel:setString(str)
		end
	end
end

function WingAndRidingRightNode:setData(key, value)
	log("key:"..key)
	if self.type == wingAndRidingType.WR_TYPE_WING then
		log("key:"..G_WING_INFO[key])
		G_WING_INFO[key] = value
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		log("key:"..G_RIDING_INFO[key])
		G_RIDING_INFO[key] = value
	end 
end

function WingAndRidingRightNode:getData(key)
	if self.isOtherRole then
		if self.type == wingAndRidingType.WR_TYPE_WING then
			return self.otherRoleData.wing[key]
		elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
			return self.otherRoleData.ridingInfo[key]
		end 
	end	

	log("key:"..key)
	if self.type == wingAndRidingType.WR_TYPE_WING then
		log("key:"..G_WING_INFO[key])
		return G_WING_INFO[key]
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		log("key:"..G_RIDING_INFO[key])
		return G_RIDING_INFO[key]
	end 
end

function WingAndRidingRightNode:getCfgData(key)
	log("WingAndRidingLeftNode:getCfgData")	
	if self.type == wingAndRidingType.WR_TYPE_WING then
		if self.isOtherRole then
			log("self.otherRoleData.wing.id = "..self.otherRoleData.wing.id)
			return getConfigItemByKey("WingCfg", "q_ID", self.otherRoleData.wing.id, key)
		else
			return getConfigItemByKey("WingCfg", "q_ID", G_WING_INFO.id, key) 
		end
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		if self.isOtherRole then
			return getConfigItemByKey("RidingCfg", "q_ID", self.otherRoleData.ridingInfo.id, key)
		else
			return getConfigItemByKey("RidingCfg", "q_ID", G_RIDING_INFO.id, key) 
		end
	end 
end

function WingAndRidingRightNode:reloadData()
end

function WingAndRidingRightNode:networkHander(buff,msgid)
	local switch = {
		[WOMAN_SC_GET_POTENCY_DATA_RET] = function()
			print("get WOMAN_SC_GET_POTENCY_DATA_RET")
			local potencyType = buff:popChar()
			local curNum = buff:popInt()
			local maxNum = buff:popInt()
			print("potencyType = "..potencyType)
			print("curNum = "..curNum)
			print("maxNum = "..maxNum)
			if potencyType == self.potencyType then
				if self.potencyTip then
					self.potencyTip:setString(curNum.."/"..maxNum)
				end
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function WingAndRidingRightNode:onAdvanceSuccess()
	log("WingAndRidingRightNode:onAdvanceSuccess")
	-- G_RIDING_INFO.id = G_RIDING_INFO.id + 1
	log("id = " .. self:getData("id"))
	-- self.stateLabel = nil 
	-- self:createNode()
	--self:removeAllChildren()
	local parent = self.parent
	local detailNode = require("src/layers/wingAndRiding/WingAndRidingLeftNode").new(parent, self.type)
	parent.switchLeftView(parent, detailNode, 30)
	local rightNode = require("src/layers/wingAndRiding/WingAndRidingRightNode").new(parent, self.type, true)
	parent.switchRightView(parent, rightNode)

	--进阶成功提示
	--MessageBox(game.getStrByKey("wr_advance_successTip"), "", nil)
end

return WingAndRidingRightNode