local ActivityInvitorListCell = class("ActivityInvitorListCell",function()
    return CCSItemCellBase:create("ui_layout/activity_ActivityInvitorListItem.json")
end)

require("app.cfg.spread_reward_info")

local Goods = require("app.setting.Goods")

function ActivityInvitorListCell:ctor()
    -- self._descLabel = self:getLabelByName("Label_desc")
    self._timesDescLabel = self:getLabelByName("Label_timesDes")
    self._timesValueLabel = self:getLabelByName("Label_timesValue")
    self._listPanel = self:getPanelByName("Panel_list")
    self._getButton = self:getButtonByName("Button_get")
    self._gotImg = self:getImageViewByName("Image_got")
    self._iconList = nil

    self._gotImg:setVisible(false)
    self:attachImageTextForBtn("Button_get","Image_9")

    self._timesDescLabel:setText(G_lang:get("LANG_ACTIVITY_INVITOR_GET")) 

    local EffectNode = require "app.common.effects.EffectNode"
    self.node = EffectNode.new("effect_around2")     
    self.node:setScale(1.4) 
    self._getButton:addNode(self.node)
    self.node:setVisible(false)
    self.node:play()

    self:initRichTxt()

    self:registerBtnClickEvent("Button_get", function()
        local info = self._data.can_reward[1]
        G_HandlersManager.activityHandler:sendInvitorDrawLvlReward(self._data.reward_id,info.invited_id,info.invited_sid,info.invited_name,info.invited_qua)
    end)
end

function ActivityInvitorListCell:initRichTxt()
        local label = self:getLabelByName("Label_desc")
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
            self._inputRichText:setPosition(ccp(posx-15,posy+3))
            label:getParent():addChild(self._inputRichText)
            label:setVisible(false)
    end
end

function ActivityInvitorListCell:updateData(data)
    self._data = data
    self._info = data.info
    local hero = self._data.can_reward[1]
    self:updateList()

    local str = ""
    local left = #data.has_reward
    -- local total = #data.can_reward + left
    self._timesValueLabel:setText(left.."/"..data.info.time)
    if #data.can_reward > 0 then
        self._getButton:setTouchEnabled(true)
        self.node:setVisible(true)
        str = G_lang:get("LANG_ACTIVITY_INVITOR_FRIEND",{name=hero.invited_name,color=Colors.qualityDecColors[hero.invited_qua],fight=GlobalFunc.ConvertNumToCharacter2(data.info.power)})
    else
        self._getButton:setTouchEnabled(false)
        self.node:setVisible(false)
        str = G_lang:get("LANG_ACTIVITY_INVITOR_FIGHT",{fight=GlobalFunc.ConvertNumToCharacter2(data.info.power)})
    end
    self:_updateRichText(str)
end

function ActivityInvitorListCell:_updateRichText( txt )
    if self._inputRichText then 
        self._inputRichText:clearRichElement()
        self._inputRichText:appendContent(txt, self._defaultColor)
        self._inputRichText:reloadData()
    end
end

function ActivityInvitorListCell:updateList()
    local award = {}
    for i = 1 , 4 do 
        table.insert(award,#award+1,{type=self._info["item_type"..i],value=self._info["item_value"..i],size=self._info["item_size"..i]})
    end
    if not self._iconList then
        self._iconList = GlobalFunc.createIconInPanel({panel=self._listPanel,award=award,click=true,left=true,offset=1})
    else
        GlobalFunc.refreshIcon({iconList=self._iconList,award=award})
    end
end

return ActivityInvitorListCell
