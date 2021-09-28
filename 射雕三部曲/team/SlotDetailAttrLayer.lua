--[[
    文件名: SlotDetailAttrLayer.lua
    描述：队伍卡槽详细属性展示页面
    创建人: peiyaoqiang
    创建时间: 2017.03.08
--]]

local SlotDetailAttrLayer = class("SlotDetailAttrLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		showSlotId: 当前显示的阵容卡槽Id
	    formationObj: 阵容数据对象
	}
]]
function SlotDetailAttrLayer:ctor(params)
    -- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("属性详情"),
        bgSize = cc.size(580, 800),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹框控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function SlotDetailAttrLayer:initUI()
    --当前卡槽玩家的信息
    local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    local heroInfo = self.mIsMyself and HeroObj:getHero(slotInfo.HeroId) or slotInfo.Hero
 
    -- 确定按钮
	local okButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确 定"),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end,
    })
    okButton:setAnchorPoint(0.5, 0)
    okButton:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(okButton)

    -- 显示分割线
    local headBgSprite = ui.newScale9Sprite("c_65.png", cc.size(514, 130))
    headBgSprite:setPosition(self.mBgSize.width * 0.5, 666)
    self.mBgSprite:addChild(headBgSprite)

    -- 显示头像
    local headerNode =require("common.CardNode").new({allowClick = false})
    local showAttrs = {CardShowAttr.eBorder}
    headerNode:setCardData({
        resourceTypeSub = ResourcetypeSub.eHero, 
        modelId = slotInfo.ModelId, 
        fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
        IllusionModelId = heroInfo.IllusionModelId,
        cardShowAttrs = showAttrs
        })
    headerNode:setAnchorPoint(0, 0.5)
    headerNode:setPosition(50, 669)
    self.mBgSprite:addChild(headerNode)

    -- 显示玩家的等级 战力
    local function addLabel(parent, strText, posX, posY)
        local label = ui.newLabel({
            text = strText,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(posX, posY)
        parent:addChild(label)
    end
    addLabel(self.mBgSprite, ConfigFunc:getHeroName(slotInfo.ModelId, {IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder}), 170, 695)
    addLabel(self.mBgSprite, TR("等级: %s%d", "#d17b00", heroInfo.Lv or 1), 170, 665)
    addLabel(self.mBgSprite, TR("战力: %s%s", "#d17b00", slotInfo.FAP or 0), 170, 635)

    -- 属性ListView
    self:properListView()
end    

-- 属性ListView
function SlotDetailAttrLayer:properListView()
    -- 构造一个同时创建name和属性的函数
    local function addNameAndProperty(parent, name, namePosX, valueBgPosX, valueBgWidth, valueView)
        local nameLabel = ui.newLabel({
            text = name,
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        nameLabel:setAnchorPoint(cc.p(0, 0.5))
        nameLabel:setPosition(namePosX, 25)
        parent:addChild(nameLabel) 

        local valueBgSprite = ui.newScale9Sprite("c_39.png", cc.size(valueBgWidth, 35))
        valueBgSprite:setAnchorPoint(cc.p(1, 0.5))
        valueBgSprite:setPosition(valueBgPosX, 25)
        parent:addChild(valueBgSprite)
        local valueBgSpriteSize = valueBgSprite:getContentSize()

        local valueLabel = ui.newLabel({
            text = valueView,
            size = 20,
            anchorPoint = cc.p(0, 0.5),
            color = cc.c3b(0xd1, 0x7b, 0x00)
        }) 
        valueLabel:setPosition(10, valueBgSpriteSize.height * 0.5)
        valueBgSprite:addChild(valueLabel)
    end

    --  需要显示属性列表
    local viewAttrList = {
        {"STR", "CON", "INTE", "FSP", "AP", "DEF", "HP", "", "HIT", "DOD", "CRI", "TEN", "BOG", "BLO", "CRID", "TEND",},
        {"DAMADD", "DAMADDR", "DAMCUT", "DAMCUTR", "CP", "CPR", "BCP", "BCPR", "PVPDAMADDR", "PVPDAMCUTR"},
    }

    -- 获取卡槽信息
    local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    local property = slotInfo.Property or {}

    -- 创建ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(580, 480))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(290, 585)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mBgSprite:addChild(self.mListView)

    -- 遍历需要显示属性列表
    for type, item in ipairs(viewAttrList) do
        -- 一行只有一项
        if type == 3 then
            for index, attrName in ipairs(item) do
                -- 创建一个cell
                local lvItem = ccui.Layout:create()
                lvItem:setContentSize(cc.size(590, 50))
                self.mListView:pushBackCustomItem(lvItem)

                -- 获取属性名字和值
                local viewName = ConfigFunc:getViewNameByFightName(attrName)
                local attrType = ConfigFunc:getFightAttrEnumByName(attrName)
                local valueView = Utility.getAttrViewStr(attrType, property[attrName], false)
                -- 创建name和属性
                addNameAndProperty(lvItem, viewName, 25, 380, 130, valueView)
            end
        else 
            local tempCount = #item
            for index = 1, math.ceil(tempCount / 2) do
                --创建一个cell
                local lvItem = ccui.Layout:create()
                lvItem:setContentSize(cc.size(590, 50))
                self.mListView:pushBackCustomItem(lvItem)

                -- 获取属性背景图片的宽度
                local valueBgWidth = (type == 1) and 147 or 107

                -- 左边属性在viewAttrList的下标
                local leftTempIndex = (index - 1) * 2 + 1
                -- 右边属性在viewAttrList的下标
                local righTempIndex = index * 2

                for i = 1, 2 do
                    local tempIndex = nil
                    local nameLabelWidth ,valueBgSpriteWidth, valueLabelWidth = nil 
                    local nameLabelHeight ,valueBgSpriteHeight, valueLabelHeight = nil 
                    --左边
                    if i == 1 then
                        tempIndex = leftTempIndex
                        nameLabelWidth ,valueBgSpriteWidth, valueLabelWidth = 35, 265, 5
                        nameLabelHeight ,valueBgSpriteHeight, valueLabelHeight = 25, 25, 5
                    -- 右边
                    else
                        tempIndex = righTempIndex
                        nameLabelWidth ,valueBgSpriteWidth, valueLabelWidth = 320, 545, 5
                        nameLabelHeight ,valueBgSpriteHeight, valueLabelHeight = 25, 25, 5
                    end
                    -- 获取属性名字和值
                    local valueName = item[tempIndex]
                    if (valueName ~= nil) and (valueName ~= "") then
                        local viewName = ConfigFunc:getViewNameByFightName(valueName)
                        local attrType = ConfigFunc:getFightAttrEnumByName(valueName)
                        local valueView = Utility.getAttrViewStr(attrType, property[valueName], false)

                        -- 创建name和属性
                        addNameAndProperty(lvItem, viewName, nameLabelWidth, valueBgSpriteWidth, valueBgWidth, valueView)
                    end
                end  
            end     
        end    
    end        
end

return SlotDetailAttrLayer