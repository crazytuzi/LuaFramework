--[[
	文件名:HeroInfoLayer.lua
	描述：人物详细信息页面
	创建人：peiyaoqiang
	创建时间：2017.03.11
--]]
-- 人物技能特效表
require("hero.HeroEffectModel")

local HeroInfoLayer = class("HeroInfoLayer", function(params)
    return display.newLayer()
end)

local OperateBtnTag = {
	eHeroLvUp = ModuleSub.eHeroLvUp, 				-- 人物升级
    eHeroStepUp = ModuleSub.eHeroStepUp, 			-- 人物突破
    eHeroChoiceTalent = ModuleSub.eHeroChoiceTalent,-- 人物天赋
    eHeroReplace = 3, 								-- 更换人物
    eUnBattle = 4,									-- 卸下
}

--[[
-- 参数 params 中各项为：
	{
		heroId: 人物实例Id，如果不传入该参数，那么只展示一类的人物的信息
		heroModelId: 人物模型Id, 如果heroId 为有效值，该参数失效
		onlyViewInfo: 是否只查看人物信息，不需要升级、突破、更换等按钮操作, 默认为true
		isOtherPlayer: 是否在查看其他玩家的信息，默认为false
		playerName: 玩家的名字，用来替换主角名，在查看其他玩家的时候需要传该参数
		formationObj: 玩家的阵容数据，在查看其他玩家的时候需要传该参数
		slotIndex: 玩家的阵容里当前人物索引，在查看其他玩家的时候需要传该参数
	}
]]
function HeroInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	params = params or {}
	self.mOnlyViewInfo = params.onlyViewInfo ~= false
	self.mHeroId = params.heroId
	self.mPlayerName = params.playerName
	self.isOtherPlayer = params.isOtherPlayer or false

	if not self.isOtherPlayer and Utility.isEntityId(self.mHeroId) then
		self.mHeroItem = HeroObj:getHero(self.mHeroId)
		if self.mHeroItem then
			self.mIsShowDropWayBtn = false
			self.mHeroModelId = self.mHeroItem.ModelId
			-- 判断是否是上阵的人物,如果是上阵的人物，则需要缓存上阵的卡槽Id和阵容信息
			self.mInFormation, self.mIsMate, self.mShowSlotId = FormationObj:heroInFormation(self.mHeroId)
			self.mFormationObj = self.mInFormation and FormationObj or nil

			self.mHeroList = {}
			if self.mOnlyViewInfo or not self.mInFormation or self.mIsMate then
				table.insert(self.mHeroList, self.mHeroItem)
			else
				local slotInfos = FormationObj:getSlotInfos()
				for slotId, slotItem in ipairs(slotInfos) do
					if Utility.isEntityId(slotItem.HeroId) then
						table.insert(self.mHeroList, HeroObj:getHero(slotItem.HeroId))
					end
				end
			end
		else
			self.mHeroModelId = params.heroModelId or params.HeroModelId
			self.mOnlyViewInfo = true
		end
		self.mFashionModelId = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
		self.mFashionStep = FashionObj:getOneItemStep(self.mFashionModelId)
	elseif self.isOtherPlayer then
		self.mIsShowDropWayBtn = false
		self.mShowSlotId = params.slotIndex
		self.mFormationObj = params.formationObj
		self.mHeroItem = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId).Hero
		self.mInFormation = true

		local otherPlayerInfo = self.mFormationObj:getThisPlayerInfo()
		self.mHeroModelId = self.mHeroItem.ModelId
		self.mFashionModelId = otherPlayerInfo.FashionModelId
		self.mFashionStep = otherPlayerInfo.FashionStep or 0
	else
		local nQuality = HeroModel.items[params.heroModelId].quality
		self.mIsShowDropWayBtn = (Utility.getQualityColorLv(nQuality) >= 4)
		self.mHeroModelId = params.heroModelId
		self.mOnlyViewInfo = true
	end
	self.mHeroModel = clone(HeroModel.items[self.mHeroModelId])
	-- 操作按钮列表（升级、突破、更换）
	self.mOperateBtnList = {}

    -- 注册退出事件
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            -- 界面关闭时，关闭未播放完的音效
            if self.mCurrSoundId then
                MqAudio.stopEffect(self.mCurrSoundId)
            end
        end
    end)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function HeroInfoLayer:initUI()
	-- 背景图片
	local bgLayer = ui.newSprite("zr_18.jpg")
	bgLayer:setAnchorPoint(cc.p(0.5, 1))
	bgLayer:setPosition(320, 1136)
	self.mParentLayer:addChild(bgLayer)	

	-- 获取途径按钮
	self.mGetWayBtn = ui.newButton({
		normalImage = "tb_34.png",
		clickAction = function()
			local illusionModelId = self.mHeroItem and self.mHeroItem.IllusionModelId and self.mHeroItem.IllusionModelId ~= 0 and self.mHeroItem.IllusionModelId or nil
			LayerManager.addLayer({
	            name = "hero.DropWayLayer",
	            data = {
	                resourceTypeSub = illusionModelId and ResourcetypeSub.eIllusion or ResourcetypeSub.eHero,
	                modelId = illusionModelId or self.mHeroModelId,
	            },
	            cleanUp = false,
	        })
		end
	})
	self.mGetWayBtn:setPosition(550, 610)
	self.mParentLayer:addChild(self.mGetWayBtn, 1)
	self.mGetWayBtn:setVisible(false)

	-- 幻化于XX
	self.mHintLabel = ui.newLabel({
			text = "",
			color = cc.c3b(0xff, 0xfb, 0xde),
            outlineColor = cc.c3b(0x37, 0x30, 0x2c),
            size = 24,
		})
	self.mHintLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mHintLabel:setPosition(10, 590)
    self.mParentLayer:addChild(self.mHintLabel, 1)

	-- 创建人物信息部分
	self:createFigureInfo()
	-- 创建人物详细信息部分
	self:createHeroDetail()
	-- 创建操作按钮
	self:createOptBtn()

	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(self.mCloseBtn)

	-- 紫色和紫色以上的人物需要显示获取途径按钮
	if (self.mHeroModel.specialType == Enums.HeroType.eNormalHero) and Utility.getQualityColorLv(self.mHeroModel.quality) >= 4 then
		self.mGetWayBtn:setVisible(true)
	end

	-- 刷新页面
	self:refreshLayer()
