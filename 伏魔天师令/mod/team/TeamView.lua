local TeamView = classGc(view, function(self,team_id)
  self.pMediator= require("mod.team.TeamMediator")()
  self.pMediator: setView(self)
  self.sceneId = 40301
  self.playerLv = _G.GPropertyProxy : getMainPlay() : getLv()
  local flag = math.floor(self.playerLv/10)
  if flag == 3 then
  		self.sceneId = 40301
  elseif flag == 4 then
  		self.sceneId = 40401
  elseif flag == 5 then
  		self.sceneId = 40501
  elseif flag == 6 then
  		self.sceneId = 40601
  elseif flag == 7 then
  		self.sceneId = 40701
  elseif flag >= 8 then
  		flag = 8
  		self.sceneId = 40801	
  end
  self.flag = flag
  self.teamID = team_id
end)

local TeamList = _G.Cfg.copy_chap[6][30100].copy_id
local FontSize = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local pSize  = cc.size( 828, 492 )
local leftSize = cc.size(158,496)
local rightSize = cc.size(680,496)
local iconSize = cc.size(79,79)
local isBuyTip = false
local FOUND = 1
local RONDOW= 2
local ADDS  = 3

function TeamView.create( self )
  if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_TEAM) then return false end
  
  self.m_normalView=require("mod.general.NormalView")()
  self.m_rootLayer=self.m_normalView:create()
  self.m_normalView : setTitle("群仙诛邪")

  local tempScene=cc.Scene:create()
  tempScene:addChild(self.m_rootLayer)

  self:init()

  return tempScene
end

function TeamView.init( self )
    local function nCloseFun()
        print("关闭群仙诛邪",self.tagClass)
        if self.tagClass~=nil then
          local msg = REQ_TEAM_LEAVE()
          _G.Network:send(msg)
          local command = CTeamCommand()
          _G.controller :sendCommand( command )
          return
        end

        if self.m_rootLayer == nil then return end
        self.m_rootLayer=nil
        cc.Director:getInstance():popScene()
        self:destroy()
        if self.tagClass~=nil then
            print("退出房间")
            local msg=REQ_TEAM_LEAVE()
            _G.Network:send(msg)
            self.tagClass:Chatdestroy()
        end
        if self.m_hasGuide then
            local command=CGuideNoticShow()
            controller:sendCommand(command)
        end
    end
    self.m_normalView:addCloseFun(nCloseFun)
    -- self.m_normalView:showSecondBg()

    self.teamNode=cc.Node:create()
    self.teamNode:setPosition(cc.p(m_winSize.width/2,m_winSize.height/2+12))
    self.m_rootLayer:addChild(self.teamNode)
    --初始化界面
    self:initView()
end

function TeamView.initView( self )
  self.pBackground = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
  self.pBackground : setContentSize( rightSize )
  self.pBackground : setPosition(82, -52 )
  self.teamNode:addChild( self.pBackground )

  self.leftSpr = ccui.Scale9Sprite:createWithSpriteFrameName( "general_di2kuan.png" )
  self.leftSpr : setPreferredSize(leftSize)
  self.leftSpr : setPosition(-pSize.width/2+leftSize.width/2-5,-52 )
  self.teamNode:addChild( self.leftSpr )

  local upline = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" )
  -- local lineHeight=upline:getContentSize().height
  upline : setPreferredSize( cc.size(rightSize.width-5,320) )
  upline : setPosition(rightSize.width/2,rightSize.height/2+35 )
  self.pBackground:addChild( upline )

  -- local downline = ccui.Scale9Sprite:createWithSpriteFrameName( "general_team_upline.png" )
  -- local lineHeight=downline:getContentSize().height
  -- downline : setPreferredSize( cc.size(rightSize.width,lineHeight) )
  -- downline : setPosition(rightSize.width/2,rightSize.height/2-120 )
  -- self.pBackground:addChild( downline,10 )

  local LabStr={"队长名称","队长等级","队伍人数","操作"}
  local LabpoX={110,rightSize.width/2-80,rightSize.width/2+70,rightSize.width-110}
  for i=1,4 do
    local explainLab = _G.Util:createLabel(LabStr[i],FontSize)
    explainLab : setPosition(LabpoX[i],rightSize.height-30 )
    explainLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.pBackground:addChild( explainLab )
  end

  self : TeamDown()
  self : TeamLeftView()
  self : IconCount(self.sceneId)

  print("self.teamID",self.teamID)
  if self.teamID~=nil then
    self.pBackground:setVisible(false)
    local msg = REQ_TEAM_JOIN()
    msg:setArgs(self.teamID)
    _G.Network:send(msg)
  else
    self : NetworkREQ(self.sceneId)
  end
