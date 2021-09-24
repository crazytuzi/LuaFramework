local EquipView = classGc(view,function( self,_pageno, _uid )
    self.OpenPageNo = _pageno
    self.m_curRoleUid = _uid or 0
    self.m_myUid=self.m_curRoleUid
	  self.m_winSize=cc.Director:getInstance():getWinSize()
    self.pMediator = require("mod.equip.EquipViewMediator")()
    self.pMediator : setView(self)

    self.m_myProperty=_G.GPropertyProxy:getMainPlay()
    self.m_myPartner=self.m_myProperty:getWarPartner()

    print("EquipLayer.__initParmen===>",self.m_myPartner)
    if self.m_myPartner==nil then
      self.m_curRoleUid=0
    else
      self.m_partnerIdx=self.m_myPartner:getPartner_idx()
      self.m_partnerId=self.m_myPartner:getPartnerId() or 0
      if self.m_curRoleUid~=0 then
        self.m_curRoleUid=self.m_partnerIdx
      end
      print("有出战的伙伴  idx=",self.m_partnerIdx)
    end

    self.PartGemdata = nil 
end)

local  TAGBTN_STRENGTH  = 1
local  TAGBTN_SHENPING  = 2
local  TAGBTN_XIANQIAN  = 3
local  TAGBTN_FUMO      = 4
local  TAGBTN_FENJIE    = 5

local MAX_BSLV  = _G.Const.CONST_MAKE_PEAR_LV
local FONT_SIZE = 24

local SYSID_ARRAY=
{
 [TAGBTN_STRENGTH]=_G.Const.CONST_FUNC_OPEN_ROLE_EQUIP,
 [TAGBTN_SHENPING]=_G.Const.CONST_FUNC_OPEN_SMITHY_QUALITY,
 [TAGBTN_XIANQIAN]=_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY,
 [TAGBTN_FUMO]=_G.Const.CONST_FUNC_OPEN_SMITHY_ENCHANTS,
 [TAGBTN_FENJIE]=_G.Const.CONST_FUNC_OPEN_SMITHY_RESOLVE,
}

function EquipView.create( self )
	self.m_EquipView  = require("mod.general.TabUpView")()
	self.m_rootLayer = self.m_EquipView:create("饰品")

  local tempScene=cc.Scene:create()
  tempScene:addChild(self.m_rootLayer)

	self:_initView()
	self:initParams()

	return tempScene
end

function EquipView.unregister(self)
    print("EquipStrengthLayer.unregister")
    if self.pMediator ~= nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
end

