
local RoomView = classGc(view, function(self)
  self.stype = 1
  self.playuid = nil
  self.mainplay = _G.GPropertyProxy : getMainPlay()
end)

local COLOR_SELECT=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE)
local COLOR_NORMAL=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE)
local TeamList = _G.Cfg.copy_chap[1][10100].copy_id
local FontSize = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local pSize  = cc.size( 835, 492 )
local dSize  = cc.size(627,492)
local leftSize = cc.size(216,492)
local rightSize = cc.size(627,492)

local INVITE= 1
local WORD  = 2
local SECEDE= 3
local START = 4
local KICK1 = 101
local KICK2 = 102
local CLOSE = 250

function RoomView.create( self,_data)
  print("==========>_data",_data,teamId,self.leftSpr,self.rightSpr)
  self.roomNode=cc.Node:create()
  local doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
  doubleSpr : setContentSize( dSize )
  doubleSpr : setPosition(pSize.width/2-dSize.width/2+6, -52 )
  self.roomNode:addChild( doubleSpr )

  self.leftSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
  self.leftSpr : setContentSize( leftSize )
  self.leftSpr : setPosition(leftSize.width/2-pSize.width/2-6, -52 )
  self.roomNode:addChild( self.leftSpr )

  self.rightSpr = cc.Node:create()
  -- self.rightSpr : setContentSize( rightSize )
  self.rightSpr : setPosition(-192, -rightSize.height/2-52 )
  self.roomNode:addChild( self.rightSpr )

  self : LeftView(_data)
  self : RightView(_data)
  return self.roomNode
end

