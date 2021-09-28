--[[
    SectPalaceHomeLayer.lua
    描述: 门派地宫主页面
    创建人: yanghongsheng
    创建时间: 2019.3.9
-- ]]


local SectPalaceHomeLayer = class("SectPalaceHomeLayer", function(params)
    return display.newLayer()
end)

-- 解锁小红点
local LockRedDotEvent = "LockRedDotEvent"

function SectPalaceHomeLayer:ctor(params)
	self.mPalaceInfoList = {}	-- 地宫数据
	self.mDefendHeroIdList = {}	-- 已派遣的侠客列表
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 地宫id列表
    self.mPalaceIdList = table.keys(SectPalaceModelModel.items)
    table.sort(self.mPalaceIdList, function (id1, id2)
    	return id1 < id2
    end)

    self:initUI()
    -- 请求数据
    self:requestInfo()
end

-- 回调刷新据
function SectPalaceHomeLayer:refreshData(baseInfo, plunderRecord)
	if baseInfo then
		self.mPalaceBaseInfo = baseInfo
	end
	if plunderRecord then
		self.mPlunderRecord = plunderRecord
	end

	-- 刷新页面
	local parent = self
	if parent and not tolua.isnull(parent) then
		self:refreshUI()
	end
end

-- 初始化界面
function SectPalaceHomeLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("mpdg_3.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 黑背景
    local blackSprite = ui.newScale9Sprite("mpdg_2.png", cc.size(600, 770))
    blackSprite:setPosition(320, 588)
    self.mParentLayer:addChild(blackSprite)

    -- 地宫列表
    self.palaceListView = ccui.ListView:create()
    self.palaceListView:setDirection(ccui.ScrollViewDir.vertical)
    self.palaceListView:setBounceEnabled(false)
    self.palaceListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.palaceListView:setContentSize(cc.size(580, 750))
    -- self.palaceListView:setItemsMargin(10)
    self.palaceListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.palaceListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.palaceListView:setPosition(320, 588)
    self.mParentLayer:addChild(self.palaceListView)

    -- 战报
    local reportBtn = ui.newButton({
    	normalImage = "mpdg_16.png",
    	clickAction = function ()
    		LayerManager.addLayer({name = "sect.SectPalaceReportLayer", data = {
	    		baseInfo = self.mPalaceBaseInfo,
	    		plunderRecord = self.mPlunderRecord,
	    		callback = handler(self, self.refreshData)
	    	}, cleanUp = false, needRestore = true})
    	end
    })
    reportBtn:setPosition(85, 150)
    self.mParentLayer:addChild(reportBtn)

    -- 掠夺
    local plunderBtn = ui.newButton({
    	normalImage = "mpdg_15.png",
    	clickAction = function ()
    		LayerManager.addLayer({name = "sect.SectPalacePlunderLayer", data = {
	    		baseInfo = self.mPalaceBaseInfo,
	    		plunderRecord = self.mPlunderRecord,
	    		callback = handler(self, self.refreshData)
	    	}, cleanUp = false, needRestore = true})
    	end
    })
    plunderBtn:setPosition(185, 150)
    self.mParentLayer:addChild(plunderBtn)
    self.mPlunderBtn = plunderBtn
    -- 添加小红点
    self.mPlunderBtn.redDot = ui.createBubble({position = cc.p(plunderBtn:getContentSize().width*0.8, plunderBtn:getContentSize().height*0.8)})
    self.mPlunderBtn:addChild(self.mPlunderBtn.redDot)
    self.mPlunderBtn.redDot:setVisible(false)

    -- 商店
    local shopBtn = ui.newButton({
    	normalImage = "mpdg_14.png",
    	clickAction = function ()
    		LayerManager.addLayer({name = "sect.SectPalaceShopLayer", data = {callback = function ()
    			self:refreshPalaceList()
    		end}, cleanUp = false})
    	end
    })
    shopBtn:setPosition(285, 150)
    self.mParentLayer:addChild(shopBtn)

    --规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(45, 1045),
        clickAction = function(pSender)
            MsgBoxLayer.addRuleHintLayer(TR("规则"),{
            	TR("1.门派地宫开启后，可以派遣侠客进行探索，探索结束后可获得奖励。"),
            	TR("2.集齐藏宝图碎片可以探索更深层的地宫。"),
            	TR("3.每次探索都需要派遣至少一位等于主角等级的侠客，至多五位。"),
				TR("4.每天可以在门派地宫中掠夺三次，除主角外，一名侠客只能参与一次掠夺。"),
				TR("5.一个探索队伍只能被掠夺一次，被掠夺后，部分探索奖励将被掠夺方夺取。掠夺无论成败都会消耗一次掠夺次数。"),
				TR("6.地宫探索和掠夺时均可使用道具，增强自己的队伍能力。"),
				TR("7.掠夺时道具只生效一次，探索道具只要不被成功掠夺就一直生效。"),
				TR("8.可以将掠夺了自己的玩家标记为仇敌，仇敌玩家在掠夺时将会有更高几率出现，最多标记十位仇敌。"),
            })
        end
    })
    self.mParentLayer:addChild(ruleBtn)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1045),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