function EquipView._initView( self )
	self.m_mainContainer = cc.Node:create()
	self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_rootLayer:addChild(self.m_mainContainer)

  neikuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
  neikuangSpr:setContentSize(cc.size(828,476))
  neikuangSpr:setPosition(2,-55)
  self.m_mainContainer:addChild(neikuangSpr)

	local function closeFun()
		self:closeWindow()
	end

	local function tabBtnCallBack(tag)
		print("EquipView._initView tabBtnCallBack>>>>> tag="..tag)
    local sysId=SYSID_ARRAY[tag]
    if _G.GOpenProxy:showSysNoOpenTips(sysId) then return false end
		self:selectContainerByTag(tag)
		return true
	end
	self.m_EquipView:addCloseFun(closeFun)
	self.m_EquipView:addTabFun(tabBtnCallBack)

	self.m_EquipView:addTabButton("饰  品",TAGBTN_STRENGTH)
  self.m_EquipView:addTabButton("镶  嵌",TAGBTN_XIANQIAN)
	self.m_EquipView:addTabButton("升  品",TAGBTN_SHENPING)
	self.m_EquipView:addTabButton("附  魔",TAGBTN_FUMO)
	self.m_EquipView:addTabButton("分  解",TAGBTN_FENJIE)

  local signArray=_G.GOpenProxy:getSysSignArray()
  if signArray[_G.Const.CONST_FUNC_OPEN_ROLE_EQUIP] then
      self.m_EquipView:addSignSprite(TAGBTN_STRENGTH,_G.Const.CONST_FUNC_OPEN_ROLE_EQUIP)
  end
  if signArray[_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY] then
      self.m_EquipView:addSignSprite(TAGBTN_XIANQIAN,_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY)
  end
  if signArray[_G.Const.CONST_FUNC_OPEN_SMITHY_QUALITY] then
      self.m_EquipView:addSignSprite(TAGBTN_SHENPING,_G.Const.CONST_FUNC_OPEN_SMITHY_QUALITY)
  end
  if signArray[_G.Const.CONST_FUNC_OPEN_SMITHY_ENCHANTS] then
      self.m_EquipView:addSignSprite(TAGBTN_FUMO,_G.Const.CONST_FUNC_OPEN_SMITHY_ENCHANTS)
  end
  
	--五个容器五个页面
	self.m_tagcontainer = {1,3,2,4,5}
  self.m_tagPanel     = {}
  self.m_tagPanelClass= {}   

	for i=1,5 do
		  self.m_tagcontainer[i] = cc.Node:create()
    	self.m_mainContainer   : addChild(self.m_tagcontainer[i])
	end

  local guideId=_G.GGuideManager:getCurGuideId()
  if guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP then
      local closeBtn=self.m_EquipView:getCloseBtn()
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(2,closeBtn)
      self.m_guideTab=TAGBTN_STRENGTH
  elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_GEM then
      local tabBtn=self.m_EquipView:getTabBtnByTag(TAGBTN_XIANQIAN) 
      local closeBtn=self.m_EquipView:getCloseBtn()
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(1,tabBtn)
      _G.GGuideManager:registGuideData(4,closeBtn)
      _G.GGuideManager:runNextStep()
      self.m_guideTab=TAGBTN_XIANQIAN
      self.m_guide_isgogem=true
      self.m_guide_init_gemview=true
  elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP_FUMO then
      local tabBtn=self.m_EquipView:getTabBtnByTag(TAGBTN_FUMO) 
      local closeBtn=self.m_EquipView:getCloseBtn()
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(1,tabBtn)
      -- _G.GGuideManager:registGuideData(5,closeBtn)
      _G.GGuideManager:runNextStep()
      self.m_guide_isgofumo=true
      self.m_guideTab=TAGBTN_FUMO
  elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP_RISE then
      local tabBtn=self.m_EquipView:getTabBtnByTag(TAGBTN_SHENPING) 
      local closeBtn=self.m_EquipView:getCloseBtn()
      _G.GGuideManager:initGuideView(self.m_rootLayer)
      _G.GGuideManager:registGuideData(1,tabBtn)
      -- _G.GGuideManager:registGuideData(5,closeBtn)
      _G.GGuideManager:runNextStep()
      self.m_guide_isgoshengpin=true
      self.m_guideTab=TAGBTN_SHENPING
  end
  if self.m_guideTab~=nil then
      local command=CGuideNoticHide()
      controller:sendCommand(command)
  end

	--左边的人物 装备 战斗力什么的
	self : cretePalyerPanel()
end

function EquipView.cretePalyerPanel( self )
	self.m_palyerContainer = cc.Node:create()
	self.m_mainContainer : addChild(self.m_palyerContainer)
	
	self.m_rootBgSize      = cc.size(828,476)
	self.m_leftBgSprSize   = cc.size(self.m_rootBgSize.width/2,self.m_rootBgSize.height)
	self.m_leftBgSpr       = cc.Node:create()
	self.m_leftBgSpr       : setContentSize( self.m_leftBgSprSize )
	self.m_palyerContainer : addChild(self.m_leftBgSpr)
	self.m_leftBgSpr       : setPosition(-self.m_leftBgSprSize.width+15,-self.m_leftBgSprSize.height/2-120)

	local roleBgSpr     = cc.Sprite:createWithSpriteFrameName("general_rolebg2.png")
  roleBgSpr : setPosition(self.m_leftBgSprSize.width/2,self.m_leftBgSprSize.height/2+50)
  self.m_leftBgSpr : addChild(roleBgSpr) 

  self:AttrFryNode(self.m_leftBgSprSize,self.m_leftBgSpr)
	self:__showRoleSpine()
	self:__showEquip()
  local _powerful = self : getPlayerData("Power")
  self:createPowerfulIcon(_powerful)
end

