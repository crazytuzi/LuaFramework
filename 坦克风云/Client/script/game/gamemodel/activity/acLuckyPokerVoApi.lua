acLuckyPokerVoApi = {
	name="",
}

function acLuckyPokerVoApi:setActiveName(name)
	self.name=name
end

function acLuckyPokerVoApi:getActiveName()
	return self.name
end

function acLuckyPokerVoApi:acIsActive(activeName)
	local vo = self:getAcVo(activeName)
	if vo and base.serverTime>vo.st and  base.serverTime<vo.et then
		return true
	end
	return false
end

function acLuckyPokerVoApi:IsAcInAllAc( )
	local allAc =activityVoApi:getAllActivity()--[tag + 1]
	for k,v in pairs(allAc) do
		local acType = v.type
		local arr=Split(acType,"_")
		if arr[1] =="luckcard" then
			local isOpen = self:acIsActive(acType)
			if self.name ==nil or self.name =="" then
				self.name = acType
			end
			return isOpen
		end
	end
	return false
end


function acLuckyPokerVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acLuckyPokerVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acLuckyPokerVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
end
function acLuckyPokerVoApi:canReward(activeName)
	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
end
function acLuckyPokerVoApi:getCostWithOneAndTenTimes( )
	local vo = self:getAcVo()
	if vo and vo.cost1 and vo.cost2 then
		return vo.cost1,vo.cost2
	end
	return nil
end
function acLuckyPokerVoApi:setFreeTime(freeTime )
	local vo  = self:getAcVo()
	if vo and freeTime then
		vo.freeTime =freeTime
	else
		vo.freeTime =nil
	end
end
function acLuckyPokerVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acLuckyPokerVoApi:updateLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end
function acLuckyPokerVoApi:getPoolRewardTb( )
	local vo = self:getAcVo()
	if vo and vo.clientReward then
		return vo.clientReward,#vo.clientReward
	end
	return nil
end


function acLuckyPokerVoApi:formatPoolRewardTb(rawTb)

	local formatTb = {}
	-- print(" in formatPoolRewardTb=====------========---------")
	for k,v in pairs(rawTb) do
		-- print("k----->",k)
		local oneTb = FormatItem(v)
		if #oneTb <4 then
			for i=1,#oneTb do
				table.insert(oneTb,oneTb[i])
			end
		end
				-- print("SizeOfTable(oneTb)------->",SizeOfTable(oneTb))

		table.insert(formatTb,oneTb)
	end
	return formatTb
end

--"reward":{"p":[{"p411":1,"index":1}]}}
function acLuckyPokerVoApi:getBigRewardTb(activeName)
	local vo = self:getAcVo(activeName)
	if vo and vo.luckyNBReward then
		-- print("vo.luckyNBReward.name----->",FormatItem({vo.luckyNBReward}).name,FormatItem({vo.luckyNBReward})[1])
		return FormatItem(vo.luckyNBReward)[1]
	end
	print("error~~~~~~~~")
	return nil
end

function acLuckyPokerVoApi:setAwardAllTbRecord( awardAllTb )
	local vo = self:getAcVo()
	if vo and awardAllTb then
		vo.awardAllTb =awardAllTb
	end
end
function acLuckyPokerVoApi:getAwardAllTbRecord( )
	local vo = self:getAcVo()
	if vo and vo.awardAllTb then
		return vo.awardAllTb
	end
end

function acLuckyPokerVoApi:setIsSeeRecord(isSee)
	local vo = self:getAcVo()
	if vo and vo.seeRecord~=nil then
		vo.seeRecord = isSee
	end
end
function acLuckyPokerVoApi:getIsSeeRecord( )
	local vo = self:getAcVo()
	if vo and vo.seeRecord ~=nil then
		return vo.seeRecord
	end
	return true
end

function acLuckyPokerVoApi:returnTankData()
	require "luascript/script/game/scene/tank/tankShowData"
	local vo = self:getAcVo()
	local nbAward = self:getBigRewardTb()
	if tankShowData and tankShowData[nbAward.key] then
		return tankShowData[nbAward.key]
	end
	-- return vo.tankActionData[nbAward.key]	
