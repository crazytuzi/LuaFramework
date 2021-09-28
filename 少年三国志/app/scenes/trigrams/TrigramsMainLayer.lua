local TrigramsMainLayer = class("TrigramsMainLayer",UFCCSNormalLayer)

require("app.cfg.wheel_info")
require("app.cfg.wheel_prize_info")

local KnightPic = require("app.scenes.common.KnightPic")
local FuCommon = require("app.scenes.dafuweng.FuCommon")
local BagConst = require("app.const.BagConst")

function TrigramsMainLayer:ctor( json, fun, scenePack, ...)

    self._timeLabel = self:getLabelByName("Label_time")
    self._timeInfoLabel = self:getLabelByName("Label_timeInfo")
    self._rankLabel = self:getLabelByName("Label_rank")
    self._rankInfoLabel = self:getLabelByName("Label_rankInfo")
    self._scoreLabel = self:getLabelByName("Label_score")
    self._scoreInfoLabel = self:getLabelByName("Label_scoreInfo")
    self._timeLabel:createStroke(Colors.strokeBrown, 1)
    self._timeInfoLabel:createStroke(Colors.strokeBrown, 1)
    self._rankLabel:createStroke(Colors.strokeBrown, 1)
    self._rankInfoLabel:createStroke(Colors.strokeBrown, 1)
    self._scoreLabel:createStroke(Colors.strokeBrown, 1)
    self._scoreInfoLabel:createStroke(Colors.strokeBrown, 1)


    --八卦阵图
    self._tianLabel = self:getLabelByName("Label_bagua1")
    self._diLabel = self:getLabelByName("Label_bagua2")
    self._renLabel = self:getLabelByName("Label_bagua3")
    self._tianLabel:createStroke(Colors.strokeBrown, 1)
    self._diLabel:createStroke(Colors.strokeBrown, 1)
    self._renLabel:createStroke(Colors.strokeBrown, 1)

    self._normalPanel = self:getPanelByName("Panel_normal")
    self._finishPanel = self:getPanelByName("Panel_finish")
    self._helpButton = self:getButtonByName("Button_help")
    

    self._normalPanel:setVisible(false)
    self._finishPanel:setVisible(false)
    self._timeStart = false

    self._rankLabel:setText("")
    self._timeLabel:setText("")
    self._scoreLabel:setText("")
    self._tianLabel:setText("")
    self._diLabel:setText("")
    self._renLabel:setText("")

    self._scoreInfoLabel:setText(G_lang:get("LANG_TRIGRAMS_SCORE"))
    self._rankInfoLabel:setText(G_lang:get("LANG_TRIGRAMS_RANK"))
    self._timeInfoLabel:setText(G_lang:get("LANG_TRIGRAMS_ACTIVITY_TIME"))

    self._wheelPage = nil   --八卦轮盘
    self._playAll = false

    self.super.ctor(self, ...)
    G_GlobalFunc.savePack(self, scenePack)

end

function TrigramsMainLayer:onBackKeyEvent()
    local packScene = G_GlobalFunc.createPackScene(self)
    if not packScene then 
        packScene = require("app.scenes.dafuweng.FuMainScene").new(FuCommon.TRIGRAMS_TYPE_ID)
    end
    uf_sceneManager:replaceScene(packScene)
    return true
end

function TrigramsMainLayer:onLayerLoad( ... )

    self:registerKeypadEvent(true)

    self:registerBtnClickEvent("Button_back", function()
        self:onBackKeyEvent()
    end)

    self:registerBtnClickEvent("Button_rank", function ( ... )
        require("app.scenes.trigrams.TrigramsRankLayer").show()
    end)

    self:registerBtnClickEvent("Button_shop", function ( ... )
        self:_onTouchShop()
    end)
    
    self:registerBtnClickEvent("Button_help", function ( ... )
        self:_onTouchHelp()
    end)

    self:registerBtnClickEvent("Button_getAward", function ( ... )
        self:_onTouchGetReward()
    end)
    
end

function TrigramsMainLayer:_onTouchShop( ... )
    --活动结束了
    if G_Me.trigramsData:getState() == FuCommon.STATE_CLOSE then
        return
    end
    require("app.const.ShopType")
    uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.TRIGRAMS))
end

function TrigramsMainLayer:_onTouchGetReward( ... )
    if G_Me.trigramsData:getState() == FuCommon.STATE_CLOSE then
        return
    end
    local top = require("app.scenes.wheel.WheelTopAward").create(FuCommon.TRIGRAMS_PRIZE_TYPE)
    uf_sceneManager:getCurScene():addChild(top)
