--[[
    文件名：ZslyMainLayer.lua
    描述：珍兽塔
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local ZslyMainLayer = class("ZslyMainLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
        isOpneElite     是否打开精英挑战弹窗
        eliteId         精英挑战id
]]

function ZslyMainLayer:ctor(params)
    self.mIsOpneElite = params.isOpneElite
    self.mEliteId = params.eliteId
	self.mZslyOrderIdList = {}	-- 章节顺序id
	self:dealZslyIdOrder()
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)
	-- 初始化页面控件
	self:initUI()
	-- 请求数据
	self:requestInfo()
end

function ZslyMainLayer:initUI()
	-- 背景图片
	local bgLayer = ui.newSprite("zsly_2.jpg")
	bgLayer:setAnchorPoint(cc.p(0.5, 0))
	bgLayer:setPosition(320, -450)
	self.mParentLayer:addChild(bgLayer)
	-- 顶部按钮
	self:createTopBtn()

	-- 关闭按钮
	local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 950),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(50, 950),
        clickAction = function(pSender)
            MsgBoxLayer.addRuleHintLayer(TR("规则"), {
                TR("1.85级开启珍兽塔。"),
                TR("2.每层通关可以获得兽粮，每通关5层可开启一个宝箱。"),
                TR("3.通关指定层数后，可解锁对应的精英挑战，首次通过可获得丰厚奖励，满星通关即可扫荡。"),
                TR("4.重置后可以直接扫荡至已通关最高层，每日重置次数有限。"),
            })
        end
    })
    self.mParentLayer:addChild(ruleBtn, 1)
end

function ZslyMainLayer:dealZslyIdOrder()
	self.mZslyOrderIdList = {}
	local function dealOrder(floorId)
		if floorId == 0 then return end

		table.insert(self.mZslyOrderIdList, floorId)

		dealOrder(ZslyNodeModel.items[floorId].nextNodeId)
	end

	dealOrder(1001)
end

function ZslyMainLayer:getRestoreData()
    local ret = {
        isOpneElite = self.mIsOpneElite,
        eliteId = self.mEliteId,
    }

    return ret
end

function ZslyMainLayer:createTopBtn()
	local btnBg = ui.newScale9Sprite("c_01.png", cc.size(640, 120))
	btnBg:setPosition(320, 1090)
    btnBg:setAnchorPoint(0.5, 1)
    self.mParentLayer:addChild(btnBg)

    -- 按钮列表
    local btnList = {
	    -- 商城
        {
            position = cc.p(60, 70),
            normalImage = "tb_313.png",
            redDotKey = "CanExchangeReward",
            clickAction = function ()
                LayerManager.addLayer({name = "zsly.ZslyShopLayer"})
            end
        },
        -- 精英挑战
        {
            position = cc.p(180, 70),
            normalImage = "tb_314.png",
            redDotKey = "HasEliteFightNum",
            clickAction = function ()
                self:addEliteLayer()
            end
        },
        -- 巅峰排行
        {
            position = cc.p(310, 70),
            normalImage = "tb_16.png",
            clickAction = function ()
                LayerManager.addLayer({name = "zsly.ZslyRankLayer"})
            end
        },
    }

    for _, btnInfo in pairs(btnList) do
        local tempBtn = ui.newButton(btnInfo)
        btnBg:addChild(tempBtn)

        if btnInfo.redDotKey then
            -- 添加小红点
            local function dealRedDotVisible(redDotSprite)
                local redData = RedDotInfoObj:isValid(ModuleSub.eZhenshouLaoyu, btnInfo.redDotKey)
                redDotSprite:setVisible(redData)
            end
            ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshouLaoyu, btnInfo.redDotKey), refreshFunc = dealRedDotVisible})
        end
    end
end

function ZslyMainLayer:addEliteLayer()
    self.mIsOpneElite = true
    LayerManager.addLayer({name = "zsly.ZslyEliteLayer", data = {
            baseInfo = self.mBaseInfo,
            eliteId = self.mEliteId,
            callback = function (baseInfo, eliteId, isOpneElite)
                self.mBaseInfo = baseInfo
                self.mEliteId = eliteId
                self.mIsOpneElite = isOpneElite
            end
        },
        cleanUp = false,
    })
end

