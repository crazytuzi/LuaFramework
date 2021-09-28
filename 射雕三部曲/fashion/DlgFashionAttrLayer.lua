--[[
    文件名: DlgFashionAttrLayer.lua
    创建人: heguanghui
    创建时间: 2017-09-16
    描述: 时装属性总览界面
--]]

local DlgFashionAttrLayer = class("DlgFashionAttrLayer", function()
    return display.newLayer()
end)

function DlgFashionAttrLayer:ctor()
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 427),
        title = TR("天赋总览"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 计算属性加成
    self:calcAttrs(function ()
        -- 初始化页面控件
        self:initUI()
    end)
end

-- 计算加成属性
function DlgFashionAttrLayer:calcAttrs(callback)
    --处理参数
    self.dataSrc = {}

    local function fashionCallback(faList)
        -- 过滤掉相同的时装
        local filter = {}
        for _,v in ipairs(faList) do 
            if not filter[v.ModelId] then 
                filter[v.ModelId] = v
            end
        end

        -- 处理基础属性数据
        local allAttrUpData = {}
        local function addToBaseAttr(item)
            local isExist = false
            for _, vv in ipairs(allAttrUpData) do
                if (vv[1] == item[1]) then
                    vv[2] = vv[2] + item[2]
                    isExist = true
                    break
                end
            end
            if not isExist then
                table.insert(allAttrUpData, item)
            end
        end
        for _, item in pairs(filter) do
            -- 添加基础属性
            for _, attr in ipairs(string.split(FashionModel.items[item.ModelId].baseAttrStr, ",")) do
                addToBaseAttr(string.split(attr, "|"))
            end
            -- 添加进阶属性
            local nStep = item.Step or 0
            if (nStep > 0) then
                local stepInfo = FashionStepRelation.items[item.ModelId][nStep]
                for _,v in ipairs(string.split(stepInfo.attrStr, ",")) do
                    addToBaseAttr(string.split(v, "|"))
                end
            end
        end
        
        -- 处理组合属性数据
        local frontAttrUpData, behindAttrUpData, allFashAttrUpData = {}, {}, {}
        -- 初始化数据
        local initData = {}
        for _,v in ipairs(FashionPrRelation.items) do
            local cell = {}
            cell.name = v.name
            cell.allAttr = v.allAttr
            local member = string.split(v.memberS, ",")
            cell.leftModuleId = member[1]
            cell.rightModuleId = member[2]
            cell.intro = v.intro
            table.insert(initData, cell)
        end
        -- 处理已拥有组合
        local data = {}
        for _,v in pairs(FashionModel.items) do
            data[tostring(v.ID)] = FashionObj:getOneItemOwned(v.ID)
        end
        -- 计算属性
        for _,v in ipairs(initData) do
            if data[v.leftModuleId] and data[v.rightModuleId] then
                local attrList = string.split(v.allAttr, ",")
                for _,attr in ipairs(attrList) do
                    local mStr = string.split(attr, "||")
                    local mAttr = string.split(mStr[2], "|")
                    if mStr[1] == "6" then
                        local isExist = false
                        for _, vv in ipairs(frontAttrUpData) do
                            if vv[1] == mAttr[1] then
                                vv[2] = vv[2] + mAttr[2]
                                isExist = true
                                break
                            end
                        end
                        if not isExist then
                            table.insert(frontAttrUpData, mAttr)
                        end
                    elseif mStr[1] == "7" then
                        local isExist = false
                        for _, vv in ipairs(behindAttrUpData) do
                            if vv[1] == mAttr[1] then
                                vv[2] = vv[2] + mAttr[2]
                                isExist = true
                                break
                            end
                        end
                        if not isExist then
                            table.insert(behindAttrUpData, mAttr)
                        end
                    elseif mStr[1] == "2" then
                        local isExist = false
                        for _, vv in ipairs(allFashAttrUpData) do
                            if vv[1] == mAttr[1] then
                                vv[2] = vv[2] + mAttr[2]
                                isExist = true
                                break
                            end
                        end
                        if not isExist then
                            table.insert(allFashAttrUpData, mAttr)
                        end
                    end
                end
            end
        end
        -- dump(allAttrUpData, "基本属性全体")
        -- dump(frontAttrUpData, "组合属性前排")
        -- dump(behindAttrUpData, "组合属性后排")
        -- dump(allFashAttrUpData, "组合属性全体")
        self.dataSrc = {behindAttrUpData, frontAttrUpData, allAttrUpData}
        -- 回调创建界面
        callback()
    end
    -- 获取时装数据
    FashionObj:getFashionList(fashionCallback)
end

-- 初始化页面控件
function DlgFashionAttrLayer:initUI()
    -- 添加背景
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(540, 325))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(bgSprite)

    -- 添加cell
    local cellSize = cc.size(520, 96)
    local attrImages = {"zr_61.png", "zr_62.png", "zr_63.png"}
    for idx,attrv in ipairs(self.dataSrc) do
        local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width , cellSize.height))
        cellSprite:setPosition(self.mBgSize.width / 2, 86 + (idx-1) * 105)
        self.mBgSprite:addChild(cellSprite)

        -- 属性名
        local attrSprite = ui.newSprite(attrImages[idx])
        attrSprite:setPosition(85, 47)
        cellSprite:addChild(attrSprite)

        -- 属性加成
        if #attrv > 0 then
            local posList = (#attrv <= 2) and {cc.p(182, 47), cc.p(342, 47)} or {cc.p(182, 64), cc.p(342, 64), cc.p(182, 30), cc.p(342, 30)}
            for i,v in ipairs(attrv) do
                local tempLabel = ui.newLabel({
                   text = string.format("%s+#087E05%d", FightattrName[tonumber(v[1])], v[2]),
                   color = cc.c3b(0x46, 0x22, 0x0d),
                   size = 22,
                })
                tempLabel:setAnchorPoint(cc.p(0, 0.5))
                tempLabel:setPosition(posList[i])
                cellSprite:addChild(tempLabel)
            end
        else
            local tempLabel = ui.newLabel({
               text = TR("尚未激活"),
               color = cc.c3b(0x46, 0x22, 0x0d),
               size = 22,
            })
            tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
            tempLabel:setPosition(322, 47)
            cellSprite:addChild(tempLabel)
        end
    end
end

return DlgFashionAttrLayer