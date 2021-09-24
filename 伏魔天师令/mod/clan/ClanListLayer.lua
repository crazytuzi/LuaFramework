local ClanListLayer = classGc(view, function(self)
    self.pMediator = require("mod.clan.ClanListLayerMediator")()
    self.pMediator : setView(self)

    self.m_msgAllData={}
end)

local FONT_SIZE   = 20
local color1      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_LBLUE )
local color2      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PBLUE )
local color3      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
local color4      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_DARKPURPLE )
local color5      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN )
local color6      = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD  )
local ChooseX     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_XSTROKE)

local Tag_Btn_CreateDF = 101
local Tag_Btn_JoinInDF = 102

function ClanListLayer.__create(self)
  self.m_container  = cc.Node:create()
  --外层绿色底图大小
  self.m_rootBgSize = cc.size(847,492)

  self.m_leftSpr    = cc.Node : create()
  self.m_container  : addChild(self.m_leftSpr)
  self.m_leftSpr    : setPosition(-self.m_rootBgSize.width/2,-240)

  self.m_righSpr    = cc.Node : create()
  self.m_container  : addChild(self.m_righSpr)
  self.m_righSpr    : setPosition(0,-235)

  self : createLftView()
  self : createRghView()

  return self.m_container
end

function ClanListLayer.createLftView( self )
  local leftSprSize = cc.size(425,self.m_rootBgSize.height-95)
  local Spr_LefBase = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  Spr_LefBase       : setPreferredSize( leftSprSize )
  Spr_LefBase       : setAnchorPoint( 0.5, 1 )
  Spr_LefBase       : setPosition( leftSprSize.width/2+15, leftSprSize.height-10 )
  self.m_leftSpr    : addChild( Spr_LefBase, -1 )

  -- 列表title
  local Lab_Line = {}
  local Text_Lab_Line = {"排 名","名 称","等 级","人 数"}
  local Pos_x   = {75,178,290,390}
  for i=1,4 do
      Lab_Line[i]     = _G.Util:createLabel(Text_Lab_Line[i],FONT_SIZE)
      Lab_Line[i]     : setPosition( Pos_x[i],self.m_rootBgSize.height-85 )
      -- Lab_Line[i]     : setColor( color4 )
      self.m_leftSpr  : addChild(Lab_Line[i],3)
  end

  -- 6个装载信息
  self.myCurrPage = 1

  local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_lowline.png")
  lineWidth=lineSpr:getContentSize().width
  lineSpr : setPreferredSize(cc.size(lineWidth,490))
  lineSpr : setPosition(leftSprSize.width+20,leftSprSize.height/2-12)
  self.m_leftSpr:addChild(lineSpr)

  self.Btn_Fanye  = {}
  local pos_FanyeX = { leftSprSize.width/2-40, leftSprSize.width/2+45 }
  local pos_FanyeY = -35

  local spr_input = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  spr_input       : setContentSize(cc.size(80,35))
  spr_input       : setPosition( leftSprSize.width/2+2, pos_FanyeY+1 ) 
  self.m_leftSpr  : addChild( spr_input, 2 ) 

  self.Lab_input  = _G.Util : createLabel( "", FONT_SIZE )
  self.Lab_input  : setPosition( leftSprSize.width/2+2, pos_FanyeY ) 
  -- self.Lab_input  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_leftSpr  : addChild( self.Lab_input, 3 ) 
end

function ClanListLayer.createPageView(self)
    local tempHeight=388
    local viewSize=cc.size(440,tempHeight)

    local pageView=ccui.PageView:create()
    pageView : setContentSize(viewSize)
    pageView : setAnchorPoint(cc.p(0,0))
    pageView : setPosition(17, -6)
    pageView : setCustomScrollThreshold(50)
    pageView : setDirection(1)
    pageView : enableSound()
    self.m_leftSpr:addChild(pageView,3)

    self.m_pageLayoutArray={}
    self.m_pageSellArray={}
    for i=1,3 do
        local layout=ccui.Layout:create()
        local tempArray={}
        for j=1,5 do
            local tempNode,tArray=self:createOneGoodMethod(j)
            tempNode:setPosition(210,tempHeight-(j-1)*78)
            layout:addChild(tempNode)
            tempArray[j]=tArray
        end
        pageView:addPage(layout)

        self.m_pageLayoutArray[i]=layout
        self.m_pageSellArray[i]=tempArray
    end

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            self:resetPageLayout()
        end
    end
    pageView : addEventListener(pageViewEvent)
    pageView : setCurPageIndex(1)
    self.m_pageView=pageView

    self.m_curMsgPage=1
    self.m_pageLayoutPos={1,2,3}
