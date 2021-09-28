return { new = function(params)
----------------------------------------------------------------
local MtradeOp = require "src/layers/trade/tradeOp"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
----------------------------------------------------------------
local bg = params.bg
----------------------------------------------------------------
local res = "res/layers/bag/"
----------------------------------------------------------------
local focusRes = "res/common/21.png"
local girdSize = params.girdSize or TextureCache:addImage(focusRes):getContentSize()
---------------------------
local layout = nil
local calculateLayout = function()
	layout = params.layout or {}
	if not layout.row then layout.row = 4.5 end
	if not layout.col then layout.col = 5 end
	
	layout.row = math.max(layout.row, 1)
	layout.col = math.max( math.floor(layout.col), 1 )
end; calculateLayout()
local viewSize = cc.size(girdSize.width * layout.col, girdSize.height * layout.row)
---------------------------
local marginLR, marginUD = params.marginLR or 5, params.marginUD or 5
local girdViewBgSize = cc.size(viewSize.width + 2 * marginLR, viewSize.height + 2 * marginUD)
----------------------------------------------------------------
local root = nil
if bg then 
	root = Mnode.createScale9Sprite({ src = bg, cSize = girdViewBgSize, })
else
	root = cc.Node:create(); Mnode.reset(root); root:setContentSize(girdViewBgSize)
end

local girdView = YGirdView:create(viewSize)
girdView:viewSizeSelfAdaption(false)
Mnode.addChild({
	parent = root,
	child = girdView,
	pos = cc.p(girdViewBgSize.width/2, girdViewBgSize.height/2),
})
local M = Mnode.beginNode(girdView)
----------------------------------------------------------------
userData = function(self, userData)
	if not userData then
		return self.mUserData
	else
		self.mUserData = userData
	end
end
----------------------------------------------------------------
getRootNode = function(self)
	return self:getParent()
end
----------------------------------------------------------------
mPackId = params.packId or MPackStruct.eBag
packId = function(self)
	return self.mPackId
end
----------------------------------------------------------------
--[[
	构建 girdView
--]]
----------------------------------------------------------------
-- 滚动事件
local VIEW_SCROLL = function(gv)
	local filter = gv.mFilter
	if not filter then return end
	
	if not gv:userData() then gv:userData({}) end
	local userData = gv:userData()
	userData[filter] = gv:getContentOffset()
end
----------------------------------------------------------------
-- 单击事件
local CELL_TOUCHED = function(gv, cell)
	local x, y = cell:getPosition()
	local size = cell:getContentSize()
	local newX, newY = (x + size.width/2), (y + size.height/2)
	
	local selected = gv.mFocusNode
	if not selected then
		local handler = gv.onCreateFocus or function()
			return cc.Sprite:create(focusRes)
		end
		
		if handler then
			gv.mFocusNode = Mnode.addChild(
			{
				parent = gv,
				child = handler(gv),
				pos = cc.p(newX, newY),
				zOrder = 1, -- 确保在上层
			})
			gv.onCreateFocus = nil
		end
	else
		selected:setVisible(true)
		selected:setPosition(newX, newY)
	end
	------------------------------------------------------
	local idx = cell:getIdx()
	local filter = gv.mFilter
	local mode = gv.mMode
	local packId = gv.mPackId
	
	local pack = MPackManager:getPack(packId)
	local gird = pack:getGirdByGirdId(idx+1, filter)
	------------------------------------------------------
	local numOfGirdOpened = pack:numOfGirdOpened()
	if not gird then
		if idx >= numOfGirdOpened then -- 格子未开启
			dump("格子未开启")
			if filter == MPackStruct.eAll and (mode == "normal" or mode == "access") and (packId == MPackStruct.eBag or 
			   packId == MPackStruct.eBank ) then
				local MConfirmBox = require "src/functional/ConfirmBox"
				local box = MConfirmBox.new(
				{
					handler = function(box)
						MPackManager:extendCapacity(packId, idx+1)
						if box then removeFromParent(box) box = nil end
					end,
					
					builder = function(box)
						local numOfGridWillOpen = idx + 1 - numOfGirdOpened
						return Mnode.createLabel(
						{
							src = string.format(game.getStrByKey("open_grid_tips"), numOfGridWillOpen * 10, numOfGridWillOpen),
							color = MColor.white,
							size = 20,
						})
					end,
				})
				return
			end
		else -- 格子开启了, 但是没有存放物品
			dump("没有存放物品")
		end
		
		return
	end
	-------------------------------------------------
	local protoId = MPackStruct.protoIdFromGird(gird)
	local girdId = MPackStruct.girdIdFromGird(gird)
	local num = MPackStruct.overlayFromGird(gird)
	-------------------------------------------------
	
	-- 普通模式
	if mode == "normal" then
		local handler = gv.onCellTouched
		if handler then handler(gv, cell, gird, cell.mIcon) end
	-- 存取模式
	elseif mode == "access" then
		if MpropOp.accessible(protoId) then
			if packId == MPackStruct.eBag then
				MPackManager:swapBetweenGird(packId, girdId, MPackStruct.eBank)
			elseif packId == MPackStruct.eBank then
				MPackManager:swapBetweenGird(packId, girdId, MPackStruct.eBag)
			end
		else
			TIPS({ type = 1  , str = game.getStrByKey("put_warehouse_tips") })
			dump("物品不能放入仓库")
		end
	-- 出售模式
	elseif mode == "sell" then
		if MpropOp.recyclable(protoId) then
			MPackManager:sell(girdId, num)
		else
			dump("物品不可出售")
			TIPS({ type = 1  , str = game.getStrByKey("sell_prop_tips") })
		end
	-- 交易模式
	elseif mode == "trade" then
		if not MPackStruct.attrFromGird(gird, MPackStruct.eAttrBind) then
			local MpropOp = require "src/config/propOp"
			local tradeFlag=getConfigItemByKey("TransactionLimit", "q_ItemId",MPackStruct.protoIdFromGird(gird),"q_LimitFace")
			if (tradeFlag and tradeFlag==1) then
				TIPS({ type = 1  , str = game.getStrByKey("trade_high_quality_prop_tips") })
				return
			elseif tradeFlag==nil then
				TIPS({ type = 1  , str = game.getStrByKey("trade_cant_prop_tips") })
				return
			end
			local strengthLv=MPackStruct.attrFromGird(gird, MPackStruct.eAttrStrengthLevel)
			if strengthLv and strengthLv>=1 then
				TIPS({ type = 1  , str = game.getStrByKey("trade_strenght_limit_prop_tips") })
				return
			end
			if not gv.mOneselfLocked then
				local bar = MtradeOp:searchInTradingBar(girdId)
				local available = num
				if bar then available = num - bar.tradingBarNum end
				local numLimit=getConfigItemByKey("TransactionLimit", "q_ItemId",protoId,"q_MaxNum1")
				if numLimit then
					available= math.min(numLimit,available)
				end
				if available > 1 then
					local grid = gird
					local MChoose = require("src/functional/ChooseQuantity")
					MChoose.new(
					{
						title = game.getStrByKey("put"),
						config = { sp = 1, ep = available, cur = 1 },
						builder = function(box, parent)
							local cSize = parent:getContentSize()
							
							box:buildPropName(grid)
							
							local icon = Mprop.new(
							{
								grid = grid,
								cb = "tips",
								red_mask = true,
							})
							
							-- 物品图标
							Mnode.addChild(
							{
								parent = parent,
								child = icon,
								pos = cc.p(70, 264),
							})
							
							box.icon = icon
						end,
						
						handler = function(box, value)
							MtradeOp:preparingItems(girdId, value, 0)
							removeFromParent(box)
						end,
						
						onValueChanged = function(box, value)
							box.icon:setOverlay(value)
						end,
					})
				elseif available == 1 then
					MtradeOp:preparingItems(girdId, 1, 0)
				end
			else
				dump("交易已锁定")
				TIPS({ type = 1  , str = game.getStrByKey("trade_locked_tips") })
			end
		else
			dump("绑定物品不可交易")
			TIPS({ type = 1  , str = game.getStrByKey("trade_bind_prop_tips") })
		end
	else
		dump("包裹处于异常模式")
	end
end

focused = function(self, value)
	local selected = self.mFocusNode
	if selected then selected:setVisible(value) end
end
----------------------------------------------------------------
-- 每个网格是否一样大小
local IS_CELLSIZE_IDENTICAL = function(gv)
	return true
end
----------------------------------------------------------------
-- 每个网格的大小
local SIZE_FOR_CELL = function(gv, idx)
	return girdSize.width, girdSize.height
end
----------------------------------------------------------------
-- 网格总数
local NUMS_IN_GIRD = function(gv)
	local filter = gv.mFilter
	if filter then
		local pack = MPackManager:getPack(gv.mPackId)
		--if filter == MPackStruct.eAll then
			return pack:maxNumOfGirdCanOpen()
		--else
			--return pack:numOfCategory(filter)
		--end
	else
		return 0
	end
end
----------------------------------------------------------------
-- 一组的网格数目
local NUMS_IN_GROUP = function(gv)
	return layout.col
end
----------------------------------------------------------------
local CreateCell = function(gv, idx, cell)
	local size = cell:getContentSize()
	local center = cc.p(size.width/2, size.height/2)
	---------------------------
	local pack = MPackManager:getPack(gv.mPackId)
	local gird = pack:getGirdByGirdId(idx+1, gv.mFilter)
	---------------------------
	-- 物品图标
	local numOfGirdOpened = pack:numOfGirdOpened()
	if not gird then
		-- 网格底板
		Mnode.createSprite(
		{
			src = "res/common/bg/itemBg.png",
			parent = cell,
			pos = center,
		})
		
		if idx >= numOfGirdOpened and gv.mFilter == MPackStruct.eAll then -- 格子未开启
			Mnode.createSprite({
				src = "res/group/lock/2.jpg",
				parent = cell,
				pos = center,
			})
		--else 
			-- 格子开启了, 但是没有存放物品
		end
		
		return
	end
	-------------------------------------------------
	local protoId = MPackStruct.protoIdFromGird(gird)
	local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
	local strengthLv = MPackStruct.attrFromGird(gird, MPackStruct.eAttrStrengthLevel)
	local girdId = MPackStruct.girdIdFromGird(gird)
	local num = MPackStruct.overlayFromGird(gird)
	local expiration = MPackStruct.attrFromGird(gird, MPackStruct.eAttrExpiration)
	-------------------------------------------------
	-- 是否绑定
	local isBind = MPackStruct.attrFromGird(gird, MPackStruct.eAttrBind)
	----------------------------------------------------------------------
	---------------------------------------------------------------------
	local icon = Mnode.addChild(
	{
		parent = cell,
		child = Mprop.new(
		{
			powerHint = (isEquip and gv.mPackId ~= MPackStruct.eDress) and true or nil,
			grid = gird,
			num = not isEquip and num or nil,
			showBind = true,
			isBind = isBind,
			expiration = expiration,
			strengthLv = strengthLv,
			red_mask = true,
		}),
		pos = center,
	})
	
	cell.mIcon = icon
	
    local dressPackChanged=function (...)
        if cell.mIcon then
            cell.mIcon:updatePowerArrows()
        end
    end
    --如果是装备,且能穿，就监听着装包裹变化，刷新战斗力比较提示箭头
    local MpropOp = require "src/config/propOp"
    local roleSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
	local equipSchool = MpropOp.schoolLimits(protoId)
	local roleSex = MRoleStruct:getAttr(PLAYER_SEX)
	local equipSex = MpropOp.sexLimits(protoId)
	if isEquip and (equipSchool == Mconvertor.eWhole or equipSchool == roleSchool) and (equipSex == Mconvertor.eSexWhole or equipSex == roleSex) then
        icon:registerScriptHandler(function(event)
	        if event == "enter" then
		         MPackManager:getPack(MPackStruct.eDress):register(dressPackChanged)
            elseif event == "exit" then
		         MPackManager:getPack(MPackStruct.eDress):unregister(dressPackChanged)
	        end
        end)
    end
	local mode = gv.mMode
	---------------------------
	--local nodes = {}
	---------------------------
	-- 普通模式
	if mode == "normal" then
		local handler = gv.onBuildCell
		if handler then handler(gv, idx, cell, icon) end
	-- 存取模式
	elseif mode == "access" then
		if not MpropOp.accessible(protoId) then
			icon:setMask( cc.Sprite:create("res/group/lock/3.png") )
		end
	-- 出售模式
	elseif mode == "sell" then
		if MpropOp.recyclable(protoId) then
			icon:recyclable()
		end
	-- 交易模式
	elseif mode == "trade" then
		if not isBind then
			local bar = MtradeOp:searchInTradingBar(girdId)
			if bar then
				local tradingBarNum = bar.tradingBarNum
				icon:setOverlay(num - tradingBarNum)
				if tradingBarNum > 0 then
					icon:setMask("res/layers/trade/2.png")
				end
			end
		end
	else
		dump("包裹处于异常模式")
	end
	---------------------------
	-- Mnode.overlayNode(
	-- {
		-- parent = icon,
		-- nodes = nodes,
	-- })
	---------------------------
end

-- 构建标号为idx的网格
local CELL_AT_INDEX = function(gv, idx)
	--cclog("-----------idx = " .. idx .. "--------")
	local width, height = SIZE_FOR_CELL(gv, idx)
	
	local createContent = function(cell)
		local handler = gv.onCreateCell or CreateCell
		if handler then handler(gv, idx, cell) end
	end
	
	local cell = gv:dequeueCell()
	if not cell then
		cell = YGirdViewCell:create()
		cell:setContentSize(width, height)
		createContent(cell)
	else
		createContent(cell)
	end
	
	return cell
end
----------------------------------------------------------------
-- 网格退出视野范围
local CELL_WILL_RECYCLE = function(gv, cell)
	cell:removeAllChildren()
end
----------------------------------------------------------------
-- 重新加载数据
refresh = function(self, filter)
	--dump("=======================")
	local old = self.mFilter or MPackStruct.eAll
	self.mFilter = filter or old
	
	self:focused(false)
	
	self:unregisterEventHandler(YGirdView.VIEW_SCROLL)
	self:reloadData()
	
	if self.mFilter == MPackStruct.eAll then
		self:registerEventHandler(VIEW_SCROLL, YGirdView.VIEW_SCROLL)
		local userData = self:userData()
		if userData and userData[self.mFilter] then
			self:setContentOffset(userData[self.mFilter])
		end
	end
end

-- 物品分类
filter = function(self)
	return self.mFilter
end
----------------------------------------------------------------
-- 模式
mMode = params.mode or "normal"

mode = function(self, value)
	if value then
		if value ~= self.mMode then
			self.mMode = value
			self:refresh()
		end
	else
		return self.mMode
	end
end
----------------------------------------------------------------
-- 初始化 girdView
local initGirdView = function(gv)

	if not params.ignoreCellTouch then
		gv:registerEventHandler(CELL_TOUCHED, YGirdView.CELL_TOUCHED)
	end
	
	gv:registerEventHandler(CELL_WILL_RECYCLE, YGirdView.CELL_WILL_RECYCLE)
	gv:registerEventHandler(IS_CELLSIZE_IDENTICAL, YGirdView.IS_CELLSIZE_IDENTICAL)
	gv:registerEventHandler(SIZE_FOR_CELL, YGirdView.SIZE_FOR_CELL)
	gv:registerEventHandler(CELL_AT_INDEX, YGirdView.CELL_AT_INDEX)
	gv:registerEventHandler(NUMS_IN_GIRD, YGirdView.NUMS_IN_GIRD)
	gv:registerEventHandler(NUMS_IN_GROUP, YGirdView.NUMS_IN_GROUP)
	gv:setDelegate()
end; initGirdView(girdView)
----------------------------------------------------------------
-- 显示选项卡
refreshWithTab = function(self, config)
	-- local config = config or {}
	
	-- local filter = config.filter
	-- local ori = config.ori or "|"
	-- local origin = config.origin or "ro"
	
	-- local tabs, filters = nil, nil
	-- if ori ~= "|" then
	-- 	tabs = { game.getStrByKey("all"), game.getStrByKey("equipment"), game.getStrByKey("drug"), game.getStrByKey("another") }
	-- 	filters = {
	-- 		MPackStruct.eAll,
	-- 		MPackStruct.eEquipment,
	-- 		MPackStruct.eMedicine, 
	-- 		MPackStruct.eOther,
	-- 	}
	-- else
	-- 	tabs = { game.getStrByKey("another"), game.getStrByKey("drug"), game.getStrByKey("equipment"), game.getStrByKey("all") }
	-- 	filters = {
	-- 		MPackStruct.eOther,
	-- 		MPackStruct.eMedicine, 
	-- 		MPackStruct.eEquipment,
	-- 		MPackStruct.eAll,
	-- 	}
	-- end
	
	-- local selected = ori ~= "|" and 1 or 4
	-- for i, v in pairs(filters) do
	-- 	if v == filter then
	-- 		selected = i
	-- 		break
	-- 	end
	-- end
	
	-- local arrows = cc.MenuItemImage:create("res/group/arrows/9.png", "")
	
	-- local TabControl = Mnode.createTabControl(
	-- {
	-- 	src = {"res/component/TabControl/9.png", "res/component/TabControl/10.png"},
	-- 	color = {MColor.lable_yellow, MColor.lable_yellow},
	-- 	size = 25,
	-- 	titles = tabs,
	-- 	margins = config.margin or 5,
	-- 	ori = ori,
	-- 	cb = function(node, tag)
	-- 		local x, y = node:getPosition()
	-- 		local size = node:getContentSize()
	-- 		arrows:setPosition(x+size.width/2+6, y)
	-- 		self:refresh(filters[tag])
	-- 	end,
	-- 	selected = selected,
	-- })
	
	-- TabControl:addChild(arrows)
	
	-- Mnode.overlayNode(
	-- {
	-- 	parent = self:getRootNode(),
	-- 	{
	-- 		node = TabControl,
	-- 		origin = origin,
	-- 		offset = config.offset,
	-- 	}
	-- })
	local tabs = { game.getStrByKey("all"), game.getStrByKey("equipment"), game.getStrByKey("drug"), game.getStrByKey("another") }
	local filters = {
		MPackStruct.eAll,
		MPackStruct.eEquipment,
		MPackStruct.eMedicine, 
		MPackStruct.eOther,
	}
	local offset =  cc.p(-126,-126)
	local callback = function(idx)
   		self:refresh(filters[idx])
  	end
	require("src/LeftSelectNode").new(self:getRootNode(),tabs,cc.size(118,500),offset,callback)
	self:refresh(filters[1])
end
----------------------------------------------------------------
-- 定位到某一个物品, 返回物品位置
girdView.locateItem = function(gv, protoId)
	--local filter = gv.mFilter
	local pack = MPackManager:getPack(gv.mPackId)
	local num, girdId = pack:countByProtoId(protoId)
	--dump(girdId, "girdId")
	if num == 0 then return end
	
	local cell_idx = nil
	if gv.mFilter == MPackStruct.eAll then
		cell_idx = girdId-1
	else
		cell_idx = pack:filterGirdId(girdId, gv.mFilter)-1
	end
	
	--dump(cell_idx, "cell_idx")
	local x, y = gv:getPositionFromIndex(cell_idx)
	local width, height = SIZE_FOR_CELL(gv, cell_idx)
	local cp = cc.p(x + width/2, y + height/2)
	local view_size = gv:getViewSize()
	local container = gv:getContainer()
	local container_size = container:getContentSize()
	--local pos_in_world = gv:getParent():convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_world = gv:convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_container = container:convertToNodeSpace(pos_in_world)
	local container_pos = gv:getContentOffset()
	local vector = cc.p(0, pos_in_container.y - cp.y)
	gv:setContentOffset(cc.p(container_pos.x + vector.x, container_pos.y + vector.y))
	container_pos = gv:getContentOffset()
	if container_pos.y > 0 then
		if container_size.height >= viewSize.height then
			gv:setContentOffset(cc.p(0, 0))
		else
			gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
		end
	elseif container_pos.y < (viewSize.height-container_size.height) then
		gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
	end
	
	local cell = gv:cellAtIndex(cell_idx)
	--local ret = cell:getParent():convertToWorldSpace(cp)
	--dump(ret, "ret")
	return cell
end
----------------------------------------------------------------
-- 定位到某一个物品, 返回物品位置
girdView.locateFirstLockItem = function(gv)
	--local filter = gv.mFilter
	local pack = MPackManager:getPack(gv.mPackId)
	--local num, girdId = pack:countByProtoId(protoId)
	--dump(girdId, "girdId")
	--if num == 0 then return end
	
	local cell_idx = nil
	-- if gv.mFilter == MPackStruct.eAll then
	-- 	cell_idx = girdId-1
	-- else
	-- 	cell_idx = pack:filterGirdId(girdId, gv.mFilter)-1
	-- end
	cell_idx = pack:numOfGirdOpened()
	cell_idx=math.min(cell_idx,pack:maxNumOfGirdCanOpen()-1)
	--dump(cell_idx, "cell_idx")
	local x, y = gv:getPositionFromIndex(cell_idx)
	local width, height = SIZE_FOR_CELL(gv, cell_idx)
	local cp = cc.p(x + width/2, y + height/2)
	local view_size = gv:getViewSize()
	local container = gv:getContainer()
	local container_size = container:getContentSize()
	--local pos_in_world = gv:getParent():convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_world = gv:convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_container = container:convertToNodeSpace(pos_in_world)
	local container_pos = gv:getContentOffset()
	local vector = cc.p(0, pos_in_container.y - cp.y)
	gv:setContentOffset(cc.p(container_pos.x + vector.x, container_pos.y + vector.y))
	container_pos = gv:getContentOffset()
	if container_pos.y > 0 then
		if container_size.height >= viewSize.height then
			gv:setContentOffset(cc.p(0, 0))
		else
			gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
		end
	elseif container_pos.y < (viewSize.height-container_size.height) then
		gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
	end
	
	local cell = gv:cellAtIndex(cell_idx)
	--local ret = cell:getParent():convertToWorldSpace(cp)
	--dump(ret, "ret")
	--dump(cell)
	return cell
end
----------------------------------------------------------------		
local dataSourceChanged = function(observable, event, pos, pos1, gird)
	local filter = girdView.mFilter; if not filter then return end
	
	--dump({ event = event, pos = pos, pos1 = pos1 })
	if event == "reset" or event == "extendCapacity" then
		girdView:refresh()
	elseif filter == MPackStruct.eAll and (event == "+" or event == "-" or event == "=") then
		girdView:updateCellAtIndex(pos-1)
	else
		girdView:refresh()
	end

	local handler = girdView.onDataChanged
	if handler then handler(girdView, observable, event, pos, gird) end
end

local tradingBarListener = function(observable, event, ...)
	if event == "otherCanceled" then
		--dump("bag:otherCanceled")
		
	elseif event == "oneselfGoodsChanged" then
		--dump("bag:oneselfGoodsChanged")
		
		local goods = ...
		
		if goods.tradingBarPos == -1 then
			--dump(goods, "自己元宝变化")
			return
		end
		
		local filter = girdView.mFilter
		
		if filter == MPackStruct.eAll then
			girdView:updateCellAtIndex(goods.bagPos-1)
		else
			local bag = MPackManager:getPack(MPackStruct.eBag)
			girdView:updateCellAtIndex(bag:filterGirdId(goods.bagPos, filter)-1)
		end
		
	elseif event == "otherGoodsChanged" then
		--dump("bag:otherGoodsChanged")
		
	elseif event == "oneselfLocked" then
		--dump("bag:oneselfLocked")
		girdView.mOneselfLocked = true
		
	elseif event == "otherLocked" then
		--dump("bag:otherLocked")
		
	elseif event == "oneselfCompleted" then
		--dump("bag:oneselfCompleted")
		
	elseif event == "tradeCompleted" then
		--dump("bag:tradeCompleted")
		
	else
		--dump("bag:未知事件")
	end
end

girdView:registerScriptHandler(function(event)
	if event == "enter" then
		MPackManager:getPack(girdView.mPackId):register(dataSourceChanged)
		if girdView.mMode == "trade" then
			MtradeOp:register(tradingBarListener)
		end
       
	elseif event == "exit" then
		MPackManager:getPack(girdView.mPackId):unregister(dataSourceChanged)
		if girdView.mMode == "trade" then
			MtradeOp:unregister(tradingBarListener)
		end
    end
end)
----------------------------------------------------------------
return girdView
end }