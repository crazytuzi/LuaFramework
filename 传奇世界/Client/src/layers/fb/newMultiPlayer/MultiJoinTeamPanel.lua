--Author:		bishaoqing
--DateTime:		2016-05-31 18:35:50
--Region:		加入队伍界面
local MultiJoinTeamPanel = class("MultiJoinTeamPanel", require("src/layers/base/BasePanel"))
local MultiDB = require("src/config/MultiCopy")

function MultiJoinTeamPanel:ctor( nCopyId )
	-- body
	self.m_nCopyId = nCopyId
	MultiJoinTeamPanel.super.ctor(self)

	
	print("self.m_nCopyId", self.m_nCopyId)
end

function MultiJoinTeamPanel:InitUI( ... )
	-- body
	MultiJoinTeamPanel.super.InitUI(self)

	local stWinSize = cc.Director:getInstance():getWinSize()
	local stBgSize = cc.size(850, 600)
	self.m_imgBg = createScale9Sprite(self.m_uiRoot, "res/common/bg/bg27.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ))
	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)
	

	local sprBlackBg = createScale9Sprite(
        self.m_baseNode,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(402/2, 98),
        cc.size(372, 366),
        cc.p(0.5, 0)
    )


	self.m_sclContent = GetWidgetFactory():CreateScrollView(cc.size(300, 400), false)
    self.m_imgBg:addChild(self.m_sclContent)
    self.m_sclContent:setAnchorPoint(cc.p(0.5, 1))
	self.m_sclContent:setPosition(cc.p(179, 530))
    
	self.m_btnClose = createMenuItem( self.m_imgBg , "res/component/button/X.png" , cc.p(823, 573) , handler(self, self.OnClose) )

	local tfTitle = createLabel(self.m_imgBg, "多人守卫", cc.p(425, 572), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	self.m_btnAutoJoin = createMenuItem( self.m_imgBg , "res/component/button/1.png" , cc.p(138, 79) , handler(self, self.onAutoJoin) )
	local stBtnSize = self.m_btnAutoJoin:getContentSize()
	local tfTitle = createLabel(self.m_btnAutoJoin, "快速加入", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	self.m_btnCreateTeam = createMenuItem( self.m_imgBg , "res/component/button/1.png" , cc.p(624, 79) , handler(self, self.onCreateTeam) )
	local stBtnSize = self.m_btnCreateTeam:getContentSize()
	local tfTitle = createLabel(self.m_btnCreateTeam, "创建队伍", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)


	local reward = MultiDB[self.m_nCopyId].reward
	if reward then
		local uiReward = self:createDayReward(reward)
		if IsNodeValid(uiReward) then
			self.m_imgBg:addChild(uiReward)
			uiReward:setPosition(624,400)
		end
	end
end

function MultiJoinTeamPanel:AddEvent( ... )
	-- body
	MultiJoinTeamPanel.super.AddEvent(self)
	Event.Add(EventName.UpdateMultiPanel, self, self.RefreshUI)
end

function MultiJoinTeamPanel:RemoveEvent( ... )
	-- body
	MultiJoinTeamPanel.super.RemoveEvent(self)
	Event.Remove(EventName.UpdateMultiPanel, self)
end

function MultiJoinTeamPanel:RefreshUI( ... )
	-- body
	self:Reset()
	local nPadding = 10

	local vAllTeam = GetMultiPlayerCtr():getAllTeam(true)

	for _,oTeam in ipairs(vAllTeam) do
		local uiCate = self:CreateCate(oTeam)
		if IsNodeValid(uiCate) then
			self.m_sclContent:addChild(uiCate)
		end
	end
	-- --设置滑动控件的高度和子控件的位置
	-- GetUIHelper():FixScrollView(self.m_sclContent, nPadding, true)
end

--创建scrollview里面重复的部件
function MultiJoinTeamPanel:CreateCate( oTeam )
	-- body
	local m_plCate = cc.Sprite:create("res/blackmarket/bg.png")
	local nTeamId = oTeam:getTeamId()
	local function onReady()
		GetMultiPlayerCtr():joinTeam(nTeamId)
	end

	local btnReady = createMenuItem( m_plCate , "res/component/button/50.png" , cc.p(0, 0) , onReady )
	return m_plCate
end

--创建每日奖励节点
function MultiJoinTeamPanel:createDayReward( reward )
	-- body
	if not reward then
		return
	end
	local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local awardsConfig = DropOp:dropItem_ex(tonumber(reward));
    for i=1, #awardsConfig do
        awards[i] =  { 
              id = awardsConfig[i]["q_item"] ,       -- 奖励ID
              num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
              streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
              quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
              upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
              time = awardsConfig[i]["q_time"] ,     -- 限时时间
              showBind = true,
              isBind = tonumber(awardsConfig[i]["bdlx"]) == 1,     -- 绑定(1绑定0不绑定)
            }
    end

    local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
    -- setNodeAttr( groupAwards , cc.p( 815/2, 20 ) , cc.p( 0.5 , 0 ) )
    return groupAwards
end

--自动加入队伍
function MultiJoinTeamPanel:onAutoJoin( ... )
	-- body

end

--创建队伍
function MultiJoinTeamPanel:onCreateTeam( ... )
	-- body
end

function MultiJoinTeamPanel:Reset( ... )
	-- body
	self.m_sclContent:getContainer():removeAllChildren()
end

function MultiJoinTeamPanel:Dispose( ... )
	-- body
	MultiJoinTeamPanel.super.Dispose(self,...)
end

return MultiJoinTeamPanel