function ZslyMainLayer:createFloorNode()
	-- hero父节点
	if not self.mHeroParent then
		self.mHeroParent = cc.Node:create()
		self.mParentLayer:addChild(self.mHeroParent)
	end
	self.mHeroParent:removeAllChildren()
	-- 三个人物站位
	local posList = {cc.p(526, 250), cc.p(175, 500), cc.p(504, 744)}
	-- 分组或组id
	local index = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonCurNodeId) or 0
	local groupindex = math.floor(index/#posList)
	if index == #self.mZslyOrderIdList then
		groupindex = groupindex-1
	end
	-- 创建节点
	for i, pos in ipairs(posList) do
		local floorId = self.mZslyOrderIdList[groupindex*#posList+i]
		if floorId then
			local heroNode = self:createHeroNode(floorId)
			heroNode:setPosition(pos)
			self.mHeroParent:addChild(heroNode)
		end
	end
end

function ZslyMainLayer:createHeroNode(floorId)
	local heroNode = cc.Node:create()
	local floorModel = ZslyNodeModel.items[floorId]

	-- 所有层的id
	local floorIdList = table.keys(ZslyNodeModel.items)
	table.sort(floorIdList, function (id1, id2)
		return id1 < id2
	end)
	-- 节点顺序
	local curIndex = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonCurNodeId) or 0
	local floorIndex = table.indexof(self.mZslyOrderIdList, floorId) or 0
	-- 宝箱
	if floorModel.ifSpecialBox then
		local box = ui.newButton({
			normalImage = "zsly_12.png",
			clickAction = function ()
				-- 领取奖励
				if floorIndex == curIndex+1 then
					self:requestGetBoxReward()
				-- 预览奖励
				else
					local rewardList = Utility.analysisStrResList(floorModel.boxReward)
					MsgBoxLayer.addPreviewDropLayer(rewardList, nil, TR("宝箱奖励"))
				end
			end,
		})
		box:setAnchorPoint(cc.p(0.5, 0))
		box:setPosition(0, -50)
		heroNode:addChild(box)

		-- 已通过
	    if floorIndex <= curIndex then
	    	box:setEnabled(false)
	    	box:loadTextures("zsly_13.png", "zsly_13.png")
        -- 能领取
        elseif floorIndex == curIndex+1 then
            ui.setWaveAnimation(box, nil, false)
	    end

        -- 引导用按钮
        if not self.mGuideBtn and floorIndex == curIndex+1 then
            self.mGuideBtn = box
        end
	else
		local hero = Figure.newHero({
            parent = heroNode,
	        heroModelID = floorModel.npcModel,
	        position = cc.p(0, 0),
	        scale = 0.2,
	        buttonAction = function()
	        	if floorIndex == curIndex+1 then
	        		self:requestFight()
	        		return
                elseif floorIndex <= curIndex then
                    return
                else
    	        	ui.showFlashView(TR("请先通过上一个关卡"))
                end
	        end,
	    })

        -- 引导用按钮
        if not self.mGuideBtn and floorIndex > curIndex then
            self.mGuideBtn = hero.button
        end

	    -- 已通过
	    if floorIndex <= curIndex then
	    	hero:setColor(cc.c3b(95, 95, 95))
	    	hero:setAnimation(0, "daiji", false)
	    	hero:setTimePercent(100)
	    end

	    -- 推荐战力
	    local fapBg = ui.newSprite("zsly_3.png")
	    fapBg:setPosition(-10, -50)
	    heroNode:addChild(fapBg)

	    local fapSprite = ui.newSprite("zsly_5.png")
	    fapSprite:setPosition(30, fapBg:getContentSize().height*0.5)
	    fapBg:addChild(fapSprite)

	    local fapLabel = ui.newNumberLabel({
			 	text = Utility.numberFapWithUnit(tonumber(floorModel.fapNeedShow)),
		        imgFile = "jhs_85.png", -- 数字图片名
		        charCount = 12, 
	    	})
	    fapLabel:setAnchorPoint(cc.p(0, 0.5))
	    fapLabel:setPosition(80, fapBg:getContentSize().height*0.5)
	    fapBg:addChild(fapLabel)
	end

	-- 节点名字
	local nameBg = ui.newSprite("zsly_4.png")
	nameBg:setPosition(10, -20)
	heroNode:addChild(nameBg)

	local nameLabel = ui.newLabel({
			text = floorModel.name,
			color = Enums.Color.eWhite,
		})
	nameLabel:setPosition(nameBg:getContentSize().width*0.5, nameBg:getContentSize().height*0.5)
	nameBg:addChild(nameLabel)

	-- 已通关
	if floorIndex <= curIndex then
		local passSprite = ui.newSprite("zsly_11.png")
		passSprite:setPosition(10, 60)
		heroNode:addChild(passSprite)
	end


	return heroNode
end

-- 重置/扫荡信息
function ZslyMainLayer:createResetInfo()
	if not self.mResetParent then
		self.mResetParent = ui.newSprite("zsly_1.png")
		self.mResetParent:setPosition(220, 240)
		self.mParentLayer:addChild(self.mResetParent)
	end
	self.mResetParent:removeAllChildren()

	-- 所有层的id
	local floorIdList = table.keys(ZslyNodeModel.items)
	table.sort(floorIdList, function (id1, id2)
		return id1 < id2
	end)
	-- 下一个节点
	local index = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonCurNodeId) or 0
	local nextNodeId = self.mZslyOrderIdList[index+1]
	local nodeModel = ZslyNodeModel.items[nextNodeId]
	-- 奖励预览
	if nodeModel then
		local text = TR("奖励预览")
		if nodeModel.customReward ~= "" then
			local rewardList = Utility.analysisStrResList(nodeModel.customReward)
			for _, rewardInfo in ipairs(rewardList) do
				text = text .. string.format("  {%s}%s", Utility.getDaibiImage(rewardInfo.resourceTypeSub, rewardInfo.modelId), rewardInfo.num)
			end
		elseif nodeModel.ifSpecialBox then
			text = text .. TR("  宝箱奖励")
		end

		local rewardLabel = ui.newLabel({
				text = text,
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		rewardLabel:setAnchorPoint(cc.p(0, 0))
		rewardLabel:setPosition(40, 180)
		self.mResetParent:addChild(rewardLabel)
	end
	-- 重置按钮
	local resetBtn = ui.newButton({
        normalImage = "c_28.png",
		text = TR("重置"),
        position = cc.p(90, 130),
        clickAction = function(pSender)
        	if self.mBaseInfo.CommonResetNum > 0 then
        		MsgBoxLayer.addOKLayer(TR("是否重置关卡？"), TR("提示"), {{
    				normalImage = "c_28.png",
    				text = TR("确定"),
    				clickAction = function (msgObj)
			        	self:requestReset()
    					LayerManager.removeLayer(msgObj)
    				end,
    			}},
    			{})
    		else
		        ui.showFlashView(TR("重置次数不足"))
	        end
        end
    })
    self.mResetParent:addChild(resetBtn)
    resetBtn:setEnabled(self.mBaseInfo.CommonCurNodeId > 0)
    -- 添加小红点
    local function dealRedDotVisible(redDotSprite)
        local redData = RedDotInfoObj:isValid(ModuleSub.eZhenshouLaoyu, "HasCommonResetNum")
        redDotSprite:setVisible(redData and self.mBaseInfo.CommonCurNodeId > 0)
    end
    ui.createAutoBubble({parent = resetBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eZhenshouLaoyu, "HasCommonResetNum"), refreshFunc = dealRedDotVisible})

    -- 扫荡按钮
	local sweepBtn = ui.newButton({
        normalImage = "c_28.png",
		text = TR("扫荡"),
        position = cc.p(270, 130),
        clickAction = function(pSender)
        	self:requestSweep()
        end
    })
    self.mResetParent:addChild(sweepBtn)
    sweepBtn:setEnabled(self.mBaseInfo.CommonMaxNodeId > 0 and self.mBaseInfo.CommonMaxNodeId > self.mBaseInfo.CommonCurNodeId)
    -- 剩余重置次数
    local resetNumLabel = ui.newLabel({
    		text = TR("剩余次数  %s", self.mBaseInfo.CommonResetNum),
    		color = cc.c3b(0x46, 0x22, 0x0d),
    	})
    resetNumLabel:setAnchorPoint(cc.p(0, 0))
	resetNumLabel:setPosition(40, 70)
	self.mResetParent:addChild(resetNumLabel)
end

-- 显示一键登顶对话框
function ZslyMainLayer:showOneKeyMaxBox(params)
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(532, 550))
        blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.51)
        bgSprite:addChild(blackBg)
        -- 奖励列表
        local listViewSize = cc.size(520, 540)
        local passList = ccui.ListView:create()
        passList:setDirection(ccui.ScrollViewDir.vertical)
        passList:setBounceEnabled(true)
        passList:setContentSize(listViewSize)
        passList:setAnchorPoint(cc.p(0.5, 0.5))
        passList:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
        blackBg:addChild(passList)

        local createCell = function(floorInfo)
            local cellSize = cc.size(listViewSize.width, 180)
            local cellItem = ccui.Layout:create()
            cellItem:setContentSize(cellSize)

            -- 背景
            local cellBg = ui.newScale9Sprite("c_54.png", cellSize)
            cellBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellItem:addChild(cellBg)
            -- title
            local titleLabel = ui.newLabel({
                    text = ZslyNodeModel.items[floorInfo.NodeId].name,
                    color = Enums.Color.eNormalWhite,
                    outlineColor = Enums.Color.eRed,
                    size = 24
                })
            titleLabel:setPosition(cellSize.width*0.5, cellSize.height*0.88)
            cellItem:addChild(titleLabel)
            -- 奖励列表
            local rewardList = Utility.analysisStrResList(floorInfo.Resources)
            local cardList = ui.createCardList({
                    maxViewWidth = cellSize.width-100,
                    cardDataList = rewardList,
                    allowClick = true
                })
            cardList:setSwallowTouches(false)
            cardList:setAnchorPoint(cc.p(0.5, 0.5))
            cardList:setPosition(cellSize.width*0.5, cellSize.height*0.4)
            cellItem:addChild(cardList)

            return cellItem
        end

        for _, floorInfo in ipairs(params.RewardList) do
            local cellItem = createCell(floorInfo)
            passList:pushBackCustomItem(cellItem)
        end
        local function action(item)
            item:setScale(0)
            local scale = cc.ScaleTo:create(0.5, 1)
            item:runAction(scale)
        end
        self.listviewAction(passList, action)
    end

    -- 创建对话框
    local boxSize = cc.size(600, 720)
    self.showOneKeyMaxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = boxSize,
            title = TR("扫荡"),
            btnInfos = {
                {
                    text = TR("完成"),
                    normalImage = "c_28.png",
                    fontSize = 22,
                    outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
                }
            },
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

