
local TrigramsRankLayer = class("TrigramsRankLayer",UFCCSModelLayer)

require("app.cfg.wheel_prize_info")

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local FuCommon = require("app.scenes.dafuweng.FuCommon")


function TrigramsRankLayer.show(...)
    local layer = TrigramsRankLayer.create(...)
    uf_sceneManager:getCurScene():addChild(layer) 
end

function TrigramsRankLayer.create(...)
    return TrigramsRankLayer.new("ui_layout/trigrams_RankList.json",Colors.modelColor,...) 
end


function TrigramsRankLayer:ctor(json,...)
    
    self:showAtCenter(true)
    self._tabs = require("app.common.tools.Tabs").new(3, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._initPutong = false
    self._initJingying = false
    self._initJiangli = false

    self._curTab = "CheckBox_jiangli"

    self:getLabelByName("Label_myLevelpt"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_myLeveljy"):createStroke(Colors.strokeBrown, 1)

    self.super.ctor(self,...)
end

function TrigramsRankLayer:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_RANK, self._onTrigramsRankRsp, self)
    
    G_HandlersManager.trigramsHandler:sendGetRankList()
  
    self:_initTabs()
end
function TrigramsRankLayer:onLayerLoad(...)

    self:registerKeypadEvent(true)

    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)

    self:registerBtnClickEvent("Button_close2", function()
        self:animationToClose()
    end)

    --self:registerBtnClickEvent("Button_help", function()
        
    --end)

end
function TrigramsRankLayer:onBackKeyEvent()
    self:animationToClose()
    return true
end

function TrigramsRankLayer:_initTabs()
    self._tabs:add("CheckBox_putong", self:getPanelByName("Panel_putong"), "Label_putong") --delay load
    self._tabs:add("CheckBox_jingying", self:getPanelByName("Panel_jingying"), "Label_jingying")  -- delay load
    self._tabs:add("CheckBox_jiangli", self:getPanelByName("Panel_jiangli"), "Label_jiangli")  -- delay load

    self._tabs:checked("CheckBox_jiangli")
end




function TrigramsRankLayer:_checkedCallBack(btnName)
    self._curTab = btnName
    if btnName == "CheckBox_putong" then
        self:_resetPutongListView()
    elseif btnName == "CheckBox_jingying" then
        self:_resetJingyingListView()
    elseif btnName == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    end
end

function TrigramsRankLayer:_resetPutongListView()
    
    if self._initPutong == false then
        self._initPutong = true
        self.ptList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_putongList"), LISTVIEW_DIR_VERTICAL)
        self.ptList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.trigrams.TrigramsRankCell").new(list, index)
        end)
        self.ptList:setUpdateCellHandler(function ( list, index, cell)
            local data = G_Me.trigramsData:getRankList(FuCommon.RANK_TYPE_PT)
            if  index < #data then
               cell:updateData(list, index, data[index+1], FuCommon.RANK_TYPE_PT) 
            end
        end)
        self.ptList:initChildWithDataLength( 0)
    end
    local length = #G_Me.trigramsData:getRankList(FuCommon.RANK_TYPE_PT)
    length = length > FuCommon.RANK_LIST_LENGTH and FuCommon.RANK_LIST_LENGTH or length
    self.ptList:reloadWithLength(length)
    self:_refreshRankList(FuCommon.RANK_TYPE_PT)
end

function TrigramsRankLayer:_resetJingyingListView()
    
    if self._initJingying == false then
        self._initJingying = true
        self.jyList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_jingyingList"), LISTVIEW_DIR_VERTICAL)
        self.jyList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.trigrams.TrigramsRankCell").new(list, index)
        end)
        self.jyList:setUpdateCellHandler(function ( list, index, cell)
            local data = G_Me.trigramsData:getRankList(FuCommon.RANK_TYPE_JY)
            if  index < #data then
               cell:updateData(list, index, data[index+1], FuCommon.RANK_TYPE_JY) 
            end
        end)
        self.jyList:initChildWithDataLength( 0)
    end
    local length = #G_Me.trigramsData:getRankList(FuCommon.RANK_TYPE_JY)
    length = length > FuCommon.RANK_LIST_LENGTH and FuCommon.RANK_LIST_LENGTH or length
    self.jyList:reloadWithLength(length)
    self:_refreshRankList(FuCommon.RANK_TYPE_JY)
end

