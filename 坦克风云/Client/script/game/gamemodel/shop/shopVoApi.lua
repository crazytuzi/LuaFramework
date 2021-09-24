shopVoApi={}

function shopVoApi:getShopItemBySid(sid)
    for  k,v in pairs(propCfg) do
        if tonumber(v.sid)==tonumber(sid) then
            return v
        end
    end
    return nil
end
function shopVoApi:clear()
    propCfg["p393"].isSell=1
    propCfg["p397"].isSell=1
    propCfg["p394"].isSell=1
    propCfg["p398"].isSell=1
    propCfg["p395"].isSell=1
    propCfg["p399"].isSell=1
    propCfg["p396"].isSell=1
    propCfg["p400"].isSell=1
end


function shopVoApi:getShopItemByType(type)
    local tab={};
    for k,v in pairs(playerVoApi:getMaxLvByKey("newTankBuilding")) do
        if v==10006 then
            propCfg["p393"].isSell=0
            propCfg["p397"].isSell=0
        elseif v==10016 then
            propCfg["p394"].isSell=0
            propCfg["p398"].isSell=0
        elseif v==10026 then
            propCfg["p395"].isSell=0
            propCfg["p399"].isSell=0
        elseif v==10036 then
            propCfg["p396"].isSell=0
            propCfg["p400"].isSell=0
        end
    end
    -- 军徽道具不可买
    if base.emblemSwitch~=1 then
        propCfg["p4001"].isSell=0
        propCfg["p4002"].isSell=0
        propCfg["p4003"].isSell=0
        propCfg["p4004"].isSell=0
        propCfg["p4005"].isSell=0
        propCfg["p4006"].isSell=0
    else
        propCfg["p4001"].isSell=1
        propCfg["p4002"].isSell=1
        propCfg["p4003"].isSell=1
        propCfg["p4004"].isSell=1
        propCfg["p4005"].isSell=1
        propCfg["p4006"].isSell=1
    end
    --空战指挥所功能未开启时，以下道具不可买（飞机技能升级和融合消耗的道具不可买）
    if base.plane~=1 then
        propCfg["p4201"].isSell=0
        propCfg["p4202"].isSell=0
        propCfg["p4203"].isSell=0
        propCfg["p4204"].isSell=0
        propCfg["p4205"].isSell=0
        propCfg["p4206"].isSell=0
    else
        propCfg["p4201"].isSell=1
        propCfg["p4202"].isSell=1
        propCfg["p4203"].isSell=1
        propCfg["p4204"].isSell=1
        propCfg["p4205"].isSell=1
        propCfg["p4206"].isSell=1
    end
    --矩阵光环 不可买
    if base.armorbr~=1 then
        propCfg["p4942"].isSell=0
    else
        propCfg["p4942"].isSell=1
    end
    for  k,v in pairs(propCfg) do
    
        if tonumber(v.isSell)==1 then
            if k=="p2129" then
                if base.autoUpgrade==1 then
                    if type==-1 or tonumber(v.type)==type then
                        table.insert(tab,v)
                    end
                end
            else
                if type==-1 or tonumber(v.type)==type then
                    table.insert(tab,v)
                end
            end
                
        end
    end
    if(tonumber(base.curZoneID)==999)then
        propCfg["p15"].isSell=0
        propCfg["p20"].isSell=0
    end
    table.sort(tab,function(a,b) return a.sortId<b.sortId end)
    return tab;
    
end

function shopVoApi:getIslandState()
    
    local tab={};
    for  k,v in pairs(propCfg) do
    
        if tonumber(v.sid)==11 or tonumber(v.sid)==12 or tonumber(v.sid)==13 or tonumber(v.sid)==14 then
            table.insert(tab,v)
        end

    end
    table.sort(tab,function(a,b) return a.sortId<b.sortId end)
    return tab;

end

