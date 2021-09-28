require("src/layers/newEquipment/NewEquipmentHandler")
local reloadView = function(root, ds)
	local MpropOp = require "src/config/propOp"
	local Mprop = require "src/layers/bag/prop"
	local MequipOp = require "src/config/equipOp"
	local Mconvertor = require "src/config/convertor"
	-----------------------------------------------------------------------
	local layer = root.layer
	local tf_tips = root.tf_tips
	layer:removeAllChildren()
	local layer_size = layer:getContentSize()
	if tf_tips then
		if ds.now_item then
			tf_tips:setVisible(false)
			root.n_material:setVisible(true)
			root.m_bubble:setVisible(false)
		else
			tf_tips:setVisible(true)
			root.n_material:setVisible(false)
			root.m_bubble:setVisible(true)
		end
	end
	if ds.now_item == nil then 
		return 
	end
	--------------------------------------------------------
	if ds.isRUL then
		Mnode.createLabel(
		{
			parent = layer,
			src = "已经强化到顶级",
			size = 20,
			anchor = cc.p(0, 1),
			pos = cc.p(535, 180),
			color = MColor.green,
		})
	end
	--------------------------------------------------------------
	-- 物品图标
	
	

	local n_icon = Mprop.new(
	{
		grid = ds.now_item.grid,
		strengthLv = ds.strengthLv,
	})

	MpropOp.createColorName(ds.now_item.grid, layer, cc.p(605, 200), cc.p(0.5,0.5), 22)

	Mnode.addChild(
	{
		parent = layer,
		child = n_icon,
		pos = cc.p(608, 265),
	})
	-------------------------------------------------------------------------------
	local buildVsNode = function(key, value, increment)
		--dump({key=key, value=value, increment=increment})
		
		local nodes = {}
		local n_key = Mnode.createLabel(
		{
			src = tostring(key),
			size = 20,
			color = MColor.lable_black,
		})
		
		nodes[#nodes+1] = n_key
		
		local n_value = Mnode.createLabel(
		{
			src = tostring(value),
			size = 20,
			color = MColor.lable_yellow,
		})
		
		nodes[#nodes+1] = n_value
		
		if increment ~= nil and increment ~= "" then
			local n_increment = Mnode.createLabel(
			{
				src = tostring(increment),
				size = 20,
				color = MColor.green,
			})
			
			nodes[#nodes+1] = n_increment
		end
		
		return Mnode.combineNode(
		{
			nodes = nodes,
			margins = {5, 10},
		})
	end
	
	local protoId = ds.protoId
	local strengthLv = ds.strengthLv
	--local lvRUL = MequipOp.upStrengthRUL(protoId, ds.quality)
	local isRUL = ds.isRUL
	
	local buildVsData = function(isRange, attr_name, base_func, qh_func)
		local base, now_qh, next_qh = nil, nil, nil
		
		base = base_func(protoId, attr_name)
		
		if (isRange and base["]"] == 0) or (not isRange and base == 0) then
			return false
		end
		
		now_qh = isRange and qh_func(attr_name, protoId, strengthLv) or qh_func(protoId, strengthLv)
		next_qh = not isRUL and (isRange and qh_func(attr_name, protoId, strengthLv + 1) or qh_func(protoId, strengthLv + 1)) or nil
		
		local ret1, ret2 = "", ""
		
		if isRange then
			base["["] = base["["] + now_qh["["]
			base["]"] = base["]"] + now_qh["]"]
			
			ret1 = ret1 .. base["["] .. "-" .. base["]"]
			if next_qh ~= nil then
				ret2 = ret2 .. "(+" .. (next_qh["["] - now_qh["["]) .. "-" .. (next_qh["]"] - now_qh["]"]) .. ")"
			end
		else
			base = base + now_qh
			ret1 = ret1 .. base
			if next_qh ~= nil then
				ret2 = ret2 .. "(+" .. (next_qh - now_qh) .. ")"
			end
		end
		
		return true, ret1, ret2
	end
	--------------------------------
	local nodes = {}
	
	-- 强化等级
	local n_tmp_node = buildVsNode("强化等级: ", tostring(strengthLv), not isRUL and "(+1)" or nil)
	table.insert(nodes, 1, n_tmp_node)
	
	-- 基础属性
	local cfg = {
		{key = game.getStrByKey("physical_attack_s") .. ": ", isRange = true, attr_name = Mconvertor.ePAttack, base_func = MequipOp.combatAttr, qh_func = MequipOp.upStrengthCombatAttr,},
		{key = game.getStrByKey("magic_attack_s") .. ": ", isRange = true, attr_name = Mconvertor.eMAttack, base_func = MequipOp.combatAttr, qh_func = MequipOp.upStrengthCombatAttr,},
		{key = game.getStrByKey("taoism_attack_s") .. ": ", isRange = true, attr_name = Mconvertor.eTAttack, base_func = MequipOp.combatAttr, qh_func = MequipOp.upStrengthCombatAttr,},
		{key = game.getStrByKey("physical_defense_s") .. ": ", isRange = true, attr_name = Mconvertor.ePDefense, base_func = MequipOp.combatAttr, qh_func = MequipOp.upStrengthCombatAttr,},
		{key = game.getStrByKey("magic_defense_s") .. ": ", isRange = true, attr_name = Mconvertor.eMDefense, base_func = MequipOp.combatAttr, qh_func = MequipOp.upStrengthCombatAttr,},
		{key = game.getStrByKey("hp") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.maxHP, qh_func = MequipOp.upStrengthMaxHP,},
		{key = game.getStrByKey("mp") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.maxMP, qh_func = MequipOp.upStrengthMaxMP,},
		{key = game.getStrByKey("luck") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.luck, qh_func = MequipOp.upStrengthLuck,},
		{key = game.getStrByKey("my_hit") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.hit, qh_func = MequipOp.upStrengthHit,},
		{key = game.getStrByKey("dodge") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.dodge, qh_func = MequipOp.upStrengthDodge,},
		{key = game.getStrByKey("strike") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.strike, qh_func = MequipOp.upStrengthStrike,},
		{key = game.getStrByKey("my_tenacity") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.tenacity, qh_func = MequipOp.upStrengthTenacity,},
		{key = game.getStrByKey("hu_shen_rift") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.huShenRift, qh_func = MequipOp.upStrengthHuShenRift,},
		{key = game.getStrByKey("hu_shen") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.huShen, qh_func = MequipOp.upStrengthHuShen,},
		{key = game.getStrByKey("freeze") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.freeze, qh_func = MequipOp.upStrengthFreeze,},
		{key = game.getStrByKey("freeze_oppose") .. ": ", isRange = false, attr_name = nil, base_func = MequipOp.freezeOppose, qh_func = MequipOp.upStrengthFreezeOppose,},
	}
	
	for i = 1, #cfg do
		local cur = cfg[i]
		local exist, value, increment = buildVsData(cur.isRange, cur.attr_name, cur.base_func, cur.qh_func)
		if exist then
			local n_tmp_node = buildVsNode(cur.key, value, increment)
			table.insert(nodes, 1, n_tmp_node)
		end
	end
	
	-- 强化附加属性
	local tJihuo = MequipOp.qiangHuaJiHuo(protoId)
	--dump(tJihuo, "tJihuo")
	if type(tJihuo) == "table" then
		local tJihuo_s = {}
		for lv, record in pairs(tJihuo) do
			if type(record) ~= "table" then break end
			
			local k, v = nil, nil
			for kk, vv in pairs(record) do
				k = kk
				v = vv
			end
			tJihuo_s[#tJihuo_s+1] = {lv=lv, k=k, v=v}
		end
		table.sort(tJihuo_s, function(a, b)
			return a.lv < b.lv
		end)
		--dump(tJihuo_s, "tJihuo_s")
		
		local next_jh_lv = nil
		local title_added = false
		local key, value, increment = nil, nil, nil
		for i = 1, #tJihuo_s do
			local cur = tJihuo_s[i]
			local lv, k, v = cur.lv, cur.k, cur.v
			--dump(cur, "cur")
			
			if type(v) ~= "table" then
				dump(tJihuo, "强化附加属性配置表出错")
			else
				key = Mconvertor.attrName(k) .. ": "
				value = tostring(v[1])
			
				if v[2] ~= nil then 
					value = value .. "-" .. tostring(v[2])
				end
				
				if strengthLv >= lv then
					if not title_added then
						title_added = true
						
						-- 标题
						local n_attr_title = Mnode.createLabel(
						{
							src = "附加属性" .. "：",
							size = 20,
							color = MColor.lable_yellow,
							outline = false,
						})
						
						table.insert(nodes, 1, n_attr_title)
					end
					--------------------------------------------
					local n_tmp_node = buildVsNode(key, value, increment)
					table.insert(nodes, 1, n_tmp_node)
				else
					next_jh_lv = lv
					break
				end
			end
		end
		
		if next_jh_lv ~= nil then
			local tmp_nodes = {}
			local n_tips = Mnode.createLabel(
			{
				src = "强化等级达到" .. tostring(next_jh_lv) .. "级激活附加属性",
				size = 20,
				color = MColor.red,
			})
			table.insert(tmp_nodes, 1, n_tips)
			
			local n_next_jh = buildVsNode(key, value, nil)
			table.insert(tmp_nodes, 1, n_next_jh)
			
			local n_tmp_node = Mnode.combineNode(
			{
				nodes = tmp_nodes,
				ori = "|",
				align = "l",
				margins = 5,
			})
			
			Mnode.addChild(
			{
				parent = layer,
				child = n_tmp_node,
				anchor = cc.p(0, 1),
				pos = cc.p(50, 100),
			})
		end
	end
	
	local content = Mnode.combineNode(
	{
		nodes = nodes,
		ori = "|",
		align = "l",
		margins = 5,
	})
	
	Mnode.addChild(
	{
		parent = layer,
		child = content,
		anchor = cc.p(0, 1),
		pos = cc.p(50, 420),
	})
end

return { new = function(params)

-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
-----------------------------------------------------------------------
local res = "res/layers/equipment/strengthen/"
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
-- 数据
local ds = {} --data source

local reloadData = nil
local onReloadData = nil
reloadData = function(ds, now_item)
	table.clear(ds)
	ds.reloadData = reloadData
	ds.material = {rate = 0, coin = 0, bag = {}, view={}} --view: {[1] = {pos=bag_pos, protoId=protoId}} bag: {[pos] = {num=num, protoId=protoId}}
	
	if now_item == nil then return end
	
	local aux_func = function(now_item)
		local m = Myoung.beginFunction()
		--------------------------------------------
		local MpropOp = require "src/config/propOp"
		local MequipOp = require "src/config/equipOp"
		--------------------------------------------
		m.now_item = now_item
		packId = now_item.packId
		--pack = MPackManager:getPack(packId)
		local grid = now_item.grid
		gridId = MPackStruct.girdIdFromGird(grid)
		protoId = MPackStruct.protoIdFromGird(grid)
		strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		quality = MpropOp.quality(protoId, grid)
		isRUL = MequipOp.isStrengthRUL(protoId, strengthLv, quality)
		--------------------------------------------
		return m
	end
	
	local m = aux_func(now_item)
	for k, v in pairs(m) do
		ds[k] = v
	end
end

reloadData(ds, params.packId ~= nil and {packId=params.packId, grid=params.grid} or nil)

--dump(ds, "ds")

-- 计算成功率
local calc_success_probability = function(ds, data)
	if ds.now_item == nil then return 0, 0 end
	
	local weight = 0
	for k, v in pairs(data) do
		local purity = MpropOp.purity(v.protoId)
		weight = weight + math.pow(2, purity-1) * v.num
	end
	--dump(weight, "weight")
	local cur_lv = ds.strengthLv
	if cur_lv >= 10 then
		cur_lv = cur_lv - 10
	end
	
	local total_weight = 5 * math.pow(2, cur_lv)
	
	--dump(total_weight, "total_weight")
	
	local rate = math.floor(weight/total_weight * 100)
	--dump(rate, "rate")
	local nRealRate = rate;
	if rate > 100 then rate = 100 end
	
	local cost_coin = MequipOp.upStrengthCoinNeed(ds.protoId, ds.strengthLv+1)
	local coin = cost_coin * rate
	
	return rate, coin, nRealRate
end
-----------------------------------------------------------------------
-- 前置声明
local one_key_put_material = nil
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -10, y = 4 },
	},
	title = {
		src = game.getStrByKey("strengthen"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

root:registerScriptHandler(function(event)
	if event == "enter" then
		clearDirect()
		setEquipRedirect(true)
	elseif event == "exit" then
		trigEquipRedirect()
	end
end)

G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_STRENGTHEN_CLOSE)

local rootSize = root:getContentSize()
-----------------------------------------------------------------------------------
local center = cc.p(rootSize.width/2+2, rootSize.height/2-20)
-- 背景图
createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )

local left_bg = Mnode.createScale9Sprite(
{
	parent = root,
	src = "res/common/scalable/panel_inside_scale9.png",
	cSize = cc.size(360, 436),
	pos = cc.p(220, center.y),
})

local right_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg70.png",
	pos = cc.p(610, center.y),
})

local right_bg_size = right_bg:getContentSize()



local separator = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg27-2.png",
	pos = cc.p(220, 110),
})

