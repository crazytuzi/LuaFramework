return { new = function(params)
-----------------------------------------------------------------------
local Mnode = require "src/young/node"
local MColor = require "src/config/FontColor"
local Mconvertor = require "src/config/convertor"
local MProcessBar = require "src/layers/role/ProcessBar"
local MRoleStruct = require "src/layers/role/RoleStruct"
-----------------------------------------------------------------------
local res = "res/layers/role/"
-----------------------------------------------------------------------
local root = cc.Sprite:create("res/common/bg/infoBg11.png")
local rootSize = root:getContentSize()
local vsize = cc.size(rootSize.width-15, rootSize.height-15)
-----------------------------------------------------------------------
local params = params or {}
-- 是否是不需要刷新的静态信息
local static = params.static
local datasource = static and params.datasource or {}
--dump(datasource, "datasource")
-----------------------------------------------------------------------
local ColorKey = MColor.lable_yellow
local ColorValue = MColor.lable_black
-----------------------------------------------------------------------
-- 创建所有必要的 node
local nodes = {}
-----------------------------------------------------------------------
-- 战斗力 特效名 roleFight
local power_bg = cc.Sprite:create("res/common/misc/powerbg_1.png")
local power_bg_size = power_bg:getContentSize()
local Mnumber = require "src/component/number/view"
local NumberBuilder = Mnumber.new("res/component/number/10.png")
local power = Mnode.createKVP(
{
	k = cc.Sprite:create("res/common/misc/power_b.png"),
	v = NumberBuilder:create(datasource[PLAYER_BATTLE] or MRoleStruct:getAttr(PLAYER_BATTLE), -5),
	margin = 15,
})

power:setScale(0.6)
power_bg.refresh = function(self)
	power:setValue( NumberBuilder:create(MRoleStruct:getAttr(PLAYER_BATTLE), 5) )
end

Mnode.addChild(
{
	parent = power_bg,
	child = power,
	anchor = cc.p(0, 0.5),
	pos = cc.p(10, power_bg_size.height/2),
})

nodes[PLAYER_BATTLE] = power_bg

-- 生命
local hp = MProcessBar.new(
{
	label = {
		src = game.getStrByKey("hp"),
		size = 20,
		color = ColorKey,
		outline = false,
	},
	bar = "res/component/progress/2_red.png",
	progress = { cur = datasource[ROLE_HP] or 1, max = datasource[ROLE_MAX_HP] or 1, },
})

hp.refresh = function(self)
	self:setProgress(
	{
		cur = MRoleStruct:getAttr(ROLE_HP),
		max = MRoleStruct:getAttr(ROLE_MAX_HP),
	})
end

-----------------------
nodes[ROLE_HP] = hp
nodes[ROLE_MAX_HP] = hp
-----------------------
-- "法力"
local mp = MProcessBar.new(
{
	label = {
		src = game.getStrByKey("mp"),
		size = 20,
		color = ColorKey,
		outline = false,
	},
	bar = "res/component/progress/2_blue.png",
	progress = { cur = datasource[ROLE_MP] or 1, max = datasource[ROLE_MAX_MP] or 1, },
})

mp.refresh = function(self)
	self:setProgress(
	{
		cur = MRoleStruct:getAttr(ROLE_MP),
		max = MRoleStruct:getAttr(ROLE_MAX_MP),
	})
end

-----------------------
nodes[ROLE_MP] = mp
nodes[ROLE_MAX_MP] = mp
-----------------------

-- "经验"
local expValue = (datasource[PLAYER_XP] or 1)/(datasource[PLAYER_NEXT_XP] or 1)

local exp = MProcessBar.new(
{
	label = {
		src = game.getStrByKey("exp"),
		size = 20,
		color = ColorKey,
		outline = false,
	},
	bar = "res/component/progress/2_green.png",
	progress = expValue - expValue % 0.0001,
})

exp.refresh = function(self)
	local expValue = MRoleStruct:getAttr(PLAYER_XP)/MRoleStruct:getAttr(PLAYER_NEXT_XP)
	self:setProgress(expValue - expValue % 0.0001)
end

-----------------------
nodes[PLAYER_XP] = exp
nodes[PLAYER_NEXT_XP] = exp
-----------------------
-----------------------------------------------------------------------
local other_size = cc.size(vsize.width, 120)
local otherInfoArea = Mnode.createColorLayer(
{
	src = cc.c4b(0 ,0 ,0, 0),
	--src = cc.c4b(244 ,164 ,96, 255*0.5),
	cSize = other_size,
})

-- 幸运值
local luck_value = 0
if static then
	luck_value = datasource[PLAYER_LUCK] or 0
else
	luck_value = MRoleStruct:getAttr(PLAYER_LUCK)
end

local luck_k = Mnode.createLabel(
{
	src = game.getStrByKey(luck_value < 0 and "curse" or "luck")..": ",
	size = 20,
	color = ColorKey,
	outline = false,
})

local luck_v = Mnode.createLabel(
{
	src = tostring(math.abs(luck_value)),
	size = 20,
	color = ColorValue,
	outline = false,
})

local luck = Mnode.combineNode(
{
	nodes = { luck_k, luck_v },
})

luck.refresh = function(self)
	local value = MRoleStruct:getAttr(PLAYER_LUCK)
	luck_k:setString( game.getStrByKey(value < 0 and "curse" or "luck")..": " )
	luck_v:setString( tostring(math.abs(value)) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = luck,
	anchor = cc.p(0, 0.5),
	pos = cc.p(0, 90+15),
})
-----------------------
nodes[PLAYER_LUCK] = luck
-----------------------
-- -- 移动速度
-- local base_speed = getConfigItemByKeys("roleData", {"q_zy", "q_level", }, {1, 1}, "q_move_speed")
	  
