--[[
文件名：GuildExamineLayer.lua
描述：帮派人员审批页面
创建人：chenzhong
创建时间：2017.3.7
-- ]]

local GuildExamineLayer = class("GuildExamineLayer", function(params)
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)

--每页数量
local itemNumsOnePage = 8

function GuildExamineLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    --排序Id
    self.sortID = 1
    --当前已加载的listview条目
    self.nowAddItemNum = 0

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --初始化页面控件
    self:initUI()

    --请求接口
    self:requestGetApplyList()
end

--初始化页面控件
function GuildExamineLayer:initUI()
	--背景
    local bgSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(595, 1040),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn)

    --免审批checkBox
    self.checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        --imageScale = 1.5,
        callback = function(state)
            if state == true then
                self:requestAlterAutoApply(1)
            else
                self:requestAlterAutoApply(0)
            end
        end
    })
    self.checkBox:setAnchorPoint(cc.p(0.5, 0.5))
    self.checkBox:setPosition(cc.p(55, 1042))
    self.mParentLayer:addChild(self.checkBox)

    --免审批label
    local showLabel = ui.newLabel({
        text = TR("免审批"),
        --font = _FONT_PANGWA,
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
    })
    showLabel:setAnchorPoint(cc.p(0, 0.5))
    showLabel:setPosition(cc.p(75, 1042))
    self.mParentLayer:addChild(showLabel)

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 900))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(320, 1005)
    self.mParentLayer:addChild(listBg)
end

-- 对listView进行排序
function GuildExamineLayer:sortListView()
	local sortData = {
		[1] = {
			text = TR("等级排序"),
			sortFunc = function(a, b) return a.Lv > b.Lv end
		},
		[2] = {
			text = TR("VIP排序"),
			sortFunc = function(a, b) return a.Vip > b.Vip end
		},
		[3] = {
			text = TR("战力排序"),
			sortFunc = function(a, b) return a.FAP > b.FAP end
		},
	}

	self.sortID = self.sortID + 1
    if self.sortID > 3 then
        self.sortID = 1
    end

    self.sortBtn:setTitleText(sortData[self.sortID].text)

    --刷新listView
    if #self.applyList > 0 then
    	table.sort(self.applyList, sortData[self.sortID].sortFunc)
        self:refreshListView(true)
    end
end

--请求接口后对控件状态进行刷新
function GuildExamineLayer:refreshNodes()
	--刷新初始面审批状态
	if self.iAutoApply then
        self.checkBox:setCheckState(true)
    else
        self.checkBox:setCheckState(false)
    end

    --根据是否有数据来决定是否添加Listview
    if #self.applyList == 0 then
    	if not tolua.isnull(self.applyListView) then
    		self.applyListView:removeFromParent()
    		self.applyListView = nil
    	end

    	if not self.noReportLabel then
		   	-- self.noReportLabel = ui.newLabel({
		    --     text = TR("暂无人员申请"),
		    --     size = 40,
		    --     color = Enums.Color.eBlack
		    -- })
            self.noReportLabel = ui.createEmptyHint(TR("暂无人员申请"))
		    self.noReportLabel:setPosition(320, 630)
		    self.mParentLayer:addChild(self.noReportLabel)
		end
	else
		if not tolua.isnull(self.noReportLabel) then
    		self.noReportLabel:removeFromParent()
    		self.noReportLabel = nil
    	end

    	if not self.applyListView then
    		--成员列表
		    self.applyListView = ccui.ListView:create()
		    self.applyListView:setContentSize(cc.size(610, 880))
		    self.applyListView:setAnchorPoint(cc.p(0.5,1))
		    self.applyListView:setPosition(cc.p(320,  995))
		    self.applyListView:setItemsMargin(10)
		    self.applyListView:setBounceEnabled(true)
		    self.mParentLayer:addChild(self.applyListView)

		    self.applyListView:addScrollViewEventListener(function(sender, eventType)
		        if eventType == 6 then  --BOUNCE_BOTTOM
		            self:refreshListView()
		        end
		    end)
		end
	end
end

--刷新列表
--isReSort 是否重新排序
function GuildExamineLayer:refreshListView(isReSort)
	if isReSort then
		self.nowAddItemNum = 0 --重新加载
		self.applyListView:removeAllItems()
	end

	for i =1,itemNumsOnePage do  --每页8个
    	if self.nowAddItemNum >= #self.applyList then
    		break
    	end

    	self.nowAddItemNum = self.nowAddItemNum + 1
    	local data = self.applyList[self.nowAddItemNum]
    	self.applyListView:pushBackCustomItem(self:createPlayerCell(data, self.nowAddItemNum))
    end
end

