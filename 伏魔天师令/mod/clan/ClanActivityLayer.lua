local ClanActivityLayer = classGc(view, function(self, tag, _LeftId, _isTrue)
    self.pMediator = require("mod.clan.ClanActivityLayerMediator")()
    self.pMediator : setView(self)
    self.isTrue = _isTrue
    self.myLeftId  = _LeftId

    self.m_winSize  = cc.Director : getInstance() : getVisibleSize()

    self.Button_State = 0
end)

local COLOR_WHITE=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
local COLOR_GOLD=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD )
local COLOR_GRASSGREEN=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
local COLOR_ORED=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED  )
local COLOR_BLUE=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE  )
local COLOR_BROWN=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)
local COLOR_DARKORANGE=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKORANGE)

local TAGBTN_GUARD    = 1
local TAGBTN_BEKING   = 2
local TAGBTN_DEFEND   = 3
local TAGBIN_QIFU     = 4
local TAGBTN_WAR      = 5
local TrueorFalse=true

local FONT_SIZE       = 20
local ACTIVITY_NAME   = {
    {tag=TAGBTN_GUARD,name="讨伐妖兽"},
    {tag=TAGBTN_BEKING,name="第一门派"},
    {tag=TAGBTN_DEFEND,name="百鬼夜行"},
    {tag=TAGBIN_QIFU,name="门派祈福"},
    {tag=TAGBTN_WAR,name="门派大战"},
} --"门派大战"
local LFETBTNCOUNT    = #ACTIVITY_NAME

local Tag_Btn_Explain = 111
local Tag_Btn_ZHspr   = 112
local Tag_Btn_TZspr   = 113
local Tag_Btn_SprAdd  = 114

local Tag_Btn_myFight = 201
local Tag_Btn_Group   = 202

local Tag_Btn_Zhanbao = 301
local Tag_Btn_Zhanbao_2 = 302

local Tag_Btn_qifu = 88

function ClanActivityLayer.__create(self,_tag)
  -- self.myUpost --我得职位
  self.m_container = cc.Node:create()
  --外层绿色底图大小
  self.m_rootBgSize = cc.size(848,492)

  --左底图
  self.m_leftSprSize= cc.size(213,488)
  self.m_leftSpr    = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
  self.m_leftSpr    : setContentSize( self.m_leftSprSize )
  self.m_container  : addChild(self.m_leftSpr)
  self.m_leftSpr    : setPosition(-312,-55)

  -- local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_lowline.png")
  -- lineWidth=lineSpr:getContentSize().width
  -- lineSpr : setPreferredSize(cc.size(lineWidth,self.m_leftSprSize.height-2))
  -- lineSpr : setPosition(self.m_leftSprSize.width+6,self.m_leftSprSize.height/2+1)
  -- lineSpr : setScaleX(-1)
  -- self.m_leftSpr:addChild(lineSpr)

  self.m_rightSprSize= cc.size(614,476)
  self.Spr_rghBase = ccui.Widget:create()
  self.Spr_rghBase   : setContentSize(self.m_rightSprSize)
  -- self.Spr_rghBase : setAnchorPoint( 0, 1 )
  self.Spr_rghBase : setPosition( self.m_leftSprSize.width*0.5+1, -55)
  self.m_container : addChild( self.Spr_rghBase,-2 )
  
  self.m_rightSpr    = cc.Node : create()
  self.m_container   : addChild(self.m_rightSpr)
  self.m_rightSpr    : setPosition(-self.m_rootBgSize.width/2+180,-self.m_rootBgSize.height/2-55)

  --容器
  self.m_tagcontainer = {}
  self.m_tagPanel     = {}
  self.m_tagPanelClass= {}  
  for i=1,LFETBTNCOUNT do
      local nTag=ACTIVITY_NAME[i].tag
      self.m_tagcontainer[nTag] = cc.Node:create()
      self.m_rightSpr    : addChild(self.m_tagcontainer[nTag])
  end

  local tag=_tag or TAGBTN_GUARD
  if self.myLeftId ~= nil and 1 <= self.myLeftId  and self.myLeftId <= 5 then 
    print( "self.myLeftId = ", self.myLeftId )
    tag = self.myLeftId
  end
  print( "```````tag = ", tag )
  --左边按钮
  self : createLeftBtnList(tag)
  self : selectContainerByTag(tag)

  return self.m_container
end

function ClanActivityLayer.createLeftBtnList(self, _tag )
    local function local_sprCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btn_tag = sender : getTag() 
            print("createLeftBtnList ok",btn_tag)
            if btn_tag~=TAGBTN_GUARD and self.spine~=nil then
              self.spine:setVisible(false)
            elseif self.spine~=nil then
              self.spine:setVisible(true)
            end
            if btn_tag ~= 5 or btn_tag ~= 6 then
              self:selectContainerByTag(btn_tag)
            end
            if self.tempSpr~=nil and btn_tag==TAGBTN_BEKING then
                self.tempSpr:removeFromParent(true)
                self.tempSpr=nil
                TrueorFalse=false
            end
        end
    end
    -- 375 318 261 204
    local rootsize = self.m_leftSprSize
    local btnsize  = cc.size(rootsize.width-10,rootsize.height/7-6) 
    self.m_leftBtnArray={}
    for i=1,LFETBTNCOUNT do
        local nTag=ACTIVITY_NAME[i].tag
        local touchText=ccui.Button:create("general_title_one.png","general_title_two.png","general_title_two.png",1)
        touchText:setTouchEnabled(true)
        touchText:setTag(nTag)
        touchText:addTouchEventListener(local_sprCallBack)
        self.m_leftSpr : addChild(touchText)
        touchText:setPosition(rootsize.width/2-2,rootsize.height-i*(rootsize.height/7-2)+25)

        local m_strLab = _G.Util:createLabel(ACTIVITY_NAME[i].name,FONT_SIZE+4)
        m_strLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        touchText: addChild(m_strLab,1)
        m_strLab : setPosition(btnsize.width*0.5,btnsize.height*0.5)

        if self.isTrue and nTag==TAGBTN_BEKING and TrueorFalse then
            print("jinlaile ")
            self.tempSpr=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
            self.tempSpr:setPosition(btnsize.width-10,btnsize.height-10)
            touchText:addChild(self.tempSpr)
        end
        self.m_leftBtnArray[nTag]=touchText
    end
end

function ClanActivityLayer.selectContainerByTag(self,_tag)
  -- 增加协议发送
  print( " *******_tag = ", _tag )
  if _tag == TAGBTN_GUARD then 
    self : REQ_CLAN_SELF_POST()
  elseif _tag == TAGBTN_BEKING then 
    if self.OneTime ~= nil then
      self : REQ_HILL_REQUEST()
    end
    self.OneTime = true
  elseif _tag == TAGBTN_DEFEND then
    self : REQ_GANG_WARFARE_REPLAY()
  elseif _tag == TAGBIN_QIFU then
    self : requireQifu()
  end

  for i,node in pairs(self.m_tagcontainer) do
    if i==_tag then
      node:setVisible(true)
    else
      node:setVisible(false)
    end
  end
  local leftBtn=self.m_leftBtnArray[_tag]
  print( "XXXX = ", leftBtn, _tag )
  for i=1,LFETBTNCOUNT do
    if i==_tag and leftBtn~=nil then
      leftBtn:setBright(false)
      leftBtn:setEnabled(false)
      leftBtn:setPosition(self.m_leftSprSize.width/2+1,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
    else
      self.m_leftBtnArray[i]:setBright(true)
      self.m_leftBtnArray[i]:setEnabled(true)
      self.m_leftBtnArray[i]:setPosition(self.m_leftSprSize.width/2-2,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
    end
  end

  --创建面板内容
  self:initTagPanel(_tag)

  if _tag==TAGBTN_GUARD then
       self:NetworkSend()
  end
end

function ClanActivityLayer.NetworkSend( self )
    local msg = REQ_CLAN_ASK_WATER()
    _G.Network :send( msg)
end

function ClanActivityLayer.initTagPanel(self,_tag)
  if self.m_tagPanel[_tag] == nil then
    --在这里创建自己面板的的东西
    if _tag == TAGBTN_BEKING then
      print("创建 第一门派")
      self.m_tagPanel[_tag] = self:createBekingPanel()
      self.m_rightSpr:setOpacity(0)
    else
      self.m_rightSpr:setOpacity(255)
      if _tag == TAGBTN_WAR then
        print("创建 门派大战面板")
        self.m_tagPanel[_tag] = self:createFightPanel()
      elseif _tag == TAGBTN_DEFEND then
        print("创建 百鬼夜行")
        self : REQ_DEFENSE_BWJM()
        self.m_tagPanel[_tag] = self:createDefendPanel()
        self:showDefendHallBtnView()
      elseif _tag == TAGBTN_GUARD then
        print("创建 讨伐妖兽 ")
        self.m_tagPanel[_tag] = self:createGuardPanel()
      elseif _tag == TAGBIN_QIFU then
        print("创建 门派祈福 ")
        self.m_tagPanel[_tag] = self:createQifu()
      end
    end
    if self.m_tagPanel[_tag] == nil then return end

    self.m_tagcontainer[_tag] : addChild(self.m_tagPanel[_tag])
  end
end

function ClanActivityLayer.createGuardPanel( self )
  local m_container = cc.Node:create()
  local width       = 610

  local function local_CallBack(sender, eventType)
      if eventType==ccui.TouchEventType.ended then
          local btn_tag = sender : getTag() 
          print("成员列表 点击成员 ",btn_tag)
          --1 2 
          if btn_tag == Tag_Btn_Explain then 
            local explainView  = require("mod.general.ExplainView")()
            local explainLayer = explainView : create(40213)
          elseif  btn_tag == Tag_Btn_ZHspr then
            print("self.error",self.error)
            if self.error==1 then
                local command = CErrorBoxCommand("需要掌门或护法才能召唤!")
                controller : sendCommand( command )
            elseif self.error==2 then
                local command = CErrorBoxCommand(11553)
                controller : sendCommand( command )
            else
              self : MessageBox(  )
            end
          -- 进入挑战界面
          -- CONST_CLAN_BOSS_MAPID
          elseif btn_tag == Tag_Btn_TZspr then
              print( "进入22222" )
              self : REQ_SCENE_ENTER_FLY( _G.Const.CONST_CLAN_BOSS_MAPID )
              self : REQ_WORLD_BOSS_CITY_BOOSS()
              if ((self.myUpost == _G.Const.CONST_CLAN_POST_MASTER ) or (self.myUpost == _G.Const.CONST_CLAN_POST_SECOND))
                  and (self.Button_State == 0) then   
                  self.Btn_ZHspr : setVisible( true  )
                  self.Btn_TZspr : setVisible( false )
              end
          end
      end
  end

  self.Btn_ZHspr = gc.CButton : create()
  self.Btn_ZHspr : loadTextures( "clan_zhbtn.png")
  self.Btn_ZHspr : setPosition( 110, self.m_rightSprSize.height-40 )
  self.Btn_ZHspr : setTag( Tag_Btn_ZHspr )
  self.Btn_ZHspr : addTouchEventListener( local_CallBack )
  m_container : addChild( self.Btn_ZHspr )
  self.Btn_ZHspr : setTouchEnabled(true)
  -- self.Btn_ZHspr : setGray()

  self.Btn_TZspr = gc.CButton : create()
  self.Btn_TZspr : loadTextures( "clan_txbtn.png")
  self.Btn_TZspr : setPosition( 110, self.m_rightSprSize.height-40 )
  self.Btn_TZspr : setTag( Tag_Btn_TZspr )
  self.Btn_TZspr : addTouchEventListener( local_CallBack )
  m_container : addChild( self.Btn_TZspr )
  self.Btn_TZspr : setTouchEnabled(true)
  -- self.Btn_TZspr : setGray()

  local Btn_Explain  = gc.CButton : create()
  Btn_Explain : loadTextures( "general_help.png")
  Btn_Explain : setPosition( self.m_rightSprSize.width-10, self.m_rightSprSize.height-30 )
  Btn_Explain : setTag( Tag_Btn_Explain )
  Btn_Explain : addTouchEventListener( local_CallBack )
  m_container : addChild( Btn_Explain )

  self.shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  self.shadow:setPosition(cc.p(350,200))
  self.shadow:setScale(2.5)
  m_container:addChild(self.shadow)

  self : _showRoleSpine( m_container ,"idle" )

  local baguaSpr=cc.Sprite:createWithSpriteFrameName("general_rolebg2.png")
  baguaSpr:setPosition(self.m_rightSprSize.width*0.5+35,self.m_rightSprSize.height/2+80)
  m_container:addChild(baguaSpr)

  local m_lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  local m_lineHeight = m_lineSpr : getContentSize().height
  m_lineSpr           : setContentSize(self.m_rightSprSize.width-60,m_lineHeight)
  m_container         : addChild(m_lineSpr)
  m_lineSpr           : setPosition(self.m_rightSprSize.width*0.5+40,160)

  local m_logoSpr = cc.Sprite : createWithSpriteFrameName("general_titlebg.png")
  m_container     : addChild(m_logoSpr)
  m_logoSpr       : setPosition(self.m_rightSprSize.width*0.5+35,130)

  local m_infoLab = _G.Util:createLabel("调戏妖兽",FONT_SIZE+4)
  -- m_infoLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
  m_infoLab : setPosition(self.m_rightSprSize.width*0.5+35,128)
  m_container     : addChild(m_infoLab)
  
  local function local_activitybtncallback(sender, eventType) 
      return self : onactivityBtnCallBack(sender, eventType)
  end

  local m_str     = {"贡献+50","贡献+100","贡献+500"}
  local m_infoStr = {"消耗:      20000","消耗:       20","消耗:       100"}
  local myFrame   = {"general_tongqian.png", "general_xianYu.png", "general_xianYu.png"}
  self.m_GuardPanelBtn = {}
  for i=1,3 do
      local m_btn  = gc.CButton:create() 
      m_btn  : setTitleFontName(_G.FontName.Heiti)
      m_btn  : setTitleText(m_str[i])
      m_btn  : loadTextures("general_btn_gold.png")
      m_btn  : setTag(i)
      m_btn  : setTitleFontSize(FONT_SIZE+2)
      m_btn  : addTouchEventListener(local_activitybtncallback)
      m_container : addChild(m_btn)
      m_btn  : setPosition(self.m_rightSprSize.width*0.5-140+(i-1)*185,35)

      m_btn : setTouchEnabled(false)
      m_btn : setGray()

      local m_infoLab = _G.Util:createLabel(m_infoStr[i],FONT_SIZE)
      -- m_infoLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKRED))
      m_infoLab : setAnchorPoint( 0, 0.5 )
      m_btn     : addChild(m_infoLab)
      m_infoLab : setPosition(0,72)

      local m_Piture = cc.Sprite : createWithSpriteFrameName( myFrame[i] )
      m_Piture : setAnchorPoint( 0, 0.5 )
      m_Piture : setPosition( 47,74 )
      m_btn    : addChild(m_Piture, 3)

     self.m_GuardPanelBtn[i] = m_btn
  end

   return m_container
