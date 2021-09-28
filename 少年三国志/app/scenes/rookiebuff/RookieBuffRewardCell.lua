local RookieBuffRewardCell = class("RookieBuffRewardCell",function()
    return CCSItemCellBase:create("ui_layout/rookiebuff_RewardCell.json")
end)

require("app.cfg.rookie_reward_info")

local RookieBuffAwardItemMax = 5  --单条奖励最大物品数


function RookieBuffRewardCell:ctor()

    self._titleLabel = self:getLabelByName("Label_levelDesc")
    self._titleLabel:createStroke(Colors.strokeBrown, 1)
    self._getButton = self:getButtonByName("Button_get")
    self._gotImg = self:getImageViewByName("Image_got")
    self._scrollView = self:getScrollViewByName("ScrollView_list")
    self._notYetImg = self:getImageViewByName("Image_notyet")
  
    self._awardInfo = nil
    
end

function RookieBuffRewardCell:updateItem(award,func)

    self._gotImg:setVisible(false)
    self._notYetImg:setVisible(false)
    self._getButton:setVisible(false)
    self._getButton:setEnabled(true)

    self._titleLabel:setText("")
    self._scrollView:removeAllChildren()

    self._awardInfo = award

    if not self._awardInfo then
        return
    end

    self._titleLabel:setText(G_lang:get("LANG_ROOKIE_BUFF_LEVEL_DESC",{level=self._awardInfo.level}))

    if G_Me.rookieBuffData:hasGetAward(self._awardInfo) then
        self._gotImg:setVisible(true)
    elseif G_Me.rookieBuffData:isAwardNotReached(self._awardInfo) then
        self._notYetImg:setVisible(true)
    elseif G_Me.rookieBuffData:canGetAward(self._awardInfo) then
        self._getButton:setVisible(true)
    end

    self:registerBtnClickEvent("Button_get", function()
        if G_Me.rookieBuffData:canGetAward(self._awardInfo) then
            if func then
                func(self._awardInfo)
                self._getButton:setEnabled(false)
                G_HandlersManager.rookieBuffHandler:sendGetRookieReward(self._awardInfo.id)
            end
        end
    end)

    self:_updateList()
end



function RookieBuffRewardCell:_updateList()
    
    local innerContainer = self._scrollView:getInnerContainer()
    local size = innerContainer:getContentSize()

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
           
        local width = 3*(#awardList+1)+100*(#awardList)
        self._scrollView:setInnerContainerSize(CCSizeMake(width,size.height))
        GlobalFunc.createIconInPanel({panel=innerContainer,award=awardList,click=true,left=true,offset=5})
    end
end

return RookieBuffRewardCell
