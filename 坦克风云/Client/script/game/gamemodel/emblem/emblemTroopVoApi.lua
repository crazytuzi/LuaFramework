require "luascript/script/game/gamemodel/emblem/emblemTroopVo"
require "luascript/script/config/gameconfig/emblemTroopCfg"
emblemTroopVoApi={
	emblemTroopList=nil, --军徽部队列表
	troopEquipList=nil, --部队装配列表（里面记录的是装配的军徽数量）
	troopWashData=nil, --部队训练数据
    shopData=nil, --军徽部队购买和洗练道具购买数据
}

function emblemTroopVoApi:clear()
	base:removeFromNeedRefresh(self)
    self.emblemTroopList=nil
    self.troopEquipList=nil
    self.troopWashData=nil
    self.shopData=nil
end

--军徽部队是否开放
function emblemTroopVoApi:checkIfEmblemTroopIsOpen()
    if base.emblemSwitch==1 and base.emblemTroopSwitch==1 and playerVoApi:getPlayerLevel()>=emblemTroopCfg.main.unlocklevel then
        return true,emblemTroopCfg.main.unlocklevel
    end
    return false,emblemTroopCfg.main.unlocklevel
end

--军徽部队是否显示
function emblemTroopVoApi:checkIfEmblemTroopCanShow()
    if base.emblemSwitch==1 and base.emblemTroopSwitch==1 and playerVoApi:getPlayerLevel()>=emblemTroopCfg.main.showlevel then
        return true
    end
    return false
end

function emblemTroopVoApi:updateTroopData(troopList)
    if troopList then
        self:clearTroopEquipedList()
        self.emblemTroopList={}
        require "luascript/script/game/gamemodel/emblem/emblemTroopVo"
        for k,v in pairs(troopList) do
            local vo=emblemTroopVo:new()
            vo:initWithData(k,v)
            self.emblemTroopList[k]=vo

            if vo.posTb then
                for kp,vp in pairs(vo.posTb) do
                    if vp and vp~=0 then
                        self:addTroopEquipedNum(vp)
                    end
                end
            end
        end
    end
end

--获取军徽部队数据
function emblemTroopVoApi:getEmblemTroopData(troopId)
    local idArr=Split(troopId,"-")
    if idArr and SizeOfTable(idArr)>11 then
        troopId=idArr[12]
    end

    if self.emblemTroopList then
        return self.emblemTroopList[troopId]
    end
    return nil
end

--判断是否是军徽部队
function emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
    if equipId then
        local equipArr=Split(equipId,"-")
        if equipArr and SizeOfTable(equipArr)>1 then
            return true,equipArr--equipId 中包含了该大师的说有相关数据
        end

        local eType=string.sub(equipId,1,1)
        if eType=="m" then
            return true--玩家当前拥有某大师
        end
    end
    return false
end

--通过id获取已装配到装备大师上的数量
function emblemTroopVoApi:getTroopEquipedNumById(equipId)
    if self.troopEquipList==nil then
        return 0
    else
        return (self.troopEquipList[equipId] or 0)
    end
end

--往装配队列中加equip
function emblemTroopVoApi:addTroopEquipedNum(equipId)
    if self.troopEquipList==nil then
        self.troopEquipList={}
    end
    if self.troopEquipList[equipId]==nil then
        self.troopEquipList[equipId]=1
    else
        self.troopEquipList[equipId]=self.troopEquipList[equipId]+1
    end
end

--清空装配队列
function emblemTroopVoApi:clearTroopEquipedList()
    self.troopEquipList=nil
end

function emblemTroopVoApi:getEmblemTroopList()
	return self.emblemTroopList
end

--获取按照强度排序过的军徽部队列表
function emblemTroopVoApi:getEmblemTroopListWithSort()
    local troopList={}
    if self.emblemTroopList then
        for k,v in pairs(self.emblemTroopList) do
            if v then
                table.insert(troopList,{id=v.id,strong=v:getTroopStrength() or 0})
            end
        end
        local function sortFunc(a,b)
            if a and b then
                return a.strong>b.strong
            end
        end
        table.sort(troopList,sortFunc)
    end
    return troopList
end

--最大可装配的军徽数量
function emblemTroopVoApi:getTroopMaxEquipNum()
    return emblemTroopCfg.main.placeNum
end

--部队装配位置解锁的配置
function emblemTroopVoApi:getTroopEquipPosUnlockCfg()
    return emblemTroopCfg.sUnlock
end

function emblemTroopVoApi:getTroopStrengthUnlockCfg()
    return emblemTroopCfg.allUnlock
end

--返回装备位达到条件激活的属性配置
function emblemTroopVoApi:getTroopActivateCfg()
    local cfg=emblemTroopCfg.colorUp
    return cfg
end