function EquipView.__showRoleSpine(self)
    if self.m_skeleton~=nil then
        self.m_skeleton:removeFromParent(true)
        self.m_skeleton=nil
    end

    self.m_wuqiSke,self.m_featherSke=nil
    if self.m_curRoleUid==0 then
        self.m_skeleton,self.m_wuqiSke,self.m_featherSke=_G.SpineManager.createMainPlayer(0.7)
    else
        self.m_skeleton=_G.SpineManager.createPartner(self.m_partnerId)
        if self.m_skeleton then
            local data = _G.Cfg.partner_init[self.m_partnerId]
            local showscale = data.showscale2/data.scale
            self.m_skeleton:setScale(showscale)
        end
    end
    if self.m_skeleton~=nil then
        self.m_skeleton:setAnimation(0,"idle",true)
        if self.m_wuqiSke~=nil then
            self.m_wuqiSke:setAnimation(0,"idle",true)
        end

        if self.m_featherSke~=nil then
            self.m_featherSke:setAnimation(0,string.format("idle_%d",self.m_myProperty:getSkinArmor()),true)
        end
        
        if self.m_partnerId == 13101 and self.m_curRoleUid~=0 then
          -- 压龙大仙
          self.m_skeleton : setPosition( self.m_leftBgSprSize.width/2+40, 115 )
        else
          self.m_skeleton:setPosition(cc.p(self.m_leftBgSprSize.width/2,115))
        end
        self.m_leftBgSpr:addChild(self.m_skeleton,10)
    end

    if self.shadow==nil then
        self.shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
        self.shadow:setPosition(cc.p(self.m_leftBgSprSize.width/2,120))
        self.m_leftBgSpr:addChild(self.shadow)
    end
end

function EquipView.__showEquip( self )
  self.m_equipBtn    = {}
  self.m_equipsixSpr = {}
  self.m_equipIndex  = {}
  self.equipBgSpr    = {}
  -- self.m_equipArrSpr = {} --装备可卡强化箭头图片
  self.m_equipGemSpr = {} --装备可卡强化宝石图片
  self.VipArrSpr     = {} --是否vip

  local function l_btnCallBack(sender, eventType)
        self : onEquipCallBack(sender, eventType)
  end

  local potY = 0  
  local potX = 0
  local action=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,150),cc.FadeTo:create(0.5,255)))
  for i=1,6 do
      self.m_equipBtn[i] = gc.CButton:create()--ccui.Button : create()
      self.m_equipBtn[i] : loadTextures("general_tubiaokuan.png") 
      self.m_equipBtn[i] : setTag(i)
      self.m_equipBtn[i] : addTouchEventListener(l_btnCallBack)
      self.m_leftBgSpr   : addChild(self.m_equipBtn[i],10)

      local szImg        = "role_ui_equipbg"..i..".png"
      self.equipBgSpr[i] = cc.Sprite:createWithSpriteFrameName(szImg)
      self.m_equipBtn[i] : addChild(self.equipBgSpr[i])
      local tempSize     = self.m_equipBtn[i] : getContentSize()
      self.equipBgSpr[i] : setPosition(tempSize.width/2,tempSize.height/2)
     
      -- self.m_equipArrSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tip_up.png")
      -- self.m_equipArrSpr[i] : setVisible( false )
      -- self.m_equipArrSpr[i] : setPosition(60,15)
      -- self.m_equipArrSpr[i] : runAction(action:clone())
      -- self.m_equipBtn[i]    : addChild(self.m_equipArrSpr[i],4) 

      self.VipArrSpr[i] = cc.Sprite:createWithSpriteFrameName("general_vip.png")
      self.VipArrSpr[i] : setVisible( false )
      self.VipArrSpr[i] : setPosition(58,10)
      self.VipArrSpr[i] : setScale(0.6)
      self.VipArrSpr[i] : runAction(action:clone())
      self.m_equipBtn[i]    : addChild(self.VipArrSpr[i],4) 

      self.m_equipGemSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tip_gem.png")
      self.m_equipGemSpr[i] : setVisible( false )
      self.m_equipGemSpr[i] : setPosition(60,60)
      self.m_equipGemSpr[i] : runAction(action:clone())
      self.m_equipBtn[i]    : addChild(self.m_equipGemSpr[i],4) 

      if  i<=3 then
          potX = self.m_leftBgSprSize.width/2 - 150
          potY = self.m_leftBgSprSize.height - 80 - 105*(i-1)
      else
          potX = self.m_leftBgSprSize.width/2 + 150
          potY = self.m_leftBgSprSize.height - 80 - 105*(i-4)
      end

      self.m_equipBtn[i]   : setPosition(potX,potY)

      if i == 1 then
          self : __showEquipEffect(self.m_equipBtn[i])
      end
  end
end

