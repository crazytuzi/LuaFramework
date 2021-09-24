acChunjiepanshengTab2={}


function acChunjiepanshengTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acChunjiepanshengTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initBg()
    self:initLayer()
    self:initPageFlag()
    return self.bgLayer
end

function acChunjiepanshengTab2:initBg()
    local acBg--=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
    local version = acChunjiepanshengVoApi:getVersion()
    if version and version==4 then
        acBg=CCSprite:create("public/acChunjiepanshengBg_v4.jpg")
        acBg:setAnchorPoint(ccp(0.5,1))
        acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
        acBg:setScaleY(0.85)
    else
        if version and version==3 then
            acBg=CCSprite:create("public/acChunjiepanshengBg.jpg")
        else
            acBg=CCSprite:create("public/acWanshengjiedazuozhanBg2.jpg")
        end
        acBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50))
        acBg:setAnchorPoint(ccp(0.5,0.5))
        acBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50)
        acBg:setOpacity(180)
        acBg:setScale(0.96)
    end
    self.bgLayer:addChild(acBg)

end

function acChunjiepanshengTab2:initLayer()
    self.list={}
    self.dlist={}
    local num=acChunjiepanshengVoApi:getNumOfDay()
    self.num=num
    for i=1,num do
        local atDialog=acChunjiepanshengTask:new(self)
        local layer=atDialog:init(self.layerNum,i)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.list[i]=layer
        self.dlist[i]=atDialog
    end

    self.taskLayer=pageDialog:new()
    local page=acChunjiepanshengVoApi:getNumDayOfActive()
    -- print("++++++++page,num",page,num)
    if page>num then
        self.page=1
    else
        self.page=page
    end
    
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.curTankTab=self.dlist[topage]
    end
    local posY=G_VisibleSizeHeight-160-40
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    local version = acChunjiepanshengVoApi:getVersion()
    local pageLayer
    if version and version==4 then
        pageLayer=self.taskLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil,nil,nil,"ArrowYellow.png",true)
    else
        pageLayer=self.taskLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil)
    end
    self.curTankTab=self.dlist[1]
end

function acChunjiepanshengTab2:initPageFlag()
end

function acChunjiepanshengTab2:hidePageLayer()
    if self and self.taskLayer then
        if self.taskLayer.hide then
            self.taskLayer:hide()
        end
    end
end
function acChunjiepanshengTab2:showPageLayer()
    if self and self.taskLayer then
        if self.taskLayer.show then
            self.taskLayer:show()
        end
    end
end


function acChunjiepanshengTab2:tick()
    local page=acChunjiepanshengVoApi:getNumDayOfActive()
    if page>self.num then
        return
    end
    if self.page~=page then
        self.page=page
        for k,v in pairs(self.dlist) do
            if(v~=nil) and (self.page-k==1 or self.page==k) then
                v:refresh()
            end
        end
    end
end

function acChunjiepanshengTab2:dispose()
    if self.dlist then
        for k,v in pairs(self.dlist) do
            if v and v.dispose then
                v:dispose()
            end
        end
    end
    if self and self.taskLayer and self.taskLayer.dispose then
        self.taskLayer:dispose()
    end
    self.list=nil
    self.dlist=nil
    self.taskLayer=nil
    self.curTankTab=nil
    self.bgLayer=nil
    self.layerNum=nil
end