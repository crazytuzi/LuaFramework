--[[
    文件名: TeamZhenjueLayer.lua
	描述: 队伍的内功心法页面，根据人物卡槽导航查看并操作各个装备（更换、洗炼）
	创建人: peiyaoqiang
	创建时间: 2016.5.4
--]]

local TeamZhenjueLayer = class("TeamZhenjueLayer", function(params)
    return display.newLayer()
end)

local OperateBtnTag = {
	eUpdate = 1, -- 洗炼
    eReplace = 2, -- 更换
    eOneKeyCombat = 3, -- 一键上阵
    eGetZhenjue = 4, -- 获取内功心法
    eStepUp = 5, -- 进阶
}

-- 模块内部消息
local SelectSlotChange = "eTeamZhenjueLayerSelectSlotChange"  -- 选中卡槽改变的事件名称

--[[
params: 参数列表
	{
		showIndex: 可选参数，进入阵容后直接显示的人物（1是主角，2~6是普通人物, 7是江湖后援团）
		showZhenjueIndex: 当前显示的内功心法所在的Index
	}
]]
function TeamZhenjueLayer:ctor(params)
	self.mShowIndex = params and params.showIndex or 1 -- 默认显示卡槽的index
	self.mShowZhenjueIndex = params and params.showZhenjueIndex  or 1  -- 默认为第一个内功心法卡槽
	-- 上阵卡槽数，包含江湖后援团入口
	self.mSlotMaxCount = FormationObj:getMaxSlotCount()

	-- 操作按钮对象列表
	self.mOperateBtnList = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
    })
    self:addChild(tempLayer)

    -- 切换页面
    self:changePage()
end

-- 初始化页面控件
function TeamZhenjueLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_18.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 卡槽信息子页面的父节点
    self.mSlotParent = cc.Node:create()
    self.mParentLayer:addChild(self.mSlotParent)
    -- 江湖后援团信息子页面的父节点
    self.mMateParent = cc.Node:create()
    self.mParentLayer:addChild(self.mMateParent)
    
	-- 页面顶部的人物头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
        needPet = true, -- 是否需要外功秘籍按钮，默认为true
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
        viewSize = cc.size(620, 106),
        bgImgName = "c_01.png",
        checkReddotId = Enums.ClientRedDot.eTeamZhenjue,
        onClickItem = function(slotIndex)
        	-- 外功技能
        	if slotIndex == 0 then
        		LayerManager.addLayer({name = "team.PetCampLayer",})
        		return
        	end

        	-- 其他卡槽点击处理
        	local isTeamSlot = slotIndex > 0 and slotIndex < self.mSlotMaxCount  -- 是阵容卡槽
        	if isTeamSlot and not FormationObj:slotIsOpen(slotIndex) then
        		-- 如果不是江湖后援团卡槽，并且该卡槽未开启，则需要提示用户去点星
        		MsgBoxLayer.gotoLightenStarHintLayer(slotIndex, false, FormationObj)
        		return
        	end
        	self.mShowIndex = slotIndex
        	-- 切换页面
        	self:changePage()

        	-- 如果是阵容卡槽并且未上阵人物，则需要打开选择人物页面
        	if isTeamSlot and FormationObj:slotIsEmpty(slotIndex) then
        		LayerManager.addLayer({name = "team.TeamSelectHeroLayer",
        			data = {
        				slotId = slotIndex,
        				alwaysIdList = {},
        			}
        		})
        	end
        end
    })
    self.mSmallHeadView:setPosition(320, 1136)
    self.mParentLayer:addChild(self.mSmallHeadView)
end

-- 获取恢复该页面的参数
function TeamZhenjueLayer:getRestoreData()
	local retData = {}
	retData.showIndex = self.mShowIndex
	retData.showZhenjueIndex = self.mShowZhenjueIndex

	return retData
end

-- 切换页面
function TeamZhenjueLayer:changePage()
	local isMateLayer = self.mShowIndex == self.mSlotMaxCount -- 江湖后援团页面

	self.mSlotParent:setVisible(not isMateLayer)
	self.mMateParent:setVisible(isMateLayer)

	if isMateLayer then
		self:createMateView()
	else
		self.mMateParent:removeAllChildren() -- 因为小伙伴页面加了屏蔽下层点击，所以这里要将其删除
		self:createSlotView()
	end

	self:dealSelectChange()
