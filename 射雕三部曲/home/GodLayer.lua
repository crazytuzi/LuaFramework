--[[
    文件名：GodLayer
	描述：获取测试用物品
	创建人：帅希涛
	创建时间：2014.04.28
-- ]]

local GodLayer = class("GodLayer", function()
    return display.newLayer()
end)

function GodLayer:ctor()
    -- 页面控件的Parent
    self.mParentNode = ui.newStdLayer()
    self:addChild(self.mParentNode)

    --背景图
    self.mBgSprite = ui.newSprite("c_34.jpg")
    self.mBgSprite:setPosition(320, 568)
    self.mParentNode:addChild(self.mBgSprite)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(580, 1050)
    self.mParentNode:addChild(self.mCloseBtn)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function GodLayer:initUI()
    self.mGetGoodsInfo = {
       -- 获取人物
        {
            editHint = "人物模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Hero", 
                        methodName = "TestFor_CreateHero",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 获取幻化人物
        {
            editHint = "幻化模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Illusion", 
                        methodName = "TestAdd",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 获取装备
        {
            editHint = "装备模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Equip", 
                        methodName = "GiveEquip",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 获取宝石
        {
            editHint = "宝石模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Imprint", 
                        methodName = "TestForImprint",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 获取称号头像匡
        {
            editHint = "称号头像框Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Designation", 
                        methodName = "Give",
                        svrMethodData = {tonumber(tempStr)},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 获取神兵
        {
            editHint = "神兵模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Treasure", 
                        methodName = "GiveTreasure",
                        svrMethodData = {tonumber(tempStr),1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 真元
        {
            editHint = "真元模型ID",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Zhenyuan", 
                        methodName = "GiveZhenyuan",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 内功心法
        {
            editHint = "内功心法模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Zhenjue", 
                        methodName = "TestAdd",
                        svrMethodData = {tonumber(tempStr),1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 外功秘籍
        {
            editHint = "外功秘籍模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Pet", 
                        methodName = "TestAdd",
                        svrMethodData = {tonumber(tempStr),1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 时装
        {
            editHint = "时装模型Id",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Fashion", 
                        methodName = "GetFashionForTest",
                        svrMethodData = {tonumber(tempStr),1},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },

        -- 珍兽
        {
            editHint = "珍兽模型ID",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then

                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Zhenshou", 
                        methodName = "GetZhenshou",
                        svrMethodData = {tonumber(tempStr), 1},
                        callbackNode = self,
                        callback = function(response)
                            dump(response, "sssaaaaa")
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },

        -- 神兵碎片
        {
            editHint = "神兵碎片",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local modelId = tonumber(self.mGetGoodsInfo[tempIndex].modelIdEdit:getText())
                    local tempModel = TreasureDebrisModel.items[modelId]
                    self:requestAddGameRecoure(tempModel.typeID, modelId, 1)
                end
            end
        },

        -- 战斗产出的星星
        {
            editHint = "战斗产出的星星",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempStr = self.mGetGoodsInfo[tempIndex].modelIdEdit:getText()
                    HttpClient:request({
                        moduleName = "Player", 
                        methodName = "AddStarCount",
                        svrMethodData = {tonumber(tempStr)},
                        callbackNode = self,
                        callback = function(response)
                            if response and response.Status == 0 then 
                                ui.showFlashView(TR("添加成功"))
                            end
                        end
                    })
                end
            end
        },
        -- 物品道具
        {
            editHint = "道具",
            needNumber = true,
            modelIdEdit = nil,
            numberEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local modelId = tonumber(self.mGetGoodsInfo[tempIndex].modelIdEdit:getText())
                    local number = tonumber(self.mGetGoodsInfo[tempIndex].numberEdit:getText())
                    local tempModel = GoodsModel.items[modelId]
                    self:requestAddGameRecoure(tempModel.typeID, modelId, number)
                end
            end
        },
        -- 直接升级
        {
            editHint = "直接升到的等级",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                local modelIdEdit = self.mGetGoodsInfo[tempIndex] and self.mGetGoodsInfo[tempIndex].modelIdEdit
                if not modelIdEdit then
                    return 
                end
                -- 玩家信息
                local playerInfo = PlayerAttrObj:getPlayerInfo()
                local tempLv = tonumber(modelIdEdit:getText())
                if not tempLv or tempLv <= playerInfo.Lv then
                    ui.showFlashView(TR("你已达到该等级"))
                    return 
                end
                local tempLv = math.min(tempLv, PlayerConfig.items[1].maxPlayerLV)
                local needExp = PlayerLvRelation.items[tempLv].EXPTotal - playerInfo.EXP 
                self:requestAddGameRecoure(ResourcetypeSub.eEXP, 0, needExp)
            end
        },
        -- 差5点经验到达的等级
        {
            editHint = "差5点经验到达的等级",
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                local modelIdEdit = self.mGetGoodsInfo[tempIndex] and self.mGetGoodsInfo[tempIndex].modelIdEdit
                if not modelIdEdit then
                    return 
                end

                -- 玩家信息
                local playerInfo = PlayerAttrObj:getPlayerInfo()
                local tempLv = tonumber(modelIdEdit:getText())
                if not tempLv or tempLv <= playerInfo.Lv then
                    ui.showFlashView(TR("你已达到该等级"))
                    return 
                end
                local tempLv = math.min(tempLv, PlayerConfig.items[1].maxPlayerLV)
                local needExp = PlayerLvRelation.items[tempLv].EXPTotal - playerInfo.EXP - 5
                self:requestAddGameRecoure(ResourcetypeSub.eEXP, 0, needExp)
            end
        },
    }

    local tempList = {
        [ResourcetypeSub.eEXP] = 1101,    -- "经验值"
        [ResourcetypeSub.eVIT] = 1102,    -- "体力值"
        [ResourcetypeSub.eSTA] = 1103,    -- "耐力值"
        [ResourcetypeSub.eVIPEXP] = 1104,    -- "VIP经验值"
        [ResourcetypeSub.eDiamond] = 1111,    -- "元宝"
        [ResourcetypeSub.eGold] = 1112,    -- "铜币"
        [ResourcetypeSub.eContribution] = 1113,    -- "贡献"
        [ResourcetypeSub.ePVPCoin] = 1115,    -- "苍茫令"
        [ResourcetypeSub.eHeroCoin] = 1116,    -- "神魂"
        [ResourcetypeSub.eHeroExp] = 1117,    -- "灵晶"
        [ResourcetypeSub.eGDDHCoin] = 1119,    -- "如风令"
        [ResourcetypeSub.eBossCoin] = 1120,    -- "积分"
        [ResourcetypeSub.eMerit] = 1124,    -- "青天令"
        [ResourcetypeSub.eHonor] = 1125,    -- "荣誉"
        [ResourcetypeSub.eRedBagFund] = 1126,    -- "红包基金"
        [ResourcetypeSub.ePetEXP] = 1127,    -- "妖灵"
        [ResourcetypeSub.ePetCoin] = 1128,    -- "外功秘籍令"
        [ResourcetypeSub.eRebornCoin] = 1129,    -- "感悟灵晶"
        [ResourcetypeSub.eGodDomainGlory] = 1130,    -- "落英铃"
        [ResourcetypeSub.eXrxsStar] = 1131,    -- "赏金点"
        [ResourcetypeSub.eTaoZhuangCoin] = 1133,    -- "天玉"
        [ResourcetypeSub.eGuildMoney] = 1134,    -- "帮派资金"
        [ResourcetypeSub.eGuildActivity] = 1135,    -- "帮派活跃度"
        [ResourcetypeSub.eMedicineCoin] = 1137,    -- "药元"
        [ResourcetypeSub.eLoveFlower] = 1139,    -- "情花"
        [ResourcetypeSub.eGuildGongfuCoin] = 1138,    -- "帮派武技"
        [ResourcetypeSub.eYinQi] = 1140,    -- "阴气"
        [ResourcetypeSub.eYangQi] = 1141,    -- "阳气"
        [ResourcetypeSub.eXieQi] = 1142,    -- "邪气"
        [ResourcetypeSub.eHonorCoin] = 1143,    -- "江湖杀荣誉点"
        [ResourcetypeSub.eZhenshouExp] = 1144, -- "兽粮"
        [ResourcetypeSub.eZhenshouCoin] = 1145, -- "珍兽精华"
        [ResourcetypeSub.eZslyCoin] = 1146,    -- "兽魂"
    }
    for key, value in pairs(tempList) do
        local tempItem = {
            editHint = ResourcetypeSubName[key],
            modelIdEdit = nil,
            onBtnClick = function(pSender, eventName)
                local tempIndex = pSender.index
                if (tempIndex <= #self.mGetGoodsInfo and self.mGetGoodsInfo[tempIndex].modelIdEdit) then
                    local tempCount = tonumber(self.mGetGoodsInfo[tempIndex].modelIdEdit:getText())
                    self:requestAddGameRecoure(key, 0, tempCount)
                end
            end
        }
        table.insert(self.mGetGoodsInfo, tempItem)
    end

    local listSize = cc.size(620, 1000)

    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(listSize)
    self.mListView:setPosition((640 - listSize.width) / 2, 0)
    self.mParentNode:addChild(self.mListView)

    local cellSize = cc.size(listSize.width, 150)
    for index, item in ipairs(self.mGetGoodsInfo) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)

        local cell = ui.newScale9Sprite("c_17.png", cellSize)
        cell:setPosition(cc.p(cellSize.width / 2, cellSize.height / 2))
        lvItem:addChild(cell)
        self.mListView:pushBackCustomItem(lvItem)


        local editBox = ui.newEditBox({
            image = "c_64.png",
            size = cc.size(270, 40),
            fontColor = Enums.Color.eRed,
            placeColor = Enums.Color.eRed,
        })
        editBox:setFontSize(19)
        editBox:setPosition(20, cellSize.height * 0.5)
        editBox:setAnchorPoint(cc.p(0, 0.5))
        editBox:setPlaceHolder(item.editHint)
        cell:addChild(editBox)
        item.modelIdEdit = editBox

        if item.needNumber then
            local tempEdit = ui.newEditBox({
                image = "c_64.png",
                size = cc.size(120, 40),
                fontColor = Enums.Color.eDarkGreen,
                placeColor = Enums.Color.eDarkGreen,
            })
            tempEdit:setFontSize(19)
            tempEdit:setPosition(300, cellSize.height * 0.5)
            tempEdit:setAnchorPoint(cc.p(0, 0.5))
            tempEdit:setPlaceHolder(TR("数量"))
            cell:addChild(tempEdit)
            item.numberEdit = tempEdit
        end

        local tempBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("获取"),
            position = cc.p(cellSize.width * 0.9, cellSize.height * 0.5),
            clickAction = item.onBtnClick,
        })
        tempBtn:setAnchorPoint(cc.p(1.0, 0.5))
        lvItem:addChild(tempBtn)
        tempBtn:setTag(index)
        tempBtn.index = index
    end
end

-- 网络请求相关函数 
function GodLayer:requestAddGameRecoure(resourcetypeSub, modelId, number)
    local tempStr = string.format("%d,%d,%d", resourcetypeSub or 0, modelId or 0, number or 1)
    HttpClient:request({
        moduleName = "Player", 
        methodName = "AddGameRecoure",
        svrMethodData = {tempStr},
        callbackNode = self,
        callback = function(response)
            if response and response.Status == 0 then 
                ui.showFlashView(TR("添加成功"))
            end
        end
    })
end

return GodLayer