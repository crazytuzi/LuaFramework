local TrigramsAwardPreviewCell = class("TrigramsAwardPreviewCell",function()
    return CCSItemCellBase:create("ui_layout/trigrams_AwardPreviewCell.json")
end)

require("app.cfg.eight_trigrams_info")

local FuCommon = require("app.scenes.dafuweng.FuCommon")

function TrigramsAwardPreviewCell:ctor()

    self._titleLabel = self:getLabelByName("Label_awardTitle")
    self._titleLabel:createStroke(Colors.strokeBrown, 1)

    self._bgImage  = self:getImageViewByName("Image_bg")

    self._boardImage  = self:getImageViewByName("Image_board")

    self._scrollView = self:getScrollViewByName("ScrollView_list")
 
end

function TrigramsAwardPreviewCell:updateItem(index)

    self._titleLabel:setText(G_lang:get("LANG_TRIGRAMS_AWARD_TITLE"..index))


    if index == 1 then
    	self._titleLabel:setColor(Colors.qualityColors[5])
        self._bgImage:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
        self._boardImage:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
    	self._titleLabel:setColor(Colors.qualityColors[6-index])
        self._bgImage:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self._boardImage:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
    end

    self:_updateList(index)
end



function TrigramsAwardPreviewCell:_updateList(index)
    
    self._scrollView:removeAllChildren()
    --self._scrollView:setScrollEnable(false)

    local level = FuCommon["TRIGRAMS_REWARD_LEVEL_"..index]

    --所以可能的奖励
    local allAwardList = {}

    for i = 1 , eight_trigrams_info.getLength() do 
		local info = eight_trigrams_info.indexOf(i)
		if info.level == level then
		    for t = 1, 4 do  --最多4项奖励
				local award = {}
	            if eight_trigrams_info.hasKey("award_type"..t) then
	                award.type = info["award_type"..t]
	                award.value = info["value"..t]
	                award.size = info["num"..t]
                    award.light = index == 1
	                table.insert(allAwardList, award)
	            end
			end

			break
		end
	end 
          
    local innerContainer = self._scrollView:getInnerContainer()
    local size = innerContainer:getContentSize() 
    local width = 4*(#allAwardList+1)+100*(#allAwardList) + 50
    self._scrollView:setInnerContainerSize(CCSizeMake(width,size.height))
    innerContainer:setPositionY(innerContainer:getPositionY()-5)
    GlobalFunc.createIconInPanel2({panel=innerContainer,name=true, award=allAwardList,click=true,left=true,offset=5, numType = 3})
    
end

return TrigramsAwardPreviewCell
