-- FileName: MissionItemCell.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: 悬赏榜物品捐献cell
--[[TODO List]]

module("MissionItemCell", package.seeall)

require "script/ui/common/CheckBoxItem"


local _cellIndex = nil
local _cellInfo  = nil

function init( ... )
	 _cellIndex = nil
	 _cellInfo  = nil
end

function create( pCellInfo, pCellIndex)
	init()
	_cellInfo = pCellInfo
	_cellIndex = pCellIndex
	local tCell = CCTableViewCell:create()
	-- 背景
	local cellBg = CCSprite:create("images/bag/item/item_cellbg.png")
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg,1,1)
	cellBg:setScale(0.88)
	local cellBgSize = cellBg:getContentSize()
	-- icon
	local iconSprite = ItemSprite.getItemSpriteById( tonumber(pCellInfo.item_template_id), tonumber(pCellInfo.item_id), iconFuncDelegate )
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)
	-- 数量
	local numberLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1147") .. pCellInfo.item_num , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    numberLabel:setPosition(ccp( ( cellBgSize.width*0.2 - numberLabel:getContentSize().width)/2, cellBgSize.height*0.26))
    cellBg:addChild(numberLabel)
    -- 印章
    local sealSprite = BagUtil.getSealSpriteByItemTempId(pCellInfo.item_template_id)
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(pCellInfo.itemDesc.quality)
	local nameLabel = CCRenderLabel:create(pCellInfo.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0, 0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2+sealSprite:getContentSize().width+5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)
	-- 捐献数量
    local itemNumDesc= GetLocalizeStringBy("lcyx_1935", pCellInfo.selectNum or 0)
	local numDescLabel = CCLabelTTF:create( itemNumDesc, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	numDescLabel:setColor(ccc3(0x78, 0x25, 0x00))
	numDescLabel:setAnchorPoint(ccp(0, 1))
	numDescLabel:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.65))
	cellBg:addChild(numDescLabel)
	-- 描述
    local itemFameDesc= GetLocalizeStringBy("lcyx_1936", pCellInfo.itemDesc.fame or 0)
	local fameDescLable = CCLabelTTF:create( itemFameDesc, g_sFontName, 23, CCSizeMake(300, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	fameDescLable:setColor(ccc3(0x78, 0x25, 0x00))
	fameDescLable:setAnchorPoint(ccp(0, 1))
	fameDescLable:setPosition(ccp(cellBgSize.width*0.21, cellBgSize.height*0.40))
	cellBg:addChild(fameDescLable)

	--选择数量回调
	local checkBoxButtonCallback = function( pTag, pSender)
		local item = tolua.cast(pSender, "CCMenuItemToggle")
		if item:getSelectedIndex() == 0 then
			--取消选择
			numDescLabel:setString(GetLocalizeStringBy("lcyx_1935", 0))
			pCellInfo.selectNum = nil
			--刷新总名望
			MissionItemDialog.updateFameLabel()
			return
		end
		--1.捐献数量不能超过上限
		local donateMax = MissionItemData.getMaxDonateNum() 
	    local limitNum = tonumber(pCellInfo.item_num) < donateMax and tonumber(pCellInfo.item_num) or  donateMax
	    if limitNum <= 0 then
	    	item:setSelectedIndex(0)
	    	AnimationTip.showTip(GetLocalizeStringBy("lcyx_1966"))
			return
	    end
		--2.拥有物品数量为1时不弹数量选择框
		if tonumber(pCellInfo.item_num) == 1 then
			--刷新cell显示
			local selectNum = 1
			numDescLabel:setString(GetLocalizeStringBy("lcyx_1935", tostring(selectNum)))
			pCellInfo.selectNum = selectNum
			--刷新总名望
			MissionItemDialog.updateFameLabel()
			return
		end
	    --2.选择捐献数量
	    require "script/utils/BigNumberSelectDialog"
	    local dialog = BigNumberSelectDialog:create()
	    dialog:setTitle(GetLocalizeStringBy("key_2051"))
	    dialog:setLimitNum(limitNum)
	    dialog:show(-812, 1000)

	    local contentMsgInfo = {}
		contentMsgInfo.labelDefaultColor = ccc3(0xff, 0xf6, 0x00)
		contentMsgInfo.labelDefaultSize = 25
		contentMsgInfo.defaultType = "CCRenderLabel"
		contentMsgInfo.lineAlignment = 1
		contentMsgInfo.labelDefaultFont = g_sFontName
		contentMsgInfo.elements = {
		    {
		        text = pCellInfo.itemDesc.name,
		        color = itemColor,
		        font = g_sFontPangWa,
		        size = 30,
		    }
		}
		contentMsgNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lcyx_1937"), contentMsgInfo)
		contentMsgNode:setAnchorPoint(ccp(0.5,0.5))
		contentMsgNode:setPosition(ccpsprite(0.5, 0.8, dialog))
		dialog:addChild(contentMsgNode)
		--争霸令
		local childNodes = {}
		childNodes[1] = CCRenderLabel:create(GetLocalizeStringBy("lcyx_1939"),g_sFontName, 25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		childNodes[1]:setColor(ccc3(0xff, 0xff, 0xff))
		childNodes[2] = CCRenderLabel:create(tostring(pCellInfo.item_num),g_sFontName, 25, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
		childNodes[2]:setColor(ccc3(0xff, 0xff, 0xff))
		contentCostNode = BaseUI.createHorizontalNode(childNodes)
		contentCostNode:setAnchorPoint(ccp(0.5,0))
		contentCostNode:setPosition(ccpsprite(0.5, 0.2, dialog))
		dialog:addChild(contentCostNode)
		dialog:registerOkCallback(function ()
			--刷新cell显示
			local selectNum = dialog:getNum()
			numDescLabel:setString(GetLocalizeStringBy("lcyx_1935", tostring(selectNum)))
			pCellInfo.selectNum = selectNum
			--刷新总名望
			MissionItemDialog.updateFameLabel()
		end)
		dialog:registerCancelCallback(function ()
			if item:getSelectedIndex() == 0 then
				item:setSelectedIndex(1)
			else
				item:setSelectedIndex(0)
			end
		end)
	end

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-600)
    cellBg:addChild(menuBar)
	--选择框
	local checkBoxButton = CheckBoxItem.createToggleBox()
	checkBoxButton:setPosition(ccpsprite(0.85, 0.5, cellBg))
	checkBoxButton:registerScriptTapHandler(checkBoxButtonCallback)
	menuBar:addChild(checkBoxButton)
	checkBoxButton:setSelectedIndex(0)
	pCellInfo.selectNum = pCellInfo.selectNum or 0
	if pCellInfo.selectNum > 0 then
		numDescLabel:setString(GetLocalizeStringBy("lcyx_1935", tostring(pCellInfo.selectNum)))
		checkBoxButton:setSelectedIndex(1)
	end
	return tCell
end
