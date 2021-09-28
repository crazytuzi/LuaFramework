-- FileName: GuildWarUtil.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarUtil 跨服军团战接口模块

module("GuildWarUtil", package.seeall)


--[[
	@des: 将时间配置转换成对应的时间戳
	@parm: 	p_configTime 配置时间组
			p_startTime  活动开始时间时间戳
	@ret:
--]]
function convertConfigTime( p_configTime, p_startTime)
	print("p_configTime", p_configTime)
	local timeConfig = {}
	local stages = string.split(p_configTime, ",")
	for i=1,#stages,2 do
		local stagetimes1 = string.split(stages[i], "|")
		local stagetimes2 = string.split(stages[i+1], "|")

		timeConfig[math.floor(i/2) + 1] = {
			stagetimes1[1]*86400 + stagetimes1[2] + p_startTime, 
			stagetimes2[1]*86400 + stagetimes2[2] + p_startTime,
		}
		print("i", i)
	end
	printTable("timeConfig", timeConfig)
	return timeConfig
end

--[[
	@des:把时间秒数转换成00 : 00 : 00这种格式
	@parm:p_timeInterval 要转换的秒数
	@ret:string 00 : 00 : 00 格式字符串
--]]
function getTimeDes( p_timeInterval )
	local hour = math.floor(p_timeInterval/3600)
	local min  = math.floor((p_timeInterval - hour*3600)/60)
	local sec  = p_timeInterval - hour*3600 - 60*min
	local ret1 = string.format("%02d",hour) .. "  :  " .. string.format("%02d",min) .. "  :  ".. string.format("%02d",sec)
	local ret2 = string.format("%02d",hour) .. ":" .. string.format("%02d",min) .. ":".. string.format("%02d",sec)
	return ret1
end

--[[
	@des:得到当前阶段的标题和副标题
	@ret{
		round 	=> 正标题,
		status 	=> 副标题,
		time    => 倒计时时间 单位s
	}
--]]
function getStageTitles( ... )
	local cuntdown     = GetLocalizeStringBy("key_10179")
	local statusDes    = GetLocalizeStringBy("key_10180")
	local going        = GetLocalizeStringBy("key_10181")
	local endCuntdown  = GetLocalizeStringBy("key_10182")
	local curRound     = GuildWarMainData.getRound()
	local curStatus    = GuildWarMainData.getStatus()
	local curSubRound  = GuildWarMainData.getSubRound()
	local curSubStatus = GuildWarMainData.getSubStatus()
	local retTable     = {}
	local curTime 	   = TimeUtil.getSvrTimeByOffset(-1)
	if curRound == GuildWarDef.INVALID or curRound == GuildWarDef.SIGNUP then

		--报名和报名前阶段
		--报名时间倒计时
		--海选赛倒计时
		retTable.round  = nil
		retTable.status = GuildWarDef.StageDesInfo[curRound] .. cuntdown
		retTable.time   = GuildWarMainData.getStartTime(curRound + 1, nil) - curTime
	elseif curRound == GuildWarDef.AUDITION then
		--海选赛阶段
		if curStatus >= GuildWarDef.END then
			--当前大阶段结束
			--显示显示下场晋级赛开始倒计时
			retTable.round  = GuildWarDef.StageDesInfo[curRound + 1]
			retTable.status = string.format(statusDes, 1) .. cuntdown
			retTable.time   = GuildWarMainData.getStartTime(curRound + 1, 1) - curTime
		else
			--海选赛进行中
			retTable.round  = nil
			retTable.status = GuildWarDef.StageDesInfo[curRound] .. going
			retTable.time   = -1
		end
	elseif curRound == GuildWarDef.ADVANCED_2 and curStatus >= GuildWarDef.DONE then
			--比赛结束
			retTable.round  = GetLocalizeStringBy("key_10183")
			retTable.status = nil
			retTable.time   = -1
	elseif curRound >= GuildWarDef.ADVANCED_16 and curRound <= GuildWarDef.ADVANCED_2 then
		if curStatus >= GuildWarDef.DONE then
			retTable.round  = GuildWarDef.StageDesInfo[curRound + 1]
			retTable.status = string.format(statusDes, 1) .. cuntdown
			retTable.time   = GuildWarMainData.getStartTime(curRound + 1, 1) - curTime
		elseif curStatus < GuildWarDef.DONE then
			if curSubStatus == GuildWarDef.FIGHTEND then
				if curSubRound + 1 > GuildWarDef.GROUP_NUM then
					if curRound + 1 > GuildWarDef.ADVANCED_2 then
						--比赛结束倒计时
						retTable.round  = GuildWarDef.StageDesInfo[curRound]
						retTable.status = endCuntdown
						retTable.time   = GuildWarMainData.getEndTime(GuildWarDef.ADVANCED_2) - curTime
					else
						retTable.round  = GuildWarDef.StageDesInfo[curRound + 1]
						retTable.status = string.format(statusDes, 1) .. cuntdown
						retTable.time   = GuildWarMainData.getStartTime(curRound + 1, 1) - curTime
					end
				else
					retTable.round  = GuildWarDef.StageDesInfo[curRound]
					retTable.status = string.format(statusDes, curSubRound + 1) .. cuntdown
					retTable.time   = GuildWarMainData.getStartTime(curRound, 1) + GuildWarMainData.getGroupTime() * curSubRound - curTime
				end
			elseif curSubStatus == GuildWarDef.FIGHTING then
				retTable.round  = GuildWarDef.StageDesInfo[curRound]
				retTable.status = string.format(statusDes, curSubRound) .. going
				retTable.time   = -1
			end
		end
	end
    -- print_t(retTable)
	return retTable