function RoomView.LeftView( self,_data)
  local teamData = _G.Cfg.scene_copy[_data.copy_id]
  if teamData == nil then return end
  local szIcon="copyui_icon_10101.png"
  if teamData.scene and teamData.scene[1] then
    local sceneId=teamData.scene[1].id
    local sceneCnf=get_scene_data(sceneId)
    if sceneCnf then
      local materialCnf=_G.MapData[sceneCnf.material_id]
      if materialCnf then
        local newIcon=string.format("copyui_icon_%d.png",materialCnf.small_id)
        newIcon="copyui_icon_0.png"
        local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(newIcon)
        local iconSpr
        if spriteFram~=nil then
            iconSpr=cc.Sprite:createWithSpriteFrame(spriteFram)
        else
            iconSpr=cc.Sprite:createWithSpriteFrameName(szIcon)
        end
        iconSpr:setPosition(leftSize.width/2,leftSize.height-80)
        self.leftSpr:addChild(iconSpr)

        local iconSize=iconSpr:getContentSize()
        local icondec=cc.Sprite:createWithSpriteFrameName("copyui_dec_bg.png")
        icondec:setPosition(iconSize.width/2+8,33)
        iconSpr:addChild(icondec)
      end
    end
  end

  local teamImg = teamData.img[1]
  print("tupian------>",teamImg)
  local headSpr=nil
  if teamImg>0 then
    local szHead=string.format("h%d.png",teamImg)
    headSpr=gc.GraySprite:createWithSpriteFrameName(szHead)
    headSpr:setPosition(leftSize.width/2,leftSize.height-80)
    self.leftSpr:addChild(headSpr)
  end

  self.teamLv = teamData.lv
  -- local nameLabel=_G.Util:createLabel(self.teamLv.."级",FontSize+2)
  -- nameLabel:setPosition(leftSize.width*0.7,leftSize.height*0.9)
  -- nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  -- self.leftSpr:addChild(nameLabel)

  local teamName = teamData.copy_name
  local nameLabel=_G.Util:createLabel(string.format("%d %s",self.teamLv,teamName),FontSize)
  nameLabel:setPosition(leftSize.width/2+10,leftSize.height-130)
  -- nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.leftSpr:addChild(nameLabel)

  -- local tipSpr=cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
  -- tipSpr:setPosition(27,leftSize.height-148)
  -- self.leftSpr:addChild(tipSpr)

  local strLabel=_G.Util:createLabel("每达成一个条件奖励一颗星",FontSize)
  strLabel:setPosition(20,leftSize.height/2+50)
  -- strLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  strLabel:setAnchorPoint( cc.p(0.0,0.5) )
  strLabel:setDimensions(leftSize.width-20, 60)
  self.leftSpr:addChild(strLabel)

  local termLab1 = _G.Util:createLabel("成功通关",FontSize)
  termLab1 : setAnchorPoint( cc.p(0,0.5) )
  termLab1 : setPosition(37,leftSize.height/2)
  -- termLab1 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  self.leftSpr:addChild(termLab1) 

  local teamLab = teamData.over_score
  local termStr = "尽情杀吧"
  local termStr1="存活人数不少于"
  local termStr2="人"
  if teamLab[1][1] == 1 then
    termStr = teamLab[1][2]
    termStr1="存活人数不少于"
    termStr2="人"
  elseif teamLab[1][1] == 2 then
    local time = teamLab[1][2]/60
    termStr = time
    termStr1="时间不超过"
    termStr2="分钟"
  end

  local termLab2=_G.Util:createLabel(termStr1,FontSize)
  termLab2:setAnchorPoint( cc.p(0,0.5) )
  termLab2:setPosition(37,leftSize.height/2-40)
  -- termLab2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  self.leftSpr:addChild(termLab2)

  local labWidth=37+termLab2:getContentSize().width
  local termLabNum=_G.Util:createLabel(termStr,FontSize)
  termLabNum:setAnchorPoint( cc.p(0,0.5) )
  termLabNum:setPosition(labWidth,leftSize.height/2-40)
  termLabNum:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  self.leftSpr:addChild(termLabNum)

  local termLabs=_G.Util:createLabel(termStr2,FontSize)
  termLabs:setAnchorPoint( cc.p(0,0.5) )
  termLabs:setPosition(labWidth+termLabNum:getContentSize().width,leftSize.height/2-40)
  -- termLabs:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  self.leftSpr:addChild(termLabs)

  if teamLab[2][1] == 1 then
    termStr =teamLab[2][2]
    termStr1="存活人数不少于"
    termStr2="人"
  elseif teamLab[2][1] == 2 then
    local time = teamLab[2][2]/60
    termStr = time
    termStr1="时间不超过"
    termStr2="分钟"
  end
  local termLab3=_G.Util:createLabel(termStr1,FontSize)
  termLab3:setAnchorPoint( cc.p(0,0.5) )
  termLab3:setPosition(37,leftSize.height/2-80)
  -- termLab3:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  self.leftSpr:addChild(termLab3)

  local labWidth=37+termLab3:getContentSize().width
  local termLabNum=_G.Util:createLabel(termStr,FontSize)
  termLabNum:setAnchorPoint( cc.p(0,0.5) )
  termLabNum:setPosition(labWidth,leftSize.height/2-80)
  termLabNum:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  self.leftSpr:addChild(termLabNum)

  local termLabs=_G.Util:createLabel(termStr2,FontSize)
  termLabs:setAnchorPoint( cc.p(0,0.5) )
  termLabs:setPosition(labWidth+termLabNum:getContentSize().width,leftSize.height/2-80)
  -- termLabs:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  self.leftSpr:addChild(termLabs)

  for i=1,3 do
    local starSpr = cc.Sprite:createWithSpriteFrameName("general_star2.png")
    starSpr : setPosition(leftSize.width*0.1,leftSize.height/2-(i-1)*40)
    self.leftSpr:addChild(starSpr)
  end

  self : ChatView()
end

function RoomView.Chatdestroy(self)
  if self.m_chatWindow then
      self.m_chatWindow:destroy()
      self.m_chatWindow=nil
  end
end

