--[[
todo:
1.测试新手引导
]]
local smelter = class("smelter",function() return cc.Node:create() end)
local Mbaseboard = require "src/functional/baseboard"
local MPackView = require "src/layers/bag/PackView"
local Mcurrency = require "src/functional/currency"
local MMenuButton = require "src/component/button/MenuButton"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
function smelter:ctor(equip, school, sex, q_sort)
    createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 15),
        cc.size(790, 454),
        5
    )
    createScale9Sprite(
        self,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(42, 23),
        cc.size(287, 437),
        cc.p(0, 0)
    )
    createScale9Sprite(
        self,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(336, 225),
        cc.size(477, 235),
        cc.p(0, 0)
    )
    -- 数据
    local bag = MPackManager:getPack(MPackStruct.eBag)
    self.list = bag:filtrate(function(grid)
	    local protoId = MPackStruct.protoIdFromGird(grid)
	    -- 是否是勋章
	    local isMedal = protoId >= 30004 and protoId <= 30006
	    return MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment and not isMedal
    end, MPackStruct.eAll)
    table.sort(self.list, function(a, b)
	    local a_protoId = MPackStruct.protoIdFromGird(a)
	    local a_quality = MpropOp.quality(a_protoId)
	    local a_level = MpropOp.levelLimits(a_protoId)
	    local b_protoId = MPackStruct.protoIdFromGird(b)
	    local b_quality = MpropOp.quality(b_protoId)
	    local b_level = MpropOp.levelLimits(b_protoId)
	    return a_quality > b_quality or (a_quality == b_quality and a_level > b_level)
    end)
    self.list_selected = {}
    for k, v in ipairs(self.list) do
        self.list_selected[k] = false
    end
    --[[
    --目前不要上下箭头
    local distance_arrow_to_table_view = 8
    self.m_upBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() + self:getTableView():getViewSize().height + distance_arrow_to_table_view
        )
        , function()
            --点击向上按钮事件
        end
    )
    self.m_upBtn:setRotation(-90)
    self.m_upBtn:setVisible(false)
	self.m_upBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 5)), cc.MoveBy:create(0.3, cc.p(0, - 5)))))
	self.m_downBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() - distance_arrow_to_table_view
        )
        , function()
            --点击向下按钮事件
        end
    )
    self.m_downBtn:setRotation(90)
    self.m_downBtn:setVisible(self:getTableView():getContentSize().height > self:getTableView():getViewSize().height)
	self.m_downBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, - 5)), cc.MoveBy:create(0.3, cc.p(0, 5)))))
    ]]
    ----------------------------------------------------------------------------------
    -- gridView
    local MCustomView = require "src/layers/bag/CustomView"
    local gv = MCustomView.new(
    {
	    packId = MPackStruct.eBag,
	    layout = {row = 4.5, col = 3},
	    marginLR = 0,
	    marginUD = 5,
    })
    gv.numsInGrid = function(gv)
	    return bag:maxNumOfGirdCanOpen()
    end
    gv.onCreateCell = function(gv, idx, cell)
	    local grid = self.list[idx+1]
	    if idx >= #self.list or type(grid) ~= "table" then return end
	    local griId = MPackStruct.girdIdFromGird(grid)
	    local cellSize = cell:getContentSize()
	    local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
	    local protoId = MPackStruct.protoIdFromGird(grid)
        local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	    local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	    local Mprop = require "src/layers/bag/prop"
	    local icon = Mprop.new(
	    {
		    grid = grid,
		    strengthLv = strengthLv,
		    isBind = isBind,
		    powerHint = true,
		    red_mask = true,
	    })
	    Mnode.addChild(
	    {
		    parent = cell,
		    child = icon,
		    pos = cellCenter,
	    })
        if self.list_selected[idx + 1] then
            local spr_selectCover = createSprite(cell, "res/common/icon_selected.png", cc.p(cell:getContentSize().width / 2, cell:getContentSize().height / 2), cc.p(0.5, 0.5))
            spr_selectCover:setTag(require("src/config/CommDef").TAG_RONGLIAN_SELECT_COVER)
        end
    end
    gv.onCellLongTouched = function(gv, idx, cell)
	    local grid = self.list[idx+1]
	    if idx >= #self.list or type(grid) ~= "table" then return end
	    local griId = MPackStruct.girdIdFromGird(grid)
	    local Mtips = require "src/layers/bag/tips"
	    local actions = {}
	    Mtips.new({ grid = grid, actions = actions })
    end
    gv.onCellTouched = function(gv, idx, cell)
	    local grid = self.list[idx+1]
	    if idx >= #self.list or type(grid) ~= "table" then return end
	    local griId = MPackStruct.girdIdFromGird(grid)
	    AudioEnginer.playTouchPointEffect()
        if not cell:getChildByTag(require("src/config/CommDef").TAG_RONGLIAN_SELECT_COVER) then
            local spr_selectCover = createSprite(cell, "res/common/icon_selected.png", cc.p(cell:getContentSize().width / 2, cell:getContentSize().height / 2), cc.p(0.5, 0.5))
            spr_selectCover:setTag(require("src/config/CommDef").TAG_RONGLIAN_SELECT_COVER)
            self.list_selected[idx + 1] = true
        else
            cell:removeChildByTag(require("src/config/CommDef").TAG_RONGLIAN_SELECT_COVER)
            self.list_selected[idx + 1] = false
        end
        self:refresh_hz_and_zq()
    end
    Mnode.addChild(
    {
	    parent = self,
	    child = gv:getBgNode(),
	    anchor = cc.p(0, 1),
	    pos = cc.p(41, 465),
    })
    local json = require("json")
    if getLocalRecordByKey(2, "smelter_check_user_preference") == "" then
        setLocalRecordByKey(2, "smelter_check_user_preference", json.encode({
            white = false
            , green = false
            , blue = false
            , purple = false
            , orange = false
        }))
    end
    local clickFunc = function(sender)
        sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
        setLocalRecordByKey(2, "smelter_check_user_preference", json.encode({
            white = self.check_box_white:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , green = self.check_box_green:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , blue = self.check_box_blue:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , purple = self.check_box_purple:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , orange = self.check_box_orange:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
        }))
        local MPropOp = require "src/config/propOp"
        for k, v in ipairs(self.list) do
            if (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 1 and self.check_box_white:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
            or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 2 and self.check_box_green:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
            or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 3 and self.check_box_blue:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
            or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 4 and self.check_box_purple:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
            or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 5 and self.check_box_orange:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
            then
                self.list_selected[k] = true
            else
                self.list_selected[k] = false
            end
        end
        gv:refresh()
		self:refresh_hz_and_zq()
    end
    local checkBox_user_prefrence = json.decode(getLocalRecordByKey(2, "smelter_check_user_preference"))
    local posY_base = 188
    self.check_box_white = createTouchItem(self, checkBox_user_prefrence.white and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(347, posY_base), clickFunc)
    self.check_box_white:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_white = createLabel(self, game.getStrByKey("set_pickup_white"), cc.p(388, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.drop_white)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_white, nil, function() clickFunc(self.check_box_white) end)
    self.check_box_green = createTouchItem(self, checkBox_user_prefrence.green and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(347 + 162, posY_base), clickFunc)
    self.check_box_green:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_green = createLabel(self, game.getStrByKey("set_pickup_green"), cc.p(388 + 162, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.green)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_green, nil, function() clickFunc(self.check_box_green) end)
    self.check_box_blue = createTouchItem(self, checkBox_user_prefrence.blue and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(347 + 162 * 2, posY_base), clickFunc)
    self.check_box_blue:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_blue = createLabel(self, game.getStrByKey("set_pickup_blue"), cc.p(388 + 162 * 2, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.blue)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_blue, nil, function() clickFunc(self.check_box_blue) end)
    posY_base = 138
    self.check_box_purple = createTouchItem(self, checkBox_user_prefrence.purple and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(347, posY_base), clickFunc)
    self.check_box_purple:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_purple = createLabel(self, game.getStrByKey("set_pickup_purple"), cc.p(388, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.purple)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_purple, nil, function() clickFunc(self.check_box_purple) end)
    self.check_box_orange = createTouchItem(self, checkBox_user_prefrence.orange and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(347 + 162, posY_base), clickFunc)
    self.check_box_orange:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_orange = createLabel(self, game.getStrByKey("set_pickup_orange"), cc.p(388 + 162, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.orange)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_orange, nil, function() clickFunc(self.check_box_orange) end)
    -- 熔炼商城按钮
    local resolveShopMenu, resolveShopBtn = MMenuButton.new(
    {
	    src = "res/component/button/50.png",
	    parent = self,
	    pos = cc.p(408, 54),
	    label = {
		    src = game.getStrByKey("melting_store"),
		    size = 25,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
            __GotoTarget({ru = "a38"})
	    end
    })
    resolveShopMenu:setTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU)
    resolveShopBtn:setTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN)
    -- 熔炼按钮
    local resolveMenu, resolveBtn = MMenuButton.new(
    {
	    src = "res/component/button/4.png",
	    parent = self,
	    pos = cc.p(726, 54),
	    label = {
		    src = game.getStrByKey("melting_begin"),
		    size = 25,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
		    local has_strength_equip = false
		    local has_high_quality_equip = false
		    local gridIds = {}
		    for k, v in pairs(self.list_selected) do
                if v == true then
				    local grid = self.list[k]
                    gridIds[#gridIds+1] = MPackStruct.girdIdFromGird(grid)
				    local protoId = MPackStruct.protoIdFromGird(grid)
				    local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
				    local quality = MpropOp.quality(protoId)
				    has_high_quality_equip = has_high_quality_equip or quality >= 4
				    has_strength_equip = has_strength_equip or strengthLv > 0
			    end
		    end
		
		    local num = #gridIds
		    if num > 0 then			
			    local action = function()
				    --if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
				
				    AudioEnginer.playEffect("sounds/uiMusic/ui_achieve.mp3",false)
				    local t = {}
				    t.itemNum = num
				    local slotList = {}
				    for i = 1, num do
					    local gridId = gridIds[i]
					    slotList[i] = gridId
				    end
				    t.slotList = slotList
				    --dump(t, "t")
				    g_msgHandlerInst:sendNetDataByTable(ITEM_CS_EQUIP_SMELTER, "SmelterReqProtocol", t)
				    addNetLoading(ITEM_CS_EQUIP_SMELTER, ITEM_SC_EQUIP_SMELTER_RET)
			    end
			
			    if has_strength_equip or has_high_quality_equip then
                    MessageBoxYesNo(nil, game.getStrByKey("equip_resolve_tips"), function()
                        action()
                    end, nil)
			    else
				    action()
			    end
		    else
			    TIPS({ type = 1  , str = game.getStrByKey("please")..game.getStrByKey("put")..game.getStrByKey("equipment") })
		    end
	    end
    })
    G_TUTO_NODE:setTouchNode(resolveBtn, TOUCH_FURNACE_RESOLVE)
    G_TUTO_NODE:setTouchNode(function() return gv:cellAtIndex(0) end, TOUCH_FURNACE_ITEM_1)
    G_TUTO_NODE:setTouchNode(function() return gv:locateItem(list, 1920301) end, TOUCH_FURNACE_ITEM_2)
    G_TUTO_NODE:setTouchNode(function() return gv:locateItem(list, 1930201) end, TOUCH_FURNACE_ITEM_3)
    G_TUTO_NODE:setTouchNode(function() return gv:locateItem(list, 1930301) end, TOUCH_FURNACE_ITEM_4)
    G_TUTO_NODE:setTouchNode(function() return gv:locateItem(list, 1910201) end, TOUCH_FURNACE_ITEM_5)
    G_TUTO_NODE:setTouchNode(function() return gv:locateItem(list, 1910301) end, TOUCH_FURNACE_ITEM_6)
    ------------------------------------------------------------------------------------
    local bagDataChanged = function(observable, event, pos, pos1, gz)
	    if event == "-" then
            -- 数据
            local bag = MPackManager:getPack(MPackStruct.eBag)
            self.list = bag:filtrate(function(grid)
	            local protoId = MPackStruct.protoIdFromGird(grid)
	            -- 是否是勋章
	            local isMedal = protoId >= 30004 and protoId <= 30006
	            return MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment and not isMedal
            end, MPackStruct.eAll)
            table.sort(self.list, function(a, b)
	            local a_protoId = MPackStruct.protoIdFromGird(a)
	            local a_quality = MpropOp.quality(a_protoId)
	            local a_level = MpropOp.levelLimits(a_protoId)
	            local b_protoId = MPackStruct.protoIdFromGird(b)
	            local b_quality = MpropOp.quality(b_protoId)
	            local b_level = MpropOp.levelLimits(b_protoId)
	            return a_quality > b_quality or (a_quality == b_quality and a_level > b_level)
            end)
            self.list_selected = {}
            for k, v in ipairs(self.list) do
                self.list_selected[k] = false
            end
            gv:refresh()
	    end
    end
    self:registerScriptHandler(function(event)
	    if event == "enter" then
		    bag:register(bagDataChanged)
		    g_msgHandlerInst:registerMsgHandler(ITEM_SC_EQUIP_SMELTER_RET, function(buf)
			    dump("装备分解返回", "装备分解返回")
			    local t = g_msgHandlerInst:convertBufferToTable("SmelterRetProtocol", buf)
			    --dump(t, "装备分解返回")
			    local roleID = t.newEquipID
			    local result = t.smelterRet
			    local hz = t.getSoulscore
			    local zq = t.getMoney
			    local t = {roleID=roleID, result=result, hz=hz, zq=zq }
			    dump(t, "装备分解返回结果")
			    if result then
				    self:refresh_hz_and_zq()
				    --TIPS({ type = 1  , str = "分解成功" })
				    -------------------------------------
				    --强化成功特效
				    local animateSpr = Effects:create(false)
				    performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,1.5)
				    animateSpr:playActionData("resolve_success", 10, 1.5, 1)
                    local width_dialogBg = 850
				    Mnode.addChild(
				    {
					    parent = self,
					    child = animateSpr,
					    pos = cc.p(width_dialogBg / 2, 500),
					    zOrder = 1000,
				    })
				    if roleID > 0 then
					    local propOp = require("src/config/propOp")
					    local name = " " .. (propOp.name(roleID) or "未知物品")
					    TIPS({ type = 1  , str = game.getStrByKey("melting")..game.getStrByKey("getAward") ..game.getStrByKey("goods")..name })
				    end
			    else
				    TIPS({ type = 1  , str = game.getStrByKey("melting")..game.getStrByKey("failure") })
			    end
		    end)
		    G_TUTO_NODE:setShowNode(self, SHOW_FURNACE)
	    elseif event == "exit" then
		    bag:unregister(bagDataChanged)
		    g_msgHandlerInst:registerMsgHandler(ITEM_SC_EQUIP_SMELTER_RET, nil)
	    end
    end)
    local spr_title = createSprite(self, "res/common/bg/titleLine.png", cc.p(577, 437), cc.p(0.5,0.5))
    createLabel(spr_title, game.getStrByKey("smelter_expect_preview"), cc.p(spr_title:getContentSize().width / 2, spr_title:getContentSize().height / 2), cc.p(0.5, 0.5), 21, nil, nil, nil, MColor.lable_yellow)
    for k, v in ipairs(self.list) do
        if (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 1 and self.check_box_white:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
        or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 2 and self.check_box_green:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
        or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 3 and self.check_box_blue:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
        or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 4 and self.check_box_purple:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
        or (MpropOp.quality(MPackStruct.protoIdFromGird(v)) == 5 and self.check_box_orange:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
        then
            self.list_selected[k] = true
        else
            self.list_selected[k] = false
        end
    end


    --新手教程专用
    self.tutoFunction = function ( ... )
        self.check_box_white:setTexture("res/component/checkbox/1.png")
        self.list_selected[1] = false
        setLocalRecordByKey(2, "smelter_check_user_preference", json.encode({
            false
            , green = self.check_box_green:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , blue = self.check_box_blue:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , purple = self.check_box_purple:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , orange = self.check_box_orange:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
        }))
        gv:refresh()
        self:refresh_hz_and_zq()
    end
    gv:refresh()
	self:refresh_hz_and_zq()
    --[[
    -- 帮助按钮
    local n_prompt = __createHelp(
    {
	    parent = self,
	    str = require("src/config/PromptOp"):content(14),
	    pos = cc.p(560, 60),
    })

    n_prompt:setScale(0.8)
    ]]
end

--[[
--目前不要上下箭头
function smelter:scrollViewDidScroll(view)
    if not (self.m_upBtn and self.m_downBtn) then
        return
    end
	local tableTemp = self:getTableView()
	local contentPos = tableTemp:getContentOffset()
    if tableTemp:getContentSize().height <= tableTemp:getViewSize().height then
        self.m_upBtn:setVisible(false)
		self.m_downBtn:setVisible(false)
	elseif contentPos.y >= 0 then
		self.m_upBtn:setVisible(true)
		self.m_downBtn:setVisible(false)
    elseif contentPos.y <=  -(tableTemp:getContentSize().height - tableTemp:getViewSize().height) then
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(false)
	else
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(true)
	end
end
]]
function smelter:refresh_hz_and_zq()
	local MequipOp = require "src/config/equipOp"
	local MpropOp = require "src/config/propOp"
	local total_hz = 0
	local total_zq = 0
	local total_material = {}
	local qcs = 1219
	local qcs_min, qcs_max = 0, 0
    local bool_qcs_promised = true
    for k, v in ipairs(self.list_selected) do
        while true do
            if v == false then
                break
            end
		    local grid = self.list[k]
            --begin 计算魂值和真气
	        local MpropOp = require "src/config/propOp"
	        local MequipOp = require "src/config/equipOp"
	        local protoId = MPackStruct.protoIdFromGird(grid)
	        local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	        local coinRet = MequipOp.upStrengthCoinRet(protoId, strengthLv)
            --local lv = MpropOp.levelLimits(protoId)
	        --local add_hz = lv + strengthLv * 4
	        --local add_zq = add_hz * 1
	        local add_hz = MpropOp.meltingValue(protoId)
	        local add_zq = MpropOp.recyclePrice(protoId)+coinRet
            --end 计算魂值和真气
		    total_hz = total_hz + add_hz
		    total_zq = total_zq + add_zq
		    local protoId = MPackStruct.protoIdFromGird(grid)
		    local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		    local materialRet = MequipOp.upStrengthMaterialRet(protoId, strengthLv)
		    for k, v in pairs(materialRet) do
			    total_material[k] = (total_material[k] or 0) + v
		    end
		    -- 七彩石
		    local min, max, rate_qiCai = MpropOp.smeltRet(protoId)
		    if max >= min and min > 0 then
			    qcs_min = qcs_min + min
			    qcs_max = qcs_max + max
		    end
            if rate_qiCai < 100 then
                bool_qcs_promised = false
            end
            break
        end
	end
    local tag_richText_rongLianResult = 40
    while self:getChildByTag(tag_richText_rongLianResult) do
        self:removeChildByTag(tag_richText_rongLianResult)
    end
    local pos_y_target_item_line = 500 - 78 - 30
    local pos_x_left, pos_x_right = 500 - 96 - 57, 645 - 118 + 60
    local label_font_size = 20
    local line_height = 26
    local richTextSize_width = 960
    local richText_zq = require("src/RichText").new(self, cc.p(pos_x_left, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_zq:setTag(tag_richText_rongLianResult)
    richText_zq:setAutoWidth()
    richText_zq:addText(
        "^c(lable_yellow)" .. game.getStrByKey("gold_coin") .. " : ^"
        .. numToFatString(total_zq)
    )
    richText_zq:format()
    local richText_hz = require("src/RichText").new(self, cc.p(pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_hz:setTag(tag_richText_rongLianResult)
    richText_hz:setAutoWidth()
    richText_hz:addText(
        "^c(lable_yellow)" .. game.getStrByKey("melting_value") .. " : ^"
        .. numToFatString(total_hz)
    )
    richText_hz:format()
    pos_y_target_item_line = pos_y_target_item_line - line_height
    --[[
	self.hz:setValue(total_hz)
	self.zq:setValue(total_zq)
    ]]
    --金币，熔炼值
	local list = {}
	for k, v in pairs(total_material) do
		list[#list+1] = {id = k, num = v}
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
    --铁矿
    local bool_atLeft = true
	for i, v in ipairs(list) do
        local richText_cost_item = require("src/RichText").new(self, cc.p(bool_atLeft and pos_x_left or pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
        richText_cost_item:setTag(tag_richText_rongLianResult)
        richText_cost_item:setAutoWidth()
        richText_cost_item:addTextItem(MpropOp.name(v.id) .. " : ", MpropOp.nameColor(v.id), false, false, true, function()
            local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				protoId = v.id,
				pos = cc.p(0, 0),
			})
        end)
        richText_cost_item:addText(
            v.num
        )
        richText_cost_item:format()
        local linkNode = richText_cost_item:getChildren()[1]:getChildren()[1]:getChildren()[1]--link item道具名
        drawUnderLine(linkNode, MpropOp.nameColor(v.id))
		--local label = cc.Label:createWithTTF("_", g_font_path, 18)
		-- label:setAnchorPoint(cc.p(0, 0))
		-- label:setPosition(cc.p(linkNode:getPositionX(), linkNode:getPositionY() - 2))
		-- local scale = linkNode:getContentSize().width / label:getContentSize().width
		-- label:setScaleX(scale)
		-- label:setColor(MpropOp.nameColor(v.id))
  --       linkNode:getParent():addChild(label)
        if bool_atLeft then
            bool_atLeft = false
        else
            bool_atLeft = true
        end
        if bool_atLeft then
            pos_y_target_item_line = pos_y_target_item_line - line_height
        end
	end
	if qcs_min > 0 then
        --七彩石
        local richText_cost_item = require("src/RichText").new(self, cc.p(bool_atLeft and pos_x_left or pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
        richText_cost_item:setTag(tag_richText_rongLianResult)
        richText_cost_item:setAutoWidth()
        richText_cost_item:addTextItem(MpropOp.name(qcs) .. " : ", MpropOp.nameColor(qcs), false, false, true, function()
            local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				protoId = qcs,
				pos = cc.p(0, 0),
			})
        end)
        richText_cost_item:addText(
            qcs_min .. "-" .. qcs_max
        )
        if not bool_qcs_promised then
            richText_cost_item:addText(
                game.getStrByKey("smelter_qcs_has_rate")
                , MColor.alarm_red
            )
        end
        richText_cost_item:format()
        local linkNode = richText_cost_item:getChildren()[1]:getChildren()[1]:getChildren()[1]--link item道具名
        drawUnderLine(linkNode, MpropOp.nameColor(qcs))
		-- local label = cc.Label:createWithTTF("_", g_font_path, 18)
		-- label:setAnchorPoint(cc.p(0, 0))
		-- label:setPosition(cc.p(linkNode:getPositionX(), linkNode:getPositionY() - 2))
		-- local scale = linkNode:getContentSize().width / label:getContentSize().width
		-- label:setScaleX(scale)
		-- label:setColor(MpropOp.nameColor(qcs))
  --       linkNode:getParent():addChild(label)
        if bool_atLeft then
            bool_atLeft = false
        else
            bool_atLeft = true
        end
        if bool_atLeft then
            pos_y_target_item_line = pos_y_target_item_line - line_height
        end
	end
end

return smelter