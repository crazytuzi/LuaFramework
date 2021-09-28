--[[
    文件名：CommonLayer.lua
	描述：底部导航按钮和顶部玩家资源信息显示通用页面
	创建人：liaoyuangang
	创建时间：2016.3.30
--]]

local CommonLayer = class("CommonLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各个字段为
	{
		needMainNav: 是否需要最底部的导航按钮
		needFAP: 是否需要显示战力，如果有 topInfos 显示，则默认为true， 否则默认为 false
		topInfos: 页面最顶部的玩家拥有资源数量显示信息，比如 
			{
				ResourcetypeSub.eDiamond, 
				ResourcetypeSub.eGold, 
				{
					resourceTypeSub = ResourcetypeSub.eFunctionProps, 
					modelId = 16050001
				}
				...
			}
	}
]]
function CommonLayer:ctor(params)
	self.mParams = params or {}
	--dump(params, "params:")

	self.mParentNode = ui.newStdLayer()
    self:addChild(self.mParentNode)

    -- 创建顶部信息
    self:createTopInfo()
	
	-- 最底部导航按钮页面(因为底部导航按钮应该显示在最上面，所以需要最后 addChild)
	if self.mParams.needMainNav then
	    self.mMainNavLayer = require("commonLayer.MainNavLayer"):create({
	    	currentLayerType = params.currentLayerType,
	    	})
	    self:addChild(self.mMainNavLayer)
	end
end

-- 创建顶部信息
function CommonLayer:createTopInfo()
	-- 不需要顶部信息
	local topInfo = self.mParams.topInfos
	-- 如果有topInfos信息，则 needFAP 默认为true， 否则默认为false
	local needFAP = topInfo and (self.mParams.needFAP ~= false) or self.mParams.needFAP
	if not topInfo and not needFAP then
		return
	end

	-- 显示顶部信息的背景
	local bgSprite = ui.newSprite("c_03.png")
	bgSprite:setPosition(320, 1136)
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	self.mParentNode:addChild(bgSprite)

	local infoPosY = 1110

	-- 战力信息
	local tempPosX = 75
	if needFAP then
		tempPosX = 220

		-- 显示战力的背景
        local FAPBgSprite = ui.newSprite("c_23.png")
        FAPBgSprite:setPosition(10, infoPosY)
        FAPBgSprite:setAnchorPoint(cc.p(0, 0.5))
        self.mParentNode:addChild(FAPBgSprite)
        -- 显示战力的标识
        local tempSprite = ui.newSprite("c_127.png")
        tempSprite:setPosition(20, infoPosY)
        self.mParentNode:addChild(tempSprite)
        -- 显示战力值的label
        local oldFAP = PlayerAttrObj:getPlayerAttrByName("FAP")
        local FAPLabel = ui.newLabel({
        	text = Utility.numberFapWithUnit(oldFAP),
        	size = 18,
        	color = Enums.Color.eWhite,
        })
        FAPLabel:setAnchorPoint(cc.p(0, 0.5))
        FAPLabel:setPosition(40, infoPosY)
        self.mParentNode:addChild(FAPLabel)
        -- 注册战力值改变的事件
        local function setLabelStr()
        	local newFAP = PlayerAttrObj:getPlayerAttrByName("FAP")
        	FAPLabel:setString(Utility.numberFapWithUnit(newFAP))
	    end
	    Notification:registerAutoObserver(FAPLabel, setLabelStr, EventsName.eFAP)
	end

	-- 其它的顶部信息
	if topInfo then
		-- 需要添加按钮的资源
		local needAddAttr = {
			[ResourcetypeSub.eDiamond] = 1,
			[ResourcetypeSub.eGold] = 2,
		}

		local tempInfos = clone(topInfo)
		-- 排序显示顺序
		table.sort(tempInfos, function(v1, v2)
			local v1IsTable = type(v1) == "table"
			local v2IsTable = type(v2) == "table"

			-- 第一个是物品，第二个是玩家属性
			if v1IsTable and not v2IsTable then
				return true
			end
			-- 第一个是玩家属性，第二个是物品
			if not v1IsTable and v2IsTable then
				return false
			end
			-- 两个都是物品
			if v1IsTable and v2IsTable then
				return v1.modelId < v2.modelId
			end
			-- 两个都是玩家属性 (把元宝和铜币排在后面)
			return (needAddAttr[v1] or v1) > (needAddAttr[v2] or v2) 
		end)

		local spaceX = 150
		for index, item in ipairs(tempInfos) do
			if index > 4 then  -- 最多排列4个
				break
			end

			local isTable = type(item) == "table"
			local resType = isTable and (item.resourceTypeSub or item.resourcetypeSub) or item
			local modelId = isTable and item.modelId or nil
			local needAdd = needAddAttr[resType]
			
			local tempNode = ui.createResCount(resType, needAdd, modelId)
			tempNode:setPosition(tempPosX, infoPosY)
			self.mParentNode:addChild(tempNode)

			tempPosX = tempPosX + spaceX + (needAddAttr[resType] and 25 or 0)
		end
	end
end

-- 获取顶部显示玩家拥有资源数量信息的高度
function CommonLayer:getTopInfoHeight()
	return 52
end

-- 获取主导航按钮背景的高度
function CommonLayer:getMainNavHeight()
	if self.mMainNavLayer then
		return self.mMainNavLayer:getNavBgHeight()
	else
		return 100
	end
end

-- 根据主导航按钮类型获取主导航按钮
--[[
-- 参数
    mainNavType: 需要获取“button”的对象的主导航按钮类型 所有枚举在Enums.MainNav中定义
]]
function CommonLayer:getNavBtnObj(mainNavType)
	if self.mMainNavLayer then
		return self.mMainNavLayer:getNavBtnObj(mainNavType)
	end
end

return CommonLayer
