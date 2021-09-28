--[[
    文件名: GuildBuildLogLayer
    描述: 帮派 建设
    创建人: chenzhong
    创建时间: 2016.06.06
-- ]]

local GuildBuildLogLayer = class("GuildBuildLogLayer",function()
	return display.newLayer()
end)

function GuildBuildLogLayer:ctor()
    --初始化页面控件
    self:initUI()

    --请求数据
    self:requestGetGuildBuildLog()
end

function GuildBuildLogLayer:initUI()
	local popBgLayer = require("commonLayer.PopBgLayer"):create({
        bgSize = cc.size(496, 486),
        title = TR("帮派日志"),
        isCloseOnTouch = true,
        })
    self:addChild(popBgLayer)
    
    self.mBgSprite = popBgLayer.mBgSprite
    self.mBgWidth = popBgLayer.mBgSize.width
    self.mBgHeight = popBgLayer.mBgSize.height

    -- 添加背景
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(430, 300))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgWidth * 0.5, 120)
    self.mBgSprite:addChild(bgSprite)

    --确定按钮
    local ensureBtn = ui.newButton({
		normalImage = "c_28.png",
		position = cc.p(239, 80),
		text = TR("确定"),
		clickAction = function (sender)
			LayerManager.removeLayer(self)
		end
	})
	self.mBgSprite:addChild(ensureBtn)
end

function GuildBuildLogLayer:reFreshListView(data)
	if #data == 0 then
		local lblEmptyHint = ui.newLabel({
            text = TR("暂时没有帮派建设日志"),
            size = 28,
            x = 239,
            y = 270,
            color = Enums.Color.eBlack,
            dimensions = cc.size(350, 0),
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
        self.mBgSprite:addChild(lblEmptyHint)
        return
	end

	--listData  一条记录的信息
	local function createItem(listData)
		local model = GuildBuildtypeModel.items[listData.BuildType]

        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(350, 50))

        local nameLabel = ui.newLabel({
            text = TR("#8e4f09%s#46220d   使用（%s）", listData.PlayerName, model.name),
            size = 24,
            y = 38,
            x = 70,
            anchorPoint = cc.p(0, 0.5)
        })
        lvItem:addChild(nameLabel)

        local fundLabel = ui.newLabel({
            text = TR("#46220d帮派资金 + #539423%s", model.outputGuildFund),
            size = 24,
            y = 6,
            x = 70,
            anchorPoint = cc.p(0, 0.5)
        })
        lvItem:addChild(fundLabel)

        local sprite = ui.newSprite("c_80.png")
        sprite:setPosition(45, 35)
        lvItem:addChild(sprite)

        return lvItem
	end

	--列表
	self.logListView = ccui.ListView:create()
    self.logListView:setContentSize(cc.size(470, 285))
    self.logListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.logListView:setPosition(cc.p(239, 265))
    self.logListView:setItemsMargin(35)
    self.logListView:setBounceEnabled(false)
    self.mBgSprite:addChild(self.logListView)

    for _,v in ipairs(data) do
        self.logListView:pushBackCustomItem(createItem(v))
    end
end

-- =============================== 请求服务器数据相关函数 ===================

--获取帮派建设日志
function GuildBuildLogLayer:requestGetGuildBuildLog()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildBuildLog",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
           	local logData = response.Value.GlobalGuildBuildingLog

           	-- local data = {
           	-- 	Id = 1,
	           --  PlayerName = "哈哈哈哈哈哈",
	           --  BuildType = 34004002,
           	-- }
           	-- for i=1,10 do
           	-- 	table.insert(logData, data)
           	-- end
           	self:reFreshListView(logData)
        end,
    })
end

return GuildBuildLogLayer