--Author:		bishaoqing
--DateTime:		2016-06-01 15:57:46
--Region:		好友邀请界面
local MultiInvitePanel = class("MultiInvitePanel", require("src/layers/base/BasePanel"))
local MultiDB = require("src/config/MultiCopy")

function MultiInvitePanel:ctor( nCopyId )
	-- body
	MultiInvitePanel.super.ctor(self)
end

function MultiInvitePanel:InitUI( ... )
	-- body
	MultiInvitePanel.super.InitUI(self)

	local stWinSize = cc.Director:getInstance():getWinSize()

	local uiBlackBg = cc.LayerColor:create( cc.c4b( 0 , 0 , 0 , 125 ) )
	uiBlackBg:setContentSize(stWinSize)
	self.m_uiRoot:addChild(uiBlackBg)

	GetUIHelper():AddTouchEventListener(true, uiBlackBg, nil, handler(self, self.OnClose))

	self.m_imgBg = createSprite(self.m_uiRoot, "res/common/bg/bg27.png", cc.p(stWinSize.width/2, stWinSize.height/2), cc.p(0.5, 0.5))
	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)
	

	local sprBlackBg = createScale9Sprite(self.m_imgBg, "res/common/scalable/panel_inside_scale9.png", cc.p(201, 468), cc.size(372, 450), cc.p(0.5, 1))


	self.m_sclContent = GetWidgetFactory():CreateScrollView(cc.size(372, 450), false)
    self.m_imgBg:addChild(self.m_sclContent)
    self.m_sclContent:setAnchorPoint(cc.p(0.5, 1))
	self.m_sclContent:setPosition(cc.p(201 + 5, 468))
    
	self.m_btnClose = createMenuItem( self.m_imgBg , "res/component/button/X.png" , cc.p(373, 503) , handler(self, self.OnClose) )

	local tfTitle = createLabel(self.m_imgBg, "邀请好友", cc.p(201, 504), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- self.m_btnAutoJoin = createMenuItem( self.m_imgBg , "res/component/button/50.png" , cc.p(103, 53) , handler(self, self.onAutoJoin) )
	-- local stBtnSize = self.m_btnAutoJoin:getContentSize()
	-- local tfTitle = createLabel(self.m_btnAutoJoin, "快速加入", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	-- tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- self.m_btnCreateTeam = createMenuItem( self.m_imgBg , "res/component/button/50.png" , cc.p(298, 53) , handler(self, self.onCreateTeam) )
	-- local stBtnSize = self.m_btnCreateTeam:getContentSize()
	-- local tfTitle = createLabel(self.m_btnCreateTeam, "创建队伍", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	-- tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

end

function MultiInvitePanel:AddEvent( ... )
	-- body
	MultiInvitePanel.super.AddEvent(self)
	Event.Add(EventName.GetFriendsRet, self, self.RefreshUI)
end

function MultiInvitePanel:RemoveEvent( ... )
	-- body
	MultiInvitePanel.super.RemoveEvent(self)
	Event.Remove(EventName.GetFriendsRet, self)
end

function MultiInvitePanel:RefreshUI( ... )
	-- body
	self:Reset()
	local nPadding = 10

	local vAllFriends = GetFriendCtr():getAllOnline(true)

	for _,oFriend in ipairs(vAllFriends) do
		local uiCate = self:CreateCate(oFriend)
		if IsNodeValid(uiCate) then
			self.m_sclContent:addChild(uiCate)
		end
	end

	--设置滑动控件的高度和子控件的位置
	GetUIHelper():FixScrollView(self.m_sclContent, nPadding, false)
end

--创建scrollview里面重复的部件
function MultiInvitePanel:CreateCate( oFriend )
	-- body
	local m_plCate = cc.Sprite:create("res/fb/multiple/12.png")
	local sFriendName = oFriend:getFriendName()
	local nFriendId = oFriend:getFriendSid()
	local nBattle = oFriend:getFriendBattle()
	local function onInviteClick()
	    GetMultiPlayerCtr():callMsgFromServer(nFriendId)
	end

	local tfName = createLabel(m_plCate, sFriendName, cc.p(21, 49), cc.p(0, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfName:setColor(GetUiCfg().FontColor.NameAndMoneyColor)

	local tfBattle = createLabel(m_plCate, "战斗力:", cc.p(21, 20), cc.p(0, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfBattle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	local stBattleSize = tfBattle:getContentSize()
	print("nBattle", nBattle)
	local tf_Num = createLabel(m_plCate, nBattle, cc.p(stBattleSize.width + 30, 20), cc.p(0, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tf_Num:setColor(GetUiCfg().FontColor.NomalNameColor)

	local btnInvite = createMenuItem( m_plCate , "res/component/button/48.png" , cc.p(301, 35) , onInviteClick )
	local stInviteSize = btnInvite:getContentSize()
	local tfInvite = createLabel(btnInvite, "邀请", cc.p(stInviteSize.width/2, stInviteSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfInvite:setColor(GetUiCfg().FontColor.NomalNameColor)
	return m_plCate
end

function MultiInvitePanel:Reset( ... )
	-- body
	self.m_sclContent:getContainer():removeAllChildren()
end

function MultiInvitePanel:Dispose( ... )
	-- body
	MultiInvitePanel.super.Dispose(self,...)
end

return MultiInvitePanel