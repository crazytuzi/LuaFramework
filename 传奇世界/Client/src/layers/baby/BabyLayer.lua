local BabyLayer = class("BabyLayer", function() return cc.Layer:create() end)

local path = "res/baby/"

function BabyLayer:ctor()
	local msgids = {BABY_SC_GETALLDATA_RET, BABY_SC_UPPERIOD_RET, BABY_SC_PROMOTOPERIOD_RET}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_GETALLDATA, "i", G_ROLE_MAIN.obj_id)
	--addNetLoading(BABY_CS_GETALLDATA, BABY_SC_GETALLDATA_RET)

	self.data = {}
	self.progressValue = 0
	self.progressMaxValue = 100
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.level = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
	self.useNum = 1
	self.materialId = 1105
	self.maxPeriodLevel = 5

	local bg = createBgSprite(self, path.."icon.png", path.."title_1.png")
	local bgImage = createSprite(bg, path.."bg_1.jpg", cc.p(bg:getContentSize().width/2 ,90), cc.p(0.5, 0))
	self.bgImage = bgImage
	createScale9Sprite(bgImage, "res/common/scalable/goldCorner.png", getCenterPos(bgImage), bgImage:getContentSize(), cc.p(0.5, 0.5))
	local bottomBg = createSprite(bg, "res/common/65.png", cc.p(bg:getContentSize().width/2 ,15), cc.p(0.5, 0))

	local effectBg = createSprite(bgImage, path.."19.png", getCenterPos(bgImage, -142, -8), cc.p(0.5, 0.5), nil, 0.7)
	effectBg:setOpacity(255*0.05)
	local babyEffect = Effects:create(false)
	babyEffect:setCleanCache()
	self.babyEffect = babyEffect
	babyEffect:playActionData("babyPeriod1", 14, 0.6, -1)
	effectBg:addChild(babyEffect)
	babyEffect:setPosition(getCenterPos(effectBg, -10, 5))
	babyEffect:setScale(1.4)

	--期框
	local levelBg = createSprite(bgImage, path.."3.png", cc.p(785, bgImage:getContentSize().height), cc.p(0.5, 1))
	self.levelBg = levelBg
	self.levelLabel = createSprite(levelBg, path.."level_1.png", getCenterPos(levelBg), cc.p(0.5, 0.5))
	local help = __createHelp(
	{
		parent = levelBg,
		str = require("src/config/PromptOp"):content(18),
		pos = cc.p(210, levelBg:getContentSize().height/2),
	})

	--战斗力框
	local fightBg = createSprite(bgImage, "res/common/fight_2.jpg", cc.p(785, 330), cc.p(0.5, 0))
	self.fightBg = fightBg
	createSprite(fightBg, "res/wingAndRiding/common/23.png", cc.p(20 ,45), cc.p(0, 0))
	self.fightLabel = cc.LabelAtlas:_create(0, "res/component/number/3.png", 35, 52, string.byte('0'))
	self.fightLabel:setScale(0.7)
	self.fightBg:addChild(self.fightLabel)
	self.fightLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.fightLabel:setPosition(fightBg:getContentSize().width/2, 28)

	--属性框
	local propBg = createScale9Sprite(bgImage, "res/common/66.png", cc.p(785 ,325), cc.size(246, 160), cc.p(0.5, 1))--createSprite(bgImage, path.."1.png", cc.p(785 ,325), cc.p(0.5, 1))
	createSprite(propBg, path.."2.png", cc.p(propBg:getContentSize().width/2 ,propBg:getContentSize().height-5), cc.p(0.5, 1))
	self.propBg = propBg

	local iconUseBtnFunc = function()
		print("iconUseBtnFunc")
		self.progressMaxValue = getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school}, "q_needTime")
		local needNum = self.progressMaxValue - self.progressValue
		local bag = MPackManager:getPack(MPackStruct.eBag)
		local haveNum = bag:countByProtoId(self.materialId)
		local useNum
		if needNum <= haveNum then
			useNum = needNum
		else
			useNum = haveNum
		end

		--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_PROMOTOPERIOD, "ii", G_ROLE_MAIN.obj_id, useNum)
		--addNetLoading(BABY_CS_PROMOTOPERIOD, BABY_SC_PROMOTOPERIOD_RET)
	end
	local iconBtn = createPropIcon(bgImage, self.materialId, true, false, nil)
	self.iconBtn = iconBtn
	iconBtn:setPosition(cc.p(765, 120))
	iconBtn:setScale(0.9)
	local iconUseBtn = createMenuItem(bgImage, "res/component/button/22.png", cc.p(850, 115), iconUseBtnFunc)
	self.iconUseBtn = iconUseBtn
	self.iconUseLabel = createLabel(iconUseBtn, game.getStrByKey("use"), getCenterPos(iconUseBtn, 5, 5), cc.p(0.5, 0.5), 20, true)

	local progressTip = createSprite(bgImage, path.."1.png", cc.p(660, 50), cc.p(0, 0), nil, 0.75)
	self.progressTip = progressTip
	--进度条
	local progressBg = createSprite(bgImage, "res/common/progress/bg.png", cc.p(785, 0), cc.p(0.5, 0))
	self.progressBg = progressBg
	progressBg:setScale(0.75, 1)
	self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/p2.png"))  
	progressBg:addChild(self.progress)
    self.progress:setPosition(getCenterPos(progressBg))
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setBarChangeRate(cc.p(1, 0))
    self.progress:setMidpoint(cc.p(0, 1))
    self.progress:setPercentage(self.progressValue)
    --进度
	self.progressLabel = createLabel(progressBg, self.progressValue.." / "..self.progressMaxValue, getCenterPos(progressBg), cc.p(0.5, 0.5), 26, true, nil, nil, MColor.white)

	function levelUpBtnFunc()
		--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_UPPERIOD, "i", G_ROLE_MAIN.obj_id)
		--addNetLoading(BABY_CS_UPPERIOD, BABY_SC_UPPERIOD_RET)
	end
	local levelUpBtn = createMenuItem(bottomBg, "res/component/button/11.png", cc.p(785, bottomBg:getContentSize().height/2-5), levelUpBtnFunc)
	self.levelUpBtn = levelUpBtn
	--特效
	local animate = tutoAddAnimation(levelUpBtn, cc.p(levelUpBtn:getContentSize().width/2, levelUpBtn:getContentSize().height/2), TUTO_ANIMATE_TYPE_BUTTON)
	animate:setContentSize(cc.size(200, 65))
	scaleToTarget(animate, levelUpBtn)
	self.levelUpLabel = createLabel(levelUpBtn, game.getStrByKey("baby_level"), getCenterPos(levelUpBtn), cc.p(0.5, 0.5), 22, true)

	function stateBtnFunc(index)
		if self.state[index] == self.data.stateLevel then
			local layer = require("src/layers/baby/BabyUpdateLayer").new(self.data)
			Manimation:transit(
			{
				ref = self,
				node = layer,
				curve = "-",
				sp = self.stateBtn[index]:getParent():convertToWorldSpace(cc.p(self.stateBtn[index]:getPosition())),
				swallow = true,
			})
		elseif self.state[index] < self.data.stateLevel then
			MessageBox(game.getStrByKey("baby_state_low_tip"))
		elseif self.state[index] > self.data.stateLevel then
			MessageBox(game.getStrByKey("baby_state_high_tip"))
		end
	end

	self.stateBtn = {}
	local btnBg1 = createMenuItem(bgImage, path.."20.png", cc.p(160, 280), function() stateBtnFunc(1) end)
	self.stateBtn[1] = createSprite(btnBg1, path.."state/state_1.png", getCenterPos(btnBg1), cc.p(0.5, 0.5))
	local btnBg2 = createMenuItem(bgImage, path.."20.png", cc.p(320, 190), function() stateBtnFunc(2) end)
	self.stateBtn[2] = createSprite(btnBg2, path.."state/state_2.png", getCenterPos(btnBg2), cc.p(0.5, 0.5))
	local btnBg3 = createMenuItem(bgImage, path.."20.png", cc.p(480, 280), function() stateBtnFunc(3) end)
	self.stateBtn[3] = createSprite(btnBg3, path.."state/state_3.png", getCenterPos(btnBg3), cc.p(0.5, 0.5))

	function refreshBtnFunc()
		if G_NFTRIGGER_NODE:isFuncOn(NF_BABY_QUALITY) then
			local layer = require("src/layers/baby/BabyRefreshLayer").new(self.data)
			Manimation:transit(
			{
				ref = self,
				node = layer,
				curve = "-",
				sp = self.refreshBtn:getParent():convertToWorldSpace(cc.p(self.refreshBtn:getPosition())),
				swallow = true,
			})
		else
			TIPS({type=1, str=game.getStrByKey("func_unavailable_baby_refresh")})
		end
	end
	local refreshBtn = createMenuItem(bgImage, "res/component/button/9.png", cc.p(580, 415), refreshBtnFunc)
	self.refreshBtn = refreshBtn
	createLabel(refreshBtn, game.getStrByKey("baby_refresh"), getCenterPos(refreshBtn), cc.p(0.5, 0.5), 22, true)