function RoomView.ChatView(self)
  local chatSprSize=cc.size(leftSize.width-4,110)
  local chatSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
  -- local lineHeight = chatSpr:getContentSize().height
  chatSpr:setPreferredSize(chatSprSize)
  chatSpr:setPosition(leftSize.width/2,70)
  self.leftSpr:addChild(chatSpr)

  -- local chatlineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_line_gold.png")
  -- chatlineSpr:setPreferredSize(cc.size(leftSize.width,lineHeight))
  -- chatlineSpr:setPosition(leftSize.width/2,chatSprSize.height)
  -- chatSpr:addChild(chatlineSpr)

  local chatViewSize=cc.size(chatSprSize.width-4,chatSprSize.height-10)
  local chatWindow=require("mod.chat.ChatWindow")(true,chatViewSize,10)
  local chatNode=chatWindow:create()
  chatNode:setPosition(5,5)
  chatSpr:addChild(chatNode)
  self.m_chatWindow=chatWindow
  -- self.m_chatWindow:showOnlyChannel(_G.Const.CONST_CHAT_TEAM)

  -- local chatSize = chatSpr:getContentSize()
  local function onChatCallBack(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      print("输入聊天内容")
      _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,{dataType=_G.Const.kChatDataTypeTeam})
    end
  end
  local chatBtn = gc.CButton:create()
  chatBtn : loadTextures("general_chat_btn.png")
  chatBtn : setPosition(chatSprSize.width-22, chatSprSize.height+7)
  chatBtn : addTouchEventListener(onChatCallBack)
  -- chatBtn : setButtonScale(0.7)
  chatSpr : addChild(chatBtn)
end

function RoomView.RightView( self,_data )
  if _data == nil or _data.data == nil then return end
  self.copy_id = _data.copy_id
  self.m_teamId= _data.team_id
  self.playWidth = (rightSize.width-12)/3
  self.bgSize = cc.size(198,398)

  self.inviteBtn={1,2,3}
  self.wordBtn = {1,2,3}
  local function onBtnCallBack(sender, eventType)
    self:onCallBack(sender, eventType)
  end
  local spriteFrame=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendbg.png")
  spriteFrame:setPreferredSize(cc.size(rightSize.width,84))
  spriteFrame:setPosition(rightSize.width/2-11,43)
  self.rightSpr:addChild(spriteFrame)

  for i=1,3 do
    local playerBg = ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
    playerBg : setPosition(self.playWidth/2-6+(i-1)*(self.playWidth),rightSize.height/2+38)
    playerBg : setPreferredSize(self.bgSize)
    self.rightSpr : addChild(playerBg)
    
    -- local guangSpr=cc.Sprite:createWithSpriteFrameName("general_rolebg2.png")
    -- guangSpr : setPosition(self.bgSize.width/2,self.bgSize.height/2)
    -- playerBg : addChild(guangSpr)

    self.inviteBtn[i] = gc.CButton:create()
    self.inviteBtn[i] : loadTextures("general_btn_lv.png")
    self.inviteBtn[i] : setPosition(self.bgSize.width/2, self.bgSize.height/2+45)
    self.inviteBtn[i] : setTitleFontName(_G.FontName.Heiti)
    self.inviteBtn[i] : setTitleFontSize(FontSize+2)
    self.inviteBtn[i] : setTitleText("邀  请")
    self.inviteBtn[i] : setTag(INVITE)
    self.inviteBtn[i] : addTouchEventListener(onBtnCallBack)
    playerBg : addChild(self.inviteBtn[i])

    self.wordBtn[i] = gc.CButton:create()
    self.wordBtn[i] : loadTextures("general_btn_gold.png")
    self.wordBtn[i] : setPosition(self.bgSize.width/2, self.bgSize.height/2-30)
    self.wordBtn[i] : setTitleFontName(_G.FontName.Heiti)
    self.wordBtn[i] : setTitleFontSize(FontSize+2)
    self.wordBtn[i] : setTitleText("世界邀请")
    self.wordBtn[i] : setTag(WORD)
    self.wordBtn[i] : addTouchEventListener(onBtnCallBack)
    playerBg : addChild(self.wordBtn[i])
  end

  -- local Btndouble = ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
  -- Btndouble : setPosition(rightSize.width/2+1,34)
  -- Btndouble : setPreferredSize(cc.size(rightSize.width-2,68))
  -- self.rightSpr : addChild(Btndouble)

  local function onBtnCallBack(sender, eventType)
    self:onCallBack(sender, eventType)
  end
  local secedeBtn = gc.CButton:create()
  secedeBtn : loadTextures("general_btn_lv.png")
  secedeBtn : setPosition(rightSize.width/2-100, 38)
  secedeBtn : setTitleFontName(_G.FontName.Heiti)
  secedeBtn : setTitleFontSize(FontSize+2)
  secedeBtn : setTitleText("退出房间")
  secedeBtn : setTag(SECEDE)
  secedeBtn : addTouchEventListener(onBtnCallBack)
  self.rightSpr : addChild(secedeBtn)

  self.startBtn = gc.CButton:create()
  self.startBtn : loadTextures("general_btn_gold.png")
  self.startBtn : setPosition(rightSize.width/2+100, 38)
  self.startBtn : setTitleFontName(_G.FontName.Heiti)
  self.startBtn : setTitleFontSize(FontSize+2)
  self.startBtn : setTitleText("开始挑战")
  self.startBtn : setTag(START)
  --self.startBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  self.startBtn : addTouchEventListener(onBtnCallBack)
  self.rightSpr : addChild(self.startBtn)

  self : RightData(_data)
