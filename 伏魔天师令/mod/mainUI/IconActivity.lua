local IconPosTypeArray={
    [_G.Const.kMainIconPos5]=true,
    [_G.Const.kMainIconPos6]=true,
}
local LimitOutsideArray=clone(_G.GOpenProxy.LimitOutsideArray)

local LimitInsideArray={}
local BigSysArray={}
for k,v in pairs(_G.Cfg.funshow) do
    local arrayCnf=_G.Cfg.sys_open_array[k]
    if arrayCnf==nil then
        local infoCnf=_G.Cfg.sys_open_info[k]
        BigSysArray[k]=infoCnf and infoCnf.name or "未配置1"
    else
        BigSysArray[k]=arrayCnf.name or "未配置2"
    end
    for kk,vv in pairs(v.activity) do
        if vv.xiaoshi==1 then
            LimitInsideArray[kk]=true
            LimitOutsideArray[kk]=nil
        end
    end
end

local IconActivity=classGc(view,function(self,_mainDelegate)
	self.m_leftIconArray={}
	self.m_upIconArray  ={}
	self.m_leftIconCount=0
	self.m_upIconCount  =0
    self.m_iconNumArray ={}

    self.m_effectAarray={}

    self.m_guideDataArray={}

    self.m_mainDelegate=_mainDelegate
	self.m_winSize=cc.Director:getInstance():getWinSize()
    -- self.m_nScale=1
    -- if self.m_winSize.width<960 then
    --     self.m_nScale=854/self.m_winSize.height
    -- end
end)

function IconActivity.create(self)
	self.m_rootNode=cc.Node:create()

	self:init()
	return self.m_rootNode
end

function IconActivity.init(self)
	self:initView()
	self:initIconButton()
    self:initGuideButton()
    self:setRoleBuffIcon()
    self:initRewardButton()
    self:checkOpenInfoUpdate()
end

function IconActivity.initView(self)
	self.m_leftContainer=cc.Node:create()
	self.m_upContainer=cc.Node:create()
	self.m_rootNode:addChild(self.m_leftContainer)
	self.m_rootNode:addChild(self.m_upContainer)
end

function IconActivity.getIconBtnById(self,_sysId)
    local arrayT=_G.Cfg.sys_open_array[_sysId]
    if arrayT==nil then
        for parentId,v in pairs(_G.Cfg.funshow) do
            for subId,_ in pairs(v.activity) do
                if subId==_sysId then
                    if self.m_upIconArray[parentId] then
                        return self.m_upIconArray[parentId].btn,parentId
                    end
                    return nil
                end
            end
        end
        return nil
    end

    local posType=arrayT.type
    if not IconPosTypeArray[posType] then return nil end

    if posType==_G.Const.kMainIconPos5 then
        if self.m_upIconArray[_sysId] then
            return self.m_upIconArray[_sysId].btn
        end
    elseif self.m_leftIconArray[_sysId] then
        return self.m_leftIconArray[_sysId].btn
    end
end

function IconActivity.getSortSysArray(self,_hasLimitSys)
    local arrayT=_G.Cfg.sys_open_array
    local newArray={}
    local saveIdArray={}
    local curCount=0
    for k,v in pairs(self.m_sysList) do
        local dataT=arrayT[k]
        if dataT~=nil then
            local posType=dataT.type
            if IconPosTypeArray[posType] then
                curCount=curCount+1
                newArray[curCount]=v
                newArray[curCount].array=dataT.array
                newArray[curCount].type=posType
                saveIdArray[k]=true
            end
        end
    end
    if _hasLimitSys then
        local limitSysList=self.m_sysLimitList
        for sysId,number in pairs(limitSysList) do
            if not saveIdArray[sysId] then
                curCount=curCount+1
                newArray[curCount]={}
                newArray[curCount].id=sysId
                newArray[curCount].array=100
                newArray[curCount].type=_G.Const.kMainIconPos5
                saveIdArray[sysId]=true
            end
        end
    end

    local function local_sort(v1,v2)
        if v1.array==v2.array then
            return v1.id<v2.id
        else
            return v1.array<v2.array
        end
    end
    table.sort( newArray, local_sort )
    return newArray
end

function IconActivity.initIconButton(self)
	self.m_sysList=_G.GOpenProxy:getSysId() --功能按钮id
	self.m_sysLimitList=_G.GOpenProxy:getLimitId()
    local resList=_G.Cfg.IconResList

    local newSys=self:getSortSysArray(false)
    for i=1,#newSys do
        local value=newSys[i]
        local sysId=value.id
        local szImg=resList[sysId]
        if szImg~=nil then
            if value.type==_G.Const.kMainIconPos6 then
                self:addLeftBtn(sysId,szImg,value.state,value.number)
            else
                self:addUpBtn(sysId,szImg,value.state,value.number)
            end
        end
    end
	self:addAllLimitBtn()
end

function IconActivity.addAllLimitBtn(self)
    for key,number in pairs(self.m_sysLimitList) do
        -- print("addAllLimitTimeBtn---->>>>",key)
        self :addOneLimitBtn(key,number)
    end
end

