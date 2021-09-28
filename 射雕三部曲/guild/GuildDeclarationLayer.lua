--[[
    文件名：GuildDeclarationLayer
    描述： 修改帮派宣言页面
    创建人：chenzhong
    创建时间：2017.3.13
-- ]]

local GuildDeclarationLayer = class("GuildDeclarationLayer",function()
	return display.newLayer()
end)

--[[
    params:
    isModify  是否是修改宣言
]]
function GuildDeclarationLayer:ctor(parmas)
    --未修改之前的帮派宣言
    self.initDeclaration = GuildObj:getGuildInfo().Declaration

    --初始化页面控件
    self:initUI()
end


function GuildDeclarationLayer:initUI()
    local popBgLayer = require("commonLayer.PopBgLayer"):create({
        title = TR("帮派宣言"),
        bgSize = cc.size(530, 380),
        closeAction = function (  )
            LayerManager.removeLayer(self)
        end
        })
    self:addChild(popBgLayer)

    --背景
    local backImageSprite = popBgLayer.mBgSprite
    local backSize = popBgLayer.mBgSize
    
    --宣言输入框
    self.decEditBox = ui.newEditBox({
        image = "c_17.png",
        size = cc.size(backSize.width*0.9, backSize.height-153),
        fontSize = 22,
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
        maxLength = 20,
        multiLines = true,
    })
    self.decEditBox:setAnchorPoint(0.5, 0)
    self.decEditBox:setPosition(cc.p(backSize.width/2, 85))
    self.decEditBox:setText(self.initDeclaration)
    backImageSprite:addChild(self.decEditBox)

    --确定按钮
    local ensureBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(backSize.width * 0.5, 50),
        clickAction = function (sender)
            local text = string.trim(self.decEditBox:getText())

            if text == "" then
                ui.showFlashView({text = TR("帮派宣言不能为空")})
                return
            end
            if string.len(text) > 60 then
                ui.showFlashView({text = TR("帮派宣言最多60个字符,中文占3个,英文占1个")})
                --label:setColor(Enums.Color.eNormalYellow)
                return 
            end

            if text == self.initDeclaration then
                LayerManager.removeLayer(self)
                return
            end

            --提交更改宣言
            self:requestUpdateDeclaration(text)
        end
    })
    backImageSprite:addChild(ensureBtn)
end

-- =================== 请求服务器数据相关函数 =====================]]==
--更改帮派宣言
function GuildDeclarationLayer:requestUpdateDeclaration(text)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "UpdateDeclaration",
        svrMethodData = {text},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            LayerManager.removeLayer(self)
            ui.showFlashView({text = TR("帮派宣言修改成功")})
        end,
    })
end

return GuildDeclarationLayer