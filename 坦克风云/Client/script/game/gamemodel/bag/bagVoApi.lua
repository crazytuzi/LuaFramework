require "luascript/script/game/gamemodel/bag/bagVo"

bagVoApi={
allBagsVo={},
redPointMaxNum=99, --红点最大显示上限数,如果大于该值就显示...
}
function bagVoApi:clear()
    for k,v in pairs(self.allBagsVo) do
         v=nil
    end
    self.allBagsVo=nil
    self.allBagsVo={}
end

function bagVoApi:clearCache()
    if self.cacheAllBagsVo then
        for k, v in pairs(self.cacheAllBagsVo) do
            v=nil
        end
    end
    self.cacheAllBagsVo=nil
end

function bagVoApi:addBag(id,num,isUserlogin)
    local vo = bagVo:new();
    local ifexist = false;
    for  k,v in pairs(self.allBagsVo) do
        if id==v.id then
            v.num = v.num+num;
            ifexist =true
        end

    end
    if ifexist == false then
        local pid="p"..id
        if propCfg[pid]~=nil then
            local isUseable=0
            if propCfg[pid].isUseable=="true" then
                isUseable=1
            end
            if tonumber(id) <3378 or tonumber(id) > 3387 then--3378 到 3387 福运双收 道具ID 福运双收活动的几个活动收集物品误配置成了道具，而实际上是活动数据不应加背包，目前已经有玩家获得了物品，因此在这里加一个限制，福运双收活动的物品不在背包中显示。
                vo:initWithData(tonumber(id),num,tonumber(propCfg[pid].sortId),isUseable)
                --table.insert(self.allBagsVo,vo)
                self.allBagsVo[tonumber(vo.id)]=vo
            end
        end
    end

    if vo.id and self.allBagsVo[tonumber(vo.id)] then
        if self.cacheAllBagsVo==nil then
            self.cacheAllBagsVo={}
        end
        if isUserlogin then
            self.cacheAllBagsVo[tonumber(vo.id)]={
                num=num, addNum=0
            }
        else
            if self.cacheAllBagsVo[tonumber(vo.id)] then
                if self.allBagsVo[tonumber(vo.id)].num > self.cacheAllBagsVo[tonumber(vo.id)].num then
                    self.cacheAllBagsVo[tonumber(vo.id)].addNum=num
                    self.cacheAllBagsVo[tonumber(vo.id)].num=self.allBagsVo[tonumber(vo.id)].num
                end
            else
                self.cacheAllBagsVo[tonumber(vo.id)]={
                    num=self.allBagsVo[tonumber(vo.id)].num, addNum=num
                }
            end
        end
    end

end

function bagVoApi:getItemRedPointNumByType(_type)
    local _count = 0
    if self.cacheAllBagsVo then
        for  k,v in pairs(self.cacheAllBagsVo) do
            local pid="p"..k
            if _type==-1 or tonumber(propCfg[pid].type)==_type then
                -- 经验书一键使用升级将领（背包不在显示）
                if base.bs==1 and propCfg[pid].useGetHeroPoint then
                else
                    if v.addNum > 0 then
                        _count=_count+1
                    end
                end
            end
        end
    end
    return _count
end

function bagVoApi:setItemRedPointNumByType(_type)
    if self.cacheAllBagsVo then
        for  k,v in pairs(self.cacheAllBagsVo) do
            local pid="p"..k
            if _type==-1 or tonumber(propCfg[pid].type)==_type then
                -- 经验书一键使用升级将领（背包不在显示）
                if base.bs==1 and propCfg[pid].useGetHeroPoint then
                else
                    v.addNum=0
                end
            end
        end
    end
end

function bagVoApi:isNewAdd(_id)
    if self.cacheAllBagsVo and self.cacheAllBagsVo[tonumber(_id)] then
        if self.cacheAllBagsVo[tonumber(_id)].addNum > 0 then
            return true
        end
    end
    return false
end

