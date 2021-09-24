local ClanPanelView = classGc(view, function(self,_ortherClanId, _data2, _data3)
    self.pMediator=require("mod.clan.ClanPanelViewMediator")(self)
    self.m_ortherClanId=_ortherClanId
    self.data2    = _data2
    self.data3    = _data3
    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.isHaveClan=false
end)

local TAG_CLOSE    = 0
local TAG_LIST     = 1
local TAG_INFO     = 2
local TAG_PARTNER  = 3
local TAG_ACTIVITY = 4
local TAG_SKILL    = 5

function ClanPanelView.create(self)

    self.m_ClanPanelView  = require("mod.general.TabUpView")()
    self.m_rootLayer      = self.m_ClanPanelView:create()
    self.m_ClanPanelView  : setTitle("帮 派")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

    self:__initView()
    self:__initParams()
    return tempScene
end

function ClanPanelView.__initParams( self )
    --判断自己是否又门派
    local myclanid = self:getPlayerData("Clan")
    local tagValue = TAG_LIST
    if myclanid == nil or myclanid == 0 then
        self.isHaveClan = false
    else
        self.isHaveClan = true
        tagValue        = TAG_INFO
    end 

    local myClanid = _G.GPropertyProxy : getMainPlay() : getClan()
    print( "self.m_ortherClanId = ", self.m_ortherClanId, self.data2, myClanid )
    if (self.m_ortherClanId == nil) and (self.data2 ~= nil) and  (myClanid == nil or myClanid == 0 ) then
    -- 没有门派的时候，跳转不能进入
      print( "不能创建，返回了！" )
      -- return ClanPanelView
      self.m_rootLayer : setVisible( false )

      local function closeFun()
        local command = CErrorBoxCommand(11555)
        controller :sendCommand( command )
        -- if self.m_rootLayer == nil then return end
        -- self.m_rootLayer=nil
        cc.Director:getInstance():popScene()
        self:destroy() 
        return ClanPanelView
      end

      local delay = cc.DelayTime:create(0.1)
      local func = cc.CallFunc:create(closeFun)
      self.m_rootLayer : runAction(cc.Sequence:create(delay,func))

    else
    -- 正常创建门派
      print( "self.data2 = ",self.data2 )
      if self.m_ortherClanId~=nil then
        if self.data2 ~= nil then
          self:selectContainerByTag(self.data2 )
          self.m_ClanPanelView:selectTagByTag(self.data2)
        else
          self:selectContainerByTag(TAG_INFO)
          self.m_ClanPanelView:selectTagByTag(TAG_INFO)
        end
      else
          local guideId=_G.GGuideManager:getCurGuideId()
          if guideId==_G.Const.CONST_NEW_GUIDE_SYS_CLAN then
              if self.isHaveClan then
                  _G.GGuideManager:removeGuide()
              else
                  local closeBtn=self.m_ClanPanelView:getCloseBtn()
                  _G.GGuideManager:initGuideView(self.m_rootLayer)
                  _G.GGuideManager:registGuideData(2,closeBtn)
                  self.m_hasGuide=true
              end
              
          end
          if self.data2 ~= nil then
              self:selectContainerByTag(self.data2 )
              self.m_ClanPanelView:selectTagByTag(self.data2)
          else
              self:selectContainerByTag(tagValue)
              self.m_ClanPanelView:selectTagByTag(tagValue)
          end
          
      end
    end
    
end

function ClanPanelView.clearCurView(self)
    if self.m_curView==nil then return end

    if self.m_NowPageTag==TAG_ACTIVITY then
        self.m_curView:clean_Scheduler()
    end
    self.m_curView:unregister()
end
function ClanPanelView.unregister(self)
  if self.pMediator ~= nil then
     self.pMediator : destroy()
     self.pMediator = nil 
  end
end

