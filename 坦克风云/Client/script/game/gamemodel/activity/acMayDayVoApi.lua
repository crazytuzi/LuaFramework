acMayDayVoApi = {}

function acMayDayVoApi:getAcVo( )
	return activityVoApi:getActivityVo("xingyunzhuanpan")
end
function acMayDayVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end
function acMayDayVoApi:getSingleCost( idx) --idx 传倍数，单倍不写
	local vo = self:getAcVo()
	if vo and vo.singleCost then
		if idx==10 then
			return (idx-1)* vo.singleCost
		end
		return vo.singleCost
	end
	if vo and vo.singleCost then
		if idx ==1 then
			return vo.singleCost
		end
	end
	return nil
end
function acMayDayVoApi:getDoubleCost( idx) --idx 传倍数，单倍不写
	local vo = self:getAcVo()
	if vo and vo.doubleCost then
		if idx ==10 then
			return (idx-1)* vo.doubleCost
		end
		return vo.doubleCost
	end
	if vo and vo.doubleCost then
		if idx ==1 then
			return vo.doubleCost
		end
	end
	return nil
end
function acMayDayVoApi:getDaiBi()
	local vo = self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end
function acMayDayVoApi:setDaiBi(idx)
	 local vo = self:getAcVo()
	 if vo then
	 	vo.v =idx
	 end
end

function acMayDayVoApi:setMul(idx)
	self.mul=idx
end
function acMayDayVoApi:getMul()
	if self.mul then
		return self.mul
	end
	return 1
end

function acMayDayVoApi:setT(t)
	self:getAcVo().t=t
end

function acMayDayVoApi:isToday()


	local isToday=false--false 是免费，true是不免费
	local vo = self:getAcVo()
	-- print("vo.lastTimevo.lastTime=",vo.b)

	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end
-- function acMayDayVoApi:setIsFre(lastTime)
-- 	local vo = self:getAcVo()
-- 	if vo then
-- 		vo.lastTime =lastTime
-- 	end
-- end
function acMayDayVoApi:setOneTwo(idx )
	if idx then
		self.singleOrDouble =idx
	end
end
function acMayDayVoApi:getOneTwo()
	if self.singleOrDouble then
		return self.singleOrDouble
	end
	return 1
end
function acMayDayVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acMayDayVoApi:getCircleList( )
	local vo = self:getAcVo()
	if vo and vo.circleList then
		return vo.circleList
	end
	return {}
end
function acMayDayVoApi:formatStr(award)
	local str = ""
	if award and SizeOfTable(award)>0 then
        for k,v in pairs(award) do
            local nameStr=v.name
            if v.type=="c" then
                nameStr=getlocal(v.name,{v.num})
            end
            if k==SizeOfTable(award) then
                str = str .. nameStr .. " x" .. v.num
            else
                str = str .. nameStr .. " x" .. v.num .. ","
            end
        end
    end
    return str
end

function acMayDayVoApi:showTips(reward)

	local str = getlocal("daily_lotto_tip_10")
	for k,v in pairs(reward) do
		G_dayin(v)
		local vo=self:FormatItemBySelf(v)
		G_dayin(vo)
		local str2 = self:formatStr(vo)
		if SizeOfTable(reward)>1 then
			str=str..str2..","
		else
			str=str..str2
		end
	end
	if SizeOfTable(reward)>1 then
		str=string.sub(str,1,string.len(str)-1)
	end

	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
end

