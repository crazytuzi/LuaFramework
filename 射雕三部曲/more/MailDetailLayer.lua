--[[
    文件名：MailDetailLayer.lua
    描述：邮件详情界面
    创建人：suntao
    创建时间：2016.5.19
    修改人：wukun
    修改时间：2016.9.12
-- ]]

local MailDetailLayer = class("MailDetailLayer")

-- 构造函数
--[[
-- 参数
	params: {
		moduleId 邮件类型的模块ID
		type 子类型
		content 邮件内容
		sendPlayerId 发送人ID
		srcModuleId 发送源的模块ID
	}
--]]

function MailDetailLayer:ctor(params)
	local title = TR("邮件详情")
	local buttonInfo = nil
    local isShengyuanId = params.srcModuleId == ModuleSub.eShengyuanWars
    local moduleText = ModuleSubModel.items[params.srcModuleId].name
	if params.moduleId ~= ModuleSub.eEmailFriend then
		if params.type == 1 then
			buttonInfo = {
				text = TR("确定"),
				clickAction = function()
		            LayerManager.removeLayer(self.mLayer)
		            self.mLayer = nil
		        end
			}
		else
			buttonInfo = {
				text = isShengyuanId and moduleText or TR("去%s", moduleText),
				clickAction = function()
					LayerManager.showSubModule(params.srcModuleId)
		        end
			}
		end
	else
		buttonInfo = {
			text = TR("回复"),
			clickAction = function()
	            self.mLayer = nil
	            require("more.MailAnswerLayer").new(params.sendPlayerId)
	        end
		}
	end
	local contentList = string.split(params.content, "\n")
	local function DIYNormalFunction(layer, layerBgSprite, layerSize)
        -- 滑动控件背景的大小
        local bgSize = cc.size(layerSize.width * 0.90, layerSize.height - 165)
        -- 滑动控件的背景图片
        local tempSprite = ui.newScale9Sprite("c_17.png", bgSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 75)
        layerBgSprite:addChild(tempSprite)

        -- 滑动控件
        local listSize = cc.size(bgSize.width - 20, bgSize.height - 20)
        local listView = ccui.ListView:create()
        listView:setContentSize(listSize)
        listView:setItemsMargin(5)
        listView:setDirection(ccui.ListViewDirection.vertical)
        listView:setBounceEnabled(true)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(cc.p(bgSize.width / 2, 10))
        listView:setBounceEnabled(false)
        listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
        tempSprite:addChild(listView)
        -- Todo
        for index, item in ipairs(contentList or {}) do
            local lvItem = ccui.Layout:create()
            local tempLabel = ui.newLabel({
                text = item == "" and " " or item,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(listSize.width, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            local cellSize = tempLabel:getContentSize()
            tempLabel:setPosition(0, cellSize.height / 2)
            lvItem:addChild(tempLabel)

            lvItem:setContentSize(cellSize)
            listView:pushBackCustomItem(lvItem)
        end
    end
    -- 复制兑换码按钮
    local exchangeCode = self.parseExchangeCode(params.content)
    local copyBtnInfo = nil
    if exchangeCode and exchangeCode ~= "" then
        copyBtnInfo = {
            text = TR("复制兑换"),
            clickAction = function()
                IPlatform:getInstance():copyWords(exchangeCode)
                ui.showFlashView(TR("复制成功"))
                LayerManager.removeLayer(self.mLayer)
                self.mLayer = nil
            end
        }
    end

    self.mLayer = MsgBoxLayer.addDIYLayer({
        msgText = "",
        title = title,
        btnInfos = copyBtnInfo and {copyBtnInfo, buttonInfo} or {buttonInfo},
        DIYUiCallback = DIYNormalFunction,
        closeBtnInfo = {},
        notNeedBlack = true
    })
end

function MailDetailLayer.parseExchangeCode(str)
    local code = string.match(str, TR("兑换码：(%w+)；"))
    return code
end

--- ==================== ”静态“函数 =======================
-- 新建邮件内容显示层
function MailDetailLayer.newLayer(moduleId, data)
	MailDetailLayer.new({
		moduleId = moduleId, 
        type = data.Type, 
        content = data.Content,
        sendPlayerId = data.SendPlayerId,
        srcModuleId = data.SubModuleId,
	})
end

return MailDetailLayer

