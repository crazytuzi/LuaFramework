--[[
	文件名：ActivityZhihuanLayer.lua
	描述：幻化置换活动
	创建人：yanghongsheng
	创建时间：2019.02.21
--]]

local ActivityZhihuanLayer = class("ActivityZhihuanLayer", function(params)
	return display.newLayer()
end)

function ActivityZhihuanLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	self.mLeftModelId = 0		-- 左边幻化模型id
	self.mRightModelId = 0		-- 右边幻化模型id
	self.mUseData = {}			-- 消耗材料数据表
	self.mUseGoodId = 16050518

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	-- 初始化页面控件
	self:initUI()

	self:requestGetInfo()
end

function ActivityZhihuanLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("hhzh_01.jpg")
    bgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(bgSprite)

    -- 倒计时
    self.mTimeLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    self.mTimeLabel:setPosition(320, 950)
    self.mParentLayer:addChild(self.mTimeLabel)
    self:createUpdateTime()

    -- 提示文字
    local hintLabel = ui.newLabel({
    		text = TR("选择想要置换的幻化侠客，消耗材料进行置换，只能置换背包中的幻化侠客"),
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    		dimensions = cc.size(475, 0)
    	})
    hintLabel:setPosition(320, 346)
    self.mParentLayer:addChild(hintLabel)

    -- 左站台
    local leftSprite = ui.newSprite("hhzh_03.png")
    leftSprite:setAnchorPoint(cc.p(0, 0))
    leftSprite:setPosition(cc.p(-30, 420))
    self.mParentLayer:addChild(leftSprite)

    -- 右站台
    local rightSprite = ui.newSprite("hhzh_03.png")
    rightSprite:setAnchorPoint(cc.p(0, 0))
    rightSprite:setRotationSkewY(180)
    rightSprite:setPosition(cc.p(670, 420))
    self.mParentLayer:addChild(rightSprite)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(40, 1045),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.消耗转生石可以进行幻化侠客置换。"),
				TR("2.置换过后的幻化侠客只能通过再次置换还原。"),
				TR("3.不同的幻化侠客置换需要消耗的材料数量不同。"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn, 1)
    
    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1045),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1)

    -- 箭头
    local arrowSprite = ui.newSprite("hhzh_04.png")
    arrowSprite:setPosition(320, 697)
    self.mParentLayer:addChild(arrowSprite, 1)

    -- 预览按钮
    local previewBtn = ui.newButton({
        normalImage = "c_79.png",
        position = cc.p(320, 567),
        clickAction = function()
        	self:createPreViewBox()
        end
    })
    self.mParentLayer:addChild(previewBtn, 1)

    -- 置换按钮
    self.mDisplaceBtn = ui.newButton({
    		normalImage = "fx_11.png",
    		text = TR("置  换"),
    		position = cc.p(320, 232),
	        clickAction = function()
	        	self:disPlaceCallback()
	        end
    	})
    self.mParentLayer:addChild(self.mDisplaceBtn, 1)

    -- 消耗
    self.mUseLabel = ui.newLabel({
    		text = "",
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
    self.mUseLabel:setPosition(320, 174)
    self.mParentLayer:addChild(self.mUseLabel, 1)

    self:refreshUI()
end

-- 置换回调
function ActivityZhihuanLayer:disPlaceCallback()
	if self.isDisplacing then
		ui.showFlashView(TR("正在进行幻化侠客置换，请稍后"))
		return
	end
	-- 获取最大置换数量
	local function getMaxNum()
		local ownGoodsNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, self.mUseGoodId)
		local onceUseNum = self.mUseData[self.mLeftModelId][self.mRightModelId]
		local maxNum = math.floor(ownGoodsNum / onceUseNum)
		local illusionNum = IllusionObj:getCountByModelId(self.mLeftModelId, {notInFormation = true})
		maxNum = maxNum > illusionNum and illusionNum or maxNum
		return maxNum
	end
	-- 数量选择弹窗
	local function selectNumBox()
		local maxNum = getMaxNum()
		if maxNum <= 0 then
			ui.showFlashView(TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eFunctionProps, self.mUseGoodId)))
			return
		elseif maxNum == 1 then
			self:DisplaceHero(1)
		else		
			MsgBoxLayer.addUseGoodsCountLayer(TR("置换数量"), self.mRightModelId, getMaxNum(), function(selCount, layerObj, btnObj)
				self:DisplaceHero(selCount)
				LayerManager.removeLayer(layerObj)
			end, nil, ResourcetypeSub.eIllusion, false)
		end
	end

	-- 提示文字弹窗
	self.hintBox = MsgBoxLayer.addOKCancelLayer(
		TR("置换之后相应幻化侠客将永久变为新幻化侠客，是否确认置换？（新幻化侠客也可以参与置换）"),
		TR("提示"),
		{
			text = TR("确定"),
			normalImage = "c_28.png",
			clickAction = function ()
				selectNumBox()
				LayerManager.removeLayer(self.hintBox)
			end
		},
		nil,
		{},
		false
	)
