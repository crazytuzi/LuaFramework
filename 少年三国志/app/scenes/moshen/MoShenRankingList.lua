local MoShenRankingList = class("MoShenRankingList",UFCCSModelLayer)
require("app.cfg.rebel_rank_reward_info")
local REBEL_RANK_TYPE = {
    EXPLOIT = 1;
    MAX_HARM = 2;
}

--注意添加json文件
function MoShenRankingList.create(...)
    local layer = MoShenRankingList.new("ui_layout/moshen_MoShenRankingList.json",Colors.modelColor,...)
    return layer
end

function MoShenRankingList:ctor(json,color,gongxunRank,shanghaiRank,...)
    self.super.ctor(self,...)
    self._tabs = nil
    self._views = {}
    self._gongxunListView = nil
    self._shanghaiListListView = nil
    self._myGongxunRank = gongxunRank
    self._myShanghaiRank = shanghaiRank


    self._gongxunList = {}
    self._shanghaiList = {}
    
    self:showAtCenter(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_REBEL_RANK, self._getRankList, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MOSHEN_MY_REBEL_RANK, self._getMyRank, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
    self:_initButtonEvent()
    self:_initAwardList()
    self:_createStrokes()
    self:setVisible(false)
    G_HandlersManager.moshenHandler:sendRebelRank()
    -- G_HandlersManager.moshenHandler:sendMyRebelRank(REBEL_RANK_TYPE.EXPLOIT)
    -- G_HandlersManager.moshenHandler:sendMyRebelRank(REBEL_RANK_TYPE.MAX_HARM)

    self:getWidgetByName("Image_11"):setCascadeColorEnabled(false)
    self:getWidgetByName("Panel_26"):setCascadeColorEnabled(false)
    self:getWidgetByName("Panel_awardList"):setCascadeColorEnabled(false)
end

function MoShenRankingList:_createStrokes()
    self:getLabelByName("Label_tag01"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_tag02"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_tag03"):createStroke(Colors.strokeBrown,2)
    --self:getLabelByName("Label_CurRank"):createStroke(Colors.strokeBlack,1)
    --self:getLabelByName("Label_TargetRank"):createStroke(Colors.strokeBlack,1)
    self:getLabelByName("Label_bottomawark"):createStroke(Colors.strokeBlack,1)

end

--接收排行榜
function MoShenRankingList:_getRankList(data)
    self:setVisible(true)
    self._gongxunList = {}
    self._shanghaiList = {}
    if data.ret == 1 then 
        for i,v in ipairs(data.exploit_rank) do
            self._gongxunList[#self._gongxunList+1] = v
        end
        for i,v in ipairs(data.max_harm_rank) do
            self._shanghaiList[#self._shanghaiList+1] = v
        end
    end
    self:_initListView()
    self:_initViews()
    self._gongxunListView:reloadWithLength(#self._gongxunList,0)
    self._shanghaiListListView:reloadWithLength(#self._shanghaiList,0)
end

function MoShenRankingList:_initAwardList()
    if self._awardListView == nil then
        self._gongxunAwardListData = {}
        self._shanghaiAwardListData = {}
        local length = rebel_rank_reward_info.getLength()
        for i=1,length do
            local item = rebel_rank_reward_info.indexOf(i)
            if item.rank_type==1 then
                table.insert(self._gongxunAwardListData,item)
            elseif item.rank_type==2 then
                table.insert(self._shanghaiAwardListData,item)
            end
        end
        local panel = self:getPanelByName("Panel_awardList")
        self._awardListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._awardListView:setCreateCellHandler(function ()
            return require("app.scenes.moshen.MoShenRankingAwardItem").new()
        end)
        self._awardListView:setUpdateCellHandler(function ( list, index, cell)
            cell:update(index,self._gongxunAwardListData[index+1],self._shanghaiAwardListData[index+1])
        end)
        local len = #self._gongxunAwardListData > #self._shanghaiAwardListData and #self._gongxunAwardListData or #self._shanghaiAwardListData
        self._awardListView:reloadWithLength(len,0)

        --这里是为了修正一个列表对齐问题：列表在刚显示时顶部并未完全顶格
        self._awardListView:scrollToTopLeftCellIndex(0, 0, 0,function() end)
        self._awardListView:setScrollEnabled(false)

    end 

end

--接收我的排名
function MoShenRankingList:_getMyRank(data)

end

function MoShenRankingList:_onGetUserInfo(data)
    if data.ret == 1 then
        if data.user == nil or data.user.knights == nil or #data.user.knights == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
            return
        end
        local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
        uf_notifyLayer:getModelNode():addChild(layer)
    end
end


function MoShenRankingList:_initViews()
    --底部提示文字
    self._tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)
    self._tabs:add("CheckBox_gongxun", self._views["CheckBox_gongxun"],"Label_gongxunRank")
    self._tabs:add("CheckBox_shanghai", self._views["CheckBox_shanghai"],"Label_shanghaiRank")
    self._tabs:add("CheckBox_awardrank", self._views["CheckBox_awardrank"],"Label_rankAward")
    self._tabs:checked("CheckBox_gongxun")
end

function MoShenRankingList:_initListView()

        --功勋排行
    if self._gongxunListView == nil then
        local panelGongxun = self:getPanelByName("Panel_gongxun")
        self._gongxunListView = CCSListViewEx:createWithPanel(panelGongxun,LISTVIEW_DIR_VERTICAL)
        self._gongxunListView:setCreateCellHandler(function ()
            return require("app.scenes.moshen.MoShenFeatRankItem").new()
        end)
        self._gongxunListView:setUpdateCellHandler(function ( list, index, cell)
            local rebelRank = self._gongxunList[index+1]
            cell:update(rebelRank)
            cell:checkZhenrong(function()
                G_HandlersManager.arenaHandler:sendCheckUserInfo(rebelRank.user_id)
                end)
        end)
    end
    self._views["CheckBox_gongxun"]=self._gongxunListView
        --伤害排行
    if self._shanghaiListListView == nil then
        local panelShanghai = self:getPanelByName("Panel_shanghai")
        self._shanghaiListListView = CCSListViewEx:createWithPanel(panelShanghai,LISTVIEW_DIR_VERTICAL)
        self._shanghaiListListView:setCreateCellHandler(function ()
            return require("app.scenes.moshen.MoShenHurtRankItem").new()
        end)
        self._shanghaiListListView:setUpdateCellHandler(function ( list, index, cell)
            local rebelRank = self._shanghaiList[index+1]
            cell:update(rebelRank)
            cell:checkZhenrong(function()
                G_HandlersManager.arenaHandler:sendCheckUserInfo(rebelRank.user_id)
                end)
        end)
    end
    self._views["CheckBox_shanghai"]=self._shanghaiListListView
    self._views["CheckBox_awardrank"] = self:getWidgetByName("Panel_awardrank")
end

function MoShenRankingList:_initButtonEvent()
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close02",function()
        self:animationToClose()
    end)
end

function MoShenRankingList:_updateRankInfo(rankType)
    -- 根据排行类型获取当前排名和奖励列表
    local rank = 0
    local awardList = nil
    if rankType == REBEL_RANK_TYPE.EXPLOIT then
        rank = self._myGongxunRank or 0
        awardList = self._gongxunAwardListData
    elseif rankType == REBEL_RANK_TYPE.MAX_HARM then
        rank = self._myShanghaiRank or 0
        awardList = self._shanghaiAwardListData
    end

    -- 如果rank超出了奖励表中最后的排名，置为0（这种情况应该服务器返回的rank本身就是0，防一下）
    if rank > awardList[#awardList].max_rank then
        rank = 0
    end

    -- 获得当前奖励项和目标奖励项
    local curAward = nil
    local targetAward = awardList[#awardList]
    if rank > 0 then
        for i, v in ipairs(awardList) do
            if rank >= v.min_rank and rank <= v.max_rank then
                curAward = v
                targetAward = (rank == 1 and nil or awardList[i-1])
            end
        end
    end

    -- 已经是第一名的话，不显示目标排名
    self:showWidgetByName("Panel_TargetRank", rank ~= 1)

    -- 未上榜，不显示当前排名奖励，显示一句提示
    self:showWidgetByName("Panel_CurAward", rank > 0)
    self:showWidgetByName("Label_Tip", rank == 0)

    -- 设置当前排名信息
    self:showTextWithLabel("Label_CurRank", rank > 0 and tostring(rank) or G_lang:get("LANG_NOT_IN_RANKING_LIST"))

    -- 设置当前排名奖励或者未上榜提示
    if rank > 0 then
        self:showTextWithLabel("Label_CurAward_Num", tostring(curAward.reward_size))
    else
        self:showTextWithLabel("Label_Tip", G_lang:get("LANG_MOSHEN_RAISE_RANK_TIP", {rank = targetAward.max_rank}))
    end

    -- 设置目标排名和奖励
    if rank ~= 1 then
        self:showTextWithLabel("Label_TargetRank", tostring(targetAward.max_rank))
        self:showTextWithLabel("Label_TargetAward_Num", tostring(targetAward.reward_size))
    end
end

function MoShenRankingList:_onCheckCallback(newName)
    local isRankChecked = (newName ~= "CheckBox_awardrank")

    self:showWidgetByName("Panel_alllist", isRankChecked)    
    self:showWidgetByName("Panel_myrank", isRankChecked)
    self:showWidgetByName("Label_bottomawark", not isRankChecked)

    -- update rank info if checked
    if isRankChecked then
        local rankType = (newName == "CheckBox_gongxun" and REBEL_RANK_TYPE.EXPLOIT or REBEL_RANK_TYPE.MAX_HARM)
        self:_updateRankInfo(rankType)
    end
end

function MoShenRankingList:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function MoShenRankingList:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return MoShenRankingList

