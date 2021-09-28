local padding_outer = 25
local tag_equipInfoNode = 50001
return { new = function(params)
-----------------------------------------------------------------------
local Mtips = require "src/layers/bag/tipsCommon"
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
local Mprop = require "src/layers/bag/prop"
local MCustomView = require "src/layers/bag/CustomView"
-----------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
local dress = MPackManager:getPack(MPackStruct.eDress)
local bank = MPackManager:getPack(MPackStruct.eBank)
-----------------------------------------------------------------------
local gvCenter_posX = 311
local gvCenter_posY = 243
local now = params.now
local specialShow = false
local handler = params.handler or function() end
local filtrate = params.filtrate or function(packId, grid, now)
	return true
end
local g_opType = 1
local act_src = params.act_src
local status = params.way or 0
-- local status = 0
-- if act_src == game.getStrByKey("disinlay") then
-- 	status = 2
-- elseif act_src == game.getStrByKey("inlay") then
-- 	status = 1
-- end
local title_src = params.title_src
local onCellLongTouched = params.onCellLongTouched
-----------------------------------------------------------------------
local root = Mbaseboard.new( 
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 4 },
	},
	title = {
		src = title_src,--game.getStrByKey("equip_select_title"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = - 27 },
	},
})
local bg_left_transparent_padding = 17
local frame_width = 6
local bg = cc.Sprite:create("res/common/scalable/panel_outer_base.png", cc.rect(0, 0, 790 - frame_width * 2, 454 - frame_width * 2))
bg:setAnchorPoint(cc.p(0, 0))
bg:setPosition(cc.p(bg_left_transparent_padding + 16 + frame_width, 17 + frame_width))
bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
root:addChild(bg)
createScale9Sprite(root, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(bg_left_transparent_padding + 16, 17), cc.size(790, 454), cc.p(0, 0))

createScale9Sprite(
    root,
    "res/common/scalable/panel_inside_scale9.png",
    cc.p(bg_left_transparent_padding + padding_outer, padding_outer),
    cc.size(112, 436),
    cc.p(0, 0)
)

createSprite(root, "res/layers/equipSelect/equip_select_frame.png", cc.p(160, 24), cc.p(0, 0))
createSprite(root, "res/layers/equipSelect/equip_select_info_bg.png", cc.p(468, 37), cc.p(0, 0))

