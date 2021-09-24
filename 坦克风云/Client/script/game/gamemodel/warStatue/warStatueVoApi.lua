require "luascript/script/config/gameconfig/statueCfg"
require "luascript/script/game/gamemodel/warStatue/warStatueVo"
warStatueVoApi={
	statueList={},
}

--1：功能未开启，2：等级不够
function warStatueVoApi:isWarStatueOpened()
	if base.warStatueSwitch==0 then
		return 1
	end
	local playerLv=playerVoApi:getPlayerLevel()
	if playerLv<statueCfg.opneLevel then
		return 2,statueCfg.opneLevel
	end
	return 0
end

function warStatueVoApi:formatData(data)
	if data==nil or data.statue==nil then
		do return end
	end
	self.statueList={}
	local playerLv=playerVoApi:getPlayerLevel()
	for k,v in pairs(statueCfg.room) do
		local unlockLv=v[1] or 0
		if playerLv>=unlockLv then
			local statueVo=warStatueVo:new(k)
			self.statueList[k]=statueVo
		end
	end
	
	for k,v in pairs(data.statue) do
		local statueVo=self.statueList[k]
		if statueVo==nil then
			statueVo=warStatueVo:new(k)
		end
		statueVo:initWithData(v)
		self.statueList[k]=statueVo
	end
end

function warStatueVoApi:updateData(data)
	if data.statue==nil then
		do return end
	end
	for k,v in pairs(data.statue) do
		local statueVo=self.statueList[k]
		statueVo:updateData(v)
	end
end

function warStatueVoApi:getStatueList()
	return self.statueList
end

--初始化战争塑像的数据
function warStatueVoApi:initWarStatue(callback,waitFlag)
	if self:isWarStatueOpened()~=0 then
		do return end
	end
	local function initStatueCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data.statue then
				self:formatData(sData.data.statue)
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:getWarStatue(initStatueCallBack,waitFlag)
end

--激活将领
function warStatueVoApi:activateHero(action,sid,hid,callback)
	if self:isWarStatueOpened()~=0 then
		do return end
	end
	local function activateCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local lastStatueVo=G_clone(self.statueList[sid])
			if sData.data.statue then
				self:updateData(sData.data.statue)
			end
			local statueVo=self.statueList[sid]
			if callback then
				local oldfc,newfc
				if sData.data.oldfc and sData.data.newfc then
					oldfc=sData.data.oldfc
					newfc=sData.data.newfc
				end
				callback(lastStatueVo,statueVo,oldfc,newfc)
			end
			local data={sid=sid}
        	eventDispatcher:dispatchEvent("warstatue.refresh",data)
		end
	end
	socketHelper:activateStatueHero(action,sid,hid,activateCallBack)
end

function warStatueVoApi:getWarStatueBuffLv(sid,vo)
	local statueVo
	if vo then
		statueVo=vo
	else
		statueVo=self.statueList[sid]
	end
	if statueVo then
		local scfg=statueCfg.room[statueVo.sid]
		if scfg and scfg[2] then
			local buffLv
			local herolist=scfg[2]
			for k,hid in pairs(herolist) do
				local activeLv=statueVo.hero[hid] or 0
				if buffLv==nil then
					buffLv=activeLv
				elseif activeLv<buffLv then
					buffLv=activeLv
				end
			end
			if buffLv and buffLv>statueCfg.openStatue then --当前技能buff等级不能超过开放的品阶
				buffLv=statueCfg.openStatue
			end
			return (buffLv or 0)
		end
	end
	return 0
end

