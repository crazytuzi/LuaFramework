--[[
 --
 -- add by vicky
 -- 2014.11.01
 --
 --]]

 local ChongzhiItem = class("ChongzhiItem", function() 
 	return CCTableViewCell:new()  
 end)


 function ChongzhiItem:getContentSize()
 	if self._cntSize == nil then 
 		local proxy = CCBProxy:create()
	 	local rootnode = {}
	 	local node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_item.ccbi", proxy, rootnode) 
	 	self._cntSize = node:getContentSize() 
 	end 

 	return self._cntSize 
 end 


 function ChongzhiItem:getIcon(index) 
    return self._rootnode["icon_" ..tostring(index)]
 end 


 function ChongzhiItem:create(param) 
 	-- dump(param) 
 	self._itemData = param.itemData 
 	local viewSize = param.viewSize 

 	local proxy = CCBProxy:create()
 	self._rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_item.ccbi", proxy, self._rootnode) 

 	local cntSize = node:getContentSize() 
 	node:setPosition(viewSize.width/2, cntSize.height/2) 
	self:addChild(node) 

	self:refresh(self._itemData) 

	return self 
 end 


 function ChongzhiItem:refresh(itemData) 
 	self._itemData = itemData 

 	for i = #self._itemData + 1, 3 do 
		self._rootnode["tag_" .. i ]:setVisible(false) 
	end 
 
 	for i, v in ipairs(self._itemData) do 
		self:refreshItem(v, i)
	end 
 end 


 function ChongzhiItem:refreshItem(data, i) 
	self._rootnode["tag_" .. i]:setVisible(true) 
 	self._rootnode["icon_" .. i]:setDisplayFrame(display.newSprite(data.iconImgName):getDisplayFrame()) 

	self._rootnode["price_lbl_" .. i]:setString("￥" .. data.price) 
	self._rootnode["gold_lbl_" .. i]:setString(tostring(data.basegold)) 

	local arrangeNode 
	if data.buyCnt > 0 or not data.isShowMark then 
		self._rootnode["gift_icon_" .. i]:setVisible(false)
		self._rootnode["gold_x3_" .. i]:setVisible(false)  
		self._rootnode["gold_give_icon_" .. i]:setVisible(true) 
		self._rootnode["gold_give_lbl_" .. i]:setString(tostring(data.chixugold)) 
		if data.chixugold > 999 then 
			self._rootnode["gold_icon_" .. i]:setPositionX(-self._rootnode["gold_icon_" .. i]:getContentSize().width/2)
		else
			self._rootnode["gold_icon_" .. i]:setPositionX(0)
		end 

		arrangeNode = self._rootnode["gold_give_icon_" .. i]
	else 
		self._rootnode["gift_icon_" .. i]:setVisible(true) 
		self._rootnode["gold_icon_" .. i]:setPositionX(0)
		self._rootnode["gold_x3_" .. i]:setVisible(true) 
		self._rootnode["gold_give_icon_" .. i]:setVisible(false) 
		arrangeNode = self._rootnode["gold_x3_" .. i] 
	end 

	arrangeTTFByPosX({
		self._rootnode["gold_lbl_" .. i], 
		arrangeNode 
		})
 end



 return ChongzhiItem 