local rootSize = root:getContentSize()
-----------------------------------------------------------------------
local buildList = function(kind)
	local equips = {}
	-- dump(kind,"kindkindkindkindkindkindkindkindkind")
	
    if kind.bag then
	    -- 背包
	    local bag_list = bag:filtrate(function(grid)
		    return filtrate(MPackStruct.eBag, grid, now)
	    end, MPackStruct.eAll)
        for i, v in ipairs(bag_list) do
	        equips[#equips+1] = { packId = MPackStruct.eBag, grid = v }
        end
    end
	
    if kind.dress then
	    -- 着装
	    -- local dress_list = dress:filtrate(function(grid)
		   --  return filtrate(MPackStruct.eDress, grid, now,true)
	    -- end, MPackStruct.eAll)
		local dress_list,opType = filtrate(MPackStruct.eDress, grid, now,true)
		-- dump({dress_list,table.nums(dress_list),opType},"dress_listdress_listdress_listdress_listdress_list")

		if dress_list then
			specialShow = true
			local tab = {}
			if opType == 4 then								
				table.insert(tab,dress_list)	
				g_opType = opType
				return tab
			elseif opType == 2 then
				for k,v in pairs(dress_list) do
					tab[#tab+1] = {v[1],v[2]}
				end
				-- dump(tab,"tabtabtabtab")
				g_opType = opType
				return tab
			end
		end

	    -- for i, v in ipairs(dress_list) do
		   --  equips[#equips+1] = { packId = MPackStruct.eDress, grid = v }
	    -- end

    end
	
    if kind.bank then
	    -- 仓库
	    local bank_list = bank:filtrate(function(grid)
		    return filtrate(MPackStruct.eBank, grid, now)
	    end, MPackStruct.eAll)
	
	    for i, v in ipairs(bank_list) do
		    equips[#equips+1] = { packId = MPackStruct.eBank, grid = v }
	    end
    end
	
	local Mconvertor = require "src/config/convertor"
	
	table.sort(equips, function(a, b)        --对总物品排序
		local a_packId = a.packId
		local b_packId = b.packId
		
		if a_packId == MPackStruct.eDress and b_packId ~= MPackStruct.eDress then
			return true
		end
		
		if a_packId ~= MPackStruct.eDress and b_packId == MPackStruct.eDress then
			return false
		end
		
		--role
		local roleSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
		local roleSex = MRoleStruct:getAttr(PLAYER_SEX)
		
		--a
		local a_protoId = MPackStruct.protoIdFromGird(a.grid)
		local a_quality = MpropOp.quality(a_protoId)
		local a_propSchool = MpropOp.schoolLimits(a_protoId)
		local a_propSex = MpropOp.sexLimits(a_protoId)
		local a_kind = MequipOp.kind(a_protoId)
		local a_wearable = (a_propSchool == Mconvertor.eWhole or a_propSchool == roleSchool) and
		                   (a_propSex == Mconvertor.eSexWhole or a_propSex == roleSex)
		
		--b
		local b_protoId = MPackStruct.protoIdFromGird(b.grid)
		local b_quality = MpropOp.quality(b_protoId)
		local b_propSchool = MpropOp.schoolLimits(b_protoId)
		local b_propSex = MpropOp.sexLimits(b_protoId)
		local b_kind = MequipOp.kind(b_protoId)
		local b_wearable = (b_propSchool == Mconvertor.eWhole or b_propSchool == roleSchool) and
		                   (b_propSex == Mconvertor.eSexWhole or b_propSex == roleSex)
		
		if a_wearable and not b_wearable then
			return true
		end
		
		if not a_wearable and b_wearable then
			return false
		end
		
		if a_quality > b_quality then
			return true
		elseif a_quality < b_quality then
			return false
		else
			return a_kind < b_kind
		end
	end)
	
	return equips
end
local gvs = {}
local showTab = {"dress", "bag", "bank"}
if status == 2 then
	showTab = {"dress"}
elseif status == 1 then
	showTab = { "bag"}
end
for k, str_type in ipairs(showTab) do  --选择类别
    local list =
    (
    str_type == "all" and buildList({bag = true, bank = true, dress = true})
    or (str_type == "bag" and buildList({bag = true, bank = false, dress = false})
    or (str_type == "bank" and buildList({bag = false, bank = true, dress = false})
    or buildList({bag = false, bank = false, dress = true})
    )
    )
    )
    -- dump({list,#list,g_opType}, "listttttttttttttttttttttttt")
    -----------------------------------------------------------------------
    -- gridView
    local layout = { row = 4.6, col = 3, }
    local nums = math.max(#list, math.ceil(layout.row) * math.ceil(layout.col))
    local gv = MCustomView.new(
    {
	    --bg = "res/common/68.png",
	    layout = layout,
        gridSize = cc.size(94, 90)
    })
    gvs[str_type] = gv
    gv:setVisible((status == 1 and str_type == "bag") or ((status == 2 or status == 0 ) and str_type == "dress"))
    gv.numsInGrid = function(gv)
	    return nums
    end

    gv.onCellLongTouched = function(gv, idx, cell)
    	-- print(#list,"9999999999999999")
    	local Mtips = require "src/layers/bag/tips"
    	if specialShow then
    		 if idx >= #list then return end
    		 if type(act_src) == "string" then
    		 	local n_root = nil
			    local actions = {}
			    actions[#actions+1] = {
				    label = act_src,
				    cb = function(act_params)
					    handler(item[idx+1],status,g_opType)
					    if n_root then removeFromParent(n_root) n_root = nil end
					    if root then removeFromParent(root) root = nil end
				    end,
			    }
			
			    n_root = Mtips.new({ protoId = list[idx+1][1], actions = actions })
    		 end
    	else
		    local item = list[idx+1]
		    
		    if idx >= #list or type(item) ~= "table" then return end
		

		    if type(onCellLongTouched) == "function" then
			    onCellLongTouched(gv, idx, cell, item)
		    elseif type(act_src) == "string" then
			    local n_root = nil
			    local actions = {}
			    actions[#actions+1] = {
				    label = act_src,
				    cb = function(act_params)
					    handler(item,status,g_opType)
					    if n_root then removeFromParent(n_root) n_root = nil end
					    if root then removeFromParent(root) root = nil end
				    end,
			    }
			
			    n_root = Mtips.new({ grid = item.grid, actions = actions })
		    else
			    local grid = item.grid
			    local Mtips = require "src/layers/bag/tips"
			    Mtips.new({ grid = grid })
		    end
		end
    end

    gv.onCreateCell = function(gv, idx, cell)
    	local cellSize = cell:getContentSize()
    	local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
    	if specialShow then
    		if idx >= #list then return end
    		local Mprop = require "src/layers/bag/prop"
		
		    local icon = Mprop.new(
		    {
			    protoId = list[idx+1][1],
			    isActive = list[idx+1][2],
		    })
		
		    Mnode.addChild(
		    {
			    parent = cell,
			    child = icon,
			    pos = cellCenter,
		    })
		
		    cell.icon = icon
    	else
		    local item = list[idx+1]
		    if idx >= #list or type(item) ~= "table" then return end
		    local grid = item.grid
		
		    -- local cellSize = cell:getContentSize()
		    -- local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
		    ------------------------------------------------------------
		    local protoId = MPackStruct.protoIdFromGird(grid)
		    local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		    local griId = MPackStruct.girdIdFromGird(grid)
		    local num = MPackStruct.overlayFromGird(grid)
		    local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
		    ------------------------------------------------------------
		    local Mprop = require "src/layers/bag/prop"
		
		    local icon = Mprop.new(
		    {
			    grid = grid,
			    --num = num,
			    strengthLv = strengthLv,
			    --showBind = true,
			    --isBind = isBind,
			    red_mask = true,
			    powerHint = item.packId ~= MPackStruct.eDress and true or nil,
			    using = item.packId == MPackStruct.eDress,
		    })
		
		    Mnode.addChild(
		    {
			    parent = cell,
			    child = icon,
			    pos = cellCenter,
		    })
		
		    cell.icon = icon
		end

    end

    gv.onCellTouched = function(gv, idx, cell)
    		-- dump({gv,gvs},"gggggggggggggggggggggggggggggggg")
    		if specialShow then
    			if idx >= #list then return end
    			if list[idx+1][1] then	    			
	    			local node = Mtips.new({protoId = list[idx+1][1]}) 
	    			node:setTag(tag_equipInfoNode)
			        node.n_scroll:setViewSize(cc.size(338, 178))
			        node:setOpacity(0)
			        node:setPosition(cc.p(638, 201))--644
			        root:removeChildByTag(tag_equipInfoNode)
			        root:addChild(node)
			        node.n_scroll:setContentOffset({
			            x = 0
			            , y = node.n_scroll:getViewSize().height - node.n_scroll:getContentSize().height
			        })
			        MMenuButton.new(
				    {
					    parent = node,
					    src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
					    label = {
						    src = act_src,--game.getStrByKey("equip_select_btn_title"),
						    size = 25,
						    color = MColor.lable_yellow,
					    },
					
					    pos = cc.p(185, 141),
					
					    cb = function(tag, node)					 
				            local MpropOp = require "src/config/propOp"
				            AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
				            params.handler(list[idx+1],nil,g_opType)
				            if root then removeFromParent(root) root = nil end
					    end,
				    })
			        -- node.uiMaxNum_:setVisible(false)
			        -- node.uiPrice_:setVisible(false)
			        node:SetPriceTagBgVisible(false)
			    end
    		else
		        for k, v in pairs(gvs) do
		            if v ~= gv then
		                v:disableFocusd()
		            end
		        end
			    local item = list[idx+1]
			    if idx >= #list or type(item) ~= "table" then return end
			    ------------------------------------------------------------
			    local grid = item.grid
		        local node = Mtips.new({grid = grid})
		        node:setTag(tag_equipInfoNode)
		        node.n_scroll:setViewSize(cc.size(338, 178))
		        node:setOpacity(0)
		        node:setPosition(cc.p(638, 201))--644
		        root:removeChildByTag(tag_equipInfoNode)
		        root:addChild(node)
		        node.n_scroll:setContentOffset({
		            x = 0
		            , y = node.n_scroll:getViewSize().height - node.n_scroll:getContentSize().height
		        })
		        MMenuButton.new(
			    {
				    parent = node,
				    src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
				    label = {
					    src = act_src,--game.getStrByKey("equip_select_btn_title"),
					    size = 25,
					    color = MColor.lable_yellow,
				    },
				
				    pos = cc.p(185, 141),
				
				    cb = function(tag, node)
					    local protoId = MPackStruct.protoIdFromGird(grid)
			            local MpropOp = require "src/config/propOp"
			            AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
			            local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
			            local griId = MPackStruct.girdIdFromGird(grid)
			            local num = MPackStruct.overlayFromGird(grid)
			            params.handler(item,status,g_opType)
			            if root then removeFromParent(root) root = nil end
				    end,
			    })
		      node:SetPriceTagBgVisible(false)
	    	end        
    end
    gv.onScrolled = function(gv, offset)
        if not (gv.m_upBtn and gv.m_downBtn) then
            return
        end
	    local contentPos = gv:getContentOffset()
        if gv:getContentSize().height <= gv:getViewSize().height then
            gv.m_upBtn:setVisible(false)
		    gv.m_downBtn:setVisible(false)
	    elseif contentPos.y >= 0 then
		    gv.m_upBtn:setVisible(true)
		    gv.m_downBtn:setVisible(false)
        elseif contentPos.y <=  -(gv:getContentSize().height - gv:getViewSize().height) then
		    gv.m_downBtn:setVisible(true)
		    gv.m_upBtn:setVisible(false)
	    else
		    gv.m_downBtn:setVisible(true)
		    gv.m_upBtn:setVisible(true)
	    end
    end

    gv:refresh()

    Mnode.addChild(
    {
	    parent = root,
	    child = gv:getBgNode(),
	    anchor = cc.p(0.5, 1),
	    pos = cc.p(311, 458),
    })
    local distance_arrow_to_table_view = 16
    local bgsize = gv:getContentSize()
    gv.m_upBtn = createTouchItem(
        root
        , "res/group/arrows/19.png"
        , cc.p(
            gvCenter_posX
            , gvCenter_posY + gv:getViewSize().height / 2 + distance_arrow_to_table_view
        )
        , function()
            --点击向上按钮事件
            -- print("11111111")
        end
    )
    gv.m_upBtn:setRotation(-90)
    gv.m_upBtn:setVisible(false)--((status == 1 and str_type == "bag") or (status == 2 and str_type == "dress"))
	gv.m_upBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 5)), cc.MoveBy:create(0.3, cc.p(0, - 5)))))
	gv.m_downBtn = createTouchItem(
        root
        , "res/group/arrows/19.png"
        , cc.p(
            gvCenter_posX
            , gvCenter_posY - gv:getViewSize().height / 2 - distance_arrow_to_table_view
        )
        , function()
            --点击向下按钮事件
            -- print("222222")
        end
    )
    gv.m_downBtn:setRotation(90)
    gv.m_downBtn:setVisible(gv:getContentSize().height > gv:getViewSize().height and (status == 1 and str_type == "bag") or ((status == 2 or status == 0) and str_type == "dress"))
	gv.m_downBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, - 5)), cc.MoveBy:create(0.3, cc.p(0, 5)))))
