--[[
    文件名：GuildBuildLvUpLayer
    描述：帮派建筑升级页面
    创建人：chenzhong
    创建时间：2017.3.7
-- ]]

local GuildBuildLvUpLayer = class("GuildBuildLvUpLayer",function()
	return display.newLayer()
end)

function GuildBuildLvUpLayer:ctor()
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --初始化页面控件
    self:initUI()
	self:addBuildList()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

function GuildBuildLvUpLayer:initUI()
	-- 创建背景
    self.mBgSprite = ui.newSprite("c_34.jpg")
    --self.mBgSprite:setPosition(cc.p(320, 568))
    self.mBgSprite:setAnchorPoint(cc.p(0, 0))
    local size = self.mBgSprite:getContentSize()
    self.mBgSprite:setScaleX(640 / size.width)
    self.mBgSprite:setScaleY(1136 / size.height)
    --mapBg1Sprite:setScale(Adapter.MinScale)
    self.mBgSprite:setPosition(0, 0)
    self.mParentLayer:addChild(self.mBgSprite)

	-- 创建人物
    local meinv = ui.newSprite("bp_17.jpg")
    self.mParentLayer:addChild(meinv)
    meinv:setPosition(cc.p(320, 931))

    --返回按钮
    local returnButton = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(570, 1030),
        clickAction = function (sender)
            Notification:postNotification(EventsName.eGuildHomeAll)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(returnButton)

    -- 下方列表背景
    local listBack = ui.newScale9Sprite("c_19.png", cc.size(640, 738))
    listBack:setAnchorPoint(cc.p(0.5, 1))
    listBack:setPosition(cc.p(320, 738))
    self.mParentLayer:addChild(listBack)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(625,530))
    listBg:setPosition(320, 375)
    self.mParentLayer:addChild(listBg)

    -- 文字描述
    local decLabel = ui.newLabel({
        text = TR("帮派建设可以增加个人贡献哦"),
        outlineColor = cc.c3b(0x28, 0x28, 0x29),
        outlineSize = 2,
        valign = ui.VERTICAL_TEXT_ALIGNMENT_TOP,
        size = 24,
        dimensions = cc.size(300, 0),
        anchorPoint = cc.p(0, 1)
    })
    decLabel:setPosition(20, 836)
    self.mParentLayer:addChild(decLabel)

    -- 帮派信息
    local guildInfo = GuildObj:getGuildInfo()
    --帮派资金
    local foundLabel = ui.newLabel({
        text = TR("帮派资金: {%s}#FA8005 %s", "db_1134.png", tostring(guildInfo.GuildFund)),
        align = cc.TEXT_ALIGNMENT_RIGHT,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    foundLabel:setAnchorPoint(cc.p(0, 0.5))
    foundLabel:setPosition(35, 675)
    self.mParentLayer:addChild(foundLabel)
    self.mFoundLabel = foundLabel

    local haveContrBack = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    haveContrBack:setPosition(cc.p(205, 675))
    self.mParentLayer:addChild(haveContrBack)
end

--添加建筑升级列表
function GuildBuildLvUpLayer:addBuildList()
	--建设数据
	local buildData = GuildBuildingLvRelation.items

	--存储id
	local keyData ={}
	for k,v in pairs(buildData) do
		keyData[#keyData + 1] = k
	end

	--对id进行排序
	table.sort( keyData, function (a, b)
		return a < b
	end )

	--图片和文字数据
	local newBuildData = {
		--大厅
		[1] = {
			itemId = keyData[1],
			logoPic = "bp_27.png",
			scale = 1,
			text1 = TR("下级人数上限:%s%d", Enums.Color.eOrangeH, self:getMemberMaxNum(self:getBuildLvFromCache(keyData[1]) + 1)+(GuildObj:getGuildInfo().ExtendCount or 0)),
		},
		--商店
		[2] = {
			itemId = keyData[2],
			logoPic = "bp_27.png",
			scale = 1,
			text1 = TR("需要大厅等级:%s%d", Enums.Color.eOrangeH, self:getBuildLvFromCache(keyData[2]) + 1),
		},
		[3] = {
			scale = 1,
			logoPic = "bp_27.png",
		}
	}

	-- 创建ListView列表
    self.listView = ccui.ListView:create()
    self.listView:setItemsMargin(10)
    self.listView:setDirection(ccui.ListViewDirection.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(630, 510))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical)
    self.listView:setPosition(cc.p(320, 628))
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.mParentLayer:addChild(self.listView)

    for i,v in ipairs(newBuildData) do
        self.listView:pushBackCustomItem(self:createBuildCell(i, v))
    end

	-- --添加控件
	-- for i,v in ipairs(newBuildData) do
	-- 	self.mParentLayer:addChild(self:createBuildCell(i,v):setPosition(320, 550 - (i - 1) * 170))
	-- end
end

--创建单个建筑升级信息
--[[
	params:
	table data:
	{
		itemId:id
		logoPic:图片
		text1:信息
	}
]]
function GuildBuildLvUpLayer:createBuildCell(index,data)
	local itemId  = data.itemId
	local logoPic = data.logoPic
	local text1 = data.text1

	--local cellSize = cc.size(625, 140)

	local cellSize = cc.size(630, 142)

    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cellSize)

    --添加背景
    local backImage = ui.newScale9Sprite("c_54.png", cc.size(610, 142))
    backImage:setPosition(cellSize.width / 2, cellSize.height / 2)
    custom_item:addChild(backImage)

	--标签
	local logoSprite = ui.newSprite(logoPic)
	logoSprite:setPosition(cc.p(80, 52))
	-- logoSprite:setScale(0.8)
	custom_item:addChild(logoSprite)

	if index == 3 then
		local spr = ui.newSprite("bp_28.png")
		spr:setPosition(cc.p(cellSize.width / 2 + 30, 60))
		custom_item:addChild(spr)

		return custom_item
	end

	local name = GuildBuildingModel.items[itemId].name
	local lv = self:getBuildLvFromCache(itemId)
	local lvupNeed = self:getBuildLvUpExp(itemId)
	local maxLv = table.getn(GuildBuildingLvRelation.items[itemId])

	--名称和等级
	local nameLabel = ui.newLabel({
        text = TR("帮派%s  %d级", name, lv),
        size = 24,
        x = cellSize.width/2,
        y = cellSize.height - 5,
        anchorPoint = cc.p(0.5, 1),
		color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
        outlineSize = 2,
    })
	custom_item:addChild(nameLabel)

	local addInfoLabelMaxLv = function ()
		local infoLabel2 = ui.newLabel({
	        text = TR("已达到最大等级"),
	        size = 32,
	        x = 170,
	        y = 55 ,
			color = cc.c3b(0x46, 0x22, 0x0d),
			anchorPoint = cc.p(0, 0.5),
	    })
		backImage:addChild(infoLabel2)
	end

	local infoLabel1, needLabel

	--是否达到最大等级
	if lv ~= maxLv then
		--描述1
		infoLabel1 = ui.newLabel({
	        text = text1,
	        size = 20,
	        x = 170,
	        y = 75,
			color = cc.c3b(0x46, 0x22, 0x0d),
			anchorPoint = cc.p(0, 0.5),
	    })
		custom_item:addChild(infoLabel1)

		--描述2
		needLabel = ui.newLabel({
	        text = TR("升级所需花费:{%s}%s%d" , "db_1134.png", "#d38212", lvupNeed),
	        color = cc.c3b(0x46, 0x22, 0x0d),
	        size = 20,
	        x = 170,
	        y = 40,
			anchorPoint = cc.p(0, 0.5),
	    })
		custom_item:addChild(needLabel)
		local newLv = self:getBuildLvFromCache(itemId)
		if itemId == 34004000 then  --大厅
    		infoLabel1:setString(TR("下级人数上限:%s %d", "#d38212", GuildLvRelation.items[newLv + 1].memberNumMax+(GuildObj:getGuildInfo().ExtendCount or 0)))
    	elseif itemId == 34005000 then  --商店
    		infoLabel1:setString(TR("需要大厅等级:%s %d", "#d38212", newLv + 1))
    	end
	else
		addInfoLabelMaxLv()
	end

    --升级按钮
    local buildButton
    buildButton = ui.newButton({
		normalImage = "c_28.png",
		position = cc.p(530, 50),
		text = TR("升级"),
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
		clickAction = function (sender)
			--资金不够
			if self:getBuildLvFromCache(itemId) >= maxLv then
				ui.showFlashView({text = TR("已达到最大等级")})
				return
			elseif itemId == 34005000 and self:getBuildLvFromCache(itemId) >= self:getBuildLvFromCache(34004000) then
				ui.showFlashView({text = TR("大厅等级不够")})
				return
			elseif GuildObj:getGuildInfo().GuildFund < lvupNeed then
				ui.showFlashView({text = TR("帮派资金不足")})
				return
			end


			self:requestGuildBuildingLvUp(itemId, function()
				--更新本页显示
	        	local newLv = self:getBuildLvFromCache(itemId)
	        	nameLabel:setString(TR("帮派%s %d",name, newLv))

	        	-- 更新帮派资金
	        	self.mFoundLabel:setString(TR("帮派资金: {%s}#FA8005 %s", "db_1134.png", tostring(GuildObj:getGuildInfo().GuildFund)))

	        	--当达到最高等级时的显示
	        	if newLv >= maxLv then
	        		needLabel:removeFromParent()
	        		infoLabel1:removeFromParent()
	        		addInfoLabelMaxLv()
	        		buildButton:setEnabled(false)
	        	else
		        	needLabel:setString(TR("升级所需花费:{%s}%s%d", "db_1134.png", "#d38212", self:getBuildLvUpExp(itemId)))

		        	if itemId == 34004000 then  --大厅
		        		infoLabel1:setString(TR("下级人数上限:%s %d", "#d38212", GuildLvRelation.items[newLv + 1].memberNumMax+(GuildObj:getGuildInfo().ExtendCount or 0)))
		        	elseif itemId == 34005000 then  --商店
		        		infoLabel1:setString(TR("需要大厅等级:%s %d", "#d38212", newLv + 1))
		        	end
		        end
			end)
		end
		})
	custom_item:addChild(buildButton)

	if lv == maxLv then
		buildButton:setEnabled(false)
	end

	return custom_item
end

--从配置中读取成员最大数量
--[[
	params:
	lv:等级
]]
function GuildBuildLvUpLayer:getMemberMaxNum(lv)
	if lv > GuildLvRelation.items_count then
		return 0
	end

	return GuildLvRelation.items[lv].memberNumMax
end

--从缓存中读取建筑等级
--[[
	params:
	id:建筑id
]]
function GuildBuildLvUpLayer:getBuildLvFromCache(id)
	local cacheData = GuildObj:getGuildBuildInfo()
	for i,v in ipairs(cacheData) do
		if v.BuildingId == id then
			return v.Lv
		end
	end
	--没找到时
	return 1
end

--从配置文件中读取升级所需花费
--[[
	params:
	id:建筑id
]]
function GuildBuildLvUpLayer:getBuildLvUpExp(id)
	local lv = self:getBuildLvFromCache(id) + 1
	if lv > #GuildBuildingLvRelation.items[id] then
		return 0
	end

	return GuildBuildingLvRelation.items[id][lv].totalExp - GuildBuildingLvRelation.items[id][lv - 1].totalExp
end

-- =============================== 请求服务器数据相关函数 ===================

--请求建筑升级借口
--itemId   升级的建筑的Id
--callBack 请求执行的回调
function GuildBuildLvUpLayer:requestGuildBuildingLvUp(itemId ,callBack)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildBuildingLvUp",
        svrMethodData = {itemId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            --执行回调
            callBack()
        end,
    })
end

return GuildBuildLvUpLayer