end
function ClanListLayer.resetPageLayout(self)
    local curPage=self.m_pageView:getCurPageIndex()

    local nextPage
    if curPage==0 then
        -- 往上翻
        local tempPos=self.m_pageLayoutPos[3]
        self.m_pageLayoutPos[3]=nil
        table.insert(self.m_pageLayoutPos,1,tempPos)

        local tempLayout=self.m_pageLayoutArray[tempPos]
        tempLayout:retain()

        self.m_pageView:removePage(tempLayout)
        self.m_pageView:insertPage(tempLayout,0)
        tempLayout:release()

        self.m_pageView : setCurPageIndex(1)

        self.m_curMsgPage=self.m_curMsgPage-1
        if self.m_curMsgPage==0 then
            self.m_curMsgPage=self.m_msgAllPage
        end

        nextPage=self.m_curMsgPage-1

    elseif curPage==2 then
        local tempPos=table.remove(self.m_pageLayoutPos,1)
        self.m_pageLayoutPos[3]=tempPos

        local tempLayout=self.m_pageLayoutArray[tempPos]
        tempLayout:retain()

        self.m_pageView:removePage(tempLayout)
        self.m_pageView:insertPage(tempLayout,2)
        tempLayout:release()

        self.m_pageView : setCurPageIndex(1)

        self.m_curMsgPage=self.m_curMsgPage+1
        if self.m_curMsgPage>self.m_msgAllPage then
            self.m_curMsgPage=1
        end

        nextPage=self.m_curMsgPage+1
    else
        return
    end

    self:resetPageNumLabel()

    if nextPage==0 then
        self:REQ_CLAN_ASL_CLANLIST(1)
    elseif nextPage>self.m_msgAllPage then
        self:REQ_CLAN_ASL_CLANLIST(self.m_msgAllPage)
    else
        self:REQ_CLAN_ASL_CLANLIST(nextPage)
    end
end
function ClanListLayer.resetPageData(self)
    -- 中间显示页面
    self.m_shenQingSprArray={}
    self.m_clanWidgetArray={}
    local tempPageIdx=self.m_curMsgPage
    local idx=self.m_pageLayoutPos[2]
    self:updatePageDataCell(self.m_pageSellArray[idx],self.m_msgAllData[tempPageIdx])

    if self.m_msgAllData[tempPageIdx] and #self.m_msgAllData[tempPageIdx]>0 then
        self:changeSelectClan(self.m_msgAllData[tempPageIdx][1].clan_id)
    end

    if self.m_msgAllPage==1 then return end

    -- 上面
    tempPageIdx=self.m_curMsgPage-1
    if tempPageIdx==0 then
        tempPageIdx=self.m_msgAllPage
    end
    local idx=self.m_pageLayoutPos[1]
    self:updatePageDataCell(self.m_pageSellArray[idx],self.m_msgAllData[tempPageIdx])

    -- 下面
    tempPageIdx=self.m_curMsgPage+1
    if tempPageIdx>self.m_msgAllPage then
        tempPageIdx=1
    end
    local idx=self.m_pageLayoutPos[3]
    self:updatePageDataCell(self.m_pageSellArray[idx],self.m_msgAllData[tempPageIdx])
