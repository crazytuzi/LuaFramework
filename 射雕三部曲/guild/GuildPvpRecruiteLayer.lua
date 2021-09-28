--[[
	文件名：GuildPvpRecruiteLayer.lua
	描述：帮派战斗佣兵招募界面
	创建人：yanghongsheng
	创建时间： 2017.1.8
--]]
local GuildPvpRecruiteLayer = class("GuildPvpRecruiteLayer", function(params)
	return display.newLayer()
end)

-- 佣兵令
local tempTokenList = Utility.analysisStrResList(XrxsConfig.items[1].hireUse)
local TokenModelId = tempTokenList[1].modelId
local TokenName = ""

--[[
    params:
        targetId        给某个玩家招募的玩家id(默认自己)
]]

function GuildPvpRecruiteLayer:ctor(params)
    self.mTargetId = params.targetId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

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
    self:addChild(topResource)

    self:initUI()

    self:requestInfo()
end

function GuildPvpRecruiteLayer:initUI()
	-- 创建背景
	local sprite = ui.newSprite("bp_12.jpg")
	sprite:setPosition(320, 568)
	self.mParentLayer:addChild(sprite)

	-- 显示页签
	self:showTabLayer()

	-- 下半部分背景
	self.cellBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
	self.cellBgSprite:setPosition(320, 0)
	self.cellBgSprite:setAnchorPoint(0.5, 0)
	self.mParentLayer:addChild(self.cellBgSprite)

	-- 创建消耗品个数背景
	local sprite = ui.newScale9Sprite("tjl_19.png")
	sprite:setContentSize(150, 40)
	sprite:setAnchorPoint(0, 0.5)
	sprite:setPosition(22, 940)
	self.mParentLayer:addChild(sprite)

	-- 代币数值控件
    local label = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eFunctionProps,
        goodsModelId = 16050016,
        number = 0,
        fontColor = Enums.Color.eNormalWhite,
    })
    label:setPosition(60, 940)
    self.mParentLayer:addChild(label, 10)
    self.mTokenNumLabel = label

	-- 购买按钮
    local button = ui.newButton({
		text = TR("购买"),
		textColor = Enums.Color.eWhite,
        normalImage = "c_28.png",
        size = cc.size(115, 50),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(147, 940),
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
            position = cc.p(505, 940),
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

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(628, 780))
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(10)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(320, 115)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(listView)
    self.mListView = listView
end


-- 显示页签
function GuildPvpRecruiteLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("帮派佣兵"),
            tag = 1,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
    })

    tabLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tabLayer)
end

--- ==================== 单个Item相关 =======================
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
-- 创建新Item
function GuildPvpRecruiteLayer:createItem(moduleId, originalData)
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

    
    if data.IsHire then
        -- 已被招募
        local hadHire = ui.createSpriteAndLabel({
                imgName = "c_156.png",
                labelStr = TR("已被招募"),
            })
        hadHire:setPosition(cc.p(536, 47))
        layout:addChild(hadHire)
    else
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
    end

    return layout
end