-- local moveSpeed = Mnode.createKVP(
-- {
-- 	k = Mnode.createLabel(
-- 	{
-- 		src = game.getStrByKey("move")..game.getStrByKey("speed").."：",
-- 		size = 20,
-- 		color = ColorKey,
-- 		outline = false,
-- 	}),
	
-- 	v = {
-- 		src = math.floor(base_speed *((datasource[ROLE_MOVE_SPEED] or 100)/100)),
-- 		size = 20,
-- 		color = ColorValue,
-- 		outline = false,
-- 	},
-- })

-- moveSpeed.refresh = function(self)
-- 	self:setValue(math.floor(base_speed *(MRoleStruct:getAttr(ROLE_MOVE_SPEED)/100)) )
-- end

-- Mnode.addChild(
-- {
-- 	parent = otherInfoArea,
-- 	child = moveSpeed,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(110, 90+15),
-- })

-- -----------------------
-- nodes[ROLE_MOVE_SPEED] = moveSpeed
-- -----------------------

-- 命中
local hit = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("my_hit")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[ROLE_HIT] or "",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

hit.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_HIT) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = hit,
	anchor = cc.p(0, 0.5),
	pos = cc.p(0, 60+15),
})

-----------------------
nodes[ROLE_HIT] = hit
-----------------------

-- 闪避
local dodge = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("dodge")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[ROLE_DODGE] or "",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

dodge.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_DODGE) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = dodge,
	anchor = cc.p(0, 0.5),
	pos = cc.p(110, 90+15),
})

-----------------------
nodes[ROLE_DODGE] = dodge
-----------------------
-- 暴击
local strike = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("strike")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[ROLE_CRIT] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

strike.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_CRIT) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = strike,
	anchor = cc.p(0, 0.5),
	pos = cc.p(0, 30+15),
})

nodes[ROLE_CRIT] = strike
-----------------------
-- 韧性
local tenacity = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("my_tenacity")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[ROLE_TENACITY] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

