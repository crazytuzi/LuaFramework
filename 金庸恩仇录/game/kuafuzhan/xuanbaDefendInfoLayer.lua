local xuanbaDefendInfoLayer = class("xuanbaDefendInfoLayer", function()
	return require("utility.ShadeLayer").new()
end)

local defendInfoMsg = {
getBattleResultInfo = function(param)
	local _callback = param.callback
	local msg = {
	m = "cross",
	a = "battleResult"
	}
	RequestHelper.request(msg, _callback, param.errback)
end
}

function xuanbaDefendInfoLayer:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/xuanba_defend_info.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self._baseLayer = node
	self:addChild(node)
	self._battleCount = param.battleCount
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@defendInfo"))
	
	--¹Ø±Õ
	self._rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			self:removeFromParentAndCleanup(true)
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	--µ÷ÕûÕóÈÝ
	self._rootnode.defend_form_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		KuafuModel.showFormLayer()
	end,
	CCControlEventTouchUpInside)
	
end

function xuanbaDefendInfoLayer:createDefendInfoList()
	local successTimes = self.successTimes
	local failedTimes = self.failedTimes
	local successTitle = common:getLanguageString("@defendSuccess") .. ":" .. successTimes .. common:getLanguageString("@chang")
	local failedTitle = common:getLanguageString("@defendFailed") .. ":" .. failedTimes .. common:getLanguageString("@chang")
	self._rootnode.defend_success_times:setString(successTitle)
	self._rootnode.defend_failed_times:setString(failedTitle)
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height
	local listViewSize = cc.size(boardWidth, boardHeight - 10)
	
	local function createFunc(index)
		local item = require("game.kuafuzhan.xuanbaItemCell").new()
		local cell = item:create({
		itemData = self._defendInfoData[index + 1],
		revengeFunc = function(itemData)
			if KuafuModel.checkCurretntStep(enumKuafuState.xuanba, true) then
				if self._battleCount > 0 then
					KuafuModel.showChallengeEnemyForm(itemData, self, 2)
				else
					show_tip_label(common:getLanguageString("@NotDareNumber"))
				end
			end
		end
		})
		cell:setScale(0.9)
		return cell
	end
	
	local itemSize = require("game.kuafuzhan.xuanbaItemCell").new():getContentSize()
	local function refreshFunc(cell, index)
		cell:refresh(self._defendInfoData[index + 1])
	end
	
	self.challengeList = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._defendInfoData,
	cellSize = cc.size(itemSize.width, itemSize.height * 0.9)
	})
	self.challengeList:setPositionY(5)
	self._rootnode.listView:addChild(self.challengeList)
end

function xuanbaDefendInfoLayer:onEnter()
	defendInfoMsg.getBattleResultInfo({
	callback = function(data)
		--dump(data)
		self.successTimes = data.winNum
		self.failedTimes = data.loseNum
		self._defendInfoData = data.info
		--[[
		for key, team in ipairs(data.info) do
			local tbl = {}
			tbl.rank = team.rank
			tbl.level = team.level
			tbl.account = team.account
			tbl.serverId = team.serverId
			tbl.serverName = team.serverName
			tbl.roleName = team.name
			tbl.point = team.point
			tbl.faction = team.faction
			tbl.battle_point = team.battlePoint
			tbl.resTeam = resTeam
			tbl.sign = team.id
			tbl.revengen = team.revengen
			table.insert(self._defendInfoData, tbl)
		end
		]]
		self:createDefendInfoList()
	end
	})
end

function xuanbaDefendInfoLayer:onExit()
	
end

return xuanbaDefendInfoLayer