
local DailyPvpTopLayer = class("DailyPvpTopLayer",UFCCSModelLayer)
require("app.cfg.daily_crosspvp_rank")
require("app.cfg.daily_crosspvp_rank_title")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local MergeEquipment = require("app.data.MergeEquipment")

function DailyPvpTopLayer.create(...)
    return require("app.scenes.dailypvp.DailyPvpTopLayer").new("ui_layout/dailypvp_PaiHang.json",require("app.setting.Colors").modelColor,...) 
end

function DailyPvpTopLayer:ctor(json,color,...)
    self.super.ctor(self,json,color, ...)
    self:showAtCenter(true)
    self._tabs = require("app.common.tools.Tabs").new(3, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._initJiangli = false
    self._initRongyu = false
    self._initPaihang = false
    self:registerBtnClickEvent("Button_close", function()
         self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close2", function()
         self:animationToClose()
    end)
    self._curTab = "CheckBox_jiangli"

    self:getLabelByName("Label_getAward"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyu_label1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyu_label2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyu_label3"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyu_label4"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_myRongyuRank"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_nextRongyuRank"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_allAffect"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_allAffect2"):createStroke(Colors.strokeBrown, 1)
end

function DailyPvpTopLayer:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPGETRANK, self._onRankRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
    
    G_HandlersManager.dailyPvpHandler:sendTeamPVPGetRank()
    self:_initTabs()
end
function DailyPvpTopLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function DailyPvpTopLayer:onBackKeyEvent()
    self:animationToClose()
    return true
end

function DailyPvpTopLayer:_initTabs()
    self._tabs:add("CheckBox_jiangli", self:getPanelByName("Panel_jiangli"), "Label_jiangli") --delay load
    self._tabs:add("CheckBox_rongyu", self:getPanelByName("Panel_rongyu"), "Label_rongyu")  -- delay load
    self._tabs:add("CheckBox_paihang", self:getPanelByName("Panel_paihang"), "Label_paihang")  -- delay load

    self._tabs:checked("CheckBox_jiangli")
end




function DailyPvpTopLayer:_checkedCallBack(btnName)
    self._curTab = btnName
    if btnName == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    elseif btnName == "CheckBox_rongyu" then
        self:_resetRongyuListView()
    elseif btnName == "CheckBox_paihang" then
        self:_resetPaihangListView()
    end
end

function DailyPvpTopLayer:_resetJiangliListView()
    if self._initJiangli == false then
        self._initJiangli = true
        self.jiangliList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_jiangliList"), LISTVIEW_DIR_VERTICAL)
        self.jiangliList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.dailypvp.DailyPvpTopAwardCell").new(list, index)
        end)
        self.jiangliList:setUpdateCellHandler(function ( list, index, cell)
               cell:updateData(daily_crosspvp_rank.indexOf(index+1)) 
        end)
        self.jiangliList:initChildWithDataLength( 0)
    end
    
    self.jiangliList:reloadWithLength(daily_crosspvp_rank.getLength())
    self:_refreshJiangliRank()
end

function DailyPvpTopLayer:_resetRongyuListView()
    if self._initRongyu == false then
        self._initRongyu = true
        self.rongyuList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_rongyuList"), LISTVIEW_DIR_VERTICAL)
        self.rongyuList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.dailypvp.DailyPvpTopTxtCell").new(list, index)
        end)
        self.rongyuList:setUpdateCellHandler(function ( list, index, cell)
               cell:updateData(daily_crosspvp_rank_title.indexOf(index+1)) 
        end)
        self.rongyuList:initChildWithDataLength( 0)
    end
    self.rongyuList:reloadWithLength(daily_crosspvp_rank_title.getLength())
    self:_refreshRongyuRank()
end

function DailyPvpTopLayer:_resetPaihangListView()
    if self._initPaihang == false then
        self._initPaihang = true
        self.paihangList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_paihangList"), LISTVIEW_DIR_VERTICAL)
        self.paihangList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.dailypvp.DailyPvpTopCell").new(list, index)
        end)
        self.paihangList:setUpdateCellHandler(function ( list, index, cell)
               cell:updateData(G_Me.dailyPvpData:getRankList()[index+1],index) 
        end)
        self.paihangList:initChildWithDataLength( 0)
    end
    local length = #G_Me.dailyPvpData:getRankList()
    length = length > 100 and 100 or length
    self.paihangList:reloadWithLength(length)
    self:_refreshPaihangRank()
end

function DailyPvpTopLayer:_onRankRsp()
    if self._curTab == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    elseif self._curTab == "CheckBox_rongyu" then
        self:_resetRongyuListView()
    elseif self._curTab == "CheckBox_paihang" then
        self:_resetPaihangListView()
    end
end