end
function ClanListLayer.updatePageDataCell(self,_tempT,_tempData)
    local myColor = {
        _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED),
        _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD),
        _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE),
        _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE),
    }

    _tempData=_tempData or {}
    for i=1,#_tempT do
        local nT=_tempT[i]
        local nData=_tempData[i]
        if nData then
            local strArray={tostring(nData.clan_rank),nData.clan_name or "nil",tostring(nData.clan_lv),string.format("%d/%d",nData.clan_members or 0,nData.clan_all_members or 0)}
            nT.shenSpr:setVisible(false)
            nT.tempWid:setTag(nData.clan_id)
            self.m_shenQingSprArray[nData.clan_id]=nT.shenSpr
            self.m_clanWidgetArray[nData.clan_id]=nT.tempWid

            for j=1,#nT.labelArray do
                nT.labelArray[j]:setString(strArray[j])
                if nData.clan_rank<4 then
                    nT.labelArray[j]:setColor(myColor[nData.clan_rank])
                else
                    nT.labelArray[j]:setColor(myColor[4])
                end
            end
        else
            nT.labelArray[1]:setString("")
            nT.labelArray[2]:setString("")
            nT.labelArray[3]:setString("")
            nT.labelArray[4]:setString("")
            nT.tempWid:setTag(0)
            nT.shenSpr:setVisible(false)
        end
    end
end
function ClanListLayer.resetPageNumLabel(self)
    if self.m_curMsgPage and self.m_msgAllPage then
        self.Lab_input:setString(string.format("%d/%d",self.m_curMsgPage,self.m_msgAllPage))
    end
end

function ClanListLayer.createOneGoodMethod( self,_no )
  -- 创建每一个门派信息装载框
  print("ClanListLayer.createOneGoodMethod===",_no)
  local container = cc.Node:create()
  local sprSize   = cc.size(415,73)

  local bgSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_noit.png" ) 
  bgSpr           : setAnchorPoint( 0.5, 1 )
  bgSpr           : setPreferredSize( sprSize )
  container       : addChild(bgSpr, -1)

  local function local_sprCallBack( obj, eventType ) 
     -- print( " obj:getWorldPosition() = ", obj:getWorldPosition().x, obj:getWorldPosition().y  )
      if obj:getWorldPosition().y>470 or obj:getWorldPosition().y<130 then
          return
      end
      self : touchEventCallBack( obj, eventType )
  end

  local touchText = ccui.Widget:create()
  touchText       : setContentSize( sprSize )
  touchText       : setAnchorPoint( 0.5, 1 )
  touchText       : setTouchEnabled( true )
  touchText       : setSwallowTouches( false )
  touchText       : setTag( _no )
  touchText       : addTouchEventListener( local_sprCallBack )
  container     : addChild(touchText,1)

  local shenSpr = cc.Sprite : createWithSpriteFrameName("clan_shen.png")
  shenSpr       : setVisible(false)
  shenSpr       : setPosition(-182,-sprSize.height/2)
  shenSpr       : setScale(1.05)
  container     : addChild(shenSpr,2)

  print("_no11111",_no)
  local leftinfoLab = {}
  local leftinfoStr = { "", "", "", "" }
  local gap         = -150 
  local leftinfoX   = {-150,-45,65,165}
  
  for i=1,4 do
      leftinfoLab[i] = _G.Util:createLabel(leftinfoStr[i],FONT_SIZE)
      container      : addChild(leftinfoLab[i],3)
      leftinfoLab[i] : setPosition(leftinfoX[i],-sprSize.height/2)
  end

  local tempT={
      tempWid=touchText,
      shenSpr=shenSpr,
      labelArray=leftinfoLab
  }

  return container,tempT
end

function ClanListLayer.createScelectLightSpr( self )
  local sprSize   = cc.size(415,73)
  local lightSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_isit.png" ) 
  lightSpr : setAnchorPoint( 0, 1 )
  lightSpr : setPreferredSize( sprSize )
  return lightSpr
end