function EquipView.playerpower(self)
  print("战力更新")
  if self.m_curRoleUid==0 or self.m_isShowOrther then
      mainplay=self.m_myProperty
  else
      mainplay=self.m_myPartner
  end
  local powerful = mainplay:getPowerful()
  self:createPowerfulIcon(powerful)
end

function EquipView.createPowerfulIcon(self,_powerful)
    if self.PowerContainer ~= nil then
        self.PowerContainer : removeFromParent(true)
        self.PowerContainer = nil 
    end
    print("createPowerfulIcon====",_powerful)
    if _powerful == nil or _powerful == 0 then 
        return
    end

    local powerful      = tostring( _powerful )
    local length        = string.len( powerful)
    self.PowerContainer = cc.Node : create()

    local m_powerSpr     = cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    m_powerSpr           : setPosition(60,0)
    self.PowerContainer  : addChild(m_powerSpr)
    -- local m_powerSprSize = m_powerSpr : getContentSize()
 
    local tempLab=_G.Util:createBorderLabel(string.format("战力:%d",powerful),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- tempLab:setAnchorPoint(cc.p(0,0.5))
    tempLab:setPosition(60,0)
    self.PowerContainer : addChild(tempLab)

    self.PowerContainer : setPosition(self.m_leftBgSprSize.width/2-60, self.m_leftBgSprSize.height+15)
    self.m_leftBgSpr    : addChild(self.PowerContainer)
end

function EquipView.onEquipCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag=sender:getTag()
      print("六装备按钮回调====",btn_tag,self.m_equipIndex[btn_tag],self.NowPageId)
    
      if self.NowPageId==TAGBTN_STRENGTH then 
        local Position=sender:getWorldPosition()
        if btn_tag<=0 then return end

        local scelectData = nil 
        for k,v in pairs(self.m_equipList) do
            print("v.index",k,v.index)
            if self.m_equipIndex[btn_tag] == v.index then
               scelectData = v
                print("dsdasdsadsad",v.goods_id,v.index)
                break
            end 
        end
        if scelectData == nil then return end

        local partnerIndex=nil
        self.m_tipsShowType=_G.Const.CONST_GOODS_SITE_INLAID
        if self.m_curRoleUid~=self.m_myUid then
            local myUid=self.m_myUid
            if self.m_myUid==0 then
                myUid=self.m_myProperty:getUid()
            end
            partnerIndex=string.format("%d%d",myUid,self.m_partnerIdx)

            self.m_tipsShowType=nil
        end
        
        local temp=_G.TipsUtil:create(scelectData,self.m_tipsShowType,Position,self.m_curRoleUid,nil,partnerIndex)
        cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      end

      local m_nowPageTag = self : getNowPageId()
      if m_nowPageTag == TAGBTN_FUMO or m_nowPageTag == TAGBTN_SHENPING then
         if self.m_equipIndex[btn_tag]~=nil and self.m_equipIndex[btn_tag]==0 then
            local command=CErrorBoxCommand(7996)
            controller:sendCommand(command)
            return 
         end
      end

      if self.m_guideTab~=nil then
          if m_nowPageTag==TAGBTN_XIANQIAN then
              print("FFFFFFFFFFF======= 1>>")
              if self.m_guide_select_equip==btn_tag then
                  print("FFFFFFFFFFF======= 2>>")
                  self.m_guide_select_equip=nil
                  _G.GGuideManager:runNextStep()
                  -- self.m_tagPanelClass[TAGBTN_XIANQIAN].m_guide_touch_gem=true
              -- elseif self.m_tagPanelClass[TAGBTN_XIANQIAN].m_guide_touch_gem
              --     or self.m_tagPanelClass[TAGBTN_XIANQIAN].m_guide_touch_add
              --     and btn_tag~=1 then
              --     print("FFFFFFFFFFF======= 3>>")
              --     self.m_guide_select_equip=1
              --     _G.GGuideManager:runThisStep(2)
              --     self.m_tagPanelClass[TAGBTN_XIANQIAN].m_guide_touch_gem=nil
              --     self.m_tagPanelClass[TAGBTN_XIANQIAN].m_guide_touch_add=nil
              end
          end
      end
      
      self : setNowGoodsIndex(self.m_equipIndex[btn_tag] or 0)
      self : setNowGoodsPart( btn_tag )
      self : __showEquipEffect(sender)
      self : EquipmentSystemCommandSend()
    end
end

function EquipView.initParams( self )
	--初始化数据 默认的页面 默认的人物id
    print("EquipView.initParams",self.OpenPageNo)

    if self.OpenPageNo ~= nil   then
        self : setNowPageId(self.OpenPageNo)
    else
        self : setNowPageId(TAGBTN_STRENGTH) 
    end

    self : setNowGoodsIndex(0)  --默认第一个装备
    self : setNowGoodsPart(1)   --默认第一个装备部分

    -- self : REQ_MAKE_PART_ALL() --发协议请求 显示小箭头以及宝石提示

    local function delayFun1()
      self.m_EquipView : selectTagByTag(self : getNowPageId())
      self : selectContainerByTag(self : getNowPageId())
    end
    local act1=cc.DelayTime:create(0.1)
    local act2=cc.CallFunc:create(delayFun1)
    self.m_mainContainer:runAction(cc.Sequence:create(act1,act2))

  	--默认人物的装备以及战斗力
  	self:updateEquip()  
    self:updateArrAndGemSpr()
end

function EquipView.selectContainerByTag(self,_tag)
	for i=1,5 do
		if i == _tag then
			self.m_tagcontainer[i] : setVisible(true)
		else
			self.m_tagcontainer[i] : setVisible(false)
		end
	end

	self : setNowPageId(_tag)
	--创建面板内容
	self : initTagPanel(_tag)

  --如果是附魔页面就判断 选中的装备位置有没有装备 没有看下一个部位 知道有 就换成那一个 如果都没有就直接发
  self : JudgeIsFuMoOrShenPingPanel(_tag)

	self : EquipmentSystemCommandSend()
  if _tag==TAGBTN_STRENGTH then
    if self.m_tagPanel[_tag]~=nil then
        local command = CProxyUpdataCommand()
        controller :sendCommand( command) 
    end
  end

  if _tag == TAGBTN_FENJIE then
     self.m_leftBgSpr : setVisible(false)
  else
     self.m_leftBgSpr : setVisible(true)
  end

  if _tag~=TAGBTN_FUMO and _tag~=TAGBTN_SHENPING then
      self : setShowEffectSpr()
  end

  if self.m_guideTab~=nil then
    if _tag==self.m_guideTab then
        if self.m_guideTab==TAGBTN_XIANQIAN then
            _G.GGuideManager:showGuideByStep(2)
            _G.GGuideManager:showGuideByStep(3)

            if _G.GGuideManager:getCurStep()~=5 then
                if self.m_guide_init_gemview then
                    self.m_guide_init_gemview=nil
                    _G.GGuideManager:registGuideData(2,self.m_equipBtn[1])
                    _G.GGuideManager:runNextStep()
                    self.m_guide_select_equip=1
                end
            end
        elseif self.m_guideTab==TAGBTN_FUMO or self.m_guideTab==TAGBTN_SHENPING then
              if self.m_guide_isgofumo then
                  self.m_guide_isgofumo=nil
                  _G.GGuideManager:runNextStep()
              elseif self.m_guide_isgoshengpin then
                  self.m_guide_isgoshengpin=nil
                  _G.GGuideManager:runNextStep()
              else
                  _G.GGuideManager:showGuideByStep(2)
              end
        else
            _G.GGuideManager:showGuideByStep(1)
        end
    else
        if self.m_guideTab==TAGBTN_XIANQIAN then
            _G.GGuideManager:hideGuideByStep(2)
            _G.GGuideManager:hideGuideByStep(3)
        elseif self.m_guideTab==TAGBTN_FUMO or self.m_guideTab==TAGBTN_SHENPING then
            _G.GGuideManager:hideGuideByStep(2)
        else
            _G.GGuideManager:hideGuideByStep(1)
        end
    end
  end
end
function EquipView.JudgeIsFuMoOrShenPingPanel( self,_pageno )
   if _pageno == TAGBTN_FUMO or _pageno == TAGBTN_SHENPING then
      local index=self:getNowGoodsIndex()--获取当前物品index
      print("--JudgeIsFuMoOrShenPingPanel--",index)
      if index==0 then 
          for i=1,6 do
             if self.m_equipIndex[i]~=nil and self.m_equipIndex[i]~=0 then
                self : setNowGoodsIndex(self.m_equipIndex[i])
                self : setNowGoodsPart(i)
                self : __showEquipEffect(self.m_equipBtn[i])
                break
             end
          end
      end
   end
end

function EquipView.initTagPanel(self,_tag)
	if self.m_tagPanel[_tag] == nil then
		--在这里创建自己面板的的东西
		local view = nil 
    
		if _tag == TAGBTN_STRENGTH then
			print("创建穿戴面板")
			view = require "mod.equip.EquipBagLayer"(self.m_curRoleUid)
      self.pMediator:setBagView(view)
		elseif _tag == TAGBTN_SHENPING then
      print("创建升品面板")
      view = require "mod.equip.EquipShenPingLayer"(self.m_curRoleUid)
      view.m_isGuide=self.m_guide_isgoshengpin
		elseif _tag == TAGBTN_XIANQIAN then
      print("创建镶嵌面板")
      view = require "mod.equip.EquipGemLayer"(self.m_curRoleUid)      
      view.m_isGuide=self.m_guide_isgogem
		elseif _tag == TAGBTN_FUMO then
      print("创建附魔面板")
      view = require "mod.equip.EquipFuMoLayer"(self.m_curRoleUid)         
      view.m_isGuide=self.m_guide_isgofumo
		elseif _tag == TAGBTN_FENJIE then
      print("创建分解面板")
      view = require "mod.equip.EquipFenJieLayer"() 
		end
		if view == nil then return end
		self.m_tagPanelClass[_tag] = view
    self.m_tagPanel[_tag]      = view : __create ()

    self.m_tagcontainer[_tag] : addChild(self.m_tagPanel[_tag])
	end
end

function EquipView.delTagPanelByType( self,_tag )
  if self.m_tagPanelClass[_tag] ~= nil then
     self.m_tagPanelClass[_tag] = nil 
  end

  if self.m_tagPanel[_tag] ~= nil then
     self.m_tagPanel[_tag] : removeFromParent(true)
     self.m_tagPanel[_tag] = nil 
  end
end

function EquipView.closeWindow( self )
	if self.m_rootLayer == nil then return end
  self.m_rootLayer=nil
	--注销各个子页面得mediator
	self : allunregister()

	cc.Director:getInstance():popScene() 
	self:destroy()

  if self.m_guideTab~=nil then
      local command=CGuideNoticShow()
      controller:sendCommand(command)
  end
end

function EquipView.allunregister( self )
  self : unregister()
	for _tag=1,5 do
		if self.m_tagPanelClass[_tag] ~= nil then
			self.m_tagPanelClass[_tag] : unregister()
		end
	end
end

function EquipView.setNowPageId( self,_id )
    self.NowPageId = _id
end
function EquipView.getNowPageId( self )
    return self.NowPageId
end
--现在的物品框index
function EquipView.setNowGoodsIndex( self,_id )
    self.NowGoodsIndex = _id
end
function EquipView.getNowGoodsIndex( self )
    return self.NowGoodsIndex
end
--现在的物品当前部位
function EquipView.setNowGoodsPart( self,_id )
    self.NowGoodsPart = _id
end
function EquipView.getNowGoodsPart( self )
    return self.NowGoodsPart
end
--保存部位的镶嵌数据
function EquipView.setPartGemdata( self,_data )
    self.PartGemdata = _data
end
function EquipView.getPartGemdata( self )
    return self.PartGemdata
end

function EquipView.EquipmentSystemCommandSend( self )
    print("EquipView.EquipmentSystemCommandSend-----")
    local data = {}
    data.nowPageId     = self : getNowPageId()    --获取当前页面id 
    data.nowPartnerId  = self.m_curRoleUid
    data.nowGoodsIndex = self : getNowGoodsIndex()--获取当前物品index
    data.nowGoodsPart  = self : getNowGoodsPart() or 0 --获取当前部位
    data.nowPartGem    = self : getPartGemdata()  --获取当前部位的镶嵌数据
  
    local _Command = EquipmentsViewCommand(data)
    controller:sendCommand(_Command)
end

function EquipView.REQ_MAKE_PART_ALL( self )
    local msg = REQ_MAKE_PART_ALL()
    msg :setArgs(self.m_curRoleUid)
    _G.Network :send( msg)
end

function EquipView.updateArrAndGemSpr(self)
  local _data
  if self.m_curRoleUid==0 then
    _data=self.m_myProperty:getEquipPartListBySort()
  else
    _data=self.m_myPartner:getEquipPartListBySort() or {}
  end
  local _count=#_data
  print("EquipView.updateArrAndGemSpr",_count)
   if _count<=0 then return end

   for i=1,6 do
      self.VipArrSpr[i]     : setVisible(false)
      -- self.m_equipArrSpr[i] : setVisible(false)
      self.m_equipGemSpr[i] : setVisible(false)
   end

  --强化小箭头
  local addlv = 0 
  local m_vip = self : getPlayerData("Vip")
  local m_lv  = self : getPlayerData("Lv")
  local vipnode = _G.Cfg.vip[m_vip]
  if vipnode ~= nil then
      addlv = vipnode.tim_exit12
  end

  local openGem = _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY,true)
    for i=1,_count do
      --强化箭头显示
      local onePartData = _data[i]
      if onePartData == nil then return end

      local no = _G.Const.kEquipPosByType[onePartData.type_sub] or 1

      if onePartData.lv < m_lv + addlv then
          -- self.m_equipArrSpr[no] : setVisible(true)
          if addlv>0 and onePartData.lv>=m_lv then
            self.VipArrSpr[no] : setVisible(true)
            -- self.m_equipArrSpr[no] : setPosition(60,28)
          else
            self.VipArrSpr[no] : setVisible(false)
            -- self.m_equipArrSpr[no] : setPosition(60,15)
          end
      else
          self.VipArrSpr[no] : setVisible(false)
          -- self.m_equipArrSpr[no] : setVisible(false)
          -- self.m_equipArrSpr[no] : setPosition(60,15)
      end
      --宝石镶嵌显示
      local isHaveGem = false
      if openGem==false then
        isHaveGem = self : checkIsHaveGem(onePartData)
      end
      self.m_equipGemSpr[no] : setVisible(isHaveGem)
    end

   --镶嵌 传输给镶嵌界面用的
    self : setPartGemdata(_data)