end

-- 获取恢复数据
function HeroInfoLayer:getRestoreData()
	local retData = {
		heroId = self.mHeroId,
		heroModelId = self.mHeroModelId,
		onlyViewInfo = self.mOnlyViewInfo,
	}

	return retData
end

-- 创建人物信息部分(包括战力、等级、星级、....)
function HeroInfoLayer:createFigureInfo()
	-- 如果是阵容卡槽人物，则需要创建一个列表
	if self.mInFormation and not self.mIsMate and not self.mOnlyViewInfo then
		-- 创建人物形象列表
		self.mFigureView = require("team.teamSubView.TeamFigureView"):create({
	    	viewSize = cc.size(640, 500),
	        showSlotId = self.mShowSlotId,
	        viewEmptySlot = false,
	        formationObj = self.mFormationObj,
	    	figureScale = 0.25,
			onSelectChange = function(slotIndex)
				self.mShowSlotId = slotIndex
				
				local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
				self.mHeroId = slotInfo.HeroId
				self.mHeroItem = HeroObj:getHero(slotInfo.HeroId)
				self.mHeroModelId = slotInfo.ModelId
				self.mHeroModel = clone(HeroModel.items[self.mHeroModelId])

				-- 刷新页面
				self:refreshLayer()

				if self.mHeroModel.specialType == Enums.HeroType.eNormalHero and Utility.getQualityColorLv(self.mHeroModel.quality) >= 4 then
					self.mGetWayBtn:setVisible(true)
				else
					self.mGetWayBtn:setVisible(false)
				end
			end,
		})
		self.mFigureView:setAnchorPoint(cc.p(0.5, 1))
		self.mFigureView:setPosition(320, 1080)
		self.mParentLayer:addChild(self.mFigureView)

		-- 左箭头
		local leftSprite = ui.newSprite("c_26.png")
		leftSprite:setPosition(20, 840)
		leftSprite:setScaleX(-1)
		self.mParentLayer:addChild(leftSprite)
		-- 右箭头
		local rightSprite = ui.newSprite("c_26.png")
		rightSprite:setPosition(620, 840)
		self.mParentLayer:addChild(rightSprite)
	else
	-- 图鉴进入
		-- 创建人物
		local curHero = Figure.newHero({
        	parent = self.mParentLayer, 
        	heroModelID = self.mHeroModelId,
        	fashionModelID = self.mFashionModelId,
        	IllusionModelId = self.mHeroItem and self.mHeroItem.IllusionModelId,
    		position = cc.p(150, 670),  
    		scale = 0.2,
    		needRace = true,
    	})
    	-- 播放技能
    	Utility.performWithDelay(self.mParentLayer, function()
			-- 随机播放技能（0是怒击，1是普攻）
	    	local randNum = math.random(0, 1)
	    	local action = randNum == 0 and "nuji" or "pugong"
    		-- 怒击和待机混合动作
			-- SkeletonAnimation.mix({
			--     skeleton      = curHero,
			--     fromAnimation = action,
			--     toAnimation   = "daiji",
			--     duration      = 1,
			-- })
    		SkeletonAnimation.action({
    		    skeleton         = curHero,
    		    action           = action,
    		    completeListener = function(p)
    		        -- p.self:setToSetupPose()
    		        -- 返回待机动作
    		        SkeletonAnimation.action({
    		        	skeleton = curHero,
    		        	action = "daiji",
    		        	loop = true,
    		        })
    		    end,
    		    endListener = function()
    		    	local moveHero = cc.MoveTo:create(0.5, cc.p(320, 670))
    		    	curHero:runAction(moveHero)
    		    end,
    		})

	    	-- 播放技能特效(有幻化将的时候播放幻化将技能)
	    	self:playHeroEffect(randNum)
	    end,0.1)
    	if (self.mIsShowDropWayBtn ~= nil) then
    		self.mGetWayBtn:setVisible(self.mIsShowDropWayBtn)
    	end
    	-- 主角人物不显示获取途径
        local heroModel = HeroModel.items[self.mHeroModelId]
    	if heroModel.specialType == Enums.HeroType.eMainHero then
    		self.mGetWayBtn:setVisible(false)
    	end
        -- 播放人物音效
        local illusionModel = self.mHeroItem and self.mHeroItem.IllusionModelId and IllusionModel.items[self.mHeroItem.IllusionModelId]
        local _, staySound = Utility.getHeroSound(illusionModel or heroModel)
        local audioFile = Utility.randomStayAudio(staySound)
        self.mCurrSoundId = MqAudio.playEffect(audioFile)
	end

	-- 只有上阵主将才显示战力信息
	if self.mInFormation and not self.mIsMate then
		self.FAPBgSprite = ui.newFAPView("")
		self.FAPBgSprite:setPosition(320, 610)
		self.mParentLayer:addChild(self.FAPBgSprite)
	end

	-- 显示人物的名字和星级
	_, _, self.mNameLabel = Figure.newNameAndStar({
		parent = self.mParentLayer,
		position = cc.p(320, 1150),
		})
