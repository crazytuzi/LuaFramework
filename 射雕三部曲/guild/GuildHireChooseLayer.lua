--[[
    GuildHireChooseLayer.lua
	描述：帮派佣兵选择页面
	创建人：chenzhong
	创建时间：2016.6.13
-- ]]

local GuildHireChooseLayer = class("GuildHireChooseLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 150))
end)

function GuildHireChooseLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()
end

function GuildHireChooseLayer:initUI()
	--背景
    self.backImageSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    self.backImageSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.backImageSprite)

    local backSize = self.backImageSprite:getContentSize()

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eSTA, 
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 900))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(320, 1005)
    self.mParentLayer:addChild(listBg)
	-- 创建ListView列表
    self.listView = ccui.ListView:create()
    self.listView:setItemsMargin(10)
    self.listView:setDirection(ccui.ListViewDirection.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(600, 1000))
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.listView:setPosition(320, 1020)
    self.mParentLayer:addChild(self.listView)

    local cacheSlotInfo = FormationObj:getSlotInfos()

    self.useSlotInfo = {}
    for i = 2, #cacheSlotInfo do
    	if cacheSlotInfo[i].HeroId == EMPTY_ENTITY_ID then
    	else
    		table.insert(self.useSlotInfo, cacheSlotInfo[i])
    	end
    end

    for i = 1, #self.useSlotInfo do
        self.listView:pushBackCustomItem(self:createCellView(i))
    end

end

function GuildHireChooseLayer:createCellView(index)
    print(index)
	local heroinfo = {}
	for k, v in ipairs(HeroObj:getHeroList()) do
		if v.Id == self.useSlotInfo[index].HeroId then
			heroinfo = v
            break
		end
	end

    local cellSize = cc.size(600, 130)

	local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cellSize)

    local backImageSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width, cellSize.height - 10))
    backImageSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - 20)
    custom_item:addChild(backImageSprite)

    -- 头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = tonumber(heroinfo.ModelId),
        IllusionModelId = heroinfo.IllusionModelId,
        --instanceData = {Lv = heroinfo.Lv, HeroModelId = heroinfo.ModelId},
        cardShowAttrs = {CardShowAttr.eBorder},
        needGray = false,
        onClickCallback = function ()end
        })
    header:setPosition(35 ,50)
    header:setAnchorPoint(cc.p(0,0.5))
    custom_item:addChild(header)
    local offsetY = 20
    local offsetX = 15
    -- 名字
    local name, tmpStep = ConfigFunc:getHeroName(heroinfo.ModelId, {heroStep = heroinfo.Step, IllusionModelId = heroinfo.IllusionModelId, heroFashionId = heroinfo.CombatFashionOrder})
    if tmpStep > 0 then
        name = name .. string.format(" %s+%d", Enums.Color.eOrangeH, tmpStep)
    end
    local nameLabel = ui.newLabel({
    	text = name,
    	color = Enums.Color.eBrown,
    	anchorPoint = cc.p(0, 0.5),
    	x = 160 - offsetX,
    	y = 100 - offsetY - 5
    	})
    custom_item:addChild(nameLabel)

    -- 战力
    local FAPLabel = ui.newLabel({
        text = TR("战力： %s%s", Enums.Color.eOrangeH, Utility.numberFapWithUnit(self.useSlotInfo[index].FAP)),
        size = 28,
        color = Enums.Color.eBrown,
        font = _FONT_PANGWA,
        --outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        anchorPoint = cc.p(0, 0.5),
        x = 160 - offsetX,
        y = 30 - offsetY + 7,
        size = 19
        })
    custom_item:addChild(FAPLabel)

    -- 资质
    local qualityLabel = ui.newLabel({
    	text = TR("资质： %s%d", Enums.Color.eOrangeH, HeroModel.items[heroinfo.ModelId].quality),
    	size = 28,
    	anchorPoint = cc.p(0, 0.5),
    	x = 160 - offsetX,
    	y = 65 - offsetY,
        size = 19,
        color = Enums.Color.eBrown
    	})
    custom_item:addChild(qualityLabel)

    -- 派遣按钮
    local paiBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("派遣"),
    	position = cc.p(520, 45),
    	clickAction = function ()
    		self:requestGuildShare(self.useSlotInfo[index].SlotId)
    	end
    	})
    custom_item:addChild(paiBtn)

    return custom_item
end

-- =============================== 请求服务器数据相关函数 ===================

function GuildHireChooseLayer:requestGuildShare(id)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildShare",
        svrMethodData = {id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 修改帮派信息
            GuildObj:updatePlayerGuildInfo({IfCanShare = false})
            ui.showFlashView({text = TR("分享成功")})
            
            -- 关闭佣兵选择页面
            LayerManager.removeLayer(self)
        end,
    })
end

return GuildHireChooseLayer