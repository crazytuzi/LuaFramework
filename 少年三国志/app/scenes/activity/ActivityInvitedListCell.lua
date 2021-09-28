local ActivityInvitedListCell = class("ActivityInvitedListCell",function()
    return CCSItemCellBase:create("ui_layout/activity_ActivityInvitedListItem.json")
end)

require("app.cfg.spread_reward_info")

local Goods = require("app.setting.Goods")

function ActivityInvitedListCell:ctor()
    -- self._descLabel = self:getLabelByName("Label_desc")
    self._timesDescLabel = self:getLabelByName("Label_timesDes")
    self._timesValueLabel = self:getLabelByName("Label_timesValue")
    self._inputLabel = self:getLabelByName("Label_input")
    self._listPanel = self:getPanelByName("Panel_list")
    self._getButton = self:getButtonByName("Button_get")
    self._inputButton = self:getButtonByName("Button_input")
    self._gotImg = self:getImageViewByName("Image_got")
    self._iconList = nil

    self:attachImageTextForBtn("Button_get","Image_9")
    self:initRichTxt()

    local EffectNode = require "app.common.effects.EffectNode"
    self.node = EffectNode.new("effect_around2")     
    self.node:setScale(1.4) 
    self._getButton:addNode(self.node)
    self.node:setVisible(false)
    self.node:play()

    self:registerBtnClickEvent("Button_get", function()
        G_HandlersManager.activityHandler:sendInvitedDrawReward(self._data.id)
    end)
    self:registerBtnClickEvent("Button_input", function()
        local gold = require("app.scenes.activity.ActivityInvitorGetID").create()
        uf_sceneManager:getCurScene():addChild(gold)
    end)
end

function ActivityInvitedListCell:initRichTxt()
        local label = self:getLabelByName("Label_title")
        if label then 
            local size = label:getSize()
            self._inputRichText = CCSRichText:create(size.width*2, size.height*2)
            self._inputRichText:setFontSize(label:getFontSize())
            self._inputRichText:setFontName(label:getFontName())
            local color = label:getColor()
            self._defaultColor = ccc3(color.r, color.g, color.b)
            self._inputRichText:setColor(self._defaultColor)
            self._inputRichText:setShowTextFromTop(true)
            local posx,posy = label:getPosition()
            self._inputRichText:setAnchorPoint(ccp(0,0.5))
            self._inputRichText:setPosition(ccp(posx-10,posy+3))
            label:getParent():addChild(self._inputRichText)
            label:setVisible(false)
    end
end

function ActivityInvitedListCell:updateData(data)
    self._data = data
    self:updateList()

    local str = ""

    if data.type == "2" then
        --填写id
        if G_Me.activityData.invited.hasBind then
            self._getButton:setVisible(true)
            self.node:setVisible(true)
            self._inputButton:setVisible(false)
            self._gotImg:setVisible(false)
            self._inputLabel:setVisible(false)
            str = G_lang:get("LANG_ACTIVITY_INVITED_SHARED")
        else
            self._getButton:setVisible(false)
            self.node:setVisible(false)
            self._inputButton:setVisible(true)
            self._gotImg:setVisible(false)
            self._inputLabel:setVisible(true)
            str = G_lang:get("LANG_ACTIVITY_INVITED_SHARE",{level=data.level})
        end
    else
        if G_Me.activityData.invited:hasGot(data.id) then
            self._getButton:setVisible(false)
            self.node:setVisible(false)
            self._gotImg:setVisible(true)
        else
            self._getButton:setVisible(true)
            self._gotImg:setVisible(false)
            self._getButton:setTouchEnabled(G_Me.userData.level>=data.level)
            self.node:setVisible(G_Me.userData.level>=data.level)
        end
        self._inputButton:setVisible(false)
        self._inputLabel:setVisible(false)
        str = G_lang:get("LANG_ACTIVITY_INVITED_LEVEL",{level=data.level})
    end

    self:_updateRichText(str)
end

function ActivityInvitedListCell:_updateRichText( txt )
    if self._inputRichText then 
        self._inputRichText:clearRichElement()
        self._inputRichText:appendContent(txt, self._defaultColor)
        self._inputRichText:reloadData()
    end
end

function ActivityInvitedListCell:updateList()
    local award = {}
    for i = 1 , 4 do 
            table.insert(award,#award+1,{type=self._data["item_type"..i],value=self._data["item_value"..i],size=self._data["item_size"..i]})
    end

    if not self._iconList then
        self._iconList = GlobalFunc.createIconInPanel({panel=self._listPanel,award=award,click=true,left=true,offset=1})
    else
        GlobalFunc.refreshIcon({iconList=self._iconList,award=award})
    end
    
end

return ActivityInvitedListCell
