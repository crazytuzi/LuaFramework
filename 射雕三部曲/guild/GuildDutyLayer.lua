--[[
    文件名：GuildDutyLayer
    描述：帮派职务页面
    创建人：chenzhong
    创建时间：2017.3.16
-- ]]

local GuildDutyLayer = class("GuildDutyLayer",function()
	return display.newLayer()
end)

function GuildDutyLayer:ctor()
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()

    self:requestGetGuildMembers()
end

function GuildDutyLayer:initUI()
    -- 背景
    local backSprite  = ui.newSprite("c_34.jpg")
    backSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(backSprite)

    local grayLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 190))
    grayLayer:setContentSize(640, 1136)
    grayLayer:setIgnoreAnchorPointForPosition(false)
    grayLayer:setAnchorPoint(0.5, 0.5)
    grayLayer:setPosition(320, 568)
    self.mParentLayer:addChild(grayLayer)

    self.backImageSprite = ui.newSprite("bp_26.png")
    self.backImageSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.backImageSprite)
    self.backImageSize = self.backImageSprite:getContentSize()

    --标题
    local titleLabel = ui.newLabel({
        text = TR("职位任免"),
        size = 30,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        outlineSize = 2,
        x = self.backImageSize.width/2,
        y = self.backImageSize.height - 35,
    })
    self.backImageSprite:addChild(titleLabel)

    --关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(self.backImageSize.width, self.backImageSize.height),
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    cancelBtn:setAnchorPoint(1,1)
    self.backImageSprite:addChild(cancelBtn)
    
end

