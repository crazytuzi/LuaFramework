-- Filename：	ChangeFashion.lua
-- Author：		Li Pan
-- Date：		2014-2-14
-- Purpose：		时装

module("ChangeFashion", package.seeall)

require "script/ui/fashion/FashionLayer"
require "script/ui/dressRoom/DressRoomCache"

local bgLayer = nil
local _shouldStopFashionLayerBgm = true

function create( ... )
	require "script/ui/main/MainScene"
	bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	bgLayer:registerScriptHandler(onNodeEvent)
	--	最上面的UI
	-- 背景
	local myScale = bgLayer:getContentSize().width/640/bgLayer:getElementScale()
	local topSprite = CCSprite:create("images/hero/select/title_bg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgLayer:getContentSize().width/2, bgLayer:getContentSize().height))
	topSprite:setScale(myScale)
	bgLayer:addChild(topSprite)

	-- 标题
	local titleSprite = CCSprite:create("images/fashion/fashion_title.png")
	titleSprite:setAnchorPoint(ccp(0.5, 0.5))
	titleSprite:setPosition(ccp(topSprite:getContentSize().width*0.2, topSprite:getContentSize().height/2 + 10))
	topSprite:addChild(titleSprite)

	-- 返回按钮
	local backMenuBar = CCMenu:create()
	backMenuBar:setPosition(ccp(0,0))
	topSprite:addChild(backMenuBar)

	local backBtn = LuaMenuItem.createItemImage("images/common/close_btn_n.png", "images/common/close_btn_h.png", backAction)
	backBtn:setAnchorPoint(ccp(0.5, 0.5))
	backBtn:setPosition(ccp(topSprite:getContentSize().width*0.85, topSprite:getContentSize().height*0.5 + 10))
	-- backBtn:registerScriptTapHandler(backAction)
	backMenuBar:addChild(backBtn)	


	--展示出 背包里的时装
	createFashionTableView()


	return bgLayer
end

function backAction( ... )
	-- require "script/ui/main/MainScene"
	-- require "script/ui/formation/FormationLayer"
	_shouldStopFashionLayerBgm = false
	bgLayer:removeFromParentAndCleanup(true)
	bgLayer=nil

	require "script/ui/fashion/FashionLayer"
	local mark = FashionLayer.getMark()
	local fashionLayer = FashionLayer:createFashion()
	MainScene.changeLayer(fashionLayer, "FashionLayer")
	FashionLayer.setMark(mark)
	
	-- local formationLayer = FormationLayer.createLayer(curHID, false)
	-- MainScene.changeLayer(formationLayer, "formationLayer")
end


function createFashionTableView( ... )
	local cellBg = CCSprite:create("images/bag/equip/equip_cellbg.png")
	cellSize = cellBg:getContentSize()			--计算cell大小

    local myScale = bgLayer:getContentSize().width/cellBg:getContentSize().width/bgLayer:getElementScale()
	--信息
	local equipDatas = {}
	local bagInfo = DataCache.getBagInfo()
	print("the baginfo is ")
	print_t(bagInfo)
	if(bagInfo and bagInfo.dress) then
		for k, itemInfo in pairs(bagInfo.dress) do
			-- if(itemInfo.itemDesc.type == curEquioPos) then
			table.insert(equipDatas, itemInfo)
			-- end
		end
	end
	print("the equipDatas is")
	print_t(equipDatas)
	

	require "script/ui/bag/FashionCell"
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
				a2 = FashionCell.createFashionCell(equipDatas[a1+1],false, nil,false,false)
				 
				-- if(_isTreasType)then
				-- 	a2 = FashionCell.createEquipCell(equipDatas[a1+1], refreshMyTableView)
				-- else
				-- 	a2 = EquipCell.createEquipCell(equipDatas[a1+1], refreshMyTableView)
				-- end
                a2:setScale(myScale)
    --             local testLabel = CCLabelTTF:create("Test_" .. (a1+1), g_sFontName, 25)
	   --          testLabel:setColor(ccc3(0,0,0))
				-- a2:addChild(testLabel, 1, 123)
				-- 不得已而为之
				-- 装备按钮Bar
				local cellMenuBar = CCMenu:create()
				cellMenuBar:setPosition(ccp(0,0))
				cellMenuBar:setTouchPriority(-1000)
				a2:addChild(cellMenuBar, 1, 8001)

				-- 装备按钮
				local equipBtn = CCMenuItemImage:create("images/formation/changeequip/btn_equip_n.png",  "images/formation/changeequip/btn_equip_h.png")
				-- LuaMenuItem.createItemImage("images/formation/changeequip/btn_equip_n.png",  "images/formation/changeequip/btn_equip_h.png", nil)
				equipBtn:setAnchorPoint(ccp(0.5, 0.5))
				equipBtn:setPosition(ccp(cellSize.width*0.85, cellSize.height*0.5))
				equipBtn:registerScriptTapHandler(changeFashionAction)
				cellMenuBar:addChild(equipBtn, a1+2000,2000+a1)
				equipBtn:setTag(equipDatas[a1+1].item_id)

				-- if(#equipDatas == a1+1)then
				-- 	_firstEquipBtn = equipBtn
				-- end
			r = a2
		elseif fn == "numberOfCells" then
			
			r = #equipDatas
		-- elseif fn == "cellTouched" then
		-- 	print("cellTouched: " .. (a1:getIdx()))
		-- elseif (fn == "scroll") then
			
		end
		return r
	end)
	local myTableView = LuaTableView:createWithHandler(h, CCSizeMake(bgLayer:getContentSize().width/bgLayer:getElementScale(),bgLayer:getContentSize().height*(0.87)/bgLayer:getElementScale()))
    myTableView:setAnchorPoint(ccp(0,0))
	myTableView:setBounceable(true)
	-- myTableView:setPosition(ccp(0, bgLayer:getContentSize().height*g_fScaleX))
	myTableView:setPosition(ccp(0, 0))

	-- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	myTableView:setTouchPriority(-170)
	bgLayer:addChild(myTableView)
end 


function changeFashionAction(tag, sender)
	print("the tag is ",tag)
	require "script/ui/fashion/FashionData"
	require "script/ui/fashion/FashionNet"
	FashionNet.dressFashion(function ( ... )
		local equipDatas = {}
		local bagInfo = DataCache.getBagInfo()
		if(bagInfo and bagInfo.dress) then
			for k, itemInfo in pairs(bagInfo.dress) do
				local itemId = tonumber(itemInfo.item_id)
				if(itemId == tag) then
				--添加数据
					-- local dresstabel = {}
					-- dresstabel["1"] = {}
					-- dresstabel["1"].item_id = tag
					-- dresstabel["1"].item_template_id = itemInfo.item_template_id
					DressRoomCache.setCurDress(itemInfo.item_template_id)
					HeroModel.getNecessaryHero().equip.dress["1"] = itemInfo
					
				-- 刷新时装属性缓存
				require "script/model/affix/DressAffixModel"
				DressAffixModel.getAffixByHid(HeroModel.getNecessaryHero().hid, true)
				DressAffixModel.getUnLockAffix(true)
				--删除数据,不用写s
					_shouldStopFashionLayerBgm = false
					require "script/ui/fashion/FashionLayer"
					local mark = FashionLayer.getMark()
					local fashionLayer = FashionLayer:createFashion()
					MainScene.changeLayer(fashionLayer, "FashionLayer")	
					FashionLayer.setMark(mark)
					FashionLayer.addPro(itemInfo.item_template_id,false,itemInfo.item_id)
				end
			end
		end
	end, tag)
end


function onNodeEvent(event)
    if event == "enter" then
    elseif event == "exit" then
        if _shouldStopFashionLayerBgm == true then
            FashionLayer.stopBgm()
        end
        _shouldStopFashionLayerBgm = true
    end
end


