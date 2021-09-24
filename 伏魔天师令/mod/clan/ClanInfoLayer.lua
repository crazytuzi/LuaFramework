local ClanInfoLayer=classGc(view,function(self,_ortherUid)
    self.pMediator=require("mod.clan.ClanInfoLayerMediator")(self)
    self.m_ortherClanId=_ortherUid
end)

local FONT_SIZE = 20
local FONT_NAME = _G.FontName.Heiti

local TAGBTN_RECRUITTING = 1
local TAGBTN_QUIT        = 2
local TAGBTN_GONGGAO     = 3

local  ONEPAGE_COUNT = 5

local color1      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LBLUE )
local color3      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
local color4      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )
local color5      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )
local color6      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD  )
local color7      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LABELBLUE  )

function ClanInfoLayer.__create(self)
  self.m_container = cc.Node:create()
  --左底图
  self.m_leftSprSize= cc.size(347,477)
  self.m_leftSpr    = ccui.Widget:create() 
  self.m_leftSpr    : setContentSize( self.m_leftSprSize )
  self.m_container  : addChild(self.m_leftSpr)
  self.m_leftSpr    : setPosition(-240,-55)

  --右底图
  self.m_rightSprSize= cc.size(479,477)
  self.m_right2Spr    = ccui.Widget:create() 
  self.m_right2Spr    : setContentSize( self.m_rightSprSize )
  self.m_container    : addChild(self.m_right2Spr)
  self.m_right2Spr    : setPosition(177,-55)

  local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_lowline.png")
  lineWidth=lineSpr:getContentSize().width
  lineSpr : setPreferredSize(cc.size(lineWidth,490))
  lineSpr : setPosition(4,self.m_rightSprSize.height/2)
  lineSpr : setScaleX(-1)
  self.m_right2Spr:addChild(lineSpr)

  local function local_btncallback(sender, eventType) 
      return self : onBtnCallBack(sender, eventType)
  end

  local titleSpr     = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
  titleSpr           : setPosition(self.m_rightSprSize.width/2,450)
  self.m_right2Spr  : addChild(titleSpr)
  --右边上
  local infoNameLab = _G.Util:createLabel("门派公告",FONT_SIZE+4)
  infoNameLab : setColor(color6)
  infoNameLab : setPosition(self.m_rightSprSize.width/2,450)
  self.m_right2Spr : addChild(infoNameLab,3)

  if not self.m_ortherClanId then
      local gonggaoBtn  = gc.CButton:create() 
      gonggaoBtn  : loadTextures("clan_gonggaotbn.png")
      gonggaoBtn  : setTag(TAGBTN_GONGGAO)
      gonggaoBtn  : addTouchEventListener(local_btncallback)
      gonggaoBtn  : setPosition(self.m_rightSprSize.width-45,450)
      self.m_right2Spr : addChild(gonggaoBtn)
      self.gonggaoBtn = gonggaoBtn
  end

  self.m_ggRichText = _G.Util : createLabel( "", 20 )
  self.m_ggRichText : setDimensions( 440, 0 ) 
  self.m_ggRichText : setAnchorPoint( cc.p(0.5, 1) )
  self.m_ggRichText : setPosition(240,408)
  -- self.m_ggRichText : setColor( color4 )
  self.m_ggRichText : setLineBreakWithoutSpace(true)
  self.m_right2Spr  : addChild(self.m_ggRichText,3)

  local kuangSpr     = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" ) 
  kuangSpr           : setPreferredSize( cc.size(465,171) )
  kuangSpr           : setPosition(self.m_rightSprSize.width/2,335)
  self.m_right2Spr  : addChild(kuangSpr)
  
  --右边下
  local titleSpr1     = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
  titleSpr1           : setPosition(self.m_rightSprSize.width/2,220)
  self.m_right2Spr  : addChild(titleSpr1)

  local infoNameLab = _G.Util:createLabel("门派日志",FONT_SIZE+4)
  infoNameLab : setColor(color6)
  infoNameLab : setPosition(self.m_rightSprSize.width/2,220)
  self.m_right2Spr : addChild(infoNameLab,3)

  local kuangSpr     = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" ) 
  kuangSpr           : setPreferredSize( cc.size(465,181) )
  kuangSpr           : setPosition(self.m_rightSprSize.width/2,100)
  self.m_right2Spr  : addChild(kuangSpr)

  --左边
  local titleSpr1     = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
  titleSpr1           : setPosition(self.m_leftSprSize.width/2,self.m_leftSprSize.height-28)
  self.m_leftSpr  : addChild(titleSpr1)

  local leftNameLab=_G.Util:createLabel("门派信息",FONT_SIZE+4)
  leftNameLab    : setColor(color6)
  leftNameLab    : setPosition(self.m_leftSprSize.width/2,self.m_leftSprSize.height-28)
  self.m_leftSpr : addChild(leftNameLab,3)

  local kuangSpr2     = ccui.Scale9Sprite:createWithSpriteFrameName( "general_gold_floor.png" ) 
  kuangSpr2           : setPreferredSize( cc.size(330,330) )
  kuangSpr2           : setPosition(self.m_leftSprSize.width/2,255)
  self.m_leftSpr   : addChild(kuangSpr2)

  
  local infoStrArray={"门派名称:","掌        门:","门派排名:","门派人数:","门派等级:","门派经验:","门派战力:"}
  local clanerInfoLab = {}
  local nPosX = self.m_leftSprSize.width/2-90
  local nPosY = self.m_leftSprSize.height-87

  for i=1,14 do
      clanerInfoLab[i] = _G.Util:createLabel(infoStrArray[i] or "",FONT_SIZE)
      self.m_leftSpr   : addChild(clanerInfoLab[i],3)

      if i <= 7 then
          clanerInfoLab[i] : setPosition(nPosX,nPosY-(i-1)*45)
          -- clanerInfoLab[i] : setColor(color5)
      elseif  i > 7 then
          clanerInfoLab[i] : setAnchorPoint( 0,0.5 )
          clanerInfoLab[i] : setPosition(nPosX+50,nPosY-(i-1-7)*45)
          clanerInfoLab[i] : setColor(color4)
      end
  end

  self.m_clanerInfoLab = clanerInfoLab

  if not self.m_ortherClanId then
      self.m_recruittingBtn  = gc.CButton:create("general_btn_gold.png") 
      self.m_recruittingBtn  : setTitleFontName(FONT_NAME)
      self.m_recruittingBtn  : setTitleText("招募新人")
      self.m_recruittingBtn  : setTag(TAGBTN_RECRUITTING)
      self.m_recruittingBtn  : setTitleFontSize(FONT_SIZE+2)
      --self.m_recruittingBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
      self.m_recruittingBtn  : addTouchEventListener(local_btncallback)
      self.m_recruittingBtn  : setPosition(self.m_leftSprSize.width/2-75,45)
      self.m_leftSpr         : addChild(self.m_recruittingBtn)

      self.m_QuitBtn = gc.CButton:create() 
      self.m_QuitBtn : setTitleFontName(FONT_NAME)
      self.m_QuitBtn : loadTextures("general_btn_lv.png")
      self.m_QuitBtn : setTitleText("退出门派")
      self.m_QuitBtn : setTitleFontSize(FONT_SIZE+2)
      self.m_QuitBtn : setTag(TAGBTN_QUIT)
      self.m_QuitBtn : addTouchEventListener(local_btncallback)
      self.m_leftSpr : addChild(self.m_QuitBtn)
      self.m_QuitBtn : setPosition(self.m_leftSprSize.width/2+75,45)
  end

  --门派日志面板
  self:__createInfoPanel()
  --初始化发协议什么的
  -- self:NetworkSend()
  
  return self.m_container
