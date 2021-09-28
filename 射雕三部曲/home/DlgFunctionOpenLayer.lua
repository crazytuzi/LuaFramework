--[[
	文件名：DlgFunctionOpenLayer.lua
	描述：新功能开启
	创建人：yanghongsheng
	创建时间： 2019.1.5
--]]

local DlgFunctionOpenLayer = class("DlgFunctionOpenLayer", function(params)
	return display.newLayer()
end)


function DlgFunctionOpenLayer:ctor(params)
	self.mModuleInfoList = {}		-- 模块信息列表
	self.mReceivedFreeList = {}		-- 已领取免费奖励模块列表
	self.mReceiveGiftList = {}		-- 已开启模块礼包奖励状态列表
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgImage = "xgnkq4.png",
    	closeImg = "c_175.png",
    	closeBtnPos = cc.p(583,693),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 初始化数据
    self:refreshData()
	-- 创建页面控件
	self:initUI()

	self:requestInfo()
end

function DlgFunctionOpenLayer:refreshData()
	local moduleIdList = table.keys(FunctionOpenRelation.items)
	-- 排序
	table.sort(moduleIdList, function (moduleId1, moduleId2)
		local moduleNeedLv1 = ModuleSubModel.items[moduleId1].openLv
		local moduleNeedLv2 = ModuleSubModel.items[moduleId2].openLv

		return moduleNeedLv1 < moduleNeedLv2
	end)
	-- 初始化列表
	self.mModuleInfoList = {}
	for _, moduleId in ipairs(moduleIdList) do
		if ModuleInfoObj:moduleIsOpenInServer(moduleId) then
			table.insert(self.mModuleInfoList, FunctionOpenRelation.items[moduleId])
		end
	end
end

function DlgFunctionOpenLayer:initUI()
	-- 创建gridview
	self.mGridView = require("common.GridView"):create({
            viewSize = cc.size(542, 370),
            colCount = 4,
            celHeight = 160,
            selectIndex = 1,
            getCountCb = function()
                return #self.mModuleInfoList
            end,
            createColCb = function(itemParent, colIndex, isSelected)
            	local itemCell = self:createCell(colIndex, isSelected)
            	itemParent:addChild(itemCell)

            	itemCell:setPosition(itemParent:getContentSize().width*0.5, itemParent:getContentSize().height*0.5)
            end,
        })
	self.mGridView:setAnchorPoint(cc.p(0.5, 1))
	self.mGridView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-142)
	self.mBgSprite:addChild(self.mGridView)

	-- 前往按钮
	local goBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("前往"),
			clickAction = function ()
				LayerManager.showSubModule(self.mModuleId)
			end
		})
	goBtn:setPosition(self.mBgSize.width-120, self.mBgSize.height*0.33)
	goBtn:setScale(0.8)
	self.mBgSprite:addChild(goBtn)
	self.mGoBtn = goBtn
end

