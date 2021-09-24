local UIMemory=classGc()

function UIMemory.create(self)
	self.m_rootNode=cc.Node:create()
	self:__initView()
	return self.m_rootNode
end
function UIMemory.__initView(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_layerSize=cc.size(self.m_winSize.width,40)

	self.m_topLayer=cc.LayerColor:create(cc.c4b(0,0,0,160))
	self.m_topLayer:setContentSize(self.m_layerSize)
	self.m_topLayer:setPosition(cc.p(0,640))
	self.m_rootNode:addChild(self.m_topLayer)

	local tag_memory=1
	local tag_texture=2
    local tag_reloadCnf=3
    local tag_clearLuaFile=4
    local tag_showMoveArea=5
    local tag_hideMoveArea=6
    local tag_chuangScene=7
    local tag_textCopy=8
    local tag_startCopy=10
    local tag_guide=13
    local tag_test=14
	local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            if tag==tag_memory then
                self:layerAction()
            elseif tag==tag_texture then
                self:showTexture()
            elseif tag==tag_reloadCnf then
                self.m_disparkHelper:reloadAllCnf()
            elseif tag==tag_clearLuaFile then
                self.m_disparkHelper:clearAllFileLoad()
            elseif tag==tag_showMoveArea then
                _G.g_Stage:showMoveArea()
                sender:setTag(tag_hideMoveArea)
            elseif tag==tag_hideMoveArea then
                _G.g_Stage:hideMoveArea()
                sender:setTag(tag_showMoveArea)
            elseif tag==tag_chuangScene then
                -- _G.g_Stage:autoExitCopy()
                local msg=REQ_SCENE_ENTER_CITY()
                _G.Network:send(msg)
                _G.GLayerManager=nil
            elseif tag==tag_textCopy then
                -- local msg=REQ_COPY_CREAT()
                -- msg:setArgs(9998)
                -- _G.Network:send(msg)
                _G.IS_TEST_COPY=true
                _G.g_Stage.m_stageMediator:gotoScene(9998,nil,nil)
            elseif tag==tag_startCopy then
                _G.GCopyProxy=nil
                _G.GLoginPoxy:setFirstLogin(true)
                local msg=REQ_COPY_CREAT()
                msg:setArgs(_G.Const.CONST_COPY_FIRST_COPY)
                _G.Network:send(msg)
            elseif tag==tag_guide then
                self:showGuideArray()
            elseif tag==tag_test then
                self:showTestView()
            else
                cc.Director:getInstance():setAnimationInterval(1/tag)
            end
        end
    end

	local memoryText = ccui.Text:create()
    memoryText:setString("【助手】")
    memoryText:setFontSize(30)
    memoryText:setFontName(_G.FontName.Heiti)
    memoryText:setTouchScaleChangeEnabled(true)
    memoryText:setPosition(cc.p(370,545))
    memoryText:setTouchEnabled(true)
    memoryText:setTag(tag_memory)
    memoryText:addTouchEventListener(c)
    memoryText:enableOutline(cc.c4b(0,0,0,255),1)
    self.m_rootNode:addChild(memoryText)

    local textureText = ccui.Text:create()
    textureText:setString("【纹理】")
    textureText:setFontSize(26)
    textureText:setFontName(_G.FontName.Heiti)
    textureText:setTouchScaleChangeEnabled(true)
    textureText:setPosition(cc.p(self.m_winSize.width-60,self.m_layerSize.height/2))
    textureText:setTouchEnabled(true)
    textureText:setTag(tag_texture)
    textureText:addTouchEventListener(c)
    self.m_topLayer:addChild(textureText)

    local nWidth=self.m_winSize.width-150
    -- if _G.SysInfo:isIos() then
    --     self.m_totalLabel=_G.Util:createLabel("",24)
    --     self.m_totalLabel:setAnchorPoint(cc.p(0,0.5))
    --     self.m_totalLabel:setPosition(cc.p(30,self.m_layerSize.height/2))
    --     self.m_topLayer:addChild(self.m_totalLabel)

    --     self.m_usedLabel=_G.Util:createLabel("",24)
    --     self.m_usedLabel:setAnchorPoint(cc.p(0,0.5))
    --     self.m_usedLabel:setPosition(cc.p(30+nWidth/4,self.m_layerSize.height/2))
    --     self.m_topLayer:addChild(self.m_usedLabel)

    --     self.m_freeLabel=_G.Util:createLabel("",24)
    --     self.m_freeLabel:setAnchorPoint(cc.p(0,0.5))
    --     self.m_freeLabel:setPosition(cc.p(30+nWidth/4*2,self.m_layerSize.height/2))
    --     self.m_topLayer:addChild(self.m_freeLabel)
    -- end

    local startCopyText = ccui.Text:create()
    startCopyText:setString("【新手副本】")
    startCopyText:setFontSize(26)
    startCopyText:setFontName(_G.FontName.Heiti)
    startCopyText:setTouchScaleChangeEnabled(true)
    startCopyText:setPosition(150,self.m_layerSize.height/2)
    startCopyText:setTouchEnabled(true)
    startCopyText:setTag(tag_startCopy)
    startCopyText:addTouchEventListener(c)
    self.m_topLayer:addChild(startCopyText)

    local tempText

    tempText = ccui.Text:create()
    tempText:setString("【测试】")
    tempText:setFontSize(26)
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(340,self.m_layerSize.height/2)
    tempText:setTouchEnabled(true)
    tempText:setTag(tag_test)
    tempText:addTouchEventListener(c)
    self.m_topLayer:addChild(tempText)

    tempText = ccui.Text:create()
    tempText:setString("【新手指引】")
    tempText:setFontSize(26)
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(550,self.m_layerSize.height/2)
    tempText:setTouchEnabled(true)
    tempText:setTag(tag_guide)
    tempText:addTouchEventListener(c)
    self.m_topLayer:addChild(tempText)

    self.m_luaLabel=_G.Util:createLabel("",24)
    self.m_luaLabel:setAnchorPoint(cc.p(0,0.5))
    self.m_luaLabel:setPosition(cc.p(20+nWidth/4*3,self.m_layerSize.height/2))
    self.m_topLayer:addChild(self.m_luaLabel)

    self:updateLabel()

    self.m_isHide=true

    self.m_downLayer=cc.LayerColor:create(cc.c4b(0,0,0,160))
    self.m_downLayer:setContentSize(self.m_layerSize)
    self.m_downLayer:setPosition(cc.p(0,-self.m_layerSize.height))
    self.m_rootNode:addChild(self.m_downLayer)
    local moveText = ccui.Text:create()
    moveText:setString("【行走区域】")
    moveText:setFontSize(26)
    moveText:setFontName(_G.FontName.Heiti)
    moveText:setTouchScaleChangeEnabled(true)
    moveText:setPosition(self.m_winSize.width*0.5,self.m_layerSize.height/2)
    moveText:setTouchEnabled(true)
    moveText:setTag(tag_showMoveArea)
    moveText:addTouchEventListener(c)
    self.m_downLayer:addChild(moveText)

    local chuangeSceneText = ccui.Text:create()
    chuangeSceneText:setString("【切换场景】")
    chuangeSceneText:setFontSize(26)
    chuangeSceneText:setFontName(_G.FontName.Heiti)
    chuangeSceneText:setTouchScaleChangeEnabled(true)
    chuangeSceneText:setPosition(cc.p(self.m_winSize.width-70,self.m_layerSize.height/2))
    chuangeSceneText:setTouchEnabled(true)
    chuangeSceneText:setTag(tag_chuangScene)
    chuangeSceneText:addTouchEventListener(c)
    self.m_downLayer:addChild(chuangeSceneText)

    local attackText = ccui.Text:create()
    attackText:setString("【测试副本】")
    attackText:setFontSize(26)
    attackText:setFontName(_G.FontName.Heiti)
    attackText:setTouchScaleChangeEnabled(true)
    attackText:setPosition(cc.p(70,self.m_layerSize.height/2))
    attackText:setTouchEnabled(true)
    attackText:setTag(tag_textCopy)
    attackText:addTouchEventListener(c)
    self.m_downLayer:addChild(attackText)

    if _G.SysInfo:isDevelopType() then
        local cnfText = ccui.Text:create()
        cnfText:setString("【重置CNF表】")
        cnfText:setFontSize(26)
        cnfText:setFontName(_G.FontName.Heiti)
        cnfText:setTouchScaleChangeEnabled(true)
        cnfText:setPosition(self.m_winSize.width*0.5-200,self.m_layerSize.height/2)
        cnfText:setTouchEnabled(true)
        cnfText:setTag(tag_reloadCnf)
        cnfText:addTouchEventListener(c)
        self.m_downLayer:addChild(cnfText)

        local luaFileText = ccui.Text:create()
        luaFileText:setString("【清Lua文件】")
        luaFileText:setFontSize(26)
        luaFileText:setFontName(_G.FontName.Heiti)
        luaFileText:setTouchScaleChangeEnabled(true)
        luaFileText:setPosition(self.m_winSize.width*0.5+200,self.m_layerSize.height/2)
        luaFileText:setTouchEnabled(true)
        luaFileText:setTag(tag_clearLuaFile)
        luaFileText:addTouchEventListener(c)
        self.m_downLayer:addChild(luaFileText)

        self.m_disparkHelper=require("mod.support.DisparkHelper")()
    end

    self.m_leftSize=cc.size(60,640)
    self.m_leftLayer=cc.LayerColor:create(cc.c4b(0,0,0,160))
    self.m_leftLayer:setContentSize(self.m_leftSize)
    self.m_leftLayer:setPosition(cc.p(-self.m_leftSize.width,0))
    self.m_rootNode:addChild(self.m_leftLayer,-1)
    local midPosX=self.m_leftSize.width*0.5
    local zhenText = ccui.Text:create()
    zhenText:setString("[30]")
    zhenText:setFontSize(26)
    zhenText:setFontName(_G.FontName.Heiti)
    zhenText:setTouchScaleChangeEnabled(true)
    zhenText:setPosition(midPosX,512)
    zhenText:setTouchEnabled(true)
    zhenText:setTag(30)
    zhenText:addTouchEventListener(c)
    self.m_leftLayer:addChild(zhenText)

    zhenText = ccui.Text:create()
    zhenText:setString("[40]")
    zhenText:setFontSize(26)
    zhenText:setFontName(_G.FontName.Heiti)
    zhenText:setTouchScaleChangeEnabled(true)
    zhenText:setPosition(midPosX,384)
    zhenText:setTouchEnabled(true)
    zhenText:setTag(40)
    zhenText:addTouchEventListener(c)
    self.m_leftLayer:addChild(zhenText)

    zhenText = ccui.Text:create()
    zhenText:setString("[50]")
    zhenText:setFontSize(26)
    zhenText:setFontName(_G.FontName.Heiti)
    zhenText:setTouchScaleChangeEnabled(true)
    zhenText:setPosition(midPosX,256)
    zhenText:setTouchEnabled(true)
    zhenText:setTag(50)
    zhenText:addTouchEventListener(c)
    self.m_leftLayer:addChild(zhenText)

    zhenText = ccui.Text:create()
    zhenText:setString("[60]")
    zhenText:setFontSize(26)
    zhenText:setFontName(_G.FontName.Heiti)
    zhenText:setTouchScaleChangeEnabled(true)
    zhenText:setPosition(midPosX,128)
    zhenText:setTouchEnabled(true)
    zhenText:setTag(60)
    zhenText:addTouchEventListener(c)
    self.m_leftLayer:addChild(zhenText)

    if _G.IsShwoStagePoolInfo then
        self:showStagePoolInfo()
    end

    if _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_KOF and _G.IS_PVP_NEW_DDX then
        local tempLabel=_G.Util:createBorderLabel("PVP机制测试版",24)
        tempLabel:setAnchorPoint(cc.p(1,1))
        tempLabel:setPosition(self.m_winSize.width-20,self.m_winSize.height-35)
        self.m_rootNode:addChild(tempLabel)
    end
end

local __MenoryManager=gc.MemoryManager:getInstance()
local __MB=1024*1024
function UIMemory.updateLabel(self)
    if self.m_totalLabel~=nil then
        local totalMemory=__MenoryManager:getTotalMemory()/__MB
        self.m_totalLabel:setString(string.format("总内存:%.2fMB",totalMemory))
    end
    if self.m_usedLabel~=nil then
        local usedMemory=__MenoryManager:getUsedMemory()/__MB
        self.m_usedLabel:setString(string.format("已使用内存:%.2fMB",usedMemory))
    end
    if self.m_freeLabel~=nil then
        local freeMemory=__MenoryManager:getFreeMemory()/__MB
        self.m_freeLabel:setString(string.format("空闲内存:%.2fMB",freeMemory))
    end
	if self.m_luaLabel~=nil then
        local luaMemory=collectgarbage("count")/1024
        self.m_luaLabel:setString(string.format("lua使用内存:%.2fMB",luaMemory))
    end
end

function UIMemory.layerAction(self)
	if self.m_isHide then
		self.m_topLayer:stopAllActions()
		self.m_topLayer:runAction(cc.MoveTo:create(0.15,cc.p(0,640-self.m_layerSize.height)))
        self.m_downLayer:stopAllActions()
        self.m_downLayer:runAction(cc.MoveTo:create(0.15,cc.p(0,0)))
        -- self.m_leftLayer:stopAllActions()
        -- self.m_leftLayer:runAction(cc.MoveTo:create(0.15,cc.p(0,0)))

		self.m_isHide=false
        self:startScheduler()
	else
		self.m_topLayer:stopAllActions()
		self.m_topLayer:runAction(cc.MoveTo:create(0.15,cc.p(0,640)))
        self.m_downLayer:stopAllActions()
        self.m_downLayer:runAction(cc.MoveTo:create(0.15,cc.p(0,-self.m_layerSize.height)))
        -- self.m_leftLayer:stopAllActions()
        -- self.m_leftLayer:runAction(cc.MoveTo:create(0.15,cc.p(-self.m_leftSize.width,0)))

		self.m_isHide=true
        self:stopScheduler()
	end
end

function UIMemory.startScheduler(self)
	if self.m_scheduler~=nil then return end

	local function c()
		self:updateLabel()
	end
	self.m_scheduler=_G.Scheduler:schedule(c,1)
end
function UIMemory.stopScheduler(self)
	if self.m_scheduler~=nil then
		_G.Scheduler:unschedule(self.m_scheduler)
		self.m_scheduler=nil
	end
end

function UIMemory.showTexture(self)
    self:removeTextureLayer()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_textureLayer=cc.Layer:create()
    self.m_textureLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_textureLayer)
    self.m_rootNode:addChild(self.m_textureLayer)
    
    local bgSize =cc.size(self.m_winSize.width-40,600)
    local scoSize=cc.size(bgSize.width-50,bgSize.height-50)

    local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    bgSpr:setContentSize(bgSize)
    bgSpr:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_textureLayer:addChild(bgSpr)

    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(cc.p(self.m_winSize.width/2-scoSize.width/2,320-scoSize.height/2))
    self.m_textureLayer:addChild(scoView)

    local szTextureInfo=cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    local infoLabel=_G.Util:createLabel(szTextureInfo,20)
    infoLabel:setDimensions(scoSize.width,0)
    infoLabel:setAnchorPoint(cc.p(0,0))
    infoLabel:setPosition(cc.p(0,0))
    infoLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    scoView:addChild(infoLabel)

    local infoSize=infoLabel:getContentSize()
    if infoSize.height>scoSize.height then
        scoView:setContentSize(infoSize)
        -- scoView:setContentOffset(cc.p(0,scoSize.height-infoSize.height),false)
    else
        scoView:setContentSize(scoSize)
    end

    local barView=require("mod.general.ScrollBar")(scoView)
    barView:setPosOff(cc.p(10,0))
    barView:setMoveHeightOff(20)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeTextureLayer()
        end
    end

    local szNormal="general_close.png"
    local button=gc.CButton:create()
    button:setTouchEnabled(true)
    button:loadTextures(szNormal)
    button:setAnchorPoint(cc.p(1,1))
    button:setPosition(cc.p(self.m_winSize.width,self.m_winSize.height))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_textureLayer:addChild(button)