function ClanListLayer.createRghView( self )
  local Spr_Base_din = ccui.Widget:create()
  Spr_Base_din       : setContentSize( cc.size( 395, 475 ) )
  Spr_Base_din       : setPosition( 225,-55 )
  self.m_container   : addChild( Spr_Base_din, -7 )

  local Spr_Base1    = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  Spr_Base1          : setPreferredSize( cc.size( 373, 125 ) )
  Spr_Base1          : setPosition( 225,65 )
  self.m_container   : addChild( Spr_Base1, -6 )

  local Spr_Base2    = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
  Spr_Base2          : setPreferredSize( cc.size( 373, 143 ) )
  Spr_Base2          : setPosition( 225,-130 )
  self.m_container   : addChild( Spr_Base2, -6 )

  local wid_Second = 373
  local hei_Second = 430

  -- 门派信息
  local Lab_title = _G.Util : createLabel( "门派信息", FONT_SIZE+4 )
  Lab_title       : setPosition( wid_Second/2+45, hei_Second - 28 )
  Lab_title       : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
  Lab_title       : setAnchorPoint( 0.5, 1 )
  self.m_righSpr  : addChild( Lab_title ) 
  local Line_Up   = cc.Sprite : createWithSpriteFrameName( "general_titlebg.png" )
  -- Line_Up         : setPreferredSize( cc.size( wid_Second-30, 2 ) )
  Line_Up         : setPosition( wid_Second/2+45, hei_Second-40 )
  self.m_righSpr  : addChild( Line_Up,-1 )

  local myLab       = {}
  local name_myLab  = { "门派战力：", "", "门        主：", "",  "门派经验：", "" }
  local posx_Dongfu = 70
  local posY=0
  for i=1,6 do
    myLab[i] = _G.Util : createLabel( name_myLab[i], FONT_SIZE )
    if i%2~=1 then
        myLab[i] : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )  )
        posx_Dongfu=170
    else
        posx_Dongfu = 70
        posY=posY+1
    end
    myLab[i] : setAnchorPoint( 0, 1 )
    myLab[i] : setPosition( posx_Dongfu, hei_Second-38-posY*40 )
    self.m_righSpr : addChild( myLab[i] )
  end
  self.Lab_DongfuMess = {}
  for i=1,3 do
    self.Lab_DongfuMess[i] = myLab[i*2]
  end

  -- local Line_1   = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  -- Line_1         : setPreferredSize( cc.size(wid_Second-30, 2) )
  -- Line_1         : setPosition( wid_Second/2-10, hei_Second-mywidth+30 ) 
  -- self.m_righSpr : addChild( Line_1 ) 
  local Line_2   = cc.Sprite : createWithSpriteFrameName( "general_titlebg.png" )
  -- Line_2         : setPreferredSize( cc.size(wid_Second-30, 2) )
  Line_2         : setPosition( wid_Second/2+45, hei_Second-225 ) 
  self.m_righSpr : addChild( Line_2 ) 
  -- local Line_3   = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
  -- Line_3         : setPreferredSize( cc.size(wid_Second-30, 2) )
  -- Line_3         : setPosition( wid_Second/2+45, 58 ) 
  -- self.m_righSpr : addChild( Line_3 ) 

  -- 门派公告
  local myGongGao = _G.Util : createLabel( "门派公告", FONT_SIZE+4 )
  myGongGao       : setPosition( wid_Second/2+45, hei_Second-212 )
  myGongGao       : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
  myGongGao       : setAnchorPoint( 0.5, 1 )
  self.m_righSpr  : addChild( myGongGao )  

  self.Lab_GongGao = _G.Util : createLabel( "", FONT_SIZE )
  self.Lab_GongGao : setAnchorPoint( 0.5, 1 )
  self.Lab_GongGao : setPosition( wid_Second/2+35,hei_Second-260)
  self.Lab_GongGao : setLineBreakWithoutSpace(true)
  self.Lab_GongGao : setDimensions( wid_Second-40, 120)
  self.m_righSpr   : addChild( self.Lab_GongGao, 3)

  -- 创建门派、申请加入 按钮
  local function buttonCallBack( obj, eventType )
      self : touchEventCallBack( obj, eventType )
  end

  self.Btn_CreateDF = gc.CButton : create()
  self.Btn_CreateDF : loadTextures( "general_btn_gold.png" )
  --self.Btn_CreateDF : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  self.Btn_CreateDF : setAnchorPoint( 0, 1 )
  self.Btn_CreateDF : setPosition( 80, 5 )
  self.Btn_CreateDF : setTitleText( "创建门派" )
  self.Btn_CreateDF : setTitleFontName( _G.FontName.Heiti )
  self.Btn_CreateDF : setTitleFontSize( FONT_SIZE+2 )
  self.Btn_CreateDF : setTag( Tag_Btn_CreateDF )
  -- self.Btn_CreateDF : setButtonScale( 0.9 )
  self.Btn_CreateDF : addTouchEventListener( buttonCallBack )
  self.m_righSpr    : addChild( self.Btn_CreateDF )

  self.Btn_JoinInDF = gc.CButton : create()
  self.Btn_JoinInDF : loadTextures( "general_btn_lv.png" )
  self.Btn_JoinInDF : setAnchorPoint( 0, 1 )
  self.Btn_JoinInDF : setPosition( wid_Second-130, 5 )
  self.Btn_JoinInDF : setTitleText( "申请加入" )
  self.Btn_JoinInDF : setTitleFontName( _G.FontName.Heiti )
  self.Btn_JoinInDF : setTitleFontSize( FONT_SIZE+2 )
  self.Btn_JoinInDF : setTag( Tag_Btn_JoinInDF )
  -- self.Btn_JoinInDF : setButtonScale( 0.9 )
  self.Btn_JoinInDF : addTouchEventListener( buttonCallBack )
  self.m_righSpr    : addChild( self.Btn_JoinInDF )

  local mainplay = _G.GPropertyProxy : getMainPlay()
  local myclanid = mainplay :getClan()
  if myclanid == nil or myclanid == 0 then
      --无门派
  else
      self.Btn_CreateDF  : setTouchEnabled(false)
      self.Btn_CreateDF  : setGray()
      self.Btn_JoinInDF  : setTouchEnabled(false)
      self.Btn_JoinInDF  : setGray()
  end

  local guideId=_G.GGuideManager:getCurGuideId()
  if guideId==_G.Const.CONST_NEW_GUIDE_SYS_CLAN then
      local function nFun()
          _G.GGuideManager:registGuideData(1,self.Btn_JoinInDF)
          _G.GGuideManager:runNextStep()
          self.m_guide_wait_shengqing=true
          self:pageNetWorkSend(1) --默认第一页
      end
      self.m_righSpr:runAction(cc.Sequence:create(cc.DelayTime:create(0.01),cc.CallFunc:create(nFun)))
  else
      self:pageNetWorkSend(1) --默认第一页
  end
