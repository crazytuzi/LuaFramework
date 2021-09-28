--[[
	文件名：GGZJRecruitLayer.lua
	描述：大罗金库佣兵招募页面
	创建人：suntao
    修改人：lengjiazhi
	创建时间：2016.6.6
--]]

local GGZJRecruitLayer = class("GGZJRecruitLayer", function()
    return display.newLayer()
end)

require("Config.XrxsConfig")

-- 预定义量
local PrivateModule = {
	eShareHero = 1,
	eSystemHero = 2,
}

local TabsConfig = {
    {
        name = TR("帮派佣兵"),
        moduleId = PrivateModule.eShareHero,
    },
    {
        name = TR("侠客试用"),
        moduleId = PrivateModule.eSystemHero,
    },
}
local tempTokenList = Utility.analysisStrResList(XrxsConfig.items[1].hireUse)
local TokenModelId = tempTokenList[1].modelId
local TokenName = ""

-- 构造函数
--[[
	params:
	{
		tag		初始页面，默认为第一个
	}
--]]
function GGZJRecruitLayer:ctor(params)
	-- 参数
	self.mOriginalTag = params.tag or PrivateModule.eShareHero
	if self.mOriginalTag == PrivateModule.eShareHero and not Utility.isEntityId(GuildObj:getGuildInfo().Id) then
		self.mOriginalTag = PrivateModule.eSystemHero
	end
    -- 新手引导时，默认显示系统佣兵
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 4005 then
        self.mOriginalTag = PrivateModule.eSystemHero
    end

    self.mCurrentPageTag = self.mOriginalTag
    --dump(self.mOriginalTag, 99999)

    TokenName = ConfigFunc:getGoodsName(TokenModelId)
	self.mDataTable = {}
	self.mPages = {}
	self.mCurTag = nil

	-- 显示可变控件
	self.mTokenNumLabel = nil

	-- 创建层
    self:createLayer()

    -- 显示代币数量
    self:refreshToken()

    -- 选择初始页面
    self:changePage(self.mOriginalTag)
end

-- 创建层
function GGZJRecruitLayer:createLayer()
	-- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建背景
    local sprite = ui.newSprite("bp_12.jpg")
    sprite:setPosition(320, 568)
    self.mParentLayer:addChild(sprite, Enums.ZOrderType.eDefault - 2)

    -- 下半部分背景
    self.cellBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1032))
    self.cellBgSprite:setPosition(320, 0)
    self.cellBgSprite:setAnchorPoint(0.5, 0)
    self.mParentLayer:addChild(self.cellBgSprite)

    -- 创建提示
    local sprite = ui.newScale9Sprite("c_25.png", cc.size(640, 48))
    sprite:setContentSize(680, 46)
    sprite:setPosition(320, 978)
    self.mParentLayer:addChild(sprite)

    -- 创建消耗品个数背景
    local sprite = ui.newScale9Sprite("tjl_19.png")
    sprite:setContentSize(150, 40)
    sprite:setAnchorPoint(0, 0.5)
    sprite:setPosition(22, 925)
    self.mParentLayer:addChild(sprite)

    -- 创建获取途径提示背景
    -- local sprite = ui.newScale9Sprite("c_25.png")
    -- sprite:setContentSize(150, 40)
    -- sprite:setAnchorPoint(0, 0.5)
    -- sprite:setPosition(405, 925)
    -- self.mParentLayer:addChild(sprite)

    -- 创建UI
    self:initUI()
end

