local RichScoreAward = class("RichScoreAward",UFCCSModelLayer)
require("app.cfg.richman_prize_info")

function RichScoreAward.create(...)
    local layer = RichScoreAward.new("ui_layout/dafuweng_Award.json",Colors.modelColor,...)
    return layer
end

function RichScoreAward:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self._list = nil
    self._awardList = nil
    self._noteLabel = self:getLabelByName("Label_listnote")
    self._noteLabel:createStroke(Colors.strokeBrown, 1)
    self:refreshAwardList()
    self:_initListView()

    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close02",function()
        self:animationToClose()
    end)
end

function RichScoreAward:updateView()
    self._noteLabel:setText(G_lang:get("LANG_FU_LOOPTOTAL",{loop=G_Me.richData:getLoop()}))
end

function RichScoreAward:_initListView()
    if self._list == nil then
        local panel = self:getPanelByName("Panel_awardList")
        self._list = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._list:setCreateCellHandler(function ()
            local cell = require("app.scenes.dafuweng.RichScoreAwardItem").new()
            return cell
        end)
        self._list:setUpdateCellHandler(function ( list, index, cell)
            if index < richman_prize_info.getLength() then
                local data = self:getAwardList()[index+1]
                cell:updateItem(data)
                cell:setOnClick(function()
                    if data == nil or G_Me.richData:getLoop() == nil  then
                        return
                    end
                    if G_Me.richData:gotRoundReward(data.id) == true then --已领取
                        return
                    end
                    if G_Me.richData:getLoop() < data.turn then   --未达成
                        return
                    end
                    G_HandlersManager.richHandler:sendRichReward(1,data.id)
                end)
            end
        end)
        self._list:initChildWithDataLength(richman_prize_info.getLength())
    end
end

function RichScoreAward:_initBtnEvent()
    self:enableAudioEffectByName("Button_close", false)
    self:enableAudioEffectByName("Button_close02", false)

end

function RichScoreAward:_getAward(data)
    if data.ret == 1 and data.type == 1 then
        local info = richman_prize_info.get(data.id)
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({info})
        uf_sceneManager:getCurScene():addChild(_layer)
        self:refreshAwardList()
        self._list:refreshAllCell()
    end
end

function RichScoreAward:getAwardList()
    return self._awardList
end

function RichScoreAward:refreshAwardList()
    local sortFunc = function(a,b)
        if G_Me.richData:gotRoundReward(a.id) then
            return false
        end
        if G_Me.richData:gotRoundReward(b.id) then
            return true
        end
        return a.id < b.id
    end
    self._awardList = {}
    for i = 1 , richman_prize_info.getLength() do 
        table.insert(self._awardList,#self._awardList+1,richman_prize_info.get(i))
    end
    table.sort(self._awardList,sortFunc)
end

function RichScoreAward:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function RichScoreAward:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

    uf_eventManager:addEventListener(EventMsgID.EVENT_RICH_REWARD, self._getAward, self)
    self:updateView()
end

return RichScoreAward

