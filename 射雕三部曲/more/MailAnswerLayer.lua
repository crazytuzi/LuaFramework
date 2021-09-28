--[[
    文件名：MailAnswerLayer.lua
    描述：邮件回复界面
    创建人：suntao
    创建时间：2016.5.19
    修改人：wukun
    修改时间：2016.9.12
-- ]]


local MailAnswerLayer = class("MailAnswerLayer")

MailAnswerLayer.buttonsInfo = {}

-- 构造函数
--[[
-- 参数
	playerId 好友ID
--]]
function MailAnswerLayer:ctor(playerId)
	local okBtnInfo = {
		text = TR("确认发送"),
		clickAction = function()
			local text = self.mEditBox:getText()
			local lengeh = string.utf8len(text)
			if lengeh == 0 then
				ui.showFlashView(TR("内容不能为空"))
				return
			elseif lengeh > 20 then
				ui.showFlashView(TR("超过20字"))
				return
			end
			MailAnswerLayer.requestSendFriendMessage(playerId, text)
	        LayerManager.removeLayer(self.mLayer)
	        self.mLayer = nil
	    end
    }

    local diy = function (layer, bgSprite, bgSize)
    	-- 输入框
	    local editBox = ui.newEditBox({
	        image = "c_17.png",
	        size = cc.size(510, 180),
	        fontSize = 26 * Adapter.MinScale,
	        fontColor = Enums.Color.eNormalWhite,
	        --maxLength = 530,
	        multiLines = true,
	        placeHolder = TR("请在这里输入内容"),
	    })
	    editBox:setPlaceholderFontSize(26 * Adapter.MinScale) --设置提示文字大小
	    editBox:setAnchorPoint(cc.p(0.5, 0))
	    editBox:setPosition(cc.p(bgSize.width/2, 90))
	    bgSprite:addChild(editBox)

	    self.mEditBox = editBox
	end

	self.mLayer = MsgBoxLayer.addDIYLayer({
		title = TR("回复好友"), 
		msgText = "", 
		DIYUiCallback = diy, 
		btnInfos = {okBtnInfo},
		closeBtnInfo = {},
		notNeedBlack = true,
	})
end

--- ==================== 服务器数据请求相关 =======================
-- 发送留言给好友
function MailAnswerLayer.requestSendFriendMessage(playerId, message)
    HttpClient:request({
        moduleName = "FriendMessage", 
        methodName = "SendFriendMessage", 
        svrMethodData = {playerId, message}, 
        callback = function(response)
            if response.Status == 0 then
            	ui.showFlashView(TR("发送留言成功"))
        	end
        end
    })
end


return MailAnswerLayer
