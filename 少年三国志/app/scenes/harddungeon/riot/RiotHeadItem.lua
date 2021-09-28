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


local RiotHeadItem = class("RiotHeadItem",function ()
    return CCSItemCellBase:create("ui_layout/dungeon_Hard_DungeonRiotHeadItem.json")
end)

function RiotHeadItem:ctor(tRiotChapter)
	self._tRiotChapter = tRiotChapter

	self._tChapterTmpl = hard_dungeon_chapter_info.get(self._tRiotChapter._nChapterId)
	self._tRiotDungeomTmpl = hard_dungeon_roit_info.get(self._tRiotChapter._nRiotId)

	self:_initWidgets()
end

function RiotHeadItem:_initWidgets()
	local szChapterName = (self._tChapterTmpl and self._tChapterTmpl.name) and self._tChapterTmpl.name or ""
	local nChapterId = self._tRiotChapter._nChapterId or 1
	local szKnightName = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.name) and self._tRiotDungeomTmpl.name or ""
	local nQuality = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.quality) and self._tRiotDungeomTmpl.quality or 1

	_updateLabel(self, "Label_ChapterId", {text=G_lang:get("LANG_HARD_RIOT_CHAPTER_NUM", {num=nChapterId}), stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_ChapterName", {text=szChapterName, stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_RiotKinghtName", {text=szKnightName, color=Colors.qualityColors[nQuality], stroke=Colors.strokeBrown})
	_updateLabel(self, "Label_Rescue", {text=G_lang:get("LANG_HARD_RIOT_RESCUE"), stroke=Colors.strokeBrown})
	_updateImageView(self, "ImageView_Frame", {texture=G_Path.getEquipColorImage(nQuality), texType=UI_TEX_TYPE_PLIST})

	local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_RiotKinghtName'),
        self:getLabelByName('Label_Rescue'),
    }, ALIGN_CENTER)
    self:getLabelByName('Label_RiotKinghtName'):setPosition(alignFunc(1))
    self:getLabelByName('Label_Rescue'):setPosition(alignFunc(2))

    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_ChapterId'),
    }, ALIGN_CENTER)
    self:getLabelByName('Label_ChapterId'):setPosition(alignFunc(1))
    
    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_ChapterName'),
    }, ALIGN_CENTER)
    self:getLabelByName('Label_ChapterName'):setPosition(alignFunc(1))

    -- icon
    local nResId = (self._tRiotDungeomTmpl and self._tRiotDungeomTmpl.image) and self._tRiotDungeomTmpl.image or 14016
    _updateImageView(self, "ImageView_Icon", {texture=G_Path.getKnightIcon(nResId)})
    -- 是否被击杀
    local isKilled = self._tRiotChapter._isFinished
    self:showWidgetByName("Image_Killed", isKilled)
    self:getImageViewByName("ImageView_Icon"):showAsGray(isKilled)
    self:getImageViewByName("ImageView_Frame"):showAsGray(isKilled)
    self:registerWidgetTouchEvent("ImageView_Frame", handler(self, self._onClickItem))
end

function RiotHeadItem:_onClickItem(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local isKilled = self._tRiotChapter._isFinished
		if not isKilled then
			-- 记录进入的章节id
			local nChapterId = self._tRiotChapter._nChapterId or 1
			G_Me.hardDungeonData:setShowRiotGateLayer(true)
			G_Me.hardDungeonData:setCurrChapterId(nChapterId)
	        uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonGateScene").new())
            -- 标记一下，
            G_Me.hardDungeonData:setEnterFlag(true)
	    else
	    	G_MovingTip:showMovingTip(G_lang:get("LANG_HARD_RIOT_ENEMY_ALREADY_KILLED"))
	    end
    end
end


return RiotHeadItem