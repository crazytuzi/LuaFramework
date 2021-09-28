local TreasureComposeFragmentItem = class("TreasureComposeFragmentItem",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/treasure_TreasureComposeFragmentItem.json")
end)

require("app.cfg.treasure_fragment_info")
require("app.cfg.treasure_compose_info")

function TreasureComposeFragmentItem:ctor(_fragmentId,...)
    self._clickFunc = nil
    self._fragmentId = _fragmentId
	self._button = UIHelper:seekWidgetByName(self,"Button_fragmentItem")
	self._button = tolua.cast(self._button,"Button")
	self._btnName = "treasure_fragment_" .. self._fragmentId
	self._button:setTouchEnabled(true)
	self._button:setName(self._btnName)
	self._numLabel = UIHelper:seekWidgetByName(self,"Label_fragmentNum")
	self._numLabel = tolua.cast(self._numLabel,"Label")
	self._itemBg = UIHelper:seekWidgetByName(self,"Image_item_bg")
	self._itemBg = tolua.cast(self._itemBg,"ImageView")
	self:loadTextureAndNum()
end

function TreasureComposeFragmentItem:getButtonName()
	return self._btnName
end 

function TreasureComposeFragmentItem:getFragmentId()
	return self._fragmentId
end


--播放数字变化动画
function TreasureComposeFragmentItem:playNumChangeAnimation()
    local action01 = CCScaleTo:create(0.5,1.4)
    local action02 = CCScaleBy:create(0.5,1.4)
    local action03 = CCScaleTo:create(0.5,1)
    local arr = CCArray:create()
    arr:addObject(action01)
    arr:addObject(CCCallFunc:create(function (  )
    
    end))
    arr:addObject(action02)
    arr:addObject(action03)

    self._numLabel:runAction(CCSequence:create(arr))
end

function TreasureComposeFragmentItem:loadTextureAndNum(_fragmentId)
	local fragment = treasure_fragment_info.get(self._fragmentId)
	if not fragment then
		return
	end
	-- local fragmentImage = self:getImageViewByName("ImageView_fragmentItem")
	-- local fragmentImage = self:getChildByTag(140)
	local fragmentImage = UIHelper:seekWidgetByName(self,"ImageView_fragmentItem")
	fragmentImage = tolua.cast(fragmentImage,"ImageView")
	fragmentImage:setScale(1.2)

	local __fragment = G_Me.bagData.treasureFragmentList:getItemByKey(self._fragmentId)
	if __fragment == nil then
		-- numLabel:setVisible(false)
		fragmentImage:loadTexture(G_Path.getTreasureFragmentIcon(fragment.res_id),UI_TEX_TYPE_LOCAL)
		fragmentImage:showAsGray(true);
		self._itemBg:loadTexture(G_Path.getTreasureFragmentBack(fragment.quality))
		self._itemBg:showAsGray(true);
		self._numLabel:setText(0)
	else
		fragmentImage:loadTexture(G_Path.getTreasureFragmentIcon(fragment.res_id),UI_TEX_TYPE_LOCAL)
		self._numLabel:setText(__fragment["num"])
		fragmentImage:showAsGray(false);
		self._itemBg:loadTexture(G_Path.getTreasureFragmentBack(fragment.quality))
		self._itemBg:showAsGray(false);
		-- numLabel:setVisible(true)
	end
	
end


function TreasureComposeFragmentItem:setClickEvent(func)
	self._clickFunc = func 
end

function TreasureComposeFragmentItem:showNumLabel(isShow)
	local imageNum = UIHelper:seekWidgetByName(self,"ImageView_num")
	if imageNum then
		imageNum:setVisible(isShow)
	end
end

return TreasureComposeFragmentItem
