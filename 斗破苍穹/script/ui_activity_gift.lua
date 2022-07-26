require"Lang"
UIActivityGift ={}

local function chargeCallBack(pack)
	if pack.header == StaticMsgRule.getFirstRechargeGift then 
		UIManager.flushWidget(UIActivityGift)
        UIActivityPanel.addImageHint(false)
	end
end

local function getFirstRechargeGift()
	UIManager.showLoading()
	local data   = { 
			header  = StaticMsgRule.getFirstRechargeGift,
	}
	netSendPackage(data,chargeCallBack)
end

function UIActivityGift.checkImageHint()
    local result = false
    if dp.rechargeGold == 0 then
        result = false
    else
        result = true
    end
    return result
end

function UIActivityGift.init()
	local btn_bath = ccui.Helper:seekNodeByName(UIActivityGift.Widget, "btn_bath")
	local function TouchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			if dp.rechargeGold == 0 then --前往充值
				utils.checkGOLD(1)
			else                         -- 领取
				getFirstRechargeGift()
			end
		end
	end
	btn_bath:setPressedActionEnabled(true)
	btn_bath:addTouchEventListener(TouchEvent)
end

local function setScrollViewItem(item, _reward)
	local itemIcon = item:getChildByName("image_good")
	local itemName = item:getChildByName("text_number")
	local itemNums = item:getChildByName("image_base_number"):getChildByName("text_number")
	local data = utils.stringSplit(_reward, "_") --[1]:TableTypeId [2]:FieldId [3]:Nums
	local name,icon =utils.getDropThing(data[1],data[2])
    local tableTypeId, tableFieldId, value = data[1],data[2],data[3]
    if not name then 
    	return 
    end
    itemIcon:loadTexture(icon)
    itemName:setString(name)
    itemNums:setString("× " .. value)
    utils.addBorderImage(tableTypeId,tableFieldId,item)
    utils.showThingsInfo(itemIcon,tableTypeId,tableFieldId)
    local itemProps = utils.getItemProp(tonumber(tableTypeId), tonumber(tableFieldId))
    if itemProps.qualityColor then
        itemName:setTextColor(itemProps.qualityColor)
        itemName:enableOutline(cc.c4b(255, 255, 255, 255), 2)
    end
end

function UIActivityGift.setup()
	local btn_bath = ccui.Helper:seekNodeByName(UIActivityGift.Widget, "btn_bath")
	local isGetFirstRechargeGift = net.InstPlayer.int["35"]
    if isGetFirstRechargeGift == 0 then 
    	utils.GrayWidget(btn_bath,false)
    	btn_bath:setTouchEnabled(true)
		if dp.rechargeGold == 0 then 
			btn_bath:setTitleText(Lang.ui_activity_gift1)
		else 
			btn_bath:setTitleText(Lang.ui_activity_gift2)
		end
    else 
    	btn_bath:setTouchEnabled(false)
    	btn_bath:setTitleText(Lang.ui_activity_gift3)
    	utils.GrayWidget(btn_bath,true)
    end
	local giftValue = DictSysConfigStr[tostring(StaticSysConfig_Str.firstRechargeGift)].value
	local giftThingTable = utils.stringSplit(giftValue,";")
	local ItemTable = {}
	for i= 1,3 do 
		local Item = ccui.Helper:seekNodeByName(UIActivityGift.Widget, "image_frame_good" .. i)
		table.insert(ItemTable,Item)
	end
	if next(giftThingTable) then 
		for key, Item in pairs(ItemTable) do
			if 	giftThingTable[key] then 
				setScrollViewItem(Item, giftThingTable[key])
			end		
		end
	end
end