---[[
-- 帮助按钮
local n_prompt = __createHelp(
{
	parent = right_bg,
	str = require("src/config/PromptOp"):content(67),
	pos = cc.p(370, 130),
})

--n_prompt:setScale(1)
--]]
-----------------------------------------------------------------------------------
-- 一键放入按钮
local n_onekey_menu, n_onekey_btn = MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
	label = {
		src = "一键放入",
		size = 25,
		color = MColor.lable_yellow,
	},
	
	pos = cc.p(530, 62),
	
	cb = function(tag, node)
		if ds.now_item == nil then
			TIPS({ type = 1  , str = "请先放入需要强化的装备" })
			return
		end
		
		if ds.isRUL then
			TIPS({ type = 1  , str = "该装备已强化到顶级" })
			node:setEnabled(false)
			return
		end
		
		one_key_put_material(ds)
	end,
	
	noInsane = 0.5,
})

n_onekey_btn:setEnabled(ds.now_item ~= nil)

-- 强化按钮
local n_click_menu, n_click_btn = MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
	label = {
		src = "开始强化",
		size = 25,
		color = MColor.lable_yellow,
	},
	
	pos = cc.p(690, 62),
	
	cb = function(tag, node)
		if ds.now_item == nil then
			TIPS({ type = 1  , str = "请先放入需要强化的装备" })
			return
		end
		
		if ds.isRUL then
			TIPS({ type = 1  , str = "该装备已强化到顶级" })
			return
		end
        --概率过低，提示无法操作
        if ds.material.rate<=0 then
            TIPS({ type = 1  , str = getConfigItemByKeys("clientmsg",{"sth","mid"},{5000,-59}).msg })
			return
        end

        local function funcDo( ... )
        	-- body
        	local material = {}
			local bag_d = ds.material.bag
			for k, v in pairs(bag_d) do
				local item = {}
				item.bagPos = k
				item.num = v.num
				material[#material+1] = item
			end
			MPackManager:upStrengthEquip(ds.packId, ds.gridId, material)
			root.m_bubbleMeterial:setVisible(true)
			root.m_bubbleTooLow:setVisible(false)
        end
        
        

    	local function funcTip( ... )
    		-- body
    		local tempLayer = nil
	    	if DATA_Mission.no_stren_tip and DATA_Mission.no_stren_tip == 1 then
	    		return funcDo()
	    	else
	    		if ds.material.nRealRate >= 120 then
		        	--概率过高
		        	tempLayer = MessageBoxYesNo("","强化概率过高("..ds.material.nRealRate.."%)是否继续？", funcDo, nil)
		        elseif ds.material.nRealRate <= 40 then
		        	--概率过低
		        	tempLayer = MessageBoxYesNo("","强化概率过低("..ds.material.nRealRate.."%)，使用高级矿石可提升成功率，是否继续？", funcDo, nil)
		        else
		        	return funcDo()
		        end
	    	end
	    	local no_selectBtn, selectBtn

	    	local selectFun = function(value)
	    		DATA_Mission.no_stren_tip = value
	    		selectBtn:setVisible(DATA_Mission.no_stren_tip ~= 0)
			end

	    	no_selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1.png" , cc.p( 170 , 110 ) , function() selectFun( 1 ) end )
	    	selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1-1.png" , cc.p( 170 , 110 ) , function() selectFun( 0 ) end )
	    	createLabel( tempLayer , game.getStrByKey("ping_btn_no_more")  , cc.p(195 , 110 ) , cc.p( 0 , 0.5 ) , 20 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
	    	selectBtn:setVisible( DATA_Mission.no_stren_tip and DATA_Mission.no_stren_tip == 1 )
    	end
    	
    	funcTip()
        

        
		
	end,
	
	noInsane = 1, -- 禁止丧心病狂式的点击
})

