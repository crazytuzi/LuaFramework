satelliteSearchVoApi={
    flag=0,
    satelliteVo=nil,
}

-- 存储上一次定位的位置
function satelliteSearchVoApi:storageLastPos(place)
    local lastPlace={x=place[1],y=place[2]}
    local lastPlaceData=G_Json.encode(lastPlace)
    local dataKey="miniMapLastPlace@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,lastPlaceData)
    CCUserDefault:sharedUserDefault():flush()
end

function satelliteSearchVoApi:getLastPos()
    local placeKey="miniMapLastPlace@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local placeData=CCUserDefault:sharedUserDefault():getStringForKey(placeKey)
    if placeData~=nil and placeData~="" then
        local placeDataTab=G_Json.decode(placeData)
        return placeDataTab
    else
        return nil
    end
end

function satelliteSearchVoApi:setSelectInfo(selectIndex,subSelectIndex,level)
    local selectKey
    if selectIndex==1 then
        selectKey="miniMapCommomSelect@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        local dateTb={index=subSelectIndex,level=level}
        local dataData=G_Json.encode(dateTb)
        CCUserDefault:sharedUserDefault():setStringForKey(selectKey,dataData)
        CCUserDefault:sharedUserDefault():flush()
    else
        selectKey="miniMapSpecialSelect@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        CCUserDefault:sharedUserDefault():setIntegerForKey(selectKey,subSelectIndex)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function satelliteSearchVoApi:getSelectInfo(selectIndex)
    local selectKey
    if selectIndex==1 then
        selectKey="miniMapCommomSelect@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        local dateTb={index=1,level=1}

        local dataData=CCUserDefault:sharedUserDefault():getStringForKey(selectKey)
        if dataData~=nil and dataData~="" then
            dateTb=G_Json.decode(dataData)
            return dateTb
        else
            return dateTb
        end
    else
        selectKey="miniMapSpecialSelect@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        local subSelectIndex=CCUserDefault:sharedUserDefault():getIntegerForKey(selectKey)
        if not subSelectIndex or subSelectIndex==0 then
            return 1
        else
            return subSelectIndex
        end
        
    end
end

function satelliteSearchVoApi:mapWorldSearch(cmdStr,mapType,mapLevel,refreshCallback,showSearchDialog)
    local function callback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data then
                if sData.data.info then
                    if not self.satelliteVo then
                        self.satelliteVo=satelliteSearchVo:new()
                    end
                    self.satelliteVo:updateNum(sData.data.info,sData.ts)
                end

                if cmdStr=="map.worldsearch.info" then
                    self.flag=1
                    if showSearchDialog then
                        showSearchDialog()
                    end
                end
                if sData.data.privateMine then
                    local privateMineList = sData.data.privateMine
                    for k,v in pairs(privateMineList) do--缺！=> 矿点信息（resType信息），mid值，剩余时间还是具体时间点，
                        privateMineVoApi:addprivateMine(v.mid,v.stamp,v.flag,v.level,v.type,v.x,v.y)
                    end
                    refreshCallback()
                elseif sData.data.map then
                    if cmdStr=="map.worldsearch.gold" then --定位到金矿的处理
                        if base.fsaok==1 then
                            local goldMine=sData.data.gm
                            if goldMine then --如果定位到金矿则添加金矿信息
                                local mid=tonumber(goldMine[1])
                                local level=goldMine[3] or 0
                                local disappearTime=goldMine[2] or 0
                                goldMineVoApi:addGoldMine(mid,level,disappearTime)
                                worldBaseVoApi:setRefreshMineFlag(true)
                            end
                        end
                    end
                    if refreshCallback then
                        refreshCallback(sData.data.map)
                    end
                else
                    if cmdStr~="map.worldsearch.info" then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des2"),30)
                        -- 记录时间
                        if cmdStr=="map.worldsearch.mine" then
                            if self.satelliteVo.timeTb1==nil then
                                self.satelliteVo.timeTb1={}
                            end
                            self.satelliteVo.timeTb1[mapType]=sData.ts+15
                        elseif cmdStr=="map.worldsearch.rebel" then
                            if self.satelliteVo.rebelTs==nil then
                                self.satelliteVo.rebelTs=0
                            end
                            self.satelliteVo.rebelTs=sData.ts+15
                        elseif cmdStr=="map.worldsearch.gold" then
                            if self.satelliteVo.goldTs==nil then
                                self.satelliteVo.goldTs=0
                            end
                            self.satelliteVo.goldTs=sData.ts+15
                        elseif cmdStr=="map.worldsearch.shipboss" then
                            if self.satelliteVo.omgTs==nil then
                                self.satelliteVo.omgTs=0
                            end
                            self.satelliteVo.omgTs=sData.ts+15
                        end
                    end
                end
            end
            
        end
    end
    if self.flag==0 and cmdStr=="map.worldsearch.info" then
        socketHelper:mapWorldSearch(cmdStr,mapType,mapLevel,callback)
    elseif self.flag==1 and cmdStr=="map.worldsearch.info" then
        if showSearchDialog then
            showSearchDialog()
        end
    else
        socketHelper:mapWorldSearch(cmdStr,mapType,mapLevel,callback)
    end
    
end

function satelliteSearchVoApi:showSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,gpsCallback)
    require "luascript/script/game/scene/scene/satelliteSearchSmallDialog"
    satelliteSearchSmallDialog:showSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,gpsCallback)
end

function satelliteSearchVoApi:getSatelliteVo()
    return self.satelliteVo
end

function satelliteSearchVoApi:clearVo()
    self.satelliteVo.raidNum=0
    self.satelliteVo.goldNum=0
    self.satelliteVo.commonNum=0
    self.satelliteVo.omgn=0
    self.satelliteVo.lastTime=base.serverTime
end

function satelliteSearchVoApi:getLastTime(selectIndex,subSelectIndex)
    local satelliteVo=self:getSatelliteVo()
    if selectIndex==1 then
        if satelliteVo.timeTb1 and self.satelliteVo.timeTb1[subSelectIndex] then
            return self.satelliteVo.timeTb1[subSelectIndex]
        end
        return 0
    else
        if subSelectIndex==1 then
            return satelliteVo.rebelTs or 0
        elseif subSelectIndex==2 then
            return satelliteVo.goldTs or 0
        elseif subSelectIndex==6 then
            return satelliteVo.omgTs or 0
        end
    end
end


function satelliteSearchVoApi:clear()
    self.flag=0
    self.satelliteVo=nil
end


