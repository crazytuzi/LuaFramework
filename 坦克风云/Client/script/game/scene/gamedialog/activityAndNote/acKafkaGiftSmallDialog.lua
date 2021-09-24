acKafkaGiftSmallDialog={}

function acKafkaGiftSmallDialog:new( idx)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.showCellInIdx=idx

	return nc
end

function acKafkaGiftSmallDialog:init(bgSrc,layerNum,inRect,size,titleStr,callBack)
  require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
	self.layerNum=layerNum
	self.dialogLayer=CCLayer:create()
  	self.size = size 
    -- 屏蔽层
    local function tmpFunc()         
    end
    local forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    forbidBg:setContentSize(CCSizeMake(640,G_VisibleSizeHeight))
    forbidBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    forbidBg:setTouchPriority(-(layerNum-1)*20-1)
    forbidBg:setOpacity(200)
    self.dialogLayer:addChild(forbidBg)

    local function tmpFunc2()
    end
    local desBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc2)
    desBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    desBg:setContentSize(size)
    self.dialogLayer:addChild(desBg)
    local award = FormatItem(acKafkaGiftVoApi:getRewardR2ById(self.showCellInIdx),true,true)
    local locaAward,awardNums = acKafkaGiftVoApi:getRewardR2ById(self.showCellInIdx)
    local awardHeight = desBg:getContentSize().height - 120
    local vipShowList = acKafkaGiftVoApi:getRequireInVipList()
    local vipNeedIconList = vipShowList["r1"][self.showCellInIdx]
    local awardCells = acKafkaGiftVoApi:getAwardCells( )
    local function showHandler( hd,fn,idx)
          local iconSp,duigSp,checkBder,smForbidBg
          for i=1,SizeOfTable(award) do
              iconSp = tolua.cast(desBg:getChildByTag(i),"CCSprite")
              checkBder = tolua.cast(iconSp:getChildByTag(i),"CCSprite")
              duigSp=tolua.cast(iconSp:getChildByTag(i+10),"CCSprite")
              smForbidBg =tolua.cast(iconSp:getChildByTag(i+20),"CCSprite")
            if idx ~=i then
              checkBder:setVisible(false)
              duigSp:setVisible(false)
            else 
              if playerVoApi:getVipLevel() >= vipNeedIconList[idx] then
                checkBder:setVisible(true)
                duigSp:setVisible(true)
                acKafkaGiftVoApi:setBigAwardInIdx(idx)
                if smForbidBg then
                  smForbidBg:setVisible(false)
                end
                local awardCellIdx = acKafkaGiftVoApi:getBigAwardCellIdx(  )
                local bigAwardIdx = acKafkaGiftVoApi:getBigAwardInIdx(  )
                -- acKafkaGiftVoApi:setHadAwardList(awardCellIdx,bigAwardIdx)
                acKafkaGiftVoApi:setChooseFlagList(bigAwardIdx,awardCells-awardCellIdx+1)
                local heroId,orderId = acKafkaGiftVoApi:takeHeroOrder(award[i].key)
                if award[i].type=="h" then
                   local td = acHuoxianmingjiangHeroInfoDialog:new(heroId,orderId)
                  local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
                  sceneGame:addChild(dialog,self.layerNum+1)
                else
                  propInfoDialog:create(sceneGame,award[i],self.layerNum+1,nil,nil,nil)
                end
               
              end
            end
          end
    end 
    if award and SizeOfTable(award)>0 then
      for k,v in pairs(award) do

          local h = awardHeight-140*math.floor(k/5)-20 --每条奖励信息的y坐标起始位置
          local icon,iconScale = acKafkaGiftVoApi:getItemIcon(v,100,true,self.layerNum,showHandler)
                icon:ignoreAnchorPointForPosition(false)
                icon:setAnchorPoint(ccp(0,0.5))
                -- icon:setPosition(ccp((k-1)*110 +20 ,h))
                icon:setPosition(ccp(math.ceil((k-1)%4)*110+20,h))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                desBg:addChild(icon,1)
                icon:setTag(k)  

          local iconScaleX=1
          local iconScaleY=1                
          if icon:getContentSize().width>100 then
            iconScaleX=0.78*100/150
            iconScaleY=0.78*100/150
          else
            iconScaleX=0.78
            iconScaleY=0.78
          end
          local numLabel=GetTTFLabel("x"..awardNums[k],21)
          numLabel:setAnchorPoint(ccp(0,0))
          numLabel:setPosition(8,8)
          icon:addChild(numLabel,1)
          numLabel:setScaleX(1/iconScaleX)
          numLabel:setScaleY(1/iconScaleY)
          local function nilFunc()
          end
          local checkBorder = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),nilFunc)
          checkBorder:setContentSize(CCSizeMake(icon:getContentSize().width+2,icon:getContentSize().height+2))
          checkBorder:setAnchorPoint(ccp(1,0))
          checkBorder:setPosition(ccp(icon:getContentSize().width,0))
          icon:addChild(checkBorder,1)
          checkBorder:setTag(k)
          checkBorder:setVisible(false)


          local p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
          p1Sp:setAnchorPoint(ccp(1,0))
          p1Sp:setPosition(ccp(icon:getContentSize().width-4,2))
          icon:addChild(p1Sp,1)
          p1Sp:setTag(k+10)
          p1Sp:setVisible(false)

          local vipIcon
          if vipNeedIconList[k] >0 then
            vipIcon=CCSprite:createWithSpriteFrameName("Vip"..vipNeedIconList[k]..".png")
            vipIcon:setAnchorPoint(ccp(0.5,0.5))
            vipIcon:setPosition(ccp(icon:getContentSize().width-18,icon:getContentSize().height-10))
            vipIcon:setRotation(25)
            icon:addChild(vipIcon,1)       

            --如果未达到VIP等级 需给相应奖励坐上遮罩
            if playerVoApi:getVipLevel()< vipNeedIconList[k] then
              local smForbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
              smForbidBg:setContentSize(CCSizeMake(icon:getContentSize().width-2,icon:getContentSize().height-2))
              smForbidBg:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
              smForbidBg:setTouchPriority(-(layerNum-1)*20-1)
              smForbidBg:setOpacity(200)
              icon:addChild(smForbidBg)
              smForbidBg:setTag(k+20)
            end
          end
      end
    end
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        
        if acKafkaGiftVoApi:getBigAwardInIdx() then
          acKafkaGiftVoApi:setSureToAward(true)
        end
        callBack()
        return self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(desBg:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    desBg:addChild(sureMenu)


    return self.dialogLayer
end



function acKafkaGiftSmallDialog:close( )
	self.showCellInIdx=nil
	self.size=nil
	self.layerNum=nil
	self.dialogLayer:removeFromParentAndCleanup(true)
	

	self=nil
end