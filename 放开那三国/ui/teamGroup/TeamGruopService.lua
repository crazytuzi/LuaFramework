-- Filename：	TeamGruopService.lua
-- Author：		zhz
-- Date：		2013-2-19
-- Purpose：		组队得网络层

module("TeamGruopService", package.seeall)

require "script/ui/teamGroup/TeamGroupData"
require "script/ui/tip/AnimationTip"

require "script/ui/guild/copy/GuildTeamData"
require "script/ui/item/ItemUtil"
require "script/ui/tip/AlertTip"
require "script/ui/tip/RichAlertTip"

--[[
	@des 	:进入对应得副本
	@param 	:callBackFunc 完成回调方法
	@return :
--]]
function getTeamInfo( callBackFunc , copyteam_id)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			print_t(dictData.ret)
			TeamGroupData.setTeamInfo(dictData.ret )
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end
	local args= CCArray:create()
    args:addObject(CCInteger:create(copyteam_id) )
   	Network.rpc(requestFunc, "team.enter", "team.enter", args, true)
end

--[[
	setInviteStatus (line 98)
	设置邀请状态 0是可以被所有人邀请 1是只能被本公会的人邀请

	return: 'ok'
	access: public
	string setInviteStatus (int $status)
	int $status
	@desc : 设置是否过滤非自己所在军团的组队邀请
	@param: pStatus 0:在组队邀请列表中对所有军团可见 1:在组队邀请列表中只对本军团可见
	@ret  :
--]]
function setInviteStatus( pStatus, pCallback )
	local cb = function ( pFlag, pRet, pBool )
		if pBool == true then
			if pCallback ~= nil then
				pCallback()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(pStatus)))
	Network.rpc(cb, "copyteam.setInviteStatus", "copyteam.setInviteStatus", args, true)
end

