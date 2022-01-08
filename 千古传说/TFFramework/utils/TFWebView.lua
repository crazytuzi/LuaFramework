local TFWebView = {}
TFWebView.isShow = false
--显示 webview
function TFWebView.showWebView(url, x, y, width, height)
	local designsize = me.EGLView:getDesignResolutionSize()
    local framesize = me.EGLView:getFrameSize();
    local sx = me.EGLView:getScaleX();
    local sy = me.EGLView:getScaleY();
    local designframe = CCSize(framesize.width / sx, framesize.height / sy);

    -- 这里可能需要根据ResolutionPolicy进行修改。
    -- Modify this ratio equation depend on your ResolutionPolicy.
    -- local ratio = designsize.height / framesize.height;
    local ratio = designsize.width / framesize.width;
    
    
    local orig = CCPoint((designframe.width - designsize.width) / 2, (designframe.height - designsize.height) / 2);
    
    x = x / ratio + orig.x / ratio;
    y = y / ratio + orig.y / ratio;
    width = width/ratio;
    height = height/ratio;
    
    TFWebView._privateShowWebView( x, y, width, height);
    TFWebView.updateURL(url);
    TFWebView.isShow = true
end


function TFWebView._privateShowWebView( x, y, width, height)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        print("showWebView :" , { x = x, y = y, width = width, height = height})
        TFLuaOcJava.callStaticMethod("TFWebView", "showWebView", { x = x, y = y, width = width, height = height})--, "(IIII)V")
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/TFWebView","displayWebView",{ x, y, width, height},"(IIII)V")
    end
end


function TFWebView.updateURL( url)
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("TFWebView", "updateURL", {url = url})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/TFWebView","updateURL",{url})
    end
end


function TFWebView.close()
	if TFWebView.isShow == false then
		return false
	else
		TFWebView.removeWebView()
		return true
	end
end

function TFWebView.removeWebView()
	TFWebView.isShow = false
	if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("TFWebView","removeWebView",nil,"()V")
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/TFWebView","removeWebView",nil,"()V")
    end
end

function TFWebView.display(bShow)
    
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        TFLuaOcJava.callStaticMethod("TFWebView","display",bShow)
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        TFLuaOcJava.callStaticMethod("org/cocos2dx/HeroesLegends/TFWebView", "display", {bShow})
    end
end

return TFWebView