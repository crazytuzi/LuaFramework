--[[
    文件名: TeamEquipLayer.lua
	描述: 队伍的装备页面，根据人物卡槽导航查看并操作各个装备（镶嵌、强化、进阶、更换等）
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local TeamEquipLayer = class("TeamEquipLayer", function(params)
    return display.newLayer()
end)

--[[
	params: 参数列表
	{
		showIndex: 可选参数，进入阵容后直接显示的人物（1是主角，2~6是普通人物）
		resourcetypeSub: 当前显示的装备类型
		defaultTag: 默认打开页面，不传任何参数的话，默认是强化页面
	}
]]
function TeamEquipLayer:ctor(params)
	self.mShowIndex = params and params.showIndex or 1 -- 默认显示卡槽的index
	self.mResourcetypeSub = params and params.resourcetypeSub or ResourcetypeSub.eClothes
	self.resStarItem = params and params.resStarItem
	-- 上阵卡槽数，包含小伙伴入口
	self.mSlotMaxCount = FormationObj:getMaxSlotCount()

	-- 操作按钮对象列表
	self.mOperateBtnList = {}
	-- 当前是否正在显示强化内容
	self.defaultTag = params.defaultTag or ModuleSub.eEquipLvUp

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

    -- 当选中的卡槽改变后的处理逻辑
	self:dealSelectChange()
end

-- 初始化页面控件
function TeamEquipLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 页面顶部的人物头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
        needPet = false, -- 是否需要外功秘籍按钮，默认为true
        needMate = false, -- 不需要小伙伴
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
        viewSize = cc.size(620, 106),
        bgImgName = "c_01.png",
        onClickItem = function(slotIndex)
        	-- 该卡槽未开启，则需要提示用户去点星
        	if not FormationObj:slotIsOpen(slotIndex) then
        		MsgBoxLayer.gotoLightenStarHintLayer(slotIndex, false, FormationObj)
        		return
        	end
        	self.mShowIndex = slotIndex

        	-- 当选中的卡槽改变后的处理逻辑
			self:dealSelectChange()

        	-- 如果是阵容卡槽并且未上阵人物，则需要打开选择人物页面
        	if FormationObj:slotIsEmpty(slotIndex) then
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

    -- 装备大图展示
    self.mFigureView = require("team.teamSubView.TeamEquipView"):create({
    	showSlotId = self.mShowIndex,
    	showEquipType = self.mResourcetypeSub,
        onSelectChange = function(slotIndex)
			self.mShowIndex = slotIndex
         	self:dealSelectChange()
		end,
		onClickItem = function(slotIndex, equipType)
			if FormationObj:slotIsEmpty(slotIndex) then
				-- 上阵侠客
				LayerManager.addLayer({name = "team.TeamSelectHeroLayer", data = {slotId = slotIndex, alwaysIdList = {}}})
			else
				local tempEquip = FormationObj:getSlotEquip(slotIndex, equipType)
        		if (not tempEquip) or (not Utility.isEntityId(tempEquip.Id)) then
					-- 上阵装备
					LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {slotId = slotIndex, resourcetypeSub = equipType, alwaysIdList = {}}})
				else
					-- 查看装备
					LayerManager.addLayer({name = "equip.EquipInfoLayer", data = {equipId = tempEquip.Id}, cleanUp = false})
				end
			end
		end,
	})
	self.mFigureView:setAnchorPoint(cc.p(0.5, 0))
	self.mFigureView:setPosition(320, 610)
	self.mParentLayer:addChild(self.mFigureView)

    -- 装备卡牌展示
	self.mEquipView = require("team.teamSubView.SlotEquipView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        selectType = self.mResourcetypeSub,
        onlyShowEquip = true,
        formationObj = FormationObj,
		onClickItem = function(resourcetypeSub)
			-- 判断人物是否为空
			local currSlotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
			if not Utility.isEntityId(currSlotInfo and currSlotInfo.HeroId) then
				return
			end

			self.mResourcetypeSub = resourcetypeSub
			self:dealSelectChange()
			-- 如果该卡槽尚未穿戴装备，则打开装备上阵页面
			if FormationObj:slotEquipIsEmpty(self.mShowIndex, resourcetypeSub) then
				LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {
					slotId = self.mShowIndex,
	        		resourcetypeSub = resourcetypeSub,
	        		alwaysIdList = {},
				}})
			end
		end,
	})
	self.mEquipView:setAnchorPoint(cc.p(0.5, 1))
	self.mEquipView:setPosition(320, 1020)
	self.mParentLayer:addChild(self.mEquipView)

	-- 创建返回按钮
	local mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	mCloseBtn:setPosition(470, 930)
	self.mParentLayer:addChild(mCloseBtn, 1)
    -- 保存按钮，引导使用
    self.mCloseBtn = mCloseBtn

	-- 创建人物名称等基本信息
	self:createEquipInfo()

	-- 创建培养信息
	self:createTrainInfo()