end

function ClanListLayer.changeSelectClan( self, _clanId )
  if self.m_selectClanId==_clanId then return end


  self.m_selectClanId=_clanId
  if self.m_selectClanId==0 then
      self.Btn_JoinInDF:setTouchEnabled(false)
      self.Btn_JoinInDF:setGray()

      if self.m_selectClanSpr then
          self.m_selectClanSpr:removeFromParent(true)
          self.m_selectClanSpr=nil
      end

      self:changeRghMess()
  else
      local tempWid=self.m_clanWidgetArray[_clanId]
      if tempWid then
          if self.m_selectClanSpr==nil then
              local tempSize=tempWid:getContentSize()
              self.m_selectClanSpr=self:createScelectLightSpr()
              self.m_selectClanSpr:setPosition(0,tempSize.height)
              tempWid:addChild(self.m_selectClanSpr,10)
          else
              self.m_selectClanSpr:retain()
              self.m_selectClanSpr:removeFromParent(true)
              tempWid:addChild(self.m_selectClanSpr,10)
              self.m_selectClanSpr:release()
          end
      end

      self:REQ_CLAN_ASK_CLAN(_clanId)

      if self.m_shenQingSprArray[_clanId] then
          if self.m_shenQingSprArray[_clanId]:isVisible() then
              self.Btn_JoinInDF:setTitleText("取消申请")
              if self.m_guide_wait_shengqing then
                  self.m_guide_wait_shengqing=nil
                  _G.GGuideManager:runNextStep()
              end
          else
              self.Btn_JoinInDF:setTitleText("申请加入")
          end
      end
  end
end

