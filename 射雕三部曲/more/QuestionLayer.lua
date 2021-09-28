--[[
	文件名：QuestionLayer.lua
	描述：更多－－联系客服
	创建人：yanxingrui
	创建时间： 2016.5.30
    修改人：yanghongsheng
    修改时间： 2017.3.6
--]]

local QuestionLayer = class("QuestionLayer", function(params)
	return display.newLayer()
end)

-- 三个标签页的定义
local pageType = {
	eSendQuestion = 1,     --输入问题
	eHistoryQuestion = 2,  --查看问题
	eContact = 3,          --联系客服
}


function QuestionLayer:ctor()
	-- 初始化页面
	self:initUI()
end

-- 初始化页面
function QuestionLayer:initUI()
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("问题反馈"),
        bgSize = cc.size(600, 480),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 中间3个分页页面的父节点
    self.mSubLayer = cc.Layer:create()
    self.mSubLayer:setContentSize(self.mBgSize)
    self.mBgSprite:addChild(self.mSubLayer)
    self.mSubLayer:setPosition(cc.p(5,0));

    -- 创建分页
    self:showTabLayer()
end

-- 创建分页
function QuestionLayer:showTabLayer()
	local btnInfos = {
        {
            text = TR("输入问题"),
            fontSize = 22,
            -- outlineColor = Enums.Color.eOutlineColor,
        },
        {
            text = TR("查看问题"),
            fontSize = 22,
            -- outlineColor = Enums.Color.eOutlineColor,
        },
        {
            text = TR("联系客服"),
            fontSize = 22,
            -- outlineColor = Enums.Color.eOutlineColor,
        }
    }

    --创建tablayer
    self.mTableLayer = ui.newTabLayer({
    	viewSize = cc.size(600, 80),
        btnSize = cc.size(120, 55),
        btnInfos = btnInfos,
        needLine = false,
        space = 5,
        onSelectChange = function(selectBtnTag)
            self:addElements(selectBtnTag)
        end,
    })
    self.mTableLayer:setPosition(self.mBgSize.width * 0.55, self.mBgSize.height * 0.74+30)
    self.mBgSprite:addChild(self.mTableLayer)
end

-- 添加分页元素
function QuestionLayer:addElements(selectBtnTag)
	self.mSubLayer:removeAllChildren()

	if selectBtnTag == pageType.eSendQuestion then
		self:sendQuestionLayer()
	elseif selectBtnTag == pageType.eHistoryQuestion then
		self:historyQuestionLayer()
	elseif selectBtnTag == pageType.eContact then
		self:contactLayer()
	end
end

-- 输入问题页面
function QuestionLayer:sendQuestionLayer()
	self.editBox = ui.newEditBox({
		image = "c_17.png",
		size = cc.size(526, 246),
		fontSize = 24 * Adapter.MinScale,
        fontColor = cc.c3b(0x59, 0x28, 0x17),
		multiLines = false,
		placeHolder = TR("请在这里输入内容......"),
        --placeColor = cc.c4b(0x76, 0x76, 0x76, 150),
	})
	self.editBox:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.483)
	self.editBox:setPlaceholderFontSize(30)
	self.mSubLayer:addChild(self.editBox)

	local sendBtn = ui.newButton({
		normalImage = "c_28.png",
		position = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.14),
		text = TR("提交"),
		clickAction = function (pSender)
            self:requestSend()
        end
	})
	self.mSubLayer:addChild(sendBtn)
end

