--[[
    文件名: HeroNeiliHomeLayer.lua
	描述: 人物内功主页面
	创建人: yanghongsheng
	创建时间: 2018.6.22
--]]

local HeroNeiliHomeLayer = class("HeroNeiliHomeLayer", function()
    return display.newLayer()
end)

--[[
	params:
		heroId 		角色实例id
]]

function HeroNeiliHomeLayer:ctor(params)
    -- 传入参数
    self.mHeroId = params.heroId

    -- 角色索引，数量
    if not self.mHeroId or not Utility.isEntityId(self.mHeroId) then
    	self.mHeroIndex = 1
    	self.mHeroId = FormationObj:getSlotInfoBySlotId(self.mHeroIndex).HeroId
    	self.mHeroNum = 6
    else
    	self.mHeroIndex = self:getCurrSlotId(self.mHeroId)
    	if self.mHeroIndex then
    		self.mHeroNum = 6
    	else
    		self.mHeroIndex = 1
    		self.mHeroNum = 1
    	end
    end
    
    -- 获取人物信息
    self.mHeroInfo = HeroObj:getHero(self.mHeroId)
    -- 当前内力类型
    self.mNeiliId = 1
    -- 内力等级字符列表
    self.mLvLabelList = {}
    -- 每重总阶数
	self.totalStep = 10
	-- 每种内力最大重数
	self.totalFloor = 10

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eHeroExp,
        }
    })
    self:addChild(topResource, 1)
    self.mCommonLayer_ = topResource

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    
    -- 初始化页面
    self:initUI()

    -- 刷新界面
    self:refreshUI()
    -- 检查当前重数buff是否一至
    self:UpSkillSelectBox()
end

-- 获取当前人物所在的卡槽ID
function HeroNeiliHomeLayer:getCurrSlotId(heroId)
    local retSlotId = nil
    for i=1,6 do
        local slotInfo = FormationObj:getSlotInfoBySlotId(i)
        if (slotInfo ~= nil) and (slotInfo.HeroId ~= nil) and (slotInfo.HeroId == heroId) then
            retSlotId = i
            break
        end
    end
    
    return retSlotId
end

function HeroNeiliHomeLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("zr_18.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)
	-- 操作面板
	local sprite = ui.newScale9Sprite("c_19.png", cc.size(640, 560))
	sprite:setAnchorPoint(0.5, 0)
	sprite:setPosition(320, 0)
	self.mParentLayer:addChild(sprite)
	-- 提示文字
	local hintLabel = ui.newLabel({
			text = TR("三种内力都升到同一重后可以提升融合重数，激活相应融合技"),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	hintLabel:setAnchorPoint(cc.p(0, 0))
	hintLabel:setPosition(15, 500)
	sprite:addChild(hintLabel)
	-- 退出按钮
	local btnClose = ui.newButton({
	    normalImage = "c_29.png",
	    anchorPoint = cc.p(0.5, 0.5),
	    position = Enums.StardardRootPos.eCloseBtn,
	    clickAction = function()
	        LayerManager.removeLayer(self)
	    end
	})
	self.mParentLayer:addChild(btnClose, 5)
	-- 规则按钮
	local btnRule = ui.newButton({
	    normalImage = "c_72.png",
	    anchorPoint = cc.p(0.5, 0.5),
	    position = cc.p(50, 1040),
	    clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.70级开启内力系统"),
                TR("2.每个角色都有阴、阳、邪三种内力，每种都可以进行升阶和升重"),
                TR("3.内力升到十阶后可升重，升重可以解锁或提升内力技能"),
                TR("4.当三种内力都升到某一重时，可以提升内力融合重数，解锁对应融合技"),
        	})
	    end
	})
	self.mParentLayer:addChild(btnRule, 5)

	-- 创建人物名字
    local nameNode, _, nameLabel = Figure.newNameAndStar({
        parent = self.mParentLayer,
        position = cc.p(320, 1120),
        })
    nameNode:setLocalZOrder(5)
    self.mNameNode = nameNode

    -- 名字刷新接口
    nameNode.nameLabel = nameLabel
    nameNode.refreshName = function (target, newHeroData)
        target.nameLabel:setString("")
        if (newHeroData == nil) then
            return
        end

        -- 构造名字
        local newHeroBase = HeroModel.items[newHeroData.ModelId]
        local strName, tempStep = ConfigFunc:getHeroName(newHeroData.ModelId, {heroStep = newHeroData.Step, IllusionModelId = newHeroData.IllusionModelId, heroFashionId = newHeroData.CombatFashionOrder})
        local text = TR("等级") .. newHeroData.Lv .. "  " .. Utility.getQualityColor(newHeroBase.quality, 2) .. strName
        if (tempStep > 0) then
            text = text .. " " .. Enums.Color.eYellowH .. "+" .. tempStep
        end
        target.nameLabel:setString(text)

    end
    nameNode:refreshName(self.mHeroInfo)

    -- 显示人物
    self:refreshHeroFigure()

    -- 显示内力融合层数
    local neiliHarmonySprite = ui.newSprite("nl_22.png")
    neiliHarmonySprite:setPosition(186, 957)
    self.mParentLayer:addChild(neiliHarmonySprite)
    local harmonyNum = self.mHeroInfo.HeroNeiliHarmonyInfo.Floor or 0
    self.mHarmonyNumLabel = ui.newNumberLabel({
    		text = harmonyNum,
    		imgFile = "nl_17.png",
    		charCount = 11,
    	})
    self.mHarmonyNumLabel:setPosition(20, 100)
    neiliHarmonySprite:addChild(self.mHarmonyNumLabel)

    -- 显示内力球椭圆旋转
    self:createEllipseLayer3D()
    -- 重生按钮
    local rebirthBtn = ui.newButton({
        normalImage = "tb_212.png",
        position = cc.p(390, 610),
        clickAction = function()        	
        	if not self.mHeroInfo.HeroNeiliInfo or not next(self.mHeroInfo.HeroNeiliInfo) then		-- 没提升过内力
        		ui.showFlashView({text = TR("还没有运气提升过内力")})
        	else
        		-- 元宝是否充足
        		local useDiamond = 200
        		if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, useDiamond) then 
        			return 
        		end
        		-- 返还弹窗
        		local rebirthResList = self:getRebirthRes(self.mHeroInfo) -- 获取返还资源
        		self.rebirthMsgBox = MsgBoxLayer.addPreviewDropLayer(
        			rebirthResList, TR("是否花费{db_1111.png}%d返还以下物品？",useDiamond), TR("重生"),
        			{
        				{
        					text = TR("确定"),
        					clickAction = function ()
        						self:requestRebirth(self.mHeroId)
        						LayerManager.removeLayer(self.rebirthMsgBox)
        					end,
        				},
        				{
        					text = TR("取消"),
        				},
        			},
        			{}
        		)
        	end
        end
    })
    self.mParentLayer:addChild(rebirthBtn, 5)
    -- 冥想选择按钮
    local mingXiangBtn = ui.newButton({
        normalImage = "nl_26.png",
        position = cc.p(490, 610),
        clickAction = function()
	        LayerManager.addLayer({
	        		name = "hero.MeditationLayer",
	        	})
        end
    })
    self.mParentLayer:addChild(mingXiangBtn, 5)
    -- 融合技选择按钮
    local btnRonghe = ui.newButton({
        normalImage = "nl_25.png",
        position = cc.p(590, 610),
        clickAction = function()
        LayerManager.addLayer({
        		name = "hero.HeroNeiliHarmonyDlgLayer",
        		data = {
        			heroId = self.mHeroId,
        			callback = function ()
        				local slotInfo = FormationObj:getSlotInfoBySlotId(self.mHeroIndex)
        				self.mHeroId = slotInfo.HeroId
        				self.mHeroInfo = HeroObj:getHero(slotInfo.HeroId)
        				local harmonyFloor = self.mHeroInfo.HeroNeiliHarmonyInfo.Floor or 0
						self.mHarmonyNumLabel:setString(harmonyFloor)
        			end,
        		},
        		cleanUp = false,
        	})
        end
    })
    self.mParentLayer:addChild(btnRonghe, 5)
    -- 升阶按钮
    self.mLvUpBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("运气"),
		clickAction = function ()
			self:requestLvUp()
		end,
	})
    self.mLvUpBtn:setPosition(320, 140)
    self.mParentLayer:addChild(self.mLvUpBtn, 5)

    -- 上一个
    local lastBtn = ui.newButton({
		normalImage = "bpz_46.png",
		clickAction = function ()
			if self.mHeroIndex - 1 > 0 then
				local slotInfo = FormationObj:getSlotInfoBySlotId(self.mHeroIndex - 1)
				-- 获取人物信息
				if slotInfo then
					self.mHeroIndex = self.mHeroIndex - 1
					self.mHeroId = slotInfo.HeroId
					self.mHeroInfo = HeroObj:getHero(slotInfo.HeroId)
					self:refreshHeroUI()
				end
			else
				return
			end
		end,
	})
    lastBtn:setPosition(80, 900)
    self.mParentLayer:addChild(lastBtn, 5)

    -- 下一个
    local nextBtn = ui.newButton({
		normalImage = "bpz_45.png",
		clickAction = function ()
			if self.mHeroIndex + 1 <= self.mHeroNum then
				local slotInfo = FormationObj:getSlotInfoBySlotId(self.mHeroIndex + 1)
				-- 获取人物信息
				if slotInfo then
					self.mHeroIndex = self.mHeroIndex + 1
					self.mHeroId = slotInfo.HeroId
					self.mHeroInfo = HeroObj:getHero(slotInfo.HeroId)
					self:refreshHeroUI()
				end
			else
				return
			end
		end,
	})
    nextBtn:setPosition(560, 900)
    self.mParentLayer:addChild(nextBtn, 5)
end

