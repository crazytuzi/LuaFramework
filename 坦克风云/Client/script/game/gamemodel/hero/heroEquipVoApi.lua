
heroEquipVoApi={
	xp_e1=0,--将领装备经验，前4个普通装备升级使用
	xp_e2=0,--勋章经验，挑战勋章升级使用
	xp_e3=0,--战术经验，战术书升级使用
	ap=0,--军演积分
	ep=0,--远征积分
	equipVoList={},--装备vo数组
	ifNeedSendRequest=true,--是否需要发送请求
	last_at=0,--上次研究的时间戳
	heroOpenFlag=false, --将领功能页面是否打开的标识，为了防止重复打开此页面设定
}

function heroEquipVoApi:clear()
	self.xp_e1=0
	self.xp_e2=0
	self.xp_e3=0
	self.ap=0
	self.ep=0
	self.equipVoList=nil
	self.equipVoList={}--装备vo数组
	self.ifNeedSendRequest=true--是否需要请求装备
	self.last_at=0
	self.heroOpenFlag=false
	if(heroEquipChallengeVoApi and heroEquipChallengeVoApi.clear)then
		heroEquipChallengeVoApi:clear()
	end
end
function heroEquipVoApi:formatData(data)
	self.ifNeedSendRequest=false
	if data.e1 then
		self.xp_e1=data.e1
	end
	if data.e2 then
		self.xp_e2=data.e2
	end
	if data.e3 then
		self.xp_e3=data.e3
	end
	if data.ap and arenaVoApi then
		arenaVoApi:setPoint(data.ap)
	end
	if data.ep and expeditionVoApi then
		expeditionVoApi:setPoint(data.ep)
	end
	if data.info then
		local eVo
		for k,v in pairs(data.info) do
			eVo = heroEquipVo:new()
			eVo:initWithData(k,v)
			self.equipVoList[k]=eVo
		end
	end
	if data.last_at then
		self.last_at=data.last_at
	end
end

function heroEquipVoApi:formatInfoData(info)
	if info then
		local eVo
		for k,v in pairs(info) do
			eVo = heroEquipVo:new()
			eVo:initWithData(k,v)
			self.equipVoList[k]=eVo
		end
	end
end

-- 
function heroEquipVoApi:addEquipXp(key,value)
	if key=="e1" then
		self.xp_e1=self.xp_e1+value
	elseif key=="e2" then
		self.xp_e2=self.xp_e2+value
	elseif key=="e3" then
		self.xp_e3=self.xp_e3+value
	end
end