end

local button_all, button_dress, button_bag, button_bank
-- button_all = createTouchItem(root, "res/component/button/43_sel.png", cc.p(98, 424), function()
--     button_all:setTexture("res/component/button/43_sel.png")
--     button_dress:setTexture("res/component/button/43.png")
--     button_bag:setTexture("res/component/button/43.png")
--     button_bank:setTexture("res/component/button/43.png")
--     for k, v in pairs(gvs) do
--         v:setVisible(false)
--         v.m_upBtn:setVisible(false)
--         v.m_downBtn:setVisible(false)
--     end
--     gvs["all"]:setVisible(true)
--     local gv = gvs["all"]
--     local contentPos = gv:getContentOffset()
--     if gv:getContentSize().height <= gv:getViewSize().height then
--         gv.m_upBtn:setVisible(false)
-- 		gv.m_downBtn:setVisible(false)
-- 	elseif contentPos.y >= 0 then
-- 		gv.m_upBtn:setVisible(true)
-- 		gv.m_downBtn:setVisible(false)
--     elseif contentPos.y <=  -(gv:getContentSize().height - gv:getViewSize().height) then
-- 		gv.m_downBtn:setVisible(true)
-- 		gv.m_upBtn:setVisible(false)
-- 	else
-- 		gv.m_downBtn:setVisible(true)
-- 		gv.m_upBtn:setVisible(true)
-- 	end
-- end)
-- createLabel(button_all, game.getStrByKey("equip_select_button_all"), cc.p(button_all:getContentSize().width/2, button_all:getContentSize().height/2), nil, 22, nil, nil, nil, MColor.lable_yellow)
local ySub = 0
if status == 2 or status == 0 then
	button_dress = createTouchItem(root, "res/component/button/43_sel.png", cc.p(98, 424 - ySub ), function()
	    -- button_all:setTexture("res/component/button/43.png")
	    button_dress:setTexture("res/component/button/43_sel.png")
	    if status == 0 then
		    button_bag:setTexture("res/component/button/43.png")
		    button_bank:setTexture("res/component/button/43.png")
		end
	    for k, v in pairs(gvs) do
	        v:setVisible(false)
	        v.m_upBtn:setVisible(false)
	        v.m_downBtn:setVisible(false)
	    end
	    -- if gvs["dress"] then
		    gvs["dress"]:setVisible(true)    	
		    local gv = gvs["dress"]
		    local contentPos = gv:getContentOffset()
		    if gv:getContentSize().height <= gv:getViewSize().height then
		        gv.m_upBtn:setVisible(false)
				gv.m_downBtn:setVisible(false)
			elseif contentPos.y >= 0 then
				gv.m_upBtn:setVisible(true)
				gv.m_downBtn:setVisible(false)
		    elseif contentPos.y <=  -(gv:getContentSize().height - gv:getViewSize().height) then
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(false)
			else
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(true)
			end
		-- end
	end)
	createLabel(button_dress, game.getStrByKey("equip_select_button_dress"), cc.p(button_dress:getContentSize().width/2, button_dress:getContentSize().height/2), nil, 22, nil, nil, nil, MColor.lable_yellow)
	ySub = ySub + 70