end

-- 播放人物技能特效
-- skillId 	0是怒击，1是普攻
function HeroInfoLayer:playHeroEffect(skillId)
	-- 获取人物技能数据
	local heroModelId = self.mHeroItem and self.mHeroItem.IllusionModelId and self.mHeroItem.IllusionModelId ~= 0 and self.mHeroItem.IllusionModelId or self.mHeroModelId
	local heroSkillData = HeroEffectModel[heroModelId]
	if not heroSkillData then return end
	-- 获取对应技能特效数据
	local skillEffect = heroSkillData[skillId]
	if not skillEffect then return end
	-- 是否延时播放
	if not skillEffect.delayTime then
		ui.newEffect({
			parent = self.mParentLayer,
			zorder = skillEffect.zorder,
			effectName = skillEffect.effectName,
			position = skillEffect.position,
			scale = skillEffect.scale,
			loop = skillEffect.loop,
			animation = skillEffect.animation,
			endRelease = skillEffect.endRelease,
			endListener = skillEffect.endListener
		})
	else
		Utility.performWithDelay(self.mParentLayer, function()
    		ui.newEffect({
			parent = self.mParentLayer,
			zorder = skillEffect.zorder,
			effectName = skillEffect.effectName,
			position = skillEffect.position,
			scale = skillEffect.scale,
			loop = skillEffect.loop,
			animation = skillEffect.animation,
			endRelease = skillEffect.endRelease,
			endListener = skillEffect.endListener
		})
    	end, skillEffect.delayTime)
	end
end

-- 创建人物详细信息部分
function HeroInfoLayer:createHeroDetail()
	-- 详细信息的背景
	local tempSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 578))
	tempSprite:setPosition(320, 0)
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mParentLayer:addChild(tempSprite)

	local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, self.mOnlyViewInfo and 520 or 460))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 535)
    self.mParentLayer:addChild(tmpGraySprite)

	-- 详细信息滑动部分
    self.mDetailView = ccui.ScrollView:create()
    self.mDetailView:setContentSize(cc.size(640, self.mOnlyViewInfo and 510 or 450))
    self.mDetailView:setDirection(ccui.ScrollViewDir.vertical)
    self.mDetailView:setAnchorPoint(cc.p(0.5, 1))
    self.mDetailView:setPosition(320, 530)
    self.mParentLayer:addChild(self.mDetailView)
    -- 详细信息真正的parent
    self.mDetailParent = ccui.Layout:create()
    self.mDetailView:addChild(self.mDetailParent)

  	-- 刷新人物的详细信息
  	self:refreshDetail()