end

function TeamView.popRoot(self)
  self.tagClass:closeRoom()
  self.pBackground : setVisible(true)
  self.leftSpr : setVisible(true)
  self.tagClass=nil
  self.teamId=nil
end

function TeamView.NetworkREQ( self,tag)
  local msg = REQ_TEAM_REQUEST()
  msg:setArgs(tag)
  _G.Network:send(msg)
end

function TeamView.TeamLeftView( self )
  local length = #TeamList
  local function sort(t1,t2)
    if t1 < t2 then
        return true
    end
    return false
  end
  table.sort( TeamList, sort )
  local oneHeight = (leftSize.height-10)/3
  local viewSize = cc.size(leftSize.width,leftSize.height-10)
  local scrollViewSize = cc.size(leftSize.width,oneHeight*length)
  local contentView = cc.ScrollView:create()
  contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  contentView : setViewSize(viewSize)
  contentView : setContentSize(scrollViewSize)
  if self.flag==3 or self.flag==4 or self.flag==5 then
  	contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height ) ) -- 设置初始位置
  else
  	contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height+(self.flag-5)*oneHeight ) ) -- 设置初始位置
  end
  contentView : setPosition(cc.p(0,5))
  self.leftSpr : addChild(contentView)

  local barView=require("mod.general.ScrollBar")(contentView)
  barView:setPosOff(cc.p(-7,0))

  local function operateButton( sender,eventType )
    if eventType == ccui.TouchEventType.ended then
      local tag = sender:getTag()
      local Position  = sender : getWorldPosition()
      print(" Position.y----<>",Position.y,m_winSize.height/2-pSize.height/2-20 )
      if Position.y > m_winSize.height/2+pSize.height/2-25 or
         Position.y < m_winSize.height/2-pSize.height/2-20 
         or self.sceneId == tag then return end

      print("--------->>>tag",tag,self.teamBtn[tag])
      self.sceneId  = tag

      self : createScelect(self.teamBtn[tag],true)
      self : IconCount(tag)
      self : NetworkREQ(tag)    
    end
  end

  self.teamBtn = {}
  for k,v in pairs(TeamList) do
    print("TeamList ---> ",k,v)
    local teamData = _G.Cfg.scene_copy[v]
    local szIcon="copyui_icon_10101.png"
    if teamData.scene and teamData.scene[1] then
      local sceneId=teamData.scene[1].id
      local sceneCnf=get_scene_data(sceneId)
      if sceneCnf then
        local materialCnf=_G.MapData[sceneCnf.material_id]
        if materialCnf then
          local newIcon=string.format("copyui_icon_%d.png",materialCnf.small_id)
          local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(newIcon)
          if spriteFram~=nil then
            szIcon=newIcon
          end
        end
      end
    end

    szIcon="copyui_icon_0.png"

    self.teamBtn[v]=gc.CButton:create()
    self.teamBtn[v]:loadTextures(szIcon)
    self.teamBtn[v]:setPosition(leftSize.width/2,scrollViewSize.height-oneHeight*(k-1)-70)
    self.teamBtn[v]:addTouchEventListener(operateButton)
    self.teamBtn[v]:setTag(v)
    self.teamBtn[v]:setSwallowTouches(false)
    contentView:addChild(self.teamBtn[v])
    local btnSize=self.teamBtn[v]:getContentSize()

    -- local iconbg=cc.Sprite:createWithSpriteFrameName("copyui_icon_bg.png")
    -- iconbg:setPosition(btnSize.width/2,btnSize.height/2)
    -- self.teamBtn[v]:addChild(iconbg)

    local icondec=cc.Sprite:createWithSpriteFrameName("copyui_dec_bg.png")
    icondec:setPosition(btnSize.width/2+8,33)
    self.teamBtn[v]:addChild(icondec)

    local teamImg = teamData.img[1]
    print("tupian------>",teamImg)
    local headSpr=nil
    if teamImg>0 then
      local szHead=string.format("h%d.png",teamImg)
      headSpr=gc.GraySprite:createWithSpriteFrameName(szHead)
      headSpr:setAnchorPoint(cc.p(1,0))
      headSpr:setPosition(btnSize.width,0)
      headSpr:setScale(1.15)
      self.teamBtn[v]:addChild(headSpr)
    end

    for i=1,3 do
      local starSpr = gc.GraySprite:createWithSpriteFrameName("general_star2.png")
      starSpr : setPosition(3+i*20,18)
      starSpr : setGray()
      self.teamBtn[v]:addChild(starSpr)
    end

    local headSize = headSpr:getContentSize()
    local teamLv = teamData.lv
    -- local nameLabel=_G.Util:createLabel(teamLv.."级",FontSize-2)
    -- nameLabel:setPosition(headSize.width/2,-20)
    -- nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
    -- headSpr:addChild(nameLabel)

    local teamName = teamData.copy_name
    local nameLabel=_G.Util:createLabel(string.format("%d %s",teamLv,teamName),FontSize)
    nameLabel:setPosition(headSize.width/2+12,-10)
    -- nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
    self.teamBtn[v]:addChild(nameLabel)

    if self.playerLv < teamLv then
      self.teamBtn[v]:setGray()
      headSpr:setGray()
      nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
  end
  self : createScelect(self.teamBtn[self.sceneId],true)