function bagVoApi:isCompound(_type)
    if self.allBagsVo then
        for  k,v in pairs(self.allBagsVo) do
            local pid="p"..v.id
            if _type==-1 or tonumber(propCfg[pid].type)==_type then
                -- 经验书一键使用升级将领（背包不在显示）
                if base.bs==1 and propCfg[pid].useGetHeroPoint then
                else
                    if v.id > 4819 and v.id < 4828 and propCfg[pid].composeGetProp and v.num >= propCfg[pid].composeGetProp[1] then
                        return true, v.id
                    end
                end
            end
        end
    end
    return false
end

function bagVoApi:getShopItemByType(type)
    local tab={};
    for  k,v in pairs(self.allBagsVo) do
            local pid="p"..v.id
            if type==-1 or tonumber(propCfg[pid].type)==type then
                -- 经验书一键使用升级将领（背包不在显示）
                if base.bs==1 and propCfg[pid].useGetHeroPoint then
                else
                    table.insert(tab,v)
                end 
            end

    end
    table.sort(tab,function(a,b) 
        if a.isUseable and b.isUseable then
            if a.isUseable==b.isUseable then
                return a.sortId<b.sortId 
            else
                return a.isUseable>b.isUseable 
            end
        else
            return a.sortId<b.sortId 
        end
    end)

    return tab;
    
end
function bagVoApi:useItemNumId(id,num)
    if self.allBagsVo[id]~=nil then
        self.allBagsVo[id].num=self.allBagsVo[id].num-num
        if self.allBagsVo[id].num==0 then
            self.allBagsVo[id]=nil
        
        end
    end
    --[[for k,v in pairs(self.allBagsVo) do
        if v.id==id then
            v.num=v.num-num
        end
    end
    ]]

    if self.cacheAllBagsVo and self.cacheAllBagsVo[id]~=nil then
        self.cacheAllBagsVo[id].num=self.cacheAllBagsVo[id].num-num
        self.cacheAllBagsVo[id].addNum=self.cacheAllBagsVo[id].addNum-num
        if self.cacheAllBagsVo[id].addNum < 0 then
            self.cacheAllBagsVo[id].addNum=0
        end
        if self.cacheAllBagsVo[id].num==0 then
            self.cacheAllBagsVo[id]=nil
        end
    end
end

function bagVoApi:getItemNumId(id)

     if self.allBagsVo[id]~=nil then

         return self.allBagsVo[id].num
     else
         return 0
     end
   --[[  local num=0
    for k,v in pairs(self.allBagsVo) do
        if tonumber(v.id)==tonumber(id) then
            num=v.num
        end
    
    end
    return num
    ]]
end

