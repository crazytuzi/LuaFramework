--[[
    文件名: TeamLayer.lua
	描述: 队伍主页面
	创建人: peiyaoqiang
	创建时间: 2016.5.4
--]]

local TeamLayer = class("TeamLayer", function(params)
    return display.newLayer()
end)

-- 模块内部消息
local SelectSlotChange = "eTeamLayerSelectSlotChange"  -- 选中卡槽改变的事件名称

-- 操作按钮的标记
local tagOfOptBtn = {
	eOnekeyLvup = 1, 	-- 一键强化
	eOnekeyCombat = 2, 	-- 一键装备
	eMaster = 3, 		-- 培养共鸣
	eHeroLvUp = 4, 		-- 人物培养
	eZhenjue = 5, 		-- 内功心法
	eFashion = 6, 		-- 绝学/更换
	eZyExchange = 7,	-- 真元兑换
	eZyCombat = 8,		-- 真元一键装备
	eZyQihai = 9,		-- 真元气海
}

-- 初始化函数
--[[
	params: 参数列表
	{
		showIndex: 可选参数，进入阵容后直接显示的人物（1是主角，2~6是普通人物, 7是小伙伴）
	}
--]]
function TeamLayer:ctor(params)
	-- 设置默认显示的卡槽index
	if params and params.showIndex then
		self.mShowIndex = params.showIndex
	else
		-- 默认是1
		self.mShowIndex = 1
		for i=1,6 do
			-- 找到第1个已经开放且没有上阵的空卡槽
			if FormationObj:slotIsOpen(i) and FormationObj:slotIsEmpty(i) then
				self.mShowIndex = i
				break
			end
		end
        -- 新手引导时指定显示位置
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID == 10302 then
            self.mShowIndex = 2 --引导第一个主将升10级
        elseif eventID == 10308 or eventID == 10402 or eventID == 11802 or eventID == 7003 then
            self.mShowIndex = 1 --引导主角进行突破或装备锻造
        end
	end
	-- 是否直接显示真元列表
	self.mZhenYuanVisible = params.showZhenYuan or false
	-- 阵容最大的卡槽数
	self.mSlotMaxCount = FormationObj:getMaxSlotCount()

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self.redDotBtnList = {}
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 切换页面
    self:changePage()
end

-- 初始化页面控件
function TeamLayer:initUI()
	-- 添加背景相关节点
	local bgLayer = ui.newSprite("zr_07.jpg")
	bgLayer:setPosition(320, 568)
	self.mParentLayer:addChild(bgLayer)

	-- 卡槽信息子页面的父节点
    self.mSlotParent = cc.Node:create()
    self.mParentLayer:addChild(self.mSlotParent)
    -- 小伙伴信息子页面的父节点
    self.mMateParent = cc.Node:create()
    self.mParentLayer:addChild(self.mMateParent)

    -- 页面顶部的人物头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
    	--needPet = false,
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
        viewSize = cc.size(620, 106),
        bgImgName = "c_01.png",
        checkReddotId = Enums.ClientRedDot.eTeamHeader,
        onClickItem = function(slotIndex)
        	-- 外功技能
        	if slotIndex == 0 then
        		LayerManager.addLayer({name = "team.PetCampLayer",})
        		return
        	end

        	-- 其他卡槽点击处理
        	local isTeamSlot = slotIndex > 0 and slotIndex < self.mSlotMaxCount  -- 是阵容卡槽
        	if isTeamSlot and not FormationObj:slotIsOpen(slotIndex) then
        		-- 如果不是小伙伴卡槽，并且该卡槽未开启，则需要提示用户去点星
        		MsgBoxLayer.gotoLightenStarHintLayer(slotIndex, false, FormationObj)
        		return
        	end
        	self.mShowIndex = slotIndex
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

-- 获取恢复数据
function TeamLayer:getRestoreData()
	local retData = {
		showIndex = self.mShowIndex,
		showZhenYuan = self.mZhenYuanVisible,
	}

	return retData
end

-- 切换页面
function TeamLayer:changePage()
	self.mSlotParent:setVisible(false)
	self.mMateParent:setVisible(false)

	if (self.mShowIndex == self.mSlotMaxCount) then
		-- 小伙伴
		self.mMateParent:setVisible(true)
		self:createMateView()
	else
		-- 阵容
		self.mSlotParent:setVisible(true)
		self.mMateParent:removeAllChildren() -- 因为小伙伴页面加了屏蔽下层点击，所以这里要将其删除
		self:createSlotView()
	end
	self:dealSelectChange()
end