-- 检查组队次数和协助组队次数是否足够，若足够则执行函数pCallFunc,若不足够则弹出提示
-- 其中pBool为pCallFunc的布尔参数
function checkNumber( pCallFunc, pBool )
	local number = tonumber(GuildTeamData.getLeftGuildAtkNum()) 
    local helpNumber= GuildTeamData.getLeftHelpGuildNum()

	if(number<=0 and helpNumber<=0 ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2652"))
		return 

	elseif( number<=0 and helpNumber>0) then
	-- elseif( number>0 and helpNumber>0) then
		local closeFunc  = function (  )
			return
    	end
		-- AlertTip.showAlert(GetLocalizeStringBy("key_1309"), createTeamFunc, true,nil,nil,nil,closeFunc)
		local info = {
            touchPriority = -180,   -- menu的优先级
            width = 460, -- 宽度
            alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 24,          -- 默认字体大小
            elements =
            {
                {
                    ["type"] = "CCLabelTTF",
                    text = GetLocalizeStringBy("zz_131"),
                    color = ccc3(0x78, 0x25, 0x00) 
                },
                {
                    ["type"] = "CCLabelTTF", 
                    text = GetLocalizeStringBy("zz_132"),
                    color = ccc3(0x00, 0x64, 0x00) 
                },
                {
                    ["type"] = "CCLabelTTF",
                    text = GetLocalizeStringBy("zz_133"),
                    color = ccc3(0x78, 0x25, 0x00) 
                },
            }
        }
		RichAlertTip.showAlert(info, pCallFunc, true,nil,nil,nil,closeFunc)
	else
		pCallFunc(pBool)
	end
end


-- 创建队伍
function createTeam(callBackFunc, copyteam_id ,limitType )


	local function createTeamFunc( isConfirm )

		if(isConfirm == false) then
			return
		end

		local function requestFunc( cbFlag, dictData, bRet )
			if(bRet == true) then
				-- TreasureData.seizerInfoData = dictData.ret
				if(callBackFunc ~= nil) then
					callBackFunc()
				end
			end
		end

		local args= CCArray:create()
	    args:addObject(CCInteger:create(copyteam_id))
	    args:addObject(CCInteger:create(limitType ))
	   	Network.rpc(requestFunc, "copyteam.createTeam", "copyteam.createTeam", args, true)

	end 


	if(ItemUtil.isBagFull() ) then
		return 
    end

	-- local number = 0
 --    number = tonumber(GuildTeamData.getLeftGuildAtkNum()) 
 --    local helpNumber= GuildTeamData.getLeftHelpGuildNum()

	-- if(number<=0 and helpNumber<=0 ) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2652"))
	-- 	return 

	-- elseif( number<=0 and helpNumber>0) then
	-- 	local closeFunc  = function (  )
	-- 		return
 --    	end
	-- 	AlertTip.showAlert(GetLocalizeStringBy("key_1309"), createTeamFunc, true,nil,nil,nil,closeFunc)
	-- else
	-- 	createTeamFunc(true)
	-- end
	checkNumber(createTeamFunc, true)

end

-- 离开房间
function leaveTeam(  )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			
		end
	end
   	Network.rpc(requestFunc, "team.leave", "team.leave", nil, true)
end

-- 解散队伍
function dismissTeam( callBackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "team.dismiss", "team.dismiss", nil, true)
end

-- 离开队伍
function quit( callBackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				TeamGroupData.setIsKick(false)
				callBackFunc()

			end
		end
	end
	Network.rpc(requestFunc, "team.quit", "team.quit", nil, true)
end


-- 开战按钮
function start( callBackFunc, teamId)

	local  teamId = tonumber(teamId)
	local teamList = TeamGroupData.getTeamListByTeamId(teamId)
	local minNum = TeamGroupData.getCopyInfo().min
	-- 如果 team里面的人数小于最小开战人数的话，无法开战
	if( table.count(teamList)< minNum ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2348"))
		return 
	end

	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "team.start", "team.start", nil, true)

end

-- 踢人
function kick( callBackFunc , uid)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end
	local args= CCArray:create()
	args:addObject(CCInteger:create(uid) )

	Network.rpc(requestFunc, "team.kick", "team.kick", args, true)
end

--  加入
function joinTeam( callBackFunc , teamId)
	

	local function joinTeamCb( isConfirm )

		if(isConfirm == false) then
			return
		end

		local function requestFunc( cbFlag, dictData, bRet )
			if(bRet == true) then
				TeamGroupData.setOwnTeadId(tonumber(teamId))
				if(callBackFunc ~= nil) then
					callBackFunc()
				end
			end
		end

		local  args = CCArray:create()
		args:addObject(CCInteger:create(teamId))
		local copyId = TeamGroupData._copyId
		args:addObject(CCInteger:create(copyId) )

		Network.rpc(requestFunc, "copyteam.joinTeam", "copyteam.joinTeam", args, true)
		
	end 

	local  teamId = tonumber(teamId)
	local teamList = TeamGroupData.getTeamListByTeamId(teamId)
	local maxNum = TeamGroupData.getCopyInfo().max
	-- 如果 team里面的人数大于等于最大人数的话，无法加入
	if( table.count(teamList)>=maxNum ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2420"))
		return 
	end

	if(ItemUtil.isBagFull() ) then
		return 
    end

	-- local number = 0
 --    number = tonumber(GuildTeamData.getLeftGuildAtkNum()) 
 --    local helpNumber= GuildTeamData.getLeftHelpGuildNum()

	-- if(number<=0 and helpNumber<=0 ) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2652"))
	-- 	return 

	-- elseif( number<=0 and helpNumber>0) then
	-- 	local closeFunc  = function (  )
	-- 		return
 --    	end
	-- 	AlertTip.showAlert(GetLocalizeStringBy("key_1017"), joinTeamCb, true,nil,nil,nil,closeFunc)
	-- else
	-- 	joinTeamCb(true)
	-- end
	checkNumber(joinTeamCb, true)

end

-- 调整队伍 
-- 将sourceIndex处的人拿走，从sourceIndex + 1到targetIndex处的人依次前移，原sourceIndex的人移到targetIndex处
function adjustTeam(callBackFunc, sourceIndex,targetIndex )
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			TeamGroupData.adjuestOwnTeam(sourceIndex, targetIndex)
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
			
		end
	end

	local  args = CCArray:create()
	args:addObject(CCInteger:create(sourceIndex))
	args:addObject(CCInteger:create(targetIndex))

	Network.rpc(requestFunc, "team.adjust", "team.adjust", args, true)
end


-- 得到可以邀请的公会成员
-- 这里显示的玩家需满足的条件为：1）满足可进入该副本的4个条件。2）当前还有剩余次数。3）在线。
-- 需要显示的玩家信息包括：玩家头像、等级、玩家名称、战斗力。
function getGuildInviteInfo( callBackFunc , copyteam_id)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				TeamGroupData.setInviteMemberInfo(dictData.ret )
				callBackFunc()
			end
		end
	end

	local args= CCArray:create()
	args:addObject(CCInteger:create(copyteam_id))
	local uids= TeamGroupData.getTeamUidsList()
	local args_1= CCArray:create()
	for i=1, table.count(uids) do
	args_1:addObject(CCInteger:create(uids[i]))
	end
	args:addObject(args_1)

	print("uids is :")
	print_t(uids)

	args:addObject(CCInteger:create(50))

	Network.rpc(requestFunc, "copyteam.getAllInviteInfo", "copyteam.getAllInviteInfo", args, true)
end


-- 设置可以自动开始
--[[
	@desc: 是否自动开启
	@para: callBackFunc: 回调函数
	@isAutoStart: 1,自动开启。0， 不是自动开启
--]]
function setAutoStart(callBackFunc, isAutoStart )
	
	
	-- local autoS
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				callBackFunc()

				-- TeamGroupData.
			end
		end
	end

	local args= CCArray:create()
	args:addObject(CCInteger:create(isAutoStart))

	Network.rpc(requestFunc, "team.setAutoStart", "team.setAutoStart",args, true)

end

-- 邀请玩家的接口
function inviteGuildMem( callBackFunc, uid)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(callBackFunc ~= nil) then
				callBackFunc(dictData.ret)
			end
		end
	end

	local teamId = TeamGroupData.getOwnTeamId()  --UserModel.getUserUid()
	print("teamid  is ", teamId )
	local teamCopyId= TeamGroupData._copyId
	local uid = tonumber(uid)

	local args= CCArray:create()
	args:addObject(CCInteger:create(uid))
	args:addObject(CCInteger:create(teamCopyId))
	args:addObject(CCInteger:create( teamId))
	Network.rpc(requestFunc, "copyteam.inviteGuildMem", "copyteam.inviteGuildMem", args, true)
	
end


--   
function getOnlineTeamInfo( callBackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true) then
			TeamGroupData.setOnlineTeamInfo(dictData.ret)
			if(callBackFunc ~= nil) then
				callBackFunc()
			end
		end
	end

	local args= CCArray:create()
	local args_1= CCArray:create()

	--接到邀请的信息
	local inviteGuildMemInfo=  TeamGroupData.getGuildInviteMem()
	for i=1, table.count(inviteGuildMemInfo) do
		local tempMemInfo= inviteGuildMemInfo[i]
		local tmpUid = tempMemInfo[3]
		local tmpCopyTeamId= tempMemInfo[2]
		local teamMap = CCDictionary:create()
		teamMap:setObject(CCInteger:create(tmpUid), "teamId");
		teamMap:setObject(CCInteger:create(tmpCopyTeamId), "roomId");
		-- array:addObject(CCInteger:addObject(tmpUid))
		-- array:addObject(CCInteger:addObject(tmpCopyTeamId))
		args_1:addObject(teamMap)
	end
	args:addObject(args_1)
	args:addObject(CCInteger:create(0))

	Network.rpc(requestFunc, "team.getTeamInfo", "team.getTeamInfo", args, true)

end



-- 接受邀请的接口
-- 
function receiveInvite( callBackFunc, index )
	local guildInviteMemInfo= {}
	table.hcopy(TeamGroupData.getOnlineInviteMemByIndex(index), guildInviteMemInfo) 

	TeamGroupData.removeOnlineInviteMemByIndex(index)

	print("guildInviteMemInfo  guildInviteMemInfo  guildInviteMemInfo ")
	print_t(guildInviteMemInfo)

	changeToGuild(guildInviteMemInfo)

	

end

function changeToGuild( guildInviteMemInfo )
	
	local guildInviteMemInfo= guildInviteMemInfo
	local function getMemberInfoCallback( cbFlag, dictData, bRet )
		require "script/ui/guild/GuildDataCache"
		GuildDataCache.setMineSigleGuildInfo(dictData.ret)

		getGuildInfo(guildInviteMemInfo)
	end
	RequestCenter.guild_getMemberInfo(getMemberInfoCallback)
end

function getGuildInfo( guildInviteMemInfo )

	local function getGuildInfoCallback( cbFlag, dictData, bRet )
		require "script/ui/guild/GuildDataCache"
		require "script/ui/guild/copy/GuildCopyLayer"
		require "script/ui/teamGroup/TeamGroupLayer"
		if(bRet == true) then

			local teamId= guildInviteMemInfo[3]
			local copyId = guildInviteMemInfo[2]
			local limitType =GuildTeamData.getTeamLimitById(tonumber(copyId) )

			GuildDataCache.setGuildInfo(dictData.ret)
			-- 创建teamGroupLayer
			local function changeLayerDidLoad( )
				--背包满则不能进入军团副本
				if(ItemUtil.isBagFull() ) then
					return 
			    end

			    --背包还不满则可以进入对应军团副本并加入队伍
				TeamGroupLayer.showLayer(copyId,limitType,nil,nil, nil , function ( )
				print("teamId is 000000000 : ", teamId, "  __  ", copyId, "limitType ", limitType)
				TeamGruopService.joinTeamDelegate(  teamId, copyId)
				end)
			end
					
			require "script/ui/guild/copy/GuildCopyLayer"
			local guildCopyLayer= GuildCopyLayer.createLayer(changeLayerDidLoad)
			MainScene.changeLayer(guildCopyLayer, "guildCopyLayer" )

		end
	end
	RequestCenter.guild_getGuildInfo(getGuildInfoCallback)
	
end

function  joinTeamDelegate(teamId, copyId)


	local function joinTeamCb( isConfirm )

		if(isConfirm == false) then
			return
		end

		-- local function joinTeam_02( cbFlag, dictData, bRet )
		-- 	if(bRet == true) then
		-- 		TeamGroupData.setOwnTeadId(tonumber(teamId))
		-- 		if(callBackFunc ~= nil) then
		-- 			callBackFunc()
		-- 		end
		-- 	end
		-- end

		local  args = CCArray:create()
		args:addObject(CCInteger:create(teamId))
		local copyId = TeamGroupData._copyId
		args:addObject(CCInteger:create(copyId) )

		Network.rpc(joinTeam_02, "copyteam.joinTeam", "copyteam.joinTeam", args, true)
		
	end 

	-- if(ItemUtil.isBagFull() ) then
	-- 	TeamGroupLayer.closeCb()
	-- 	return 
 	-- end

	-- local number = 0
 --    number = tonumber(GuildTeamData.getLeftGuildAtkNum()) 
 --    local helpNumber= GuildTeamData.getLeftHelpGuildNum()

	-- if(number<=0 and helpNumber<=0 ) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_2652"))
	-- 	return 

	-- elseif( number<=0 and helpNumber>0) then
	-- 	local closeFunc  = function (  )
	-- 		return
 --    	end
	-- 	AlertTip.showAlert(GetLocalizeStringBy("key_1017"), joinTeamCb, true,nil,nil,nil,closeFunc)
	-- else
	-- 	joinTeamCb(true)
	-- end
	checkNumber(joinTeamCb, true)



	-- local args= CCArray:create()
	-- args:addObject(CCInteger:create(teamId))
	-- args:addObject(CCInteger:create(copyId))
	-- Network.rpc(joinTeam_02, "copyteam.joinTeam", "copyteam.joinTeam", args, true)
	
end


function joinTeam_02( cbFlag, dictData, bRet )

	print("dictData.err is : ",dictData.err , "  dictData.ret is : " , dictData.ret)
	if(dictData.err=="fake" ) then
		print("fake +++++++++++++++++++++")
		AlertTip.showAlert(GetLocalizeStringBy("key_1045"), nil)
		return 	
	elseif(dictData.ret == "false" or dictData.ret == false) then
		print("false +++++++++++++++++++++")
		AlertTip.showAlert(GetLocalizeStringBy("key_1045"), nil)
		return 	
	elseif(dictData.ret== "full" ) then
		AlertTip.showAlert(GetLocalizeStringBy("key_2420"),nil)
		return 
	elseif(dictData.ret =="ok") then
		TeamGroupData.setOwnTeadId(tonumber(teamId))
		TeamGroupLayer.rfcAftJoin()
	end
end


function changeMainLayer( )
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)

    require "script/ui/teamGroup/ReceiveInviteLayer"
    TeamGroupLayer.closeCb()
    ReceiveInviteLayer.showLayer()
end


