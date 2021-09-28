--[[
	文件名: DlgGuessLogLayer
	描述: 我的竞猜日志对话框
	创建人: peiyaoqiang
	创建时间: 2017.11.2
-- ]]

local DlgGuessLogLayer = class("DlgGuessLogLayer",function()
	return display.newLayer()
end)

function DlgGuessLogLayer:ctor(params)
	-- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("我的竞猜"),
        bgSize = cc.size(570, 660),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    local gayBg = ui.newScale9Sprite("c_17.png", cc.size(self.mBgSize.width-70, self.mBgSize.height-140))
    gayBg:setAnchorPoint(0.5, 1)
    gayBg:setPosition(self.mBgSize.width/2, self.mBgSize.height-65)
    self.mBgSprite:addChild(gayBg)

	-- 连接接口
	self.mBetList = {}    -- 下注列表
	self.mTotalReward = 0 -- 总共获得
	self:loadData()
end

-- 创建列表
function DlgGuessLogLayer:createListView()
    if next(self.mBetList) == nil then 
        local emptyHint = ui.createEmptyHint(TR("未参与本次竞猜"))
        emptyHint:setPosition(cc.p(self.mBgSize.width/2, self.mBgSize.height/2+50))
        self.mBgSprite:addChild(emptyHint)
        return
    end     
	-- 创建ListView列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(cc.size(self.mBgSize.width, 510))
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(cc.p(self.mBgSize.width / 2, self.mBgSize.height - 70))
    self.mBgSprite:addChild(listView)

    for _, info in ipairs(self.mBetList) do
    	listView:pushBackCustomItem(self:createCellView(info))
    end

    -- 累计获得
    local config = PvpinterTopGamble.items[16][1]  -- 获取下注的类型 默认16强第一场
    local rewardAmount = Utility.analysisStrResList(config.rewardAmount)[1]
	ui.newLabel({
		text  = TR("#73430D累计获得 {%s}#258711%s", Utility.getDaibiImage(rewardAmount.resourceTypeSub), Utility.numberWithUnit(self.mTotalReward or 0, nil, nil)),
		size  = 24,
		font  = _FONT_PANGWA,
        anchorPoint = cc.p(0, 0.5),
		x     = 40,
		y     = 50,
	}):addTo(self.mBgSprite)

    ui.newLabel({
        text  = TR("下注奖励赛后发放至领奖中心"),
        size  = 20,
        font  = _FONT_PANGWA,
        x     = self.mBgSize.width-30,
        y     = 50,
        color = Enums.Color.eBrown,
        anchorPoint = cc.p(1, 0.5),
    }):addTo(self.mBgSprite)
end

function DlgGuessLogLayer:createCellView(info)
	local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cc.size(self.mBgSize.width, 166))

    -- 背景图
    local width = self.mBgSize.width - 100
    local height = 160
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    cellBgSprite:setAnchorPoint(cc.p(0.5, 1))
    cellBgSprite:setPosition(self.mBgSize.width * 0.5, 165)
    custom_item:addChild(cellBgSprite)

    -- 标题
    local titleImage = "wlmz_30.png" 
    if info.KingRank == 1 then
        titleImage = "wlmz_25.png"
	elseif info.KingRank == 2 then
		titleImage = "wlmz_24.png"
    elseif info.KingRank == 4 then
        titleImage = "wlmz_22.png"
    elseif info.KingRank == 8 then
        titleImage = "wlmz_23.png"
    -- elseif info.KingRank == 16 then    
    --     titleImage = "wlmz_23.png"
	end
    local nameSprite = ui.newSprite(titleImage)
    nameSprite:setPosition(width * 0.5, height - 30)
    cellBgSprite:addChild(nameSprite)

	-- 下注玩家
	ui.newLabel({
		text  = TR("下注玩家:"),
		size  = 24,
		font  = _FONT_PANGWA,
        anchorPoint = cc.p(0, 0.5),
		x     = 60,
		y     = 90,
        color = Enums.Color.eBrown,
	}):addTo(custom_item)

	-- 玩家名字
    local qualityNum =  Utility.getQualityByModelId(info.TargetHeadImageId)
	ui.newLabel({
		text  = info.TargetName,
		size  = 24,
		color = Utility.getQualityColor(qualityNum, 1),
		anchorPoint = cc.p(0, 0.5),
		x     = 170,
		y     = 90
	}):addTo(custom_item)


	-- 竞猜状态
	local text_ = ""
	if info.IsWin == -1 then
		text_ = TR("#258711正在进行")
	elseif info.IsWin == 0 then
		text_ = TR("#258711竞猜失败")
	elseif info.IsWin == 1 then
		text_ = TR("#258711竞猜成功")
	end

	-- 竞猜状态
	ui.newLabel({
		text  = text_,
		size  = 24,
		font  = _FONT_PANGWA,
		x     = 60,
		y     = 46,
        anchorPoint = cc.p(0, 0.5),
		}):addTo(custom_item)

	-- 赔率1:2
    local peiLvText = PvpinterTopGamble.items[info.KingRank][info.BetsType].oddsDes or "1:1"
	ui.newLabel({
		text  = TR("#73430D赔率%s", peiLvText),
		size  = 24,
		font  = _FONT_PANGWA,
		x     = 220,
		y     = 46
	}):addTo(custom_item)


	-- 读取配置
	local config = PvpinterTopGamble.items[info.KingRank][info.BetsType]
	local rewardAmount = Utility.analysisStrResList(config.rewardAmount)[1]
	local betsAmount = Utility.analysisStrResList(config.betsAmount)[1]
	-- 获得奖金xxxx
	if info.IsWin == 1 then
		ui.newLabel({
			text  = TR("#d17b00获得奖金 {%s}#73430D%s", Utility.getDaibiImage(rewardAmount.resourceTypeSub),  Utility.numberWithUnit(rewardAmount.num or 0, nil, nil)),
			size  = 24,
			font  = _FONT_PANGWA,
			x     = 280,
			y     = 46,
			anchorPoint = cc.p(0, 0.5)
		}):addTo(custom_item)

		self.mTotalReward = self.mTotalReward + rewardAmount.num
	else
		ui.newLabel({
			text  = TR("#d17b00下注金额 {%s}#73430D%s", Utility.getDaibiImage(betsAmount.resourceTypeSub), Utility.numberWithUnit(betsAmount.num or 0, nil, nil)),
			size  = 24,
			font  = _FONT_PANGWA,
			x     = 280,
			y     = 46,
			anchorPoint = cc.p(0, 0.5)
		}):addTo(custom_item)
	end

    return custom_item
end

----------------------请求接口------------------
function DlgGuessLogLayer:loadData()
	HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "GetOwnBetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- dump(response, "GetOwnBetInfo")
            if not response or response.Status ~= 0 then
                return
            end
            self.mBetList = response.Value.PVPinterTopBetInfo or {}
			self:createListView()
        end
    })
end

return DlgGuessLogLayer