function ClanListLayer.changeDF_ID( self, _num, _clanId )
  print( "num对应的的门派ID：",_num,_clanId)
  self.myDF_ID[_num] = _clanId 
end

function ClanListLayer.changeRghMess( self, _data, _GongGao )
  if _data then
      for i=1,3 do
          self.Lab_DongfuMess[i] : setString( _data[i] )
          if _GongGao ~= nil then
              self.Lab_GongGao : setString( string.format( "%s%s","         ",_GongGao) )
          else
              self.Lab_GongGao : setString( "" )  
          end
      end
  else
      for i=1,3 do
          self.Lab_DongfuMess[i] : setString( "暂无" )
          self.Lab_GongGao : setString( "" )
      end
  end
end

function ClanListLayer.createCreatePanel( self )
  local m_textField = nil
  local function sure( )
      local clanName = m_textField:getString()
      local wordFilter = require("util.WordFilter")
      print("取了个门派名",clanName)
      if wordFilter:checkName(clanName) then
          local msg = REQ_CLAN_ASK_REBUILD_CLAN()
          msg :setArgs(clanName)
          _G.Network :send( msg)
      end
  end
  local function cancel(  )

  end

  local size  = cc.Director : getInstance() : getWinSize()
  local view  = require("mod.general.TipsBox")()
  local layer = view : create("",sure,cancel) 
  -- layer       : setPosition(cc.p(size.width/2,size.height/2))
  cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
  view        : setTitleLabel( "创建门派" )
  local m_creatbox = view:getMainlayer()

  local View_Size=cc.size(390,270)
  local bgSpr      = cc.Layer:create()
  bgSpr            : setPosition( -170, -125 )
  bgSpr            : setContentSize( View_Size )
  m_creatbox  : addChild(bgSpr)

  local m_mainLab = _G.Util:createLabel("创建门派需要花费".._G.Const.CONST_CLAN_CREATE_COST.."钻石",FONT_SIZE)
  -- m_mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  bgSpr         : addChild(m_mainLab)

  local m_inputLab = _G.Util:createLabel("请输入门派名称:",FONT_SIZE)
  -- m_inputLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  bgSpr         : addChild(m_inputLab)

  local m_textbgspr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" ) 
  m_textbgspr       : setPreferredSize(cc.size(135,30))
  bgSpr             : addChild(m_textbgspr)

  local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            sender :setString("")
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
          print( "进入textFieldEvent" )
          local clanName = sender : getString()
          local isstring =string.match(clanName,"%s*(.-)%s*$")--string.gsub(x, "%s+", "") 
          local isstring =string.gsub(isstring, "%s+", "") 

          local charNum  = self:getCharCountByUTF8(isstring)

          -- if charNum < 2 or #isstring < 4 then
          --     --字符个数小于3或者大于12 字节长度大于15或小于6都不符合长度需求
          --     sender : setString("")
          --     local command = CErrorBoxCommand(72)
          --     controller :sendCommand( command )
          --     return
          -- elseif #isstring%charNum == 0 and #isstring/charNum > 3 and charNum > 8 then
          --     --输入的是同种类型字符 , 中文 且字符数大于6
          --     sender : setString("")
          --     local command = CErrorBoxCommand(74)
          --     controller :sendCommand( command )
          --     return
          -- else
          -- if #isstring > 18 or charNum >6 then
          --     --字符个数大于12或字节长度大于15都不符合长度需求
          --     sender : setString("")
          --     local command = CErrorBoxCommand(74)
          --     controller :sendCommand( command )
          --     return
          -- end
      end
  end

  m_textField = ccui.TextField:create("最多六个字",_G.FontName.Heiti,FONT_SIZE)
  m_textField:setTouchEnabled(true)
  m_textField:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  m_textField:setMaxLengthEnabled(true)
  m_textField:setMaxLength(6)
  m_textField:setAnchorPoint(cc.p(0,0.5))
  bgSpr:addChild(m_textField,3) 
  m_textField : addEventListener(textFieldEvent) 

  m_mainLab      :setPosition(View_Size.width/2-30,View_Size.height-110)
  m_inputLab     :setPosition(View_Size.width/2-90,120)
  m_textField    :setPosition(cc.p(View_Size.width/2-5,120))
  m_textbgspr    :setPosition(cc.p(View_Size.width/2+120/2-5,120))

