--[[
	文件名：SectPalacePlunderLayer.lua
	描述：门派地宫掠夺界面
	创建人：yanghongsheng
	创建时间： 2019.3.16
--]]

local SectPalacePlunderLayer = class("SectPalacePlunderLayer", function(params)
	return display.newLayer()
end)

local TabTypeEums = {
	ePlunder = 1,
	eGoods = 2,
	eRecord = 3,
}

--[[
	params:
		baseInfo 		-- 地宫基础信息
		plunderRecord	-- 掠夺记录
		playerData 		-- 掠夺玩家列表
		defaultTag		-- 默认tag
		callback 		-- 回调
]]

function SectPalacePlunderLayer:ctor(params)
	self.mBaseInfo = params.baseInfo or {}
	self.mPlayerList = params.playerData or {}
	self.mPlunderRecord = params.plunderRecord or {}
	self.mPlunderHeroIdList = {}
	self.mCurTag = params.defaultTag or TabTypeEums.ePlunder
	self.mCallback = params.callback
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 995),
        title = TR("门派掠夺"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 请求服务器数据
	self:requestPlunderList(function ()
		self:initUI()
	end)
end

function SectPalacePlunderLayer:getRestoreData()
	local ret = {
		baseInfo = self.mBaseInfo,
		playerData = self.mPlayerList,
		plunderRecord = self.mPlunderRecord,
		defaultTag = self.mCurTag,
		callback = self.mCallback,
	}

	return ret
end

function SectPalacePlunderLayer:initUI()
	-- 创建分页控件
	self:createTabView()
end

-- 创建分页控件
function SectPalacePlunderLayer:createTabView()
	-- 创建分页
	local buttonInfos = {
	    {
	        text = TR("掠 夺"),
	        tag = TabTypeEums.ePlunder,
	    },
	    {
	        text = TR("我的道具"),
	        tag = TabTypeEums.eGoods,
	    },
	    {
	        text = TR("掠夺记录"),
	        tag = TabTypeEums.eRecord,
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
function SectPalacePlunderLayer:changPage(selectTag)
	-- 当前tag
	self.mCurTag = selectTag

	-- 删除原子页
	if self.mBeforeLayer then
		self.mBeforeLayer:removeFromParent()
		self.mBeforeLayer = nil
	end

	-- 添加新子页
	-- 掠夺
	if TabTypeEums.ePlunder == selectTag then
		self.mBeforeLayer = self:createPlunderLayer()
	-- 道具
	elseif TabTypeEums.eGoods == selectTag then
		self.mBeforeLayer = self:createGoodsLayer()
	-- 记录
	elseif TabTypeEums.eRecord == selectTag then
		self.mBeforeLayer = self:createRecordLayer()
	end
end

-- 创建掠夺页面
function SectPalacePlunderLayer:createPlunderLayer()
	local parentLayer = cc.Node:create()
	self.mBgSprite:addChild(parentLayer)

	-- 横线
	local lineSprite = ui.newScale9Sprite("mpdg_1.png", cc.size(self.mBgSize.width, 4))
	lineSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-123)
	parentLayer:addChild(lineSprite)

	-- 掠夺次数
	local plunderNumLabel = ui.newLabel({
		text = TR("今日剩余掠夺次数：%s次", self.mBaseInfo.PlunderNum or 0),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	plunderNumLabel:setAnchorPoint(cc.p(0, 0.5))
	plunderNumLabel:setPosition(60, self.mBgSize.height-150)
	parentLayer:addChild(plunderNumLabel)

	-- 刷新按钮
	local refreshBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("刷新"),
		clickAction = function ( ... )
			self:refreshPlunderList()
		end
	})
	refreshBtn:setPosition(self.mBgSize.width*0.5, 50)
	parentLayer:addChild(refreshBtn)

	-- 玩家列表
    local playerListView = ccui.ListView:create()
    playerListView:setDirection(ccui.ScrollViewDir.vertical)
    playerListView:setBounceEnabled(false)
    playerListView:setContentSize(cc.size(565, 735))
    playerListView:setItemsMargin(7)
    playerListView:setAnchorPoint(cc.p(0.5, 1))
    playerListView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-175)
    parentLayer:addChild(playerListView)

    -- 创建Hero列表项
    local function createHeroItem(heroInfo, playerName)
    	local heroItemSize = cc.size(320, 110)
    	local heroItem = ccui.Layout:create()
    	heroItem:setContentSize(heroItemSize)

    	-- 背景
    	local bgSprite = ui.newScale9Sprite("c_18.png", heroItemSize)
    	bgSprite:setPosition(heroItemSize.width*0.5, heroItemSize.height*0.5)
    	heroItem:addChild(bgSprite)

		local fashionModelId = ConfigFunc:getFashionModelId(heroInfo.IllusionModelId)
		local illusionModelId = ConfigFunc:getIllusionModelId(heroInfo.IllusionModelId)
        local heroFashionId = ConfigFunc:getHeroFashionModelId(heroInfo.IllusionModelId)
    	-- 主角
    	local headName, heroStep = ConfigFunc:getHeroName(heroInfo.HeroModelId, {playerName = playerName, heroStep = heroInfo.Step, IllusionModelId = illusionModelId, heroFashionId = heroFashionId})
    	local quality = IllusionModel.items[illusionModelId] and IllusionModel.items[illusionModelId].quality or HeroModel.items[heroInfo.HeroModelId].quality
    	if ConfigFunc:heroIsMain(heroInfo.HeroModelId) then
    		quality = FashionModel.items[fashionModelId] and FashionModel.items[fashionModelId].quality or HeroModel.items[heroInfo.HeroModelId].quality
    	end
    	if heroInfo.Step > 0 then
	        headName = headName .. "+".. heroStep
	    end
    	-- 头像
    	local headCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = heroInfo.HeroModelId,
            fashionModelID = fashionModelId,
            IllusionModelId = illusionModelId,
            heroFashionId = heroFashionId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        headCard:setSwallowTouches(false)
        headCard:setPosition(60, heroItemSize.height*0.5)
        heroItem:addChild(headCard)
        -- 名字
        local nameLabel = ui.newLabel({
			text = headName,
			color = Utility.getQualityColor(quality, 1),
			outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	        outlineSize = 2,
		})
		nameLabel:setAnchorPoint(cc.p(0, 0.5))
		nameLabel:setPosition(cc.p(120, heroItemSize.height-25))
		heroItem:addChild(nameLabel)
		-- 滚动
		ui.createLabelClipRoll({label = nameLabel, dimensions = cc.size(190, 30), anchorPoint = cc.p(0, 0.5), position = cc.p(120, heroItemSize.height-25)})
		-- 资质
		local qualityLabel = ui.newLabel({
			text = TR("资质:%s%d", Enums.Color.eBlackH, quality),
			color = Enums.Color.eBrown,
		})
		qualityLabel:setAnchorPoint(cc.p(0, 0.5))
		qualityLabel:setPosition(120, heroItemSize.height * 0.5)
		heroItem:addChild(qualityLabel)
		-- 战力
		local fapLabel = ui.newLabel({
			text = TR("战力:%s%s", Enums.Color.eBlackH, Utility.numberFapWithUnit(heroInfo.FAP)),
			color = Enums.Color.eBrown,
		})
		fapLabel:setAnchorPoint(cc.p(0, 0.5))
		fapLabel:setPosition(120, 25)
		heroItem:addChild(fapLabel)

    	return heroItem
    end

    -- 创建玩家列表项
    local function createPlayerItem(PlayerInfo)
    	local playerItemSize = cc.size(565, 240)
    	local playerItem = ccui.Layout:create()
    	playerItem:setContentSize(playerItemSize)

    	-- 灰背景
    	local blackBg = ui.newScale9Sprite("mpdg_2.png", playerItemSize)
    	blackBg:setPosition(playerItemSize.width*0.5, playerItemSize.height*0.5)
    	playerItem:addChild(blackBg)

    	-- 仇敌
    	if PlayerInfo.IfEnemy then
    		local enemySprite = ui.newSprite("mpdg_18.png")
    		enemySprite:setPosition(50, 45)
    		playerItem:addChild(enemySprite)
		end

		-- 地宫层数, 携带道具
		local useGoodsList = string.splitBySep(PlayerInfo.UseGoodsIdStr or "", ",")
		local goodsNameList = {}
		for _, goodsModelId in pairs(useGoodsList) do
			table.insert(goodsNameList, GoodsModel.items[tonumber(goodsModelId)].name)
		end
		local goodsStr = next(goodsNameList) and TR("，携带%s", table.concat(goodsNameList, ",")) or ""
		local palaceName = ui.newLabel({
			text = TR("%s%s队伍%s", PlayerInfo.PlayerName, SectPalaceModelModel.items[PlayerInfo.PalaceId].name, goodsStr),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
		palaceName:setAnchorPoint(cc.p(0, 0.5))
		palaceName:setPosition(20, playerItemSize.height-20)
		playerItem:addChild(palaceName)

    	-- 掠夺按钮
    	local plunderBtn = ui.newButton({
    		normalImage = "c_28.png",
			text = TR("掠夺"),
			clickAction = function ()
				if self.mBaseInfo.PlunderNum <= 0 then
					ui.showFlashView(TR("掠夺次数不足"))
					return
				end
				LayerManager.addLayer({
					name = "sect.SectPalaceSelectHeroLayer",
					data = {
						limitHeroIdList = self.mPlunderHeroIdList,
						btnTitle = TR("掠夺"),
						callback = function (heroIdList, goodsList)
							self:requestPlunder(PlayerInfo.PlayerId, PlayerInfo.PalaceId, heroIdList, goodsList)
						end,
					},
					cleanUp = false,
				})
			end
    	})
    	plunderBtn:setPosition(playerItemSize.width*0.3-10, 45)
    	playerItem:addChild(plunderBtn)

    	-- 掠夺倒计时
    	local plunderTimeLabel = ui.newLabel({
    		text = "",
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
    	plunderTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    	plunderTimeLabel:setPosition(playerItemSize.width*0.5-50, 45)
    	playerItem:addChild(plunderTimeLabel)
    	-- 计时器
    	plunderTimeLabel.plunderTimeUpdate = Utility.schedule(plunderTimeLabel, function ()
    		local timeLeft = PlayerInfo.EndTime - Player:getCurrentTime()
    		if timeLeft > 0 then
    			plunderTimeLabel:setString(TR("可被掠夺倒计时：#f8ea3a%s", MqTime.formatAsDay(timeLeft)))
    		else
    			self:refreshPlunderList()
    		end
	    end, 1)

    	-- 探索侠客列表
    	local heroListView = ccui.ListView:create()
	    heroListView:setDirection(ccui.ScrollViewDir.horizontal)
	    heroListView:setBounceEnabled(true)
	    heroListView:setContentSize(cc.size(playerItemSize.width-20, 110))
	    heroListView:setItemsMargin(5)
	    heroListView:setAnchorPoint(cc.p(0.5, 1))
	    heroListView:setPosition(playerItemSize.width*0.5, playerItemSize.height-45)
	    heroListView:setSwallowTouches(false)
	    playerItem:addChild(heroListView)

	    for _, heroInfo in pairs(PlayerInfo.HeroInfo or {}) do
		    local heroItem = createHeroItem(heroInfo, PlayerInfo.PlayerName)
		    heroListView:pushBackCustomItem(heroItem)
		end

	    return playerItem
    end

    -- 填充玩家列表
    playerListView:removeAllChildren()
    if next(self.mPlayerList) then
	    for _, playerInfo in pairs(self.mPlayerList) do
	    	local playerItem = createPlayerItem(playerInfo)
	    	playerListView:pushBackCustomItem(playerItem)
	    end
	else
		-- 空提示
		local emptyHint = ui.createEmptyHint(TR("暂无可掠夺的玩家，请稍后再来"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
		parentLayer:addChild(emptyHint)
	end

	return parentLayer
end

-- 创建道具页面
function SectPalacePlunderLayer:createGoodsLayer()
	local parentLayer = cc.Node:create()
	self.mBgSprite:addChild(parentLayer)

	local blackSize = cc.size(565, 660)
	-- 灰背景
	local blackBg = ui.newScale9Sprite("mpdg_2.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-120)
	parentLayer:addChild(blackBg)
	-- 显示道具简介
	local function showIntroLabel(goodsModelId)
		if not parentLayer.introParent then
			parentLayer.introParent = cc.Node:create()
			parentLayer:addChild(parentLayer.introParent)
		end
		parentLayer.introParent:removeAllChildren()

		local goodModel = GoodsModel.items[goodsModelId]
		-- 创建显示图片
        local card = CardNode.createCardNode({
        	resourceTypeSub = Utility.getTypeByModelId(goodModel.ID),
			modelId = goodModel.ID, 
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        card:setPosition(100, 140)
        parentLayer.introParent:addChild(card)
        -- 名字
        local nameLab = ui.newLabel({
	        text = TR(goodModel.name),
	        size = 22,
	        color = Utility.getQualityColor(goodModel.quality, 1),
	        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	        outlineSize = 2,
	        anchorPoint = cc.p(0, 1),
	        dimensions = cc.size(300, 0),
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	    })
	    nameLab:setPosition(160, 180)
	    parentLayer.introParent:addChild(nameLab)
	    -- 简介
	    local introLab = ui.newLabel({
	        text = TR(goodModel.intro),
	        size = 20,
	        color = cc.c3b(0x46, 0x22, 0x0d),
	        anchorPoint = cc.p(0, 0),
	        dimensions = cc.size(370, 0),
	        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	    })

	    local size = introLab:getContentSize()
	    local height = math.min(size.height, 60)
	    local scrollView = ccui.ScrollView:create()
	    scrollView:setContentSize(cc.size(370, height))
	    scrollView:setAnchorPoint(cc.p(0, 1))
	    scrollView:setPosition(cc.p(160, 140))
	    scrollView:setInnerContainerSize(introLab:getContentSize())
	    scrollView:addChild(introLab)
	    parentLayer.introParent:addChild(scrollView)
	end
	-- 道具gridView
	local goodsIdList = self.getGoodsList()
	if next(goodsIdList) then
	    local goodsGridView = require("common.GridView"):create({
	        viewSize = cc.size(blackSize.width, blackSize.height-10),
	        colCount = 5,
	        celHeight = 120,
	        selectIndex = 1,
	        needDelay = true,
	        getCountCb = function()
	            return #goodsIdList
	        end,
	        createColCb = function(itemParent, colIndex, isSelected)
	        	local attrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                end
                local goodModel = GoodsModel.items[goodsIdList[colIndex]]
                -- 创建显示图片
                local card, Attr = CardNode.createCardNode({
                	resourceTypeSub = Utility.getTypeByModelId(goodModel.ID),
        			modelId = goodModel.ID, 
			        num = GoodsObj:getCountByModelId(goodModel.ID),
                    cardShowAttrs = attrs,
                    onClickCallback = function()
                        showIntroLabel(goodModel.ID)
                        parentLayer.goodsGridView:setSelect(colIndex)
                    end,
                })
                card:setPosition(64, 60)
                itemParent:addChild(card)
	        end,
	    })
	    goodsGridView:setAnchorPoint(cc.p(0.5, 0.5))
	    goodsGridView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	    blackBg:addChild(goodsGridView)
	    parentLayer.goodsGridView = goodsGridView

	    showIntroLabel(goodsIdList[1])
	else
		-- 空提示
		local emptyHint = ui.createEmptyHint(TR("没有可用的道具"))
		emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
		parentLayer:addChild(emptyHint)
	end
	return parentLayer
end

-- 创建道具页面
function SectPalacePlunderLayer:createRecordLayer()
	local parentLayer = cc.Node:create()
	self.mBgSprite:addChild(parentLayer)

	local blackSize = cc.size(565, 840)
	-- 灰背景
	local blackBg = ui.newScale9Sprite("mpdg_2.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-120)
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
        reportBtn:setPosition(475, reportItemSize.height*0.5)
        reportItem:addChild(reportBtn)

        return reportItem
    end

    -- 按时间排序
    table.sort(self.mPlunderRecord, function (reportInfo1, reportInfo2)
    	return reportInfo1.Crdate > reportInfo2.Crdate
    end)

    local count = 0
    for _, reportInfo in ipairs(self.mPlunderRecord) do
    	if reportInfo.PlunderType == 1 then
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

-- 刷新掠夺列表
function SectPalacePlunderLayer:refreshPlunderList()
	self:requestPlunderList(function ()
		self:changPage(self.mCurTag)
	end)
end

-- 刷新已经使用的掠夺学员列表
function SectPalacePlunderLayer:refreshPlunderHeroIdList()
	self.mPlunderHeroIdList = {}
	local heroIdList = self.mBaseInfo.PlunderHeroIdStr ~= "" and cjson.decode(self.mBaseInfo.PlunderHeroIdStr) or {}
    for _, heroId in pairs(heroIdList) do
    	table.insert(self.mPlunderHeroIdList, heroId)
    end
end

-- 获取列表道具
function SectPalacePlunderLayer.getGoodsList()
	local goodsModelIdList = {
		16050529,	-- 捕兽夹
		16050530,	-- 强体丹
		16050531,	-- 迷烟
	}
	local tempList = {}
	for _, goodsModelId in pairs(goodsModelIdList) do
		if GoodsObj:findByModelId(goodsModelId) then
			table.insert(tempList, goodsModelId)
		end
	end

	return tempList
end

--=========================服务器相关============================
-- 获取掠夺列表
function SectPalacePlunderLayer:requestPlunderList(callback)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "GetPlunderList",
        svrMethodData = {prescriptionId, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "掠夺列表")
            -- 可掠夺玩家列表
            self.mPlayerList = response.Value.PlunderPlayerData
            -- 刷新已经使用的掠夺学员列表
            self:refreshPlunderHeroIdList()
            -- 刷新页面
            if callback then
				callback()
			end
        end
    })
    
end

-- 掠夺玩家
function SectPalacePlunderLayer:requestPlunder(playerId, palaceId, heroList, goodsList)
    HttpClient:request({
        moduleName = "SectPalace",
        methodName = "Plunder",
        svrMethodData = {playerId, palaceId, heroList, goodsList},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            self.mBaseInfo = response.Value.SectPalaceBaseInfo
            self.mPlunderRecord = response.Value.SectPalacePlunderRecord
            -- 可掠夺玩家列表
            self.mPlayerList = response.Value.PlunderPlayerData
            -- 刷新已经使用的掠夺学员列表
            self:refreshPlunderHeroIdList()

            if self.mCallback then
            	self.mCallback(self.mBaseInfo, self.mPlunderRecord)
            end

         --    if response.Value.IsWin then
	        --     ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	        -- else
	        -- 	ui.showFlashView("掠夺失败")
	        -- end

         --    self:changPage(self.mCurTag)

    		-- 战斗页面控制信息
    		local controlParams = Utility.getBattleControl(ModuleSub.eSectPalace)

            local battleLayer
            battleLayer = LayerManager.addLayer({
		        name = "ComBattle.BattleLayer",
		        cleanUp = true,
		        data = {
		            data = response.Value.FightInfo,
		            skip = controlParams.skip,
		            trustee = controlParams.trustee,
		            skill = controlParams.skill,
		            callback = function(retData)
		               PvpResult.showPvpResultLayer(ModuleSub.eSectPalace, response.Value)

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
		            end
		        },
		    })
        end
    })
    
end

return SectPalacePlunderLayer