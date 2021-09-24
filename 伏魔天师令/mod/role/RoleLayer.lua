local RoleLayer = classGc(view,function(self,_uid,_isShowOrther)
    self.m_curRoleUid=_uid or 0
    self.m_firstUid=self.m_curRoleUid
    self.m_isShowOrther=_isShowOrther
end)

local FONT_SIZE     = 24
local DARKSKILL_TAG = 1211
local m_winSize  = cc.Director : getInstance() : getVisibleSize()

function RoleLayer.__create(self)
    self.m_container = cc.Node:create()
    self:__initPartment()
    self:__initView()
    self:__createNameAndProp()
    self:__createPlayerInfo()
    self:updateInfo()

    return self.m_container
end

function RoleLayer.__initPartment(self)
    print("self.m_curRoleUid",self.m_curRoleUid)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(self.m_curRoleUid,_G.Const.CONST_PLAYER)
    self.m_myPartner=self.m_myProperty:getWarPartner()
end

function RoleLayer.__initView(self)
    local rootBgSize = cc.size(828,476)
    self.m_bgSpr2Size = cc.size(rootBgSize.width/2-30,rootBgSize.height-11)
    self.m_rightBgSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
    self.m_rightBgSpr : setPreferredSize( self.m_bgSpr2Size )
    self.m_rightBgSpr : setPosition(rootBgSize.width/2-self.m_bgSpr2Size.width/2-5,-55)
    self.m_container: addChild(self.m_rightBgSpr)

    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_jianbian.png")
    local lineWidth=lineSpr:getContentSize().width
    lineSpr:setPreferredSize( cc.size(lineWidth,235) )
    -- lineSpr:setScaleX(0.75)
    lineSpr:setPosition( self.m_bgSpr2Size.width/2,self.m_bgSpr2Size.height-137 )
    self.m_rightBgSpr:addChild(lineSpr)
end

function RoleLayer.unregister(self)
    print("RoleLayer.unregister")
end

-- function RoleLayer.showShouHuContainer( self )
--   if self.m_ShouHuContainer ~= nil then
--       self.m_ShouHuContainer : removeFromParent(true)
--       self.m_ShouHuContainer = nil 
--   end
--   self.m_ShouHuContainer = cc.Node:create()
--   self.m_ShouHuContainer : setVisible(false)
--   self.m_ShouHuContainer : setPosition(cc.p(0,self.m_bgSpr2Size.height-50))
--   self.m_rightBgSpr      : addChild(self.m_ShouHuContainer)

--   local partnerWar=self.m_myPartner
--   if partnerWar==nil then return end
--   local lv=partnerWar:getLv()
--   local partnerId=partnerWar:getPartnerId()
--   local partnerInitCnf=_G.Cfg.partner_init[partnerId]

--   if partnerInitCnf==nil then return end
--   local iStar=partnerInitCnf.star

--     self.m_ShouHuInfoLab = {}
--     local bgSize = cc.size((self.m_bgSpr2Size.width)/2,44)
--     local posX = {20,self.m_bgSpr2Size.width/2+30}
--     for i=1,2 do
--         self.m_ShouHuInfoLab[i] = _G.Util : createLabel("等级:",FONT_SIZE-4)
--         self.m_ShouHuInfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
--         self.m_ShouHuInfoLab[i] : setPosition(posX[i],-14)
--         self.m_ShouHuInfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
--         self.m_ShouHuContainer  : addChild(self.m_ShouHuInfoLab[i],1)

--         if i==1 then
--             self.m_ShouHuInfoLab[1] : setString("资质:")
--             local starLab =_G.Util : createLabel(iStar,FONT_SIZE-4)
--             local starsize=self.m_ShouHuInfoLab[1]:getContentSize()
--             starLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
--             starLab:setAnchorPoint( cc.p(0.0,0.5) )
--             starLab:setPosition(posX[i]+starsize.width+10,-14)
--             self.m_ShouHuContainer:addChild(starLab,1) 

