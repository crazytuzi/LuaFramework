--[[
	文件名：TeambattleChoseHeroLayer.lua
	描述：西漠选择镇守人物界面
	创建人：yanxingrui
	创建时间： 2016.7.25
--]]

local TeambattleChoseHeroLayer = class("TeambattleChoseHeroLayer", function (params)
	return display.newLayer()
end)

function TeambattleChoseHeroLayer:ctor(params)
	-- 满足条件的镇守英雄列表
	self.mHeroList = {}
	-- 已镇守英雄
	self.mBanList = params.banList or {}
	self.mConfig = params.config or {}

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

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function TeambattleChoseHeroLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 显示面板的背景
    self.mInfoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 880))
    self.mInfoBgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.mInfoBgSprite:setPosition(cc.p(320, 110))
    self.mParentLayer:addChild(self.mInfoBgSprite)

	-- 选择镇守人物背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(630,830))
    listBg:setAnchorPoint(0.5, 0)
    listBg:setPosition(320, 120)
    self.mParentLayer:addChild(listBg)

    self.mChooseSprite = ui.newScale9Sprite("c_25.png", cc.size(300, 50))
    self.mChooseSprite:setPosition(300, 1030)
    self.mParentLayer:addChild(self.mChooseSprite)
	local chooseLabel = ui.newLabel({
		text = TR("选择镇守侠客"),
		size = 24
	})
	chooseLabel:setPosition(150, 25)
	self.mChooseSprite:addChild(chooseLabel)

	-- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 得到满足镇守条件的英雄列表
    self:getHeroList()
    -- 创建镇守人物列表
    self:createList()
end

-- 得到满足镇守条件的英雄列表
function TeambattleChoseHeroLayer:getHeroList()
	-- 得到去掉主角以外的橙将
    self.mHeroList = clone(HeroObj:getHeroList({
    	excludeModelIds = {HeroObj:getMainHero().HeroModelId},
    	minColorLv = 5,
    	maxColorLv = 5,
    }))
    --dump(self.mHeroList,"self.mHeroListxxx")

    -- 已上阵优先排序
    table.sort(self.mHeroList, function(a, b)
    	local isIna = FormationObj:heroInFormation(a.Id)
    	local isInb = FormationObj:heroInFormation(b.Id)
    	if isIna and not isInb then
    		return true
    	else
    		return false
    	end
	end)

	local finalList = {}
    -- 删掉重复英雄
    for k, v in pairs(self.mHeroList) do
        local isHave = false
        for key, value in ipairs(finalList) do
            if value.ModelId == v.ModelId then
                isHave = true
            end
        end

        if not isHave then
            table.insert(finalList, v)
        end
    end
    self.mHeroList = finalList
    --删除自己
    for k, v in ipairs(self.mHeroList) do
    	if PlayerAttrObj:isPlayerSelf(v.Id) then
    		table.remove(self.mHeroList, k)
    		break
    	end
    end
end

-- 创建镇守人物列表
function TeambattleChoseHeroLayer:createList()
	if #self.mHeroList == 0 then

		self.mChooseSprite:setVisible(false)

		local emptySprite = ui.createEmptyHint(TR("%s橙色侠客才可参与镇守，当前无可镇守侠客",
			Enums.Color.eNormalWhiteH))
        emptySprite:setPosition(320, 568)
        self.mParentLayer:addChild(emptySprite)

        local zhaoBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("去招募"),
            clickAction = function()
                LayerManager.addLayer({
                    name = "shop.ShopLayer",
                })
            end,
        })
        zhaoBtn:setPosition(320, 300)
        self.mParentLayer:addChild(zhaoBtn)
	else
		-- 创建列表控件
		self.mListView = ccui.ListView:create()
	    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
	    self.mListView:setBounceEnabled(true)
	    self.mListView:setContentSize(cc.size(620, 810))
	    self.mListView:setAnchorPoint(cc.p(0.5, 0))
	    self.mListView:setItemsMargin(8)
	    self.mListView:setPosition(cc.p(320, 130))
	    self.mParentLayer:addChild(self.mListView)

	    for i = 1, #self.mHeroList do
	    	local item = ccui.Layout:create()
		    item:setContentSize(cc.size(620, 120))

		    -- 单行条目的背景
		    local bgSp = ui.newScale9Sprite("c_18.png", cc.size(620, 120))
		    bgSp:setPosition(310, 60)
		    item:addChild(bgSp)

		    -- 头像
		    local attr = {CardShowAttr.eBorder}--, CardShowAttr.eBattle}
		    -- end
		    local card = CardNode.createCardNode({
		    	resourceTypeSub = ResourcetypeSub.eHero,
		    	modelId = self.mHeroList[i].ModelId,
		    	cardShowAttrs = attr,
		    })
		    card:setPosition(80, 60)
		    bgSp:addChild(card)

		    -- 上阵添加已上阵标签
		    if FormationObj:heroInFormation(self.mHeroList[i].Id) then
			    local battle = ui.newSprite("c_32.png")
			    battle:setPosition(35, 90)
			    bgSp:addChild(battle)
			end

		    -- 名字
		    local nameColor = Utility.getQualityColor(HeroModel.items[self.mHeroList[i].ModelId].quality, 2)
		    local name = ui.newLabel({
		    	text = string.format("%s%s", nameColor, HeroModel.items[self.mHeroList[i].ModelId].name)
		    })
		    name:setAnchorPoint(cc.p(0, 0.5))
		    name:setPosition(140, 80)
		    bgSp:addChild(name)

		    -- 资质
		    local quality = ui.newLabel({text = TR("%s资质：%s%s", Enums.Color.eBrownH,
		    	Enums.Color.eNormalGreenH, HeroModel.items[self.mHeroList[i].ModelId].quality)})
		    quality:setAnchorPoint(cc.p(0, 0.5))
		    quality:setPosition(140, 50)
		    bgSp:addChild(quality)

		    -- 镇守按钮
		    local zhenShouBtn = ui.newButton({
		        normalImage = "c_28.png",
		        text = TR("开始镇守"),
		        clickAction = function()
		            local params = {}
		            params.heroModelId = self.mHeroList[i].ModelId
		            params.config = self.mConfig
		            LayerManager.addLayer({
		                name = "teambattle.TeambattleManorLayer",
		                data = params,
		            })
		            LayerManager.deleteStackItem("teambattle.TeambattleChoseHeroLayer")
		        end
		    })
		    zhenShouBtn:setPosition(500, 60)
		    bgSp:addChild(zhenShouBtn)


		    for k, v in ipairs(self.mBanList) do
		        if v == self.mHeroList[i].ModelId then
		            zhenShouBtn:setEnabled(false)
		            zhenShouBtn:setTitleText(TR("已镇守"))
		        end
		    end

		    self.mListView:pushBackCustomItem(item)
	    end
	end

end


return TeambattleChoseHeroLayer
