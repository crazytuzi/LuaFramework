return { new = function(params)
	local Mmisc = require "src/young/util/misc"
	local MpropOp = require "src/config/propOp"
	local Mprop = require "src/layers/bag/prop"
	local MequipOp = require "src/config/equipOp"
	local Mconvertor = require "src/config/convertor"
	local MMenuButton = require "src/component/button/MenuButton"
	--------------------------------------------------------
	if type(params) ~= "table" then return end
	--------------------------------------------------------
	local dress = MPackManager:getPack(MPackStruct.eDress)
	--------------------------------------------------------
	local size = 20
	local color = MColor.lable_yellow
	--------------------------------------------------------
    local strfile = "res/common/bg/tips1.png"
    local addY = 234
    if params.bgType ~= 1 then
        strfile = "res/common/bg/tips2.png"
        addY = 0
    end
	local root = cc.Sprite:create(strfile)
	local rootSize = root:getContentSize()
	--------------------------------------------------------
	-- 包裹id
	local packId = params.packId
	
	local grid = Mmisc:getValue(params, "grid", MPackStruct:buildGirdFromProtoId(params.protoId))
	
	local gridId = MPackStruct.girdIdFromGird(grid)
	
	-- 原型ID
	local protoId = MPackStruct.protoIdFromGird(grid)
	
	-- 是否是勋章
	local isMedal = protoId >= 30004 and protoId <= 30006
	-- 类型
	local cate = MPackStruct.categoryFromGird(grid)

	-- 是否是装备类型
	local isEquip = not isMedal and cate == MPackStruct.eEquipment
	
	local isWeapon = isEquip and MequipOp.kind(protoId) == MPackStruct.eWeapon
	
	-- 是否是套装
	local isSuit = MequipOp.isSuit(protoId)
	
	-- 是否绑定
	local isBind = nil
	if params.isBind ~= nil then
		isBind = params.isBind
	else
		isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	end
	
	-- 使用职业
	local school = MpropOp.schoolLimits(protoId)
	
	-- 使用性别
	local sex = MpropOp.sexLimits(protoId)
	
	-- 物品等级
	local level = MpropOp.levelLimits(protoId)
	
	-- 过期时间
	local expiration = MPackStruct.attrFromGird(grid, MPackStruct.eAttrExpiration)
	
	-- 装备强化等级
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	
	-- 装备战斗力
	local power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)
	
	-- 物品品质
	local quality = MpropOp.quality(protoId, grid)
	
	--------------------------------------------------------
	-- 更新数据
	local act_params = { root = root, grid = grid, packId = packId }
	local reloadData = function(gridObj)
		if gridObj == nil then return end
		
		grid = gridObj
		act_params.grid = grid
		
		--local new_gridId = MPackStruct.girdIdFromGird(grid)
		--if new_gridId ~= gridId then return end
		
		strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)
	end
	--------------------------------------------------------
	-- 物品名字
	Mnode.createLabel(
	{
		parent = root,
		src = MpropOp.name(protoId),
		color = color,
		anchor = cc.p(0, 0.5),
		pos = cc.p(26, 262 + addY),
		size = size,
	})
	
	-- 是否绑定
	Mnode.createLabel(
	{
		parent = root,
		src = isBind and (game.getStrByKey("already")..game.getStrByKey("theBind")) or (game.getStrByKey("not")..game.getStrByKey("theBind")),
		color = isBind and MColor.red or MColor.green,
		anchor = cc.p(0, 0.5),
		pos = cc.p(215, 262 + addY),
		size = size,
	})
	
	-- 物品等级
	local n_level = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = "LV.",
			size = size,
			color = color,
		}),
		
		v = {
			src = tostring(level),
			size = size,
			color = MRoleStruct:getAttr(ROLE_LEVEL) >= level and MColor.green or MColor.red,
		},
	})
	
	Mnode.addChild(
	{
		parent = root,
		child = n_level,
		anchor = cc.p(0, 0.5),
		pos = cc.p(290, 262 + addY),
	})
	
	-- 物品图标
	local icon = Mprop.new(
	{
		grid = grid,
		strengthLv = strengthLv,
	})

	Mnode.addChild(
	{
		parent = root,
		child = icon,
		pos = cc.p(68, 194 + addY),
	})

    local icon_size = icon:getContentSize()
    Mnode.createSprite(
    {
        src = "res/layers/bag/using.png",
        parent = icon,
        anchor = cc.p(0,1),
        pos = cc.p(0,icon_size.height),
        zOrder = 100,
    } )
	
	-- 使用职业
	local n_school = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("school").."：",
			size = size,
			color = color,
		}),
		
		v = {
			src = Mconvertor:school(school),
			size = size,
			color = (school~= Mconvertor.eWhole and school ~= MRoleStruct:getAttr(ROLE_SCHOOL)) and  MColor.red or MColor.green,
		},
	})

	-- 使用性别
	local n_sex = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("sex").."：",
			size = size,
			color = color,
		}),
		
		v = {
			src = Mconvertor:sexName(sex),
			size = size,
			color = (sex ~= Mconvertor.eSexWhole and sex ~= MRoleStruct:getAttr(PLAYER_SEX)) and  MColor.red or MColor.green,
		},
	})

	local n_school_pos = cc.p(136, 211 + addY)
	local n_sex_pos = cc.p(136, 176 + addY)
	
	local n_power = nil
	if isEquip or isMedal then
		n_school_pos = cc.p(116, 221 + addY)
		n_sex_pos = cc.p(116, 196 + addY)
		-- 装备类型
		Mnode.createLabel(
		{
			parent = root,
			src = game.getStrByKey("cate").."："..Mconvertor:equipName(MequipOp.kind(protoId)),
			color = color,
			size = size,
			anchor = cc.p(0, 0.5),
			pos = cc.p(116, 171 + addY),
		})
		
		-- 装备战斗力
		local n_power_bg = Mnode.createSprite(
		{
			parent = root,
			src = "res/common/bg/powerBg.png",
			child = n_power_bg,
			pos = cc.p(290, 190 + addY),
		})
		
		local n_power_bg_size = n_power_bg:getContentSize()
		
		n_power = Mnode.createKVP(
		{
			k = Mnode.createLabel(
			{
				src = game.getStrByKey("combat_power"),
				size = 25,
				color = color,
			}),
			
			v = {
				src = tostring(power), -- 10000000
				color = MColor.white,
				size = 22,
			},
			
			ori = "|",
			margin = 5,
		})
		
		Mnode.addChild(
		{
			parent = n_power_bg,
			child = n_power,
			pos = cc.p(n_power_bg_size.width/2, n_power_bg_size.height/2+10),
		})
	end
	
	Mnode.addChild(
	{
		parent = root,
		child = n_school,
		anchor = cc.p(0, 0.5),
		pos = n_school_pos,
	})
	
	Mnode.addChild(
	{
		parent = root,
		child = n_sex,
		anchor = cc.p(0, 0.5),
		pos = n_sex_pos,
	})
	
	--------------------------------------------------------
	-- 滚动区域
	local vSize = cc.size(338, 270)
    if params.bgType ~= 1 then
        vSize = cc.size(338, 128)
    end
	local cSize = cc.size(vSize.width, vSize.height) -- 不能写成 cSize = vSize
	
	local n_placeholder = Mnode.createColorLayer(
	{
		--src = cc.c4b(244 ,164 ,96, 255*0.5),
		src = cc.c4b(244 ,164 ,96, 255*0),
		cSize = cSize,
	})
	
	-- ScrollView
	local n_scroll = cc.ScrollView:create()
	n_scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	n_scroll:setClippingToBounds(true)
	--n_scroll:setBounceable(true)
	n_scroll:setViewSize(vSize)
	n_scroll:setContainer(n_placeholder)
	n_scroll:updateInset()
	--n_scroll:setContentOffset(cc.p(0, vSize.height - cSize.height))
    if params.bgType ~= 1 then
        Mnode.addChild(
	    {
		    parent = root,
		    child = n_scroll,
		    anchor = cc.p(0, 1),       
		    pos = cc.p(20, 140),
	    })
    else
	    Mnode.addChild(
	    {
		    parent = root,
		    child = n_scroll,
		    anchor = cc.p(0, 1),       
		    pos = cc.p(20, 367),
	    })
    end
	
	local refresh_content = function(parent, child) -- n_placeholder-n_content
		local content_tag = 1
		local n_content = parent:getChildByTag(content_tag)
		if n_content then removeFromParent(n_content) end
		
		local child_size = child:getContentSize()
		cSize.height = child_size.height
		parent:setContentSize(cSize)
		
		local parent_size = parent:getContentSize()
		n_content = Mnode.addChild(
		{
			parent = parent,
			child = child,
			anchor = cc.p(0, 1),
			pos = cc.p(0, parent_size.height), -- 对齐左上角
			tag = content_tag,
		})
	end
	--------------------------------------------------------
	-- 滚动区域内容
	local buildScrollContent = function()
		local nodes = {}
		
		if isEquip then			
			-- 构建基础属性节点
			local buildInfoNode = function(key, base, added, vs)
				local isRange = type(base) == "table"
				local now_see = vs.now_see
				local vs = vs.vs

				-- 这些情况对比持平
				if vs ~= nil and ((isRange and vs["["] == 0 and vs["]"] == 0) or (not isRange and vs == 0)) then vs = nil end			
				
                local hasBase = (isRange and base["]"] > 0) or (not isRange and base > 0)
                
                if vs ~= nil or hasBase then
					local nodes = {}
					nodes[#nodes+1] = Mnode.createLabel(
					{
						src = key,
						size = 18,
						color = MColor.lable_black,
						outline = false,
					})
								
					if vs ~= nil then
						local isGreen = (isRange and vs["]"] > 0) or (not isRange and vs > 0)
						nodes[#nodes+1] = Mnode.combineNode(
						{
							nodes = {
								Mnode.createSprite(
								{
									src = "res/group/arrows/" .. (isGreen and "1.png" or "2.png"),
								}),
								
								Mnode.createLabel(
								{
									src = isRange and (math.abs(vs["["]) .. "-" .. math.abs(vs["]"])) or math.abs(vs),
									size = 18,
									color = isGreen and MColor.green or MColor.red,
									outline = false,
								}),
							},
							
							margins = 0,
						})
                    else
                        nodes[#nodes+1] = Mnode.createLabel(
					    {
						    src = "--",
						    size = 18,
						    color = MColor.white,
						    outline = false,
					    })
					end
					
					return Mnode.combineNode(
					{
						nodes = nodes,
						margins = {0, 5, 2},
					})
				end

                return nil
			end
			
			-- 构建对比节点
			local calc_vs = function(grid, attr_name)
				if packId == MPackStruct.eDress then
					return { now_see = MPackStruct.attrFromGird(grid, attr_name) }
				end
				
		--[[		local protoId = MPackStruct.protoIdFromGird(grid)
				local now_dress_grid = nil
				
				local kind = MequipOp.kind(protoId)
				if kind == Mconvertor.eCuff then -- 护腕
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.eCuffLeft)
				elseif kind == Mconvertor.eRing then -- 戒指
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.eRingLeft)
				else
					now_dress_grid = dress:getGirdByGirdId(MPackStruct.dressId(kind))
				end
			]]	
				local now_see = MPackStruct.attrFromGird(params.compareGrid, attr_name)
				local now_dress = MPackStruct.attrFromGird(grid, attr_name)
				
				local ret = {}
				ret.now_see = now_see
				if type(now_see) == "table" then
					ret.vs = { ["["]= now_see["["]-now_dress["["], ["]"]= now_see["]"]-now_dress["]"] }
				else
					ret.vs = now_see-now_dress
				end

				return ret
			end

			-- 基础属性
			-- 标题
			local n_attr_title = Mnode.createLabel(
			{
				src = game.getStrByKey("attr_change").."：",
				size = size,
				color = color,
				outline = false,
			})
			
			table.insert(nodes, 1, n_attr_title)
			-------------------------------------
			local addAttrNode = function(title, attr_name1, attr_name2, base_func, grow_func)
				if attr_name2 then
					local n_tmp = buildInfoNode(title, MequipOp.combatAttr(protoId, attr_name2),
									            MequipOp.upStrengthCombatAttr(attr_name2, protoId, strengthLv), calc_vs(grid, attr_name1))
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				else
					local n_tmp = buildInfoNode(title, base_func(protoId), grow_func(protoId, strengthLv), calc_vs(grid, attr_name1))
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			end
			
			addAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, Mconvertor.ePAttack)
			addAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, Mconvertor.eMAttack)
			addAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, Mconvertor.eTAttack)
			addAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, Mconvertor.ePDefense)
			addAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, Mconvertor.eMDefense)
			addAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, nil, MequipOp.maxHP, MequipOp.upStrengthMaxHP)
			addAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, nil, MequipOp.maxMP, MequipOp.upStrengthMaxMP)
			addAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, nil, MequipOp.luck, MequipOp.upStrengthLuck)
			addAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, nil, MequipOp.hit, MequipOp.upStrengthHit)
			addAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, nil, MequipOp.dodge, MequipOp.upStrengthDodge)
			addAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, nil, MequipOp.strike, MequipOp.upStrengthStrike)
			addAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, nil, MequipOp.tenacity, MequipOp.upStrengthTenacity)
			addAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, nil, MequipOp.huShenRift, MequipOp.upStrengthHuShenRift)
			addAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, nil, MequipOp.huShen, MequipOp.upStrengthHuShen)
			addAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, nil, MequipOp.freeze, MequipOp.upStrengthFreeze)
			addAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, nil, MequipOp.freezeOppose, MequipOp.upStrengthFreezeOppose)
		end
		

		local n_content = Mnode.combineNode(
		{
			nodes = nodes,
			ori = "|",
			align = "l",
			margins = 10,
		})
		
		refresh_content(n_placeholder, n_content)
		n_scroll:updateInset() -- 调用它，否则滑动无动画
		n_scroll:setContentOffset(cc.p(0, vSize.height - cSize.height))
	end
	
    buildScrollContent()

	
--[[	
	local reloadView = function()
		buildScrollContent()
		icon:setStrengthLv(strengthLv)
		if n_power ~= nil then
			n_power:setValue({text = tostring(power)})
		end
	end
	
	--------------------------------------------------------
	-- tips 的刷新
	if (packId == MPackStruct.eBag or packId == MPackStruct.eDress) and isEquip then
		local dataSourceChanged = function(pack, event, id)
			if (id == gridId) and (event == "=" or event == "+") then
				local new_grid = pack:getGirdByGirdId(id)
				reloadData(new_grid)
				reloadView()
			end
		end
		
		-- 用root:registerScriptHandler方式调用 ios debug 版本不知什么原因会报错
		root.registerScriptHandler(root, function(event)
			local pack = MPackManager:getPack(packId)
			if event == "enter" then
				pack:register(dataSourceChanged)
			elseif event == "exit" then
				pack:unregister(dataSourceChanged)
			end
		end)
	end
]]	
	return root
	--------------------------------------------------------
end }

