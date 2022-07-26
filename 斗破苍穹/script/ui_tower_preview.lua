UITowerPreview = {}

local scrollView = nil
local sv_item = nil

local function setScrollViewItem(svItem, data)
	local _storeyNum = ccui.Helper:seekNodeByName(svItem, "text_lv_number")
	local _itemPanel = svItem:getChildByName("image_base_good")
	local _item = _itemPanel:getChildByName("image_frame_good")
	_storeyNum:setString(tostring(data.pagodaStorey5))
	local space = 10
	local rewards = utils.stringSplit(data.reward, ";")
	for key, obj in pairs(rewards) do
		local item = nil
		if key == 1 then
			item = _item
		else
			item = _item:clone()
			item:setPositionX(item:getPositionX() + ((key - 1)* (item:getContentSize().width + space)))
			_itemPanel:addChild(item)
		end
		local itemIcon = item:getChildByName("image_good")
		local itemName = item:getChildByName("text_name")
		local itemNums = ccui.Helper:seekNodeByName(item, "text_number")

		local data = utils.stringSplit(obj, "_") --[1]:TableTypeId [2]:FieldId [3]:Nums
		local name,icon = utils.getDropThing(data[1],data[2])
		local tableTypeId, tableFieldId, value = data[1],data[2],data[3]
		itemName:setString(name)
		itemIcon:loadTexture(icon)
		itemNums:setString(tostring(value))
		utils.addBorderImage(tableTypeId,tableFieldId,item)
	end
end

function UITowerPreview.init()
	local btn_close = ccui.Helper:seekNodeByName(UITowerPreview.Widget, "btn_close")
	btn_close:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			UIManager.popScene()
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	scrollView = ccui.Helper:seekNodeByName(UITowerPreview.Widget, "view_award_lv")
	sv_item = scrollView:getChildByName("image_base_gift"):clone()
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
end

function UITowerPreview.setup()
	scrollView:removeAllChildren()
	
	local innerHieght, space = 0, 10
	local data = {}
	for key, obj in pairs(DictPagodaFormation) do
		data[#data + 1] = obj
	end
	utils.quickSort(data, function(obj1, obj2) if obj1.id > obj2.id then return true end return false end)
	for key, obj in pairs(data) do
		local scrollViewItem = sv_item:clone()
		setScrollViewItem(scrollViewItem, obj)
		scrollView:addChild(scrollViewItem)
		innerHieght = innerHieght + scrollViewItem:getContentSize().height + space
	end
	
	innerHieght = innerHieght + space
	if innerHieght < scrollView:getContentSize().height then
		innerHieght = scrollView:getContentSize().height
	end
	scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHieght))
	local childs = scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space))
		else
			childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - space))
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(scrollView)
end

function UITowerPreview.free()
	if sv_item and sv_item:getReferenceCount() >= 1 then
		sv_item:release()
		sv_item = nil
	end
	scrollView:removeAllChildren()
end