end
function UIMemory.removeTextureLayer(self)
    if self.m_textureLayer~=nil then
        self.m_textureLayer:removeFromParent(true)
        self.m_textureLayer=nil
    end
end

function UIMemory.showGuideArray(self)
    self:removeGuideView()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_guideLayer=cc.Layer:create()
    self.m_guideLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_guideLayer)
    self.m_rootNode:addChild(self.m_guideLayer)
    
    local bgSize =cc.size(600,400)
    local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    bgSpr:setContentSize(bgSize)
    bgSpr:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_guideLayer:addChild(bgSpr)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag=sender:getTag()
            if nTag==0 then
                _G.GGuideManager:removeGuide()
            else
                local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_RECEIVE)
                command.touchId=nTag
                _G.controller:sendCommand(command)
            end
        end
    end

    local scoSize=cc.size(bgSize.width,bgSize.height-20)
    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(cc.p(self.m_winSize.width/2-scoSize.width/2,320-scoSize.height/2))
    self.m_guideLayer:addChild(scoView)

    local nCount=0
    for k,v in pairs(_G.Cfg.guide) do
        nCount=nCount+1
    end
    local oneHeight=scoSize.height*0.1
    local allHeight=nCount*oneHeight
    allHeight=allHeight<scoSize.height and scoSize.height or allHeight
    scoView:setContentSize(cc.size(scoSize.width,allHeight))
    scoView:setContentOffset(cc.p(0,scoSize.height-allHeight))

    local barView=require("mod.general.ScrollBar")(scoView)
    barView:setPosOff(cc.p(-scoSize.width,0))
    barView:setMoveHeightOff(10)

    local curHeight=allHeight-oneHeight*0.5
    local index=0
    local function nAddBtnFun(_index,_name,_tag)
        local nPosX=scoSize.width*0.5
        
        local tempText=ccui.Text:create()
        tempText:setString(_name)
        tempText:setFontSize(20)
        tempText:setFontName(_G.FontName.Heiti)
        tempText:setTouchScaleChangeEnabled(true)
        tempText:setPosition(nPosX,curHeight)
        tempText:setTouchEnabled(true)
        tempText:setTag(_tag)
        tempText:addTouchEventListener(c)
        scoView:addChild(tempText)
        curHeight=curHeight-oneHeight
    end
    for k,v in pairs(_G.Cfg.guide) do
        index=index+1
        local szName=string.format("[%s]",v.name)
        nAddBtnFun(index,szName,v.drive_id)
    end
    -- index=index+1
    -- nAddBtnFun(index,"[清除指引]",0)

    local tempText=ccui.Text:create()
    tempText:setString("[清除指引]")
    tempText:setFontSize(20)
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(bgSize.width-60,20)
    tempText:setTouchEnabled(true)
    tempText:setTag(0)
    tempText:addTouchEventListener(c)
    bgSpr:addChild(tempText)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeGuideView()
        end
    end

    local szNormal="general_close.png"
    local button=gc.CButton:create()
    button:setTouchEnabled(true)
    button:loadTextures(szNormal)
    button:setAnchorPoint(cc.p(1,1))
    button:setPosition(cc.p(bgSize.width,bgSize.height))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    bgSpr:addChild(button)