function bagVoApi:getItemIcon(pid)
    local sbId = tonumber(RemoveFirstChar(pid))
    local function touch()
    end
    local sprite
    if (G_curPlatName()=="11" or G_curPlatName()=="androidsevenga") and pid=="p87" then
    -- if pid=="p87" then
        sprite = LuaCCSprite:createWithFileName("public/caidan.png",touch)
    elseif propCfg[pid].useGetHero then
        local heroData={h=G_clone(propCfg[pid].useGetHero)}
        local itemTb=FormatItem(heroData)
        local item=itemTb[1]
        if item and item.type=="h" then
            if item.eType=="h" then
                local productOrder=item.num
                sprite = heroVoApi:getHeroIcon(item.key,productOrder,true,touch,nil,nil,nil,{adjutants={}})
            else
                sprite = heroVoApi:getHeroIcon(item.key,1,false,touch)
            end
        end
    elseif propCfg[pid].useGetArmor then
        local reward=G_rewardFromPropCfg(pid)
        if(reward[1].key=="exp")then
            sprite=G_getItemIcon(reward[1],100,false)
        else
            sprite=armorMatrixVoApi:getArmorMatrixIcon(reward[1].key,90,100)
        end
    elseif propCfg[pid].Aid then
        local equipId=propCfg[pid].Aid
        local eType=string.sub(equipId,1,1)
        if eType=="a" then
            sprite=accessoryVoApi:getAccessoryIcon(equipId,80,100,touch)
        elseif eType=="f" then
            sprite=accessoryVoApi:getFragmentIcon(equipId,80,100,touch)
        elseif eType=="p" then
            local pic=accessoryCfg.propCfg[equipId].icon
            sprite=LuaCCSprite:createWithSpriteFrameName(pic,touch)
        end
    elseif pid=="p56" then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,70,100)
    elseif pid=="p57" then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,80,100)
    elseif pid=="p677" then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,80,100)
    elseif pid=="p866" then
        sprite = CCSprite:createWithSpriteFrameName("item_prop_866.png")
    elseif pid=="p903" then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,70,100)
    elseif pid=="p904" then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,70,100)
    elseif sbId>=2001 and sbId<=2128 then
        sprite = GetBgIcon(propCfg[pid].icon,nil,nil,70,100)
    else
        -- dmj2015-10-19修改，背包统一走G_getItemIcon()

        -- sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon)
        local propData={p={}}
        propData.p[pid]=0
        local itemTb = FormatItem(propData)
        local item = itemTb[1]
        if item then
            -- print("-----dmj=---id:"..item.id.."--type:"..item.type.."--key:"..item.key.."--pic:"..item.pic)
            sprite = G_getItemIcon(item,100)
        end
    end
    if sprite and sprite:getContentSize().width>100 then
        sprite:setScale(100/sprite:getContentSize().width)
    end
    return sprite
end

function bagVoApi:showUsePropSmallDialog(layerNum,reward,pid,useNum)
    require "luascript/script/game/scene/gamedialog/usePropSmallDialog"
    local sDialog=usePropSmallDialog:new()
    sDialog:init(layerNum,reward,pid,useNum)
    return sDialog
end

function bagVoApi:showSearchSmallDialog(layerNum,pid,callback,targetStr)
    require "luascript/script/game/scene/gamedialog/searchSmallDialog"
    local sDialog=searchSmallDialog:new()
    sDialog:init(layerNum,pid,callback,targetStr)
    return sDialog
end
function bagVoApi:showPropDisplaySmallDialog(layerNum,reward,title,desStr,btnTb,propDSize)
    require "luascript/script/game/scene/gamedialog/propDisplaySmallDialog"
    local td=propDisplaySmallDialog:new()
    local size=propDSize or CCSizeMake(550,650)
    local dialog=td:init("PanelHeaderPopup.png",size,nil,false,false,layerNum,reward,title,desStr,btnTb)
    sceneGame:addChild(dialog,layerNum)
    return td
end

function bagVoApi:showSearchResultSmallDialog(layerNum,eid)
    require "luascript/script/game/scene/gamedialog/searchResultSmallDialog"
    local sDialog=searchResultSmallDialog:new()
    sDialog:init(layerNum,eid)
    return sDialog
end

function bagVoApi:showSelectSearchSmallDialog(targetName,layerNum)
    require "luascript/script/game/scene/gamedialog/selectSearchSmallDialog"
    local sDialog=selectSearchSmallDialog:new()
    sDialog:init(targetName,layerNum)
    return sDialog
end

--是否显示侦查按钮
function bagVoApi:isShowSearchBtn()
    if propCfg and propCfg["p3304"] and propCfg["p3305"] then
        local num1=self:getItemNumId(3304) or 0
        local num2=self:getItemNumId(3305) or 0
        if (num1 and num1>0) or (num2 and num2>0) then
            return true
        end
    end
    return false
end

