--[[
    文件名：ModifyNameLayer.lua
    描述：  更改昵称
    创建人： wusonglin
    创建时间：2016.7.4
-- ]]

local ModifyNameLayer = class("ModifyNameLayer", function(params)
    return cc.LayerColor:create()
end)

-- 初始化
function ModifyNameLayer:ctor(params)
    -- 设置ui
    self:setUI()
end

function ModifyNameLayer:setUI()
	-- 设置背景大小
    local bgWidth = 515
    local bgHeight = 405

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("修改昵称"),
        bgSize = cc.size(bgWidth, bgHeight),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    -- 文字描述
    local textSrc = ui.newLabel({
        text = TR("随机一个昵称或者输入新昵称"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    textSrc:setAnchorPoint(cc.p(0.5, 1.0))
    textSrc:setPosition(cc.p(bgWidth / 2, bgHeight - 75))
    self.mBgSprite:addChild(textSrc)

    -- 内容
    self:createContentBg()

     --不同编码下获取字符串长度
    local function asciilen(str)
        local barrier  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
        local size = #barrier
        local count, delta = 0, 0
        local c, i, j = 0, #str, 0

        while i > 0 do
            delta, j, c = 1, size, string.byte(str, -i)
            while barrier[j] do
                if c >= barrier[j] then i = i - j; break end
                j = j - 1
            end
            delta = j == 1 and 1 or 2
            count = count + delta
        end
        return count
    end

    -- 确认按钮
    local btnOk = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        color = cc.c3b(0xff, 0xff, 0xff),
        size = 22,
        position = cc.p(bgWidth /2 , bgHeight * 0.12),
        clickAction = function()
            if self.mNameEditBox:getText() ~= "" then
                if asciilen(self.mNameEditBox:getText()) <= 12 then
                    -- 使用更名卡
                    local goodsNum = GoodsObj:getCountByModelId(16050002) or 0
                    if goodsNum < 1 then
                        local resumeCount = PlayerConfig.items[1].alterNameSpendDiamond
                        if Utility.isResourceEnough(ResourcetypeSub.eDiamond, resumeCount) then
                            -- 显示提示框
                            local tempData = {
                                title = TR("提示"),
                                msgText = TR("确定要使用%d元宝进行更名么！", resumeCount),
                                btnInfos = {
                                    {
                                    text = TR("确定"),
                                    clickAction = function ()
                                        self:requestAlterPlayerName(self.mNameEditBox:getText(), 3)
                                        LayerManager.removeLayer(self.mMsgLayer)
                                    end},
                                    {text = TR("取消"),}

                                },
                                closeBtnInfo = false
                                }
                            -- 弹出提示框
                            self.mMsgLayer = LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})
                        end
                    else
                        self:requestAlterPlayerName(self.mNameEditBox:getText(), 2)
                    end
                else
                    MsgBoxLayer.addOKLayer(TR("输入长度不得超过6个汉字或12个字符"),TR("提示"))
                end
            else
                ui.showFlashView({text = TR("请输入昵称"),})
            end
        end,
    })
    self.mBgSprite:addChild(btnOk)
end
-- 设置内容展示
function ModifyNameLayer:createContentBg()
	self.mContentBg = ui.newScale9Sprite("c_17.png", cc.size(466, 197))
    self.mContentBg:setPosition(cc.p(515 / 2, 190))
    self.mBgSprite:addChild(self.mContentBg)

    self.mNameEditBox = ui.newEditBox({
    	  image = "c_38.png",
  		  size  = cc.size(270, 40),
  		  fontColor = Enums.Color.eNormalGreen,
  		  placeHolder = TR("请输入新的昵称"),
  		  placeColor = Enums.Color.eNormalGreen,
    	})
    self.mNameEditBox:setAnchorPoint(cc.p(0, 0.5))
    self.mNameEditBox:setPosition(cc.p(35, 157))
    self.mContentBg:addChild(self.mNameEditBox)

    -- 随机名字
    local randBtn = ui.newButton({
        normalImage = "jsxz_06.png",
        position = cc.p(380 , 157),
        clickAction = function()
            print("newName")
            local newName = self:getRandomName()
            print(newName)
            self.mNameEditBox:setText(newName or "")
        end,
    })
    self.mContentBg:addChild(randBtn)

    -- 设置中部label
    self:setCenterLabel()
end