function ClanPanelView.__initView(self)

  print("ClanPanelView.__initView")
  self.m_mainContainer = cc.Node:create()
  self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
  self.m_rootLayer:addChild(self.m_mainContainer)

  local function closeFun()
      self : allunregister()
      
      if self.m_rootLayer == nil then return end
      self.m_rootLayer=nil
      cc.Director:getInstance():popScene()
      self:destroy()
      local msg=REQ_CLAN_LEAVE()
      _G.Network:send(msg)

      if self.m_hasGuide then
          local command=CGuideNoticShow()
          controller:sendCommand(command)
      end

      if self.m_NowPageTag==TAG_PARTNER then
          self.m_curView:clearScheduler()
      end
  end
  local function l_btnCallBack(tag)
    print("ClanPanelView._initView >>>>> tag="..tag,self.isHaveClan)
    if self.isHaveClan then
      self : selectContainerByTag(tag)
    else
      local command = CErrorBoxCommand(11555)
      controller :sendCommand( command ) 

       return self.isHaveClan
    end
  end
  self.m_ClanPanelView:addCloseFun(closeFun)
  self.m_ClanPanelView:addTabFun(l_btnCallBack)

  local name_btn = {"列 表","总 览","成 员","活 动","技 能"}
  if self.m_ortherClanId==nil then
    for i=1,5 do
        self.m_ClanPanelView:addTabButton(name_btn[i],i)
    end
    local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_GANGS)
    
    local signArray=_G.GOpenProxy:getSysSignArray()
    if signArray[_G.Const.CONST_FUNC_OPEN_GANGS_ACTIVITY] then
        self.m_ClanPanelView:addSignSprite(4,_G.Const.CONST_FUNC_OPEN_GANGS_ACTIVITY)
        self.redpoint=true
    end
    if signArray[_G.Const.CONST_FUNC_OPEN_GANGS_SKILL] then
        self.m_ClanPanelView:addSignSprite(5,_G.Const.CONST_FUNC_OPEN_GANGS_SKILL)
    end
  else
    self.m_ClanPanelView:addTabButton(name_btn[1],1,true)
    self.m_ClanPanelView:addTabButton(name_btn[2],2)
    self.m_ClanPanelView:addTabButton(name_btn[3],3,true)
    self.m_ClanPanelView:addTabButton(name_btn[4],4,true)
    self.m_ClanPanelView:addTabButton(name_btn[5],5,true)
  end
  --五个容器五个页面
  self.m_secondNode=cc.Node:create()
  self.m_mainContainer:addChild(self.m_secondNode)
end

function ClanPanelView.chuangIconNum(self,_sysId,_number)
  if _G.Const.CONST_FUNC_OPEN_GANGS==_sysId then
    self.m_ClanPanelView:setTagIconNum(TAG_PARTNER,_number)
  end
end

function ClanPanelView.setNowPageTag(self,_data)
   self.m_NowPageTag = _data
end

function ClanPanelView.getNowPageTag(self)
   return self.m_NowPageTag
end

function ClanPanelView.allunregister( self )
  self : unregister()
  self : clearCurView()
end

function ClanPanelView.selectContainerByTag(self,_tag )
  if self.m_NowPageTag==_tag then return end

  if self.m_curView and self.m_NowPageTag==TAG_PARTNER then
      self.m_curView:clearScheduler()
  end

  self.m_secondNode:removeAllChildren(true)
  self:clearCurView()
  self:removeSpine()
  self:setNowPageTag(_tag)
  --创建面板内容
  self:initTagPanel(_tag)
end

