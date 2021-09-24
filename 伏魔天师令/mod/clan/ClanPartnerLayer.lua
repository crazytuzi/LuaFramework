local ClanPartnerLayer = classGc(view, function(self)
    self.pMediator = require("mod.clan.ClanPartnerLayerMediator")()
    self.pMediator : setView(self)

    local mainplay=_G.GPropertyProxy:getMainPlay()
    self.m_myUid=mainplay:getUid()
    self.m_hallMemberArray={}
end)

local color4      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
local color5      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )
local color6      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD  )

local SZTABARRAY={"全体成员","申请列表"}

local TAGBTN_ALL     = 0
-- local TAGBTN_QLT     = 1
-- local TAGBTN_BHT     = 2
-- local TAGBTN_ZQT     = 3
-- local TAGBTN_XWT     = 4
-- local TAGBTN_RENMING = 5
local TAGBTN_APPLY   = 1

local TAGBTN_ZRDZ = 11
local TAGBTN_RMHF = 12
local TAGBTN_QCDH = 13
local TAGBTN_CKXX = 14
local TAGBTN_JWHY = 15
local TAGBTN_CXHF = 16
local TAGBTN_THDZ = 17

local FONT_SIZE  = 20

local TAGBTN_RECRUITTING = 1
local TAGBTN_QUIT        = 2
local  ONEPAGE_COUNT = 6

function ClanPartnerLayer.__create(self)
  self.m_container = cc.Node:create()
  --外层绿色底图大小
  self.m_rootBgSize = cc.size(846,492)

  --左底图
  self.m_leftSprSize= cc.size(213,488)
  self.m_leftSpr    = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png") 
  self.m_leftSpr    : setContentSize( self.m_leftSprSize )
  self.m_leftSpr    : setPosition(-312,-55)
  self.m_container  : addChild(self.m_leftSpr)
  --右底图
  local sprSize  = cc.size(620,443)
  self.m_mainBgSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
  self.m_mainBgSpr : setContentSize( sprSize )
  self.m_mainBgSpr : setPosition( 112, -77 )
  self.m_container: addChild(self.m_mainBgSpr,-1)

  -- local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_lowline.png")
  -- lineWidth=lineSpr:getContentSize().width
  -- lineSpr : setPreferredSize(cc.size(lineWidth,sprSize.height-2))
  -- lineSpr : setPosition(8,sprSize.height/2)
  -- lineSpr : setScaleX(-1)
  -- self.m_mainBgSpr:addChild(lineSpr)
  --容器
  self.m_panelContainer=cc.Node:create()
  self.m_container:addChild(self.m_panelContainer,10)
  
  --左边按钮
  self : createLeftBtnList()


  return self.m_container
end

function ClanPartnerLayer.createLeftBtnList(self )
    local function local_sprCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btn_tag = sender : getTag() 
            print("createLeftBtnList ok",btn_tag)

            if self.m_curTag==btn_tag then return end
            print( " btn_tag = ", btn_tag )

            if self:selectContainerByTag(btn_tag) then
                for i=1,TAGBTN_APPLY+1 do
                  if i==btn_tag+1 then
                    self.myFist[i]:setBright(false)
                    self.myFist[i]:setEnabled(false)
                    self.myFist[i]:setPosition(self.m_leftSprSize.width/2+1,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
                  else
                    self.myFist[i]:setBright(true)
                    self.myFist[i]:setEnabled(true)
                    self.myFist[i]:setPosition(self.m_leftSprSize.width/2-2,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
                  end
                end
            end
        end
    end

    local rootsize = self.m_leftSprSize
    local btnsize  = cc.size(rootsize.width-10,rootsize.height/7-6) 
    self.myFist  = {} 
    for i=TAGBTN_ALL+1,TAGBTN_APPLY+1 do
        local touchWidget=ccui.Button:create("general_title_one.png","general_title_two.png","general_title_two.png",1)
        -- touchWidget:setContentSize(btnsize)
        touchWidget:setTouchEnabled(true)
        touchWidget:setTag(i-1)
        touchWidget:addTouchEventListener(local_sprCallBack)
        self.m_leftSpr : addChild(touchWidget)
        touchWidget:setPosition(rootsize.width/2-2,rootsize.height-i*(rootsize.height/7-2)+25)

        
        if i==TAGBTN_APPLY+1 then
            local iconSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
            iconSpr:setPosition(btnsize.width-15,btnsize.height-15)
            touchWidget:addChild(iconSpr,10)
            self.tipIcon = iconSpr

            local iconSize=iconSpr:getContentSize()
            local tempLabel=_G.Util:createLabel("",18)
            tempLabel:setPosition(iconSize.width*0.5,iconSize.height*0.5-2.5)
            iconSpr:addChild(tempLabel)
            self.numLab=tempLabel
        end

        local m_strLab = _G.Util:createLabel(SZTABARRAY[i],FONT_SIZE+4)
        m_strLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        touchWidget: addChild(m_strLab,15)
        m_strLab : setPosition(btnsize.width/2,btnsize.height/2)

        self.myFist[i] = touchWidget 
        if i == 1 then
            touchWidget:setBright(false)
            touchWidget:setEnabled(false)
            touchWidget:setPosition(rootsize.width/2+1,rootsize.height-i*(rootsize.height/7-2)+25)
            self:selectContainerByTag(TAGBTN_ALL)
        end
    end

    -- local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_GANGS)
    -- self:chuangIconNum(_G.Const.CONST_FUNC_OPEN_GANGS,rewardIconCount)
end

function ClanPartnerLayer.chuangIconNum(self,_number)
  if self.numLab~=nil then
      if _number>0 then
          self.tipIcon:setVisible(true)
          local Count = _number>9 and "N" or _number
          self.numLab:setString(Count)
      else
          self.tipIcon:setVisible(false)
      end
  end
end

function ClanPartnerLayer.__clearPanelContainer(self)
    self.m_panelContainer:removeAllChildren(true)

    self:clearScheduler()

    -- 成员列表
    self.m_allPartnerNode=nil
    self.m_allPartnerScoBarView=nil

    -- 任命
    self.m_renMingRightPartnerNode=nil

    -- 申请列表
    self.m_applyPartnerNode=nil
    self.m_applyPartnerScoView=nil
end

function ClanPartnerLayer.selectContainerByTag(self,_tag)
    if _tag==self.m_curTag then return end

    print("selectContainerByTag===>>>>>",_tag)

    if _tag==TAGBTN_RENMING or _tag==TAGBTN_APPLY then
        print( "XXXX = ", _G.GPropertyProxy : getMainPlay() : getClanPost() )
        self.myPost = _G.GPropertyProxy : getMainPlay() : getClanPost()
        if self.myPost~=5 and self.myPost~=6 then
            local command=CErrorBoxCommand(11516)
            _G.controller:sendCommand(command)
            return false
        end
    end

    self:__clearPanelContainer()

    --创建面板内容
    self.m_mainBgSpr : setVisible( true )

    --在这里创建自己面板的的东西
    if _tag == TAGBTN_ALL then
        print("创建全体成员面板")
        self:__showAllPartnerTitle()
        local msg=REQ_CLAN_ASK_MEMBER_MSG()
        _G.Network:send(msg)
    -- elseif _tag == TAGBTN_QLT then
    --     print("创建青龙堂")
    --     self:__showAllPartnerTitle()
    --     local msg=REQ_CLAN_ASK_MEMBER_MSG()
    --     _G.Network :send(msg)
    -- elseif _tag == TAGBTN_BHT then
    --     print("创建白虎堂")
    --     self:__showAllPartnerTitle()
    --     local msg=REQ_CLAN_ASK_MEMBER_MSG()
    --     _G.Network :send(msg)
    -- elseif _tag == TAGBTN_ZQT then
    --     print("创建朱雀堂")
    --     self:__showAllPartnerTitle()
    --     local msg=REQ_CLAN_ASK_MEMBER_MSG()
    --     _G.Network :send(msg)
    -- elseif _tag == TAGBTN_XWT then
    --     print("创建玄武堂")
    --     self:__showAllPartnerTitle()
    --     local msg=REQ_CLAN_ASK_MEMBER_MSG()
    --     _G.Network :send(msg)
    -- elseif _tag == TAGBTN_RENMING then
    --     print("创建任命圣兽堂")
    --     self.m_mainBgSpr : setVisible( false )
    --     self:__showRenMingTitle()

    --     local msg=REQ_CLAN_ASK_MEMBER_MSG()
    --     _G.Network :send(msg)
    --     local msg=REQ_DEFENSE_VIEW()
    --     _G.Network:send(msg)

    elseif _tag == TAGBTN_APPLY then
        print("创建申请列表")
        self:__showApplyTitle()

        local msg=REQ_CLAN_ASK_JOIN_LIST()
        _G.Network:send(msg)
    end

    self.m_curTag=_tag

    return true
end

-- 任命:四个堂的分配成员界面
function ClanPartnerLayer.createRenMingLeftNode( self,_container,_nSize )
  if _container==nil or _nSize==nil   then return end

  local function local_sprCallBack(sender, eventType)
      if eventType==ccui.TouchEventType.ended then
          local uid = sender : getTag() 
          print("点击分配成员 ",uid)
          --协议发送 由第几个成员以及当前是在那个堂控制
          local msg=REQ_DEFENSE_UPORD()
          msg:setArgs(self.m_curRenmingTag,0,uid)
          _G.Network:send(msg)
      end
  end

  -- self.unallot_pageCount = 1 

  self.m_renMingLeftPalyer = {}
  for i=1,7 do
      local touchWidget=ccui.Button:create("general_noit.png","general_isit.png","general_isit.png",1)
      touchWidget:setScale9Enabled(true)
      touchWidget:setContentSize(cc.size(300,60))
      touchWidget:setTouchEnabled(true)
      touchWidget:setTag(i)
      touchWidget:addTouchEventListener(local_sprCallBack)
      touchWidget:setPosition(_nSize.width/2,_nSize.height - 38- (i-1)*62)
      _container:addChild(touchWidget)

      -- local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" ) 
      -- lineSpr       : setAnchorPoint( 0.5, 0 )
      -- lineSpr       : setPreferredSize( cc.size(_nSize.width-16,58) )
      -- lineSpr       : setPosition(_nSize.width/2,-3) 
      -- touchWidget   : addChild(lineSpr)

      local node = cc.Node : create()
      -- node       : setPosition( -5, 0 )
      touchWidget: addChild( node, 1 )

      local nameLab = _G.Util:createLabel("",FONT_SIZE-2)
      nameLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ))
      nameLab       : setAnchorPoint(cc.p(0,0.5))
      nameLab       : setPosition(65,30)
      node          : addChild(nameLab,3)

      local powerLab = _G.Util:createLabel("战力:",FONT_SIZE-2)
      powerLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ))
      powerLab       : setAnchorPoint(cc.p(0,0.5))
      powerLab       : setPosition(175,30)
      node           : addChild(powerLab,3)

      local powerLab = _G.Util:createLabel("9999999",FONT_SIZE-2)
      powerLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ))
      powerLab       : setAnchorPoint(cc.p(0,0.5))
      powerLab       : setPosition(220,30)
      node           : addChild(powerLab,3)

      local infoLab = _G.Util:createLabel("未分配成员",FONT_SIZE)
      -- infoLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ))
      infoLab       : setPosition(155,30)
      infoLab       : setVisible(false)
      touchWidget   : addChild(infoLab,3)

      local headSpr = cc.Sprite:create()
      headSpr       : setPosition(35,30)
      headSpr       : setScale(0.65)
      node          : addChild(headSpr,3)

      self.m_renMingLeftPalyer[i] = {}
      self.m_renMingLeftPalyer[i].node = node
      self.m_renMingLeftPalyer[i].touchWidget = touchWidget
      self.m_renMingLeftPalyer[i].nameLab  = nameLab
      self.m_renMingLeftPalyer[i].powerLab = powerLab
      self.m_renMingLeftPalyer[i].headSpr  = headSpr
      self.m_renMingLeftPalyer[i].infoLab  = infoLab
  end

  self:__updateHallView()