--获取各个装配位置军徽的品阶
function emblemTroopVoApi:getTroopEquipColorTbByPosTb(posTb)
    local max=self:getTroopMaxEquipNum()
    local colorTb={}
    for i=1,max do
        colorTb[i]=0
        if posTb and posTb[i] then
            local equipId=posTb[i]
            if equipId then
                local cfg=emblemVoApi:getEquipCfgById(equipId)
                if cfg and cfg.color then
                    colorTb[i]=cfg.color
                end
            end
        end
    end
    return colorTb
end

function emblemTroopVoApi:getTroopStrengthById(troopId,emTroopVo)
    local strength=0
    local troopVo=emTroopVo or self:getEmblemTroopData(troopId)
    if troopVo then
        strength=troopVo:getTroopStrength()
    end
    return strength
end

--根据传入的部队属性计算部队战斗力
function emblemTroopVoApi:getTroopStrengthByAtt(attUp)
    local strength=0
    if attUp then
        for k,v in pairs(attUp) do
            local ratio=self:getStrengthRatioByAttType(k)
            strength=strength+tonumber(v)*ratio
        end
    end
    return math.ceil(strength)
end

--获取军徽部队的基础战斗力
function emblemTroopVoApi:getTroopBaseStrength(equipId)
    local strength=0
    local equipCfg=emblemVoApi:getEquipCfgById(equipId)
    if equipCfg and equipCfg.attUp then
        strength=self:getTroopStrengthByAtt(equipCfg.attUp)
    end
    return strength
end

function emblemTroopVoApi:getTroopStrengthByTroopData(equipId,posTb,attUp,maxWashStrength)
    local strength=0
    --基础强度
    local baseStrength=self:getTroopBaseStrength(equipId)
    strength=strength+baseStrength

    --洗练强度
    local washStrength=self:getTroopStrengthByAtt(attUp)--洗练强度
    strength=strength+washStrength

    --洗练强度达到一定值解锁条件加成属性
    local unlockCfg=self:getTroopEquipPosUnlockCfg()
    if unlockCfg then
        for k,v in pairs(unlockCfg) do
            if v.strNeed and maxWashStrength>=v.strNeed then
                if v.troopsAdd then
                    strength=strength+v.troopsAdd*self:getStrengthRatioByAttType("troopsAdd")
                elseif v.first then
                    strength=strength+v.first*self:getStrengthRatioByAttType("first")
                end
            end
        end
    end
    
    if posTb then
        local equipedColor={0,0,0,0,0}
        local max=self:getTroopMaxEquipNum()
        for i=1,max do
            local equipId
            if posTb and posTb[i] then
                equipId=posTb[i]
            end
            if equipId and equipId~=0 then
                local equipCfg=emblemVoApi:getEquipCfgById(equipId)
                if equipCfg then
                    equipedColor[equipCfg.color]=equipedColor[equipCfg.color]+1
                    local equipStrength=equipCfg.qiangdu*emblemTroopCfg.main.placeGet[i]
                    strength=strength+equipStrength
                end
            end
        end
        --某种颜色超级装备镶嵌数量达到时激活属性加成。
        local activateId=self:getTroopActivateIdByColorTb(equipedColor)
        if activateId then
            activateId=tonumber(RemoveFirstChar(activateId))
            local activateCfg=self:getTroopActivateCfg()
            for k,v in pairs(activateCfg) do
                if activateId and activateId>=tonumber(RemoveFirstChar(k)) and v and v.attUp then
                    for k1,v1 in pairs(v.attUp) do
                        local ratio=self:getStrengthRatioByAttType(k1)
                        strength=strength+tonumber(v1)*ratio
                    end
                end
            end
        end
    end
    return math.ceil(strength)
end

--获取部队指定属性的加成
function emblemTroopVoApi:getTroopAttValue(attType,equipId,posTb,addSavedTb,maxWashStrength)
    local attValue=0
    local equipCfg=emblemVoApi:getEquipCfgById(equipId)
    if equipCfg and equipCfg.attUp and equipCfg.attUp[attType] then
        attValue=attValue+tonumber(equipCfg.attUp[attType])
    end
    if addSavedTb and addSavedTb[attType] then
       attValue=attValue+tonumber(addSavedTb[attType])
    end
    --洗练强度达到一定值解锁条件加成属性
    local unlockCfg=self:getTroopEquipPosUnlockCfg()
    if unlockCfg then
        for k,v in pairs(unlockCfg) do
            if v.strNeed and maxWashStrength>=v.strNeed then
                if v[attType] then
                    attValue=attValue+v[attType]
                end
            end
        end
    end

    if posTb then
        local equipedColor={0,0,0,0,0}
        local max=self:getTroopMaxEquipNum()
        for i=1,max do
            local equipId
            if posTb[i] then
                equipId=posTb[i]
            end
            if equipId and equipId~=0 then
                local equipCfg=emblemVoApi:getEquipCfgById(equipId)
                if equipCfg then
                    equipedColor[equipCfg.color]=equipedColor[equipCfg.color]+1
                    if equipCfg.attUp and equipCfg.attUp[attType] then
                        attValue=attValue+equipCfg.attUp[attType]*emblemTroopCfg.main.placeGet[i]
                    end
                end
            end
        end
        --某种颜色超级装备镶嵌数量达到时激活属性加成。
        local activateId=self:getTroopActivateIdByColorTb(equipedColor)
        if activateId then
            activateId=tonumber(RemoveFirstChar(activateId))
            local activateCfg=self:getTroopActivateCfg()
            for k,v in pairs(activateCfg) do
                if activateId and activateId>=tonumber(RemoveFirstChar(k)) and v and v.attUp then
                    if v.attUp[attType] then
                        attValue=attValue+v.attUp[attType]
                    end
                end
            end
        end
    end
    if attType=="troopsAdd" or attType=="first" then
        attValue=math.ceil(attValue)
    else
        attValue=tonumber(string.format("%.3f",attValue))
    end
    return attValue