end
function UIMemory.removeGuideView(self)
    if self.m_guideLayer~=nil then
        self.m_guideLayer:removeFromParent(true)
        self.m_guideLayer=nil
    end
end

function UIMemory.showTestView(self)
    self:removeTestView()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_testLayer=cc.Layer:create()
    self.m_testLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_testLayer)
    self.m_rootNode:addChild(self.m_testLayer)
    
    local bgSize =cc.size(600,400)
    local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    bgSpr:setContentSize(bgSize)
    bgSpr:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_testLayer:addChild(bgSpr)

    local scoSize=cc.size(bgSize.width,bgSize.height-80)
    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(cc.p(self.m_winSize.width/2-scoSize.width/2,320-scoSize.height+bgSize.height*0.5-10))
    self.m_testLayer:addChild(scoView)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag=sender:getTag()
            if nTag==1 then
                _G.g_Stage:registerEnterFrameCallBack()
            elseif nTag==2 then
                _G.g_Stage:removeFrameCallBack()
            elseif nTag==3 then
                if next(_G.CharacterManager.m_lpNpcArray)~=nil then return end
                _G.StageXMLManager:addNPC(_G.g_Stage:getScenesID())
            elseif nTag==4 then
                for k,v in pairs(_G.CharacterManager.m_lpNpcArray) do
                    v:releaseResource()
                    _G.CharacterManager:remove(v)
                end
            elseif nTag==5 then
                _G.g_Stage:loadMap()
            elseif nTag==6 then
                _G.g_Stage:unloadMap()
            elseif nTag==7 then
                self:hideAll()
            elseif nTag==8 then
                self:changeSpeed()
            elseif nTag==9 then
                self:ruler()
            elseif nTag==10 then
                gc.TcpClient:getInstance():close()
            elseif nTag==11 then
                LOG_CLOSE()
            elseif nTag==12 then
                LOG_OPEN()
            elseif nTag==13 then
                _G.g_Stage:getMainPlayer().setSP=function (  ) end
            elseif nTag==14 then
                -- if _G.StageXMLManager.m_noHurtEffect then 
                --     _G.StageXMLManager.m_noHurtEffect=nil
                -- else
                --     _G.StageXMLManager.m_noHurtEffect=true
                -- end
                if not self.m_setStopAI then
                    for i,v in pairs(_G.CharacterManager[_G.Const.CONST_MONSTER]) do
                        v :setAI(0)
                    end
                    self.m_setStopAI=true
                else
                    for i,v in pairs(_G.CharacterManager[_G.Const.CONST_MONSTER]) do
                        v :setAI()
                    end
                    self.m_setStopAI=false
                end
            elseif nTag==15 then
                cc.Director:getInstance():setDisplayStats(false)
            elseif nTag==16 then
                cc.Director:getInstance():setDisplayStats(true)
            elseif nTag==17 then
                local nView=require("mod.support.UISceneTest")()
                local tempScene=nView:create()
                cc.Director:getInstance():pushScene(tempScene)
            elseif nTag==18 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    v.setHP=function() end
                end
            elseif nTag==19 then
                _G.controller.m_isCanNotConnect=true
                gc.TcpClient:getInstance():close()
            elseif nTag==20 then
                if self.m_handleSkillFrameBuff==nil then
                    self.m_handleSkillFrameBuff=_G.g_Stage:getMainPlayer().handleSkillFrameBuff
                    _G.g_Stage:getMainPlayer().handleSkillFrameBuff=function () end
                else
                    _G.g_Stage:getMainPlayer().handleSkillFrameBuff=self.m_handleSkillFrameBuff
                    self.m_handleSkillFrameBuff=nil
                end
            elseif nTag==21 then
                if self.m_playAudioEffect==nil then
                    self.m_playAudioEffect=_G.Util.playAudioEffect
                    _G.Util.playAudioEffect=function () end
                else
                    _G.Util.playAudioEffect=self.m_playAudioEffect
                    self.m_playAudioEffect=nil
                end
            elseif nTag==22 then
                if self.m_playBattleEffect==nil then
                    self.m_playBattleEffect=_G.Util.playBattleEffect
                    _G.Util.playBattleEffect=function () end
                else
                    _G.Util.playBattleEffect=self.m_playBattleEffect
                    self.m_playBattleEffect=nil
                end
            elseif nTag==23 then
                self:showStagePoolInfo()
                _G.IsShwoStagePoolInfo=true
            elseif nTag==24 then
                self:hideStagePoolInfo()
                _G.IsShwoStagePoolInfo=false
            elseif nTag==25 then
                _G.IS_PVP_NEW_DDX=false
            elseif nTag==26 then
                _G.IS_PVP_NEW_DDX=true
            elseif nTag==27 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    if v.blockLayer~=nil then
                        v.blockLayer:setVisible(true)
                    end
                    if v.aiBlockLayer~=nil then
                        v.aiBlockLayer:setVisible(true)
                    end
                    if v.m_attLayer~=nil then
                        v.m_attLayer:setVisible(true)
                        v.m_noAtt=true
                    end
                end
            elseif nTag==28 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    if v.blockLayer~=nil then
                        v.blockLayer:setVisible(false)
                    end
                    if v.aiBlockLayer~=nil then
                        v.aiBlockLayer:setVisible(false)
                    end
                    if v.m_attLayer~=nil then
                        v.m_attLayer:setVisible(false)
                        v.m_noAtt=false
                    end
                end
            elseif nTag==29 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    if v.blockLayer~=nil then
                        v.blockLayer:setVisible(true)
                    end
                    if v.aiBlockLayer~=nil then
                        v.aiBlockLayer:setVisible(false)
                    end
                    if v.m_attLayer~=nil then
                        v.m_attLayer:setVisible(false)
                        v.m_noAtt=false
                    end
                end
            elseif nTag==30 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    if v.blockLayer~=nil then
                        v.blockLayer:setVisible(false)
                    end
                    if v.aiBlockLayer~=nil then
                        v.aiBlockLayer:setVisible(false)
                    end
                    if v.m_attLayer~=nil then
                        v.m_attLayer:setVisible(true)
                        v.m_noAtt=true
                    end
                end
            elseif nTag==31 then
                for _,v in pairs(_G.CharacterManager:getCharacter()) do
                    if v.blockLayer~=nil then
                        v.blockLayer:setVisible(false)
                    end
                    if v.aiBlockLayer~=nil then
                        v.aiBlockLayer:setVisible(true)
                    end
                    if v.m_attLayer~=nil then
                        v.m_attLayer:setVisible(false)
                        v.m_noAtt=false
                    end
                end
            elseif nTag==32 then
                _G.IsHideSkillEffect=true
            else
                local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_RECEIVE)
                command.touchId=nTag
                _G.controller:sendCommand(command)
            end
        end
    end

    local tempArray={
        [1]=[[开启场景Update]],
        [2]=[[关闭场景Update]],
        [3]=[[加入NPC]],
        [4]=[[清除NPC]],
        [5]=[[开启地图]],
        [6]=[[关闭地图]],
        [7]=[[隐藏助手]],
        [8]=[[变速]],
        [9]=[[标尺]],
        [10]=[[断线]],
        [11]=[[关闭LOG]],
        [12]=[[开启LOG]],
        [13]=[[无限蓝]],
        [14]=[[AI]],
        [15]=[[关闭渲染状态]],
        [16]=[[开启渲染状态]],
        [17]=[[Spine场景]],
        [18]=[[无伤]],
        [19]=[[测试-永久断线]],
        [20]=[[测试-handleSkillFrameBuff]],
        [21]=[[测试-playAudioEffect]],
        [22]=[[测试-playBattleEffect]],
        [23]=[[对象池-显示]],
        [24]=[[对象池-隐藏]],
        [25]=[[PVP原始机制]],
        [26]=[[PVP测试机制]],
        [27]=[[显示所有战斗区域]],
        [28]=[[隐藏所有战斗区域]],
        [29]=[[显示受击区域]],
        [30]=[[显示攻击区域]],
        [31]=[[显示AI区域]],
        [32]=[[关闭技能特效]],
    }
    local nCount=#tempArray

    local oneHeight=scoSize.height*0.13
    local allHeight=(nCount+1)*math.ceil(oneHeight*0.5)
    allHeight=allHeight<scoSize.height and scoSize.height or allHeight
    scoView:setContentSize(cc.size(scoSize.width,allHeight))
    scoView:setContentOffset(cc.p(0,scoSize.height-allHeight))

    local barView=require("mod.general.ScrollBar")(scoView)
    barView:setPosOff(cc.p(-scoSize.width,0))
    barView:setMoveHeightOff(10)

    local curHeight=allHeight-oneHeight*0.5
    local index=0
    local function nAddBtnFun(_name,_tag)
        local nnnnn=_tag%2
        local nPosX=nnnnn==1 and scoSize.width*0.25 or scoSize.width*0.75
        
        local tempText=ccui.Text:create()
        tempText:setFontName(_G.FontName.Heiti)
        tempText:setFontSize(20)
        tempText:setString(_name)
        tempText:setTouchScaleChangeEnabled(true)
        tempText:setPosition(nPosX,curHeight)
        tempText:setTouchEnabled(true)
        tempText:setTag(_tag)
        tempText:addTouchEventListener(c)
        scoView:addChild(tempText)

        if nnnnn==0 then
            curHeight=curHeight-oneHeight
        end
    end
    for i=1,nCount do
        nAddBtnFun(tempArray[i],i)
    end


    local lpTextField=nil
    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            return true
        elseif eventType == ccui.TouchEventType.ended then
            local nTag=sender:getTag()
            if nTag==1 then
                local szString=lpTextField:getString()
                local monsterId=tonumber(szString)
                if monsterId==nil then
                    return
                end
                -- for i=1,monsterId do
                --     _G.g_Stage:getMainPlayer():showCritHurtNumber(5556)
                -- end
                -- do return end

                if _G.Cfg.scene_monster[monsterId]==nil then
                    -- local command=CErrorBoxCommand("没有此怪物!!!")
                    -- _G.controller:sendCommand(command)
                    CCMessageBox("没有此怪物!!!","提示")
                    return
                end
                local nX,nY=_G.g_Stage:getMainPlayer():getLocationXY()
                local monsterArray={}
                monsterArray[1]={[1]=monsterId,[4]=nX+100,[5]=nY,[2]=_G.Const.CONST_DRAMA_DIR_WEST,[6]=nil}
                _G.StageXMLManager:addMonsterByIDList(monsterArray)
            elseif nTag==2 then
                RESTART_GAME(_G.Const.kResetGameTypeChuangAccount)
            elseif nTag==3 then
                _G.GSystemProxy.isInfinityPlot=true
            else
                self:removeTestView()
            end
        end
    end

    local tempHeight=self.m_winSize.height/2 - bgSize.height*0.5 + 25
    local lpSize=cc.size(110,30)
    local ntLabel=_G.Util:createLabel("创建怪物:",20)
    ntLabel:setAnchorPoint(cc.p(1,0.5))
    ntLabel:setPosition(self.m_winSize.width/2-lpSize.width*0.5,tempHeight)
    self.m_testLayer:addChild(ntLabel,10)

    local contentSpri=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    contentSpri:setPreferredSize(lpSize)
    contentSpri:setPosition(self.m_winSize.width/2,tempHeight)
    self.m_testLayer:addChild(contentSpri,10)

    lpTextField=ccui.TextField:create()
    lpTextField:setTouchEnabled(true)
    lpTextField:setFontName(_G.FontName.Heiti)
    lpTextField:setFontSize(19)
    lpTextField:setPlaceHolder("id")
    lpTextField:setMaxLengthEnabled(true)
    lpTextField:setMaxLength(6)
    lpTextField:setAnchorPoint(cc.p(0,0.5))
    lpTextField:setPosition(0,lpSize.height*0.5)
    lpTextField:ignoreContentAdaptWithSize(false)
    lpTextField:setContentSize(lpSize)
    contentSpri:addChild(lpTextField,10)

    local sendBtnRes = "general_btn_gold.png"   
    local sendButton=gc.CButton:create(sendBtnRes)
    sendButton:setPosition(self.m_winSize.width/2+lpSize.width*0.5+10,tempHeight)
    sendButton:setTitleText("创 建")
    sendButton:setTitleFontSize(26)
    sendButton:setTitleFontName(_G.FontName.Heiti)
    sendButton:addTouchEventListener(c)
    sendButton:setTag(1)
    sendButton:setButtonScale(0.7)
    self.m_testLayer:addChild(sendButton,10)

    local tempText=ccui.Text:create()
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setFontSize(24)
    tempText:setString("切换帐号")
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(self.m_winSize.width/2 + bgSize.width*0.5 - 60,tempHeight)
    tempText:setTouchEnabled(true)
    tempText:setTag(2)
    tempText:addTouchEventListener(c)
    self.m_testLayer:addChild(tempText,10)

    local tempText=ccui.Text:create()
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setFontSize(24)
    tempText:setString("无限剧情")
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(self.m_winSize.width/2 - bgSize.width*0.5 + 60,tempHeight)
    tempText:setTouchEnabled(true)
    tempText:setTag(3)
    tempText:addTouchEventListener(c)
    self.m_testLayer:addChild(tempText,10)

    local szNormal="general_close.png"
    local button=gc.CButton:create()
    button:setTouchEnabled(true)
    button:loadTextures(szNormal)
    button:setAnchorPoint(cc.p(1,1))
    button:setPosition(cc.p(self.m_winSize.width/2+bgSize.width*0.5,self.m_winSize.height/2+bgSize.height*0.5))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_testLayer:addChild(button)