end


function TrigramsMainLayer:_onTouchHelp( ... )
    require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_TRIGRAMS_HELPTITLE1"), content=G_lang:get("LANG_TRIGRAMS_HELP1")},
            {title=G_lang:get("LANG_TRIGRAMS_HELPTITLE2"), content=G_lang:get("LANG_TRIGRAMS_HELP2",{num=G_Me.trigramsData.jyRankScore})},
            {title=G_lang:get("LANG_TRIGRAMS_HELPTITLE3"), content=G_lang:get("LANG_TRIGRAMS_HELP3")},
            } )
end

function TrigramsMainLayer:onLayerEnter( ... )
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO, self._onGetInfoRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_REFRESH_INFO, self._onRefreshInfoRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_PLAY_RESULT, self._onPlayOneRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_PLAY_ALL_RESULT, self._onPlayAllRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_GET_REWARD, self._onGetRewardRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_RANK, self._onGetRankRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagChanged, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._onBuyResult, self)


    --初始数量
    self._old_tianNum = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.TIAN_TRIGRAM)
    self._old_diNum = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.DI_TRIGRAM)
    self._old_renNum = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.REN_TRIGRAM)
    self._old_score = G_Me.trigramsData.score


    G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()
    G_HandlersManager.trigramsHandler:sendGetRankList()
    
    -- self:_initEndPanel()
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._scheduleTimer))
    end
end

function TrigramsMainLayer:onLayerExit( ... )

    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end

    self:stopAllActions()
    uf_eventManager:removeListenerWithTarget(self)
end


function TrigramsMainLayer:updateView(  )

    local state = G_Me.trigramsData:getState()

    self:setTouchEnabled(true) 

    if state == FuCommon.STATE_OPEN then
        self._normalPanel:setVisible(true)
        self._finishPanel:setVisible(false)
        self._helpButton:setVisible(true)
        --self._itemButton:setVisible(true)
        self:_initWheelPage()
    elseif state == FuCommon.STATE_AWARD then
        self._normalPanel:setVisible(false)
        self._finishPanel:setVisible(true)
        self._helpButton:setVisible(false)
        --self._itemButton:setVisible(false)
        self:_initEndPanel()
    elseif state == FuCommon.STATE_CLOSE then 
        --应该关闭
        uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new(FuCommon.WHEEL_TYPE_ID))
        return
    end

    self:_updateScore()
    self:_updateTrigrams()
    self:_updateTime()

    --self._wheelPage:updateView()
  
end

function TrigramsMainLayer:adaptLayerView(  )
    self:adapterWidgetHeight("Panel_middle", "Panel_top", "", 0, 60)
end


function TrigramsMainLayer:_initWheelPage()
    
    if self._wheelPage == nil then
    	self._wheelPage = require("app.scenes.trigrams.TrigramsWheelPage").create()
    	self._normalPanel:addNode(self._wheelPage)
        self._wheelPage:setParent(self)
    end

    self._wheelPage:updateView()

end


function TrigramsMainLayer:_initEndPanel()

	self:_initMeiNv()

    self:getLabelByName("Label_hasAward1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_hasAward2"):createStroke(Colors.strokeBrown, 1)
    if G_Me.trigramsData:getMyRank() == 0 then
        self:getLabelByName("Label_hasAward1"):setVisible(false)
        self:getLabelByName("Label_hasAward2"):setVisible(true)
        self:getButtonByName("Button_getAward"):setVisible(false)
        self:getImageViewByName("Image_got"):setVisible(false)
    else
        self:getLabelByName("Label_hasAward1"):setVisible(true)
        self:getLabelByName("Label_hasAward2"):setVisible(false)
        -- self:getButtonByName("Button_getAward"):setVisible(true)
        if G_Me.trigramsData.got_reward then
            self:getImageViewByName("Image_got"):setVisible(true)
            self:getButtonByName("Button_getAward"):setVisible(false)
        else
            self:getImageViewByName("Image_got"):setVisible(false)
            self:getButtonByName("Button_getAward"):setVisible(true)
        end
    end
    self:getLabelByName("Label_hasAward2"):setText(G_lang:get("LANG_TRIGRAMS_END3"))

    if G_Me.trigramsData.score >= G_Me.trigramsData.jyRankScore then
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_TRIGRAMS_END1",{rank=G_Me.trigramsData:getMyRank()}))
    else
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_TRIGRAMS_END2",{rank=G_Me.trigramsData:getMyRank()}))
    end

    for i = 1 , 3 do 
        if i <= #G_Me.trigramsData.rankList then
            local info = G_Me.trigramsData.rankList[i]
            local knightBaseInfo = knight_info.get(info.main_role)
            self:getImageViewByName("Image_rank"..i):loadTexture("ui/text/txt/phb_"..i.."st.png")
            self:getLabelByName("Label_name"..i):createStroke(Colors.strokeBrown, 1)
            self:getLabelByName("Label_name"..i):setText(info.name)
            self:getLabelByName("Label_name"..i):setColor(Colors.qualityColors[knightBaseInfo.quality])
            self:getLabelByName("Label_score"..i):setText(info.sp1)
            self:getPanelByName("Panel_best"..i):setVisible(true) 
        else
            self:getPanelByName("Panel_best"..i):setVisible(false) 
        end
    end