end

function getStageTitles2( ... )
	local curRound     = GuildWarMainData.getRound()
	local curStatus    = GuildWarMainData.getStatus()
	local curSubRound  = GuildWarMainData.getSubRound()
	local curSubStatus = GuildWarMainData.getSubStatus()
	--print(curRound, curStatus, curSubRound, curSubStatus)
	local roundDeses = {
		[GuildWarDef.INVALID]     = GetLocalizeStringBy("key_8526"),
		[GuildWarDef.SIGNUP]      = GetLocalizeStringBy("key_8527"),
		[GuildWarDef.AUDITION]    = GetLocalizeStringBy("key_8528"),
		[GuildWarDef.ADVANCED_16] = GetLocalizeStringBy("key_8529"),
		[GuildWarDef.ADVANCED_8]  = GetLocalizeStringBy("key_8530"),
		[GuildWarDef.ADVANCED_4]  = GetLocalizeStringBy("key_8531"),
		[GuildWarDef.ADVANCED_2]  = GetLocalizeStringBy("key_8532"),
	}
	local des = {}
	local curTime 	   = TimeUtil.getSvrTimeByOffset()
	if curRound == GuildWarDef.INVALID then
		local remainTime = GuildWarMainData.getStartTime(GuildWarDef.SIGNUP) - curTime
		if remainTime > 0 then
			des.timeDes = GetLocalizeStringBy("key_8533")
			des.remainTime = remainTime
		else
			des.timeDes = GetLocalizeStringBy("key_8534")
		end
	elseif curRound == GuildWarDef.SIGNUP then
		if curStatus < GuildWarDef.END then
			local remainTime = GuildWarMainData.getEndTime(GuildWarDef.SIGNUP) - curTime
			if remainTime > 0 then
				des.timeDes = GetLocalizeStringBy("key_8535")
				des.remainTime = remainTime
			else
				des.timeDes = GetLocalizeStringBy("key_8536")
			end
		else
			local remainTime = GuildWarMainData.getStartTime(GuildWarDef.AUDITION) - curTime
			if remainTime > 0 then
				des.timeDes = GetLocalizeStringBy("key_8537")
				des.remainTime = remainTime
			else
				des.timeDes = GetLocalizeStringBy("key_8538")
			end
		end
	elseif curRound == GuildWarDef.AUDITION and curStatus < GuildWarDef.END then
		local remainTime = GuildWarMainData.getEndTime(GuildWarDef.AUDITION) - curTime
		if remainTime > 0 then
			des.timeDes = GetLocalizeStringBy("key_8539")
			des.remainTime = remainTime
		else
			des.timeDes = GetLocalizeStringBy("key_8538")
		end
	elseif curRound < GuildWarDef.ADVANCED_2 or curRound == GuildWarDef.ADVANCED_2 and curStatus < GuildWarDef.FIGHTEND then
		local round = curRound
		local subRound = curSubRound
		if curRound == GuildWarDef.AUDITION then 
			round = curRound + 1
			subRound = 1
		else
			if curSubStatus == GuildWarDef.FIGHTEND then
				if curSubRound == GuildWarDef.GROUP_NUM and curStatus == GuildWarDef.END then
					round = curRound + 1
					subRound = 1
				else
					subRound = subRound + 1
				end
			end
		end
		des.roundDes = roundDeses[round]
		if curSubStatus == GuildWarDef.FIGHTING then
			local remainTime = GuildWarMainData.getEndTime(round, subRound) - curTime
			if remainTime > 0 then
				des.timeDes = GetLocalizeStringBy("key_8540", subRound)
			else
				des.timeDes = GetLocalizeStringBy("key_8538")
			end
		elseif curStatus < GuildWarDef.FIGHTEND  or curStatus >= GuildWarDef.END then
			local remainTime = GuildWarMainData.getStartTime(round, subRound) - curTime
			if remainTime > 0 then
				des.timeDes = GetLocalizeStringBy("key_8541", subRound)
				des.remainTime = remainTime
			else
				des.timeDes = GetLocalizeStringBy("key_8538")
			end
		else
			local remainTime = GuildWarMainData.getEndTime(curRound) - curTime
			if remainTime > 0 then
				des.timeDes = GetLocalizeStringBy("key_8542", roundDeses[curRound])
				des.remainTime = remainTime
			else
				des.timeDes = GetLocalizeStringBy("key_8538")
			end
		end
	elseif curRound == GuildWarDef.ADVANCED_2 and curStatus < GuildWarDef.END then
		des.roundDes = roundDeses[GuildWarDef.ADVANCED_2]
		local remainTime = GuildWarMainData.getEndTime(GuildWarDef.ADVANCED_2) - curTime
		if remainTime > 0 then
			des.timeDes = GetLocalizeStringBy("key_8543")
			des.remainTime = remainTime
		else
			des.timeDes = GetLocalizeStringBy("key_8538")
		end
	else 
		--比赛结束
		des.roundDes  = GetLocalizeStringBy("key_8544")
	end
    -- print_t(des)
	return des