end

function ClanInfoLayer.NetworkSend(self)
    local myPro = _G.GPropertyProxy : getMainPlay() : getClanPost()
    if myPro == 5 or myPro == 6 then
      if self.gonggaoBtn ~= nil then
        self.gonggaoBtn : setDefault()
        self.gonggaoBtn : setTouchEnabled( true ) 
      end
    else
      if self.gonggaoBtn ~= nil then
        self.gonggaoBtn : setGray()
        self.gonggaoBtn : setTouchEnabled( false ) 
      end
    end

    local msg=REQ_CLAN_ASK_CLAN()
    msg:setArgs(self.m_ortherClanId or 0)
    _G.Network:send(msg)

    self.m_ortherClanId=nil
end

function ClanInfoLayer.__createInfoPanel(self )
    if self.m_pageView ~= nil then 
        self.m_pageView : removeFromParent(true)
        self.m_pageView = nil 
    end

    local logsCount = self.m_logscount
    local logsData  = self.m_logsmsgdata
    
    if logsCount == nil or logsCount < 1 then return end

    local function sortfuncup( logs1, logs2)
        if logs1.time > logs2.time then
            return true
        end
        return false
    end
    table.sort( logsData, sortfuncup)

    -- print("EquipGemLayer.createGoodPanel=",logsCount)
    
    local sprSize       = cc.size(380,35)
    local innerHeight   = sprSize.height*logsCount
    local _pageViewSize = cc.size(self.m_rightSprSize.width,sprSize.height*ONEPAGE_COUNT)
    local innerViewSize = cc.size(self.m_rightSprSize.width-10,innerHeight)

    local pageView = cc.ScrollView:create()
    pageView:setTouchEnabled(true)
    pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pageView:setContentSize(innerViewSize)  
    pageView:setViewSize(_pageViewSize) 
    pageView:setPosition(cc.p(0,13))     
    pageView:setContentOffset(cc.p(0,-innerHeight+_pageViewSize.height)) -- 设置初始位置

    for k=1,logsCount do
        local nNode=self:LabNodeCreate( logsData[k] )
        local posX =20
        local posY =innerHeight-_pageViewSize.height+(sprSize.height)*(ONEPAGE_COUNT-1)+sprSize.height/2-sprSize.height*(k-1)
        nNode:setPosition(posX,posY)
        pageView:addChild(nNode)
    end

    self.m_right2Spr:addChild(pageView)
    self.m_pageView=pageView