-- 招募弹窗
function GuildPvpRecruiteLayer:createRecruitLayer(moduleId, data)
    self.mRecruitLayer = MsgBoxLayer.addDIYLayer({
        btnInfos = {
           {
                text = TR("招募"),
                clickAction = function()
                     self:requestHire(data)
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
            RecruitLabel:setPosition(286, 215)
            mBgSprite:addChild(RecruitLabel)
            local RecruitLabel2 = ui.newLabel({
                text = TR("（同时只能存在一个招募对象，并且招募之后不能更换）"),
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
end

-- 创建信息显示容器（包括标题，时间，内容）
function GuildPvpRecruiteLayer:createTextLayout(moduleId, data)
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
function GuildPvpRecruiteLayer:extractData(moduleId, originalData)
    local data = {}
	-- 分类处理

	data.heroModelId = originalData.ModelId
	data.ownerName = originalData.PlayerName
	data.hireUse = XrxsConfig.items[1].hireUse

	data.playerId = originalData.PlayerId
    data.IllusionModelId = originalData.IllusionModelId

	-- 统一处理
	data.fap = originalData.FAP
	data.name = ConfigFunc:getHeroName(data.heroModelId, {IllusionModelId = data.IllusionModelId, heroFashionId = data.CombatFashionOrder})
    data.Lv = originalData.Lv
    data.IsHire = originalData.IsHire
	return data
end

function GuildPvpRecruiteLayer:refreshListView()
    self.mListView:removeAllChildren()
	-- 添加Item
	for i, data in ipairs(self.mDataTable) do
	    local item = self:createItem(tag, data)
	    self.mListView:pushBackCustomItem(item)
	end

	self.mListView:jumpToTop()

	-- 暂时没有此类佣兵
	if #self.mDataTable == 0 then
	    if not self.mEmptyHint then
	        self.mEmptyHint = ui.createEmptyHint(TR("暂时没有帮派佣兵"))
	        self.mEmptyHint:setPosition(320, 600)
	        self.mParentLayer:addChild(self.mEmptyHint)
	    end
	    self.mEmptyHint:setVisible(true)
	elseif self.mEmptyHint then
	   self.mEmptyHint:setVisible(false)
	end
end

function GuildPvpRecruiteLayer:refreshUI()
	self:refreshListView()
	self.mTokenNumLabel.setNumber(Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, TokenModelId))
end

--=========================服务器相关==================
-- 请求初始信息
function GuildPvpRecruiteLayer:requestInfo()
	-- 获取共享英雄数据
	HttpClient:request({
		moduleName = "Guild",
		methodName = "GetGuildShare",
		callback = function(response)
		    if not response or response.Status ~= 0 then
                return
            end
	        -- 过滤自身共享英雄
	        local infos = response.Value.GuildShareInfo
	        for i=#infos, 1, -1 do
	        	if infos[i].PlayerId == self.mTargetId then
	        		table.remove(infos, i)
                    break
	        	end
	        end
	        self.mDataTable = infos
            table.sort(infos, function (a, b)
                if a.IsHire ~= b.IsHire then
                    return not a.IsHire
                end

                if a.FAP ~= b.FAP then
                    return a.FAP > b.FAP
                end
                return a.ModelId > b.ModelId
            end)

            self:refreshUI()
		end
	})
end

-- 招募请求
function GuildPvpRecruiteLayer:requestHire(data)
    HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "Hire",
        svrMethodData = {self.mTargetId, data.playerId},
        callbackNode = self,
        callback = function(response)
            if response.Status == 0 then
                ui.showFlashView(TR("雇佣成功"))
                LayerManager.removeLayer(self)
            else
                -- 刷新招募界面
                if response.Value then
                    -- 过滤自身共享英雄
                    local infos = response.Value.GuildShareInfo
                    for i=#infos, 1, -1 do
                        if infos[i].PlayerId == self.mTargetId then
                            table.remove(infos, i)
                        end
                    end
                    self.mDataTable = infos
                    table.sort(infos, function (a, b)
                        if a.IsHire ~= b.IsHire then
                            return not a.IsHire
                        end
                        
                        if a.FAP ~= b.FAP then
                            return a.FAP > b.FAP
                        end
                        return a.ModelId > b.ModelId
                    end)

                    self:refreshUI()
                end
            end

            if self.mRecruitLayer ~= nil then
                LayerManager.removeLayer(self.mRecruitLayer)
                self.mRecruitLayer = nil
            end
        end
    })
end

-- 获取道具的购买信息
function GuildPvpRecruiteLayer:requestGetShopGoodsInfo(goodsModelId)
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
function GuildPvpRecruiteLayer:requestBuyGoods(goodsModelId, selCount, priceType, selPrice)
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

            -- 刷新当前佣兵令数量
            self.mTokenNumLabel.setNumber(Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, goodsModelId))
        end
    })
end

return GuildPvpRecruiteLayer