end

function ClanActivityLayer.MessageBox( self )
  local function tipsSure()
    self : REQ_CLAN_BOSS_START_BOSS()
    if self.Button_State == 1 then 
      self.Btn_ZHspr : setVisible( false )
      self.Btn_TZspr : setVisible( true  )
    end
  end
  local function cancel()
    
  end
 
  local tipsBox = require("mod.general.TipsBox")()
  local tipsNode   = tipsBox :create( "", tipsSure, cancel)
  -- tipsNode : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
  cc.Director:getInstance():getRunningScene():addChild(tipsNode,1000)
  tipsBox : setTitleLabel("提 示")

  local layer=tipsBox:getMainlayer()
  local Yuanbao = _G.Const.CONST_CLAN_CLAN_BOSS_SPEND
  local lab = _G.Util : createLabel( "花费"..Yuanbao.."元宝召唤门派boss？" , FONT_SIZE  )
  lab : setPosition( 0, 40 )
  layer : addChild( lab )

  local lab2 = _G.Util : createLabel( "（元宝不足则消耗钻石）" , FONT_SIZE-2  )
  lab2 : setPosition( 0, 15 )
  layer : addChild( lab2 )
end

function ClanActivityLayer.MessageBox_2( self, tag, Fit_type, name, money )
  local function tipsSure()
    self:removeSpine()
    if Fit_type == 1 then 
      -- CONST_MOUNTAIN_KING_MAP  -- 第一门派
      self : clean_Scheduler()
      print( "开始飞场景" )
      _G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_MOUNTAIN_KING_MAP)
      local property  = _G.GPropertyProxy.m_lpMainPlay
      local originKey = property:getPropertyKey()
      local szKey = gc.Md5Crypto:md5(originKey,string.len(originKey))
      print( "UID = ", tag )
      print( "KEY = ", szKey )
      local msg=REQ_HILL_BATTLE()
      msg:setArgs( tag, szKey)
      _G.Network:send(msg)
    else
      self : clean_Scheduler()
      self : REQ_HILL_CLEAN()
    end
  end
  local function cancel()
    
  end
 
  local tipsBox = require("mod.general.TipsBox")()
  local tipsNode   = tipsBox :create( "", tipsSure, cancel)
  tipsNode : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
  self.m_container  : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  tipsBox : setTitleLabel("提 示")

  local layer=tipsBox:getMainlayer()
  if Fit_type == 1 then 
    local width  = 0
    local myWighet = ccui.Widget:create()

    local Lab_1 = _G.Util : createLabel( "挑战玩家", FONT_SIZE)
    Lab_1 : setAnchorPoint( 0, 0.5 )
    Lab_1 : setPosition( width, 20 )
    myWighet : addChild( Lab_1 )
    width = width + Lab_1 : getContentSize().width
    local Lab_2 = _G.Util : createLabel( name , FONT_SIZE)
    Lab_2 : setColor( COLOR_GRASSGREEN )
    Lab_2 : setAnchorPoint( 0, 0.5 )
    Lab_2 : setPosition( width, 20 )
    myWighet : addChild( Lab_2 )
    width = width + Lab_2 : getContentSize().width
    local Lab_3 = _G.Util : createLabel( "么？", FONT_SIZE )
    Lab_3 : setAnchorPoint( 0, 0.5 )
    Lab_3 : setPosition( width, 20 )
    myWighet : addChild( Lab_3 )
    width = width + Lab_3 : getContentSize().width

    myWighet : setContentSize( cc.size( width, 0 ) )
    layer  : addChild( myWighet )
  else
    local lab = _G.Util : createLabel( "花费"..money.."元宝刷新挑战CD？" , FONT_SIZE  )
    lab : setPosition( 0, 40 )
    layer : addChild( lab )

    local lab2 = _G.Util : createLabel( "（元宝不足则消耗钻石）" , FONT_SIZE-2  )
    lab2 : setPosition( 0, 15 )
    layer : addChild( lab2 )

  end
end


function ClanActivityLayer.onactivityBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag  = sender : getTag()
      print("--onactivityBtnCallBack---",btn_tag)
      local m_cost = 20 
      if btn_tag==1 then
        print("贡献 + 50")
        local msg = REQ_CLAN_START_WATER()
        msg :setArgs(btn_tag )        -- {1 退出门派| 0 解散门派}
        _G.Network :send( msg)

      elseif btn_tag==2 then
          print("贡献 + 100")
      elseif btn_tag==3 then
          print("贡献 + 200")
          m_cost = 100 
      end
      self.m_GuardPanelBtnDown = true
      if btn_tag == 1 then return end

      local function fun()
          local msg = REQ_CLAN_START_WATER()
          msg :setArgs(btn_tag )        -- {1 退出门派| 0 解散门派}
          _G.Network :send( msg)
      end
      local szMsg= "花费"..m_cost.._G.Lang.Currency_Type[2].."调戏妖兽？"
      _G.Util:showTipsBox(szMsg,fun)
    end
end

-- function ClanActivityLayer.createscelectSpr(self,_obj )
--    if self.m_scelect1Spr ~= nil then
--       self.m_scelect1Spr : removeFromParent(true)
--       self.m_scelect1Spr = nil 
--    end
--    if self.m_scelect2Spr ~= nil then
--       self.m_scelect2Spr : removeFromParent(true)
--       self.m_scelect2Spr = nil 
--    end

--    if _obj == nil then return end

--     local rootsize = self.m_leftSprSize
--     local btnsize  = cc.size(rootsize.width-10,rootsize.height/7-6) 

--     self.m_scelect1Spr = cc.Sprite : createWithSpriteFrameName( "general_title_two.png" ) 
--     local m_1SprSize   = self.m_scelect1Spr : getContentSize()
--     -- self.m_scelect1Spr : setScaleY( 0.7 )
--     self.m_scelect1Spr : setPosition(btnsize.width*0.5+3,btnsize.height-m_1SprSize.height*0.5)
--     _obj               : addChild(self.m_scelect1Spr)
-- end

function ClanActivityLayer.unregister(self)
  if self.pMediator ~= nil then
     self.pMediator : destroy()
     self.pMediator = nil 
  end
  
end

function ClanActivityLayer.NetWorkReturn_isHuDongBtnOk( self,_state )
   if _state == 0 then
        for i=1,3 do
          self.m_GuardPanelBtn[i] : setTouchEnabled(false)
          self.m_GuardPanelBtn[i] : setGray()
        end
    elseif _state == 1 then
        for i=1,3 do
          self.m_GuardPanelBtn[i] : setTouchEnabled(true)
          self.m_GuardPanelBtn[i] : setDefault()
        end
   end
   if self.m_GuardPanelBtnDown then
      self.m_GuardPanelBtnDown = false
      _G.Util:playAudioEffect("balance_reward")
   end
end

function ClanActivityLayer.createDefendPanel(self)
  local container=cc.Node:create()

  local pUtil =_G.Util
  local viewSize=cc.size(630,350)
  local leftPoint=cc.p(0,0.5)
  local leftPosX=30
  local nPosY=-10
  local szArray1  = {"奖        励：","时        间：","参与条件："}
  local text_clan = _G.Cfg.clan_active_all[4]
  local szArray2  = { text_clan.reward, text_clan.type1, text_clan.condition }
  for i=1,3 do
    nPosY=i>1 and nPosY-30 or nPosY
    local lb1=pUtil:createLabel(szArray1[i],20)
    local lb2=pUtil:createLabel(szArray2[i],20)
    -- lb1:setColor(COLOR_WHITE)
    lb2:setColor(COLOR_GRASSGREEN)
    lb1:setPosition(leftPosX,nPosY)
    lb2:setPosition(125,nPosY)
    lb1:setAnchorPoint(leftPoint)
    lb2:setAnchorPoint(leftPoint)
    container:addChild(lb1)
    container:addChild(lb2)
  end

  local function ButtonCallBack( obj, eventType )
    tag = obj:getTag()
    if eventType == ccui.TouchEventType.ended then 
      if tag == Tag_Btn_Zhanbao_2 then 
        print( "开始请求战报2" )
        -- self : REQ_DEFENSE_VIEW()
        self : REQ_DEFENSE_PRE_DATA()
      end
    end
  end

  local Btn_Zhanbao_2 = gc.CButton : create()
  Btn_Zhanbao_2       : loadTextures( "general_wrod_zb.png" )
  Btn_Zhanbao_2       : setPosition( 540,nPosY+45 )
  Btn_Zhanbao_2       : setTag( Tag_Btn_Zhanbao_2 )
  Btn_Zhanbao_2       : addTouchEventListener( ButtonCallBack )
  container           : addChild( Btn_Zhanbao_2 )

  nPosY=nPosY-35
  local noticLb=pUtil:createLabel("详细规则：",20)
  noticLb:setColor(COLOR_WHITE)
  noticLb:setPosition(leftPosX,nPosY)
  noticLb:setAnchorPoint(leftPoint)
  container:addChild(noticLb)

  nPosY=nPosY-18
  local szNoticArray=text_clan.value1
  local tempLb=pUtil:createLabel(szNoticArray,20)
  -- tempLb:setColor(color4)
  tempLb:setPosition(leftPosX,nPosY)
  tempLb:setAnchorPoint(cc.p(0,1))
  tempLb:setDimensions(viewSize.width-leftPosX*2-10,0)
  tempLb:setLineBreakWithoutSpace(true)
  tempLb:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  container:addChild(tempLb)

  local tempSize=tempLb:getContentSize()
  nPosY=nPosY-tempSize.height-3

  local nHeight=10
  local contentHeight=(-nPosY<viewSize.height and viewSize.height or -nPosY)+nHeight
  local pContainer=cc.Node:create()
  local tempScrollView=cc.ScrollView:create()
  tempScrollView:setTouchEnabled(true)
  tempScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  tempScrollView:setContentSize(cc.size(viewSize.width,contentHeight))
  tempScrollView:setViewSize(viewSize) 
  tempScrollView:setContentOffset(cc.p(0,viewSize.height-contentHeight)) -- 设置初始位置
  tempScrollView:addChild(container)
  tempScrollView:setPosition(5,-2)
  pContainer:addChild(tempScrollView)
  container:setPosition(0,contentHeight-nHeight)

  local barView=require("mod.general.ScrollBar")(tempScrollView)
  barView:setPosOff(cc.p(-4,0))
  -- barView:setMoveHeightOff(-20)

  local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
  local lineSprSize=lineSpr:getPreferredSize()
  lineSpr:setPreferredSize(cc.size(viewSize.width-10,lineSprSize.height))
  lineSpr:setPosition(viewSize.width*0.5+10,viewSize.height)
  pContainer:addChild(lineSpr)

  -- local myJianbianSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_fram_jianbian.png" )
  -- myJianbianSpr       : setPreferredSize( cc.size(viewSize.width-10,290) )
  -- myJianbianSpr       : setAnchorPoint( 0.5, 1 )
  -- myJianbianSpr       : setPosition( 5+viewSize.width*0.5-5,5+viewSize.height+2 )
  -- pContainer          : addChild( myJianbianSpr, -1 )

  pContainer : setPosition( 30, 5 )
  return pContainer
end

function ClanActivityLayer.REQ_DEFENSE_VIEW( self )
  local msg = REQ_DEFENSE_VIEW()
  _G.Network : send( msg )
end

function ClanActivityLayer.REQ_DEFENSE_PRE_DATA( self )
  local msg = REQ_DEFENSE_PRE_DATA()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_COMBAT_RANK( self, _ackMsg )
  local count = _ackMsg.count
  local data  = _ackMsg.data
  print( "战报数量： ", count )
  for i=1,count do
    print( "玩家名字： ", data[i].uname )
    print( "   排名： ", data[i].rank )
    print( "击杀数量： ", data[i].kill_num )
  end
end

