--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-18
-- Time: 下午1:43
-- To change this template use File | Settings | File Templates.
--

local UseDialog = class("UseDialog", function()
    return require("utility.ShadeLayer").new()
end)

function UseDialog:ctor()
    display.addSpriteFramesWithFile("ui/ui_pop_window.plist", "ui/ui_pop_window.png")
--
    local _width = CONFIG_SCREEN_WIDTH * 0.8
    local _height = CONFIG_SCREEN_HEIGHT * 0.38
    local bg = display.newScale9Sprite("#popwin_bg.png")
    bg:setPreferredSize(CCSizeMake(_width, _height) )
    bg:setPosition(display.width / 2, display.height / 2)
    self:addChild(bg, TOP_LAYER_TAG, TOP_LAYER_TAG)

    local titleSprite = display.newSprite("#bag_piliang.png")
    titleSprite:setPosition(_width / 2, _height - titleSprite:getContentSize().height * 1.5)
    bg:addChild(titleSprite)

    local lineSprite = display.newScale9Sprite("#bag_line.png")
    lineSprite:setPreferredSize(CCSizeMake(_width * 0.8, 1.5) )
    lineSprite:setPosition(_width / 2, _height - titleSprite:getContentSize().height * 2)
    bg:addChild(lineSprite)

    local cancelBtn = require("utility.CommonButton").new({
        img = "#com_btn_green.png",
        listener = function (  )
            bg:runAction(transition.sequence({

                CCScaleTo:create(0.2, 0),
                CCCallFunc:create(function()
                    self:removeFromParentAndCleanup(true)
                end)
            }))
        end
    })
    cancelBtn:setPosition(_width / 4 - cancelBtn:getContentSize().width / 2, cancelBtn:getContentSize().height * 0.5)
    bg:addChild(cancelBtn)

    local okBtn = require("utility.CommonButton").new({
        img = "#com_btn_red.png",
        listener = function (  )

        end
    })
    okBtn:setPosition(_width * (3 / 4) - okBtn:getContentSize().width / 2, okBtn:getContentSize().height * 0.5)
    bg:addChild(okBtn)

    local availNumLabel = ui.newTTFLabel({
        text = "当前可使用48个",
        color = FONT_COLOR.LIGHT_ORANGE,
        size = 22,
        x = _width / 2,
        y = _height * 0.68,
        align = ui.TEXT_ALIGN_CENTER
    })
    bg:addChild(availNumLabel)

    local useNumLabel = ui.newTTFLabel({
        text = "输入使用大还丹的数量",
        color = FONT_COLOR.LIGHT_ORANGE,
        size = 22,
        x = _width / 2,
        y = _height * 0.6,
        align = ui.TEXT_ALIGN_CENTER
    })
    bg:addChild(useNumLabel)

    local countBg = display.newSprite("#bag_use_num_bg.png")
    countBg:setPosition(_width / 2, _height * 0.42)
    bg:addChild(countBg)

    local countLabel = ui.newTTFLabel({
        text = "0",
        color = FONT_COLOR.DARK_RED,
        size = 22,
        x = countBg:getContentSize().width / 2,
        y = countBg:getContentSize().height / 2,
        align = ui.TEXT_ALIGN_CENTER
    })
    countBg:addChild(countLabel)

    local count = 0
    local function updateCountlabel()

        countLabel:runAction(transition.sequence({
            CCScaleTo:create(0.2, 1.5),
            CCCallFunc:create(function()
                countLabel:setString(tostring(count))
            end),
            CCScaleTo:create(0.1, 1),
        }))
    end



    local reduceBtn_1 = require("utility.CommonButton").new({
        img = "#bag_add_btn.png",
        listener = function (  )
            if count > 0 then
                count = count - 1
            end

            updateCountlabel()
        end
    })
    reduceBtn_1:setPosition(_width / 2 - countBg:getContentSize().width / 2 - reduceBtn_1:getContentSize().width, _height * 0.42 - reduceBtn_1:getContentSize().height / 2)
    bg:addChild(reduceBtn_1)

    local addBtn_1 = require("utility.CommonButton").new({
        img = "#bag_add_btn.png",
        listener = function ()
            count = count + 1
            updateCountlabel()
        end
    })
    addBtn_1:setPosition(_width / 2 + countBg:getContentSize().width / 2, _height * 0.42 - addBtn_1:getContentSize().height / 2)
    bg:addChild(addBtn_1)

    local reduceBtn_10 = require("utility.CommonButton").new({
        img = "#bag_add_btn.png",
        listener = function ()
            if count - 10 > 0 then
                count = count - 10
            else
                count = 0
            end
            updateCountlabel()
        end
    })
    reduceBtn_10:setPosition(_width * 0.1, _height * 0.42 - reduceBtn_10:getContentSize().height / 2)
    bg:addChild(reduceBtn_10)

    local addBtn_10 = require("utility.CommonButton").new({
        img = "#bag_add_btn.png",
        listener = function (  )
            count = count + 10
            updateCountlabel()
        end
    })
    addBtn_10:setPosition(_width * 0.9 - addBtn_10:getContentSize().width, _height * 0.42 - addBtn_10:getContentSize().height / 2)
    bg:addChild(addBtn_10)


--
end

return UseDialog