end
function ClanPartnerLayer.__updateHallView(self)
  if self.m_curTag~=TAGBTN_RENMING then return end

  self.m_renMingLeftTitle:setString(SZTABARRAY[self.m_curRenmingTag+1])
  local hallRoleDataArray={}
  for k,v in pairs(self.m_hallMemberArray[self.m_curRenmingTag] or {}) do
    hallRoleDataArray[#hallRoleDataArray+1]=v
    print("__updateHallView=======>>>",k,v)
  end
 
  if #hallRoleDataArray>1 then
    local function sort(v1,v2)
      return v1.idx<v2.idx
    end
  end

  for i=1,7 do
    local roleData=hallRoleDataArray[i]
    if roleData==nil then
      self.m_renMingLeftPalyer[i].node : setVisible( false )
      self.m_renMingLeftPalyer[i].infoLab:setVisible( true )
    else
      self.m_renMingLeftPalyer[i].touchWidget:setTag(roleData.uid)
      self.m_renMingLeftPalyer[i].node : setVisible( true )
      self.m_renMingLeftPalyer[i].infoLab:setVisible(false)

      print( "roleData.uid = ", roleData.uid, self.m_allMemberDataByUid[roleData.uid] )
      local roleMsg=self.m_allMemberDataByUid[roleData.uid]
      if roleMsg ~= nil then
        local szImg=string.format("general_role_head%d.png",roleMsg.pro)
        if szImg~=self.m_renMingLeftPalyer[i].szHead then
          local frame=cc.SpriteFrameCache:getInstance():getSpriteFrame(szImg)
          self.m_renMingLeftPalyer[i].headSpr:setSpriteFrame(frame)
          self.m_renMingLeftPalyer[i].headSpr:setScale(0.5)
          self.m_renMingLeftPalyer[i].szHead=szImg
        end
        self.m_renMingLeftPalyer[i].nameLab:setString(roleMsg.name)
        self.m_renMingLeftPalyer[i].powerLab:setString(roleMsg.power)
      end
    end
  end
end

-- 任命:右侧所有成员界面
function ClanPartnerLayer.createRenMingRightNode( self )
  if self.m_renMingRightPartnerNode then
      self.m_renMingRightPartnerNode:removeFromParent(true)
      self.m_renMingRightPartnerNode=nil 
  end

  local tempNode = cc.Node:create()
  tempNode : setPosition(112,-297)
  self.m_panelContainer : addChild(tempNode,10)

  local nSize       = self.m_createRenMingPanel_rightSpr:getContentSize()
  -- local Spr_BaseRht = ccui.Scale9Sprite : createWithSpriteFrameName( "general_daybg.png" )
  -- Spr_BaseRht       : setPreferredSize( cc.size( nSize.width, 47) )
  -- Spr_BaseRht       : setAnchorPoint( 0, 1 )
  -- Spr_BaseRht       : setPosition( 0, nSize.height+1 )
  -- tempNode          : addChild( Spr_BaseRht )

  local playerCount=#self.m_allMemberData
  local playerData={}
  for i=1,playerCount do
      local tPost=self.m_allMemberData[i].post
      if tPost~=_G.Const.CONST_CLAN_POST_MASTER
         and tPost~=_G.Const.CONST_CLAN_POST_SECOND then
          playerData[#playerData+1]=self.m_allMemberData[i]
      end
  end
  playerCount=#playerData
  print("playerCount===",playerCount)
  if playerCount==0 then return end
  local ONEPAGE_COUNT = 7
  local sprSize       = cc.size(nSize.width,62)
  local innerHeight   = sprSize.height*(playerCount<ONEPAGE_COUNT and ONEPAGE_COUNT or playerCount)
  local _pageViewSize = cc.size(nSize.width,sprSize.height*ONEPAGE_COUNT)
  local innerViewSize = cc.size(nSize.width,innerHeight)

  -- 任命圣兽堂
  local pageView = cc.ScrollView:create()
  pageView:setTouchEnabled(true)
  pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  pageView:setContentSize(innerViewSize)  
  pageView:setViewSize(_pageViewSize) 
  -- pageView:setPosition(cc.p(0,4))     
  pageView:setContentOffset( cc.p( 0, -innerHeight+_pageViewSize.height)) -- 设置初始位置

  self.m_allotRightPalyerArray={}
  self.m_rightNode={}
  for k=1,playerCount do
      local oneGood = self:createAllotOnePalyerCell(k,playerData[k],sprSize)
      local posY = innerHeight-sprSize.height/2-3-(sprSize.height)*(k-1)
      oneGood  : setPosition(3,posY)
      pageView : addChild(oneGood)
  end
      
  tempNode : addChild(pageView)

  local lpScrollBar=require("mod.general.ScrollBar")(pageView)
  lpScrollBar:setPosOff(cc.p(-2,0))
  self.m_renMingRightPartnerNode = tempNode
end

function ClanPartnerLayer.resetRightPos( self )
    print( "ClanPartnerLayer.resetRightPos====" )
    local playerCount=#self.m_allMemberData
    local playerData={}
    for i=1,playerCount do
        local tPost=self.m_allMemberData[i].post
        if tPost~=_G.Const.CONST_CLAN_POST_MASTER
           and tPost~=_G.Const.CONST_CLAN_POST_SECOND then
            playerData[#playerData+1]=self.m_allMemberData[i]
            -- print( "playerData[#playerData+1].name ===>>>> ", playerData[#playerData].name, playerData[#playerData].uid, playerData[#playerData].post )
        end
    end
    local sortArray={
      [_G.Const.CONST_CLAN_POST_MASTER]=1,
      [_G.Const.CONST_CLAN_POST_SECOND]=2,
      [_G.Const.CONST_CLAN_POST_QLSZ]=3,
      [_G.Const.CONST_CLAN_POST_BHSZ]=4,
      [_G.Const.CONST_CLAN_POST_ZQSZ]=5,
      [_G.Const.CONST_CLAN_POST_XWSZ]=6,
      [_G.Const.CONST_CLAN_POST_COMMON]=7,
    }

    local function nSort( data1, data2 )
      if data1.time~=1 and data2.time==1 then
          return false
      elseif data1.time==1 and data2.time~=1 then
          return true
      elseif data1.post==data2.post then
          if data1.power==data2.power then
              return data1.uid<data2.uid
          else
              return data1.power>data2.power
          end
      else
          return sortArray[data1.post]<sortArray[data2.post]
      end
    end

    table.sort(playerData,nSort)

    playerCount=#playerData
    local ONEPAGE_COUNT = 7
    local nSize        = self.m_createRenMingPanel_rightSpr : getPreferredSize()
    local sprSize       = cc.size(nSize.width,62)
    local innerHeight   = sprSize.height*(playerCount<ONEPAGE_COUNT and ONEPAGE_COUNT or playerCount)
    local _pageViewSize = cc.size(nSize.width,sprSize.height*ONEPAGE_COUNT)
    local innerViewSize = cc.size(nSize.width,innerHeight)

    for k=1,playerCount do
        local uid  = playerData[k].uid
        local posY = innerHeight-sprSize.height/2-3-(sprSize.height)*(k-1)
        self.m_rightNode[uid]  : setPosition(3,posY)
    end
end

function ClanPartnerLayer.createAllotOnePalyerCell( self,_no,_data,_size)
    print("createAllotOnePalyerCell==",_no)
    local _container = cc.Node : create()
    if _data==nil then  return  _container end 

    local myPosY = nil
    local function local_sprCallBack(sender, eventType)
        local Position  = sender : getWorldPosition()
        if Position.y > 448 or Position.y < 47 then 
          print("Position.y",Position.y)
          return 
        end
        
        if eventType==ccui.TouchEventType.began then
            myPosY = Position.y
        elseif eventType==ccui.TouchEventType.ended then
            if not myPosY or myPosY-Position.y > 10 or Position.y-myPosY > 10 then 
              print( "这是一次移动" )
              return 
            end
            local btn_tag = sender:getTag() 
            print("成员列表 点击成员 ",btn_tag,self.m_curRenmingTag,_data.uid,_data.name)
            --协议发送 由第几个成员以及当前是在那个堂控制
            local msg=REQ_DEFENSE_UPORD()
            msg:setArgs(self.m_curRenmingTag,1,_data.uid)
            _G.Network:send(msg)
        end
    end
  
    -- local halfHeight=_size.height*0.5
    local partnerBtn=ccui.Button:create("general_noit.png","general_isit.png","general_isit.png",1)
    partnerBtn:setScale9Enabled(true)
    partnerBtn:setContentSize(cc.size(_size.width-8,60))
    partnerBtn:setTouchEnabled(true)
    partnerBtn:setSwallowTouches(false)
    partnerBtn:setTag(_no)
    partnerBtn:addTouchEventListener(local_sprCallBack)
    partnerBtn:setPosition(_size.width/2,3)
    _container : addChild(partnerBtn)

    local nameLab = _G.Util:createLabel(_data.name or "",FONT_SIZE-2)
    nameLab       : setAnchorPoint(cc.p(0,0.5))
    nameLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN ))
    nameLab       : setPosition(65,5)
    _container    : addChild(nameLab,2)

    local powerLab = _G.Util:createLabel("战力:",FONT_SIZE-2)
    powerLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ))
    powerLab       : setAnchorPoint(cc.p(0,0.5))
    powerLab       : setPosition(170,5)
    _container     : addChild(powerLab,2)

    local powerLab = _G.Util:createLabel(_data.power or "",FONT_SIZE-2)
    powerLab       : setColor(_G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ))
    powerLab       : setAnchorPoint(cc.p(0,0.5))
    powerLab       : setPosition(210,5)
    _container     : addChild(powerLab,2)

    local szImg = string.format("general_role_head%d.png",_data.pro)
    local headSpr = gc.GraySprite:createWithSpriteFrameName(szImg)
    -- headSpr       : setScale()
    headSpr       : setPosition(35,5)
    headSpr       : setScale(0.5)
    _container    : addChild(headSpr,3)

    local postname = self:getOneWordAndColorByPost(_data.post)
    local aaa      = nil
    if postname == nil or postname == "" then
      postname = "clan_qing.png"
      aaa = true
    end
    local postSpr = cc.Sprite:createWithSpriteFrameName( postname )
    postSpr       : setPosition(25,-5)
    _container    : addChild(postSpr,4)
    if aaa == true then
      postSpr : setVisible( false )
    end

    self.m_rightNode[_data.uid] = _container

    self.m_allotRightPalyerArray[_data.uid] = {}
    self.m_allotRightPalyerArray[_data.uid].nameLab  = nameLab
    self.m_allotRightPalyerArray[_data.uid].powerLab = powerLab
    self.m_allotRightPalyerArray[_data.uid].headSpr  = headSpr
    self.m_allotRightPalyerArray[_data.uid].szHead   = szImg
    self.m_allotRightPalyerArray[_data.uid].postSpr  = postSpr

    return _container
