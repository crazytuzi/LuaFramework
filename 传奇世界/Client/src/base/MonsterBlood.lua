local MonsterBlood = class("MonsterBlood", function() return  cc.Node:create() end)

require "src/config/Debug"

local tipLayer

function MonsterBlood:ctor(params,parent) 
  local res_base,res_common = "res/monster/head/","res/common/"
  self.headbg = createSprite(self,res_base.."boss_bg.png",cc.p(35,0),cc.p(0.0,0.5))
  self.headbg:setLocalZOrder(5)
  self.name_label = createLabel(self.headbg," ",cc.p(185,55),false,18)
  local blood = cc.ProgressTimer:create(cc.Sprite:create(res_base.."blood.png"))  
  blood:setPosition(118, 28)
  blood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  blood:setAnchorPoint(cc.p(0.0,0.0))
  blood:setBarChangeRate(cc.p(1, 0))
  blood:setMidpoint(cc.p(0,1))
  blood:setPercentage(50)
  self.headbg:addChild(blood)
  self.r_pro_blood = blood

  self.blood_label = createLabel(self.headbg,"900".."/".."1000",cc.p(180,33),false,12)

  if parent then 
    self.parent = parent
  end

  local closeFunc = function() 
    if self.parent then 
      self.parent:resetTouchTag()
    end
  end
  local closebtn = createTouchItem(self.headbg,"res/component/button/x2.png",cc.p(255,60),closeFunc)
  closebtn:setScale(0.8)
  local func = function() self:showOperate() end
  local def_cfg = { res_base.."elite_def.png"  , res_base.."elite_def.png" , res_base.."boss_def.png" , res_base.."plot_def.png" , res_base.."bodyguard1.png" , res_base.."bodyguard2.png" }
  self.head_img = createTouchItem(self.headbg, def_cfg[2] ,cc.p(86,38),func)
  --扩大点击区域
  local  listenner = cc.EventListenerTouchOneByOne:create()
  listenner:setSwallowTouches(true)
  listenner:registerScriptHandler(function(touch, event)
    local pt = self:convertTouchToNodeSpace(touch)
    if cc.rectContainsPoint(self.headbg:getBoundingBox(),pt) then
      return true
    end       
    return false
  end,cc.Handler.EVENT_TOUCH_BEGAN)
  listenner:registerScriptHandler(function(touch, event)
    local pt = self:convertTouchToNodeSpace(touch)
    if cc.rectContainsPoint(self.headbg:getBoundingBox(),pt) then
        func()
    end
  end,cc.Handler.EVENT_TOUCH_ENDED)
  local eventDispatcher =  self.headbg:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,  self.headbg )
  --展示Boss归属
  local function showBossMaster( buff )
    local t = g_msgHandlerInst:convertBufferToTable( "WorldBossOwnerRetProtocol" , buff ) 
    if not self.bossMaster then
      self.bossMaster = createLabel( self.headbg , game.getStrByKey( "map_faction_owner" ) .. t.ownerName  , cc.p( 125 , 0 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.green )
      self.bossMaster:enableOutline(cc.c4b(0,0,0,255),1)
    else
      local text = tolua.cast( self.bossMaster , "cc.Label" )
      if text then
        local text_str = t.ownerName and (game.getStrByKey( "map_faction_owner" ) .. t.ownerName) or ""
        text:setString(text_str)
      end
    end
  end
  local monster_type = 1
  local monster_id = nil
  local monster_node = nil
  if params then
    monster_node = tolua.cast(params,"SpritePlayer")
    if monster_node then
      monster_id = monster_node:getMonsterId()
      if monster_id then
        monster_type = getConfigItemByKey("monster","q_id",monster_id,"q_type")
      end

      if monster_type and monster_type == 3 then --BOSS
        local tagid = monster_node:getTag()   --动态ID
        if tagid then
          g_msgHandlerInst:registerMsgHandler( WORLDBOSS_SC_OWNERID , showBossMaster )       --刷新
          g_msgHandlerInst:sendNetDataByTableExEx( WORLDBOSS_CS_GETOWNERID , "WorldBossGetOwnerProtocol", { bossID = tagid } )
        end
        
      end

    end
  end
  
  if monster_type and  monster_type >= 1 then
    monster_type = ( monster_type>4 and 2 or monster_type )
    local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true }

    if monster_type == 2 and  carCfg[ monster_id .. "" ] then
        monster_type = 5    --单人镖车
        -- local monsterParams = monster_node.params or {}
        local teamName = MRoleStruct:getAttr( ROLE_STATUS_NAME , monster_node:getTag() )
        if  teamName and teamName ~= "" then 
            monster_type = 6        --组队镖车
            createMenuItem( self.headbg , "res/layers/activity/cell/bodyguard/see_team.png" , cc.p( 186 , 12 ) , function() LOOK_TEAM( teamName ) end  )
        end
    end
    self.head_img:setTexture(def_cfg[monster_type])  
  end


  self.level_label = createLabel(self.headbg,"100",cc.p(53,22),false,15)

  self.buffNode = cc.Node:create()
  self.headbg:addChild(self.buffNode)
  self.buffNode:setPosition(cc.p(0, -17))

  self:updateInfo(params)

  if monster_type == 3 then
    self.head_img:setPositionX(self.head_img:getPositionX() + 7)
    self.head_img:setPositionY(self.head_img:getPositionY() -2)
    self.level_label:setPositionX(self.level_label:getPositionX() + 6)
    self.blood_label:setPositionX(self.blood_label:getPositionX() + 6)
    self.r_pro_blood:setPositionX(self.r_pro_blood:getPositionX() + 6)
  end

  local function eventCallback(eventType)
      if eventType == "enter" then

      elseif eventType == "exit" then
        if tipLayer then tipLayer:close() tipLayer = nil end 
      end
  end
  self:registerScriptHandler(eventCallback)
  local listenner = cc.EventListenerTouchOneByOne:create()
  listenner:setSwallowTouches( true )
  listenner:registerScriptHandler(function(touch, event) 
                  local pt = self:convertTouchToNodeSpace(touch)
                  if cc.rectContainsPoint(self.headbg:getBoundingBox(), pt) then
                      return true 
                  end
                  return false  
                  end, cc.Handler.EVENT_TOUCH_BEGAN)
  local eventDispatcher = self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
  local updateBlood = function()
    local monster_node = tolua.cast(self.node,"SpriteMonster")
    if monster_node then
      local hp = monster_node:getHP()
      if self.max_hp then
        self.blood_label:setString(""..hp.."/"..self.max_hp)
        if hp <= self.max_hp then
          self.r_pro_blood:setPercentage(hp/self.max_hp*100)
        end
       end

    end
  end
  schedule(self,updateBlood,0.5)

  if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 2124 then
    self.blood_label:setVisible(false)
  end
