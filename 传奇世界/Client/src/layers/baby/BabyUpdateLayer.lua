local BabyUpdateLayer = class("BabyUpdateLayer", function() return cc.Layer:create() end)

local path = "res/baby/"

function BabyUpdateLayer:ctor(data)
	local msgids = {BABY_SC_UPSTATE_RET}
	require("src/MsgHandler").new(self, msgids)

	self.data = data
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.maxLv = 15

	local bg = createBgSprite(self, path.."icon.png", path.."title_3.png")
	local bgImage = createSprite(bg, path.."4.png", cc.p(bg:getContentSize().width/2 ,15), cc.p(0.5, 0))
	local levelBg = createSprite(bg, path.."5.png", cc.p(bg:getContentSize().width/2 ,275), cc.p(0.5, 0))
	local connect = createSprite(levelBg, path.."6.png", cc.p(levelBg:getContentSize().width/2 ,0), cc.p(0.5, 1))

	if self.data.stateLevel ~= self.maxLv then
		createSprite(levelBg, "res/group/arrows/6.png", getCenterPos(levelBg), cc.p(0.5, 0.5))
	end
	local leftLevelBg = createSprite(levelBg, path.."7.png", cc.p(levelBg:getContentSize().width/2-230 ,levelBg:getContentSize().height/2), cc.p(0.5, 0.5))
	self.leftLevelBg = leftLevelBg
	createSprite(leftLevelBg, path.."state/state_"..self.data.stateLevel.."_1"..".png", cc.p(leftLevelBg:getContentSize().width/2 ,112), cc.p(0.5, 0), nil, 1)
	if self.data.stateLevel == self.maxLv then
		leftLevelBg:setPosition(getCenterPos(levelBg))
	end

	if self.data.stateLevel ~= self.maxLv then
		local rightLevelBg = createSprite(levelBg, path.."7.png", cc.p(levelBg:getContentSize().width/2+230 ,levelBg:getContentSize().height/2), cc.p(0.5, 0.5))
		self.rightLevelBg = rightLevelBg
		createSprite(rightLevelBg, path.."state/state_"..(self.data.stateLevel+1).."_1"..".png", cc.p(rightLevelBg:getContentSize().width/2 ,112), cc.p(0.5, 0), nil, 1)
	end

	local help = __createHelp(
	{
		parent = levelBg,
		str = require("src/config/PromptOp"):content(19),
		pos = cc.p(865, 30),
	})

	function levelUpFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_UPSTATE, "i", G_ROLE_MAIN.obj_id)
		--addNetLoading(BABY_CS_UPSTATE, BABY_SC_UPSTATE_RET)

		-- self:getParent():levelUpState(self.data.stateLevel+1)
		-- removeFromParent(self)
	end
	if self.data.stateLevel ~= self.maxLv then
		local levelUpBtn = createMenuItem(bgImage, "res/component/button/4.png", cc.p(bgImage:getContentSize().width/2 ,45), levelUpFunc)
		createLabel(levelUpBtn, game.getStrByKey("upgrade"), getCenterPos(levelUpBtn), cc.p(0.5, 0.5), 24, true)
	end

	local pointFunc = function()
		local layer = require("src/layers/baby/BabyPointLayer").new(self.data, self.pointId)
		Manimation:transit(
		{
			ref = self,
			node = layer,
			curve = "-",
			sp = self.pointBtn:getParent():convertToWorldSpace(cc.p(self.pointBtn:getPosition())),
			swallow = true,
		})
	end
	local pointBtn = createMenuItem(connect, "res/common/23.png", cc.p(0, -40), pointFunc)
	self.pointBtn = pointBtn
	createSprite(pointBtn, path.."15.png", getCenterPos(pointBtn), cc.p(0.5, 0.5), nil, 1.15)
	--特效
	local animate = tutoAddAnimation(pointBtn, cc.p(pointBtn:getContentSize().width/2, pointBtn:getContentSize().height/2), TUTO_ANIMATE_TYPE_BUTTON)
	animate:setContentSize(cc.size(200, 60))
	scaleToTarget(animate, pointBtn)
	local pointLabel = createLabel(pointBtn, "", cc.p(pointBtn:getContentSize().width/2, -30), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)
	self.pointLabel = pointLabel

	local moneyBtn = createPropIcon(connect, 999998, true, false, nil)
	moneyBtn:setPosition(cc.p(connect:getContentSize().width/2, -40))
	local moneyLabel = createLabel(moneyBtn, "", cc.p(moneyBtn:getContentSize().width/2, -30), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)
	self.moneyLabel = moneyLabel

	local icon = createPropIcon(connect, 1104, true, false, nil)
	icon:setPosition(cc.p(connect:getContentSize().width, -40))
	local iconLabel = createLabel(icon, "", cc.p(icon:getContentSize().width/2, -30), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)
	self.iconLabel = iconLabel

	self:addAttInfo()
	self:updateData()