end

--根据部队属性类型获取战斗力系数
function emblemTroopVoApi:getStrengthRatioByAttType(attType)
    local ratio=emblemTroopCfg.main.attriRatio[attType] or 1
    return ratio
end

--部队训练调用
function emblemTroopVoApi:getWashStrengthByAtt(attUp)
    local attTypeTb=self:getTroopBaseAttributeType()
    local strength=0
    for k,v in pairs(attTypeTb) do
        local ratio=self:getStrengthRatioByAttType(v)
        strength=strength+tonumber(attUp[k] or 0)*ratio
    end
    return math.ceil(strength)
end

--得到当前最大的强度激活id
function emblemTroopVoApi:getTroopActivateIdByColorTb(equipedColor)
    local cfg=self:getTroopActivateCfg()
    local activateId
    for k,v in pairs(cfg) do
        if equipedColor[v.colorNeed]>=v.numNeed then
            if activateId==nil or tonumber(RemoveFirstChar(activateId))<tonumber(RemoveFirstChar(k)) then
                activateId=k
            end
        end
    end
    return activateId
end

function emblemTroopVoApi:getTroopBaseAttributeType()
    return {"hp","dmg","accuracy","evade","crit","anticrit"}
end

function emblemTroopVoApi:getTroopAttributeType()
    return {"hp","dmg","accuracy","evade","crit","anticrit","troopsAdd","first",}
end

--根据装配军徽获取部队的技能列表
function emblemTroopVoApi:getTroopSkillsByPosTb(posTb)
    local skillTb={}
    if posTb then
        local len=SizeOfTable(posTb)
        for i=1,len do
            if posTb[i] then
                local equipCfg=emblemVoApi:getEquipCfgById(posTb[i])
                if equipCfg and equipCfg.skill then
                    table.insert(skillTb,equipCfg.skill)
                end
            end
        end
    end
    return skillTb
end

function emblemTroopVoApi:getEmblemTroopPosUnlockNum(mashStrength)
    if mashStrength then
        mashStrength=tonumber(mashStrength)
    end

    local unlockIndex=0
    if mashStrength and mashStrength>0 then
        local cfg=self:getTroopEquipPosUnlockCfg()
        for k,v in pairs(cfg) do
            local kIndex=tonumber(RemoveFirstChar(k))
            if mashStrength>=v.strNeed and unlockIndex<kIndex then
                unlockIndex=kIndex
            end
        end
    end
    return unlockIndex
end

