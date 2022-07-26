require"Lang"
UIActivityHJY ={}
local instActivityObj = nil
local countDownTime = nil
local ScheduleId = nil
local ui_image_base_di = nil
local ui_timeText = nil
local hunyuanNumber = nil
local image_frame_good =nil
local ui_goodInfo = nil
local ui_image_yanli = nil
local refresh_number = nil
UIActivityHJY.isReset = false
local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.updateAuctionOrHjy then
      UIActivityHJY.setup() 
  elseif tonumber(pack.header) == StaticMsgRule.convertGoods then
      UIActivityHJY.setup()
      UIManager.showToast(Lang.ui_activity_heijiaoyu1)
  end  
end
--1-拍卖行刷新物品 2-黑角域增加刷新次数 3-黑角域刷新物品
local function sendRefreshData(_type)
    local  sendData = {
      header = StaticMsgRule.updateAuctionOrHjy,
      msgdata = {
        int = {
          type  = _type ,
          instActivityId  = instActivityObj.int["1"]
        }
      }
    }
    netSendPackage(sendData, netCallbackFunc)
end
local function sendConvertData(_instHJYStoreId)
    local  sendData = {
      header = StaticMsgRule.convertGoods,
      msgdata = {
        int = {
          type   = 2,
          instHJYStoreId = _instHJYStoreId
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
local function stopSchedule()
	if ScheduleId then 
      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ScheduleId)
      ScheduleId = nil
      countDownTime =nil
    end
end

local function updateTime()
    --local ui_timeText = ccui.Helper:seekNodeByName(ui_image_base_di, "text_time") 
    if countDownTime > 0 then 
        countDownTime  = countDownTime -1
        local hour= math.floor(countDownTime/3600)
        local min= math.floor(countDownTime%3600/60)
        local sec= countDownTime%60
        ui_timeText:setString(string.format(" %02d:%02d:%02d",hour,min,sec))
    else
       stopSchedule()
       sendRefreshData(2)
    end
end

local function show(Enable,param)
    if Enable then
            local tableTypeId  = param.tableTypeId
            local tableFieldId =param.tableFieldId
            local value = param.value
            local name,icon,_description =utils.getDropThing(tableTypeId,tableFieldId)
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
            bg_image:setAnchorPoint(cc.p(0.5, 0.5))
            bg_image:setPreferredSize(cc.size(350, 150)) 
            local bg_image_x = visibleSize.width / 2
            if param.Pos.x - bg_image:getPreferredSize().width/2 < 0 then 
                bg_image_x = bg_image:getPreferredSize().width/2 
            elseif param.Pos.x + bg_image:getPreferredSize().width/2 > visibleSize.width then 
                bg_image_x = visibleSize.width - bg_image:getPreferredSize().width/2 
            else 
                bg_image_x = param.Pos.x
            end
            bg_image:setPosition(cc.p(bg_image_x, param.Pos.y+bg_image:getPreferredSize().height))
            local node = cc.Node:create()
            local image_di = ccui.ImageView:create("ui/quality_small_purple.png")
            local image = ccui.ImageView:create(icon)
            image:setPosition(cc.p(image_di:getContentSize().width/2,image_di:getContentSize().height/2))
            image_di:addChild(image)
            image_di:setPosition(cc.p(20,20))
            image_di:setScale(0.7)
            local description = ccui.Text:create()
            description:setFontSize(20)
            description:setFontName(dp.FONT)
            description:setAnchorPoint(cc.p(0,0.5))
            description:setString(_description)
            description:setTextAreaSize(cc.size(bg_image:getPreferredSize().width-image_di:getContentSize().width-40,description:getContentSize().height*2))
            description:setPosition(cc.p(cc.p(image_di:getPosition()).x+image_di:getContentSize().width/2,30))
            local text_num = ccui.Text:create()
            text_num:setFontSize(20)
            text_num:setFontName(dp.FONT)
            text_num:setAnchorPoint(cc.p(0,0.5))
            text_num:setString(string.format(Lang.ui_activity_heijiaoyu2,value))
            text_num:setPosition(cc.p(cc.p(image_di:getPosition()).x+image_di:getContentSize().width/2,-30))
            utils.addBorderImage(tableTypeId,tableFieldId,image_di)
            node:addChild(image_di)
            node:addChild(description)
            node:addChild(text_num)
            node:setPosition(cc.p(image_di:getContentSize().width/2,bg_image:getPreferredSize().height/2))
            bg_image:addChild(node,3)
            UIActivityHJY.Widget:addChild(bg_image,100,100)
    else
      if UIActivityHJY.Widget:getChildByTag(100) then 
        UIActivityHJY.Widget:removeChildByTag(100)
      end
    end
end

local function setItemView(_Item,obj)
    local tableTypeId,tableFieldId,value = nil
    tableTypeId = obj.int["3"]
    tableFieldId = obj.int["4"] 
    value = obj.int["5"] 
    
    local Item = _Item:getChildByName("image_frame_good")
    utils.showThingsInfo( Item , tableTypeId , tableFieldId )
    local btn_exchange = _Item:getChildByName("btn_exchange")
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          if sender == Item then 
--              if UIActivityHJY.Widget:getChildByTag(100) then 
--                UIActivityHJY.Widget:removeChildByTag(100)
--              end
--              local param = {}
--              param.tableTypeId = tableTypeId
--              param.tableFieldId = tableFieldId
--              param.value = value
--              param.Pos = sender:getParent():convertToWorldSpace(cc.p(sender:getPosition()))
--              show(true,param)     
                local dictCardSoul = DictCardSoul[tostring(tableFieldId)]
				local dictData = DictCard[tostring(dictCardSoul.cardId)]
       		    UICardInfo.setDictCardId(dictData.id)
				UIManager.pushScene("ui_card_info")      
          elseif sender == btn_exchange then  ---------兑换------------------
              if UIActivityHJY.Widget:getChildByTag(100) then 
                UIActivityHJY.Widget:removeChildByTag(100)
                return
              end
              if obj.int["6"] == 2 then --出售类型
                  if hunyuanNumber < obj.int["7"] then 
                    UIActivityMiteer.PromptDialog(Lang.ui_activity_heijiaoyu3,2)
                    return 
                  end 
              elseif obj.int["6"] ==  1 then 
                  if net.InstPlayer.int["5"] < obj.int["7"] then 
                      UIManager.showToast(Lang.ui_activity_heijiaoyu4)
                      return 
                  end 
              end
              sendConvertData(obj.int["1"])
          end 
      end
    end
--    Item:setEnabled(true)
--    Item:setTouchEnabled(true)
--    Item:addTouchEventListener(TouchEvent)
    btn_exchange:setPressedActionEnabled(true)
    btn_exchange:addTouchEventListener(TouchEvent)
    local  ui_image_good = Item:getChildByName("image_good")
    local ui_base_number = Item:getChildByName("image_base_number")
    local ui_name = _Item:getChildByName("text_info")
    if value ~= 1 then 
      ui_base_number:setVisible(true)
    else 
      ui_base_number:setVisible(false)
    end
    local  ui_number = ui_base_number:getChildByName("text_number")
    ui_number:setString(value)
    local  thingName,thingIcon = utils.getDropThing(tableTypeId,tableFieldId)
    local qualityId = utils.addBorderImage(tableTypeId,tableFieldId,Item)
    ui_name:setString(thingName)
    if tonumber(tableTypeId) == StaticTableType.DictMagic then 
      utils.changeNameColor(ui_name,tonumber(qualityId),dp.Quality.gongFa)
    else 
      utils.changeNameColor(ui_name,tonumber(qualityId))
    end
    local ui_image_price = Item:getChildByName("image_price")
    if obj.int["6"] == 1 then --出售类型
        ui_image_price:loadTexture("ui/jin.png")
    elseif obj.int["6"] ==  2 then 
        ui_image_price:loadTexture("ui/small_hunyuan.png")
    end
    ui_image_price:getChildByName("text_price"):setString("×" .. obj.int["7"])  --- 价格
    ui_image_good:loadTexture(thingIcon)
  	if obj.int["8"] == 1 then 
       utils.GrayWidget(Item,true)
	     utils.GrayWidget(btn_exchange,true)
  	elseif obj.int["8"] == 0 then 
       utils.GrayWidget(Item,false)
  	   utils.GrayWidget(btn_exchange,false)
  	end 
end

function UIActivityHJY.init()
    local btn_refresh = ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "btn_refresh")
    btn_refresh:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
      if eventType == ccui.TouchEventType.ended then
          if UIActivityHJY.Widget:getChildByTag(100) then 
            UIActivityHJY.Widget:removeChildByTag(100)
            return
          end
          if sender == btn_refresh then
               local vipNum = net.InstPlayer.int["19"]
               local freshCount = 0
              if instActivityObj and instActivityObj.string["7"]  and instActivityObj.string["7"] ~= "" then
                   freshCount = tonumber(instActivityObj.string["7"]) 
              end
              if instActivityObj and instActivityObj.string["8"]  and instActivityObj.string["8"] ~= "" then
                   local temp = utils.stringSplit(instActivityObj.string["8"], " ")
                   local date = utils.stringSplit(temp[1], "-")
                   local oldDay = date[3]
                   local _tableStartTime = os.date("*t", utils.getCurrentTime() / 1000)
                   local newDay = _tableStartTime.day
                   if tonumber(oldDay) ~= newDay then
                        freshCount = 0
                   end
              end
              if UIActivityHJY.isReset then
                   freshCount = 0
                   UIActivityHJY.isReset = false
              end

              if refresh_number and instActivityObj and refresh_number > 0 or DictVIP[tostring( vipNum + 1 )].hJYReset - instActivityObj.int["6"] > 0  then
                  sendRefreshData(3)
              else
                  UIManager.showToast( "刷新次数已用完" )
              end
--               if refresh_number and instActivityObj and refresh_number == 0 and DictVIP[tostring( vipNum + 1 )].hJYReset - instActivityObj.int["6"] <= 0 and DictVIP[tostring( vipNum + 1 )].hjyFreshCount - freshCount <= 0 then
--                    local toastStr = "今日刷新次数已达上限！"
--                    local toastStr1 = ""
--                    local nextVip = 15
--                    local curCount = DictVIP[tostring( vipNum + 1 )].hjyFreshCount
--                    for i = vipNum , 15 do
--                        local count = DictVIP[tostring( i + 1 )].hjyFreshCount
--                        if tonumber( count ) > tonumber( curCount ) then
--                            nextVip = i
--                            break 
--                        end
--                    end
--                    if tonumber ( nextVip ) < 15 then
--                        toastStr1 = "VIP达到"..nextVip.."级，刷新次数为"..DictVIP[tostring( nextVip + 1 )].hjyFreshCount.."次"
--                        UIHintBuy.show( UIHintBuy.MONEY_TYPE_RECHARGE , { toastStr , toastStr1 } )
--                    else
--                        UIManager.showToast(toastStr)
--                    end
                  --  cclog( toastStr )
                  --   cclog( toastStr1 )
               --else
               --     sendRefreshData(3)
              -- end
          end
      end
    end
    UIActivityHJY.Widget:addTouchEventListener(btnTouchEvent)
    btn_refresh:addTouchEventListener(btnTouchEvent)
end 

function UIActivityHJY.setup()
	 stopSchedule()
	 image_frame_good = {}
	 for i=1,8 do
       image_frame_good[i] = ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "image_base_good" .. i)
     end
	 local ui_text_hint =ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "image_shadow_down")
	-- ui_text_hint:getChildByName("text_hint"):setString(string.format("*使用刷新令或%d元宝可以刷新一次",DictSysConfig[tostring(StaticSysConfig.hJYStoreResetGold)].value))
	 -----显示魂源和刷新令----
      local ui_hunyuan =ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "text_hunyuan_number")
      local ui_text_refresh_number =ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "text_refresh_number")
      local ui_text_sxl = ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "text_refresh")
      local image_refresh = ccui.Helper:seekNodeByName( UIActivityHJY.Widget , "image_refresh")
      hunyuanNumber = 0 
      refresh_number = 0
     
      if net.InstPlayerThing then
        for _key,_obj in pairs(net.InstPlayerThing) do
              if _obj.int["3"] == StaticThing.soulSource then
                  hunyuanNumber =_obj.int["5"]
              end
        end
      end
	  if net.InstPlayerThing then
        for _key,_obj in pairs(net.InstPlayerThing) do
              if _obj.int["3"] == StaticThing.refreshSign then
                  refresh_number =_obj.int["5"]
              end
        end
      end
      ui_hunyuan:setString(hunyuanNumber)

      
      
      local ui_text_left_number =ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "text_free_number")
      local vipNum = net.InstPlayer.int["19"]
	  local freeFreshNum = DictVIP[tostring(vipNum+1)].hJYReset
      ui_text_left_number:setString(string.format("%d/%d",freeFreshNum - instActivityObj.int["6"],freeFreshNum))

      local ui_fresh_num = ccui.Helper:seekNodeByName( UIActivityHJY.Widget , "text_gold")

      local freshCount = 0
      if instActivityObj and instActivityObj.string["7"]  and instActivityObj.string["7"] ~= "" then
           cclog("instActivityObj : "..instActivityObj.string["7"])
           freshCount = tonumber(instActivityObj.string["7"])
      end
      if instActivityObj and instActivityObj.string["8"]  and instActivityObj.string["8"] ~= "" then
           local temp = utils.stringSplit(instActivityObj.string["8"], " ")
           local date = utils.stringSplit(temp[1], "-")
           local oldDay = date[3]
           local _tableStartTime = os.date("*t", utils.getCurrentTime())
           local newDay = _tableStartTime.day
           if tonumber(oldDay) ~= newDay then
            freshCount = 0
           end
      end
      if UIActivityHJY.isReset then
           freshCount = 0
      end
  --  ui_fresh_num:setString(Lang.ui_activity_heijiaoyu9..( DictVIP[tostring(vipNum + 1 )].hjyFreshCount - freshCount ) )
       ui_fresh_num:setString("")
      if freeFreshNum - instActivityObj.int["6"] == 0 then
           UIActivityPanel.addImageHint(UIActivityHJY.checkImageHint(),"hJYStore")
      end

      if refresh_number == 0 and freeFreshNum - instActivityObj.int["6"] == 0 then --没次数或者刷新令  显示元宝
        -- ui_text_sxl:setString(Lang.ui_activity_heijiaoyu10)
        -- image_refresh:loadTexture("ui/jin.png")
        -- ui_text_refresh_number:setString("×" .. DictSysConfig[tostring(StaticSysConfig.hJYStoreResetGold)].value)
         ui_text_sxl:setString(Lang.ui_activity_heijiaoyu11)
         image_refresh:loadTexture("ui/sxl.png")
         ui_text_refresh_number:setString("×" .. 0)
      else
         ui_text_sxl:setString(Lang.ui_activity_heijiaoyu11)
         image_refresh:loadTexture("ui/sxl.png")
         ui_text_refresh_number:setString("×" .. refresh_number)
      end
	-------------------增加刷新次数倒计时----------------------------
	--    ui_image_base_di = ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "image_base_di")
      local starTime =utils.GetTimeByDate(instActivityObj.string["4"])
      local currentTime = utils.getCurrentTime()
      local hJYStoreResetTime = DictSysConfig[tostring(StaticSysConfig.hJYStoreResetTime)].value
      countDownTime = hJYStoreResetTime*3600 - math.abs(currentTime - starTime)%(hJYStoreResetTime*3600)
      ui_timeText = ccui.Helper:seekNodeByName(UIActivityHJY.Widget, "text_free_time")
      if countDownTime ~= 0 and instActivityObj.int["6"] > 0 then 
         local hour= math.floor(countDownTime/3600)
         local min= math.floor(countDownTime%3600/60)
         local sec= countDownTime%60
         ui_timeText:setVisible(true)
         ui_timeText:setString(string.format(" %02d:%02d:%02d",hour,min,sec))
         if not ScheduleId then 
           ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime,1,false)
         end
      else 
         ui_timeText:setVisible(false)
         stopSchedule()
      end
      ---------------------------------------------------------------
      if net.InstHJYStore then
          local i = 1 
          for key,obj in pairs(net.InstHJYStore) do
              image_frame_good[tonumber(i)]:setTag(i)
              setItemView(image_frame_good[tonumber(i)],obj)
              i=i+1
          end
      end