function ClanActivityLayer.Net_DEFENSE_ZHANBAO( self, _ackMsg )
  print( "接收到塔防战斗信息！" )
  local msg = _ackMsg
  print( "剩余血青龙 ： ", msg.hp1 )
  print( "总血青龙   ： ", msg.all_hp1 )
  print( "层次      ： ", msg.cen1  )
  print( "xxx      ： ", msg.state1  )
  print( "剩余血白虎 ： ", msg.hp2 )
  print( "总血白虎   ： ", msg.all_hp2 )
  print( "层次      ： ", msg.cen2  )
  print( "xxx      ： ", msg.state2  )
  print( "剩余血朱雀 ： ", msg.hp3 )
  print( "总血朱雀   ： ", msg.all_hp3 )
  print( "层次      ： ", msg.cen3  )
  print( "xxx      ： ", msg.state3  )
  print( "剩余血玄武 ： ", msg.hp4 )
  print( "总血玄武   ： ", msg.all_hp4 )
  print( "层次      ： ", msg.cen4  )
  print( "xxx      ： ", msg.state4  )

  self : createZBView( 2, msg )
end

function ClanActivityLayer.showDefendHallBtnView(self)
  if self.m_tagPanel[TAGBTN_DEFEND]==nil then return end

  local container=cc.Node:create()
  container:setPosition( -10, 0 )
  container:setTag(6681)
  self.m_tagPanel[TAGBTN_DEFEND]:addChild(container)
  -- self.m_defendHallNode=container

  local width       = 580
  local function c(sender,eventType)
    if eventType==ccui.TouchEventType.ended then
      local tag=sender:getTag()
      print("showDefendHallBtnView=====>>",tag)
      -- _G.StageXMLManager:setServerId(tag)
      self : REQ_DEFENSE_REQUEST(tag)
      -- self:showDefendHallEnterView(tag)
    end
  end

  local nWidth=250
  local nHeight=415
  local qltBtn=gc.CButton:create("clan_td_icon_1.png")
  qltBtn:setTag(_G.Const.CONST_DEFENSE_TYPE_1)
  qltBtn:addTouchEventListener(c)
  qltBtn:setPosition(210,nHeight)
  container:addChild(qltBtn)

  local bhtBtn=gc.CButton:create("clan_td_icon_2.png")
  bhtBtn:setTag(_G.Const.CONST_DEFENSE_TYPE_2)
  bhtBtn:addTouchEventListener(c)
  bhtBtn:setPosition(210+nWidth,nHeight)
  container:addChild(bhtBtn)

--[[
  local zqtBtn=gc.CButton:create("clan_td_icon_3.png")
  zqtBtn:setTag(_G.Const.CONST_DEFENSE_TYPE_3)
  zqtBtn:addTouchEventListener(c)
  zqtBtn:setPosition(105+nWidth*2,nHeight)
  container:addChild(zqtBtn)

  local xwtBtn=gc.CButton:create("clan_td_icon_4.png")
  xwtBtn:setTag(_G.Const.CONST_DEFENSE_TYPE_4)
  xwtBtn:addTouchEventListener(c)
  xwtBtn:setPosition(105+nWidth*3,nHeight)
  container:addChild(xwtBtn)
  --]]
  self.Btn_ShenShow = { qltBtn, bhtBtn }     -- zqtBtn, xwtBtn }

  for i=1,2 do
    self.Btn_ShenShow[i] : setTouchEnabled( false )
    self.Btn_ShenShow[i] : setGray()
  end
end

function ClanActivityLayer.createBekingPanel(self)
  -- 人物头像在协议中创建
  self : REQ_HILL_REQUEST()
  local container=cc.Node:create()

  local sprSize=cc.size(286,self.m_rightSprSize.height)
  local leftSpr  = cc.Node : create()
  self.rightSpr  = cc.Node : create()
  leftSpr        : setPosition( 35, 0 )
  self.rightSpr  : setPosition( sprSize.width+40, 0 )
  container:addChild(leftSpr)
  container:addChild(self.rightSpr)

  local upHeight=80

  -- local container=ccui.Scale9Sprite:createWithSpriteFrameName("general_daybg.png")
  -- upSpr:setPreferredSize(cc.size(self.m_rightSprSize.width+18,upHeight))
  -- upSpr:setPosition(353,sprSize.height-27)
  -- container:addChild(upSpr,1)

  local leftPoint=cc.p(0,0.5)
  local pUtil=_G.Util

  local addLabel1=pUtil:createLabel("进攻方加成:",FONT_SIZE)
  addLabel1:setAnchorPoint(leftPoint)
  -- addLabel1:setColor( color4 )
  addLabel1:setPosition(70,sprSize.height-10)
  container:addChild(addLabel1, 1)

  self.addLabel2=pUtil:createLabel("",FONT_SIZE)
  self.addLabel2:setColor(COLOR_GRASSGREEN)
  self.addLabel2:setAnchorPoint(leftPoint)
  self.addLabel2:setPosition(70,sprSize.height-40)
  container:addChild(self.addLabel2)

  
  local ptag_crank=2
  local ptag_rrank=3
  local ptag_info=4
  local ptag_notic=5
  local function c(sender,eventType)
    if eventType==ccui.TouchEventType.ended then
      local tag=sender:getTag()
      print("createBekingPanel===>>>>>>",tag)
      if tag == ptag_crank then 
          self : REQ_HILL_TOP( 0 )
      elseif tag == ptag_rrank then 
          self : REQ_HILL_TOP( 1 )
      elseif tag == ptag_info then
          self : REQ_HILL_REDIO()
      elseif tag == TAGBTN_WAR then 
          local explainView  = require("mod.general.ExplainView")()
          local explainLayer = explainView : create(40215)
      elseif tag == ptag_info then
          print( "这个战报没有做" )
          -- local command = CErrorBoxCommand(36950)
          -- controller : sendCommand( command )
      end
    end
  end
  local noticBtn=gc.CButton:create("general_help.png")
  noticBtn:setTag(ptag_notic)
  noticBtn:addTouchEventListener(c)
  noticBtn:setPosition(self.m_rightSprSize.width-90,40)
  container:addChild(noticBtn)

  local timesLabel=pUtil:createLabel("挑战冷却:",FONT_SIZE)
  timesLabel:setAnchorPoint(leftPoint)
  -- timesLabel:setColor(color4)
  timesLabel:setPosition(self.m_rightSprSize.width/2+60,50)
  container:addChild(timesLabel)

  self.timesLabel=pUtil:createLabel("00:00:00",FONT_SIZE)
  self.timesLabel:setAnchorPoint(leftPoint)
  self.timesLabel:setPosition(self.m_rightSprSize.width/2+60,20)
  self.timesLabel:setColor(COLOR_ORED)
  container:addChild(self.timesLabel)

  local infoBtn=gc.CButton:create("general_wrod_zb.png")
  infoBtn:setTag(ptag_info)
  infoBtn:addTouchEventListener(c)
  infoBtn:setPosition(self.m_rightSprSize.width-10,40)
  container:addChild(infoBtn)

  local downHeight=sprSize.height-upHeight+20
  self.stateSpr=cc.Sprite:createWithSpriteFrameName("clan_word_fscg.png")
  self.stateSpr:setPosition(sprSize.width*0.5,downHeight-20)
  self.stateSpr:setVisible( false )
  leftSpr:addChild(self.stateSpr, 10)

  local flagSpr=cc.Sprite:createWithSpriteFrameName("clan_flag.png")
  local flagSprSize=flagSpr:getContentSize()
  flagSpr:setPosition(sprSize.width*0.5,downHeight*0.5+50)
  leftSpr:addChild(flagSpr)

  local flagClanLvLb=pUtil:createLabel("本轮灵妖门派",FONT_SIZE)
  -- flagClanLvLb:setString("本轮灵妖的门派：")
  -- flagClanLvLb:setSystemFontSize( FONT_SIZE )
  -- flagClanLvLb:setSystemFontName( _G.Const.Heiti )
  -- flagClanLvLb:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
  flagClanLvLb:setPosition(flagSprSize.width*0.5,flagSprSize.height*0.5+40)
  flagSpr:addChild(flagClanLvLb)

  self.flagClanNameLb=pUtil:createBorderLabel("我的门派",FONT_SIZE)
  self.flagClanNameLb:setColor( COLOR_GRASSGREEN )
  self.flagClanNameLb:setPosition(flagSprSize.width*0.5,flagSprSize.height*0.5+10)
  flagSpr:addChild(self.flagClanNameLb)

  local nowTime     = _G.TimeUtil:getServerTimeSeconds()
  local nowTime_str = os.date("*t", nowTime)
  local hour        = nowTime_str.hour
  print( "`````Nowtime.hour = ",   nowTime_str.hour)
  local Text = ""
  if hour < 10 then 
    Text = "活动时间：10:00—22:00"
  elseif hour >= 22 then
    Text = "活动将于明日10点开始"
  else 
    Text = "活动进行中......"
  end
  local Lab_OpenTime = pUtil : createLabel( Text, FONT_SIZE )
  -- Lab_OpenTime : setColor( color4 )
  Lab_OpenTime : setPosition( sprSize.width*0.5, 105 )
  leftSpr : addChild( Lab_OpenTime )
  self.Lab_OpenTime = Lab_OpenTime

  local cRankBtn=gc.CButton:create("general_btn_gold.png")
  cRankBtn:setTag(ptag_crank)
  cRankBtn:addTouchEventListener(c)
  cRankBtn:setPosition(sprSize.width*0.5-67,45)
  cRankBtn:setTitleFontName(_G.FontName.Heiti)
  cRankBtn:setTitleText("门派排行")
  -- cRankBtn:setButtonScale(0.9)
  --cRankBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  cRankBtn:setTitleFontSize(FONT_SIZE+2)
  leftSpr:addChild(cRankBtn)

  local rRankBtn=gc.CButton:create("general_btn_lv.png")
  rRankBtn:setTag(ptag_rrank)
  rRankBtn:addTouchEventListener(c)
  rRankBtn:setPosition(sprSize.width*0.5+67,45)
  rRankBtn:setTitleFontName(_G.FontName.Heiti)
  -- rRankBtn:setButtonScale(0.9)  
  rRankBtn:setTitleText("个人排行")
  rRankBtn:setTitleFontSize(FONT_SIZE+2)
  leftSpr:addChild(rRankBtn)

  local myLine = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  myLine       : setPreferredSize( cc.size( 333, 409 ) )
  myLine       : setPosition( self.m_rightSprSize.width-120, self.m_rightSprSize.height/2+40 )
  container    : addChild( myLine,-1 )

  return container
end

function ClanActivityLayer.REQ_DEFENSE_BWJM( self )
  local msg = REQ_DEFENSE_BWJM()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_BWJM_BACK( self, _ackMsg )
  local msg = _ackMsg
  print( "数量：", msg.count )
  for i=1,2 do
    self.Btn_ShenShow[i] : setTouchEnabled( false )
    self.Btn_ShenShow[i] : setGray()
  end
  print("msg.count-->",msg.count)
  for i=1,msg.count do
    local num = msg.group[i]
    print( "能进入的为：", num )
    self.Btn_ShenShow[num] : setTouchEnabled( true )
    self.Btn_ShenShow[num] : setDefault()
  end
end

function ClanActivityLayer.REQ_HILL_CLEAN( self )
  local msg = REQ_HILL_CLEAN()
  _G.Network : send( msg )
end

function ClanActivityLayer.REQ_DEFENSE_REQUEST( self, _groud )
  local msg = REQ_DEFENSE_REQUEST()
  msg : setArgs( _groud )
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_CLEAN_OK( self )
  self:clean_Scheduler()
  self.timesLabel : setString( "00:00:00" )
  _G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_MOUNTAIN_KING_MAP)
  local property  = _G.GPropertyProxy.m_lpMainPlay
  local originKey = property:getPropertyKey()
  local szKey = gc.Md5Crypto:md5(originKey,string.len(originKey))
  print( "self.Uid = ", self.Uid )
  print( "KEY = ", szKey )
  local msg=REQ_HILL_BATTLE()
  msg:setArgs( self.Uid, szKey)
  _G.Network:send(msg)
end

function ClanActivityLayer.clean_Scheduler( self )
  if self.Scheduler ~= nil then
      _G.Scheduler : unschedule( self.Scheduler )
      self.Scheduler = nil
  end
end

function ClanActivityLayer.REQ_CLAN_BOSS_START_BOSS( self )
  local msg = REQ_CLAN_BOSS_START_BOSS()
  _G.Network :send( msg )
end

function ClanActivityLayer.Boss_State( self, _ackMsg )
  print( "接收到请求！是否可以开启：", _ackMsg.state, self.myUpost )
  self.Button_State = _ackMsg.state

  if self.Button_State == 1 then 
    print( "：：state 1：： 可挑战" )
    self.Btn_TZspr : setVisible( true  )
    self.Btn_ZHspr : setVisible( false )
  elseif self.Button_State == 2 then 
    print( "：：state 2：：挑战结束" )
    self.Btn_ZHspr : setVisible( true )
    self.Btn_TZspr : setVisible( false  )
    self.error=2
  elseif (self.myUpost == _G.Const.CONST_CLAN_POST_MASTER ) or (self.myUpost == _G.Const.CONST_CLAN_POST_SECOND) then 
    self.Btn_TZspr : setVisible( false )
    self.Btn_ZHspr : setVisible( true  )
    print( "：：state 掌门可召唤：：" )
  else
    self.Btn_ZHspr : setVisible( true )
    self.Btn_TZspr : setVisible( false  )
    self.error=1
    print( "：：state 成员等待：：" )
  end