n_click_btn:setEnabled(false)

G_TUTO_NODE:setTouchNode(n_click_menu, TOUCH_STRENGTHEN_USE)
G_TUTO_NODE:setTouchNode(n_onekey_menu, TOUCH_STRENGTHEN_ADDTOOLS)
------------------------------------------------------------------
-- 强化成功率
local n_rate_tips = Mnode.createLabel(
{
	parent = root,
	src = "强化成功率: 100%",
	pos = cc.p(608, 160),
	size = 20,
	color = MColor.lable_yellow,
	hide = true
})

-- 加号
Mnode.createSprite(
{
	parent = root,
	src = "res/layers/equipment/jia.png",
	pos = cc.p(608, 265),
})

local placeholder = Mnode.createNode(
{
	parent = root,
	cSize = cc.size(80, 80),
	pos = cc.p(608, 265),
})

G_TUTO_NODE:setTouchNode(placeholder, TOUCH_STRENGTHEN_ADDWEAPON)
-- 提示信息
local n_jia_tips = Mnode.createLabel(
{
	parent = root,
	src = "选择需要强化的装备",
	pos = cc.p(608, 200),
	size = 20,
	color = MColor.lable_yellow,
})

n_jia_tips:setVisible(ds.now_item == nil)

-- 强化预览
Mnode.createLabel(
{
	parent = root,
	src = "强化预览",
	pos = cc.p(220, 440),
	size = 20,
	color = MColor.lable_yellow,
})

