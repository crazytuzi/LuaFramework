--[[
******群豪榜管理类*******

	-- by haidong.gan
	-- 2013/12/27
]]


local ArenaManager = class("ArenaManager")


-- ArenaManager.EVENT_REWARD_COMPELETE = "ArenaManager.EVENT_REWARD_COMPELETE";
ArenaManager.ResetWaitTimeSuccess       = "ArenaManager.ResetWaitTimeSuccess";
ArenaManager.TOP_FIGHT_REPORT_UPDATE    = "ArenaManager.TOP_FIGHT_REPORT_UPDATE";
ArenaManager.MY_FIGHT_REPORT_UPDATE     = "ArenaManager.MY_FIGHT_REPORT_UPDATE";

function ArenaManager:ctor()
    TFDirector:addProto(s2c.ARENA_PLAYER_LIST, self, self.onReceivePlayerList);
    TFDirector:addProto(s2c.ARENA_TOP_PLAYER_LIST, self, self.onReceiveTopPlayerList);

    -- TFDirector:addProto(s2c.ARENA_RAND_LIST, self, self.onReceiveRandList);
    TFDirector:addProto(s2c.ARENA_HOME_INFO, self, self.onReceiveHomeInfo);
    -- TFDirector:addProto(s2c.ARENA_REWARD_COMPELETE, self, self.onReceiveRewardComplete);
   
    TFDirector:addProto(s2c.ARENA_CHALLENGE_RESULT, self, self.onReceiveChallengeResult);

    TFDirector:addProto(s2c.ARENA_BEST_UPDATE, self, self.onReceiveArenaBestUpdate);

    TFDirector:addProto(s2c.RESET_WAIT_TIME_SUCCESS, self, self.resetWaitTimeCallback);


    TFDirector:addProto(s2c.ARENA_TOP_BATTLE_REPORT_LIST, self, self.recvTopFightReport);
    TFDirector:addProto(s2c.MY_CHALLENAGE_ARENA_BATTLE_REPORT_LIST, self, self.recvMyFightReport);

    self.rewardList = require("lua.table.t_s_hero_list_reward");
end

function ArenaManager:onReceiveChallengeResult( event )
    print("onReceiveChallengeResult")
    -- print(event.data)

    hideLoading();
    local win = event.data.win;
    local myRank = event.data.myRank;
    if win == true then

        if myRank <=7 then
        self:updateTopPlayerList();
        end

        self:updatePlayerList();
    end
    self:updateHomeInfo();

end

function ArenaManager:onReceiveArenaBestUpdate( event )
    print("onReceiveArenaBestUpdate")
    -- print(event.data)
    hideLoading();
    self:showArenaResultLayer(event.data);
end

function ArenaManager:onReceivePlayerList( event )
    print("onReceivePlayerList")
    print(event.data)

    hideLoading();
    ViewDataCache:setCache(self.updatePlayerList, event.data);
    TFDirector:dispatchGlobalEventWith(self.updatePlayerList, event.data);
end

function ArenaManager:onReceiveTopPlayerList( event )
    print("onReceiveTopPlayerList")
    -- print(event.data)

    hideLoading();
    ViewDataCache:setCache(self.updateTopPlayerList, event.data);
    TFDirector:dispatchGlobalEventWith(self.updateTopPlayerList, event.data);
end

-- function ArenaManager:onReceiveRandList( event )
--     print("onReceiveRandList")
--     print(event.data)

--     hideLoading();
--     ViewDataCache:setCache(self.updateRandList, event.data);
--     TFDirector:dispatchGlobalEventWith(self.updateRandList, event.data);
-- end

-- function ArenaManager:onReceiveRewardComplete( event )
--     print("onReceiveRewardComplete")
--     print(event.data)

--     hideLoading();
--     TFDirector:dispatchGlobalEventWith(ArenaManager.EVENT_REWARD_COMPELETE, event.data);
-- end

function ArenaManager:onReceiveHomeInfo( event )
    print("onReceiveHomeInfo")
    print(event.data)

    hideLoading();
    ViewDataCache:setCache(self.updateHomeInfo, event.data);
    TFDirector:dispatchGlobalEventWith(self.updateHomeInfo, event.data);
end

function ArenaManager:updateTopPlayerList()
    showLoading();
    TFDirector:send(c2s.ARENA_GET_TOP_PLAYER_LIST, {} );

    -- --测试代码 begin
    -- local event = require("testdata.Arena_s2c")
    -- self:onReceivePlayerList(event.playerEvent);
    -- --测试代码 end