function shopVoApi:getGoldResources()
    
    local tab={};
    for  k,v in pairs(propCfg) do
    
        if tonumber(v.sid)==11 or tonumber(v.sid)==12 or tonumber(v.sid)==13 or tonumber(v.sid)==14 then
            table.insert(tab,v)
        end

    end
    table.sort(tab,function(a,b) return a.sortId<b.sortId end)
    return tab;

end

function shopVoApi:getWorkShopResources()
    
    local tab={};
    for  k,v in pairs(propCfg) do
    
        if tonumber(v.sid)==6 or tonumber(v.sid)==7 or tonumber(v.sid)==8 or tonumber(v.sid)==9 or tonumber(v.sid)==10 or tonumber(v.sid)==13 then
            table.insert(tab,v)
        end

    end
    table.sort(tab,function(a,b) return a.sortId<b.sortId end)
    return tab;

end

function shopVoApi:showPropDialog(layerNum,isGuide,jumpIdx)
    require "luascript/script/game/scene/gamedialog/propDialog"
    local td=propDialog:new(layerNum,isGuide,10+(jumpIdx or 0))
    local tbArr={getlocal("bundle"),getlocal("market")}
    local isNewShowOnlyBag = true
    local dialogName = isNewShowOnlyBag and getlocal("bundle") or getlocal("prop")
    --test data
    if(base.isPlatShopOpen==1 and platCfg.platShopCfg[G_curPlatName()])then
    --if(true)then
    --test end
        tbArr={getlocal("bundle"),getlocal("market"),getlocal("shop_tab_platItems")}
    else
        tbArr={getlocal("bundle"),getlocal("market")}
    end
    local tbArrSub={getlocal("resource"),getlocal("help4_t3"),getlocal("chestText"),getlocal("otherText")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbArrSub,nil,dialogName,false,layerNum)
    sceneGame:addChild(dialog,layerNum)
    return td
end

function shopVoApi:getPlatShopItemByType(type)
    local tab={}
    for k,v in pairs(playerVoApi:getMaxLvByKey("newTankBuilding")) do
        if v==10006 then
            propCfg["p393"].isSell=0
            propCfg["p397"].isSell=0
        elseif v==10016 then
            propCfg["p394"].isSell=0
            propCfg["p398"].isSell=0
        elseif v==10026 then
            propCfg["p395"].isSell=0
            propCfg["p399"].isSell=0
        elseif v==10036 then
            propCfg["p396"].isSell=0
            propCfg["p400"].isSell=0
        end
    end
    if platCfg.platShopCfg[G_curPlatName()] then
    local itemIDTb=platCfg.platShopCfg[G_curPlatName()]["item"]
        for k,v in pairs(itemIDTb) do
            local cfg=propCfg[v]
                if type==-1 or tonumber(cfg.type)==type then
                    if G_curPlatName()=="androidkunlun" or G_curPlatName()=="14" or G_curPlatName()=="androidkunlun1mobile" then
                        if v~="p12" and v~="p42" and v~="p11" and v~="p43" then
                            table.insert(tab,cfg)
                        end
                    else
                        table.insert(tab,cfg)
                    end
                end
        end
        table.sort(tab,function(a,b) return a.sortId<b.sortId end)
    end
    return tab
end

--@ onePrice:单价
--@ isIntegral:是否积分
function shopVoApi:showBatchBuyPropSmallDialog(pid,layerNum,callback,btnStr,limitNum,truePrice,costTb,isNotProp,shopItem,onePrice,isIntegral)
    require "luascript/script/game/scene/gamedialog/useOrBuyPropSmallDialog"
    local sd=useOrBuyPropSmallDialog:new()
    local dialog=sd:init("TankInforPanel.png",CCSizeMake(550,500),CCRect(0,0,400,350),CCRect(130,50,1,1),nil,layerNum,true,pid,callback,btnStr,limitNum,truePrice,costTb,isNotProp,shopItem,onePrice,isIntegral)
    return sd
end
