--[[
	文件名：SectPalaceReportLayer.lua
	描述：门派地宫掠夺界面
	创建人：yanghongsheng
	创建时间： 2019.3.16
--]]

local SectPalaceReportLayer = class("SectPalaceReportLayer", function(params)
	return display.newLayer()
end)

local TabTypeEums = {
	eRecord = 1,
	eEnemy = 2,
}

--[[
	params:
		baseInfo 		-- 地宫基础信息
		plunderRecord	-- 掠夺记录
		defaultTag		-- 默认tag
		callback 		-- 回调
]]

function SectPalaceReportLayer:ctor(params)
	self.mBaseInfo = params.baseInfo or {}
	self.mPlunderRecord = params.plunderRecord or {}
	self.mPlunderHeroIdList = {}
	self.mCurTag = params.defaultTag or TabTypeEums.ePlunder
	self.mCallback = params.callback
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 905),
        title = TR("宵小来袭"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 请求服务器数据
	self:requestInfo()
end

function SectPalaceReportLayer:getRestoreData()
	local ret = {
		baseInfo = self.mBaseInfo,
		plunderRecord = self.mPlunderRecord,
		defaultTag = self.mCurTag,
		callback = self.mCallback,
	}

	return ret
end

function SectPalaceReportLayer:initUI()
	-- 创建分页控件
	self:createTabView()
end

-- 创建分页控件
function SectPalaceReportLayer:createTabView()
	-- 创建分页
	local buttonInfos = {
	    {
	        text = TR("地宫记录"),
	        tag = TabTypeEums.eRecord,
	    },
	    {
	        text = TR("门派仇人"),
	        tag = TabTypeEums.eEnemy,
	    },
	}
	-- 创建分页
	local tabLayer = ui.newTabLayer({
	    btnInfos = buttonInfos,
	    viewSize = cc.size(self.mBgSize.width-50, 80),
	    needLine = false,
	    defaultSelectTag = self.mCurTag,
	    onSelectChange = function (selectTag)
	    	self:changPage(selectTag)
		end,
	})
	tabLayer:setAnchorPoint(cc.p(0.5, 0.5))
	tabLayer:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-90)
	self.mBgSprite:addChild(tabLayer)
	self.mTabView = tabLayer
end

-- 切换子页面
function SectPalaceReportLayer:changPage(selectTag)
	-- 当前tag
	self.mCurTag = selectTag

	-- 删除原子页
	if self.mBeforeLayer then
		self.mBeforeLayer:removeFromParent()
		self.mBeforeLayer = nil
	end

	-- 添加新子页
	-- 记录
	if TabTypeEums.eRecord == selectTag then
		self.mBeforeLayer = self:createRecordLayer()
	-- 仇人
	elseif TabTypeEums.eEnemy == selectTag then
		self.mBeforeLayer = self:createEnemyLayer()
	end
end

