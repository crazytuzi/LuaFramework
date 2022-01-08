--[[--
	Loading 小菊花:

	--By: yun.bo
	--2013/12/16
]]
TFLoading = {}

function TFLoading:lazyInit(szBgImgPath, szChrysanthemumImgPath)
	if not self.bIsInit then
		local panel = TFPanel:create()
		panel:setTouchEnabled(true)
		panel:setSize(VisibleRect:getVisibleRect().size)

		local img = TFImage:create()
		img:setPositionType(TF_POSITION_PERCENT)
		img:setPositionPercent(ccp(0.5, 0.5))
		self.loadingImg = img
		img:addMEListener(TFWIDGET_ENTERFRAME,function()
			img:setRotation(img:getRotation() + 4)
		end)

		panel:addChild(img)
		panel:retain()
		self.objLoadingPanel = panel
		self.bIsInit = true
	end

	if szBgImgPath then
		self.objLoadingPanel:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
		self.objLoadingPanel:setBackGroundImage(szBgImgPath)
	else
		self.objLoadingPanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
		self.objLoadingPanel:setBackGroundColor(ccc3(0, 0, 0))
		self.objLoadingPanel:setBackGroundColorOpacity(188)
	end

	if szChrysanthemumImgPath then
		self.loadingImg:setTexture(szChrysanthemumImgPath)
	else
		self.loadingImg:setTexture("meloading.png")
	end
end

function TFLoading:show(layer, szBgImgPath, szChrysanthemumImgPath, tTween)
	self:lazyInit(szBgImgPath, szChrysanthemumImgPath)

	self.objLoadingPanel:removeFromParent(false)
	if not layer then
		local scene = TFDirector:currentScene()
		layer = scene
	end
	if layer then
		layer:addChild(self.objLoadingPanel, 100001)

		TFDirector:killTween(self.tCurTween)
		self.tCurTween = tTween
		if tTween then
			tTween.target = self.objLoadingPanel
			TFDirector:toTween(tTween)
		end
	end

end

function TFLoading:hide(tTween)
	self.onLoadingImgRotateFunc = nil
	self.objLoadingPanel:removeFromParent(false)

	TFDirector:killTween(self.tCurTween)
	self.tCurTween = tTween
	if tTween then
		tTween.target = self.objLoadingPanel
		TFDirector:toTween(tTween)
	end
end

return TFLoading