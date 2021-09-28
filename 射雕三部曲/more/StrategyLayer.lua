--[[
	文件名：StrategyLayer.lua
	描述：更多－－攻略
	创建人：yanxingrui
	创建时间： 2016.5.31
--]]

local StrategyLayer = class("StrategyLayer", function(params)
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 192))
end)

-- 四个标签页的定义
local pageType = {
	eUpPower = 1,		-- 提升战力
	eGetEquip = 2,		-- 装备获取
	eCommonGoods = 3,  	-- 常用物品
	eStrongTeam = 4,  	-- 最强阵容
}

function StrategyLayer:ctor()
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 初始化页面
	self:initUI()
end

-- 初始化页面
function StrategyLayer:initUI()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mSubLayer = ui.newStdLayer()
	self:addChild(self.mSubLayer)

	-- 背景
	self.bg = ui.newScale9Sprite("c_13.png", cc.size(614, 588))
	self.bg:setPosition(320, 568)
	self.mParentLayer:addChild(self.bg)

	-- self.bgSprite = ui.newScale9Sprite("c_51.png", cc.size(581, 434))
	-- self.bgSprite:setPosition(320, 520)
	-- self.mParentLayer:addChild(self.bgSprite)

	-- 标题文字
	local titleLabel = ui.newLabel({
		text = TR("%s游戏攻略", Enums.Color.eNormalBlueH),
	})
	titleLabel:setPosition(320, 830)
	self.mParentLayer:addChild(titleLabel)

	-- 退出按钮
	self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 830),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 创建分页
    self:showTabLayer()
end

-- 创建分页
function StrategyLayer:showTabLayer()
	self.tabItems = {
        {
            text = TR("提升战力"),
        },
        {
            text = TR("装备获取"),
        },
        {
            text = TR("常用物品"),
        },
        {
            text = TR("最强阵容"),
        }
    }

    -- 创建tablayer
    self.tableLayer = ui.newTabLayer({
    	viewSize = cc.size(600, 80),
    	space = 8,
        btnInfos = self.tabItems,
        onSelectChange = function (selectBtnTag)
            self:addElements(selectBtnTag)
        end,
    })
    self.tableLayer:setPosition(305, 490)
    self.bg:addChild(self.tableLayer)
end

-- 添加分页元素
function StrategyLayer:addElements(selectBtnTag)

	self.mSubLayer:removeAllChildren()

	if selectBtnTag == pageType.eUpPower then
		self:upPowerLayer()
	elseif selectBtnTag == pageType.eGetEquip then
		self:getEquipLayer()
	elseif selectBtnTag == pageType.eCommonGoods then
		self:commonGoodsLayer()
	elseif selectBtnTag == pageType.eStrongTeam then
		self:strongTeamLayer()
	end
end

-- 提升战力页面
function StrategyLayer:upPowerLayer()
	local btnList = {
        {
        	image = "tb_114.png",
        	text = TR("装备强化进阶，提升大量属性"),
            btnPos = cc.p(200, 610),
            action = function()
                -- 装备升级突破
                LayerManager.addLayer({
                	name = "team.TeamEquipLayer",
                    data = {},
                	data = {showIndex = 1},
                	cleanUp = true,
                })
        	end
        },
        {
        	image = "tb_132.png",
        	text = TR("侠客升级和突破，提升大量属性"),
            btnPos = cc.p(440, 610),
            action = function()
                LayerManager.showSubModule(ModuleSub.eHeroStepUp, nil, true, 0)
        	end
        },
        {
        	image = "tb_88.png",
        	text = TR("提升主角属性属性，开启江湖后援团"),
            btnPos = cc.p(440, 410),
            action = function()
                -- 仙脉
                local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePracticeLightenStar, true)
                if not isOpen then
                    return
                end
                LayerManager.showSubModule(ModuleSub.ePracticeLightenStar, nil, true, 0)
        	end
        },
    }
    for i, v in ipairs(btnList) do
        local button = ui.newButton({
            normalImage = v.image,
            anchorPoint = cc.p(0.5, 0),
            clickAction = v.action,
        })
        button:setPosition(v.btnPos)
        self.mSubLayer:addChild(button)

        local textLabel = ui.newLabel({
            text = v.text,
            size = 22,
            color = Enums.Color.eNormalWhite,
            dimensions = cc.size(220, 0),
            -- align = cc.TEXT_ALIGNMENT_CENTER,        -- 水平对齐方式, 默认为 cc.TEXT_ALIGNMENT_LEFT
        })
        textLabel:setPosition(cc.p(button:getPositionX() + 10, button:getPositionY() - 30))
        self.mSubLayer:addChild(textLabel)
    end
end