-- 强化预览
root.tf_tips = Mnode.createLabel(
{
	parent = root,
	src = "请点击右侧加号选择需要强化的装备",
	pos = cc.p(220, 400),
	size = 20,
	color = MColor.lable_yellow,
})

--uiParent, stPos, stAnchor, stPadding, strContent, stFontSize, isOutLine, fontName, fontColor
root.m_bubble = GetUIHelper():createBubble(root, cc.p(608, 330), cc.p(0.5, 0.5), nil, "请添加要强化的装备", 20, false, nil, MColor.lable_yellow, true)

-----------------------------------------------------------------------
-- 消耗金币
local n_cost = Mnode.createColorLayer(
{
	src = cc.c4b(0 ,0 ,0, 0),
	--src = cc.c4b(244 ,164 ,96, 255*0.5),
	cSize = cc.size(325, 30),
})

local own_coin = MRoleStruct:getAttr(PLAYER_MONEY)
local n_coin_node = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "消耗金币: ",
		size = 19,
		color = MColor.lable_yellow,
	}),
	
	v = {
		src = "0", --numToFatString(cost_coin),
		size = 19,
		color = MColor.green,
	}
})

Mnode.addChild(
{
	parent = n_cost,
	child = n_coin_node,
	anchor = cc.p(0, 0.5),
	pos = cc.p(5, 15),
})

-- 拥有金币数目
local n_own_coin = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "拥有: ",
		size = 19,
		color = MColor.lable_yellow,
	}),
	
	v = {
		src = numToFatString(own_coin),
		size = 19,
		color = MColor.lable_yellow,
	},
})
local function updateStrengthCostMoneyColor()
	local strColor=MColor.green
	if n_coin_node.costMoeny and MRoleStruct:getAttr(PLAYER_MONEY)<n_coin_node.costMoeny then
		strColor=MColor.red
	end
	n_coin_node:setValue({ color=strColor })
end
-- 货币数值发生了变化
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if not isMe then return end
	if attrId == PLAYER_MONEY then
		n_own_coin:setValue({ text = numToFatString(MRoleStruct:getAttr(PLAYER_MONEY)) })
		updateStrengthCostMoneyColor()
	end
