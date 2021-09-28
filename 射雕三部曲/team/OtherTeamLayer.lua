--[[
    文件名: OtherTeamLayer.lua
	描述: 其他玩家队伍主页面
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local OtherTeamLayer = class("OtherTeamLayer", function(params)
    return display.newLayer()
end)

-- 初始化函数
--[[
	params: 参数列表
	{
		showIndex: 可选参数，进入阵容后直接显示的人物（1是主角，2~6是普通人物）
		formationObj: 其他玩家的整容数据对象
	}
--]]
function OtherTeamLayer:ctor(params)
	params = params or {}
	-- 默认显示卡槽的index
	self.mShowIndex = params and params.showIndex or 1
	-- 玩家的整容数据对象
	self.mFormationObj = params.formationObj
	-- 阵容最大的卡槽数
	self.mSlotMaxCount = self.mFormationObj:getMaxSlotCount()

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer
end

-- 初始化页面控件
function OtherTeamLayer:initUI()
	-- 创建背景相关节点
	local bgLayer = ui.newSprite("zr_07.jpg")
	bgLayer:setPosition(320, 568)
	self.mParentLayer:addChild(bgLayer)

	-- 卡槽信息子页面的父节点
    self.mSubParent = cc.Node:create()
    self.mParentLayer:addChild(self.mSubParent)

	-- 页面顶部的人物头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
        showSlotId = self.mShowIndex,
        formationObj = self.mFormationObj,
        viewSize = cc.size(620, 106),
        bgImgName = "c_01.png",
        needPet = false,
        onClickItem = function(slotIndex)
        	if self.mShowIndex == slotIndex then
        		return
        	end

        	if slotIndex == self.mSlotMaxCount then  -- 从阵容卡槽切换到小伙伴
        		self.mShowIndex = slotIndex
        		self:createMateInfo()
        		self:dealSelectChange()
        		return
        	end
        	
        	local oldShowIndex = self.mShowIndex
        	self.mShowIndex = slotIndex
        	if oldShowIndex == self.mSlotMaxCount then  -- 从小伙伴切换到阵容卡槽
        		self:createSlotInfo()
        	end
        	self:dealSelectChange()
        end
    })
    self.mSmallHeadView:setPosition(320, 1136)
    self.mParentLayer:addChild(self.mSmallHeadView)

    if self.mShowIndex == self.mSlotMaxCount then
    	self:createMateInfo()
    else
    	self:createSlotInfo()
    end
end

-- 获取恢复数据
function OtherTeamLayer:getRestoreData()
	local retData = {
		showIndex = self.mShowIndex,
		formationObj = self.mFormationObj,
	}

	return retData
end

