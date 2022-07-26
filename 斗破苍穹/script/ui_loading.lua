UILoading = class("UILoading")

function UILoading.init()
    UILoading.Widget:setBackGroundColorOpacity(0)
end

function UILoading.setup()
	local loadingImg = ccui.Helper:seekNodeByName(UILoading.Widget, "loading")
	loadingImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.15, 30)))
end