function IconActivity.addOneLimitBtn(self,_id,_number)
	if LimitOutsideArray[_id]==nil then return end
    local szImg=_G.Cfg.IconResList[_id]
    if szImg==nil then return end
    if LimitOutsideArray[_id]==_G.Const.kMainIconPos5 then
	   self:addUpBtn(_id,szImg,_G.Const.CONST_ACTIVITY_YONGJIU,_number)
    else
        self:addLeftBtn(_id,szImg,_G.Const.CONST_ACTIVITY_YONGJIU,_number)
    end
end

function IconActivity.addLeftBtn(self,_id,_szName,_state,_number)
	if self.m_leftIconArray[_id] then
        self:resetSysNumber(_id)
        return
    end
	-- print("addLeftBtn--->>",_id,_szName,_state,_number,debug.traceback())
	
	self.m_leftIconCount=self.m_leftIconCount+1

	local iconT={}
	iconT.id=_id

	local function c(sender,eventType)
        return self:iconClickCallBack(sender,eventType)
    end

	local button = gc.CButton:create(_szName)
    button:setPosition(self:getLeftBtnPos(self.m_leftIconCount))
    button:addTouchEventListener(c)
    button:setTag(_id)
    -- button:setScaleY(0.5)
    self.m_leftContainer:addChild(button)

    iconT.btn=button

    self.m_leftIconArray[_id]=iconT

    self:addEffectsById(_id,_state)
    if _number~=nil and _number~=0 then
        self:resetSysNumber(_id)
    end

    self:initRewardBtnPos()
end
function IconActivity.getLeftBtnPos(self,_idx)
    -- local r=_idx%3
    -- local row=r==0 and math.floor(_idx/3)-1 or math.floor(_idx/3)
    -- local remainder=1-r
    -- local nPosX=50+remainder*90
    -- local nPosY=500-row*90

    -- return nPosX,nPosY

    local rowCount=3
    local r=_idx%rowCount
    r=r==0 and rowCount or r
    local row=r==rowCount and math.floor(_idx/rowCount)-1 or math.floor(_idx/rowCount)
    local nPosX=50+(r-1)*90
    local nPosY=465-row*90
    return nPosX,nPosY
end

function IconActivity.addUpBtn(self,_id,_szName,_state,_number)
	if self.m_upIconArray[_id] then
        self:resetSysNumber(_id)
        return
    end

    self.m_upIconCount=self.m_upIconCount+1
	print("addUpBtn--->>",_id,_szName,_state,_number,self.m_upIconCount)
	
	local iconT={}
	iconT.id=_id

	local function c(sender,eventType)
        return self:iconClickCallBack(sender,eventType)
    end

	local button=gc.CButton:create(_szName)
    button:setPosition(self:getUpBtnPos(self.m_upIconCount))
    button:addTouchEventListener(c)
    button:setTag(_id)
    self.m_upContainer:addChild(button)

    iconT.btn=button

    self.m_upIconArray[_id]=iconT

    self:addEffectsById(_id,_state)
    if _number~=nil and _number~=0 then
        self:resetSysNumber(_id)
    end
end
function IconActivity.getUpBtnPos(self,_idx)
    local rowCount=5
    local r=_idx%rowCount
    r=r==0 and rowCount or r
    local row=r==rowCount and math.floor(_idx/rowCount)-1 or math.floor(_idx/rowCount)
    local nPosX=self.m_winSize.width-50-(r-1)*90
    local nPosY=595-row*90
    return nPosX,nPosY
end

function IconActivity.setRoleBuffIcon(self)
	if  _G.GOpenProxy==nil or self.m_sysList==nil then
        return
    end
    
    local _buffData=_G.GOpenProxy:getEnergyBuffActivityInfo()
    if _buffData ~= nil then
    	local id=_buffData.id
        if id~=nil and _buffData.state~=nil and id==_G.Const.CONST_FUNC_OPEN_ENARGY then
            if _buffData.state == 1 then
                self:removeUpButton(id)
            else
                self.m_sysList[id]       = {}
                self.m_sysList[id].id    = id
                self.m_sysList[id].state = _G.Const.CONST_ACTIVITY_YONGJIU
                self:addUpBtn(id,"main_icon_power.png",self.m_sysList[id].state)
            end
        end
    end
end
function IconActivity.initRewardButton(self)
    if _G.GPropertyProxy:getMainPlay():getLv()>60 then return end

    local function nFun(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            local msg=REQ_LV_REWARD_REWARD_GET()
            _G.Network:send(msg)
        end
    end

    self.m_rewardNode=cc.Node:create()
    self.m_rewardNode:setScale(0.8)
    self.m_leftContainer:addChild(self.m_rewardNode)

    self.m_rewardIconBgSpr=ccui.Widget:create()
    self.m_rewardIconBgSpr:setContentSize(cc.size(85,85))
    -- self.m_rewardIconBgSpr:setTouchEnabled(true)
    self.m_rewardIconBgSpr:setPosition(0,10)
    self.m_rewardNode:addChild(self.m_rewardIconBgSpr)

    --local bgSize=self.m_rewardIconBgSpr:getContentSize()
    --local icondiSpr=cc.Sprite:createWithSpriteFrameName("ui_goods_back_6.png")
    --icondiSpr:setPosition(bgSize.width*0.5,bgSize.height*0.5)
    --self.m_rewardIconBgSpr:addChild(icondiSpr)

    local nPosY=-48
    self.m_rewardBtn=gc.CButton:create("general_btn_gold.png")
    self.m_rewardBtn:setButtonScale(0.65)
    self.m_rewardBtn:setPosition(0,nPosY)
    self.m_rewardBtn:addTouchEventListener(nFun)
    self.m_rewardBtn:setVisible(false)
    self.m_rewardBtn:ignoreContentAdaptWithSize(false)
    self.m_rewardBtn:setContentSize(cc.size(60,60))
    self.m_rewardNode:addChild(self.m_rewardBtn)

    self.m_rewardLab=_G.Util:createBorderLabel("",18,_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_OSTROKE))
    self.m_rewardLab:setPosition(0,nPosY)
    self.m_rewardNode:addChild(self.m_rewardLab)

    self:initRewardBtnPos()
    local msg=REQ_LV_REWARD_REQUEST()
    _G.Network:send(msg)
