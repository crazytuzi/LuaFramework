require"Lang"
UITips = { }


function UITips.init()
    UITips.Widget:runAction(cc.Sequence:create( cc.DelayTime:create(5) , cc.CallFunc:create(function ()

        if dp.RELEASE then
            UIManager.showScreen("ui_login")
        else
            UIManager.showScreen("test_login")
        end
        cc.JNIUtils:showGameNotice(dp.NOTICE_URL)
end)))
end


function UITips.setup()

end

function UITips.free()

end