end

-- 刷新侠客显示
function ActivityZhihuanLayer:refreshHero()
	if not self.mHeroParent then
		self.mHeroParent = cc.Node:create()
		self.mParentLayer:addChild(self.mHeroParent)
	end
	self.mHeroParent:removeAllChildren()

	local function createHero(modelId, isMySelf, pos)
		if modelId and modelId > 0 then
			local figure = Figure.newHero({
				IllusionModelId = modelId,
				parent = self.mHeroParent,
				position = cc.p(pos.x, 510),
				scale = 0.3,
				buttonAction = function ()
					self:createSelectLayer(isMySelf)
				end
			})
			if not isMySelf then figure:setRotationSkewY(180) end

			-- 幻化名字
			local nameLabel = ui.newLabel({
					text = IllusionModel.items[modelId].name,
					color = Enums.Color.eWhite,
				})
			nameLabel:setPosition(pos.x, 448)
			self.mHeroParent:addChild(nameLabel)
		else
			local emptyBtn = ui.newButton({
					normalImage = "hhzh_02.png",
					clickAction = function ()
						if not isMySelf and (not self.mLeftModelId or self.mLeftModelId <= 0) then
							ui.showFlashView("请先选择左边幻化侠客")
							return
						end
						self:createSelectLayer(isMySelf)
					end
				})
			emptyBtn:setPosition(pos)
			self.mHeroParent:addChild(emptyBtn)
		end
	end
	-- 左边侠客
	createHero(self.mLeftModelId, true, cc.p(150, 690))
	-- 右边侠客
	createHero(self.mRightModelId, false, cc.p(520, 690))

end

-- 创建选择界面
function ActivityZhihuanLayer:createSelectLayer(isMySelf)
	if self.isDisplacing then
		ui.showFlashView(TR("正在进行幻化侠客置换，请稍后"))
		return
	end
	LayerManager.addLayer({
			name = "activity.ActivityZhihuanSelectLayer",
			data = {
				displaceList = isMySelf and table.keys(self.mUseData) or table.keys(self.mUseData[self.mLeftModelId]),
				isMySelf = isMySelf,
				leftModelId = self.mLeftModelId,
				callback = function (selectModelId)
					if isMySelf then
						self.mLeftModelId = selectModelId
						self.mRightModelId = 0
					else
						self.mRightModelId = selectModelId
					end
					self:refreshUI()
				end,
			},
			cleanUp = false,
		})
end

-- 预览弹窗
function ActivityZhihuanLayer:createPreViewBox()
	local illusionList = table.keys(self.mUseData)
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		local gridView = require("common.GridView"):create({
            viewSize = cc.size(570, 530),
            colCount = 4,
            celHeight = 130,
            selectIndex = 1,
            -- needDelay = true,
            getCountCb = function()
                return #illusionList
            end,
            createColCb = function(itemParent, colIndex, isSelected)

                local attrs = {CardShowAttr.eBorder, CardShowAttr.eName}

                local illusionModel = IllusionModel.items[illusionList[colIndex]]
                -- 创建显示图片
                local card, Attr = CardNode.createCardNode({
                	resourceTypeSub = ResourcetypeSub.eIllusion,
        			modelId = illusionModel.modelId, 
                    cardShowAttrs = attrs,
                    allowClick = false,
                })
                card:setPosition(64, 60)
                itemParent:addChild(card)
                -- 是否激活
                if not IllusionObj:getOneItemOwned(illusionModel.modelId) then
                	local activeSprite = ui.newSprite("hhzh_05.png")
                	activeSprite:setPosition(card:getContentSize().width*0.5, card:getContentSize().height*0.5)
                	card:addChild(activeSprite)
                end
            end,
        })
		gridView:setPosition(bgSize.width*0.5, 370)
		bgSprite:addChild(gridView)

	end

	LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgSize = cc.size(630, 700),
            title = TR("置换幻化"),
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {},
        }
    })