end

function BabyLayer:updateData()
	dump(getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school}))
	self.progressValue = self.data.periodprogress
	self.progressMaxValue = getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school}, "q_needTime")

	--local stateLevelTab = getConfigItemByKey("BabyStateDB", "q_school", self.school)
	self.state = {}
	self.state[1] = math.floor((self.data.stateLevel-1)/3) * 3 + 1
	self.state[2] = math.floor((self.data.stateLevel-1)/3) * 3 + 2
	self.state[3] = math.floor((self.data.stateLevel-1)/3) * 3 + 3

	self:updateUI()
end

function BabyLayer:updateUI()
	self.bgImage:setTexture(path.."bg_"..self.data.periodLevel..".jpg")
	self.babyEffect:playActionData("babyPeriod"..self.data.periodLevel, 14, 1, -1)

	if self.progressValue and self.progressMaxValue then
		self.progress:setPercentage(self.progressValue/self.progressMaxValue * 100)
		self.progressLabel:setString(self.progressValue.." / "..self.progressMaxValue)
	end

	--dump(self.state)
	--dump(self.data.stateLevel)
	for i=1,3 do
		self.stateBtn[i]:setTexture(path.."state/state_"..self.state[i]..".png")
		if self.state[i] == self.data.stateLevel then
			self:addStateEffect(self.stateBtn[i])
		end

		if self.state[i] > self.data.stateLevel then
			self.stateBtn[i]:getParent():setVisible(false)
		else
			self.stateBtn[i]:getParent():setVisible(true)
		end
	end

	if self.state[1] == self.data.stateLevel then
		self.stateBtn[1]:getParent():setPosition(cc.p(320, 190))
	else
		self.stateBtn[1]:getParent():setPosition(cc.p(160, 280))
	end

	self.levelLabel:setTexture(path.."level_"..self.data.periodLevel..".png")

	self:updateFight()
	self:addAttInfo()
	self:checkShowOrHide()