tenacity.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_TENACITY) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = tenacity,
	anchor = cc.p(0, 0.5),
	pos = cc.p(110, 60+15),
})

nodes[ROLE_TENACITY] = tenacity
-----------------------
-- 穿透
local hu_shen_rift = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("hu_shen_rift")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[PLAYER_PROJECT_DEF] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

hu_shen_rift.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(PLAYER_PROJECT_DEF) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = hu_shen_rift,
	anchor = cc.p(0, 0.5),
	pos = cc.p(0, 0+15),
})

nodes[PLAYER_PROJECT_DEF] = hu_shen_rift
-----------------------
-- 免伤
local hu_shen = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("hu_shen")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[PLAYER_PROJECT] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

hu_shen.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(PLAYER_PROJECT) )
end

Mnode.addChild(
{
	parent = otherInfoArea,
	child = hu_shen,
	anchor = cc.p(0, 0.5),
	pos = cc.p(110, 30+15),
})

nodes[PLAYER_PROJECT] = hu_shen
-----------------------
--[[
-- 冰冻
local freeze = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("freeze")..game.getStrByKey("value")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[PLAYER_BENUMB] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

freeze.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(PLAYER_BENUMB) )
end

nodes[PLAYER_BENUMB] = freeze
-----------------------
-- 冰冻抵抗
local freeze_oppose = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("freeze_oppose")..game.getStrByKey("value")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[PLAYER_BENUMB_DEF] or "0",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

freeze_oppose.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(PLAYER_BENUMB_DEF) )
end

nodes[PLAYER_BENUMB_DEF] = freeze_oppose
--]]
-----------------------


----------------------------------------------------
--QQ会员展示
local qqNode = Mnode.createNode({ cSize = cc.size(80, 40) })
local bShowQQInfo = false
--if not static and (not LoginUtils.isReviewServer() or isWindows()) then
if not static and isWindows() then--暂时关闭qq登录等
    bShowQQInfo = true
    local function cb() 
       local tmp_sub_node = require("src/layers/qqMember/gameCenterLayer").new()
       G_MAINSCENE.base_node:addChild(tmp_sub_node,200)
    end
    if LoginUtils.isLaunchFromQQGameCenter() then
        createTouchItem(qqNode,"res/layers/qqMember/qqstart.png",cc.p(60,16),cb)
    elseif LoginUtils.isLaunchFromWXGameCenter() then 
        reateTouchItem(qqNode,"res/layers/qqMember/wxstart.png",cc.p(60,16),cb)
    else
        if LoginUtils.isQQLogin() then
            local btn = createTouchItem(qqNode,"res/layers/qqMember/qqstart.png",cc.p(60,16),cb)
            btn:addColorGray()
        else
            local btn = createTouchItem(qqNode,"res/layers/qqMember/wxstart.png",cc.p(60,16),cb)
            btn:addColorGray()
        end
    end
end

--if not static and ((LoginUtils.isQQLogin() and isAndroid()) or isWindows() ) then
if not static and isWindows() then--暂时关闭qq登录等
    bShowQQInfo = true
    local function cb() 
       --打开qq特权界面
       local tmp_sub_node = require("src/layers/qqMember/qqMemberLayer").new()
       G_MAINSCENE.base_node:addChild(tmp_sub_node,200)
    end

    if game.getVipLevel() == 0 then
        createMenuItem(qqNode, "res/layers/qqMember/vip_over.png", cc.p(140, 20), cb)
        createMenuItem(qqNode, "res/layers/qqMember/start_vip1.png", cc.p(204, 15), cb)
    elseif game.getVipLevel() == 1 then
        createMenuItem(qqNode, "res/layers/qqMember/vip.png", cc.p(140, 20), cb)
        createMenuItem(qqNode, "res/layers/qqMember/start_svip1.png", cc.p(204, 15), cb)
    elseif game.getVipLevel() == 2 then
        createMenuItem(qqNode, "res/layers/qqMember/svip.png", cc.p(140, 20), cb)
        createMenuItem(qqNode, "res/layers/qqMember/continue_svip1.png", cc.p(204, 15), cb)
    end