-- 根据hid和eid来获取该装备的icon
-- hid将领id,size：icon的尺寸，eid装备id,callback点击icon的回调方法,showTipIcon=1,是否显示可升级,=2可觉醒的提示,addAdvanceLv添加的进阶等级
function heroEquipVoApi:getEquipIcon(hid,size,eid,callback,addAwakenLv,productOrder,showTipIcon,addAdvanceLv)
	-- equip_e1_0.png   e1:武器,0为觉醒前
	local awakenLv = self:getAwakenLevelByEidAndIndex(hid,eid)
	local awakenMaxLv = self:getAwakenMaxLevel(hid,eid)
	local ifAwakenMaxLv = false
	if awakenLv==awakenMaxLv then
		ifAwakenMaxLv=true
	end
	
	if addAwakenLv then
		awakenLv=awakenLv+addAwakenLv
	end
	
	local jinjieLv = self:getJinjieLevelByEidAndIndex(hid,eid,productOrder)
	if addAdvanceLv then
		jinjieLv=jinjieLv+addAdvanceLv
	end
	local picBg,diamondPic,diamondNum=heroEquipVoApi:getEquipIconBg(jinjieLv)
	
	local iconSp = LuaCCScale9Sprite:createWithSpriteFrameName(picBg,CCRect(20, 20, 10, 10),callback)
	iconSp:setContentSize(size)

	local picStr = heroEquipVoApi:getEquipIconPic(hid,eid,addAwakenLv)
	local icon=CCSprite:createWithSpriteFrameName(picStr)
	icon:setPosition(getCenterPoint(iconSp))
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setScale(size.width/100*90/icon:getContentSize().width)
	iconSp:addChild(icon)
	for i=1,awakenLv do
		local starSize=18
		local starSpace=18
		local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
		starSp:setAnchorPoint(ccp(0.5,0))
		starSp:setScale(starSize/starSp:getContentSize().width)
		local px=iconSp:getContentSize().width/2-starSpace/2*(awakenLv-1)+starSpace*(i-1)
		local py=10
		starSp:setPosition(ccp(px,py))
		iconSp:addChild(starSp,1)
	end
	if diamondNum>0 then
		for i=1,diamondNum do
			local starSpace=18
			local starSp=CCSprite:createWithSpriteFrameName(diamondPic)
			local px=iconSp:getContentSize().width/2-starSpace/2*(diamondNum-1)+starSpace*(i-1)
			local py=iconSp:getContentSize().height
			starSp:setPosition(ccp(px,py))
			iconSp:addChild(starSp,1)
		end
	end
	if showTipIcon then
		local ifShowTipIcon = false
		if showTipIcon==1 then
			ifShowTipIcon=self:checkIfCanUpOrJinjie(hid,eid,productOrder)
		elseif showTipIcon==2 then
			ifShowTipIcon=self:checkIfCanAwaken(hid,eid,productOrder)
		end
		if ifShowTipIcon==true then
			local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
            tipSp:setAnchorPoint(CCPointMake(1,0.5))
            tipSp:setPosition(ccp(iconSp:getContentSize().width+10,iconSp:getContentSize().height-5))
            iconSp:addChild(tipSp)
            tipSp:setScale(0.7)
		end
	end
	return iconSp
end

-- 获取装备icon图
function heroEquipVoApi:getEquipIconPic(hid,eid,addAwakenLv)
	local awakenLv = self:getAwakenLevelByEidAndIndex(hid,eid)
	local picStr = "equip_"..eid.."_0.png"
	if addAwakenLv then
		awakenLv=awakenLv+addAwakenLv
	end
	if awakenLv>0 then
		picStr = "equip_"..eid.."_1.png"
	end
	return picStr
end

-- 获取装备icon背景图
function heroEquipVoApi:getEquipIconBg(jinjieLv)
	local bg="equipBg_gray.png"
	local diamondPic = "diamond_green.png"
	local diamondNum = 0--几颗钻石
	if jinjieLv==2 or jinjieLv==3 or jinjieLv==4 then
		bg="equipBg_green.png"
		diamondPic = "diamond_green.png"
		diamondNum=jinjieLv%2
		if jinjieLv==4 then
			diamondNum=2
		end
	elseif jinjieLv==5 or jinjieLv==6 or jinjieLv==7 or jinjieLv==8 then
		bg="equipBg_blue.png"
		diamondPic = "diamond_blue.png"
		diamondNum=jinjieLv%5
	elseif jinjieLv==9 then
		bg="equipBg_purple.png"
		diamondPic = "diamond_purple.png"
		diamondNum=jinjieLv%9
	-- elseif jinjieLv==10 then
	-- 	bg="diamond_orange.png"
	-- 	diamondPic = "equipBg_orange.png"
	end
	return bg,diamondPic,diamondNum
end

-- 获取装备名称的颜色
function heroEquipVoApi:getEquipNameColor(jinjieLv)
	local color = G_ColorWhite
	if jinjieLv==2 or jinjieLv==3 or jinjieLv==4 then
		color=G_ColorGreen
	elseif jinjieLv==5 or jinjieLv==6 or jinjieLv==7 or jinjieLv==8 then
		color=G_ColorBlue
	elseif jinjieLv==9 then
		color=G_ColorPurple
	-- elseif jinjieLv==10 then
	-- 	color=G_ColorOrange
	end
	return color
end

function heroEquipVoApi:getEquipVo(hid)
	if self.equipVoList and self.equipVoList[hid] then
		return self.equipVoList[hid]
	end
	return nil
end

--设置上一次免费研究的时间戳
function heroEquipVoApi:setLast_at(last_at)
	self.last_at=last_at
end