end

function ClanActivityLayer.REQ_WORLD_BOSS_CITY_BOOSS( self )
  local msg = REQ_WORLD_BOSS_CITY_BOOSS()
  _G.Network : send( msg )
end

function ClanActivityLayer.REQ_SCENE_ENTER_FLY( self, _ackMsg )
  local msg = REQ_SCENE_ENTER_FLY()
  msg : setArgs( _ackMsg )
  _G.Network : send( msg )
end

function ClanActivityLayer._showRoleSpine( self, m_container ,action )
  print( "进入：_showRoleSpine !" )
  self:removeSpine()
  local nScale=0.45
  self.spine=_G.SpineManager.createSpine("spine/20621",nScale) -- _mountId
  self.spine:setPosition(cc.p(740,200))
  self.spine:setAnimation(0,"idle",true)
  cc.Director:getInstance():getRunningScene():addChild(self.spine,800)
end

function ClanActivityLayer.removeSpine( self )
    print("removeSpine========>>>>>>>",self.spine)
    if self.spine ~= nil then
        self.spine : removeFromParent(true)
        self.spine = nil
    end
end

function ClanActivityLayer.REQ_HILL_REQUEST( self )
  local msg = REQ_HILL_REQUEST()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_HILL_REPLAY( self, _ackMsg )
  local msg = _ackMsg
  print(" 防守门派  ",  msg.clan_name )
  print(" 防守情况  ",  msg.res )
  print(" 伤害加成  ",  msg.bonus )
  print(" 免伤加成  ",  msg.reduction )
  print(" 挑战cd    ",  msg.time  )
  print(" 数量      ",  msg.count )

  local data = msg.data
  local function sort( data1, data2 )
      if data1.sy_hp == 0 then 
        return false 
      elseif data2.sy_hp == 0 then 
        return true
      elseif data1.hp > data2.hp then
        return true
    end
  end
  table.sort( data , sort )
  for i=1, msg.count do
    print(" 玩家uid  ",  data[i].uid )
    print(" 玩家名字  ",  data[i].name  )
    print(" 击杀数量  ",  data[i].kill  )
    print(" 剩余血量  ",  data[i].sy_hp )
    print(" 职业     ",  data[i].pro )
    print(" 总血量    ",  data[i].hp , "\n" )
  end

  self : ChangeLabText( msg )
  self : createScrollView( msg.count, data )
end

function ClanActivityLayer.ChangeLabText( self, _msg )
  -- self.flagClanNameLb  -- 我的门派
  local msg = _msg
  if msg.res == 0 then 
    self.stateSpr : setVisible( true )
  elseif msg.res == 2 then
    self.stateSpr : setVisible( false )
  end
  self.flagClanNameLb : setString( msg.clan_name )
  self.addLabel2  : setString( "伤害+"..msg.bonus.." 免伤+"..msg.reduction )
  self.timesLabel : setString( self : _getTimeStr( msg.time ) )

  self.myTime = msg.time
  if msg.time ~= 0 and msg.time ~= nil then 
    local function step1(  )
      self.myTime = self.myTime - 1
      -- print( "self.myTime = ,", self.myTime, self.timesLabel:getString() )
      self.timesLabel : setString( self : _getTimeStr( self.myTime ) )
      -- print( "googogogog" )
      if self.myTime <= 0 then 
        _G.Scheduler : unschedule( self.Scheduler )
        self.Scheduler = nil
      end
    end
    if self.Scheduler==nil then 
      self.Scheduler = _G.Scheduler : schedule(step1, 1)
    end
  end

end

function ClanActivityLayer.createScrollView( self, _count, _data )
  local count = _count
  local data  = _data
  -- for i=1,10 do
  --   data[i]=data[1]
  -- end

  local function TouchEventFight( obj, touchEventType )
    local tag       = obj : getTag()
    local Position  = obj : getWorldPosition()
    local _pos_y    = Position.y
    print( "_pos_y = ", _pos_y  )
    if _pos_y >= 490 or _pos_y <= 140 then 
      return
    end
    if touchEventType == ccui.TouchEventType.ended then
      print("   抬起  ", tag)
      self.Uid  = tag
      self.Name = ""
      for i=1,count do
          if data[i].uid == tag then
            self.Name = data[i].name
          end
      end
      local Fit_type = 0
      if self.timesLabel : getString() == "00:00:00" then
        Fit_type = 1
      else
        Fit_type = 2
      end
      print( "Fit_type = ", tag, Fit_type, self.Name )
      if Fit_type == 1 then 
        self : MessageBox_2( tag, Fit_type , self.Name, 0  )
      else
        -- self : clean_Scheduler()
        local property  = _G.GPropertyProxy.m_lpMainPlay
        local originKey = property:getPropertyKey()
        local szKey = gc.Md5Crypto:md5(originKey,string.len(originKey))
        print( "UID = ", tag )
        print( "KEY = ", szKey )
        local msg=REQ_HILL_BATTLE()
        msg:setArgs( tag, szKey)
        _G.Network:send(msg)
      end
    end
  end

  print("初始化滚动框", count, _count)
  local newCount = count
  if count < 4 then
    newCount = 4
  end
  local ScrollHeigh   = 100.5      
  local viewSize      = cc.size( 330, 4*ScrollHeigh)
  local containerSize = cc.size( 330, newCount*ScrollHeigh)
  if self.ScrollView ~= nil then 
    self.ScrollView : removeFromParent()
    self.ScrollView = nil
  end
  self.ScrollView  = cc.ScrollView : create()
  self.ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  self.ScrollView  : setViewSize(viewSize)
  self.ScrollView  : setContentSize(containerSize)
  self.ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
  self.ScrollView  : setPosition(cc.p(3, 77))
  self.ScrollView  : setBounceable(true)
  self.ScrollView  : setTouchEnabled(true)
  self.ScrollView  : setDelegate()
  self.rightSpr: addChild( self.ScrollView )

  local barView = require("mod.general.ScrollBar")(self.ScrollView)
  barView     : setPosOff(cc.p(-4,0))

  for i=1,count do
    local My_Height     = newCount*ScrollHeigh - i*ScrollHeigh + ScrollHeigh/2-2
    local Btn_Spr_Fight = gc.CButton : create()
    local spr = string.format( "general_role_head%d.png", data[i].pro )
    Btn_Spr_Fight : loadTextures( spr ,"","",ccui.TextureResType.plistType ) 
    Btn_Spr_Fight : setPosition( 50, My_Height  )
    Btn_Spr_Fight : setButtonScale(0.9)
    Btn_Spr_Fight : setTag( data[i].uid )
    Btn_Spr_Fight : addTouchEventListener( TouchEventFight )
    self.ScrollView    : addChild( Btn_Spr_Fight )

    local mySpr  = "clan_fight.png"
    if data[i].sy_hp <= 0 then 
      mySpr = "clan_death.png"
      Btn_Spr_Fight : setTouchEnabled( false )
      Btn_Spr_Fight : setGray()
    end

    local Spr_TZ = cc.Sprite : createWithSpriteFrameName( mySpr )
    Spr_TZ       : setAnchorPoint( 0, 0 )
    Spr_TZ       : setPosition( 20, 10 )
    Btn_Spr_Fight: addChild( Spr_TZ )

    local My_Text_1  = { "名字：", "连杀：", "血量：" }
    local myBlood    = data[i].sy_hp
    local My_Text_2  = { data[i].name or "暂无", data[i].kill or " " , myBlood or " " }
    for k=1,3 do
      local Lab_1 = _G.Util : createLabel( My_Text_1[k], FONT_SIZE )
      Lab_1 : setPosition( 125, My_Height + 50 - k*25 )
      -- Lab_1 : setColor( COLOR_GRASSGREEN )
      self.ScrollView : addChild( Lab_1 )

      local Lab_2 = _G.Util : createLabel( My_Text_2[k], FONT_SIZE )
      Lab_2 : setAnchorPoint( 0, 0.5 )
      Lab_2 : setColor(COLOR_GRASSGREEN)
      Lab_2 : setPosition( 155, My_Height + 50 - k*25 )
      self.ScrollView : addChild( Lab_2 )
      if k == 3 then 
            local Blood = data[i].sy_hp / data[i].hp * 100 - data[i].sy_hp / data[i].hp * 100 % 1
            local Lab_3 = _G.Util : createLabel( "("..Blood.."%)", FONT_SIZE-2 )
            Lab_3 : setAnchorPoint( 0, 0.5 )
            Lab_3 : setColor( COLOR_GRASSGREEN )
            Lab_3 : setPosition( Lab_2 : getContentSize().width + 165 , My_Height - 25 )
            self.ScrollView : addChild( Lab_3 )

            if Blood <= 30 then 
              Lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
              Lab_3 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
            elseif Blood <= 50 then 
              Lab_2 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_YELLOW ) )
              Lab_3 : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_YELLOW ) )
            end 
      end
    end

    local thisbgSpr  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" )
    thisbgSpr : setContentSize( cc.size( 325, ScrollHeigh-2) )
    thisbgSpr : setPosition( 165, My_Height )
    self.ScrollView : addChild( thisbgSpr,-1)
  end
end

function ClanActivityLayer.Net_CD_SEC( self, _rmb )
  print( "需要花费元宝数：", _rmb )
  local rmb = _rmb
  self : MessageBox_2( self.Uid, 2, self.Name, rmb )
end

function ClanActivityLayer.REQ_HILL_TOP( self, _ackMsg )
  local msg = REQ_HILL_TOP()
  msg : setArgs( _ackMsg )
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_CLAN_TOP( self, _ackMsg )
  local msg = _ackMsg
  print(" 数量   ",  msg.count   )
  print(" 我得 门派/个人 排名  ",  msg.zrank   )
  print(" 总伤害  ",  msg.zharm   )
  print(" 击杀：  ",  msg.zkill   )
  for i=1,msg.count do
    if msg.type == 0 then 
      print(" 门派id  ",  msg.clan_id[i]   )
      print(" 门派名  ",  msg.clan_name[i] )
      print(" 排名    ",  msg.rank[i]      )
      print(" 总伤害  ",  msg.all_bonus[i] )
      print(" 总击杀  ",  msg.killed[i]    )
    elseif msg.type == 1 then 
      print(" 玩家uid  ",  msg.uid[i]       )
      print(" 玩家名   ",  msg.name[i]      )
      print(" 排名     ",  msg.rank[i]      )
      print(" 总伤害   ",  msg.all_bonus[i] )
      print(" 总击杀   ",  msg.killed[i]    )
    end
  end

  self : createRankView( 3, msg )
  -- self : createDongfuRanking( msg )
end

function ClanActivityLayer.REQ_HILL_REDIO( self )
  local msg = REQ_HILL_REDIO()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_REDIO_BACK( self, _ackMsg )
  print( "Net_REDIO_BACK : 战报接收！" )
  local msg =_ackMsg
  for i=1,msg.count do
    print(" 挑战玩家uid     ", msg.data[i].t_uid )
    print(" 挑战玩家名字    ", msg.data[i].t_name  )
    print(" 被挑战玩家uid   ", msg.data[i].b_uid )
    print(" 被挑战玩家名字   ", msg.data[i].b_name  )
    print(" 0.成功 1.失败   ", msg.data[i].result  )
    print(" 造成伤害        ", msg.data[i].bonus )
    print(" 挑战时间戳       ", msg.data[i].time  )
  end
  self : createZBView(1, msg)
end