-- 创建UI
function GGZJRecruitLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            {
                resourceTypeSub = ResourcetypeSub.eFunctionProps,
                modelId = 16050016,
            }
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    -- 创建退出按钮
    local button = ui.newButton({
            normalImage = "c_29.png",
            anchorPoint = cc.p(0.5, 0.5),
            position = cc.p(600, 1050),
            clickAction = function()
                LayerManager.removeLayer(self)
            end
        })
    self.mParentLayer:addChild(button, Enums.ZOrderType.eDefault + 5)
    self.mCloseBtn = button

    -- 创建招募提示标签
    local label = ui.newLabel({
    	text = TR("每种通缉等级每日可招募一名佣兵协助作战，佣兵不能超过主角%d级",
    		XrxsConfig.items[1].hireLVDiffMax),
    	anchorPoint = cc.p(0, 0.5),
    	x = 0,
    	y = 978,
        size = 21,
        dimensions = cc.size(640, 0),
        outlineColor = Enums.Color.eOutlineColor,
        align = cc.TEXT_ALIGNMENT_CENTER
    })
    self.mParentLayer:addChild(label)

    label:setScaleY(0)
    label:runAction(cc.ScaleTo:create(0.2, 1))

    -- 获取途径提示
    -- local label = ui.newLabel({
    -- 	text = TR("获取途径"),
    -- 	color = Enums.Color.eNormalWhite,
    -- 	anchorPoint = cc.p(0, 0.5),
    -- 	x = 415,
    -- 	y = 925,
    -- })
    -- self.mParentLayer:addChild(label)

    ----- 可操作控件 -----
    -- 购买按钮
    local button = ui.newButton({
		text = TR("购买"),
		textColor = Enums.Color.eWhite,
        normalImage = "c_28.png",
        size = cc.size(115, 50),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(147, 925),
        clickAction = function()
            self:requestGetShopGoodsInfo(TokenModelId)
        end
    })
    self.mParentLayer:addChild(button)

    -- 查看获取途径按钮
    local button = ui.newButton({
    		text = TR("获取途径"),
            normalImage = "c_33.png",
            size = cc.size(115, 50),
            anchorPoint = cc.p(0, 0.5),
            position = cc.p(505, 925),
            clickAction = function()
                -- 规则
                local rules = {
                    [1] = TR("1.道具商城可使用元宝购买"),
                    [2] = TR("2.帮派每日使用中级和高级建设可获得"),
                    [3] = TR("3.每日任务130积分宝箱"),
                    [4] = TR("4.帮派商店每日购买"),
                }
                MsgBoxLayer.addRuleHintLayer(TR(TokenName), rules)
            end
        })
    self.mParentLayer:addChild(button)

    -- 创建标签
    self:createTabs()

    ----- 显示可变控件 -----
    -- 代币数值控件
    local tempCount = GoodsObj:getCountByModelId(16050016)
    local label = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eFunctionProps,
        goodsModelId = 16050016,
        number = 0,
        fontColor = Enums.Color.eNormalWhite,
    })
    label:setPosition(60, 925)
    self.mParentLayer:addChild(label, 10)
    self.mTokenNumLabel = label
end

-- 创建标签
function GGZJRecruitLayer:createTabs()
    -- 初始化按钮信息
    local buttonInfos = {}
    for i, config in ipairs(TabsConfig) do
        buttonInfos[i] = {
            text = TR(config.name),
            tag = config.moduleId,
        }
    end

    -- 创建标签
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        defaultSelectTag = self.mOriginalTag,
        onSelectChange = function (tag)
            self.mCurrentPageTag = tag
            self:changePage(tag)
        end,
        allowChangeCallback = function (tag)
        	if tag == PrivateModule.eShareHero and not Utility.isEntityId(GuildObj:getGuildInfo().Id) then
        		ui.showFlashView(TR("尚未加入帮派"))
        		return false
        	else
        		return true
        	end
     	end
    })
    tabLayer:setAnchorPoint(cc.p(0, 0))
    tabLayer:setPosition(cc.p(0, 1012))

    self.mParentLayer:addChild(tabLayer, Enums.ZOrderType.eDefault + 1)
    self.mTabs = tabLayer
end

