acSecretshopVoApi={
	name=nil,
}

function acSecretshopVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acSecretshopVoApi:setActiveName(name)
	self.name=name
end

function acSecretshopVoApi:getActiveName()
	return self.name or "secretshop"
end
function acSecretshopVoApi:clearAll()
	self.name=nil
end

function acSecretshopVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	return G_formatActiveDate(vo.et - base.serverTime)
end

function acSecretshopVoApi:getShopList()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.shoplist
	end
	return {}
end

function acSecretshopVoApi:getRefreshNumById(id)
	local vo=self:getAcVo()
	if vo and vo.rd then
		local infoTb = vo.rd[id] or {}
		return infoTb.r or 0
	end
	return 0
end

function acSecretshopVoApi:getRefreshListById(id)
	local vo=self:getAcVo()
	if vo and vo.rd then
		local infoTb = vo.rd[id] or {}
		return infoTb.list
	end
	return nil
end

function acSecretshopVoApi:getRefreshCost()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.freshcost or 0
	end
	return 0
end

function acSecretshopVoApi:getRefreshTimes()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.freetimes or 0
	end
	return 0
end

function acSecretshopVoApi:getBuyNum(id)
	local vo=self:getAcVo()
	if vo and vo.rd then
		local infoTb = vo.rd[id] or {}
		return infoTb.b or 0
	end
	return 0
end

function acSecretshopVoApi:getChangeNum(id)
	local vo=self:getAcVo()
	if vo and vo.changeList then
		local num = vo.changeList[id] or 0
		return num
	end
	return 0
end

-- 跨天需要修改
function acSecretshopVoApi:clearData(flag)
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	local rd=vo.rd or {}
	for k,v in pairs(rd) do
		if v.b then
			v.b=0
		end
		if v.r then
			v.r=0
		end
	end
	-- local changeList=vo.changeList or {}
	-- for k,v in pairs(changeList) do
	-- 	changeList[k]=0
	-- end
	if flag then
		eventDispatcher:dispatchEvent("active.secretshop",{})
	end
end


function acSecretshopVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acSecretshopVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acSecretshopVoApi:showRefreshSmalldialog(layerNum,istouch,isuseami,callBack,titleStr,contentStr,costNum,parent)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acSecretshopSmallDialog"
	acSecretshopSmallDialog:showRefresh(layerNum,istouch,isuseami,callBack,titleStr,contentStr,costNum,parent)
end

function acSecretshopVoApi:showChangeDialog(layerNum,istouch,isuseami,callBack,titleStr)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acSecretshopChangeSmallDialog"
	local tabInfo1,tabInfo2,flag=acSecretshopVoApi:getChangeKey()
	return acSecretshopChangeSmallDialog:showChange(layerNum,istouch,isuseami,callBack,titleStr,tabInfo1,tabInfo2,flag)
end

function acSecretshopVoApi:getChangeKey()
	local vo=self:getAcVo()
	local tab1={}
	local tab2={}
	local flag=1
	if vo and vo.activeCfg then
		local outputlist=vo.activeCfg.outputlist
		for k,v in pairs(outputlist) do
			local changeNum=self:getChangeNum(k)
			if v.maxtimes==0 then
				table.insert(tab2,{key=k,value=v,changeNum=changeNum})
			else
				local index=v.index
				if changeNum>=v.maxtimes then
					index=v.index+10000
				end
				table.insert(tab1,{key=k,value=v,changeNum=changeNum,index=index})
			end
		end
	end
	local function sortFunc(a,b)
		return a.value.index<b.value.index
	end
	table.sort(tab2,sortFunc)

	local function sortFunc2(a,b)
		return a.index<b.index
	end
	table.sort(tab1,sortFunc2)


	return tab1,tab2,flag
end

function acSecretshopVoApi:getInputList(targetReward)
	local vo=self:getAcVo()
	local inputTb={}
	if vo and vo.activeCfg then
		local inputlist=vo.activeCfg.inputlist
		for k,v in pairs(inputlist) do
			local r=v.r
			local rewardItem=FormatItem(r)[1]

			if targetReward and targetReward.type==rewardItem.type and targetReward.key==rewardItem.key then
			else
				local propId=(tonumber(rewardItem.key) or tonumber(RemoveFirstChar(rewardItem.key)))
				local haveNum=bagVoApi:getItemNumId(propId) or 0

				sort=v.sort
				if haveNum==0 then
					sort=v.sort+10000
				end
				local key=k
				local point=v.point

				table.insert(inputTb,{key=key,point=point,sort=sort,rewardItem=rewardItem,haveNum=haveNum})
			end
		end
	end
	local function sortFunc(a,b)
		return a.sort<b.sort
	end
	table.sort(inputTb,sortFunc)
	return inputTb
end

function acSecretshopVoApi:socketGift(action,sid,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:acSecretshopGift(callBack,action,sid)
end

function acSecretshopVoApi:socketchange(sid,resp,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:acSecretshopChange(callBack,sid,resp)
end



function acSecretshopVoApi:canReward(activeName)
	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
    
end

function acSecretshopVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end

function acSecretshopVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end
