-- Filename：    ConsoleBtn.lua
-- Author：      zhz
-- Date：        2013-6-14
-- Purpose：     控制台按钮

module ("ConsoleBtn", package.seeall)
require("script/consoleExe/ConsoleLayer")

local IMG_PATH = "images/level_reward/"

function ConsoleBtnCb(tag, itemBtn)
    local consoleLayer = ConsoleLayer.createLayer()
    MainScene.changeLayer(consoleLayer, "consoleLayer")
end


function createConsoleBtn(bglayer)
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bglayer:addChild(menu)

    local ConsoleBtn = CCMenuItemImage:create("images/common/question_mask.png", "images/common/question_mask.png")
    --position changed by zhang zihang
    ConsoleBtn:setPosition(ccp(bglayer:getContentSize().width*0.35/g_fElementScaleRatio,bglayer:getContentSize().height/2/g_fElementScaleRatio))
    ConsoleBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(ConsoleBtn)
    ConsoleBtn:registerScriptTapHandler(ConsoleBtnCb)
    
end

function checkBtnCallback()

end