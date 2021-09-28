--[[
	文件名：TeambattleManorLayer.lua
	描述：西漠添加镇守人物界面
	创建人：yanxingrui
	创建时间： 2016.7.22
--]]

local TeambattleManorLayer = class("TeambattleManorLayer", function (params)
	return display.newLayer()
end)

function TeambattleManorLayer:ctor(params)

	ui.registerSwallowTouch({node = self})
	-- 镇守英雄模型ID
	self.mHeroModelId = params.heroModelId or nil
	-- 镇守奖励
    self.mHoldDrop = {}
    -- 节点信息配置
    self.mConfig = params.config or {}
    -- 回调函数
    self.mCallback = params.callBack
    self.mBanList = params.banList

	-- 该页面的Parent
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond},
        currentLayerType = Enums.MainNav.ePractice,
    })
    self:addChild(topResource)

	-- 概率获得道具
	for k, v in ipairs(TeambattleHoldDropoddsRelation.items) do
        if tonumber(v.nodeModelID) == self.mConfig.ID and v.dropResource ~= "" then
            table.insert(self.mHoldDrop, v.dropResource)
        end
    end

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function TeambattleManorLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jsxy_02.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	if self.mHeroModelId == nil then
		-- 黑色剪影
		local blackSprite = ui.newButton({
			normalImage = "c_36.png",
			clickAction = function()
				LayerManager.addLayer({
					cleanUp = false,
					name = "teambattle.TeambattleChoseHeroLayer",
					data = {
						banList = self.mBanList,
						config = self.mConfig,
					}
				})
			end
		})
		blackSprite:setPosition(320, 700)
		self.mParentLayer:addChild(blackSprite)

		local zsLable = ui.newLabel({
			text = TR("点击添加镇守侠客"),
			size = 30,
			color = Enums.Color.eGreen,
			outlineColor = Enums.Color.eBlack
		})
		zsLable:setPosition(320, 720)
		self.mParentLayer:addChild(zsLable)

		-- 每次镇守结束可获得对应镇守人物碎片
		local labelSprite = ui.newScale9Sprite("c_25.png", cc.size(500, 50))
		labelSprite:setPosition(320, 380)
		self.mParentLayer:addChild(labelSprite)

		local textLabel = ui.newLabel({text = TR("%s每次镇守结束可获得对应%s镇守侠客碎片",
			Enums.Color.eWhiteH, Enums.Color.eYellowH)})
		textLabel:setPosition(250, 25)
		labelSprite:addChild(textLabel)
	else
		-- 人物模型
		local hero = Figure.newHero({
			heroModelID = self.mHeroModelId,
			scale = 0.3,
		})
		hero:setPosition(320, 480)
		self.mParentLayer:addChild(hero)

		-- 镇守者名字
		local nameSprite = ui.newScale9Sprite("c_25.png", cc.size(300, 50))
		nameSprite:setPosition(320, 1020)
		self.mParentLayer:addChild(nameSprite)

		local heroColor = Utility.getQualityColor(HeroModel.items[self.mHeroModelId].quality, 2)
		local nameLabel = ui.newLabel({
			text = TR("%s镇守者:  %s%s", Enums.Color.eLightYellowH,
				heroColor, HeroModel.items[self.mHeroModelId].name),
			size = 24,
			outlineColor = Enums.Color.eBlack,
			outlineSize = 1,
		})
		nameLabel:setAnchorPoint(0.5,0.5)
		nameLabel:setPosition(nameSprite:getContentSize().width / 2, nameSprite:getContentSize().height / 2)
		nameSprite:addChild(nameLabel)

		-- 开始镇守
		local startBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("开始镇守"),
			clickAction = function()
				if Utility.isResourceEnough(ResourcetypeSub.eVIT, TeambattleConfig.items[1].needVIT, true) then
					self:zhenShou()
				end
			end
		})
		startBtn:setPosition(320, 165)
		self.mParentLayer:addChild(startBtn)

		-- 镇守至24点 体力消耗：20
		local VITLabel = ui.newLabel({text = TR("%s镇守至%s24点 %s镇守消耗：{%s}%s20",
			Enums.Color.eWhiteH, Enums.Color.eNormalGreenH, Enums.Color.eWhiteH, Utility.getDaibiImage(ResourcetypeSub.eVIT), Enums.Color.eNormalGreenH)})
		VITLabel:setPosition(320, 230)
		self.mParentLayer:addChild(VITLabel)

		-- 判断当前时间是否过了中午12点
		if tonumber(string.split(os.date("%X", Player:getCurrentTime()), ":")[1]) >= 12 then
			VITLabel:setString(TR("%s镇守至%s24点   %s镇守消耗：{%s}%s%d",
				Enums.Color.eWhiteH, Enums.Color.eNormalGreenH, Enums.Color.eWhiteH, Utility.getDaibiImage(ResourcetypeSub.eVIT), Enums.Color.eNormalGreenH,
				TeambattleConfig.items[1].needVIT))
		else
			VITLabel:setString(TR("%s镇守%s12小时   %s镇守消耗：{%s}%s%d",
				Enums.Color.eWhiteH, Enums.Color.eNormalGreenH, Enums.Color.eWhiteH, Utility.getDaibiImage(ResourcetypeSub.eVIT), Enums.Color.eNormalGreenH,
				TeambattleConfig.items[1].needVIT))
		end
	end

	-- 产出道具
	local goodsSprite = ui.newScale9Sprite("c_65.png", cc.size(580, 150))
	goodsSprite:setPosition(320, 270)
	self.mParentLayer:addChild(goodsSprite)

	-- 镇守该节点，有概率产出下列道具：
	local goodsLabel = ui.newLabel({
        text = TR("镇守该节点，有概率产出下列道具"),
        color = Enums.Color.eBrown,
        size = 20,
    })
	goodsLabel:setPosition(290, 130)
	goodsSprite:addChild(goodsLabel)

	-- 奖励栏
	local cardlist = {}
	for i = 1,#self.mHoldDrop do
		local headerInfo = Utility.analysisStrResList(self.mHoldDrop[i])[1]
        local card = {
            resourceTypeSub = headerInfo.resourceTypeSub,
            modelId = headerInfo.modelId,
            num = headerInfo.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        }
        table.insert(cardlist, card)
	end

	local rewardList = ui.createCardList({
		maxViewWidth = 520,
		cardShape = Enums.CardShape.eCircle,
		cardDataList = cardlist,
	})
	rewardList:setAnchorPoint(cc.p(0.5, 0.5))
	rewardList:setPosition(315, 50)
	goodsSprite:addChild(rewardList)

	-- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

----------------------------------网络请求---------------------
function TeambattleManorLayer:zhenShou()
	HttpClient:request({
        moduleName = "TeambattleHoldinfo",
        methodName = "HeroHold",
        svrMethodData = {self.mConfig.ID, self.mHeroModelId},
        callbackNode = self,
        callback = function (response)
            if response.Status == 0 then
                if self.mCallback then
                    self.mCallback()
                end

                LayerManager.removeLayer(self)
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            end
        end
    })
end

return TeambattleManorLayer