--             -- local titlebgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_titlebg.png")
--             -- local titleHeight=titlebgSpr:getContentSize().height
--             -- titlebgSpr:setPreferredSize(cc.size(self.m_bgSpr2Size.width+80,titleHeight))
--             -- titlebgSpr:setPosition(self.m_bgSpr2Size.width/2,-12)
--             -- self.m_ShouHuContainer : addChild(titlebgSpr)
--         else
--           local plvLab =_G.Util : createLabel(lv,FONT_SIZE-4)
--           local starsize=self.m_ShouHuInfoLab[2]:getContentSize()
--           plvLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
--           plvLab:setAnchorPoint( cc.p(0.0,0.5) )
--           plvLab:setPosition(posX[i]+starsize.width+10,-14)
--           self.m_ShouHuContainer:addChild(plvLab,1)
--         end
--     end

--     --灵妖技能
--     local m_skillLab = _G.Util : createLabel("技能:",FONT_SIZE-4)
--     m_skillLab : setAnchorPoint( cc.p(0.0,0.5) )
--     m_skillLab : setPosition(cc.p(15,-75))
--     m_skillLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
--     self.m_ShouHuContainer : addChild(m_skillLab,3)  

--     local skillArray=partnerInitCnf.all_skill or {}
--     local skillCount=partnerInitCnf.skill or 0


--   local function btn_skillCallback(sender, eventType)
--     if eventType == ccui.TouchEventType.ended then
--         print("dasdasdada")
--         local tip = require("mod.partner.PartnerTips")()
--         local tag = sender:getTag()
--         local dark = nil
--         if tag==-1 then
--             return
--         end
--         if sender:getChildByTag(DARKSKILL_TAG)~=nil then
--             dark = true
--         end
--         cc.Director:getInstance():getRunningScene():addChild(tip:createSkill(tag,sender:getWorldPosition(),dark),1000)
--     end
--   end
--     --四个灵妖技能
--     for i=1,4 do
--       local skSize = cc.size(62,62)
--       local skillButton=gc.CButton:create("general_skillBox.png")
--       skillButton:addTouchEventListener(btn_skillCallback)
--       skillButton:setPosition(107+(skSize.width+15)*(i-1),-75)
--       self.m_ShouHuContainer:addChild(skillButton)

--         if skillArray[i]~=nil then
--           local skillId = skillArray[i][1]
--           local iconString=_G.Cfg.skill[skillId].icon
--           skillButton:setTag(skillId)
--           local tempSpr=_G.ImageAsyncManager:createSkillSpr(iconString)
--           tempSpr:setPosition(skSize.width/2,skSize.height/2)
--           skillButton:addChild(tempSpr)
--           if i>skillCount then
--               tempSpr:setGray()
--               tempSpr:setTag(DARKSKILL_TAG)
--           end
--         end
--     end 
-- end

function RoleLayer.createPlayerExpContainer( self )
  if self.m_PlayerExpContainer ~= nil then
      self.m_PlayerExpContainer : removeFromParent(true)
      self.m_PlayerExpContainer = nil 
  end
  self.m_PlayerExpContainer=cc.Node:create()
  self.m_PlayerExpContainer:setPosition(self.m_bgSpr2Size.width/2,self.m_bgSpr2Size.height-210)
  self.m_rightBgSpr:addChild(self.m_PlayerExpContainer)

  local bgSpr=cc.Sprite:createWithSpriteFrameName("main_exp_2.png")
  -- bgSpr:setScaleX(1.1)
  bgSpr:setPosition(35,0)
  self.m_PlayerExpContainer:addChild(bgSpr)

  local expSpr=ccui.LoadingBar:create()
  expSpr:loadTexture("main_exp.png",ccui.TextureResType.plistType)
  -- expSpr:setScaleX(1.1)
  expSpr:setPosition(35,0.5)
  self.m_PlayerExpContainer:addChild(expSpr)

  if self.m_exp>self.m_expn then
      self.m_exp=self.m_expn
  end
  print("self.m_exp",self.m_exp,self.m_expn)

  local length=self.m_exp/self.m_expn*100
  expSpr:setPercent(length)

  local bgSprSize=bgSpr:getContentSize()
  local nameLab=_G.Util : createLabel("经验: ",FONT_SIZE-4)
  nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  nameLab:setPosition(cc.p(-bgSprSize.width/2+7,0))
  self.m_PlayerExpContainer:addChild(nameLab)

  local explabel=_G.Util:createLabel(self.m_exp.."/"..self.m_expn,17)
  explabel:setPosition(35,1)
  self.m_PlayerExpContainer:addChild(explabel)