-- 跳转到分页
function GGZJRecruitLayer:changePage(tag)
    if self.mTabs == nil then
        return
    end

    local oldTag = self.mCurTag
    -- 隐藏旧分页
    if self.mPages[oldTag] ~= nil then
        self.mPages[oldTag]:setVisible(false)
    end

    -- 转到新分页
    self.mCurTag = tag
    local page = self.mPages[tag]
    if page ~= nil and not page.needReload then
        -- 页面存在
        page:setVisible(true)

        -- 暂时没有此类佣兵
        if #page.itemsData == 0 then
            --ui.showFlashView("暂时没有此类佣兵")
            if not self.mEmptyHint then
                self.mEmptyHint = ui.createEmptyHint(TR("暂时没有此类佣兵"))
                self.mEmptyHint:setPosition(320, 520)
                self.mParentLayer:addChild(self.mEmptyHint)
            end
            self.mEmptyHint:setVisible(true)
        elseif self.mEmptyHint then
           self.mEmptyHint:setVisible(false)
        end
    else
        -- 页面不存在
        if tag == PrivateModule.eShareHero then
        	-- 共享英雄
        	self:requestGetGuildShare()
        elseif tag == PrivateModule.eSystemHero then
        	-- 系统英雄
        	local itemsData = self:systemHeroConfig()
            self:addPage(tag, itemsData, true)
    	end
    end
end

--- ==================== 单个Page相关 =======================
-- 预定义常量
local Page = {
    width = 628,
    height = 780,
    x = 320,
    y = 115,
}

local Item = {
    width = Page.width,
    height = 135,
    headerWidth = 125,
    textWidth = 340,
    buttonsWidth = 150,
}

-- 添加新分页(如果对应的页面已经存在，先移除后添加)
function GGZJRecruitLayer:addPage(tag, itemsData, needAction)
	-- 列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(Page.width, Page.height))
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(10)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(Page.x, Page.y)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(listView)

    -- 添加Item
    for i, data in ipairs(itemsData) do
        local item = self:createItem(tag, data)
        listView:pushBackCustomItem(item)
    end

    listView:jumpToTop()

    -- 暂时没有此类佣兵
    if #itemsData == 0 then
        if not self.mEmptyHint then
            self.mEmptyHint = ui.createEmptyHint(TR("暂时没有帮派佣兵"))
            self.mEmptyHint:setPosition(320, 600)
            self.mParentLayer:addChild(self.mEmptyHint)
        end
        self.mEmptyHint:setVisible(true)
    elseif self.mEmptyHint then
       self.mEmptyHint:setVisible(false)
    end

    self:removePage(tag)

    self.mPages[tag] = listView
    listView.itemsData = itemsData
end

-- 删除分页
function GGZJRecruitLayer:removePage(tag)
    if self.mPages[tag] ~= nil then
        self.mParentLayer:removeChild(self.mPages[tag])
        self.mPages[tag] = nil
    end
end