end

function RoomView.RightData(self,_data,roleData)
  if _data == nil or _data.data == nil then return end

  local function onBtnCallBack(sender, eventType)
    self:onCallBack(sender, eventType)
  end

  if self.playerWid~=nil then
    for k,v in pairs(self.playerWid) do
        v : removeFromParent(true)
    end
  end

  for i=1,3 do
    self.wordBtn[i]:setVisible(true)
    self.inviteBtn[i]:setVisible(true)
  end

  self.playerWid = {}
  for k,v in pairs(_data.data) do
    print("_data.data",k,v.name,v.lv,v.uid,v.pos)
    self.wordBtn[v.pos]:setVisible(false)
    self.inviteBtn[v.pos]:setVisible(false)
    -- if self.playerWid[v.uid]==nil then
      self.playerWid[v.uid] = cc.Node:create()
      -- self.playerWid[v.uid] : setContentSize(self.bgSize)
      self.playerWid[v.uid] : setPosition((v.pos-1)*(self.playWidth)-3,75)
      self.rightSpr : addChild(self.playerWid[v.uid])

      self.nameLab = _G.Util:createLabel(v.name,FontSize)
      self.nameLab : setPosition(self.playWidth/2,self.bgSize.height-30)
      self.nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
      self.playerWid[v.uid] : addChild(self.nameLab)

      local playlvLab = _G.Util:createLabel("LV."..v.lv,FontSize)
      playlvLab:setPosition(self.bgSize.width/2,self.bgSize.height-55)
      -- playlvLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
      self.playerWid[v.uid] : addChild(playlvLab)

      -- self.lvLabel = _G.Util:createLabel(v.lv,FontSize)
      -- self.lvLabel : setPosition(self.bgSize.width/2+5,self.bgSize.height-55)
      -- self.lvLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
      -- self.lvLabel : setAnchorPoint( cc.p(0,0.5) )
      -- self.playerWid[v.uid] : addChild(self.lvLabel)

      local playzlNode = self : updatePower(v.power)
      playzlNode : setPosition(40,30)
      self.playerWid[v.uid] : addChild(playzlNode)

      local spine = self : PlayerSpine(v.pro)
      spine : setScale(1.1)
      self.playerWid[v.uid] : addChild(spine)

      local playerUid = self.mainplay : getUid()
      if v.uid == _data.leader_uid then
          local captainSpr = cc.Sprite:createWithSpriteFrameName("general_captain.png")
          captainSpr : setPosition(34,self.bgSize.height-30)
          self.playerWid[v.uid] : addChild(captainSpr)   
      else
          local closeBtn = gc.CButton:create()
          closeBtn : loadTextures("general_close_second_1.png")
          closeBtn : setPosition(25,self.bgSize.height-15)
          closeBtn : addTouchEventListener(onBtnCallBack)
          closeBtn : setTag(v.uid)
          closeBtn : setSoundPath("bg/ui_sys_clickoff.mp3")
          self.playerWid[v.uid] : addChild(closeBtn)
          if _data.leader_uid == playerUid then
            closeBtn : setVisible(true)
          else
            closeBtn : setVisible(false)
          end
      end

      print("playerUid",_data.leader_uid,playerUid)
      if _data.leader_uid == playerUid then
        self.inviteBtn[v.pos] : setBright(true)
        self.inviteBtn[v.pos] : setEnabled(true)
        self.wordBtn[v.pos]   : setBright(true)
        self.wordBtn[v.pos]   : setEnabled(true)
      elseif _data.leader_uid ~= playerUid then
        self.inviteBtn[v.pos] : setBright(false)
        self.inviteBtn[v.pos] : setEnabled(false)
        self.wordBtn[v.pos]  : setBright(false)
        self.wordBtn[v.pos]  : setEnabled(false)
      end
    end
  -- end

  local playerUid = self.mainplay : getUid()
  if _data.leader_uid == playerUid then
    for i=1, 3 do 
      self.inviteBtn[i] : setBright(true)
      self.inviteBtn[i] : setEnabled(true)
      self.wordBtn[i]   : setBright(true)
      self.wordBtn[i]   : setEnabled(true)
    end
    self.startBtn : setBright(true)
    self.startBtn : setEnabled(true)
  else
    for i=1, 3 do 
      self.inviteBtn[i] : setBright(false)
      self.inviteBtn[i] : setEnabled(false)
      self.wordBtn[i]   : setBright(false)
      self.wordBtn[i]   : setEnabled(false)
    end
    self.startBtn : setBright(false)
    self.startBtn : setEnabled(false)
  end