end

function TrigramsMainLayer:_initMeiNv()
    local hero = self:getPanelByName("Panel_meizi")
    hero:removeAllChildrenWithCleanup(true)
    local GlobalConst = require("app.const.GlobalConst")
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local knight = nil
    if appstoreVersion or IS_HEXIE_VERSION  then 
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    else
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end
    if knight then
        KnightPic.createKnightPic( knight.res_id, hero, "meinv",true )
        hero:setScale(0.8)
    end
end


-- increase the score by jumping the number out
function TrigramsMainLayer:_playAddNum(labelNum, oldNum, newNum)

    labelNum:stopAllActions()

    -- create the action array
    local arr1 = CCArray:create()
    arr1:addObject(CCDelayTime:create(1.5))
    arr1:addObject(CCScaleTo:create(0.25, 2))
    arr1:addObject(CCScaleTo:create(0.25, 1))

    local scale = CCSequence:create(arr1)

    local arr2 = CCArray:create()
    arr2:addObject(CCDelayTime:create(1.5))
    arr2:addObject(CCNumberGrowupAction:create(oldNum, newNum, 0.5, function(number) 
        labelNum:setText(tostring(number))
    end))
    arr2:addObject(CCCallFunc:create(function() 
                labelNum:stopAllActions()
            end))

    local growUp = CCSequence:create(arr2)

    local act = CCSpawn:createWithTwoActions(scale, growUp)
    labelNum:runAction(act)
end


function TrigramsMainLayer:_updateScore()

	--积分
    local score = G_Me.trigramsData.score 
    if score > self._old_score then
        self:_playAddNum(self._scoreLabel, self._old_score, score)
        self._old_score = score
    else
        self._scoreLabel:setText(G_Me.trigramsData.score)
    end

    --排名
    local rank = G_Me.trigramsData:getMyRank()
    --local old_rank = G_Me.trigramsData.myOldRank

    --if rank > old_rank then
    --    self:_playAddNum(self._rankLabel, old_rank, rank)
    --else    
        self._rankLabel:setText(rank <= 0 and G_lang:get("LANG_TRIGRAMS_NORANK") or rank)
    --end
end

function TrigramsMainLayer:_updateTrigrams( )

    local tian_num = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.TIAN_TRIGRAM) 
    if tian_num > self._old_tianNum then
        self:_playAddNum(self._tianLabel, self._old_tianNum, tian_num)
        self._old_tianNum = tian_num
    else
        self._tianLabel:setText(tian_num)
    end

    local di_num = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.DI_TRIGRAM)
    if di_num > self._old_diNum then
        self:_playAddNum(self._diLabel, self._old_diNum, di_num)
        self._old_diNum = di_num
    else
        self._diLabel:setText(di_num)
    end

    local ren_num = G_Me.bagData:getPropCount(BagConst.TRIGRAMS_TYPE.REN_TRIGRAM) 
    if ren_num > self._old_renNum then
        self:_playAddNum(self._renLabel, self._old_renNum, ren_num)
        self._old_renNum = ren_num
    else
        self._renLabel:setText(ren_num)
    end

end

function TrigramsMainLayer:_updateTime( )
    local time = G_Me.trigramsData:getTimeLeft()
    local timeTitle = G_Me.trigramsData:getState() == FuCommon.STATE_OPEN and G_lang:get("LANG_TRIGRAMS_ACTIVITY_TIME") or G_lang:get("LANG_TRIGRAMS_SHOP_TIME")
    self._timeLabel:setText(G_GlobalFunc.formatTimeToHourMinSec(time))
    self._timeInfoLabel:setText(timeTitle)
