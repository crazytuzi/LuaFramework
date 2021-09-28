--[[
文件名:SlotBriefView.lua
描述：队伍卡槽的羁绊和属性概况（该页面没有做适配处理，需要创建者考虑适配问题）
创建人：peiyaoqiang
创建时间：2017.03.08
--]]

local SlotBriefView = class("SlotBriefView", function(params)
    return display.newLayer()
end)
-- 精灵纹理缓存
local cache = cc.Director:getInstance():getTextureCache()

--[[
-- 参数 params中的每项为：
    {
    	viewSize: 显示大小
        showSlotId: 当前显示的阵容卡槽Id
        formationObj: 阵容数据对象
    }
--]]
function SlotBriefView:ctor(params)
    params = params or {}
    -- 显示大小
    self.mViewSize = params.viewSize or cc.size(640, 220)
    -- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()

    -- 显示卡槽属性的label列表
    self.mAttrLabelList = {}
    -- 显示卡槽羁绊信息的 label 列表
    self.mPrLabelList = {}

    self:setContentSize(self.mViewSize)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    -- 创建页面控件
    self:initUI()
end

-- 创建页面控件
function SlotBriefView:initUI()
	-- 创建属性预览部分信息
    self:createAttrView()
    -- 创建卡槽羁绊信息
    self:createPrView()
    -- 刷新控件显示
    self:changeShowSlot()
end

-- 创建卡槽属性预览部分信息
function SlotBriefView:createAttrView()
    -- 卡槽属性预览的背景
    local tempBtn = ui.newButton({
        normalImage = "zr_04.png",
        clickAction = function()
            if not self.mIsMyself then
                return 
            end

            -- 当卡槽为空时不能点击
            if self.mFormationObj:slotIsEmpty(self.mShowSlotId) then
                return 
            end

            LayerManager.addLayer({
                name = "team.SlotDetailAttrLayer",
                cleanUp = false,
                data = {
                    showSlotId = self.mShowSlotId,
                    formationObj = self.mFormationObj,
                },
            })
        end
    })
    tempBtn:setPressedActionEnabled(false)
    tempBtn:setAnchorPoint(cc.p(0.5, 0.5))
    tempBtn:setPosition(self.mViewSize.width * 0.25, self.mViewSize.height / 2)
    self:addChild(tempBtn)
    -- 标题
    local titleSprite = ui.newSprite("zr_01.png")
    titleSprite:setPosition(148, 153)
    tempBtn:addChild(titleSprite)
    -- 详情
    local tempSprite = ui.newSprite("zr_03.png")
    tempSprite:setAnchorPoint(cc.p(1, 1))
    tempSprite:setPosition(280, 177)
    tempBtn:addChild(tempSprite)

    for index = 1, 4 do
        local tempLabel = ui.newLabel({
            text = "",
            color = cc.c3b(0x8f, 0x4f, 0x0a),
            size = 22,
            align = cc.TEXT_ALIGNMENT_LEFT,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(60, 110 - (index - 1) * 28)
        tempBtn:addChild(tempLabel)

        table.insert(self.mAttrLabelList, tempLabel)
    end
end

-- 创建卡槽羁绊信息
function SlotBriefView:createPrView()
    -- 卡槽羁绊的背景
    local tempBtn = ui.newButton({
        normalImage = "zr_04.png",
        clickAction = function()
            if not self.mIsMyself then
                return 
            end
            local prInfoList = self.mFormationObj:getSlotPrInfo(self.mShowSlotId)
            if #prInfoList == 0 then  -- 没有羁绊
                return 
            end
            
            LayerManager.addLayer({
                name = "team.SlotDetailPrLayer",
                cleanUp = false,
                data = {
                    showSlotId = self.mShowSlotId,
                    formationObj = self.mFormationObj,
                },
            })
        end
    })
    tempBtn:setPressedActionEnabled(false)
    tempBtn:setAnchorPoint(cc.p(0.5, 0.5))
    tempBtn:setPosition(self.mViewSize.width * 0.75, self.mViewSize.height / 2)
    self:addChild(tempBtn)
    -- 标题
    local titleSprite = ui.newSprite("zr_02.png")
    titleSprite:setPosition(148, 153)
    tempBtn:addChild(titleSprite)
    -- 详情
    local tempSprite = ui.newSprite("zr_03.png")
    tempSprite:setAnchorPoint(cc.p(1, 1))
    tempSprite:setPosition(280, 177)
    tempBtn:addChild(tempSprite)

    -- 创建显示羁绊信息的Label控件, 每个卡槽最多10条羁绊
    for index = 1, 10 do
        local tempLabel = ui.newLabel({
            text = "index" .. tostring(index),
            size = 22,
            color = Enums.Color.eNotPrColor,
            align = cc.TEXT_ALIGNMENT_LEFT,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempBtn:addChild(tempLabel)

        table.insert(self.mPrLabelList, tempLabel)
    end
end

-- 显示的阵容卡槽改变
--[[
-- 参数
    showSlotId: 当前显示的阵容卡槽Id
]]
function SlotBriefView:changeShowSlot(showSlotId)
    self.mShowSlotId = showSlotId or self.mShowSlotId
    
    -- 刷新卡槽属性
    local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    if slotInfo and Utility.isEntityId(slotInfo.HeroId) then
        local attrInfo = self.mFormationObj:getSlotAttrInfo(self.mShowSlotId)
        for index, attrName in ipairs({"HP", "AP", "DEF", "FSP"}) do
            local tempInfo = attrInfo[attrName]
            local tempLabel = self.mAttrLabelList[index]
            if tempLabel then
                tempLabel:setString(string.format("%s: %s", tempInfo.viewName, tempInfo.viewValue))
            end
        end
    else
        for _, lable in pairs(self.mAttrLabelList) do
            lable:setString("")
        end
    end

    -- 根据羁绊数量，调整大小
    local prInfoList = self.mFormationObj:getSlotPrInfo(self.mShowSlotId)
    local isNeedShrink = #prInfoList > 8
    for index, label in ipairs(self.mPrLabelList) do
        local cel = math.mod((index - 1), 2)
        local row = math.floor((index - 1) / 2)
        local tempPos = cc.p(30 + cel * 120, (isNeedShrink and 114 or 110) - row * (isNeedShrink and 23 or 28))
        label:setPosition(tempPos)
        label:setFontSize(isNeedShrink and 20 or 22)
        label:setVisible(index <= #prInfoList)

        -- 刷新羁绊简介信息
        if index <= #prInfoList then
            local prInfo = prInfoList[index]
            label:setString(prInfo and prInfo.prName or "")
            label:setTextColor(prInfo and prInfo.havePr and Enums.Color.ePrColor or Enums.Color.eNotPrColor)
        end
    end
end 

return SlotBriefView