end

function ClanListLayer.getCharCountByUTF8( self, str )
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then left=left-i break end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end

function ClanListLayer.REQ_CLAN_ASL_CLANLIST( self, _page )
  print( "开始读取页数：", _page )
  local msg    = REQ_CLAN_ASL_CLANLIST()
  msg : setArgs( _page )
  _G.Network : send( msg )
end

function ClanListLayer.pageNetWorkSend( self, _pageno )
    if _pageno == nil or _pageno < 1 then return end
    print( "caocaocao" )
    local msg = REQ_CLAN_ASL_CLANLIST()
    msg :setArgs(_pageno)
    _G.Network :send( msg)
end

-- 门派信息1
function ClanListLayer.Net_CLAN_OK_CLANLIST( self, _ackMsg )
  if not self.m_pageView then
      self:createPageView()
  end

  if not self.m_msgAllPage then
      -- _ackMsg.all_pages=2
      self.m_msgAllPage=_ackMsg.all_pages

      if _ackMsg.all_pages>1 then
          self:REQ_CLAN_ASL_CLANLIST(_ackMsg.all_pages)
          if _ackMsg.all_pages>2 then
              self:REQ_CLAN_ASL_CLANLIST(2)
          end
      end

      self:resetPageNumLabel()
  end
  self.m_msgAllData[_ackMsg.page]=_ackMsg.clandata_msg

  if self.m_msgAllPage==1 then
      self.m_pageView:setTouchEnabled(false)
  end

  self:resetPageData()

  if not self.m_selectClanId then
      if #_ackMsg.clandata_msg>0 then
          self:changeSelectClan(_ackMsg.clandata_msg[1].clan_id)
      else
          self:changeSelectClan(0)
      end
  end
end

function ClanListLayer.Net_APPLIED_CLANLIST( self, _ackMsg )
  print( "得到请求申请门派", _ackMsg.is,_ackMsg.count )

	local nis = _ackMsg.is
  for i=1,_ackMsg.count do
      local clan_id=_ackMsg.clan_list[i].value
      local shenSpr=self.m_shenQingSprArray[clan_id]
      if shenSpr then
          shenSpr:setVisible(true)
      end
  end

  if nis == 0 then
    self.Btn_CreateDF : setTouchEnabled( true )
    self.Btn_CreateDF : setDefault()
    self.Btn_JoinInDF : setTouchEnabled( true )
    self.Btn_JoinInDF : setDefault()
  elseif nis == 1 then
    self.Btn_CreateDF : setTouchEnabled( false )
    self.Btn_CreateDF : setGray()
    self.Btn_JoinInDF : setTouchEnabled( false )
    self.Btn_JoinInDF : setGray()
  end

end
-- 门派信息2
function ClanListLayer.REQ_CLAN_ASK_CLAN( self, _clanId )
  local msg = REQ_CLAN_ASK_CLAN()
  msg : setArgs( _clanId )
  _G.Network : send( msg )
end

function ClanListLayer.Net_OTHER_DATA( self, _ackMsg )
  local msg = _ackMsg
	-- print(" 掌门uid          :",   msg.master_uid  )
 --  print(" 掌门名字          :",   msg.master_name )
 --  print(" 掌门名字颜色      :",   msg.master_name_color )
 --  print(" 掌门等级          :",   msg.master_lv )
 --  print(" 门派总战斗力      :",   msg.sum_power )
 --  print(" 门派贡献          :",   msg.clan_all_contribute )
 --  print(" 门派升级所需贡献   :",   msg.clan_contribute )
 --  print(" 门派公告          :",   msg.clan_broadcast  )
 --  print(" 自己的职位        :",   msg.upost )
  local data = nil
  if msg.clan_all_contribute < 0 or msg.master_lv > 14 then
      data = { msg.sum_power, msg.master_name, "等级已满" }
  else
      data = { msg.sum_power, msg.master_name, string.format( "%d%s%d",msg.clan_all_contribute,"/",msg.clan_contribute ) }
  end
  self : changeRghMess( data, msg.clan_broadcast  )

  if self.m_shenQingSprArray then
      local shenSpr=self.m_shenQingSprArray[self.m_selectClanId]
      if shenSpr then
          if shenSpr:isVisible() then
              self.Btn_JoinInDF:setTitleText("取消申请")
              if self.m_guide_wait_shengqing then
                  self.m_guide_wait_shengqing=nil
                  _G.GGuideManager:runNextStep()
              end
          else
              self.Btn_JoinInDF:setTitleText("申请加入")
          end
      end
  end
