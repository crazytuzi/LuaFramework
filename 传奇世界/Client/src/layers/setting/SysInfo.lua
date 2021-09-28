local SysInfo = class("SysInfo", function() return cc.Node:create() end)
local PATH = "res/layers/setting/"
--mainui/netstatus/wifi3.png
SysInfo.netType = 5
function SysInfo:ctor(no_refresh,callback)
    self.no_refresh = no_refresh
    local plat = cc.Application:getInstance():getTargetPlatform()
    local getParam = function()
        if  plat == cc.PLATFORM_OS_ANDROID then 
            local javaClassName = "org/cocos2dx/lua/AppActivity"
            local javaMethodName = "setSysInfoCallback"
            local javaParams = {
                function( info ) 
                    --print("******time:*******RoleId:"..tostring(userInfo.currRoleStaticId).."**"..os.date())
                    self:refreshLayout(info) 
                end
            }
            local javaMethodSig = "(I)V" 
            callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig) 
        elseif (cc.PLATFORM_OS_IPHONE == plat) or (cc.PLATFORM_OS_IPAD == plat) or (cc.PLATFORM_OS_MAC == plat) then 
            local className = "SysInfoOC"
            local ok,ret  = callStaticMethod(className,"getBatteryLevel",{})
            local datainfo = {}
            datainfo.energy = 50
            datainfo.netType = 3
            datainfo.net_level = 10
            if ok then datainfo.energy = ret*100 end
            local ok,ret  = callStaticMethod(className,"getNetState",{})
            if ok then datainfo.netType = ret end
            self:refreshLayout(info,datainfo)
            if callback then callback(SysInfo.netType) end
        else
            self:refreshLayout(info)
            if callback then callback(SysInfo.netType) end
        end 

        -- if (not no_refresh) then 
        --     if g_dwon_manage then
        --         if (SysInfo.netType == 5 and G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL)>=20) or g_dwon_manage.no_wifi_down then
        --             if not g_dwon_manage:checkDownload() then
        --                 if g_dwon_manage:hasGetAll() then
        --                     g_dwon_manage = nil
        --                 end
        --             end
        --         else 
        --             g_dwon_manage:pauseDown() 
        --         end
        --     end  
        -- end   
    end 
    -- self.tonicTemp = 1
    getParam()

    self.time_tick = 0
    local scheduleUpdate = function()
        self.time_tick = self.time_tick + 1
        getParam()
        if self.timeText and (self.time_tick%15 == 0) then
            self.timeText:setString( self:getTime() ) 
        end
    end
    if not no_refresh then
        schedule(self,scheduleUpdate,2)
    end
end

function SysInfo:getTime()
    local curTime = stringsplit( os.date("%X") , ":" )
    -- if G_MAINSCENE then
    --     if curTime[2]%15 == 0 and self.tonicTemp == 1 then
    --         G_MAINSCENE:expBallButton(1070)
    --         G_MAINSCENE:spoolerButton(2)
    --     end
    --     -- if curTime[2]%1 == 0 then
    --     --     G_MAINSCENE:updateHeadInfo()
    --     -- end
    --     if curTime[2]%30 == 0 and self.tonicTemp == 1 then
    --         G_MAINSCENE:spoolerButton(3)
    --     end
    --     if curTime[2]%20 == 0 and self.tonicTemp == 1 then
    --         G_MAINSCENE:spoolerButton(1)
    --     end
    -- end
    -- self.tonicTemp = self.tonicTemp * (-1)
    return curTime[1] .. ":" .. curTime[2]
end

function SysInfo:formatData( infoStr )
    local strAry = stringsplit( infoStr , "****" )
    local data = {}
    for key , v in pairs( strAry ) do
        local curAry  = stringsplit( v , ":" )
        data[ curAry[1] .. "" ] = tonumber( curAry[2] )
    end
    
    return data
end

function SysInfo:getPingInfo()
    local pingNum = userInfo and userInfo.pingNum or math.random(5, 50)
    local lev = 1
    if pingNum > 100 then
        lev = 1 
    else
        lev = 2
    end
    return pingNum, lev
end

