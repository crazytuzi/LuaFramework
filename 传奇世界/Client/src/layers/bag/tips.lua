local Mmisc = require "src/young/util/misc"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local MMenuButton = require "src/component/button/MenuButton"
local Mtips = require "src/layers/bag/tipsCommon"
local tips = class("tips", function( ... )
	-- body
	return cc.Layer:create()
end)

function tips:ctor(params)
	self:RegEvent()
	--------------------------------------------------------
	if type(params) ~= "table" then return end
	--------------------------------------------------------
	local dress = MPackManager:getPack(MPackStruct.eDress)
	--------------------------------------------------------
	local size = 20
	local color = MColor.lable_yellow
	--------------------------------------------------------
	local root = cc.Sprite:create("res/common/bg/tips1.png")
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
	local isRideEquip=MpropOp.category(protoId)==MPackStruct.eRideEquipment
	-- 是否是装备类型
	local isEquip =not isRideEquip and not isMedal and cate == MPackStruct.eEquipment
	
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
	 
	local root = Mtips.new(params)
    ------------------------------------------------------- 

    local addLayer = self
    addLayer:addChild(root)
    root:setAnchorPoint(cc.p(0, 0))

    self.uiRoot_ = root

    local rsize = root:getContentSize()
    addLayer:setContentSize(rsize)

    if packId ~= MPackStruct.eDress and isEquip then				
        local protoId = MPackStruct.protoIdFromGird(grid)
        local kind = MequipOp.kind(protoId)
        local dressGrids = {}
        if kind == Mconvertor.eCuff then
            -- 护腕
            local dressGrid1 = dress:getGirdByGirdId(MPackStruct.eCuffLeft)
            if dressGrid1 ~= nil then table.insert(dressGrids, dressGrid1) end
            local dressGrid2 = dress:getGirdByGirdId(MPackStruct.eCuffRight)
            if dressGrid2 ~= nil then table.insert(dressGrids, dressGrid2) end

        elseif kind == Mconvertor.eRing then
            -- 戒指
            local dressGrid1 = dress:getGirdByGirdId(MPackStruct.eRingLeft)
            if dressGrid1 ~= nil then table.insert(dressGrids, dressGrid1) end
            local dressGrid2 = dress:getGirdByGirdId(MPackStruct.eRingRight)
            if dressGrid2 ~= nil then table.insert(dressGrids, dressGrid2) end
        else
            local now_dress_grid = dress:getGirdByGirdId(MPackStruct.dressId(kind))
            if now_dress_grid ~= nil then table.insert(dressGrids, now_dress_grid) end
        end

        if #dressGrids > 0 then
            addLayer:setContentSize(cc.size(rsize.width*2, rsize.height + (#dressGrids - 1)*40))            
            -- root:setPosition(cc.p(rsize.width, 0 + (#dressGrids - 1)*20))
            root:setPosition(cc.p(rsize.width, 20))
            --如果确定是对比，那么就显示特殊按钮(当前观察的装备显示对比项，身上穿的原样显示)
            root:SetIsCompare(true)
            root:ShowCompareOrDetail(true)
            

            -- local stDress1 = {packId = packId, grid = dressGrids[1], compareGrid = grid, bgType = #dressGrids}
            
            -- local comTips = Mtips.new(stDress1)
            -- root:setCompareGrid(stDress1)
            -- addLayer:addChild(comTips)
            -- comTips:setAnchorPoint(cc.p(0, 1))
            -- comTips:setPosition(cc.p(0, rsize.height + (#dressGrids - 1)*50 - (i-1)*295))

            local iDressNum = #dressGrids
            

         --    local stDress2 = {packId = packId, grid = dressGrids[2], compareGrid = grid, bgType = #dressGrids}
        	-- root:SetDress2(stDress2)

        	self.vAllDressGrids_ = {}
        	self.vAllDressTips_ = {}
            for i = 1, #dressGrids do
            	local t = {
		            packId = packId,
		            grid = dressGrids[i],
                    compareGrid = grid,
                    -- bgType = #dressGrids,
                    extraTip = true,
	            }
                local comTips = Mtips.new(t)
                if iDressNum > 1 then
	            	comTips:ShowSwitchButton(true)
	            else
	            	comTips:ShowSwitchButton(false)
	            end

                -- table.insert(self.vAllDressGrids_, t)
                -- table.insert(self.vAllDressTips_, comTips)
                self.vAllDressGrids_[i] = t
                self.vAllDressTips_[i] = comTips
                addLayer:addChild(comTips)
                comTips:setAnchorPoint(cc.p(0, 1))
                comTips:setPosition(cc.p(0, rsize.height + 20))
                comTips:SetIndex(i)
                comTips:ShowEquiped(true)

            end

            -- root:setCompareGrid(self.vAllDressGrids_[1]) 
            self:CompareWith(1)    
        end
    end

    -----------------------------------------------------------
    --析构
    self:registerScriptHandler(function (event)
		if event == "exit" then

			self:unregisterScriptHandler()
			self:dispose()
		end
	end)

	if not params.static then
		local tag = 9902
		local ref = getRunScene()
		if ref ~= nil then
			local old = ref:getChildByTag(tag)
			if old then old:removeFromParent() end
		end
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			ref = getRunScene(),
			node = addLayer,
			sp = params.pos,
			--trend = "-",
			zOrder = 200,
			swallow = true,
			tag = 9902,
		})
	end
	
	G_TUTO_NODE:setShowNode(root, SHOW_TIP)

	local closeNode = cc.Node:create()
	root:addChild(closeNode)
	closeNode:setPosition(cc.p(400, 430))
	closeNode:setContentSize(cc.size(50, 50))
	G_TUTO_NODE:setTouchNode(closeNode, TOUCH_TIP_CLOSE)



end

function tips:dispose( ... )
	-- body
	print("dispose")
	self:UnRegEvent()
end

function tips:RegEvent( ... )
	-- body
	Event.Add(EventName.ReplaceCompare, self, self.OnReplaceCompare)
end

function tips:UnRegEvent( ... )
	-- body
	Event.Remove(EventName.ReplaceCompare, self)
end

function tips:CompareWith( iIndex )
	-- body
	for k,v in pairs(self.vAllDressTips_) do
		if k ~= iIndex then
			v:setVisible(false)
		else
			v:setVisible(true)
		end
	end
	self.uiRoot_:setCompareGrid(self.vAllDressGrids_[iIndex])
end

function tips:OnReplaceCompare( iCurIndex )
	-- body
	if not iCurIndex then
		iCurIndex = 1
	end
	if not self.uiRoot_ or not self.vAllDressGrids_ or not self.vAllDressTips_ or not self.vAllDressGrids_[iCurIndex] or not self.vAllDressTips_[iCurIndex] then
		return
	end
	local iIndex = iCurIndex
	for k,v in pairs(self.vAllDressTips_) do
		if k ~= iCurIndex then
			iIndex = k
		end
	end
	self:CompareWith(iIndex)
end

return tips

