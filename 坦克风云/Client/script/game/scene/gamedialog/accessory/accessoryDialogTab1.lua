accessoryDialogTab1={}

function accessoryDialogTab1:new( ... )
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.parent=nil

    self.tankLayer=nil

    self.curTankTab=nil
    return nc
end

function accessoryDialogTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTank()
    self:initPageFlag()
    self:initDesc()
    local function dialogListener(event,data)
        local infoBtn=tolua.cast(self.bgLayer:getChildByTag(100),"CCMenu")
        if(data.type==1)then
            self.tankLayer:setEnabled(false)
            infoBtn:setVisible(false)
            self.curPageFlag:setVisible(false)
            for i=1,4 do
                local pageFlag=tolua.cast(self.bgLayer:getChildByTag(100 + i),"CCSprite")
                pageFlag:setVisible(false)
            end
        else
            self.tankLayer:setEnabled(true)
            infoBtn:setVisible(true)
            self.curPageFlag:setVisible(true)
            for i=1,4 do
                local pageFlag=tolua.cast(self.bgLayer:getChildByTag(100 + i),"CCSprite")
                pageFlag:setVisible(true)
            end
        end
    end
    self.dialogListener=dialogListener
    eventDispatcher:addEventListener("accessory.dialog.tankDetail",self.dialogListener)
    local function refreshListener(event,data)
        for k,v in pairs(data.type) do
            if(v==4)then
                self:refresh()
                break
            end
        end
    end
    self.refreshListener=refreshListener
    eventDispatcher:addEventListener("accessory.data.refresh",refreshListener)
    return self.bgLayer
end

function accessoryDialogTab1:initTank()
    self.list={}
    self.dlist={}
    require "luascript/script/game/scene/gamedialog/accessory/accessoryDialogTank"
    for i=1,4 do
        local atDialog=accessoryDialogTank:new(self)
        local layer=atDialog:init(self.layerNum,i)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.list[i]=layer
        self.dlist[i]=atDialog
    end

    self.tankLayer=pageDialog:new()
    local page=1
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.curTankTab.isShow=false
        self.curTankTab=self.dlist[topage]
        self.curTankTab.isShow=true
        if(self.curTankTab.needRefresh and self.curTankTab.refresh)then
            self.curTankTab:refresh()
        end
        self.curPageFlag:setPositionX(self.pageFlagPosXTb[topage])
    end
    local tankHeight=256
    if(G_isIphone5()==false)then
        tankHeight=tankHeight*0.9
    end
    local posY=G_VisibleSizeHeight - 250 - tankHeight/2
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    self.tankLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos)
    self.curTankTab=self.dlist[1]
    self.curTankTab.isShow=true

    local maskSpHeight=self.bgLayer:getContentSize().height-133
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end

end

function accessoryDialogTab1:initPageFlag()
    self.pageFlagPosXTb={G_VisibleSizeWidth/2-90,G_VisibleSizeWidth/2-30,G_VisibleSizeWidth/2+30,G_VisibleSizeWidth/2+90}
    local tankHeight=256
    if(G_isIphone5()==false)then
        tankHeight=tankHeight*0.9
    end
    local posY=G_VisibleSizeHeight - 250 - tankHeight - 80 - 20
    for i=1,4 do
        local pageFlag=CCSprite:createWithSpriteFrameName("circlenormal.png")
        pageFlag:setTag(100 + i)
        pageFlag:setPosition(ccp(self.pageFlagPosXTb[i],posY))
        self.bgLayer:addChild(pageFlag,1)
    end

    self.curPageFlag=CCSprite:createWithSpriteFrameName("circleSelect.png")
    self.curPageFlag:setPosition(ccp(self.pageFlagPosXTb[1],posY))
    self.bgLayer:addChild(self.curPageFlag,2)
end

function accessoryDialogTab1:hidePageLayer()
    if self and self.tankLayer then
        if self.tankLayer.hide then
            self.tankLayer:hide()
        end
    end
end
function accessoryDialogTab1:showPageLayer()
    if self and self.tankLayer then
        if self.tankLayer.show then
            self.tankLayer:show()
        end
    end
end

function accessoryDialogTab1:initDesc()
    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("accessory_desc"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorYellow,nil})
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setTag(100)
    infoBtn:setAnchorPoint(ccp(1,1))
    local tankHeight=256
    if(G_isIphone5()==false)then
        tankHeight=tankHeight*0.9
    end
    local posY=G_VisibleSizeHeight - 250 - tankHeight/2
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-35,G_VisibleSizeHeight - 250 - tankHeight - 50))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-3);
    self.bgLayer:addChild(infoBtn,3);
end

function accessoryDialogTab1:refresh()
    for k,v in pairs(self.dlist) do
        if(v~=nil)then
            if(v.isShow)then
                v:refresh()
            else
                v.needRefresh=true
            end
        end
    end
end

function accessoryDialogTab1:dispose()
    if self.dlist then
        for k,v in pairs(self.dlist) do
            if v and v.dispose then
                v:dispose()
            end
        end
    end
    if self and self.tankLayer and self.tankLayer.dispose then
        self.tankLayer:dispose()
    end
    self.list=nil
    self.dlist=nil
    self.tankLayer=nil
    self.curTankTab=nil
    self.bgLayer=nil
    self.layerNum=nil
    eventDispatcher:removeEventListener("accessory.dialog.tankDetail",self.dialogListener)
    eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
end