end
--封号—-------------------------------------------
local function specialTitlecb() 
   local tmp_sub_node = require("src/layers/role/specialTitleLayer").new(params)
   G_MAINSCENE.base_node:addChild(tmp_sub_node,200)
end
local function getSpecialTitle( school,lv,xpPercent )
	local titles={}
    for k,v in pairs(getConfigItemByKey("SpecialTitleDB", "q_id")) do
        
        if not titles[v.q_school] then
            titles[v.q_school]={}
        end
        titles[v.q_school][#titles[v.q_school]+1]=v
    end
    local myLv=lv
    
	for k,v in pairs(titles[school]) do
		if v.q_lv==lv then
			idx=k-1
		    local item=titles[school][idx+1]
		    local lastItem=nil
		    local nextItem=nil
		    if idx~=0 then
		        lastItem=titles[1][idx]
		    end
		    if idx<#titles[school] then

		        nextItem=titles[1][idx+2]
		    end
		    local lv = item["q_lv"]
		   

		    local lvStr=""
		    
		    local lastExp=lastItem and lastItem.q_exp
		    local lastLv =lastItem and lastItem.q_lv

		    local nextExp=nextItem and nextItem.q_exp
		    local nextLv =nextItem and nextItem.q_lv

		    
		    local nowExp=item.q_exp
		    
		    if lv==myLv  and nowExp<=xpPercent  then
		        if nextLv and nextLv==myLv then
		            if nextExp and nextExp>xpPercent then
		                return v.q_name
		            else

					end
		        else
		            return v.q_name
		        end
		    end
		elseif v.q_lv<myLv    then
			if titles[v.q_school][k+1]==nil or (titles[v.q_school][k+1].q_exp>xpPercent and titles[v.q_school][k+1].q_lv==myLv and v.q_lv<myLv) then
				return v.q_name
			end
		end
	end
end
local specialTitle=nil
local xpPercent=datasource[PLAYER_XP] and datasource[PLAYER_NEXT_XP] and math.floor(datasource[PLAYER_XP]/datasource[PLAYER_NEXT_XP]*100) or 0
local titleName=getSpecialTitle( datasource[ROLE_SCHOOL] or 1,datasource[ROLE_LEVEL] or 0,xpPercent )
if not static then
	xpPercent=math.floor(MRoleStruct:getAttr(PLAYER_XP)/MRoleStruct:getAttr(PLAYER_NEXT_XP)*100)
	titleName=getSpecialTitle( MRoleStruct:getAttr(ROLE_SCHOOL),MRoleStruct:getAttr(ROLE_LEVEL),xpPercent )
end
if math.max((datasource[ROLE_LEVEL] or 0),MRoleStruct:getAttr(ROLE_LEVEL))>=getConfigItemByKey("SpecialTitleDB", "q_id",1,"q_lv") and titleName then
	
	specialTitle=cc.Node:create()
	createLinkLabel(specialTitle, "封号:", cc.p(0, 0), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, specialTitlecb, true)
	specialTitle.titelNameLabel=createLinkLabel(specialTitle, titleName, cc.p(55, 0), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, specialTitlecb, false)
	function specialTitle:getSize()
		return cc.size(specialTitle:getContentSize().width, 30)
	end
	specialTitle.refresh = function(self)
		local xpPercent=math.floor(MRoleStruct:getAttr(PLAYER_XP)/MRoleStruct:getAttr(PLAYER_NEXT_XP)*100)
		local titleName=getSpecialTitle( MRoleStruct:getAttr(ROLE_SCHOOL),MRoleStruct:getAttr(ROLE_LEVEL),xpPercent )
		if specialTitle.titelNameLabel then
			specialTitle.titelNameLabel:removeFromParent()
		end
		specialTitle.titelNameLabel=createLinkLabel(specialTitle, titleName, cc.p(55, 0), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, specialTitlecb, false)
	end
end
if specialTitle then
	nodes[PLAYER_XP] = specialTitle
end
---------------------------------------------------
--pk帮助链接
--改成点击后面的数值也可以打开帮助界面
local PK=cc.Node:create()
local function helpPK()
	local PK_size = PK:getContentSize() 
    local pk_prompt, func = __createHelp(
    {
	    parent = nil,
	    str = require("src/config/PromptOp"):content(1),
	    pos = cc.p(PK_size.width+60, PK_size.height/2),
    })

    func()
end
createLinkLabel(PK, "PK"..game.getStrByKey("value")..": ", cc.p(0, 0), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, helpPK, true)
local PKvalue=createLinkLabel(PK,  datasource[PLAYER_PK] or "", cc.p(55, 0), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, helpPK, false)
function PK:getSize()
	return cc.size(PK:getContentSize().width, 30)
end
PK.refresh = function(self)
	PKvalue:setString( MRoleStruct:getAttr(PLAYER_PK) )
end
-----------------------
nodes[PLAYER_PK] = PK


---------------------------------------------------------
--炫耀
if not static and (LoginUtils.isQQLogin() or LoginUtils.isWXLogin() or isWindows()) then
    local function xuanyao() 
        local layer = require("src/layers/role/shareInfo").new()
        G_MAINSCENE.base_node:addChild(layer, 300)
    end
    local PK_size = PK:getContentSize()
    local sign = createSprite(PK, "res/share/sign.png", cc.p(150, PK_size.height/2), cc.p(0.5, 0.5))
    createLinkLabel(sign, game.getStrByKey("friend_share_xuanyao"), cc.p(32, 16), cc.p(0, 0.5), 20, false, nil, ColorKey, nil, xuanyao, true)
end

--------------------------------------------------------

-- 帮派
local faction = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("faction")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = static and (datasource[PLAYER_FACTIONNAME] or "") or MRoleStruct:getAttr(PLAYER_FACTIONNAME),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

-- 职业
local school = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("school")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = Mconvertor:school(static and (datasource[ROLE_SCHOOL] or 0) or MRoleStruct:getAttr(ROLE_SCHOOL)),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

-- 等级
local level = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("level")..": ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = datasource[ROLE_LEVEL] or "",
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

level.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_LEVEL) )
end

