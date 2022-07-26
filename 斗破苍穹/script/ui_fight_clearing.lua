require"Lang"
---连续战斗结算
UIFightClearing={}
local scrollView ={}
local Item = nil
UIFightClearing.param = {}

local function setChildScrollViewItem(_thingItem,obj)
    --local _childObj = DictBarrierDrop[obj.id]
    local thingIcon = _thingItem:getChildByName("image_good")
    local thingName = thingIcon:getChildByName("text_name")
    local thingCount = ccui.Helper:seekNodeByName(_thingItem, "text_number")
   
    --local tableTypeId, tableFieldId, value = _childObj.tableTypeId, _childObj.tableFieldId, _childObj.value
    local name,icon =utils.getDropThing(obj.tableTypeId,obj.tableFieldId)
    thingName:setString(name)
    thingIcon:loadTexture(icon)
    if tonumber(obj.tableTypeId) ~=  StaticTableType.DictCard then 
      thingCount:setString(tostring(obj.num*obj.value))
    else 
      thingCount:setString(tostring(obj.num))
    end
    utils.addBorderImage(obj.tableTypeId,obj.tableFieldId,_thingItem)
end
local function setScrollViewItem(_Item,_obj)
      local ui_text_ceng = ccui.Helper:seekNodeByName(_Item, "text_ceng")
      local ui_label_lv = ccui.Helper:seekNodeByName(_Item, "label_lv") 
      local ui_bar_lv  = ccui.Helper:seekNodeByName(_Item, "bar_lv") 
      local InstPlayerNowLevel = net.InstPlayer.int["4"]
      local nowExp = net.InstPlayer.int["7"]
      local ExpNowLevelValue =0
      ui_label_lv:setString(tostring(InstPlayerNowLevel))
      if DictLevelProp[tostring(InstPlayerNowLevel)]~= nil then 
          ExpNowLevelValue = DictLevelProp[tostring(InstPlayerNowLevel)].fleetExp 
      end
      local number =nowExp/ ExpNowLevelValue * 100
      if number >100 then
          ui_bar_lv:setPercent(100)
      else
          ui_bar_lv:setPercent(number)
      end
          
      local ui_text_money = ccui.Helper:seekNodeByName(_Item, "text_silver_number")
      local ui_text_expNumber = ccui.Helper:seekNodeByName(_Item, "text_exp_number")
      local copper = DictBarrierLevel[tostring(UIFightClearing.param[1])].copper
      ui_text_money:setString(copper)
--      if utils.LevelUpgrade == true then 
--         ui_text_expNumber:setString(DictLevelProp[tostring(utils.beforeLevel)].oneWarExp)
--     else
--         ui_text_expNumber:setString(DictLevelProp[tostring(InstPlayerNowLevel)].oneWarExp)
--     end
      ui_text_expNumber:setString(UIFightClearing.param[2].int["3"])
      local thingIds = utils.stringSplit(_obj, ":") --副本获得掉落字典表ID
      local fightTime = thingIds[1]
      ui_text_ceng:setString(Lang.ui_fight_clearing1 .. fightTime .. Lang.ui_fight_clearing2)
      local dropIds = nil
      if thingIds[2] then 
        dropIds = utils.stringSplit(thingIds[2], ";")
      end
      local childScrollView = _Item:getChildByName("view_good")
      local thingItem = childScrollView:getChildByName("image_frame_good")
      childScrollView:removeAllChildren()

      local dropData = {}
      if dropIds then 
        for key, id in pairs(dropIds) do
          local data = utils.stringSplit(id, "_")
          if data.tableTypeId ~=  StaticTableType.DictCard then 
            local flag =false 
            if next(dropData) then 
              for _key,_obj in pairs(dropData) do 
                if _obj.id == id then 
                  flag = true 
                  _obj.num = _obj.num + 1
                  end 
              end
            end
            if flag == false  then 
              local _data= {}
              _data.id = id 
              _data.tableTypeId = data[1] 
              _data.tableFieldId = data[2]
              _data.value = data[3]
              _data.num = 1
              table.insert(dropData,_data)
            end
          else 
            local _data= {}
            _data.id = id 
            _data.tableTypeId = data[1] 
            _data.tableFieldId = data[2]
            _data.value = data[3]
            _data.num = 1
            table.insert(dropData,_data)
          end
        end
      end