end

function RoleLayer.createVipContainer( self )
  if self.m_VipContainer ~= nil then
      self.m_VipContainer : removeFromParent(true)
      self.m_VipContainer = nil 
  end
  self.m_VipContainer = cc.Node : create()
  self.m_VipContainer : setPosition(cc.p(self.m_bgSpr2Size.width-134,self.m_bgSpr2Size.height-73))
  self.m_rightBgSpr: addChild(self.m_VipContainer)

  local vipLab = _G.Util : createLabel("VIP : ",FONT_SIZE-4)
  vipLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  vipLab : setPosition(0,0)
  self.m_VipContainer : addChild(vipLab)

  local vipValue = self.m_myProperty: getVipLv() or 0

  local tempLab = _G.Util : createLabel(vipValue,FONT_SIZE-4)
  tempLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  tempLab : setAnchorPoint(cc.p(0,0.5))
  tempLab : setPosition( 27,0)
  self.m_VipContainer : addChild( tempLab )
end

function RoleLayer.__createPlayerInfo( self )
    if self.m_PlayerInfoContainer ~= nil then
        self.m_PlayerInfoContainer : removeFromParent(true)
        self.m_PlayerInfoContainer = nil 
    end
    self.m_PlayerInfoContainer = cc.Node : create()
    self.m_PlayerInfoContainer : setPosition(cc.p(6,self.m_bgSpr2Size.height-100))
    self.m_rightBgSpr: addChild(self.m_PlayerInfoContainer,1)

    self.m_InfoLab = {1,2,3,4}
    self.m_PlayerInfoLab = {1,2,3,4}
    local bgSize = cc.size((self.m_bgSpr2Size.width)/2,25)
    local posX = -self.m_bgSpr2Size.width/2
    local posY = bgSize.height
    for i=1,4 do
      if i % 2 == 1 then
          posX = 20
          posY = posY - 45
      else
          posX = 20+bgSize.width+10
      end

      -- local uptitlebgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_titlebg.png")
      -- -- local titleHeight=uptitlebgSpr:getContentSize().height
      -- uptitlebgSpr:setAnchorPoint( cc.p(0.0,0.5) )
      -- uptitlebgSpr:setScaleX(0.4)
      -- uptitlebgSpr:setPosition(posX+20,posY+2)
      -- self.m_PlayerInfoContainer : addChild(uptitlebgSpr)

      self.m_InfoLab[i] = _G.Util : createLabel("",FONT_SIZE-4)
      self.m_InfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      self.m_InfoLab[i] : setPosition(posX,posY)
      self.m_InfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_PlayerInfoContainer : addChild(self.m_InfoLab[i])

      self.m_PlayerInfoLab[i] = _G.Util : createLabel("",FONT_SIZE-4)
      self.m_PlayerInfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      self.m_PlayerInfoLab[i] : setPosition(posX+50,posY)
      self.m_PlayerInfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
      self.m_PlayerInfoContainer : addChild(self.m_PlayerInfoLab[i])
    end
end