function ClanPanelView.initTagPanel( self,_tag )
  local view = nil 
  if _tag == TAG_LIST then
      print("创建面板---门派列表")
      view = require ("mod.clan.ClanListLayer")(_tag)
  elseif _tag == TAG_INFO then
      print("创建面板---门派总览")
      view = require ("mod.clan.ClanInfoLayer")(self.m_ortherClanId)
      self.m_ortherClanId=nil
  elseif _tag == TAG_PARTNER then
      print("创建面板---门派成员")
      view = require ("mod.clan.ClanPartnerLayer")(_tag)
  elseif _tag == TAG_ACTIVITY then
      print("创建面板---门派活动", self.data3)
      view = require ("mod.clan.ClanActivityLayer")(_tag,self.data3,self.redpoint)
  elseif _tag == TAG_SKILL then
      view = require ("mod.clan.ClanSkillLayer")(_tag)      
  end

  if view == nil then return end

  self.m_curView=view
  local tempLayer=view:__create()
  self.m_secondNode:addChild(tempLayer)
  if _tag == TAG_ACTIVITY then
    self.ActivityLayer=view
  end

  if _tag==TAG_SKILL then
      view:NetworkSend()
  end

  if _tag==TAG_INFO then
      self.m_curView:NetworkSend()
  elseif _tag==TAG_ACTIVITY and self.data3==nil then
      self.m_curView:selectContainerByTag(1)
      if self.myCount and self.myCount[2] then
        self.m_curView:chuangIconNum(self.myCount[2])
      end
  elseif _tag==TAG_SKILL then
      self.m_curView:NetworkSend()
  elseif _tag == TAG_PARTNER then
      if self.myCount and self.myCount[1] then
        self.m_curView:chuangIconNum(self.myCount[1])
      end
  end
end

function ClanPanelView.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 

    if     _CharacterName == "Lv" then
        CharacterValue = mainplay : getLv()
    elseif _CharacterName == "Vip" then
        CharacterValue = mainplay : getVipLv()
    elseif _CharacterName =="Clan" then
        CharacterValue = mainplay :getClan()
    end

    return CharacterValue
end
--创建门派就调用这个 跳转到总览界面 申请加入成功也是用这个
function ClanPanelView.NetWorkReturn_changePageFromMediator( self )
    self.isHaveClan = true
    
    self.m_ClanPanelView : selectTagByTag(TAG_INFO)
    self : selectContainerByTag(TAG_INFO)
end
--退出门派就调用这个 跳转到门派列表界面
function ClanPanelView.NetWorkReturn_OutClan( self ) --退出门派成功协议
    self.isHaveClan = false
    
    self.m_ClanPanelView : selectTagByTag(TAG_LIST)
    self : selectContainerByTag(TAG_LIST)
end

function ClanPanelView.Net_CLAN_CORNER( self, _ackMsg )
  local msg = _ackMsg
  print( "角标数量：", msg.count )
  self.myCount = {}
  for i=1,msg.count do
    print( "编号,数量：", msg.data[i].idx, msg.data[i].num )
    self.myCount[msg.data[i].idx] = msg.data[i].num
  end
  self : addJiaoBiao( msg )
end

function ClanPanelView.addJiaoBiao( self, _ackMsg )
  local msg    = _ackMsg

  local myTag = { TAG_PARTNER, TAG_ACTIVITY }
  print( "创建角标!" )
  for i=1,msg.count do
      print( "正在创建！",i,myTag[i],msg.data[i].num)
      -- msg.data[i].num = 3
      self.m_ClanPanelView:setTagIconNum(myTag[msg.data[i].idx],msg.data[i].num)
  end
  
  for i=1,msg.count do
    if msg.data[i].idx == 2 then
      if self.m_NowPageTag==TAG_ACTIVITY then
        print( "TAG_ACTIVITY ===>>>", msg.data[i].num )
        self.m_curView:chuangIconNum(msg.data[i].num)
      end
    end
    if msg.data[i].idx == 1 then
      if self.m_NowPageTag==TAG_PARTNER then
        print( "TAG_PARTNER ===>>>", msg.data[i].num )
        self.m_curView:chuangIconNum(msg.data[i].num)
      end
    end
  end
end

function ClanPanelView.removeSpine( self )
    print("ClanPanelView.removeSpine")
    if self.ActivityLayer==nil then return end
    self.ActivityLayer:removeSpine()
end

return ClanPanelView