end

function TeamView.TeamDown( self)
  local outputLab = _G.Util:createLabel("几率产出：",FontSize)
  outputLab : setPosition(70,105)
  -- outputLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.pBackground:addChild(outputLab)

  local rewardLab = _G.Util:createLabel("剩余奖励次数：",FontSize)
  rewardLab : setPosition(rightSize.width-175,105)
  -- rewardLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.pBackground:addChild(rewardLab)

  -- local numSpr = cc.Sprite:createWithSpriteFrameName("general_input.png")
  -- numSpr : setPreferredSize(cc.size(60,24))
  -- numSpr : setPosition(rightSize.width-85,105)
  -- self.pBackground : addChild(numSpr)

  self.NumLab = _G.Util:createLabel("",FontSize)
  self.NumLab : setPosition(rightSize.width-90,105)
  self.NumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  self.pBackground:addChild(self.NumLab)

  local function onBtnCallBack(sender, eventType)
    self:onButtonCallBack(sender, eventType)
  end

  local addSpr = gc.CButton:create()
  addSpr : loadTextures("general_btn_add.png")
  addSpr : setPosition(rightSize.width-40, 105)
  addSpr : setTag(ADDS)
  addSpr : addTouchEventListener(onBtnCallBack)
  addSpr : ignoreContentAdaptWithSize(false)
  addSpr : setContentSize(cc.size(80,80))
  self.pBackground : addChild(addSpr)

  local foundBtn = gc.CButton:create()
  foundBtn : loadTextures("general_btn_lv.png")
  foundBtn : setPosition(rightSize.width-220, 42)
  foundBtn : setTitleFontName(_G.FontName.Heiti)
  foundBtn : setTitleFontSize(FontSize)
  foundBtn : setTitleText("创建房间")
  foundBtn : setTag(FOUND)
  foundBtn : addTouchEventListener(onBtnCallBack)
  self.pBackground : addChild(foundBtn)

  local randomBtn = gc.CButton:create()
  randomBtn : loadTextures("general_btn_gold.png")
  randomBtn : setPosition(rightSize.width-80, 42)
  randomBtn : setTitleFontName(_G.FontName.Heiti)
  randomBtn : setTitleFontSize(FontSize)
  randomBtn : setTitleText("快速加入")
  randomBtn : setTag(RONDOW)
  --randomBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  randomBtn : addTouchEventListener(onBtnCallBack)
  self.pBackground : addChild(randomBtn)

  local guideId=_G.GGuideManager:getCurGuideId()
  if guideId==_G.Const.CONST_NEW_GUIDE_SYS_TEAM then
      self.m_hasGuide=true
      self.m_guide_wait_join=true
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(1,randomBtn)
      _G.GGuideManager:runNextStep()
      local command=CGuideNoticHide()
      controller:sendCommand(command)
  end

end

