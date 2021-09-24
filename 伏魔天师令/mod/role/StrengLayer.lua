local StrengLayer=classGc(view,function(self,_uid,_isShowOrther)
    self.m_curRoleUid=_uid or 0
    self.m_isShowOrther=_isShowOrther
    self.m_myUid=self.m_curRoleUid
end)

function StrengLayer.create(self)
  	self.m_rootNode=cc.Node:create()
  	self:__initParment()

    if self.m_myProperty==nil then return self.m_rootNode end

  	self:__initView()
    self:__showEquip()
    self:__showRoleSpine()
    self:playerpower()
    -- self:updateEquip()

  	return self.m_rootNode
end

function StrengLayer.__initParment(self)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(self.m_curRoleUid,_G.Const.CONST_PLAYER)

    if self.m_isShowOrther then
        self.m_tipsShowType=nil
    else
        self.m_tipsShowType=_G.Const.CONST_GOODS_SITE_PLAYER
    end

    if self.m_myProperty==nil then return end

    self.m_myPartner=self.m_myProperty:getWarPartner()
    print("StrengLayer.__initParmen===>",self.m_myPartner)
    if self.m_myPartner~=nil then
        self.m_partnerIdx=self.m_myPartner:getPartner_idx()
        self.m_partnerId=self.m_myPartner:getPartnerId() or 0
        -- if self.m_curRoleUid~=0 then
        --     self.m_curRoleUid=self.m_partnerIdx
        -- end
        print("有出战的伙伴  idx=",self.m_partnerIdx)
    end
end

function StrengLayer.__initView(self)
	--外层绿色底图大小
  local rootBgSize = cc.size(828,476)
  --左边内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
  self.m_leftBgSprSize = cc.size(rootBgSize.width/2,rootBgSize.height)
  local bgSpr1  = cc.Node:create() 
  -- bgSpr1        : setContentSize( self.m_leftBgSprSize )
  self.m_rootNode: addChild(bgSpr1)
  bgSpr1        : setPosition(-self.m_leftBgSprSize.width+15,-112-self.m_leftBgSprSize.height/2)

  self.m_leftBgSpr=bgSpr1

  local baguaBg=cc.Sprite:createWithSpriteFrameName("general_rolebg2.png")
  baguaBg:setPosition(self.m_leftBgSprSize.width/2,self.m_leftBgSprSize.height/2+50)
  baguaBg:setScale(1.8)
  self.m_leftBgSpr:addChild(baguaBg)

  -- local fazhenName="spine/wuqifazhen_1"
  -- -- self.m_spineResArray[fazhenName]=true
  -- local fazhenspine = _G.SpineManager.createSpine(fazhenName,1)
  -- fazhenspine:setAnimation(0,"idle",true)
  -- fazhenspine:setPosition(self.m_leftBgSprSize.width/2,120)
  -- self.m_leftBgSpr:addChild(fazhenspine)
end

function StrengLayer.__showEquip(self)
  self.m_equipBtn    = {}
  self.m_equipsixSpr = {}

  local function l_btnCallBack(sender, eventType)
    if eventType==ccui.TouchEventType.ended then
        if self.m_isEquipActionRuning then return end

        local btn_tag =sender:getTag()
        local Position=sender:getWorldPosition()
        if btn_tag<=0 then return end

        self:showStrengthOkEffect(btn_tag)
        self:BtnMoveDown(btn_tag)
        self:setNowGoodsIndex(btn_tag)
        self:EquipmentSystemCommandSend()

        if self.m_guide_wait_touch then
            self.m_guide_wait_touch=nil
            _G.GGuideManager:runNextStep()
        end
    end
  end

  self.potY = {self.m_leftBgSprSize.height/2+20,self.m_leftBgSprSize.height/2+65,self.m_leftBgSprSize.height/2+100,
              self.m_leftBgSprSize.height/2+105,self.m_leftBgSprSize.height/2+80,self.m_leftBgSprSize.height/2+28}
  self.potX = {self.m_leftBgSprSize.width/2+15,self.m_leftBgSprSize.width/2+105,self.m_leftBgSprSize.width/2+50,
                self.m_leftBgSprSize.width/2-12,self.m_leftBgSprSize.width/2-65,self.m_leftBgSprSize.width/2-92}              
  self.Scale= {1.7,1.2,0.8,0.6,0.9,1.3}
  self.ceng = {10,8,3,1,3,8}
  self.isTrue = {true,true,false,false,false,true}

  local act=cc.MoveBy:create(2,cc.p(0,20))
  local nAction=cc.RepeatForever:create(cc.Sequence:create(act,act:reverse()))
  for i=1,6 do
      self.m_equipBtn[i]=gc.CButton:create(string.format("role_streng%d.png",i))
      self.m_equipBtn[i]:addTouchEventListener(l_btnCallBack)
      self.m_equipBtn[i]:setPosition(self.potX[i],self.potY[i])
      self.m_equipBtn[i]:setButtonScale(self.Scale[i])
      self.m_equipBtn[i]:setEnabled(self.isTrue[i])
      self.m_equipBtn[i]:runAction(nAction:clone())
      self.m_equipBtn[i]:setTag(i)
      self.m_equipBtn[i]:setTouchActionType(_G.Const.kCButtonTouchTypeGray)
      self.m_leftBgSpr:addChild(self.m_equipBtn[i],self.ceng[i])      
  end
  self:showStrengthOkEffect(1)

  local guideId=_G.GGuideManager:getCurGuideId()
  if guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP then
      self.m_guide_wait_touch=true
      _G.GGuideManager:registGuideData(2,self.m_equipBtn[2])

      local function nFun()
          _G.GGuideManager:runNextStep()
      end
      self.m_equipBtn[2]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(nFun)))
  end