end

-- 创建卡槽相关控件
function TeamZhenjueLayer:createSlotView()
	if self.mSlotParent:getChildrenCount() > 0 then
		return
	end

	-- 创建人物形象列表
	self.mFigureView = require("team.teamSubView.TeamFigureView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
    	figureScale = 0.3,
		onSelectChange = function(slotIndex)
			self.mShowIndex = slotIndex
        	self:dealSelectChange()
		end,
		onClickItem = function(slotIndex)
			if FormationObj:slotIsEmpty(slotIndex) then
        		LayerManager.addLayer({name = "team.TeamSelectHeroLayer",
        			data = {
        				slotId = slotIndex,
        				alwaysIdList = {},
        			}
        		})
        	else
        		local slotInfo = FormationObj:getSlotInfoBySlotId(slotIndex)
        		local tempData = {
        			heroId = slotInfo.HeroId,
        			heroModelId = slotInfo.HeroModelId,
        			onlyViewInfo = false,
        			fashionModelId = -1,
        		}
        		LayerManager.addLayer({name = "hero.HeroInfoLayer", data = tempData})
        	end
		end,
	})
	self.mFigureView:setAnchorPoint(cc.p(0.5, 1))
	self.mFigureView:setPosition(320, 1000)
	self.mSlotParent:addChild(self.mFigureView)

	-- 创建内功心法卡牌展示
	self.mZhenjueView = require("team.teamSubView.SlotZhenjueView"):create({
    	viewSize = cc.size(640, 400),
        showSlotId = self.mShowIndex,
        zhenjueSlotIndex = self.mShowZhenjueIndex,
        isCircleView = true,
        formationObj = FormationObj,
		onClickItem = function(zhenjueSlotIndex)
			-- 判断改卡槽是否已经开启
			if not FormationObj:slotZhenjueIsOpen(self.mShowIndex, zhenjueSlotIndex) then
				local tempStr = nil
				if zhenjueSlotIndex > 4 then
					tempStr = TR("传说侠客才能开启该卡槽")
				elseif zhenjueSlotIndex > 3 then
					tempStr = TR("神话侠客才能开启该卡槽")
				else
					tempStr = TR("宗师侠客才能开启该卡槽")
				end
				ui.showFlashView(tempStr)
				return
			end

			self.mShowZhenjueIndex = zhenjueSlotIndex
			self:dealSelectChange()
			-- 如果该卡槽上没有内功心法，则调用内功心法选择页面
			if FormationObj:slotZhenjueIsEmpty(self.mShowIndex, self.mShowZhenjueIndex) then
				local tempData = {
					slotId = self.mShowIndex,
	        		zhenjueSlotId = self.mShowZhenjueIndex,
	        		alwaysIdList = {},
				}
				LayerManager.addLayer({name = "team.TeamSelectZhenjueLayer", data = tempData})
			end
		end,
	})
	self.mZhenjueView:setAnchorPoint(cc.p(0.5, 1))
	self.mZhenjueView:setPosition(320, 920)
	self.mSlotParent:addChild(self.mZhenjueView)

	-- 规则按钮
	local tempBtn = ui.newButton({
		normalImage = "c_72.png",
		clickAction = function()
			local rulesData = {
                [1] = TR("1.资质为10的紫色品质侠客只有1个内功心法卡槽"),
                [2] = TR("2.资质为13的橙色品质侠客只有3个内功心法卡槽"),
                [3] = TR("3.资质为15的橙色品质侠客只有4个内功心法卡槽"),
                [4] = TR("4.资质为18的红色品质侠客拥有6个内功心法卡槽"),
                [5] = TR("5.橙色及橙色品质以上的内功心法能够触发技能"),
                [6] = TR("6.守卫襄阳可以获取内功")
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则"), rulesData)
		end
	})
	tempBtn:setPosition(55, 980)
	self.mSlotParent:addChild(tempBtn)

	-- 创建返回按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(585, 980)
	self.mSlotParent:addChild(self.mCloseBtn)

	-- 创建内功心法信息
	self:createZhenjueInfo()

	-- 创建人物名称等基本信息
	self:createHeroInfo()
end

-- 创建江湖后援团信息的相关控件
function TeamZhenjueLayer:createMateView()
	self.mMateParent:removeAllChildren()

    -- 创建江湖后援团信息View
    local mateInfoView = require("team.teamSubView.MateInfoView"):create({
        formationObj = FormationObj,
        viewSize = cc.size(640, 920),
        clickCallback = function(slotIndex, isMateSlot)
            if not isMateSlot then  -- 暂时不处理阵容卡牌
                return
            end

            if FormationObj:slotIsOpen(slotIndex, true) then
                local slotInfo = FormationObj:getMateSlotInfo(slotIndex)
                if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
                    local tempData = {
                        heroId = slotInfo.HeroId,
                        onlyViewInfo = false,
                    }
                    LayerManager.addLayer({name = "hero.HeroInfoLayer", data = tempData})
                else
                    LayerManager.addLayer({name = "team.TeamSelectHeroLayer",
	                    data = {
	                        slotId = slotIndex,
	                        isMateSlot = true,
	                        alwaysIdList = {},
	                    }
                	})
                end
            else
                if FormationObj:mateSlotIsVipOpen(slotIndex) then -- Vip开启的江湖后援团卡槽
                    if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
                        local tempItem = VipSlotRelation.items[slotIndex]
                        ui.showFlashView(TR("VIP%d 开启", tempItem.LV))
                    else
                        ui.showFlashView(TR("暂未开启"))
                    end
                else
                	MsgBoxLayer.gotoLightenStarHintLayer(slotIndex, true, FormationObj)
                end
            end
        end
    })
    mateInfoView:setAnchorPoint(cc.p(0.5, 1))
	mateInfoView:setPosition(320, 1020)
    self.mMateParent:addChild(mateInfoView)
end

-- 创建内功心法信息
function TeamZhenjueLayer:createZhenjueInfo()
	self.mZhenjueInfoNode = cc.Node:create()
	self.mSlotParent:addChild(self.mZhenjueInfoNode)

	-- 详细信息的背景
	local infoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 375))
	infoBgSprite:setPosition(320, 0)
	infoBgSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mZhenjueInfoNode:addChild(infoBgSprite)

	-- 创建操作按钮
	local btnInfos = {
        -- 更换
        {
            text = TR("更换"),
            position = cc.p(150, 140),
            operateBtnTag = OperateBtnTag.eReplace,
            clickAction = function()
            	local tempData = {
					slotId = self.mShowIndex,
	        		zhenjueSlotId = self.mShowZhenjueIndex,
	        		alwaysIdList = {},
				}
				LayerManager.addLayer({name = "team.TeamSelectZhenjueLayer", data = tempData})
            end
        },
		-- 洗炼
        {
            text = TR("洗炼"),
            position = cc.p(490, 140),
            operateBtnTag = OperateBtnTag.eUpdate,
            clickAction = function()
            	local tempData = {
					showIndex = self.mShowIndex,
	        		showZhenjueIndex = self.mShowZhenjueIndex,
				}
				LayerManager.addLayer({name = "zhenjue.TeamZhenjueExtraLayer", data = tempData})
            end
        },
        -- 进阶
        {
        	text = TR("进阶"),
            position = cc.p(320, 140),
            operateBtnTag = OperateBtnTag.eStepUp,
            clickAction = function()
            	local zhenjueInfo = FormationObj:getSlotZhenjue(self.mShowIndex, self.mShowZhenjueIndex) or {}
            	if (ZhenjueObj:getNameImgOfStep(zhenjueInfo.ModelId) == nil) then
            		ui.showFlashView(TR("该内功心法暂时不能进阶"))
            		return
            	end
            	LayerManager.addLayer({name = "zhenjue.ZhenjueStepUpLayer", data = {zhenjueId = zhenjueInfo.Id, refreshFunc = function ()
            			self.mZhenjueView:changeShowSlot(self.mShowIndex)
            			self.mZhenjueInfoNode.refresh()
            		end}, cleanUp = false})
            end
    	},
        -- 获取
        {
        	text = TR("前往"),
            position = cc.p(320, 140),
            operateBtnTag = OperateBtnTag.eGetZhenjue,
            clickAction = function()
            	LayerManager.showSubModule(ModuleSub.eTeambattle)
            end
    	},
        -- 一键装备
        {
        	text = TR("一键上阵"),
            position = cc.p(320, 400),
            operateBtnTag = OperateBtnTag.eOneKeyCombat,
            clickAction = function()
            	local onekeyData = SlotPrefObj:getOneKeyReplaceZhenjue(self.mShowIndex)
            	if not onekeyData or not next(onekeyData) then
            		return
            	end
            	--
            	local haveCombatData = false
            	-- 请求服务器接口的参数
				local tempData = {self.mShowIndex}
            	-- 改人物卡槽可以上阵的最大内功心法个数
            	local tempList = {}
            	local maxCount = FormationObj:getSlotZhenjueMaxCount(self.mShowIndex)
				for index = 1, maxCount do
					if onekeyData[index] and Utility.isEntityId(onekeyData[index].Id) then
						haveCombatData = true
						tempList[tostring(index)] = onekeyData[index].Id
					end
				end
				if not haveCombatData then
					ui.showFlashView(TR("没有更好的内功心法可以上阵"))
					return
				end
				table.insert(tempData, tempList)

				self:requestOneKeyZhenjueCombat(tempData)
            end
    	},
	}
    for index, item in ipairs(btnInfos) do
        item.normalImage = (item.operateBtnTag == OperateBtnTag.eOneKeyCombat) and "c_27.png" or "c_28.png"
        local tempBtn = ui.newButton(item)
        self.mZhenjueInfoNode:addChild(tempBtn)

        if item.operateBtnTag then
            self.mOperateBtnList[item.operateBtnTag] = tempBtn

            -- 小红点逻辑
            if (item.operateBtnTag == OperateBtnTag.eOneKeyCombat) or (item.operateBtnTag == OperateBtnTag.eStepUp) then
            	-- 事件名
		        local eventNames = {SelectSlotChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
		        local function dealRedDotVisible(redDotSprite)
	        		local redDotData = false
	        		if (item.operateBtnTag == OperateBtnTag.eOneKeyCombat) then
	        			-- 一键上阵
	        			redDotData = (SlotPrefObj:havePreferableZhenjue(self.mShowIndex) ~= nil)
	        		elseif (item.operateBtnTag == OperateBtnTag.eStepUp) then
	        			-- 进阶
	        			local zhenjueInfo = FormationObj:getSlotZhenjue(self.mShowIndex, self.mShowZhenjueIndex) or {}
	        			redDotData = SlotPrefObj:itemZhenjueCanStep(zhenjueInfo.Id)
	        		end
		            redDotSprite:setVisible(redDotData)
		        end
                ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempBtn})
            end
        end
    end

	-- 刷新内功心法信息
	self.mZhenjueInfoNode.refresh = function()
		local zhenjueType = FormationObj:getZhenjueSlotType(self.mShowZhenjueIndex)
		local zhenjueIsEmpty =  FormationObj:slotZhenjueIsEmpty(self.mShowIndex, self.mShowZhenjueIndex)
		local slotIsEmpty = FormationObj:slotIsEmpty(self.mShowIndex)
		local zhenjueIsOpen = FormationObj:slotZhenjueIsOpen(self.mShowIndex, self.mShowZhenjueIndex)
		local idleCount = ZhenjueObj:getCountByTypeId(zhenjueType, {
			notInFormation = true
		})
		-- 设置操作按钮的状态
		local replaceBtn = self.mOperateBtnList[OperateBtnTag.eReplace]
		local updateBtn = self.mOperateBtnList[OperateBtnTag.eUpdate]
		local getBtn = self.mOperateBtnList[OperateBtnTag.eGetZhenjue]
		local oneKeyBtn = self.mOperateBtnList[OperateBtnTag.eOneKeyCombat]
		local stepUpBtn = self.mOperateBtnList[OperateBtnTag.eStepUp]
		
		replaceBtn:setVisible(zhenjueIsOpen and (idleCount > 0 or not zhenjueIsEmpty))
		replaceBtn:setPositionX(zhenjueIsEmpty and 320 or 150)
		replaceBtn:setTitleText(zhenjueIsEmpty and TR("上阵") or TR("更换"))
		updateBtn:setVisible(zhenjueIsOpen and not zhenjueIsEmpty)
		stepUpBtn:setVisible(zhenjueIsOpen and not zhenjueIsEmpty)
		getBtn:setVisible(zhenjueIsOpen and zhenjueIsEmpty and (idleCount == 0))
		oneKeyBtn:setVisible(not slotIsEmpty)

		infoBgSprite:removeAllChildren()
		if zhenjueIsEmpty then  -- 没有上阵内功心法，需要显示提示信息
			local tempStr = ""
			if slotIsEmpty then  -- 没有上阵人物
				tempStr = TR("该卡槽没有上阵侠客")
			elseif not zhenjueIsOpen then  -- 内功心法卡槽没有开启
				if self.mShowZhenjueIndex > 4 then
					tempStr = TR("传说侠客才能开启该卡槽")
				elseif self.mShowZhenjueIndex > 3 then
					tempStr = TR("神话侠客才能开启该卡槽")
				else
					tempStr = TR("宗师侠客才能开启该卡槽")
				end
			elseif idleCount > 0 then  -- 有可上阵的内功心法
				tempStr = TR("包裹里还有可以穿戴的空闲内功心法，是否上阵?")
			else -- 没有可上阵的内功心法
				tempStr = TR("镇守襄阳可以获得各种品质的内功心法，是否前往?")
			end
			local tempLabel = ui.newLabel({
				text = tempStr,
				color = Enums.Color.eBrown,
				align = cc.TEXT_ALIGNMENT_CENTER
			})
			tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
			tempLabel:setPosition(320, 240)
			infoBgSprite:addChild(tempLabel)
		else
			local zhenjueInfo = FormationObj:getSlotZhenjue(self.mShowIndex, self.mShowZhenjueIndex)
			local nStepTimes = ZhenjueObj:getTimesOfStep(zhenjueInfo)
			local zhenjueModel = ZhenjueModel.items[zhenjueInfo.ModelId]
			-- 创建内功心法的卡牌
			local tempCard = CardNode:create({
				cardShape = Enums.CardShape.eHexagon,
			})
			tempCard:setPosition(70, 255)
			tempCard:setZhenjue(zhenjueInfo, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eStep})
			infoBgSprite:addChild(tempCard)
			-- 创建内功心法属性显示
			local attrList = Utility.analysisStrAttrList(zhenjueModel.initAttrStr)
			local startPosX, startPosY = 154, 315
			for index, item in pairs(attrList) do
				local nameStr = FightattrName[item.fightattr]
				local baseAttrStr = Utility.getAttrViewStr(item.fightattr, math.floor(item.value * nStepTimes), false)
				local upAttrStr = ""
				if zhenjueInfo.UpAttrData[tostring(item.fightattr)] and zhenjueInfo.UpAttrData[tostring(item.fightattr)] > 0 then
					upAttrStr = Utility.getAttrViewStr(item.fightattr, zhenjueInfo.UpAttrData[tostring(item.fightattr)], false)
				end

				-- 属性的背景
				local tempSprite = ui.newScale9Sprite("c_39.png", cc.size(220, 33))
				tempSprite:setAnchorPoint(cc.p(0, 0.5))
				tempSprite:setPosition(startPosX + math.mod((index - 1), 2) * 240, startPosY - math.floor((index - 1) / 2) * 37)
				infoBgSprite:addChild(tempSprite)
				-- 属性值
				local tempStr = upAttrStr == "" and string.format("%s:%s", nameStr, baseAttrStr) or
					string.format("%s:%s %s+%s", nameStr, baseAttrStr, Enums.Color.eDarkGreenH, upAttrStr)
				local tempLabel = ui.newLabel({
					text = tempStr,
					color = cc.c3b(0x46, 0x22, 0x0d),
				})
				tempLabel:setAnchorPoint(cc.p(0, 0.5))
				tempLabel:setPosition(10, 16)
				tempSprite:addChild(tempLabel)
			end
			-- 创建内功心法技能
			local tempStr = ""
			local talItem = TalModel.items[zhenjueModel.talModelID]
			if talItem then
				tempStr = string.format("%s:%s%s", talItem.name, Enums.Color.eDarkGreenH, talItem.intro)
			else
				tempStr = TR("橙色或更高品质的内功心法才能触发内功心法技能")
				if zhenjueModel.upOddsClass == 0 then
					tempStr = tempStr .. TR("\n蓝色及其以上的内功心法才能进行洗炼")
				end
			end
			local tempLabel = ui.newLabel({
				text = tempStr,
				color = Enums.Color.eBrown,
				valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
				dimensions = cc.size(440, 0)
			})
			tempLabel:setAnchorPoint(cc.p(0, 1))
			tempLabel:setPosition(154, 250)
			infoBgSprite:addChild(tempLabel)
		end
	end
	self.mZhenjueInfoNode.refresh()