-- 创建内力球椭圆旋转
function HeroNeiliHomeLayer:createEllipseLayer3D()
	self._ellipseLayer = require("common.EllipseLayer3D").new({
	    longAxias = 300,
	    shortAxias = 200,
	    fixAngle = 90,
	    totalItemNum = 3,
	    itemContentCallback = function(parent, index)
	        self:createOneNeili(parent, index)
	    end,
	    alignCallback = function (index)
	    	-- 更新内力id
	    	self.mNeiliId = NeiliTypeModel.items[index].ID
	    	-- 更新内力属性显示
	        self:refreshNeiliShow()
	        -- 更新资源消耗
	        self:refreshUseRes()
	        -- 检查当前重数buff是否一至
            self:UpSkillSelectBox()
	    end
	})
	self._ellipseLayer:setPosition(cc.p(320, 800))
	self.mParentLayer:addChild(self._ellipseLayer, 1)

	-- 添加触摸事件
	self:setTouch()
end

-- 创建一个内力球
function HeroNeiliHomeLayer:createOneNeili(parent, index)
	-- 内力球特效列表
	local neiliEffectList = {
		"effect_ui_neili_lanqiu",
		"effect_ui_neili_hongqiu",
		"effect_ui_neili_huangqiu",
	}
	-- 内力名列表
	local neiliNameList = {
		"nl_11.png",
		"nl_12.png",
		"nl_13.png",
	}
	local typeId = NeiliTypeModel.items[index].ID
	-- 创建特效球
	local effect = ui.newEffect({
			parent = parent,
			effectName = neiliEffectList[typeId],
			loop = true,
		})
	-- 创建特性名
	local neiliName = ui.newSprite(neiliNameList[typeId])
	neiliName:setPosition(0, -50)
	effect:addChild(neiliName)
	-- 创建等级显示
	local lv = self.mHeroInfo.HeroNeiliInfo[tostring(typeId)] and self.mHeroInfo.HeroNeiliInfo[tostring(typeId)].Lv or 0
	local floor = self.mHeroInfo.HeroNeiliInfo[tostring(typeId)] and self.mHeroInfo.HeroNeiliInfo[tostring(typeId)].Floor or 0
	local neiliLvLabel = ui.newLabel({
			text = TR("%s重%s阶", self.getChineseNumber(floor), self.getChineseNumber(lv)),
			outlineColor = Enums.Color.eOutlineColor,
		})
	effect:addChild(neiliLvLabel)
	-- 刷新函数
	neiliLvLabel.refreshLv = function(target)
		local lv = self.mHeroInfo.HeroNeiliInfo[tostring(typeId)] and self.mHeroInfo.HeroNeiliInfo[tostring(typeId)].Lv or 0
		local floor = self.mHeroInfo.HeroNeiliInfo[tostring(typeId)] and self.mHeroInfo.HeroNeiliInfo[tostring(typeId)].Floor or 0
		target:setString(TR("%s重%s", self.getChineseNumber(floor), floor < self.totalFloor and self.getChineseNumber(lv)..TR("阶") or ""))
	end
	neiliLvLabel:refreshLv()
	self.mLvLabelList[typeId] = neiliLvLabel
end

-- 获取中文个位数
function HeroNeiliHomeLayer.getChineseNumber(num)
	local chineseNumList = {
		[0] = TR("零"),
		[1] = TR("一"),
		[2] = TR("二"),
		[3] = TR("三"),
		[4] = TR("四"),
		[5] = TR("五"),
		[6] = TR("六"),
		[7] = TR("七"),
		[8] = TR("八"),
		[9] = TR("九"),
		[10] = TR("十"),
	}

	return chineseNumList[num]
end

-- 根据技能id获取技能图片
function HeroNeiliHomeLayer:getSkillPic(skillTalId)
	local skillPicList = {
		{
			tal1 = "nl_31.png",
			tal2 = "nl_33.png",
			tal3 = "nl_32.png",
		},
		{
			tal1 = "nl_34.png",
			tal2 = "nl_35.png",
			tal3 = "nl_36.png",
		},
		{
			tal1 = "nl_37.png",
			tal2 = "nl_38.png",
			tal3 = "nl_39.png",
		},
	}

	local neiliType, floor, talKey = self.getSkillFloorKey(skillTalId)

	return skillPicList[neiliType][talKey]
end

-- 根据技能id获取技能所在内力类型，重数，天赋键值
function HeroNeiliHomeLayer.getSkillFloorKey(skillTalId)
	if not skillTalId or skillTalId == 0 then return end

	for _, neiliModel in pairs(NeiliFloorModel.items) do
		for _, floorModel in pairs(neiliModel) do
			for key, value in pairs(floorModel) do
				if skillTalId == value then
					return floorModel.neiliTypeId, floorModel.floor, key
				end
			end
		end
	end
end