end

-- 刷新地宫列表
function SectPalaceHomeLayer:refreshPalaceList()
	for i, _ in ipairs(self.mPalaceIdList) do
		self:refreshPalaceItem(i)
	end
end

-- 刷新地宫项
function SectPalaceHomeLayer:refreshPalaceItem(index)
	local cellSize = cc.size(self.palaceListView:getContentSize().width, 150)
	local cellItem = self.palaceListView:getItem(index-1)
	if not cellItem then
		cellItem = ccui.Layout:create()
		cellItem:setContentSize(cellSize)
		self.palaceListView:pushBackCustomItem(cellItem)
	end
	cellItem:removeAllChildren()

	-- 背景图
	local bgPicList = {"mpdg_7.png", "mpdg_9.png", "mpdg_10.png", "mpdg_11.png", "mpdg_12.png"}
	local bgSprite = ui.newSprite(bgPicList[index] or bgPicList[1])
	bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	cellItem:addChild(bgSprite)

	-- 地宫数据
	local palaceId = self.mPalaceIdList[index]
	local palaceModel = SectPalaceModelModel.items[palaceId]
	local palaceInfo = self.mPalaceInfoList[palaceId]

	-- 地宫名
	local nameLabel = ui.newLabel({
		text = palaceModel.name,
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		size = 24,
	})
	nameLabel:setPosition(cellSize.width*0.5, cellSize.height-30)
	cellItem:addChild(nameLabel)

	-- 是否解锁
	if index <= self.mPalaceBaseInfo.PalaceNum then
		local status = palaceInfo and palaceInfo.PalaceStatus or 0
		-- 初始状态
		if status == 0 then
			-- 探索按钮
			local exploreBtn = ui.newButton({
					normalImage = "mpdg_4.png",
					clickAction = function ()
						LayerManager.addLayer({
							name = "sect.SectPalaceSelectHeroLayer",
							data = {
								limitHeroIdList = self.mDefendHeroIdList,
								btnTitle = TR("派遣"),
								callback = function (heroIdList, goodsList, isDouble)
									self:requestExplorePalace(palaceId, heroIdList, goodsList, isDouble)
								end,
								isShowDouble = true,
							},
							cleanUp = false,
						})
					end
			})
			exploreBtn:setPosition(500, cellSize.height*0.5)
			cellItem:addChild(exploreBtn)
			-- 小红点
			local reddot = ui.createBubble({position = cc.p(exploreBtn:getContentSize().width*0.8, exploreBtn:getContentSize().height*0.8)})
			exploreBtn:addChild(reddot)
		-- 探索完成
		elseif status == 1 then
			-- 领取按钮
			local getBtn = ui.newButton({
				normalImage = "mpdg_6.png",
				clickAction = function ()
					self:requestPalaceReward(palaceId, false)
				end
			})
			getBtn:setPosition(500, cellSize.height*0.5)
			cellItem:addChild(getBtn)
			ui.setWaveAnimation(getBtn)
			-- 小红点
			local reddot = ui.createBubble({position = cc.p(getBtn:getContentSize().width*0.8, getBtn:getContentSize().height*0.8)})
			getBtn:addChild(reddot)
		-- 探索中
		elseif status == 2 then
			-- 加速探索按钮
			local addSpeedBtn = ui.newButton({
				normalImage = "mpdg_5.png",
				clickAction = function ()
					self:createFinishUseBox(palaceInfo)
				end
			})
			addSpeedBtn:setPosition(80, cellSize.height*0.5)
			cellItem:addChild(addSpeedBtn)
			-- 探索中
			local exploringSprite = ui.newSprite("mpdg_8.png")
			exploringSprite:setPosition(500, cellSize.height*0.5)
			cellItem:addChild(exploringSprite)
			-- 探索倒计时
			local timeLabel = ui.newLabel({
				text = "",
				color = Enums.Color.eWhite,
				outlineColor = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
			timeLabel:setPosition(cellSize.width*0.5, 30)
			cellItem:addChild(timeLabel)

			timeLabel.timeUpdate = Utility.schedule(timeLabel, function ()
				local timeLeft = palaceInfo.EndTime - Player:getCurrentTime()
				if timeLeft > 0 then
					timeLabel:setString(TR("探索倒计时：%s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
				else
					timeLabel:setString(TR("探索完成"))
					timeLabel:stopAction(timeLabel.timeUpdate)
					palaceInfo.PalaceStatus = 1
					self:refreshUI()
				end
			end, 1)
		end
	-- 未解锁
	else
		bgSprite:setGray(true)
		-- 锁按钮
		local lockBtn = ui.newButton({
			normalImage = "mpdg_17.png",
			clickAction = function ()
				if index ~= self.mPalaceBaseInfo.PalaceNum+1 then
					ui.showFlashView(TR("需先解锁上一层"))
					return
				end
				local useStr = SectPalaceModelModel.items[palaceId].openNeed
				local resList = Utility.analysisStrResList(useStr)
				local textStrList = {}
				for _, resInfo in pairs(resList) do
					local daibiImg = Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId)
					local textStr = "{"..daibiImg.."}"..resInfo.num
					table.insert(textStrList, textStr)
				end
				local useResStr = table.concat(textStrList, "、")
				MsgBoxLayer.addOKLayer(TR("是否花费 %s%s%s 解锁地宫", "#ffe748", useResStr, Enums.Color.eWhiteH), TR("解锁地宫"),
				{
					{
						text = TR("确定"),
						clickAction = function (layerObj)
							LayerManager.removeLayer(layerObj)
							-- 资源是否充足
							for _, resInfo in pairs(resList) do
								if not Utility.isResourceEnough(resInfo.resourceTypeSub, resInfo.num, true, resInfo.modelId) then
									return
								end
							end
							cellItem.lockBtn:setTouchEnabled(false)
							ui.setWaveAnimation(cellItem.lockBtn, nil, false)
							Utility.performWithDelay(cellItem.lockBtn, function ()
								self:requestOpenPalace(palaceId)
							end, 1)
						end
					}
				},
				{})
			end,
		})
		lockBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		cellItem:addChild(lockBtn)
		cellItem.lockBtn = lockBtn
		-- 解锁需要碎片
		if index == self.mPalaceBaseInfo.PalaceNum+1 then
			local useStr = SectPalaceModelModel.items[palaceId].openNeed
			local resList = Utility.analysisStrResList(useStr)
			local textStrList = {}
			for _, resInfo in pairs(resList) do
				local textStr = "{"..Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId).."}"
				local ownNum = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
				textStr = (ownNum >= resInfo.num and "#258711" or "#ea2c00") ..textStr.. Utility.numberWithUnit(ownNum).."/"..Utility.numberWithUnit(resInfo.num)
				table.insert(textStrList, textStr)
			end
			local useTextStr = table.concat(textStrList, "  ")

			local useLabel = ui.newLabel({
				text = TR("需: %s", useTextStr),	
				color = Enums.Color.eWhite,
				outlineColor = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
			useLabel:setAnchorPoint(cc.p(1, 0.5))
			useLabel:setPosition(cellSize.width-40, 20)
			cellItem:addChild(useLabel)

			-- 小红点
			local function dealRedDotVisible(redDotSprite)
				local isEnough = true
	        	for _, resInfo in pairs(resList) do
					if not Utility.isResourceEnough(resInfo.resourceTypeSub, resInfo.num, false, resInfo.modelId) then
						isEnough = false
						break
					end
				end

				redDotSprite:setVisible(isEnough and index == self.mPalaceBaseInfo.PalaceNum+1)
	        end
		    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = lockBtn,
		        eventName = {LockRedDotEvent..index}})
		end
    end
end

-- 加速消化弹窗
function SectPalaceHomeLayer:createFinishUseBox(palaceInfo)
	local function DIYUiCallback(layerObj, bgSprite, bgSize)
		-- 加速花费
		local useLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(bgSize.width-60, 0),
			align = cc.TEXT_ALIGNMENT_CENTER,
		})
		useLabel:setAnchorPoint(cc.p(0.5, 0.5))
		useLabel:setPosition(bgSize.width*0.5, bgSize.height*0.5)
		bgSprite:addChild(useLabel)

		local function refreshUseLabel(timeLeft)
			local minute = math.ceil(timeLeft/60)
			local useStr = SectPalaceModelModel.items[palaceInfo.PalaceId].accelerateNeed
			local resList = Utility.analysisStrResList(useStr)
			local textStrList = {}
			for _, resInfo in pairs(resList) do
				local daibiImg = Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId)
				local textStr = "{"..daibiImg.."}"..resInfo.num*minute
				table.insert(textStrList, textStr)
			end
			local useResStr = table.concat(textStrList, "、")
			useLabel:setString(TR("是否花费 %s%s%s 加速探索", "#ffe748", useResStr, Enums.Color.eWhiteH))
		end


		-- 探索倒计时
		local timeLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
		timeLabel:setPosition(bgSize.width*0.5, bgSize.height-100)
		bgSprite:addChild(timeLabel)

		timeLabel.timeUpdate = Utility.schedule(timeLabel, function ()
			local timeLeft = palaceInfo.EndTime - Player:getCurrentTime()
			refreshUseLabel(timeLeft)
			if timeLeft > 0 then
				timeLabel:setString(TR("探索倒计时：%s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
			else
				timeLabel:setString(TR("探索完成"))
				timeLabel:stopAction(timeLabel.timeUpdate)
				LayerManager.removeLayer(layerObj)
			end
		end, 1)
	end
	LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = {
        	bgSize = cc.size(540, 336),
        	title = TR("加速探索"),
        	closeBtnInfo = {},
        	DIYUiCallback = DIYUiCallback,
        	btnInfos = {
        		{
        			text = TR("确定"),
        			clickAction = function (layerObj)
        				self:requestPalaceReward(palaceInfo.PalaceId, true)
        				LayerManager.removeLayer(layerObj)
        			end
        		}
        	},
        },
        cleanUp = false,
    })
