local json = require("framework.json")

local xuanbaHistoryLayer = class("xuanbaHistoryLayer", function()
	return display.newLayer("xuanbaHistoryLayer")
end)

local xuanbaHistoryMsg = {
getHistoryData = function(param)
	local msg = {
	m = "cross",
	a = "crossHeroHistory"
	}
	RequestHelper.request(msg, param.callback, param.errback)
end
}

function xuanbaHistoryLayer:ctor(param)
	self._type = param.data
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("kuafu/retrospection_layer.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self._parent = param.parent
	
	--¿ç·þÀúÊ·×ó·­Ò³
	self._rootnode.left_title_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:changeHistoryInfo(1)
	end,
	CCControlEventTouchUpInside)
	
	--¿ç·þÀúÊ·ÓÒ·­Ò³
	self._rootnode.right_title_btn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:changeHistoryInfo(2)
	end,
	CCControlEventTouchUpInside)
	
	--¾´¾Æ
	self._rootnode.Apply:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self.isCanJingjiu == 1 then
			show_tip_label(common:getLanguageString("@kfs_jingjiucishu"))
			return
		end
		local function func(result, num)
			self.isCanJingjiu = result
			self._num = self._num - num
			return
		end
		local layer = require("game.kuafuzhan.jingjiuLayer").new({
		size = self.viewSize,
		fun = func,
		_number = self._num
		})
		self._parent:addChild(layer, 999999)
	end,
	CCControlEventTouchUpInside)
	
end

function xuanbaHistoryLayer:initData()
	xuanbaHistoryMsg.getHistoryData({
	callback = function(data)
		dump(data)
		self.maxHistoryRank = 0
		self.historyData = {}
		if data.info then
			for k, v in ipairs(data.info) do
				if not self.historyData[v.phase] then
					self.historyData[v.phase] = {}
				end
				table.insert(self.historyData[v.phase], v.rank, v)
				if self.maxHistoryRank < v.phase then
					self.maxHistoryRank = v.phase
				end
			end
		end
		self.isCanJingjiu = data.tag
		self._num = data.numer or 0
		self.maxHistoryNum = get_table_len(self.historyData)
		self.curHistoryIndex = math.max(1, self.maxHistoryRank)
		self:refresh()
	end,
	errback = function(data)
	end
	})
end

function xuanbaHistoryLayer:refresh()
	local historyIndex = KuafuModel.getShowPhaseLanginfo(self.curHistoryIndex)
	self._rootnode.kuafu_title:setString(common:getLanguageString("KuafuTitle", historyIndex))
	self._rootnode.left_title_btn:setVisible(false)
	self._rootnode.Apply:setVisible(false)
	self._rootnode.right_title_btn:setVisible(false)
	for i = 1, 3 do
		self._rootnode["info_node_top" .. i]:setVisible(false)
	end
	local ranks = self.historyData[self.curHistoryIndex]
	if not ranks then
		return
	end
	self._rootnode.Apply:setVisible(true)
	if self.curHistoryIndex ~= self.maxHistoryRank then
		self._rootnode.Apply:setEnabled(false)
	else
		self._rootnode.Apply:setEnabled(true)
	end
	
	if not self._type then
		self._rootnode.left_title_btn:setVisible(true)
		self._rootnode.right_title_btn:setVisible(true)
	end
	
	for i = 1, 3 do
		self._rootnode["info_node_top" .. i]:setVisible(true)
	end
	
	for index = 1, 3 do
		local rankdata = ranks[index]
		local heroImg = self._rootnode["hero_image_0" .. index]
		local heroInfoNode = self._rootnode["info_node_top" .. index]
		if rankdata then
			rankdata.fashionId = rankdata.fashionId or 0
			heroInfoNode:setVisible(true)
			heroImg:setScale(0.6)
			heroImg:setDisplayFrame(ResMgr.getHeroFrame(rankdata.resId, rankdata.cls, rankdata.fashionId))
			self._rootnode["hero_name_0" .. index]:setString(rankdata.name)
			self._rootnode["android_serves_0" .. index]:setString(rankdata.serverName)
			local factionStr = self._rootnode["guild_name_0" .. index]
			if rankdata.faction then
				factionStr:setVisible(true)
				factionStr:setString("[" .. rankdata.faction .. "]")
			else
				factionStr:setVisible(false)
			end
		else
			heroInfoNode:setVisible(false)
		end
	end
end

function xuanbaHistoryLayer:changeHistoryInfo(side)
	local newSide = self.curHistoryIndex
	if side == 1 then
		newSide = math.max(self.curHistoryIndex - 1, self.maxHistoryRank - self.maxHistoryNum + 1)
	else
		newSide = math.min(self.curHistoryIndex + 1, self.maxHistoryRank)
	end
	if self.curHistoryIndex == newSide then
		return
	end
	self.curHistoryIndex = newSide
	self:refresh()
end

function xuanbaHistoryLayer:onExit()
	self.isShowXuanbaHistoryLayer = false
end

function xuanbaHistoryLayer:onEnter()
	self.isShowXuanbaHistoryLayer = true
end

return xuanbaHistoryLayer