end

function ClanPartnerLayer.__chuangeAllotRightPlayerCell(self,_uid)
  if self.m_allotRightPalyerArray ~= nil then
    if not self.m_allotRightPalyerArray[_uid] 
      or not self.m_allMemberDataByUid[_uid] then return end

    local belongTag=nil
    if self.m_hallMemberArray[TAGBTN_QLT][_uid] then
        belongTag=TAGBTN_QLT
    elseif self.m_hallMemberArray[TAGBTN_BHT][_uid] then
        belongTag=TAGBTN_BHT
    elseif self.m_hallMemberArray[TAGBTN_ZQT][_uid] then
        belongTag=TAGBTN_ZQT
    elseif self.m_hallMemberArray[TAGBTN_XWT][_uid] then
        belongTag=TAGBTN_XWT
    end

    local szImg=string.format("general_role_head%d.png",self.m_allMemberDataByUid[_uid].pro)
    if szImg~=self.m_allotRightPalyerArray[_uid].szHead then
        local frame=cc.SpriteFrameCache:getInstance():getSpriteFrame(szImg)
        self.m_allotRightPalyerArray[_uid].headSpr:setSpriteFrame(frame)
        self.m_allotRightPalyerArray[_uid].headSpr:setScale(0.5)
        self.m_allotRightPalyerArray[_uid].szHead=szImg
    end

    if belongTag==nil then
        self.m_allotRightPalyerArray[_uid].headSpr:setDefault()
        self.m_allotRightPalyerArray[_uid].postSpr:setVisible(false)
    else
        self.m_allotRightPalyerArray[_uid].headSpr:setGray()
        local postname = self:getOneWordAndColorByPost(belongTag)
        -- self.m_allotRightPalyerArray[_uid].postLab:setVisible(true)
        if postname ~= nil and postname ~= "" then
            self.m_allotRightPalyerArray[_uid].postSpr:setSpriteFrame(postname)
            self.m_allotRightPalyerArray[_uid].postSpr:setVisible(true)
        end
    end
  end