end

-- 刷新界面
function SectPalaceHomeLayer:refreshUI()
	-- 刷新地宫列表
	self:refreshPalaceList()
	-- 刷新掠夺按钮小红点
	self.mPlunderBtn.redDot:setVisible(self.mPalaceBaseInfo.PlunderNum > 0)
end

-----------------服务器相关-----------------
-- 请求初始信息
function SectPalaceHomeLayer:requestInfo()
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mDefendHeroIdList = {}
            -- 基础信息
            self.mPalaceBaseInfo = response.Value.SectPalaceBaseInfo
            -- 掠夺记录
            self.mPlunderRecord = response.Value.SectPalacePlunderRecord
            -- 地宫信息
            for _, palaceInfo in pairs(response.Value.SectPalaceInfo) do
            	self.mPalaceInfoList[palaceInfo.PalaceId] = palaceInfo
	            -- 已派遣侠客
	            local heroIdList = palaceInfo.DefendHeroIdStr ~= "" and cjson.decode(palaceInfo.DefendHeroIdStr) or {}
	            for _, heroId in pairs(heroIdList) do
	            	table.insert(self.mDefendHeroIdList, heroId)
	            end
            end

            self:refreshUI()
        end
    })
end

-- 开启地宫
function SectPalaceHomeLayer:requestOpenPalace()
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "OpenPalace",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mDefendHeroIdList = {}
            self.mPalaceBaseInfo = response.Value.SectPalaceBaseInfo
            -- 地宫信息
            for _, palaceInfo in pairs(response.Value.SectPalaceInfo) do
            	self.mPalaceInfoList[palaceInfo.PalaceId] = palaceInfo
	            -- 已派遣侠客
	            local heroIdList = palaceInfo.DefendHeroIdStr ~= "" and cjson.decode(palaceInfo.DefendHeroIdStr) or {}
	            for _, heroId in pairs(heroIdList) do
	            	table.insert(self.mDefendHeroIdList, heroId)
	            end
            end

            self:refreshUI()
        end
    })