--添加职位按钮和label
function GuildDutyLayer:addDutyManaUis()
    local memberData = self.GuildMembersInfo

    local postData = {
        hzData = {},
        fhzData = {},
        jyData = {}
    }

    local isHz = false  --自己是否是帮主

    local myPostId = GuildObj:getPlayerGuildInfo().PostId
    if myPostId == 34001001 then
        isHz = true
    end

    for i,v in ipairs(memberData) do
        if v.PostId == 34001001 then --帮主
            table.insert(postData.hzData, v)
        elseif v.PostId == 34001002 then  --副帮主
            table.insert(postData.fhzData, v)
        elseif v.PostId == 34001003 then  --精英
            table.insert(postData.jyData, v)
        end
    end

    local spriteData = {
        [1] = {
            image = "bp_20.png",
            position = cc.p(315, 734),
        },
        [2] = {
            image = "bp_18.png",
            position = cc.p(175, 531),
        },
        [3] = {
            image = "bp_18.png",
            position = cc.p(463, 531),
        },
        [4] = {
            image = "bp_21.png",
            position = cc.p(102, 325),
        },
        [5] = {
            image = "bp_21.png",
            position = cc.p(252, 325),
        },
        [6] = {
            image = "bp_21.png",
            position = cc.p(390, 325),
        },
        [7] = {
            image = "bp_21.png",
            position = cc.p(540, 325),
        }
    }
    local btnData = {
        [1] = {
            position = cc.p(315, 664),  --按钮的位置
            item = postData.hzData[1],   --对应的数据
            btnPost = 34001001   --每个按钮对应的权限id
        },
        [2] = {
            position = cc.p(175, 461),
            item = postData.fhzData[1],
            btnPost = 34001002
        },
        [3] = {
            position = cc.p(463, 461),
            item = postData.fhzData[2],
            btnPost = 34001002
        },
        [4] = {
            position = cc.p(102, 250),
            item = postData.jyData[1],
            btnPost = 34001003
        },
        [5] = {
            position = cc.p(252, 250),
            item = postData.jyData[2],
            btnPost = 34001003
        },
        [6] = {
            position = cc.p(390, 250),
            item = postData.jyData[3],
            btnPost = 34001003
        },
        [7] = {
            position = cc.p(540, 250),
            item = postData.jyData[4],
            btnPost = 34001003
        },
    }

    --添加职位按钮
    local dutyButtons = {}
    local nameLabel = {}
    local headerSpr = {}
    local postSprite = {}

    local function changeHeader(headId, index, PVPInterLv, FashionModelId)
        if headerSpr[index] then
            headerSpr[index]:removeFromParent()
            headerSpr[index] = nil
        end

        local pos = cc.p(btnData[index].position.x, btnData[index].position.y)

        if headId then
            headerSpr[index] = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = headId,
                pvpInterLv = PVPInterLv,
                fashionModelID = FashionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                onClickCallback = function ()

                end
                })
            headerSpr[index]:setPosition(pos)
            headerSpr[index]:setSwallowTouches(false)
            headerSpr[index]:setAnchorPoint(cc.p(0.5,0.5))
            self.backImageSprite:addChild(headerSpr[index])
        else
            headerSpr[index] = ui.newLabel({
                text = TR("虚 位\n以 待"),
                size = 24,
            })
            headerSpr[index]:setPosition(pos)
            self.backImageSprite:addChild(headerSpr[index])
        end
    end
    -- 职位图标
    for i,v in ipairs(spriteData) do
        postSprite[i] = ui.newSprite(v.image)
        postSprite[i]:setPosition(v.position)
        self.backImageSprite:addChild(postSprite[i])
    end

    for i,v in ipairs(btnData) do
        --图像按钮
        dutyButtons[i] = ui.newButton({
            normalImage = "c_04.png",
            position = v.position,
            anchorPoint = cc.p(0.5, 0.5),
            clickAction = function (sender)
                if not GuildObj:havePost(GuildAuth.ePostChange) or myPostId >= v.btnPost then
                    ui.showFlashView(TR("您没有任命或罢免职位的权限"))
                    return
                end

                if sender.id == 0 then
                    -- 任命职位
                    LayerManager.addLayer({
                        name = "guild.GuildDutyChoMemLayer",
                        zOrder = Enums.ZOrderType.ePopLayer,
                        data = {
                            callBack = function (mid, mname, mheadId, PVPInterLv)
                                self:requestPostChange(mid, v.btnPost, function()
                                    --先查找是否成员从一个职位换到另一个职位
                                    for f = 1, 7 do
                                        if dutyButtons[f].id == mid then
                                            dutyButtons[f].id  = 0
                                            dutyButtons[f].name = ""
                                            nameLabel[f]:setString("")
                                            changeHeader(nil, f, nil)
                                            break
                                        end
                                    end

                                    --再改变自身的状态
                                    sender.id =  mid
                                    sender.name = mname

                                    --改变ui状态
                                    nameLabel[i]:setString(sender.name)
                                    changeHeader(mheadId, i, PVPInterLv)
                                    --通知帮派信息改变
                                    Notification:postNotification(EventsName.eGuildHomeAll)
                                end)
                            end,
                            setPostId = btnData[i].btnPost,
                            isZhuanR = false
                        },
                        cleanUp = false
                    })
                else
                    -- 罢免职位
                    MsgBoxLayer.addOKLayer(TR("您确定要罢免%s的职务吗？", sender.name), TR("提示"),
                        {{text = TR("确定"), clickAction = function(okLyaer)
                            self:requestPostChange(sender.id, 34001004, function()
                                --改变数据
                                sender.id =  0    --代表职位空缺
                                sender.name = ""

                                --改变ui状态
                                nameLabel[i]:setString("")
                                changeHeader(nil, i, nil)

                                LayerManager.removeLayer(okLyaer)
                            end)
                        end}}, {}
                    )
                end
            end
        })
        dutyButtons[i].id = v.item and v.item.Id or 0    --代表职位空缺
        dutyButtons[i].name = v.item and v.item.Name or ""
        dutyButtons[i]:setPressedActionEnabled(false)
        self.backImageSprite:addChild(dutyButtons[i])

        --玩家头像HeadImageId
        changeHeader(v.item and v.item.HeadImageId, i, v.item and v.item.DesignationId, v.item and v.item.FashionModelId)

        --玩家名字
        nameLabel[i] = ui.newLabel({
            text = v.item and v.item.Name or "",
            size = 22,
            x = v.position.x,
            y = v.position.y - 75,
            color = Enums.Color.eRed,
        })
        self.backImageSprite:addChild(nameLabel[i])
    end
    dutyButtons[1]:setEnabled(false)  --帮主的头像应该不能被点击

    -- 添加操作按钮
    local function addCtrlButton(strText, posX, clickFunc)
        local jsBtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(posX, 120),
            text = strText,
            clickAction = clickFunc
        })
        self.backImageSprite:addChild(jsBtn)
    end

    if isHz then
        addCtrlButton(TR("解散"), self.backImageSize.width * 0.75, function (sender)
            --从缓存得到帮派等级
            local nowLv = 0
            local guildBulidInfo = GuildObj:getGuildBuildInfo()
            for i,v in ipairs(guildBulidInfo) do
                if v.BuildingId == 34004000 then --大厅等级就是帮派等级
                    nowLv = v.Lv
                end
            end
            if  nowLv > GuildConfig.items[1].dismissGuildLVMax then
                ui.showFlashView(TR("大于%d级的帮派不能解散", GuildConfig.items[1].dismissGuildLVMax))
                return
            end

            MsgBoxLayer.addOKLayer(
                TR("您确定要解散帮派吗？"),
                TR("提示"),
                {{
                    text = TR("确定"),
                    clickAction = function()
                        self:requestDismissGuild()
                    end
                }},{})
        end)

        addCtrlButton(TR("转让"), self.backImageSize.width * 0.25, function (sender)
            if dutyButtons[2].id == 0 and dutyButtons[3].id == 0 then
                ui.showFlashView(TR("只能转让给副帮主，请先任命一位副帮主"))
                return
            end

            LayerManager.addLayer({
                name = "guild.GuildDutyChoMemLayer",
                zOrder = Enums.ZOrderType.ePopLayer,
                data = {
                    setPostId = nil,
                    isZhuanR = true,
                    callBack = function (mid, mname, mheadId)
                        self:requestPostAssignment(mid)
                    end
                },
                cleanUp = false
            })
        end)
    else
        addCtrlButton(TR("弹劾帮主"), self.backImageSize.width * 0.25, function (sender)
            --只要找到一个权限大于自己的，且7天内上过线的，即代表自己无法弹劾
            local isBmBtnEnabled = true
            for i,v in ipairs(btnData) do
                if v.item and MqTime.toHour(v.item.OutTime) < (GuildConfig.items[1].impeachOfflineTimeMin / 24) and v.item.PostId < myPostId then
                    isBmBtnEnabled = false
                    break
                end
            end
            if (isBmBtnEnabled == false) then
                MsgBoxLayer.addOKLayer(TR("有更高职位的成员在7天内上线过，您暂时还无权进行弹劾"))
                return
            end

            MsgBoxLayer.addOKLayer(
                TR("弹劾帮主将消耗%d元宝，成功后您将成为新的帮主，确定要弹劾吗？", GuildConfig.items[1].impeachUseDiamond),
                TR("提示"),
                {{
                    text = TR("确定"),
                    clickAction = function(okLyaer)
                        if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, GuildConfig.items[1].impeachUseDiamond) then
                            return
                        end
                        self:requestGuildImpeach()
                        LayerManager.removeLayer(okLyaer)
                    end
                }},{})
        end)

        addCtrlButton(TR("退出帮派"), self.backImageSize.width * 0.75, function (sender)
            MsgBoxLayer.addOKLayer(
                TR("每日第二次退出帮派后需要次日才能加入帮派,是否确定退出帮派?"),
                TR("提示"),
                {{text = TR("确定"), clickAction = function(okLyaer)
                    self:requesetExitGuild()

                    LayerManager.removeLayer(okLyaer)
                end}},{})
        end)
    end

    -- 如果是帮主有更名的权利
    local myPostId = GuildObj:getPlayerGuildInfo().PostId
    if myPostId == 34001001 then 
        addCtrlButton(TR("更名"), self.backImageSize.width * 0.5, function (sender)
            LayerManager.addLayer({
                name    = "guild.GuildModifyNameLayer",
                data    = {},
                cleanUp = false
            })
        end)
    end 
