--[[
    文件名: DlgFashionPreviewLayer.lua
    创建人: peiyaoqiang
    创建时间: 2018-05-03
    描述: 绝学进阶预览的对话框
--]]

local DlgFashionPreviewLayer = class("DlgFashionPreviewLayer", function()
    return display.newLayer()
end)

function DlgFashionPreviewLayer:ctor(params)
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 读取参数
    local fashionModelId = params.modelId
    self.fashionStep = FashionObj:getOneItemStep(fashionModelId)
    self.stepConfig = {}
    for _,v in pairs(FashionStepRelation.items[fashionModelId] or {}) do
        if (v.step > 0) then
            table.insert(self.stepConfig, clone(v))
        end
    end
    table.sort(self.stepConfig, function (a, b)
            return a.step < b.step
        end)
    
    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 840),
        title = TR("进阶预览"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 
    self:initUI()
end

-- 初始化页面控件
function DlgFashionPreviewLayer:initUI()
    -- 添加背景
    local bgSize = cc.size(560, 740)
    local bgSprite = ui.newScale9Sprite("c_17.png", bgSize)
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(bgSprite)

    -- 创建列表
    local listWidth = bgSize.width - 20
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(listWidth, 720))
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(5)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(bgSize.width / 2, 10)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    bgSprite:addChild(listView)

    -- 添加cell
    for _,v in ipairs(self.stepConfig) do
        local layout = ccui.Layout:create()
        local cellWidth, cellHeight = listWidth, 120

        -- 处理技能描述
        local function dealSkillIntro(str)
            local tmpStr = str
            if (self.fashionStep < v.step) then
                tmpStr = ""
                for _,v in ipairs(string.splitBySep(str, "#73430D")) do
                    tmpStr = tmpStr .. "#585045" .. v
                end
            end
            local label = ui.newLabel({
                text = tmpStr,
                color = cc.c3b(0x73, 0x43, 0x0d),
                size = 18,
                align = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions = cc.size(cellWidth - 40, 0)
            })
            label:setAnchorPoint(cc.p(0, 1))
            return label, label:getContentSize().height
        end
        local label1, height1 = dealSkillIntro(TR("普攻: ") .. AttackModel.items[v.NAID].intro)
        local label2, height2 = dealSkillIntro(TR("技攻: ") .. AttackModel.items[v.RAID].intro)
        -- 重新计算背景高度
        cellHeight = cellHeight + height1 + height2
        label2:setPosition(20, 10 + height2)
        label1:setPosition(20, 10 + height2 + 5 + height1)
        layout:setContentSize(cellWidth, cellHeight)
        layout:addChild(label1, 1)
        layout:addChild(label2, 1)
        listView:pushBackCustomItem(layout)
        
        -- 背景图片
        local itemBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight - 2))
        itemBg:setAnchorPoint(cc.p(0.5, 0))
        itemBg:setPosition(cellWidth * 0.5, 0)
        layout:addChild(itemBg)

        -- 当前进阶
        local str = TR("进阶+%d", v.step)
        if (self.fashionStep >= v.step) then
            str = str .. " " .. TR("[已完成]")
        end
        local label = ui.newLabel({
            text = str,
            color = (self.fashionStep >= v.step) and Enums.Color.eNormalGreen or Enums.Color.eRed,
            size = 22,
        })
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(cc.p(20, cellHeight - 25))
        layout:addChild(label)

        -- 基础属性
        local xPosList = {110, 300}
        local yPosList = {cellHeight-55, cellHeight-85}
        local function addAttrLabel(strAttr, xPos, yPos)
            local label = ui.newLabel({
                text = strAttr,
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(xPos, yPos))
            layout:addChild(label)
        end
        addAttrLabel(TR("普通属性: "), 20, cellHeight-55)
        for i,v in ipairs(ConfigFunc:getBaseAttrByStep(v.ID, v.step)) do
            local x = math.floor((i-1) % #xPosList) + 1
            local y = math.floor((i-1) / #yPosList) + 1
            addAttrLabel(FightattrName[tonumber(v[1])] .. Enums.Color.eNormalGreenH .. "+" .. v[2], xPosList[x], yPosList[y])
        end
    end
end

return DlgFashionPreviewLayer