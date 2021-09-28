
local RankListDetailBox = class("RankListDetailBox", function (param)	
	return  require("utility.ShadeLayer").new()
end)



function RankListDetailBox:ctor(cellData)

	self:initData(cellData)

	local rootProxy = CCBProxy:create()
    self._rootnode = {}

    local rootnode = CCBuilderReaderLoad("rankList/rank_detail_box.ccbi", rootProxy, self._rootnode)
    rootnode:setPosition(display.cx, display.cy)
    self:addChild(rootnode, 1)

    self:initContent()

	ResMgr.setControlBtnEvent(self._rootnode["view_formation_btn"], function()
	    self:onViewFormation()
	end)

	ResMgr.setControlBtnEvent(self._rootnode["add_friend_btn"], function()
	    self:onAddFriend()
	end)

	ResMgr.setControlBtnEvent(self._rootnode["close_btn"], function()
	    self:removeSelf()
	end)
	
end

function RankListDetailBox:initContent()
	if game.player:checkIsSelfByAcc(self.account) then
		self._rootnode["add_friend_btn"]:setVisible(false)
	end

	self._rootnode["zhanli_num"]:setString(self.battlepoint)
	ResMgr.refreshIcon({id = self.resId,itemBg = self._rootnode["headIcon"],resType = ResMgr.HERO,cls = self.cls})

	self._rootnode["player_name"]:setString(self.name)

	self.lvlTTF =  ResMgr.createShadowMsgTTF({text = "",color = ccc3(255,222,0),size = 22})--n
	self._rootnode["lvl_icon"]:getParent():addChild(self.lvlTTF)
	self.lvlTTF:setString(self.grade) -- 等级
	self.lvlTTF:setPosition(self._rootnode["lvl_icon"]:getPositionX() + self._rootnode["lvl_icon"]:getContentSize().width,self._rootnode["lvl_icon"]:getPositionY())
end

function RankListDetailBox:initData(cellData)
	self.name        = cellData.name        or 0
	self.account     = cellData.account
	self.battlepoint = cellData.attack      or 0
	self.resId       = cellData.resId       or 0  
	self.cls         = cellData.cls         or 1

	self.roleId      = cellData.roleId      or 0
	self.rank        = cellData.rank        or 0

	self.gonghui     =  cellData.faction    

	self.grade       = cellData.grade       or 0  --等级
	self.battleStars = cellData.battleStars or 0

	self.battleId    = cellData.battleId    or 5 -- 副本id

end

function RankListDetailBox:onAddFriend()
	local applyBox = require("game.Friend.FriendApplyBox").new({account = self.account})
	display.getRunningScene():addChild(applyBox, BOX_ZORDER.BASE)
end

function RankListDetailBox:onViewFormation()

	local layer = require("game.form.EnemyFormLayer").new(1, self.account)
    layer:setPosition(0, 0)
    game.runningScene:addChild(layer, 10000000)
end















return RankListDetailBox