end

function EquipView.checkIsHaveGem( self,_data )
  local isTrue = false
  local m_oneData = _data.gem_xxx

  if m_oneData == nil then return end

  for i,part in pairs(m_oneData) do
     local gemtype  = part.type
     local gemid    = part.pearl_id
     local isInsert = true
     print("EquipView.checkIsHaveGem 镶嵌数据===",i,gemtype,gemid)
     if gemid == 0 then
        --通过判断类型 看有没有宝石在背包 有就给true
        isTrue = self : getGemCountByType(gemtype)
        if isTrue then break end 
     else
        --看一下有没有下一级的宝石在背包 有就给true
        isTrue = self : getGemCountById(gemid)
        if isTrue then break end 
     end
  end

  return isTrue
end

function EquipView.getGemCountById(self,_id)
  local data = _G.GBagProxy : getGemstoneList()
  local node = _G.Cfg.goods[_id]
  if node == nil then return false end
  local next_gemId = node.d.as2 or 0  

  -- if data ~= nil then
  --     for k,v in pairs(data) do
  --        local id = v.goods_id 
  --        if id == next_gemId then
  --           print("EquipView getGemCountById 有宝石勒",_id,id,next_gemId)
  --           return true
  --        end
  --     end
  -- end
  self.sum = 0 
  local isTrue = self : getGemById(_id)
  print("true",isTrue)
  return isTrue
