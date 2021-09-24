acOlympicVoApi = {
	name="",
}

function acOlympicVoApi:setActiveName(name)
	self.name=name
end

function acOlympicVoApi:getActiveName()
	return self.name
end

function acOlympicVoApi:acIsActive(activeName)
	local vo = self:getAcVo(activeName)
	if vo and base.serverTime>vo.st and  base.serverTime<vo.et then
		return true
	end
	return false
end

function acOlympicVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acOlympicVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acOlympicVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
end
function acOlympicVoApi:canReward(activeName)
	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
end

function acOlympicVoApi:setFreeTime(freeTime )
	local vo  = self:getAcVo()
	if vo and freeTime then
		vo.freeTime =freeTime
	else
		vo.freeTime =nil
	end
end

function acOlympicVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acOlympicVoApi:updateLastTime(newTime)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = newTime
	end
end

function acOlympicVoApi:getCostWithOneAndTenTimes( )
	local vo = self:getAcVo()
	if vo and vo.cost1 and vo.cost2 then
		return vo.cost1,vo.cost2
	end
	return nil
end

function acOlympicVoApi:getAllColors( ) --六种颜色
	local vo = self:getAcVo()
	if vo and vo.allColors then
		return vo.allColors
	end
	return {}
end


function acOlympicVoApi:getAwardAllTb( )
	local vo = self:getAcVo()
	if vo and vo.awardAllTb then
		local formatAwardTb = {}
		for k,v in pairs(vo.awardAllTb) do
			local awardSTb = FormatItem(v)
			table.insert(formatAwardTb,awardSTb)
		end
		return formatAwardTb
	end
	return {}
end

function acOlympicVoApi:getScoreTb( )
	local vo = self:getAcVo()
	if vo and vo.scoreTb then
		return vo.scoreTb
	end
	return {}
end

function acOlympicVoApi:showTip( awardTb)
	-- local bigAwardTb = self:getBigRewardTb()
	local str = ""
	if awardTb and SizeOfTable(awardTb)>0 then
	    str = getlocal("daily_lotto_tip_10")
	    for k,v in pairs(awardTb) do
	        local nameStr=v.name
	        local beiShu = curBei
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

function acOlympicVoApi:setIsSeeRecord(isSee)
	local vo = self:getAcVo()
	if vo and vo.seeRecord~=nil then
		vo.seeRecord = isSee
	end
end
function acOlympicVoApi:getIsSeeRecord( )
	local vo = self:getAcVo()
	if vo and vo.seeRecord ~=nil then
		return vo.seeRecord
	end
	return true
end

function acOlympicVoApi:setAwardAllTbRecord( awardAllTbRecord )
	local vo = self:getAcVo()
	if vo and awardAllTbRecord then
		vo.awardAllTbRecord =awardAllTbRecord
	end
end
function acOlympicVoApi:getAwardAllTbRecord( )
	local vo = self:getAcVo()
	if vo and vo.awardAllTbRecord then
		return vo.awardAllTbRecord
	end
end

function acOlympicVoApi:setTimeRecord(curCellTimeRecord)
	local vo = self:getAcVo()
	if vo and curCellTimeRecord then
		vo.curCellTimeRecord =curCellTimeRecord
	end
end
function acOlympicVoApi:getTimeRecord()
	local vo = self:getAcVo()
	if vo and vo.curCellTimeRecord then
		return vo.curCellTimeRecord
	end
	return nil
end
function acOlympicVoApi:setCurCellAwardRecord(curAwardTb)
	local vo = self:getAcVo()
	if vo and vo.curCellAwardTb then
		self:setIsTen()
		if curAwardTb ~= nil then
			local formatAwardTb = {}
			for k,v in pairs(curAwardTb) do
				if k ==2 then
					local timeStr = G_getDateStr(v,false,false)
					self:setTimeRecord(timeStr)
				elseif k==1 then
					for m,n in pairs(v) do
						-- for i,j in pairs(n) do
							local finishFormatTb = FormatItem(n)
							for kk,vv in pairs(finishFormatTb) do
								local curSingleTb = G_clone(vv)
								-- print("curSingleTb.name------->",curSingleTb.name,curSingleTb.num)
								table.insert(formatAwardTb,curSingleTb)
							end
						-- end
					end
				elseif k ==3 then
					self:setIsTen( true )
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

			vo.curCellAwardTb =G_clone(formatOverTb)
		else
			vo.curCellAwardTb = {}
		end
	end
end
function acOlympicVoApi:getCurCellAwardRecord( )
	local vo = self:getAcVo()
	local removeTb = {}
	if vo and vo.curCellAwardTb then
		return vo.curCellAwardTb
	end
	print("error~~~~getCurCellAwardRecord~~~~")
	return nil
end

function acOlympicVoApi:getPointTb( )---金银铜的各个分数
	local vo = self:getAcVo()
	if vo and vo.pointTb then
		return vo.pointTb
	end
	return {}
end