end

-- 探索地宫
function SectPalaceHomeLayer:requestExplorePalace(palaceId, heroIdList, goodsList, isDouble)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "OpenExplorePalace",
        svrMethodData = {palaceId, heroIdList, goodsList, isDouble},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            self.mDefendHeroIdList = {}
            for _, palaceInfo in pairs(response.Value.SectPalaceInfo) do
            	self.mPalaceInfoList[palaceInfo.PalaceId] = palaceInfo
            	-- 已派遣侠客
	            local heroIdList = palaceInfo.DefendHeroIdStr ~= "" and cjson.decode(palaceInfo.DefendHeroIdStr) or {}
	            for _, heroId in pairs(heroIdList) do
	            	table.insert(self.mDefendHeroIdList, heroId)
	            end
            end

            self:refreshUI()
        end
    })
end

-- 领奖
function SectPalaceHomeLayer:requestPalaceReward(palaceId, isAddSpeed)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "EndExplorePalace",
        svrMethodData = {palaceId, isAddSpeed},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mDefendHeroIdList = {}
            for _, palaceInfo in pairs(response.Value.SectPalaceInfo) do
            	self.mPalaceInfoList[palaceInfo.PalaceId] = palaceInfo
            	-- 已派遣侠客
	            local heroIdList = palaceInfo.DefendHeroIdStr ~= "" and cjson.decode(palaceInfo.DefendHeroIdStr) or {}
	            for _, heroId in pairs(heroIdList) do
	            	table.insert(self.mDefendHeroIdList, heroId)
	            end
            end

            self:refreshUI()
        end
    })
end

return SectPalaceHomeLayer