end

function BabyLayer:checkShowOrHide()
	local sonStr = getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school}, "q_son")
	local sonTab = stringsplit(sonStr, "_")
	self.needStateLevel = tonumber(sonTab[#sonTab])%20
	-- dump(sonTab)
	-- dump(self.data.stateLevel)
	-- dump(self.needStateLevel)
	if self.data.stateLevel == self.needStateLevel then
		self.iconBtn:setVisible(true)
		self.iconUseBtn:setVisible(true)
		self.iconUseLabel:setOpacity(255)

		self.progressTip:setVisible(true)
		self.progressBg:setVisible(true)
		self.progressLabel:setOpacity(255)

		self.levelUpBtn:setVisible(true)
		self.levelUpLabel:setOpacity(255)

		self.levelBg:setPosition(cc.p(785, self.bgImage:getContentSize().height))
		self.fightBg:setPosition(cc.p(785, 330))
		self.propBg:setPosition(cc.p(785, 325))
	else
		self.iconBtn:setVisible(false)
		self.iconUseBtn:setVisible(false)
		self.iconUseLabel:setOpacity(0)

		self.progressTip:setVisible(false)
		self.progressBg:setVisible(false)
		self.progressLabel:setOpacity(0)

		self.levelUpBtn:setVisible(false)
		self.levelUpLabel:setOpacity(0)

		self.levelBg:setPosition(cc.p(785, self.bgImage:getContentSize().height-100))
		self.fightBg:setPosition(cc.p(785, 330-100))
		self.propBg:setPosition(cc.p(785, 325-100))
	end

	if self.data.periodLevel == self.maxPeriodLevel then
		self.iconBtn:setVisible(false)
		self.iconUseBtn:setVisible(false)
		self.iconUseLabel:setOpacity(0)

		self.progressTip:setVisible(false)
		self.progressBg:setVisible(false)
		self.progressLabel:setOpacity(0)

		self.levelUpBtn:setVisible(false)
		self.levelUpLabel:setOpacity(0)

		self.levelBg:setPosition(cc.p(785, self.bgImage:getContentSize().height-100))
		self.fightBg:setPosition(cc.p(785, 330-100))
		self.propBg:setPosition(cc.p(785, 325-100))
	end

	if self.data.periodLevel == self.maxPeriodLevel or self.progressValue < self.progressMaxValue then
		self.levelUpBtn:setVisible(false)
		self.levelUpLabel:setOpacity(0)
	else
		self.levelUpBtn:setVisible(true)
		self.levelUpLabel:setOpacity(255)
	end
end

function BabyLayer:updateFight()
	local getFightAbility = function(record)
		if record then
			--dump(record)
			local paramTab = {}

			local MRoleStruct = require("src/layers/role/RoleStruct")
			paramTab.school = MRoleStruct:getAttr(ROLE_SCHOOL)
			if paramTab.school == 1 then
				paramTab.attack = {["["] = record.q_attack_min, ["]"] = record.q_attack_max}
			elseif paramTab.school == 2 then
				paramTab.attack = {["["] = record.q_magic_attack_min, ["]"] = record.q_magic_attack_max}
			elseif paramTab.school == 3 then
				paramTab.attack = {["["] = record.q_sc_attack_min, ["]"] = record.q_sc_attack_max}
			end
			 
			paramTab.lucks = record.q_luck
			paramTab.pDefense = {["["] = record.q_defence_min, ["]"] = record.q_defence_max}
			paramTab.mDefense = {["["] = record.q_magic_defence_min, ["]"] = record.q_magic_defence_max}
			paramTab.hp = record.q_max_hp
			paramTab.hit = record.q_hit
			paramTab.dodge = record.q_dodge
			paramTab.skill = {}

			--dump(paramTab)
			local Mnumerical = require "src/functional/numerical"
			return Mnumerical:calcCombatPowerRange(paramTab)
		else
			return 0
		end
	end 

	local attRecord = getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school})
	local fight = getFightAbility(attRecord)
	dump(fight)
	self.fightLabel:setString(fight)
