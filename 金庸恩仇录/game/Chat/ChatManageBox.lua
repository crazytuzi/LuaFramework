local ChatManageBox = class("ChatManageBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function ChatManageBox:ctor(param)
	self._account = param.account
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("chat/chat_manage_box.ccbi", rootProxy, self._rootnode)
	rootnode:setPosition(display.cx, display.cy)
	self:addChild(rootnode, 1)
	ResMgr.setControlBtnEvent(self._rootnode.close_btn, function()
		self:removeSelf()
	end,
	SFX_NAME.u_guanbi)
	ResMgr.setControlBtnEvent(self._rootnode.info_btn, function()
		self:checkInfo()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.apply_btn, function()
		self:applyFriend()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.pullBack_btn, function()
		self:pullBack()
	end)
end

function ChatManageBox:checkInfo()
	local layer = require("game.form.EnemyFormLayer").new(1, self._account)
	layer:setPosition(0, 0)
	game.runningScene:addChild(layer, self:getZOrder())
	self:removeSelf()
end

function ChatManageBox:applyFriend()
	local function applyFunc()
		RequestHelper.friend.applyFriend({
		content = common:getLanguageString("@ContentTxt"),
		account = self._account,
		callback = function(data)
			if data.result == 1 then
				ResMgr.showErr(3200115)
			else
				ResMgr.showErr(2900018)
			end
		end
		})
	end
	RequestHelper.friend.getRelation({
	facc = self._account,
	callback = function(data)
		dump(data)
		if data.status == 0 or rtnObj.status == 3 or data.status == 4 then
			if data.black == 1 then
				ResMgr.showErr(3200014)
			elseif data.blacked == 1 then
				ResMgr.showErr(3200018)
			else
				applyFunc()
			end
		elseif data.status == 1 then
			if data.black == 1 then
				ResMgr.showErr(3200019)
			else
				ResMgr.showErr(2900018)
			end
		elseif data.status == 2 then
			if data.black == 1 then
				ResMgr.showErr(3200017)
			else
				ResMgr.showErr(3200016)
			end
		end
	end
	})
end

function ChatManageBox:pullBack()
	local function pullFunc()
		RequestHelper.friend.pullBack({
		type = 1,
		facc = self._account,
		callback = function(data)
			if data.result == 1 then
				ResMgr.showErr(3200118)
			end
		end
		})
	end
	RequestHelper.friend.getRelation({
	facc = self._account,
	callback = function(data)
		if data.black == 0 then
			pullFunc()
		else
			ResMgr.showErr(3200015)
		end
	end
	})
end

function ChatManageBox:onExit()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return ChatManageBox