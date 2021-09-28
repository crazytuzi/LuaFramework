-- Filename: PocketChooseLayer.lua
-- Author: llp
-- Date: 2014-6-12
-- Purpose: 该文件用于: 锦囊选择界面

module ("PocketChooseLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/audio/AudioUtil"
require "script/ui/main/MainScene"
require "script/ui/bag/PocketBagCell"
require "script/ui/pocket/PocketService"
require "script/ui/pocket/PocketController"
local _okButtonCallBack = nil 		
local _touchPriority    = nil
local _bg 				= nil
local _hid 				= nil
local _pos				= nil
local _paramDataTable
function init()
	layer              	= nil
	topMenuBar         	= nil
	_bg 				= nil
	_paramDataTable 	= nil
	_hid 				= nil
	_pos				= nil
	_okButtonCallBack  	= nil 		
	_touchPriority     	= nil
	_goodId            	= false
	_clothId           	= false
	_ksTagChooseItem   	= 1002	
end

function fnHandlerOfClose(pInfo,pFromId,pOldInfo)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local layer = PocketMainLayer.createLayer(_hid,nil,nil,nil,pInfo,pOldInfo)
    MainScene.changeLayer(layer,"PocketMainLayer")
end

function createTitleLayer()
	local tArgs = {}
	tArgs[1] = {x=125, tag=_ksTagChooseItem, handler=fnHandlerOfButtons}
	local _bulletinBg = BulletinLayer.getBg()
	--创建主菜单
	topMenuBar = LuaCCSprite.createTitleBarCpy(tArgs)
	topMenuBar:setAnchorPoint(ccp(0, 1))
	topMenuBar:setPosition(0, layer:getContentSize().height-_bulletinBg:getContentSize().height)
	topMenuBar:setScale(g_fScaleX)
	layer:addChild(topMenuBar,1)

	local layerNameSprite = CCSprite:create("images/pocket/equippocket.png")
		  layerNameSprite:setColor(ccc3(0xff,0xf6,0x00))
		  layerNameSprite:setAnchorPoint(ccp(0,0.5))
		  layerNameSprite:setPosition(ccp(20,topMenuBar:getContentSize().height*0.5))
	topMenuBar:addChild(layerNameSprite)
	
	local tItems = {
		{normal="images/common/close_btn_n.png", highlighted="images/common/close_btn_h.png", pos_x=550, pos_y=20, cb=fnHandlerOfClose},
	}
	local menu = CCMenu:create()
		  menu:setAnchorPoint(ccp(0, 0))
		  menu:setPosition(ccp(0, 0))
		  menu:setTouchPriority(_touchPriority - 10)
	topMenuBar:addChild(menu)

	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
		  closeButton:setPosition(ccp(550, 20))
		  closeButton:registerScriptTapHandler(fnHandlerOfClose)
	menu:addChild(closeButton)
end

function refreshTableView( ... )
	-- body
	layer:removeChildByTag(1,true)
	createPocketTableView()
end

function afterChoosePocket( pItemId,pItem )
	-- body
	local _heroInfo = HeroModel.getHeroByHid(tostring(_hid))

	for key,value in pairs(_paramDataTable)do
		if(tonumber(value.item_id)==tonumber(pItemId))then
			for i,p in pairs(_heroInfo.equip.pocket) do
				if(not table.isEmpty(p) and tonumber(value.itemDesc.pocket_type)==tonumber(p.itemDesc.pocket_type) and tonumber(i)~=_pos)then
					AnimationTip.showTip( GetLocalizeStringBy("llp_248") )
					return
				end
			end
			if(not table.isEmpty(_heroInfo.equip.pocket[tostring(_pos)]))then
				PocketController.addPocketCallback(_hid,_pos,value,value.hid,_heroInfo.equip.pocket[tostring(_pos)])
			else
				PocketController.addPocketCallback(_hid,_pos,value,value.hid,nil)
			end
			break
		end
	end
end

local function createTableView(p_param,pData)
	local _sellBottomSprite = CCSprite:create("images/common/sell_bottom.png")
	local myScale = layer:getContentSize().width/_sellBottomSprite:getContentSize().width/g_fBgScaleRatio
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(640*g_fScaleX, 225*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = PocketBagCell.createCell(pData[table.count(pData)-a1], nil,true,true)
            local menuBar = CCMenu:create()
				  menuBar:setPosition(ccp(0,0))
	  			  menuBar:setTouchPriority(_touchPriority-1)
			a2:addChild(menuBar,1, 9898)
			a2:setScale(g_fScaleX)
			
			-- 强化
			local enhanceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("llp_234"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				  enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
		    	  enhanceBtn:setPosition(ccp(640*0.85, 240*0.5))
		    	  enhanceBtn.hid = pData[table.count(pData)-a1].hid
				  enhanceBtn:registerScriptTapHandler(afterChoosePocket)
			menuBar:addChild(enhanceBtn, 1, tonumber(pData[table.count(pData)-a1].item_id))
            r = a2
        elseif fn == "numberOfCells" then
            r = table.count(pData)
        else
        end

        return r
    end)

    local tableViewResult = LuaTableView:createWithHandler(h, p_param.bgSize)
    	  tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return(tableViewResult)
end

function createPocketTableView( ... )
	-- 创建tableView
	local bottomBg = CCSprite:create("images/main/menu/" .. "menu_bg.png")
    layerBeginHeight = bottomBg:getContentSize().height*g_fScaleX
    local _bulletinBg = BulletinLayer.getBg()
    local paramTable = {}
    paramTable.bgSize = CCSizeMake(layer:getContentSize().width,layer:getContentSize().height-topMenuBar:getContentSize().height*g_fScaleX-layerBeginHeight-_bulletinBg:getContentSize().height)
    _paramDataTable = PocketData.getFiltersForItem(_hid,true)
    _pocketTableView = createTableView(paramTable,_paramDataTable)
    _pocketTableView:setAnchorPoint(ccp(0,0))
    _pocketTableView:setPosition(ccp(0,layerBeginHeight))
    _pocketTableView:setTouchPriority(_touchPriority - 2)
    layer:addChild(_pocketTableView,0,1)
end

function createLayer(p_okButtonCallback, p_touchPriority, p_hid, p_pos)
	init()
	_okButtonCallBack = p_okButtonCallback
	_touchPriority    = p_touchPriority or -300
	_hid = p_hid
	_pos = p_pos
	MainScene.setMainSceneViewsVisible(true,false,true)
	layer = CCLayer:create()
	-- 加载模块背景图
	_bg = CCSprite:create("images/main/module_bg.png")
	_bg:setScale(g_fBgScaleRatio)
	layer:addChild(_bg)
	-- 创建选择项目标题栏
	createTitleLayer()
	-- 锦囊列表tableview
	createPocketTableView()
	return layer
end