end
-- 请求创建门派
function ClanListLayer.REQ_CLAN_ASK_REBUILD_CLAN( self, _name )
  local msg = REQ_CLAN_ASK_REBUILD_CLAN()
  msg : setArgs( _name )
  _G.Network : send( msg )
end

function ClanListLayer.Net_REBUILD_CLAN( self )

  if self.m_shenQingSprArray then
      for i=1,#self.m_shenQingSprArray do
          self.m_shenQingSprArray[i]:setVisible(false)
      end
  end

  self.Btn_CreateDF : setTouchEnabled( false )
  self.Btn_CreateDF : setGray()
  self.Btn_JoinInDF : setTouchEnabled( false )
  self.Btn_JoinInDF : setGray()
end

-- 退出门派OK
function ClanListLayer.Net_OUT_CLAN( self )
end

-- 申请加入门派
function ClanListLayer.REQ_CLAN_ASK_CANCEL( self )
  if not self.m_selectClanId or self.m_selectClanId==0 then return end

  local isCreate = 0
  if self.m_shenQingSprArray[self.m_selectClanId]:isVisible()==false then
      isCreate = 1
  end
  local msg=REQ_CLAN_ASK_CANCEL()
  msg:setArgs(isCreate,self.m_selectClanId)
  _G.Network:send(msg)
end

function ClanListLayer.Net_JOIN_CLAN( self, _ackMsg )
	local ntype   = _ackMsg.type    -- 操作类型0取消| 1申请
  local clan_id = _ackMsg.clan_id -- 门派ID

  local isBool=false
  if self.m_shenQingSprArray then
      local shenSpr=self.m_shenQingSprArray[clan_id]
      if shenSpr then
          if ntype==0 then
              shenSpr:setVisible(false)
          elseif ntype==1 then
              shenSpr:setVisible(true)
              isBool=true
          end
      end
  end

  if self.m_selectClanId==clan_id then
      if isBool then
          self.Btn_JoinInDF:setTitleText("取消申请")
          if self.m_guide_wait_shengqing then
              self.m_guide_wait_shengqing=nil
              _G.GGuideManager:runNextStep()
          end
      else
          self.Btn_JoinInDF:setTitleText("申请加入")
      end
  end
end

function ClanListLayer.Net_AUDIT_SUCCESS( self )
  print( "-------申请成功-------" )
	self.Btn_CreateDF  : setTouchEnabled(false)
  self.Btn_CreateDF  : setGray()
  self.Btn_JoinInDF  : setTouchEnabled(false)
  self.Btn_JoinInDF  : setGray()

  if self.m_shenQingSprArray then
      for i=1,#self.m_shenQingSprArray do
          self.m_shenQingSprArray[i]:setVisible(false)
      end
  end
end

function ClanListLayer.unregister(self)
  if self.pMediator ~= nil then
     self.pMediator : destroy()
     self.pMediator = nil 
  end
end

function ClanListLayer.touchEventCallBack( self, obj, touchEvent )
    if touchEvent == ccui.TouchEventType.ended then
        print("   抬起  ", tag)
        -- 门派排名按下
        local nTag=obj:getTag()
        if nTag==0 then
            return
        elseif nTag==Tag_Btn_CreateDF then
            self:createCreatePanel()
        elseif nTag==Tag_Btn_JoinInDF then
            self:REQ_CLAN_ASK_CANCEL()
        else
            self:changeSelectClan(nTag)
        end
    end
end

return ClanListLayer