-- 设置中部label
function ModifyNameLayer:setCenterLabel()

	-- 消耗
	local castLabel1 = ui.newLabel({
        text  = TR("消耗:"),
        color = Enums.Color.eLightYellow,
    })
    castLabel1:setAnchorPoint(cc.p(0, 1))
    castLabel1:setPosition(50, 110)
    self.mContentBg:addChild(castLabel1)
    -- 图标
    local nameImage = GoodsModel.items[16050002].pic .. ".png"
	local modifySprite1 = ui.newSprite(nameImage)
    modifySprite1:setScale(0.6)
	modifySprite1:setAnchorPoint(cc.p(0, 1))
    modifySprite1:setPosition(120, 122)
    self.mContentBg:addChild(modifySprite1)
    -- 消耗
    local castNum1 = ui.newLabel({
        text = TR("X1"),
        color = Enums.Color.eNormalGreen,
    })
    castNum1:setAnchorPoint(cc.p(0, 1))
    castNum1:setPosition(175, 110)
    self.mContentBg:addChild(castNum1)

    -- 显示元宝消耗
    local orLabel = ui.newLabel({
        text = TR("或"),
        color = Enums.Color.eLightYellow,
    })
    orLabel:setAnchorPoint(cc.p(0, 1))
    orLabel:setPosition(210, 110)
    self.mContentBg:addChild(orLabel)
    -- 图标
    local diamondLabel = ui.newSprite(Utility.getResTypeSubImage(ResourcetypeSub.eDiamond))
    diamondLabel:setAnchorPoint(cc.p(0, 1))
    diamondLabel:setPosition(250, 120)
    self.mContentBg:addChild(diamondLabel)
    -- 消耗
    local diamondLabel1 = ui.newLabel({
        text = string.format("X%d", PlayerConfig.items[1].alterNameSpendDiamond),
        color = Enums.Color.eNormalGreen,
    })
    diamondLabel1:setAnchorPoint(cc.p(0, 1))
    diamondLabel1:setPosition(300, 110)
    self.mContentBg:addChild(diamondLabel1)

    local castLabel2 = ui.newLabel({
        text = TR("拥有:"),
        color = Enums.Color.eLightYellow,
    })
    castLabel2:setAnchorPoint(cc.p(0, 1))
    castLabel2:setPosition(50, 50)
    self.mContentBg:addChild(castLabel2)

    local modifySprite3 = ui.newSprite(nameImage)
    modifySprite3:setScale(0.6)
	modifySprite3:setAnchorPoint(cc.p(0, 1))
    modifySprite3:setPosition(120, 60)
    self.mContentBg:addChild(modifySprite3)
    -- 消耗 PlayerAttrObj:getPlayerInfo().Merit
    local curGoodsCount = GoodsObj:getCountByModelId(16050002)
    local castNum2 = ui.newLabel({
        text = TR("X%s", curGoodsCount),
        color = (curGoodsCount > 0) and Enums.Color.eNormalGreen or Enums.Color.eRed,
    })
    castNum2:setAnchorPoint(cc.p(0, 1))
    castNum2:setPosition(175, 50)
    self.mContentBg:addChild(castNum2)
end

-- 获取随机名字
function ModifyNameLayer:getRandomName()
    local firstname, lastname = _firstname, _lastname
    if not firstname then
        local fullpath1 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name1)
        local fullpath2 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name2)

        print(fullpath1)

        local randomString1 = cc.FileUtils:getInstance():getStringFromFile(fullpath1)
        local randomString2 = cc.FileUtils:getInstance():getStringFromFile(fullpath2)



        if #randomString1==0 or #randomString2==0 then
            return nil
        end

        firstname, lastname = {}, {}
        for i in randomString1:gmatch "%S+" do
            table.insert(firstname, i)
            -- table.insert(lastname, i)
        end

        for i in randomString2:gmatch "%S+" do
            table.insert(lastname, i)
        end

        _firstname, _lastname = firstname, lastname
    end

    local x, y = math.random(1, #firstname), math.random(1, #lastname)
    return firstname[x]..lastname[y]
end

------[[------网络相关------]]-------
function ModifyNameLayer:requestAlterPlayerName(name, buyId)
    HttpClient:request({
        moduleName = "Player",
        methodName = "AlterPlayerName",
        svrMethodData = {name, buyId},
        callback = function(data)
            --dump(data)
            if data.Status == 0 then
                 -- 通知SDK，游戏名
                local enterTable = {Type = "UserNameChanged", IsCreate="0", Name=name}
                Utility.cpInvoke("UserNameChanged")

                ui.showFlashView({text = TR("更名成功"),})
                LayerManager.removeLayer(self)
            end
        end,
    })
end

return ModifyNameLayer