end

-- 获取恢复该页面的参数
function TeamEquipLayer:getRestoreData()
	local retData = {}
	retData.showIndex = self.mShowIndex
	retData.resourcetypeSub = self.mResourcetypeSub
	retData.defaultTag = self.defaultTag
	retData.resStarItem = self.resStarItem

	return retData
end

-- 创建装备信息
function TeamEquipLayer:createEquipInfo()
	self.mEquipInfoNode = cc.Node:create()
	self.mParentLayer:addChild(self.mEquipInfoNode)

	-- 创建装备的名字
    local mNameLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = "",
        fontSize = 24,
        fontColor = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        outlineSize = 2,
    })
    mNameLabel:setAnchorPoint(cc.p(0.5, 1))
    mNameLabel:setPosition(320, 1020)
    self.mEquipInfoNode:addChild(mNameLabel)

	-- 更换按钮
	local btnChange = ui.newButton({
		normalImage = "tb_48.png",
		clickAction = function()
			LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {
				slotId = self.mShowIndex,
        		resourcetypeSub = self.mResourcetypeSub,
        		alwaysIdList = {},
			}})
		end
	})
	btnChange:setAnchorPoint(cc.p(0.5, 0))
	btnChange:setPosition(200, 580)
	self.mEquipInfoNode:addChild(btnChange)

    -- 宝石镶嵌按钮
    local imprintBtn = ui.newButton({
        normalImage = "bs_9.png",
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eImprint, true) then
                return
            end
            LayerManager.addLayer({name = "hero.ImprintMainLayer", data = {
                slotId = self.mShowIndex,
                partId = self.mResourcetypeSub,
            }})
        end
    })
    imprintBtn:setAnchorPoint(cc.p(0.5, 0))
    imprintBtn:setPosition(320, 580)
    self.mEquipInfoNode:addChild(imprintBtn)

	-- 共鸣按钮
	local btnMaster = ui.newButton({
		normalImage = "tb_49.png",
		clickAction = function()
			if (ConfigFunc:canEnterEquipMaster() == false) then
				return
			end
			LayerManager.addLayer({
                name = "equip.EquipMasterLayer",
                data = {
                	-- 共鸣没有强化，所以这里要处理一下
                	defaultTag = (self.defaultTag == ModuleSub.eEquipStarUp) and ModuleSub.eEquipStarUp or nil,
                	resourcetypeSub = self.mResourcetypeSub,
                },
            })
		end
	})
	btnMaster:setAnchorPoint(cc.p(0.5, 0))
	btnMaster:setPosition(440, 580)
	self.mEquipInfoNode:addChild(btnMaster)

	-- 刷新装备信息（名字、星级、大图等）
	self.mEquipInfoNode.refresh = function()
		if self.mEquipInfoNode.mStarNode then
			self.mEquipInfoNode.mStarNode:removeFromParent()
			self.mEquipInfoNode.mStarNode = nil
		end

		-- 刷新大图列表
		self.mFigureView:changeShowSlot(self.mShowIndex, self.mResourcetypeSub)

		-- 刷新属性显示
		if FormationObj:slotEquipIsEmpty(self.mShowIndex, self.mResourcetypeSub) then
			self.mEquipInfoNode:setVisible(false)
		else
			local tempEquip = FormationObj:getSlotEquip(self.mShowIndex, self.mResourcetypeSub)
			local tempModel = EquipModel.items[tempEquip.modelId]
			local hColor = Utility.getQualityColor(tempModel.quality, 2)
			mNameLabel:setString(string.format("[%s]%s%s", ResourcetypeSubName[tempModel.typeID], hColor, tempModel.name))

			-- 播放特效
			if (self.needPlayEffect ~= nil) then
				ui.newEffect({
					parent = self.mParentLayer,
			        effectName = self.needPlayEffect.name,
			        position = self.needPlayEffect.pos,
			        zorder = 1,
			        loop = false,
			        endRelease = true,
			    })
			    self.needPlayEffect = nil
			end

			-- 显示星级
			self.mEquipInfoNode.mStarNode = Figure.newEquipStarLevel({
				parent = self.mEquipInfoNode,
				anchorPoint = cc.p(0.5, 1),
				position = cc.p(320, 965),
				guid = tempEquip.Id,
			})

			self.mEquipInfoNode:setVisible(true)
		end
	end
	self.mEquipInfoNode.refresh()
end

