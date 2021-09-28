--[[
    文件名: TestLoginLayer.lua
	描述: 试登录页面
	创建人：liaoyuangang
	创建时间：2016.09.24
-- ]]

local TestLoginLayer = class("TestLoginLayer", function()
    return display.newLayer()
end)

function TestLoginLayer:ctor()
    -- 创建背景layer
    local tempLayer = require("login.LoginBgLayer"):create()
    self:addChild(tempLayer)

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    self.editControlTable = {}

    Player:cleanCache()  -- 这样做的目的是考虑重新登录的情况

    -- 创建页面控件
    self:initUI()
end

-- 创建页面控件
function TestLoginLayer:initUI()
    local editInfoList = {
        partnerId = { -- 渠道Id
            index = 1,
            hintStr = TR("渠道Id(如:6006)"), 
            editBoxObj = nil, 
            checkText = function(text)
                local tempId = tonumber(text or "")
                if not tempId or tempId == 0 then
                    ui.showFlashView(TR("渠道Id不合法"))
                    return false
                end
                return true
            end,
        },  
        versionId = { -- 通信版本号
            index = 2,
            hintStr = TR("通信版本号(如:100)"), 
            editBoxObj = nil, 
            checkText = function(text)
                return true
            end,
        },
        userId = { -- 玩家账户登录后的Id
            index = 3,
            hintStr = TR("UserId(如:5A0580266D)"), 
            editBoxObj = nil, 
            checkText = function(text)
                return true
            end,
        },
        playerName = { -- 玩家名称
            index = 4,
            hintStr = TR("玩家名(如:黄四郎)"), 
            editBoxObj = nil, 
            checkText = function(text)
                return true
            end,
        }
    }
    local keyList = table.keys(editInfoList)
    table.sort(keyList, function(key1, key2)
        local index1 = editInfoList[key1].index
        local index2 = editInfoList[key2].index
        return index1 < index2
    end)

    local tempAccout = LocalData:getGameDataValue("TestLoginAccout")
    self.keyEditTable = {"PartnerId", "VersionId", "userId", "name"}
    -- 创建输入框
    local startPosY = 700
    for index, value in ipairs(keyList) do
        local tempItem = editInfoList[value]

        local tempEditBox = ui.newEditBox({
            image = "dl_02.png",
            size = cc.size(600, 60),
        })
        tempEditBox:setPosition(cc.p(320, startPosY - (index - 1) * 110))
        tempEditBox:setPlaceHolder(tempItem.hintStr)
        self.mParentLayer:addChild(tempEditBox)

        local tempText = tempAccout and tempAccout[self.keyEditTable[index]]
        if tempText then
            tempEditBox:setText(tempText)
        end

        tempItem.editBoxObj = tempEditBox
        table.insert(self.editControlTable, tempEditBox)
    end

    -- 是否测试地址登录选择
    local channel = IPlatform:getInstance():getConfigItem("Channel")
    local isMqkk = (not channel or channel == "" or string.lower(channel) == "mqkk")
    local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        isRevert = false, -- 是否把文字放到复选框前面，默认false
        text = TR("测试地址"),
        textColor = Enums.Color.eDarkGreen,
        callback = function(isSelected)
            -- todo
        end
    })
    checkBox:setCheckState(isMqkk)
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(cc.p(25, 280))
    self.mParentLayer:addChild(checkBox)

    -- 登 录
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("登录"),
        position = cc.p(430, 200),
        clickAction = function()
            local tempData = {}
            -- 检查输入内容是否合法
            for key, item in pairs(editInfoList) do
                local tempStr = item.editBoxObj:getText()
                if not item.checkText(tempStr) then
                    return 
                end
                tempData[key] = tempStr
            end

            -- 如果 userId 和 玩家名都为空，则提示
            if (not tempData.userId or tempData.userId == "") and 
                (not tempData.playerName or tempData.playerName == "") then
                ui.showFlashView(TR("请输入 userId 或者 玩家名"))
                return
            end

            -- 
            local platform = IPlatform:getInstance()
            tempData.versionId = tempData.versionId ~= "" and tempData.versionId or platform:getConfigItem("Version")
            tempData.userId = tempData.userId ~= "" and tempData.userId or "1"
            tempData.playerName = tempData.playerName ~= "" and tempData.playerName or "1"
            tempData.loginKey = "1d7f0abf-7822-4c68-a18a-48522680cfdf"

            platform:setConfigItems("LoginKey=" .. tempData.loginKey)
            platform:setConfigItems("PartnerID=" .. tempData.partnerId)
            platform:setConfigItems("Version=" .. tempData.versionId)
            if checkBox.getCheckState() then
                platform:setConfigItems("ManageCenter=https://loginsvrtest-sdgat.moqikaka.com/API/ServerList_Client.ashx")
                platform:setConfigItems("DebugDomain=http://loginsvrtest-sdgat.moqikaka.com/")
            else
                platform:setConfigItems("ManageCenter=https://loginsvr-sdgat.moqikaka.com/API/ServerList_Client.ashx")
                platform:setConfigItems("DebugDomain=https://loginsvr-sdgat.moqikaka.com/")
            end

            --dump(tempData, "testLoginData:")
            -- 
            self:loginForTest() -- 保存试登录信息

            LayerManager.addLayer({
                name="login.StartGameLayer", 
                data = {
                    testLoginData = tempData
                }
            })
        end,
    })
    self.mParentLayer:addChild(tempBtn)

    -- 返回
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("返回"),
        position = cc.p(210, 200),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(tempBtn)
end

function TestLoginLayer:loginForTest()
    -- 以下参数需要手动设置
    local inputTextTable = {}
    for _,item in ipairs(self.editControlTable) do
        local inputText = item:getText()
        table.insert(inputTextTable, inputText)
    end
    local testTable = {PartnerId=tonumber(inputTextTable[1]), VersionId=tonumber(inputTextTable[2]), testCenter=false,
        LoginKey="7D90C8C95C4379CFF13D02B6FC034260", UserId=inputTextTable[3], name=inputTextTable[4]}
    -- 保存输入的内容
    local inputTeampAccout = {PartnerId=testTable.PartnerId, VersionId=testTable.VersionId, userId=testTable.UserId, name=testTable.name}
    LocalData:saveGameDataValue("TestLoginAccout", inputTeampAccout)
end

return TestLoginLayer