function ClanActivityLayer.createZBView( self, _myType, msg )
  print( "进入这里！！" )
  local myZBView  = require( "mod.general.BattleMsgView"  )()
  local ZB_D2Base = myZBView : create( )
  local m_mainSize = myZBView : getSize()
  local myHeight  = m_mainSize.height

  if msg.count==0 then
      self.monkeySpr = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
      self.monkeySpr : setPosition(m_mainSize.width/2,m_mainSize.height/2+30)
      ZB_D2Base : addChild(self.monkeySpr)

      local monkeySize=self.monkeySpr:getContentSize()
      self.nomsgLab = _G.Util : createLabel("暂无战报", 20)
      -- self.nomsgLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
      self.nomsgLab : setPosition(monkeySize.width/2,-10)
      self.monkeySpr : addChild(self.nomsgLab)  
      return
  end
  if self.monkeySpr~=nil then
      self.monkeySpr:removeFromParent(true)
      self.monkeySpr=nil

      self.nomsgLab:removeFromParent(true)
      self.nomsgLab=nil
  end

  local myNode = cc.Node : create()
  ZB_D2Base : addChild( myNode )

  local myScroCont = 0
  local myUid      = _G.GPropertyProxy : getMainPlay() : getUid() 
  local returnNode = nil
  -- 1 ： 第一门派
  if _myType == 1 then

    local myScrollView = nil
    myScroCont      = msg.count 
    local data      = msg.data
    local myHeight1 = myHeight
    local myData    = {}
    local text2     = { [0] = "失败" ,"成功", "失败" }
    for i=1,msg.count do
      myData[1] = self:_combatTime( data[i].time )
      myData[5] = data[i].bonus
      if myUid == data[i].t_uid then
        -- 我为进攻方
        myData[2] = "你对"
        myData[3] = data[i].b_name
        myData[4] = "造成"
        myData[6] = "点伤害,击杀"
        myData[7] = text2[data[i].result]
      else
        -- 我为防守方
        myData[3] = data[i].t_name
        myData[4] = "对你造成"
        print( "data[i].result = ", data[i].result )
        myData[6] = "点伤害,防守"
        myData[7] = text2[data[i].result+1]
      end
      -- myScroCont=10
      if myScroCont > 7 then
        myHeight1 = myScroCont*41
      end

      returnNode =  self : showZBWords( i, myHeight1, myData )
      if myScroCont <= 7 then
        myNode  : addChild( returnNode )
      else
        -- scrollView 增加对象
        if myScrollView == nil then
          -- local mySize        = cc.size(540,270) 
          local viewSize      = cc.size( m_mainSize.width, m_mainSize.height+5)
          local containerSize = cc.size( m_mainSize.width, myHeight1)
          local myScrollView    = cc.ScrollView : create()
          myScrollView  : setDirection(ccui.ScrollViewDir.vertical)
          myScrollView  : setViewSize(viewSize)
          myScrollView  : setAnchorPoint( 0,0 )
          myScrollView  : setContentSize(containerSize)
          myScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
          myScrollView  : setPosition( 0,8 )
          myScrollView  : setBounceable(true)
          myScrollView  : setTouchEnabled(true)
          myScrollView  : setDelegate()
          myNode : addChild( myScrollView,5 )
          
          myNode:setPosition(0,-12)
          local barView = require("mod.general.ScrollBar")(myScrollView)
          barView : setPosOff( cc.p(-4, 0) )
          myScrollView : addChild( returnNode )
        else
          myScrollView : addChild( returnNode )
        end
      end
      
    end
  -- 2 ： 百鬼夜行
  elseif _myType == 2 then
    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    line1       : setPreferredSize( cc.size( 600, 3 ) )
    line1       : setAnchorPoint( 0, 1 )
    line1       : setPosition( 10, myHeight-32 )
    myNode      : addChild( line1 )

    local lineMid = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    lineMid       : setPreferredSize( cc.size( 600, 3 ) )
    lineMid       : setAnchorPoint( 0, 1 )
    lineMid       : setPosition( 10, myHeight-188 )
    myNode        : addChild( lineMid )

    local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    line2       : setPreferredSize( cc.size( 600, 3 ) )
    line2       : setAnchorPoint( 0, 1 )
    line2       : setPosition( 10, myHeight-226 )
    myNode      : addChild( line2 )

    local Text1 = { "雕像", "通关层数", "剩余血量", "进度" }
    local PosX  = { 80, 220, 370, 530 }
    for i=1,#Text1 do
      local lab = _G.Util : createLabel( Text1[i],FONT_SIZE )
      -- lab : setColor( color4 )
      lab : setAnchorPoint( 0.5, 1 )
      lab : setPosition( PosX[i], myHeight+2 )
      myNode : addChild( lab )
    end

    local function getCeng( myCeng )
      if myCeng == 0 or myCeng == nil then
        return 1
      end
      return myCeng
    end
    local function checkState( taget )
      if taget == 1 then
        return true
      end
      return false
    end

    local function getOver( )
      if checkState(msg.state1) and checkState(msg.state2) and checkState(msg.state3) and checkState(msg.state4) then
        return 1
      end
      return 0
    end

    local text1 = { "青龙", "白虎","总计",}-- "朱雀", "玄武",  }
    -- local cen1  = getCeng( msg.cen1 )
    -- local cen2  = getCeng( msg.cen2 )
    -- local cen3  = getCeng( msg.cen3 )
    -- local cen4  = getCeng( msg.cen4 )
    local cen1  = msg.cen1
    local cen2  = msg.cen2
    local cen3  = msg.cen3
    local cen4  = msg.cen4
    local text2 = { string.format("%s%s", _G.Lang.number_Chinese[cen1], "层"),
                    string.format("%s%s", _G.Lang.number_Chinese[cen2], "层"),
                    --string.format("%s%s", _G.Lang.number_Chinese[cen3], "层"),
                    --string.format("%s%s", _G.Lang.number_Chinese[cen4], "层"),
                    string.format("%s%s", _G.Lang.number_Chinese[(msg.cen1 or 0) + (msg.cen2 or 0) + (msg.cen3 or 0) + (msg.cen4 or 0)], "层") }
    local hp1   = msg.hp1
    local hp2   = msg.hp2
    local hp3   = msg.hp3
    local hp4   = msg.hp4
    local allLevHp = hp1 + hp2 --+ hp3 + hp4
    local allHp    = msg.all_hp1 + msg.all_hp2 --  + msg.all_hp3 + msg.all_hp4
    local floor1 =  { math.floor( hp1/msg.all_hp1*100), 
                      math.floor( hp2/msg.all_hp2*100), 
                    --  math.floor( hp3/msg.all_hp3*100),
                     -- math.floor( hp4/msg.all_hp4*100), 
                      math.floor( allLevHp/allHp*100)}
    local text3 = 
    { string.format( "%d%s%d%s", hp1, "(", floor1[1], "%)" ), 
      string.format( "%d%s%d%s", hp2, "(", floor1[2], "%)" ),
     -- string.format( "%d%s%d%s", hp3, "(", floor1[3], "%)" ), 
     -- string.format( "%d%s%d%s", hp4, "(", floor1[4], "%)" ),
      string.format( "%d%s%d%s", allLevHp, "(", floor1[3], "%)" )
   }
    local myText = { [0] = "进行中", "已结束" }
    print( "msg.state1=====>>>>>", msg.state1, msg.state2, msg.state3, msg.state4, getOver() )
    local text4  = { myText[msg.state1], 
                     myText[msg.state2], 
                     --myText[msg.state3], 
                     --myText[msg.state4],
                     myText[getOver()] }
    local alltext = { text1, text2, text3 ,text4}
    for i=1,3 do
        local myLab = {}
        for k=1,#alltext do
          myLab[k] = _G.Util : createLabel( alltext[k][i], 20 )
          myLab[k] : setPosition( PosX[k], myHeight-65-(i-1)*66 )
          myLab[k] : setAnchorPoint( 0.5, 1 )
          myNode   : addChild( myLab[k] )
          if k == 4 then
            -- myLab[k] : setColor( color4 )
            if alltext[k][i] == "已结束" then
              myLab[k] : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
            end
          end
          if i == 3 then
            myLab[k] : setColor( COLOR_GOLD )
          end
        end
        if floor1[i] <= 10 then
          myLab[3] : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_ORED ) )
        elseif floor1[i] <= 50 then
          --myLab[3] : setColor( color4 )
        end
    end

    local width   = 200 
    local endlab1 = _G.Util : createLabel( "你本次击杀了        个敌人", FONT_SIZE )
    endlab1       : setAnchorPoint( 0, 0 )
    endlab1       : setPosition( width, 14 )
    myNode        : addChild( endlab1 )

    self.killlab = _G.Util : createLabel( self.myKill or "100", FONT_SIZE )
    self.killlab : setAnchorPoint( 0.5, 0 )
    self.killlab : setPosition( 338, 14 )
    self.killlab : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_SPRINGGREEN ) )
    myNode       : addChild( self.killlab,5 )
  end
end

function ClanActivityLayer.Net_SELF_KILL( self, kill_num )
  self.myKill = kill_num 
  if self.killlab ~= nil then
    self.killlab : setString( kill_num )
  end
end

function ClanActivityLayer.showZBWords( self, which, myHeight, myData )
  local myNode = cc.Node : create()
  local width  = 20
  local height = myHeight - (which-1)*41
  for i=1,#myData do
    local myText = nil
    if myData[i] ~= nil then
      myText = _G.Util: createLabel( myData[i], 20 )
      myText : setAnchorPoint( 0, 1 )
      myText : setPosition( width, height )
      myNode : addChild( myText )
      width  = width + myText:getContentSize().width
      if i == 3 then
        myText : setColor( COLOR_GRASSGREEN )
      elseif i == 7 then
        if myData[7] == "成功" then
          myText : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN) )
        else
          myText : setColor( COLOR_ORED )
        end
      else
        -- myText : setColor( color1 )
      end
    end
  end
  local line = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  local lineY= line : getContentSize().height
  line : setPreferredSize( cc.size( 610, lineY ) )
  line : setAnchorPoint( 0, 1 )
  line : setPosition( 5, height+15-45 )
  myNode : addChild( line )

  return myNode
end

-- 3 ：门派 和 个人 排行，第一门派
function ClanActivityLayer.createRankView( self, _myType, msg )
    local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rankLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rankLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rankLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rankLayer,1000)

    local rankSize=cc.size(732,517)
    local secondSize=cc.size(712,460)
    local Spr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
    Spr1 : setPreferredSize( rankSize )
    Spr1 : setPosition( self.m_winSize.width/2, self.m_winSize.height/2-20 )
    self.m_rankLayer : addChild( Spr1 )

    local function closeFunSetting()
        print( "开始关闭" )
        self.m_rankLayer:removeFromParent(false)
        self.m_rankLayer=nil
    end

    local Btn_Close = gc.CButton : create("general_close.png")
    Btn_Close   : setPosition( cc.p( rankSize.width-23, rankSize.height-24) )
    Btn_Close   : addTouchEventListener( closeFunSetting )
    Spr1 : addChild( Btn_Close , 8 )

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2-135, rankSize.height-28)
    Spr1 : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2+130, rankSize.height-28)
    tipslogoSpr : setRotation(180)
    Spr1 : addChild(tipslogoSpr)

    local text1   = { [0] = "门派排行", "个人排行" }
    local m_titleLab=_G.Util:createBorderLabel(text1[msg.type],24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)

    local mainContent = cc.Node : create()
    mainContent : setPosition( 10,  0)
    Spr1 : addChild( mainContent )

    local width  = secondSize.width
    local height = secondSize.height
    local oneHeight=(secondSize.height-105)/10
    if _myType == 3 then
        local Text1  = { "排 名", "名 称", "总伤害", "总击杀" }
        local myPosX = { 70, 260, 450, 650 } 
        for i=1,4 do
          local lab = _G.Util : createLabel( Text1[i], 20 )
          -- lab       : setColor( color4 )
          lab       : setPosition( myPosX[i], height-10 )
          mainContent : addChild( lab, 3 )
        end
        local Line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
        Line1       : setPreferredSize( cc.size( width-10, 3 ) )
        -- Line1       : setAnchorPoint( 0, 0 )
        Line1       : setPosition( width/2, height-28 )
        mainContent : addChild( Line1, 5 )

        local Line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
        Line2       : setPreferredSize( cc.size( width-10, 3 ) )
        -- Line2       : setAnchorPoint( 0, 0 )
        Line2       : setPosition( width/2, 75 )
        mainContent : addChild( Line2, 5 )

        local star = cc.Sprite : createWithSpriteFrameName( "general_star.png" )
        star : setPosition( 25, 58 )
        -- star : setScale( 0.7 )
        mainContent : addChild( star )

        local myRank  = _G.Util : createLabel( msg.zrank, 20 )
        myRank : setPosition( myPosX[1], 58 )
        mainContent : addChild( myRank )

        local text1 = { _G.GPropertyProxy : getMainPlay() : getName() ,
                        [0] = _G.GPropertyProxy : getMainPlay() : getClanName() }

        local myName = _G.Util : createLabel( text1[msg.type], 20 )
        myName : setPosition( myPosX[2], 58 )
        mainContent : addChild( myName )

        local myharm = _G.Util : createLabel( msg.zharm, 20 )
        myharm       : setPosition( myPosX[3], 58 )
        mainContent  : addChild( myharm, 3 )

        local myKill = _G.Util : createLabel( msg.zkill, 20 )
        myKill : setPosition( myPosX[4], 58 )
        mainContent : addChild( myKill )  

        local Line4 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
        Line4       : setPreferredSize( cc.size( width-10, 3 ) )
        -- Line4       : setAnchorPoint( 0, 0 )
        Line4       : setPosition( width/2, 42 )
        mainContent : addChild( Line4, 5 )

        -- local tanhao = cc.Sprite : createWithSpriteFrameName( "general_tanhao.png" )
        -- tanhao  : setPosition( 70, 12 )
        -- mainContent : addChild( tanhao )

        local text2 = { "门派排名越高奖励越丰厚！", [0] = "伤害前三名可获得排名称号！" }
        local lab = _G.Util : createLabel( text2[msg.type], 20 )
        lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_ORED ) )
        lab : setPosition( width/2, 26 )
        -- lab : setAnchorPoint( 0, 0.5 )
        mainContent : addChild( lab )

        local myRank_Text = { {[0] = msg.rank,      msg.rank     },
                              {[0] = msg.clan_name, msg.name     },
                              {[0] = msg.all_bonus, msg.all_bonus},
                              {[0] = msg.killed,    msg.killed   }}
        local choice = msg.type
        local myNode = cc.Node : create()
        local COLOR_BLUE = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BLUE  ) 
        local myColor2 = { COLOR_ORED, COLOR_GOLD, COLOR_BLUE }
          

        for k=1,msg.count do
            for i=1,4 do
                -- print( "XXXX = ", myRank_Text[i], myRank_Text[i][choice], choice, myRank_Text[i][choice][k] )
                local lab = _G.Util : createLabel( myRank_Text[i][choice][k] or "" , 20 )
                -- lab       : setColor( color1 )
                lab       : setAnchorPoint( 0.5, 1 )
                lab       : setPosition( myPosX[i], -(k-1)*oneHeight-30 )
                myNode    : addChild( lab, 3 )
                if k <= 3 then
                    lab : setColor( myColor2[k] )
                end
            end
            local myline = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
            local lineY  = myline: getContentSize().height 
            myline       : setPreferredSize( cc.size( width-15, lineY ) )
            -- myline       : setAnchorPoint( 0, 1 )
            myline       : setPosition( width/2, -(k-1)*oneHeight-59 )
            myNode       : addChild( myline, 3 )
        end
        
        if msg.count <= 10 then
            myNode : setPosition( 0, oneHeight*10+100 )
            mainContent : addChild( myNode )
        else
            local mySize        = cc.size(width-8,oneHeight*10) 
            local My_Height     = msg.count*oneHeight
            local viewSize      = cc.size( mySize.width, mySize.height)
            local containerSize = cc.size( mySize.width, My_Height)
            local ScrollView    = cc.ScrollView : create()
            ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
            ScrollView  : setViewSize(viewSize)
            -- ScrollView  : setAnchorPoint( 0,0 )
            ScrollView  : setContentSize(containerSize)
            ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
            ScrollView  : setPosition( 0,78 )
            ScrollView  : setBounceable(true)
            ScrollView  : setTouchEnabled(true)
            ScrollView  : setDelegate()
            mainContent : addChild( ScrollView,5 )

            ScrollView  : addChild( myNode ) 
            myNode : setPosition( 0, My_Height+22 )
            
            local barView = require("mod.general.ScrollBar")(ScrollView)
        end
    end 