end

function ClanPartnerLayer.hallHandleBack(self,_ackMsg)
  if _ackMsg.upd==1 then
      -- 上阵

      -- 检查是否在其他地方上阵
      local memberData=self.m_allMemberDataByUid[_ackMsg.uid]
      if memberData then
          if self.m_hallMemberArray[memberData.post] then
              print("hallHandleBack====>>  把之前的下阵了")
              self.m_hallMemberArray[memberData.post][_ackMsg.uid]=nil
              self:__chuangeAllotRightPlayerCell(_ackMsg.uid)
          end
      end

      self.m_hallMemberArray[_ackMsg.type][_ackMsg.uid]=_ackMsg.data[1]
  else
      -- 下阵
      self.m_hallMemberArray[_ackMsg.type][_ackMsg.uid]=nil
  end

  if self.m_allMemberDataByUid[_ackMsg.uid] and self.m_allMemberDataByUid[_ackMsg.uid].post then
    if _ackMsg.upd~=0 then
      self.m_allMemberDataByUid[_ackMsg.uid].post = _ackMsg.type
    else
      self.m_allMemberDataByUid[_ackMsg.uid].post = 0
    end
  end
  
  print( "hallHandleBack===>>_ackMsg.type===>>", _ackMsg.type, _ackMsg.uid )
  self:__chuangeAllotRightPlayerCell(_ackMsg.uid)
  self:__updateHallView()
  self:resetRightPos()
end

function ClanPartnerLayer.getOneWordAndColorByPost( self,_post )
  local name  = ""

  if _post == _G.Const.CONST_CLAN_POST_QLSZ then
    name  = "clan_qing.png"
  elseif _post == _G.Const.CONST_CLAN_POST_BHSZ then
    name  = "clan_bai.png"
  elseif _post == _G.Const.CONST_CLAN_POST_ZQSZ then
    name  = "clan_zhu.png"
  elseif _post == _G.Const.CONST_CLAN_POST_XWSZ then
    name  = "clan_xuan.png"
  end
  print( "name  = ", name )
  return name
end

function ClanPartnerLayer.createApplyPartnerNode( self)
  if self.m_applyPartnerNode then
      self.m_applyPartnerNode:removeFromParent(true)
      self.m_applyPartnerNode=nil 
  end
  if self.m_applyPartnerScoView then
      self.m_applyPartnerScoView:remove()
      self.m_applyPartnerScoView=nil
  end

  self:__removeApplyPartnerScheduler()

  local playerData  = self.m_ApplyPanel_data
  local playerCount = #playerData
  
  if playerCount==nil or playerCount<=0 then return end
  print("ClanPartnerLayer.createGoodPanel=",playerCount)

  self.oneHeight      = 73
  local innerHeight   = self.oneHeight*(playerCount<ONEPAGE_COUNT and ONEPAGE_COUNT or playerCount)
  local _pageViewSize = cc.size(620,self.oneHeight*6)
  local innerViewSize = cc.size(620,innerHeight)
  -- 未知
  local pageView = cc.ScrollView:create()
  pageView:setTouchEnabled(true)
  pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  pageView:setContentSize(innerViewSize)  
  pageView:setViewSize(_pageViewSize) 
  pageView:setPosition(-197,-297)   
  pageView : setContentOffset( cc.p( 0, -innerHeight+_pageViewSize.height)) -- 设置初始位置

  self.m_panelContainer : addChild(pageView)

  local lpScrollBar=require("mod.general.ScrollBar")(pageView)
  lpScrollBar:setPosOff(cc.p(-5,0))

  self.m_applyPartnerNode    = pageView
  self.m_applyPartnerScoView = lpScrollBar

  local index=1
  local function nFun()
      local oneGood = self : createApply_OnePartnerMethod(index,playerData[index])

      local posX =self.SprSize.width/2-3
      local posY =innerHeight-self.oneHeight/2-2-self.oneHeight*(index-1)
      oneGood  : setPosition(posX,posY)
      pageView : addChild(oneGood)

      index=index+1
      if index>playerCount then
          self:__removeApplyPartnerScheduler()
      end
  end
      
  local minCount=playerCount>6 and 6 or playerCount
  for i=1,minCount do
      nFun()
  end

  if playerCount>minCount then
      self.m_applyPartnerScheduler=_G.Scheduler:schedule(nFun,0)
  end
  
end