end

--[[
	@author:	bzx
	@desc:								得到倒计时Node
	@param:		string 		p_type		类型
	@return:	CCNode 
--]]
function getTimeTitle(p_type)
    local timeTileNode = CCNode:create()
    local des = getStageTitles2()
    local titleLabel = nil
    if p_type == "LordWarMainLayer" then
        titleLabel = CCRenderLabel:create("", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
    else
        titleLabel = CCLabelTTF:create("", g_sFontPangWa, 21)
    end
    timeTileNode:addChild(titleLabel)
    titleLabel:setColor(ccc3(0x00, 0xff, 0x18))
    titleLabel:setAnchorPoint(ccp(0, 0.5))
    titleLabel:setPosition(ccp(0, 0))
    local timeBg = CCSprite:create("images/olympic/time_bg.png")
    timeTileNode:addChild(timeBg)
    timeBg:setAnchorPoint(ccp(0, 0.5))
    local timeLabel = CCLabelTTF:create("00  :  00  :  00", g_sFontPangWa, 21)
    timeBg:addChild(timeLabel)
    timeLabel:setAnchorPoint(ccp(0.5, 0.5))
    timeLabel:setPosition(ccpsprite(0.5, 0.5, timeBg))
    local update = function()
        local size = CCSizeMake(0, 0)
        local des = getStageTitles2()
        if des.timeDes == nil then
            titleLabel:setVisible(false)
        else
        	titleLabel:setVisible(true)
            titleLabel:setString(des.timeDes)
            size.width = size.width + titleLabel:getContentSize().width
        end
        if des.remainTime == nil then
            timeBg:setVisible(false)
        else
            timeBg:setVisible(true)
            timeBg:setPosition(ccp(size.width, 0))
            local remainTimeStr = TimeUtil.getTimeString(des.remainTime)
            local timeArray = string.split(remainTimeStr, ":")
            local timeStr = string.format("%s  :  %s  :  %s", timeArray[1], timeArray[2], timeArray[3])
            timeLabel:setString(timeStr)
            size.width = size.width + timeBg:getContentSize().width
        end
        timeTileNode:setContentSize(size)
    end
    update()
    schedule(timeTileNode, update, 1)
    return timeTileNode
end

--[[
    @author:    bzx
    @desc:                              得到Round标题
    @return:    CCLabelTTF
--]]
function getRoundTitle()
    local titleLabel = CCLabelTTF:create("", g_sFontPangWa, 25)
    titleLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    local update = function()
        local timeDes = getStageTitles2()
        if timeDes.roundDes == nil then
            titleLabel:setVisible(false)
        else
            titleLabel:setVisible(true)
            titleLabel:setString(timeDes.roundDes)
        end
    end
    update()
  	schedule(titleLabel, update, 1)
    return titleLabel
end

--[[
	@author:		bzx
	@desc:					得到本届军团跨服赛的名称
	@return: 		CCLayerSprite
--]]
function getGuildWarNameSprite( ... )
	local nameSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/guild_war/effect/juntuansaibt/juntuansaibt"), -1, CCString:create(""))
	local timesLabel = CCRenderLabel:create(tostring(GuildWarMainData.getSession()), g_sFontPangWa, 40, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	nameSprite:addChild(timesLabel)
	timesLabel:setAnchorPoint(ccp(0.5, 0.5))
	timesLabel:setPosition(ccp(-105, 0))
	timesLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	return nameSprite
end
