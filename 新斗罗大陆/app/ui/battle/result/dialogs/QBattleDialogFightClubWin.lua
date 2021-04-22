--
-- zxs
-- 地狱杀戮战斗胜利
--
local QBattleDialogBaseFightEnd = import(".QBattleDialogBaseFightEnd")
local QBattleDialogFightClubWin = class("QBattleDialogFightClubWin", QBattleDialogBaseFightEnd)

local QUIWidgetItemsBox = import("....widgets.QUIWidgetItemsBox")

function QBattleDialogFightClubWin:ctor(options, owner)
    --设置该节点启用enter事件
    self:setNodeEventEnabled(true)
    QBattleDialogFightClubWin.super.ctor(self, options, owner)
    self._audioHandler = app.sound:playSound("battle_complete")

    if options.isWin then
        self._ccbOwner.node_fight_club:setVisible(true)
        self._ccbOwner.node_bg_win:setVisible(true)
        self._ccbOwner.node_win_client:setVisible(true)
        self._ccbOwner.node_win_text_title:setVisible(true)

        local myLastInfo = remote.fightClub:getMyLastInfo()
        local myInfo = remote.fightClub:getMyInfo()
        self._ccbOwner.win_count:setString(myLastInfo.fightClubWinCount)
        self._ccbOwner.win_add:setString(myInfo.fightClubWinCount)
    	self._ccbOwner.ranking:setString(myLastInfo.fightClubRoomRank)
    	self._ccbOwner.ranking_add:setString(myInfo.fightClubRoomRank)

        self._ccbOwner.node_award_title:setVisible(true)
        self._ccbOwner.tf_award_title:setString("战斗奖励")
        self._ccbOwner.node_fight_club_award:setVisible(false)

        local awards = {}
        local winAdd = myInfo.fightClubWinCount - myLastInfo.fightClubWinCount
        if winAdd > 0 then
            local name = options.rivaleName or "对手"
            self._ccbOwner.node_fight_club_award:setVisible(true)
            self._ccbOwner.tf_male_name:setString(name.."的血腥玛丽")
        end
    else
        self._ccbOwner.node_bg_lost:setVisible(true)
        self._ccbOwner.node_lost_client:setVisible(true)

        self:hideAllPic()
        self:chooseBestGuide()
    end
end

--分数变化（+4）
function QBattleDialogFightClubWin:scoreChangeStr(num)
    if not num then
        return "" 
    end
    if num >= 0 then 
        return "( +"..num.." )"
    else
        return "( "..num.." )"
    end
end

function QBattleDialogFightClubWin:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QBattleDialogFightClubWin:onExit()
   	if self.prompt ~= nil then
   		self.prompt:removeItemEventListener()
   	end
end

function QBattleDialogFightClubWin:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:_onClose()
  	
  	--remote.fightClub:requestFightClubInfo()
end

return QBattleDialogFightClubWin