end

function UIMemory.hideAll(self )
    local text = self.m_rootNode:getChildByTag(1)
    self:layerAction()
    text:setVisible(false)
    local text = _G.pmainView.m_rootNode:getChildByTag(4)
    text:setVisible(false)
    local text = _G.pmainView.m_rootNode:getChildByTag(5)
    text:setVisible(false)
end
function UIMemory.changeSpeed(self )
    local num = cc.Director:getInstance():getScheduler():getTimeScale()
    if num == 1 then
        num = 0.1
    else
        num = num + 0.45
    end
    cc.Director:getInstance():getScheduler():setTimeScale(num)
end

function UIMemory.removeTestView(self)
    if self.m_testLayer~=nil then
        self.m_testLayer:removeFromParent(true)
        self.m_testLayer=nil
    end
end
function UIMemory.ruler(self)
    if not self.m_showRuler then
        self.m_showRuler=true
        _G.g_Stage:showRuler()
    else
        _G.g_Stage:hideRuler()
        self.m_showRuler=nil
    end
end

function UIMemory.setDelayFPS(self,_FPS)
    -- if _FPS>10000 then
    --     print("setDelayFPS=====>>>>????",debug.traceback())
    -- end
    local szMsg=string.format("FPS:%d",_FPS)
    if not self.m_fpsLabel then
        self.m_fpsLabel=_G.Util:createBorderLabel(szMsg,20)
        self.m_fpsLabel:setPosition(self.m_winSize.width-70,620)
        self.m_rootNode:addChild(self.m_fpsLabel)
    else
        self.m_fpsLabel:setString(szMsg)
    end