-- 是否有免费的研究次数
function heroEquipVoApi:checkIfHasFreeLottery()
	if self.last_at==0 then
		return true,0
	end
	local t = base.serverTime-self.last_at
	if t>0 and math.ceil(t/3600)>20 then--大于20个小时可以有一次免费机会
		return true,0
	end
	return false,GetTimeStr(3600*20-t)
end

-- 获取装备id
function heroEquipVoApi:getHeroEidList()
	return {"e1","e3","e5","e2","e4","e6"}
end

-- 装备名称
function heroEquipVoApi:getEquipName(hid,eid,addAwakenLv)
	local awakenLv = self:getAwakenLevelByEidAndIndex(hid,eid)
	local name = getlocal("equip_name_"..eid.."_0")
	if addAwakenLv then
		awakenLv=awakenLv+addAwakenLv
	end
	if awakenLv>0 then
		name = getlocal("equip_name_"..eid.."_1")
	end

	return name
end
-- 获取装备强化等级
function heroEquipVoApi:getUpLevelByEidAndIndex(hid,eid)
	local eVo = self:getEquipVo(hid)
	local upLv = 1
	local jinjieLv = 1
	local maxLevel = self:getCanUpgradeMaxUpLevel(jinjieLv)
	if eVo and eVo.eList and eVo.eList[eid] then
		upLv=eVo.eList[eid][1]
		jinjieLv=eVo.eList[eid][2]
		maxLevel=self:getCanUpgradeMaxUpLevel(jinjieLv)
	end
	return upLv,maxLevel
end
-- 当前可以强化的最高等级，level：进阶的等级
function heroEquipVoApi:getCanUpgradeMaxUpLevel(level)
	if equipCfg and equipCfg.growLimit and equipCfg.growLimit[level] then
		return tonumber(equipCfg.growLimit[level])
	end
	return 1
end
-- 获取装备进阶等级,maxLv:最大可进阶的等级,productOrder英雄的品阶
function heroEquipVoApi:getJinjieLevelByEidAndIndex(hid,eid,productOrder)
	local eVo = self:getEquipVo(hid)
	
	local curMaxLv = equipCfg.upgradeLimit[productOrder]
	-- 后端version限制的等级
	local unEquipLevel = playerVoApi:getMaxLvByKey("unEquipLevel")
	if eVo and eVo.eList and eVo.eList[eid] then
		return eVo.eList[eid][2],curMaxLv,unEquipLevel
	end
	return 1,curMaxLv,unEquipLevel
end


-- 获取装备觉醒等级
function heroEquipVoApi:getAwakenLevelByEidAndIndex(hid,eid)
	local eVo = self:getEquipVo(hid)
	if eVo and eVo.eList and eVo.eList[eid] then
		return eVo.eList[eid][3]
	end
	return 0
end

function heroEquipVoApi:getEquipAttrName(eid)
	local attrName = ""
	local attrNum = 1000
	attrName=getlocal("tankBlood")
	return attrName,attrNum
end

-- 获取强化需要消耗的道具配置
function heroEquipVoApi:getUpCostProp(hid,eid,upLv)
	local lv
	if upLv==nil then
		lv = self:getUpLevelByEidAndIndex(hid,eid)
	else
		lv=upLv
	end
	local cfg = nil
	if equipCfg and equipCfg[hid] and equipCfg[hid][eid] and equipCfg[hid][eid].grow  and equipCfg[hid][eid].grow.cost and equipCfg[hid][eid].grow.cost[lv] then
		cfg=equipCfg[hid][eid].grow.cost[lv]
	end
	local award = FormatItem(cfg)
	local ownNum = 0
	local needNum = 0
	local xpname
	-- 支持一种道具
	for k,v in pairs(award) do
		if v and v.key and v.key=="e1" then
			ownNum=self.xp_e1
			xpname=getlocal("sample_prop_name_e1")
		elseif v and v.key and v.key=="e2" then
			ownNum=self.xp_e2
			xpname=getlocal("sample_prop_name_e2")
		elseif v and v.key and v.key=="e3" then
			ownNum=self.xp_e3
			xpname=getlocal("sample_prop_name_e3")
		end
		needNum=v.num
	end
	return award,ownNum,needNum,xpname