function ZslyMainLayer.listviewAction(listObj, action, dt)
    if not listObj then
        return
    end
    if not action then
        return
    end
    if not dt then
        dt = 0.5
    end

    -- 设置动画效果
    listObj:forceDoLayout()
    local innerNode = listObj:getInnerContainer()
    local listSize = listObj:getContentSize()
    local innerSize = innerNode:getContentSize()
    local innerX, innerY = innerNode:getPosition()

    local listCount = 0
    local curItem = listObj:getItem(listCount)
    while curItem do
        curItem:setVisible(false)
        -- 动画配置
        local actionList = {
            -- 延时
            cc.DelayTime:create(listCount*dt),
            -- 动作
            cc.CallFunc:create(function(curItem)
                curItem:setVisible(true)
                action(curItem)
                local x, y = curItem:getPosition()
                local offestY = innerSize.height - y
                if offestY > listSize.height then
                    local moveInner = cc.MoveTo:create(0.25, cc.p(innerX, -y))
                    innerNode:runAction(moveInner)
                end
            end)
        }
        -- 执行动作
        curItem:runAction(cc.Sequence:create(actionList))
        -- 更新循环变量
        listCount = listCount + 1
        curItem = listObj:getItem(listCount)
    end
end

function ZslyMainLayer:refreshUI()
	-- 挑战节点按钮
	self:createFloorNode()
	-- 重置/扫荡信息
	self:createResetInfo()