end

function ClanActivityLayer.CreateRedioBack( self, _ackMsg )
  local msg    = _ackMsg
  local width  = self.m_mainSize.width  
  local height = self.m_mainSize.height
  print( "开始创建战报table：", width, height )

  local Spr_Di2 = cc.Node:create()
  -- Spr_Di2       : setContentSize( cc.size( 477, 225 ) )
  Spr_Di2       : setPosition( 0, -5 )
  self.combatBG   : addChild( Spr_Di2, 2)

  local spizeY = height/2-100
  local Spr_Base = cc.Node : create( )
  Spr_Base   : setPosition( -width/2+30, spizeY )
  Spr_Di2    : addChild( Spr_Base, 3)

  local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  line1 : setPreferredSize( cc.size( width-10, 3 ) )
  -- line1 : setOpacity( 255*0.5 )
  -- line1 : setAnchorPoint( 0, 1 )
  line1 : setPosition( width/2, 157 )
  Spr_Di2 : addChild( line1, 3 )

  local line2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  line2 : setPreferredSize( cc.size( width-20, 2 ) )
  -- line2 : setOpacity( 255*0.4 )
  -- line2 : setAnchorPoint( 0, 1 )
  line2 : setPosition( width/2, 119 )
  Spr_Di2 : addChild( line2, 3 )

  local line3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  line3 : setPreferredSize( cc.size( width-20, 2 ) )
  -- line3 : setOpacity( 255*0.4 )
  -- line3 : setAnchorPoint( 0, 1 )
  line3 : setPosition( width/2, 81 )
  Spr_Di2 : addChild( line3, 3 )

  local line4 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  line4 : setPreferredSize( cc.size( width-10, 3 ) )
  -- line4 : setOpacity( 255*0.5 )
  -- line4 : setAnchorPoint( 0, 1 )
  line4 : setPosition( width/2, 45 )
  Spr_Di2 : addChild( line4, 3 )

  -- 数据在此
  -- 198 156 118 77 28
  local Text    = { "门派名称", "剩余人数", "总击杀数", "剩余战力" }
  local PosX    = { 75, 192, 310, 428 }
  local posy    = { 138, 100, 63, 175 }
  local myColor = { COLOR_GRASSGREEN, COLOR_WHITE, COLOR_WHITE, COLOR_GOLD }
  local place   = Spr_Di2
  for i=1,4 do
      local Text_Which = {}
      if i == 4 then 
          Text_Which = Text
          myColor    = { COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE }
      else
          if msg.data[i] == nil then
              Text_Which = { "暂无", "暂无", "暂无", "暂无" }
          else
              Text_Which = { msg.data[i].clan, msg.data[i].s_role, msg.data[i].sum_kill, msg.data[i].s_power }
          end
      end
      for k=1,4 do
          local myText = _G.Util : createLabel( Text_Which[k], 20 )
          myText  : setPosition( PosX[k], posy[i] )
          myText  : setColor( myColor[k] )
          place   : addChild( myText, 5 )
      end
  end
  local kill = 0
  if not self.batter then
    print( "self.batter没有数据!" )
  else
    kill = self.batter.kill or 0
    print( "击杀了多少人：", kill, self.batter.kill )
  end
  local myWidth = width/2-100 
  local Text    = { "你本次击杀了", kill, "个敌人！" }
  local myColor = { COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE } 
  for i=1,3 do
      local mylab = _G.Util : createLabel( Text[i], 20 )
      mylab       : setColor( myColor[i] )
      mylab       : setAnchorPoint( 0, 0.5 )
      mylab       : setPosition( myWidth, 25 )
      Spr_Di2     : addChild( mylab, 5 )
      myWidth = myWidth + mylab:getContentSize().width
  end

end

function ClanActivityLayer._combatTime( self,times)
  local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times

    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)

    local temptime = ""
    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    else
        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime  = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime  = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    return temptime
end



function ClanActivityLayer._getTimeStr( self,_time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)
    local time = tostring(hour)..":"..tostring(min)..":"..second
    if hour < 10 then
        hour = "0"..hour
    elseif hour < 0 then
        hour = "00"
    end
    if min < 10 then
        min = "0"..min
    elseif min < 0 then
        min = "00"
    end
    if second < 10 then
        second = "0"..second
    end

    local time = ""

    time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

function ClanActivityLayer.createGroup( self, msg )

  local function onTouchBegan() return true end
  local listerner=cc.EventListenerTouchOneByOne:create()
  listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  listerner:setSwallowTouches(true)

  local NewView = cc.LayerColor:create(cc.c4b(0,0,0,255*0.5))
  NewView : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,NewView)
  cc.Director : getInstance() : getRunningScene() : addChild( NewView, 999 )

  local function closeFunSetting( obj, eventType )
    if eventType == ccui.TouchEventType.ended then
      print( "开始关闭" )
      if NewView == nil then return end
      NewView : removeFromParent( true )
      NewView = nil
    end
  end

  local mySize = cc.size( 754, 515 )

  local mainContent = cc.Node : create()
  mainContent : setPosition( self.m_winSize.width/2, self.m_winSize.height/2-30)
  NewView : addChild( mainContent )

  local base1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
  base1 : setPreferredSize( mySize )
  mainContent : addChild( base1, -3 )

  local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
  frameSpr:setPreferredSize(cc.size(740,460))
  frameSpr:setPosition(0,-20)
  mainContent:addChild(frameSpr,-3)

  local title = cc.Sprite : createWithSpriteFrameName( "general_tips_up.png" )
  title : setPosition( -135, mySize.height/2 -28 )
  mainContent : addChild( title, 4 )

  local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
  titleSpr:setPosition(130,mySize.height/2 -28)
  titleSpr:setRotation(180)
  mainContent:addChild(titleSpr,4)

  local titleText = _G.Util : createBorderLabel( "门派大战", 24, _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
  titleText:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  titleText : setPosition( 0, mySize.height/2 -28 )
  mainContent : addChild( titleText, 4 )

  local Btn_Close = gc.CButton : create()
  Btn_Close   : loadTextures( "general_close.png" )
  Btn_Close   : addTouchEventListener( closeFunSetting )
  Btn_Close   : setPosition( mySize.width/2-23, mySize.height/2-23 )
  mainContent : addChild(Btn_Close, 3)

  local node2 = cc.Node : create()
  node2 : setPosition( -45, 30 )
  frameSpr : addChild( node2 )

  self : createShowView( node2, msg )
end

function ClanActivityLayer.createShowView( self, place, _ackMsg )
  local msg = _ackMsg
  self.Lab_DongfuName = {}
  local posx = { 70,70,70,    70,70,70,     70,70,70,   310,310,310,  580 }
  local posy = { 410,365,320, 260,215,170,  110,65,20,  365,215,65,   215 }
 
  for i=1,13 do
    local Name_Kuang = cc.Sprite : createWithSpriteFrameName( "clan_kuan.png" )
    Name_Kuang : setAnchorPoint( 0, 1 )
    -- Name_Kuang : setPreferredSize( cc.size( 137, 40 ) )
    Name_Kuang : setPosition( posx[i]-1, posy[i]+2 )
    place : addChild( Name_Kuang, 3 )

    self.Lab_DongfuName[i] = _G.Util : createLabel( "", FONT_SIZE )
    self.Lab_DongfuName[i] : setAnchorPoint( 0.5, 1 )
    self.Lab_DongfuName[i] : setPosition( posx[i]+75, posy[i]-3 )
    -- self.Lab_DongfuName[i] : setColor( color1 )
    place : addChild( self.Lab_DongfuName[i],5 )
  end
  local Spr_Kuang = cc.Sprite : createWithSpriteFrameName( "clan_winflag.png" )
  Spr_Kuang : setAnchorPoint( 0, 0.5 )
  Spr_Kuang : setPosition( posx[13]-39, posy[13]-45 )
  place : addChild( Spr_Kuang )

  -- self.Lab_DongfuName[13] = _G.Util : createLabel( "", FONT_SIZE-1 )
  -- self.Lab_DongfuName[13] : setAnchorPoint( 0.5, 1 )
  -- self.Lab_DongfuName[13] : setPosition( posx[13], posy[13]-31 )
  -- -- self.Lab_DongfuName[13] : setColor( color1 )
  -- place : addChild( self.Lab_DongfuName[13],5 )

  local piture = "clan_line_blue.png"
  for i=1,4 do
    for k=1,6 do
      self : createOneLine( place, k, i, piture )
    end
  end

  print(" 开始测试数量              :", msg.count       )
  local myCeng = { 0, 9, 12 }
  local Text_Group = { [16]=12, [13]=11, [10]=10 } 
  local RankName = {}
  for i=1,msg.count do
    print(" 第几层            :", msg.data[i].ceng      )

    local ceng = msg.data[i].ceng
    for k=1,msg.data[i].group_count do
      -- print(" 3.第几组            :", msg.data[i].data[k].group   )
      local group_num = msg.data[i].data[k].group
      for t=1,msg.data[i].data[k].clan_count do
        local num  = myCeng[ceng] + group_num*3 -3 + msg.data[i].data[k].data[t].idx
        if ceng == 2 then
          num = Text_Group[myCeng[ceng] + group_num*3 -3 + msg.data[i].data[k].data[t].idx]
        end
        print( "得到的num是：", num, ceng, myCeng[ceng], group_num*3 -3,msg.data[i].data[k].data[t].idx )
        local name = msg.data[i].data[k].data[t].clan_name 
        RankName[num] = name
        self.Lab_DongfuName[num] : setString( name ) 
      end
    end
    
  end

  for i=1,#RankName do
    print("RankName[i] = ", RankName[i])
    if i>9 and i<13 then 
      for t=1,3 do
        if RankName[10] == RankName[t] then
          self : createWinLine( place, t, 1 )
        end
      end
      for t=4,6 do
        if RankName[11] == RankName[t] then
          self : createWinLine( place, t, 1 )
        end
      end
      for t=7,9 do
        if RankName[12] == RankName[t] then
          self : createWinLine( place, t, 1 )
        end
      end
    elseif i == 13 then 
      for t=1,9 do
        if RankName[13] == RankName[t] then
          print( "t = ", t )
          self : createWinLine( place, t, 2 )
        end
      end
    end
  end
end

function ClanActivityLayer.createOneLine( self, place, num, which, piture )
  local Rota_num   = { 0,           90,         0,            0,            90,         0   }
  local Posx_num   = { 180,         225,        180,          180,          225,        222 }
  local Posy_num   = { 395,         395,        351,          307,          351,        351 }
  local Posy_4_num = { 43,          43,         150,          258,          150,        150 }
  local Posx_4_num = { 180,         235,        180,          180,          235,        232 }
  local MySetX     = { 45,  45, 45, 45,  45, 55 }
  local My4SetX    = { 55, 152, 55, 55, 152, 61 }
  local myHeight   = 2
  if piture == "clan_line_yellow.png" then
    myHeight = 3
  end
  local Posx_which = { 0,       0,      0,   305  }
  local Posy_which = { 0,  150, 300,   40   }

  local Spr_line = ccui.Scale9Sprite : createWithSpriteFrameName( piture )
  Spr_line : setAnchorPoint( 0, 1 )
  Spr_line : setPosition( Posx_num[num]+35+Posx_which[which], Posy_num[num]-Posy_which[which] )
  Spr_line : setRotation(Rota_num[num])
  place : addChild( Spr_line )

  if which == 4 then
    Spr_line : setPosition( Posx_4_num[num]-27+Posx_which[which], Posy_num[num]-Posy_4_num[num] )
    Spr_line : setPreferredSize( cc.size( My4SetX[num], myHeight ) )
  else
    Spr_line : setPreferredSize( cc.size( MySetX[num], myHeight ) )
  end

end

function ClanActivityLayer.createWinLine( self, place, whoWin, which )
  local Text_GetInto = { {1, 2, 6}, {3, 6}, {4, 5, 6} }
  local Text_WhoWin  = { {1,2,3,  1,2,3,  1,2,3},{1,1,1,  2,2,2,  3,3,3}}
  local aaa          = Text_GetInto[ Text_WhoWin[which][whoWin] ]
  local toWhich      = { math.floor((whoWin-1)/3)+1, 4 }  
  for i=1,#aaa do
    local num = aaa[i]
    print( "num = ", num, "which = ", toWhich[which] )
    self : createOneLine( place, num, toWhich[which], "clan_line_yellow.png" )
  end
  print( "\n" )
end

function ClanActivityLayer.createNewScrollview( self, place )

  local function myTouchEvent( ojb, eventType )
    tag = ojb : getTag()
    if eventType == ccui.TouchEventType.ended then
      if tag == Tag_Btn_Zhanbao then
        print( "门派大战----战报" )
        self : REQ_GANG_WARFARE_WAR_REPORT()
      end
    end
  end

  local myNode = cc.Node : create()

  local My_Height  = 0
  local text_clan  = _G.Cfg.clan_active_all[3]
  local MyText     = { "奖    励：", text_clan.reward, "时    间：", text_clan.type1, "参与条件：", text_clan.condition, "详细规则：" }
  local Text_Color = { COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE, COLOR_GRASSGREEN, COLOR_WHITE }
  local gap        = 120
  local posx       = { 30, gap, 30, gap, 30, gap, 30 }
  local posy       = { My_Height-10, My_Height-10, My_Height-40, My_Height-40, My_Height-70, My_Height-70, My_Height-105 }
  for i=1,7 do
    local lab = _G.Util : createLabel( MyText[i], FONT_SIZE )
    lab : setColor( Text_Color[i] )
    lab : setAnchorPoint( 0, 1 )
    lab : setPosition( posx[i], posy[i] )
    myNode : addChild( lab )
  end
  local Btn_Zhanbao = gc.CButton:create( )
  Btn_Zhanbao       : loadTextures( "general_wrod_zb.png" )
  Btn_Zhanbao       : setPosition( 560, My_Height-45 )
  Btn_Zhanbao       : setTag( Tag_Btn_Zhanbao )
  Btn_Zhanbao       : addTouchEventListener( myTouchEvent )
  myNode        : addChild( Btn_Zhanbao )

  local Lab_Value = _G.Util : createLabel( text_clan.value1, FONT_SIZE )
  -- Lab_Value : setColor( color4 )
  Lab_Value : setAnchorPoint( 0, 1 )
  Lab_Value : setDimensions( 570, 0)
  Lab_Value : setPosition( 30, My_Height-135 )
  myNode : addChild( Lab_Value )

  local mySize        = cc.size(622,387) 
  local My_Height     = 131 + Lab_Value:getContentSize().height + 10
  local viewSize      = cc.size( mySize.width, mySize.height)
  local containerSize = cc.size( mySize.width, My_Height)
  local ScrollView    = cc.ScrollView : create()
  ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  ScrollView  : setViewSize(viewSize)
  ScrollView  : setAnchorPoint( 0,0 )
  ScrollView  : setContentSize(containerSize)
  ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
  ScrollView  : setPosition( 0,3 )
  ScrollView  : setBounceable(true)
  ScrollView  : setTouchEnabled(true)
  ScrollView  : setDelegate()
  place       : addChild( ScrollView )

  local barView = require("mod.general.ScrollBar")(ScrollView)
  -- local color5  = _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_BROWN )

  myNode : setPosition( 0, My_Height )
  ScrollView : addChild( myNode )
