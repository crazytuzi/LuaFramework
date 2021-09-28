
local TrigramsAllAwards = class("TrigramsAllAwards", UFCCSModelLayer)

require("app.cfg.item_info")

local BagConst = require("app.const.BagConst")

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local FuCommon = require("app.scenes.dafuweng.FuCommon")

function TrigramsAllAwards:ctor(json, color, callback, ...)
    self.super.ctor(self, json, color,...)
    self:showAtCenter(true)

    self._callback = callback

    self._listPanel = self:getPanelByName("Panel_list")
    self._scrollView = self:getScrollViewByName("ScrollView_list")
    self:getLabelByName("Label_desc"):setText(G_lang:get("LANG_TRIGRAMS_ALLAWARD_INFO"))

    self:registerBtnClickEvent("Button_close", function()
    	self:animationToClose()
        if self._callback then
            self._callback()
        end       
    end)
end

function TrigramsAllAwards.create(callback, ...)
    local layer = TrigramsAllAwards.new("ui_layout/trigrams_AllAwards.json",Colors.modelColor, callback, ...) 
    return layer
end

function TrigramsAllAwards:onLayerEnter()
    EffectSingleMoving.run(self, "smoving_bounce")

    self:_initAwardlist()
end




function TrigramsAllAwards:_createAwardList( ... )
	
    local awardList = G_Me.trigramsData:getAwardList()
    local levelList = G_Me.trigramsData:getLevelList()

    local temp = {}

    for i = 1 , #awardList do
        local good = G_Goods.convert(awardList[i].type,awardList[i].value)
    	local award = {type=good.type, value = good.value, size = awardList[i].size, quality = good.quality, level=levelList[i]}
        if i <= #levelList and  levelList[i] == FuCommon.TRIGRAMS_REWARD_LEVEL_1 then 
            award.light = true
         else
            award.light = false
        end
    	table.insert(temp,#temp+1, award)
    end


    local trigramsNum = {0, 0, 0}  --分别表示蓝 紫 橙挂盘数量
    --先计算各种挂盘数量
    for i = 1 , #awardList do
        if i <= #levelList then
        	local level = levelList[i]
        	if level == FuCommon.TRIGRAMS_REWARD_LEVEL_1 then
        		trigramsNum[3] = trigramsNum[3] + 1
        	elseif level == FuCommon.TRIGRAMS_REWARD_LEVEL_2 then
        		trigramsNum[2] = trigramsNum[2] + 1
        	else
        		trigramsNum[1] = trigramsNum[1] + 1
        	end
        end
    end

    --加上阵图道具
    for i = 1 , FuCommon.TRIGRAMS_BORDER_MAX do
    	if trigramsNum[i] > 0 then
    		local itemId = BagConst.TRIGRAMS_TYPE.REN_TRIGRAM + 1 - i
            local good = G_Goods.convert(3,itemId)
    		local award = {type=good.type, value=good.value, size=trigramsNum[i], quality = good.quality, level = i, light= (i ==3)}
    		table.insert(temp,#temp+1, award)
    	end
    end

    local sortFunc = function ( a, b )

        if a.quality ~= b.quality then
            return a.quality > b.quality
        elseif a.level ~= b.level then
            return a.level > b.level
        else
            return a.size > b.size
        end
    end


    table.sort(temp, sortFunc)


    awardList = {}

    for k , v in pairs(temp) do 
        table.insert(awardList,#awardList+1,{type=v.type,value=v.value,size=v.size,light=v.light})
    end

    return awardList

end

function TrigramsAllAwards:_initAwardlist()
    
    local awardList = self:_createAwardList()

    local count = #awardList
    local height = math.floor((count-1)/4)+1
    height = height * 155 + (height-1)*10

    local size = self._scrollView:getContentSize()
    if height > size.height then
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,0)
        self._scrollView:setTouchEnabled(true)
    else
        self._scrollView:setInnerContainerSize(CCSizeMake(size.width,size.height))
        self._listPanel:setSize(CCSizeMake(size.width,height))
        self._listPanel:setPositionXY(0,size.height-height)
        self._scrollView:setTouchEnabled(false)
    end
    GlobalFunc.createIconInPanel({panel=self._listPanel,award=awardList,click=true,name=true,offset=5,maxX=4, numType = 3})
end


return TrigramsAllAwards