-- 装备获取页面
function StrategyLayer:getEquipLayer()
	local btnList = {
        {
        	image = "tb_89.png",
        	text = TR("获得蓝色装备，助您前期推图轻松"),
        	btnPos = cc.p(200, 610),
            action = function()
                -- 夺宝
                local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChallengeGrab, true)
                if not isOpen then
                    return
                end
                LayerManager.showSubModule(ModuleSub.eChallengeGrab, nil, true, 0)
        	end
        },
        {
            image = "tb_81.png",
            text = TR("九山兵阁可获得各品质装备"),
            btnPos = cc.p(440, 610),
            action = function()
                -- 装备召唤
                local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePracticeBloodyDemonDomain, true)
                if not isOpen then
                    return
                end
                LayerManager.showSubModule(ModuleSub.ePracticeBloodyDemonDomain, nil, true, 0)
        	end
        },
        {
        	image = "tb_84.png",
        	text = TR("可获得和主角搭配的紫色套装"),
            btnPos = cc.p(200, 410),
            action = function()
                -- 秘藏妖王
                local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eChallengeWrestle, true)
                if not isOpen then
                    return
                end
                LayerManager.showSubModule(ModuleSub.eChallengeWrestle, nil, true, 0)
        	end
        },
        {
        	image = "tb_36.png",
        	text = TR("获得大量神兵和神兵碎片,运气好的还有橙色神兵碎片哦"),
            btnPos = cc.p(440, 410),
            action = function()
                -- 挑战妖王
                local isOpen = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleBoss, true)
                if not isOpen then
                    return
                end
                LayerManager.showSubModule(ModuleSub.eBattleBoss, nil, true, 0)
        	end
        }
    }

    for index, value in ipairs(btnList) do
        local button = ui.newButton({
            normalImage = value.image,
            anchorPoint = cc.p(0.5, 0),
            clickAction = value.action,
        })
        button:setPosition(value.btnPos)
        self.mSubLayer:addChild(button)

        local textLabel = ui.newLabel({
            text = value.text,
            size = 22,
            color = Enums.Color.eNormalWhite,
            dimensions = cc.size(220, 0)
        })
        textLabel:setPosition(cc.p(button:getPositionX() + 10, button:getPositionY() - 40))
        self.mSubLayer:addChild(textLabel)
    end
end

-- 常用物品页面
function StrategyLayer:commonGoodsLayer()

    -- 至尊丹卡片
    local zzd = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eFunctionProps,
        modelId = 16050001,
        cardShowAttrs = {CardShowAttr.eBorder},
    })
    zzd:setPosition(130, 630)
    self.mSubLayer:addChild(zzd)

    -- 突破丹名字
    local zzdName = ui.newLabel({
        text = TR("突破丹:[用于侠客突破]"),
        size = 29,
        color = Enums.Color.eNormalGreen,
        anchorPoint = cc.p(0, 0),
    })

    -- 突破丹获得途径
    local zzdGet = ui.newLabel({
        text = TR("获得途径:普通副本，战役通关宝箱，聚宝阁，活动"),
        size = 22,
        color = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(400, 0),
    })

    zzdName:setPosition(180, 640)
    zzdGet:setPosition(180, 630)
    self.mSubLayer:addChild(zzdName)
    self.mSubLayer:addChild(zzdGet)


    -- 阅历卡片
    local lj = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHeroExp,
        cardShowAttrs = {CardShowAttr.eBorder},
    })
    lj:setPosition(130, 430)
    self.mSubLayer:addChild(lj)

    -- 阅历名字
    local ljName = ui.newLabel({
        text = TR("阅历:[用于侠客升级]"),
        size = 29,
        color = Enums.Color.eNormalGreen,
        anchorPoint = cc.p(0, 0),
    })

    -- 阅历获得途径
    local ljGet = ui.newLabel({
        text = TR("获得途径:普通副本，侠客分解，商城购买"),
        size = 22,
        color = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0, 1),
        dimensions = cc.size(400, 0),
    })

    ljName:setPosition(180, 440)
    ljGet:setPosition(180, 430)
    self.mSubLayer:addChild(ljName)
    self.mSubLayer:addChild(ljGet)

end

-- 最强阵容页面
function StrategyLayer:strongTeamLayer()
    local list1, list2 = {}, {}
    local str = string.split(StrongFormModel.items[1].heroModelIDList, ",")
    for index, value in ipairs(str) do
        table.insert(list1, tonumber(value))
    end
    str = string.split(StrongFormModel.items[2].heroModelIDList, ",")
    for index, value in ipairs(str) do
        table.insert(list2, tonumber(value))
    end

	local teamList = {list1, list2}
    local heroTeamName = {TR("%s%s",Enums.Color.eOrangeH, StrongFormModel.items[1].name),
        TR("%s%s",Enums.Color.eOrangeH, StrongFormModel.items[2].name)}

    -- 创建详情
    local function createListView(index)
        -- 取出每一个组合
        local info = teamList[index]
        -- 创建layout
        local layOut = ccui.Layout:create()
        -- -- 组合名字背景
        -- local nameBg = ui.newScale9Sprite("c_40.png",cc.size(581, 34))
        -- -- 显示组合名字
        -- local name = ui.newLabel({
        --     text = heroTeamName[index],
        -- })
        local name = ui.createAttrTitle({
            leftImg = "c_39.png",
            titleStr = heroTeamName[index],
        })

        -- layOut:addChild(nameBg)
        layOut:addChild(name)

        -- 对组合名字，名字背景和卡片设置位置
        for i, v in ipairs(info) do
            local card = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = v,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
            })
            if #info < 6 then
                layOut:setContentSize(cc.size(580, 180))
                -- nameBg:setPosition(280, 140)
                name:setPosition(280, 140)
                card:setPosition(60 + (i - 1) % 5 * 120, 70)
            else
                layOut:setContentSize(cc.size(580, 280))
                -- nameBg:setPosition(280, 245)
                name:setPosition(280, 245)
                card:setPosition(60 + (i - 1) % 5 * 120, 170 - math.floor((i - 1) / 5) * 120)
            end
            layOut:addChild(card)
        end

        return layOut
    end

    -- 创建ListView列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setContentSize(cc.size(600, 410))
    listView:setItemsMargin(8)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(320, 525)
    self.mSubLayer:addChild(listView)

    -- 添加数据
    for i = 1, #heroTeamName do
        listView:pushBackCustomItem(createListView(i))
    end
end

return StrategyLayer