end

function EquipView.getGemById(self,_id)
  print("当前宝石id",_id)
  local yushu = math.fmod(_id,10)
  print("当前宝石等级",yushu,MAX_BSLV)
  if yushu >= MAX_BSLV then return false end 
  local data = _G.GBagProxy : getGemstoneList()
  if data ~= nil then
    for k,v in pairs(data) do
      local goodId = data[k].goods_id
      print("goodId",goodId)
      local count  = 0 
      local bsdj = math.fmod(goodId,10)
      if bsdj <= yushu then
        if math.floor(_id/1000) == math.floor(goodId/1000) then
          count = data[k].goods_num
          print("goodId",goodId,count,bsdj)
          self.sum = self.sum + count*3^(bsdj-1)
        end
      end
    end
  end

  local xCount = math.floor(self.sum/(2*3^(yushu-1)))
  print("当前背包拥有升级数",self.sum,xCount)
  if xCount > 0 then
    return true
  else
    return false
  end
end

function EquipView.getGemCountByType(self,_type)
  local data = _G.GBagProxy : getGemstoneList()
  if data ~= nil then
      for k,v in pairs(data) do
         local id = v.goods_id 
         local node = _G.Cfg.goods[id]
         if node ~= nil and _type == node.type_sub  then
            print("EquipView getGemCountByType 有宝石勒")
            return true
         end
      end
  end
  return false
