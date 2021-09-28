--[[
	文件名：DlgExchangeNoticeLayer.lua
	描述：装备分解页面的兑换提示框
	创建人: peiyaoqiang
	创建时间: 2017.08.29
--]]

local DlgExchangeNoticeLayer = class("DlgExchangeNoticeLayer", function()
	return display.newLayer()
end)


-- 构造函数
function DlgExchangeNoticeLayer:ctor(params)
	local itemName = params.isEquip and TR("装备") or TR("内功心法")
    local savedName = params.isEquip and "PurpleEquipsOneKeyRefine" or "PurpleZhenJueOneKeyRefine"
	-- 创建提示框
    local noticeLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 374),
        title = TR("兑换"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(noticeLayer)
    local noticeSprite = noticeLayer.mBgSprite

    local exchangeList = {}
    if not isNotPurple then
        table.insert(exchangeList, TR("凑够 {%s} %d可兑换%s紫色%s", params.dbImageName, params.usedCountList[1], Enums.Color.ePurpleH, itemName))
    end
    table.insert(exchangeList, TR("凑够 {%s} %d可兑换%s橙色%s", params.dbImageName, params.usedCountList[2], Enums.Color.eOrangeH, itemName))
    for i,desc in ipairs(exchangeList) do
        local descY = 335 - i * 80
        local descBgSprite = ui.newScale9Sprite("gd_10.png", cc.size(390, 58))
        descBgSprite:setPosition(cc.p(35, descY))
        descBgSprite:setAnchorPoint(cc.p(0, 0.5))
        noticeSprite:addChild(descBgSprite)

        local descLabel = ui.newLabel({
                text = desc,
                size = 24,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        descLabel:setAnchorPoint(cc.p(0, 0.5))
        descLabel:setPosition(cc.p(50, descY))
        noticeSprite:addChild(descLabel)

        local exchangeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("兑换"),
            fontSize = 24,
            position = cc.p(500, descY),
            clickAction = function ()
                if params.isEquip then
                    -- 紫色，橙色
                    local startIndex = (isNotPurple and 3 or 2)
                    LayerManager.addLayer({
                        name = "challenge.BddExchangeLayer",
                        data = {
                            mTag = i + startIndex
                        }
                    })
                else
                    LayerManager.showSubModule(ModuleSub.eTeambattleShop)
                end
            end})
        noticeSprite:addChild(exchangeBtn)
        exchangeBtn:setEnabled(params.localCount >= params.usedCountList[i])
    end

    local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        imageScale = 2,
        text = TR("不提示%s紫色%s#46220d兑换", Enums.Color.ePurpleH, itemName),
        textColor = cc.c3b(0x46, 0x22, 0x0d),
        callback = function(isSelect)
            -- 保存当前的选择
            LocalData:saveGameDataValue(savedName, isSelect)
        end
    })
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(50, 50)
    checkBox:setCheckState(isNotPurple)
    noticeSprite:addChild(checkBox)
end

return DlgExchangeNoticeLayer