end

function UIActivityHJY.setData(_instActivityObj)
    instActivityObj  =_instActivityObj
    sendRefreshData(2)
end

function UIActivityHJY.setTimeInterval(intervalTime)
    -- 修复极端情况下countDownTime为nil时的错误
    if not countDownTime then
      countDownTime = 0
      return
    end
    local countDownTime1 =  countDownTime- intervalTime
    if countDownTime1 > 0 then 
        countDownTime = countDownTime1
    else
        countDownTime = 0
    end
end

function UIActivityHJY.free()
  if UIActivityHJY.Widget:getChildByTag(100) then 
    UIActivityHJY.Widget:removeChildByTag(100)
  end
  refresh_number = nil
end

function UIActivityHJY.checkImageHint()
    local vipNum = net.InstPlayer.int["19"]
    local _instActivityObj = nil
        if net.InstActivity then 
          for key,obj  in pairs(net.InstActivity) do
              if 2 == obj.int["3"] then
                  _instActivityObj = obj
                  break 
              end
          end
        end
    if _instActivityObj == nil then
        return false
    end
    local freeFreshNum = DictVIP[tostring(vipNum+1)].hJYReset
    if( freeFreshNum - _instActivityObj.int["6"] ) > 0 then
        return true 
    end
    return false
end
