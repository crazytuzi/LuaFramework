-- Filename: HeroSoulLayer.lua
-- Author: fang
-- Date: 2013-07-26
-- Purpose: 该文件用于: 武将系统中武魂系统

module("HeroSoulLayer", package.seeall)

-- 武魂数据项
local _soul_items

-- GetLocalizeStringBy("key_1307")按钮起始tag
local _ksTagRecruitBegin=1001
-- 头像按钮起始tag
local _ksTagHeadBegin=2001
-- 菜单起始tag
local _ksTagMenuBegin=3001
-- 未收集精灵图片的tag
local _ksTagInsufficient=4001
-- 所有武将碎片
local _allHeroFragments
-- 网络回调flag
local _sOnNetworkFlagRecruit
-- 当前内容区高度
local _scrollview_height
-- 当前层父节点
local _ccLayerParent
-- 当前TableView对象
local _ccObjCurrentTableView

local function fnRefreshAfterRecruit ()
	local lastOffset = _ccObjCurrentTableView:getContentOffset()
	_ccObjCurrentTableView:removeFromParentAndCleanup(true)
	_ccObjCurrentTableView = createTableView(_ccLayerParent, _scrollview_height)
	if lastOffset.y < _ccObjCurrentTableView:getViewSize().height - _ccObjCurrentTableView:getContentSize().height  then
		lastOffset = ccp(0, _ccObjCurrentTableView:getViewSize().height - _ccObjCurrentTableView:getContentSize().height)
	end
	_ccObjCurrentTableView:setContentOffset(lastOffset)

	require "script/ui/hero/HeroLayer"
	HeroLayer.setSoulTableView(_ccObjCurrentTableView)
	_ccObjCurrentTableView:ignoreAnchorPointForPosition(false)
    _ccObjCurrentTableView:setAnchorPoint(ccp(0.5,0))
    _ccObjCurrentTableView:setPosition(_ccLayerParent:getContentSize().width*0.5,10*g_fScaleX)
	_ccLayerParent:addChild(_ccObjCurrentTableView)
end

-- 当前格子id
local _current_gid
--
local _itemNumAfterRecruit

-- 招募武将网络回调处理
local function fnHandlerOfNetworkRecruit(cbName, dictData, bRet)
	if not bRet then
		return
	end
	if cbName == _sOnNetworkFlagRecruit then
		if _itemNumAfterRecruit == 0 then
			DataCache.delHeroFragOfGid(_current_gid)
		else
			DataCache.setHeroFragItemNumOfGid(_current_gid, _itemNumAfterRecruit)
		end
		-- 招募后刷新界面信息
		fnRefreshAfterRecruit()
		--刷新可合成红色提示
		require "script/ui/hero/HeroLayer"
		HeroLayer.refreshTitleTipNum()
		--提示
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1918"))

	end