--- ==================== 单个Item相关 =======================
-- 创建新Item
function GGZJRecruitLayer:createItem(moduleId, originalData)
	local data = self:extractData(moduleId, originalData)
    -- 创建Item容器
    local layout = ccui.Layout:create()
    layout:setContentSize(Item.width, Item.height)

    -- 添加背景
    local sprite = ui.newScale9Sprite("c_65.png", cc.size(Item.width, Item.height))
    sprite:setAnchorPoint(0, 0)
    layout:addChild(sprite)

    -- 左方头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = data.heroModelId,
        IllusionModelId = data.IllusionModelId,
        cardShowAttrs = {CardShowAttr.eBorder},
        allowClick = false,
    })
    -- header:setCardLevel(data.Lv)
    header:setPosition(Item.headerWidth / 2 + 5, Item.height / 2)
    layout:addChild(header)

    if Utility.isEntityId(data.playerId) then
        local fapName
        for i,v in ipairs(GgzjGuildHeronameRelation.items) do
            if data.fap >= v.fapMin and data.fap <= v.fapMax then

                fapName = v.name
                break
            end
        end
        local fapStepLabel = ui.newLabel({
            text = TR("称号：%s", fapName),
            color = Enums.Color.eBlack,
            size = 22,
            })
        fapStepLabel:setPosition(Item.headerWidth / 2 + 330, Item.height / 2 + 30)
        layout:addChild(fapStepLabel)
    end

    -- 显示文字信息
    local textLayout = self:createTextLayout(moduleId, data)
    textLayout:setAnchorPoint(0, 0)
    textLayout:setPosition(Item.headerWidth, 0)
    layout:addChild(textLayout)

    -- 显示代币消耗信息
    local resInfo = Utility.analysisStrResList(data.hireUse)[1]
    local label = ui.createDaibiView({
    	resourceTypeSub = resInfo.resourceTypeSub,
    	goodsModelId = resInfo.modelId,
    	number = resInfo.num,
    })
    label:setPosition(536, 100)
    layout:addChild(label)

    -- 显示招募按钮
    local button = ui.newButton({
		text = TR("招募"),
        normalImage = "c_28.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(536, 47),
        clickAction = function()
            if Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId) >= resInfo.num then
            	self:createRecruitLayer(moduleId, data)
            else
                local btnlist = {
                    {
                        text = TR("购买"),
                        position = cc.p(140, 50),
                        normalImage = "c_28.png",
                        clickAction = function ()
                            self:requestGetShopGoodsInfo(TokenModelId)
                        end
                    },
                    {
                        text = TR("取消"),
                        position = cc.p(420, 50),
                        normalImage = "c_28.png",
                    }
                }

                -- 佣兵令不足时提示DIY函数
                local function DIYMsgBoxFunc(layerObj, layerBgSprite, bgSize)
                    -- 创建佣兵令图标
                    local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
                    local cardNode = CardNode:create({allowClick = false,})
                    cardNode:setGoods({ModelId = TokenModelId}, showAttrs)
                    cardNode:setPosition(bgSize.width / 2, bgSize.height / 2 + 20)
                    layerBgSprite:addChild(cardNode)

                    -- 创建提示购买信息
                    local tempNode = ui.createSpriteAndLabel({
                        imgName = "c_83.png",
                        scale9Size = cc.size(490, 40),
                        labelStr = TR("你的佣兵牌不足，购买获得更多佣兵牌"),
                        fontSize = 20,
                        fontColor = Enums.Color.eBlack,
                    })
                    tempNode:setPosition(bgSize.width / 2, bgSize.height / 2 + 85)
                    layerBgSprite:addChild(tempNode)

                    -- 创建现有佣兵令数量
                    local tempStr = Utility.getOwnedGoodsCount(resInfo.resourceTypeSub, resInfo.modelId)
                    local nameLabel = ui.newLabel({
                        text = TR("佣兵牌：%s", tempStr),
                        color = Enums.Color.eBlack,
                        size = 20,
                    })
                    nameLabel:setPosition(bgSize.width / 2, bgSize.height / 2 - 75)
                    layerBgSprite:addChild(nameLabel)
                end
                -- 佣兵令不足时的弹窗
                MsgBoxLayer.addDIYLayer({
                    bgSize = cc.size(572, 382),
                    btnInfos = btnlist,
                    closeBtnInfo = {},
                    DIYUiCallback = DIYMsgBoxFunc
                })
            end
        end
    })
    layout:addChild(button)

    if not self.mHireBtn_ then
        self.mHireBtn_ = button
    end

    return layout
end

-- 创建信息显示容器（包括标题，时间，内容）
function GGZJRecruitLayer:createTextLayout(moduleId, data)
	local offset = 30

    local layout = ccui.Layout:create()
    layout:setContentSize(350, Item.height)
    -- 显示名字等级
    local nameText = data.name
    if data.Lv then
        nameText = TR("等级%d %s",data.Lv, data.name)
    end
    local labelInfo = {
        text = nameText,
        color = Enums.Color.eBlack,
        anchorPoint = cc.p(0, 1),
        size = 24,
        x = 0,
        y = 112,
    }
    layout:addChild(ui.newLabel(labelInfo))

    -- 显示战力
    labelInfo.size = 24
    labelInfo.text = TR("战力：%s%s", Enums.Color.eRedH, Utility.numberFapWithUnit(data.fap))
    labelInfo.y = labelInfo.y - offset
    layout:addChild(ui.newLabel(labelInfo))

    -- 显示归属
    labelInfo.text = TR("归属：%s%s", "#8d26c8", data.ownerName)
    labelInfo.y = labelInfo.y - offset
    layout:addChild(ui.newLabel(labelInfo))

    return layout