end
if status == 1 or status == 0 then
	local res = "res/component/button/43_sel.png"
	if ySub ~= 0 then
		res = "res/component/button/43.png"
	end
	button_bag = createTouchItem(root, res, cc.p(98, 424 - ySub ), function()
	    -- button_all:setTexture("res/component/button/43.png")
	    if status == 0 then
	    	button_dress:setTexture("res/component/button/43.png")
	    	button_bank:setTexture("res/component/button/43.png")
	    end
	    button_bag:setTexture("res/component/button/43_sel.png")	    
	    for k, v in pairs(gvs) do
	        v:setVisible(false)
	        v.m_upBtn:setVisible(false)
	        v.m_downBtn:setVisible(false)
	    end
	    -- if gvs["bag"] then
		    gvs["bag"]:setVisible(true)
		    local gv = gvs["bag"]
		    local contentPos = gv:getContentOffset()
		    if gv:getContentSize().height <= gv:getViewSize().height then
		        gv.m_upBtn:setVisible(false)
				gv.m_downBtn:setVisible(false)
			elseif contentPos.y >= 0 then
				gv.m_upBtn:setVisible(true)
				gv.m_downBtn:setVisible(false)
		    elseif contentPos.y <=  -(gv:getContentSize().height - gv:getViewSize().height) then
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(false)
			else
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(true)
			end
		-- end
	end)
	createLabel(button_bag, game.getStrByKey("equip_select_button_bag"), cc.p(button_bag:getContentSize().width/2, button_bag:getContentSize().height/2), nil, 22, nil, nil, nil, MColor.lable_yellow)
	ySub = ySub + 70