-- 查看问题页面
function QuestionLayer:historyQuestionLayer()
    -- 给mSubLayer添加背景图
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(526, 246))
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.483)
    self.mSubLayer:addChild(bgSprite)

	-- 用于存放历史问题记录
	self.scrollView = ccui.ScrollView:create()
    self.scrollView:setDirection(ccui.ScrollViewDir.vertical)
	self.scrollView:setContentSize(cc.size(546, 216))
    self.scrollView:setAnchorPoint(cc.p(0.5, 0.5))
	self.scrollView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.45)
	self.mSubLayer:addChild(self.scrollView)

	self:requestHistoryInfo()

    -- 添加确认按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.14),
        text = TR("确认"),
        -- size = 30,
        -- color = cc.c3b(0x8e, 0x4f, 0x09),
        clickAction = function (pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mSubLayer:addChild(confirmBtn)

end

-- 联系客服页面
function QuestionLayer:contactLayer()
    -- 给mSubLayer添加背景图
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(526, 246))
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.483)
    self.mSubLayer:addChild(bgSprite)

	-- 客服电话
	local qqLabel = ui.newLabel({
        text = TR("客服电话： 4009909708"),
        size = 24,
        color = cc.c3b(0x59, 0x28, 0x17),
        --outlineColor = Enums.Color.eBlack,
    })
    qqLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.53)
    self.mSubLayer:addChild(qqLabel)

    -- 客服QQ群
    local qqFamLabel = ui.newLabel({
        text = TR("客服QQ： 2962377683"),
        size = 24,
        color = cc.c3b(0x59, 0x28, 0x17),
        --outlineColor = Enums.Color.eBlack,
    })
    qqFamLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.4)
    self.mSubLayer:addChild(qqFamLabel)

    -- 添加确认按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.14),
        text = TR("确认"),
        -- size = 30,
        -- color = cc.c3b(0x8e, 0x4f, 0x09),
        clickAction = function (pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mSubLayer:addChild(confirmBtn)
end


--------------------------网络请求------------
-- 向服务器发送问题
function QuestionLayer:requestSend()
	local message = self.editBox:getText()
	if message ~= "" then
		HttpClient:request({
            moduleName = "GlobalFeedback",
            methodName = "Send",
            svrMethodData = {message},
            callback = function(data)
				if not data or data.Status ~= 0 then
					return
				end
                ui.showFlashView(TR("提交成功"))
                self.editBox:setText("")
            end,
        })
	else
		ui.showFlashView(TR("输入内容为空"))
	end
end

-- 得到历史问题
function QuestionLayer:requestHistoryInfo()
	HttpClient:request({
        moduleName = "GlobalFeedback",
        methodName = "GetHistoryInfo",
        svrMethodData = {},
        callback = function(data)
            local totalHeight = 0
            local partList = {}
            for index, value in ipairs(data.Value) do
            	partList[index] = {}
            	partList[index].node = cc.Node:create()
            	partList[index].position = 60 + (-1 * totalHeight)
            	local height = 0

            	-- 提问
            	local askLabel = ui.newLabel({
            		text = TR("%s提问:",value.PlayerName),
            		size = 24,
                    color = cc.c3b(0x59, 0x28, 0x17),
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,       -- 垂直对齐方式，默认为 cc.VERTICAL_TEXT_ALIGNMENT_CENTER
                	dimensions = cc.size(510, 0),
            	})
            	askLabel:setAnchorPoint(cc.p(0, 1))
            	askLabel:setPosition(0, -80)
            	partList[index].node:addChild(askLabel)
            	height = height + askLabel:getContentSize().height

                local quesLabel = ui.newLabel({
                    text = value.Question,
                    size = 24,
                    color = cc.c3b(0x59, 0x28, 0x17),
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,       -- 垂直对齐方式，默认为 cc.VERTICAL_TEXT_ALIGNMENT_CENTER
                    dimensions = cc.size(510, 0),
                })
                quesLabel:setAnchorPoint(cc.p(0, 1))
                quesLabel:setPosition(16, -116)
                partList[index].node:addChild(quesLabel)
                height = height + quesLabel:getContentSize().height

            	-- 回答
            	local answerLabel = ui.newLabel({
            		text = TR("%s回复:", value.HandlerName),
            		size = 24,
                    color = cc.c3b(0x59, 0x28, 0x17),
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                	dimensions = cc.size(510, 0),
            	})
            	answerLabel:setAnchorPoint(cc.p(0, 1))
            	answerLabel:setPosition(0, -1 * height - 80)
            	partList[index].node:addChild(answerLabel)
            	height = height + answerLabel:getContentSize().height

                local answerLabel2 = ui.newLabel({
                    text = value.Answer,
                    size = 24,
                    color = cc.c3b(0x59, 0x28, 0x17),
                    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    dimensions = cc.size(500, 0),
                })
                answerLabel2:setAnchorPoint(cc.p(0, 1))
                answerLabel2:setPosition(12, -1 * height - 100)
                partList[index].node:addChild(answerLabel2)
                height = height + answerLabel2:getContentSize().height

            	self.scrollView:addChild(partList[index].node)
            	totalHeight = totalHeight + height + 50--50
            end
        	if totalHeight < 328 then
        		for index, value in ipairs(partList) do
        			value.node:setPosition(0, 328 + value.position)
        		end
        	else
        		self.scrollView:setInnerContainerSize(cc.size(520, totalHeight))
        		for index, value in ipairs(partList) do
        			value.node:setPosition(0, totalHeight + value.position)
        		end
        	end
        end,
    })
end

return QuestionLayer
