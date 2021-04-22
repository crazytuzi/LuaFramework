
local QCCBNodeCache = class("QCCBNodeCache")

function QCCBNodeCache:ctor()
	-- UI scene
	self._cachedCCBIFile = {
		-- "ccb/Widget_HeroOverview_sheet.ccbi",
		-- "ccb/Widget_TeamArangement.ccbi",
		-- "ccb/Widget_EquipmentGrid.ccbi",
		-- "ccb/Widget_EquipmentBox.ccbi",
		-- "ccb/Widget_HeroHeadBox.ccbi",
		-- "ccb/Widget_HeroHeadStar.ccbi",
		-- "ccb/Widget_ProfessionalIcon.ccbi",
		-- "ccb/Widget_Instance_NormalBoss.ccbi",
		-- "ccb/Widget_Instance_EliteBoss.ccbi",
		-- "ccb/Widget_Instance_NormalMonster.ccbi",
		-- "ccb/Widget_Instance_EliteMonster.ccbi",
		-- "ccb/Widget_ItemBox.ccbi",
		-- "ccb/Widget_DailySignIn_Box.ccbi",
		-- "ccb/Widget_RewardRules_client3.ccbi",
		-- "ccb/Widget_shop.ccbi",
		-- "ccb/Widget_ShopItem.ccbi",
		-- "ccb/Widget_ShopVIP.ccbi",
		-- "ccb/Widget_TreasureChestDraw_Review_client2.ccbi",
		-- "ccb/Widget_TreasureChestDraw_Review_client1.ccbi",
	}

	-- Battle scene
	self._cachedCCBIFile2 = {
	}

	self._cachedCCBNode = {}
	self._root = CCNode:create()
	self._root:retain()
end

function QCCBNodeCache:purgeCCBNodeCache()
	for _, ccbView in pairs(self._cachedCCBNode) do
		if ccbView ~= nil then
			ccbView:cleanup()
			ccbView:removeFromParent()
		end
	end
	self._root:release()

	self._cachedCCBNode = {}
	self._root = CCNode:create()
	self._root:retain()
end

function QCCBNodeCache:cacheCCBNodeInOneFrame(isEnterBattle)
	self:purgeCCBNodeCache()

	local cachedCCBIFile = self._cachedCCBIFile
	if isEnterBattle == true then
		cachedCCBIFile = self._cachedCCBIFile2
	end

	for _, fileName in ipairs(cachedCCBIFile) do
		local ccbView = CCBuilderReaderLoad(fileName, CCBProxy:create(), {})
	    if ccbView == nil then
	        assert(false, "load ccb file:" .. fileName .. " faild!")
	    else
	    	if self._cachedCCBNode[fileName] ~= nil then
	    		local view = self._cachedCCBNode[fileName]
				view:cleanup()
	    		view:removeFromParent()
	    	end
	    	self._root:addChild(ccbView)
	    	self._cachedCCBNode[fileName] = ccbView
	    end
	end
end

function QCCBNodeCache:cacheCCBNode(progressFun)
	self._progressFun = progressFun

	self:purgeCCBNodeCache()

	self._currentIndex = 1
	self._totalCount = #self._cachedCCBIFile
	if self._totalCount == 0 then
		self._progressFun(1)
		self._progressFun = nil
	else
		scheduler.performWithDelayGlobal(handler(self, self._loadCCBI), 0)
	end
end

function QCCBNodeCache:_loadCCBI()
	if self._currentIndex > self._totalCount then
		if self._progressFun ~= nil then
			self._progressFun(1)
			self._progressFun = nil
		end
		return
	end

	local fileName = self._cachedCCBIFile[self._currentIndex]
	local ccbView = CCBuilderReaderLoad(fileName, CCBProxy:create(), {})
    if ccbView == nil then
        assert(false, "load ccb file:" .. fileName .. " faild!")
    else
    	if self._cachedCCBNode[fileName] ~= nil then
    		local view = self._cachedCCBNode[fileName]
    		view:removeFromParent()
    	end
    	self._root:addChild(ccbView)
    	self._cachedCCBNode[fileName] = ccbView
    end
    self._progressFun((self._currentIndex - 1) / self._totalCount)
    self._currentIndex = self._currentIndex + 1
    scheduler.performWithDelayGlobal(handler(self, self._loadCCBI), 0)
end

function QCCBNodeCache:loadCCBI(ccbi, ccbOwner)
	if ccbi == nil then
		return nil
	end

	local ccbView = self._cachedCCBNode[ccbi]
	if ccbView ~= nil then
	    return CCBuilderCloneNode(ccbView, ccbOwner)
	else
		local index = table.indexof(self._cachedCCBIFile, ccbi)
		if index ~= false then
			ccbView = CCBuilderReaderLoad(ccbi, CCBProxy:create(), {})
			self._root:addChild(ccbView)
    		self._cachedCCBNode[ccbi] = ccbView
    		return CCBuilderCloneNode(ccbView, ccbOwner)
		else
			return CCBuilderReaderLoad(ccbi, CCBProxy:create(), ccbOwner)
		end
	end
end

function QCCBNodeCache:hibernate()
    if HIBERNATE_TEXTURE and CCTextureCache.wakeupAllTextures then
		if self._root.hibernate then
			self._root:hibernate()
		end
	end
end

function QCCBNodeCache:wakeup()
	if self._root.wakeup then
		self._root:wakeup()
	end
end

return QCCBNodeCache