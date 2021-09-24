local EquipLayer=classGc(view,function(self,_uid,_isShowOrther)
    self.m_curRoleUid=_uid or 0
    self.m_isShowOrther=_isShowOrther
    self.m_myUid=self.m_curRoleUid
end)

function EquipLayer.create(self)
  	self.m_rootNode=cc.Node:create()
  	self:__initParment()

    if self.m_myProperty==nil then return self.m_rootNode end

  	self:__initView()
    self:__showEquip()
    self:__showRoleSpine()
    self:playerpower()
    self:updateEquip()

  	return self.m_rootNode
end

function EquipLayer.__initParment(self)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(self.m_curRoleUid,_G.Const.CONST_PLAYER)

    if self.m_isShowOrther then
        self.m_tipsShowType=nil
    else
        self.m_tipsShowType=_G.Const.CONST_GOODS_SITE_PLAYER
    end

    if self.m_myProperty==nil then return end

    self.m_myPartner=self.m_myProperty:getWarPartner()
    print("EquipLayer.__initParmen===>",self.m_myPartner)
    if self.m_myPartner~=nil then
        self.m_partnerIdx=self.m_myPartner:getPartner_idx()
        self.m_partnerId=self.m_myPartner:getPartnerId() or 0
        -- if self.m_curRoleUid~=0 then
        --     self.m_curRoleUid=self.m_partnerIdx
        -- end
        print("有出战的伙伴  idx=",self.m_partnerIdx)
    end
end