-- 当选中的卡槽改变后的处理逻辑
function TeamLayer:dealSelectChange()
	local isTeamSlot = self.mShowIndex > 0 and self.mShowIndex < self.mSlotMaxCount  -- 是阵容卡槽
	if isTeamSlot then  -- 阵容卡槽
		if self.mFigureView then
			self.mFigureView:changeShowSlot(self.mShowIndex)
		end
		if self.mEquipView then
			self.mEquipView:changeShowSlot(self.mShowIndex)
		end
		if self.mZhenyuanView then
			self.mZhenyuanView:changeShowSlot(self.mShowIndex)
		end
		if self.mSlotBriefView then
			self.mSlotBriefView:changeShowSlot(self.mShowIndex)
		end
		if self.mHeroInfoNode then
			self.mHeroInfoNode.refresh()
		end

		-- 修改绝学／更换按钮的状态
		self.redDotBtnList[tagOfOptBtn.eFashion]:setTitleText((self.mShowIndex == 1) and TR("绝学") or TR("更换"))

		-- 显示/隐藏真元的信息
		local equipBtnList = {tagOfOptBtn.eOnekeyLvup, tagOfOptBtn.eOnekeyCombat, tagOfOptBtn.eMaster}
		local zhenyuanBtnList = {tagOfOptBtn.eZyExchange, tagOfOptBtn.eZyCombat, tagOfOptBtn.eZyQihai}
		local isShowZhenyuan = (self.mZhenYuanVisible ~= nil) and (self.mZhenYuanVisible == true)
		for _,v in ipairs(equipBtnList) do
			self.redDotBtnList[v]:setVisible(not isShowZhenyuan)
		end
		for _,v in ipairs(zhenyuanBtnList) do
			self.redDotBtnList[v]:setVisible(isShowZhenyuan)
		end
		self.mEquipView:setVisible(not isShowZhenyuan)
		self.mZhenyuanView:setVisible(isShowZhenyuan)
	end

	if self.mSmallHeadView then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end

	-- 通知选中卡槽改变
	Notification:postNotification(SelectSlotChange)

    if self.mHeroFashionBtn then
        self.mHeroFashionBtn:setVisible(not (self.mShowIndex == 1))
    end
    if self.mFashionBtn then
        self.mFashionBtn:setVisible(self.mShowIndex == 1)
    end
end