end

-- =============================== 请求服务器数据相关函数 ===================

--请求成员列表
function GuildDutyLayer:requestGetGuildMembers()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildMembers",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value

            self.GuildMembersInfo = value.GuildMembersInfo

            self:addDutyManaUis()
        end,
    })
end

--退出帮派
function GuildDutyLayer:requesetExitGuild()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "ExitGuild",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            --转到游戏主页
            LayerManager.addLayer({
                name = "home.HomeLayer",
                isRootLayer = true,
            })

            --清除帮派缓存数据
            GuildObj:reset()
        end,
    })
end

--弹劾帮主
function GuildDutyLayer:requestGuildImpeach()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildImpeach",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            --刷新页面
            self.mParentLayer:removeAllChildren()
            self:initUI()
            self:requestGetGuildMembers()
        end,
    })
end

--转让帮派
--id  转让给的玩家的id
function GuildDutyLayer:requestPostAssignment(id)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "PostAssignment",
        svrMethodData ={id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("转让成功"))
            LayerManager.removeLayer(self)
        end,
    })
end

--解散帮派
function GuildDutyLayer:requestDismissGuild()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "DismissGuild",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            --转到游戏主页
            LayerManager.addLayer({
                name = "home.HomeLayer",
                isRootLayer = true,
                })

            --清除帮派缓存数据
            GuildObj:reset()
        end,
    })
end

--职位更改
--id 更改的玩家id
--postId 帮派职位Id
function GuildDutyLayer:requestPostChange(id, postId, callBack)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "PostChange",
        svrMethodData = {id, postId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            end
            callBack()
        end,
    })
end

return GuildDutyLayer