end
-- 获取装备进阶需要消耗的道具配置
function heroEquipVoApi:getJinjieCostProp(hid,eid,productOrder)
	local lv = self:getJinjieLevelByEidAndIndex(hid,eid,productOrder)
	if equipCfg and equipCfg[hid] and equipCfg[hid][eid] and equipCfg[hid][eid].upgrade  and equipCfg[hid][eid].upgrade.cost and equipCfg[hid][eid].upgrade.cost[lv] then
		local costList = equipCfg[hid][eid].upgrade.cost[lv]
		return costList
	end
	return nil
end

-- 获取装备觉醒需要消耗的道具配置
function heroEquipVoApi:getAwakenCostProp(hid,eid)
	local lv = self:getAwakenLevelByEidAndIndex(hid,eid)
	if equipCfg and equipCfg[hid] and equipCfg[hid][eid] and equipCfg[hid][eid].awaken  and equipCfg[hid][eid].awaken.cost and equipCfg[hid][eid].awaken.cost[lv+1] then
		return equipCfg[hid][eid].awaken.cost[lv+1]
	end
	return nil
end

-- 觉醒可以升级的多高等级
function heroEquipVoApi:getAwakenMaxLevel(hid,eid)
	return SizeOfTable(equipCfg[hid][eid].awaken.cost)
end

-- 获取属性加成列表,addAwakenLv=2显示下2级的属性，-1为上一级的属性
function heroEquipVoApi:getAttList(hid,eid,addAwakenLv,productOrder,upLevel,addAdvanceLv)
	local upLv
	if upLevel==nil then
		upLv = self:getUpLevelByEidAndIndex(hid,eid)
	else
		upLv=upLevel
	end
	local jinjieLv = self:getJinjieLevelByEidAndIndex(hid,eid,productOrder)
	local awakenLv = self:getAwakenLevelByEidAndIndex(hid,eid)
	local awakenMaxLv = self:getAwakenMaxLevel(hid,eid)
	local upAtt = equipCfg[hid][eid].grow.att
	local jinjieAtt = equipCfg[hid][eid].upgrade.att
	local awakenAtt = equipCfg[hid][eid].awaken.att
	local attList = {}
	local ifAwakenMaxLv = false

	if awakenLv==awakenMaxLv then
		ifAwakenMaxLv=true
	end
	
	if addAwakenLv then
		awakenLv=awakenLv+addAwakenLv
	end

	if addAdvanceLv then
		jinjieLv=jinjieLv+addAdvanceLv
	end
	
	local tb={atk={icon="attributeARP.png",lb={getlocal("dmg"),},sort=1},
            hlp={icon="attributeArmor.png",lb={getlocal("hlp"),},sort=1},
            hit={icon="skill_01.png",lb={getlocal("sample_skill_name_101"),},sort=1},
            eva={icon="skill_02.png",lb={getlocal("sample_skill_name_102"),},sort=1},
            cri={icon="skill_03.png",lb={getlocal("sample_skill_name_103"),},sort=1},
            res={icon="skill_04.png",lb={getlocal("sample_skill_name_104"),},sort=1},
            first={icon="skill_04.png",lb={getlocal("firstValue"),},sort=100},
           }
    for k,v in pairs(upAtt) do
    	if attList[k]==nil then
    		attList[k]={icon=tb[k].icon,lb=tb[k].lb,value=tonumber(v)*upLv,sort=tb[k].sort,key=k}
    	end
    end
    for k,v in pairs(jinjieAtt) do
    	if attList[k]==nil then
    		
    		attList[k]={icon=tb[k].icon,lb=tb[k].lb,value=tonumber(v)*jinjieLv,sort=tb[k].sort,key=k}
    	else
    		attList[k].value=attList[k].value+tonumber(v)*jinjieLv
    	end
    end
    for k,v in pairs(awakenAtt) do
    	if attList[k]==nil then
    		attList[k]={icon=tb[k].icon,lb=tb[k].lb,value=tonumber(v)*awakenLv,sort=tb[k].sort,key=k}
    	else
    		attList[k].value=attList[k].value+tonumber(v)*awakenLv
    	end
    end

    local newAttList = {}
    for k,v in pairs(attList) do
    	table.insert(newAttList,v)
    end
    local function sortA(a,b)
    	if a and b and a.sort and b.sort then
    		return tonumber(a.sort)<tonumber(b.sort)
    	end
    end
    table.sort(newAttList,sortA)
    return newAttList,ifAwakenMaxLv,attList