function TeamView.TeamScrollView( self, _data )
  print("TeamScrollView",_data.copy_id,_data.count,self.m_scrollView)
  if _data == nil then return end
  if self.m_scrollView ~= nil then
    self.m_scrollView : removeFromParent(true)
    self.m_scrollView = nil
  end

  local m_Count = #_data>5 and #_data or 5
  m_Count=m_Count>20 and 20 or m_Count
  -- local framSize = self.teambgSpr:getContentSize()
  self.OneHeight = 312/5
  local viewSize = cc.size(rightSize.width, 312)
  local contentSize = cc.size(rightSize.width, self.OneHeight*m_Count)
  local ScrollView = cc.ScrollView : create()
  self.m_scrollView = ScrollView
  ScrollView : setDirection(ccui.ScrollViewDir.vertical)
  ScrollView : setPosition(-1,126 )
  ScrollView : setViewSize(viewSize)
  ScrollView : setContentSize(contentSize)
  ScrollView : setContentOffset( cc.p( 0, viewSize.height-contentSize.height ))
  ScrollView : setBounceable(false)
  ScrollView : setTouchEnabled(true)
  self.pBackground : addChild(self.m_scrollView)
  if viewSize.height < contentSize.height then
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-7,0))
  end

  print("dasdsadsadasdas-->>",_data.count_2,_data.msg_eva)
  for k,v in pairs(_data.msg_eva) do
    print("_data.msg_eva",k,v.copy_id,v.eva)
    for i=1,3 do
      starSpr = gc.GraySprite:createWithSpriteFrameName("general_star2.png")
      starSpr : setPosition(3+i*20,15)
      self.teamBtn[v.copy_id]:addChild(starSpr)
      if i>v.eva then
        starSpr : setGray()
      end
    end
  end

  for k,v in pairs(_data.reply_msg) do
    print("_data.reply_msg",k,v.team_id)
    if k>m_Count then return end
    local oneTeam = self : OneTeamWidget(v)
    oneTeam : setPosition(rightSize.width/2+1,contentSize.height-self.OneHeight/2-(k-1)*self.OneHeight)
    ScrollView : addChild(oneTeam)
  end
end

function TeamView.OneTeamWidget( self, msg )
  local oneWid = ccui.Scale9Sprite:createWithSpriteFrameName( "general_noit.png" )
  oneWid : setPreferredSize( cc.size(rightSize.width-18,57) )
  local widgetSize = oneWid : getContentSize()

  local function onBtnCallBack(sender, eventType)
    self:onCallBack(sender, eventType)
  end

  local addBtn = gc.CButton:create()
  addBtn : loadTextures("general_btn_gold.png")
  addBtn : setPosition(widgetSize.width-95, widgetSize.height/2)
  addBtn : setTitleFontName(_G.FontName.Heiti)
  addBtn : setTitleFontSize(FontSize+2)
  addBtn : setTitleText("加  入")
  addBtn : setTag(msg.team_id)
  addBtn : addTouchEventListener(onBtnCallBack)
  oneWid : addChild(addBtn)

  local playname = msg.name or ""
  local nameLab = _G.Util:createLabel(playname,FontSize)
  nameLab : setPosition(100,widgetSize.height/2)
  nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWid : addChild(nameLab)

  local playLv = msg.lv or ""
  local lvLab = _G.Util:createLabel(playLv,FontSize)
  lvLab : setPosition(cc.p(widgetSize.width/2-80,widgetSize.height/2))
  lvLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWid : addChild(lvLab)

  local teamNum = msg.men or ""
  local NumLab = _G.Util:createLabel(teamNum.."/3",FontSize)
  NumLab : setPosition(cc.p(widgetSize.width/2+70,widgetSize.height/2))
  NumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  oneWid : addChild(NumLab)

  -- local oneline = ccui.Scale9Sprite:createWithSpriteFrameName( "general_teambg.png" )
  -- -- local lineSprSize = oneline:getContentSize()
  -- oneline : setPreferredSize( cc.size(widgetSize.width-10,60) )
  -- oneline : setPosition( cc.p( widgetSize.width/2,30 ) )
  -- oneWid  : addChild( oneline )

  return oneWid
end

function TeamView.IconCount( self , tag)
  if self.oneIconSpr ~= nil then
    for k,v in pairs(self.oneIconSpr) do
      v:removeFromParent(true)
    end
  end
  self.oneIconSpr = {1,2,3,4}
  for i=1,4 do
    self.oneIconSpr[i] = self:oneIcon(i,tag)
    self.oneIconSpr[i] : setPosition(65+(i-1)*(iconSize.width+10),50)
    self.pBackground : addChild(self.oneIconSpr[i])
  end