-- 创建阵容卡槽信息
function OtherTeamLayer:createSlotInfo()
	self.mSubParent:removeAllChildren()

	-- 创建人物形象列表
	self.mFigureView = require("team.teamSubView.TeamFigureView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        formationObj = self.mFormationObj,
    	figureScale = 0.3,
		onSelectChange = function(slotIndex)
			self.mShowIndex = slotIndex
        	self:dealSelectChange()
		end,
		onClickItem = function(slotIndex)
			if not self.mFormationObj:slotIsEmpty(slotIndex) then
        		local tempData = {
        			heroModelId = self.mFormationObj:getSlotInfoBySlotId(slotIndex).ModelId,
        			onlyViewInfo = true,
        			playerName = self.mFormationObj.mOtherPlayerInfo.Name,
        			isOtherPlayer = true,
        			slotIndex = slotIndex,
        			formationObj = self.mFormationObj,
        		}
        		LayerManager.addLayer({
        			name = "hero.HeroInfoLayer",
        			data = tempData,
        			cleanUp = false,
        		})
        	end
		end,
	})
	self.mFigureView:setAnchorPoint(cc.p(0.5, 1))
	self.mFigureView:setPosition(320, 950)
	self.mSubParent:addChild(self.mFigureView)
	
	-- 创建装备卡牌展示
	self.mEquipView = require("team.teamSubView.SlotEquipView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        formationObj = self.mFormationObj,
		onClickItem = function(resourcetypeSub)
			-- 判断人物是否为空
			local currSlotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowIndex)
			if not Utility.isEntityId(currSlotInfo and currSlotInfo.HeroId) then
				return
			end

			-- 查看详情
			if Utility.isTreasure(resourcetypeSub) then
				-- 神兵
				if not self.mFormationObj:slotEquipIsEmpty(self.mShowIndex, ResourcetypeSub.eBook) then
					local tempTreasure = self.mFormationObj:getSlotEquip(self.mShowIndex, resourcetypeSub)
					LayerManager.addLayer({
			            name = "equip.TreasureInfoLayer",
			            data = {
			                treasureInfo = tempTreasure,
			                needOpt = false,
			            },
			            cleanUp = false
			        })
				end
			elseif Utility.isPet(resourcetypeSub) then
				-- 外功秘籍
				if not self.mFormationObj:slotPetIsEmpty(self.mShowIndex) then
					local curId
			    	local petArray = {}
			    	for i=1, self.mFormationObj:getMaxSlotCount() - 1 do
			    		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(i)
			    		if slotInfo and slotInfo.Pet and slotInfo.Pet.Id then
			    			local petData = slotInfo["Pet"]
			    			table.insert(petArray, petData)
			    			if i == self.mShowIndex then
			    				curId = petData.Id
			    			end
			    		end
			    	end
			    	if curId then
						LayerManager.addLayer({
				            name = "pet.PetInfoLayer",
				            data = {
				            	formationObj = self.mFormationObj,
				                petId = curId,
				                petList = petArray,
				                needOpt = false,
				            },
				            cleanUp = false,
				        })
				    end
				end
			else
				-- 装备
				if not self.mFormationObj:slotEquipIsEmpty(self.mShowIndex, resourcetypeSub) then
					LayerManager.addLayer({
			            name = "equip.EquipInfoLayer",
			            data = {
			                equipItem = self.mFormationObj:getSlotEquip(self.mShowIndex, resourcetypeSub),
			            },
			            cleanUp = false
			        })
				end
			end
		end,
	})
	self.mEquipView:setAnchorPoint(cc.p(0.5, 1))
	self.mEquipView:setPosition(320, 1000)
	self.mSubParent:addChild(self.mEquipView)

	-- 创建卡槽属性
	self.mSlotBriefView = require("team.teamSubView.SlotBriefView"):create({
		viewSize = cc.size(640, 220),
    	showSlotId = self.mShowIndex,
        formationObj = self.mFormationObj,
	})
	self.mSlotBriefView:setPosition(320, 200)
	self.mSubParent:addChild(self.mSlotBriefView)

	-- 创建返回按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(585, 990)
	self.mParentLayer:addChild(self.mCloseBtn)

	-- 创建卡槽人物名称、等级、战力等属性
	self:createAtrrView()
end

-- 创建小伙伴信息
function OtherTeamLayer:createMateInfo()
	self.mSubParent:removeAllChildren()

	-- 创建小伙伴信息View
    self.mMateInfoView = require("team.teamSubView.MateInfoView"):create({
        formationObj = self.mFormationObj,
        viewSize = cc.size(640, 920),
        clickCallback = function(slotIndex, isMateSlot)
        end
    })
    self.mMateInfoView:setAnchorPoint(cc.p(0.5, 1))
	self.mMateInfoView:setPosition(320, 1020)
    self.mSubParent:addChild(self.mMateInfoView)
end