function acOlympicVoApi:setCurAllScores( report )
	local pointTb = self:getPointTb()
	local vo = self:getAcVo()
	if vo and report then
		vo.curAllScores = 0
		vo.curEachAwardScoresTb = {0,0,0}
		for k,v in pairs(report) do
			if v == k then
				vo.curAllScores = vo.curAllScores + pointTb[1]
				vo.curGetSocresTb[k] = pointTb[1]
				vo.curEachAwardScoresTb[1] = vo.curEachAwardScoresTb[1] + 1
			elseif v >5 then
				vo.curAllScores = vo.curAllScores + pointTb[3]
				vo.curGetSocresTb[k] = pointTb[3]
				vo.curEachAwardScoresTb[3] = vo.curEachAwardScoresTb[3] + 1
			else
				vo.curAllScores = vo.curAllScores + pointTb[2]
				vo.curGetSocresTb[k] = pointTb[2]
				vo.curEachAwardScoresTb[2] = vo.curEachAwardScoresTb[2] + 1
			end
		end
	end
end

function acOlympicVoApi:getCurEachAwardScoresTb( )
	local vo = self:getAcVo()
	if vo and vo.curEachAwardScoresTb then
		return vo.curEachAwardScoresTb,vo.curAllScores,vo.scoreLimit
	end
	return {0,0,0},vo.curAllScores,vo.scoreLimit
end
function acOlympicVoApi:getCurAllScores( )
	local vo = self:getAcVo()
	if vo and vo.curAllScores then
		return vo.curAllScores
	end
	return 0
end

function acOlympicVoApi:setCurAwardTb(curAwardTb)
	local vo = self:getAcVo()
	if vo and vo.curAwardTb then
		vo.curAwardTbWithAc ={}
		vo.curAwardTb ={}
		if curAwardTb ~= nil then
			for k,v in pairs(curAwardTb) do
					local finishFormatTb = FormatItem(v)
					for kk,vv in pairs(finishFormatTb) do
						local curSingleTb = G_clone(vv)
						G_addPlayerAward(vv.type, vv.key, vv.id,tonumber(vv.num))
						table.insert(vo.curAwardTbWithAc,curSingleTb)
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
			vo.curAwardTb =G_clone(formatOverTb)
		else
			vo.curAwardTb = {}
		end
	end
end
function acOlympicVoApi:getAllCurAwardTb( )
	local vo = self:getAcVo()
	local ishasBig = false
	local isTen =true
	local isNum = 1
	if vo and vo.curAwardTb then
		local unSortTb = G_clone(vo.curAwardTb)
		for k,v in pairs(vo.curAwardTb) do
			if v.num >=10 then
				isNum =10
			end
		end
		return vo.curAwardTb,ishasBig,unSortTb,isNum
	end
	print("error~~~~getAllCurAwardTb~~~~")
	return nil

end

function acOlympicVoApi:setAgainBuy(tag )
	local vo = self:getAcVo()
	if vo and tag then
		vo.isagainBuyNum = tag
	end
end
function acOlympicVoApi:getAgainBug( )
	local vo = self:getAcVo()
	if vo and vo.isagainBuyNum then
		return vo.isagainBuyNum
	end
	return vo.isagainBuyNum
end

function acOlympicVoApi:setBuyTagAndGems(acIdx,needSubCost )
	local vo = self:getAcVo()
	if vo and acIdx then
		if acIdx == 1 then
			acIdx =acIdx +1
		end
		vo.acIdx = acIdx
	end
	if vo and needSubCost then
		vo.needSubCost =needSubCost
	end
end
function acOlympicVoApi:getBuyTagAndGems( )
	local vo = self:getAcVo()
	if vo and vo.acIdx and vo.needSubCost then
		return vo.acIdx, vo.needSubCost
	end
	return nil,nil
end

function acOlympicVoApi:getScoreLimit( )
	local vo = self:getAcVo()
	if vo and vo.scoreLimit then
		return vo.scoreLimit
	end
	return 0
end
--acOlympicVoApi:getCurAllScores( )
function acOlympicVoApi:IsFilck( )
	local curSocres = self:getCurAllScores()
	local vo = self:getAcVo()
	if vo and vo.scoreLimit then
		if curSocres >=vo.scoreLimit then
			return true
		else 
			return false
		end
	end
	return false
end

function acOlympicVoApi:setIsTen(isTen )
	local vo = self:getAcVo()
	if vo and isTen then
		vo.isTen = isTen
	else
		vo.isTen =false
	end
end
function acOlympicVoApi:getIsTen( )
	local vo = self:getAcVo()
	if vo and vo.isTen then
		return vo.isTen
	end
	return vo.isTen
end

--curGetSocresTb
function acOlympicVoApi:setCurGetSocresTb(curSocresTb )
	local vo = self:getAcVo()
	if vo and curSocresTb then
		vo.curGetSocresTb = curSocresTb
	end
end
function acOlympicVoApi:getCurGetSocresTb( )
	local vo = self:getAcVo()
	if vo and vo.curGetSocresTb then
		return vo.curGetSocresTb
	end
	return vo.curGetSocresTb
end