end

function UIMemory.showStagePoolInfo(self)
    if self.m_stagePoolInfoScheduler then
        return
    end

    self.m_stagePoolInfoNode=cc.Node:create()
    self.m_stagePoolInfoNode:setPosition(self.m_winSize.width-250,625)
    self.m_rootNode:addChild(self.m_stagePoolInfoNode,5)

    local tempY,tempHei=0,30
    local uLabel1=_G.Util:createBorderLabel("",24)
    uLabel1:setAnchorPoint(cc.p(0,1))
    uLabel1:setPosition(0,tempY)
    -- uLabel1:setColor(_G.)
    self.m_stagePoolInfoNode:addChild(uLabel1)

    tempY=tempY-tempHei
    local uLabel2=_G.Util:createBorderLabel("",24)
    uLabel2:setAnchorPoint(cc.p(0,1))
    uLabel2:setPosition(0,tempY)
    self.m_stagePoolInfoNode:addChild(uLabel2)

    local function c()
        local totalCount,tempArray1,tempArray2,tempCount1,tempCount2=_G.StageObjectPool:getArrayByTotal(false)
        uLabel1:setString(string.format("USED: R:%d,W:%d,T:%d",tempCount2,tempCount1,totalCount))

        local totalCount,tempArray1,tempArray2,tempCount1,tempCount2=_G.StageObjectPool:getArrayByTotal(true)
        uLabel2:setString(string.format("FREE: R:%d,W:%d,T:%d",tempCount2,tempCount1,totalCount))
    end
    self.m_stagePoolInfoScheduler=_G.Scheduler:schedule(c,0.5)

    tempY=tempY-tempHei-15
    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:__showStagePoolInfoDetail()
        end
    end
    local tempText=ccui.Text:create()
    tempText:setString("【详情】")
    tempText:setFontSize(24)
    tempText:setFontName(_G.FontName.Heiti)
    tempText:setTouchScaleChangeEnabled(true)
    tempText:setPosition(80,tempY)
    tempText:setTouchEnabled(true)
    tempText:addTouchEventListener(c)
    tempText:enableOutline(cc.c4b(0,0,0,255),1)
    self.m_stagePoolInfoNode:addChild(tempText)
