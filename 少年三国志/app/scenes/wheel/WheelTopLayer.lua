
local WheelTopLayer = class("WheelTopLayer",UFCCSModelLayer)
require("app.cfg.wheel_prize_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function WheelTopLayer.create(mode,...)
    return require("app.scenes.wheel.WheelTopLayer").new("ui_layout/wheel_PaiHang.json",require("app.setting.Colors").modelColor,mode,...) 
end
--类型1-转盘，2-大富翁
function WheelTopLayer:ctor(json,color,mode,...)
    self.super.ctor(self,json,color, ...)
    self._mode = mode
    self:showAtCenter(true)
    self._tabs = require("app.common.tools.Tabs").new(3, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._initPutong = false
    self._initJingying = false
    self._initJiangli = false
    self:registerBtnClickEvent("Button_close", function()
         self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close2", function()
         self:animationToClose()
    end)
    self._curTab = "CheckBox_jiangli"

    local titlePath = mode==1 and "ui/text/txt-title/lunpanpaihangbang.png" or "ui/text/txt-title/xunyoupaihangbang.png"
    -- print("titlePath "..titlePath)
    self:getImageViewByName("Image_TitleTxt"):loadTexture(titlePath)
    self:getLabelByName("Label_myLevelpt"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_myLeveljy"):createStroke(Colors.strokeBrown, 1)
end

function WheelTopLayer:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_RANK, self._onWheelRankRsp, self)
    if self._mode == 1 then
        G_HandlersManager.wheelHandler:sendWheelRankingList()
    elseif self._mode == 2 then
        G_HandlersManager.richHandler:sendRichRankingList()
    end
    self:_initTabs()
end
function WheelTopLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function WheelTopLayer:onBackKeyEvent()
    self:animationToClose()
    return true
end

function WheelTopLayer:_initTabs()
    self._tabs:add("CheckBox_putong", self:getPanelByName("Panel_putong"), "Label_putong") --delay load
    self._tabs:add("CheckBox_jingying", self:getPanelByName("Panel_jingying"), "Label_jingying")  -- delay load
    self._tabs:add("CheckBox_jiangli", self:getPanelByName("Panel_jiangli"), "Label_jiangli")  -- delay load

    self._tabs:checked("CheckBox_jiangli")
end




function WheelTopLayer:_checkedCallBack(btnName)
    self._curTab = btnName
    if btnName == "CheckBox_putong" then
        self:_resetPutongListView()
    elseif btnName == "CheckBox_jingying" then
        self:_resetJingyingListView()
    elseif btnName == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    end
end

function WheelTopLayer:_resetPutongListView()
    -- print("_resetPutongListView")
    if self._initPutong == false then
        self._initPutong = true
        self.ptList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_putongList"), LISTVIEW_DIR_VERTICAL)
        self.ptList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.wheel.WheelTopCell").new(list, index,1)
        end)
        self.ptList:setUpdateCellHandler(function ( list, index, cell)
            local data = self:_getData(1)
            if  index < #data then
               cell:updateData(list, index,data[index+1],self._mode,1) 
            end
        end)
        self.ptList:initChildWithDataLength( 0)
    end
    local length = #self:_getData(1)
    length = length > 20 and 20 or length
    self.ptList:reloadWithLength(length)
    self:_refreshMyRank(1)
end

function WheelTopLayer:_resetJingyingListView()
    -- print("_resetJingyingListView")
    if self._initJingying == false then
        self._initJingying = true
        self.jyList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_jingyingList"), LISTVIEW_DIR_VERTICAL)
        self.jyList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.wheel.WheelTopCell").new(list, index,2)
        end)
        self.jyList:setUpdateCellHandler(function ( list, index, cell)
            local data = self:_getData(2)
            if  index < #data then
               cell:updateData(list, index,data[index+1],self._mode,2) 
            end
        end)
        self.jyList:initChildWithDataLength( 0)
    end
    local length = #self:_getData(2)
    length = length > 20 and 20 or length
    self.jyList:reloadWithLength(length)
    self:_refreshMyRank(2)
end