-- 创建卡槽相关控件
function TeamLayer:createSlotView()
	if self.mSlotParent:getChildrenCount() > 0 then
		return
	end

	-- 创建人物形象列表
	local mFigureView = require("team.teamSubView.TeamFigureView"):create({
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
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10207 then
                    Guide.manager:nextStep(eventID)
                    Guide.manager:removeGuideLayer()
                end

                LayerManager.addLayer({name = "team.TeamSelectHeroLayer",
        			data = {
        				slotId = slotIndex,
        				alwaysIdList = {},
        			}
        		})
        	else
        		local tempData = {
        			heroId = FormationObj:getSlotInfoBySlotId(slotIndex).HeroId,
        			onlyViewInfo = false,
        		}
        		LayerManager.addLayer({name = "hero.HeroInfoLayer", data = tempData})
        	end
		end,
	})
	mFigureView:setAnchorPoint(cc.p(0.5, 1))
	mFigureView:setPosition(320, 1000)
	self.mSlotParent:addChild(mFigureView)
	self.mFigureView = mFigureView

	-- 创建装备卡牌展示
	local mEquipView = require("team.teamSubView.SlotEquipView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
		onClickItem = function(resourcetypeSub)
			-- 判断人物是否为空
			local currSlotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
			if not Utility.isEntityId(currSlotInfo and currSlotInfo.HeroId) then
				return
			end

			-- 上阵或查看详情
			if Utility.isTreasure(resourcetypeSub) then
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 11202 then
                    -- 特殊处理，直接跳去神兵锻造，并指定判官笔
                    Guide.manager:nextStep(eventID)
                    LayerManager.showSubModule(ModuleSub.eChallengeGrab, {modelId = 15032601})
                    return
                elseif eventID == 112091 or eventID == 11301 then
                    Guide.manager:removeGuideLayer()
                    Guide.manager:nextStep(eventID)
                end
				-- 神兵
				if FormationObj:slotEquipIsEmpty(self.mShowIndex, ResourcetypeSub.eBook) then
					LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {
						slotId = self.mShowIndex,
		        		resourcetypeSub = resourcetypeSub,
		        		alwaysIdList = {},
					}})
				else
					local tempTreasure = FormationObj:getSlotEquip(self.mShowIndex, resourcetypeSub)
					LayerManager.addLayer({
			            name = "equip.TreasureInfoLayer",
			            data = {
			                treasureInfo = TreasureObj:getTreasure(tempTreasure.Id),
			                treasureModelID = tempTreasure.modelId,
			                needOpt = true,
			            },
			            cleanUp = false
			        })
				end
			elseif Utility.isPet(resourcetypeSub) then
				-- 外功秘籍
				if FormationObj:slotPetIsEmpty(self.mShowIndex) then
					if not ModuleInfoObj:moduleIsOpen(ModuleSub.ePet, true) then
						return
					end
					LayerManager.addLayer({name = "team.TeamSelectPetLayer", data = {
	    				slotId = self.mShowIndex,
	    				alwaysIdList = {},
	    			}})
				else
			        local curId
			    	local petArray = {}
			    	for i=1, FormationObj:getMaxSlotCount() - 1 do
			    		local slotInfo = FormationObj:getSlotPet(i)
			    		if slotInfo then
			    			local petData = PetObj:getPet(slotInfo.Id)
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
				                petId = curId,
				                petList = petArray,
				                needOpt = true,
				            },
				            cleanUp = false,
				            --needRestore = true,
				        })
				    end
				end
			else
				-- 装备
				if FormationObj:slotEquipIsEmpty(self.mShowIndex, resourcetypeSub) then
					LayerManager.addLayer({name = "team.TeamSelectEquipLayer", data = {
						slotId = self.mShowIndex,
		        		resourcetypeSub = resourcetypeSub,
		        		alwaysIdList = {},
					}})
				else
                    --[[--------新手引导--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 11803 then
                        Guide.manager:nextStep(eventID)
                    end
					LayerManager.addLayer({name = "team.TeamEquipLayer", data = {
						showIndex = self.mShowIndex,
						resourcetypeSub = resourcetypeSub,
					}})
				end
			end
		end,
	})
	mEquipView:setAnchorPoint(cc.p(0.5, 1))
	mEquipView:setPosition(320, 1000)
	self.mSlotParent:addChild(mEquipView)
	self.mEquipView = mEquipView

	-- 创建装备卡牌展示
	local mZhenyuanView = require("team.teamSubView.SlotZhenyuanView"):create({
    	viewSize = cc.size(640, 600),
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
		onClickItem = function(zhenyuanSlotIndex, posIndex)
			-- 判断人物是否为空
			local currSlotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
			if not Utility.isEntityId(currSlotInfo and currSlotInfo.HeroId) then
				return
			end

			-- 判断卡槽是否开启
			if not ConfigFunc:getZhenyuanGridIsOpen(currSlotInfo.HeroId, zhenyuanSlotIndex) then
				local needQuenchNum = ConfigFunc:getZhenyuanGridOpenConfig(zhenyuanSlotIndex)
			    local tempStr = TR("%s%s%s才能开启该卡槽,是否前往？", Enums.Color.eNormalGreenH, Utility.getQuenchName(needQuenchNum), Enums.Color.eNormalWhiteH)
			    -- if posIndex > 6 then 
			    -- 	tempStr = TR("至少开启三个真元卡槽才能开启该卡槽,是否前往？")
			    -- end 
			    local okBtnInfo = {
			        text = TR("前往"),
			        clickAction = function(layerObj, btnObj)
			            LayerManager.removeLayer(layerObj)

			            -- 跳转到淬体
			            local originalTag = ModuleSub.eHeroQuench
		                LayerManager.showSubModule(originalTag, {
					        originalTag = originalTag,
					        originalId = FormationObj:getSlotInfoBySlotId(self.mShowIndex).HeroId,
					    })
			        end,
			    }
			    MsgBoxLayer.addOKLayer(tempStr, TR("提示"), {okBtnInfo}, {})
				return
			end

			-- 判断真元是否上阵
			local zhenyuanInfo = currSlotInfo.ZhenYuan[posIndex]
			if (zhenyuanInfo ~= nil) and Utility.isEntityId(zhenyuanInfo.Id) then
				-- 查看详情
				LayerManager.addLayer({
		            name = "zhenyuan.ZhenyuanInfoLayer",
		            data = {
		                zhenyuanInfo = ZhenyuanObj:getZhenyuan(zhenyuanInfo.Id), -- 阵容卡槽里的数据变化滞后，所以这里获取最新数据显示
		                onlyViewInfo = false,
		            },
		            cleanUp = false
		        })
			else
				-- 选择上阵
				LayerManager.addLayer({name = "team.TeamSelectZhenyuanLayer", data = {
					slotId = self.mShowIndex,
	        		currZhenyuanIndex = posIndex,
				}})
			end
		end,
	})
	mZhenyuanView:setAnchorPoint(cc.p(0.5, 1))
	mZhenyuanView:setPosition(320, 1000)
	self.mSlotParent:addChild(mZhenyuanView)
	self.mZhenyuanView = mZhenyuanView
	
	-- 创建卡槽属性
	local mSlotBriefView = require("team.teamSubView.SlotBriefView"):create({
		viewSize = cc.size(640, 220),
    	showSlotId = self.mShowIndex,
        formationObj = FormationObj,
	})
	mSlotBriefView:setPosition(320, 200)
	self.mSlotParent:addChild(mSlotBriefView)
	self.mSlotBriefView = mSlotBriefView

    -- 战力变化时刷新当前属性(有可能前后排加成变化)
    Notification:registerAutoObserver(self.mSlotBriefView, function(view)
            view:changeShowSlot(self.mShowIndex)
        end, EventsName.eSlotAttrChanged)

	-- 推荐阵容按钮
	local tempBtn = ui.newButton({
		normalImage = "tb_18.png",
		clickAction = function()
			LayerManager.addLayer({name = "team.RecommendFormationLayer",})
		end
	})
	tempBtn:setScale(0.85)
	tempBtn:setPosition(55, 980)
	tempBtn:setVisible(ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eSuccessRecommend))
	self.mSlotParent:addChild(tempBtn)

	-- 推荐阵容按钮的小红点
	local function dealRedDotVisible(redDotSprite)
		local redDotData = RedDotInfoObj:isValid(ModuleSub.eSuccessRecommend)
		redDotSprite:setVisible(redDotData)
	end
    ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eSuccessRecommend), refreshFunc = dealRedDotVisible})

    -- Q版时装按钮
	local tempBtn = ui.newButton({
		normalImage = "tb_346.png",
		clickAction = function()
			if not ModuleInfoObj:moduleIsOpen(ModuleSub.eQbanShizhuang, true) then
				return
			end
			LayerManager.addLayer({name = "fashion.QFashionLayer", cleanUp = false})
		end
	})
	tempBtn:setScale(0.85)
	tempBtn:setPosition(135, 980)
	tempBtn:setVisible(ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eQbanShizhuang))
	self.mSlotParent:addChild(tempBtn)
	self.mFashionBtn = tempBtn

	-- 时装按钮的小红点
	local function dealRedDotVisible(redDotSprite)
		local redDotData = RedDotInfoObj:isValid(ModuleSub.eQbanShizhuang)
		redDotSprite:setVisible(redDotData)
	end
    ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eQbanShizhuang), refreshFunc = dealRedDotVisible})

    -- 侠客时装按钮
    local tempBtn = ui.newButton({
        normalImage = "tb_346.png",
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eHeroFashion, true) then
                return
            end
            
            local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
            if not Utility.isEntityId(slotInfo.HeroId) then
                ui.showFlashView(TR("请先上阵侠客"))
                return
            end
            
            -- local heroInfo = HeroObj:getHero(slotInfo.HeroId)
            -- local heroModelId = heroInfo.ModelId
            -- if heroInfo.IllusionModelId > 0 then
            --     heroModelId = heroInfo.IllusionModelId
            -- end
            -- if not HeroFashionRelation.items[heroModelId] then
            --     ui.showFlashView(TR("该侠客还没开放时装"))
            --     return
            -- end

            LayerManager.addLayer({name = "fashion.HeroFashionHomeLayer", data = {heroId = slotInfo.HeroId, callback = function ()
                self.mFigureView:refreshShowSlot(self.mShowIndex)
            end}, cleanUp = false})
        end
    })
    tempBtn:setScale(0.85)
    tempBtn:setPosition(135, 980)
    tempBtn:setVisible(ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eHeroFashion))
    self.mSlotParent:addChild(tempBtn)
    self.mHeroFashionBtn = tempBtn

    -- 时装按钮的小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eHeroFashion)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eHeroFashion), refreshFunc = dealRedDotVisible})


    -- 布阵按钮
	local tempBtn = ui.newButton({
		normalImage = "tb_11.png",
		clickAction = function()
			LayerManager.addLayer({name = "team.CampLayer", cleanUp = false,})
		end
	})
	tempBtn:setAnchorPoint(cc.p(0.5, 0.5))
	tempBtn:setPosition(590, 980)
	tempBtn:setScale(0.85)
	self.mSlotParent:addChild(tempBtn)

	-- 创建操作按钮
	self:createOptBtn()
	-- 创建卡槽人物名称、等级、战力等属性
	self:createHeroInfo()
