local RookieBuffMainLayer = class("RookieBuffMainLayer",UFCCSModelLayer)


require("app.cfg.rookie_reward_info")

local RookieBuffAwardItemMax = 5  --单条奖励最大物品数


function RookieBuffMainLayer.show(...)

    local layer = RookieBuffMainLayer.create(...)
    uf_sceneManager:getCurScene():addChild(layer) 
    layer:_adapterLayer()  

end

function RookieBuffMainLayer.create(...)
    local layer = RookieBuffMainLayer.new("ui_layout/rookiebuff_MainLayer.json",Colors.modelColor,...)
    --layer:adapterLayer()
    return layer
end

function RookieBuffMainLayer:_adapterLayer()
    self:adapterWidgetHeight("","","",0,0)

    self:_initRewardList()
end

function RookieBuffMainLayer:ctor(...)
    self._rewardListView = nil
    self._rewardListData = {}
    self.super.ctor(self,...)
    
    self._awardInfo = nil


    self:_initWidgets()
 
end

function RookieBuffMainLayer:_initWidgets()
 
    local label = self:getLabelByName("Label_rookieInfo")
    label:setVisible(false)
      

    local size = label:getSize()
    local clr = label:getColor()
    self._labelClr = ccc3(clr.r, clr.g, clr.b)
    self._richText = CCSRichText:create(size.width, size.height)
    self._richText:setFontName(label:getFontName())
    self._richText:setFontSize(22)
    local x, y = label:getPosition()
    self._richText:setPosition(ccp(x+6, y + 2))
    self._richText:setShowTextFromTop(true)
    local parent = label:getParent()
    if parent then
        parent:addChild(self._richText, 5)
    end

    self._richText:enableStroke(Colors.strokeBrown)  


end

function RookieBuffMainLayer:_initListView()
    if self._rewardListView == nil then
        local panel = self:getPanelByName("Panel_list")
        self._rewardListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._rewardListView:setCreateCellHandler(function ()
            local cell = require("app.scenes.rookiebuff.RookieBuffRewardCell").new()
            return cell
        end)
        self._rewardListView:setUpdateCellHandler(function ( list, index, cell)
            if cell and index < #self._rewardListData then
               cell:updateItem(self._rewardListData[index+1],function (_award)
                    self._awardInfo = _award
               end) 
            end
        end) 
    end
end


function RookieBuffMainLayer:_initBtnEvent()
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    
end

function RookieBuffMainLayer:_initRewardList()
 
    if not G_Me.rookieBuffData:dataReady() or not G_Me.rookieBuffData:showReward() then
        return
    end


    local buffInfo = G_Me.rookieBuffData:getBuffInfo()

    if not buffInfo then
        return
    end

    local dayStr = ""
    if G_Me.rookieBuffData:getCreateDay() == 2 then
        dayStr = G_lang:get("LANG_ROOKIE_BUFF_FIRST_DAY")
    else
        dayStr = G_lang:get("LANG_ROOKIE_BUFF_SECOND_DAY")
    end

    local text = G_lang:get("LANG_ROOKIE_BUFF_INFO_DESC", 
            {create_day = GlobalFunc.numberToChinese(G_Me.rookieBuffData:getCreateDay()), 
            level_min = buffInfo.open_level, 
            level_max = buffInfo.close_level, 
            buff_value = buffInfo.buff,
            berofe_day = dayStr
            })

    self._richText:clearRichElement()
    self._richText:appendContent(text, self._labelClr)
    self._richText:reloadData()


    for k, v in pairs(G_Me.rookieBuffData:getAwardlist()) do
        table.insert(self._rewardListData, v)
    end
    
    self:_sortRewardListData()
    self:_initListView()
    self._rewardListView:initChildWithDataLength(#self._rewardListData)

    --TEST
    --GlobalFunc.flyIntoScreenLR({self._rewardListView}, true, 0.2, 2, 50)

end


function RookieBuffMainLayer:_getAward(data)

    if self._awardInfo ~= nil then
        local awardList = {}
        for i=1, RookieBuffAwardItemMax do
            local award = {}
            if rookie_reward_info.hasKey("type_"..i) then
                award.type = self._awardInfo["type_"..i]
                award.value = self._awardInfo["value_"..i]
                award.size = self._awardInfo["size_"..i]
                table.insert(awardList, award)
            end
        end
        
        if #awardList > 0 then
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awardList)
            uf_sceneManager:getCurScene():addChild(_layer,1000)
        end

    end

    self:_sortRewardListData()
    self._rewardListView:reloadWithLength(#self._rewardListData,self._rewardListView:getShowStart())
    self._awardInfo = nil

end

--奖励排序
function RookieBuffMainLayer:_sortRewardListData()
    if self._rewardListData == nil or #self._rewardListData < 2 then
        return
    end

    local sortFunc = function(a,b)
        
        if G_Me.rookieBuffData:canGetAward(a) ~= G_Me.rookieBuffData:canGetAward(b) then
            local A = G_Me.rookieBuffData:canGetAward(a) and 1 or 0
            local B = G_Me.rookieBuffData:canGetAward(b) and 1 or 0
            return A > B
        elseif G_Me.rookieBuffData:hasGetAward(a) ~= G_Me.rookieBuffData:hasGetAward(b) then
            local C = G_Me.rookieBuffData:hasGetAward(c) and 1 or 0
            local D = G_Me.rookieBuffData:hasGetAward(b) and 1 or 0
            return C < D
        end
        --表顺序有问题，只能这样了
        if (a.id == 6 or b.id == 6) then
            local A = (a.id == 6) and 1 or 0
            local B = (b.id == 6) and 1 or 0
            return A > B
        end
        return a.id < b.id
    end

    table.sort(self._rewardListData,sortFunc)
end

function RookieBuffMainLayer:onLayerLoad(...)

    uf_eventManager:addEventListener(EventMsgID.EVENT_ROOKIE_GET_REWARD, self._getAward, self)

    self:_initBtnEvent()

    self:registerKeypadEvent(true)

end

function RookieBuffMainLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end


function RookieBuffMainLayer:onBackKeyEvent()
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end


function RookieBuffMainLayer:onLayerEnter()
    self:showAtCenter(true)
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return RookieBuffMainLayer