end

-- 创建卡槽人物信息
function TeamZhenjueLayer:createHeroInfo()
	self.mHeroInfoNode = cc.Node:create()
	self.mSlotParent:addChild(self.mHeroInfoNode)

	-- 创建人物的名字
	local _, _, nameNode = Figure.newNameAndStar({
		parent = self.mHeroInfoNode,
		position = cc.p(320, 1050),
		})

	-- 创建卡槽的战力
	local FAPBgSprite = ui.newFAPView()
	FAPBgSprite:setPosition(320, 460)
	self.mHeroInfoNode:addChild(FAPBgSprite)

	-- 刷新人物信息（名字、战力、星数）
	self.mHeroInfoNode.refresh = function()
		local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
		local haveHero = Utility.isEntityId(slotInfo.HeroId)
		self.mHeroInfoNode:setVisible(haveHero)

		if haveHero then
			local heroInfo = HeroObj:getHero(slotInfo.HeroId)
			local tempModel = HeroModel.items[slotInfo.ModelId]
			local strName, tempStep = ConfigFunc:getHeroName(slotInfo.ModelId, {heroStep = heroInfo.Step, IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
			local strText = TR("等级%d  %s%s",
				heroInfo.Lv,
				Utility.getQualityColor(tempModel.quality, 2),
				strName)
			if (tempStep > 0) then
				strText = strText .. Enums.Color.eYellowH .. "  +" .. tempStep
			end
			nameNode:setString(strText)

			FAPBgSprite.setFAP(FormationObj:getSlotAttrByName(self.mShowIndex, "FAP"))
		end
	end
	self.mHeroInfoNode.refresh()
end

-- 当选中的卡槽改变后的处理逻辑
function TeamZhenjueLayer:dealSelectChange()
	local isTeamSlot = self.mShowIndex > 0 and self.mShowIndex < self.mSlotMaxCount  -- 是阵容卡槽
	if isTeamSlot then  -- 阵容卡槽
		if self.mZhenjueView then
			self.mZhenjueView:changeShowSlot(self.mShowIndex)
		end

		if self.mFigureView then
			self.mFigureView:changeShowSlot(self.mShowIndex)
		end

		if self.mHeroInfoNode then
			self.mHeroInfoNode:refresh()
		end

		if self.mZhenjueInfoNode then
			self.mZhenjueInfoNode.refresh()
		end
	end

	if self.mSmallHeadView then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end

	-- 通知选中卡槽改变
	Notification:postNotification(SelectSlotChange)
end

-- ======================== 服务器数据请求相关函数 =======================
-- 更换装备数据请求
function TeamZhenjueLayer:requestOneKeyZhenjueCombat(svrParams)
	--
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "OneKeyZhenjueCombat",
        svrMethodData = svrParams,
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then --
                return
            end

            -- 刷新本页面
            self:dealSelectChange()
        end,
    })
end

return TeamZhenjueLayer