function ClanPartnerLayer.createApply_OnePartnerMethod( self,_no,_data )
    print("ClanPartnerLayer.createOnePartnerMethod===",_no)
    local oneSprSize = cc.size(610,70)
    local doubleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_noit.png")
    doubleSpr : setPreferredSize(oneSprSize)
    if _data==nil then  return doubleSpr end 

    -- local infoLab   = {}
    local proname  = _G.Lang.Role_ProName[_data.pro] or ""
    local infoStr  = {_data.name,_data.lv,proname,_data.power}
    local potX     = {75,165,240,325}
    local colorStr = { _G.Const.CONST_COLOR_GRASSGREEN, _G.Const.CONST_COLOR_WHITE, 
    _G.Const.CONST_COLOR_WHITE, _G.Const.CONST_COLOR_GOLD }

    for i=1,4 do
        local tempLab = _G.Util:createLabel(infoStr[i],FONT_SIZE)
        tempLab       : setColor( _G.ColorUtil : getRGB(colorStr[i] ) )
        tempLab       : setPosition(potX[i]-8,oneSprSize.height/2)
        doubleSpr : addChild(tempLab)
    end

    local function local_OKbtncallback(sender, eventType) 
        return self : onOKBtnCallBack(sender, eventType)
    end
    local function local_Refulsebtncallback(sender, eventType) 
        return self : onRefulsebtncallback(sender, eventType)
    end

    local okBtn  = gc.CButton:create() 
    okBtn  : setTitleFontName(_G.FontName.Heiti)
    okBtn  : loadTextures("general_btn_gold.png")
    okBtn  : setButtonScale(0.85)
    okBtn  : setTitleText("同 意")
    okBtn  : setTag(_data.uid)
    okBtn  : setTitleFontSize(FONT_SIZE+4)
    --okBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    okBtn  : addTouchEventListener(local_OKbtncallback)
    okBtn  : setPosition(oneSprSize.width-175,oneSprSize.height/2)
    doubleSpr : addChild(okBtn)

    local refuseBtn = gc.CButton:create() 
    refuseBtn : setTitleFontName(_G.FontName.Heiti)
    refuseBtn : loadTextures("general_btn_lv.png")
    refuseBtn : setButtonScale(0.85)
    refuseBtn : setTitleText("拒 绝")
    refuseBtn : setTitleFontSize(FONT_SIZE+4)
    refuseBtn : setTag(_data.uid)
    refuseBtn : addTouchEventListener(local_Refulsebtncallback)
    refuseBtn : setPosition(oneSprSize.width-62,oneSprSize.height/2)
    doubleSpr : addChild(refuseBtn)

    return doubleSpr
end

function ClanPartnerLayer.__showAllPartnerTitle(self)
    if self.m_applyTitleNode~=nil then
        self.m_applyTitleNode:setVisible(false)
    end
    if self.m_renMingTitleNode~=nil then
        self.m_renMingTitleNode:setVisible(false)
    end
    if self.m_allPartnerTitleNode~=nil then
        self.m_allPartnerTitleNode:setVisible(true)
        return
    end

    local sprSize = cc.size(626,492)
    local tempNode = cc.Node:create()
    tempNode : setPosition(-sprSize.width/2+112,-sprSize.height/2-57)
    self.m_container : addChild(tempNode)

    -- local myBase  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_daybg.png" )
    -- myBase        : setContentSize( sprSize.width, 53 ) 
    -- myBase        : setAnchorPoint( 0.5, 1 )
    -- myBase        : setPosition( sprSize.width/2,sprSize.height )
    -- tempNode      : addChild( myBase )

    -- local posX = { 119, 170, 253, 331, 449 }
    -- for i=1,5 do
    --   local lineSpr = cc.Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
    --   lineSpr       : setScaleX( 0.3 )
    --   lineSpr       : setAnchorPoint( 0, 0 )
    --   lineSpr       : setRotation( 90 )
    --   lineSpr       : setPosition( posX[i], sprSize.height-3 )
    --   tempNode      : addChild(lineSpr,2)
    -- end

    local infoStr = {"成员名称","等级","职位","战斗力","贡献/总贡献","最后在线"}
    local potX    = {75,165,240,325,440,565}
    for i=1,6 do
        local infoLab = _G.Util:createLabel(infoStr[i],FONT_SIZE)
        -- infoLab  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        infoLab  : setPosition(potX[i],sprSize.height-25)
        tempNode : addChild(infoLab)
    end

    self.m_allPartnerTitleNode=tempNode
end

function ClanPartnerLayer.__showApplyTitle(self)
    if self.m_renMingTitleNode~=nil then
        self.m_renMingTitleNode:setVisible(false)
    end
    if self.m_allPartnerTitleNode~=nil then
        self.m_allPartnerTitleNode:setVisible(false)
    end
    if self.m_applyTitleNode~=nil then
        self.m_applyTitleNode:setVisible(true)
        return
    end

    local sprSize = cc.size(626,492)
    local tempNode = cc.Node:create()
    tempNode : setPosition(-sprSize.width/2+112,-sprSize.height/2-57)
    self.m_container : addChild(tempNode)

    self.SprSize = cc.size(626,492)

    local infoStr  = {"成员名称","等级","职业","战斗力","操作"}
    local potX = {75,165,240,325,499}
    for i=1,5 do
        local infoLab = _G.Util:createLabel(infoStr[i],FONT_SIZE)
        -- infoLab  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        infoLab  : setPosition(potX[i],self.SprSize.height-25)
        tempNode : addChild(infoLab)
    end

    self.m_applyTitleNode=tempNode
end

function ClanPartnerLayer.__showRenMingTitle(self)
    if self.m_applyTitleNode~=nil then
        self.m_applyTitleNode:setVisible(false)
    end
    if self.m_allPartnerTitleNode~=nil then
        self.m_allPartnerTitleNode:setVisible(false)
    end
    if self.m_renMingTitleNode~=nil then
        self.m_renMingTitleNode:setVisible(true)
        return
    end

    local tempNode = cc.Node:create()
    self.m_container : addChild(tempNode)

    local sprX = -self.m_rootBgSize.width/2+20
    sprX       = sprX + self.m_leftSprSize.width

    -- 任命圣兽堂--中底图
    local middleSprSize= cc.size(308,443)
    local middleSpr    = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    middleSpr          : setContentSize( middleSprSize )
    tempNode           : addChild(middleSpr)
    middleSpr          : setPosition(sprX+middleSprSize.width/2-8,-77)
    sprX               = sprX+middleSprSize.width

    --任命圣兽堂--右底图
    local rightSprSize= cc.size(308,443)
    local rightSpr    = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    rightSpr          : setContentSize( rightSprSize )
    rightSpr          : setPosition(sprX+rightSprSize.width/2-3,-77)
    tempNode          : addChild(rightSpr)

    self.m_curRenmingTag=TAGBTN_QLT

    local function local_pageCallBack(sender, eventType)
      if eventType==ccui.TouchEventType.ended then
          local btn_tag = sender : getTag() 
          if btn_tag == 1 then
              print("向左按")
              if self.m_curRenmingTag==TAGBTN_QLT then
                  self.m_curRenmingTag=TAGBTN_XWT
              else
                  self.m_curRenmingTag=self.m_curRenmingTag-1
              end
              self:__updateHallView()
          elseif btn_tag == 2 then
              print("向右按")
              if self.m_curRenmingTag==TAGBTN_XWT then
                  self.m_curRenmingTag=TAGBTN_QLT
              else
                  self.m_curRenmingTag=self.m_curRenmingTag+1
              end
              self:__updateHallView()
          end
      end
  end

    local leftPageBtn  = gc.CButton : create()
    leftPageBtn  : loadTextures("general_fangye_1.png")
    leftPageBtn  : setTag(1)
    leftPageBtn  : addTouchEventListener(local_pageCallBack)
    leftPageBtn  : ignoreContentAdaptWithSize(false)
    leftPageBtn  : setContentSize(cc.size(85,60))
    tempNode   : addChild(leftPageBtn,5)
    leftPageBtn  : setPosition(sprX-middleSprSize.width/2-70,165)

    local rightPageBtn  = gc.CButton : create()
    -- rightPageBtn  : 
    rightPageBtn  : loadTextures("general_fangye_1.png")
    rightPageBtn  : setButtonScaleX(-1)
    rightPageBtn  : setTag(2)
    rightPageBtn  : addTouchEventListener(local_pageCallBack)
    rightPageBtn  : ignoreContentAdaptWithSize(false)
    rightPageBtn  : setContentSize(cc.size(85,60))
    tempNode    : addChild(rightPageBtn,5)
    rightPageBtn  : setPosition(sprX-middleSprSize.width/2+70,165)

    self.m_renMingLeftTitle = _G.Util:createLabel(SZTABARRAY[self.m_curRenmingTag+1],FONT_SIZE)
    -- self.m_renMingLeftTitle : setColor(color5)
    self.m_renMingLeftTitle : setPosition(sprX-middleSprSize.width/2-3,165)
    tempNode              : addChild(self.m_renMingLeftTitle,5)

    local allot_TangLab  = _G.Util:createLabel("成员列表",FONT_SIZE)
    allot_TangLab        : setPosition(sprX+rightSprSize.width/2-2,165)
    tempNode             : addChild(allot_TangLab)

    --刷新只用改变string 刷新
    self:createRenMingLeftNode(middleSpr,middleSprSize)

    self.m_createRenMingPanel_rightSpr = rightSpr

    self.m_renMingTitleNode=tempNode
