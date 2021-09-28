

local RankListModel = {}


RankListModel.listVec       = {}
RankListModel.myRankVec     = {}



local LEVEL_TYPE      = 1
local BATTLE_TYPE     = 2
local JIANGHU_TYPE    = 3
local ARENA_TYPE      = 4

RANK_LIST_KEY = {
	NO_ONE_KEY           = 3200109,         --申请列表没有玩家
	AGREE_SUC_KEY        = 3200110,         --添加好友成功
	REJECT_SUC_KEY       = 3200111,         --拒绝好友成功
	SEND_NAILI_SUC_KEY   = 3200112,			--成功赠送对方1点耐力
	GET_NAILI_SUC_KEY    = 3200106,         --领取耐力成功
	NAI_LI_FULL_KEY      = 3200002,         --耐力已满
	GET_ALL_NAILI_KEY    = 3200113,			--领取所有耐力并回赠
	AGREE_FRIEND_KEY     = 3200114,         --接受好友
	SEND_APPLY_KEY       = 3200115,         --已申请	
	NUM_PLZ_KEY          = 3200101,			--搜索玩家id只能输入数字，请重新输入
	CANNOT_EMPTY_KEY     = 3200102,			--发送内容不能为空！
	TOO_MUCH_CHAR_KEY    = 3200103,			--输入内容超过40个字，请重新编辑
	REV_FRIEND_SUC_KEY   = 3200104,			--删除好友成功
	NO_PLAYER_KEY        = 3200105,			--您搜索的玩家不存在！
	TOO_MUCH_NAME_KEY    = 3200116,         --玩家名称不得超过七个字

	NUM_LIMIT_KEY	     = 3200004,         --我好友已满了

	FRIEND_NUM_LIMIT_KEY = 3200005          --对方好友已满

}

RankListModel.MAX_NAME_LEN      = 7
RankListModel.MAX_TEXT_LEN      = 30

function RankListModel.resetType(type)
	--服务器的type和前端的不一样
	--服务器的type:竞技场=1;等级=2;战力=3;副本=4;
	if type == 1 then
		return 2
	elseif type == 2 then
		return 3
	elseif type == 3 then
		return 4
	else 
		return 1
	end
end

function RankListModel.sendListReq(param)
	local requestType = RankListModel.resetType(param.listType)

	 RequestHelper.sendRankListReq({
	 	callback = function(data)
		 	RankListModel.initData(param.listType,data)
		 	param.callback()
	 	end,
	 	listType = requestType
	 	})
  
end

function RankListModel.initData(type,data)



	RankListModel.listVec[type] = data.rtnObj.infos
	RankListModel.myRankVec[type] = data.rtnObj.myRank

end

function RankListModel.getList(type)
	return RankListModel.listVec[type]
end

function RankListModel.getMyRank(type)
	return RankListModel.myRankVec[type]
end






return RankListModel