end

function ClanActivityLayer.REQ_CLAN_SELF_POST( self )
    local msg = REQ_CLAN_SELF_POST()
    _G.Network : send( msg )
end

function ClanActivityLayer.REQ_GANG_WARFARE_REPLAY( self )
  local msg = REQ_GANG_WARFARE_REPLAY()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_WARFARE_BACK( self, isEnter )
  print( "0:不可以1：可以  ：", isEnter )
  if self.Btn_myFight==nil then return end
  if isEnter == 0 then
    self.Btn_myFight : setTouchEnabled( false )
    self.Btn_myFight : setGray()
  elseif isEnter == 1 then
    self.Btn_myFight : setTouchEnabled( true )
    self.Btn_myFight : setDefault()
  end
end

function ClanActivityLayer.REQ_GANG_WARFARE_WAR_REPORT( self )
  local msg = REQ_GANG_WARFARE_WAR_REPORT()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_WARFARE_ONCE( self, _ackMsg )
  local msg = _ackMsg
  self.batter = msg
  print( "个人击杀数量: ", msg.kill )
  print( "个人连击数  : ", msg.batter_kill )
  print( "复活次数    : ", msg.rec )
end

function ClanActivityLayer.Net_WARFARE_C_FINISH( self, _ackMsg )
  local msg = _ackMsg
  local function sort( data1, data2 )
      if data1.s_role > data2.s_role then 
        return true 
      elseif data1.s_role == data2.s_role then 
        if data1.sum_kill > data2.sum_kill then 
            return true
        else 
            return false 
        end
      else
        return false
      end
  end
  table.sort( msg.data , sort )

  print( "类型0：初赛，1：决赛 -->", msg.type )
  print( "输赢    : ", msg.res )
  print( "参赛门派数量: ", msg.count, "\n" )
  for i=1,msg.count do
    print(" 门派名字        :",   msg.data[i].clan  )
    print(" 门派击杀人数    :",   msg.data[i].sum_kill  )
    print(" 门派剩余人数    :",   msg.data[i].s_role  )
    print(" 门派等级        :",   msg.data[i].clan_lv )
    print(" 门派剩余平均战力 :",    msg.data[i].s_power, "\n" )
  end

  local Text = "" 
  local res  = { [0]="失利", [1]="胜出" } 
  if msg.type == 1 then
    Text = string.format( "%s%s", "初战", res[ msg.res ] )
  elseif msg.type == 2 then
    Text = string.format( "%s%s", "决赛", res[ msg.res ] )
  end

  local frameSize=cc.size(520,250)
  local Text_1  = Text or "" 
  local combatView  = require("mod.general.BattleMsgView")()
  self.combatBG = combatView : create(Text,frameSize)

  self.m_mainSize = combatView : getSize()
  self : CreateRedioBack( msg )
end

function ClanActivityLayer.Net_POST_BACK( self, _ackMsg )
    self.myUpost = _ackMsg.post
    print( "个人职位号：", self.myUpost)
end

function ClanActivityLayer.REQ_GANG_WARFARE_REQ( self )
  local msg = REQ_GANG_WARFARE_REQ()
  _G.Network : send( msg )
end

function ClanActivityLayer.Net_WARFARE_GROUP( self, _ackMsg )
  local msg = _ackMsg
  print(" 1.数量              :", msg.count       )
  if msg == nil or msg.count == nil or msg.count <= 0 then
    local command = CErrorBoxCommand(36980)
    controller :sendCommand( command )
  else
    for i=1,msg.count do
      print(" 2.第几层            :", msg.data[i].ceng      )
      print(" 2.组的数量          :", msg.data[i].group_count     )
      for k=1,msg.data[i].group_count do
        print(" 3.第几组            :", msg.data[i].data[k].group   )
        print(" 3.门派数量          :", msg.data[i].data[k].clan_count    )
        for t=1,msg.data[i].data[k].clan_count do
          print(" 4.位置              :", msg.data[i].data[k].data[t].idx )
          print(" 4.门派名字          :", msg.data[i].data[k].data[t].clan_name )
        end
        print( "\n" )
      end
    end
    self : createGroup( msg )
  end
  
end

function ClanActivityLayer.REQ_GANG_WARFARE_ENTER_MAP( self )
  local msg = REQ_GANG_WARFARE_ENTER_MAP()
  _G.Network : send( msg )
end

function ClanActivityLayer.REQ_GANG_WARFARE_ONCE_REQ( self )
  local msg = REQ_GANG_WARFARE_ONCE_REQ()
  _G.Network : send( msg )
end



function ClanActivityLayer.createFightPanel( self )
    local mySize = cc.size(628,492)
    local function ButtonCallBack( ojb, eventType )
      tag = ojb : getTag()
      if eventType==ccui.TouchEventType.ended then
        print( "按下：", tag )
        if tag == Tag_Btn_myFight then
          self : REQ_GANG_WARFARE_ENTER_MAP()
        elseif tag == Tag_Btn_Group then
          -- self : createGroup()
          self : REQ_GANG_WARFARE_REQ()
        end 
      end
    end
    print( "开始创建门派大战面板：ClanActivityLayer.createFightPanel" )
    self : REQ_GANG_WARFARE_REPLAY()
    if self.my_FightNode == nil then
      self.my_FightNode = cc.Node : create()
      self.my_FightNode : setPosition( 40, 0 )

      self.Btn_myFight = gc.CButton : create()
      self.Btn_myFight : setPosition( 30, mySize.height-15 )
      self.Btn_myFight : setAnchorPoint( 0, 1 )
      self.Btn_myFight : loadTextures( "clan_word_jrzd_0.png" )
      self.Btn_myFight : setTag( Tag_Btn_myFight ) 
      self.Btn_myFight : addTouchEventListener( ButtonCallBack )
      self.my_FightNode: addChild( self.Btn_myFight )
      self.Btn_myFight : setTouchEnabled( false )
      self.Btn_myFight : setGray()

      local Btn_Group = gc.CButton : create()
      Btn_Group : setPosition( mySize.width-35, mySize.height-35 )
      Btn_Group : loadTextures( "general_btn_gold.png" )
      Btn_Group : setTitleText( "分组信息" )
      Btn_Group : setTitleFontName( _G.FontName.Heiti )
      Btn_Group : setTitleFontSize( FONT_SIZE+2 )
      Btn_Group : setAnchorPoint( 1, 1 )
      Btn_Group : setTag( Tag_Btn_Group )
      Btn_Group : addTouchEventListener( ButtonCallBack )
      self.my_FightNode : addChild( Btn_Group )

      local myDoubleLine = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
      myDoubleLine : setContentSize( mySize.width-20, 2 )
      myDoubleLine : setPosition( mySize.width/2, mySize.height-100 )
      self.my_FightNode : addChild( myDoubleLine )

      self : createNewScrollview( self.my_FightNode )
    end

    return self.my_FightNode
end

function ClanActivityLayer.requireQifu( self )
    self : REQ_CLIFFORD_REQUEST()
end

function ClanActivityLayer.REQ_CLIFFORD_REQUEST( self )
    local msg = REQ_CLIFFORD_REQUEST()
    _G.Network : send( msg )
end

function ClanActivityLayer.chuangIconNum( self, _num )
    local myPosy = 147
    if self.m_tagPanel[TAGBIN_QIFU] then
      self : requireQifu()
    end

    if _num <= 0 then
      if self.jiaobiaoSpr ~= nil then
        self.jiaobiaoSpr : removeFromParent(true)
        self.jiaobiaoSpr = nil
      end
      return
    end
    if self.m_leftBtnArray[TAGBIN_QIFU]==nil then return end

    if self.jiaobiaoSpr then
      self.jiaobiaoSpr : getChildByTag(1) : setString( _num )
    else
      local btnsize=self.m_leftBtnArray[TAGBIN_QIFU]:getContentSize()
      self.jiaobiaoSpr = cc.Sprite : createWithSpriteFrameName( "general_report_tips2.png" )
      self.jiaobiaoSpr : setPosition( btnsize.width-10, btnsize.height-15 )
      self.m_leftBtnArray[TAGBIN_QIFU] : addChild( self.jiaobiaoSpr, 10 )

      local lab = _G.Util : createLabel( _num, 18 )
      lab : setPosition( self.jiaobiaoSpr:getContentSize().width/2, self.jiaobiaoSpr:getContentSize().height/2-2 )
      lab : setTag( 1 )
      self.jiaobiaoSpr : addChild( lab )
    end
end

function ClanActivityLayer.Net_CLIFFORD_REPLY( self, _ackMsg)
    local msg = _ackMsg
    print(" 剩余祈福次数   :", msg.num     )
    print(" 总的祈福值    :",  msg.value   )
    print(" 战报数量 (循环)  :",  msg.count  )
    print(" 宝箱数量 (循环)  :",  msg.counts )
    self.qifu_times = msg.num
    self.times_qifu  : setString( msg.num  )
    self.lab_fuzhiValue : setString( msg.value )

    self : changeJindutiaoValue( msg.value )
    self : changeQifuScrollview( msg.data, msg.count )

    if msg.num <= 0 then
      self.btn_qifu : setTouchEnabled(false)
      self.btn_qifu : setGray()

      self.times_qifu : setColor( COLOR_ORED )
    else
      self.btn_qifu : setTouchEnabled(true)
      self.btn_qifu : setDefault()
    end

    self.qifu_zhaobao = {}
    self.qifu_zhaobao.count = count
    self.qifu_zhaobao.data  = msg.data            
    for i=1,msg.count do
      print("第",i,",玩家名字：", msg.data[i].name)
    end

    self.myDate = {}
    for i=1,msg.counts do
      print( " 可领编号：", msg.xz_data[i].idx )
      self.myDate[msg.xz_data[i].idx] = true
    end
    local function getHightValue( value )
      local table_qifu = _G.Cfg.clan_qifu
      for i=1,5 do
        if value >= table_qifu[7-i].value then
          return 6-i
        end
      end
      return 0
    end
    local getNum = getHightValue( msg.value )
    -- print( "getNum = ", getNum )
    for i=1,getNum do
      if self.myDate[i] then
        self.qifu_xiangzi[i] : setDefault()
      else
        self.qifu_xiangzi[i] : setDefault()
        self.qifu_xiangzi[i] : loadTextures( "gl_open.png" )
      end
    end
end

function ClanActivityLayer.createQifuScrollView( self, _place )
    local size2 = cc.size( 326, 300 )

    local ScrollView=cc.ScrollView:create()
    ScrollView:setTouchEnabled(true)
    ScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    ScrollView:setContentSize(size2)
    ScrollView:setViewSize(size2) 
    ScrollView:setPosition(cc.p(0,3))     
    _place:addChild(ScrollView)
    self.qifuScrollview = ScrollView