end
function IconActivity.initRewardBtnPos(self)
    if self.m_rewardNode==nil then return end
    local nPosX,nPosY=self:getLeftBtnPos(self.m_leftIconCount+1)
    self.m_rewardNode:setPosition(nPosX+4,nPosY)
end
function IconActivity.updateRewardButton(self,_lv,_state,_autoo)
    if self.m_rewardNode==nil then return end

    if _lv>60 or _lv==0 then
        self.m_rewardNode:removeFromParent(true)
        self.m_rewardNode=nil
        self.m_rewardIconSpr=nil
        return
    end

    if self.m_rewardIconSpr~=nil then
        self.m_rewardIconSpr:removeFromParent(true)
        self.m_rewardIconSpr=nil
    end

    local lvData=_G.Cfg.lv_reward[_lv]
    if lvData~=nil then
        print("LeftRewardIcon--->",_lv,lvData,self.m_rewardBtn:isVisible())
        local function cFun(sender,eventType)
            if eventType==ccui.TouchEventType.ended then
                if self.m_rewardBtn:isVisible()==true then
                    local msg=REQ_LV_REWARD_REWARD_GET()
                    _G.Network:send(msg)
                else
                    local btn_tag=sender:getTag()
                    local _pos = sender:getWorldPosition()
                    local temp = _G.TipsUtil:createById(btn_tag,nil,_pos)
                    cc.Director:getInstance():getRunningScene():addChild(temp,1000)
                end
            end
        end
        local goodsId=lvData.goods[1]
        local goodsdata=_G.Cfg.goods[goodsId]
        if goodsdata~=nil then
            -- local iconImg=string.format("icon/%d.png",goodsdata.icon)
            -- if not _G.FilesUtil:check(iconImg) then
            --     iconImg="icon/0.png"
            -- end
            self.m_rewardIconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodsId)
            self.m_rewardIconSpr : setPosition(42.5, 42.5)
            self.m_rewardIconBgSpr : addChild(self.m_rewardIconSpr)
            -- self.m_rewardIconBgSpr : setTag(goodsId)
            -- self.m_rewardIconBgSpr : addTouchEventListener(cFun)
        end
        
        if _state==2 then
            self.m_rewardBtn:setVisible(true)
            self.m_rewardLab:setString("")
            
            if self.tempSpine == nil then
            	local szName = "spine/lqtx1"
		        self.tempSpine=_G.SpineManager.createSpine(szName,1)
				self.tempSpine:setPosition(self.m_rewardLab:getPositionX(),self.m_rewardLab:getPositionY()+55)
				self.tempSpine:setAnimation(0,"idle",true)
				self.m_rewardNode:addChild(self.tempSpine,99)
            end

            if self.tempSpine1 == nil then
            	local szName = "spine/lqtx2"
		        self.tempSpine1=_G.SpineManager.createSpine(szName,1)
				self.tempSpine1:setPosition(self.m_rewardLab:getPosition())
				self.tempSpine1:setAnimation(0,"idle",true)
				self.m_rewardNode:addChild(self.tempSpine1,99)
            end

            if _autoo==1 then
                local msg=REQ_LV_REWARD_REWARD_GET()
                _G.Network:send( msg)
            end
        else
        	if self.tempSpine then
        		self.tempSpine : removeFromParent()
        		self.tempSpine = nil
        	end

        	if self.tempSpine1 then
        		self.tempSpine1 : removeFromParent()
        		self.tempSpine1 = nil
        	end

            self.m_rewardBtn:setVisible(false)
            self.m_rewardLab:setString(string.format("%d级可领",lvData.lv))
        end
    end
end
function IconActivity.sysOpenDataChuange(self,_cList)
    local resList=_G.Cfg.IconResList
    local arrayCnf=_G.Cfg.sys_open_array
    local isUpVtn=false
    local isLeftBtn=false
	for _,id in pairs(_cList) do
        local arrayT=arrayCnf[id]
        if arrayT~=nil then
            if arrayT.type==_G.Const.kMainIconPos5 then
                isUpVtn=true
                self:addUpBtn(id,resList[id],self.m_sysList[id].state,self.m_sysList[id].number)
            elseif arrayT.type==_G.Const.kMainIconPos6 then
                isLeftBtn=true
                self:addLeftBtn(id,resList[id],self.m_sysList[id].state,self.m_sysList[id].number)
            end
        end
	end
    if isUpVtn and isLeftBtn then
        local newSys=self:getSortSysArray(true)
        self:resetLeftPos(newSys)
        self:resetUpPos(newSys)
    elseif isUpVtn then
        self:resetUpPos()
    elseif isLeftBtn then
        self:resetLeftPos()
    end
