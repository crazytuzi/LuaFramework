require"Lang"
UILootChoose={}
local scrollView = nil
local playerItem = nil
local ui_label_fight= nil
local ui_endurance1 = nil
local ui_endurance2 = nil
local ui_gold = nil 
local ui_silver=nil
local chipId = nil
UILootChoose.selectedCardDatas = nil
UILootChoose.npc ={}
UILootChoose.pc ={}
UILootChoose.warParam = {}
UILootChoose.enemyInfo = {} ---显示胜利界面用

local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.lootPlayer then
      UILootChoose.npc ={}
      UILootChoose.pc ={}
      if pack.msgdata.message.npc and pack.msgdata.message.npc.message then
          UILootChoose.npc = pack.msgdata.message.npc.message
      end
      if pack.msgdata.message.pc and pack.msgdata.message.pc.message then 
          UILootChoose.pc = pack.msgdata.message.pc.message
      end
      if pack.msgdata.message.ds and pack.msgdata.message.ds.int then 
          UILootChoose.ds = pack.msgdata.message.ds.int
      end
      UILootChoose.setup()
  elseif tonumber(pack.header) == StaticMsgRule.lootWar then
      ----pc玩家消除和平镇保护时间-----
      if  UILoot.ScheduleId ~= nil and  UILootChoose.warParam[1] == 1 then
          UILoot.stopSchedule()
      end
      UITeam.checkRecoverState()
      UILootChoose.warParam[#UILootChoose.warParam+1] = pack.msgdata.string["1"]
      if UILootChoose.selectedCardDatas then 
        utils.sendFightData(UILootChoose.selectedCardDatas ,dp.FightType.FIGHT_CHIP.NPC)
      else 
        pvp.loadGameData(pack)
        ------如果引导PC 将等级置1--------------
        if UIGuidePeople.guideFlag then 
          if pvp.InstPlayerCard then 
            for key,obj in pairs(pvp.InstPlayerCard) do 
              obj.int["9"] = 1
            end
          end
        end
        --------------------------------
        utils.sendFightData(nil,dp.FightType.FIGHT_CHIP.PC)
      end
      if not UIFightMain.Widget or not UIFightMain.Widget:getParent() then 
        UIFightMain.loading()
      else 
        UIFightMain.setup()
      end
  end
end
function UILootChoose.sendlootWarData(param)
    local  sendData = {
      header = StaticMsgRule.lootWar,
      msgdata = {
        int = {
          type   = param[1],
          chipId  = param[2],
          playerId = param[3],
          instPlayerLootId = param[4],
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc, param[5])
end

function UILootChoose.sendAKeyWarData(param)

    local function aKeyWarCB(pack)
         if tonumber(pack.header) == StaticMsgRule.aKeyLootWar then
         local showparam = {}
		 table.insert(showparam,param[2])
		 table.insert(showparam,pack.msgdata)
		    UILootClearing.setParam(showparam)
		    UIManager.pushScene("ui_loot_clearing")
         end
    end

    local  sendData = {
      header = StaticMsgRule.aKeyLootWar,
      msgdata = {
        int = {
          chipId  = param[2]
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, aKeyWarCB)
end
local guide =nil 
---1 pc 2 npc
local function setScrollViewItem(_type,playerItem, _obj)
    local ui_label_lv = ccui.Helper:seekNodeByName(playerItem, "text_lv")
    local ui_name = ccui.Helper:seekNodeByName(playerItem, "text_player_name")
    local btn_loot = ccui.Helper:seekNodeByName(playerItem, "btn_loot")
    btn_loot:setPressedActionEnabled(true)
    local ui_prob = ccui.Helper:seekNodeByName(playerItem, "image_base_prob")
    local ui_image_frame_card ={}
    local cardData = utils.stringSplit(_obj.string["4"], ";")
    for i =1,4 do
      ui_image_frame_card[i] = ccui.Helper:seekNodeByName(playerItem, "image_frame_card" .. i)
      if  i> #cardData then 
          ui_image_frame_card[i]:setVisible(false)
      end
    end
    ui_name:setString(_obj.string["3"])
    ui_label_lv:setString(_obj.int["2"].. Lang.ui_loot_choose1)
    local imageName = nil
    if _type == 1 then
      if _obj.int["2"] >= net.InstPlayer.int["4"] then 
        imageName = "gl_ggl.png"
      else 
        imageName = "gl_jggl.png"
      end
    else 
      if UILootChoose.ds[tostring(_type)] == 3 then 
        imageName = "gl_ybgl.png"
      elseif UILootChoose.ds[tostring(_type)] == 4 then 
        imageName = "gl_dgl.png"
      elseif UILootChoose.ds[tostring(_type)] == 5 then 
        imageName = "gl_jigl.png"
      end
    end
    if imageName then 
      ui_prob:loadTexture("ui/" .. imageName)
    end
    for key,obj in pairs(cardData) do
        if key <= 4 then 
          local objData = utils.stringSplit(obj, "_")
          local cardId,qualityId = objData[1],objData[2]
          local smallUiId=DictCard[tostring(cardId)].smallUiId
          local smallImage= DictUI[tostring(smallUiId)].fileName
          local qualityImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
          ui_image_frame_card[key]:loadTexture(qualityImage)
          ui_image_frame_card[key]:getChildByName("image_card" .. key):loadTexture("image/" .. smallImage)
        end
    end
    local function LootFunction(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/fight.mp3")
            if _type == 1 then 
              local startTime = DictSysConfig[tostring(StaticSysConfig.lootCloseStartTime)].value
              local endTime = DictSysConfig[tostring(StaticSysConfig.lootCloseEndTime)].value
              local curTime = utils.getCurrentTime()
              local curHour= os.date("%H", curTime)
              if tonumber(curHour) >= startTime and tonumber(curHour) < (tonumber( endTime ) + 1) then 
                UIManager.showToast(string.format(Lang.ui_loot_choose2,startTime,tonumber( endTime ) + 1 ) )
                if UIGuidePeople.guideStep then 
                  UIGuidePeople.guideStep = nil
                end
                return
              end
            end
            if net.InstPlayer.int["10"] >= DictSysConfig[tostring(StaticSysConfig.lootVigor)].value then
                UILootChoose.warParam ={} 
                table.insert(UILootChoose.warParam,_type) -- 2 npc ,1 pc
                table.insert(UILootChoose.warParam,chipId) -- 
                table.insert(UILootChoose.warParam,_obj.int["1"])
                for key, obj in pairs(net.InstPlayerLoot) do
                    table.insert(UILootChoose.warParam,obj.int["1"])
                end
                UILootChoose.enemyInfo = {}
                table.insert(UILootChoose.enemyInfo,_obj.string["3"])
                local objData = utils.stringSplit(cardData[1], "_")
                table.insert(UILootChoose.enemyInfo,objData[1])
                if _type == 1 or UIGuidePeople.guideStep == guideInfo["20B6"].step then
                    if UILoot.ScheduleId  ~= nil then
                        local info = Lang.ui_loot_choose3
                        utils.PromptDialog(UILootChoose.sendlootWarData,info,UILootChoose.warParam)
                    else
                       UILootChoose.sendlootWarData(UILootChoose.warParam)
                    end
                else
                    UILootChoose.sendAKeyWarData(UILootChoose.warParam)
                end
            else
                if UIGuidePeople.guideStep then 
                  UIGuidePeople.guideStep = nil
                end
                --UIManager.showToast("耐力不足")
                utils.checkPlayerVigor()
            end
        end
    end
    btn_loot:addTouchEventListener(LootFunction)
    if _type == 2 then
        if UIGuidePeople.guideStep == guideInfo["20B5"].step then
            btn_loot:setTitleText(Lang.ui_loot_choose4)
        else
            btn_loot:setTitleText(Lang.ui_loot_choose5)
        end
    else
        btn_loot:setTitleText(Lang.ui_loot_choose6)
    end
    
    if not guide then 
      UIGuidePeople.isGuide(function () guide =true end,UILootChoose)
    end
end
local function scrollviewUpdate()
     guide = nil
     if next(UILootChoose.npc) then 
        for key, obj in pairs(UILootChoose.npc) do
           local _playerItem = playerItem:clone()
           setScrollViewItem(2,_playerItem, obj)
           scrollView:addChild(_playerItem)
        end
     end
     if next(UILootChoose.pc) then 
        for key, obj in pairs(UILootChoose.pc) do
           local _playerItem = playerItem:clone()
           setScrollViewItem(1,_playerItem, obj)
           scrollView:addChild(_playerItem)
        end
     end

end

function UILootChoose.init()
    local ui_time = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_time_left")
    ui_label_fight = ccui.Helper:seekNodeByName(UILootChoose.Widget, "label_fight")
    ui_endurance1 = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_endurance_number")
    ui_endurance2 = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_endurance")
    ui_gold = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_gold_number")
    ui_silver = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_silver_number")
    local ui_cost  = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_cost")
    local ui_hint  = ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_hint")
    local btn_back = ccui.Helper:seekNodeByName(UILootChoose.Widget, "btn_back") 
    local btn_change = ccui.Helper:seekNodeByName(UILootChoose.Widget, "btn_change") 
    btn_back:setPressedActionEnabled(true)
    btn_change:setPressedActionEnabled(true)
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UILoot.isFlush = true
                UIManager.showWidget("ui_loot")
            elseif sender == btn_change then
                UILootHint.getLootData(netCallbackFunc)
            end
        end
    end
    btn_back:addTouchEventListener(btnTouchEvent)
    btn_change:addTouchEventListener(btnTouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UILootChoose.Widget, "view_player")
    playerItem = scrollView:getChildByName("image_base_player"):clone()
    ui_time:setVisible(false)
    ui_cost:setString(Lang.ui_loot_choose7 .. DictSysConfig[tostring(StaticSysConfig.lootVigor)].value)
    ui_hint:setString(string.format(Lang.ui_loot_choose8,DictSysConfig[tostring(StaticSysConfig.lootCloseStartTime)].value, ( tonumber ( DictSysConfig[tostring(StaticSysConfig.lootCloseEndTime)].value) ) + 1 ) )
end

function UILootChoose.setup()
    if playerItem:getReferenceCount() == 1 then
      playerItem:retain()
    end
    ui_label_fight:setString(utils.getFightValue())
    ui_endurance1:setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
    ui_endurance2:setString(Lang.ui_loot_choose9 .. net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    ui_silver:setString(net.InstPlayer.string["6"])
    if next(UILootChoose.npc) or next(UILootChoose.pc) then 
        scrollView:jumpToTop()
        scrollView:removeAllChildren()
        scrollviewUpdate()
        local innerHeight ,space = 0 ,0
        local childs = scrollView:getChildren()
        local ItemHeight = playerItem:getContentSize().height 
        innerHeight = (ItemHeight +space) * #childs
        
        if innerHeight < scrollView:getContentSize().height then
          innerHeight = scrollView:getContentSize().height
        end
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width,innerHeight))
        local x,y = 26,0
        for i=1,#childs do
             y= innerHeight  -(i-1)*(ItemHeight +space)
             childs[i]:setPosition(cc.p(x,y))
             if i == 1 then 
                UIGuidePeople.isGuide(childs[i]:getChildByName("btn_loot"),UILootChoose)
             end
        end 
        if not  UIGuidePeople.guideFlag then 
          ActionManager.ScrollView_SplashAction(scrollView)
        end
    end
end

function UILootChoose.flushVigor()
    ui_label_fight:setString(utils.getFightValue())
    ui_endurance1:setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
    ui_endurance2:setString(Lang.ui_loot_choose10 .. net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    ui_silver:setString(net.InstPlayer.string["6"])
end

function UILootChoose.setChipId(_chipId)
    UILoot.isLoot = true
    chipId = _chipId
    UIManager.showWidget("ui_loot_choose")
end

function UILootChoose.free( ... )
    guide = nil
    scrollView:removeAllChildren()
end
