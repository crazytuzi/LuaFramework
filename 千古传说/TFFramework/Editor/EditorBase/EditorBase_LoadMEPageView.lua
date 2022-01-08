local tMEPageView = {}
tMEPageView.__index = tMEPageView
setmetatable(tMEPageView, require("TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel"))

function EditLua:createPageView(szId, tParams)
	print("createPageView")
	local pageView = TFPageView:create()
	pageView:setSize(CCSizeMake(400, 400))
	pageView:setBackGroundColorOpacity(50)

	-- tTouchEventManager:registerEvents(pageView)
	targets[szId] = pageView
	
	EditLua:addToParent(szId, tParams)

	print("createPageView success")
end

function EditLua:createPage(szId, tParams)
	local page = TFPanel:create()
	-- tTouchEventManager:registerEvents(page)
	targets[szId] = page
	
	EditLua:addToParent(szId, tParams)
	page:retain()
	page:removeFromParent()
	targets[tParams.szParent]:addPage(page)
	
	print("createPage success")
end

function tMEPageView:addPage(szId, tParams)
	print("addPage ")
	local page = TFPanel:create()
	page:setTouchEnabled(true)
	page:setSize(CCSizeMake(240, 130))

	local imageView = TFImage:create()
	imageView:setScale9Enabled(true)
	imageView:setTexture("test/scrollviewbg.png")
	imageView:setSize(CCSizeMake(240, 130))
	imageView:setPosition(ccp(120, 65))
	page:addChild(imageView)

	local label = TFLabel:create()
	label:setText("page" .. (targets[szId]:getCurPageIndex() + 1))
	label:setFontSize(30)
	label:setColor(ccc3(192, 192, 192))
	label:setPosition(ccp(page:getSize().width / 2, page:getSize().height / 2))
	page:addChild(label)

	targets[szId]:addPage(page)
	print("addPage success")
end

function tMEPageView:removePageAtIndex(szId, tParams)
	print("removePageAtIndex ")
	targets[szId]:removePageAtIndex(tParams.nIndex)
	print("removePageAtIndex success")
end

-- function tMEPageView:removeAllPages(szId, tParams)
-- 	print("removeAllPages ")
-- 	targets[szId]:removeAllPage()
-- 	print("removeAllPages success")
-- end

function tMEPageView:changePageIndex(szId, tParams)
	print("changePageIndex", szId, tParams)
	if tParams.nOldIndex == -1 then
		tParams.nOldIndex = targets[szId]:getPageCount()-1
	end
	local page = targets[szId]:getPage(tParams.nOldIndex)
	page:retain()
	targets[szId]:removePageAtIndex(tParams.nOldIndex)
	targets[szId]:insertPage(page, tParams.nNewIndex)
	targets[szId]:scrollToPage(0, 0)
	print("changePageIndex success")
end

function tMEPageView:scrollToPage(szId, tParams)
	print("scrollToPage ")
	targets[szId]:scrollToPage(tParams.nIndex)
	print("scrollToPage success")
end

function tMEPageView:setBounceEnabled(szId, tParams)
	print("setBounceEnabled")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setBounceEnabled then
		targets[szId]:setBounceEnabled(tParams.bRet)
		print("setBounceEnabled run success")
	end
end

return tMEPageView