end
function IconActivity.resetSysNumber(self,_id)
    local arrayT=_G.Cfg.sys_open_array[_id]
    if (arrayT==nil or not IconPosTypeArray[arrayT.type]) and not LimitOutsideArray[_id] then
        return
    end

    local tNum=nil
    if self.m_sysList[_id] then
    	tNum=self.m_sysList[_id].number
    elseif self.m_sysLimitList[_id] then
    	tNum=self.m_sysLimitList[_id]
    else
    	return
    end
    
    if tNum==nil or tNum==0 then
        self:removeSysNumber(_id)
        return
    end
    local szNum=tNum>9 and "N" or tostring(tNum)
    
    if self.m_iconNumArray[_id]~=nil then
        self.m_iconNumArray[_id]:getChildByTag(33):setString(szNum)
        return
    end

    local tParent=self.m_upIconArray[_id] or self.m_leftIconArray[_id]
    if tParent==nil then return end

    tParent=tParent.btn
    local numSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
    numSpr:setPosition(65,62)
    tParent:addChild(numSpr,20)

    local sprSize=numSpr:getContentSize()
    local tempLabel=_G.Util:createLabel(szNum,18)
    tempLabel:setTag(33)
    tempLabel:setPosition(sprSize.width*0.5+1.5,sprSize.height*0.5-2)
    numSpr:addChild(tempLabel)

    self.m_iconNumArray[_id]=numSpr
end
function IconActivity.removeSysNumber(self,_id)
    if self.m_iconNumArray[_id]~=nil then
        self.m_iconNumArray[_id]:removeFromParent(true)
        self.m_iconNumArray[_id]=nil
    end
end

function IconActivity.addGuideTouch(self,_sysId)
    if _G.GGuideManager:getCurGuideId() then
        self:hideTaskGuideEffect()
    end

    local sysBtn,parentId=self:getIconBtnById(_sysId)
    if sysBtn==nil then return end

    if parentId==nil then
        if self.m_guideDataArray[_sysId]~=nil then return end
    else
        if self.m_guideDataArray[parentId]~=nil then
            self.m_guideDataArray[parentId].subArray[_sysId]=true
            return
        end
    end

    sysBtn:setLocalZOrder(0)
    sysBtn:setLocalZOrder(1)
    local btnSize=sysBtn:getContentSize()
    local guideNode=_G.GGuideManager:createTouchNode()
    guideNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    sysBtn:addChild(guideNode,100)

    local indexId=parentId or _sysId
    self.m_guideDataArray[indexId]={}
    self.m_guideDataArray[indexId].node=guideNode
    self.m_guideDataArray[indexId].subArray={}
    self.m_guideDataArray[indexId].subArray[_sysId]=true
    return true
end
function IconActivity.removeGuideTouch(self,_sysId)
    if not _G.GGuideManager:getCurGuideId() then
        self:showTaskGuideEffect()
    end

    local sysBtn,parentId=self:getIconBtnById(_sysId)
    if sysBtn==nil then return end

    local indexId=parentId or _sysId
    local guideData=self.m_guideDataArray[indexId]
    if guideData==nil then return end

    self.m_guideDataArray[indexId].node:removeFromParent(true)
    self.m_guideDataArray[indexId]=nil
end
function IconActivity.setVisibleGuideTouch(self,_bool,_isGoTask)
    if self.m_guideDataArray~=nil then
        for k,v in pairs(self.m_guideDataArray) do
            v.node:setVisible(_bool)
        end
    end
    if _bool and _isGoTask then
        if self.m_curTaskData~=nil and self.m_curTaskData.state==_G.Const.CONST_TASK_STATE_FINISHED then
            if self.m_waitToGuideTaskSchudler then return end

            local function nFun()
                if _G.g_Stage:getScene()==cc.Director:getInstance():getRunningScene() then
                    self:onGuiderTask()
                end
                
                _G.Scheduler:unschedule(self.m_waitToGuideTaskSchudler)
                self.m_waitToGuideTaskSchudler=nil
            end
            self.m_waitToGuideTaskSchudler=_G.Scheduler:schedule(nFun,0.2)
        end
    end
end

function IconActivity.removLeftButton(self,_id)
    if LimitInsideArray[_id] then
	   self.m_sysList[_id]=nil
    end
	if self.m_leftIconArray[_id]~=nil then
		self.m_leftIconArray[_id].btn:removeFromParent(true)
		self.m_leftIconArray[_id]=nil

        self.m_effectAarray[_id]=nil
        self.m_guideDataArray[_id]=nil

        self.m_leftIconCount=self.m_leftIconCount-1
        self:resetLeftPos()
	end
    self:initRewardBtnPos()