end

--此方法在协议回来的时候调用数据
function ClanPartnerLayer.createAllPartnerNode( self,_tag,_playerData )
    if self.m_allPartnerNode then
        self.m_allPartnerNode:removeFromParent(true)
        self.m_allPartnerNode=nil
    end
    if self.m_allPartnerScoBarView then
        self.m_allPartnerScoBarView:remove()
        self.m_allPartnerScoBarView=nil
    end

    self:__removeAllPartnerScheduler()

    local playerCount =#_playerData
    if playerCount==nil or playerCount <= 0 then return end
    print("ClanPartnerLayer.createAllPartnerNode=",_tag,playerCount)
    
    local sprSize       = cc.size(620,73)
    local innerHeight   = sprSize.height*(playerCount<ONEPAGE_COUNT and ONEPAGE_COUNT or playerCount)
    local _pageViewSize = cc.size(620,sprSize.height*ONEPAGE_COUNT)
    local innerViewSize = cc.size(620,innerHeight)
    -- 成员
    local pageView = cc.ScrollView:create()
    pageView:setTouchEnabled(true)
    pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pageView:setContentSize(innerViewSize)  
    pageView:setViewSize(_pageViewSize) 
    pageView:setPosition(-197,-297)
    pageView:setContentOffset( cc.p( 0, -innerHeight+_pageViewSize.height)) -- 设置初始位置

    self.m_panelContainer : addChild(pageView)

    local lpScrollBar=require("mod.general.ScrollBar")(pageView)
    lpScrollBar:setPosOff(cc.p(-5,0))

    self.m_allPartnerNode       = pageView
    self.m_allPartnerScoBarView = lpScrollBar

    local index=1
    local function nFun()
        local oneGood = self:createAll_OnePartnerMethod(_playerData[index])

        local posX = sprSize.width/2
        local posY = innerHeight-sprSize.height/2-2-sprSize.height*(index-1)
        oneGood  : setPosition(posX,posY)
        pageView : addChild(oneGood)

        index=index+1
        if index>playerCount then
            self:__removeAllPartnerScheduler()
        end
    end

    local minCount=playerCount>6 and 6 or playerCount
    for i=1,minCount do
        nFun()
    end

    if playerCount>minCount then
        self.m_allPartnerScheduler=_G.Scheduler:schedule(nFun,0)
    end
end

function ClanPartnerLayer.createAll_OnePartnerMethod( self,_data )
  -- print("ClanPartnerLayer.createAll_OnePartnerMethod===",_data.uid)
  local container = cc.Node:create()
  if _data==nil then return container end

  local sprSize = cc.size(610,70)
  local function c(sender, eventType)
      local Position  = sender : getWorldPosition()
      print( "caocaocao : ", Position.y )
      if Position.y > 448 or Position.y < 57 then 
        return 
      end
      if eventType==ccui.TouchEventType.move then 
          print( "移动啦" )
      elseif eventType==ccui.TouchEventType.began then
          self.isMove = sender : getWorldPosition().y
          print( "按下啦" )
          -- sender:setOpacity(180)
      elseif eventType==ccui.TouchEventType.ended then
          local move  = sender : getWorldPosition().y - self.isMove
          print( "移动了：", move )
          if move > 10 or move < -10 then
            print( "这是一次移动" )
            return
          end
          print( "弹起啦" )
          local uid=sender:getTag()
          local data=self.m_allMemberDataByUid[uid]
          print("ooasdssooo=========>>>",uid)
          self:__showClanMemberTips(_data)
          -- sender:setOpacity(255)
      elseif eventType==ccui.TouchEventType.canceled then
          print( "取消啦" )
          -- return
          -- sender:setOpacity(255)
      end
  end

  local bgBtn=ccui.Button:create("general_noit.png","general_isit.png","general_isit.png",1)
  bgBtn:setScale9Enabled(true)
  bgBtn:setContentSize(sprSize)
  bgBtn:setSwallowTouches(false)
  bgBtn:setTouchEnabled(true)
  bgBtn:setTag(_data.uid)
  bgBtn:addTouchEventListener(c)
  container:addChild(bgBtn)

  -- local infoLab   = {}
  -- print("职位职位:",_data.name,_data.post,_data.power)
  local proname  = _G.Lang.faction_post[_data.post] or ""
  local temptime = nil
  local timecolor=_G.Const.CONST_COUNTRY_DEFAULT
  if _data.time == 1 then
      -- print( "这个是在线的", _data.uid, _data.name )
      temptime = _G.Lang.LAB_N[284]
      timecolor=_G.Const.CONST_COLOR_WHITE
  else
      -- print( "不在线" )
      local nowTime = _G.TimeUtil : getServerTimeSeconds()
      local offlineTime = nowTime -_data.time
      if math.floor( offlineTime/86400 ) > 0 then
          temptime = math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92]
      elseif math.floor( offlineTime/3600 ) > 0 then
          temptime = math.floor( offlineTime/3600 ).._G.Lang.LAB_N[91]
      elseif math.floor( offlineTime/60 ) > 0 then
          temptime = math.floor( offlineTime/60 ).._G.Lang.LAB_N[90]
      else
          temptime = "1".._G.Lang.LAB_N[90]
      end
  end

  local infoStr  = {_data.name,_data.lv,proname,_data.power,_data.today_gx.."/".._data.all_gx,temptime}
  local potX     = {75,165,240,325,440,565}
  local colorStr = {_G.Const.CONST_COLOR_GRASSGREEN, _G.Const.CONST_COLOR_WHITE,
                    _G.Const.CONST_COLOR_SPRINGGREEN, _G.Const.CONST_COLOR_GOLD,
                     _G.Const.CONST_COLOR_GRASSGREEN, timecolor }

  for i=1,6 do
      local tempLab = _G.Util:createLabel(infoStr[i],FONT_SIZE)
      tempLab       : setColor(_G.ColorUtil : getRGB(colorStr[i] ))
      tempLab       : setPosition(potX[i]-8,sprSize.height/2)
      bgBtn         : addChild(tempLab)
  end

  return container
end
-----------------------]]]]]]]]]]]]----------------------------------------------------
-- function ClanPartnerLayer.createscelectBtn(self,_obj )
-- end

function ClanPartnerLayer.onOKBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      print("同意回调 uid",btn_tag)
      if btn_tag==nil or btn_tag <= 0 then return end
      local msg = REQ_CLAN_ASK_AUDIT()
      msg :setArgs( btn_tag,1)
      _G.Network :send( msg)
    end