-- 设置触摸事件
function HeroNeiliHomeLayer:setTouch()
    local startPosX, prevPosX = 0, 0
    local isMove = false
    local moveRight = true
    -- local diffX = 0
    local prev = {x = 0, y = 0}
    local start = {x = 0, y = 0}

    -- 触摸开始函数
    local function touchBegin(touch, event)
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y

        start.x = touch:getLocation().x
        start.y = touch:getLocation().y

        return true
    end

    -- 触摸中函数
    local function touchMoved(touch, event)
        local diffX = touch:getLocation().x - prev.x
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y
        if diffX > 0 then
            self._ellipseLayer:setRadiansOffset(-1)
        end
        if diffX < 0 then
            self._ellipseLayer:setRadiansOffset(1)
        end
    end

    -- 触摸结束函数
    local function touchEnd(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    local function onTouchCancel(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    -- 创建触摸层
    ui.registerSwallowTouch({
        node = self._ellipseLayer,
        allowTouch = false,
        beganEvent = touchBegin,
        movedEvent = touchMoved,
        endedEvent = touchEnd,
        cancellEvent = onTouchCancel,
    })
end

function HeroNeiliHomeLayer.getFloorPic(floor)
	-- 内力重数图片
	local FloorPicList = {
		"nl_01.png",
        "nl_02.png",
        "nl_03.png",
        "nl_04.png",
        "nl_05.png",
        "nl_06.png",
        "nl_07.png",
        "nl_08.png",
        "nl_09.png",
        "nl_10.png",
	}

	return FloorPicList[floor]
end

-- 选内力技弹窗
--[[
	isReset 	是否需要重选技能
]]
function HeroNeiliHomeLayer:selectSkillBox(isReset)
	-- 内力类型图
	local NeiliPicList = {
		"nl_27.png",
		"nl_29.png",
		"nl_28.png",
	}
	-- 内力类型火特效
	local NeiliEffectList = {
		"effect_ui_neili_yinhuo",
		"effect_ui_neili_yanghuo",
		"effect_ui_neili_xiehuo",
	}
	
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		-- 选择的技能id
		local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}
		local selectSkillTalId = isReset and 0 or (neiliInfo.TalModelId or 0)
		-- 内力图
		local neiliSprite = ui.newSprite(NeiliPicList[self.mNeiliId])
		neiliSprite:setPosition(bgSize.width*0.5, bgSize.height*0.62)
		bgSprite:addChild(neiliSprite)
		--火的特效
		ui.newEffect({
                parent = neiliSprite,
                effectName = NeiliEffectList[self.mNeiliId],
                position = cc.p(55, 75),
                loop = true,
            })
		-- 重数
		local floorSprite = ui.newSprite(self.getFloorPic(neiliInfo.Floor or 1))
		floorSprite:setPosition(100, bgSize.height-150)
		bgSprite:addChild(floorSprite)
		-- 提升
		local hintLabel = ui.newLabel({
				text = TR("请选择要使用的内力技能"),
				outlineColor = cc.c3b(0x46, 0x22, 0x0d),
				size = 24
			})
		hintLabel:setPosition(bgSize.width*0.5, 265)
		bgSprite:addChild(hintLabel)
		-- 描述背景
		local descSize = cc.size(580, 145)
		local descBg = ui.newScale9Sprite("c_65.png", descSize)
		descBg:setPosition(bgSize.width*0.5+5, 165)
		bgSprite:addChild(descBg)
		-- 刷新描述
		local function refreshSkillDesc(skillTalId)
			descBg:removeAllChildren()
			-- 技能图标
			local skillSprite = ui.newSprite(self:getSkillPic(skillTalId))
			skillSprite:setPosition(75, 70)
			descBg:addChild(skillSprite)
			-- 技能描述
			local skillDesc = ui.newLabel({
					text = TalModel.items[skillTalId].intro,
					color = cc.c3b(0x46, 0x22, 0x0d),
					dimensions = cc.size(270, 0)
				})
			skillDesc:setAnchorPoint(cc.p(0, 0.5))
			skillDesc:setPosition(150, descSize.height*0.5)
			descBg:addChild(skillDesc)
			-- 使用按钮
			local useBtn = ui.newButton({
					normalImage = "c_28.png",
					text = TR("使用"),
					clickAction = function ()
						if selectSkillTalId == 0 then
							ui.showFlashView(TR("请选择一种内力技能"))
							return
						end
						self:requestChoiceTal(selectSkillTalId)
						LayerManager.removeLayer(boxRoot)
					end
				})
			useBtn:setPosition(500, 70)
			descBg:addChild(useBtn)
		end
		-- 创建技能按钮
		local beforeSelSprite = nil
	    local function createSkillBtn(skillTalId, pos)
	    	-- 选择框
	    	local selectSprite = ui.newSprite("c_31.png")
	    	selectSprite:setPosition(pos)
	    	bgSprite:addChild(selectSprite)
	    	selectSprite:setVisible(false)
	    	-- 按钮
	    	local skillBtn = ui.newButton({
	    			normalImage = self:getSkillPic(skillTalId),
	    			position = pos,
	    			clickAction = function ()
	    				if selectSkillTalId == skillTalId then return end
	    				-- 刷新id
	    				selectSkillTalId = skillTalId
	    				-- 刷新选择框
	    				if beforeSelSprite then
	    					beforeSelSprite:setVisible(false)
	    				end
	    				selectSprite:setVisible(true)
	    				beforeSelSprite = selectSprite
	    				-- 刷新描述
	    				refreshSkillDesc(skillTalId)
	    			end,
	    		})
	    	bgSprite:addChild(skillBtn)
	    	-- 初始化选择框
	    	if not beforeSelSprite then
		    	if selectSkillTalId == 0 then
		    		beforeSelSprite = selectSprite
		    		beforeSelSprite:setVisible(true)
		    		selectSkillTalId = skillTalId
		    		refreshSkillDesc(skillTalId)
		    	else
		    		if selectSkillTalId == skillTalId then
		    			beforeSelSprite = selectSprite
		    			beforeSelSprite:setVisible(true)
		    			refreshSkillDesc(skillTalId)
		    		end
		    	end
		    end
	    end

	    createSkillBtn(NeiliFloorModel.items[self.mNeiliId][neiliInfo.Floor].tal1, cc.p(bgSize.width*0.5, 700))
	    createSkillBtn(NeiliFloorModel.items[self.mNeiliId][neiliInfo.Floor].tal2, cc.p(163, 370))
	    createSkillBtn(NeiliFloorModel.items[self.mNeiliId][neiliInfo.Floor].tal3, cc.p(463, 370))
	end

	-- 创建对话框
	LayerManager.addLayer({
	    name = "commonLayer.MsgBoxLayer",
	    cleanUp = false,
	    data = {
		    bgImage = "nl_30.png",
	        notNeedBlack = true,
	        title = TR("内力技能"),
	        DIYUiCallback = DIYfunc,
	        btnInfos = {},
	        closeBtnInfo = {}
	    }
	})
end

-- 重生提示弹窗


-- 刷新内力技能信息
function HeroNeiliHomeLayer:refreshNeiliShow()
	if not self.downParent then
		self.downParent = ui.newScale9Sprite("c_17.png", cc.size(625, 295))
		self.downParent:setPosition(320, 345)
		self.mParentLayer:addChild(self.downParent, 1)
	end
	self.downParent:removeAllChildren()

	-- 紫色以下的将不能升内力
	local heroModel = HeroModel.items[HeroObj:getHero(self.mHeroId).ModelId]
	if heroModel.quality < 10 then
		local emptyHint = ui.createEmptyHint(TR("需要紫色品质以上的侠客"))
		emptyHint:setPosition(320, 150)
		self.downParent:addChild(emptyHint)
		return
	end

	-- 内力数据
	local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}

	local parentSize = self.downParent:getContentSize()
	-- 技能信息
	local skillBgSize = cc.size(610, 120)
	local skillSprite = ui.newScale9Sprite("c_18.png", skillBgSize)
	skillSprite:setPosition(parentSize.width*0.5, 230)
	self.downParent:addChild(skillSprite)
	-- 未解锁
	if not neiliInfo.Floor or neiliInfo.Floor == 0 then
		local lockLabel = ui.newLabel({
				text = TR("内力升到一重解锁"),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		lockLabel:setPosition(skillBgSize.width*0.5, skillBgSize.height*0.5)
		skillSprite:addChild(lockLabel)
	else
		if neiliInfo.TalModelId == 0 or not self:checkFloorBuff() then
			local selectBtn = ui.newButton({
					normalImage = "nl_41.png",
					position = cc.p(skillBgSize.width*0.5, skillBgSize.height*0.5),
					clickAction = function ()
						self:UpSkillSelectBox(true)
					end,
				})
			skillSprite:addChild(selectBtn)
		else
			local talModel = TalModel.items[neiliInfo.TalModelId]
			-- 重数
			local floorSpirte = ui.newSprite(self.getFloorPic(neiliInfo.Floor or 1))
			floorSpirte:setScale(0.5)
			floorSpirte:setPosition(30, skillBgSize.height*0.8)
			skillSprite:addChild(floorSpirte)
			-- 技能图片
			local skillPic = ui.newSprite(self:getSkillPic(neiliInfo.TalModelId))
			skillPic:setPosition(70, skillBgSize.height*0.5)
			skillSprite:addChild(skillPic)
			-- 技能描述
			local skillDesc = ui.newLabel({
				text = TalModel.items[neiliInfo.TalModelId].intro,
				color = cc.c3b(0x46, 0x22, 0x0d),
				dimensions = cc.size(340, 0),
			})
			skillDesc:setAnchorPoint(cc.p(0, 0.5))
			skillDesc:setPosition(140, skillBgSize.height*0.5)
			skillSprite:addChild(skillDesc)
			-- 切换按钮
			local changeBtn = ui.newButton({
					normalImage = "zy_13.png",
					position = cc.p(535, skillBgSize.height*0.5),
					clickAction = function ()
						self:UpSkillSelectBox(true)
					end,
				})
			skillSprite:addChild(changeBtn)
		end
	end

	-- 属性提升
	local attrBgSize = cc.size(605, 155)
	local attrBg = ui.newScale9Sprite("c_54.png", attrBgSize)
	attrBg:setPosition(parentSize.width*0.5, 85)
	self.downParent:addChild(attrBg)
	-- title
	local titleLabel = ui.newLabel({
			text = TR("属性提升"),
			outlineColor = Enums.Color.eOutlineColor,
		})
	titleLabel:setPosition(attrBgSize.width*0.5, attrBgSize.height-20)
	attrBg:addChild(titleLabel)
	-- 属性加成
	-- 创建属性字符串
	local function createAttrLabel(neiliFloor, neiliLv, pos)
		local textStr = ""
		if neiliFloor >= self.totalFloor then
			if neiliLv > 0 then
				textStr = TR("已满级")
			else
				neiliFloor = 9
				neiliLv = 10
			end
		elseif neiliLv == 0 then
			if neiliFloor == 0 then
				textStr = TR("无属性加成")
			end
		elseif neiliLv > self.totalStep then
			neiliFloor = neiliFloor + 1
			neiliLv = 0
			if neiliFloor >= self.totalFloor then
				textStr = TR("已满级")
			end
		end

		if textStr == "" then
			local attrList = self:getAttrSum(self.mNeiliId, neiliFloor, neiliLv)
			local attrTextList = {}
			for attrType, value in pairs(attrList) do
				local attrName = FightattrName[attrType]
				local attrValue = Utility.getAttrViewStr(attrType, value)
				local color, numColor = "#46220d", "#a0461f"
				local attrText = color..attrName..numColor..attrValue
				table.insert(attrTextList, attrText)
			end
			textStr = table.concat(attrTextList, "\n")
		end
		local attrLabel = ui.newLabel({
				text = textStr,
				color = cc.c3b(0x46, 0x22, 0x0d),
				x = pos.x,
				y = pos.y,
			})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrBg:addChild(attrLabel)
	end

	local neiliFloor = neiliInfo.Floor or 0
	local neiliLv = neiliInfo.Lv or 0
	if neiliLv == self.totalStep then
		-- 左边重数
		local leftFloorLabel = ui.newLabel({
				text = neiliFloor == 0 and TR("无技能") or TR("内力技：%d重", neiliFloor),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		leftFloorLabel:setPosition(150, attrBgSize.height*0.45)
		attrBg:addChild(leftFloorLabel)
		-- 右边重数
		local rightFloorLabel = ui.newLabel({
				text = neiliFloor == 10 and TR("已满级") or TR("内力技：%d重", neiliFloor+1),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		rightFloorLabel:setPosition(450, attrBgSize.height*0.45)
		attrBg:addChild(rightFloorLabel)
	else
		-- 左边字符串
		createAttrLabel(neiliFloor, neiliLv, cc.p(80, attrBgSize.height*0.45))
		-- 右边字符串
		createAttrLabel(neiliFloor, neiliLv+1, cc.p(400, attrBgSize.height*0.45))
		-- 下面字符串
		if neiliFloor < self.totalFloor then
			local hintUnlockLabel = ui.newLabel({
					text = TR("#46220d再升#b4582f%d#46220d阶可%s内力技", self.totalStep-neiliLv,
							neiliFloor > 0 and TR("升级") or TR("解锁")),
				})
			hintUnlockLabel:setAnchorPoint(cc.p(0.5, 0))
			hintUnlockLabel:setPosition(attrBgSize.width*0.5, 5)
			attrBg:addChild(hintUnlockLabel)
		end
	end
	-- 中间箭头
	local arrowSprite = ui.newSprite("c_67.png")
	arrowSprite:setPosition(attrBgSize.width*0.5, attrBgSize.height*0.45)
	attrBg:addChild(arrowSprite)
end

-- 获取累计属性列表
function HeroNeiliHomeLayer:getAttrSum(neiliId, floor, lv)
	local neiliModel = NeiliLvupModel.items[neiliId]
	local attrList = {}
	for i = 0, floor do
		if i < floor then
			for j = 0, self.totalStep do
				local tempAttrList = Utility.analysisStrAttrList(neiliModel[i][j].perAttr)
				for _, attrInfo in ipairs(tempAttrList) do
					attrList[attrInfo.fightattr] = (attrList[attrInfo.fightattr] or 0) + attrInfo.value
				end
			end
		else
			for j = 0, lv do
				local tempAttrList = Utility.analysisStrAttrList(neiliModel[i][j].perAttr)
				for _, attrInfo in ipairs(tempAttrList) do
					attrList[attrInfo.fightattr] = (attrList[attrInfo.fightattr] or 0) + attrInfo.value
				end
			end
		end
	end

	return attrList
end

-- 刷新资源消耗显示
function HeroNeiliHomeLayer:refreshUseRes()
	-- 消耗代币
	if not self.mUseLabel then
		self.mUseLabel = ui.newLabel({
				text = "",
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		self.mUseLabel:setAnchorPoint(cc.p(0, 0.5))
		self.mUseLabel:setPosition(400, 140)
		self.mParentLayer:addChild(self.mUseLabel, 5)
	end
	self.mUseLabel:setString("")
	-- 消耗道具父节点
	if not self.mUseListView then
		self.mUseListView = ui.createCardList({
				maxViewWidth = 240,
			})
		self.mUseListView:setAnchorPoint(cc.p(1, 0.5))
		self.mUseListView:setPosition(240, 130)
		self.mParentLayer:addChild(self.mUseListView)
	end
	self.mUseListView.refreshList({})

	-- 紫色以下的将不能升内力
	local heroModel = HeroModel.items[HeroObj:getHero(self.mHeroId).ModelId]
	if heroModel.quality < 10 then
		self.mUseLabel:setVisible(false)
		self.mUseListView:setVisible(false)
		self.mLvUpBtn:setVisible(false)
		return
	else
		self.mUseLabel:setVisible(true)
		self.mUseListView:setVisible(true)
		self.mLvUpBtn:setVisible(true)
	end

	-- 内力数据
	local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}
	-- 重数阶数
	local neiliFloor, neiliLv = neiliInfo.Floor or 0, neiliInfo.Lv or 0
	
	-- 已满级
	if neiliFloor >= self.totalFloor then
		self.mLvUpBtn:setTitleText(TR("已满级"))
		self.mLvUpBtn:setEnabled(false)
		return
	else
		self.mLvUpBtn:setEnabled(true)
	end

	-- 要升重
	if neiliLv == self.totalStep then
		self.mLvUpBtn:setTitleText(TR("升重"))
	else
		self.mLvUpBtn:setTitleText(TR("运气"))
	end

	-- 消耗字符串
	local useList = Utility.analysisStrResList(NeiliLvupModel.items[self.mNeiliId][neiliFloor][neiliLv].consume)
	local cardResList = {}
	local useTextList = {}
	for _, resInfo in ipairs(useList) do
		if resInfo.modelId == 0 then
			local daiImage = Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId)
			local ownCount = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
			local useText = "{"..daiImage.."}"..Utility.numberWithUnit(ownCount).."/"..Utility.numberWithUnit(resInfo.num)
			if resInfo.num > ownCount then
				useText = Enums.Color.eRedH.."{"..daiImage.."}"..Utility.numberWithUnit(ownCount).."#46220d".."/"..Utility.numberWithUnit(resInfo.num)
			end
			table.insert(useTextList, useText)
		else
			resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
			table.insert(cardResList, resInfo)
		end
	end
	local useText = table.concat(useTextList, "\n")
	self.mUseLabel:setString(useText)
	-- 消耗道具
	self.mUseListView.refreshList(cardResList)
	-- 重设数量（显示拥有数量）
	for _, cardNode in pairs(self.mUseListView.getCardNodeList()) do
		local numLabel = cardNode:getAttrControl()[CardShowAttr.eNum].label
		local ownCount = Utility.getOwnedGoodsCount(cardNode.mResourceTypeSub, cardNode.mModelId)
		local oldNum = tonumber(numLabel:getString())
		local newNum = Utility.numberWithUnit(ownCount).."/"..Utility.numberWithUnit(oldNum)
		if oldNum > ownCount then
			newNum = Enums.Color.eRedH..Utility.numberWithUnit(ownCount)..Enums.Color.eWhiteH.."/"..Utility.numberWithUnit(oldNum)
		end
		numLabel:setString(newNum)
	end
end

function HeroNeiliHomeLayer:refreshHeroFigure()
	if self.mHeroFigure and not tolua.isnull(self.mHeroFigure) then
		self.mHeroFigure:removeFromParent()
		self.mHeroFigure = nil
	end

	self.mHeroFigure = Figure.newHero({
	    parent = self.mParentLayer,
	    heroModelID = self.mHeroInfo.ModelId,
	    fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
	    IllusionModelId = self.mHeroInfo.IllusionModelId,
        heroFashionId = self.mHeroInfo.CombatFashionOrder,
	    position = cc.p(320, 620),
	    scale = 0.3,
	})
end

-- 刷新某个人物
function HeroNeiliHomeLayer:refreshHeroUI()
	-- 融合重数
	local harmonyFloor = self.mHeroInfo.HeroNeiliHarmonyInfo.Floor or 0
	self.mHarmonyNumLabel:setString(harmonyFloor)
	-- 当前内力球重数
	for _, label in pairs(self.mLvLabelList) do
		label:refreshLv()
	end
	-- 属性技能显示
	self:refreshNeiliShow()
	-- 资源消耗显示
	self:refreshUseRes()
	-- 刷新人物
	self.mNameNode:refreshName(self.mHeroInfo)
	self:refreshHeroFigure()
end
-- 刷新界面
function HeroNeiliHomeLayer:refreshUI()
	-- 融合重数
	local harmonyFloor = self.mHeroInfo.HeroNeiliHarmonyInfo.Floor or 0
	self.mHarmonyNumLabel:setString(harmonyFloor)
	-- 当前内力球重数
	self.mLvLabelList[self.mNeiliId]:refreshLv()
	-- 属性技能显示
	self:refreshNeiliShow()
	-- 资源消耗显示
	self:refreshUseRes()
end

-- 检查当前重数buff是否一至
function HeroNeiliHomeLayer:checkFloorBuff()
	local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}

	if not neiliInfo.Floor or neiliInfo.Floor == 0 then return true end

	local floorTalModel = NeiliFloorModel.items[self.mNeiliId][neiliInfo.Floor]
	if neiliInfo.TalModelId == floorTalModel.tal1 or
		neiliInfo.TalModelId == floorTalModel.tal2 or
		neiliInfo.TalModelId == floorTalModel.tal3 then
		return true
	end

	return false
end

-- 升级内力技弹窗
function HeroNeiliHomeLayer:UpSkillSelectBox(isChange)
	local isReset = false
	if not self:checkFloorBuff() then
		isReset = true
		-- 弹出选择buff弹窗(延时弹出，需要主界面初始化完后弹出)
		Utility.performWithDelay(self, function()
			self:selectSkillBox(isReset)
		end, 0)
	elseif isChange then
		-- 弹出选择buff弹窗(延时弹出，需要主界面初始化完后弹出)
		Utility.performWithDelay(self, function()
			self:selectSkillBox(isReset)
		end, 0)
	end
	
end

-- 内力重生
function HeroNeiliHomeLayer:getRebirthRes(heroInfo)
	dump(heroInfo)
	local useResList = {}
	-- 内力升级消耗
	for _, neiliInfo in pairs(heroInfo.HeroNeiliInfo) do
		for i = neiliInfo.Floor, 0, -1 do
			local initJ = #NeiliLvupModel.items[neiliInfo.NeiliTypeId][i]
			if i == neiliInfo.Floor then initJ = neiliInfo.Lv-1 end
			for j = initJ, 0, -1 do
				local useStr = NeiliLvupModel.items[neiliInfo.NeiliTypeId][i][j].consume
				local resList = Utility.analysisStrResList(useStr)
				for _, resInfo in pairs(resList) do
					local key = resInfo.resourceTypeSub..resInfo.modelId
					if useResList[key] then
						useResList[key].num = useResList[key].num + resInfo.num
					else
						useResList[key] = resInfo
					end
				end
			end
		end
	end

	-- 融合消耗
	local harmonyFloor = heroInfo.HeroNeiliHarmonyInfo and heroInfo.HeroNeiliHarmonyInfo.Floor or 0
	for i = 1, harmonyFloor do
		local useStr = NeiliHarmonyModel.items[i].consume
		local resList = Utility.analysisStrResList(useStr)
		for _, resInfo in pairs(resList) do
			local key = resInfo.resourceTypeSub..resInfo.modelId
			if useResList[key] then
				useResList[key].num = useResList[key].num + resInfo.num
			else
				useResList[key] = resInfo
			end
		end
	end

	useResList = table.values(useResList)
	return useResList
end

-----------------------------服务器相关----------------------------
-- 内力升级
function HeroNeiliHomeLayer:requestLvUp()
	-- 资源判断
	-- 内力数据
	local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}
	-- -- 重数阶数
	local neiliFloor, neiliLv = neiliInfo.Floor or 0, neiliInfo.Lv or 0
	local useList = Utility.analysisStrResList(NeiliLvupModel.items[self.mNeiliId][neiliFloor][neiliLv].consume)
	for _, resInfo in pairs(useList) do
		if resInfo.resourceTypeSub == ResourcetypeSub.eGold then
			if not Utility.isResourceEnough(resInfo.resourceTypeSub, resInfo.num) then
				return
			end
		else
			local ownCount = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
			if ownCount < resInfo.num then
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = resInfo.resourceTypeSub,
		                modelId = resInfo.modelId
		            },
		            cleanUp = false,
		        })
				return
			end
		end
	end

    HttpClient:request({
        moduleName = "HeroNeili",
        methodName = "LvUp",
        svrMethodData = {self.mHeroId, self.mNeiliId},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- 更新缓存
            HeroObj:modifyHeroItem(response.Value.HeroInfo)
            -- 更新页面数据
            self.mHeroInfo = response.Value.HeroInfo
            -- 刷新页面
            self:refreshUI()
            -- 检查当前重数buff是否一至
            local neiliInfo = self.mHeroInfo.HeroNeiliInfo[tostring(self.mNeiliId)] or {}
            if neiliInfo.Lv == 0 then 	-- 刚升重才检查
			    self:UpSkillSelectBox()
			end

			-- 播放特效
			local animationList = {
				"lan",
				"hong",
				"zi",
			}
			ui.newEffect({
					parent = self.mParentLayer,
					effectName = "effect_neili",
					animation = animationList[self.mNeiliId],
					position = cc.p(320, 840),
					zorder = 5,
					loop = false,
				})

        end
    })
end

-- 选择内功技能
function HeroNeiliHomeLayer:requestChoiceTal(skillTalId)
	HttpClient:request({
	    moduleName = "HeroNeili",
	    methodName = "ChoiceTal",
	    svrMethodData = {self.mHeroId, self.mNeiliId, skillTalId},
	    callback = function(response)
	        if response.Status ~= 0 then return end
	        -- 更新缓存
	        HeroObj:modifyHeroItem(response.Value.HeroInfo)
	        -- 更新页面数据
	        self.mHeroInfo = response.Value.HeroInfo
	        -- 刷新属性技能显示
			self:refreshNeiliShow()
	    end
	})
end

-- 重生
function HeroNeiliHomeLayer:requestRebirth(heroId)
	HttpClient:request({
	    moduleName = "HeroNeili",
	    methodName = "Rebirth",
	    svrMethodData = {heroId},
	    callback = function(response)
	        if response.Status ~= 0 then return end

	        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	        -- 更新缓存
	        HeroObj:modifyHeroItem(response.Value.HeroInfo)
	        -- 更新页面数据
	        self.mHeroInfo = response.Value.HeroInfo
	        -- 刷新属性技能显示
			self:refreshHeroUI()
	    end
	})
end

return HeroNeiliHomeLayer