end

-- 获取该英雄所有装备属性加成
function heroEquipVoApi:getAttListByHid(hid,addAwakenLv,productOrder,upLevel)
	local allAttList = {}
	for k,v in pairs(self:getHeroEidList()) do
		local a,b,attList=self:getAttList(hid,v,addAwakenLv,productOrder,upLevel)
		for kk,vv in pairs(attList) do
			if allAttList[kk]==nil then
	    		allAttList[kk]={icon=vv.icon,lb=vv.lb,value=tonumber(vv.value),sort=vv.sort,key=kk}
	    	else
	    		allAttList[kk].value=allAttList[kk].value+tonumber(vv.value)
	    	end
		end
	end

	local newAllAttList = {}
	for k,v in pairs(allAttList) do
		table.insert(newAllAttList,v)
	end
	local function sortA(a,b)
		if a and b and a.sort and b.sort then
			return a.sort<b.sort
		end
	end
	table.sort(newAllAttList,sortA)
	return allAttList,newAllAttList
end

-- 装备战力
function heroEquipVoApi:getEquipFight(hid,productOrder,upLv,eid)
	local fight = 0
	local totalFirstValue = 0
	local otherSkillValue = 0
	for k,v in pairs(self:getHeroEidList()) do
		local attList = self:getAttList(hid,v,nil,productOrder)
		if eid and eid==v and upLv then
			attList = self:getAttList(hid,v,nil,productOrder,upLv)
		end
		if attList then
			for kk,vv in pairs(attList) do
				-- if kk=="first" then
				if vv["key"]=="first" then	
					totalFirstValue=totalFirstValue+tonumber(vv.value)
				else
					otherSkillValue=otherSkillValue+vv.value
				end
			end
		end
	end
	-- cri,res,hit,eva,atk,hlp之和*8+first*2
	fight=totalFirstValue*2+otherSkillValue*8
	fight=math.floor(fight)
	return fight
end

--拿到所有将领的装备战力
function heroEquipVoApi:getAllEquipFightPower( )
	local heroList = heroVoApi:getHeroList()
	local powers = 0
	for k,v in pairs(heroList) do
		powers = powers + self:getEquipFight(v.hid, v.productOrder)
	end
	return powers
end

-- 获取技能列表
function heroEquipVoApi:getSkillList(hid,eid)
	if equipCfg[hid][eid].awaken.skill then
		local awakenSkill = equipCfg[hid][eid].awaken.skill
		return awakenSkill
	end
	return nil
end