--雷达扫描
--pid 道具id(3304，3305)
--targetName 目标名字
function bagVoApi:mapRadarscan(pid,targetName,layerNum,callback,errorCallback,posCallback)
    local function mapRadarscanCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            eventDispatcher:dispatchEvent("prop.dialog.useProp",{})
            if sData and sData.data and sData.data.mail and sData.data.mail.report then
                local reportTb=sData.data.mail.report
                emailVoApi:addEmail(2,reportTb)
                local eid
                for k,v in pairs(reportTb) do
                    eid=v.eid
                end
                if pid=="p3304" then
                    if eid then
                        require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                        local td=emailDetailDialog:new(layerNum+1,2,eid)
                        local ppid=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("search_report_title_"..ppid),false,layerNum+1)
                        sceneGame:addChild(dialog,layerNum+1)
                    end
                elseif pid=="p3305" then
                    if sData.data.radarscan and sData.data.radarscan.lastTs then
                        local lastTs=tonumber(sData.data.radarscan.lastTs) or 0
                        local dataKey="last_use_p3305_time@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                        CCUserDefault:sharedUserDefault():setStringForKey(dataKey,lastTs)
                        CCUserDefault:sharedUserDefault():flush()
                    end
                    if eid then
                        self:showSearchResultSmallDialog(layerNum+1,eid)
                    end
                end
                if posCallback and reportTb[1] and reportTb[1].content and reportTb[1].content.info and reportTb[1].content.info.place then
                    posCallback(reportTb[1].content.info.place)
                elseif posCallback then
                    posCallback()
                end
            end
            if callback then
                callback()
            end
        else
            if errorCallback then
                errorCallback()
            end
        end
    end
    if targetName and targetName~="" then
        if string.lower(targetName)==string.lower(playerVoApi:getPlayerName()) then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("can_not_use_for_self"),30)
            do return end
        end
        if pid=="p3304" then
            socketHelper:mapRadarscan(1,targetName,nil,mapRadarscanCallback)
        elseif pid=="p3305" then
            local lastTs=0
            local dataKey="last_use_p3305_time@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
            local lastTime=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
            if lastTime then
                lastTs=tonumber(lastTime) or 0
            end
            socketHelper:mapRadarscan(2,targetName,lastTs,mapRadarscanCallback)
        end
    --[[else
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("please_input_target_name"),30)--]]
    end
end

function bagVoApi:showBatchUsePropSmallDialog(pid,layerNum,callback)
    require "luascript/script/game/scene/gamedialog/useOrBuyPropSmallDialog"
    local sd=useOrBuyPropSmallDialog:new()
    local dialog=sd:init("TankInforPanel.png",CCSizeMake(550,500),CCRect(0,0,400,350),CCRect(130,50,1,1),nil,layerNum,false,pid,callback)
end

function bagVoApi:showSelectRewardSmallDialog(layerNum,reward,desStr,pCallback,titleStr,pid,isMulti)
    require "luascript/script/game/scene/gamedialog/selectRewardSmallDialog"
    if not desStr then
        desStr=getlocal("activity_xiaofeisongli_small_des")
    end
    selectRewardSmallDialog:showSelectRewardDialog("PanelHeaderPopup.png",CCSizeMake(550,607),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,layerNum,reward,desStr,pCallback,titleStr,pid,isMulti)
end

function bagVoApi:propUseSelectReward(pid,m_index,selectId,count,Pcalback)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.accessory and accessoryVoApi then
                accessoryVoApi:onRefreshData(sData.data.accessory)
            end
            if sData and sData.data and sData.data.weapon and superWeaponVoApi then
                superWeaponVoApi:formatData(sData.data.weapon)
            end
            if Pcalback then
                Pcalback()
            end
        end
    end
    socketHelper:useProc(m_index,nil,callBack,nil,nil,count,propCfg[pid].useGetOne[selectId][1])
end

--判断是否是红色配件的道具
function bagVoApi:isRedAccessoryProp(pid)
    --红色配件相关道具
    if pid == "p4840" or pid == "p4841" or pid == "p4842" or pid == "p4843" then
        return true
    end
    return false
end

--判断红色配件的道具是否可以购买（因某些平台未开放红色配件）
function bagVoApi:isRedAccPropCanSell()
    if base.redAcc == 1 then
        return true
    end
    return false
end
