--[[
    文件名：PetCampLayer.lua
    描述：上阵宠物技能顺序界面
    创建人：peiyaoqiang
    创建时间：2017.03.27
-- ]]

local PetCampLayer = class("PetCampLayer", function()
    return display.newLayer()
end)

-- 配置
local SlotCount = 6

-- UI配置
local CloseButtonY = 1039
local ListTopY = 982
local Width = 640
local Height = 144
local cellHalfW = 305
local cellHalfH = 66

--[[
--]]
function PetCampLayer:ctor(params)
    -- 变量
    self.mItemData = {}

    -- 获取数据
    self.mPosConfig = self:calcFormationConfig()
    self:initData()
    
    -- 创建页面
    self:createLayer()

    -- 显示列表
    self:showItems()
end

-- 初始化界面
function PetCampLayer:createLayer()
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建背景
    local sprite = ui.newSprite("c_34.jpg")
    sprite:setPosition(320, 568)
    self.mParentLayer:addChild(sprite, -5)

    -- 规则提示
    local sprite = ui.createSpriteAndLabel({
    	imgName = "c_25.png",
        scale9Size = cc.size(490, 48),
        labelStr = TR("佩戴秘籍的侠客阵亡后则不能再发动外功"),
        fontSize = 22,
        fontColor = Enums.Color.eWhite,
    })
    sprite:setPosition(320, CloseButtonY + 10)
    self.mParentLayer:addChild(sprite)

    local label = ui.newLabel({
        text = TR("拖动技能栏可调整技能释放顺序"),
        color = Enums.Color.eRed,
        size = 22,
    })
    label:setPosition(320, CloseButtonY - 30)
    self.mParentLayer:addChild(label)
    
    -- 创建UI
    self:initUI()

    -- 添加自删除事件
    self.mParentLayer:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            self:requestPetFormationChange()
        end
    end)
end

-- 创建UI
function PetCampLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.ePetEXP,
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    -- 创建退出按钮
    local button = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(588, CloseButtonY),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(button, Enums.ZOrderType.eDefault + 5)
end

-- 显示Items
function PetCampLayer:showItems()
    -- 这里应该按照释放顺序显示
    for i,v in ipairs(self.mItemData) do
        if (v.nodeSprite == nil) then
            local itemPos = self.mPosConfig[i]
            local node = self:createItem(self.mSlotData[v.slotId], i)
            node:setPosition(itemPos)
            self.mParentLayer:addChild(node, 2)

            -- 补充内容
            v.pos = itemPos
            v.nodeSprite = node
            v.zorder = 2
        end
    end
    
    -- 注册拖动事件
    require("common.CommonDrag"):registerDragTouch({
        parent = self.mParentLayer,
        nodeHalfW = cellHalfW,
        nodeHalfH = cellHalfH,
        itemList = self.mItemData,
        callback = function (newList)
            -- 刷新界面显示
            self.mItemData = clone(newList)
            for _,v in ipairs(self.mItemData) do
                v.nodeSprite.refresh(v.showIndex)
            end
        end
    })
end