-- 创建培养信息
function TeamEquipLayer:createTrainInfo()
    self.mTrainViewList = {}
	self.mTrainInfoNode = cc.Node:create()
	self.mParentLayer:addChild(self.mTrainInfoNode)

	-- 显示背景图
	local bgSize = cc.size(640, 530)
    local bgSprite = ui.newScale9Sprite("c_19.png", bgSize)
    bgSprite:setAnchorPoint(0.5, 0)
    bgSprite:setPosition(320, 0)
    self.mTrainInfoNode:addChild(bgSprite, 1)
    self.mTrainInfoNode.bgSprite = bgSprite

    -- 刷新培养信息
    self.mTrainInfoNode.refresh = function(target)
		target.bgSprite:removeAllChildren()

		-- 判断是否上阵
		if FormationObj:slotEquipIsEmpty(self.mShowIndex, self.mResourcetypeSub) then
			local infoLabel = ui.newLabel({
				text = TR("该卡槽没有上阵装备"),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 30,
			})
			infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
			infoLabel:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5 + 50))
			target.bgSprite:addChild(infoLabel)
			return
		end

		local viewSrcList = {
			[ModuleSub.eEquipLvUp] = "equip.SubEquipLvUpView",
			[ModuleSub.eEquipStarUp] = "equip.SubEquipStarUpView",
			[ModuleSub.eEquipStepUp] = "equip.SubEquipStepUpView",
		}
		local tempEquip = FormationObj:getSlotEquip(self.mShowIndex, self.mResourcetypeSub)
		local mSubView = require(viewSrcList[self.defaultTag]):create({
			parentName = "team.TeamEquipLayer",
			resStarItem = self.resStarItem,
	        viewSize = cc.size(bgSize.width, bgSize.height - 100),
	        equipId = tempEquip.Id,
            parent =  self,
	        callback = function(responseType)
	        	-- 显示特效
                if responseType == ModuleSub.eEquipLvUp then
                elseif responseType == ModuleSub.eEquipStarUp then
                	self.needPlayEffect = {name = "effect_ui_zhuangbeishengxing", pos = cc.p(315, 725)}
                elseif responseType == ModuleSub.eEquipStepUp then
                	self.needPlayEffect = {name = "effect_ui_zhuangbeishengjie", pos = cc.p(310, 732)}
                end
                
                -- 刷新页面
	        	self:dealSelectChange()

                -- 播放音效
                if responseType == ModuleSub.eEquipLvUp then
                    self.mEquipView:palyLevelUpEffectAudio(self.mResourcetypeSub)
                end
	        end,
	    })
	    mSubView:setPosition(0, 100)
	    target.bgSprite:addChild(mSubView)
        -- 保存属性结点，引导使用
        self.mTrainViewList[self.defaultTag] = mSubView
	end

	-- 显示Tab
	local buttonInfos = {
		{
			tag = ModuleSub.eEquipLvUp,
			text = TR("强化"),
		},
        {
            tag = ModuleSub.eEquipStepUp,
            text = TR("锻造"),
        },
		{
			tag = ModuleSub.eEquipStarUp,
			text = TR("升星"),
		},
	}
	local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        btnSize = cc.size(122, 56), 
        defaultSelectTag = self.defaultTag,
        needLine = false,
        onSelectChange = function (tag)
        	self.defaultTag = tag
            self.mTrainInfoNode:refresh()
            -- 执行子界面新手引导
            if self.mTrainViewList[tag] and self.mTrainViewList[tag].executeGuide then
                self.mTrainViewList[tag]:executeGuide()
            end
        end,
        allowChangeCallback = function (tag)
            return ModuleInfoObj:moduleIsOpen(tag, true)
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(cc.p(320, 510))
    self.mTrainInfoNode:addChild(tabLayer)
    -- 保存新手引导使用
    self.equipTabLayer = tabLayer
end

-- 当选中的卡槽改变后的处理逻辑
function TeamEquipLayer:dealSelectChange()
	local isTeamSlot = self.mShowIndex > 0 and self.mShowIndex < self.mSlotMaxCount  -- 是阵容卡槽
	if isTeamSlot then  -- 阵容卡槽
		if self.mEquipView then
			self.mEquipView:changeShowSlot(self.mShowIndex)
		end

		if self.mEquipInfoNode then
			self.mEquipInfoNode:refresh()
		end

		if self.mTrainInfoNode then
			self.mTrainInfoNode:refresh()
		end
	end

	if self.mSmallHeadView then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end

	-- 清空升星的选择材料
	self.resStarItem = nil
end

-- ========================== 新手引导 ===========================
function TeamEquipLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function TeamEquipLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 点击锻造按钮
        [11804]  = {clickNode = self.equipTabLayer:getTabBtnByTag(ModuleSub.eEquipStepUp)},
    })
end

return TeamEquipLayer