-- 创建卡槽人物名称、等级、战力等属性
function OtherTeamLayer:createAtrrView()
	self.mHeroInfoNode = cc.Node:create()
	self.mSubParent:addChild(self.mHeroInfoNode)

	-- 创建人物的名字
	local _, _, nameLabel = Figure.newNameAndStar({
		parent = self.mHeroInfoNode,
		position = cc.p(320, 1050),
		})

	-- 创建绝学的名字
	local otherPlayerInfo = self.mFormationObj:getThisPlayerInfo()
	local fashionModelId = otherPlayerInfo.FashionModelId or 0
	local fashionModel = FashionModel.items[fashionModelId]
	local strFahion, fashionColor = "", nil
	if (fashionModel ~= nil) then
		local fashionStep = otherPlayerInfo.FashionStep or 0
		strFahion, fashionColor = fashionModel.name, Utility.getQualityColor(fashionModel.quality, 1)
		if (fashionStep > 0) then
			strFahion = strFahion .. "+" .. fashionStep
		end
	end
	local fashionNameLabel = ui.newLabel({
        text = strFahion,
        size = 24,
        color = fashionColor,
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
    })
    fashionNameLabel:setAnchorPoint(cc.p(0.5, 1))
    fashionNameLabel:setPosition(320, 955)
    self.mHeroInfoNode:addChild(fashionNameLabel)

	-- 创建卡槽的战力
	local FAPBgSprite = ui.newFAPView()
	FAPBgSprite:setPosition(320, 420)
	self.mHeroInfoNode:addChild(FAPBgSprite)

	-- 查看其他属性的按钮
	local tempBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("其他属性"),
		clickAction = function()
            -- 获取玩家的等级
            local firstSlot = self.mFormationObj:getSlotInfoBySlotId(1)
            local firstLv = firstSlot.Hero.Lv
			LayerManager.addLayer({
				name = "team.OtherMoreLayer",
				data = {
					showIndex = self.mShowIndex,
					formationObj = self.mFormationObj,
                    playerLv = firstLv,
				},
				cleanUp = false,
			})
		end
	})
	tempBtn:setPosition(320, 350)
	self.mHeroInfoNode:addChild(tempBtn)

	-- 刷新人物信息（名字、战力、星数）
	self.mHeroInfoNode.refresh = function()
		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowIndex)
		local haveHero = Utility.isEntityId(slotInfo.HeroId)
		self.mHeroInfoNode:setVisible(haveHero)

		if haveHero then
			local heroInfo = slotInfo.Hero
			local tempModel = HeroModel.items[slotInfo.ModelId]
			local strName, tempStep = ConfigFunc:getHeroName(slotInfo.ModelId, {heroStep = heroInfo.Step, IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder, playerName = self.mFormationObj:getThisPlayerInfo().Name})
			local strText = TR("等级%d  %s%s", heroInfo.Lv, Utility.getQualityColor(tempModel.quality, 2), strName)
			if (tempStep > 0) then
				strText = strText .. Enums.Color.eYellowH .. "  +" .. tempStep
			end
			nameLabel:setString(strText)
			-- 战力
			FAPBgSprite.setFAP(self.mFormationObj:getSlotAttrByName(self.mShowIndex, "FAP"))
			-- 绝学
			fashionNameLabel:setVisible(tempModel.specialType == Enums.HeroType.eMainHero)
		end
	end
	self.mHeroInfoNode.refresh()
end

-- 当选中的卡槽改变后的处理逻辑
function OtherTeamLayer:dealSelectChange()
	if not tolua.isnull(self.mFigureView) then
		self.mFigureView:changeShowSlot(self.mShowIndex)
	end
	if not tolua.isnull(self.mSmallHeadView) then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end
	if not tolua.isnull(self.mEquipView) then
		self.mEquipView:changeShowSlot(self.mShowIndex)
	end
	if not tolua.isnull(self.mSlotBriefView) then
		self.mSlotBriefView:changeShowSlot(self.mShowIndex)
	end
	if not tolua.isnull(self.mHeroInfoNode) then
		self.mHeroInfoNode:refresh()
	end
end

return OtherTeamLayer