-----------------------
nodes[ROLE_LEVEL] = level
-----------------------

local n_level_school = Mnode.combineNode(
{
	nodes = { level, school },
	margins = 80,
})

local cbNodes = {PK, faction, n_level_school, }
if specialTitle then
	table.insert(cbNodes,1,specialTitle)
end
if bShowQQInfo then
    table.insert(cbNodes,1,qqNode)
end
local baseInfoArea = Mnode.combineNode(
{
    nodes = cbNodes,
    ori = "|",
    align = "l",
    margins = 7,
} )


-----------------------------------------------------------------------
--[[战斗属性]]
-- 物理攻击
local pAttack = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("physical_attack").." ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = (datasource[ROLE_MIN_AT] or "") .. "-" .. (datasource[ROLE_MAX_AT] or ""),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

pAttack.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_MIN_AT) .. "-" .. MRoleStruct:getAttr(ROLE_MAX_AT) )
end

-----------------------
nodes[ROLE_MIN_AT] = pAttack
nodes[ROLE_MAX_AT] = pAttack
-----------------------

-- 物理防御
local pDefense = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("physical_defense").." ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = (datasource[ROLE_MIN_DF] or "") .. "-" .. (datasource[ROLE_MAX_DF] or ""),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

pDefense.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_MIN_DF) .. "-" .. MRoleStruct:getAttr(ROLE_MAX_DF) )
end