--获取所有的已解锁的战争塑像增加的buff（包括战斗buff和技能buff）
function warStatueVoApi:getTotalWarStatueAddedBuff(buffKey)
	if self:isWarStatueOpened()~=0 then
		do return {},{} end
	end
	local battleBuff,skillBuff={},{}
	if buffKey then
		battleBuff[buffKey]=0
		skillBuff[buffKey]=0
	else
		battleBuff={dmage=0,dmg=0,dmg_reduce=0,first=0,add=0,accuracy=0,maxhp=0,evade=0,crit=0,anticrit=0,antifirst=0}
		skillBuff={moveSpeed=0,colloctSpeed=0,madeSpeed=0,studySpeed=0,buildSpeed=0,honourLimit=0,pNewSpeed=0,productTankSpeed=0,refitTankSpeed=0}
	end
	for sid,statueVo in pairs(self.statueList) do
		local buffLv=self:getWarStatueBuffLv(sid)
		local scfg=statueCfg.skill[sid]
		if scfg then
			local realBuffCfg=scfg[buffLv] or {}
			if buffKey then
				battleBuff[buffKey]=battleBuff[buffKey]+(realBuffCfg[buffKey] or 0)
				skillBuff[buffKey]=skillBuff[buffKey]+(realBuffCfg[buffKey] or 0)
			else
				for k,v in pairs(realBuffCfg) do
					if k=="dmg" then
						battleBuff["dmage"]=battleBuff["dmage"]+(v or 0)  --攻击显示成伤害
					else
						if battleBuff[k] then
							battleBuff[k]=battleBuff[k]+(v or 0)
						end
						if skillBuff[k] then
							skillBuff[k]=skillBuff[k]+(v or 0)
						end
					end
				end
			end
		end
		if buffKey==nil then
			for hid,productOrder in pairs(statueVo.hero) do
				local heroBuffLv=productOrder
				if heroBuffLv>statueCfg.openStatue then --当前将领buff等级不能超过开放的品阶
					heroBuffLv=statueCfg.openStatue
				end
				local cfg=statueCfg.arr1[sid][hid]
				if cfg and cfg[heroBuffLv] then
					local buffCfg=cfg[heroBuffLv]
					local dmgBuff,hpBuff=(buffCfg[1] or 0),(buffCfg[2] or 0)
					battleBuff.dmg=battleBuff.dmg+dmgBuff
					battleBuff.maxhp=battleBuff.maxhp+hpBuff
				end
			end
		end
	end

	return battleBuff,skillBuff
end

--获取战争塑像对应buff等级的buff值
function warStatueVoApi:getWarStatueBuff(sid,buffLv)
	local buffKey,buffValue
	local statueVo=self.statueList[sid]
	if statueVo then
		local scfg=statueCfg.skill[sid]
		if scfg then
			local lastBuffCfg=scfg[buffLv-1] or {}
			local buffCfg=scfg[buffLv] or {}
			for k,v in pairs(buffCfg) do
				if lastBuffCfg[k] and tonumber(v)>tonumber(lastBuffCfg[k]) then
					buffKey,buffValue=k,tonumber(v)
					do break end
				elseif lastBuffCfg[k]==nil and tonumber(v)>0 then
					buffKey,buffValue=k,tonumber(v)
					do break end
				end
			end
		end
	end
	if buffKey=="dmg" then --攻击转成伤害显示
		buffKey="dmage"
	end
	return buffKey,buffValue
end

--获取战争塑像对应将领的buff值
function warStatueVoApi:getWarStatueHeroBuff(sid,hid)
	return statueCfg.arr1[sid][hid]
end

--获取buff对应的buff描述详情
function warStatueVoApi:getBuffDesc(buffKey,buffValue,onlyValueStr)
	local str=""
	local buffId=buffKeyMatchCodeCfg[buffKey]
	if buffId and buffEffectCfg[buffId] then
		local cfg=buffEffectCfg[buffId]
		if buffKey=="first" or buffKey=="add" or buffKey == "antifirst" then --先手值和带兵量是数字不是百分比
			if onlyValueStr==true then
				str="+"..buffValue
			else
				str=getlocal(cfg.name).."  +"..buffValue
			end
		else
			if onlyValueStr==true then
				str="+"..(buffValue*100).."%"
			else
				str=getlocal(cfg.name).."  +"..(buffValue*100).."%"
			end
		end
	end
	return str