end

function ArenaManager:updatePlayerList()
    showLoading();
    TFDirector:send(c2s.ARENA_GET_PLAYER_LIST, {} );

    -- --测试代码 begin
    -- local event = require("testdata.Arena_s2c")
    -- self:onReceivePlayerList(event.playerEvent);
    -- --测试代码 end
end
-- function ArenaManager:updateRandList(startIndex, length)
--     showLoading();
--     TFDirector:send(c2s.ARENA_GET_RAND_LIST, {startIndex, length} );

--     -- --测试代码 begin
--     -- local event = require("testdata.Arena_s2c")
--     -- self:onReceiveRandList(event.rankEvent);
--     -- --测试代码 end
-- end

-- function ArenaManager:receiveReward()
--     showLoading();
--     TFDirector:send(c2s.ARENA_RECEIVE_REWARD, {} );
--     --测试代码 begin
--     -- self:onReceiveRewardComplete({});
--     --测试代码 end
-- end

function ArenaManager:challengePlayer(playerId)
    showLoading();
    TFDirector:send(c2s.ARENA_CHALLENGE_PLAYER, { playerId } );
end

function ArenaManager:updateHomeInfo()
    showLoading();
    TFDirector:send(c2s.ARENA_GET_HOME_INFO, {} );
end



function ArenaManager:getRewardList(rank)
    for reward in self.rewardList:iterator() do
        if rank >= reward.min_rank and rank <= reward.max_rank then
           return RewardConfigureData:GetRewardItemListById(reward.reward_id);
        end
    end
    print("rank没有找到奖励 rank =",rank)
    return nil
end

function ArenaManager:restart()

end

function ArenaManager:showHomeLayer()
    AlertManager:addLayerByFile("lua.logic.arena.ArenaHomeLayer");
    AlertManager:show();

    -- getDynamicData(self, self.updateHomeInfo);
end

function ArenaManager:showArenaLayer()
    AlertManager:addLayerByFile("lua.logic.arena.ArenaPlayerListLayer");
    AlertManager:show()

    getDynamicData(self, self.updatePlayerList);
    getDynamicData(self, self.updateTopPlayerList);

    getDynamicData(self, self.updateHomeInfo);

end

function ArenaManager:showRewardList()
    AlertManager:addLayerByFile("lua.logic.arena.ArenaRewardListLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    AlertManager:show();
end
function ArenaManager:showArenaResultLayer(data)
    local layer = AlertManager:addLayerByFile("lua.logic.arena.ArenaResultLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(data)
    AlertManager:show();
end

function ArenaManager:showDetail(playerId,type)
    OtherPlayerManager:showOtherPlayerdetails(playerId,type)
end

-- function ArenaManager:showRandList(startIndex, length)
--     AlertManager:addLayerByFile("lua.logic.arena.ArenaRankListLayer");
--     AlertManager:show();

--     getDynamicData(self, self.updateRandList, startIndex, length);
-- end
-- function ArenaManager:showRewardLayer()

--     AlertManager:addLayerByFile("lua.logic.arena.ArenaRewardInfoLayer");
--     AlertManager:show();

--     getDynamicData(self, self.updateHomeInfo);

-- end
function ArenaManager:addLayerToCache()
end

--[[
重置等待时间
]]
function ArenaManager:requestResetWaitTime(resType)
    showLoading()
    local msg = 
    {
        resType
    }
    TFDirector:send(c2s.REQUEST_RESET_WAIT_TIME,msg)
end

--[[
重置等待时间回调
]]
function ArenaManager:resetWaitTimeCallback(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(self.ResetWaitTimeSuccess, event.data);
end

function ArenaManager:requestTopFightReport()
    showLoading()
    TFDirector:send(c2s.QUERY_ARENA_TOP_BATTLE_REPORT, {})
end

function ArenaManager:recvTopFightReport(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(self.TOP_FIGHT_REPORT_UPDATE, event.data);
end


function ArenaManager:requestMyFightReport()
    showLoading()
    TFDirector:send(c2s.QUERY_MY_ARENA_CHALLENGE_BATTLE_REPORT, {})
end

function ArenaManager:recvMyFightReport(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(self.MY_FIGHT_REPORT_UPDATE, event.data);
end

return ArenaManager:new();