end

-- 更新时间
function ActivityZhihuanLayer:createUpdateTime()
    if self.mSchelTime then
        self.mTimeLabel:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end

    self.mEndTime = ActivityObj:getActivityItem(ModuleSub.eCommonHoliday30)[1].EndDate

    self.mSchelTime = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a%s",MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时：#f8ea3a00:00:00"))

            -- 停止倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end

            LayerManager.removeLayer(self)
        end
    end, 1)
end

-- 刷新界面
function ActivityZhihuanLayer:refreshUI()
	-- 刷新侠客显示
	self:refreshHero()
	-- 刷新置换按钮
	if self.mLeftModelId and self.mRightModelId and self.mLeftModelId > 0 and self.mRightModelId > 0 then
		self.mDisplaceBtn:setEnabled(true)
		local useNum = self.mUseData[self.mLeftModelId][self.mRightModelId]
		local ownGoodsNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, self.mUseGoodId)
		self.mUseLabel:setString(TR("消耗：%s%s/%s{%s}", ownGoodsNum >= useNum and Enums.Color.eWhiteH or Enums.Color.eRedH, ownGoodsNum, useNum, "db_50518.png"))
	else
		self.mDisplaceBtn:setEnabled(false)
		self.mUseLabel:setString("")
	end
end

-- 整理服务器数据
function ActivityZhihuanLayer:dealServerData(response)
	for _, groupInfo in pairs(response.Value or {}) do
		local leftModelList = string.splitBySep(groupInfo.ModelIdStr or "", ",")
		local rightModelList = string.splitBySep(groupInfo.NewModelIdStr or "", ",")
		for _, leftModelId in pairs(leftModelList) do
			local tempList = self.mUseData[tonumber(leftModelId)] or {}
			for _, rightModelId in pairs(rightModelList) do
				tempList[tonumber(rightModelId)] = groupInfo.ConsumeNum
			end
			self.mUseData[tonumber(leftModelId)] = tempList
		end
	end
	-- dump(self.mUseData)
end

-- 播放置换特效
function ActivityZhihuanLayer:DisplaceHero(num)
	-- 置换中
	self.isDisplacing = true
	ui.newEffect({
			parent = self.mHeroParent,
			effectName = "effect_ui_zhihuan",
			position = cc.p(320, 568),
			loop = false,
			endListener = function ()
				self:requestDisplace(num)
			end
		})
end

---------------------------网络相关------------------------------
-- 请求服务器数据
function ActivityZhihuanLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "Illusion",
        methodName = "GetIllusionConvertInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)

            self:dealServerData(response)
            
            self:refreshUI()
        end
    })
end

-- 请求服务器数据
function ActivityZhihuanLayer:requestDisplace(num)
	local IdList = IllusionObj:getOneTypeIdList(self.mLeftModelId, {notInFormation = true})
	local useIdList = {}
	for i = 1, num do
		table.insert(useIdList, IdList[i].Id)
	end

    HttpClient:request({
        moduleName = "Illusion",
        methodName = "IllusionConvert",
        svrMethodData = {useIdList, self.mRightModelId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.isDisplacing = false

            ui.showFlashView(TR("置换成功"))
            -- 奖励弹窗
            local resourceList = {}
            for i = 1, num do
            	local tempItem = {resourceTypeSub = ResourcetypeSub.eIllusion, modelId = self.mRightModelId, num = 1}
            	table.insert(resourceList, tempItem)
            end
            local newLayer = require("commonLayer.StepDropLayer").new({
            		resourceList = resourceList,
            	})
            local currScene = LayerManager.getMainScene()
            currScene:addChild(newLayer, Enums.ZOrderType.eDrapReward)

            -- 更新数据
            IllusionObj:setIllusionList(response.Value.IllusionInfo)

            -- 左边是否还有幻化
            if IllusionObj:getCountByModelId(self.mLeftModelId, {notInFormation = true}) <= 0 then
            	self.mLeftModelId = 0
            	self.mRightModelId = 0
            end
            
            -- 刷新
            self:refreshUI()
        end
    })
end

return ActivityZhihuanLayer