end

function BabyLayer:removeStateEffect()
	for i=1,3 do
		self.stateBtn[i]:removeChildByTag(10)
	end
end

function BabyLayer:addStateEffect(btn)
	self:removeStateEffect()

	local stateEffect = createSprite(btn, path.."effect/"..self.data.quality..".png", getCenterPos(btn), cc.p(0.5, 0.5), -1)
	self.stateEffect = stateEffect
	stateEffect:setTag(10)
	stateEffect:setScale(0.8)
	stateEffect:setOpacity(255*0.8)
	local effectAction = cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2, 180)))
	stateEffect:runAction(effectAction)
end

function BabyLayer:addAttInfo()
	self.propBg:removeChildByTag(10)

	local attRecord = getConfigItemByKeys("BabyPeriodDB", {"q_level", "q_school"}, {self.data.periodLevel, self.school})
	--dump(attRecord)
	local attNode = createAttNode(attRecord, 20, MColor.green)
	self.propBg:addChild(attNode)
	attNode:setAnchorPoint(cc.p(0, 1))
	attNode:setPosition(cc.p(35, 115))
	attNode:setTag(10)
end

function BabyLayer:levelUpState(newStateLevel)
	self.data.stateLevel = newStateLevel

	self:updateData()
end

function BabyLayer:updateQuality(newQuality)
	self.data.quality = newQuality

	self:updateData()
end

function BabyLayer:networkHander(buff, msgid)
	local switch = {
		[BABY_SC_GETALLDATA_RET] = function()
			log("get BABY_SC_GETALLDATA_RET")
			self.data = {}
			self.data.isActive = buff:popChar()
			self.data.periodLevel = buff:popChar()
			self.data.periodprogress = buff:popInt()
			self.data.stateLevel = buff:popChar()
			self.data.quality = buff:popChar()

			self.data.pointData = {}
			local pointNum = buff:popChar()
			dump(pointNum)
			for i=1,pointNum do
				local record = {}
				record.id = buff:popInt()
				record.lv = buff:popChar()
				table.insert(self.data.pointData, #self.data.pointData+1, record)
			end
			dump(self.data)
			self:updateData()
		end
		,

		[BABY_SC_UPPERIOD_RET] = function()
			log("get BABY_SC_UPPERIOD_RET")
			self.data.periodLevel = buff:popChar()
			self.data.periodprogress = buff:popInt()

			self:updateData()
		end
		,

		[BABY_SC_PROMOTOPERIOD_RET] = function()
			log("get BABY_SC_PROMOTOPERIOD_RET")
			self.data.periodprogress = buff:popInt()
			dump(self.data.periodprogress)
			self:updateData()
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return BabyLayer