function EquipLayer.__initView(self)
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
  baguaBg:setScale(1.5)
  self.m_leftBgSpr:addChild(baguaBg)
  --切换灵妖
  -- local function local_btncallback(sender, eventType) 
  --   if eventType==ccui.TouchEventType.ended then
  --       local nTag=sender:getTag()
  --       if nTag==-1 then
  --           _G.Util:showErrorTips(4200)
  --       else
  --           print("\n切换灵妖====>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  --           self.m_curRoleUid=nTag
  --           self:updateEquip()

  --           local command=CRoleViewCommand(data)
  --           command.isZLF=false
  --           command.uid=self.m_curRoleUid
  --           _G.controller:sendCommand(command)

  --           if nTag==self.m_myUid then
  --               self.m_Switchbtn:setTitleText("切换灵妖")
  --               self.m_Switchbtn:setTag(self.m_partnerIdx)
  --           else
  --               self.m_Switchbtn:setTitleText("切换主角")
  --               self.m_Switchbtn:setTag(self.m_myUid)
  --           end
  --           self:__showRoleSpine()
  --           self:playerpower()
  --       end
  --   end
  -- end

  -- local sTag=-1
  -- local btnX=0
  -- if self.m_curRoleUid==self.m_myUid then
  --     sTag=self.m_partnerIdx or -1
  --     btnX=100
  -- end
  -- self.m_Switchbtn  = gc.CButton:create("general_btn_gold.png") 
  -- self.m_Switchbtn  : setTitleFontName(_G.FontName.Heiti)
  -- self.m_Switchbtn  : setTitleText("切换灵妖")
  -- self.m_Switchbtn  : addTouchEventListener(local_btncallback)
  -- self.m_Switchbtn  : setTitleFontSize(24)
  -- self.m_Switchbtn  : setTag(sTag)
  -- self.m_Switchbtn  : setPosition(self.m_leftBgSprSize.width/2-btnX,30)
  -- bgSpr1            : addChild(self.m_Switchbtn)

  --   local function c(sender, eventType) 
  --       if eventType==ccui.TouchEventType.ended then
  --           print("\n换装")
  --           local player=_G.g_Stage:getMainPlayer()
  --           local a
  --           if player.m_SkinId==10001 then
  --               a=10002
  --           else
  --               a=10001
  --           end
  --           player:setSkin(a)
  --           self:__showRoleSpine()
  --       end
  --   end

  --   if self.m_curRoleUid==self.m_myUid then
  --       local btn  = gc.CButton:create("general_btn_gold.png") 
  --       btn  : setTitleFontName(_G.FontName.Heiti)
  --       btn  : setTitleText("换装")
  --       btn  : addTouchEventListener(c)
  --       btn  : setTitleFontSize(24)
  --       btn  : setPosition(self.m_leftBgSprSize.width/2+100,30)
  --       bgSpr1 : addChild(btn)
  --   end

end

function EquipLayer.__showEquip(self)
  self.m_equipBtn    = {}
  self.m_equipsixSpr = {}

  local function l_btnCallBack(sender, eventType)
    if eventType==ccui.TouchEventType.ended then
        -- self:__showEquipEffect(sender)

        local btn_tag =sender:getTag()
        local Position=sender:getWorldPosition()
        if btn_tag<=0 then return end

        local scelectData = nil 
        for k,v in pairs(self.m_equipList) do
           if btn_tag == v.index then
                scelectData = v
                print("dsdasdsadsad",v.goods_id,v.index)
                break
            end
        end
        if scelectData == nil then return end

        local partnerIndex=nil
        if self.m_curRoleUid~=self.m_myUid then
            local myUid=self.m_myUid
            if self.m_myUid==0 then
                myUid=self.m_myProperty:getUid()
            end
            partnerIndex=string.format("%d%d",myUid,self.m_partnerIdx)
        end
        local temp=_G.TipsUtil:create(scelectData,self.m_tipsShowType,Position,self.m_curRoleUid,nil,partnerIndex)
        cc.Director:getInstance():getRunningScene():addChild(temp,1000)
    end
  end

  local potY = 0  
  local potX = 0
  self.equipBgSpr={}
  for i=1,6 do
      self.m_equipBtn[i]=gc.CButton:create("general_tubiaokuan.png")
      self.m_equipBtn[i]:addTouchEventListener(l_btnCallBack)
      self.m_leftBgSpr:addChild(self.m_equipBtn[i],10)

      local szImg="role_ui_equipbg"..i..".png"
      self.equipBgSpr[i]=cc.Sprite:createWithSpriteFrameName(szImg)
      self.m_equipBtn[i]:addChild(self.equipBgSpr[i])
      local size=self.m_equipBtn[i]:getContentSize()
      self.equipBgSpr[i]:setPosition(size.width/2,size.height/2)
     
      if  i <= 3 then
          potX = self.m_leftBgSprSize.width/2 - 150
          potY = self.m_leftBgSprSize.height - 80 - 105*(i-1)
      else
          potX = self.m_leftBgSprSize.width/2 + 150
          potY = self.m_leftBgSprSize.height - 80 - 105*(i-4)
      end

      self.m_equipBtn[i]:setPosition(potX,potY)
  end
end

-- function EquipLayer.__showEquipEffect(self,_sender)
--     if _sender==nil then return end

--     if self.m_scelectSpr~=nil then
--         self.m_scelectSpr:retain()
--         self.m_scelectSpr:removeFromParent(false)
--         _sender:addChild(self.m_scelectSpr,20)
--         self.m_scelectSpr:release()
--         return
--     end

--     self.m_scelectSpr=cc.Sprite:create()
--     self.m_scelectSpr:runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
--     self.m_scelectSpr:setPosition(78/2-1,78/2)
--     _sender:addChild(self.m_scelectSpr,20)
-- end

function EquipLayer.__showRoleSpine(self)
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
        self.m_leftBgSpr:addChild(self.m_skeleton,10)
    end

    if self.shadow==nil then
        self.shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
        self.shadow:setPosition(self.m_leftBgSprSize.width/2,nPosY+5)
        self.m_leftBgSpr:addChild(self.shadow)
    end
end

function EquipLayer.resetEquipData( self )
   for i=1,6 do
      if self.m_equipsixSpr[i]~=nil then
          self.m_equipsixSpr[i]:removeFromParent(true)
          self.m_equipsixSpr[i]=nil 
      end
      self.m_equipBtn[i]:setTag(-1)
      self.equipBgSpr[i]:setVisible(true)
   end
end

function EquipLayer.updateEquip(self)
    local mainplay = nil
    print("EquipLayer.updateEquip------>",self.m_curRoleUid==self.m_myUid)

    if self.m_curRoleUid==self.m_myUid then
        mainplay=self.m_myProperty
    else
        mainplay=self.m_myPartner
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
        self.m_equipBtn[no]:setTag(index)
        self.m_equipBtn[no]:addChild(self.m_equipsixSpr[no])
        self.equipBgSpr[no]:setVisible(false)
      end
   end
end

function EquipLayer.updatePower(self,powerful)
    if self.m_powerNode~=nil then
        self.m_powerNode:removeFromParent(true)
        self.m_powerNode=nil 
    end
    print("createPowerfulIcon====",powerful)
    -- local powerful=tostring(powerful)
    -- local length=string.len(powerful)
    self.m_powerNode=cc.Node:create()
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setPosition(0,0)
    self.m_powerNode:addChild(powerSpr)

    -- local spriteWidth=35
    -- for i=1,length do
        local tempLab=_G.Util:createBorderLabel(string.format("战力:%d",powerful),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
        -- tempLab:setAnchorPoint(cc.p(0,0.5))
        tempLab:setPosition(0,0)
        self.m_powerNode : addChild(tempLab)
    -- end

    self.m_powerNode:setPosition(self.m_leftBgSprSize.width/2, self.m_leftBgSprSize.height)
    self.m_leftBgSpr:addChild(self.m_powerNode,10)
end

function EquipLayer.getCurRoleUid(self)
  return self.m_curRoleUid
end

function EquipLayer.playerpower(self)
  print("战力更新",self.m_curRoleUid,self.m_myUid)
  if self.m_curRoleUid==self.m_myUid then
      mainplay=self.m_myProperty
  else
      mainplay=self.m_myPartner
  end
  local powerful=mainplay:getPowerful()
  self:updatePower(powerful)
end

return EquipLayer