end

function StrengLayer.BtnMoveDown( self,_id )
  local function nFun()
      self.m_isEquipActionRuning=nil
  end

  self.m_isEquipActionRuning=true
  for i=1,6 do
      local num=_id+(i-1)>6 and _id+(i-1)-6 or _id+(i-1)
      local moveTo = cc.MoveTo:create(0.4,cc.p(self.potX[i],self.potY[i]))
      local scaleTo = cc.ScaleTo:create(0.4,self.Scale[i])

      local act=i~=1 and moveTo or cc.Sequence:create(moveTo,cc.CallFunc:create(nFun))
      self.m_equipBtn[num]:runAction(act)
      self.m_equipBtn[num]:runAction(scaleTo)
      -- self.m_equipBtn[num]:setButtonScale()
      self.m_equipBtn[num]:setLocalZOrder(self.ceng[i])
      self.m_equipBtn[num]:setEnabled(self.isTrue[i])
  end
end

function StrengLayer.showStrengthOkEffect(self,_id)
  if self.tempObj~=nil then 
      self.tempObj:removeFromParent(true)
      self.tempObj=nil
  end

  print("showStrengthOkEffect--->>",_id)
  local tempGafAsset=gaf.GAFAsset:create("gaf/choose.gaf")
  self.tempObj=tempGafAsset:createObject()
  local btnSize=self.m_equipBtn[_id]:getContentSize()
  local nPos=cc.p(btnSize.width/2-3,btnSize.height/2+3)
  self.tempObj:setScale(0.6)
  self.tempObj:setLooped(true,true)
  self.tempObj:start()
  self.tempObj:setPosition(nPos)
  self.m_equipBtn[_id] : addChild(self.tempObj,1000)
end

--现在的物品框index
function StrengLayer.setNowGoodsIndex( self,_id )
    self.NowGoodsIndex = _id
end
function StrengLayer.getNowGoodsIndex( self )
    return self.NowGoodsIndex
end

function StrengLayer.EquipmentSystemCommandSend( self )
    print("EquipView.EquipmentSystemCommandSend111111111-----")
    local data = {}
    data.nowPartnerId  = self.m_curRoleUid
    data.nowGoodsPart  = self : getNowGoodsIndex() or 0 --获取当前部位
  
    local _Command = EquipmentsViewCommand(data)
    controller:sendCommand(_Command)
end

function StrengLayer.__showRoleSpine(self)
    if self.m_skeleton~=nil then
        self.m_skeleton:removeFromParent(true)
        self.m_skeleton=nil
    end

    self.m_wuqiSke,self.m_featherSke=nil
    if self.m_curRoleUid==self.m_myUid then
        self.m_skeleton,self.m_wuqiSke,self.m_featherSke=_G.SpineManager.createPlayer(self.m_myProperty:getSkinArmor()%100,0.7,self.m_myProperty:getSkinWeapon(),self.m_myProperty:getSkinFeather())
    else
        self.m_skeleton=_G.SpineManager.createPartner(self.m_partnerId)
        if self.m_skeleton then
            local data = _G.Cfg.partner_init[self.m_partnerId]
            local showscale = data.showscale2/data.scale
            self.m_skeleton:setScale(showscale)
        end
    end

    local nPosY=120
    if self.m_skeleton~=nil then
        self.m_skeleton:setAnimation(0,"idle",true)
        if self.m_wuqiSke~=nil then
            self.m_wuqiSke:setAnimation(0,"idle",true)
        end
        if self.m_featherSke~=nil then
            self.m_featherSke:setAnimation(0,string.format("idle_%d",self.m_myProperty:getSkinArmor()),true)
        end
        
        if self.m_partnerId == 13101 and self.m_curRoleUid~=self.m_myUid then
          -- 压龙大仙
          self.m_skeleton : setPosition( self.m_leftBgSprSize.width/2+40, nPosY )
        else
          self.m_skeleton:setPosition(cc.p(self.m_leftBgSprSize.width/2,nPosY))
        end
        self.m_leftBgSpr:addChild(self.m_skeleton,5)
    end

    if self.shadow==nil then
        self.shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
        self.shadow:setPosition(self.m_leftBgSprSize.width/2,nPosY+5)
        self.m_leftBgSpr:addChild(self.shadow)
    end
end

function StrengLayer.updatePower(self,powerful)
    if self.m_powerNode~=nil then
        self.m_powerNode:removeFromParent(true)
        self.m_powerNode=nil 
    end
    print("createPowerfulIcon====",powerful)
    self.m_powerNode=cc.Node:create()
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setPosition(0,0)
    self.m_powerNode:addChild(powerSpr)

    local tempLab=_G.Util:createBorderLabel(string.format("战力:%d",powerful),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    tempLab:setPosition(0,0)
    self.m_powerNode : addChild(tempLab)

    self.m_powerNode:setPosition(self.m_leftBgSprSize.width/2, self.m_leftBgSprSize.height)
    self.m_leftBgSpr:addChild(self.m_powerNode,10)
end

function StrengLayer.getCurRoleUid(self)
  return self.m_curRoleUid
end

function StrengLayer.playerpower(self)
  print("战力更新",self.m_curRoleUid,self.m_myUid)
  if self.m_curRoleUid==self.m_myUid then
      mainplay=self.m_myProperty
  else
      mainplay=self.m_myPartner
  end
  local powerful=mainplay:getPowerful()
  self:updatePower(powerful)
end

return StrengLayer