end
function IconActivity.removeUpButton(self,_id)
    if LimitInsideArray[_id] then
	   self.m_sysList[_id]=nil
    end
	if self.m_upIconArray[_id]~=nil then
		self.m_upIconArray[_id].btn:removeFromParent(true)
		self.m_upIconArray[_id]=nil

        self.m_effectAarray[_id]=nil
        self.m_guideDataArray[_id]=nil

        self.m_upIconCount=self.m_upIconCount-1
        self:resetUpPos()
	end
end

function IconActivity.resetLeftPos(self,_newSys)
    local newSys=_newSys or self:getSortSysArray(true)
    local idx=1
    for i=1,#newSys do
        local v=newSys[i]
        if self.m_leftIconArray[v.id] then
            self.m_leftIconArray[v.id].btn:setPosition(self:getLeftBtnPos(idx))
            idx=idx+1
        end
    end
end
function IconActivity.resetUpPos(self,_newSys)
	local newSys=_newSys or self:getSortSysArray(true)
    local idx=1
    for i=1,#newSys do
        local v=newSys[i]
        if self.m_upIconArray[v.id] then
            self.m_upIconArray[v.id].btn:setPosition(self:getUpBtnPos(idx))
            idx=idx+1
        end
    end
end

function IconActivity.iconClickCallBack(self,sender,eventType)
	if eventType == ccui.TouchEventType.ended then
        local tag=sender:getTag()
        print("iconClickCallBack---->>",tag)

        local showCnf=_G.Cfg.funshow[tag]
        if showCnf~=nil then
            _G.g_Stage.m_lpPlay.m_lpMovePos=nil
            _G.GTaskProxy:setAutoFindWayData()
                
            local guideArray=self.m_guideDataArray[tag] and self.m_guideDataArray[tag].subArray or {}
            local tempView=require("mod.mainUI.SysArrayView")(tag,BigSysArray[tag],showCnf.activity,LimitInsideArray,guideArray)
            local tempScene=tempView:create()
            _G.GLayerManager:pushLuaScene(tempScene,false,true)
        elseif tag==_G.Const.CONST_FUNC_OPEN_ENARGY then
            CCLOG("请求请求领取体力buff")
            local msg=REQ_ROLE_BUFF_REQUEST()
            _G.Network:send(msg)
            return
        elseif tag==_G.Const.CONST_FUNC_OPEN_GANGS_BOSS then
            local msg = REQ_SCENE_ENTER_FLY()
            msg : setArgs(  _G.Const.CONST_CLAN_BOSS_MAPID  )
            _G.Network : send( msg )
            
            local msg = REQ_WORLD_BOSS_CITY_BOOSS()
            _G.Network : send( msg )
        else
            _G.GLayerManager:openLayer(tag)
        end

        -- if self.m_sysList[tag].state == _G.Const.CONST_ACTIVITY_NEW then
            -- self:removeEffectsById( tag, _G.Const.CONST_ACTIVITY_NEW )

        --     local msg=REQ_ROLE_USE_SYS()
        --     msg:setArgs(tag)  -- {功能ID}
        --     _G.Network:send(msg)
        -- end
    end
end

function IconActivity.addEffectsById(self,_sysId,_type)
    if _sysId==nil then return end
    if _type~=_G.Const.CONST_ACTIVITY_YONGJIU and _type~=_G.Const.CONST_ACTIVITY_ZILEI then return end

    if self.m_effectAarray[_sysId]~=nil then return end
    if self.m_sysList[_sysId]==nil then return end

    if self.m_sysList[_sysId].state~=_type then
        self.m_sysList[_sysId].state=_type
    end
    local tempBtn,isLeftBtn
    if self.m_leftIconArray[_sysId] then
        tempBtn=self.m_leftIconArray[_sysId].btn
        isLeftBtn=true
    elseif self.m_upIconArray[_sysId] then
        tempBtn=self.m_upIconArray[_sysId].btn
        isLeftBtn=false
    else
        return
    end

    local btnSize=tempBtn:getContentSize()
    local tempSpr=cc.Sprite:createWithSpriteFrameName("main_icon_effect.png")
    tempSpr:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    tempSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,90)))
    -- tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,150),cc.FadeTo:create(1,255))))
    tempBtn:addChild(tempSpr,-1)

    local spine=_G.SpineManager.createSpine("spine/6048")
	spine:setPosition(cc.p(btnSize.width*0.5,btnSize.height*0.5))
  	spine:setAnimation(0,"idle",true)
  	tempBtn:addChild(spine)

    self.m_effectAarray[_sysId]={tempSpr,spine}
end
function IconActivity.removeEffectsById(self,_sysId,_type)
    if not _sysId or not self.m_effectAarray[_sysId] then return end

    if self.m_sysList[_sysId]==nil then return end

    if _type~=nil and _type~=self.m_sysList[_sysId].state then
        return
    end

    for k,v in pairs(self.m_effectAarray[_sysId]) do
    	v:removeFromParent(true)
    end
    self.m_effectAarray[_sysId]=nil

    self.m_sysList[_sysId].state=_G.Const.CONST_ACTIVITY_ZHENGCHANG
end