end


function TrigramsMainLayer:setPlayAll(isPlayingAll)
    self._playAll = isPlayingAll or false
end

function TrigramsMainLayer:setButtonEnable(enable)
    self:getButtonByName("Button_shop"):setEnabled(enable)
    self:getButtonByName("Button_rank"):setEnabled(enable)
end

function TrigramsMainLayer:_scheduleTimer(  )

    local time = G_Me.trigramsData:getTimeLeft()

    if self._timeStart then
        self:updateView()
        self._timeStart = false
    end
    if time <= 0 then
        self._timeStart = true
        if G_Me.trigramsData:getState() == FuCommon.STATE_OPEN then
            G_HandlersManager.trigramsHandler:sendGetRankList()
        end
        if G_Me.trigramsData:getState() == FuCommon.STATE_AWARD then
            G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()
        end
    end
    self:_updateTime()
end


function TrigramsMainLayer:_onGetInfoRsp( data )
    self:updateView()  
end


function TrigramsMainLayer:_onRefreshInfoRsp( data )
    self._wheelPage:playRefreshAnimation()
end


function TrigramsMainLayer:_onBuyResult(data)
	--self:updateView() 
end

function TrigramsMainLayer:_onBagChanged(  )
    --一键抽取时延缓更新数字
    if not self._playAll then
        self:_updateTrigrams()
    end
end


function TrigramsMainLayer:_onPlayOneRsp( data )
	
	self:_updateScore()

	if rawget(data, "open_id") and rawget(data, "pos")  then
		
		local award = G_Me.trigramsData:getAwardInfo(data.pos)

		if award then

            --最后一个不能点击了
            if G_Me.trigramsData:isAllPosOpen() then
			    self._wheelPage:setTouchEnabled(false)
                self:setTouchEnabled(false)
            end

			local awardList = {}
			table.insert(awardList,award)

			local awardLevel = G_Me.trigramsData:getAwardLevel(data.pos)

			--把获得的挂阵也加进去
			local itemId = BagConst.TRIGRAMS_TYPE.REN_TRIGRAM + 1 - awardLevel

	    	local bagua = {type=3, value=itemId, size=1, light = awardLevel== FuCommon.TRIGRAMS_BORDER_MAX}
	    	table.insert(awardList,#awardList+1, bagua)

			--先播放打开挂盘动作
			--self:getImageViewByName("Image_bagua
			self._wheelPage:playOpenOneAnimation(award, awardLevel, data.pos, bagua, self:getLabelByName("Label_bagua"..(FuCommon.TRIGRAMS_BORDER_MAX+1-awardLevel)))

			--迟点显示掉落物品
			local actions = {}
			table.insert(actions, CCDelayTime:create(FuCommon.MOVE_TIME*3))

		    table.insert(actions, CCCallFunc:create(function() 
		        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awardList, function ()
					
					if rawget(data, "new_trigram_info") then
                        G_Me.trigramsData:updateTrigram(data.new_trigram_info)
			        	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_REFRESH_INFO, nil, false, decodeBuffer)
			        end

				end, G_lang:get("LANG_TRIGRAMS_AWARD_GET"..awardLevel))
            	uf_sceneManager:getCurScene():addChild(_layer)
		    end))

    		local sequence = transition.sequence(actions)

			self:runAction(sequence)
	
		end

	end

end


function TrigramsMainLayer:_onPlayAllRsp( data )
	
    self:setPlayAll(false)

    self:setTouchEnabled(false)
    self._wheelPage:setTouchEnabled(false) 

	local getAwardAll = require("app.scenes.trigrams.TrigramsAllAwards").create(
		function( ... )
			self:_updateScore()
			self:_updateTrigrams()
 			self:_updateTime()
			self._wheelPage:playRefreshAnimation()
		end)
    uf_sceneManager:getCurScene():addChild(getAwardAll)


end


function TrigramsMainLayer:_onGetRewardRsp( data)
    
    if data and type(data) == "table" then
	    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
	    uf_sceneManager:getCurScene():addChild(_layer,1000)
	    self:updateView()
	end

end

function TrigramsMainLayer:_onGetRankRsp(data  )
    self:updateView()
    
end



return TrigramsMainLayer