end

function RoomView.updatePower(self,powerful)
    print("createPowerfulIcon====",powerful)
    -- local powerful=tostring(powerful)
    -- local length=string.len(powerful)
    m_powerNode=cc.Node:create()
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setScale(0.98)
    powerSpr:setPosition(60,15)
    m_powerNode:addChild(powerSpr)
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setScale(0.98)
    powerSpr:setPosition(60,15)
    m_powerNode:addChild(powerSpr)
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setScale(0.98)
    powerSpr:setPosition(60,15)
    m_powerNode:addChild(powerSpr)

    local tempLab=_G.Util:createBorderLabel(string.format("战力:%d",powerful),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- tempLab:setAnchorPoint(cc.p(0,0.5))
    tempLab:setPosition(60,15)
    m_powerNode : addChild(tempLab)

    -- local powerSprSize=powerSpr:getContentSize()
    -- local spriteWidth=37
    -- for i=1,length do
    --     local tempSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_"..string.sub(powerful,i,i)..".png")
    --     tempSpr:setScale(0.8)
    --     m_powerNode : addChild(tempSpr)

    --     local tempSprSize=tempSpr:getContentSize()
    --     spriteWidth=spriteWidth+tempSprSize.width/2+5
    --     tempSpr:setPosition(spriteWidth,0)
    -- end
    
    return m_powerNode
end

function RoomView.PlayerSpine(self,pro)
    local shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    shadow:setPosition(cc.p(self.bgSize.width/2,85))

    local shaSize = shadow : getContentSize()
    local m_skeleton=_G.SpineManager.createPlayer(pro)
    m_skeleton:setAnimation(0,"idle",true)
    m_skeleton:setPosition(shaSize.width/2,shaSize.height/2)
    shadow:addChild(m_skeleton)

    --_G.SpineManager.createPlayer(pro)  --其余玩家

    return shadow
end

function RoomView.InviteTips(self)
  local tipSize = cc.size(618,417)
  local function onTouchBegan(touch)
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(m_winSize.width/2-tipSize.width/2,m_winSize.height/2-tipSize.height/2,
        tipSize.width,tipSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
          return true
        end
        self:delayCallFun()
        self.stype=1
        return true 
  end
  local tipslisterner=cc.EventListenerTouchOneByOne:create()
  tipslisterner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  tipslisterner:setSwallowTouches(true)
  
  self.TipsAction=cc.LayerColor:create(cc.c4b(0,0,0,150))
  -- self.TipsAction:setContentSize(tipSize)
  -- self.TipsAction:setPosition(m_winSize.width/2,m_winSize.height/2)
  self.TipsAction:getEventDispatcher():addEventListenerWithSceneGraphPriority(tipslisterner,self.TipsAction)
  cc.Director:getInstance():getRunningScene():addChild(self.TipsAction,1000)

  local tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
  tipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
  tipSpr : setPreferredSize(tipSize)
  self.TipsAction : addChild(tipSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(tipSize.width/2-120, tipSize.height-25)
  tipSpr : addChild(tipslogoSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(tipSize.width/2+125, tipSize.height-25)
  tipslogoSpr : setRotation(180)
  tipSpr : addChild(tipslogoSpr)

  local logoLab= _G.Util : createBorderLabel("邀 请", FontSize+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  logoLab : setPosition(tipSize.width/2, tipSize.height-25)
  -- logoLab : setAnchorPoint( cc.p(0.0,0.5) )
  tipSpr  : addChild(logoLab)

  local function close(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      local tipTag = sender : getTag()
      self:tipsBtnCallBack(tipTag)
    end
  end

  self.upBtn = {1,2,3,4}
  self.tagNode = {1,2,3,4}
  local btnstr = {"附近玩家","我的好友","门派成员","铜钱雇佣"}
  for i=1,4 do
    self.upBtn[i]=gc.CButton:create("general_btn_weixuan.png","general_btn_selected.png","general_btn_selected.png")
    self.upBtn[i]:setPosition(100+(i-1)*135,tipSize.height-76)
    self.upBtn[i]:addTouchEventListener(close)
    self.upBtn[i]:setTag(i)
    -- self.upBtn[i]:setButtonScale(0.8)
    tipSpr:addChild(self.upBtn[i])

    local btnLab = _G.Util:createBorderLabel(btnstr[i],FontSize,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE))
    btnLab:setPosition(60,20)
    btnLab:setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
    btnLab:setTag(1122)
    self.upBtn[i]:addChild(btnLab)
  end
  self.upBtn[1]:setBright(false)
  self.upBtn[1]:setEnabled(false)
  self.upBtn[1]:getChildByTag(1122):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))

  local doubleSize = cc.size(601,317)
  local di2kuanSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
  di2kuanSpr : setPreferredSize(doubleSize)
  di2kuanSpr : setPosition(tipSize.width/2,tipSize.height/2-40)
  tipSpr : addChild(di2kuanSpr)

  self.floorSize=cc.size(tipSize.width-23,275)
  self.kuangSpr = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" )
  self.kuangSpr : setPreferredSize( self.floorSize )
  self.kuangSpr : setPosition(tipSize.width/2,tipSize.height/2-60 )
  tipSpr : addChild( self.kuangSpr )

  local inviteStr = {"名字","等级","战力","操作"}
  for i=1,4 do
    local inviteLab = _G.Util:createLabel(inviteStr[i],FontSize)
    inviteLab:setPosition(100+(i-1)*130,doubleSize.height-25)
    inviteLab:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.kuangSpr : addChild(inviteLab)
  end
  -- for i=1,3 do
  --   local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" )
  --   local lineSize = lineSpr:getContentSize()
  --   lineSpr : setScaleX(36/lineSize.width)
  --   lineSpr : setPosition(140+(i-1)*125,18 )
  --   lineSpr : setRotation(-90)
  --   baseSpr : addChild( lineSpr )
  -- end
end

function RoomView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.TipsAction~=nil then
            self.TipsAction:removeFromParent(true)
            self.TipsAction=nil
            self.tipsScro=nil
        end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.TipsAction:runAction(cc.Sequence:create(delay,func))
end

function RoomView.tipsBtnCallBack( self,tipTag)
    for i=1, 4 do
        if i ~= tipTag then
            self.upBtn[i]:setBright(true)
            self.upBtn[i]:setEnabled(true)
            self.upBtn[i]:getChildByTag(1122):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE))
        else
            self.upBtn[i]:setBright(false)
            self.upBtn[i]:setEnabled(false)
            self.upBtn[i]:getChildByTag(1122):setTextColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
            local msg = REQ_TEAM_INVITE_LIST()
            msg:setArgs(i,self.teamLv)
            _G.Network:send(msg)
            self.stype = i
        end
    end
end

function RoomView.tipScrollView( self,_data)
  if self.tipsScro ~= nil then
      self.tipsScro : removeFromParent(true)
      self.tipsScro = nil
  end
  if _data.count > 20 then _data.count = 20 end
  self.oneHeight = (self.floorSize.height-10)/4
  local viewSize = cc.size(self.floorSize.width,self.floorSize.height-10)
  local scrollViewSize = cc.size(self.floorSize.width,self.oneHeight*_data.count)
  local contentView = cc.ScrollView:create()
  contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  contentView : setViewSize(viewSize)
  contentView : setContentSize(scrollViewSize)
  contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  contentView : setPosition(cc.p(0,4))
  self.kuangSpr : addChild(contentView)
  if viewSize.height<scrollViewSize.height then 
    local barView=require("mod.general.ScrollBar")(contentView)
    barView:setPosOff(cc.p(-5,0))
  end

  self.tipsScro = contentView
  self.intuidBtn = {}
  self.dataV = {}
  self.datapow={}
  for k,v in pairs(_data.msg) do
    print("_data.msg",k,v.name)
    self.dataV[k] = v
  end
  for i=1,_data.count do
    local onePlay = self:OnePlayerNews(self.dataV[i])
    onePlay : setPosition(self.floorSize.width/2,scrollViewSize.height-self.oneHeight/2-(i-1)*self.oneHeight)
    contentView : addChild(onePlay)
  end
end

function RoomView.OnePlayerNews(self,_data)
  if _data == nil then return end
  local oneWidget = ccui.Scale9Sprite:createWithSpriteFrameName("general_noit.png")
  oneWidget : setContentSize(cc.size(self.floorSize.width-10,self.oneHeight-4))

  local Name = _data.name or "无"
  local nameLab = _G.Util:createLabel(Name,FontSize)
  nameLab:setPosition(90,self.oneHeight/2-4)
  -- nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWidget : addChild(nameLab)

  local LV = _data.lv or 0
  local lvLab = _G.Util:createLabel(LV,FontSize)
  lvLab:setPosition(220,self.oneHeight/2-4)
  -- lvLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWidget : addChild(lvLab)

  local Powerful = _data.powerful or 0
  local powLab = _G.Util:createLabel(Powerful,FontSize)
  powLab:setPosition(355,self.oneHeight/2-4)
  -- powLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  oneWidget : addChild(powLab)

  self.datapow[_data.uid]=Powerful

  local function inviteBack(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      local uidTag = sender : getTag()
      print("邀请玩家的id",uidTag,self.stype,self.mainplay : getGold())
      local Position = sender : getWorldPosition()
      print("Position.y",Position.y,m_winSize.height/2-self.floorSize.height/2-82)
      if Position.y > m_winSize.height/2+self.floorSize.height/2-90 or 
        Position.y < m_winSize.height/2-self.floorSize.height/2-82 then
      return end
      if self.stype==4 then
          local GoldNum=self.datapow[uidTag]
          local szMsg=string.format("花费与该玩家战力对等的%d铜钱雇佣金雇佣？\n(踢出雇佣后玩家不会返还雇佣金)",GoldNum)
          if self.mainplay : getGold() < GoldNum then
              szMsg="铜钱不足，是否前往招财？"
          end
          local function fun1()
            if self.mainplay : getGold() < GoldNum then
                if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_LUCKY) then return false end
                    _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_LUCKY)
                return
            end
            local msg = REQ_TEAM_INVITE()
            msg:setArgs(uidTag,self.stype)
            _G.Network:send(msg)
          end
          _G.Util:showTipsBox(szMsg,fun1)
          self.playuid = uidTag
      else
        local msg = REQ_TEAM_INVITE()
        msg:setArgs(uidTag,self.stype)
        _G.Network:send(msg)
        self.playuid = uidTag
      end
    end
  end

  local Str="邀 请"
  local inStr="已邀请"
  if self.stype==4 then
      Str="雇 佣"
      inStr="已雇佣"
  end

  local intBtn=gc.CButton:create("general_btn_gold.png")
  intBtn:setPosition(self.floorSize.width-110,self.oneHeight/2-4)
  intBtn:setTitleFontName(_G.FontName.Heiti)
  intBtn:setTitleFontSize(FontSize+2)
  intBtn:setTitleText(Str)
  intBtn:addTouchEventListener(inviteBack)
  -- intBtn:setButtonScale(0.8)
  intBtn:setTag(_data.uid)
  oneWidget:addChild(intBtn)
  if _data.state == 1 then
    intBtn:setTitleText(inStr)
    intBtn:setBright(false)
    intBtn:setEnabled(false)
  end
  self.intuidBtn[_data.uid] = {}
  self.intuidBtn[_data.uid].Btn = intBtn

  return oneWidget