end

function ClanActivityLayer.changeQifuScrollview( self, _data, _count )
    local data  = _data
    local count = _count
    if self.qifuBarview ~= nil then
      self.qifuBarview : remove()
      self.qifuBarview = nil
    end 
    if self.qifuSNode ~= nil then
      self.qifuSNode : removeFromParent(true)
      self.qifuSNode = nil
    end

    local oneHeight  = 60
    local size2      = cc.size( 326, 300 )
    local allHeight  = count * oneHeight
    local ScrollView = self.qifuScrollview
    if allHeight > size2.height then
      ScrollView : setContentSize( cc.size( size2.width, oneHeight*count ) )
      ScrollView : setContentOffset( cc.p( 0,size2.height-allHeight ) )
    else
      allHeight  = size2.height
    end

    self.qifuBarview=require("mod.general.ScrollBar")(ScrollView)
    self.qifuBarview:setPosOff(cc.p(-4,0))

    local node = cc.Node : create()
    node       : setPosition( 10, allHeight )
    ScrollView : addChild( node )
    self.qifuSNode = node

    local box_red = _G.Cfg.clan_qifu[1].box_red[1]
    local table_1 = { "", "", "为门派祈福", "获得:", string.format("%s*%d", _G.Cfg.goods[box_red[1]].name, box_red[2] ) }
    local posy    = { 5, 5, 5, 30, 30 }
    local myColor = { COLOR_WHITE ,COLOR_GRASSGREEN, COLOR_WHITE, COLOR_WHITE, COLOR_GRASSGREEN }  
    for i=1,count do
      table_1[1] = self : _combatTime( data[i].time ).." "
      table_1[2] = data[i].name.." "
      
      local myLab = {}
      local posx  = 0
      for k=1,#table_1 do
        if k == 2 or k == 3 or k == 5 then
          posx = myLab[k-1]:getContentSize().width + posx+8
        else
          posx  = 8
        end
        myLab[k] = _G.Util : createLabel( table_1[k], 20 ) 
        myLab[k] : setAnchorPoint( 0, 1 )
        myLab[k] : setPosition( posx, -(i-1)*oneHeight-posy[k] )
        myLab[k] : setColor( myColor[k] )
        node     : addChild( myLab[k] )
      end
      
    end
end

function ClanActivityLayer.changeJindutiaoValue( self, _value )
    local table_jindu = { [0]=0, 1, 2, 3, 4, 4 }
    local function check_jindu( _value )
      local table_qifu = _G.Cfg.clan_qifu
      for i=1,5 do
        if _value >= table_qifu[7-i].value then
          return 6-i
        end
      end
      return 0
    end  
    local percent = check_jindu( _value )
    local allPercent = table_jindu[ percent ]
    print( "allPercent >>>>>>>>> ", allPercent, percent )

    if _value > 30 then 
      self.gl_jindutiao : setPercent( 100 )
    else
      self.gl_jindutiao : setPercent( (_value/30)*100 )
    end
    
end

function ClanActivityLayer.REQ_CLIFFORD_START( self )
    local msg  = REQ_CLIFFORD_START()
    _G.Network : send( msg )
end

function ClanActivityLayer.Net_CLIFFORD_OVER( self )
    print( "祈福成功！" )
    _G.Util:playAudioEffect("ui_draw_partner")
    self.qifu_times = self.qifu_times - 1
    self.times_qifu  : setString( self.qifu_times )
    if self.qifu_times <= 0 then
      self.btn_qifu : setTouchEnabled(false)
      self.btn_qifu : setGray()

      self.times_qifu : setColor( COLOR_WHITE )
    end
end

function ClanActivityLayer.REQ_CLIFFORD_LQ_REWAR( self, _idx )
   local msg  = REQ_CLIFFORD_LQ_REWAR()
   msg : setArgs( _idx )
   _G.Network : send( msg )
end

function ClanActivityLayer.Net_LQ_BACK( self, _ackMsg )
    print( "领取成功" )
    local idx = _ackMsg.idx
    self.myDate[idx] = false
    self.qifu_xiangzi[idx] : loadTextures( "gl_open.png" )

end

function ClanActivityLayer.MessageBox3( self )
  local function tipsSure()
    self : REQ_CLIFFORD_START()
  end
  local function cancel()
    
  end
 
  if self.qifu_times <= 0 then
    local command = CErrorBoxCommand(27190)
    controller :sendCommand( command )
    return
  end
  local tipsBox = require("mod.general.TipsBox")()
  local tipsNode   = tipsBox :create( "", tipsSure, cancel)
  tipsNode : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
  self.m_container  : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  tipsBox : setTitleLabel("提 示")

  local layer=tipsBox:getMainlayer()
  local Yuanbao = _G.Const.CONST_CLAN_QIFU_XH
  local lab = _G.Util : createLabel( "花费"..Yuanbao.."元宝进行门派祈福？" , FONT_SIZE )
  lab : setPosition( 0, 40 )
  layer : addChild( lab )

  local lab2 = _G.Util : createLabel( "（元宝不足则消耗钻石）" , FONT_SIZE-2  )
  lab2 : setPosition( 0, 15 )
  layer : addChild( lab2 )
end

function ClanActivityLayer.createQifu( self )
    local mySize = cc.size(629,492)
    local function QifuCallBack( obj, eventType )
      tag = obj:getTag()
      if eventType==ccui.TouchEventType.ended then
        if tag == 77 then
          local explainView  = require("mod.general.ExplainView")()
          local explainLayer = explainView : create(30160)
        elseif tag == 88 then
          self : MessageBox3()
        end
      end
    end

    if not self.my_QifuNode then
      self.my_QifuNode = cc.Node : create()
      self.my_QifuNode : setPosition( 40, 0 )
      local jinduY     = mySize.height-120

      local Btn_Explain = gc.CButton : create()
      Btn_Explain : loadTextures( "general_help.png" )
      Btn_Explain : setAnchorPoint( 1, 1 )
      Btn_Explain : setPosition( mySize.width-30, mySize.height-30 )
      Btn_Explain : setTag( 77 )
      Btn_Explain : addTouchEventListener( QifuCallBack )
      self.my_QifuNode : addChild( Btn_Explain )

      local size2 = cc.size( 270, 307 )
      local base_lef = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
      base_lef : setContentSize(size2)
      base_lef : setAnchorPoint( 0, 0 )
      base_lef : setPosition( 10, 10 )
      self.my_QifuNode : addChild( base_lef )

      local rightsize2 = cc.size( 328, 307 )
      local base_rig = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
      base_rig : setContentSize( rightsize2 )
      base_rig : setAnchorPoint( 0, 0 )
      base_rig : setPosition( 289, 10 )
      self.my_QifuNode : addChild( base_rig )

      -- 进度条
      self : JinduTiao( self.my_QifuNode, 0.7 )
      -- Scrollview
      self : createQifuScrollView( base_rig )

      local spr_lu = cc.Sprite : createWithSpriteFrameName( "clan_qifu.png" )
      spr_lu   : setPosition( size2.width/2, size2.height-30 )
      spr_lu   : setAnchorPoint( 0.5, 1 )
      base_lef : addChild( spr_lu ) 

      local lab1 = _G.Util : createLabel( "今日剩余次数:", FONT_SIZE )
      lab1 : setPosition( size2.width/2-4, size2.height/2-20 )
      -- lab1 : setColor( color4 )
      base_lef : addChild( lab1 )

      local lab2 = _G.Util : createLabel( "2", FONT_SIZE )
      lab2 : setPosition( size2.width/2+lab1:getContentSize().width/2+3, size2.height/2-20 )
      lab2 : setColor( COLOR_GRASSGREEN )
      base_lef : addChild( lab2 )
      self.times_qifu = lab2

      local btn_qifu = gc.CButton : create()
      btn_qifu : loadTextures( "general_btn_gold.png" )
      btn_qifu : setAnchorPoint( 0.5, 1 )
      btn_qifu : setPosition( size2.width/2, size2.height/2-55 )
      btn_qifu : setTitleText( "祈 福" )
      btn_qifu : setTitleFontName( _G.FontName.Heiti )
      btn_qifu : setTitleFontSize( FONT_SIZE+4 )
      btn_qifu : setTag( Tag_Btn_qifu )
      btn_qifu : addTouchEventListener( QifuCallBack )
      base_lef : addChild( btn_qifu )
      btn_qifu : setTouchEnabled( false )
      btn_qifu : setGray()
      self.btn_qifu = btn_qifu

      local lab3 = _G.Util : createLabel("祈福可得", FONT_SIZE )
      lab3 : setPosition(80, 15 )
      lab3 : setAnchorPoint( 0.5, 0 )
      -- lab3 : setColor( color4 )
      base_lef : addChild( lab3 )
      local goodData =  _G.Cfg.goods[41105]
      local strName =  goodData.name
      local colorValue = goodData.name_color
      local liBaoName = _G.Util : createLabel(strName,FONT_SIZE)
      liBaoName : setColor(_G.ColorUtil : getRGB(colorValue))
      liBaoName : setAnchorPoint( 0.5, 0 )
      liBaoName : setPosition(178 ,15)
      base_lef : addChild(liBaoName)


    end
    return self.my_QifuNode
end

function ClanActivityLayer.boxTips( self, tag )
  local idstep = tag
  local _pos   = self.qifu_xiangzi[tag]:getWorldPosition()

  local boxD = _G.Cfg.clan_qifu[tag+1]
  local red  = boxD.box_red[1]
  local temp = _G.TipsUtil : createById(red[1],nil,_pos)
  cc.Director:getInstance():getRunningScene() : addChild(temp,1000)

end

function ClanActivityLayer.JinduTiao( self, _place, _size )
    local function QifuCallBack( obj, eventType )
      tag = obj:getTag()
      if eventType==ccui.TouchEventType.ended then
          local box_type = obj:isBright()
          if box_type and self.myDate[tag] then
            local idstep = tag
            print("领取宝箱奖励",box_type, idstep)
            self : REQ_CLIFFORD_LQ_REWAR( idstep )
          else  
            print("宝箱tips奖励",box_type)
            self:boxTips(tag)
          end
      end
    end

    local mySize     = cc.size(629,490)
    local table_qifu = _G.Cfg.clan_qifu
    local jinduY     = mySize.height-110

    local lab_fuzhi  = _G.Util : createLabel( "福值: ", FONT_SIZE )
    -- lab_fuzhi : enableOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
    -- lab_fuzhi : setColor(COLOR_WHITE)
    lab_fuzhi : setAnchorPoint( 0, 0.5 )
    lab_fuzhi : setPosition( 15, jinduY) 
    _place : addChild( lab_fuzhi )

    local lab_fuzhiValue = _G.Util : createLabel( "", FONT_SIZE )
    lab_fuzhiValue : setColor( COLOR_GRASSGREEN )
    lab_fuzhiValue : setAnchorPoint( 0, 0.5 )
    lab_fuzhiValue : setPosition( 20+lab_fuzhi:getContentSize().width, jinduY) 
    _place : addChild( lab_fuzhiValue, 1 )
    self.lab_fuzhiValue = lab_fuzhiValue

    local lab_fuzhiWidth = lab_fuzhi:getContentSize().width + 40
    local spr_jinduDi = ccui.Scale9Sprite : createWithSpriteFrameName( "clan_expbg.png" )
    --spr_jinduDi : setScale9Enabled(true)
    spr_jinduDi : setPreferredSize(cc.size(460,20))
    spr_jinduDi : setAnchorPoint( 0, 0.5 )
    spr_jinduDi : setPosition( lab_fuzhiWidth+40, jinduY )
    _place : addChild( spr_jinduDi )

    local expSize = spr_jinduDi:getContentSize()
    self.gl_jindutiao = ccui.LoadingBar:create()
    self.gl_jindutiao : loadTexture("clan_exp.png",ccui.TextureResType.plistType)
    self.gl_jindutiao : setPosition(expSize.width/2,expSize.height/2)
    spr_jinduDi       : addChild(self.gl_jindutiao)

    local boxWidth    = 47
    local myWidth     = self.gl_jindutiao:getContentSize().width
    local allPercent  = table_qifu[6].value*myWidth/(myWidth-4*boxWidth)
    local gap         = boxWidth/myWidth
    self.allPercent   = allPercent  
    self.gap          = gap

    self.gl_jindutiao : setPercent(0)

    self.qifu_xiangzi = {}
    print( "allPercent = ", allPercent, gap )
    local oneWidth=expSize.width/4
    for i=1,5 do
      self.qifu_xiangzi[i] = gc.CButton : create()
      self.qifu_xiangzi[i] : loadTextures( "gl_box_light.png" )
      -- self.qifu_xiangzi[i] : setAnchorPoint( 0, 0.5 )
      self.qifu_xiangzi[i] : setPosition(i*oneWidth+8, jinduY )
      self.qifu_xiangzi[i] : setTag( i )
      self.qifu_xiangzi[i] : addTouchEventListener( QifuCallBack )
      _place : addChild( self.qifu_xiangzi[i],1 )
      self.qifu_xiangzi[i] : setGray()

      local lab = _G.Util : createLabel( table_qifu[i+1].value, FONT_SIZE )
      -- lab : setColor( color4 )
      lab : setPosition( i*oneWidth-10, jinduY-42 )
      self.my_QifuNode : addChild( lab )
    end
end

return ClanActivityLayer