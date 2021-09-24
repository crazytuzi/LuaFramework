local InviteMediator = classGc(mediator, function(self, _view)
    self.name = "InviteMediator"
    self.view = _view
    self:regSelf()
end)

InviteMediator.protocolsList={
    _G.Msg["ACK_TEAM_LIVE_REP"],       -- 查询队伍返回
}
function InviteMediator.ACK_TEAM_LIVE_REP(self, _ackMsg)
    print("ACK_TEAM_LIVE_REP ")
    self:getView():AcceptInvite(_ackMsg)
end

local InviteView = classGc(view, function(self,_data)
  self.data = _data
  self.pMediator= InviteMediator(self)
  _G.GFriendProxy:removeAllInviteTeamArray()
end)

local FontSize = 20
local tipSize = cc.size(619,372)
local SecondSize=cc.size(600,317)
local m_winSize=cc.Director:getInstance():getWinSize()
-- local mainplay = _G.GPropertyProxy : getMainPlay()

function InviteView.create( self )
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
      return true
  end
  local listerner=cc.EventListenerTouchOneByOne:create()
  listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  listerner:setSwallowTouches(true)

  self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
  self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

  -- local tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
  -- tipSpr : setPreferredSize(tipSize)
  -- tipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
  -- self.m_rootLayer : addChild(tipSpr)

  local tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
  tipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
  tipSpr : setPreferredSize(tipSize)
  self.m_rootLayer : addChild(tipSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(tipSize.width/2-125, tipSize.height-28)
  tipSpr : addChild(tipslogoSpr)

  local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
  titleSpr:setPosition(tipSize.width/2+120,tipSize.height-28)
  titleSpr:setRotation(180)
  tipSpr:addChild(titleSpr)

  local logoLab= _G.Util : createBorderLabel("邀 请", FontSize+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  logoLab : setPosition(tipSize.width/2, tipSize.height-26)
  tipSpr  : addChild(logoLab)

  -- local function close(sender, eventType)
  --   if eventType==ccui.TouchEventType.ended then
  --     self : closeView(sender,eventType)
  --   end
  -- end
  -- local m_closeBtn=gc.CButton:create("general_close.png")
  -- m_closeBtn:setPosition(tipSize.width-7,tipSize.height-7)
  -- m_closeBtn:addTouchEventListener(close)
  -- m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
  -- tipSpr:addChild(m_closeBtn)

  -- local inviteLab = _G.Util:createLabel("组队邀请",FontSize+8)
  -- inviteLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  -- inviteLab:setPosition(tipSize.width/2,tipSize.height-30)
  -- tipSpr:addChild(inviteLab)

  self.doubleSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
  self.doubleSpr : setPreferredSize(SecondSize)
  self.doubleSpr : setPosition(tipSize.width/2,tipSize.height/2-17)
  tipSpr : addChild(self.doubleSpr)

  local bluebgSpr = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" )
  bluebgSpr : setPreferredSize( cc.size(SecondSize.width-2,274) )
  bluebgSpr : setPosition(SecondSize.width/2,SecondSize.height/2-22 )
  self.doubleSpr : addChild( bluebgSpr )

  local teamStr = {"副本名字","队长名字","战力","操作"}
  for i=1,4 do
    local teamLab = _G.Util:createLabel(teamStr[i],FontSize)
    teamLab:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    teamLab:setPosition(110+(i-1)*130,SecondSize.height-25)
    -- if i==1 then teamLab:setPosition(100,25) end
    self.doubleSpr : addChild(teamLab)
  end

  if self.data~=nil then
    self : tipScrollView()
  end

  return self.m_rootLayer
end

function InviteView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.m_rootLayer~=nil then
            self.m_rootLayer:removeFromParent(true)
            self.m_rootLayer=nil
        end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.m_rootLayer:runAction(cc.Sequence:create(delay,func))
end

function InviteView.tipScrollView( self )
  self.oneHeight = (SecondSize.height-50)/4
  local Count = #self.data
  local viewSize = cc.size(SecondSize.width-4,SecondSize.height-50)
  local scrollViewSize = cc.size(SecondSize.width-4,self.oneHeight*Count)
  local contentView = cc.ScrollView:create()
  contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  contentView : setViewSize(viewSize)
  contentView : setContentSize(scrollViewSize)
  contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  contentView : setPosition(cc.p(0,3))
  self.doubleSpr : addChild(contentView)
  if viewSize.height<scrollViewSize.height then 
    local barView=require("mod.general.ScrollBar")(contentView)
    barView:setPosOff(cc.p(-4,0))
  end

  for k,v in pairs(self.data) do
    print("self.data",k,v.type,v.uname,v.powerful,v.copy_id,v.team_id)
    local onePlay = self:OnePlayerNews(v)
    onePlay : setPosition(SecondSize.width/2,scrollViewSize.height-self.oneHeight/2-(k-1)*self.oneHeight)
    contentView : addChild(onePlay)
  end
end

function InviteView.OnePlayerNews(self,m_msg)
  if m_msg == nil then return end

  local oneWidget = ccui.Scale9Sprite:createWithSpriteFrameName("general_noit.png")
  oneWidget : setContentSize(cc.size(SecondSize.width-16,self.oneHeight-4))

  print("m_msg.copy_id",m_msg.copy_id)
  local teamData = _G.Cfg.scene_copy[m_msg.copy_id]
  local teamlv = teamData.lv or ""
  -- local lvLab = _G.Util:createLabel(teamlv.."级",FontSize)
  -- lvLab:setPosition(30,self.oneHeight/2-4)
  -- lvLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  -- oneWidget : addChild(lvLab)

  local copyname = teamData.copy_name or ""
  local nameLab = _G.Util:createLabel(string.format("%d级 %s",teamlv,copyname),FontSize)
  nameLab:setPosition(100,self.oneHeight/2)
  -- nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWidget : addChild(nameLab)

  local teamname = m_msg.uname or ""
  local playerLab = _G.Util:createLabel(teamname,FontSize)
  playerLab:setPosition(240,self.oneHeight/2)
  -- playerLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWidget : addChild(playerLab)

  local teampow = m_msg.powerful or ""
  local powerLab = _G.Util:createLabel(teampow,FontSize)
  powerLab:setPosition(370,self.oneHeight/2)
  -- powerLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  oneWidget : addChild(powerLab)

  local function inviteBack(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      local roomTag = sender : getTag()
      print("邀请玩家的id",roomTag,",,,,",m_msg.type)
      local Position = sender : getWorldPosition()
      print("Position.y",Position.y,m_winSize.height/2+SecondSize.height/2-65)
      if Position.y > m_winSize.height/2+SecondSize.height/2-65 or 
        Position.y < m_winSize.height/2-SecondSize.height/2-15 then
      return end
      local msg = REQ_TEAM_LIVE_REQ()      
      msg.team_id=roomTag
      msg.type=m_msg.type
      _G.Network:send(msg)

      self.teamId = roomTag
    end
  end

  local intBtn=gc.CButton:create("general_btn_gold.png")
  intBtn:setPosition(SecondSize.width-100,self.oneHeight/2-3)
  intBtn:setTitleFontName(_G.FontName.Heiti)
  intBtn:setTitleFontSize(FontSize+6)
  intBtn:setTitleText("接 受")
  intBtn:addTouchEventListener(inviteBack)
  -- intBtn:setButtonScale(0.8)
  intBtn:setTag(m_msg.team_id)
  oneWidget:addChild(intBtn)

  return oneWidget
end

function InviteView.AcceptInvite(self,_data)
  if _data.rep==1 then
    print("跳转界面")
    self:closeView()
    _G.GLayerManager : openLayer(_G.Const.CONST_FUNC_OPEN_TEAM,nil,self.teamId)
  -- else
  --   local command = CErrorBoxCommand("该队伍已满员或不存在！")
  --   controller : sendCommand( command )
  end
end

function InviteView.closeView(self,sender,eventType)
  self.m_rootLayer : removeFromParent(true)
  self.m_rootLayer = nil 
  self.pMediator : destroy()
  self.pMediator = nil 
end

return InviteView