end
function acLuckyPokerVoApi:cleanAllAwardTb( )
	local vo = self:getAcVo()
	if vo and vo.curAwardTb then
		vo.curAwardTb ={}
	end
end
function acLuckyPokerVoApi:setAllAwardTb(curAwardTb)
	local vo = self:getAcVo()
	local bigAwardTb = self:getBigRewardTb()
	if vo and vo.curAwardTb then
		vo.curAwardTbWithAc ={}
		vo.curAwardTb ={}
		if curAwardTb ~= nil then
			-- local formatAwardTb = {}
			for k,v in pairs(curAwardTb) do
				for m,n in pairs(v) do
					local finishFormatTb = FormatItem(n)
					for kk,vv in pairs(finishFormatTb) do
						local curSingleTb = G_clone(vv)
						-- print("curSingleTb.name------->",curSingleTb.name,curSingleTb.num)
						G_addPlayerAward(vv.type, vv.key, vv.id,tonumber(vv.num))
						table.insert(vo.curAwardTbWithAc,curSingleTb)
					end
					
				end
			end
			local formatOverTb = {}
			local sortNumTB = {}
			local isNone = true
			for k,v in pairs(vo.curAwardTbWithAc) do

				for m,n in pairs(formatOverTb) do
					if n.id ==v.id then
						n.num =v.num+n.num
						isNone =false
						do break end
					end
				end
				if isNone ==true then
					local newTb = G_clone(v)
					table.insert(formatOverTb,newTb)
				else
					isNone =true
				end
			end

			local function sortAsc(a, b)
				if a.type =="o" and b.type =="o" then
					return a.id > b.id
				elseif a.type ~="o" and b.type =="o" then
					return false
				end
		    end
			table.sort(formatOverTb,sortAsc)

			vo.curAwardTb =G_clone(formatOverTb)
		else
			vo.curAwardTb = {}
		end
	end
end

function acLuckyPokerVoApi:setIsTen( curBei )
	local vo = self:getAcVo()
	if vo and vo.isTen then
		vo.isTen =curBei
	end
end

function acLuckyPokerVoApi:getIsTen( )
	local vo = self:getAcVo()
	if vo and vo.isTen == 10 then
		return vo.isTen
	end
	return 1
end
function acLuckyPokerVoApi:showTip( awardTb)
	local bigAwardTb = self:getBigRewardTb()
	local str = ""
	if awardTb and SizeOfTable(awardTb)>0 then
	    str = getlocal("daily_lotto_tip_10")
	    for k,v in pairs(awardTb) do
	        local nameStr=v.name
	        local beiShu = curBei
	        if bigAwardTb.name ==v.name and beiShu == 10 then
	        	beiShu =1
	        end
	        if v.type=="c" then
	            nameStr=getlocal(v.name,{v.num})
	        end
	        if k==SizeOfTable(awardTb) then
	            str = str .. nameStr .. " x" .. v.num
	        else
	            str = str .. nameStr .. " x" .. v.num .. ","
	        end
	    end
	end

	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
end
function acLuckyPokerVoApi:getAllCurAwardTb( )
	local vo = self:getAcVo()
	local ishasBig = false
	local nbAward = self:getBigRewardTb()
	local removeTb = {}
	local isTen =true
	local isNum = 1
	if vo and vo.curAwardTb then
		local unSortTb = G_clone(vo.curAwardTb)
		for k,v in pairs(vo.curAwardTb) do
			if nbAward.id ==v.id then
				ishasBig =true
				table.insert(removeTb,k)
			elseif v.num >=10 then
				isNum =10
			end
		end
		for m,n in pairs(removeTb) do
			table.remove(vo.curAwardTb,n)
		end
		return vo.curAwardTb,ishasBig,unSortTb,isNum
	end
	print("error~~~~getAllCurAwardTb~~~~")
	return nil

end

function acLuckyPokerVoApi:setTimeRecord(curCellTimeRecord)
	local vo = self:getAcVo()
	if vo and curCellTimeRecord then
		vo.curCellTimeRecord =curCellTimeRecord
	end
end
function acLuckyPokerVoApi:getTimeRecord()
	local vo = self:getAcVo()
	if vo and vo.curCellTimeRecord then
		return vo.curCellTimeRecord
	end
	return nil
end

