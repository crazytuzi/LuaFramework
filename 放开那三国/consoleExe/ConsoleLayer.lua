-- Filename：	ConsoleLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-6-14
-- Purpose：		控制台入口

module ("ConsoleLayer", package.seeall)

require "script/network/Network"
require "script/utils/BaseUI"

local clearPathMap = {
	-- "script/ui/mission/",
	"script/localized/",
	"script/fight/",
	"script/ui/treasure",
	-- "script/ui/countryWar/",
	"script/ui/countryWar/cheer/",
	-- "script/ui/countryWar/shop/",
	"script/ui/shopall/tally",
	"script/ui/hero/HeroInfoLayer",
	"script/ui/tally/preview/",
	"script/ui/refining/",
	"script/ui/active/",
	"script/ui/pet",
	"script/ui/common/DetailAttrLayer"
}


local IMG_PATH = "images/common/"	
local ccEditBox = nil
local bgLayer = nil

function consoleCallback( cbFlag, dictData, bRet )
	require "script/utils/LuaUtil"
	print_table("dictData",dictData)

end

local function itemMenuAction( tag, menuItem )
	local text = ccEditBox:getText()
	if (#text == 0) then
		return
	end
	local args = CCArray:createWithObject(CCString:create(text)); 
	Network.rpc(ConsoleLayer.consoleCallback, "console.execute", "console.execute", args, true)
end

function checkBattleButtonCallback( ... )
	local text = ccEditBox:getText()
	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(text)
end

function testBattleButtonCallback( ... )
	local text = ccEditBox:getText()
	require "script/battle/BattleUtil"
	BattleUtil.playerTestBattleReportById(text)
end

function clearModule( ... )
	local releaseFileArr = {}
	for k, v in pairs(package.loaded) do
		for _,path in pairs(clearPathMap) do
			local status = false
			if string.find(k, path) == 1 then
				status = true
			end
			if status then
				table.insert(releaseFileArr, k)
			end
		end
	end
	for _, m_name in pairs(releaseFileArr) do
		package.loaded[m_name]=nil
		local arrModNames=string.split(m_name, "/")
		local modName=arrModNames[#arrModNames]
		package.loaded[modName]=nil
		_G[modName]=nil
		
	end
end



function createLayer()
	require "script/ui/main/MainScene"
--	bgLayer = MainScene.createBaseLayer()
	bgLayer = CCLayer:create()
	local args = CCArray:createWithObject(CCString:create("help")); 
	Network.rpc(ConsoleLayer.consoleCallback, "console.execute", "console.execute", args, true)
	--position changed by zhang zihang
	ccEditBox = CCEditBox:create (CCSizeMake(400*g_fElementScaleRatio,60*g_fElementScaleRatio), CCScale9Sprite:create("images/test/green_edit.png"))
	ccEditBox:setPosition(ccp(g_winSize.width/2,370*g_fScaleY))
	ccEditBox:setPlaceHolder("点击输入控制台指令")
	ccEditBox:setAnchorPoint(ccp(0.5,0.5))
	ccEditBox:setMaxLength(100)
	ccEditBox:setReturnType(kKeyboardReturnTypeDone)
	ccEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
	--ccEditBox:setScale(g_fElementScaleRatio)
	bgLayer:addChild(ccEditBox)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bgLayer:addChild(menu)
    require "script/ui/main/MainScene"
	
	require "script/ui/common/LuaMenuItem"
	local itemImage = CCMenuItemImage:create( "images/copy/fort/btn_normal_n.png","images/copy/fort/btn_normal_h.png" )
	itemImage:setScale(g_fElementScaleRatio)
	itemImage:setAnchorPoint(ccp(0.5,0.5))
    itemImage:setPosition(ccp(bgLayer:getContentSize().width*0.75,bgLayer:getContentSize().height * 0.25))
    itemImage:registerScriptTapHandler(itemMenuAction)
	menu:addChild(itemImage, 1, 1)

	local checkBattleButton = CCMenuItemImage:create( "images/copy/fort/btn_fight_n.png","images/copy/fort/btn_fight_h.png" )
	checkBattleButton:setScale(g_fElementScaleRatio)
	checkBattleButton:setAnchorPoint(ccp(0.5,0.5))
    checkBattleButton:setPosition(ccp(bgLayer:getContentSize().width*0.25,bgLayer:getContentSize().height * 0.25))
    checkBattleButton:registerScriptTapHandler(checkBattleButtonCallback)
	menu:addChild(checkBattleButton, 1, 1)

	local testBattleButton = CCMenuItemImage:create( "images/copy/fort/btn_fight_n.png","images/copy/fort/btn_fight_h.png" )
	testBattleButton:setScale(g_fElementScaleRatio)
	testBattleButton:setAnchorPoint(ccp(0.5,0.5))
    testBattleButton:setPosition(ccp(bgLayer:getContentSize().width*0.5,bgLayer:getContentSize().height * 0.55))
    testBattleButton:registerScriptTapHandler(testBattleButtonCallback)
	menu:addChild(testBattleButton, 1, 1)

	local testBattleButton = CCMenuItemLabel:create( CCLabelTTF:create("clear lua", g_sFontName, 40))
	testBattleButton:setScale(g_fElementScaleRatio)
	testBattleButton:setAnchorPoint(ccp(0.5,0.5))
    testBattleButton:setPosition(ccp(bgLayer:getContentSize().width*0.5,bgLayer:getContentSize().height * 0.6))
    testBattleButton:registerScriptTapHandler(clearModule)
	menu:addChild(testBattleButton, 1, 1)

	-- bgLayer:addChild(menu)

	-- local menu = CCMenu:create()
 --    menu:setPosition(0,0)
	-- -- setAdaptNode(menu)

 --    local okButton = BaseUI.createButton(CCSizeMake(150, 60),GetLocalizeStringBy("key_2008"), itemMenuAction)
 --   	okButton:setPosition (440, 270)
 --    menu:addChild(okButton)
	
	return bgLayer
end 