function TrigramsRankLayer:_resetJiangliListView()
    if self._initJiangli == false then
        self._initJiangli = true
        local prize = self:_getPrizeData()
        self:getLabelByName("Label_titlept"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_titlejy"):createStroke(Colors.strokeBrown, 1)
        self.ptAwardList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_awardListpt"), LISTVIEW_DIR_VERTICAL)
        self.ptAwardList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.trigrams.TrigramsRankTxtCell").new()
        end)
        self.ptAwardList:setUpdateCellHandler(function ( list, index, cell)
            if  index < #prize/2 then
               cell:updateData(list, FuCommon.RANK_TYPE_PT, prize[index+1]) 
            end
        end)
        self.ptAwardList:initChildWithDataLength( #prize/2)

        self.jyAwardList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_awardListjy"), LISTVIEW_DIR_VERTICAL)
        self.jyAwardList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.trigrams.TrigramsRankTxtCell").new()
        end)
        self.jyAwardList:setUpdateCellHandler(function ( list, index, cell)
            if  index < #prize/2 then
               cell:updateData(list, FuCommon.RANK_TYPE_JY, prize[index+#prize/2+1]) 
            end
        end)
        self.jyAwardList:initChildWithDataLength( #prize/2)
        self:getLabelByName("Label_awardDesc"):setText(G_lang:get("LANG_TRIGRAMS_AWARD_DESC"))
        self:getLabelByName("Label_awardDesc"):createStroke(Colors.strokeBrown, 1)
    end
end

function TrigramsRankLayer:_onTrigramsRankRsp()
    if self._curTab == "CheckBox_putong" then
        self:_resetPutongListView()
    elseif self._curTab == "CheckBox_jingying" then
        self:_resetJingyingListView()
    elseif self._curTab == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    end
end


function TrigramsRankLayer:_getPrizeData()
    local prizeList = {}
    for i = 1 , wheel_prize_info.getLength() do 
        local info = wheel_prize_info.indexOf(i)
        if info.event_type == FuCommon.TRIGRAMS_PRIZE_TYPE then
            table.insert(prizeList,#prizeList+1,info)
        end
    end

    return prizeList
end

function TrigramsRankLayer:_refreshRankList(_type)

    local typeStr = _type == FuCommon.RANK_TYPE_PT and "pt" or "jy"
    local rank,score,jyRankScore,awardRank,score100
    
    rank = G_Me.trigramsData.myRank
    score = G_Me.trigramsData.score
    jyRankScore = G_Me.trigramsData.jyRankScore
    awardRank = G_Me.trigramsData.awardRank
    score100 = G_Me.trigramsData:getScore100(_type)

    if rank  == 0 or (_type == FuCommon.RANK_TYPE_JY and score < jyRankScore) then
        self:getPanelByName("Panel_my"..typeStr.."RankAward"):setVisible(false)
        self:getImageViewByName("Image_rank"..typeStr):setVisible(true)
        self:getImageViewByName("Image_rank"..typeStr):loadTexture("ui/text/txt/phb_weishangbang.png")
        self:getLabelBMFontByName("BitmapLabel_rank"..typeStr):setVisible(false)
        self:getLabelByName("Label_award"..typeStr):setVisible(false)
        self:getLabelByName("Label_norank"..typeStr):setVisible(true)
        local txt = G_lang:get("LANG_WHEEL_NORANK2",{num=awardRank,num2=awardRank,score=score100})
        if _type == FuCommon.RANK_TYPE_JY and score < jyRankScore then
            txt = G_lang:get("LANG_WHEEL_NORANK1",{num=jyRankScore})
        end
        self:getLabelByName("Label_norank"..typeStr):setText(txt)
    else
        self:getPanelByName("Panel_my"..typeStr.."RankAward"):setVisible(true)
        self:getLabelByName("Label_award"..typeStr):setVisible(true)
        self:getLabelByName("Label_norank"..typeStr):setVisible(false)
        if rank <= 3 then
            self:getImageViewByName("Image_rank"..typeStr):setVisible(true)
            self:getImageViewByName("Image_rank"..typeStr):loadTexture("ui/text/txt/phb_"..rank.."st.png")
            self:getLabelBMFontByName("BitmapLabel_rank"..typeStr):setVisible(false)
        else
            self:getLabelBMFontByName("BitmapLabel_rank"..typeStr):setVisible(true)
            self:getImageViewByName("Image_rank"..typeStr):setVisible(false)
            self:getLabelBMFontByName("BitmapLabel_rank"..typeStr):setText(rank)
        end
        local info = G_Me.trigramsData:getAward(rank,_type)
        
        if info ~= nil then
	        for i = 1 , 3 do 
	            if info["type_"..i] > 0 then

                    self:getLabelByName("Label_"..typeStr.."Award"..i):setText(info["prize_"..i].." x"..GlobalFunc.ConvertNumToCharacter2(info["size_"..i]))
	                --local g = G_Goods.convert(info["type_"..i], info["value_"..i])
	                --self:getLabelByName("Label_"..typeStr.."Award"..i):setText(info["prize_"..i].." x"..GlobalFunc.ConvertNumToCharacter2(info["size_"..i]))
	                self:getLabelByName("Label_"..typeStr.."Award"..i):setVisible(true)
	            else
	                self:getLabelByName("Label_"..typeStr.."Award"..i):setVisible(false)
	            end
	        end
	    end
    end
end

function TrigramsRankLayer:onLayerExit()
   
end


return TrigramsRankLayer
