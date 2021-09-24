acOlympicEventDialog=commonDialog:new()


function acOlympicEventDialog:new(page)
    local nc={}
    nc.page=nil
    nc.curPage=page
    nc.tvTab={}
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acOlympicEventDialog:initTableView() 
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    if self.page==nil then
        self.page=acOlympicCollectVoApi:getNumDayOfActive()
    end
    local num=acOlympicCollectVoApi:getNumOfDay()
    self.num=num
    if self.page>num then
        self.page=1
    end
    self:initBg()
    self:initLayer()
    self:initPageFlag()
end

function acOlympicEventDialog:initBg()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((G_VisibleSizeWidth-20)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    self.bgLayer:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local function nilFunction()
    end
    local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunction)
    lineBg:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height/2-36))
    lineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.bgLayer:addChild(lineBg)
end

function acOlympicEventDialog:initLayer()
    self.list={}
    self.dlist={}
  
    for i=1,self.num do
        local atDialog=acOlympicTask:new(self)
        local layer=atDialog:init(self.layerNum,i)
        self.bgLayer:addChild(layer,1)

        layer:setPosition(ccp(0,0))

        self.list[i]=layer
        self.dlist[i]=atDialog
    end

    self.taskLayer=pageDialog:new()
    if self.dlist[self.curPage] then
        self.dlist[self.curPage]:realShow()
        self.tvTab[self.curPage]=self.dlist[self.curPage].tv
    end
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.curPage=topage
        if self.titleLabel then
            local pic,name,desc,openDay=acOlympicCollectVoApi:getDayOfEvent(topage)
            if name and name~="" then
                self.titleLabel:setString(name)
            end
        end
    end
    local function movedCallback(turnType,isTouch)
        local canMove=true
        if self.curPage and self.tvTab then
            local turnPage=self.curPage+1
            if turnType==1 then
                turnPage=self.curPage-1
            end
            if turnPage<=0 then
                turnPage=self.num
            elseif turnPage>self.num then
                turnPage=1
            end
            if self.tvTab[turnPage] then
            else
                if self.dlist[turnPage] then
                    self.dlist[turnPage]:realShow()
                    self.tvTab[turnPage]=self.dlist[turnPage].tv
                end
            end
            if self.tvTab[self.curPage] and isTouch==true then
                local tv=self.tvTab[self.curPage]
                local desTv=self.dlist[self.curPage].desTv
                if tv and tv.getScrollEnable and tv.getIsScrolled and desTv and desTv.getScrollEnable and desTv.getIsScrolled then
                    canMove=false
                    if tv:getScrollEnable()==true and tv:getIsScrolled()==false  and desTv:getScrollEnable()==true and desTv:getIsScrolled()==false then
                        canMove=true
                    end
                end
            end
        end
        return canMove
    end
    local posY=G_VisibleSizeHeight/2
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    local pageLayer=self.taskLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.curPage,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback)
end

function acOlympicEventDialog:initPageFlag()
end

function acOlympicEventDialog:hidePageLayer()
    if self and self.taskLayer then
        if self.taskLayer.hide then
            self.taskLayer:hide()
        end
    end
end
function acOlympicEventDialog:showPageLayer()
    if self and self.taskLayer then
        if self.taskLayer.show then
            self.taskLayer:show()
        end
    end
end


function acOlympicEventDialog:tick()
    local page=acOlympicCollectVoApi:getNumDayOfActive()
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

function acOlympicEventDialog:dispose()
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
    self.bgLayer=nil
    self.layerNum=nil
    self.curPage=nil
    self.page=nil
    self.num=nil
    self.tvTab={}
end