end

-- 创建小伙伴信息的相关控件
function TeamLayer:createMateView()
	self.mMateParent:removeAllChildren()

	-- 创建小伙伴信息View
    local mMateInfoView = require("team.teamSubView.MateInfoView"):create({
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
                if FormationObj:mateSlotIsVipOpen(slotIndex) then -- Vip开启的小伙伴卡槽
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
    mMateInfoView:setAnchorPoint(cc.p(0.5, 1))
	mMateInfoView:setPosition(320, 1020)
    self.mMateParent:addChild(mMateInfoView)
end

-- 创建卡槽人物名称、等级、战力等属性
function TeamLayer:createHeroInfo()
	self.mHeroInfoNode = cc.Node:create()
	self.mSlotParent:addChild(self.mHeroInfoNode)

	-- 创建人物的名字
	local _, _, nameLabel = Figure.newNameAndStar({
		parent = self.mHeroInfoNode,
		position = cc.p(320, 1050),
		})

	-- 创建绝学的名字
	local fashionModelId = PlayerAttrObj:getPlayerAttrByName("FashionModelId") or 0
	local fashionModel = FashionModel.items[fashionModelId]
	local strFahion, fashionColor = "", nil
	if (fashionModel ~= nil) then
		local fashionStep = FashionObj:getOneItemStep(fashionModelId) or 0
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
			nameLabel:setString(strText)
			-- 设置战力
			FAPBgSprite.setFAP(FormationObj:getSlotAttrByName(self.mShowIndex, "FAP"))
			-- 设置绝学
			fashionNameLabel:setVisible(tempModel.specialType == Enums.HeroType.eMainHero)
		end
	end
	self.mHeroInfoNode.refresh()
end

-- 创建操作按钮
function TeamLayer:createOptBtn()
	-- 真元按钮列表
	local zyBtnInfos = {
		{
			normalImage = "c_27.png",
			text = TR("练气"),
			optBtnTag = tagOfOptBtn.eZyExchange,
			btnPos = cc.p(120, 380),
			clickAction = function()
				LayerManager.addLayer({name = "zhenyuan.ZhenYuanTabLayer", data = {}})
			end
		},
		{
			normalImage = "c_27.png",
			text = TR("一键装备"),
			optBtnTag = tagOfOptBtn.eZyCombat,
			btnPos = cc.p(320, 380),
			clickAction = function()
				local onekeyData = SlotPrefObj:getOneKeyReplaceZhenyuan(self.mShowIndex)
				if not onekeyData or not next(onekeyData) then
            		return
            	end
            	local haveCombatData = false
            	-- 请求服务器接口的参数
				local tempData = {self.mShowIndex}
				local tempList = {}
				for k,v in pairs(onekeyData) do
					if Utility.isEntityId(v.Id) then
						haveCombatData = true
						tempList[tostring(k)] = v.Id
					end
				end
            	if not haveCombatData then
					ui.showFlashView(TR("没有更好的内功心法可以上阵"))
					return
				end
				table.insert(tempData, tempList)
				self:requestOneKeyZhenyuanCombat(tempData)
			end
		},
		{
			normalImage = "c_27.png",
			text = TR("气海"),
			optBtnTag = tagOfOptBtn.eZyQihai,
			btnPos = cc.p(520, 380),
			clickAction = function()
				LayerManager.addLayer({name = "zhenyuan.ZhenYuanTabLayer", data = {moduleSub = 3}})
			end
		},
	}

	-- 上排按钮列表
	local upBtnInfos = {
		{
			normalImage = "c_27.png",
			text = TR("一键强化"),
			optBtnTag = tagOfOptBtn.eOnekeyLvup,
			btnPos = cc.p(120, 380),
			clickAction = function()
                local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
				if not Utility.isEntityId(slotInfo.HeroId) then
					return
				end

			    local equpIdList, enoughGold = {}, false
			    local maxLv = PlayerAttrObj:getPlayerInfo().Lv * 2
			    local haveGold = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eGold)

				-- 处理该阵容卡槽的一种装备
				local function dealOneEquip(typeName)
					local tempEquip = slotInfo[typeName]
					if not tempEquip or not Utility.isEntityId(tempEquip.Id) or tempEquip.Lv >= maxLv then
						return
					end
					table.insert(equpIdList, tempEquip.Id)

					-- 判断铜钱是否够强化一次
					local equipBase = EquipModel.items[tempEquip.ModelId]
					local tmpUseGold = math.floor(EquipLvUpRelation.items[tempEquip.Lv].perExp * equipBase.upUseR)
					if (haveGold >= tmpUseGold) then
						enoughGold = true
					end
				end
				for _, typeName in pairs({"Weapon", "Helmet", "Clothes", "Necklace", "Pants", "Shoes"}) do
					dealOneEquip(typeName)
				end

				if #equpIdList == 0 then
			        ui.showFlashView(TR("没有装备可以继续升级"))
			        return
			    end

			    -- 判断铜币是否足够
			    if not enoughGold then
			        MsgBoxLayer.addGetGoldHintLayer()
			        return
			    end

			    -- 装备一键强化的数据请求
				self:requestOneKeyEquipLvUp(equpIdList)
			end
		},
		{
			normalImage = "c_27.png",
			text = TR("一键装备"),
			optBtnTag = tagOfOptBtn.eOnekeyCombat,
			btnPos = cc.p(320, 380),
			clickAction = function()
				local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
				if not slotInfo or not Utility.isEntityId(slotInfo.HeroId) then
					return
				end

                -- 没有最优装备时，不调接口
				local oneKeyItems = SlotPrefObj:getOneKeyReplaceEquip(self.mShowIndex)
				if not next(oneKeyItems) then
                    --[[--------新手引导容错--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10402 then
                        -- 跳到副本
                        Guide.manager:nextStep(eventID)
                        Guide.manager:nextStep(10404)
                        self:executeGuide()
                    else
                        ui.showFlashView(TR("暂时没有更好的装备了"))
                    end
					return
				end

				-- 请求服务器接口的参数
				local tempData = {self.mShowIndex}
				for _, typeName in ipairs({"Weapon", "Helmet", "Clothes", "Necklace", "Pants", "Shoes", "Book", "Pet"}) do
					table.insert(tempData, oneKeyItems[typeName] and oneKeyItems[typeName].Id or "")
				end

                self:requestOneKeyEquipCombat(tempData)
			end
		},
		{
			normalImage = "c_27.png",
			text = TR("培养共鸣"),
			optBtnTag = tagOfOptBtn.eMaster,
			btnPos = cc.p(520, 380),
			clickAction = function()
				if (ConfigFunc:canEnterEquipMaster() == false) then
					return
				end
				LayerManager.addLayer({
	                name = "equip.EquipMasterLayer",
	                data = {
	                	defaultTag = nil,
	                	resourcetypeSub = nil,
	                },
	            })
			end
		},
	}
	
	-- 下排按钮列表
	local bottomInfos = {
		{
			normalImage = "c_28.png",
			text = TR("培养"),
			optBtnTag = tagOfOptBtn.eHeroLvUp,
			btnPos = cc.p(120, 320),
			clickAction = function()
				local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
				if not Utility.isEntityId(slotInfo.HeroId) then
					return
				end

				-- 
				local originalTag = ModuleSub.eHeroLvUp
                if SlotPrefObj:slotHeroCanStep(self.mShowIndex) then
                    originalTag = ModuleSub.eHeroStepUp
				elseif SlotPrefObj:slotHeroCanReborn(self.mShowIndex) then
					originalTag = ModuleSub.eReborn
                end

                -- 新手引导指定进入类型
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10302 then
                    originalTag = ModuleSub.eHeroLvUp
                    Guide.manager:nextStep(eventID)
                elseif eventID == 7003 then
                    -- 指定进入经脉
                    originalTag = ModuleSub.eReborn
                    Guide.manager:nextStep(eventID, true)
                    Guide.manager:removeGuideLayer()
                end
                LayerManager.showSubModule(originalTag, {
			        originalTag = originalTag,
			        originalId = FormationObj:getSlotInfoBySlotId(self.mShowIndex).HeroId,
			    })
			end
		},
		{
			normalImage = "c_28.png",
			text = (self.mShowIndex == 1) and TR("绝学") or TR("更换"),
			optBtnTag = tagOfOptBtn.eFashion,
			btnPos = cc.p(320, 320),
			clickAction = function()
				-- 如果是主角卡槽，显示绝学按钮，其它卡槽显示更换主将
				if self.mShowIndex == 1 then
					if not ModuleInfoObj:moduleIsOpen(ModuleSub.eFashion, true) then
						return
					end

					-- 进入绝学页面
	                LayerManager.showSubModule(ModuleSub.eFashion, {
				        originalTag = ModuleSub.eFashion,
				        originalId = FormationObj:getSlotInfoBySlotId(self.mShowIndex).HeroId,
				    })
				else
					local slotInfo = FormationObj:getSlotInfoBySlotId(self.mShowIndex)
					LayerManager.addLayer({name = "team.TeamSelectHeroLayer",
		            	data = {
		            		slotId = self.mShowIndex,
		            		isMateSlot = false,
		            		alwaysIdList = {}, -- slotInfo and {slotInfo.HeroId} or {},
		            	}
		            })
				end
			end
		},
		{
			normalImage = "c_28.png",
			text = TR("内功心法"),
			optBtnTag = tagOfOptBtn.eZhenjue,
			btnPos = cc.p(520, 320),
			clickAction = function()
				LayerManager.showSubModule(ModuleSub.eZhenjue, {showIndex = self.mShowIndex, showZhenjueIndex = 1,})
			end
		}
	}

    self.redDotBtnList = {}
	for arrayIndex, array in pairs({zyBtnInfos, upBtnInfos, bottomInfos}) do
		local spaceX = 350 - #array * 50
		local startPosX = (640 - #array * spaceX) / 2 + spaceX / 2
		for index, btnInfo in pairs(array) do
			local tempBtn = ui.newButton(btnInfo)
			tempBtn:setPosition(btnInfo.btnPos)
			self.mSlotParent:addChild(tempBtn)
			self.redDotBtnList[btnInfo.optBtnTag] = tempBtn
		end
	end
	
    -- 添加指定按钮小红点
    local redDotTagList = {
    	[tagOfOptBtn.eHeroLvUp] = Enums.ClientRedDot.eTeamTrain,
        [tagOfOptBtn.eOnekeyCombat] = Enums.ClientRedDot.eTeamOneKeyEquip,
        [tagOfOptBtn.eZhenjue] = Enums.ClientRedDot.eTeamZhenjue,
        [tagOfOptBtn.eMaster] = Enums.ClientRedDot.eTeamEquipMaster,
        [tagOfOptBtn.eZyCombat] = Enums.ClientRedDot.eTeamOneKeyZhenyuan,
    }
    for k,v in pairs(redDotTagList) do
        local eventNames = {SelectSlotChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}

        local function dealRedDotVisible(redDotSprite)
        	redDotSprite:setVisible(RedDotInfoObj:isValid(v, nil, self.mShowIndex))
        end
        ui.createAutoBubble({parent = self.redDotBtnList[k], eventName = eventNames, refreshFunc = dealRedDotVisible})
    end

    -- 真元/装备切换按钮
    local tmpBtnZhenyuan = ui.newButton({
		normalImage = "zy_13.png",
		clickAction = function()
			if (self.mZhenYuanVisible ~= nil) and (self.mZhenYuanVisible == true) then
				self.mZhenYuanVisible = false
			else
				if not ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenyuan, true) then
					return
				end
				self.mZhenYuanVisible = true
			end
			self:dealSelectChange()
		end
	})
	tmpBtnZhenyuan:setPosition(450, 460)
	self.mSlotParent:addChild(tmpBtnZhenyuan, 1)

	-- 显示小红点
	ui.createAutoBubble({
    	parent = tmpBtnZhenyuan, 
    	eventName = {SelectSlotChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}, 
    	refreshFunc = function (redDotSprite)
    		-- 真元界面时显示装备的小红点，反之则显示真元的小红点
    		if (self.mZhenYuanVisible ~= nil) and (self.mZhenYuanVisible == true) then
    			redDotSprite:setVisible(RedDotInfoObj:isValid(Enums.ClientRedDot.eTeamBtnZhenyuan, nil, self.mShowIndex))
    		else
    			redDotSprite:setVisible(RedDotInfoObj:isValid(Enums.ClientRedDot.eTeamOneKeyZhenyuan, nil, self.mShowIndex))
    		end
    	end})
end

-- ======================== 服务器数据请求相关函数 =======================
-- 装备一键强化的数据请求
function TeamLayer:requestOneKeyEquipLvUp(equipIdList)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Equip",
        methodName = "OneKeyEquipLvUp",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10404),
        svrMethodData = {equipIdList},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then -- 强化失败
		        return
		    end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10404 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end

		    local retValue = response.Value  or {}
		    -- 刷新装备等级
            for _, item in pairs(retValue.EquipsInfo) do
                EquipObj:modifyEquipItem(item)
            end
            -- 刷新本页面
            self:dealSelectChange()

            -- 等级改变的装备列表
            local equipList = self.mEquipView:getChangeEquipList(equipIdList)
            -- 一键强化特效
            for _, item in ipairs(equipList) do
            	local tempSize = item:getContentSize()
            	ui.newEffect({
	            	parent = item,
	            	effectName = "effect_ui_zhuangbeiqianghua",
	            	position = cc.p(tempSize.width / 2, tempSize.height / 2),
	            	loop = false,
	            	endRelease = true,
	            })
            end
            -- 播放强化成功的音效
            MqAudio.playEffect("zhuangbei_qianghua.mp3")
        end,
    })