end

-- 创建操作按钮
function HeroInfoLayer:createOptBtn()
	-- 如果知识查看信息，则不需要操作按钮
	if self.mOnlyViewInfo then
		return
	end

	local btnInfos = {}
	if self.mIsMate then -- 江湖后援团
		table.insert(btnInfos, {
	        text = TR("卸下"),
            operateBtnTag = OperateBtnTag.eUnBattle,
            clickAction = function()
            	self:requestMateinfoCombat()
            end
	    })
	else
		table.insert(btnInfos, {
	        text = TR("升级"),
            operateBtnTag = OperateBtnTag.eHeroLvUp,
            clickAction = function()
            	local tempLayer = LayerManager.showSubModule(ModuleSub.eHeroLvUp, {
			        heroesData = self.mHeroList or {},
			        originalTag = ModuleSub.eHeroLvUp, 
			        originalId = self.mHeroId,
			    })
			    if tempLayer then
			    	LayerManager.deleteStackItem("hero.HeroInfoLayer")
			    end
            end
	    })
	    table.insert(btnInfos, {
	        text = TR("突破"),
            operateBtnTag = OperateBtnTag.eHeroStepUp,
            clickAction = function()
            	local tempLayer = LayerManager.showSubModule(ModuleSub.eHeroStepUp, {
			        heroesData = self.mHeroList or {},
			        originalTag = ModuleSub.eHeroStepUp, 
			        originalId = self.mHeroId,
			    })
			    if tempLayer then
			    	LayerManager.deleteStackItem("hero.HeroInfoLayer")
			    end
            end
	    })
	end
	table.insert(btnInfos, {
        text = TR("更换"),
        operateBtnTag = OperateBtnTag.eHeroReplace,
        clickAction = function()
            local tempLayer = LayerManager.addLayer({name = "team.TeamSelectHeroLayer", 
            	data = {
            		slotId = self.mShowSlotId,
            		isMateSlot = self.mIsMate,
            		alwaysIdList = {}, 
            	},
            })
            if tempLayer then
            	LayerManager.deleteStackItem("hero.HeroInfoLayer")
            end
        end
    })
    
	local btnStartPosX = 320 - (#btnInfos - 1) / 2 * 160
    for index, item in ipairs(btnInfos) do
        item.normalImage = "c_28.png"
        item.position = cc.p(btnStartPosX + (index - 1) * 160, 40)
        
        local tempBtn = ui.newButton(item)
        self.mParentLayer:addChild(tempBtn)

        -- 添加到操作按钮列表
        if item.operateBtnTag then
            self.mOperateBtnList[item.operateBtnTag] = tempBtn
        end

        if item.operateBtnTag == OperateBtnTag.eHeroStepUp then -- 突破按钮
            -- 小红点
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eHeroStepUp, nil, self.mShowSlotId))
            end
            local eventNames = {EventsName.eSlotRedDotPrefix .. tostring(self.mShowSlotId)}
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempBtn})
        end
    end
end

-- 创建显示羁绊描述的label
function HeroInfoLayer:createPrLabels()
	local prInfo
	if self.mHeroItem then
		prInfo = not self.isOtherPlayer and FormationObj:getHeroPrInfo(self.mHeroItem.Id)
			or self.mFormationObj:getSlotPrInfo(self.mShowSlotId)
	else
		prInfo = FormationObj:getHeroPrInfoByModelId(self.mHeroModelId)
	end

	local labelHeight = 0
	local nameList, introList = {}, {}
	for _, item in ipairs(prInfo or {}) do
		local currColor = item.havePr and Enums.Color.ePrColor or Enums.Color.eNotPrColor
		local currColorH = item.havePr and Enums.Color.ePrColorH or Enums.Color.eNotPrColorH

		local tempLabel = ui.newLabel({
			text = item.prName,
			color = currColor,
			align = cc.TEXT_ALIGNMENT_LEFT,
        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		})
		tempLabel:setAnchorPoint(cc.p(0, 1))
		table.insert(nameList, tempLabel)

		--
		local strText = ""
		for _,v in ipairs(string.splitBySep(item.prIntro, Enums.Color.ePrColorH)) do
			strText = strText .. currColorH .. v
		end
		local tempLabel = ui.newLabel({
			text = strText,
			color = currColor,
			align = cc.TEXT_ALIGNMENT_LEFT,
        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        	dimensions = cc.size(440, 0)
		})
		tempLabel:setAnchorPoint(cc.p(0, 1))

		table.insert(introList, tempLabel)
		labelHeight = labelHeight + tempLabel:getContentSize().height
	end

	return nameList, introList, labelHeight