function IconActivity.showMopTypeIcon(self,_type)
    if _type==nil or _type==self.m_mopType then return end
    
    self.m_mopType=_type
    if _type==0 then
        -- 没有挂机
        self:hideMopTypeIcon()
        return
    end

    local szImg
    if _type==1 then
        szImg="main_icon_saodang.png"
        -- color=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
    else
        szImg="main_icon_saodang2.png"
        -- color=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
    end

    if self.m_mopTypeBtn~=nil then
        self.m_mopTypeBtn:loadTextures(szImg)
        return
    end

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            _G.GLayerManager :openLayer(Cfg.UI_CCopyMapLayer)
        end
    end

    local button =gc.CButton:create("main_icon_saodang.png")
    local btnSize=button:getContentSize()
    button:addTouchEventListener(c)
    self.m_leftContainer:addChild(button)

    self.m_mopTypeBtn=button
    self:resetMopTypeIconPos()
end
function IconActivity.hideMopTypeIcon(self)
    if self.m_mopTypeBtn then
        self.m_mopTypeBtn:removeFromParent(true)
        self.m_mopTypeBtn=nil
        self.m_mopTypeLabel=nil
    end
end
function IconActivity.resetMopTypeIconPos(self)
    if not self.m_mopTypeBtn then return end

    local posIdx
    if self.m_openNode then
        posIdx=5
    else
        posIdx=4
    end
    self.m_mopTypeBtn:setPosition(self:getLeftBtnPos(posIdx))
end





