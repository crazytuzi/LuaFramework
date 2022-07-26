require"Lang"
UIFightGetAccident={}
local scrollView ={}
local Item = nil
local param = nil
local uiItem = nil 
local callFunc = nil

local function setScrollViewItem(item, data)
  local image_frame_chip = ccui.Helper:seekNodeByName(item, "image_frame_chip")
  local thingIcon = ccui.Helper:seekNodeByName(item, "image_chip")
  local thingName = ccui.Helper:seekNodeByName(item, "text_name_chip")
  local thingCount = ccui.Helper:seekNodeByName(item, "text_chip_number")
  local thingDescription = ccui.Helper:seekNodeByName(item, "text_chip_describe")
  local tableTypeId, tableFieldId, value = data.tableTypeId, data.tableFieldId, data.value
  local name,icon,description =utils.getDropThing(tableTypeId,tableFieldId)
  utils.addBorderImage(tableTypeId,tableFieldId,image_frame_chip)
  thingName:setString(name)
  thingIcon:loadTexture(icon)
  thingCount:setString(Lang.ui_fight_get_accident1 .. value)
  if description ~= nil  then 
    thingDescription:setString(description)
  end
end

function UIFightGetAccident.init()
    local btn_close = ccui.Helper:seekNodeByName(UIFightGetAccident.Widget, "btn_close")
    local btn_sure = ccui.Helper:seekNodeByName(UIFightGetAccident.Widget, "btn_sure")
    local function TouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.popScene()
            if callFunc then 
              callFunc()
              callFunc = nil
            end
        end
    end
    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(TouchEvent)
    btn_sure:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIFightGetAccident.Widget, "view_list")
    Item = scrollView:getChildByName("image_base_di"):clone()
end
function UIFightGetAccident.setup()
    UIFightGetAccident.Widget:setEnabled(true)
    local ui_text_preview = ccui.Helper:seekNodeByName(UIFightGetAccident.Widget, "text_preview")
    local ui_image_base_hint = ccui.Helper:seekNodeByName(UIFightGetAccident.Widget, "text_hint")
    if Item:getReferenceCount() == 1 then 
        Item:retain()
    end
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    if param then
      if uiItem == UIFightWin or uiItem == UIFightClearing then 
        ui_text_preview:setString(Lang.ui_fight_get_accident2)
        ui_image_base_hint:setVisible(true)
        local dropIds = utils.stringSplit(tostring(param), ";") --副本获得掉落字典表ID
        for key, id in pairs(dropIds) do
          local scrollViewItem = Item:clone()
          scrollView:addChild(scrollViewItem)
          setScrollViewItem(scrollViewItem, DictBarrierDrop[id])
        end
        
        local innerHieght, space = 0, 15
        local childs = scrollView:getChildren()
        local ItemHeight = Item:getContentSize().height
        innerHieght = (ItemHeight + space) * #childs
        
        if innerHieght < scrollView:getContentSize().height then
          innerHieght = scrollView:getContentSize().height
        end
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHieght))
        local x,y = scrollView:getContentSize().width/2,0
        for i=1,#childs do
             y= innerHieght - ItemHeight/2 -space/2 -(i-1)*(ItemHeight+space)
             childs[i]:setPosition(cc.p(x,y))
        end 
      else
        ui_text_preview:setString(Lang.ui_fight_get_accident3)
        ui_image_base_hint:setVisible(false)
        local scrollViewItem = Item:clone()
        scrollView:addChild(scrollViewItem)
        setScrollViewItem(scrollViewItem, param)
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, scrollView:getContentSize().height))
        scrollViewItem:setPosition(cc.p(scrollView:getContentSize().width/2, scrollView:getContentSize().height/2))
      end
    end
end
function UIFightGetAccident.setParam(_uiItem,_param)
    uiItem = _uiItem
    param = _param
end

function UIFightGetAccident.free()
  if uiItem == UIFightClearing then 
    if UIFightClearing.LevelUpgrade then
      UIGuidePeople.levelGuideTrigger()
      UIFightClearing.LevelUpgrade = false
    end
  end
  uiItem = nil
  param = nil
end

function UIFightGetAccident.setCallFunc(_callFunc)
  callFunc = _callFunc
end