end

-- 创建显示天赋突破的label
function HeroInfoLayer:createHeroTalLabel(illusionModelId)
	local heroTals = table.values(illusionModelId and IllusionTalRelation.items[illusionModelId] or HeroTalRelation.items[self.mHeroModelId] or {})
	table.sort(heroTals, function(item1, item2)
		return item1.step < item2.step
	end)

	local heroStep = self.mHeroItem and self.mHeroItem.Step or 0
	local labelHeight = 0
	local nameList, introList = {}, {}
	for index, item in ipairs(heroTals or {}) do
		local tempColor = heroStep < item.step and Enums.Color.eNotPrColor or Enums.Color.ePrColor
		local tempLabel = ui.newLabel({
			text = item.TALName,
			color = tempColor,
			align = cc.TEXT_ALIGNMENT_LEFT,
        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		})
		tempLabel:setAnchorPoint(cc.p(0, 1))
		table.insert(nameList, tempLabel)

		local tempText = TR("尚未选择天赋")
		if (item.TALModelID == nil) or (item.TALModelID == 0) then
			-- 自选天赋
			local stepTalentId = HeroObj:getTalentIdByStep(self.mHeroItem.Id, item.step)
			if (stepTalentId ~= nil) and (stepTalentId > 0) then
				local tempTal = TalModel.items[stepTalentId] or {}
				tempText = tempTal.intro or " "
			end
		else
			local tempTal = TalModel.items[item.TALModelID] or {}
			tempText = tempTal.intro or " "
		end
		local tempLabel = ui.newLabel({
			text = tempText,
			color = tempColor,
			align = cc.TEXT_ALIGNMENT_LEFT,
        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        	dimensions = cc.size(440, 0)
		})
		tempLabel:setAnchorPoint(cc.p(0, 1))

		table.insert(introList, tempLabel)
		labelHeight = labelHeight + tempLabel:getContentSize().height
	end

	return nameList, introList, labelHeight
end