end

n_own_coin:registerScriptHandler(function(event)
	if event == "enter" then
		MRoleStruct:register(onDataSourceChanged)
	elseif event == "exit" then
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)

Mnode.addChild(
{
	parent = n_cost,
	child = n_own_coin,
	anchor = cc.p(0, 0.5),
	pos = cc.p(5+160, 15),
})

Mnode.addChild(
{
	parent = root,
	child = n_cost,
	anchor = cc.p(0, 0.5),
	pos = cc.p(458, 125),
})
-----------------------------------------------------------------------
-- 选择消耗的材料
local material_nodes = {}

local removeMaterialIcon = function(i)
	local itemBg = material_nodes[i]
	local n_icon = itemBg:getChildByTag(1)
	if n_icon ~= nil then n_icon:removeFromParent() end
	
	local n_purity = itemBg:getChildByTag(2)
	if n_purity ~= nil then n_purity:setVisible(false) end
end

local addMaterialIcon = function(i, protoId)
	local itemBg = material_nodes[i]
	local itemBgSize = itemBg:getContentSize()
	
	local n_icon = itemBg:getChildByTag(1)
	if n_icon ~= nil then n_icon:removeFromParent() end
	
	n_icon = Mprop.new(
	{
		protoId = protoId,
	})
	
	n_icon:setScale(0.92)

	Mnode.addChild(
	{
		parent = itemBg,
		child = n_icon,
		pos = cc.p(itemBgSize.width/2, itemBgSize.height/2),
		tag = 1,
	})
	
	local n_purity = itemBg:getChildByTag(2)
	if n_purity ~= nil then
		n_purity:setString("纯度" .. MpropOp.purity(protoId))
		n_purity:setVisible(true)
	end
end

--消耗金币
local on_update_material = function()
	n_rate_tips:setString("强化成功率: " .. tostring(ds.material.rate) .. "%")
	n_coin_node.costMoeny=ds.material.coin
	n_coin_node:setValue({ text = numToFatString(ds.material.coin) })
	updateStrengthCostMoneyColor()
	if table.size(ds.material.view) > 0 then
		n_rate_tips:setVisible(true)
		n_click_btn:setEnabled(true)
		root.m_bubbleMeterial:setVisible(false)

		if ds.material.rate <= 40 then
			root.m_bubbleTooLow:setVisible(true)
		else
			root.m_bubbleTooLow:setVisible(false)
		end
	else
		n_rate_tips:setVisible(false)
		n_click_btn:setEnabled(false)
		root.m_bubbleMeterial:setVisible(true)
		root.m_bubbleTooLow:setVisible(false)
	end
end

local put_material = function(i, data)
	---------------------------------------------------
	if ds.now_item == nil then return end
	---------------------------------------------------
	local view_d = ds.material.view
	local bag_d = ds.material.bag
	
	-- 该视图位置已经放入东西
	if view_d[i] ~= nil then
		local old_pos = view_d[i].pos
		if bag_d[old_pos] ~= nil then
			bag_d[old_pos].num = bag_d[old_pos].num - 1
			if bag_d[old_pos].num < 1 then
				bag_d[old_pos] = nil
			end
		end
	end
	
	view_d[i] = data
	
	local bag_pos_d = bag_d[data.pos]
	if bag_pos_d == nil then
		bag_d[data.pos] = {num = 1, protoId = data.protoId}
	elseif data.protoId == bag_pos_d.protoId then
		bag_pos_d.num = bag_pos_d.num + 1
	end
	---------------------------------------------------
	addMaterialIcon(i, data.protoId)
	ds.material.rate, ds.material.coin, ds.material.nRealRate = calc_success_probability(ds, ds.material.bag)
	on_update_material()
end

local get_material = function(i)
	---------------------------------------------------
	if ds.now_item == nil then return end
	---------------------------------------------------
	local view_d = ds.material.view
	local bag_d = ds.material.bag
	
	local cur = view_d[i]
	if cur == nil then return end
	---------------------------------------------------
	local bag_pos_d = bag_d[cur.pos]
	if bag_pos_d ~= nil then
		bag_pos_d.num = bag_pos_d.num - 1
		if bag_pos_d.num < 1 then
			bag_d[cur.pos] = nil
		end
	end
	
	view_d[i] = nil
	---------------------------------------------------
	removeMaterialIcon(i)
	ds.material.rate, ds.material.coin, ds.material.nRealRate = calc_success_probability(ds, ds.material.bag)
	on_update_material()
end