function RoleLayer.__createNameAndProp( self )
    --名字－－－－－－－－－－
      self.m_playerLab = _G.Util : createLabel("",FONT_SIZE-4)
      self.m_playerLab : setAnchorPoint( cc.p(0.0,0.5) )
      self.m_playerLab : setPosition(cc.p(27,self.m_bgSpr2Size.height-73))
      self.m_playerLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_rightBgSpr: addChild(self.m_playerLab)
    --属性加成－－－－－－－－－－
    local function btn_update(sender,eventType)
      if eventType==ccui.TouchEventType.ended then
          local msg = REQ_ROLE_ATTR_ADD_REQUEST()
          msg : setArgs(self.m_curRoleUid)
          _G.Network : send(msg)
          if self.InfoNode==nil then
              self:__createPlayerAddInfo()
          else
              self.InfoNode:setVisible(true)
              self.ranklisterner:setSwallowTouches(true)
          end
      end
    end
    local action=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,255)))
    self.infoBtn = gc.CButton:create("role_infobtn.png") 
    self.infoBtn : addTouchEventListener(btn_update)
    self.infoBtn : runAction(action:clone())
    self.m_rightBgSpr : addChild(self.infoBtn)
    --属性－－－－－－－－－－

    -- local titlebgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_titlebg.png")
    -- local titleHeight=titlebgSpr:getContentSize().height
    -- titlebgSpr:setPreferredSize(cc.size(self.m_bgSpr2Size.width+80,220))
    -- titlebgSpr:setPosition(self.m_bgSpr2Size.width/2,115)
    -- self.m_rightBgSpr : addChild(titlebgSpr)

    self.m_PropLab = {1,2,3,4,5,6,7,8,9,10}
    self.m_PropSpr = {1,2,3,4,5,6,7,8,9,10}
    self.m_PropNumLab = {1,2,3,4,5,6,7,8,9,10}
    local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png","general_hit.png",
                      "general_dodge.png","general_crit.png","general_crit_res.png","general_bonus.png","general_reduc.png"}

    local bgSize = cc.size((self.m_bgSpr2Size.width)/2,40)
    local posX = 0
    local posY = 192 + bgSize.height

    for i=1,10 do
      if i % 2 == 1 then
          posX = 50
          posY = posY-(bgSize.height)
      else
          posX = 50+bgSize.width
      end

      self.m_PropLab[i] = _G.Util:createLabel("",FONT_SIZE-4)
      self.m_PropLab[i] : setAnchorPoint(cc.p(0,0.5))
      self.m_PropLab[i] : setPosition(posX,posY)
      self.m_PropLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_rightBgSpr : addChild(self.m_PropLab[i],1)

      self.m_PropNumLab[i] = _G.Util:createLabel("",FONT_SIZE-4)
      self.m_PropNumLab[i] : setAnchorPoint(cc.p(0,0.5))
      self.m_PropNumLab[i] : setPosition(posX+55,posY)
      self.m_PropNumLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
      self.m_rightBgSpr : addChild(self.m_PropNumLab[i],1)

      self.m_PropSpr[i] = cc.Sprite:createWithSpriteFrameName(prop_img[i])
      self.m_PropSpr[i] : setPosition(posX-20,posY+2)
      self.m_rightBgSpr : addChild(self.m_PropSpr[i],1)
    end
end

function RoleLayer.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.InfoNode~=nil then
            self.InfoNode:setVisible(false)
            self.ranklisterner:setSwallowTouches(false)
        end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.InfoNode:runAction(cc.Sequence:create(delay,func))
end