end

function RoomView.onCallBack( self,sender, eventType)
  if eventType == ccui.TouchEventType.ended then
    local btnTag = sender : getTag()
    if btnTag == INVITE then
      print("进入邀请Tips")
      local msg = REQ_TEAM_INVITE_LIST()
      msg:setArgs(1,self.teamLv)
      _G.Network:send(msg)
      self : InviteTips()
    elseif btnTag == WORD then
      print("发送世界邀请",self.m_teamId,self.copy_id)
      _G.GChatProxy:requestInviteTeam(self.m_teamId,self.copy_id)
    elseif btnTag == SECEDE then
      print("退出房间")
      local msg = REQ_TEAM_LEAVE()
      _G.Network:send(msg)

      local command = CTeamCommand()
      _G.controller :sendCommand( command )
    elseif btnTag == START then
      print("开始挑战",self.copy_id)
      local msg = REQ_COPY_CREAT()
      msg:setArgs(self.copy_id)
      _G.Network:send(msg)
    else
      print("踢掉",btnTag)
      local msg = REQ_TEAM_KICK()
      msg:setArgs(btnTag)
      _G.Network:send(msg)
      if self.playerWid[btnTag] ~= nil then
        self.playerWid[btnTag] : removeFromParent(true)
        self.playerWid[btnTag] = nil
      end
    end
  end
end

function RoomView.closeRoom(self)
  self.roomNode:removeFromParent(true)
  self.roomNode=nil 
  self:Chatdestroy()
end

function RoomView.ListRealy(self,_data)
  if _data.type == nil then return end
  self : tipScrollView(_data)
end

function RoomView.Invite(self)
  print("Invite")
  local inStr="已邀请"
  if self.stype==4 then
      inStr="已雇佣"
  end
  self.intuidBtn[self.playuid].Btn:setTitleText(inStr)
  self.intuidBtn[self.playuid].Btn:setBright(false)
  self.intuidBtn[self.playuid].Btn:setEnabled(false) 
end

return RoomView