-- 创建记录页面
function SectPalaceReportLayer:createRecordLayer()
	local parentLayer = cc.Node:create()
	self.mBgSprite:addChild(parentLayer)

	local blackSize = cc.size(565, 750)
	-- 灰背景
	local blackBg = ui.newScale9Sprite("mpdg_2.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-122)
	parentLayer:addChild(blackBg)

	-- 战报列表
    local reportListView = ccui.ListView:create()
    reportListView:setDirection(ccui.ScrollViewDir.vertical)
    reportListView:setBounceEnabled(true)
    reportListView:setContentSize(cc.size(blackSize.width-20, blackSize.height-20))
    reportListView:setItemsMargin(10)
    reportListView:setAnchorPoint(cc.p(0.5, 0.5))
    reportListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
    blackBg:addChild(reportListView)

    -- 创建战报项
    local function createReportItem(reportInfo)
    	local reportItemSize = cc.size(reportListView:getContentSize().width, 125)
    	local reportItem = ccui.Layout:create()
    	reportItem:setContentSize(reportItemSize)

    	-- 背景
    	local bgSprite = ui.newScale9Sprite("c_18.png", reportItemSize)
    	bgSprite:setPosition(reportItemSize.width*0.5, reportItemSize.height*0.5)
    	reportItem:addChild(bgSprite)

    	-- 是否胜利
    	local isWin = nil
    	if reportInfo.PlunderType == 1 then			-- 去掠夺
    		isWin = reportInfo.IfPlunder
    	elseif reportInfo.PlunderType == 2 then		-- 被掠夺
    		isWin = not reportInfo.IfPlunder
    	end
    	reportInfo.IsWin = isWin
    	local winPic = isWin and "mpdg_19.png" or "mpdg_20.png"
    	local winSprite = ui.newSprite(winPic)
    	winSprite:setPosition(45, reportItemSize.height*0.5)
    	winSprite:setScale(0.8)
    	reportItem:addChild(winSprite)

    	-- 描述
    	local descStr = ""
    	if reportInfo.PlunderType == 1 then			-- 去掠夺
    		descStr = TR("门派地宫中掠夺 %s%s%s %s%s%s 的探索队伍", "#258711", reportInfo.PlunderPlayerName, Enums.Color.eWhiteH,
    			"#37ff40", SectPalaceModelModel.items[reportInfo.PalaceId].name, Enums.Color.eWhiteH)
    	elseif reportInfo.PlunderType == 2 then		-- 被掠夺
    		descStr = TR("门派地宫中被 %s%s%s 掠夺 %s%s%s 的探索队伍", "#ea2c00", reportInfo.PlunderPlayerName, Enums.Color.eWhiteH,
    			"#37ff40", SectPalaceModelModel.items[reportInfo.PalaceId].name, Enums.Color.eWhiteH)
    	end
    	-- 添加时间
    	local curDate = MqTime.getLocalDate(reportInfo.Crdate)
    	local timeStr = TR("于%s-%s-%s %02d:%02d:%02d，", curDate.year, curDate.month, curDate.day, curDate.hour, curDate.min, curDate.sec)
    	descStr = timeStr .. descStr

    	local descLabel = ui.newLabel({
    		text = descStr,
    		color = Enums.Color.eWhite,
    		dimensions = cc.size(300, 0),
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
    	descLabel:setAnchorPoint(cc.p(0, 0.5))
    	descLabel:setPosition(110, reportItemSize.height*0.5)
    	reportItem:addChild(descLabel)

        -- 战报按钮
        local reportBtn = ui.newButton({
        	normalImage = "c_28.png",
        	text = TR("战报"),
        	clickAction = function ()
        		-- 战斗页面控制信息
	    		local controlParams = Utility.getBattleControl(ModuleSub.eSectPalace)

	            local battleLayer
	            battleLayer = LayerManager.addLayer({
			        name = "ComBattle.BattleLayer",
			        cleanUp = true,
			        data = {
			            data = cjson.decode(reportInfo.FightInfo),
			            skip = controlParams.skip,
			            trustee = controlParams.trustee,
			            skill = controlParams.skill,
			            callback = function(retData)
			               PvpResult.showPvpResultLayer(ModuleSub.eSectPalace, reportInfo)

	                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
	                            controlParams.trustee.changeTrusteeState(retData.trustee)
	                        end
			            end
			        },
			    })
	        end,
        })
        reportBtn:setPosition(475, 90)
        reportItem:addChild(reportBtn)

        -- 结仇按钮
        local addEnemyBtn = ui.newButton({
        	normalImage = "c_28.png",
        	text = TR("结仇"),
        	clickAction = function ()
        		self:requestAddEnemy(reportInfo.PlunderPlayerId)
	        end,
	    })
	    addEnemyBtn:setPosition(475, 35)
        reportItem:addChild(addEnemyBtn)

        -- 是否已结仇
        for _, playerInfo in pairs(self.mEnemyList or {}) do
        	if playerInfo.PlayerId == reportInfo.PlunderPlayerId then
	        	addEnemyBtn:setEnabled(false)
	        	addEnemyBtn:setTitleText(TR("已结仇"))
	        	break
	        end
        end

        return reportItem
    end

    -- 按时间排序
    table.sort(self.mPlunderRecord, function (reportInfo1, reportInfo2)
    	return reportInfo1.Crdate > reportInfo2.Crdate
    end)

    local count = 0
    for _, reportInfo in ipairs(self.mPlunderRecord) do
    	if reportInfo.PlunderType == 2 then
	    	local reportItem = createReportItem(reportInfo)
	    	reportListView:pushBackCustomItem(reportItem)
	    	count = count + 1
	    end
    end

    if count <= 0 then
		local emptyHint = ui.createEmptyHint(TR("暂无战报"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
		parentLayer:addChild(emptyHint)
	end

	return parentLayer
end

-- 创建仇人页面
function SectPalaceReportLayer:createEnemyLayer()
	local parentLayer = cc.Node:create()
	self.mBgSprite:addChild(parentLayer)

	local blackSize = cc.size(565, 750)
	-- 灰背景
	local blackBg = ui.newScale9Sprite("mpdg_2.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-122)
	parentLayer:addChild(blackBg)

	-- 提示文字
	local hintLabel = ui.newLabel({
		text = TR("被标记为仇敌的玩家将会被优先掠夺，最多标记十位仇敌"),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		size = 20,
	})
	hintLabel:setAnchorPoint(cc.p(0, 0.5))
	hintLabel:setPosition(60, self.mBgSize.height-150)
	parentLayer:addChild(hintLabel)

	-- 仇人列表
    local enemyListView = ccui.ListView:create()
    enemyListView:setDirection(ccui.ScrollViewDir.vertical)
    enemyListView:setBounceEnabled(true)
    enemyListView:setContentSize(cc.size(blackSize.width-20, blackSize.height-70))
    enemyListView:setItemsMargin(10)
    enemyListView:setAnchorPoint(cc.p(0.5, 0.5))
    enemyListView:setPosition(blackSize.width*0.5, blackSize.height*0.5-20)
    blackBg:addChild(enemyListView)

    -- 创建战报项
    local function createEnemyItem(playerInfo)
    	local enemyItemSize = cc.size(enemyListView:getContentSize().width, 125)
    	local enemyItem = ccui.Layout:create()
    	enemyItem:setContentSize(enemyItemSize)

    	-- 背景
    	local bgSprite = ui.newScale9Sprite("c_18.png", enemyItemSize)
    	bgSprite:setPosition(enemyItemSize.width*0.5, enemyItemSize.height*0.5)
    	enemyItem:addChild(bgSprite)

    	-- 头像
        local headCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = playerInfo.HeadImageId,
            fashionModelID = playerInfo.FashionModelId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        headCard:setPosition(65, enemyItemSize.height*0.5)
        enemyItem:addChild(headCard)

        -- 玩家名
		local playerName = ui.newLabel({
				text = playerInfo.PlayerName,
				size = 22,
				color = cc.c3b(0xfb, 0x73, 0x73),
				outlineColor = Enums.Color.eBlack,
			})
		playerName:setAnchorPoint(cc.p(0, 0.5))
		playerName:setPosition(130, enemyItemSize.height*0.75)
		enemyItem:addChild(playerName)
		-- 会员等级
		local vipNode = ui.createVipNode(playerInfo.VipLv)
	    vipNode:setPosition(playerName:getContentSize().width+150, enemyItemSize.height*0.75)
	    enemyItem:addChild(vipNode)
	    -- 等级
		local lvLabel = ui.newLabel({
				text = TR("等级: %s%s", "#d17b00", playerInfo.Lv),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		lvLabel:setAnchorPoint(cc.p(0, 0.5))
		lvLabel:setPosition(130, enemyItemSize.height*0.5)
		enemyItem:addChild(lvLabel)
		-- 战力
		local fapLabel = ui.newLabel({
				text = TR("战力: %s%s", "#d17b00", Utility.numberFapWithUnit(playerInfo.Fap)),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		fapLabel:setAnchorPoint(cc.p(0, 0.5))
		fapLabel:setPosition(130, enemyItemSize.height*0.25)
		enemyItem:addChild(fapLabel)

		-- 删除仇人
		local deleteBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("删除"),
			clickAction = function ()
				self:requestRemoveEnemy(playerInfo.PlayerId)
			end
		})
		deleteBtn:setPosition(465, enemyItemSize.height*0.5)
		enemyItem:addChild(deleteBtn)

    	return enemyItem
    end

    if self.mEnemyList and next(self.mEnemyList) then
	    for _, playerInfo in pairs(self.mEnemyList) do
	    	local enemyItem = createEnemyItem(playerInfo)
	    	enemyListView:pushBackCustomItem(enemyItem)
	    end
	else
		local emptyHint = ui.createEmptyHint(TR("还没有仇人"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
		parentLayer:addChild(emptyHint)
	end
	return parentLayer
end

-- 刷新页面
function SectPalaceReportLayer:refreshUI()
	self:changPage(self.mCurTag)
end

--=========================服务器相关============================
-- 请求初始信息
function SectPalaceReportLayer:requestInfo()
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 基础信息
            self.mBaseInfo = response.Value.SectPalaceBaseInfo
            -- 仇人列表
            self.mEnemyList = self.mBaseInfo.EnemyPlayerStr ~= "" and cjson.decode(self.mBaseInfo.EnemyPlayerStr) or {}
            -- 掠夺记录
            self.mPlunderRecord = response.Value.SectPalacePlunderRecord

            self:initUI()

            if self.mCallback then
            	self.mCallback(self.mBaseInfo, self.mPlunderRecord)
            end
        end
    })
end

-- 添加仇人
function SectPalaceReportLayer:requestAddEnemy(playerId)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "AddEnemy",
        svrMethodData = {playerId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 基础信息
            self.mBaseInfo = response.Value.SectPalaceBaseInfo
            -- 仇人列表
            self.mEnemyList = self.mBaseInfo.EnemyPlayerStr ~= "" and cjson.decode(self.mBaseInfo.EnemyPlayerStr) or {}

            self:refreshUI()

            if self.mCallback then
            	self.mCallback(self.mBaseInfo, self.mPlunderRecord)
            end
        end
    })
end

-- 删除仇人
function SectPalaceReportLayer:requestRemoveEnemy(playerId)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "RemoveEnemy",
        svrMethodData = {playerId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 基础信息
            self.mBaseInfo = response.Value.SectPalaceBaseInfo
            -- 仇人列表
            self.mEnemyList = self.mBaseInfo.EnemyPlayerStr ~= "" and cjson.decode(self.mBaseInfo.EnemyPlayerStr) or {}

            self:refreshUI()

            if self.mCallback then
            	self.mCallback(self.mBaseInfo, self.mPlunderRecord)
            end
        end
    })
end

return SectPalaceReportLayer