end

--=============================网络相关=======================
function ZslyMainLayer:requestInfo()
	HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "GetBaseInfo",
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            self.mBaseInfo = data.Value.BaseInfo

            self:refreshUI()

            if self.mIsOpneElite then
                self:addEliteLayer()
            end

            -- 执行新手引导
            Utility.performWithDelay(self, function ( ... )
                self:executeGuide()
            end, 0.01)
        end,
    })
end

-- 挑战
function ZslyMainLayer:requestFight()
	HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "GetCommonNodeFightInfo",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10069),
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            local maxIndex = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonMaxNodeId) or 0
            local curIndex = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonCurNodeId) or 0
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eZhenshouLaoyu, maxIndex > 0 and maxIndex > curIndex)
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = data.Value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    callback = function(retData)
                        --本地战斗完成,进行校验
                        CheckPve.Zsly(retData)
                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end,
    })
end

-- 领取宝箱奖励
function ZslyMainLayer:requestGetBoxReward()
	HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "FightCommonNode",
        svrMethodData = {true, false},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            self.mBaseInfo = data.Value.BaseInfo

            self:refreshUI()
        end,
    })
end

-- 重置
function ZslyMainLayer:requestReset()
	HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "ResetCommonNode",
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            self.mBaseInfo = data.Value.BaseInfo

            self:refreshUI()
        end,
    })
end

-- 扫荡
function ZslyMainLayer:requestSweep()
	HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "SweepCommonNode",
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then 
                return 
            end
            self.mBaseInfo = data.Value.BaseInfo

            self:refreshUI()

            self:showOneKeyMaxBox(data.Value)
        end,
    })
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function ZslyMainLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向选择珍兽界面
        [10069] = {clickNode = self.mGuideBtn},
    })
end

return ZslyMainLayer