--data 一个玩家的信息
--index  --序目
function GuildExamineLayer:createPlayerCell(data, index)
	-- 初始化数据
    local infoItem = data

    --定义大小
    local width = 610
    local height = 120

    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cc.size(width, height))

    --背景
    local cellSprite = ui.newScale9Sprite("c_18.png")
    cellSprite:setContentSize(cc.size(width-10, height))
    cellSprite:setPosition(width / 2, height / 2)
    custom_item:addChild(cellSprite)

    -- 创建header
    local header = CardNode.createCardNode({
    	resourceTypeSub = ResourcetypeSub.eHero,
        modelId = infoItem.HeadImageId,
        fashionModelID = infoItem.FashionModelId,
        IllusionModelId = infoItem.IllusionModelId,
        pvpInterLv = infoItem.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function ()

        end
        })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(25, 60))
    cellSprite:addChild(header)

    -- 显示等级
    local nameLabel = ui.newLabel({
        text = infoItem.Name,
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLabel:setAnchorPoint(cc.p(0, 1))
    nameLabel:setPosition(cc.p(125, 105))
    cellSprite:addChild(nameLabel)
    

    -- 显示VIP
    local vipLabel = ui.newLabel({
        text = TR("VIP %s", infoItem.Vip),
        size = 22,
        color = Enums.Color.eNormalYellow,
    })
    vipLabel:setAnchorPoint(cc.p(0, 1))
    vipLabel:setPosition(cc.p(125, 45))
    cellSprite:addChild(vipLabel)

    -- 设置战力
    local fapText = tostring(infoItem.FAP)
    if (infoItem.FAP >= 1000000) then
        fapText = math.floor(infoItem.FAP / 10000) .. TR("万")
    end
    local fapLabel = ui.newLabel({
        text = TR("战力: #d27b00%s", fapText),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    fapLabel:setAnchorPoint(cc.p(0, 1))
    fapLabel:setPosition(cc.p(125, 75))
    cellSprite:addChild(fapLabel)

    -- 设置同意按钮
    local agreeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("同意"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(460, 60),
        clickAction = function()
            self:requestManageApply(infoItem.PlayerId, 1, custom_item)
        end,
    })
    agreeBtn:setSwallowTouches(false)
    custom_item:addChild(agreeBtn)

    -- 设置拒绝按钮
    local refuseBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("拒绝"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(315, 60),
        clickAction = function()
            self:requestManageApply(infoItem.PlayerId, 0, custom_item)
        end,
    })
    refuseBtn:setSwallowTouches(false)
    custom_item:addChild(refuseBtn)

    return custom_item
end

-- =============================== 请求服务器数据相关函数 ===================

--请求申请列表
function GuildExamineLayer:requestGetApplyList()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetApplyList",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value

            --申请列表
            self.applyList = value.ApplyListInfo
            --是否免审批
            self.iAutoApply = value.IsAutoApply

            --默认按等级排序
            table.sort(self.applyList, function(a, b)
            	return a.Lv > b.Lv
            end)

            self:refreshNodes()
            self:refreshListView()
        end,
    })
end

--切换免审批状态
--byte  1免审批 0非免审批
function GuildExamineLayer:requestAlterAutoApply(byte)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "AlterAutoApply",
        svrMethodData = {byte},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.iAutoApply = byte
        end,
    })
end

--处理拒绝或者同意玩家的请求
--playerId 处理的玩家的Id
--byte    同意还是拒绝  1同意 0拒绝
--layout 操作的列表子对象
function GuildExamineLayer:requestManageApply(playerId, byte, layout)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "ManageApply",
        svrMethodData = {playerId, byte},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	if response.Status == -3409 or response.Status == -3404 then
	                MsgBoxLayer.addOKLayer(TR("该玩家进入帮派了或者被其他帮派接纳了哦"))
                    local index = self.applyListView:getIndex(layout)
	                table.remove(self.applyList, index + 1)
            		self.applyListView:removeItem(index)
            		self.nowAddItemNum = self.nowAddItemNum - 1

	                return true
	            elseif errorCode == -3406 then
	                ui.showFlashView({text = TR("帮派成员已经满了哦")})

	                return true
	            elseif errorCode == -3408 then
	                MsgBoxLayer.addOKLayer(TR("你已经没有权限了"), TR("提示"),{
	                	clickAction = function()
	                		LayerManager.removeLayer(self)
	                	end
	                })
	                return true
	            else
	                return false
	            end

                return
            end

            --删除处理过的数据
            local index = self.applyListView:getIndex(layout)

            table.remove(self.applyList, index + 1)
            self.applyListView:removeItem(index)
            self.nowAddItemNum = self.nowAddItemNum - 1

            --如果是最后一条
            if #self.applyList == 0 then
            	self:refreshNodes()
                return
            end

            --如果小于8条  自动添加新的数据
            if #self.applyListView:getItems() < itemNumsOnePage then
            	self:refreshListView()
            end
        end,
    })
end

-- 一键拒绝所有申请
function GuildExamineLayer:requestOneKeyRefuseApply()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "OneKeyRefuseApply",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

			self.applyList = {}
            self:refreshNodes()
        end,
    })
end

return GuildExamineLayer