function DailyPvpTopLayer:_refreshJiangliRank(  )
    local rank = G_Me.dailyPvpData:getRank()
    self:getLabelByName("Label_myJiangliRank"):setText(rank > 0 and rank or G_lang:get("LANG_WHEEL_NORANK"))
    if rank == 0 then
        local goodData = daily_crosspvp_rank.indexOf(daily_crosspvp_rank.getLength())
        for i = 1 , 2 do
            local g = G_Goods.convert(goodData["type_"..i],goodData["value_"..i])
            self:getImageViewByName("Image_award_myJiangli_icon"..i):loadTexture(g.icon_mini,g.texture_type)
            self:getLabelByName("Label_award_myJiangli_label"..i):setText(0)
        end
        for i = 1 , 2 do
            local g = G_Goods.convert(goodData["type_"..i],goodData["value_"..i])
            self:getLabelByName("Label_nextJiangliRank"):setText(goodData.lower_rank)
            self:getImageViewByName("Image_award_nextJiangli_icon"..i):loadTexture(g.icon_mini,g.texture_type)
            self:getLabelByName("Label_award_nextJiangli_label"..i):setText(GlobalFunc.ConvertNumToCharacter4(goodData["size_"..i]))
        end
    else
        local rankData = G_Me.dailyPvpData:getRankData(rank)
        for i = 1 , 2 do
            local g = G_Goods.convert(rankData["type_"..i],rankData["value_"..i])
            self:getImageViewByName("Image_award_myJiangli_icon"..i):loadTexture(g.icon_mini,g.texture_type)
            self:getLabelByName("Label_award_myJiangli_label"..i):setText(GlobalFunc.ConvertNumToCharacter4(rankData["size_"..i]))
        end
        local index = rankData.id - 1 
        index = index > 0 and index or 1
        local nextRankData = daily_crosspvp_rank.indexOf(index)
        self:getLabelByName("Label_nextJiangliRank"):setText(nextRankData.lower_rank)
        for i = 1 , 2 do
            local g = G_Goods.convert(nextRankData["type_"..i],nextRankData["value_"..i])
            self:getImageViewByName("Image_award_nextJiangli_icon"..i):loadTexture(g.icon_mini,g.texture_type)
            self:getLabelByName("Label_award_nextJiangli_label"..i):setText(GlobalFunc.ConvertNumToCharacter4(nextRankData["size_"..i]))
        end
    end
end

function DailyPvpTopLayer:_refreshRongyuRank(  )
    local title = G_Me.dailyPvpData:getTitle()
    local info = daily_crosspvp_rank_title.get(title)
    local nextTitle = title - 1 < 1 and title or title - 1
    local nextInfo = daily_crosspvp_rank_title.get(nextTitle)
    self:getLabelByName("Label_myRongyuRank"):setText(info.text)
    self:getLabelByName("Label_myRongyuRank"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_nextRongyuRank"):setText(nextInfo.text)
    self:getLabelByName("Label_nextRongyuRank"):setColor(Colors.qualityColors[nextInfo.quality])

    local loadString = function ( label1,label2,_type,_value )
        if _type > 0 then
            local _,_,typeStr,valueStr = MergeEquipment.convertAttrTypeAndValue(_type, _value)
            label1:setText(typeStr)
            label2:setText("+"..valueStr)
            label1:setVisible(true)
            label2:setVisible(true)
        else
            label1:setVisible(false)
            label2:setVisible(false)
        end
    end

    loadString(self:getLabelByName("Label_myRongyu_add_title1"),self:getLabelByName("Label_myRongyu_add_value1"),info.add_type1,info.add_value1)
    loadString(self:getLabelByName("Label_myRongyu_add_title2"),self:getLabelByName("Label_myRongyu_add_value2"),info.add_type2,info.add_value2)
    loadString(self:getLabelByName("Label_nextRongyu_add_title1"),self:getLabelByName("Label_nextRongyu_add_value1"),nextInfo.add_type1,nextInfo.add_value1)
    loadString(self:getLabelByName("Label_nextRongyu_add_title2"),self:getLabelByName("Label_nextRongyu_add_value2"),nextInfo.add_type2,nextInfo.add_value2)

    if info.add_type1 == 0 then
        self:getLabelByName("Label_myRongyu_add_value1"):setVisible(true)
        self:getLabelByName("Label_myRongyu_add_value1"):setText(G_lang:get("LANG_WUSH_NO"))
    end
end


function DailyPvpTopLayer:_refreshPaihangRank(  )
    local rank = G_Me.dailyPvpData:getRank()
    self:getLabelByName("Label_myPaiHang"):setText(rank > 0 and rank or G_lang:get("LANG_WHEEL_NORANK"))
    if rank == 0 then
        local goodData = daily_crosspvp_rank.indexOf(daily_crosspvp_rank.getLength())
        for i = 1 , 2 do
            local g = G_Goods.convert(goodData["type_"..i],goodData["value_"..i])
            self:getLabelByName("Label_myPaihangAward"..i):setText(g.name.." x 0")
        end
    else
        local rankData = G_Me.dailyPvpData:getRankData(rank)
        for i = 1 , 2 do
            local g = G_Goods.convert(rankData["type_"..i],rankData["value_"..i])
            self:getLabelByName("Label_myPaihangAward"..i):setText(g.name.." x "..GlobalFunc.ConvertNumToCharacter4(rankData["size_"..i]))
        end
    end
end

function DailyPvpTopLayer:_onRcvPlayerTeam(data)
        local user = rawget(data, "user")
        if user ~= nil then
            local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
            uf_sceneManager:getCurScene():addChild(layer)
        end
end

function DailyPvpTopLayer:onLayerExit()

end


return DailyPvpTopLayer