end

function ClanPartnerLayer.onRefulsebtncallback( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      print("拒绝回调 uid",btn_tag)
      if btn_tag==nil or btn_tag <= 0 then return end

      local msg = REQ_CLAN_ASK_AUDIT()
      msg :setArgs( btn_tag,0)
      _G.Network :send( msg)
    end
end

function ClanPartnerLayer.unregister(self)
    if self.pMediator ~= nil then
       self.pMediator : destroy()
       self.pMediator = nil 
    end
end

function ClanPartnerLayer.NetWorkReturn_CLAN_OK_JOIN_LIST(self,m_count,m_user_data)
    if self.m_curTag==TAGBTN_APPLY then
        self.m_ApplyPanel_count = m_count
        self.m_ApplyPanel_data  = m_user_data

        self : createApplyPartnerNode()
    end
end

function ClanPartnerLayer.NetWorkReturn_CLAN_OK_MEMBER_LIST(self,m_count,m_user_data)
  local changedata=self:__sortPlayerByPost(m_user_data)
  if not self.GetIn then
    self : findMyPost( m_count, m_user_data )
  end
  self.m_allMemberData=changedata

  self.m_allMemberDataByUid={}
  for i=1,#changedata do
      local uid=changedata[i].uid
      if self.m_myUid==uid then
          self.m_myInfo=changedata[i]
      end
      self.m_allMemberDataByUid[uid]=changedata[i]
  end
  print( "changedata = ", #changedata)

  if self.m_curTag==TAGBTN_ALL then
      self:createAllPartnerNode(self.m_curTag,changedata)
  elseif self.m_curTag==TAGBTN_QLT or self.m_curTag==TAGBTN_BHT or self.m_curTag==TAGBTN_ZQT or self.m_curTag==TAGBTN_XWT then
      local newDataArray={}
      for i=1,#self.m_allMemberData do
          local roleMsg=self.m_allMemberData[i]
          if roleMsg.post==self.m_curTag then
              newDataArray[#newDataArray+1]=roleMsg
          end
      end
      print("NetWorkReturn_CLAN_OK_MEMBER_LIST===>>>",#newDataArray)
      self:createAllPartnerNode(self.m_curTag,newDataArray)
  end
end

function ClanPartnerLayer.NetWorkReturn_DEFENSE_ALL_GROUP(self,_ackMsg)
    if self.m_curTag~=TAGBTN_RENMING then return end

    self.m_hallMemberArray={}
    self.m_hallMemberArray[TAGBTN_QLT]=_ackMsg.data[TAGBTN_QLT] or {}
    self.m_hallMemberArray[TAGBTN_BHT]=_ackMsg.data[TAGBTN_BHT] or {}
    self.m_hallMemberArray[TAGBTN_ZQT]=_ackMsg.data[TAGBTN_ZQT] or {}
    self.m_hallMemberArray[TAGBTN_XWT]=_ackMsg.data[TAGBTN_XWT] or {}

    if self.m_allMemberData~=nil then
        --更新任命圣兽堂的 所有成员列表
        self:createRenMingRightNode()
    end
    for i=1,#self.m_hallMemberArray do
        for k,v in pairs(self.m_hallMemberArray[i]) do
            print("SSSSSSSSSSSSSSS======>>>>>",k)
            self:__chuangeAllotRightPlayerCell(k)
        end
    end
    self:__updateHallView()
end

function ClanPartnerLayer.findMyPost( self, _count, _data )
    print( "我的UID", self.m_myUid)
    for i=1,_count do
        if _data[i].uid == self.m_myUid then
            self.myPost = _data[i].post
            print( "我的职位：", self.myPost )
        end
    end
    self.GetIn = true
end

function ClanPartnerLayer.__sortPlayerByPost(self,_data)
  if _data==nil then return _data end

  local sortArray={
      [_G.Const.CONST_CLAN_POST_MASTER]=1,
      [_G.Const.CONST_CLAN_POST_SECOND]=2,
      [_G.Const.CONST_CLAN_POST_QLSZ]=3,
      [_G.Const.CONST_CLAN_POST_BHSZ]=4,
      [_G.Const.CONST_CLAN_POST_ZQSZ]=5,
      [_G.Const.CONST_CLAN_POST_XWSZ]=6,
      [_G.Const.CONST_CLAN_POST_COMMON]=7,
  }

  local function nSort( data1, data2 )
      if data1.time~=1 and data2.time==1 then
          return false
      elseif data1.time==1 and data2.time~=1 then
          return true
      elseif data1.post==data2.post then
          if data1.power==data2.power then
              return data1.uid<data2.uid
          else
              return data1.power>data2.power
          end
      else
          return sortArray[data1.post]<sortArray[data2.post]
      end
  end

  table.sort(_data,nSort)
  return _data
end

function ClanPartnerLayer.__hideClanMemberTips(self)
  -- if self.m_clanMenberLayer~=nil then
  --   self.m_clanMenberLayer:removeFromParent(true)
  --   self.m_clanMenberLayer=nil
  -- end
  if self.m_clanMenberLayer==nil then return end

  local function f(_node)
      _node:removeFromParent(true)
  end
  -- cc.ScaleTo:create(0.3,0.05)
  local action=cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(f))
  self.m_clanMenberLayer:runAction(action)
  self.m_clanMenberLayer=nil
end
function ClanPartnerLayer.__showClanMemberTips(self,_data)
  self:__hideClanMemberTips()

  if self.m_myUid==_data.uid then 
    local command = CErrorBoxCommand(15001)
    controller : sendCommand( command )
    return 
  end

  self.m_curShowMemberData=_data
  local winSize=cc.Director:getInstance():getWinSize()
  self.m_clanMenberLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
  -- self.m_clanMenberLayer:setPosition()

  local btnInfoArray={}
  if _data.post==_G.Const.CONST_CLAN_POST_MASTER then
    btnInfoArray[#btnInfoArray+1]={TAGBTN_THDZ,"弹劾掌门"}
  end
  if not _G.GFriendProxy:hasThisFriend(_data.uid) then
      btnInfoArray[#btnInfoArray+1]={TAGBTN_JWHY,"加为好友"}
  end
  btnInfoArray[#btnInfoArray+1]={TAGBTN_CKXX,"查看信息"}
  local myPost=self.m_myInfo.post
  if myPost==_G.Const.CONST_CLAN_POST_MASTER then
      btnInfoArray[#btnInfoArray+1]={TAGBTN_QCDH,"请出门派"}
      if _data.post==_G.Const.CONST_CLAN_POST_SECOND then
          btnInfoArray[#btnInfoArray+1]={TAGBTN_CXHF,"撤销护法"}
      else
          btnInfoArray[#btnInfoArray+1]={TAGBTN_RMHF,"任命护法"}
      end
      btnInfoArray[#btnInfoArray+1]={TAGBTN_ZRDZ,"转让门派"}
  elseif myPost==_G.Const.CONST_CLAN_POST_SECOND then 
      btnInfoArray[#btnInfoArray+1]={TAGBTN_QCDH,"请出门派"}
  end

  local buttonCount=#btnInfoArray
  local oneHeight=55
  local tipsSize=cc.size(176,60+(oneHeight)*buttonCount)
  local backFrameSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendkuang.png")
  backFrameSpri:setPosition(winSize.width*0.5,winSize.height*0.5)
  backFrameSpri:setPreferredSize(tipsSize)
  self.m_clanMenberLayer:addChild(backFrameSpri)

  local midPos=tipsSize.width*0.5
  local nameLabel=_G.Util:createLabel(_data.name,20)
  nameLabel:setPosition(midPos,tipsSize.height-30)
  nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  backFrameSpri:addChild(nameLabel,1)

  local btnSize=cc.size(tipsSize.width-20,oneHeight)
  for i=1,#btnInfoArray do
      self:createLightButton(i,btnInfoArray[i][1],btnInfoArray[i][2],midPos,backFrameSpri)
  end

  local function onTouchBegan()
      self:__hideClanMemberTips()
      return true 
  end
  local listerner=cc.EventListenerTouchOneByOne:create()
  listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  listerner:setSwallowTouches(true)
  self.m_clanMenberLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_clanMenberLayer)
  cc.Director:getInstance():getRunningScene():addChild(self.m_clanMenberLayer,999)
end
function ClanPartnerLayer.createLightButton(self,_no,_tag,_szName,_posX,_parent)
  local function c(sender,eventType)
    if eventType==ccui.TouchEventType.ended then
      local tag=sender:getTag()
      print("createLightButton=========>>>>>",tag)
      local szMsg,nSureFun
      if tag==TAGBTN_ZRDZ then
          self:ClanTipsView()
      elseif tag==TAGBTN_RMHF then
          local msg=REQ_CLAN_ASK_SET_POST()
          msg:setArgs(self.m_curShowMemberData.uid,_G.Const.CONST_CLAN_POST_SECOND)
          _G.Network:send(msg)
      elseif tag==TAGBTN_QCDH then
          szMsg=string.format("是否请[%s]离开门派?",self.m_curShowMemberData.name)
          nSureFun=function()
              local msg=REQ_CLAN_ASK_SET_POST()
              msg:setArgs(self.m_curShowMemberData.uid,_G.Const.CONST_CLAN_POST_OUT)
              _G.Network:send(msg)
          end
      elseif tag==TAGBTN_THDZ then
          szMsg="确认弹劾掌门?"
          nSureFun=function()
              local msg=REQ_CLAN_TH_MASTER()
              _G.Network:send(msg)
          end
      elseif tag==TAGBTN_CKXX then
          _G.GLayerManager:showPlayerView(self.m_curShowMemberData.uid)
      elseif tag==TAGBTN_JWHY then
          local sendList = {}
          sendList[1] = self.m_curShowMemberData.uid
          
          local msg=REQ_FRIEND_ADD()
          msg:setArgs(1,1,sendList)
          _G.Network:send(msg)
      elseif tag==TAGBTN_CXHF then
          local msg=REQ_CLAN_ASK_SET_POST()
          msg:setArgs(self.m_curShowMemberData.uid,_G.Const.CONST_CLAN_POST_COMMON)
          _G.Network:send(msg)
      end
      self:__hideClanMemberTips()
      if szMsg and nSureFun then
          _G.Util:showTipsBox(szMsg,nSureFun)
      end
    end
  end

  local widget = gc.CButton:create("general_btn_gray.png")
  widget : setPosition(_posX,10+(_no-0.5)*55) 
  widget : setTitleText( _szName )
  widget : setTitleFontSize( 22 )
  widget : setTitleFontName( _G.FontName.Heiti )
  widget : setTag(_tag)
  widget : addTouchEventListener(c)
  _parent: addChild( widget, 5 )

  return widget
end

function ClanPartnerLayer.ClanTipsView(self)
  local function sure()
    local num = self.m_editbox : getString()
    print("--textFieldEvent---",num)
    if tostring(num)=="yes" then
      local msg=REQ_CLAN_ASK_SET_POST()
      msg:setArgs(self.m_curShowMemberData.uid,_G.Const.CONST_CLAN_POST_MASTER)
      _G.Network:send(msg)
      if m_mainBgSpr~=nil then
          m_mainBgSpr:removeFromParent(true)
          m_mainBgSpr=nil
      end
    else
      local command = CErrorBoxCommand("输入错误，请注意区分大小写！")
      controller : sendCommand( command )
    end
  end

  local view  = require("mod.general.TipsBox")()
  local layer = view : create("",sure) 
  cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

  local m_creatbox = view:getMainlayer()
  szMsg=string.format("是否转让门派给[%s]?",self.m_curShowMemberData.name)
  local m_mainLab=_G.Util:createLabel("是否转让门派给",20)
  local m_nameLab=_G.Util:createLabel(self.m_curShowMemberData.name,20)
  local nameWidth=m_nameLab:getContentSize().width
  local mainWidth=m_mainLab:getContentSize().width
  m_mainLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) --居中对齐 
  -- m_mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
  -- m_mainLab:setDimensions( P_VIEW_SIZE.width-20*2,90)            --设置文字区
  m_mainLab:setPosition(-nameWidth/2,50)
  m_creatbox:addChild(m_mainLab)
  
  m_nameLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) --居中对齐 
  m_nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  -- m_nameLab:setDimensions( P_VIEW_SIZE.width-20*2,90)            --设置文字区
  m_nameLab:setPosition(mainWidth/2,50)
  m_creatbox:addChild(m_nameLab)

  m_tiptipsLab=_G.Util:createLabel("(请在下方框框内输入“yes”确认)",18)
  -- m_tiptipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  m_tiptipsLab:setPosition(0,20)
  m_creatbox:addChild(m_tiptipsLab)

  local boxSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" ) 
  boxSpr1 : setPreferredSize(cc.size(60,30))
  boxSpr1 : setPosition(0,-30) 
  m_creatbox:addChild(boxSpr1)

  local boxSpr1Size=boxSpr1:getContentSize()
  self.m_editbox = ccui.TextField:create("",_G.FontName.Heiti,FONT_SIZE)
  self.m_editbox : setMaxLengthEnabled(true)
  self.m_editbox : setMaxLength(3)
  self.m_editbox : ignoreContentAdaptWithSize(false)
  self.m_editbox : setContentSize(boxSpr1Size)
  self.m_editbox : setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
  self.m_editbox : setPosition(0,-30) 
  m_creatbox:addChild(self.m_editbox)
end

function ClanPartnerLayer.Net_SYSTEM_ERROR( self, _ackMsg )
  local ackMsg = _ackMsg
  local errorNum = _ackMsg.error_code
  print( "error_code= ", errorNum )
  if errorNum == 11516 then 
    print( "不是管理员，改变位置" )
    self : selectContainerByTag( TAGBTN_ALL )
    for i=1,TAGBTN_APPLY+1 do
      if i==1 then
        self.myFist[i]:setBright(false)
        self.myFist[i]:setEnabled(false)
        self.myFist[i]:setPosition(self.m_leftSprSize.width/2+1,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
      else
        self.myFist[i]:setBright(true)
        self.myFist[i]:setEnabled(true)
        self.myFist[i]:setPosition(self.m_leftSprSize.width/2-2,self.m_leftSprSize.height-i*(self.m_leftSprSize.height/7-2)+25)
      end
    end
  end
end

function ClanPartnerLayer.__removeAllPartnerScheduler(self)
    if self.m_allPartnerScheduler then
        _G.Scheduler:unschedule(self.m_allPartnerScheduler)
        self.m_allPartnerScheduler=nil
    end
end
function ClanPartnerLayer.__removeApplyPartnerScheduler(self)
    if self.m_applyPartnerScheduler then
        _G.Scheduler:unschedule(self.m_applyPartnerScheduler)
        self.m_applyPartnerScheduler=nil
    end
end
function ClanPartnerLayer.clearScheduler(self)
    self:__removeAllPartnerScheduler()
    self:__removeApplyPartnerScheduler()
end
return ClanPartnerLayer