function acLuckyPokerVoApi:setCurCellAwardRecord(curAwardTb)
	local vo = self:getAcVo()
	local bigAwardTb = self:getBigRewardTb()
	if vo and vo.curCellAwardTb then
		if curAwardTb ~= nil then
			local formatAwardTb = {}
			for k,v in pairs(curAwardTb) do
				if k ==1 then
					local timeStr = G_getDateStr(v,false,false)
					self:setTimeRecord(timeStr)
				elseif k==2 then
					for m,n in pairs(v) do
						for i,j in pairs(n) do
							local finishFormatTb = FormatItem(j)
							for kk,vv in pairs(finishFormatTb) do
								local curSingleTb = G_clone(vv)
								-- print("curSingleTb.name------->",curSingleTb.name,curSingleTb.num)
								table.insert(formatAwardTb,curSingleTb)
							end
						end
					end
				end
			end
			local formatOverTb = {}
			local sortNumTB = {}
			local isNone = true
			for k,v in pairs(formatAwardTb) do

				for m,n in pairs(formatOverTb) do
					if n.id ==v.id then
						n.num =v.num+n.num
						isNone =false
						do break end
					end
				end
				if isNone ==true then
					table.insert(formatOverTb,v)
				else
					isNone =true
				end
			end

			local function sortAsc(a, b)
				if a.type =="o" and b.type =="o" then
					return a.id > b.id
				elseif a.type ~="o" and b.type =="o" then
					return false
				end
		    end
			table.sort(formatOverTb,sortAsc)

			vo.curCellAwardTb =G_clone(formatOverTb)
		else
			vo.curCellAwardTb = {}
		end
	end
end
function acLuckyPokerVoApi:getCurCellAwardRecord( )
	local vo = self:getAcVo()
	local nbAward = self:getBigRewardTb()
	local removeTb = {}
	if vo and vo.curCellAwardTb then
		local function sortAsc(a, b)
			if a.type =="o" and a.id == nbAward.id then
				return true
			end
	    end
		table.sort(vo.curCellAwardTb,sortAsc)
		return vo.curCellAwardTb,nbAward
	end
	print("error~~~~getCurCellAwardRecord~~~~")
	return nil

end

function acLuckyPokerVoApi:getAwardWithAction()--只给动画使用
	local nbAward = self:getBigRewardTb()
	local vo = self:getAcVo()
	local returnTb = {}
	if vo and vo.curAwardTbWithAc then
		for k,v in pairs(vo.curAwardTbWithAc) do
			-- print("v.name---v.id----v.num----->",v.name,v.id,v.num)
			if v.name ==nbAward.name and v.id ==nbAward.id then
			else
				table.insert(returnTb,v)
			end
		end
		return returnTb
	end
	return nil
end

function acLuckyPokerVoApi:getSaleValue( )
	local vo = self:getAcVo()
	if vo and vo.saleValue then
		return vo.saleValue
	end
	return 0
end

function acLuckyPokerVoApi:getNextRequireUseInAlienFactory(activeName)
	-- print("in getNextRequireUseInAlienFactory ~~~")
	local vo = self:getAcVo(activeName)
	if vo and vo.nextRequire then
		local curTb = {}
		for i=2,SizeOfTable(vo.nextRequire) do
			local tankId = vo.nextRequire[i]
			local formatedTankId = string.sub(tankId,8,string.len(tankId))
			table.insert(curTb,formatedTankId)
		end
		return curTb
	else
		print("error : vo.nextRequire is nil")
	end
	return {}
end

function acLuckyPokerVoApi:getNextRequire( )
	local vo = self:getAcVo()
	if vo and vo.nextRequire then
		local tankId = vo.nextRequire[1]
		local formatedTankId = tonumber(string.sub(tankId,9,string.len(tankId)))
		-- print("tankId，formatedTankId------>",tankId,formatedTankId)
		local tankName = tankCfg[formatedTankId].name
		local tankSp = tankCfg[formatedTankId].icon
		if tankName and tankSp then
			return getlocal(tankName),tankSp
		else
			print ("error~~~~~~in getNextRequire 222222")
			return "","icon_build.png"
		end
	end
	print ("error~~~~~~in getNextRequire ")
	return "","icon_build.png"
end