-----------------------
nodes[ROLE_MIN_DF] = pDefense
nodes[ROLE_MAX_DF] = pDefense
-----------------------

-- 魔法攻击
local mAttack = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("magic_attack").." ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = (datasource[ROLE_MIN_MT] or "") .. "-" .. (datasource[ROLE_MAX_MT] or ""),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

mAttack.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_MIN_MT) .. "-" .. MRoleStruct:getAttr(ROLE_MAX_MT) )
end

-----------------------
nodes[ROLE_MIN_MT] = mAttack
nodes[ROLE_MAX_MT] = mAttack
-----------------------

-- 魔法防御
local mDefense = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("magic_defense").." ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = (datasource[ROLE_MIN_MF] or "") .. "-" .. (datasource[ROLE_MAX_MF] or ""),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

mDefense.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_MIN_MF) .. "-" .. MRoleStruct:getAttr(ROLE_MAX_MF) )
end

-----------------------
nodes[ROLE_MIN_MF] = mDefense
nodes[ROLE_MAX_MF] = mDefense
-----------------------

-- 道术攻击
local tAttack = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("taoism_attack").." ",
		size = 20,
		color = ColorKey,
		outline = false,
	}),
	
	v = {
		src = (datasource[ROLE_MIN_DT] or "") .. "-" .. (datasource[ROLE_MAX_DT] or ""),
		size = 20,
		color = ColorValue,
		outline = false,
	},
})

tAttack.refresh = function(self)
	self:setValue( MRoleStruct:getAttr(ROLE_MIN_DT) .. "-" .. MRoleStruct:getAttr(ROLE_MAX_DT) )
end

-----------------------
nodes[ROLE_MIN_DT] = tAttack
nodes[ROLE_MAX_DT] = tAttack
-----------------------
local nodeOrder={ mDefense, pDefense, tAttack, mAttack, pAttack, }
local mySchool=MRoleStruct:getAttr(ROLE_SCHOOL)
if mySchool==2 then
	nodeOrder={ mDefense, pDefense, tAttack, pAttack, mAttack }
elseif mySchool==3 then
	nodeOrder={ mDefense, pDefense,  mAttack, pAttack, tAttack,}
end
local combatAttrArea = Mnode.combineNode(
{
	nodes = nodeOrder,
	ori = "|",
	align = "l",
	margins = 7,
})
-----------------------------------------------------------------------
--[[
-- 元婴属性区域
local buildBabyAttr = function(k, v, attr_name)
	local tmp_node = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = k,
			size = 20,
		}),
		
		v = {
			src = v,
			size = 20,
			color = MColor.blue,
		},
	})

	tmp_node.refresh = function(self)
		self:setValue( MRoleStruct:getAttr(attr_name) )
	end
	
	return tmp_node
end

-----------------------
-- 增加战士伤害几率
local AT_ADD = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("zhanshi")..game.getStrByKey("intrepid").."：", datasource[PLAYER_AT_ADD] or "0", PLAYER_AT_ADD)
nodes[PLAYER_AT_ADD] = AT_ADD

-- 增加法师伤害几率
local MT_ADD = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("fashi")..game.getStrByKey("intrepid").."：", datasource[PLAYER_MT_ADD] or "0", PLAYER_MT_ADD)
nodes[PLAYER_MT_ADD] = MT_ADD

-- 增加道士伤害几率
local DT_ADD = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("daoshi")..game.getStrByKey("intrepid").."：", datasource[PLAYER_DT_ADD] or "0", PLAYER_DT_ADD)
nodes[PLAYER_DT_ADD] = DT_ADD

-- 减少战士伤害几率
local AT_SUB = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("zhanshi")..game.getStrByKey("tenacity").."：", datasource[PLAYER_AT_SUB] or "0", PLAYER_AT_SUB)
nodes[PLAYER_AT_SUB] = AT_SUB