end
-- GetLocalizeStringBy("key_1307")按钮事件回调处理
local function fnHandlerOfRecruitButtons(tag, obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/model/hero/HeroModel"
    require "script/ui/hero/HeroPublicUI"
	if HeroPublicUI.showHeroIsLimitedUI() then
		return
	end
	local value = _allHeroFragments[tag-_ksTagRecruitBegin]

	local maxNum = math.floor(value.item_num/value.need_part_num)

	if( maxNum < 2 )then
		require "script/network/RequestCenter"
		local args = Network.argsHandler(value.gid, value.item_id, value.need_part_num,1,1)
		_sOnNetworkFlagRecruit = RequestCenter.bag_useItem(fnHandlerOfNetworkRecruit, args)
		_current_gid = value.gid
		_itemNumAfterRecruit = value.item_num - value.need_part_num
	else
		require "script/utils/SelectNumDialog"
	    local dialog = SelectNumDialog:create()
	    dialog:setTitle(GetLocalizeStringBy("lic_1815"))
	    dialog:show(-500, 1010)
	    dialog:setMinNum(1)
	    dialog:setLimitNum(maxNum)

	    -- 请选择招募xx个数
	    local textInfo = {
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultColor = ccc3(0xff,0xff,0xff),  -- 默认字体颜色
	        labelDefaultSize = 25,          -- 默认字体大小
	        defaultType = "CCRenderLabel",
	        defaultStrokeSize = 1,
	        defaultStrokeColor = ccc3(0x49,0x00,0x00),
	        elements =
	        {	
	        	{	
	        		text =	value.name,
	        		color = ccc3(0xfe,0xdb,0x1c),
			        font = g_sFontPangWa,
			        size = 30,
	        	},
	        }
	 	}
	 	local tipLabel = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lic_1816"), textInfo)
	    tipLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    tipLabel:setAnchorPoint(ccp(0.5,0.5))
	    tipLabel:setPosition(dialog:getContentSize().width*0.5, dialog:getContentSize().height*0.7)
	    dialog:addChild(tipLabel)

	    dialog:registerOkCallback(function ()
	  		-- 选择数量
	      	local chooseNum = dialog:getNum()
	      	local useNum = tonumber(value.need_part_num) * chooseNum
	      	_current_gid = value.gid
			_itemNumAfterRecruit = value.item_num - useNum
	      	local args = Network.argsHandler(value.gid, value.item_id,useNum,1,1)
			_sOnNetworkFlagRecruit = RequestCenter.bag_useItem(fnHandlerOfNetworkRecruit, args)
	    end)

	    dialog:registerChangeCallback(function ( pNum )

	    end)
	end
end

local function fnHandlerOfHeadButtons(tag, obj)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local data = _allHeroFragments[(tag-_ksTagHeadBegin)]

	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroInfoLayer"
	local tArgs = {}
	tArgs.sign = "HeroLayer"
	tArgs.fnCreate = HeroLayer.createLayer
	tArgs.reserved = {index=HeroLayer.m_indexOfSoul}
	MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
end

local function fnCreateCell(tCellValue)
	local ccCell = CCTableViewCell:create()
	-- 背景
	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	cellBg:setAnchorPoint(ccp(0, 0))
	if (tCellValue.tag_bg) then
		ccCell:addChild(cellBg, 1, tCellValue.tag_bg)
	else
		ccCell:addChild(cellBg, 1, 9001)
	end

	-- 武将所属国家
	local country = CCSprite:create(tCellValue.country_icon)
	country:setAnchorPoint(ccp(0, 0))
	country:setPosition(ccp(16, 105))
	cellBg:addChild(country)
	-- 武将等级
	local lv = CCLabelTTF:create("Lv."..tCellValue.level, g_sFontName, 20, CCSizeMake(130, 30), kCCTextAlignmentCenter)
	lv:setPosition(30, 105)
	lv:setColor(ccc3(0xff, 0xee, 0x3a))
	cellBg:addChild(lv)
	-- 武将名称
	local name = CCLabelTTF:create(tCellValue.name, g_sFontName, 22, CCSizeMake(136, 30), kCCTextAlignmentCenter)
	name:setPosition(139, 106)
	local cccQuality = HeroPublicLua.getCCColorByStarLevel(tCellValue.star_lv)
	name:setColor(cccQuality)
	cellBg:addChild(name)
	-- 星级
	local star_lv = HeroPublicCC.createStars("images/hero/star.png", tCellValue.star_lv, ccp(290, 112), 4)
	cellBg:addChild(star_lv)
	-- 已上阵
	if tCellValue.isBusy then
		local being_front = CCSprite:create("images/hero/being_fronted.png")
		being_front:setPosition(ccp(534, 82))
		cellBg:addChild(being_front)
	end
	-- 武将头像图标背景
	local csQuality = CCSprite:create(tCellValue.quality_bg)
	local csQualityLighted = CCSprite:create(tCellValue.quality_bg)
	local csFrame = CCSprite:create(tCellValue.quality_h)
	csFrame:setAnchorPoint(ccp(0.5, 0.5))
	csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
	csQualityLighted:addChild(csFrame)
	local head_icon_bg = CCMenuItemSprite:create(csQuality, csQualityLighted)
	-- 招募进度
	local bIsItemNumberFull = false
	if (tCellValue.type == "HeroFragment") then
		local tLabels = {
			{ctype=1, text=GetLocalizeStringBy("key_3092"), color=ccc3(0x48, 0x1b, 0), fontsize=24},
		}
		if tCellValue.item_num >= tCellValue.need_part_num then
			bIsItemNumberFull = true
			table.insert(tLabels, {ctype=1, text=tCellValue.item_num.."/"..tCellValue.need_part_num, color=ccc3(0, 0x6d, 0x2f), hOffset=6, vOffset=-2})
		else
			table.insert(tLabels, {ctype=1, text=tCellValue.item_num, color=ccc3(0xb9, 0, 0), hOffset=6, vOffset=-2})
			table.insert(tLabels, {ctype=1, text="/"..tCellValue.need_part_num, color=ccc3(0x48, 0x1b, 0), hOffset=0})
		end
		local tObjs = LuaCC.createCCNodesOnHorizontalLine(tLabels)
		tObjs[1]:setPosition(ccp(120, 48))
		cellBg:addChild(tObjs[1])
	end

	-- 头像、“可招募”均为CCMenuItem
	local menu_ms = CCMenu:create()
	local tag = tCellValue.tag_head or -1
	menu_ms:addChild(head_icon_bg, 0, tag)
	if tCellValue.cb_head then
		head_icon_bg:registerScriptTapHandler(tCellValue.cb_head)
	end

	tag = tCellValue.menu_tag or -1
	cellBg:addChild(menu_ms, 0, tag)
	-- 武将头像图标

	local head_icon = CCSprite:create(tCellValue.head_icon)
	head_icon:setPosition(ccp(9, 8))
	head_icon_bg:addChild(head_icon)
	head_icon_bg:setPosition(ccp(14, 14))
	menu_ms:setPosition(ccp(0, 0))

	local ccSpriteInsufficient = CCSprite:create("images/hero/insufficient.png")
	ccSpriteInsufficient:setAnchorPoint(ccp(0, 0.5))
	ccSpriteInsufficient:setPosition(ccp(290, 58))
	tag = tCellValue.tag_insufficient or -1
	cellBg:addChild(ccSpriteInsufficient, 0, tag)

	local ccBtnRecruit = CCMenuItemImage:create("images/hero/can_recruit_n.png", "images/hero/can_recruit_h.png")
	ccBtnRecruit:setAnchorPoint(ccp(0, 0.5))
	ccBtnRecruit:setPosition(ccp(290, 58))
	if tCellValue.cb_recruit then
		ccBtnRecruit:registerScriptTapHandler(tCellValue.cb_recruit)
	end
	local tag = tCellValue.tag_recruit or -1
	menu_ms:addChild(ccBtnRecruit, 0, tag)

	-- add by chengliang
	local showDropBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 65), GetLocalizeStringBy("key_2167"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	showDropBtn:registerScriptTapHandler(showDropActionFunc)
	showDropBtn:setAnchorPoint(ccp(0, 0.5))
	showDropBtn:setPosition(ccp(465, 58))
	menu_ms:addChild(showDropBtn, 1, tCellValue.gid)

	-- 如果未集齐
	if not bIsItemNumberFull then
		ccBtnRecruit:setVisible(false)
	else
		ccSpriteInsufficient:setVisible(false)
	end

	return ccCell
end

-- add by chengliang
function showDropActionFunc( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/copy/ShowAwardWayLayer"
	ShowAwardWayLayer.showLayer(tag)
end 

-- 创建武魂的tableview显示区域
function createTableView(layer, scrollview_height)



	_ccLayerParent = layer
	_scrollview_height = scrollview_height
	-- 从背包数据中取得武将碎片数据
	require "script/model/DataCache"
	local tHeroFrag = DataCache.getHeroFragFromBag()
	local heroesValue = {}
	-- 如果没有武魂数据则提示可通过打副本获得武魂
	if table.isEmpty(tHeroFrag) then
		local ccLayerHint = CCLayer:create()
		local ccLabelHint01 = CCLabelTTF:create(GetLocalizeStringBy("key_3090"), g_sFontName, 32)
		ccLabelHint01:setColor(ccc3(255, 255, 255))
		ccLabelHint01:setPosition(g_winSize.width/2, scrollview_height/2+40*g_fScaleY)
		ccLabelHint01:setScale(g_fScaleX)
		ccLabelHint01:setAnchorPoint(ccp(0.5, 0.5))
		ccLayerHint:addChild(ccLabelHint01)
		local ccLabelHint02  = CCLabelTTF:create(GetLocalizeStringBy("key_1204"), g_sFontName, 28)
		ccLabelHint02:setColor(ccc3(128, 128, 128))
		ccLabelHint02:setPosition(g_winSize.width/2, scrollview_height/2)
		ccLabelHint02:setScale(g_fScaleX)
		ccLabelHint02:setAnchorPoint(ccp(0.5, 0.5))
		ccLayerHint:addChild(ccLabelHint02)
		return ccLayerHint
	end

	local cellBg = CCSprite:create("images/hero/attr_bg.png")
	local cellSize = cellBg:getContentSize()
	cellSize.width = cellSize.width * g_fScaleX
	cellSize.height = cellSize.height * g_fScaleX
	cellBg = nil

	local _visiableCellNum = math.floor(scrollview_height/(cellSize.height*g_fScaleX))

	require "db/DB_Item_hero_fragment"
	require "db/DB_Heroes"
	local value
	local heroCount = 1

	for k,v in pairs(tHeroFrag) do
		value = {}
		-- 背包格子id
		value.gid = tonumber(k)
		-- 已有武将碎片
		value.item_num = tonumber(v.item_num)
		value.item_id = tonumber(v.item_id)
		local heroFragment = DB_Item_hero_fragment.getDataById(v.item_template_id)
		-- 所需碎片数量
		value.need_part_num = heroFragment.need_part_num
		value.htid = heroFragment.aimItem
		local db_hero = DB_Heroes.getDataById(heroFragment.aimItem)
		value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
		value.name = db_hero.name
		value.level = db_hero.lv
		value.star_lv = db_hero.star_lv
		value.hero_cb = menu_item_tap_handler
		value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
        value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
		value.quality_h = "images/hero/quality/highlighted.png"
		value.type = "HeroFragment"

		value.tag_insufficient = _ksTagInsufficient
		value.cb_recruit = fnHandlerOfRecruitButtons
		value.cb_head = fnHandlerOfHeadButtons

		value.progress = value.item_num.."/"..value.need_part_num
		value.isRecruited = false
		if value.item_num >= value.need_part_num then
			value.isRecruited = true
		end

		heroesValue[heroCount] = value
		heroCount = heroCount + 1
	end
	require "script/ui/hero/HeroSort"

	_allHeroFragments = HeroSort.fnSortOfHeroSoul(heroesValue)
	local nArrLen = #_allHeroFragments
	for i=1, nArrLen do
		local value=_allHeroFragments[i]
		value.tag_recruit = _ksTagRecruitBegin+i
		value.tag_head = _ksTagHeadBegin+i
		value.menu_tag = _ksTagMenuBegin + i
	end


	require "script/ui/hero/HeroLayerCell"
	require "script/ui/hero/HeroPublicCC"
    require "script/ui/hero/HeroPublicLua"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
			r = fnCreateCell(_allHeroFragments[#_allHeroFragments - a1])
			r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #_allHeroFragments
		elseif (fn == "cellTouched") then
			print ("a1: ", a1, ", a2: ", a2)
			print ("cellTouched, index is: ", a1:getIdx())
		else
			print (fn, " event is not handled.")
		end
		return r
	end)
	local tableView = LuaTableView:createWithHandler(handler, CCSizeMake(layer:getContentSize().width, scrollview_height))
	tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(ccp(0.5,0))
	tableView:setBounceable(true)

	_ccObjCurrentTableView = tableView

	return tableView
end

function getTableData( ... )
	-- 从背包数据中取得武将碎片数据
	require "script/model/DataCache"
	local tHeroFrag = DataCache.getHeroFragFromBag()
	local heroesValue = {}

	require "db/DB_Item_hero_fragment"
	require "db/DB_Heroes"
	local value
	local heroCount = 1

	for k,v in pairs(tHeroFrag) do
		value = {}
		-- 背包格子id
		value.gid = tonumber(k)
		-- 已有武将碎片
		value.item_num = tonumber(v.item_num)
		value.item_id = tonumber(v.item_id)
		local heroFragment = DB_Item_hero_fragment.getDataById(v.item_template_id)
		-- 所需碎片数量
		value.need_part_num = heroFragment.need_part_num
		value.htid = heroFragment.aimItem
		local db_hero = DB_Heroes.getDataById(heroFragment.aimItem)
		value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
		value.name = db_hero.name
		value.level = db_hero.lv
		value.star_lv = db_hero.star_lv
		value.hero_cb = menu_item_tap_handler
		value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
        value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
		value.quality_h = "images/hero/quality/highlighted.png"
		value.type = "HeroFragment"

		value.tag_insufficient = _ksTagInsufficient
		value.cb_recruit = fnHandlerOfRecruitButtons
		value.cb_head = fnHandlerOfHeadButtons

		value.progress = value.item_num.."/"..value.need_part_num
		value.isRecruited = false
		if value.item_num >= value.need_part_num then
			value.isRecruited = true
		end

		heroesValue[heroCount] = value
		heroCount = heroCount + 1
	end
	require "script/ui/hero/HeroSort"

	_allHeroFragments = HeroSort.fnSortOfHeroSoul(heroesValue)
	local nArrLen = #_allHeroFragments
	for i=1, nArrLen do
		local value=_allHeroFragments[i]
		value.tag_recruit = _ksTagRecruitBegin+i
		value.tag_head = _ksTagHeadBegin+i
		value.menu_tag = _ksTagMenuBegin + i
	end
end




--add by lichenyang
--@des:	得到玩家可合成武魂数
function getFuseSoulNum( ... )
	getTableData()
	local num = 0
	for k,v in pairs(_allHeroFragments) do
		if(tonumber(v.item_num) >= tonumber(v.need_part_num)) then
			num = num + math.floor(tonumber(v.item_num)/tonumber(v.need_part_num))
		end
	end
	return num
end

