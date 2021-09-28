local M = Myoung.beginModule(...)
---------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
---------------------------------------------------------
local res = "res/layers/bag/"
---------------------------------------------------------
--[[ 
	zOrder
	背景 -> -2
	原型 -> 1
	边框 -> 0
	红色蒙版 -> 1
	绑定 -> 2
	数量 -> 2
	可回收 -> 6
	限时 -> 3
	蒙版 -> 15
	特效 -> 4
	强化 -> 6
	使用中 -> 5
	提示性特效 -> 5
]]

--[[ 
	tag 编号
	原型 -> 1
	
	数量 -> 3 -- 右下角
	可回收 -> 4 -- 左上角
	蒙版 -> 5
	特效 -> 6
	限时 -> 7 -- 右上角
	绑定 -> 8 -- 左下角
	强化 -> 9 -- 右上角
	使用中 -> 10 -- 左上角
	背景 -> 11
	提示性特效 -> 12 右下角
	红色蒙版 -> 13
	纹饰激活标签->14
]]

local tMethods = 
{
	addEffect = function(self)
		if not self.mProtoId then return end
		
		local protoId = self.mProtoId
		local isMedal = type(protoId) == "number" and protoId >= 30004 and protoId <= 30006
		if isMedal then return end
		
		local quality = MpropOp.quality(self.mProtoId, self.mGrid)
		if quality >= 1 and quality <= 5 then
			local size = self:getContentSize()
			local effectNode = Effects:create(false)
			effectNode:playActionData("propColor".. quality, 11, 1.2, -1)
			Mnode.addChild(
			{
				parent = self,
				child = effectNode,
				pos = cc.p(size.width/2, size.height/2),
				zOrder = 0,
				tag = 6,
			})
		end
	end,
	
	getIcon = function(self)
		return self.icon
		--return self:getChildByTag(1) -- 用这个好像有bug
		--icon_node:addColorGray()
		--icon_node:removeColorGray()
	end,

	-- 暴力设置物品图标
	forceSetIcon = function(self, icon_path)
		local icon = self:getChildByTag(1)
		icon:setTexture(icon_path)
	end,

	-- 设置物品数量
	setOverlay = function(self, num)

		local text = nil
		if num < 10000 then
			text = tostring(num)
		elseif num < 10000000 then -- 上百万
			text = num/10000
			text = (text - text % 0.1) .. game.getStrByKey("task_num")
		elseif num < 100000000 then -- 上千万
			text = num/10000000
			text = (text - text % 0.1) .. game.getStrByKey("ten_million")
		else -- 上亿
			text = num/100000000
			text = (text - text % 0.1) .. game.getStrByKey("hundred_million")
		end

		local node = self:getChildByTag(3)
		if not node then
			local size = self:getContentSize()

			local lab = Mnode.createLabel(
			{
				parent = self,
				src = text,
				size = 18,
				color = MColor.white,
				anchor = cc.p(1, 0),
				pos = cc.p(size.width - 8, 5),
				tag = 3,
				zOrder = 2,
				outline = false,
			})
			lab:enableOutline(cc.c4b(0,0,0,255),1)
		else
			node:setString(text)
		end
	end,

	-- 设置强化等级
	setStrengthLv = function(self, strengthLv)
		if not strengthLv or strengthLv < 0 then return end
		local node = self:getChildByTag(9)
		if node then removeFromParent(node) end
		
		if strengthLv == 0 then return end
		
		local protoId = self.mProtoId
		local isMedal = protoId >= 30004 and protoId <= 30006
		if isMedal then return end

		local backpic = 1
		if (protoId >= 1301 and protoId <= 1310) then
			if strengthLv <= 5 then
				backpic = 1
			else
				backpic = 2
			end
		elseif (protoId >= 1401 and protoId <= 1410) then
			if strengthLv <= 5 then
				backpic = 3
			else
				backpic = 4
			end
		else
			if strengthLv <= 5 then
				backpic = 1
			elseif strengthLv <= 10 then
				backpic = 2
			elseif strengthLv <= 15 then
				backpic = 3
			else
				backpic = 4
			end
		end

		Mnode.addChild(
		{
			parent = self,
			child = cc.Sprite:create("res/group/itemBorder/s" .. backpic .. ".png"),
			pos = cc.p(73, 66),
			anchor = cc.p(1, 0.5),
			zOrder = 6,
		})
		
		local number = MakeNumbers:createWithSymbol("res/component/number/12.png", strengthLv, -1, true)
		--number:setScale(0.7)
		number:setCascadeColorEnabled(true)
		--local color = MpropOp.nameColor(self.mProtoId, self.mGrid)
		--number:setColor(color)
		
		Mnode.addChild(
		{
			parent = self,
			child = number,
			pos = cc.p(57, 66),
			anchor = cc.p(0.5, 0.5),
			tag = 9,
			zOrder = 6,
		})
	end,

	setStrengthLvColor = function(self, color)
		local node = self:getChildByTag(9)
		if node then node:setColor(color) end
	end,

	-- 设置使用中标签
	setOutOfPrint = function(self)
		local node = self:getChildByTag(10)
		if node then removeFromParent(node) end
		
		local size = self:getContentSize()
		Mnode.addChild(
		{
			parent = self,
			child = cc.Sprite:create("res/layers/bag/using.png"),
			pos = cc.p(20, 58),
			tag = 10,
			zOrder = 5,
		})
	end,

	setActiveLabel = function(self)
		-- local node = self:getChildByTag(14)
		-- if node then removeFromParent(node) end
		
		-- local size = self:getContentSize()
		-- Mnode.addChild(
		-- {
		-- 	parent = self,
		-- 	child = cc.Sprite:create("res/layers/bag/time_limit.png"),
		-- 	pos = cc.p(20, 58),
		-- 	tag = 14,
		-- 	zOrder = 5,
		-- }) 
	end,

	-- 设置限时标识
	setTimeLimit = function(self, expiration)
		local icon = nil
		-- local now = os.time()
		local now = G_TIME_INFO.time or os.time()
		if now <= expiration then
			icon = res .. "time_limit.png"
		else
			icon = res .. "out_of_date.png"
		end

		local node = self:getChildByTag(7)
		if not node then
			local size = self:getContentSize()
			Mnode.createSprite(
			{
				parent = self,
				src = icon,
				anchor = cc.p(1, 1),
				pos = cc.p(size.width, size.height),
				tag = 7,
				zOrder = 3,
			})
		else
			node:setTexture(icon)
		end
	end,

	-- 播放可回收特效
	recyclable = function(self)
		local node = self:getChildByTag(4)
		if not node then
			local dollar = cc.Sprite:create(res .. "6.png")
		
			-- 左右摆动
			local swingTime, swingAngle = 0.5, 30
			--local rotate1 = cc.EaseSineInOut:create( cc.RotateTo:create(swingTime, -swingAngle) )
			--local rotate2 = cc.EaseSineInOut:create( cc.RotateTo:create(swingTime, swingAngle) )
			local rotate1 = cc.RotateTo:create(swingTime, -swingAngle)
			local rotate2 = cc.RotateTo:create(swingTime, swingAngle)
			local sequence = cc.Sequence:create(rotate1, rotate2)
			local forever = cc.RepeatForever:create(sequence)
			dollar:runAction(forever)
		
			Mnode.overlayNode(
			{
				parent = self,
				{
					node = dollar,
					origin = "lt",
					offset = { x = 8, y = -5, },
					tag = 4,
					zOrder = 6,
				}
			})
		end
	end,

	-- 设置蒙版
	setMask = function(self, mask)
		local node = self:getChildByTag(5)
		if node then removeFromParent(node) node = nil end
		
		if mask then
			local size = self:getContentSize()
			Mnode.addChild(
			{
				parent = self,
				child = Mnode.createScale9Sprite(
				{
					src = res.."mask.png",
					cSize = cc.size(size.width+5, size.height+5),
				}),
				pos = cc.p(size.width/2, size.height/2),
				tag = 5,
				zOrder = 15,
			})
		end
	end,
    --更新战斗力箭头
	updatePowerArrows = function(self)
        --dump("更新战斗力箭头______________________________")
        local size = self:getContentSize()
        local  protoId=self.mProtoId 
        local total_hint = self.hint
        local grid=self.mGrid 
	    local powerHint = self.isEquip and self.powerHint or nil
		if total_hint == nil and self.powerHint then
			local MequipOp = require "src/config/equipOp"
			local Mconvertor = require "src/config/convertor"
				
			local hint = nil
			local roleSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
			local equipSchool = MpropOp.schoolLimits(protoId)
			local roleSex = MRoleStruct:getAttr(PLAYER_SEX)
			local equipSex = MpropOp.sexLimits(protoId)
			if (equipSchool == Mconvertor.eWhole or equipSchool == roleSchool) and (equipSex == Mconvertor.eSexWhole or equipSex == roleSex) then
				local dress = MPackManager:getPack(MPackStruct.eDress)
				local power = MPackStruct.attrFromGird(grid, MPackStruct.eAttrCombatPower)
				--dump(power, "power")
				local kind = MequipOp.kind(protoId)
				if kind == Mconvertor.eCuff then -- 护腕
					local cur_l_grid = dress:getGirdByGirdId(MPackStruct.eCuffLeft)
					local cur_l_power = cur_l_grid and MPackStruct.attrFromGird(cur_l_grid, MPackStruct.eAttrCombatPower) or 0
					local cur_r_grid = dress:getGirdByGirdId(MPackStruct.eCuffRight)
					local cur_r_power = cur_r_grid and MPackStruct.attrFromGird(cur_r_grid, MPackStruct.eAttrCombatPower) or 0
					if power > cur_l_power or power > cur_r_power then
						hint = "res/group/arrows/1.png"
					elseif power < cur_l_power or power < cur_r_power then
						hint = "res/group/arrows/2.png"
					end
				elseif kind == Mconvertor.eRing then -- 戒指
					local cur_l_grid = dress:getGirdByGirdId(MPackStruct.eRingLeft)
					local cur_l_power = cur_l_grid and MPackStruct.attrFromGird(cur_l_grid, MPackStruct.eAttrCombatPower) or 0
					local cur_r_grid = dress:getGirdByGirdId(MPackStruct.eRingRight)
					local cur_r_power = cur_r_grid and MPackStruct.attrFromGird(cur_r_grid, MPackStruct.eAttrCombatPower) or 0
					if power > cur_l_power or power > cur_r_power then
						hint = "res/group/arrows/1.png"
					elseif power < cur_l_power or power < cur_r_power then
						hint = "res/group/arrows/2.png"
					end
				else
					local cur_grid = dress:getGirdByGirdId(MPackStruct.dressId(kind))
					local cur_power = cur_grid and MPackStruct.attrFromGird(cur_grid, MPackStruct.eAttrCombatPower) or 0
					--dump(cur_power, "cur_power")
					if power > cur_power then
						hint = "res/group/arrows/1.png"
					elseif power < cur_power then
						hint = "res/group/arrows/2.png"
					end
				end
			end
			
			total_hint = hint
		end
		
		if total_hint ~= nil then
            --如果箭头不用变，就不改
            if self.lastPowerHint and self.lastPowerHint == total_hint then
                return
            end
            self:removeChildByTag(12)
            self.lastPowerHint=total_hint
			local hint_icon = Mnode.createSprite(
			{
				parent = self,
				src = total_hint,
				--pos = cc.p(62, 20),
				tag = 12,
				zOrder = 5,
			})
			local hint_icon_size = hint_icon:getContentSize()
			hint_icon:setPosition(size.width-hint_icon_size.width/2-5, hint_icon_size.height/2+5)
			local FadeTo1 = cc.FadeTo:create(1, 0)
			local FadeTo2 = cc.FadeTo:create(1, 255)
			local Sequence = cc.Sequence:create(FadeTo1, FadeTo2)
			local RepeatForever = cc.RepeatForever:create(Sequence)
			hint_icon:runAction(RepeatForever)
		end
    end,
	-- 设置物品原型id
	setPrototype = function(self, protoId, cfg)
		if protoId == nil then return end
		
		local cfg = cfg or {}
		
		self:removeAllChildren()
		
		local size = self:getContentSize()
		
		-- 添加背景
		if self.bg == nil or type(self.bg) == "string" then
			Mnode.createSprite(
			{
				src = self.bg or "res/common/bg/itemBg.png",
				parent = self,
				pos = cc.p(size.width/2, size.height/2),
				tag = 11,
				zOrder = -2,
			})
		end
		
		-- 设置为空状态
		if protoId == "empty" then
			self.mProtoId = nil
			if self.border ~= "empty" then self:setTexture(self.border) end
			return
		end
		
		local grid = cfg.grid or MPackStruct:buildGirdFromProtoId(protoId)
		self.mGrid = grid
		
		-- 是否是装备
		local isEquip = MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment
		-- 是否是套装
		local isSuit = MequipOp.isSuit(protoId)
		
		local isMedal = protoId >= 30004 and protoId <= 30006
		
		-- 设置原型icon
		
		--勋章做特殊处理
		local icon_path = nil
		local isHaveWen = {[1] = false, [2] = false, [3] = false}
		local standardPos = cc.p(size.width/2, size.height/2)
		local standardScale = 1
		if isMedal then
			-- 占位值为红色边框
			local borderDir = "res/layers/role/honourIcon/"
			local diwen = MPackStruct.emblazonry1(grid)
			local bianwen = MPackStruct.emblazonry2(grid)
			local shiwen = MPackStruct.emblazonry3(grid)
			if diwen then
				isHaveWen[1] = diwen
			end
			if bianwen then
				isHaveWen[2] = bianwen
			end
			if shiwen then
				isHaveWen[3] = shiwen
			end
			local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)			
			local honourNum = math.floor(strengthLv/10)+1
			local result = (honourNum > 5) and 5 or honourNum   --math.ceil( (math.floor(strengthLv/5)+1)/3 )
			icon_path = borderDir..tostring(protoId).."_"..tostring(result)..".png"
			--dump(icon_path, "icon_path")
			local texture = TextureCache:addImage(icon_path)
			-- print(strengthLv,honourNum,result,texture,"strengthLv,honourNum,result,texturekkkkkkkkkkkkkkkkkkkk")
			if texture then
				
			else				
				icon_path = borderDir..tostring(protoId).."_1.png"
			end
		else
			if MpropOp.shiwen(protoId) then
				local wenshiKind = MpropOp.shiwen(protoId)
				standardScale = 0.9
				if wenshiKind == 1 then
					standardPos = cc.p(size.width/2, size.height/2+20)
				elseif wenshiKind == 2 then
					standardPos = cc.p(size.width/2, size.height/2-15)
				elseif wenshiKind == 3 then
					standardPos = cc.p(size.width/2, size.height/2-5)
				end
			end
			icon_path = MpropOp.icon(protoId)
		end
		--dump(icon_path, "icon_path")

		local icon = GraySprite:create(icon_path)
		Mnode.addChild(
		{
			parent = self,
			child = icon,
			pos = standardPos,
			tag = 1,
			zOrder = 1,
			scale = standardScale,
		})
		
		self.icon = icon
		self.mProtoId = protoId

		if isMedal then
			for k,v in pairs(isHaveWen) do
				if type(v) == "table" and v[1] ~= 0 then
					local icon_path = MpropOp.icon(v[1])
					local icon = GraySprite:create(icon_path)
					Mnode.addChild(
					{
						parent = self,
						child = icon,
						pos = cc.p(size.width/2, size.height/2),
						tag = 1,
						zOrder = 0,
					})
				end
			end
			local eff = function(super,lv)
				local level = math.floor(lv/10)+1
				if level > 5 then
					local jobkind = {"zs","fs","ds"}
					local job = MpropOp.schoolLimits(protoId)
					local effect = Effects:create(false)					
					effect:playActionData(jobkind[job].."xz"..level, 19, 2, -1)
					effect:setRenderMode(2)
					super:addChild(effect, 2)
					effect:setPosition(cc.p(super:getContentSize().width/2, super:getContentSize().height/2))
				end
				-- createSprite(icon,"res/layers/role/30.png",cc.p(20,20))
			end
			eff(icon, MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel))
		end
		---------------------------------------------
		-- 红色蒙版 
		if cfg.red_mask then
			if MpropOp.isLimitToMe(protoId) then
				Mnode.addChild(
				{
					parent = self,
					child = Mnode.createSprite(
					{
						src = "res/common/scalable/red_masking.png",
						--scale = 0.65,
					}),
					pos = cc.p(size.width/2, size.height/2),
					tag = 13,
					zOrder = 1,
				})
			end
		end
		---------------------------------------------
		
		-- 强化等级
		local strengthLv = cfg.strengthLv or MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		self:setStrengthLv(strengthLv)
		
		-- 矿石做特殊处理
		if (protoId >= 1301 and protoId <= 1310) or (protoId >= 1401 and protoId <= 1410) then
			local purity = MpropOp.purity(protoId)
			self:setStrengthLv(purity)
		end
		------------------------------------------------
		-- 提示性特效
        --更新战斗力箭头
		self:updatePowerArrows()
        ------------------------------------------------
		
		-- 特效
		if cfg.effect then self:addEffect() end
		
		-- 绑定状态
		if cfg.showBind then
			Mnode.overlayNode(
			{
				parent = self,
				{
					node = cc.Sprite:create("res/group/lock/1.png"),
					origin = "lb",
					offset = { x = 8, y = 5, },
					zOrder = 2,
					tag = 8,
				}
			})
		end
		
		-- 物品数量
		if cfg.num then self:setOverlay(cfg.num) end
		------------------------------------------------------------------------------------
		-- 物品可回收特效
		if cfg.recyclable ~= nil and cfg.recyclable then self:recyclable() end
		------------------------------------------------------------------------------------
		-- 限时标识
		local expiration = MPackStruct.attrFromGird(grid, MPackStruct.eAttrExpiration)
		if expiration ~= nil then self:setTimeLimit(expiration) end
		------------------------------------------------------------------------------------
		-- 设置使用中标签
		if cfg.using then self:setOutOfPrint() end


		if cfg.isActive then
			self:setActiveLabel()
		end
		------------------------------------------------------------------------------------
		--物品小红点
		if (protoId==1017 or protoId==1018) and G_isBagLayer then
			local redPoint=createSprite( self , "res/component/flag/red.png" ,cc.p( self:getContentSize().width - 5 , self:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
			redPoint:setScale(0.9)
		end			
	end,
}

new = function(params)
------------------------------------------------------------------------------------
-- root 节点
local grid = params.grid or MPackStruct:buildGirdFromProtoId(params.protoId)

-- 物品的原型ID
local protoId = MPackStruct.protoIdFromGird(grid)
------------------------------------------------------------------------------------
-- 背景图片
local bg = params.bg

-- 是否播放特效
local effect = params.effect

-- 是否接受触摸事件
local touchable = params.touchable

-- 触摸事件的回调函数
local callback = params.cb

-- 物品数量
local num = params.num

-- 过期时间
local expiration = params.expiration

-- 是否是装备
local isEquip = MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment

-- 是否显示已绑定图标
local showBind = params.showBind

-- 物品无否绑定
local isBind = params.isBind

-- 是否显示可回收特效
local recyclable = params.recyclable

-- 强化等级
local strengthLv = params.strengthLv

-- 提示性特效
local hint = params.hint
local powerHint = params.powerHint

-- 红色蒙版
local red_mask = params.red_mask

-- isOther
local isOther = params.isOther

-- 是否正在使用中
local using = params.using

--针对纹饰是否激活
local isActive = params.isActive == 1

------------------------------------------------------------------------------------
-- 物品边框
local border = params.border or (type(protoId) == "number" and MpropOp.border(protoId) or "empty")
local isMedal = type(protoId) == "number" and protoId >= 30004 and protoId <= 30006
local isWenShi = type(protoId) == "number" and MpropOp.shiwen(protoId) 
if isMedal or isWenShi then border = "empty" end
if params.noFrame then border = "empty" end	
local root = nil

if border == "empty" then
	root = Mnode.createNode({cSize = cc.size(80, 80)})
else
	root = cc.Sprite:create(border)
end

root.border = border
root.bg = bg

local rootSize = root:getContentSize()
local rootCenter = cc.p(rootSize.width/2, rootSize.height/2)
------------------------------------------------------------------------------------
root.mGrid = grid
------------------------------------------------------------------------------------
-- 继承方法
for k, v in pairs(tMethods) do
	root[k] = v
end
root.powerHint=isEquip and powerHint or nil
root.hint=isEquip and hint or nil
------------------------------------------------------------------------------------
-- 物品图标
root:setPrototype(protoId, {
	grid = grid,
	num = num,
	expiration = expiration,
	recyclable = recyclable,
	strengthLv = isEquip and strengthLv or nil,
	hint =root.hint,
	powerHint =root.powerHint ,
	effect = effect,
	showBind = showBind and isBind,
	red_mask = red_mask,
	using = using,
	isActive = isActive,
})
------------------------------------------------------------------------------------

-- 触摸事件
if touchable or callback then
	Mnode.listenTouchEvent(
	{
		node = root,
		swallow = params.swallow,
		begin = function(touch, event)
			local node = event:getCurrentTarget()
			
			if node.catch then return false end
			if not IsNodeValid(node) or not node:isVisible() then
				return false
			end
			local inside = Mnode.isTouchInNodeAABB(node, touch)
			if inside and node:isClippingParentContainsPointEx(touch:getLocation()) then
				node.catch = true
				node.recovered = false
				
				local originalScale = node.originalScale or node:getScale()
				node.originalScale = originalScale
				local Manimation = require "src/young/animation"
				node:setScale(originalScale)
				local action = cc.ScaleTo:create(0.2, originalScale*1.2)
				node:runAction( Manimation:buffer(
				{
					action = action,
					buffer = Manimation.eEnterStage,
				}))
				--dump("begin")
				return true
			end
			
			return false
		end,
		
		moved = function(touch, event)
			local node = event:getCurrentTarget()
			if node.recovered then return end
			
			local inside = Mnode.isTouchInNodeAABB(node, touch)
			if not inside then
				node.recovered = true
				
				local originalScale = node.originalScale
				
				local Manimation = require "src/young/animation"
				local action = cc.ScaleTo:create(0.2, originalScale)
				node:runAction( Manimation:buffer(
				{
					action = action,
					buffer = Manimation.eBackInOut,
				}))
				
				--dump("end")
			end
		end,
		
		ended = function(touch, event)
			local node = event:getCurrentTarget()
			
			node.catch = false
			
			if not node.recovered then 
				local originalScale = node.originalScale
				local Manimation = require "src/young/animation"
				local action = cc.ScaleTo:create(0.2, originalScale)
				node:runAction( Manimation:buffer(
				{
					action = action,
					buffer = Manimation.eBackInOut,
				}))
				
				--dump("end")
			end
			
			if Mnode.isTouchInNodeAABB(node, touch) and callback then
				local protoId = MPackStruct.protoIdFromGird(root.mGrid)
				if protoId ~= nil then
					local MpropOp = require "src/config/propOp"
					AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
				end
				
				if callback == "tips" then
					local Mtips = require "src/layers/bag/tips"
					Mtips.new(
					{
						grid = root.mGrid,
						pos = node:getParent():convertToWorldSpace( cc.p(node:getPosition()) ),
						isOther = isOther,
						isBind = isBind,
					})
				elseif type(callback) == "function" then
					callback(touch, event)
				end
			end
		end,
	})
end
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------

--设置回调（ value值可以为  "tips" or function() or nil ）
function root:setCallback( value )
	callback = value
end



return root
end