end
function UIMemory.hideStagePoolInfo(self)
    if not self.m_stagePoolInfoScheduler then
        return
    end

    self.m_stagePoolInfoNode:removeFromParent(true)
    self.m_stagePoolInfoNode=nil

    _G.Scheduler:unschedule(self.m_stagePoolInfoScheduler)
    self.m_stagePoolInfoScheduler=nil
end
function UIMemory.__hideStagePoolInfoDetail(self)
    if self.m_detailStagePoolInfoNode then
        self.m_detailStagePoolInfoNode:removeFromParent(true)
        self.m_detailStagePoolInfoNode=nil
    end
end
function UIMemory.__showStagePoolInfoDetail(self)
    self:__hideStagePoolInfoDetail()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_detailStagePoolInfoNode=cc.Layer:create()
    self.m_detailStagePoolInfoNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_detailStagePoolInfoNode)
    self.m_rootNode:addChild(self.m_detailStagePoolInfoNode)
    
    local bgSize =cc.size(600,400)
    local scoSize=cc.size(bgSize.width-50,bgSize.height-50)
    local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    bgSpr:setContentSize(bgSize)
    bgSpr:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_detailStagePoolInfoNode:addChild(bgSpr)

    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(cc.p(self.m_winSize.width/2-scoSize.width/2,320-scoSize.height/2))
    self.m_detailStagePoolInfoNode:addChild(scoView)

    local totalCount,tempArray1,tempArray2,tempCount1,tempCount2=_G.StageObjectPool:getArrayByTotal(false)
    local szMsgArray={}
    szMsgArray[#szMsgArray+1]="****************************"
    szMsgArray[#szMsgArray+1]=string.format("使用中的对象:totalCount=%d",totalCount)
    for k,v in pairs(tempArray1) do
        szMsgArray[#szMsgArray+1]=string.format("resName=%s,count=%d,有问题,对象处于空闲状态。",k,v)
    end
    for k,v in pairs(tempArray2) do
        szMsgArray[#szMsgArray+1]=string.format("resName=%s,count=%d,状态正常,使用中。",k,v)
    end
    szMsgArray[#szMsgArray+1]="****************************"

    local totalCount,tempArray1,tempArray2,tempCount1,tempCount2=_G.StageObjectPool:getArrayByTotal(true)
    szMsgArray[#szMsgArray+1]=string.format("空闲中的对象:totalCount=%d",totalCount)
    for k,v in pairs(tempArray1) do
        szMsgArray[#szMsgArray+1]=string.format("resName=%s,count=%d,有问题,对象处于使用状态。",k,v)
    end
    for k,v in pairs(tempArray2) do
        szMsgArray[#szMsgArray+1]=string.format("resName=%s,count=%d,状态正常,空闲中。",k,v)
    end
    szMsgArray[#szMsgArray+1]="****************************"

    local maxHeight=0
    local tempNode=cc.Node:create()
    for i=1,#szMsgArray do
        local szMsg=szMsgArray[i]
        print(szMsg)

        local infoLabel=_G.Util:createLabel(szMsg,20)
        infoLabel:setAnchorPoint(cc.p(0,1))
        infoLabel:setPosition(0,-maxHeight)
        tempNode:addChild(infoLabel)

        maxHeight=maxHeight+infoLabel:getContentSize().height+3
    end
    scoView:addChild(tempNode)
    tempNode:setPosition(0,maxHeight)

    if maxHeight>scoSize.height then
        scoView:setContentSize(cc.size(scoSize.width,maxHeight))
        scoView:setContentOffset(cc.p(0,scoSize.height-maxHeight),false)
    else
        scoView:setContentSize(scoSize)
    end

    local barView=require("mod.general.ScrollBar")(scoView)
    barView:setPosOff(cc.p(10,0))
    barView:setMoveHeightOff(20)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:__hideStagePoolInfoDetail()
        end
    end

    local szNormal="general_close.png"
    local button=gc.CButton:create()
    button:setTouchEnabled(true)
    button:loadTextures(szNormal)
    button:setAnchorPoint(cc.p(1,1))
    button:setPosition(cc.p(bgSize.width,bgSize.height))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    bgSpr:addChild(button)
end

return UIMemory