end

function TeamView.oneIcon( self , i,tag)
  local iconSpr = gc.GraySprite:createWithSpriteFrameName("general_tubiaokuan.png")
  local function cFun(sender,eventType)
    if eventType==ccui.TouchEventType.ended then
      local good_tag=sender:getTag()
      local _pos = sender:getWorldPosition()
      local temp = _G.TipsUtil:createById(good_tag,nil,_pos)
      cc.Director:getInstance():getRunningScene():addChild(temp,1000)
    end
  end
  local copyCnf=_G.Cfg.scene_copy[tag]
  if copyCnf == nil then return end
  local icondata=copyCnf.reward 
  local iconImg = nil
  if icondata~=nil and icondata[i]~=nil then
    print("请求物品图片", icondata[i][1][1],icondata[i][1][2])
    local goodId    = icondata[i][1][1]
    local goodCount = icondata[i][1][2]
    local goodsdata = _G.Cfg.goods[goodId]
    if goodsdata ~= nil then
      iconImg = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
      iconImg : setPosition(iconSize.width/2,iconSize.height/2)
      iconSpr : addChild(iconImg)
    end
  end

  return iconSpr
end

function TeamView.createScelect( self,_obj,_istrue )
    print("createScelect",_obj,_istrue)
    if _obj == nil then return end
    if self.m_headEffect ~= nil then
        self.m_headEffect : retain()
        self.m_headEffect : removeFromParent(false)
        _obj : addChild(self.m_headEffect)
        self.m_headEffect : release()
        return
    end

    if _istrue then
      self.m_headEffect = cc.Sprite :createWithSpriteFrameName("copyui_icon_light.png")
      -- self.m_headEffect : setScale(1.1)
      -- self.m_headEffect : runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
      self.m_headEffect : setPosition(47,32)

      _obj : addChild(self.m_headEffect,-1)
    end
end

function TeamView.onCallBack( self,sender, eventType)
  if eventType == ccui.TouchEventType.ended then
    local teamTag = sender : getTag()
    local Position = sender : getWorldPosition()
    print("teamTag",teamTag,Position.y,m_winSize.height/2-120)
    if Position.y > m_winSize.height/2+pSize.height/2-75 or
        Position.y < m_winSize.height/2-120 then return end
    local msg = REQ_TEAM_JOIN()
    msg:setArgs(teamTag)
    _G.Network:send(msg)
  end
end

function TeamView.onButtonCallBack( self,sender, eventType )
  if eventType == ccui.TouchEventType.ended then
    local Tag = sender : getTag()
    local teamData = _G.Cfg.scene_copy[self.sceneId]
    local teamLv = teamData.lv

    if Tag == FOUND then
      print("创建房间",Tag)
      if self.playerLv < teamLv then 
        print("等级不足")
        local command = CErrorBoxCommand(_G.Lang.LAB_N[122])
        controller : sendCommand( command )
        return 
      end
      local msg = REQ_TEAM_CREAT()
      msg:setArgs(self.sceneId)
      _G.Network:send(msg)
    elseif Tag == RONDOW then
      print("随机进入",Tag)
      if self.m_guide_wait_join then
          _G.GGuideManager:removeCurGuideNode()
          self.m_guide_wait_join=nil
      end

      if self.playerLv < teamLv then 
        print("等级不足")
        local command = CErrorBoxCommand(_G.Lang.LAB_N[122])
        controller : sendCommand( command )
        return 
      end
      local msg = REQ_TEAM_QUICK_JOIN()
      msg:setArgs(self.sceneId)
      _G.Network:send(msg)
    elseif Tag == ADDS then
      print("加次数",Tag,self.buy_times)
      if isBuyTip then
        print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
        local msg  = REQ_TEAM_BUY_TIMES()
        _G.Network : send(msg)
      else
        self : BuyCountCallBack(self.buy_times)
      end
    end
  end
end