end

-- 提取数据
function GGZJRecruitLayer:extractData(moduleId, originalData)
	local data = {}
	-- 分类处理
	if moduleId == PrivateModule.eShareHero then
		data.heroModelId = originalData.ModelId
        data.IllusionModelId = originalData.IllusionModelId
		data.ownerName = originalData.PlayerName
		data.hireUse = XrxsConfig.items[1].hireUse

		data.playerId = originalData.PlayerId
	else
		data.heroModelId = originalData.heroModelID
		data.ownerName = TR("系统")
		data.hireUse = XrxsConfig.items[1].highHireUse

        data.playerId = EMPTY_ENTITY_ID
	end
	-- 统一处理
	data.fap = originalData.FAP
	data.name = ConfigFunc:getHeroName(data.heroModelId, {IllusionModelId = data.IllusionModelId})
    data.Lv = originalData.Lv
	return data
end

-- 系统佣兵配置
function GGZJRecruitLayer:systemHeroConfig()
    local itemsData = {}
    local originalData = XrxsSystemHeroRelation.items[PlayerAttrObj:getPlayerAttrByName("Lv")]
    if originalData == nil then
        ui.showFlashView(TR("配置文件解析错误"))
    end

    for i, data in pairs(originalData) do
        table.insert(itemsData, data)
    end

    return itemsData
end

-- 招募弹窗
function GGZJRecruitLayer:createRecruitLayer(moduleId, data)
    self.mRecruitLayer = MsgBoxLayer.addDIYLayer({
        btnInfos = {
           {
                text = TR("招募"),
                clickAction = function()
                     self:requestHire(moduleId, data)
                end,
                position = cc.p(150, 60)
            },
            {
                text = TR("取消"),
                normalImage = "c_28.png",
                position = cc.p(430, 60)
            },
        },
        title = TR("招募侠客"),
        DIYUiCallback = function (pSender, mBgSprite)
            local heroNameColor = Utility.getColorValue(Utility.getColorLvByModelId(data.heroModelId),2)
            local RecruitLabel = ui.newLabel({
                text = TR("确定招募%s%s%s吗？", heroNameColor, data.name, Enums.Color.eNormalWhiteH),
                size = 22,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(492, 0),
                align = ui.TEXT_ALIGN_CENTER,
                })
            RecruitLabel:setAnchorPoint(cc.p(0.5, 0.5))
            RecruitLabel:setPosition(286, 235)
            mBgSprite:addChild(RecruitLabel)
            local RecruitLabel2 = ui.newLabel({
                text = TR("（同时只能存在一个招募对象，如果继续招募佣兵，新的佣兵将替代原来的招募对象）"),
                size = 22,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(400, 0),
                })
            RecruitLabel2:setAnchorPoint(cc.p(0.5, 0.5))
            RecruitLabel2:setPosition(286, 170)
            mBgSprite:addChild(RecruitLabel2)
        end
    })

    -- 延时继续新手引导
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 4006 then
        Utility.performWithDelay(self.mRecruitLayer, handler(self, self.executeGuide), 0.25)
    end
end

--- ==================== 数据刷新相关相关 =======================
-- 刷新代币数量
function GGZJRecruitLayer:refreshToken()
    self.mTokenNumLabel.setNumber(Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, TokenModelId))
end