end
if status == 0 then
	button_bank = createTouchItem(root, "res/component/button/43.png", cc.p(98, 424 - ySub ), function()
	    -- button_all:setTexture("res/component/button/43.png")
	    if status == 0 then
	    	button_dress:setTexture("res/component/button/43.png")
	    	button_bag:setTexture("res/component/button/43.png")
	    end	    
	    button_bank:setTexture("res/component/button/43_sel.png")
	    for k, v in pairs(gvs) do
	        v:setVisible(false)
	        v.m_upBtn:setVisible(false)
	        v.m_downBtn:setVisible(false)
	    end
	    -- if gvs["bank"] then
		    gvs["bank"]:setVisible(true)
		    local gv = gvs["bank"]
		    local contentPos = gv:getContentOffset()
		    if gv:getContentSize().height <= gv:getViewSize().height then
		        gv.m_upBtn:setVisible(false)
				gv.m_downBtn:setVisible(false)
			elseif contentPos.y >= 0 then
				gv.m_upBtn:setVisible(true)
				gv.m_downBtn:setVisible(false)
		    elseif contentPos.y <=  -(gv:getContentSize().height - gv:getViewSize().height) then
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(false)
			else
				gv.m_downBtn:setVisible(true)
				gv.m_upBtn:setVisible(true)
			end
		-- end
	end)
	createLabel(button_bank, game.getStrByKey("equip_select_button_bank"), cc.p(button_bank:getContentSize().width/2, button_bank:getContentSize().height/2), nil, 22, nil, nil, nil, MColor.lable_yellow)
end


local gv = ((status == 2 or status == 0) and gvs["dress"]) or (status == 1 and gvs["bag"])
gv:touchCellAtIndex(0)
-----------------------------------------------------------------------
return root
end }