function TeamView.BuyCountCallBack( self,buy_times )
  local function buy()
    print("购买挑战次数")
    local msg  = REQ_TEAM_BUY_TIMES()
    _G.Network : send(msg)
  end

  local topLab    = string.format("花费%d元宝购买1次奖励次数吗?",self.rmbnum)
  local centerLab = _G.Lang.LAB_N[940]
  local downLab   = _G.Lang.LAB_N[416]..": "
  local timesLab  = buy_times
  local rightLab  = _G.Lang.LAB_N[106]

  local szSureBtn = "确 定"

  local view  = require("mod.general.TipsBox")()
  local layer = view : create("",buy,cancel)
  cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

  view:setTitleLabel("购买次数")
  if topLab ~= nil then
    local label =_G.Util : createLabel(topLab,20)
    -- label : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_YELLOW ) )
    label     : setPosition(cc.p(0,60))
    view:getMainlayer() : addChild(label,88)
  end
  if centerLab ~= nil then
    local label =_G.Util : createLabel(centerLab,18)
    -- label : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_YELLOW ) )
    label     : setPosition(cc.p(0,30))
    view:getMainlayer() : addChild(label,88)
  end
  local labWidth=0
  if downLab ~= nil then
    local labeldown =_G.Util : createLabel(downLab,20)
    -- labeldown : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_YELLOW ) )
    labeldown : setPosition(cc.p(-7,-5))
    view:getMainlayer() : addChild(labeldown,88)
    labWidth=labeldown:getContentSize().width
  end
  if timesLab ~= nil then
    local labeltimes =_G.Util : createLabel(timesLab,20)

    labeltimes : setPosition(cc.p(3+labWidth/2,-5))
    if timesLab>0 then
      labeltimes : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    else
      labeltimes : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
    view:getMainlayer() : addChild(labeltimes,88)
  end
  if rightLab then
    local label =_G.Util : createLabel(rightLab,20)
    -- label : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_YELLOW ) )
    label     : setPosition(cc.p(25,-50))
    view:getMainlayer() : addChild(label,88)
  end
  if szSureBtn ~= nil then
      view : setSureBtnText(szSureBtn)
  end

  local function c(sender, eventType)
    if eventType==ccui.TouchEventType.ended then
      print("勾选了不再提示",isBuyTip)
      if isBuyTip then
        isBuyTip = false
        -- _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_TEAM,false)
      else
        isBuyTip = true
        -- _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_TEAM,true)
      end
    end
  end

  local checkbox = ccui.CheckBox : create()
  checkbox : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
  checkbox : setPosition(cc.p(-80,-52))
  checkbox : setName("sdjfgksjdfklgj")
  checkbox : addTouchEventListener(c)
  -- checkbox : setAnchorPoint(cc.p(1,0.5))
  view:getMainlayer()    : addChild(checkbox)
end

function TeamView.setBuySuccess(self,_data)
  print("setBuySuccess-->>",_data.reward_times,_data.buy_times,_data.rmb)
  self.NumLab : setString(_data.reward_times)
  self.buy_times = _data.buy_times
  self.rmbnum = _data.rmb or 0
end

function TeamView.pushdata(self,_data)
  if self.pBackground == nil then return end
  print("协议返回数据",_data.copy_id,_data.times,_data.buy_times,_data.rmb)
  print("协议返回数据的数量",_data.count)
  self.NumLab : setString(_data.times)
  self.buy_times = _data.buy_times
  self.rmbnum = _data.rmb or 0
  self : TeamScrollView(_data)
end

function TeamView.setNotice(self,_data)
  print("离队原因",_data.reason)
  if _data.reason == 1 then
    self : popRoot()
  -- elseif _data.reason == 2 then
  end
end

function TeamView.setTeamData(self,_data)
  print("setTeamData",_data.team_id,_data.copy_id,_data.leader_uid,_data.count,_data.data)
  if self.pBackground~=nil then
    self.leftSpr : setVisible(false)
    self.pBackground : setVisible(false)
  end
  
  if self.tagClass==nil then
    print("创建")
    self.tagClass  = require "mod.team.RoomView"()
    local tempNode = self.tagClass : create(_data)
    self.teamNode : addChild(tempNode)
  elseif self.teamId==_data.team_id then
    print("刷新")
    self.tagClass : RightData(_data)
  end
  self.teamId=_data.team_id
end

function TeamView.setList(self,_data)
  print("setList",_data.count)
  self.tagClass : ListRealy(_data)
end

function TeamView.setInvite(self)
  print("setInvite")
  self.tagClass : Invite()
end

function TeamView.destroy(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return TeamView