--- ==================== 服务器数据请求相关 =======================
-- 获取共享英雄数据
function GGZJRecruitLayer:requestGetGuildShare()
	HttpClient:request({
		moduleName = "Guild",
		methodName = "GetGuildShare",
		callback = function(response)
		    if response.Status == 0 then
		        -- 过滤自身共享英雄
		        local infos = response.Value.GuildShareInfo
		        for i=#infos, 1, -1 do
		        	if infos[i].ShareId == response.Value.ShareId then
		        		table.remove(infos, i)
		        	end
		        end
		        self.mDataTable[PrivateModule.eShareHero] = infos
                table.sort(infos, function (a, b)
                    if a.FAP ~= b.FAP then
                        return a.FAP > b.FAP
                    end
                    return a.ModelId > b.ModelId
                end)
		        self:addPage(PrivateModule.eShareHero, infos, true)
		    end
		end
	})
end

-- 招募请求
function GGZJRecruitLayer:requestHire(moduleId, data)
	HttpClient:request({
		moduleName = "XrxsInfo",
		methodName = "Hire",
		svrMethodData = {moduleId, data.playerId, data.heroModelId},
        callbackNode = self,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(4006),
		callback = function(response)
		    if response.Status == 0 then
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 4006 then
                    Guide.manager:nextStep(eventID)
                end

		        ui.showFlashView(TR("雇佣成功"))
                LayerManager.removeLayer(self)
                -- 刷新显示
                -- self:refreshToken()
		    end

            if self.mRecruitLayer ~= nil then
                LayerManager.removeLayer(self.mRecruitLayer)
                self.mRecruitLayer = nil
            end
		end
	})
end

-- 获取道具的购买信息
function GGZJRecruitLayer:requestGetShopGoodsInfo(goodsModelId)
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "GetShopGoodsInfo",
        svrMethodData = {goodsModelId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            MsgBoxLayer.addBuyGoodsCountLayer(
                TR("购买%s", TokenName),
                response.Value[1],
                function(selCount, layerObj, btnObj, selPrice)
                    layerObj:removeFromParent()
                    self:requestBuyGoods(goodsModelId, selCount, response.Value[1].SellTypeId, selPrice)
                end
            )
        end
    })
end

-- 道具购买请求
function GGZJRecruitLayer:requestBuyGoods(goodsModelId, selCount, priceType, selPrice)
    if selCount == 0 then
        return
    end
    if not Utility.isResourceEnough(priceType, selPrice, true) then
        return
    end
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "BuyGoods",
        svrMethodData = {goodsModelId, selCount},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.showFlashView(TR("购买成功"))
            self:refreshToken()

            -- 系统佣兵配置
            local itemsData = self:systemHeroConfig()
            -- 刷新页面
            if next(self.mDataTable) and self.mCurrentPageTag == PrivateModule.eShareHero then
                if next(self.mDataTable[1]) then
                    self.mCurTag = PrivateModule.eShareHero
                    self.mTabs:activeTabBtnByTag(PrivateModule.eShareHero)
                    self:changePage(PrivateModule.eShareHero, self.mDataTable[PrivateModule.eShareHero])
                    self:addPage(PrivateModule.eShareHero, self.mDataTable[PrivateModule.eShareHero])
                else
                    self.mCurTag = PrivateModule.eSystemHero
                    self.mTabs:activeTabBtnByTag(PrivateModule.eSystemHero)
                    self:addPage(PrivateModule.eSystemHero, itemsData)
                end
            else
                self.mCurTag = PrivateModule.eSystemHero
                self.mTabs:activeTabBtnByTag(PrivateModule.eSystemHero)
                self:addPage(PrivateModule.eSystemHero, itemsData)
            end
        end
    })
end


----------------- 新手引导 -------------------
function GGZJRecruitLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function GGZJRecruitLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向招募按钮
        [4005] = {clickNode = self.mHireBtn_},
        -- 指向第一个招募确定按钮
        [4006] = {clickNode = self.mRecruitLayer and self.mRecruitLayer:getBottomBtns()[1]},
    })
end

return GGZJRecruitLayer