function acMayDayVoApi:FormatItemBySelf(data,includeZore,sortByIndex)
	local isDaibi = false
	for k,v in pairs(data) do
		if k=="mm_m1" then
			isDaibi=true
		end
	end
	if isDaibi and SizeOfTable(data)==1 then
		return {{name=getlocal("daibi"),num=data["mm_m1"]}}
	end

	if includeZore==nil then
		includeZore=true
	end
	local formatData={}	
	local num=0
	local name=""
	local pic=""
	local desc=""
    local id=0
	local index=0
    local eType=""
    local noUseIdx=0 --无用的index 只是占位
    local posId=0
    local equipId
	if data then
		for k,v in pairs(data) do
			if v and k ~="m"then
				for m,n in pairs(v) do
					if m~=nil and n~=nil then
						local key,type1,num=m,k,n
						if type(n)=="table" then
							for i,j in pairs(n) do
								if i=="index" then
									index=j
								elseif i =="icon" then
									posId=j
								else
									key=i
									num=j
								end
							end
						end
						if sortByIndex then
							name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
						else
							name,pic,desc,id,index,eType,equipId=getItem(key,type1)
						end
						if name and name~="" then
							if includeZore==false then
								if num>0 then
									--index=index+1
									table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,posId=posId})
								end
							else
								--index=index+1
								table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,posId=posId})
							end
						end
					end
				end
			else
				if k=="m" and v then
					for m,n in pairs(v) do
						local item={type="mm"}
						for i,j in pairs(n) do
							if i=="index" then
								item.index=j
							elseif i =="icon" then
								item.posId=j
							else
								item.key=i
								item.num=j
								--local id=(tonumber(i) or tonumber(RemoveFirstChar(i)))
								item.name=getlocal("daibi")
								item.desc="daibiDesc"
								item.pic="acMayDayBgGold.png"
							end
						end
						if item and SizeOfTable(item)>0 then
							table.insert(formatData,item)
						end
					end
				end
			end
		end
	end
	if formatData and SizeOfTable(formatData)>0 then
		local function sortAsc(a, b)
			if sortByIndex then
				if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
					return a.index < b.index
				end
			else
				if a.type==b.type then
					if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
						return a.index < b.index
					end
					--else
					--return a.type<b.type
		        end
			end
	    end
		table.sort(formatData,sortAsc)
	end

	-- for k,v in pairs(data) do

	-- end
	return formatData
end

function acMayDayVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return nil
end

function acMayDayVoApi:getShopCfg()
	local acVo = self:getAcVo()
	G_dayin(acVo.shopItem)

	if acVo ~= nil and acVo.shopItem then
		return acVo.shopItem
	end


	return {}
end
function acMayDayVoApi:getIsChatByID(id)
	for k,v in pairs(self:getShopCfg()) do
		if id==v.id and v.report==1 then
			return true
		end
	end

	return false

end
function acMayDayVoApi:getHasBuyNumByID(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.hasBuy and type(acVo.hasBuy)=="table" then
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				return tonumber(v)
			end 
		end
	end
	return tonumber(0)
end

function acMayDayVoApi:updateHasBuyNumByID(id,num)
	local acVo = self:getAcVo()
	if num ==nil then
		num = 1 
	end
	if acVo ~= nil then
		if acVo.hasBuy == nil then
			acVo.hasBuy = {}
		end
		local isBuy = false
		for k,v in pairs(acVo.hasBuy) do
			if k and v and k == id then
				acVo.hasBuy[id]=num+v
				isBuy = true
			end 
		end
		if isBuy == false then
			acVo.hasBuy[id]=num
		end

	end
end

function acMayDayVoApi:getSelfTokens()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.token then
		return acVo.token
	end
	return {}
end

function acMayDayVoApi:getTokenNumByID(mtype)
	local Tokens = self:getSelfTokens()
	if Tokens ~= nil and type(Tokens)=="table" then
		for k,v in pairs(Tokens) do
			if k == mtype and v then
				return tonumber(v)
			end
		end
	end
	return 0
end

function acMayDayVoApi:updateSelfTokens(mtype,num)
	local acVo = self:getAcVo()
	if acVo ~= nil  then
		if acVo.token==nil then
			acVo.token = {}
		end
		local add = false
		for k,v in pairs(acVo.token) do
			if k == mtype and v then
				acVo.token[mtype] = tonumber(v + num)
				add = true
			end
		end
		if add == false then
			acVo.token[mtype] = tonumber(num)
		end
	end
end

