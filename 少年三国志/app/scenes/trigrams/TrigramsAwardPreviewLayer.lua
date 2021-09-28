local TrigramsAwardPreviewLayer = class("TrigramsAwardPreviewLayer",UFCCSModelLayer)

local TRIGRAMS_REWARD_TYPE = 3  --奖励类型 分为罕见、稀有、普通

function TrigramsAwardPreviewLayer.show(...)

    local layer = TrigramsAwardPreviewLayer.create(...)
    uf_sceneManager:getCurScene():addChild(layer) 
    layer:_adapterLayer()  

end

function TrigramsAwardPreviewLayer.create(...)
    local layer = TrigramsAwardPreviewLayer.new("ui_layout/trigrams_AwardPreview.json",Colors.modelColor,...)
    return layer
end

function TrigramsAwardPreviewLayer:_adapterLayer()
    --self:adapterWidgetHeight("","","",0,0)
    self:_initListView()
end

function TrigramsAwardPreviewLayer:ctor(json, color, callback, ...)
	
	self.super.ctor(self, json, color, ...)

    self._rewardListView = nil

    self._awardLabel = self:getLabelByName("Label_awardInfo")
    self._awardLabel:setText(G_lang:get("LANG_TRIGRAMS_AWARD_INFO"))
    self._awardLabel:createStroke(Colors.strokeBrown, 1)  
 
end


function TrigramsAwardPreviewLayer:_initListView()
    if self._rewardListView == nil then
        local panel = self:getPanelByName("Panel_list")
        self._rewardListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._rewardListView:setCreateCellHandler(function ()
            local cell = require("app.scenes.trigrams.TrigramsAwardPreviewCell").new()
            return cell
        end)

        self._rewardListView:setUpdateCellHandler(function ( list, index, cell)
            if cell then
               cell:updateItem(index+1)
            end
        end) 
    end

    self._rewardListView:initChildWithDataLength(TRIGRAMS_REWARD_TYPE)

end


function TrigramsAwardPreviewLayer:_initBtnEvent()
    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close2",function()
        self:animationToClose()
    end)
end


function TrigramsAwardPreviewLayer:onLayerLoad(...)

    self:_initBtnEvent()
    self:registerKeypadEvent(true)

end

function TrigramsAwardPreviewLayer:onLayerUnload()
    
end


function TrigramsAwardPreviewLayer:onBackKeyEvent()
    self:animationToClose()
    return true
end


function TrigramsAwardPreviewLayer:onLayerEnter()
    self:showAtCenter(true)
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return TrigramsAwardPreviewLayer