end

--获取将领激活状态 1：可激活，2：不可激活，3：未拥有
function warStatueVoApi:getHeroActiveState(sid,hid)
	local hero=heroVoApi:getHeroByHid(hid)	
	if hero==nil then
		return 3
	end
	local statueVo=self.statueList[sid]
	if statueVo then
		local lv=statueVo.hero[hid]
		if lv==nil or (hero.productOrder>lv and lv<statueCfg.openStatue) then
			return 1,lv
		end
		return 2,lv
	end
	return 2
end

--判断塑像是否解锁
function warStatueVoApi:isWarStatueUnlock(sid)
	local playerLv=playerVoApi:getPlayerLevel()
	local id=RemoveFirstChar(sid)
	local openLv=statueCfg.opneLevel+(id-1)*statueCfg.nextStatue
	if playerLv>=openLv then
		return true,openLv
	end
	return false,openLv
end

--判断塑像该版本存在与否
function warStatueVoApi:isWarStatueExist(sid)
	if statueCfg.room[sid] then
		return true
	end
	return false
end

function warStatueVoApi:showWarStatueDialog(layerNum)
	local flag,lv=self:isWarStatueOpened()
	if flag~=0 then
		local unlockStr=""
		if flag==1 then
			unlockStr=getlocal("backstage17000")
		elseif flag==2 then
            unlockStr=getlocal("equip_explore_unlock",{lv})
		end
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),unlockStr,28)
		do return end
	end
	local function realShow()
	    require "luascript/script/game/scene/gamedialog/warStatue/warStatueDialog"
	    local td=warStatueDialog:new()
	    local tbArr={}
	    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("warStatue_title"),true,layerNum)
	    sceneGame:addChild(dialog,layerNum)
	end
	warStatueVoApi:initWarStatue(realShow)
end

function warStatueVoApi:showWarStatueDetailDialog(sid,layerNum)
	local flag,lv=self:isWarStatueOpened()
	if flag~=0 then
		local unlockStr=""
		if flag==1 then
			unlockStr=getlocal("backstage17000")
		elseif flag==2 then
            unlockStr=getlocal("equip_explore_unlock",{lv})
		end
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),unlockStr,28)
		do return end
	end
    require "luascript/script/game/scene/gamedialog/warStatue/warStatueDetailDialog"
    warStatueDetailDialog:showWarStatueDetailDialog(sid,layerNum,nil)
end

--一键升级后的buff效果详情
function warStatueVoApi:showUpgradeBuffDialog(lastStatueVo,statueVo,layerNum,callback)
    require "luascript/script/game/scene/gamedialog/warStatue/warStatueSmallDialog"
    warStatueSmallDialog:showUpgradeBuffDialog(lastStatueVo,statueVo,layerNum,callback)
end

--查看将领buff信息
function warStatueVoApi:showHeroBuffDialog(sid,hid,layerNum,callback)
    require "luascript/script/game/scene/gamedialog/warStatue/warStatueSmallDialog"
    warStatueSmallDialog:showHeroBuffDialog(sid,hid,layerNum,callback)
end

function warStatueVoApi:saveSelectSid(sid)
	local dataKey="selectwarstatue@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,sid)
	CCUserDefault:sharedUserDefault():flush()
end

function warStatueVoApi:getSelectSid()
	local dataKey="selectwarstatue@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local sid=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
    if sid==0 then
    	sid=1
    end
	return tonumber(sid)
end

function warStatueVoApi:hasHeroCanActivate()
	for k,v in pairs(self.statueList) do
		local herolist=statueCfg.room[k][2]
		for kk,hid in pairs(herolist) do
			local flag=self:getHeroActiveState(k,hid)
			if flag==1 then
				return true
			end
		end
	end
	return false
end

function warStatueVoApi:clear()
	self.statueList={}
end