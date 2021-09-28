local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local function _updateImageView(target, name, params)
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end 
end

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)
        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)
    end
    
    if align == ALIGN_CENTER then
        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])
        end       
    elseif align == ALIGN_LEFT then       
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])
        end
    elseif align == ALIGN_RIGHT then
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])
        end
    else
        assert(false, "Now we don't support other align type :"..align)
    end
end

local EffectNode = require "app.common.effects.EffectNode"

local RiotHeadToken = class("RiotHeadToken",function ()
    return CCSItemCellBase:create("ui_layout/dungeon_Hard_DungeonRiotHeadToken.json")
end)


function RiotHeadToken:ctor(tRiotChapter, clickCallback)
	self._tRiotChapter = tRiotChapter
	self._clickCallback = clickCallback
	self._tRiotDungeomTmpl = hard_dungeon_roit_info.get(self._tRiotChapter._nRiotId)

	self:_initWidgets()
end

function RiotHeadToken:_initWidgets()
	-- icon
    local nResId = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.image) and self._tRiotDungeomTmpl.image or 14016
    _updateImageView(self, "Image_Icon", {texture=G_Path.getKnightIcon(nResId)})
    -- 敌方援军名字
    local nQuality = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.quality) and self._tRiotDungeomTmpl.quality or 1
    local szKnightName = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.name) and self._tRiotDungeomTmpl.name or ""
    _updateLabel(self, "Label_RiotKnightName", {text=szKnightName, stroke=Colors.strokeBrown, color=Colors.qualityColors[nQuality]})
    -- 来援
    _updateLabel(self, "Label_Come", {text=G_lang:get("LANG_HARD_RIOT_RESCUE"), stroke=Colors.strokeBrown})

    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_RiotKnightName'),
        self:getLabelByName('Label_Come'),
    }, ALIGN_CENTER)
    self:getLabelByName('Label_RiotKnightName'):setPosition(alignFunc(1))
    self:getLabelByName('Label_Come'):setPosition(alignFunc(2))

    self:showWidgetByName("Image_Bg", false)
    local tSize = self:getSize()
    self.eff = EffectNode.new("effect_hitme", nil, nil, nil, function (sprite, png, key) 
            if string.find(key, "var_card_") == 1  then
                if sprite == nil then
                    local knight = CCSprite:create( G_Path.getKnightIcon(nResId) )
                    return true, knight
                else
                    return true, sprite     
                end
               
            end
            return false
        end)
    self.eff:setPosition(ccp(tSize.width/2 - 5, tSize.height/2 + 10))
    self.eff:play()
    self:addChild(self.eff)

    self:registerWidgetTouchEvent("Panel_Click", handler(self, self._onClickToken))
end

function RiotHeadToken:_onClickToken(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if self._clickCallback then
			self._clickCallback()
		end
		local nChapterId = self._tRiotChapter._nChapterId or 1
		G_Me.hardDungeonData:setShowRiotGateLayer(true)
		G_Me.hardDungeonData:setCurrChapterId(nChapterId)
        uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonGateScene").new())
        -- 做一个标记
        G_Me.hardDungeonData:setEnterFlag(true)
	end
end

		
return RiotHeadToken