function WheelTopLayer:_resetJiangliListView()
    if self._initJiangli == false then
        self._initJiangli = true
        local prize = self:_getPrizeData()
        self:getLabelByName("Label_titlept"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_titlejy"):createStroke(Colors.strokeBrown, 1)
        self.ptAwardList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_awardListpt"), LISTVIEW_DIR_VERTICAL)
        self.ptAwardList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.wheel.WheelTopTxtCell").new(list, index,1)
        end)
        self.ptAwardList:setUpdateCellHandler(function ( list, index, cell)
            if  index < #prize/2 then
               cell:updateData(list, index,prize[index+1]) 
            end
        end)
        self.ptAwardList:initChildWithDataLength( #prize/2)

        self.jyAwardList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_awardListjy"), LISTVIEW_DIR_VERTICAL)
        self.jyAwardList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.wheel.WheelTopTxtCell").new(list, index,2)
        end)
        self.jyAwardList:setUpdateCellHandler(function ( list, index, cell)
            if  index < #prize/2 then
               cell:updateData(list, index,prize[index+#prize/2+1]) 
            end
        end)
        self.jyAwardList:initChildWithDataLength( #prize/2)
        self:getLabelByName("Label_awardDesc"):setText(G_lang:get("LANG_WHEEL_AWARD_DESC"))
        self:getLabelByName("Label_awardDesc"):createStroke(Colors.strokeBrown, 1)
    end
end

function WheelTopLayer:_onWheelRankRsp()
    if self._curTab == "CheckBox_putong" then
        self:_resetPutongListView()
    elseif self._curTab == "CheckBox_jingying" then
        self:_resetJingyingListView()
    elseif self._curTab == "CheckBox_jiangli" then
        self:_resetJiangliListView()
    end
end

function WheelTopLayer:_getData(_type)
    if self._mode == 1 then
        return G_Me.wheelData:getRankList(_type)
    elseif self._mode == 2 then
        return G_Me.richData:getRankList(_type)
    end
    return {}
end

function WheelTopLayer:_getPrizeData()
    local prizeList = {}
    for i = 1 , wheel_prize_info.getLength() do 
        local info = wheel_prize_info.indexOf(i)
        if info.event_type == self._mode then
            table.insert(prizeList,#prizeList+1,info)
        end
    end
    return prizeList
end

function WheelTopLayer:_refreshMyRank(_type)
    local typeStr = _type == 1 and "pt" or "jy"
    local rank,score,jyRankScore,awardRank,score100
    if self._mode == 1 then
        rank = G_Me.wheelData.myRank
        score = G_Me.wheelData.score_total
        jyRankScore = G_Me.wheelData.jyRankScore
        awardRank = G_Me.wheelData.awardRank
        score100 = G_Me.wheelData:getScore100(_type)
    elseif self._mode == 2 then
        rank = G_Me.richData.myRank
        score = G_Me.richData.score
        jyRankScore = G_Me.richData.jyRankScore
        awardRank = G_Me.richData.awardRank
        score100 = G_Me.richData:getScore100(_type)
    end
    if rank  == 0 or (_type == 2 and score < jyRankScore) then
        self:getPanelByName("Panel_my"..typeStr.."RankAward"):setVisible(false)
        self:getImageViewByName("Image_rank"..typeStr):setVisible(true)
        self:getImageViewByName("Image_rank"..typeStr):loadTexture("ui/text/txt/phb_weishangbang.png")
        self:getLabelBMFontByName("BitmapLabel_rank"..typeStr):setVisible(false)
        self:getLabelByName("Label_award"..typeStr):setVisible(false)
        self:getLabelByName("Label_norank"..typeStr):setVisible(true)
        local txt = G_lang:get("LANG_WHEEL_NORANK2",{num=awardRank,num2=awardRank,score=score100})
        if _type == 2 and score < jyRankScore then
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
        local info
        if self._mode == 1 then
            info = G_Me.wheelData:getAward(rank,_type)
        elseif self._mode == 2 then
            info = G_Me.richData:getAward(rank,_type)
        end
        if info == nil then
            return
        end
        for i = 1 , 3 do 
            if info["type_"..i] > 0 then
                local g = G_Goods.convert(info["type_"..i], info["value_"..i])
                self:getLabelByName("Label_"..typeStr.."Award"..i):setText(g.name.."  x"..GlobalFunc.ConvertNumToCharacter2(info["size_"..i]))
                self:getLabelByName("Label_"..typeStr.."Award"..i):setVisible(true)
            else
                self:getLabelByName("Label_"..typeStr.."Award"..i):setVisible(false)
            end
        end
    end
end

function WheelTopLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return WheelTopLayer