end

function EquipView.delscelecteffectFromCommand( self )
    if self.effects_selectSpr ~= nil then
        self.effects_selectSpr : setVisible(false)
    end
end

function EquipView.setShowEffectSpr( self )
    if self.effects_selectSpr ~= nil then
        self.effects_selectSpr : setVisible(true)
    end
end

function EquipView.updateEquip( self )
    local mainplay = nil
    print("EquipView.updateEquip------>")

    if self.m_curRoleUid==0 then
        mainplay=self.m_myProperty
    else
        local index=tostring(self.m_myProperty:getUid())..tostring(self.m_curRoleUid)
        mainplay=_G.GPropertyProxy:getOneByUid(index,_G.Const.CONST_PARTNER)
    end

    if mainplay==nil then return end
    self.m_equipCount = mainplay:getEquipCount() --装备数量
    self.m_equipList  = mainplay:getEquipList()  --装备数据

    --装备刷新
    self:resetEquipData()

    if self.m_equipCount~=nil and self.m_equipCount>0 then
      for i=1,self.m_equipCount do
        local id    = self.m_equipList[i].goods_id
        local index = self.m_equipList[i].index
        local node  = _G.Cfg.goods[id]
        if node == nil then return end

        --获取物品应该放的位置
        local no         = _G.Const.kEquipPosByType[node.type_sub] or 1
        if no==nil then return end

        local btnSize=self.m_equipBtn[no]:getContentSize()
        self.m_equipsixSpr[no]=_G.ImageAsyncManager:createGoodsSpr(node)
        self.m_equipsixSpr[no]:setPosition(btnSize.width/2,btnSize.height/2)
        self.m_equipBtn[no]:addChild(self.m_equipsixSpr[no])
        self.equipBgSpr[no]:setVisible(false)

        print("KKKKKKKKKKKKKKK>>>>>>>>>>>",no,index)
        self.m_equipIndex[no]=index
      end
   end
