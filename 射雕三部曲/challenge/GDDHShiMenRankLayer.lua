--[[
	文件名：GDDHGuideRankLayer.lua
	描述：武林大会排行榜帮派排名页面
	创建人：liucunxin
	创建时间：2016.1.3
--]]

local GDDHGuideRankLayer = class("GDDHGuideRankLayer", function()
    return display.newLayer()
end)

-- 构造函数
--[[
	params:
        GuildInfo:帮派
        [
            {
                Rank:排名
                GuildName:帮派名称
                Integral：帮派积分
                LV：帮派等级
                IsSelfGuild：是否是自己的帮派（true/false）
                LeaderName:会长名（休战时返回）
                LeaderId：会长玩家id（休战时返回）
                LeaderLv：会长等级（休战时返回）
                LeaderHeadImageId：会长头像（休战时返回）
                LeaderFashionModelId:时装id（休战时返回）
            }
        ] 			-- 帮派排名数据
--]]
function GDDHGuideRankLayer:ctor(params)
    -- 帮派数据
    if params.guildList and next(params.guildList) then
        self.mGuildList = params.guildList
    else
        self:noneGuideUI()
        return
    end
    -- 帮派数据按积分按从小到大进行排名
    table.sort(self.mGuildList, function(a, b) return a.Rank < b.Rank end)

    -- 测试数据
	---------------
	-- self.mTestData = {}
	-- local tempData = {
	-- 	Rank = 5,
	-- 	GuildName = "1111111111",
	-- 	Integral = "555",
	-- 	LV = 10,
	-- }
	-- for i = 1, 7 do
	-- 	table.insert(self.mTestData, tempData)
	-- end
	---------------
	self:createListView()
end

function GDDHGuideRankLayer:noneGuideUI()
    local noneSprite = ui.createEmptyHint(TR("暂无帮派排行"))
    self:addChild(noneSprite)
    noneSprite:setPosition(cc.p(320, 600))
end

-- 创建listview
function GDDHGuideRankLayer:createListView()
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 840))
    underBgSprite:setPosition(320, 540)
    self:addChild(underBgSprite)

	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 820))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(3)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(303, 830))
    underBgSprite:addChild(self.mListView)

    -- for i = 1, 7 do 
    -- 	self.mListView:pushBackCustomItem(self:createItem(self.mTestData[i]))
    -- end

    for _, v in ipairs(self.mGuildList) do
        self.mListView:pushBackCustomItem(self:createItem(v))
    end
end

-- 创建条目
function GDDHGuideRankLayer:createItem(data)
    -- 创建cell
    local width, height = 590, 126
    local customCell = ccui.Layout:create()
    -- customCell:setPosition(cc.p(self.mListView:getContentSize().width * 0.5, 0))
    customCell:setContentSize(cc.size(width, height))
	-- 背景条
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    bgSprite:setPosition(5, 0)
	bgSprite:setAnchorPoint(cc.p(0, 0))
	customCell:addChild(bgSprite)

	local rankPic = nil
    if data.Rank == 1 then
        rankPic = "c_44.png"
    elseif data.Rank == 2 then
        rankPic = "c_45.png"
    elseif data.Rank == 3 then
        rankPic = "c_46.png"
    end

 	-- 排名
    if rankPic then
        local rankSpr = ui.newSprite(rankPic)
        rankSpr:setPosition(width * 0.13, height * 0.5)
        customCell:addChild(rankSpr)
    else
        local rankLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = data.Rank,
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 40
        })
        rankLabel:setPosition(cc.p(width * 0.13, height * 0.5))
        customCell:addChild(rankLabel)
    end

    -- 帮派名字
    local guideNameLabel = ui.newLabel({
    	text = TR("%s", data.GuildName),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    guideNameLabel:setAnchorPoint(cc.p(0, 0.5))
    guideNameLabel:setPosition(width * 0.25, height * 0.7)
    customCell:addChild(guideNameLabel)
    
    -- 积分、威望等级
    local integralLabel = ui.newLabel({
    	text = TR("积分:#249029%s                        #46220d等级  #ff974a%s 级", data.Integral, data.LV),
        color = cc.c3b(0x46, 0x22, 0x0d),

	})
	integralLabel:setAnchorPoint(cc.p(0, 0.5))
	integralLabel:setPosition(cc.p(width * 0.25, height * 0.35))
	customCell:addChild(integralLabel)


	return customCell
end

return GDDHGuideRankLayer