function DlgFunctionOpenLayer:createCell(index, isSelected)
	local bgSprite = ui.newSprite("xgnkq3.png")
	local bgSize = bgSprite:getContentSize()

	local moduleInfo = self.mModuleInfoList[index]
	local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
	local needLv = ModuleSubModel.items[moduleInfo.moduleId].openLv
	-- 选中框
	local selectSprite = ui.newScale9Sprite("c_31.png", cc.size(bgSize.width+10, bgSize.height+10))
	selectSprite:setPosition(bgSize.width*0.5, bgSize.height*0.5)
	bgSprite:addChild(selectSprite)
	selectSprite:setVisible(false)
	if isSelected then
		self.mSelectSprite = selectSprite
		self.mSelectSprite:setVisible(true)
	end
	-- 图标
	local tbBtn = ui.newButton({
			normalImage = moduleInfo.pic .. ".png",
			clickAction = function ()
				if self.mSelectSprite then
					self.mSelectSprite:setVisible(false)
				end
				selectSprite:setVisible(true)
				self.mSelectSprite = selectSprite
				self:refreshRewardInfo(index)
				self.mGridView:setSelect(index)
			end,
		})
	tbBtn:setSwallowTouches(false)
	tbBtn:setPosition(bgSize.width*0.5, bgSize.height*0.4)
	bgSprite:addChild(tbBtn)
	-- 礼包图标
	local giftSprite = ui.newSprite("xgnkq9.png")
	giftSprite:setPosition(bgSize.width-10, 10)
	bgSprite:addChild(giftSprite)
	-- 礼包显示
	local giftInfo = self.mReceiveGiftList[moduleInfo.moduleId]
	giftSprite:setVisible(self.mReceivedFreeList[moduleInfo.moduleId] and moduleInfo.exReward ~= "" and giftInfo and not giftInfo.IsBuy and giftInfo.EndTime > Player:getCurrentTime())

	-- 置灰
	tbBtn:setEnabled(needLv <= currLv)
	bgSprite:setGray(needLv > currLv)

	-- 未开放
	if needLv > currLv then
		local needLvLabel = ui.newLabel({
				text = TR("%d级开放", needLv),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		needLvLabel:setPosition(bgSize.width*0.5, bgSize.height-20)
		bgSprite:addChild(needLvLabel)
	else
		local picName = nil
		-- 已领取
		if self.mReceivedFreeList[moduleInfo.moduleId] then
			picName = "xgnkq2.png"
		-- 可领取
		else
			picName = "xgnkq1.png"
		end
		local hintSprite = ui.newSprite(picName)
		hintSprite:setPosition(bgSize.width*0.5, bgSize.height-20)
		bgSprite:addChild(hintSprite)
	end

	return bgSprite
end

function DlgFunctionOpenLayer:refreshRewardInfo(index)
	local moduleInfo = self.mModuleInfoList[index]
	if not self.mRewardParent then
		self.mRewardParent = cc.Node:create()
		self.mBgSprite:addChild(self.mRewardParent)
	end
	self.mRewardParent:removeAllChildren()

	self.mModuleId = moduleInfo.moduleId
	-- 聊天和大侠之路不显示前往按钮
	if self.mModuleId == ModuleSub.eChat or self.mModuleId == ModuleSub.eMainTask then
		self.mGoBtn:setVisible(false)
	else
		self.mGoBtn:setVisible(true)
	end

	-- 提示文字
	local hintStr = ""
	if self.mReceivedFreeList[moduleInfo.moduleId] and moduleInfo.exReward ~= "" then
		hintStr = TR("%s折扣出售", ModuleSubModel.items[moduleInfo.moduleId].name)
	else
		hintStr = TR("%s开启奖励", ModuleSubModel.items[moduleInfo.moduleId].name)
	end
	local hintLabel = ui.newLabel({
			text = hintStr,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	hintLabel:setPosition(self.mBgSize.width*0.5+5 ,270)
	self.mRewardParent:addChild(hintLabel)

	-- 奖励列表
	local rewardStr = moduleInfo.freeReward
	if self.mReceivedFreeList[moduleInfo.moduleId] and moduleInfo.exReward ~= "" then
		rewardStr = moduleInfo.exReward
	end
	local rewardList = Utility.analysisStrResList(rewardStr)
	local rewardCardList = ui.createCardList({
        maxViewWidth = 350,
        cardDataList = rewardList,
    })
    rewardCardList:setAnchorPoint(cc.p(0.5, 0.5))
    rewardCardList:setPosition(234, 175)
    self.mRewardParent:addChild(rewardCardList)
    -- 添加半价标志
    if self.mReceivedFreeList[moduleInfo.moduleId] and moduleInfo.exReward ~= "" then
    	local cardList = rewardCardList.getCardNodeList()
    	for _, card in pairs(cardList) do
    		local halfSprite = ui.newSprite("xgnkq7.png")
    		halfSprite:setPosition(0, card:getContentSize().height*0.6)
    		card:addChild(halfSprite)
    	end
    end

    -- 购买按钮
    if self.mReceivedFreeList[moduleInfo.moduleId] and moduleInfo.exReward ~= "" then
    	-- 现价
	    local nowUseList = Utility.analysisStrResList(moduleInfo.exNeed)
	    local textStr = ""
	    for _, useInfo in ipairs(nowUseList) do
	        textStr = textStr..string.format("{%s}%d  ", Utility.getDaibiImage(useInfo.resourceTypeSub, useInfo.modelId), useInfo.num)
	    end
	    local nowLabel = ui.newLabel({
	            text = textStr,
	            color = Enums.Color.eWhite,
	            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	        })
	    nowLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    nowLabel:setPosition(503, 175)
	    self.mRewardParent:addChild(nowLabel)
    	-- 原价
	    local textStr = ""
	    for _, useInfo in ipairs(nowUseList) do
	        textStr = textStr..string.format("{%s}%d  ", Utility.getDaibiImage(useInfo.resourceTypeSub, useInfo.modelId), useInfo.num*2)
	    end
	    local originalLabel = ui.newLabel({
	            text = textStr,
	            color = Enums.Color.eWhite,
	            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	        })
	    originalLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    originalLabel:setPosition(503, 220)
	    self.mRewardParent:addChild(originalLabel)
	    -- 斜线
	    local originalSize = originalLabel:getContentSize()
	    local redLine = ui.newScale9Sprite("cdjh_14.png", cc.size(originalSize.width, 3))
	    redLine:setRotation(10)
	    redLine:setAnchorPoint(cc.p(0.5, 0.5))
	    redLine:setPosition(503, 220)
	    self.mRewardParent:addChild(redLine)
    	-- 购买
		local buyBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("购买"),
			clickAction = function ()
				self:requestGiftReward(index)
			end,
		})
		buyBtn:setPosition(503, 130)
		self.mRewardParent:addChild(buyBtn)
		-- 礼包信息
		local giftInfo = self.mReceiveGiftList[moduleInfo.moduleId]
		-- 置灰购买按钮
		if giftInfo and giftInfo.IsBuy then
			buyBtn:setTitleText(TR("已购买"))
			buyBtn:setEnabled(false)
		elseif giftInfo and giftInfo.EndTime < Player:getCurrentTime() then
			buyBtn:setEnabled(false)
		end
		-- 倒计时
		if giftInfo and giftInfo.EndTime and not giftInfo.IsBuy then
			local timeLabel = ui.newLabel({
					text = "",
					color = cc.c3b(0xff, 0xe7, 0x48),
					outlineColor = cc.c3b(0x46, 0x22, 0x0d),
					size = 20,
				})
			timeLabel:setAnchorPoint(cc.p(0, 0.5))
			timeLabel:setPosition(55, 263)
			self.mRewardParent:addChild(timeLabel)

			Utility.schedule(timeLabel, function ()
				local timeLeft = giftInfo.EndTime - Player:getCurrentTime()
				if timeLeft > 0 then
					timeLabel:setString(MqTime.formatAsDay(timeLeft))
				else
					timeLabel:setString(TR("折扣已过期"))
					timeLabel:stopAllActions()
					buyBtn:setEnabled(false)
				end
			end, 1)
		end
	else
		-- 领取
		local drawBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("领取"),
			clickAction = function ()
				self:requestFreeReward(index)
			end,
		})
		drawBtn:setPosition(503, 175)
		self.mRewardParent:addChild(drawBtn)

		if self.mReceivedFreeList[moduleInfo.moduleId] then
			drawBtn:setTitleText(TR("已领取"))
			drawBtn:setEnabled(false)
		end
	end