--刷新信号
function SysInfo:refreshLayout( infoStr,datainfo )
    local data  = nil
    if infoStr then data = self:formatData( infoStr ) end
    if datainfo then data = datainfo end
    if data then SysInfo.netType = data.netType end
    if self.no_refresh then return end
    --生成电池Icon
    local redRGB = cc.c3b(255,51,51)
    local yellowRGB = cc.c3b(255,255,0)
    local greenRGB = cc.c3b(48,197,48)
    local  function energyIcon()
        local node =  cc.Node:create()
        local bg = createSprite( node , getSpriteFrame("mainui/netstatus/energy_bg.png") , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
        
        local bgSize = bg:getContentSize()
        local energyFront = cc.ProgressTimer:create( cc.Sprite:createWithSpriteFrame( getSpriteFrame("mainui/netstatus/energy_front.png") ) )

        energyFront:setType( cc.PROGRESS_TIMER_TYPE_BAR )
        energyFront:setBarChangeRate( cc.p( 1 , 0 ) )
        energyFront:setMidpoint( cc.p( 0 , 1 ) )
        energyFront:setPercentage( 100 )
        node:addChild( energyFront )

        --[[
        energyFront:setColor(greenRGB)
        local s = cc.Sprite:create( PATH .. "energy_front.png")
        s:setColor(cc.c3b(0,255,0))
        setNodeAttr( s , cc.p( 2 , bgSize.height/2 ) , cc.p( 1 , 0.5 ) )
        node:addChild(s)
        ]]

        setNodeAttr( energyFront , cc.p( 2 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) )
        node:setContentSize( bgSize )
        --local lightningSp = createSprite( node , PATH .. "lightning.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
        --lightningSp:setVisible( false )

        --刷新信息
        self.setEnergyFront = function( value , chargeType )
            local isChargeCfg = { true , false , false , false , false , true , true } 
            chargeType = chargeType or 2
            if isChargeCfg[chargeType] then 
                --lightningSp:setVisible( isChargeCfg[chargeType]  ) 
            else
                --lightningSp:setVisible( false  ) 
            end

            if value then
                energyFront:setPercentage( value ) 
                if value > 50 then
                    energyFront:setColor(greenRGB)
                elseif value > 20 then
                    energyFront:setColor(yellowRGB)
                else
                    energyFront:setColor(redRGB)
                end
            end
        end

        return node
    end

    local function createLayout()
        local node = cc.Node:create()
        local bgSize = cc.size( 125 , 33 )
        node:setContentSize( bgSize )

        local energy = energyIcon()
        setNodeAttr( energy , cc.p( 68 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) )
        node:addChild( energy )


        local timeText = createLabel( node , self:getTime() , cc.p( 15 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 17 , true , 100 , nil , MColor.yellow_gray , nil , nil )
        self.timeText = timeText

        local pingNum, pingLev = self:getPingInfo()
        local staticTimeText1 = createLabel( node , game.getStrByKey("delay"), cc.p( -15 + 13 - g_scrSize.width + bgSize.width + 280, bgSize.height-19 ) , cc.p( 0 , 0 ) , 17 , true , 100 , nil , MColor.white , nil , nil )
        staticTimeText1:enableOutline(cc.c4b(0,0,0,255),1)
        local staticTimeText2 = createLabel( node , "ms", cc.p( -15 + 13 + 45 + 38 - g_scrSize.width + bgSize.width + 280, bgSize.height-19 ) , cc.p( 0 , 0 ) , 17 , true , 100 , nil , MColor.white , nil , nil )
        staticTimeText2:enableOutline(cc.c4b(0,0,0,255),1)
        local timeText = createLabel( node , pingNum, cc.p( -15 + 13 + 48 - g_scrSize.width + bgSize.width + 280, bgSize.height-19 ) , cc.p( 0 , 0 ) , 17 , true , 100 , nil , MColor.yellow_gray , nil , nil )
        timeText:enableOutline(cc.c4b(0,0,0,255),1)
        self.PingText = timeText

        --[[
        local function createNetFlag( img_path )
            return createSprite( node , img_path , cc.p( -15 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) )
        end

        local netConfig = { "2g.png" , "2g.png" , "3g.png" , "4g.png" ,"wifi3.png"}

        local plat = cc.Application:getInstance():getTargetPlatform()
        if (cc.PLATFORM_OS_IPHONE == plat) or (cc.PLATFORM_OS_IPAD == plat) or (cc.PLATFORM_OS_MAC == plat) then 
            netConfig = { "ios_net.png" , "ios_net.png" , "ios_net.png" , "ios_net.png" ,"wifi3.png"}
        end
        
        local netFlag = createNetFlag( PATH .. netConfig[SysInfo.netType] ) 

        self.setData = function( tempData )
            if not tempData then return end
            if tempData.energy and self.setEnergyFront then self.setEnergyFront( tempData.energy , tempData.chargeType) end

            if tempData.netType then --信号类型  0 没有网络  1wap网络 2 2G网络 3 3G和3G以上网络，或统称为快速网络 4wifi网络 
                SysInfo.netType = tempData.netType
                if tempData.netType == 0 then
                    if netFlag then
                        removeFromParent(netFlag)
                        netFlag = nil
                    end
                else
                	local setFlag = function()
	                    if tempData.netType == 5 then
	                        -- int型数据，其中0到50表示信号最好，50到70表示信号偏差，大于70表示最差，有可能连接不上或者掉线
	                        local lv = ( tempData.net_level < 50 and 3 or ( tempData.net_level >70 and 1 or 2 ) )
	                        local img_path = PATH .. ( "wifi" .. lv .. ".png" )
	                        if netFlag then
	                            netFlag:setTexture( img_path )
	                        else
	                            netFlag = createNetFlag( img_path ) 
	                        end
                            if lv == 1 then
                                netFlag:setColor(redRGB)
                            elseif lv == 2 then
                                netFlag:setColor(yellowRGB)
                            elseif lv == 3 then
                                netFlag:setColor(greenRGB)
                            end
	                    else
	                        local img_path = PATH ..  netConfig[ tonumber( tempData.netType ) ] 
	                        if netFlag then
	                            netFlag:setTexture( img_path )
	                        else
	                            netFlag = createNetFlag( img_path ) 
	                        end
	                    end
                	end
                    setFlag()
                    --performWithDelay(self , setFlag , 1 )
                end
                   
            end
        end]]--
        return node
    end

    local updatePing = function()
        local pingNum, pingLev = self:getPingInfo()
        if self.PingText then
            if pingLev == 1 then
                self.PingText:setColor(MColor.red)
            elseif pingLev == 2 then
                self.PingText:setColor(MColor.green)
            end
            self.PingText:setString(pingNum)
        end
    end

    if not self.viewLayer then
        self.viewLayer = createLayout()
        setNodeAttr( self.viewLayer , cc.p( display.width , display.height ) ,  cc.p( 1 , 1  ) )
        self:addChild( self.viewLayer )
    end
    updatePing()

    if data then
        if data.energy and self.setEnergyFront then self.setEnergyFront( data.energy , data.chargeType) end
    end

    --if self.setData then
    --    self.setData( data )
    --end
end

return SysInfo