function RoleLayer.__createPlayerAddInfo( self )
  local NodeSize = cc.size(598,356)
  local function onTouchBegan(touch)
      print("TipsUtil remove tips")
      local location=touch:getLocation()
      local bgRect=cc.rect(m_winSize.width/2-NodeSize.width/2,m_winSize.height/2-NodeSize.height/2,
        NodeSize.width,NodeSize.height)
      local isInRect=cc.rectContainsPoint(bgRect,location)
      print("location===>",location.x,location.y)
      print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
      if isInRect then
          return true
      end
      self:delayCallFun()
      return true 
  end
  self.ranklisterner=cc.EventListenerTouchOneByOne:create()
  self.ranklisterner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
  self.ranklisterner:setSwallowTouches(true)
  
  self.InfoNode=cc.LayerColor:create(cc.c4b(0,0,0,150))
  cc.Director:getInstance():getRunningScene() :addChild(self.InfoNode,1000)
  self.InfoNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.ranklisterner,self.InfoNode)
  
  self.tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
  self.tipSpr : setPreferredSize(NodeSize)
  self.tipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
  self.InfoNode : addChild(self.tipSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(NodeSize.width/2-135, NodeSize.height-32)
  self.tipSpr : addChild(tipslogoSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(NodeSize.width/2+130, NodeSize.height-32)
  tipslogoSpr : setRotation(180)
  self.tipSpr : addChild(tipslogoSpr)

  local logoLab= _G.Util : createBorderLabel("属性加成", FONT_SIZE)
  -- logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
  logoLab : setPosition(NodeSize.width/2, NodeSize.height-32)
  self.tipSpr  : addChild(logoLab)

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")

  lineSpr : setPreferredSize(cc.size(572,288))
  lineSpr : setPosition(NodeSize.width/2,NodeSize.height/2-20)
  self.tipSpr : addChild(lineSpr)

  -- local function close(sender, eventType)
  --     if eventType==ccui.TouchEventType.ended then
  --         print("close")
  --         if self.tipSpr~=nil then
  --           self.tipSpr : removeFromParent(true)
  --           self.tipSpr = nil
  --         end
  --         if self.isTru then
  --           for i=1,10 do
  --             self:uncountdownEvent(i)
  --           end
  --         end
  --         self.ranklisterner:setSwallowTouches(false)
  --     end
  -- end
  -- local m_closeBtn=gc.CButton:create("general_close.png")
  -- m_closeBtn:setAnchorPoint(cc.p(1,1))
  -- m_closeBtn:setPosition(NodeSize.width+5,NodeSize.height+5)
  -- m_closeBtn:addTouchEventListener(close)
  -- m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
  -- self.tipSpr:addChild(m_closeBtn,1000)

  self.timeLab={1,2,3,4,5,6,7,8,9,10}
  self.NumNode={1,2,3,4,5,6,7,8,9,10}
  self.m_addNode={}
  local propStr_name  = {"攻击","破甲","命中","暴击","伤害","气血","防御","闪避","抗暴","免伤"}
  local prop_img  = {"general_att.png","general_wreck.png","general_hit.png","general_crit_res.png","general_bonus.png",
  "general_hp.png","general_def.png","general_dodge.png","general_crit.png","general_reduc.png"}
  self.infoPoX={}
  self.infoPoY={}
  local posX=-31
  local posY=NodeSize.height-120
  for i=1,10 do
    if i % 6 == 0 then
        posX = 79
        posY = posY-135
    else
        posX = posX+110
    end
    local boxSpr = cc.Sprite : createWithSpriteFrameName("beauty_skill_box.png")
    boxSpr : setPosition(posX,posY)
    self.tipSpr : addChild(boxSpr)

    local boxSize=boxSpr:getContentSize()
    infoSpr = cc.Sprite:createWithSpriteFrameName(prop_img[i])
    infoSpr : setPosition(boxSize.width/2,boxSize.height/2+10)
    infoSpr : setScale(1.6)
    boxSpr : addChild(infoSpr)

    local infoLab= _G.Util : createLabel(propStr_name[i], FONT_SIZE-4)
    -- infoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE))
    infoLab : setPosition(boxSize.width/2, 12)
    boxSpr  : addChild(infoLab)

    self.timeLab[i] = _G.Util : createLabel("00:00:00", FONT_SIZE-4)
    -- self.timeLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
    self.timeLab[i] : setPosition(boxSize.width/2, -20)
    boxSpr  : addChild(self.timeLab[i])

    self.infoPoX[i]=posX
    self.infoPoY[i]=posY
    self:updateAddNum(0,i)
  end
end

function RoleLayer.getTimeStr( self, _time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)

    if hour < 10 then hour = "0"..hour
    elseif hour < 0 then hour = "00" end

    if min < 10 then min = "0"..min
    elseif min < 0 then min = "00" end

    if second < 10 then second = "0"..second end
    local time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

function RoleLayer.updateAddNum(self,addNum,type)
  print("createPowerfulIcon====",self.m_addNode[type],addNum)
  if self.m_addNode[type]~=nil then
      self.m_addNode[type]:removeFromParent(true)
      self.m_addNode[type]=nil 
  end
  
  self.m_addNode[type]=cc.Node:create()

  local NumLab=_G.Util:createLabel(string.format("+%s%s",addNum,"%"),20)
  NumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
  NumLab:setPosition(0,0)
  self.m_addNode[type]:addChild(NumLab)

  -- local addNum=tostring(addNum)
  -- local length=string.len(addNum)
  -- 
  -- local addSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_add.png")
  -- addSpr:setAnchorPoint(cc.p(0,0.5))
  -- self.m_addNode[type] : addChild(addSpr)
  -- local sprWidth=addSpr:getContentSize().width
  -- for i=1,length do
  --     local tempSpr=cc.Sprite:createWithSpriteFrameName("general_powerno_"..string.sub(addNum,i,i)..".png")
  --     tempSpr:setAnchorPoint(cc.p(0,0.5))
  --     self.m_addNode[type] : addChild(tempSpr)

  --     local tempWidth=tempSpr:getContentSize().width
  --     tempSpr:setPosition(sprWidth,0)
  --     sprWidth=sprWidth+tempWidth
  -- end
  -- local fuhaoSpr=cc.Sprite:createWithSpriteFrameName("beauty_symbol.png")
  -- local bolWidth=fuhaoSpr:getContentSize().width
  -- fuhaoSpr:setAnchorPoint(cc.p(0,0.5))
  -- fuhaoSpr:setPosition(sprWidth,0)
  -- self.m_addNode[type] : addChild(fuhaoSpr)
  -- sprWidth=sprWidth+bolWidth

  self.m_addNode[type] : setPosition(self.infoPoX[type],self.infoPoY[type])
  self.tipSpr : addChild(self.m_addNode[type])