-- 刷新人物的详细信息
function HeroInfoLayer:refreshDetail()
	self.mDetailParent:removeAllChildren()
	local parentPosY = 0
    local splitSize = cc.size(600, 4)
    local function addBgSprite(tempBgSize, posY, titleText)
		return ui.newNodeBgWithTitle(self.mDetailParent, tempBgSize, titleText, cc.p(320, posY), cc.p(0.5, 1))
    end

    --------------------------------------------------------------------------------
	-- 创建人物的基础属性(等级、攻击、防御、血量、先手)
	local baseBgSize = cc.size(595, 122)
	local baseBgSprite = addBgSprite(baseBgSize, parentPosY, TR("基础属性"))
	local attrInfo = not self.isOtherPlayer and HeroObj:getHeroAttrInfo(self.mHeroItem and self.mHeroItem.Id, self.mHeroModelId) or self.mFormationObj:getSlotAttrInfo(self.mShowSlotId)
	local function addBaseAttrLabel(tmpViewItem, xIndex, yPos)
		local tempLabel = ui.newLabel({
			text = string.format("%s: %s%s", tmpViewItem.viewName, Enums.Color.eNormalGreenH, tmpViewItem.viewValue),
			color = cc.c3b(0x46, 0x22, 0x0d),
			align = cc.TEXT_ALIGNMENT_LEFT,
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		})
		tempLabel:setAnchorPoint(cc.p(0, 0.5))
		tempLabel:setPosition((xIndex - 1) * 165 + 20, yPos)
		baseBgSprite:addChild(tempLabel)
	end
	
	-- 资质、等级、先手
	for index, item in ipairs({"quality", "Lv", "FSP"}) do
		local viewItem = attrInfo[item] or {}
	    addBaseAttrLabel(viewItem, index, baseBgSize.height - 62)
	end
	-- 攻击、防御、血量
	for index, item in ipairs({"AP", "DEF", "HP"}) do
		local viewItem = attrInfo[item] 
		addBaseAttrLabel(viewItem, index, baseBgSize.height - 97)
	end
	parentPosY = parentPosY - baseBgSize.height - 5
	
	--------------------------------------------------------------------------------
	-- 技能描述(普通攻击和技能攻击)
	local NAID, RAID = HeroObj:getHeroAttackId(self.mHeroModelId, self.mHeroItem, self.mFashionModelId, self.mFashionStep)
	local naItem, raItem = AttackModel.items[NAID], AttackModel.items[RAID]
	local function addAttackLabel(strName, strIntro, isActive)
		local cColor, hColor = Enums.Color.ePrColor, Enums.Color.ePrColorH
		if (isActive ~= nil) and (isActive == false) then -- 没有激活
			cColor, hColor = Enums.Color.eNotPrColor, Enums.Color.eNotPrColorH
		end

		-- 重新构造显示字符串
		local attackList = string.splitBySep(strIntro, "#73430D")
		local attackText = string.format("【%s】 ", strName)
		for _,v in ipairs(attackList) do
			attackText = attackText .. hColor .. v
		end
		if (isActive ~= nil) and (isActive == false) then 
			-- 没有激活，处理一下字符串
			local attackText1 = ""
			local tmpList1 = string.splitBySep(attackText, "#249029")
			for _,v in ipairs(tmpList1) do
				attackText1 = attackText1 .. v
			end

			local attackText2 = ""
			local tmpList2 = string.splitBySep(attackText1, hColor)
			for _,v in ipairs(tmpList2) do
				attackText2 = attackText2 .. v
			end
			attackText = attackText2
		end

		-- 显示
		local attackLabel = ui.newLabel({
			text = attackText,
			color = cColor,
			align = cc.TEXT_ALIGNMENT_LEFT,
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	        dimensions = cc.size(500, 0)
		})
		attackLabel:setAnchorPoint(cc.p(0, 1))
		return attackLabel, attackLabel:getContentSize()
	end
	local naLabel, naLabelSize = addAttackLabel(naItem.name, naItem.intro)
	local raLabel, raLabelSize = addAttackLabel(raItem.name, raItem.intro)
	local uaLabel, uaLabelSize = nil, nil
    -- 如果是幻化将(暂时不显示合体技能)
    local jointModel = nil 
    if (not self.mHeroItem) then
    	-- 从图鉴进入
    	jointModel = HeroJointModel.items[self.mHeroModel.jointID]
    else
    	local illusionModel = IllusionModel.items[self.mHeroItem.IllusionModelId]
    	-- 有幻化
    	if illusionModel then
    		jointModel = HeroJointModel.items[illusionModel.jointID]
    	else
    		jointModel = HeroJointModel.items[self.mHeroModel.jointID]
    	end
    end
    if (jointModel ~= nil) then
		local uaItem = AttackModel.items[jointModel.jointSkillID]
		local mainHeroModel = HeroModel.items[jointModel.mainHeroID] or IllusionModel.items[jointModel.mainHeroID]
		local mainHeroName = mainHeroModel.name
		local aidHeroName = ""
		if (jointModel.aidHeroID == 0) then -- 副将为0表示主角
			aidHeroName = (self.mPlayerName ~= nil) and self.mPlayerName or ConfigFunc:getHeroName(FormationObj:getSlotInfoBySlotId(1).ModelId)
		else
			local aidHeroModel = HeroModel.items[jointModel.aidHeroID] or IllusionModel.items[jointModel.aidHeroID]
			aidHeroName = aidHeroModel.name
		end
		local extName = (self.mHeroModelId == jointModel.mainHeroID) and aidHeroName or mainHeroName
		if self.mHeroItem then
			extName = (self.mHeroModelId == jointModel.mainHeroID or self.mHeroItem.IllusionModelId == jointModel.mainHeroID) and aidHeroName or mainHeroName
		end
		local extStr = TR("【与%s%s%s出战可触发，由%s%s%s发动】", "#249029", extName, "#73430D", "#249029", mainHeroName, "#73430D")
		local isActive = (self.mFormationObj ~= nil) and self.mFormationObj:isHeroJointActive(jointModel.ID) or false
		uaLabel, uaLabelSize = addAttackLabel(uaItem.name, uaItem.intro .. "\n" .. extStr, isActive)
	end
	
	-- 技能属性的背景
	local attackBgSize = cc.size(595, naLabelSize.height + raLabelSize.height + 80)
	if (jointModel ~= nil) then
		attackBgSize = cc.size(595, naLabelSize.height + raLabelSize.height + uaLabelSize.height + 90)
	end
	local attackBgSprite = addBgSprite(attackBgSize, parentPosY, TR("技能属性"))
	local function addAttackImage(attackLabel, attackImg, posY)
		local tempSprite = ui.newSprite(attackImg)
		tempSprite:setAnchorPoint(cc.p(0, 1))
		tempSprite:setPosition(10, posY)
		attackBgSprite:addChild(tempSprite)
		-- 添加描述文字
		attackLabel:setPosition(60, posY)
		attackBgSprite:addChild(attackLabel)
	end
	addAttackImage(naLabel, "c_71.png", attackBgSize.height - 50)
	addAttackImage(raLabel, "c_70.png", attackBgSize.height - 50 - naLabelSize.height - 10)
	if (jointModel ~= nil) then
		addAttackImage(uaLabel, "c_146.png", attackBgSize.height - 50 - naLabelSize.height - 10 - raLabelSize.height - 10)
	end
	parentPosY = parentPosY - attackBgSize.height - 5

	--------------------------------------------------------------------------------
	-- 显示名称、介绍、属性等label
	local function setLabelPos(nameList, introList, title, bgSize)
		local tempBgSprite = addBgSprite(bgSize, parentPosY, title)
		local tempPosY = bgSize.height - 60
		for index = 1, #nameList do
			local nameLabel = nameList[index]
			nameLabel:setPosition(10, tempPosY)
			tempBgSprite:addChild(nameLabel)
			--
			local introLabel = introList[index]
			introLabel:setPosition(150, tempPosY)
			tempBgSprite:addChild(introLabel)

			tempPosY = tempPosY - introLabel:getContentSize().height - 10
		end
	end
	-- 羁绊属性
	local nameList, introList, labelHeight = self:createPrLabels()
	if next(nameList) then
		local prBgSize = cc.size(595, labelHeight + #introList * 10 + 75)
		setLabelPos(nameList, introList, TR("羁绊属性"), prBgSize)
		parentPosY = parentPosY - prBgSize.height - 5
	end
	-- 天赋突破
	local illusionModelId = self.mHeroItem and self.mHeroItem.IllusionModelId and self.mHeroItem.IllusionModelId ~= 0 and self.mHeroItem.IllusionModelId or nil
	local nameList, introList, labelHeight = self:createHeroTalLabel(illusionModelId)

	-- 获取从突破x到突破y的天赋字符串列表
	local function getStepTalList(x, y)
		local nameTable, introTable = {}, {}
		local labelHeight = 0
		for i = x, y do
			if not nameList[i] or not introList[i] then
				break
			end
			table.insert(nameTable, nameList[i])
			table.insert(introTable, introList[i])
			labelHeight = labelHeight + introList[i]:getContentSize().height
		end
		return nameTable, introTable, labelHeight
	end

	-- 创建突破页
	local function createTupoTab(startPos, endPos, title)
		local nameTable, introTable, labelHeight = getStepTalList(startPos, endPos)
		local talBgSize = cc.size(595, labelHeight + #introTable * 10 + 75)
		setLabelPos(nameTable, introTable, title, talBgSize)
		parentPosY = parentPosY - talBgSize.height - 5
	end

	if next(nameList) then
		local startStep, endStep = 1,0
		local curStep = self.mHeroItem and self.mHeroItem.Step or 0
		-- 主角要多一个有突破+1，其他角色没有
		if HeroModel.items[self.mHeroModelId].specialType == Enums.HeroType.eMainHero then
			endStep = endStep + 10
		else
			endStep = endStep + 9
		end
		-- 创建突破1-10
		if #nameList > 0 then
			createTupoTab(startStep, endStep, TR("天赋突破"))
		end

		-- 创建突破11-15
		if #nameList > 10 then
			startStep = endStep + 1
			endStep = endStep + 5
	        createTupoTab(startStep, endStep, TR("武尊"))
	    end

	    -- 创建突破16-20
	    if #nameList > 15 then
			startStep = endStep + 1
			endStep = endStep + 5
	        createTupoTab(startStep, endStep, TR("武圣"))
	    end

	    -- 创建突破21-25
	    if #nameList > 20 then
			startStep = endStep + 1
			endStep = endStep + 5
	        createTupoTab(startStep, endStep, TR("无极"))
	    end
	end

	--------------------------------------------------------------------------------
	-- 人物简介
    local introText = self.mHeroModel.intro
    if self.mHeroItem and (self.mHeroItem.IllusionModelId and self.mHeroItem.IllusionModelId > 0) then 
        introText = IllusionModel.items[self.mHeroItem.IllusionModelId].intro
    end 
	local introLabel = ui.newLabel({
		text = introText,
		color = cc.c3b(0x46, 0x22, 0x0d),
		align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(570, 0)
	})

	local introBgSize = cc.size(595, introLabel:getContentSize().height + 87)
	local introBgSprite = addBgSprite(introBgSize, parentPosY, TR("侠客简介"))

	introLabel:setAnchorPoint(cc.p(0.5, 1))
	introLabel:setPosition(introBgSize.width / 2, introBgSize.height - 55)
	introBgSprite:addChild(introLabel)
	parentPosY = parentPosY - introBgSize.height - 10
	
	--------------------------------------------------------------------------------
	local tempSize = self.mDetailView:getContentSize()
	local tempHeight = math.max(tempSize.height, math.abs(parentPosY))
	self.mDetailParent:setPosition(0, tempHeight)
	self.mDetailView:setInnerContainerSize(cc.size(tempSize.width, tempHeight))
    self.mDetailView:jumpToTop()
end

-- 刷新页面
function HeroInfoLayer:refreshLayer()
	-- 刷新人物等级、名字、进阶
	local nameStr, tempStep = ConfigFunc:getHeroName(self.mHeroModelId, {
		heroStep = (self.mHeroItem and self.mHeroItem.Step or 0), 
		IllusionModelId = (self.mHeroItem and self.mHeroItem.IllusionModelId or 0),
        heroFashionId = self.mHeroItem and self.mHeroItem.CombatFashionOrder,
		playerName = self.mPlayerName})
	local lvStr = self.mHeroItem and TR("等级%d ", self.mHeroItem.Lv) or ""
	local stepStr = (tempStep > 0) and string.format("%+d", tempStep) or ""
	self.mNameLabel:setString(string.format("%s %s%s%s %s", lvStr, Utility.getQualityColor(self.mHeroModel.quality, 2), nameStr, Enums.Color.eYellowH, stepStr))
	
	-- 刷新战力
	if self.FAPBgSprite and self.mInFormation then
		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
		self.FAPBgSprite.setFAP(slotInfo.Property.FAP)
	end

	-- 刷新人物的详细信息
	self:refreshDetail()

	-- 显示操作按钮的显示状态
	if not self.mIsMate then
		self:refreshOperateBtnPosX()
	end

	-- 显示幻化于
	if self.mHeroItem and self.mHeroItem.IllusionModelId and self.mHeroItem.IllusionModelId ~= 0 then
		self.mHintLabel:setVisible(true)
		local heroBase = HeroModel.items[self.mHeroItem.ModelId]
		self.mHintLabel:setString(TR("幻化于%s%s", Utility.getQualityColor(heroBase.quality, 2), heroBase.name))
	else
		self.mHintLabel:setVisible(false)
	end
end

-- 刷新操作按钮的位置
function HeroInfoLayer:refreshOperateBtnPosX()
	local showTagList = {}
	if (self.mShowSlotId == 1) then
		-- 主角显示：突破、天赋
		--showTagList = {OperateBtnTag.eHeroStepUp, OperateBtnTag.eHeroChoiceTalent}
		showTagList = {OperateBtnTag.eHeroStepUp}
	else
		-- 其他人显示：升级、突破、更换
		showTagList = {OperateBtnTag.eHeroLvUp, OperateBtnTag.eHeroStepUp, OperateBtnTag.eHeroReplace}
	end
	for _, btnObj in pairs(self.mOperateBtnList) do
		btnObj:setVisible(false)
	end

	-- 刷新显示按钮的位置
	local btnStartPosX = 320 - (#showTagList - 1) / 2 * 160
	for index,btnTag in ipairs(showTagList) do
		local btnObj = self.mOperateBtnList[btnTag]
		if (btnObj ~= nil) then
			btnObj:setPositionX(btnStartPosX + (index - 1) * 160)
			btnObj:setVisible(true)
		end
	end
end

-- ============== 服务器数据请求相关接口 ============================

-- 卸下江湖后援团
function HeroInfoLayer:requestMateinfoCombat()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "MateinfoCombat",
        svrMethodData = {self.mShowSlotId, EMPTY_ENTITY_ID},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then --
                return
            end

            -- 更新江湖后援团卡槽信息
            FormationObj:updateMateInfos(response.Value.MateInfo)
            LayerManager.removeLayer(self)
        end,
    })
end

return HeroInfoLayer