end

function DlgFunctionOpenLayer:moveNextRewardBtn(index)
	local index = index or 1
	for i = index, #self.mModuleInfoList do
		local moduleInfo = self.mModuleInfoList[i]
		local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
		local needLv = ModuleSubModel.items[moduleInfo.moduleId].openLv
		if not self.mReceivedFreeList[moduleInfo.moduleId] and needLv <= currLv then
			self.mGridView:setSelect(i)
            self:refreshRewardInfo(i)
            -- 设置gridview内容显示位置
            self.mGridView:setItemShow(i)
			break
		end
	end

end

function DlgFunctionOpenLayer:refreshServerData(ServerData)
	-- 已领取免费奖励模块
	if ServerData.GetRewardStr then
		self.mReceivedFreeList = {}
		local receivedModuleList = string.splitBySep(ServerData.GetRewardStr, ",")
		for _, moduleId in pairs(receivedModuleList) do
			self.mReceivedFreeList[tonumber(moduleId)] = true
		end
	end

	-- 已开启礼包奖励信息
	if ServerData.GetExRewardStr and next(ServerData.GetExRewardStr) then
		self.mReceiveGiftList = {}
		for _, moduleGiftInfo in pairs(ServerData.GetExRewardStr) do
			self.mReceiveGiftList[moduleGiftInfo.ModuleId] = moduleGiftInfo
		end
	end
end

--=========================服务器相关============================
-- 获取模块领奖状态
function DlgFunctionOpenLayer:requestInfo()
    HttpClient:request({
        moduleName = "FunctionOpenInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "领奖状态")
            
            self:refreshServerData(response.Value)
            self.mGridView:reloadData()
            self:refreshRewardInfo(1)

            self:moveNextRewardBtn()
        end
    })
end

-- 领取免费奖励
function DlgFunctionOpenLayer:requestFreeReward(index)
	local moduleInfo = self.mModuleInfoList[index]
    HttpClient:request({
        moduleName = "FunctionOpenInfo",
        methodName = "GetReward",
        svrMethodData = {moduleInfo.moduleId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "免费奖励")
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            self:refreshServerData(response.Value)
            self.mGridView:refreshCell(index)
            self:refreshRewardInfo(index)
            self:moveNextRewardBtn(index)
        end
    })
end

-- 购买额外奖励
function DlgFunctionOpenLayer:requestGiftReward(index)
	local moduleInfo = self.mModuleInfoList[index]
	local needDaibi = Utility.analysisStrResList(moduleInfo.exNeed)
	for _, needItem in pairs(needDaibi) do
        if not Utility.isResourceEnough(needItem.resourceTypeSub, needItem.num) then
            return
        end
    end

    HttpClient:request({
        moduleName = "FunctionOpenInfo",
        methodName = "GetExReward",
        svrMethodData = {moduleInfo.moduleId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "额外奖励")
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            self:refreshServerData(response.Value)
            self.mGridView:refreshCell(index)
            self:refreshRewardInfo(index)
        end
    })
end

return DlgFunctionOpenLayer