end

function RoleLayer.setInfoMsg( self,_data )
  if _data.count==0 then self.isTru=false return end
  self.isTru=true
  self.m_timeScheduler={}
  for k,v in pairs(_data.msg_xxx) do
    print("setInfoMsg-->",k,v.type,v.value,v.time)
    if v.type==41 then
      self : countdownEvent(6,v.time)
      self:updateAddNum(v.value/100,6)
    elseif v.type==42 then
      self : countdownEvent(1,v.time)
      self:updateAddNum(v.value/100,1)
    elseif v.type==43 then
      self : countdownEvent(7,v.time)
      self:updateAddNum(v.value/100,7)
    elseif v.type==44 then
      self : countdownEvent(2,v.time)
      self:updateAddNum(v.value/100,2)
    elseif v.type==45 then
      self : countdownEvent(3,v.time)
      self:updateAddNum(v.value/100,3)
    elseif v.type==46 then
      self : countdownEvent(8,v.time)
      self:updateAddNum(v.value/100,8)
    elseif v.type==47 then
      self : countdownEvent(4,v.time)
      self:updateAddNum(v.value/100,4)
    elseif v.type==48 then
      self : countdownEvent(9,v.time)
      self:updateAddNum(v.value/100,9)
    elseif v.type==49 then
      self : countdownEvent(5,v.time)
      self:updateAddNum(v.value/100,5)
    elseif v.type==50 then
      self : countdownEvent(10,v.time)
      self:updateAddNum(v.value/100,10)
    end
  end
end

function RoleLayer.countdownEvent( self,_type,time )
    local function local_scheduler()
        self : initCountdown(_type,time)
    end
    self.m_timeScheduler[_type] =  _G.Scheduler : schedule(local_scheduler, 1)
    self : initCountdown(_type,time)
end

function RoleLayer.uncountdownEvent( self,_type )
    print("关闭计时器",_type)
    if self.m_timeScheduler[_type] ~= nil then
        _G.Scheduler : unschedule(self.m_timeScheduler[_type] )
        self.m_timeScheduler[_type] = nil
    end
end

function RoleLayer.initCountdown(self,_type,time)
    local m_serverTime = _G.TimeUtil : getServerTimeSeconds()
    time = time - m_serverTime-1
    print("m_endTimes", time)
    -- local time = ""
    if time <= 0 then
        self : uncountdownEvent(_type)
        self.timeLab[_type] : setString("00:00:00")
    else
        time = self : getTimeStr(time)
        self.timeLab[_type]:setString(time)
    end
end

--现在的角色id
function RoleLayer.setNowPartnerId( self,_id )
    self.NowPartnerId = _id
end
function RoleLayer.getNowPartnerId( self )
    return self.NowPartnerId
end

