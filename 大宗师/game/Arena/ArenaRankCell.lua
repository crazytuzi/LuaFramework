

local ArenaRankCell = class("ArenaRankCell", function ()
  return CCTableViewCell:new()
end)

function ArenaRankCell:getContentSize()
    if self.cntSize == nil then 
        local proxy = CCBProxy:create()
        local rootNode = {}

        local node = CCBuilderReaderLoad("arena/rank_item.ccbi", proxy, rootNode)
        self.cntSize = rootNode["itemBg"]:getContentSize()
        self:addChild(node)
        node:removeSelf()
    end 

    return self.cntSize 
end


function ArenaRankCell:refresh(id)

  local _cellData = self.data[id]

  -- 更换各种背景框 
  local playerBgName 
  local bgName 
  local innerBgName 
  local lvBgName
  local markIconName 

  if id < 4 then 
    playerBgName = "#arena_name_bg_" .. id .. ".png" 
    bgName = "#arena_itemBg_" .. id .. ".png" 
    innerBgName = "#arena_itemInner_bg_" .. id .. ".png" 
    lvBgName = "#arena_lv_bg_" .. id .. ".png"
    markIconName = "#arena_mark_" .. id .. ".png" 

    self._rootnode["mark_icon"]:setVisible(true) 
    self._rootnode["mark_icon"]:setDisplayFrame(display.newSprite(markIconName):getDisplayFrame()) 
  else
    self._rootnode["mark_icon"]:setVisible(false) 
    playerBgName = "#arena_name_bg_4.png"
    bgName = "#arena_itemBg_4.png"
    innerBgName = "#arena_itemInner_bg_1.png"
    lvBgName = "#arena_lv_bg_4.png" 
    markIconName = "#arena_mark_1.png" 
  end 

  self._rootnode["lv_bg"]:setDisplayFrame(display.newSprite(lvBgName):getDisplayFrame()) 

  self._rootnode["bg_node"]:removeAllChildren() 
  local bg = display.newScale9Sprite(bgName, 0, 0, self._rootnode["bg_node"]:getContentSize()) 
  bg:setAnchorPoint(0, 0)
  self._rootnode["bg_node"]:addChild(bg) 

  self._rootnode["name_bg"]:removeAllChildren() 
  local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode["name_bg"]:getContentSize()) 
  playerBg:setAnchorPoint(0, 0)
  self._rootnode["name_bg"]:addChild(playerBg) 

  self._rootnode["innerBg_node"]:removeAllChildren() 
  local innerBg = display.newScale9Sprite(innerBgName, 0, 0, self._rootnode["innerBg_node"]:getContentSize()) 
  innerBg:setAnchorPoint(0, 0)
  self._rootnode["innerBg_node"]:addChild(innerBg) 

  if game.player:checkIsSelfByAcc(_cellData["acc"]) then 
      self._rootnode["form_btn"]:setVisible(false) 
  else
      self._rootnode["form_btn"]:setVisible(true)  
  end 


   if _cellData["faction"] == "" then 
       self._rootnode["gang_name"]:setVisible(false)
   else
       self._rootnode["gang_name"]:setVisible(true)
       self._rootnode["gang_name"]:setString("【".. _cellData["faction"] .."】")
   end

   self._rootnode["lv_num"]:setString("LV." .. tostring(_cellData["level"])) 
   self._rootnode["player_name"]:setString(_cellData["name"])

   -- arrangeTTF({
   --     self._rootnode["player_name"],
   --     self._rootnode["gang_name"]
   -- })

   self._rootnode["reward_money"]:setString(_cellData["getSilver"])
   self._rootnode["shengwang_num"]:setString("X" .. tostring(_cellData["getPopual"])) 

   self._rootnode["rank_num"]:setString("排名: " .. tostring(_cellData["rank"])) 

   local _cards = _cellData["card"]
   for i =1,4 do
       if i > #_cards then
           self._rootnode["icon_"..i]:setVisible(false)
       else
           self._rootnode["icon_"..i]:setVisible(true)
           local cls = _cards[i]["cls"]
           local resId = _cards[i]["resId"]
           ResMgr.refreshIcon({id = resId,itemBg = self._rootnode["icon_"..i],resType = ResMgr.HERO,cls = cls})
       end
   end
end


function ArenaRankCell:setStars(num)
    for i = 1,5 do
        if i > num then
            self._rootnode["star"..i]:setVisible(false)
        else
            self._rootnode["star"..i]:setVisible(true)
        end
    end
end


function ArenaRankCell:create(param)

    self.data = param.listData
    local _id = param.id
    local _createFormFunc = param.createFormFunc
    local _viewSize = param.viewSize 

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("arena/rank_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width/2, 0) 
    self:addChild(node)

    -- self.rankName = ui.newTTFLabelWithOutline({
    --     text = "排名:",
    --     size = 26,
    --     color = ccc3(205,3,3),
    --     outlineColor = ccc3(255,255,255),
    --     font = FONTS_NAME.font_haibao,
    --     align = ui.TEXT_ALIGN_LEFT
    -- })
    -- node:addChild(self.rankName)

    -- copyNodePos({
    --     self.rankName,
    --     self._rootnode["rank_name"]
    -- })

    self._rootnode["form_btn"]:addHandleOfControlEvent(function(eventName,sender)
      GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if ENABLE_ZHENRONG then 
            _createFormFunc(self:getIdx())
        else
            show_tip_label(data_error_error[2800001].prompt)
        end 
    end,
    CCControlEventTouchDown)

    self:refresh(_id + 1)
    return self
end

function ArenaRankCell:beTouched()
    
end

function ArenaRankCell:onExit()

end

function ArenaRankCell:runEnterAnim(  )

end



return ArenaRankCell