end

function MonsterBlood:updateInfo(monster_node)
  local monster_node = tolua.cast(monster_node,"SpriteMonster")
  if monster_node then
    self.node = monster_node
    self.monster_id = monster_node:getTag()
    local m_type = monster_node:getType()
    if m_type < 20 then
      self.head_img:setScale(1)
      if m_type < 12 then
        if m_type==10 then
          self.headbg:setTexture("res/monster/head/role_bg.png")
        else
          self.headbg:setTexture("res/monster/head/elite_bg.png")
        end 
      else
        self.headbg:setTexture("res/monster/head/boss_bg.png") 
      end
    else 
      self.headbg:setTexture("res/monster/head/role_bg.png") 
      local school = monster_node:getSchool()
      local sex = monster_node:getSex()
      self.head_img:setTexture("res/mainui/head/"..(school+(sex-1)*3)..".png")
      self.head_img:setScale(0.65)
    end
   
    local hp,mhp = monster_node:getHP(),monster_node:getMaxHP()
    self.max_hp = mhp
    local monster_id = monster_node:getMonsterId()
    local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true }
    if carCfg[ monster_id .. "" ] then
      self.name_label:setScale( 0.85 )
      local nameStr = monster_node:getTheName()
      if nameStr then
        -- nameStr = string.gsub( nameStr , "\n" , "(" )
        nameStr =  stringsplit(nameStr , "\n")
        self.name_label:setString( nameStr[1] )
      end
    else
      self.name_label:setString(monster_node:getTheName())
    end
    self.blood_label:setString(""..hp.."/"..mhp)
    self.level_label:setString(""..monster_node:getLevel())
    self.r_pro_blood:setPercentage(hp/mhp*100)
    --self:updateBuffer()
  end
