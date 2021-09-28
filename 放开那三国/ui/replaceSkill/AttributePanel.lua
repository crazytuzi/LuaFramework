-- Filename: AttributePanel.lua
-- Author: zhangqiang
-- Date: 2014-08-07
-- Purpose: 创建主角属性面板

module("AttributePanel", package.seeall)

local kPanelTouchPriority = -350
local kCloseMenuTouchPriority = -351
local kTableViewTouchPriority = -351
local _panelLayer = nil
local _tableView = nil
local _closeMenuItem = nil

--[[

--]]
function createPanel(p_tapCloseBtnCb)
	--更新要显示的数据
	ReplaceSkillData.updateAttrPanelDataSrc()

	--一级背景
	local attributePanelBg = CCScale9Sprite:create("images/common/bg/attr_bg.png", CCRectMake(0,0,75,75), 
		                                      CCRectMake(30,30,15,15))
	attributePanelBg:setPreferredSize(CCSizeMake(246,332))

	--收起按钮
	local closeMenu = CCMenu:create()
	closeMenu:setTouchPriority(kCloseMenuTouchPriority)
	closeMenu:setPosition(6,attributePanelBg:getContentSize().height/2)
	attributePanelBg:addChild(closeMenu)

	_closeMenuItem = CCMenuItemImage:create("images/star/btn_hidden_n.png","images/star/btn_hidden_h.png")
	_closeMenuItem:setAnchorPoint(ccp(1,0.5))
	_closeMenuItem:setPosition(0,0)
	closeMenu:addChild(_closeMenuItem)
	_closeMenuItem:registerScriptTapHandler(p_tapCloseBtnCb)
	_closeMenuItem:setEnabled(false)

	--二级背景
	local tableViewBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	tableViewBg:setPreferredSize(CCSizeMake(236, 290))
	tableViewBg:setAnchorPoint(ccp(0.5,0))
	tableViewBg:setPosition(123,5)
	attributePanelBg:addChild(tableViewBg)

	--属性表
	print("_tableView")
	print_t(ReplaceSkillData._attrPanelDataSrc)
	_tableView = CreateUI.createTableView(0,CCSizeMake(230,284), CCSizeMake(230,40), 
		                                  #ReplaceSkillData._attrPanelDataSrc, createCell)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(tableViewBg:getContentSize().width*0.5,tableViewBg:getContentSize().height*0.5)
	_tableView:setTouchPriority(kTableViewTouchPriority)
	tableViewBg:addChild(_tableView)

	_panelLayer = CCLayer:create()
	_panelLayer:setContentSize(CCSizeMake(attributePanelBg:getContentSize().width
		                                         +_closeMenuItem:getContentSize().width-6,
                                                 attributePanelBg:getContentSize().height))

	attributePanelBg:setAnchorPoint(ccp(1,0))
	attributePanelBg:setPosition(_panelLayer:getContentSize().width,0)
	_panelLayer:addChild(attributePanelBg)
	_panelLayer:ignoreAnchorPointForPosition(false)
	_panelLayer:registerScriptHandler(onNodeEvent)

	return _panelLayer

end

--[[

--]]
function setCloseBtnEnabled( p_enabledBool )
	_closeMenuItem:setEnabled(p_enabledBool)
end

--[[

--]]
require "script/ui/replaceSkill/ReplaceSkillData"
function createCell(p_cellIndex)
	local cell = CCTableViewCell:create()
	local cellData = ReplaceSkillData._attrPanelDataSrc[p_cellIndex]

	local cellBg = nil
	if p_cellIndex%2 == 0 then
		cellBg = CCSprite:create()
	else
		cellBg = CCScale9Sprite:create("images/star/intimate/item9s.png")
	end
	cellBg:setContentSize(CCSizeMake(230,40))
	cellBg:setAnchorPoint(ccp(0,0))
	cellBg:setPosition(0,0)
	cell:addChild(cellBg)

	--图标
	local feelSprite = nil
	local labelColorTable = nil
	if tonumber(ReplaceSkillData.getCurMasterInfo().feel_level) < cellData.needFeelLevel 
		or tonumber(UserModel.getAvatarLevel()) < cellData.needUserLevel then
		feelSprite = BTGraySprite:create("images/replaceskill/awaken_icon.png")
		labelColorTable = {ccc3(0x3c, 0x3c, 0x3c),ccc3(0x3c, 0x3c, 0x3c),ccc3(0x3c, 0x3c, 0x3c)}
	else
		feelSprite = CCSprite:create("images/replaceskill/awaken_icon.png")
		labelColorTable = {ccc3(0x00,0x6d,0x2f),ccc3(0x78,0x25,0x00),ccc3(0x00,0x6d,0x2f)}
	end
	feelSprite:setAnchorPoint(ccp(0,0))
	feelSprite:setPosition(40,4)
	cellBg:addChild(feelSprite)

	--label
	local labelStrTable = {tostring(cellData.needFeelLevel), cellData.ability.name,
	                       "+" .. cellData.ability.addNum,}
	local labelPositionTable = {ccp(40,8),ccp(70,8),ccp(150,8)}
	local labelAnchorPointTable = {ccp(1,0),ccp(0,0),ccp(0,0)}
	for i = 1,3 do
		local feelDesc = CCLabelTTF:create(labelStrTable[i], g_sFontName, 21)
		feelDesc:setColor(labelColorTable[i])
		feelDesc:setAnchorPoint(labelAnchorPointTable[i])
		feelDesc:setPosition(labelPositionTable[i])
		cellBg:addChild(feelDesc,1)
	end

	return cell
end

--[[

--]]
function refreshTableView()
	--ReplaceSkillData.updateAttrPanelDataSrc()
	if _tableView ~= nil then
		_tableView:reloadData()
	end
end

--[[

--]]
function onNodeEvent(p_eventType)
	if p_eventType == "enter" then
		_panelLayer:registerScriptTouchHandler(touchPanelCb,false,kPanelTouchPriority,true)
		_panelLayer:setTouchEnabled(true)
	else
		--p_eventType == "exit"
		_panelLayer:unregisterScriptTouchHandler()
	end
end

--[[

--]]
function touchPanelCb( p_eventType, p_touchX, p_touchY )
	if p_eventType == "began" then
		local beginPoint = ccp(p_touchX, p_touchY)
		if _panelLayer ~= nil then
	    	local panelBeginPoint = _panelLayer:convertToNodeSpace(beginPoint)
	    	local panelContentSize = _panelLayer:getContentSize()
	    	if panelBeginPoint.x >= 0 and panelBeginPoint.x <= panelContentSize.width and
	    		panelBeginPoint.y >= 0 and panelBeginPoint.y <= panelContentSize.height then
	    		return true
	    	end
	    end
	end
end