require"Lang"
---连续战斗结算
UILootClearing={}
local scrollView ={}
local Item = nil
UILootClearing.param = nil

local function setScrollViewItem(_Item,_obj)
      local ui_text_ceng = ccui.Helper:seekNodeByName(_Item, "text_ceng")
      local InstPlayerNowLevel = net.InstPlayer.int["4"]
      local ui_text_money = ccui.Helper:seekNodeByName(_Item, "text_silver_number")
      local thingItem = ccui.Helper:seekNodeByName(_Item, "image_frame_good")
      local _dlpData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
	  ui_text_money:setString("×" .. _dlpData.duelFleetCopper)
      local thingIds = utils.stringSplit(_obj, ":")
      local fightTime = thingIds[1]
      ui_text_ceng:setString(Lang.ui_loot_clearing1 .. fightTime .. Lang.ui_loot_clearing2)
      local dropIds = nil
      if thingIds[2] then 
        local _goodsDetail = utils.getItemProp(thingIds[2])
        thingItem:getChildByName("image_good"):loadTexture(_goodsDetail.smallIcon)
        thingItem:getChildByName("image_good"):getChildByName("text_name"):setString(_goodsDetail.name)
        thingItem:getChildByName("image_base_number"):getChildByName("text_number"):setString(tostring(_goodsDetail.count))
      end 
end

function UILootClearing.init()
    local btn_sure = ccui.Helper:seekNodeByName(UILootClearing.Widget, "btn_sure")
    local function TouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_sure then 
                UIManager.popScene()
                if UILootClearing.param[2].int["1"] == 1  then
                    UILoot.isFlush = true
					UIManager.showScreen("ui_notice", "ui_loot",  "ui_menu")
				else
                    UIManager.flushWidget(UILootChoose)
				end
            end
        end
    end
    btn_sure:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UILootClearing.Widget, "view_get_good")
    Item = scrollView:getChildByName("panel_good"):clone()
end

function UILootClearing.setup()
    local param = UILootClearing.param
    if Item:getReferenceCount() == 1 then 
        Item:retain()
    end
    scrollView:removeAllChildren()
    local ui_fightName = ccui.Helper:seekNodeByName(UILootClearing.Widget, "text_fight_name")
    if param[2] then 
        if param[2].int["1"] == 0 then
            ui_fightName:setString(Lang.ui_loot_clearing3)
        else
            local fightName = DictChip[tostring(param[1])].name
            ui_fightName:setString(Lang.ui_loot_clearing4..fightName)
        end
        local dropThings = utils.stringSplit(param[2].string["2"], "|")
        for key, obj in pairs(dropThings) do
            local scrollViewItem = Item:clone()
            scrollView:addChild(scrollViewItem)
            setScrollViewItem(scrollViewItem, obj)
        end
        scrollView:jumpToTop()
        local innerHieght, space = 0, 25
        local childs = scrollView:getChildren()
        innerHieght = (Item:getContentSize().height + space) * #childs
        
        if innerHieght < scrollView:getContentSize().height then
            innerHieght = scrollView:getContentSize().height
        end
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHieght))
        local x,y = 0,0
        for i=1,#childs do
                y= innerHieght - Item:getContentSize().height -space -(i-1)*(Item:getContentSize().height+space)
                childs[i]:setPosition(cc.p(x,y))
        end 
    end
end

function UILootClearing.setParam(_param)
    UILootClearing.param = _param
end

function UILootClearing.free()
  if Item and Item:getReferenceCount() >= 1 then 
      Item:release()
      Item = nil
  end
  if scrollView then
    scrollView:removeAllChildren()
    scrollView = nil
  end
end