-- ******************************************************************
-- 任务处理
local GuideType_FindNPC  =1
local GuideType_PlayCopy =2
local GuideType_OpenLayer=3
function IconActivity.initGuideButton(self)
    local function fun2(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            CCLOG("Touch to guider task!")
            self:guideBtnClick()
        end
    end

    local taskGuideBtn=gc.CButton:create("main_task_dins.png")
    local btnSize=taskGuideBtn:getContentSize()
    taskGuideBtn:addTouchEventListener(fun2)
    taskGuideBtn:setPosition(self.m_winSize.width - btnSize.width*0.5,370)
    taskGuideBtn:enableSound()
    taskGuideBtn:setTouchActionType(_G.Const.kCButtonTouchTypeGray)
    self.m_rootNode:addChild(taskGuideBtn,2)
    self.m_taskGuideBtn=taskGuideBtn

    local bgSprSize=cc.size(150,30)
    local bgSprPos=cc.p(self.m_winSize.width-bgSprSize.width*0.5-10,315)

    local nPosX=70
    local nPosY=btnSize.height*0.5
    local fontSize=20
    -- local taskTypeLabel=_G.Util:createLabel("[主线]",fontSize)
    -- local labelSize=taskTypeLabel:getContentSize()
    -- taskTypeLabel:setAnchorPoint(cc.p(0,0.5))
    -- taskTypeLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    -- taskTypeLabel:setPosition(nPosX,nPosY)
    -- taskGuideBtn:addChild(taskTypeLabel)
    -- self.m_taskTypeLabel=taskTypeLabel

    local taskInfoLabel=_G.Util:createLabel("",fontSize)
    taskInfoLabel:setAnchorPoint(cc.p(0,0.5))
    taskInfoLabel:setPosition(nPosX,nPosY)
    taskGuideBtn:addChild(taskInfoLabel)
    self.m_taskInfoLabel=taskInfoLabel

    self:updateTaskInfo()
end
function IconActivity.getTaskGuideBtn(self)
    return self.m_taskGuideBtn
end

function IconActivity.clearOpenNode(self)
    if self.m_openNode then
        self.m_openNode:removeFromParent(true)
        self.m_openNode=nil
        self.m_curOpenData=nil
    end
end
function IconActivity.checkOpenInfoUpdate(self,_lv)
    _lv=_lv or _G.GPropertyProxy:getMainPlay():getLv()

    local showArray={}
    local showCount=0
    local openCnfArray=_G.Cfg.sys_open_info
    for openId,v in pairs(openCnfArray) do
        if v.open_lv>_lv and v.open_effect~=0 then
            showCount=showCount+1
            showArray[showCount]=v
        end
    end

    self:clearOpenNode()

    if showCount==0 then
        return
    end

    local function sortFun(v1,v2)
        if v1.open_lv==v2.open_lv then
            return v1.open_id<v2.open_id
        else
            return v1.open_lv<v2.open_lv
        end
    end
    table.sort(showArray,sortFun)

    self.m_openNode=cc.Node:create()
    self.m_openNode:setPosition(self:getLeftBtnPos(4))
    self.m_leftContainer:addChild(self.m_openNode)

    local curData=showArray[1]
    local openSpr=cc.Sprite:createWithSpriteFrameName(string.format("%s.png",curData.open_effect))
    openSpr:setTag(101)
    self.m_openNode:addChild(openSpr)

    local openLabel=_G.Util:createBorderLabel(string.format("%d级开启",curData.open_lv),20)
    openLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    openLabel:setTag(102)
    self.m_openNode:addChild(openLabel)

    self.m_curOpenData=curData
    self:resetMopTypeIconPos()
end

function IconActivity.updateTaskInfo(self)
    local taskData=_G.GTaskProxy:getMainTask()

    self.m_curTaskData=taskData
    if taskData==nil then
        -- self.m_tCaoZuoLabel  :setString("")
        local nextTaskCnf=_G.GTaskProxy:getNextMainTaskCnf()
        if nextTaskCnf~=nil then
            -- self.m_taskTypeLabel :setString("[主线]")
            self.m_taskInfoLabel :setString(nextTaskCnf.name)
            self.m_taskInfoLabel :setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
        else
            -- self.m_taskTypeLabel :setString("")
            self.m_taskInfoLabel :setString("")
        end

        if self.m_taskGuideEffectNode~=nil then
            self.m_taskGuideEffectNode:setVisible(false)
        end
        self:hideTaskGuideEffect()
    else
        self.m_curGuideData={}
        self.m_curGuideData.taskId=taskData.id
        -- local szCaoZuo=nil
        local nState=taskData.state
        local nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
        if nState == _G.Const.CONST_TASK_STATE_ACTIVATE 
            or nState == _G.Const.CONST_TASK_STATE_ACCEPTABLE then --1 or 2
            self.m_curGuideData.type=GuideType_FindNPC
            self.m_curGuideData.npcId=taskData.beginNpc
            self.m_curGuideData.sceneId=taskData.beginNpcScene
            if nState == _G.Const.CONST_TASK_STATE_ACTIVATE then
                nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
            end
            -- szCaoZuo="[寻路]"
        elseif nState == _G.Const.CONST_TASK_STATE_UNFINISHED then --3
            local targetType = taskData.target_type
            if targetType == _G.Const.CONST_TASK_TARGET_COPY then
                self.m_curGuideData.type=GuideType_PlayCopy
                self.m_curGuideData.taskData=clone(taskData)
            elseif targetType == _G.Const.CONST_TASK_TARGET_OTHER and taskData.target_id~=nil then     
                self.m_curGuideData.type=GuideType_OpenLayer
                self.m_curGuideData.targetId=taskData.target_id
                -- szCaoZuo="[其他]"
            else
                self.m_curGuideData=nil
            end
            -- if szCaoZuo==nil then
                -- szCaoZuo="[副本]"
            -- end
        elseif nState == _G.Const.CONST_TASK_STATE_FINISHED then             --4
            self.m_curGuideData.type=GuideType_FindNPC
            self.m_curGuideData.npcId=taskData.endNpc
            self.m_curGuideData.sceneId=taskData.endNpcScene
            -- szCaoZuo="[寻路]"
        end

        local taskCnf=_G.GTaskProxy:getTaskDataById(taskData.id)
        local szName=taskCnf.name
        local szType
        if taskCnf.type==1 then
            szType="[主线]"
        else
            szType="[支线]"
        end
        
        -- self.m_tCaoZuoLabel  :setString(szCaoZuo)
        -- self.m_taskTypeLabel :setString(szType)
        self.m_taskInfoLabel :setString(szName)
        self.m_taskInfoLabel :setColor(nColor)

        self:showTaskGuideEffect()
    end
end

function IconActivity.showTaskGuideEffect(self)
    if self.m_curTaskData==nil then return end
    -- if _G.GLayerManager:isTaskDialogOpen() then return end

    local lv=_G.GPropertyProxy:getMainPlay():getLv()
    if lv>_G.Const.CONST_NEW_GUIDE_LV_TASK then
        if self.m_taskGuideEffectNode~=nil then
            self.m_taskGuideEffectNode:removeFromParent(true)
            self.m_taskGuideEffectNode=nil
        end
        return
    elseif self.m_taskGuideEffectNode==nil then
        local btnSize=self.m_taskGuideBtn:getContentSize()
        local tempGafAsset=gaf.GAFAsset:create("gaf/renwu.gaf")
        self.m_taskGuideEffectNode=tempGafAsset:createObject()
        self.m_taskGuideEffectNode:setLooped(true,false)
        self.m_taskGuideEffectNode:start()
        self.m_taskGuideEffectNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
        self.m_taskGuideBtn:addChild(self.m_taskGuideEffectNode,10)
    end

    if self.m_curTaskData.state<_G.Const.CONST_TASK_STATE_ACCEPTABLE then
        self.m_taskGuideEffectNode:setVisible(false)
    else
        self.m_taskGuideEffectNode:setVisible(true)
    end

    if _G.GGuideManager:getCurGuideId() then
        return
    end

    local taskId=self.m_curTaskData.id
    local szNotic=nil
    if taskId==100110 then
        szNotic="点击任务框追踪任务"
    elseif taskId==100210 then
        szNotic="寻路到下一个任务目标"
    else
        szNotic=""
    end
    if self.m_guideNoticNode~=nil then
        self.m_guideNoticNode:removeFromParent(true)
        self.m_guideNoticNode=nil
    end
    if szNotic~=nil then
        local guideNode=cc.Node:create()
        guideNode:setTag(776)
        self.m_taskGuideBtn:addChild(guideNode)

        local btnSize=self.m_taskGuideBtn:getContentSize()
        local handNode=_G.GGuideManager:createTouchNode(nil,nil,true)
        handNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
        guideNode:addChild(handNode)

        if szNotic~="" then
            local noticNode=_G.GGuideManager:createNoticNode(szNotic,true)
            noticNode:setPosition(-120,20)
            guideNode:addChild(noticNode)
        end
        self.m_guideNoticNode=guideNode
    end
end
function IconActivity.hideTaskGuideEffect(self)
    if self.m_guideNoticNode~=nil then
        self.m_guideNoticNode:removeFromParent(true)
        self.m_guideNoticNode=nil
    end
end

function IconActivity.guideBtnClick(self)
    local curTimes    = _G.TimeUtil:getNowMilliseconds()
    self.m_touchTimes = self.m_touchTimes or 0
    if self.m_touchTimes>curTimes-500 then
        return
    end
    self.m_touchTimes = curTimes

    if not _G.GTaskProxy:getInitialized() then
        return
    end

    local isOpenRewardTask=false
    local mainTask=_G.GTaskProxy:getMainTask()
    if mainTask~=nil then
        local taskArray=_G.GTaskProxy:getTaskDataList()
        if mainTask.id~=taskArray[1].id then
            _G.GTaskProxy:setMainTask(taskArray[1])
            mainTask=_G.GTaskProxy:getMainTask()
        end
        if taskArray[1].state<_G.Const.CONST_TASK_STATE_ACCEPTABLE then
            isOpenRewardTask=true
        end
    else
        isOpenRewardTask=true
    end

    if isOpenRewardTask then
        local szMsg
        if mainTask then
            local taskCnf=_G.GTaskProxy:getTaskDataById(mainTask.id)
            szMsg=string.format("%d级任务(%s)接受等级不足,",taskCnf.lv,taskCnf.name)
        else
            szMsg="当前任务接受等级不足,"
        end
        
        local myLv=_G.GPropertyProxy:getMainPlay():getLv()
        if myLv>=_G.Const.CONST_TASK_TIAOZHUAN_XUANSHAN then
            local rewardCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_TASK)
            if rewardCount>0 then
                local function nSureFun()
                    _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_TASK_DAILY)
                end
                szMsg=szMsg.."是否前往完成修行任务获取经验?"
                _G.Util:showTipsBox(szMsg,nSureFun)
                return
            end
        end

        local function nSureFun()
            _G.GLayerManager:openLayer(_G.Cfg.UI_CCopyMapLayer)
        end
        szMsg=szMsg.."是否前往扫荡副本获取经验?"
        _G.Util:showTipsBox(szMsg,nSureFun)
        return
    end

    self:onGuiderTask()