--命令调用进来传三个数据
function RoleLayer.updateInfo(self)
    local mainplay
    if self.m_curRoleUid==0 or self.m_curRoleUid==self.m_myProperty:getUid() then
        mainplay=self.m_myProperty
    else
        mainplay=self.m_myPartner
    end
    if mainplay==nil then
      CCMessageBox("找不到伙伴缓存...","ERROR")
      return
    end

    self.m_name              = mainplay :getName()      --玩家姓名
    self.m_name_color        = mainplay :getNameColor() --名字颜色
    self.m_pro               = mainplay :getPro()       --玩家职业
    self.m_clan              = mainplay :getClan()
    self.m_clanname          = _G.Lang.LAB_N[551]
    if self.m_clan ~= nil and mainplay :getClanName()~=nil  then
        self.m_clanname      = mainplay :getClanName()  --门派名字
    end

    self.m_lv                = mainplay :getLv() or 1        --玩家等级
    self.m_power             = mainplay :getPower() or 0      --道行
    self.m_vip_lv            = mainplay :getVipLv() or 0     --玩家VIP等级
    self.m_rank              = mainplay :getRank() or 0      --竞技排名
    self.m_exp               = mainplay :getExp() or 0       --经验值
    self.m_expn              = mainplay :getExpn() or 1      --下一级需要的经验
    self.m_stata             = mainplay :getStata()          --伙伴状态
    --有背景属性 PVP
    local mainplaypvp        = mainplay :getAttr()

    self.m_hp                 = mainplaypvp :getHp() or 0         --气血值
    self.m_strong_att         = mainplaypvp :getStrongAtt() or 0  --攻击
    self.m_strong_def         = mainplaypvp :getStrongDef() or 0  --防御
    self.m_crit               = mainplaypvp :getCrit() or 0       --暴击值(万分比)
    self.m_crit_res           = mainplaypvp :getCritRes() or 0    --抗暴值(万分比)
    self.m_wreck              = mainplaypvp :getWreck() or 0      --破甲值(万分比)
    self.m_sp                 = mainplaypvp :getSp() or 0         -- {怒气}
    self.m_dodge              = mainplaypvp :getDodge() or 0      -- {躲避值}
    self.m_hit                = mainplaypvp :getHit() or 0        -- {命中值}

    self.m_bonus              = mainplaypvp :getBonus() or 0      -- {伤害率}
    self.m_reduction          = mainplaypvp :getReduction() or 0  -- {免伤率}

    if mainplay == nil or self.m_name == nil  then return end

    self:updatePanelData()
end

function RoleLayer.updatePanelData( self )
    --主角名字
    self.m_playerLab : setString(self.m_name or "")
    local labWidth=self.m_playerLab:getContentSize().width
    self.infoBtn : setPosition(50+labWidth,self.m_bgSpr2Size.height-68)
    --十个属性
    local propStr_name  = {"攻击: ","气血: ","破甲: ","防御: ","命中: ",
                             "躲闪: ","暴击: ","抗暴: ","伤害: ","免伤: "}
    local propStr_value = {self.m_strong_att,self.m_hp,self.m_wreck,self.m_strong_def,self.m_hit,
                             self.m_dodge,self.m_crit,self.m_crit_res,self.m_bonus,self.m_reduction}
    for i=1,10 do
        self.m_PropLab[i]:setString(propStr_name[i])
        self.m_PropNumLab[i]:setString(propStr_value[i])
    end
    --主角 职业 等级 门派 战功
    local proName = _G.Lang.LAB_N[31]
    if self.m_pro ~= nil then
        proName = _G.Lang.Role_ProName[self.m_pro]
        if  proName == nil then
            proName = _G.Lang.LAB_N[31]
        end
    end

    local info = {"职业: ","等级: ","门派: ","道行: "}
    local play = {proName,self.m_lv,self.m_clanname,self.m_power}
    for i=1,4 do
      self.m_InfoLab[i] : setString(info[i])
      self.m_PlayerInfoLab[i] : setString(play[i])
    end

    --vip exp 
    if self.m_VipContainer==nil then
      self:createVipContainer()
    end

    if self.m_isShowOrther then return end
    if self.m_PlayerExpContainer==nil then
      self:createPlayerExpContainer()
    end
end

function RoleLayer.changePage( self,_isPlayer )
    if self.m_PlayerInfoContainer~=nil then
        self.m_PlayerInfoContainer:setVisible(_isPlayer)
    end
    if self.m_PlayerExpContainer~=nil then
      self.m_PlayerExpContainer:setVisible(_isPlayer)
    end

    if not _isPlayer then
      if self.m_ShouHuContainer==nil then
        self:showShouHuContainer()
      end
      self.m_ShouHuContainer:setVisible(true)
    else
      if self.m_ShouHuContainer then
        self.m_ShouHuContainer:setVisible(false)
      end
    end
end

function RoleLayer.chuangeRole(self,_roleUid)
    print("RoleLayer.chuangeRole===>>>>")
    self.m_curRoleUid=_roleUid or 0

    local _isPlayer=self.m_curRoleUid==self.m_firstUid
    self:updateInfo()
    self:changePage(_isPlayer)
end

return RoleLayer