-- 创建一行Item
function PetCampLayer:createItem(data, formationIndex)
    -- 创建Item容器
    local item = ccui.Layout:create()
    item:setAnchorPoint(cc.p(0.5, 0.5))
    item:setContentSize(Width, Height)

    -- 背景
    local sprite = ui.newScale9Sprite("c_65.png", cc.size(Width - 30, Height - 12))
    sprite:setPosition(Width/2, Height/2)
    item:addChild(sprite)

    -- 读取装备的人物
    local strHeroName, heroNameColorH = "", Enums.Color.eDarkGreenH
    if (data ~= nil) and (data.Id ~= nil) then
        local isIn, slotId = FormationObj:petInFormation(data.Id)
        local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
        local heroInfo = FormationObj:getSlotHeroInfo(slotInfo.HeroId)
        local heroBase = HeroModel.items[heroInfo.ModelId]
        strHeroName = ConfigFunc:getHeroName(heroInfo.ModelId, {IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
        heroNameColorH = Utility.getQualityColor(heroBase.quality, 2)
    end

    -- 创建释放时机的label
    local function showSkillIndex(posY, formationIdx)
        local tmpLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eDarkGreen,
            size = 22,
            anchorPoint = cc.p(0.5, 0),
            x = 320,
            y = posY,
        })
        item:addChild(tmpLabel)

        -- 刷新释放回合显示
        item.refresh = function (formationIndex)
            tmpLabel:setString(TR("%s%s%s[第%d回合后释放]", heroNameColorH, strHeroName, Enums.Color.eDarkGreenH, formationIndex or item.formationIndex))
        end
        item.refresh(formationIdx)
    end

    -- 没有上阵宠物
    if not data then
        -- 灰色背景
        local graySprite = ui.newScale9Sprite("wgmj_15.png", cc.size(Width - 40, Height - 22))
        graySprite:setPosition(Width/2, Height/2)
        item:addChild(graySprite)

        -- 技能描述
        local infoLabel = ui.newLabel({
            text = TR("该回合结束无技能"),
            size = 32,
            color = Enums.Color.eWhite,
            outlineColor = Enums.Color.eShadowColor,
            outlineSize = 2,
        })
        infoLabel:setPosition(Width/2, Height/2 - 25)
        item:addChild(infoLabel)
        
        -- 释放时机
        showSkillIndex(90, formationIndex)
    else
        -- 技能头像
        local x = 85
        local y = Height / 2
        local card = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.ePet,
            instanceData = data,
            modelId = data.ModelId,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep},
        })
        card:setPosition(x, y)
        item:addChild(card)
        x = x + 70

        -- 技能描述
        local label = ui.newLabel({
            text = Utility.getPetSkillDes(data, true, {Enums.Color.eRedH, Enums.Color.eBrownH}),
            color = Enums.Color.eBrown,
            size = 20,
            anchorPoint = cc.p(0, 1),
            dimensions = cc.size(440, 0),
        })
        local labelSize = label:getContentSize()
        y = (Height - labelSize.height - 29) / 2 + labelSize.height

        label:setPosition(x, y)
        item:addChild(label)
        y = y + 5

        -- 释放时机
        showSkillIndex(y, formationIndex)
    end

    return item
end

--- ==================== 数据相关 =======================
-- 初始化数据
function PetCampLayer:initData()
	-- 读取外功列表
    self.mSlotData = {}
	for slotIdx=1, SlotCount do
		if FormationObj:slotIsOpen(slotIdx) and not FormationObj:slotIsEmpty(slotIdx) then
			local slotInfo = FormationObj:getSlotInfoBySlotId(slotIdx)
            if slotInfo.Pet and slotInfo.Pet.Id then
			    self.mSlotData[slotIdx] = slotInfo.Pet
            end
		end
	end

    -- 读取布阵信息
    self.mItemData = {}
    local originalFormation = FormationObj:getPetFormationInfo()
    local tmpFormationList = string.split(originalFormation.FormationStr, ",")
    -- 按照服务端的理解，这里应该是以释放顺序为key的列表，value是对应的卡槽
    -- 转换成以释放顺序为key的索引，内容里的 slotId 是这个顺序对应的卡槽ID，showIndex 是技能释放的顺序，也是显示的顺序。
    for i,v in ipairs(tmpFormationList) do
        table.insert(self.mItemData, {showIndex = i, slotId = tonumber(v)})
    end
end

-- 计算阵型UI配置
function PetCampLayer:calcFormationConfig()
    local formationConfig = {}

    local x = Width / 2
    local y = ListTopY - Height / 2
    for formationIndex=1, SlotCount do
        -- 位置坐标
        formationConfig[formationIndex] = {
            x = x,
            y = y
        }
        y = y - Height
    end

    return formationConfig
end

--- ==================== 服务器数据请求相关 =======================
-- 请求调整顺序的接口
function PetCampLayer:requestPetFormationChange()
    -- 提取参数
    local paramsArray = {}
    for _,v in ipairs(self.mItemData) do
        table.insert(paramsArray, v.slotId)
    end
    local newFormationStr = table.concat(paramsArray, ",")
    HttpClient:request({
        moduleName = "Pet", 
        methodName = "PetFormationChange", 
        svrMethodData = paramsArray,
        callback = function(response)
            if response.Status == 0 then
                -- 修改缓存数据
                FormationObj:updatePetFormationInfo({FormationStr = newFormationStr})
            end
        end
    })
end

return PetCampLayer