end

function MonsterBlood:updateBloodAsUnknow()
  self.blood_label:setString("??/??")
end

function MonsterBlood:showOperate()
  if G_MAINSCENE.map_layer.isStory then
      return
  end
  if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
      return
  end
  local lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) or 0
  self.node = tolua.cast(self.node,"SpriteMonster")
  if self.node and self.node:getType() > 20 and (not self.node:getIsMonsterRole()) then
    local func = function(tag)
      local switch = {
        [1] = function() 
          PrivateChat(self.node:getTheName())
        end,
        [2] = function() 
          LookupInfo(self.node:getTheName())
        end,
        [3] = function() 
          InviteTeamUp(self.node:getTheName())
        end,
        -- [4] = function() 
        --   LookupBooth(self.node:getTheName())
        -- end,
        [4] = function() 
          AddFriends(self.node:getTheName())
        end,
        [5] = function() 
          AddBlackList(self.node:getTheName())
        end,
        [6] = function() 
          TradeWithRole(self.node)
        end,
        [7] = function() 
          SendFlower(self.node:getTheName())
        end,
        [8] = function() 
          --发送邀请入会协议
          g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_INVITE_JONE, "FactionInviteJoin", {opRoleName=self.node:getTheName()})
        end,
        [10] = function() 
          if lv >= 19 and lv <= 49 then
            AskForMaster(self.node:getTheName())
          elseif lv >= 50 then
            AskForStudent(self.node:getTheName())
          end 
        end,
        }
    if switch[tag] then switch[tag]() end
      removeFromParent(self.operate)
      self.operate = nil
    end
    local menus = {
      {game.getStrByKey("private_chat"),1,func},
      {game.getStrByKey("look_info"),2,func},
      {game.getStrByKey("re_team"),3,func},
      --{game.getStrByKey("look_shop"),4,func},
      {game.getStrByKey("addas_friend"),4,func},
      {game.getStrByKey("add_blackList"),5,func},
      {game.getStrByKey("trade"),6,func},
      {game.getStrByKey("send_flower_text"),7,func},
      {game.getStrByKey("faction_invite_member"),8,func},
    }

    if G_CONTROL:isFuncOn( GAME_SWITCH_ID_TRADE ) == false then
      table.remove( menus , 6 )
    end

    if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
      for i,v in ipairs(menus) do
        if v[1] == game.getStrByKey("send_flower_text") then
          table.remove(menus, i)
          break
        end
      end
    end

    if G_FACTION_INFO == nil or G_FACTION_INFO.job == nil or G_FACTION_INFO.job < 3 then
  		table.remove(menus, 8)
  	end
    
    if lv >= 19 and lv <= 49 and self.node:getLevel() >= 50 then
      table.insert(menus, #menus+1, {game.getStrByKey("master_apply_for_master"),10,func})
    elseif lv >= 50 and self.node:getLevel() >= 19 and self.node:getLevel() <= 49 then
      table.insert(menus, #menus+1, {game.getStrByKey("master_apply_for_student"),10,func})
    end

    if G_MAINSCENE and G_MAINSCENE.map_layer and (not G_MAINSCENE.map_layer.isJjc) and (not G_MAINSCENE.map_layer.isMine) then
      self.operate =  require("src/OperationLayer").new(self,1,menus)
      self.operate:setPosition(cc.p(-250,-580))
    end
  end
end

function MonsterBlood:updateBuffer()
  local roleId = self.node:getTag()
  local buffs = g_buffs[roleId]

  self.gainbuff = {}
  self.debuff = {}

  --dump(buffs)
  if buffs then
    for k,v in pairs(buffs) do
      local buff_type = getConfigItemByKey("buff", "id", tonumber(k), "effectType")
      if buff_type == 0 then
        table.insert(self.debuff, k)
      elseif buff_type == 1 then
        table.insert(self.gainbuff, k)
      end
    end
  end

  self:showBuffer()
end

function MonsterBlood:showBuffer()
  --dump(self.gainbuff)
  --dump(self.debuff)
  if self.gainBuffNode == nil then
    self.gainBuffNode = cc.Node:create()
    self.buffNode:addChild(self.gainBuffNode)
  else
    self.gainBuffNode:removeAllChildren()
  end

  if self.debuffNode == nil then
    self.debuffNode = cc.Node:create()
    self.buffNode:addChild(self.debuffNode)
    self.debuffNode:setPosition(cc.p(0, -17))
  else
    self.debuffNode:removeAllChildren()
  end 

  local gainBuffPosY = self.gainBuffNode:getPositionY()
  local debuffPosY = self.debuffNode:getPositionY()
  local scale = 0.5
  local iconBtn

  local function isBuffShow(id)
    return (getConfigItemByKey("buff", "id", id) ~= 0)
  end

  local function tipFun( key , pos )

    if tipLayer then tipLayer:close() tipLayer = nil end

    tipLayer = popupBox({ parent = getRunScene()  , 
             actionOff = { offX = 230 , offY = 0 } ,  
             bg = "res/layers/buff/" .. "tips_bg.png" ,  
                         isBgClickQuit = true , 
                         zorder = 200 , 
                         actionType = 5 ,
                         isNoSwallow = true , 
                       })

    local cfgData = getConfigItemByKey( "buff" , "id" )[ tonumber( key ) ]
    createLabel( tipLayer , cfgData.name  , cc.p( 50 , 230 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.yellow )
    createLabel( tipLayer , game.getStrByKey( "desc_text" ) , cc.p( 20 , 195 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.purple )
    local desc = createLabel( tipLayer , cfgData.desc_text or "" , cc.p( 20 , 180 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.white )
    desc:setDimensions( 310,0 )

    if  cfgData.statement and cfgData.statement == 1 then
      createLabel( tipLayer , game.getStrByKey( "addbuff" ) , cc.p( 20 , 20 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.green )
    end

  end

  for i,v in pairs(self.gainbuff) do
    if isBuffShow(v) then
      iconBtn = createMenuItem(self.gainBuffNode , "res/mainui/buff/"..getConfigItemByKey("buff", "id", v, "icon")..".png", cc.p(i*35 ,gainBuffPosY), function()  end)
      createSprite(iconBtn, "res/layers/buff/".."add.png", cc.p(iconBtn:getContentSize().width/2, iconBtn:getContentSize().height/2), cc.p(0.5 , 0.5))
      iconBtn:setScale(scale)
      Mnode.listenTouchEvent(
      {
          node = iconBtn,
          swallow = true,
          begin = function(touch, event)
            local node = event:getCurrentTarget()
            if node.catch then return false end
            
            local touchOutside = not Mnode.isTouchInNodeAABB(node, touch)
            if touchOutside then return false end

            local p = touch:getLocation()
            clickX , clickY = p.x, p.y
            
            node.catch = touch
            tipFun( v , pos )
            return true
          end,

          ended = function(touch, event)
            local node = event:getCurrentTarget()
            if node.catch == touch then
              node.catch = nil
              if tipLayer then tipLayer:close() tipLayer = nil end
            end
          end,
      })
    end
  end

  for i,v in pairs(self.debuff) do
    if isBuffShow(v) then
      iconBtn = createMenuItem(self.debuffNode , "res/mainui/buff/"..getConfigItemByKey("buff", "id", v, "icon")..".png", cc.p(i*35 ,debuffPosY), function()  end)
      createSprite(iconBtn, "res/layers/buff/".."add.png", cc.p(iconBtn:getContentSize().width/2, iconBtn:getContentSize().height/2), cc.p(0.5 , 0.5))
      iconBtn:setScale(scale)
      Mnode.listenTouchEvent(
      {
          node = iconBtn,
          swallow = true,
          begin = function(touch, event)
            local node = event:getCurrentTarget()
            if node.catch then return false end
            
            local touchOutside = not Mnode.isTouchInNodeAABB(node, touch)
            if touchOutside then return false end

            local p = touch:getLocation()
            clickX , clickY = p.x, p.y
            
            node.catch = touch
            tipFun( v , pos )
            return true
          end,

          ended = function(touch, event)
            local node = event:getCurrentTarget()
            if node.catch == touch then
              node.catch = nil
              if tipLayer then tipLayer:close() tipLayer = nil end
            end
          end,
      })
    end
  end
end

return MonsterBlood