-- 获取该道具的途径,pid道具的id,rtype=1:装备探索，rtype=2:装备研究所商店,rtype=3:装备研究所,rtype=4:限时精工石商店,rtype=5:活动产出，但不说明是哪个活动,rtype=99暂未开放
function heroEquipVoApi:getPropChannelList(pid,type)
	local tb = {}
	local newTb = {}
	local rtype = 0
	if pid ==489 or pid ==491 or pid ==493 or pid ==494 or pid ==496 or pid ==498 or pid ==499 then
		rtype = 2
		table.insert(newTb,1)
	elseif  (pid>=481 and pid<=487) then
		rtype = 3
		table.insert(newTb,1)
	elseif pid ==488 or pid ==490 or pid ==492 or pid ==495 or pid ==497 or pid==937 or pid==938 or pid==939 or pid==940 then
		rtype=4
		table.insert(newTb,1)
	elseif (pid>=941 and pid<=946) or pid==5020 or pid==5021 then
		rtype=5
		table.insert(newTb,1)
	else
		rtype=1
		if hChallengeCfg and hChallengeCfg.list then
			for k,v in pairs(hChallengeCfg.list) do
				local baseReward = FormatItem(v.clientReward.base)
				local randReward = FormatItem(v.clientReward.rand)
				local ifHas = false
				for kk,vv in pairs(baseReward) do
					if ifHas==false then
						if vv.id and vv.id==pid then
							
							table.insert(tb,k)
							ifHas=true
						end
					end
				end
				for kk,vv in pairs(randReward) do
					if ifHas==false then
						if vv.id and vv.id==pid then
							table.insert(tb,k)
							ifHas=true
						end
					end
				end
			end
		end

		local function sortA(a,b)
			if a and b then
				return a<b
			end
		end
		table.sort(tb,sortA)
		
		-- if SizeOfTable(tb)>3 then
		-- 	for k,v in pairs(tb) do
		-- 		if SizeOfTable(newTb)<3 then
		-- 			table.insert(newTb,v)
		-- 		else
		-- 			local chapterId,index=heroEquipChallengeVoApi:getChapterIdByPointId(v)
		-- 			local isUnlock=heroEquipChallengeVoApi:checkPointIsUnlock(chapterId,index)
		-- 			if isUnlock==true then
		-- 				newTb[1]=nil
		-- 				table.insert(newTb,v)
		-- 			end
		-- 		end
		-- 	end
		-- else
			newTb=tb
		-- end
		table.sort(newTb,sortA)
	end

	
	return newTb,rtype
end

-- 展示觉醒商店
function heroEquipVoApi:showAwakeShop(layerNum,closeCallback)
	-- require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipAwakeShopDialog"
	-- local td=heroEquipAwakeShopDialog:new(closeCallback)
	-- local tbArr={}
	-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("equip_awakenShop"),true,layerNum)
	-- sceneGame:addChild(dialog,layerNum)
	local td = allShopVoApi:showAllPropDialog(layerNum,"seiko",closeCallback)
end