end

function BabyUpdateLayer:updateData()
	self:updateUI()
end

function BabyUpdateLayer:updateUI()
	self:updatePointInfo()
	self:updateMoneyInfo()
	self:updateIconInfo()
end

function BabyUpdateLayer:updatePointData(data)
	for k,v in pairs(data) do
		local id = v.q_ID 
		local lv = v.q_lv
		--print("id = "..id)
		--print("lv = "..lv)
		for k,v in pairs(self.data.pointData) do
			if v.id == id then
				--print("find!!!!!!!!!!!")
				v.lv = lv
			end
		end
	end

	self:updateData()
end

function BabyUpdateLayer:updatePointInfo()
	local record = getConfigItemByKeys("BabyStateDB", {"q_level", "q_school"}, {self.data.stateLevel, self.school})
	if record.q_needPoint then
		local pointTab = unserialize(record.q_needPoint)
		local pointId
		local pointNeedLevel
		for k,v in pairs(pointTab) do
			pointId = k
			pointNeedLevel = v
		end
		self.pointId = pointId
		local pointName = getConfigItemByKey("BabyPointRelationDB", "q_ID", pointId, "q_name")

		local pointlevel = 0
		for k,v in pairs(self.data.pointData) do
			if v.id == pointId then
				pointlevel = v.lv 
				break
			end
		end

		local color = MColor.red
		if pointlevel >= pointNeedLevel then
			color = MColor.green
		end

		self.pointLabel:setString(pointName..":"..pointlevel.."/"..pointNeedLevel..game.getStrByKey("baby_point_level"))
		self.pointLabel:setColor(color)
	end
end

function BabyUpdateLayer:updateMoneyInfo()
	local record = getConfigItemByKeys("BabyStateDB", {"q_level", "q_school"}, {self.data.stateLevel, self.school})
	if record.q_needMoney then
		local myMoney = require("src/layers/role/RoleStruct"):getAttr(PLAYER_MONEY)
		local myBindMoney = require("src/layers/role/RoleStruct"):getAttr(PLAYER_BINDMONEY)
		local myMoney = myMoney + myBindMoney

		local needMoney = record.q_needMoney

		local color = MColor.red
		if myMoney >= needMoney then
			color = MColor.green
		end

		self.moneyLabel:setString(game.getStrByKey("baby_refresh_monney")..numToFatString(needMoney).."/"..numToFatString(myMoney))
		self.moneyLabel:setColor(color)
	end
end

function BabyUpdateLayer:updateIconInfo()
	local record = getConfigItemByKeys("BabyStateDB", {"q_level", "q_school"}, {self.data.stateLevel, self.school})
	if record.q_materialID then
		local materialTab = unserialize(record.q_materialID)
		local materialId
		local materialNeedNum
		for k,v in pairs(materialTab) do
			materialId = k
			materialNeedNum = v
		end
		local materialName = require("src/config/propOp").name(materialId)

		local bag = MPackManager:getPack(MPackStruct.eBag)
		local materialNum = bag:countByProtoId(materialId)

		local color = MColor.red
		if materialNum >= materialNeedNum then
			color = MColor.green
		end

		self.iconLabel:setString(materialName..":"..materialNum.."/"..materialNeedNum..game.getStrByKey("baby_material_number"))
		self.iconLabel:setColor(color)
	end
end

function BabyUpdateLayer:addAttInfo()
	self.leftLevelBg:removeChildByTag(10)
	--dump(self.data.stateLevel)
	--dump(self.school)
	local attRecord = getConfigItemByKeys("BabyStateDB", {"q_level", "q_school"}, {self.data.stateLevel, self.school})
	--dump(attRecord)
	local attNode = createAttNode(attRecord, 20, MColor.green)
	self.leftLevelBg:addChild(attNode)
	attNode:setPosition(cc.p(75, 10))
	attNode:setTag(10)
	--dump(attNode:getContentSize())

	if self.rightLevelBg then
		self.rightLevelBg:removeChildByTag(10)

		local attRecord = getConfigItemByKeys("BabyStateDB", {"q_level", "q_school"}, {self.data.stateLevel+1, self.school})
		--dump(attRecord)
		if attRecord then
			local attNode = createAttNode(attRecord, 20, MColor.green)
			self.rightLevelBg:addChild(attNode)
			attNode:setPosition(cc.p(75, 10))
			attNode:setTag(10)
		end
		--dump(attNode:getContentSize())
	end
end

function BabyUpdateLayer:networkHander(buff, msgid)
	local switch = {
		[BABY_SC_UPSTATE_RET] = function()
			log("get BABY_SC_UPSTATE_RET")
			local newStateLevel = buff:popChar()
			if newStateLevel > self.data.stateLevel then
				self:getParent():levelUpState(newStateLevel)
				removeFromParent(self)
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return BabyUpdateLayer