end

function ClanInfoLayer.getdealStrWithData( self,_data )

    local times = _data.time
    local temptime = ""
    local nowTime = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime -times


    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)


    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    -- elseif math.floor( offlineTime/3600 ) > 0 then   --超过一个小时但一天内
    --     temptime = math.floor( offlineTime/3600 ).._G.Lang.LAB_N[91]
    -- elseif math.floor( offlineTime/60 ) > 0 then   --超过一分钟 但一个小时内
    --     temptime = math.floor( offlineTime/60 ).._G.Lang.LAB_N[90]
    else
        -- temptime = "1".._G.Lang.LAB_N[90]

        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    
   return  temptime
end

function ClanInfoLayer.LabNodeCreate( self, _data )
  local node = cc.Node : create()

  local time       = self:getdealStrWithData(_data)
  local tempstring = _data.string_msg
  local tempint    = _data.int_msg
  local lab = {}
  local ColorNum=2
  lab[1] = time
  lab[2] = tempstring[1].name
  if _data.type == 3 or _data.type == 6 then
    lab[3] = "被"
    lab[4] = tempstring[2].name
  elseif _data.type == 5 or _data.type == 11 then
    lab[6] = tempstring[2].name
  elseif _data.type == 10 then
    lab[7] = tempint[1].value
  end
  lab[5] = _G.Lang.faction_logs[_data.type]

  local myColor = { color3, color4, color3, color4, color3, color4, color3 }
  local width = 0
  for i=1,7 do
    if lab[i] ~= nil then
      local lab = _G.Util : createLabel( lab[i], 20 )
      lab  : setColor( myColor[i] )
      lab  : setAnchorPoint( 0, 0.5 )
      lab  : setPosition( width, 0 )
      node : addChild( lab )

      width= width + lab : getContentSize().width
    end
  end

  return node
end

function ClanInfoLayer.onBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      if btn_tag==TAGBTN_RECRUITTING then
          print("招募新人")
          local myProperty=_G.GPropertyProxy:getMainPlay()
          print("天天开心，天天快乐",myProperty:getClan(),myProperty:getClanName())
          _G.GChatProxy:requestClanRecruit(myProperty:getClan(),myProperty:getClanName())
      elseif btn_tag==TAGBTN_QUIT then
          print("退出门派")
          local szMsg = "确定要退出门派吗？\n(门派技能保留)"
          local function fun1()
              local msg = REQ_CLAN_ASK_OUT_CLAN()
              msg :setArgs(1)        -- {1 退出门派| 0 解散门派}
              _G.Network:send(msg)
          end
          _G.Util:showTipsBox(szMsg,fun1)
      elseif btn_tag==TAGBTN_GONGGAO then
          print("编辑公告")
          self:createCreatePanel()
      end
    end
end

function ClanInfoLayer.unregister(self)
  if self.pMediator ~= nil then
     self.pMediator : destroy()
     self.pMediator = nil 
  end
end

function ClanInfoLayer.getMyPost(self)
  return self.m_myPost
end

function ClanInfoLayer.NetWorkReturn_ClanInfoData( self,_data ) 
    self.m_clanerInfoLab[8]  : setString(_data.clan_name or "无")
    self.m_clanerInfoLab[10] : setString(_data.clan_rank or "无")

    self.m_clanerInfoLab[11] : setString(_data.clan_members.."/".._data.clan_all_members)
    self.m_clanerInfoLab[12] : setString(_data.clan_lv or "无")
end