-- 减少法师伤害几率
local MT_SUB = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("fashi")..game.getStrByKey("tenacity").."：", datasource[PLAYER_MT_SUB] or "0", PLAYER_MT_SUB)
nodes[PLAYER_MT_SUB] = MT_SUB

-- 减少道士伤害几率
local DT_SUB = buildBabyAttr(game.getStrByKey("vs")..game.getStrByKey("daoshi")..game.getStrByKey("tenacity").."：", datasource[PLAYER_DT_SUB] or "0", PLAYER_DT_SUB)
nodes[PLAYER_DT_SUB] = DT_SUB

local babyAttrArea = Mnode.combineNode(
{
	nodes = { DT_SUB, MT_SUB, AT_SUB, DT_ADD, MT_ADD, AT_ADD },
	ori = "|",
	align = "l",
	margins = 8,
})
--]]
local cSize = cc.size(vsize.width, 50)
local base_info = Mnode.createNode({ cSize = cSize })
Mnode.addChild(
{
	parent = base_info,
	child =cc.Sprite:create("res/common/bg/infoBg11-2.png"),
	pos = cc.p(cSize.width/2, cSize.height/2),
})

Mnode.createLabel(
{
	src = game.getStrByKey("base_info"),
	parent = base_info,
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(133, 20),
})
local baltte_value = Mnode.createNode({ cSize = cSize })
Mnode.addChild(
{
	parent = baltte_value,
	child =cc.Sprite:create("res/common/bg/infoBg11-2.png"),
	pos = cc.p(cSize.width/2, cSize.height/2),
})
Mnode.createLabel(
{
	src = game.getStrByKey("battle_value"),
	parent = baltte_value,
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(133, 25),
})
-----------------------------------------------------------------------
local content = Mnode.combineNode(
{
	nodes = 
	{
		otherInfoArea,
		---------------------------------0
		cc.Sprite:create("res/common/bg/infoBg11-3.png"),
		--5
		combatAttrArea,
		--5
		cc.Sprite:create("res/common/bg/infoBg11-3.png"),
		---------------------------------5
		exp,
		--5
		mp,
		--5
		hp,
		---------------------------------0
		baltte_value,
		--5
		baseInfoArea,
		--0
		base_info,
		-- -15
		power_bg,
		---------------------------------
	},
	
	ori = "|",
	margins = {0, 5, 5, 5, 5, 5, -8, 5, -3, -18},
	align = "l",
})

local csize = content:getContentSize()
-----------------------------------------------------------------------
-- 滚动区域
local scroll = cc.ScrollView:create()
scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
scroll:setClippingToBounds(true)
--scroll:setBounceable(true)

scroll:setViewSize(vsize)
scroll:setContainer(content)
scroll:updateInset()
scroll:setContentOffset(cc.p(0, vsize.height - csize.height))
scroll:addSlider("res/common/slider.png")


Mnode.addChild(
{
	parent = root,
	child = scroll,
	anchor = cc.p(0, 0.5),
	pos = cc.p(15, rootSize.height/2+5),
})
-----------------------------------------------------------------------
if not static then
-----------------------------------------------------------------------
	local tPureNodes = {}
	for k, v in pairs(nodes) do
		tPureNodes[v] = true
	end

	scroll.refresh = function(self)
		for k, v in pairs(tPureNodes) do
			k:refresh()
		end
	end; scroll:refresh()
	-----------------------------------------------------------------------
	local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
		if not isMe then return end
		
		if attrId == ROLE_LEVEL then
			scroll:refresh()
		else
			local node = nodes[attrId]
			if node then node:refresh() end
		end
	end

	content:registerScriptHandler(function(event)
		if event == "enter" then
			MRoleStruct:register(onDataSourceChanged)
		elseif event == "exit" then
			MRoleStruct:unregister(onDataSourceChanged)
		end
	end)
-----------------------------------------------------------------------
end
-----------------------------------------------------------------------
return root
end }