local function get5Material_ex( list )
	-- body
	local tmp_view = {}
	local tmp_bag = {}
	local rate, coin = 0, 0

	for i = 1, #list do
		local cur = list[i]
		local num = cur.num
		
		local isOk = false
		
		for j = 1, num do
			if #tmp_view >= 5 then break end
			
			local item = {pos = cur.bag_pos, protoId = cur.protoId}
			tmp_view[#tmp_view+1] = item
			
			local now_exit = tmp_bag[cur.bag_pos]
			if now_exit == nil then
				tmp_bag[cur.bag_pos] = {num = 1, protoId = cur.protoId}
			else
				tmp_bag[cur.bag_pos].num = tmp_bag[cur.bag_pos].num + 1
			end
			
			rate, coin = calc_success_probability(ds, tmp_bag)
			if rate >= 100 then
				isOk = true
				break
			end
		end
		
		if #tmp_view >= 5 then break end
		if isOk then break end
	end

	return tmp_view, tmp_bag, rate, coin
end

--第一个变成最后一个
local function first2last( vector )
	-- body
	if #vector <= 1 then
		return vector
	end
	local pFirst = vector[1]
	table.remove(vector, 1)
	table.insert(vector, pFirst)
	return vector
end

local function get5Material( list )
	-- body
	local tmp_view, tmp_bag, rate, coin
	for i=1,#list-1 do
		tmp_view, tmp_bag, rate, coin = get5Material_ex(list)
		if rate < 100 then
			list = first2last(list)
		else
			break
		end
	end
	return tmp_view, tmp_bag, rate, coin
end

local function expandList( list )
	-- body
	--把list展开
	local vAll = {}
	local nUid = 1
	for _,cur in ipairs(list) do
		local num = cur.num		
		for j = 1, num do
			local item = {pos = cur.bag_pos, protoId = cur.protoId, nUid = nUid}
			nUid = nUid + 1
			table.insert(vAll, item)
		end
	end

	--所有材料按照纯度从小到大排序
	table.sort(vAll, function( a, b )
		-- body
		local nProtoA = a.protoId
		local nProtoB = b.protoId
		if nProtoA == nProtoB then
			return a.nUid < b.nUid
		end
		return nProtoA < nProtoB
	end)

	return vAll
end

--尽可能少的数量，达到100%
local function getLeast( tmp_view_, tmp_bag_, rate_, coin_, nRealRate_ )
	-- body
	--tmp_view是有序的，所以从左到右依次删除一个，直到100%以下就停止
	local nNum = #tmp_view_
	if nNum <= 1 then
		return tmp_view_, tmp_bag_, rate_, coin_, nRealRate_
	end

	--用从第一个开始进行运算，直到1个数量进行运算
	local rate, coin, nRealRate = rate_, coin_, nRealRate_
	local tmp_bag = tmp_bag_

	local nIndex = 0
	--总共需要测试nNum-1次
	for i=1, nNum-1 do
		local tmp_bag_ex = {}

		--从第i个开始，到nnum个之间进行运算
		for j=i + 1,nNum do
			local item = tmp_view_[j]
			local now_exsit = tmp_bag_ex[item.pos]
			if now_exsit == nil then
				tmp_bag_ex[item.pos] = {num = 1, protoId = item.protoId}
			else
				tmp_bag_ex[item.pos].num = tmp_bag_ex[item.pos].num + 1
			end
		end
		local tmpRate, tmpCoin, tmpRealRate = calc_success_probability(ds, tmp_bag_ex)
		if tmpRate < 100 then
			break
		else
			rate, coin, nRealRate = tmpRate, tmpCoin, tmpRealRate
			tmp_bag = tmp_bag_ex
			nIndex = i + 1
		end
	end
	for i=nIndex-1,1,-1 do
		table.remove(tmp_view_, 1)
	end
	return tmp_view_, tmp_bag, rate, coin, nRealRate
end

--展开的数组，要取几个值，从哪个下表开始
local function get5MaterialIntelligent_ex( vAll, nNum, nStartIndex )
	-- body
	if not nStartIndex then
		nStartIndex = 1
	end

	local tmp_view = {}
	local tmp_bag = {}
	local rate, coin, nRealRate = 0, 0, 0
	local isOk = false
	for i,item in ipairs(vAll) do

		if i >= nStartIndex then

			table.insert(tmp_view, item)
			local now_exit = tmp_bag[item.pos]
			if now_exit == nil then
				tmp_bag[item.pos] = {num = 1, protoId = item.protoId}
			else
				tmp_bag[item.pos].num = tmp_bag[item.pos].num + 1
			end
			
			rate, coin, nRealRate = calc_success_probability(ds, tmp_bag)
			if rate >= 100 then


				tmp_view, tmp_bag, rate, coin, nRealRate = getLeast(tmp_view, tmp_bag, rate, coin, nRealRate)
				isOk = true
				break
			end
			
			if #tmp_view >= nNum then break end
			if isOk then break end
		end
	end

	return tmp_view, tmp_bag, rate, coin, nRealRate

end



local function get5MaterialIntelligent( list, nNum )
	-- body

	local vAll = expandList(list)
	if not nNum then
		nNum = 5
	end

	--{1,1,1,2,2,3,3,4,4...}此时排序大概是这样（数字单表矿石纯度）
	--策略是这样：从第一个开始取5个，如果不足100，那么就从第二个开始取，如果到倒数第5个那就停止（如果本身大小不足5个，直接返回）
	if #vAll <= nNum then
		return get5MaterialIntelligent_ex(vAll, nNum)
	end
	local tmp_view, tmp_bag, rate, coin, nRealRate
	local nStartIndex = 1
	repeat
		tmp_view, tmp_bag, rate, coin, nRealRate = get5MaterialIntelligent_ex(vAll, nNum, nStartIndex)
        nStartIndex = nStartIndex + 1
		if rate >= 100 then
			break
		end
	until(nStartIndex > #vAll - nNum)
	return tmp_view, tmp_bag, rate, coin, nRealRate
end

one_key_put_material = function(ds)
	---------------------------------------------------
	if ds.now_item == nil then return end
	---------------------------------------------------
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local bag_list = bag:categoryList(MPackStruct.eOther)
	
	local list = {}
	for i, v in ipairs(bag_list) do
		local protoId = MPackStruct.protoIdFromGird(v)
		if (ds.strengthLv < 10 and protoId >= 1301 and protoId <= 1310) or (ds.strengthLv >= 10 and protoId >= 1401 and protoId <= 1410) then
			local gridId = MPackStruct.girdIdFromGird(v)
			local num = MPackStruct.overlayFromGird(v)
			list[#list+1] = { bag_pos = gridId, num = num, protoId = protoId }
		end
	end
	table.sort(list, function(a, b)
		--a
		local a_protoId = a.protoId
		--local a_purity = MpropOp.purity(a_protoId)
		
		--b
		local b_protoId = b.protoId
		--local b_purity = MpropOp.purity(b_protoId)
		
		return  a_protoId < b_protoId
	end)
	
	--dump(list, "list")
	
	if #list == 0 then
		TIPS({ type = 1  , str = "没有可供放入的材料" })
		return
	end
	
	local tmp_view = {}
	local tmp_bag = {}
	local rate, coin, nRealRate = 0, 0, 0
	
	tmp_view, tmp_bag, rate, coin, nRealRate = get5MaterialIntelligent(list)
	
	--dump({tmp_view=tmp_view, tmp_bag=tmp_bag})
	
	ds.material.view = tmp_view
	ds.material.bag = tmp_bag
	ds.material.rate = rate
	ds.material.coin = coin
	ds.material.nRealRate = nRealRate
	for i = 1, 5 do
		local cur = tmp_view[i]
		removeMaterialIcon(i)
		if cur ~= nil then addMaterialIcon(i, cur.protoId) end
	end
	
	
	on_update_material()
end

local one_key_get_material = function(ds)
	---------------------------------------------------
	if ds.now_item == nil then return end
	---------------------------------------------------
	local view_d = ds.material.view
	local bag_d = ds.material.bag
	
	table.clear(view_d)
	table.clear(bag_d)
	ds.material.rate = 0
	ds.material.coin = 0
	ds.material.nRealRate = 0
	for i = 1, 5 do
		removeMaterialIcon(i)
	end
	
	n_rate_tips:setVisible(false)
	n_coin_node:setValue({ text = "0" })
	n_click_btn:setEnabled(false)
end

for i = 1, 5 do
	local itemBg = cc.Sprite:create("res/common/bg/itemBg3.png")
	local itemBgSize = itemBg:getContentSize()
	-- 加号
	Mnode.createSprite(
	{
		parent = itemBg,
		src = "res/layers/equipment/jia.png",
		pos = cc.p(itemBgSize.width/2, itemBgSize.height/2),
	})
	
	local n_purity = Mnode.createLabel(
	{
		parent = itemBg,
		src = "纯度10",
		pos = cc.p(itemBgSize.width/2, -20),
		size = 18,
		color = MColor.lable_yellow,
		hide = true,
		tag = 2,
	})
	
	--[[
	-- 物品图标
	local n_icon = Mprop.new(
	{
		protoId = 5010604,
	})
	
	n_icon:setScale(0.92)

	Mnode.addChild(
	{
		parent = itemBg,
		child = n_icon,
		pos = cc.p(itemBgSize.width/2, itemBgSize.height/2),
		tag = 1,
	})
	
	--]]
	
	material_nodes[#material_nodes+1] = itemBg
	
	-- 监听触摸事件
	Mnode.listenTouchEvent(
	{
		swallow = false,
		node = itemBg,
		begin = function(touch, event)
			local node = event:getCurrentTarget()
			if node.catch then return false end
		
			local inside = Mnode.isTouchInNodeAABB(node, touch)
			if inside then
				return true
			end
			
			return false
		end,
		
		ended = function(touch, event)
			local node = event:getCurrentTarget()
			node.catch = false
			
			if Mnode.isTouchInNodeAABB(node, touch) then
				AudioEnginer.playTouchPointEffect()
				
				if ds.now_item == nil then
					TIPS({ type = 1  , str = "请先放入需要强化的装备" })
					return
				end
				
				if ds.isRUL then
					TIPS({ type = 1  , str = "该装备已强化到顶级" })
					return
				end
				
				if ds.material.view[i] ~= nil then
					get_material(i)
				else
					local Mreloading = require "src/layers/equipment/material_reloading"
					local Manimation = require "src/young/animation"
					Manimation:transit(
					{
						node = Mreloading.new(
						{
							filtrate = function(packId, grid)
								local protoId = MPackStruct.protoIdFromGird(grid)
								if not ((ds.strengthLv < 10 and protoId >= 1301 and protoId <= 1310) or (ds.strengthLv >= 10 and protoId >= 1401 and protoId <= 1410)) then
									return false
								end
								
								local gridId = MPackStruct.girdIdFromGird(grid)
								local num = MPackStruct.overlayFromGird(grid)
								
								local bag_d = ds.material.bag
								--dump(gridId, "gridId")
								--dump(bag_d, "bag_d")
								if bag_d[gridId] then
									local remain = num - bag_d[gridId].num
									if remain > 0 then
										return true, remain
									else
										return false
									end
								else
									return true, num
								end
								
								return false
							end,
							handler = function(item)
								put_material(i, {pos = MPackStruct.girdIdFromGird(item.grid), protoId=MPackStruct.protoIdFromGird(item.grid)})
							end,
							
							act_src = "放入",
						}),
						sp = g_scrCenter,
						ep = g_scrCenter,
						--trend = "-",
						zOrder = 200,
						curve = "-",
						swallow = true,
					})
				end
			end
		end,
	})
end

local n_material = Mnode.combineNode(
{
	nodes = material_nodes,
	margins = 12,
})

n_material:setVisible(false)
root.n_material = n_material
root.m_bubbleMeterial = GetUIHelper():createBubble(n_material, cc.p(200, -30), cc.p(0.5, 0.5), nil, "请添加矿石", 20, false, nil, MColor.lable_yellow, true, true)
root.m_bubbleTooLow = GetUIHelper():createBubble(n_material, cc.p(200, -30), cc.p(0.5, 0.5), nil, "当前成功率较低，建议合成更高级矿石", 20, false, nil, MColor.lable_yellow, true, true)
root.m_bubbleTooLow:setVisible(false)
Mnode.addChild(
{
	parent = root,
	child = n_material,
	pos = cc.p(610, 424),
})
-----------------------------------------------------------------------
-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = placeholder,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			
			local Mreloading = require "src/layers/equipment/equip_select"
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				node = Mreloading.new(
				{
					now = ds.now_item or {},
					filtrate = function(packId, grid, now)
						local MequipOp = require "src/config/equipOp"
						local MpropOp = require "src/config/propOp"
						local Mconvertor = require "src/config/convertor"
						
						local protoId = MPackStruct.protoIdFromGird(grid)
						-- 是否是勋章
						local isMedal = protoId >= 30004 and protoId <= 30006
						if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
							return false
						end
						
						local gridId = MPackStruct.girdIdFromGird(grid)
						local now_gridId = MPackStruct.girdIdFromGird(now.grid)
						if packId == now.packId and gridId == now_gridId then return false end
						
						local quality = MpropOp.quality(protoId, grid)
						local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
						local isRUL = MequipOp.isStrengthRUL(protoId, strengthLv, quality)
						if isRUL then return false end
						
						return true
					end,
					handler = function(item)
						ds.reloadData(ds, item)
						onReloadData(ds)
						n_jia_tips:setVisible(false)
						one_key_get_material(ds)
						n_onekey_btn:setEnabled(true)
						reloadView(root, ds)
					end,
					
					act_src = "放入",
				}),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
		end
	end,
})
-----------------------------------------------------------------------------
-- 内容层
local layer = Mnode.createNode(
{
	parent = root,
	cSize = rootSize,
	pos = cc.p(rootSize.width/2, rootSize.height/2),
})
root.layer = layer


reloadView(root, ds)
------------------------------------------------------------------------
onReloadData = function(ds)
	local n_aux = root:getChildByTag(1)
	if n_aux ~= nil then n_aux:removeFromParent() end
	
	if ds.now_item == nil then return end
	
	n_aux = cc.Node:create()
	local onPackChanged = function(pack, event, id, result)
		if event == "upStrength" then
			n_rate_tips:setVisible(false)
			
			if result == 0 then -- 强化失败
				AudioEnginer.playEffect("sounds/upFail.mp3",false)
				TIPS({ type = 1  , str = "强化失败" })
				
				one_key_get_material(ds)
				n_onekey_btn:setEnabled(true)
						
			elseif result == 1 then -- 成功
				AudioEnginer.playEffect("sounds/upSuccess.mp3",false)
				TIPS({ type = 1  , str = "强化成功" })
				
				local animateSpr = Effects:create(false)
				performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,1.9)
				animateSpr:playActionData("equipRefine", 27, 1.9, 1)
				Mnode.addChild(
				{
					parent = root,
					child = animateSpr,
					pos = cc.p(608, 265),
					zOrder = 1000,
				})
			end
		elseif (id == ds.gridId) and (event == "=" or event == "+") then
			ds.reloadData(ds, {packId=ds.now_item.packId, grid=pack:getGirdByGirdId(id)})
			onReloadData(ds)
			reloadView(root, ds)
			
			one_key_get_material(ds)
			if ds.isRUL then
				n_onekey_btn:setEnabled(false)
			else
				n_onekey_btn:setEnabled(true)
			end
		end
	end
	
	local pack = MPackManager:getPack(ds.now_item.packId)
	n_aux:registerScriptHandler(function(event)
		if event == "enter" then
			pack:register(onPackChanged)
			
		elseif event == "exit" then
			pack:unregister(onPackChanged)
		end
	end)

	Mnode.addChild(
	{
		parent = root,
		child = n_aux,
		tag = 1,
	})
end
G_TUTO_NODE:setShowNode(root, SHOW_STRENGTHEN)
onReloadData(ds)
-----------------------------------------------------------------------
return root
end }