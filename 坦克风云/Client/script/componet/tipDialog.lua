tipDialog={
dialogLayer=nil,
}

function tipDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      bgSize,
      isTouch,
      isUseAmi,
      refreshData={},			--需要刷新的数据
      stPoint=nil,
      endPoint=nil,
      status=0, --0:关闭状态  1:打开状态
      lable,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end



function tipDialog:showTipsBar(parent,stPoint,endPoint,text,heigh,layerNum,autoClose,stayTime,color,lbHeightPos)
  if tipDialog.dialogLayer~=nil then
     local diaLog = tolua.cast(tipDialog.dialogLayer,"CCNode")
     if diaLog then
       diaLog:removeFromParentAndCleanup(true)
     end
     tipDialog.dialogLayer=nil
  end
      local sd=tipDialog:new()
      sd:initTipsDialog(parent,stPoint,endPoint,text,heigh,layerNum,autoClose,stayTime,color,lbHeightPos)
      return sd
end


-- bgSrc:
function tipDialog:initTipsDialog(parent,stPoint,endPoint,text,heigh,layerNum,autoClose,stayTime,color,lbHeightPos)

  self.stPoint=stPoint;
  self.endPoint=endPoint;
    local function tmpFunc()
      
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    tipDialog.dialogLayer=CCLayer:create()
    dialogBg:setOpacity(255)
    self.bgLayer=dialogBg
     local size=CCSizeMake(640,100)
  if heigh~=nil then
        self.bgLayer:setContentSize(CCSizeMake(640,heigh))
        local size=CCSizeMake(640,heigh)
  else
    self.bgLayer:setContentSize(CCSizeMake(640,100))
  end


    -- self.lable = GetTTFLabelWrap(text,25,CCSizeMake(size.width-60,size.height-60),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.lable = GetTTFLabelWrap(text,25,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.lable:setPosition(getCenterPoint(self.bgLayer));
    if lbHeightPos then
        self.lable:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbHeightPos));
    end
    if color then
        self.lable:setColor(color)
    end
    self.bgLayer:addChild(self.lable,1);
    self.bgLayer:setIsSallow(false);
    tipDialog.dialogLayer:addChild(self.bgLayer,1);
    parent:addChild(tipDialog.dialogLayer,layerNum)
    tipDialog.dialogLayer:setPosition(stPoint)
  self:showTips(autoClose,stayTime)


end
--显示面板,加效果
function tipDialog:showTips(autoClose,stayTime)
    self.status=1
    local function realClose()
        return self:realClose()
    end
   local fc= CCCallFunc:create(realClose)
   local moveTo1=CCMoveTo:create(0.3,self.endPoint)
   local moveTo2=CCMoveTo:create(0.3,self.stPoint)
   local delayTime
   if stayTime then
        delayTime = CCDelayTime:create(stayTime);
   else
        delayTime = CCDelayTime:create(1);
   end
   
   local acArr=CCArray:create()
   acArr:addObject(moveTo1)
   if autoClose==nil or autoClose==true then
       acArr:addObject(delayTime)
       acArr:addObject(moveTo2)
       acArr:addObject(fc)
   end
   local seq=CCSequence:create(acArr)
   tipDialog.dialogLayer:runAction(seq)

end


function tipDialog:close()
        self.status=0
   	    local function realClose()
	        return self:realClose()
	    end
   local fc= CCCallFunc:create(realClose)
   local moveTo2=CCMoveTo:create(0.3,self.stPoint)
   
   local acArr=CCArray:create()
   acArr:addObject(moveTo2)

   acArr:addObject(fc)
   
   local seq=CCSequence:create(acArr)
   if tipDialog.dialogLayer~=nil then
      tipDialog.dialogLayer:runAction(seq)
   end
   
end
function tipDialog:realClose()
	if tipDialog.dialogLayer~=nil then
	    tipDialog.dialogLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
    tipDialog.dialogLayer=nil
    self.bgSize=nil

end