end

function EquipView.resetEquipData( self )
   for i=1,6 do
      if self.m_equipsixSpr[i]~=nil then
          self.m_equipsixSpr[i]:removeFromParent(true)
          self.m_equipsixSpr[i]=nil 
      end
      
      self.m_equipIndex[i]=0
      self.equipBgSpr[i]:setVisible(true)
   end
end

function EquipView.getPlayerData( self,_CharacterName )
    local CharacterValue = nil 
    if     _CharacterName == "Lv" then
        CharacterValue = self.m_myProperty : getLv()
    elseif _CharacterName == "Power" then
        CharacterValue = self.m_myProperty : getPowerful()
    elseif _CharacterName == "Pro" then
        CharacterValue = self.m_myProperty : getPro()
    elseif _CharacterName == "Vip" then
        CharacterValue = self.m_myProperty : getVipLv()
    elseif _CharacterName=="XuanJing" then
        CharacterValue = self.m_myProperty : getXuanJing()
    elseif _CharacterName == MONEYTYPE_GOLD then
        CharacterValue = self.m_myProperty : getGold()
    elseif _CharacterName == MONEYTYPE_RMB then
        CharacterValue = self.m_myProperty :getRmb() + self.m_myProperty :getBindRmb()
    elseif _CharacterName == MONEYTYPE_JADE then
        CharacterValue = 1
    end

    return CharacterValue
end

function EquipView.__showEquipEffect( self,_sender )
    if _sender==nil then return end

    if self.m_scelectSpr~=nil then
        self.m_scelectSpr:retain()
        self.m_scelectSpr:removeFromParent(false)
        _sender:addChild(self.m_scelectSpr,20)
        self.m_scelectSpr:release()
        return
    end

    self.m_scelectSpr=cc.Sprite:create()
    self.m_scelectSpr:runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
    self.m_scelectSpr:setPosition(78/2-1,78/2)
    _sender:addChild(self.m_scelectSpr,20)
end

function EquipView.AttrFryNode(self,_pos,_obj)
  local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
  attrFryNode:setPosition(_pos.width/2,_pos.height/2)
  _obj:addChild(attrFryNode,20)
end

function EquipView.NotAttrFryNode(self)

end

return EquipView