function ClanInfoLayer.NetWorkReturn_ClanInfoData2( self,_data )
    self.m_clanerInfoLab[9]  : setString(_data.master_name or "无")
    self.m_clanerInfoLab[13] : setString(_data.clan_all_contribute.."/".._data.clan_contribute)
    self.m_clanerInfoLab[14] : setString(_data.sum_power or "无")

    print("公告传过来的东西==",_data.clan_broadcast,_data.upost)
    self.m_updateClanInfo=_data.clan_broadcast or ""
    self.m_ggRichText : setString( string.format( "%s%s", "         ",self.m_updateClanInfo) )

    self.m_updateClanInfo=_data.clan_broadcast
    
    local master_uid = _data.master_uid
    local myuid      = _G.GLoginPoxy:getUid()
    print( "出现这里", _data.upost, self.into )
    if not self.into then
      if (_data.upost~=_G.Const.CONST_CLAN_POST_SECOND
        and _data.upost~=_G.Const.CONST_CLAN_POST_MASTER
        and self.m_recruittingBtn) then
          print( "再这里出问题", _data.upost, self.into )
          self.m_recruittingBtn:setTouchEnabled(false)
          self.m_recruittingBtn:setGray()
      end
    end
    if _data.upost==_G.Const.CONST_CLAN_POST_SECOND
      or _data.upost==_G.Const.CONST_CLAN_POST_MASTER then
        self.into = true
    end

    self.m_myPost=_data.upost
end

function ClanInfoLayer.NetWorkReturn_ClanLogs( self,logscount,logsmsg )
    if logscount<=0 or logsmsg==nil then return end

    self.m_logscount   = logscount
    self.m_logsmsgdata = logsmsg
    self:__createInfoPanel()
end


function ClanInfoLayer.createCreatePanel( self )
  -- local function onTouchBegan() return true end
  -- local listerner=cc.EventListenerTouchOneByOne:create()
  -- listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  -- listerner:setSwallowTouches(true)

  -- if m_creatbox ~= nil then
  --    m_creatbox : removeFromParent(true)
  --    m_creatbox = nil 
  -- end
  -- m_creatbox = cc.Layer:create()
  -- m_creatbox:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,m_creatbox)
  -- cc.Director:getInstance():getRunningScene():addChild(m_creatbox,1000)

  local textField = nil

  local function sure( )
    local clanInfo = textField:getString()
      -- local clanInfo = textField:getText()
      print("修改门派信息",clanInfo)
      if clanInfo == nil or clanInfo == "" then 
         print("======asdasdasda>>>>ABNNMMMM>>>")
         -- clanInfo = "掌门很懒，什么都没写！"
         local command = CErrorBoxCommand(11571)
         controller :sendCommand( command )
         return
      end
      local maxlength = string.len("字") * _G.Const.CONST_CLAN_NOTICE_MAX
      local length    = string.len(clanInfo) 
      print("length",maxlength,length)
      if length > maxlength then 
         local command = CErrorBoxCommand(11528)
         controller :sendCommand( command )
         return 
      end

      local msg=REQ_CLAN_ASK_RESET_CAST()
      msg:setArgs(clanInfo)
      _G.Network:send(msg)

      self.m_updateClanInfo = clanInfo
  end

  local function cancel(  )

  end

  local size  = cc.Director : getInstance() : getWinSize()
  local view  = require("mod.general.TipsBox")()
  local layer = view : create("",sure,cancel) 
  -- layer       : setPosition(cc.p(size.width/2,size.height/2))
  cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  view        : setTitleLabel( "修改公告" )
  local m_creatbox = view:getMainlayer()

  -- local View_Size=cc.size(390,270)

  -- local bgSpr      = ccui.Widget:create( ) 
  -- bgSpr            : setContentSize( View_Size )
  -- m_creatbox  : addChild(bgSpr)

  -- local lineSpr     = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
  -- local lineSprSize = lineSpr:getPreferredSize()
  -- lineSpr           : setPreferredSize( cc.size(View_Size.width-60,lineSprSize.height) )
  -- bgSpr             : addChild(lineSpr)

  textField=ccui.TextField:create("请输入公告内容...",_G.FontName.Heiti,FONT_SIZE)
  textField:setTouchEnabled(true)
  -- textField:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  textField:setMaxLengthEnabled(true)
  textField:setMaxLength(50)
  textField:setTouchSize(cc.size(310,110))
  textField:setContentSize(cc.size(310,110))
  if ccui.TextField.setLineBreakWithoutSpace then
      textField:setLineBreakWithoutSpace(true)
      textField:ignoreContentAdaptWithSize(false)
  end
  m_creatbox:addChild(textField,3)

  if self.m_updateClanInfo~=nil then
      textField:setString(self.m_updateClanInfo)
  end

  -- lineSpr      :setPosition(View_Size.width/2,View_Size.height-45)
  textField    :setPosition(0,15)
end

function ClanInfoLayer.NetWorkReturn_updateClanInfo( self )
  self.m_updateClanInfo=self.m_updateClanInfo or ""
  self.m_ggRichText : setString( string.format( "%s%s", "",self.m_updateClanInfo) )
end

return ClanInfoLayer