end

-- 装备一键上阵的数据请求
function TeamLayer:requestOneKeyEquipCombat(svrParams)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "OneKeyEquipCombat",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10402),
        svrMethodData = svrParams,
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
		        return
		    end

            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10402 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end
		    -- 删除一键装备数据，不显示小红点
		    SlotPrefObj:deleteSlotEquipPref()
            -- 刷新本页面
            self:dealSelectChange()
            -- 播放音效
            MqAudio.playEffect("yijianzhuangbei.mp3")
        end,
    })
end

-- 装备一键上阵的数据请求
function TeamLayer:requestOneKeyZhenyuanCombat(svrParams)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Slot",
        methodName = "OneKeyZhenyuanCombat",
        svrMethodData = svrParams,
        callbackNode = self,
        callback = function(response)
        	if not response or response.Status ~= 0 then
		        return
		    end
            -- 刷新本页面
            self:dealSelectChange()
            -- 播放音效
            MqAudio.playEffect("yijianzhuangbei.mp3")
        end,
    })
end

-- ========================== 新手引导 ===========================
function TeamLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function TeamLayer:executeGuide()
    local equipRect = nil
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 11803 then
        local equipPosX, equipPosY = self.mEquipView:findItemCanStepUp(1)
        if equipPosX and equipPosY then
            local nodePos = self.mEquipView:convertToWorldSpace(cc.p(equipPosX, equipPosY))
            equipRect = cc.rect(nodePos.x - 50 * Adapter.MinScale, nodePos.y - 50 * Adapter.MinScale, 100 * Adapter.MinScale, 100 * Adapter.MinScale)
        else
            -- 未找到可锻造的装备，退出引导
            Guide.helper:guideError(eventID, -1)
            return
        end
    elseif eventID == 11202 or eventID == 11301 or eventID == 112091 then
        local isEquiped = self.mEquipView:isTreasureEquiped(self.mShowIndex)
        -- 排除经验神兵
        local treasureCount = #TreasureObj:getTreasureList({notExpTreasure = true})
        if (eventID == 11202 and isEquiped) or (eventID == 11301 and not isEquiped) or 
            (eventID == 112091 and treasureCount == 0) then
            -- 神兵已上阵或找不到可装备的神兵，退出2个引导
            Guide.helper:guideError(eventID, -1)
            return
        end
    end

    local bookRect = cc.rect(display.cx - 300 * Adapter.MinScale, display.cy - 130 * Adapter.MinScale,
            100 * Adapter.MinScale, 100 * Adapter.MinScale)
    local isInGuide = Guide.helper:executeGuide({
        [10207] = {clickRect = cc.rect(
            display.cx - 100 * Adapter.MinScale,
            display.cy + 30 * Adapter.MinScale,
            200 * Adapter.MinScale,
            180 * Adapter.MinScale
        )},
        -- 点击副本
        [10209]  = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        [10302] = {clickNode = self.redDotBtnList[tagOfOptBtn.eHeroLvUp]}, -- 第一个主将培养按钮
        [10308] = {clickNode = self.redDotBtnList[tagOfOptBtn.eHeroLvUp]}, -- 玩家角色培养按钮
        [10402] = {clickNode = self.redDotBtnList[tagOfOptBtn.eOnekeyCombat]}, -- 一键穿戴装备
        [10404] = {clickNode = self.redDotBtnList[tagOfOptBtn.eOnekeyLvup]},  -- 一键强化装备
        [10405] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        [204] = {clickNode = self.redDotBtnList[tagOfOptBtn.eHeroLvUp]},
        [303] = {clickNode = self.redDotBtnList[tagOfOptBtn.eHeroLvUp]},
        [514] = {clickNode = self.redDotBtnList[tagOfOptBtn.eOnekeyCombat]},
        [515] = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eBattle)},
        -- 指向神兵
        [11202] = {clickRect = bookRect},
        [112091] = {clickRect = bookRect},
        -- 神兵升级
        [11301] = {clickRect = bookRect},
        -- 装备锻造，添加锻造石
        [11802] = {nextStep = function(eventID, isGot)
            if isGot then
                -- 领取服务器物品成功执行下一步
                Guide.manager:nextStep(11802)
            end
            self:executeGuide()
        end},
        [11803] = {clickRect = equipRect},
        [11807] = {clickNode = self.redDotBtnList[tagOfOptBtn.eMaster]},
        -- 培养
        [7003] = {clickNode = self.redDotBtnList[tagOfOptBtn.eHeroLvUp]},
    })
    if isInGuide then
        self.mFigureView.mSliderView:setTouchEnabled(false)
    end
end

return TeamLayer