--      if dropIds then 
--        for key, id in pairs(dropIds) do
--          local data = DictBarrierDrop[id]
--          if data.tableTypeId ~=  StaticTableType.DictCard then 
--            local flag =false 
--            if next(dropData) then 
--              for _key,_obj in pairs(dropData) do 
--                if _obj.id == id then 
--                  flag = true 
--                  _obj.num = _obj.num + 1
--                  end 
--              end
--            end
--            if flag == false  then 
--              local _data= {}
--              _data.id = id 
--              _data.num = 1
--              table.insert(dropData,_data)
--            end
--          else 
--            local _data= {}
--            _data.id = id 
--            _data.num = 1
--            table.insert(dropData,_data)
--          end
--        end
--      end
      for key, obj in pairs(dropData) do
        local childThingItem = thingItem:clone()
        childScrollView:addChild(childThingItem)
        setChildScrollViewItem(childThingItem, obj)
      end
      local width, space = 0, 20
      local childs = childScrollView:getChildren()
      width = (thingItem:getContentSize().width + space) * #childs
      
      if width < childScrollView:getContentSize().width then
        width = childScrollView:getContentSize().width
      end
      childScrollView:setInnerContainerSize(cc.size(width,childScrollView:getContentSize().height))
      local x,y = 0,childScrollView:getContentSize().height/2+20
      for i=1,#childs do
           x= thingItem:getContentSize().width/2 + space +(i-1)*(thingItem:getContentSize().width + space)
           childs[i]:setPosition(cc.p(x,y))
      end 
end

----------显示意外获得界面--------------
local function showAccidentScene()
    local param = UIFightClearing.param
    if param and param[2].string["2"] ~= nil then
        UIFightGetAccident.setParam(UIFightClearing,param[2].string["2"])
        UIManager.pushScene("ui_fight_get_accident")
        UIFightClearing.param = nil
        return true 
    else 
        return false
    end
end

function UIFightClearing.init()
   local btn_sure = ccui.Helper:seekNodeByName(UIFightClearing.Widget, "btn_sure")
   local function TouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_sure then 
                UIManager.popScene()
            end
        end
    end
    btn_sure:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIFightClearing.Widget, "view_get_good")
    Item = scrollView:getChildByName("panel_good"):clone()
end
function UIFightClearing.setup()
    local param = UIFightClearing.param
    if Item:getReferenceCount() == 1 then 
        Item:retain()
    end
    UIFightClearing.Widget:setEnabled(false)
    scrollView:removeAllChildren()
    local ui_fightName = ccui.Helper:seekNodeByName(UIFightClearing.Widget, "text_fight_name")
    local DictBarrierLevelId  = param[1]
    local barrierId = DictBarrierLevel[tostring(DictBarrierLevelId)].barrierId
    local fightName = DictBarrier[tostring(barrierId)].name
    ui_fightName:setString(fightName)
    if param[2] then 
        local dropThings = utils.stringSplit(param[2].string["1"], "|") --连战10次得物品表
        local sDropThings = {}
        if param[2].string["4"] then
            local sThings = utils.stringSplit( param[2].string["4"] , "|" )
            for key ,value in pairs( sThings ) do
                local things = utils.stringSplit( value , ":" )
                if things[ 2 ] then
                    sDropThings[ things[ 1 ] ] = things[ 2 ] 
                end
            end
        end
        for key, obj in pairs(dropThings) do
          local dropId = utils.stringSplit( obj , ":" )[1]
         -- print( "dropId:" , dropId )
          if sDropThings and sDropThings[ dropId ] then
            obj = obj .. ";" .. sDropThings[ dropId ]
          end
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

function UIFightClearing.onEnter()
  if utils.LevelUpgrade == true  then
     local function FrameEventCallFunc(bone,eventName,originFrameIndex,currentFrameIndex)
        if eventName == "level" then
           UIManager.pushScene("ui_fight_upgrade")
        end
     end
     local function callbackFunc(armature)
        if armature:getParent() then armature:removeFromParent() end
        local childs = UIManager.uiLayer:getChildren()
        for key, obj in pairs(childs) do
          obj:setEnabled(true) 
        end
     end
     local armature = ActionManager.getUIAnimation(1, callbackFunc)
     armature:getAnimation():setSpeedScale(0.8)
     armature:getAnimation():setFrameEventCallFunc(FrameEventCallFunc)
     armature:setPosition(UIManager.screenSize.width / 2,UIManager.screenSize.height / 2);
     UIFightClearing.Widget:addChild(armature,100)
  else 
     UIFightClearing.Widget:setEnabled(true) 
  end
end

function UIFightClearing.setParam(_param)
    UIFightClearing.param = _param
end

function UIFightClearing.free()
  if Item and Item:getReferenceCount() >= 1 then 
      Item:release()
      Item = nil
  end
  if scrollView then
    scrollView:removeAllChildren()
    scrollView = nil
  end
  if not showAccidentScene() then 
    if UIFightClearing.LevelUpgrade then 
      UIGuidePeople.levelGuideTrigger()
      UIFightClearing.LevelUpgrade = false
    end
  end
end