end

--{追踪任务}
function IconActivity.onGuiderTask( self )
    if _G.GGuideManager:getCurGuideCnf() then
        -- 新手指引中,不处理
        print("onGuiderTask===>>>> has guide")
        return
    end
    
    CCLOG("\n[进入了 追踪任务]" )
    -- self :removeTaskArrowSpr()
    if self.m_curTaskData==nil then
        -- 一个任务都木有啦
        CCLOG("[追踪任务] 没有任务可追踪,跳到助手界面!")
        local command=CErrorBoxCommand("暂无可接任务")
        controller:sendCommand(command)
        _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_STRATEGY)
        return
    end

    -- 不能接的时候???

    if self.m_curGuideData==nil then
        CCLOG("[追踪任务] 当前任务追踪不了!")
        return
    end
    if self.m_curGuideData.type==GuideType_FindNPC then
        CCLOG("[追踪任务] 寻路!")
        local npcId  =self.m_curGuideData.npcId
        local sceneId=self.m_curGuideData.sceneId
        _G.GTaskProxy :autoWayFinding( npcId, sceneId )
        local command = CNpcUpdateCommand( CNpcUpdateCommand.MAIN_TASK )
        command.taskId = self.m_curGuideData.taskId
        command.npcId  = npcId
        _G.controller :sendCommand( command )
    elseif self.m_curGuideData.type==GuideType_PlayCopy then
        CCLOG("[追踪任务] 副本!")
        local taskData=self.m_curGuideData.taskData
        local copyId=taskData.copy_id
        if copyId~=nil then
            local sceneCopyCnf=_G.Cfg.scene_copy[copyId]
            if sceneCopyCnf~=nil then
                local copyType=sceneCopyCnf.copy_type
                if copyType==_G.Const.CONST_COPY_TYPE_TEAM then
                    _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TEAM)
                    return
                elseif copyType==_G.Const.CONST_COPY_TYPE_FIGHTERS then
                    _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_TOWER)
                    return
                end
            end
        end

        if copyId and taskData.chapId then
            local roleProperty=_G.GPropertyProxy:getMainPlay()
            roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_MAIN_TASK,
                                     taskData.copy_id,
                                     taskData.chapId,
                                     taskData.current or "",
                                     taskData.max or "",
                                     taskData.id)
        else
            CCLOG("[追踪任务] copy_id==nil or chapId==nil")
        end

        _G.GTaskProxy :setCopyTask(taskData)
        _G.GTaskProxy :gotoCopyDoor()
    elseif self.m_curGuideData.type==GuideType_OpenLayer then
        CCLOG("[追踪任务] 打开界面!")
        local targetId=self.m_curGuideData.targetId
        _G.GTaskProxy:goSomeViewByTargetId(targetId)
    end
end



-- ******************************************************************
-- 其他处理写这

return IconActivity