-- equipId：大师配置id
-- callback：回调方法
-- bgTag:背景的tag
-- strong 装备的强度
function emblemTroopVoApi:getTroopIconWithBg(equipId,strength,maxWashStrength,colorTb,callback,isBig)
    local function clickCallBack(object,fn,tag)
        if callback ~= nil then
           callback(tag)
        end
    end
    local bgPic="em_troopBg2.png"
    if isBig==true then
        bgPic="em_troopBg.png"
    end
    local iconBg=LuaCCSprite:createWithSpriteFrameName(bgPic,clickCallBack)

    local equipPic=self:getTroopIconPic(equipId,maxWashStrength)
    local icon=LuaCCSprite:createWithFileName(equipPic,clickCallBack)
    if icon==nil then
        icon=LuaCCSprite:createWithFileName("public/emblem/icon/emblemIcon_e2.png",clickCallBack)
    end
    icon:setAnchorPoint(ccp(0.5,0.5))
    iconBg:addChild(icon)
    if isBig==true then
        icon:setScale(1)
        icon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+60))
    else
        icon:setScale(130/icon:getContentSize().width)
        icon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+40))
    end
    local nameFontSize=17
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        nameFontSize = 20
    end
    if isBig==true then
        nameFontSize=24
    end
    if colorTb then
        local max = SizeOfTable(colorTb)
        local oneSpace = 15
        local startX = nil
        for i = 1, max do
            local equipColor = colorTb[i] --当前位置装配的装备的品质，如果没有就灰化
            local cIcon = CCSprite:createWithSpriteFrameName("emTroop_posColor_" .. equipColor .. ".png")
            if startX==nil then
                startX=iconBg:getContentSize().width/2-cIcon:getContentSize().width-oneSpace
            end
            cIcon:setAnchorPoint(ccp(0.5, 0.5))
            if isBig==true then
                cIcon:setPosition(ccp(startX, 150))
            else
                cIcon:setPosition(ccp(startX, iconBg:getContentSize().height/2-20))
                cIcon:setScale(0.8)
            end
            iconBg:addChild(cIcon)
            startX = startX + cIcon:getContentSize().width + oneSpace
        end
    end

    --军徽部队名称
    local nameStr=getlocal("emblem_name_"..equipId)
    local equipNameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(iconBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    equipNameLb:setAnchorPoint(ccp(0.5,1))
    if isBig==true then
        equipNameLb:setPosition(iconBg:getContentSize().width/2,95)
    else
        equipNameLb:setPosition(iconBg:getContentSize().width/2,65)
    end
    iconBg:addChild(equipNameLb)

    local strengthLb=GetTTFLabelWrap(getlocal("alliance_boss_degree",{strength}),nameFontSize,CCSizeMake(iconBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    strengthLb:setAnchorPoint(ccp(0.5,1))
    strengthLb:setPosition(iconBg:getContentSize().width/2,equipNameLb:getPositionY()-equipNameLb:getContentSize().height-10)
    iconBg:addChild(strengthLb)

    return iconBg
end

function emblemTroopVoApi:getTroopIconNoBg(equipId,strength,washStrength,colorTb,callback)
    local icon
    local function clickCallBack(object,fn,tag)
        if callback~=nil then
           callback(tag)
        end
    end

    local equipPic=self:getTroopIconPic(equipId,washStrength)
    icon=LuaCCSprite:createWithFileName(equipPic,clickCallBack)
    if icon==nil then
        icon=LuaCCSprite:createWithFileName("public/emblem/icon/emblemIcon_e2.png",clickCallBack)
    end
    local iconBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),clickCallBack)
    iconBg:setOpacity(0)
    local starSize,sp=22,5
    local bgWidth,bgHeight=icon:getContentSize().width,icon:getContentSize().height+starSize+5
    iconBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
    iconBg:addChild(icon)
    icon:setPosition(bgWidth/2,bgHeight-icon:getContentSize().height/2)
    -- --军徽部队名称
    -- local nameStr=getlocal("emblem_name_"..equipId)
    -- local equipNameLb=GetTTFLabelWrap(nameStr,22,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    -- equipNameLb:setAnchorPoint(ccp(0.5,1))
    -- equipNameLb:setPosition(ccp(icon:getContentSize().width/2,-30))
    -- equipNameLb:setTag(1)
    -- icon:addChild(equipNameLb)

    --军徽部队各个位置装配的军徽品阶
    if colorTb then
        local colorNum=SizeOfTable(colorTb)
        if colorNum and colorNum>0 then
            local sw=colorNum*starSize+(colorNum-1)*sp
            local px=(bgWidth-sw)/2
            local py=starSize/2
            for i=1,colorNum do
                local pic="emTroop_posColor_"..colorTb[i]..".png"
                local colorSp=CCSprite:createWithSpriteFrameName(pic)
                if colorSp then
                    colorSp:setScale(starSize/colorSp:getContentSize().width)
                    colorSp:setAnchorPoint(ccp(0,0.5))
                    colorSp:setPosition(ccp(px,py+5))
                    colorSp:setTag(10+i)
                    iconBg:addChild(colorSp)
                end
                px=px+starSize+sp
            end
        end
    end

    return iconBg
end

-----------------------以下是军徽部队训练相关-----------------------
--军徽部队每次自动洗练次数
function emblemTroopVoApi:getTroopAutoWashTimes()
    return emblemTroopCfg.main.autoLimit
end

function emblemTroopVoApi:getTroopWashCfg()
    return emblemTroopCfg.refine
end

function emblemTroopVoApi:getTroopWashMaxValueByType(washType,attType)
    if washType and attType then
        if emblemTroopCfg.refine["x"..washType] then
            local refineMax=self:getTroopRefineMax()
            return emblemTroopCfg.refine["x"..washType].maxAtt[attType]*(1+refineMax)
        end
    end
    return 0
end

--获取训练上限提升系数
function emblemTroopVoApi:getTroopRefineMax()
    local refineMax=0
    local totalStrength=self:getTroopsTotalStrength()
    for k,v in pairs(emblemTroopCfg.allUnlock) do
        if totalStrength>=v.allstrNeed and v.refineMax and v.refineMax>refineMax and self.troopWashData.au and tonumber(self.troopWashData.au)>=k then --训练上限已激活
            refineMax=v.refineMax
        end
    end
    return refineMax
end

function emblemTroopVoApi:getTroopsTotalStrength()
    local totalStrength=0
    if self.troopWashData and self.troopWashData.s then
        totalStrength=self.troopWashData.s
    end
    return totalStrength
end

--获取部队训练消耗的道具或者资源
function emblemTroopVoApi:getTroopWashCost(washType)
    if emblemTroopCfg.refine["x"..washType] then
        local costCfg=emblemTroopCfg.refine["x"..washType].cost
        local award=FormatItem(costCfg)
        local costReward=award[1]
        if costReward then
            if costReward.key=="gems" then
                costReward.pic="IconGold.png"
            elseif costReward.key=="p4916" then
                costReward.pic="emTroop_prop4916.png"
            end
        end
        return costReward
    end
    return nil
end

function emblemTroopVoApi:updateWashData(xtimes)
    if xtimes then
        self.troopWashData=xtimes
    end
end

function emblemTroopVoApi:getTroopWashTimes(washType)
    if self.troopWashData and self.troopWashData["x"..washType] then
        local ts=self.troopWashData.t
        if ts and ts==G_getWeeTs(base.serverTime) then
            return tonumber(self.troopWashData["x"..washType])
        else
            return 0
        end
    end
    return 0
end

--获取军徽部队列表的最大强度
function emblemTroopVoApi:getTroopListMaxStrength()
    if self.troopWashData and self.troopWashData.s then
        return self.troopWashData.s
    end
    return 0
end

function emblemTroopVoApi:getTroopStrengthRewardState()
    if self.troopWashData and self.troopWashData.au then
        return self.troopWashData.au
    end
end

function emblemTroopVoApi:getTroopWashMaxTimes(washType)
    if emblemTroopCfg.main.limit[washType] then
        return emblemTroopCfg.main.limit[washType]
    end
    return 0
end

--自动洗练(washSave保存条件（注：位置固定 前后端一致）： 强度提升 hp,dmg,accuracy,evade,crit,anticrit)
function emblemTroopVoApi:troopWashAuto(troopId,washType,washTimeIndex,washSave,callback)
    local troopVo=self:getEmblemTroopData(troopId)
    if troopVo==nil then
        do return end
    end
    local times=emblemTroopCfg.main.autoLimit[washTimeIndex]
    if times and times>0 then
        local costReward=self:getTroopWashCost(washType)
        if costReward then
            local hadNum=0
            if costReward.key=="gems" then
                hadNum=playerVoApi:getGems()
            else
                hadNum=bagVoApi:getItemNumId(costReward.id)
            end
            if hadNum<costReward.num*times then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notenoughprop"),30)
                do return end
            end
        end
        
        local function washCallBack(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.smaster and sData.data.report then
                    self:updateTroopData(sData.data.smaster)
                    self:updateWashData(sData.data.xtimes)
                    if costReward then
                        if costReward.key=="gems" then
                            playerVoApi:setGems(playerVoApi:getGems()-costReward.num*times)
                        else
                            local id=(tonumber(costReward.id) or tonumber(RemoveFirstChar(costReward.id)))
                            bagVoApi:useItemNumId(id,costReward.num*times)
                        end
                    end

                    local report=sData.data.report
                    if callback then
                        callback(report)
                    end
                end
            end
        end
        socketHelper:emblemTroopWashAuto(troopId,washType,washTimeIndex,washSave,washCallBack)
    end
end

--训练
function emblemTroopVoApi:troopWash(troopId,washType,callback)
    local costReward=self:getTroopWashCost(washType)
    if costReward then
        local hadNum=0
        if costReward.key=="gems" then
            hadNum=playerVoApi:getGems()
        else
            hadNum=bagVoApi:getItemNumId(costReward.id)
        end
        if hadNum<costReward.num then
            if costReward.key=="gems" then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
            else 
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notenoughprop"),30)
            end
            do return end
        end
    end
    
    local function washCallBack(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.att then
                local attData=sData.data.att
                local troopVo=self:getEmblemTroopData(troopId)
                troopVo:updateLastWashTb("x"..washType,attData)
                self:updateWashData(sData.data.xtimes)
                if costReward then
                    if costReward.key=="gems" then
                        playerVoApi:setGems(playerVoApi:getGems()-costReward.num)
                    else
                        local id=(tonumber(costReward.id) or tonumber(RemoveFirstChar(costReward.id)))
                        bagVoApi:useItemNumId(id,costReward.num)
                    end
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:emblemTroopWash(troopId,washType,washCallBack)
end

--保存训练数据
function emblemTroopVoApi:troopWashSave(troopId,callback)
    local function saveCallBack(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data then
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:emblemTroopWashSave(troopId,saveCallBack)
end
-----------------------是军徽部队训练相关结束-----------------------

function emblemTroopVoApi:getTroopPosUnlockNeed(posIndex)
    if posIndex and emblemTroopCfg.main.unlockPlace[posIndex] then
        return emblemTroopCfg.main.unlockPlace[posIndex]
    end
    return 999999
end

--某大师某装配位是否解锁
function emblemTroopVoApi:checkIfPosUnlock(troopId,posIndex)
    local washStrengthNeed = self:getTroopPosUnlockNeed(posIndex)
    local washStrengthCurrent = 0
    local troopData = self:getEmblemTroopData(troopId)
    if troopData then
        washStrengthCurrent = troopData:getMaxWashStrength()
    end
    local isUnlock = false
    if washStrengthCurrent >= washStrengthNeed then
        isUnlock = true
    end
    return isUnlock,washStrengthNeed
end

--得到装配在某大师某位置上的装备id
function emblemTroopVoApi:getEmblemTroopPosEquipId(troopId,posIndex)
    local troopData = self:getEmblemTroopData(troopId)
    if troopData and troopData.posTb and troopData.posTb[posIndex] then
        local equipId = troopData.posTb[posIndex]
        if equipId and equipId ~= 0 then
            return equipId
        end
    end
    return nil
end

--装备大师装备位配置超级装备
function emblemTroopVoApi:troopSetEquip(troopId,selectEquipId,posIndex,callback)
    if selectEquipId then
        local equipCfg = emblemVoApi:getEquipCfgById(selectEquipId)
        if equipCfg.etype == 1 then
            -- local equipVo = self:getEquipVoByIdAndColor(selectEquipId,equipCfg.color)
            local equipVo = emblemVoApi:getEquipVoByID(selectEquipId)
            if equipVo:getUsableNum() == 0 then--已派出或已装备的不能装备
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip4"),30)
                do return end
            end
            local skillCfg
            if equipCfg.skill then
                skillCfg = emblemVoApi:getEquipSkillCfgById(equipCfg.skill[1])
            end
            local baseEquipId = Split(selectEquipId,"_")[1]
            local masterData = self:getEmblemTroopData(troopId)
            for k,v in pairs(masterData.posTb) do
                if v and v ~= 0 then
                    if Split(v,"_")[1] == baseEquipId then--同一装备大师不可装配相同（等级不同也算）的超级装备
                       smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip2"),30)
                       do return end
                    elseif skillCfg then
                        local eCfg = emblemVoApi:getEquipCfgById(v)
                        if eCfg and eCfg.skill then
                            local sCfg = emblemVoApi:getEquipSkillCfgById(eCfg.skill[1])
                            if skillCfg.stype == sCfg.stype then--也不可装配拥有同一类型技能的超级装备
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip3"),30)
                                do return end
                            end
                        end
                    end
                end
            end
            

            local function setCallBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip5"),30)
                    if callback then
                        callback()
                    end
                end
            end
            socketHelper:emblemSetTroop(troopId,selectEquipId,posIndex,setCallBack)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip1"),30)
        end        
    end
end

--装备大师装备位卸下超级装备
function emblemTroopVoApi:troopUnSetEquip(troopId,posIndex,callback)
    -- print("~~~~~~~~~~装备位卸下超级装备: ", troopId,posIndex)
    if troopId and posIndex then--卸下
        local equipId = self:getEmblemTroopPosEquipId(troopId,posIndex)
        if equipId then
            local function unSetCallBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_setTip7"),30)
                    if callback then
                        callback()
                    end
                end
            end
            socketHelper:emblemUnSetMaster(troopId,posIndex,unSetCallBack)
        end
    end
end

function emblemTroopVoApi:checkIsCanEquip(troopId,allEmblems)
    if troopId then
        local troopData = self:getEmblemTroopData(troopId)
        if troopData==nil then
            return {}
        end
        local listTb={}
        for k, v in pairs(allEmblems) do
            if v.cfg.etype==1 and v:getUsableNum()>0 then
                local canUse2 = true
                local skillCfg
                if v.cfg.skill then
                    skillCfg = emblemVoApi:getEquipSkillCfgById(v.cfg.skill[1])
                end
                local baseEquipId = Split(v.id,"_")[1]
                for km,vm in pairs(troopData.posTb) do
                    if vm and vm ~= 0 then
                        if Split(vm,"_")[1] == baseEquipId then--同一装备大师不可装配相同（等级不同也算）的超级装备
                            canUse2 = false
                        elseif skillCfg then
                            local eCfg = emblemVoApi:getEquipCfgById(vm)
                            if eCfg and eCfg.skill then
                                local sCfg = emblemVoApi:getEquipSkillCfgById(eCfg.skill[1])
                                if skillCfg.stype == sCfg.stype then--也不可装配拥有同一类型技能的超级装备
                                    canUse2 = false
                                end
                            end
                        end
                    end
                end
                if canUse2 == true then
                    -- v.num = v:getUsableNum()
                    table.insert(listTb,v)
                end
            end
        end
        return listTb
    end
    return {}
end

--根据后台拼接的部队信息字符串来解析出来部队的数据
function emblemTroopVoApi:getTroopDataByJointId(id)
    --id-p1-p2-p3-strength-hp-dmg-accuracy-evade-crit-anticrit-mid
    -- print("JointId======>",id)
    local arr=Split(id,"-")
    local type=arr[1]
    local posTb={arr[2],arr[3],arr[4]}
    local washStrength=tonumber(arr[5] or 0)
    local addSavedTb={hp=tonumber(arr[6]) or 0,dmg=tonumber(arr[7]) or 0,accuracy=tonumber(arr[8]) or 0,evade=tonumber(arr[9]) or 0,crit=tonumber(arr[10]) or 0,anticrit=tonumber(arr[11]) or 0}
    local mId=arr[12]
    return type,posTb,washStrength,addSavedTb,mId
end

--根据后台的拼接的军徽部队id来获取各个属性值
function emblemTroopVoApi:getTroopAttUpByJointId(id,attType)
    local type,posTb,washStrength,addSavedTb,mId=self:getTroopDataByJointId(id)
    if attType then
        local attri=self:getTroopAttValue(attType,type,posTb,addSavedTb,washStrength)
        return attri
    end
    local attUp={}
    for k,v in pairs(addSavedTb) do
        attUp[k]=self:getTroopAttValue(k,type,posTb,addSavedTb,washStrength)
    end
    return attUp
end

--获取部队所有的属性加成
function emblemTroopVoApi:getTroopAllAttUpByJointId(id)
    local type,posTb,washStrength,addSavedTb,mId=self:getTroopDataByJointId(id)
    local attTypeTb=self:getTroopAttributeType()
    local attUp={}
    for k,v in pairs(attTypeTb) do
        attUp[v]=self:getTroopAttValue(v,type,posTb,addSavedTb,washStrength)
    end
    return attUp
end

--获取部队信息，包括属性，技能（id是部队数据拼接起来的话，按照数据计算，如果只是部队id的话则取自身的数据计算）
function emblemTroopVoApi:getTroopInfoById(id,emTroopVo)
    local attUp,skillTb
    local isTroop,troopDataArr=self:checkIfIsEmblemTroopById(id)
    if isTroop==true then
        if troopDataArr then
            local type,posTb,washStrength,addSavedTb,mId=self:getTroopDataByJointId(id)
            local attTypeTb=self:getTroopAttributeType()
            local attUp={}
            for k,v in pairs(attTypeTb) do
                attUp[v]=self:getTroopAttValue(v,type,posTb,addSavedTb,washStrength)
            end
            skillTb=self:getTroopSkillsByPosTb(posTb)
        else
            local troopVo=emTroopVo or self:getEmblemTroopData(id)
            if troopVo then
                attUp=troopVo:getAttValueTb()
                skillTb=troopVo:getSkillTb()
            end
        end
    end
    return attUp,skillTb
end

--根据后台传的部队数据拼接的部队id来获取部队技能列表
function emblemTroopVoApi:getTroopSkillsByJointIdForBattle(id)
    local type,posTb,washStrength,addSavedTb,mId=self:getTroopDataByJointId(id)
    local skillTb=emblemTroopVoApi:getTroopSkillsByPosTb(posTb)
    local showPosTb={} --技能对应装配军徽的位置
    for k,v in pairs(posTb) do
        local equipCfg=emblemVoApi:getEquipCfgById(v)
        if equipCfg and equipCfg.skill then
            table.insert(showPosTb,k)
        end
    end
    return skillTb,showPosTb
end

function emblemTroopVoApi:getTroopIconPic(equipId,washStrength)
    local path="public/emblem/icon/"
    local unlockIndex=self:getEmblemTroopPosUnlockNum(washStrength)
    if unlockIndex>0 then
        return path.."emblemIcon_"..equipId.."_"..unlockIndex..".png"
    end
    return path.."emblemIcon_"..equipId..".png"
end

function emblemTroopVoApi:getTroopIconById(troopId,callback,withBg,isBig,emTroopVo)
    local bgFlag=(withBg==nil) and true or withBg
    local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(troopId)
    if isTroop==true then
        local iconBg
        if data then
            local type,posTb,washStrength,addSavedTb=self:getTroopDataByJointId(troopId)
            local strength=self:getTroopStrengthByTroopData(type,posTb,addSavedTb,washStrength)
            local colorTb=self:getTroopEquipColorTbByPosTb(posTb)
            if bgFlag==true then
                iconBg=self:getTroopIconWithBg(type,strength,washStrength,colorTb,callback,isBig)
            else
                iconBg=self:getTroopIconNoBg(type,strength,washStrength,colorTb,callback)
            end
        else
            local troopVo=emTroopVo or self:getEmblemTroopData(troopId)
            if troopVo then
                if bgFlag==true then
                    iconBg=troopVo:getIconWithBg(callback,isBig)
                else
                    iconBg=troopVo:getIconNoBg(callback)
                end
            end
        end
        return iconBg
    end
    return nil
end

--获取当前档位的最大强度值
function emblemTroopVoApi:getTroopCurMaxStrength()
    local index = self:getTroopStrengthRewardState()
    if index == nil then
        index = 1
    else
        index = index + 1
    end
    local cfg = self:getTroopStrengthUnlockCfg()
    local cfgSize = SizeOfTable(cfg)
    if cfg[index] then
        return cfg[index].allstrNeed
    end
    local tipStr = nil
    if cfgSize == index - 1 then
        tipStr = getlocal("emblem_troop_activateAllReward")
    end
    return cfg[cfgSize].allstrNeed, tipStr
end

--是否可以激活强度奖励
function emblemTroopVoApi:isCanActiveStrengthReward()
    local cfg = self:getTroopStrengthUnlockCfg()
    local index = self:getTroopStrengthRewardState()
    if index and index==SizeOfTable(cfg) then
        return false
    else
        local curStrength = self:getTroopListMaxStrength()
        local maxStrength = self:getTroopCurMaxStrength()
        if curStrength >= maxStrength then
            return true
        end
    end
    return false
end

--军徽部队强度奖励激活接口
function emblemTroopVoApi:emblemTroopActiveStrengthReward(callback)
    local function onSocketCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.xtimes then
                self:updateWashData(sData.data.xtimes)
            end
            if type(callback)=="function" then
                callback()
            end
        end
    end
    socketHelper:emblemTroopActiveStrengthReward(onSocketCallback)
end

--军徽部队购买和洗练道具购买数据
function emblemTroopVoApi:updateShopData(sshop)
    if sshop then
        self.shopData = sshop
    end
end

--获取军徽部队可购买次数
function emblemTroopVoApi:getEmblemTroopBuyNum()
    local num = 0
    local index = self:getTroopStrengthRewardState()
    if index then
        local cfg = self:getTroopStrengthUnlockCfg()
        for k, v in pairs(cfg) do
            if index >= k and v.unlock then
                if type(v.unlock) == "table" then
                    num = num + SizeOfTable(v.unlock)
                else
                    num = num + 1
                end
            end
        end
        if self.shopData and self.shopData.i2 then
            num = num - self.shopData.i2
        end
    end
    return num
end

--获取购买军徽部队所消耗的道具
function emblemTroopVoApi:getEmblemTroopCostItem()
    local costIndex = 1
    if self.shopData and self.shopData.i2 then
        costIndex = self.shopData.i2 + 1
    end
    local costItem = emblemTroopCfg.shopList.i2.cost[costIndex]
    if costItem then
        costItem=FormatItem(costItem)[1]
        return costItem
    end
end

--军徽部队购买和洗练道具购买接口
function emblemTroopVoApi:emblemTroopShopExchange(shopId,buyNum,callback)
    local function onSocketCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.smaster then --军徽部队数据
                self:updateTroopData(sData.data.smaster)
            end
            if sData and sData.data and sData.data.sshop then --军徽部队购买和洗练道具购买数据
                self:updateShopData(sData.data.sshop)
            end
            if sData and sData.data and sData.data.xtimes then
                self:updateWashData(sData.data.xtimes)
            end
            if type(callback)=="function" then
                callback()
            end
        end
    end
    socketHelper:emblemTroopShopExchange(shopId,buyNum,onSocketCallback)
end

--获取道具可购买次数
function emblemTroopVoApi:getShopItemBuyNum(itemKey)
    if self.shopData and self.shopData.t and self.shopData[itemKey] then
        local itemCfg=emblemTroopCfg.shopList[itemKey]
        if itemCfg.costType==0 then
            return tonumber(self.shopData[itemKey])
        else
            local ts=self.shopData.t
            if ts and ts==G_getWeeTs(base.serverTime) then
                return tonumber(self.shopData[itemKey])
            else
                return 0
            end
        end
    end
    return 0
end

function emblemTroopVoApi:getTroopEquipPosUnlockCfgByIndex(index)
    local cfg = self:getTroopEquipPosUnlockCfg()
    if index and cfg["q"..index] then
        return cfg["q"..index]
    end
    return nil
end

function emblemTroopVoApi:getEmblemTroopPlaceGetCfg()
    return emblemTroopCfg.main.placeGet
end