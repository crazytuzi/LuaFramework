-- Filename：	MysteryMerchantCell.lua
-- Author：		bzx
-- Date：		2014-04-10
-- Purpose：		神秘商人的cell

module("MysteryMerchantCell", package.seeall)

require "script/ui/rechargeActive/ActiveUtil"
require "script/ui/rechargeActive/ActiveCache"
require "script/libs/LuaCC"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicUI"
require "script/ui/item/ItemUtil"


local _curItemTable

-- 购买商品的网络回调函数 
local function buyGoodsCallBack( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok") then
		return 
	end

	local itemInfo = ActiveUtil.getItemInfo(tonumber(_curItemTable.type), tonumber(_curItemTable.tid))
	local itemName = itemInfo.name 

	if(_curItemTable.costType == 1) then
		UserModel.addJewelNum(-_curItemTable.costNum)
		-- AnimationTip.showTip(GetLocalizeStringBy("key_2574") .. itemName)
		ActiveUtil.showItemGift(_curItemTable)
	elseif(_curItemTable.costType == 2) then
		UserModel.addGoldNumber(-_curItemTable.costNum)
		-- AnimationTip.showTip(GetLocalizeStringBy("key_1128") .. itemName)
		ActiveUtil.showItemGift(_curItemTable)
    elseif _curItemTable.costType == 3 then
        UserModel.addSilverNumber(-_curItemTable.costNum)
        ActiveUtil.showItemGift(_curItemTable)
    end
	-- AnimationTip.showTip(GetLocalizeStringBy("key_1948"))

	require "script/ui/rechargeActive/MysteryMerchantLayer"
	ActiveCache.MysteryMerchant:changeCanBuyNumByid(_curItemTable.id, -1 )
    MysteryMerchantLayer.recordOffset()
    MysteryMerchantLayer.refreshUI()
    MysteryMerchantLayer.setOffset()
end


local function buyAction( tag, item )

	local id = tonumber(tag)
	local itemsTable = ActiveCache.MysteryMerchant:getItemTable()
	-- local itemInfo 
	for i=1 ,#itemsTable do
		if(id == itemsTable[i].id ) then
			_curItemTable = itemsTable[i]
			break
		end
	end
	print("cur buy is ;")
	print_t(_curItemTable)

	if( _curItemTable.type == 1 and ItemUtil.isBagFull() == true )then
		--AnimationTip.showTip(GetLocalizeStringBy("key_2094")) 
		return
	end

	if(_curItemTable.type == 2 or _curItemTable.type == 3) and  HeroPublicUI.showHeroIsLimitedUI()then
		return
	end
	--花费 1：花费类型为魂玉 , 2：花费类型为金币 3:花费类型为银币
	if(_curItemTable.costType == 1 and UserModel.getJewelNum() < _curItemTable.costNum ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1131"))
		return
	end
	if(_curItemTable.costType == 2 and UserModel.getGoldNumber() < _curItemTable.costNum ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
		return
	end

    if _curItemTable.costType == 3 and UserModel.getSilverNumber() < _curItemTable.costNum then
        AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        return
    end
    local buy = function(p_confirmed, arg)
        if p_confirmed == true then
            local args = CCArray:create()
            args:addObject(CCInteger:create(_curItemTable.id))
            Network.rpc(buyGoodsCallBack, "mysmerchant.buyGoods" , "mysmerchant.buyGoods", args , true)
        end
    end
    if _curItemTable.costType == 2 then
        local itemInfo = ActiveUtil.getItemInfo(tonumber(_curItemTable.type), tonumber(_curItemTable.tid))
        local richInfo =
        {
            width = 460,
            alignment = 2,
            labelDefaultFont = g_sFontName,
            labelDefaultColor = ccc3(0x78, 0x25, 0x00),
            labelDefaultSize = 25,
            elements =
            {
                {
                    type = "CCLabelTTF",
                    text = string.format(GetLocalizeStringBy("key_8307"), _curItemTable.costNum),
                },
                {
                    type = "CCSprite",
                    image = "images/common/gold.png"
                },
                {
                    type = "CCLabelTTF", 
                    text = GetLocalizeStringBy("key_8308"),
                },
                {
                    type = "CCRenderLabel",
                    text = itemInfo.name,
                    font = g_sFontPangWa,
                    color = HeroPublicLua.getCCColorByStarLevel(itemInfo.quality),
                    renderType = type_stroke
                },
                {
                    type = "CCLabelTTF", 
                    text = GetLocalizeStringBy("key_8309"),
                },
            }
        }
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(richInfo, buy, true, nil, GetLocalizeStringBy("key_2864"))
    else
        buy(true)
    end
end



function createCell(cellValues)
    print_t(cellValues)
	local tCell = CCTableViewCell:create()

	local cellBg = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBg:setContentSize(CCSizeMake(462,140))
	tCell:addChild(cellBg)

	-- 白底
	local itemBg= CCScale9Sprite:create("images/reward/item_back.png")
	itemBg:setContentSize(CCSizeMake(290,100))
	itemBg:setPosition(19,21)
	cellBg:addChild(itemBg)

	-- 物品图标
	-- print("cellValues  type is : ", cellValues.type, "  cellValues.tid is : ", cellValues.tid)
	-- print_t(cellValues)
	local isHot = cellValues.isHot == 1
	local itemSprite= ActiveUtil.getItemIcon(tonumber(cellValues.type), tonumber(cellValues.tid), nil, isHot)
	itemSprite:setPosition(ccp(12, itemBg:getContentSize().height/2))
	itemSprite:setAnchorPoint(ccp(0,0.5))
	itemBg:addChild(itemSprite)

	-- 数量
	local itemNumLabel = CCRenderLabel:create("" .. cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
	local width = itemSprite:getContentSize().width - itemNumLabel:getContentSize().width- 6
	itemNumLabel:setPosition(width, itemBg:getContentSize().height*0.3)
	itemNumLabel:setColor(ccc3(0x00,0xff,0x18))
	itemSprite:addChild(itemNumLabel)
	if(tonumber(cellValues.num)==1 ) then
		itemNumLabel:setVisible(false)
	end

	-- 显示名字
	local itemInfo = ActiveUtil.getItemInfo(tonumber(cellValues.type), tonumber(cellValues.tid))
	local corlor =  HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
	local itemName=CCRenderLabel:create(itemInfo.name , g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	itemName:setAnchorPoint(ccp(0,0))
	itemName:setPosition(110,62)
	itemName:setColor(corlor)
	itemBg:addChild(itemName)

	--显示花费  1：花费类型为魂玉 , 2：花费类型为金币
	local content= {
			{note= GetLocalizeStringBy("key_1805"), img_path = "images/common/soul_jade.png", buyNote = GetLocalizeStringBy("key_2689"), buyNumTxt = GetLocalizeStringBy("key_2696")},
			{note= GetLocalizeStringBy("key_3059"), img_path = "images/common/gold.png", buyNote = GetLocalizeStringBy("key_1523"), buyNumTxt = GetLocalizeStringBy("key_2235")},
            {note= GetLocalizeStringBy("key_2650"), img_path = "images/common/coin.png", buyNote = GetLocalizeStringBy("key_1523"), buyNumTxt = GetLocalizeStringBy("key_2235")}
	}

	local costType = tonumber(cellValues.costType)
	local alertContent= {}
	alertContent[1]= CCRenderLabel:create(content[costType].note, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	alertContent[1]:setColor(ccc3(0xfe,0xdb,0x1c))
	alertContent[2]= CCSprite:create(content[costType].img_path)
	alertContent[3]= CCRenderLabel:create("" .. cellValues.costNum, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	alertContent[3]:setColor(ccc3(0xfe,0xdb,0x1c))

	local alertNode= BaseUI.createHorizontalNode(alertContent)
	alertNode:setPosition(116,16)
	itemBg:addChild(alertNode)

	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	cellBg:addChild(menu)

	local buyItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64), content[costType].buyNote ,ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	buyItem:setPosition(324,52)
	menu:addChild(buyItem,1, cellValues.id )
	buyItem:registerScriptTapHandler(buyAction)

	local buyNumLabel = CCLabelTTF:create(content[costType].buyNumTxt.. cellValues.canBuyNum ,g_sFontName,23)
	buyNumLabel:setColor(ccc3(0x78,0x25,0x00))
	buyNumLabel:setPosition(310,33)
	cellBg:addChild(buyNumLabel)

	local disableSp = BTGraySprite:create("images/common/btn/btn_blue_n.png")
	disableSp:setPosition(324,52)
	disableSp:setVisible(false)
	local disableLabel = CCRenderLabel:create(content[costType].buyNote,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	disableLabel:setColor(ccc3(0xab,0xab,0xab))
	disableLabel:setPosition(ccp(disableSp:getContentSize().width/2, disableSp:getContentSize().height/2))
	disableLabel:setAnchorPoint(ccp(0.5,0.5))
	disableSp:addChild(disableLabel)
	cellBg:addChild(disableSp)

	if(cellValues.canBuyNum == 0) then
		buyItem:setVisible(false)
		disableSp:setVisible(true)

	end


	return tCell
end
