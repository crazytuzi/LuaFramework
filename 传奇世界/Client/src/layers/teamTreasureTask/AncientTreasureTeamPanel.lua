--Author:		bishaoqing
--DateTime:		2016-05-12 15:52:39
--Region:		远古宝藏组队界面
local AncientTreasureTeamPanel = class("AncientTreasureTeamPanel", require("src/layers/base/BasePanel"))
local Arg = require("src/layers/teamTreasureTask/AncientTreasureCfg")

function AncientTreasureTeamPanel:ctor( uiParent, nZorder )
	-- body
	AncientTreasureTeamPanel.super.ctor(self, uiParent, nZorder)
	GetAncientTreasureTeamCtr():GetTeamsFromServer()
	-- self:Debug()
end

function AncientTreasureTeamPanel:AddEvent( ... )
	-- body
	AncientTreasureTeamPanel.super.AddEvent(self)
	Event.Add(EventName.UpdateTeam, self, self.RefreshUI)
end

function AncientTreasureTeamPanel:RemoveEvent( ... )
	-- body
	AncientTreasureTeamPanel.super.RemoveEvent(self)
	Event.Remove(EventName.UpdateTeam, self)
end

function AncientTreasureTeamPanel:InitUI( ... )
	-- body
	AncientTreasureTeamPanel.super.InitUI(self)

	local stWinSize = cc.Director:getInstance():getWinSize()

	self.m_imgBg = createSprite(self.m_uiRoot, "res/common/bg/bg27.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ))
	local bgSize = self.m_imgBg:getContentSize()

	local uiBlack = createScale9Sprite(
        self.m_imgBg,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(402/2, 98),
        cc.size(372, 366),
        cc.p(0.5, 0)
    )

	-- self.m_oBgListener = GetUIHelper():AddTouchEventListener(true, self.m_imgBg)
	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)

	self.m_tfTitle = createLabel(self.m_imgBg, "宝藏队伍", cc.p(bgSize.width/2, bgSize.height-26), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize, false)
	self.m_tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	self.m_sclContent = GetWidgetFactory():CreateScrollView(cc.size(368, 350) ,false)
    self.m_imgBg:addChild(self.m_sclContent)
    self.m_sclContent:setAnchorPoint(cc.p(0, 1))
    self.m_sclContent:setPosition(cc.p(20, 450))


	self.m_btnClose = createMenuItem( self.m_imgBg , "res/component/button/X.png" , cc.p(bgSize.width-38, bgSize.height-26) , handler(self, self.OnClose) )

end

function AncientTreasureTeamPanel:RefreshUI( ... )
	-- body

	self:Reset()

	local vAllTeams = GetAncientTreasureTeamCtr():GetAllCach(true)

	--边距
	local nPadding = 10

	for _,oTeam in ipairs(vAllTeams) do
	-- for i=1,14 do
		local uiCate = self:CreateCate(oTeam)
		if IsNodeValid(uiCate) then
			self.m_sclContent:addChild(uiCate)
		end
	end
	--设置滑动控件的高度和子控件的位置
	GetUIHelper():FixScrollView(self.m_sclContent, nPadding)

end

function AncientTreasureTeamPanel:CreateCate( oTeam )
	-- body
	
	local m_plCate = cc.Sprite:create("res/fb/multiple/12.png")
	local stSize = m_plCate:getContentSize()
	-- m_plCate:setContentSize(cc.size(500, 100))
	local tf_name = createLabel(m_plCate, "名字", cc.p(20, stSize.height*5/7), cc.p(0, 0.5), GetUiCfg().stFontSize.NormalSize)
	tf_name:setColor(GetUiCfg().FontColor.NameAndMoneyColor)


	local tf_lv = createLabel(m_plCate, "LV60", cc.p(tf_name:getContentSize().width + 30, stSize.height*5/7), cc.p(0, 0.5), GetUiCfg().stFontSize.NormalSize)
	tf_lv:setColor(GetUiCfg().FontColor.NomalNameColor)

	local tf_treasure_name = createLabel(m_plCate, "宝藏名称:", cc.p(20, stSize.height*2/7), cc.p(0, 0.5), GetUiCfg().stFontSize.NormalSize)
	tf_treasure_name:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	local tf_percent = createLabel(m_plCate, "1/3", cc.p(tf_treasure_name:getContentSize().width + 30, stSize.height*2/7), cc.p(0, 0.5), GetUiCfg().stFontSize.NormalSize)
	tf_percent:setColor(GetUiCfg().FontColor.NomalNameColor)

	local function OnApplyClick( sender, eventType )
		-- body
		GetAncientTreasureTeamCtr():Apply(oTeam)
	end

	local bt_apply = createMenuItem(  m_plCate, "res/component/button/48.png" , cc.p(stSize.width - 20, stSize.height / 2) ,  OnApplyClick)
	bt_apply:setAnchorPoint(cc.p(0.5, 0.5))
	local stButtonSize = bt_apply:getContentSize()
	bt_apply:setPositionX(bt_apply:getPositionX() - stButtonSize.width / 2)

	local tf_apply = createLabel(bt_apply, "组 队", cc.p(stButtonSize.width / 2, stButtonSize.height / 2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.SecondTabsSize)
	tf_apply:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	if oTeam then
		--通过team对象获取数据
		local nSid = oTeam:GetSid()
		local strCapName = oTeam:GetName()
		local nCapLevel = oTeam:GetLevel()
		local nTaskRank = oTeam:GetTaskRank()
		local nTaskStatus = oTeam:GetTaskStatus()

		tf_name:setString(strCapName)
		tf_lv:setString("Lv." .. nCapLevel)
		tf_treasure_name:setString(Arg.GetTaskRankName( nTaskRank ) .. "进度:")
		tf_percent:setString(tostring(nTaskStatus) .. "/".. Arg.MaxStatus)

		tf_lv:setPositionX(tf_name:getContentSize().width + 30)
		tf_percent:setPositionX(tf_treasure_name:getContentSize().width + 30)
	end

	

	return m_plCate
end

function AncientTreasureTeamPanel:Reset( ... )
	-- body
	self.m_sclContent:getContainer():removeAllChildren()
end

function AncientTreasureTeamPanel:Dispose( ... )
	-- body
	AncientTreasureTeamPanel.super.Dispose(self)
	-- if self.m_oBgListener then
	-- 	ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.m_oBgListener)
	-- 	self.m_oBgListener = nil
	-- end
end

return AncientTreasureTeamPanel