function heroEquipVoApi:openEquipLabDialog(layerNum,ifOpenShop,callback)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroEquipLabDialog" 
    local td=heroEquipLabDialog:new(ifOpenShop,callback)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("equip_lab_title"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

function heroEquipVoApi:checkIfCanUpOrJinjie(hid,eid,productOrder)
	local upLv,maxLevel = self:getUpLevelByEidAndIndex(hid,eid)
	local isCommonUpgrade=true
	local jinjieLv,maxJinjieLv,unEquipLevel=self:getJinjieLevelByEidAndIndex(hid,eid,productOrder)
	local maxUpLv = self:getCanUpgradeMaxUpLevel(unEquipLevel)
	if upLv>=maxUpLv then
		-- print("----dmj----hid:"..hid.."--eid:"..eid.."upLv:"..upLv.."--maxUpLv:"..maxUpLv.."--unEquipLevel;"..unEquipLevel.."==maxLevel:"..maxLevel)
		return false,1
	end

	if upLv>=maxLevel then
		-- 目前是进阶等级
		-- print("----dmj--2--hid:"..hid.."--eid:"..eid.."upLv:"..upLv.."--maxUpLv:"..maxUpLv.."--unEquipLevel;"..unEquipLevel.."==maxLevel:"..maxLevel)
		--装备进阶受英雄品阶的影响，当当前装备进阶等级大于等于英雄品阶的限制等级，则不可进阶
		local limitLv = equipCfg.upgradeLimit[productOrder]
		if jinjieLv >= limitLv then
			return false,2
		end
	
		local jinjieCost=self:getJinjieCostProp(hid,eid,productOrder)
		local isCommonEquip = true
		local pointValue = 0
		if eid=="e5" then
			pointValue=arenaVoApi:getPoint()
			isCommonEquip=false
		elseif eid=="e6" then
			pointValue=expeditionVoApi:getPoint()
			isCommonEquip=false
		end

		if pointValue == nil then
			-- 如果是nil置0
			pointValue = 0
		end

		local award = FormatItem(jinjieCost)
		if isCommonEquip==true then
			for i,v in pairs(award) do
				local item = v
                local curNum = bagVoApi:getItemNumId(item.id) or 0
                local needNum = item.num
                if needNum == nil or curNum<needNum then
                	return false,3
                end
			end
		else
			for k,v in pairs(award) do
				if v.num == nil or pointValue<v.num then
					return false,4
				end
			end
		end
		return true
	else
		-- print("----dmj--3--hid:"..hid.."--eid:"..eid.."upLv:"..upLv.."--maxUpLv:"..maxUpLv.."--unEquipLevel;"..unEquipLevel.."==maxLevel:"..maxLevel)
		-- 目前是强化等级
		local award,ownNum,needNum,xpname = self:getUpCostProp(hid,eid,upLv)
		-- print("-----dmj----ownNum:"..ownNum.."--needNum:"..needNum)
		if ownNum>=needNum then
			return true
		end
	end
	
	return false,5
end

function heroEquipVoApi:checkIfCanAwaken(hid,eid,productOrder)
	local awakenLv = self:getAwakenLevelByEidAndIndex(hid,eid)
	local awakenMaxLv = self:getAwakenMaxLevel(hid,eid)
	if awakenLv>=awakenMaxLv then
		return false
	end
	local costProp = self:getAwakenCostProp(hid,eid)
	local award = FormatItem(costProp)
	if award then
		for k,v in pairs(award) do
			local item = v
            local curNum = bagVoApi:getItemNumId(item.id)
            local needNum = item.num
            if curNum<needNum then
            	return false
            end
		end
	end
	return true
end

function heroEquipVoApi:checkIfCanUpOrJinjieByHid(hid,productOrder)
	for k,v in pairs(self:getHeroEidList()) do
		if self:checkIfCanUpOrJinjie(hid,v,productOrder)==true then
			return true
		end
	end
	return false
end

function heroEquipVoApi:checkIfCanAwakenByHid(hid,productOrder)
	for k,v in pairs(self:getHeroEidList()) do
		if self:checkIfCanAwaken(hid,v,productOrder)==true then
			return true
		end
	end
	return false
end

-- 是否能进行装备强化
function heroEquipVoApi:isCanStreng()
	local heroList = heroVoApi:getHeroList()
	if SizeOfTable(heroList)==0 then
		return false
	end
	local sizeNum = SizeOfTable(equipCfg.growLimit)
	local maxLv=equipCfg.growLimit[sizeNum]
	for k,v in pairs(heroList) do
		local equipVo=self:getEquipVo(v.hid)
		if equipVo==nil or equipVo.eList==nil then
			return false
		end
		if SizeOfTable(equipVo.eList)<6 then
			return false
		end

		for kk,vv in pairs(equipVo.eList) do
			if vv[1]<maxLv then
				return false
			end
		end
	end
	return true
end

--获取装备信息
function heroEquipVoApi:equipGet(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data.equip then
				heroEquipVoApi:formatData(sData.data.equip)
			end
			if sData and sData.data and sData.data.hchallenge then
				if(heroEquipChallengeVoApi and heroEquipChallengeVoApi.formatData)then
					heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
				end
			end
			if(callback)then
				callback()
			end
		end
	end
	if heroEquipChallengeVoApi and heroEquipChallengeVoApi.getIfNeedSendECRequest and heroEquipChallengeVoApi:getIfNeedSendECRequest()==true then
		socketHelper:getHeroEquip(onRequestEnd,1)
	else
		socketHelper:getHeroEquip(onRequestEnd)
	end
end

function heroEquipVoApi:isOpen()
	if base.heroSwitch==0 then
		return false
	end
	if base.he == 1 then
		local equipOpenLv = base.heroEquipOpenLv or 30
		if playerVoApi:getPlayerLevel() >= equipOpenLv then
			return true
		end
	end
	return false
end

--获取免费数据
--[[@return
	{ 
		{ 当前免费次数, 最大免费次数(写死1次) },
	}
--]]
function heroEquipVoApi:getFreeData()
	local isFree, num = self:checkIfHasFreeLottery()
	if isFree==true and num==0 then
		num=1
	else
		num=0
	end
	return { {num,1} }
end

